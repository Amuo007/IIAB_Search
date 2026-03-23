echo "==> Downloading ZIM files..."
mkdir -p /library/zims/content
cd /library/zims/content

download_if_missing() {
  local url="$1"
  local file
  file="$(basename "$url")"
  if [ ! -f "$file" ]; then
    wget -c "$url"
  else
    echo "Skipping $file (already exists)"
  fi
}

download_if_missing https://download.kiwix.org/zim/wikipedia/wikipedia_en_100_2026-01.zim
download_if_missing https://download.kiwix.org/zim/devdocs/devdocs_en_python_2026-02.zim
download_if_missing https://download.kiwix.org/zim/devdocs/devdocs_en_c_2026-01.zim
download_if_missing https://download.kiwix.org/zim/devdocs/devdocs_en_git_2026-01.zim
download_if_missing https://download.kiwix.org/zim/devdocs/devdocs_en_openjdk_2026-02.zim

echo "==> Registering ZIMs with Kiwix..."
iiab-make-kiwix-lib
