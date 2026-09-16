#!/bin/sh
# title="$icon_hrg SleepingFox"
# 2025 magdesign
# v0.4
# checks if firefox/librewolf is running but not playing music or downloading,
# put it into CPU sleep, in hope to safe some cpu/battery
# not sure if this should go into sxmo_jobs.sh or if
# the -STOP state should be added to: /usr/share/sxmo/default_hooks/sxmo_hook_screenoff.sh 
# the -CONT state to: /usr/share/sxmo/default_hooks/sxmo_hook_unlock.sh
# to test just link to this file in the 2 mentioned above.

FIREFOX_PID=$(pgrep -o firefox*)
LIBREWOLF_PID=$(pgrep -o librewolf*)
SLEEPFILE="$XDG_CACHE_HOME/sxmo/sleepingfox"

if [ -z "$FIREFOX_PID$LIBREWOLF_PID" ]; then
    echo "firefox/librewolf not running"
    if ! [ -f "$SLEEPFILE" ]; then
        exit 0
    fi
	return
fi


if [ -f "$SLEEPFILE" ]; then
    rm -f "$SLEEPFILE"
#	echo "lets unsleep $FIREFOX_PID"
	# could not figure out how to get it working with cat $SLEEPFILE pid out of the file
	kill -CONT "$FIREFOX_PID"
	kill -CONT "$LIBREWOLF_PID"
else
	# if not downloading, only works when using ~/Downloads/ dir as dir
	# fd version is significantly faster than find
	#if find ~/Downloads/ -type f -name "*.part" | grep -q .; then
	if fd -ie .part  --search-path ~/Downloads/ | grep -q .; then
#    	echo "Downloads are in progress."
		exit 1
	fi
	# if not playing audio (may not work with pulseaudio)
	if pactl list sink-inputs | grep firefox  >/dev/null 2>&1; then
		echo "there is audio playing, exit"
		exit 1
	fi

	kill -STOP "$FIREFOX_PID"
	kill -STOP "$LIBREWOLF_PID"
	printf '%s\n' "$FIREFOX_PID" "$LIBREWOLF_PID"> "$SLEEPFILE"
#	echo "put it sleeping"
	exit 0
fi
exit 0
