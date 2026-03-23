# IIAB Search Engine

A Google-style search interface for offline Wikipedia via [Kiwix](https://www.kiwix.org/), with AI-powered answer summaries — built to run locally on a Raspberry Pi or any IIAB (Internet-in-a-Box) server.

---

## Android Setup (Termux)

Run directly on your Android device using Termux.

### Requirements
- [Termux](https://f-droid.org/en/packages/com.termux/) installed from F-Droid
- IIAB running on the same device (Kiwix on `http://localhost:8085`)

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/Amuo007/iiab-search
cd iiab-search

# 2. Run it will set up and run 
bash setup.sh

```


## Raspberry Pi / IIAB Server Setup

### Requirements

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

```bash
ollama pull qwen2.5:0.5b
ollama pull snowflake-arctic-embed:22m
```

### Steps

```bash
# 1. Clone the repo
git clone <your-repo>
cd iiab-search

# 2. Install dependencies
pip install -r requirements.txt

# 3. Pull Ollama models
ollama pull qwen2.5:0.5b
ollama pull snowflake-arctic-embed:22m

# 4. Start the server
python 1.py
```

Open **http://localhost:5000** in your browser.

---

## How It Works

```
User query
    │
    ├─► /search
    │       ├─ Scrape Kiwix results   (requests + lxml)
    │       └─ Re-rank semantically   (snowflake-arctic-embed:22m + FAISS)
    │
    └─► /ai
            └─ Stream 2–3 sentence answer  (qwen2.5:0.5b)
```

---

## Features

- 🔍 Full-text search over offline Wikipedia and DevDocs (via Kiwix)
- 📊 Semantic re-ranking of results using embeddings + FAISS
- ⚡ Streaming AI answer box (2–3 sentence summary)
- 🖼️ Images page with masonry grid
- 💾 SQLite result caching (7-day TTL)
- 🔎 Autocomplete from cached queries
- 📴 Fully offline — no internet required after setup

---

## Configuration

Edit the top of `1.py` to match your setup:

```python
BASE_URL = "http://localhost:8085"  # Android (IIAB)
BASE_URL = "http://box"             # Raspberry Pi (IIAB)
```

---

## Project Structure

```
iiab-search/
├── 1.py                 # FastAPI backend
├── requirements.txt     # Python dependencies
├── setup.sh             # Android/Termux one-time setup
├── run.sh               # Android/Termux daily runner
├── README.md
└── static/
    ├── index.html       # Search homepage
    ├── results.html     # Results page with AI answer box
    └── images.html      # Images page
```

---

## Known Limitations

- **Slow on low-end hardware** — embeddings are generated per search; expect slower performance on older devices
- **AI answer has no article context** — the `/ai` endpoint answers from model knowledge only, not from retrieved articles
