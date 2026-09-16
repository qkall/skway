#!/bin/sh
# title="$icon_bat_c_3 Night Mode"
# Author: magdesign
# License: MIT
# Description:
# Note: v0.1
# include common definitions
# shellcheck source=scripts/core/sxmo_common.sh
. "/usr/bin/sxmo_common.sh"

# set my screen superdark
#echo 5 > /sys/class/backlight/ae94000.dsi.0/brightness
/usr/bin/sxmo_brightness.sh setvalue 1

exit
