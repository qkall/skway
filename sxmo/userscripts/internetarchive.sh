
# title="$icon_fnd Internet Archive"
#!/usr/bin/env bash
# ia-sxmo.sh - Internet Archive search and viewer with logging

LOG_FILE="$HOME/.cache/ia-sxmo.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "==================== $(date) ===================="

echo "Checking dependencies..."
for cmd in wofi ia mpv zathura nsxiv xdg-open; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "WARNING: Command '$cmd' not found in PATH."
    fi
done

QUERY=$(echo "" | wofi --show dmenu --prompt "Search Archive.org:" --lines 1)
echo "QUERY: '$QUERY'"
[ -z "$QUERY" ] && { echo "Query empty, exiting."; exit 0; }

CATEGORY=$(printf "any\nroms\nmovies\naudio\ntexts\nimage" | wofi --show dmenu --prompt "Category:")
echo "CATEGORY: '$CATEGORY'"
[ -z "$CATEGORY" ] && { echo "Category empty, exiting."; exit 0; }

if [ "$CATEGORY" = "any" ]; then
    SEARCH_STR="$QUERY"
elif [ "$CATEGORY" = "roms" ]; then
    SEARCH_STR="$QUERY AND (mediatype:software OR subject:rom)"
else
    SEARCH_STR="$QUERY AND mediatype:$CATEGORY"
fi
echo "SEARCH_STR: '$SEARCH_STR'"

echo "Executing ia search..."
RAW_SEARCH_OUTPUT=$(ia search "$SEARCH_STR" 2>&1)
EXIT_CODE=$?
echo "ia search exit code: $EXIT_CODE"

SEARCH_OUTPUT=$(echo "$RAW_SEARCH_OUTPUT" | sed -nE 's/.*"identifier": "([^"]+)".*/\1/p')
echo "ia search parsed output: $SEARCH_OUTPUT"

ITEM=$(echo "$SEARCH_OUTPUT" | head -n 50 | wofi --show dmenu --prompt "Select Item:")
echo "ITEM: '$ITEM'"
[ -z "$ITEM" ] && { echo "Item empty, exiting."; exit 0; }

echo "Executing ia list for item: $ITEM..."
LIST_OUTPUT=$(ia list "$ITEM" 2>&1)
EXIT_CODE=$?
echo "ia list exit code: $EXIT_CODE"
echo "ia list output: $LIST_OUTPUT"

FILE=$(echo "$LIST_OUTPUT" | grep -ivE "\.(xml|sqlite)$" | wofi --show dmenu --prompt "Select File:")
echo "FILE: '$FILE'"
[ -z "$FILE" ] && { echo "File empty, exiting."; exit 0; }

ACTION=$(printf "Temp / Play\nDownload Permanently" | wofi --show dmenu --prompt "Action:")
echo "ACTION: '$ACTION'"
[ -z "$ACTION" ] && { echo "Action empty, exiting."; exit 0; }

EXT="${FILE##*.}"
EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')
echo "EXT: '$EXT'"

FILE_URL=$(echo "$FILE" | sed 's/ /%20/g')
STREAM_URL="https://archive.org/download/${ITEM}/${FILE_URL}"
echo "STREAM_URL: '$STREAM_URL'"

ROM_EXT_REGEX="^(nes|sfc|smc|gb|gbc|gba|nds|3ds|n64|z64|v64|iso|bin|cue|chd|rvz|pbp|cso|gcm|xci|nsp|zip|7z)$"

launch_file() {
    local filepath="$1"
    local ext="$2"

    if [[ "$ext" =~ ^(pdf|epub|djvu|cbz)$ ]]; then
        echo "Opening with zathura..."
        zathura "$filepath"
    elif [[ "$ext" =~ ^(jpg|jpeg|png|gif|webp)$ ]]; then
        echo "Opening with nsxiv..."
        nsxiv "$filepath"
    elif [[ "$ext" =~ $ROM_EXT_REGEX ]]; then
        if command -v retroarch &> /dev/null; then
            echo "Opening ROM with RetroArch..."
            retroarch "$filepath"
        else
            echo "Opening ROM with xdg-open..."
            xdg-open "$filepath"
        fi
    else
        echo "Opening with xdg-open..."
        xdg-open "$filepath"
    fi
}

if [[ "$ACTION" == *"Temp"* ]]; then
    echo "Branch: Temp / Play"
    if [[ "$EXT" =~ ^(mp3|mp4|mkv|webm|ogg|flac|wav|m4a)$ ]]; then
        echo "Streaming media via mpv..."
        mpv "$STREAM_URL"
    else
        TMP_DIR=$(mktemp -d)
        echo "Created temp dir: $TMP_DIR"
        echo "Downloading to temp..."
        ia download "$ITEM" "$FILE" --destdir="$TMP_DIR"
        LOCAL_FILE="$TMP_DIR/$ITEM/$FILE"
        echo "LOCAL_FILE: '$LOCAL_FILE'"
        
        launch_file "$LOCAL_FILE" "$EXT"
        
        echo "Cleaning up temp dir..."
        rm -rf "$TMP_DIR"
    fi
else
    echo "Branch: Download Permanently"
    DL_DIR="$HOME/Downloads/InternetArchive"
    mkdir -p "$DL_DIR"
    echo "Downloading to $DL_DIR..."
    ia download "$ITEM" "$FILE" --destdir="$DL_DIR"
    LOCAL_FILE="$DL_DIR/$ITEM/$FILE"
    echo "LOCAL_FILE: '$LOCAL_FILE'"
    
    if [[ "$EXT" =~ ^(mp3|mp4|mkv|webm|ogg|flac|wav|m4a)$ ]]; then
        mpv "$LOCAL_FILE"
    else
        launch_file "$LOCAL_FILE" "$EXT"
    fi
fi

echo "Script finished successfully."
