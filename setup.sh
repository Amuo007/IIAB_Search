#!/usr/bin/env bash

echo ""
echo " ___ ___    _    ____    ____                      _     "
echo "|_ _|_ _|  / \  | __ )  / ___|  ___  __ _ _ __ ___| |__  "
echo " | | | |  / _ \ |  _ \  \___ \ / _ \/ _\` | '__/ __| '_ \ "
echo " | | | | / ___ \| |_) |  ___) |  __/ (_| | | | (__| | | |"
echo "|___|___/_/   \_\____/  |____/ \___|\__,_|_|  \___|_| |_|"
echo ""
echo "  Setting up IIAB Search..."
echo ""


set -euo pipefail

echo "==> Updating apt..."
apt update

echo "==> Installing Debian packages..."
apt install -y \
  curl \
  python3 \
  python3-numpy \
  python3-lxml \
  python3-fastapi \
  python3-requests \
  python3-httpx \
  python3-ollama \
  python3-faiss \
  python3-bs4 \
  python3-cssselect \
  python3-html5lib \
  python3-soupsieve

echo "==> Verifying Python imports..."
python3 -c "import numpy, lxml, fastapi, requests, ollama, faiss; print('all good')"

echo "==> Installing Ollama if missing..."
if ! command -v ollama >/dev/null 2>&1; then
  curl -fsSL https://ollama.com/install.sh | sh
else
  echo "Ollama already installed."
fi

echo "==> Stopping old Ollama server if running..."
pkill -f "ollama serve" 2>/dev/null || true

echo "==> Starting Ollama in background..."
nohup ollama serve > /root/ollama.log 2>&1 &

echo "==> Waiting for Ollama API..."
for i in $(seq 1 20); do
  if curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "Ollama is up."
    break
  fi
  sleep 1
done

echo "==> Pulling models..."
ollama pull qwen2.5:0.5b
ollama pull snowflake-arctic-embed:22m

echo "==> Final checks..."
python3 -c "import numpy, lxml, fastapi, requests, ollama, faiss; print('python imports OK')"
ollama list

echo
echo "==> Setup complete."
echo "Ollama log: /root/ollama.log"
echo "Run your project with:"
echo "bash run.sh"
