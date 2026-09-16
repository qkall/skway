#!/bin/sh
# title="$icon_fnd Scale Display"
# Description: select display scale factor
# Author: Frank Oltmanns / magdesign
# License: MIT
# Note: v0.2 fixed dmenu sh
menu() {
	# TODO: export WVKBD_LAYERS to a number layout when one exists.
	SCALEINPUT="$(
	echo "
		4
		3.5
		3
		2.5
		2
		1.75
		1.5
		1.25
		1
		Close Menu
	" | awk 'NF' | awk '{$1=$1};1' | sxmo_dmenu.sh -p Select scale factor
	)"
	[ "Close Menu" = "$SCALEINPUT" ] && exit 0

	case "$SXMO_WM" in
		sway)
			swaymsg "output \"DSI-1\" scale $SCALEINPUT"
			;;
		*)
			notify-send "Scale Display only supports sway."
			exit 1
			;;
	esac
}

menu
