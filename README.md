# IIAB Search Engine

A Google-style search interface for offline Wikipedia via [Kiwix](https://www.kiwix.org/), with AI-powered answer summaries — built to run locally on a Raspberry Pi or any IIAB (Internet-in-a-Box) server.

---

## Features

- 🔍 Full-text search over offline Wikipedia (via Kiwix)
- 🤖 AI keyword extraction for better search queries
- 📊 Semantic re-ranking of results using embeddings + FAISS
- ⚡ Streaming AI answer box (2–3 sentence summary)
- 📴 Fully offline — no internet required after setup

---

## How It Works

```
User query
    │
    ├─► /search
    │       ├─ Extract keywords       (qwen2.5:0.5b)
    │       ├─ Scrape Kiwix results   (requests + lxml)
    │       └─ Re-rank semantically   (mxbai-embed-large + FAISS)
    │
    └─► /ai
            └─ Stream 2–3 sentence answer  (qwen2.5:0.5b)
```

---

## Requirements

### Python dependencies

```bash
pip install -r requirements.txt
```

| Package | Version | Purpose |
|---|---|---|
| fastapi | 0.115.6 | Web framework |
| uvicorn | 0.32.1 | ASGI server |
| requests | 2.32.3 | HTTP scraping |
| lxml | 5.3.0 | HTML parsing |
| ollama | 0.4.4 | Local LLM client |
| faiss-cpu | 1.9.0 | Vector similarity search |
| numpy | 1.26.4 | Embedding math |

### Ollama models

Install [Ollama](https://ollama.com) then pull:

```bash
ollama pull qwen2.5:0.5b
ollama pull mxbai-embed-large
```

---

## Setup

```bash
# 1. Clone / copy project files
git clone <your-repo>
cd iiab-search

# 2. Install dependencies
pip install -r requirements.txt

# 3. Pull Ollama models
ollama pull qwen2.5:0.5b
ollama pull mxbai-embed-large

# 4. Make sure Kiwix is running at http://box
#    and the ZIM file matches the name in main.py:
#    ZIM = "wikipedia_en_all_maxi_2025-08"

# 5. Start the server
python main.py
```

Open **http://localhost:5000** in your browser.

---

## Project Structure

```
iiab-search/
├── main.py              # FastAPI backend
├── requirements.txt     # Python dependencies
├── README.md
└── static/
    ├── index.html       # Search homepage
    └── results.html     # Results page with AI answer box
```

---

## Configuration

Edit the top of `main.py` to match your setup:

```python
ZIM = "wikipedia_en_all_maxi_2025-08"   # Your Kiwix ZIM file name
BASE_URL = "http://box"                  # Your Kiwix server address
```

---

## Known Limitations

- **Slow on low-end hardware** — 25 embeddings are generated sequentially per search; expect 10–20s on a Raspberry Pi
- **AI answer has no article context** — the `/ai` endpoint answers from model knowledge only, not from the retrieved Wikipedia articles
- **No error handling** — if Kiwix is unreachable, the app will crash silently
