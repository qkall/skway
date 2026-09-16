#!/bin/sh
# title="$icon_net Share WiFi"
# shows the wifi password+qr code  of the currently connected wifi
# Open a new terminal window and execute the desired code
sxmo_terminal.sh -- bash -c "nmcli dev wifi show-password; read -p 'Press enter to close this terminal';"
