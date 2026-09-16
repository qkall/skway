# title="$icon_gps GPS-ish"
mmcli -m any --location-enable-gps-nmea
mmcli -m any --location-enable-gps-raw 
mmcli -m any --location-get 
qmicli -d qrtr://0 --loc-set-engine-lock=mt
qmicli -d qrtr://0 --loc-set-nmea-types=all
/usr/libexec/geoclue-2.0/demos/where-am-i > /dev/null 2>&1 &
flatpak run page.codeberg.tpikonen.satellite & ~/sxmop6/launchers/puremaps_launcher.sh
