# IIAB Search Engine

A Google-style search interface for offline Wikipedia and DevDocs via [Kiwix](https://www.kiwix.org/), with AI-powered answer summaries — built to run locally on a Raspberry Pi or any IIAB (Internet-in-a-Box) server.

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

# 2. Download ZIM files
bash download_zims.sh

# 3. Run setup and start (installs dependencies, pulls models, starts server)
bash setup.sh
```

To start the server on subsequent runs:

```bash
bash run.sh
```

---

## Raspberry Pi / IIAB Server Setup

### Requirements

```bash
pip install -r requirements.txt
```

| Package | Version | Purpose |
|---|---|---|
| fastapi | latest | Web framework |
| uvicorn | latest | ASGI server |
| requests | latest | HTTP scraping |
| lxml | latest | HTML parsing |
| ollama | latest | Local LLM client |
| faiss-cpu | latest | Vector similarity search |
| numpy | latest | Embedding math |

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

## ZIM Files

The following ZIM files are supported. Edit the `ZIMS` list in `1.py` to enable/disable sources:

| ZIM | Results | Images |
|---|---|---|
| wikipedia_en_all_maxi_2025-08 | 20 | ✅ |
| wikipedia_en_100_2026-01 | 5 | ✅ |
| devdocs_en_python_2026-02 | 5 | ❌ |
| devdocs_en_c_2026-01 | 5 | ❌ |
| devdocs_en_git_2026-01 | 5 | ❌ |
| devdocs_en_openjdk_2026-02 | 5 | ❌ |

> **Note:** `download_zims.sh` downloads all ZIMs except `wikipedia_en_all_maxi` (very large). Download it manually if needed.

---

## How It Works

```
User query
    │
    ├─► /suggest        ← SQLite prefix match on cached queries (autocomplete)
    │
    ├─► /search
    │       ├─ Scrape all Kiwix ZIMs in parallel   (ThreadPoolExecutor + lxml)
    │       ├─ Re-rank semantically                (snowflake-arctic-embed:22m + FAISS)
    │       └─ Cache results                       (SQLite, 7-day TTL)
    │
    ├─► /images
    │       ├─ Reuse ranked results (or run pipeline if not cached)
    │       └─ Scrape images from top result pages in parallel
    │
    └─► /ai
            └─ Stream 2–3 sentence answer  (qwen2.5:0.5b)
```

---

## Features

- 🔍 Full-text search over offline Wikipedia and DevDocs (via Kiwix)
- 📊 Semantic re-ranking of results using embeddings + FAISS
- ⚡ Streaming AI answer box (2–3 sentence summary)
- 🖼️ Images page with masonry grid and lightbox viewer
- 💾 SQLite result caching (7-day TTL)
- 🔎 Autocomplete from cached queries (prefix match)
- 🔀 Parallel scraping across all ZIM sources
- 📴 Fully offline — no internet required after setup

---

## Configuration

Edit the top of `1.py` to match your setup:

```python
BASE_URL = "http://localhost:8085"  # Android/Termux (IIAB)
BASE_URL = "http://box"             # Raspberry Pi (IIAB)
```

Adjust result counts and enabled ZIMs in the `ZIMS` list:

```python
ZIMS = [
    {"name": "wikipedia_en_all_maxi_2025-08", "count": 20, "has_images": True},
    {"name": "devdocs_en_python_2026-02",     "count": 5,  "has_images": False},
    # ...
]
```

---

## Project Structure

```
iiab-search/
├── 1.py                 # FastAPI backend (search, images, AI, suggest endpoints)
├── requirements.txt     # Python dependencies
├── setup.sh             # One-time setup (installs packages, pulls Ollama models)
├── run.sh               # Daily runner (starts Ollama + server)
├── download_zims.sh     # Downloads ZIM files to /library/zims/content/
├── README.md
└── static/
    ├── index.html       # Search homepage
    ├── results.html     # Results page with AI answer box and pagination
    └── images.html      # Images page with masonry grid and lightbox
```

---

## API Endpoints

| Endpoint | Description |
|---|---|
| `GET /search?q=` | Returns ranked search results (cached) |
| `GET /suggest?q=` | Returns autocomplete suggestions from cache |
| `GET /images?q=` | Returns scraped images from top results |
| `GET /ai?q=` | Streams a 2–3 sentence AI answer |
| `GET /` | Search homepage |
| `GET /results` | Results page |
| `GET /images-page` | Images page |

---

## Known Limitations

- **Slow on low-end hardware** — embeddings are generated per search on cache miss; expect slower performance on older devices
- **AI answer has no article context** — the `/ai` endpoint answers from model knowledge only, not from retrieved articles
- **`wikipedia_en_all_maxi` not in download script** — it's very large; download manually if needed
