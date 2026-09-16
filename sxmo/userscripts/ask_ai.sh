# title="$icon_fnd Ask AI"
#!/bin/bash
QUERY=$(echo "" | wofi --show dmenu --prompt "Ask AI Query:" --lines 1)
[ -z "$QUERY" ] && exit 0

ENCODED_QUERY=$(echo "$QUERY" | jq -sRr @uri)
URL="https://duckduckgo.com/?q=$ENCODED_QUERY&ia=chat"

librewolf --new-window "$URL" &
