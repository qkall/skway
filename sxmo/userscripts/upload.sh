

# title="$icon_mov Upload File"
#!/usr/bin/env bash
set -euo pipefail

# Temporary file to store the selection from Yazi
CHOOSER_TMP=$(mktemp)

# 1. Launch Yazi in a terminal window as a file picker
if command -v foot >/dev/null 2>&1; then
    foot -e yazi --chooser-file="$CHOOSER_TMP"
elif [ -n "${TERMINAL:-}" ]; then
    $TERMINAL -e yazi --chooser-file="$CHOOSER_TMP"
else
    # Fallback if executed directly inside an active terminal session
    yazi --chooser-file="$CHOOSER_TMP"
fi

# Read selected file path
FILE=$(cat "$CHOOSER_TMP" 2>/dev/null || true)
rm -f "$CHOOSER_TMP"

if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  notify-send "Uploader" "No valid file selected."
  exit 1
fi

UPLOAD_SUCCESS=false
URL=""
SUCCESSFUL_HOST=""

# 2. Ask if the user wants to use Litterbox
USE_LITTERBOX=false
CHOICE=$(printf "No (Permanent hosts: envs.sh, x0.at, ttm.sh)\nYes (Litterbox temporary)" | wofi --show dmenu --prompt "Use Litterbox temporary host?")

if [[ "$CHOICE" == *"Yes"* ]]; then
  USE_LITTERBOX=true
fi

if [[ "$USE_LITTERBOX" == true ]]; then
  EXPIRY="$(printf "1h\n12h\n24h\n72h" | wofi --show dmenu --prompt "Select expiration time:")"
  [ -z "$EXPIRY" ] && EXPIRY="24h"
  
  HOST="https://litterbox.catbox.moe/resources/internals/api.php"
  RESP="$(curl -sS -m 30 -F "reqtype=fileupload" -F "time=${EXPIRY}" -F "fileToUpload=@${FILE}" "$HOST" 2>/dev/null)" || true
  URL="$(printf '%s' "$RESP" | tr -d '\r\n')"
  
  if [[ "$URL" =~ ^https?:// ]]; then
    UPLOAD_SUCCESS=true
    SUCCESSFUL_HOST="litterbox.catbox.moe"
  fi
else
  HOSTS=(
    "https://envs.sh"
    "https://x0.at"
    "https://ttm.sh"
  )

  for HOST in "${HOSTS[@]}"; do
    RESP="$(curl -sS -m 30 -F "file=@${FILE}" "$HOST" 2>/dev/null)" || continue
    URL="$(printf '%s' "$RESP" | tr -d '\r\n')"
    if [[ "$URL" =~ ^https?:// ]]; then
      UPLOAD_SUCCESS=true
      SUCCESSFUL_HOST="$HOST"
      break
    fi
  done
fi

if [[ "$UPLOAD_SUCCESS" == false ]]; then
  notify-send "Uploader" "Upload failed entirely. All hosts unreachable."
  exit 1
fi

if command -v wl-copy >/dev/null 2>&1; then
  printf '%s' "$URL" | wl-copy
fi

notify-send "Uploader" "Success via ${SUCCESSFUL_HOST}. URL copied!"
printf '%s\n' "$URL"
