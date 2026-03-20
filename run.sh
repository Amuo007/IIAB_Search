#!/data/data/com.termux/files/usr/bin/bash

# Start ollama if not already running
if ! pgrep -x "ollama" > /dev/null; then
  echo "Starting Ollama..."
  ollama serve &
  until curl -sf http://localhost:11434 > /dev/null 2>&1; do
    sleep 1
  done
  echo "✓ Ollama ready"
else
  echo "✓ Ollama already running"
fi

python 1.py
