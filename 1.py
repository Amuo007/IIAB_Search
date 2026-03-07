import requests
from lxml import html
import ollama
import faiss
import numpy as np
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, StreamingResponse

app = FastAPI()

ZIM = "wikipedia_en_all_maxi_2025-08"
BASE_URL = "http://box"

def extract_keywords(query):
    response = ollama.chat(
        model="qwen2.5:0.5b",
        messages=[
            {"role": "system", "content": "extract only the key search words from the user query. return only the keywords, nothing else."},
            {"role": "user", "content": query}
    a
    )
    return response['message']['content'].strip()

def scrape_kiwix(keywords):
    url = f"{BASE_URL}/kiwix/search?pattern={keywords}&books.name={ZIM}&start=0&pageLength=25"
    response = requests.get(url)
    tree = html.fromstring(response.content)
    results = []
    for li in tree.xpath('//div[@class="results"]//li'):
        try:
            title = li.xpath('.//a/text()')[0].strip()
            href = li.xpath('.//a/@href')[0]
            snippet = ' '.join(li.xpath('.//cite//text()')).strip()
            wordcount = li.xpath('.//div[@class="informations"]/text()')[0].strip()
            results.append({
                'title': title,
                'url': BASE_URL + href,
                'snippet': snippet,
                'wordcount': wordcount
            })
        except:
            continue
    return results

def embed(text):
    return np.array(ollama.embeddings(model="mxbai-embed-large", prompt=text)["embedding"], dtype=np.float32)

def rank_results(query, results):
    query_embedding = embed(query)
    title_embeddings = [embed(r['title']) for r in results]
    matrix = np.stack(title_embeddings)
    faiss.normalize_L2(matrix)
    faiss.normalize_L2(query_embedding.reshape(1, -1))
    index = faiss.IndexFlatIP(len(query_embedding))
    index.add(matrix)
    _, indices = index.search(query_embedding.reshape(1, -1), 25)
    return [results[i] for i in indices[0]]

@app.get("/search")
async def search(q: str):
    keywords = extract_keywords(q)
    results = scrape_kiwix(keywords)
    ranked = rank_results(q, results)
    return {'query': q, 'keywords': keywords, 'results': ranked}

@app.get("/ai")
async def ai_answer(q: str):
    def generate():
        stream = ollama.chat(
            model="qwen2.5:0.5b",
            messages=[
                {"role": "system", "content": "answer the user question briefly in 2-3 sentences."},
                {"role": "user", "content": q}
            ],
            stream=True
        )
        for chunk in stream:
            yield chunk['message']['content']
    return StreamingResponse(generate(), media_type="text/plain")

@app.get("/")
async def index():
    return FileResponse("static/index.html")

@app.get("/results")
async def results():
    return FileResponse("static/results.html")

app.mount("/static", StaticFiles(directory="static"), name="static")

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host='0.0.0.0', port=5000)