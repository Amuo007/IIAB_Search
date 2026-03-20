#!/data/data/com.termux/files/usr/bin/bash

echo ""
echo " ___ ___    _    ____    ____                      _     "
echo "|_ _|_ _|  / \  | __ )  / ___|  ___  __ _ _ __ ___| |__  "
echo " | | | |  / _ \ |  _ \  \___ \ / _ \/ _\` | '__/ __| '_ \ "
echo " | | | | / ___ \| |_) |  ___) |  __/ (_| | | | (__| | | |"
echo "|___|___/_/   \_\____/  |____/ \___|\__,_|_|  \___|_| |_|"
echo ""
echo "  Setting up IIAB Search..."
echo ""

# Install packages (skip if root since pkg doesn't work as root)
if [ "$(id -u)" != "0" ]; then
  command -v python > /dev/null 2>&1 || pkg install -y python
  command -v ollama > /dev/null 2>&1 || pkg install -y ollama
  # lxml dependencies
  pkg install -y libxml2 libxslt
else
  echo "⚠ Running as root — skipping pkg install. Make sure python, ollama, libxml2, libxslt are installed."
fi

# Install pip deps
pip install -r requirements.txt

# Patch BASE_URL only if not already patched
grep -q 'localhost:8085' 1.py || sed -i 's|BASE_URL = .*|BASE_URL = "http://localhost:8085"|g' 1.py

# Start ollama and wait until it actually responds
if ! command -v ollama > /dev/null 2>&1; then
  echo "✗ ollama not found. Install it first: pkg install ollama"
  exit 1
fi

ollama serve &
echo "Waiting for Ollama..."
until curl -sf http://localhost:11434 > /dev/null 2>&1; do
  sleep 1
done
echo "✓ Ollama ready"

# Pull models only if not already downloaded
ollama list | grep -q "snowflake-arctic-embed:22m" || ollama pull snowflake-arctic-embed:22m
ollama list | grep -q "qwen2.5:0.5b"              || ollama pull qwen2.5:0.5b

echo ""
echo "✓ Setup complete! Run: bash run.sh"
