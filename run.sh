#!/data/data/com.termux/files/usr/bin/bash
 
echo ""
echo " ___ ___    _    ____    ____                      _     "
echo "|_ _|_ _|  / \  | __ )  / ___|  ___  __ _ _ __ ___| |__  "
echo " | | | |  / _ \ |  _ \  \___ \ / _ \/ _\` | '__/ __| '_ \ "
echo " | | | | / ___ \| |_) |  ___) |  __/ (_| | | | (__| | | |"
echo "|___|___/_/   \_\____/  |____/ \___|\__,_|_|  \___|_| |_|"
echo ""
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
