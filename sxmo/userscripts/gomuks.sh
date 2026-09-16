#!/bin/sh
# title="$icon_trm Gomuks Update"
# buildmuks.sh - Update, build, and restart gomuks
# Inspired by magdesign sxmop6 userscripts

# 1. Resolve absolute path so Wofi executes the correct file
SCRIPT_PATH=$(realpath "$0")

# 2. Relaunch via Sxmo's default terminal wrapper if not in a TTY
if [ ! -t 0 ]; then
    exec sxmo_terminal.sh -- sh -c "'$SCRIPT_PATH'"
    exit 0
fi

NOTIFY="sxmo_notify_user.sh"
TITLE="Gomuks Update"

# 3. Notification wrapper for both terminal output and Sxmo UI
notify() {
    "$NOTIFY" "$1" "$2" 2>/dev/null || true
    echo "[$1] $2"
}

notify "$TITLE" "Navigating to source..."
cd "$HOME/gomuks" || { notify "$TITLE" "Error: ~/gomuks not found!"; sleep 5; exit 1; }

notify "$TITLE" "Pulling latest changes..."
if ! git pull; then
    notify "$TITLE" "Git pull failed!"
    sleep 5
    exit 1
fi

notify "$TITLE" "Building... this may take a while."
if ! ./build.sh; then
    notify "$TITLE" "Build failed!"
    sleep 5
    exit 1
fi

notify "$TITLE" "Stopping old instances..."
killall gomuks 2>/dev/null

notify "$TITLE" "Installing new binary..."
echo ""
echo "=================================================="
echo "  Root privileges required to install the binary  "
echo "=================================================="

# Prompt for doas password interactively and allow retries on failure
while ! doas cp gomuks /usr/bin/gomuks; do
    echo "Incorrect password or error. Please try again."
done

notify "$TITLE" "Starting Gomuks..."
nohup /usr/bin/gomuks >/dev/null 2>&1 &

notify "$TITLE" "Update complete!"
echo "Closing terminal in 3 seconds..."
sleep 3
