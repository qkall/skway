# title="$icon_fnd DuckDuckGo"
#!/bin/bash
QUERY=$(echo "" | wofi --show dmenu --prompt "DuckDuckGo Search:" --lines 1)
[ -z "$QUERY" ] && exit 0

ENCODED_QUERY=$(echo "$QUERY" | jq -sRr @uri)
URL="https://duckduckgo.com/?q=$ENCODED_QUERY"

librewolf --new-window "$URL" &
