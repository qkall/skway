# title="$icon_bok Anna's Archive"
#!/usr/bin/env bash
# anna-sxmo.sh - Search Anna's Archive directly in LibreWolf via wofi

LOG_FILE="$HOME/.cache/anna-sxmo.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "==================== $(date) ===================="

echo "Checking dependencies..."
for cmd in wofi python3 librewolf; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "WARNING: Command '$cmd' not found in PATH."
    fi
done

DOMAIN="https://annas-archive.gl"
echo "DOMAIN: '$DOMAIN'"

QUERY=$(echo "" | wofi --show dmenu --prompt "Search Anna's:" --lines 1)
echo "QUERY: '$QUERY'"
[ -z "$QUERY" ] && { echo "Query empty, exiting."; exit 0; }

EXT=$(printf "any\nepub\npdf\ncbz\nmobi" | wofi --show dmenu --prompt "Format:")
echo "EXT: '$EXT'"
[ -z "$EXT" ] && { echo "Format empty, exiting."; exit 0; }

# Safely URL encode the query and format extension filter for the search URL
ENCODED_QUERY=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$QUERY")

SEARCH_URL="${DOMAIN}/search?q=${ENCODED_QUERY}"
if [ "$EXT" != "any" ]; then
    SEARCH_URL="${SEARCH_URL}&ext=${EXT}"
fi

echo "SEARCH_URL: '$SEARCH_URL'"
echo "Launching LibreWolf..."

librewolf "$SEARCH_URL" &

echo "Script finished successfully."
