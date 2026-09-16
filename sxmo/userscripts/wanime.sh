#!/bin/bash
# title="$icon_vid Watch Anime"

# Define the menu options
OPTIONS="Toonami Aftermath West
Toonami Aftermath East
Toonami Aftermath Movie
Toonami Aftermath Radio
Locomotion TV
Locomotion TV 1
Stream Anime (ani-cli)"

# Pop up the menu to prompt the user
SELECTION=$(printf "%s" "$OPTIONS" | sxmo_dmenu.sh -p "Watch:")

# Play the selected stream with mpv or launch ani-cli
case "$SELECTION" in
    "Toonami Aftermath West")
        mpv "http://api.toonamiaftermath.com:3000/pst/playlist.m3u8"
        ;;
    "Toonami Aftermath East")
        mpv "http://api.toonamiaftermath.com:3000/est/playlist.m3u8"
        ;;
    "Toonami Aftermath Movie")
        mpv "http://api.toonamiaftermath.com:3000/movies/playlist.m3u8"
        ;;
    "Toonami Aftermath Radio")
        mpv "http://api.toonamiaftermath.com:3000/radio/playlist.m3u8"
        ;;
    "Locomotion TV")
        mpv "http://51.222.85.85:81/hls/loco/index.m3u8"
        ;;
    "Locomotion TV 1")
        mpv "http://146.19.49.197:81/live/loco_hi/index.m3u8"
        ;;
    "Stream Anime (ani-cli)")
        sxmo_terminal.sh ani-cli --dub
        ;;
    *)
        # Exit if the user presses Esc or closes the menu
        exit 0
        ;;
esac
