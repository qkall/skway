#!/bin/sh
# title="$icon_prn OCRscreen"
# Author: magdesign
# Description: Reads text of selected area
# Requirements: bash tesseract-ocr tesseract-ocr-data-eng wl-clipboard
# Notes: v0.4 detect wifi qr-codes on copy passwords
# Works only in sway/wayland

# check requirements
requirements(){
	if ! command -v tesseract >/dev/null 2>&1 ;then
  		notify-send --urgency=critical "Please install tesseract-ocr tesseract-ocr-data-eng"
  		exit 1
	fi
	if ! command -v wl-paste >/dev/null 2>&1 ;then
  		notify-send --urgency=critical "Please install wl-clipboard"
  		exit 1
	fi
	if ! command -v ZXingReader >/dev/null 2>&1 ;then
  		notify-send --urgency=critical "Please install zxing"
  		exit 1
	fi
}

screenshot(){
	area="$(slurp -d)"
	grim -g "$area" $IMAGE
}

qr_reader(){
	ZXingReader $IMAGE | awk '/^Text:/ {print $2}'| awk '{gsub(/^"|"$/,"")}1' > $TEXT.txt
	# check if we found something
	if [[ -s $TEXT.txt ]]; then
  		# check if its a wifi connection
   		if [[ "$(cat $TEXT.txt)" == *"WIFI:"* ]]; then
	  		name=$(cat "$TEXT.txt" | grep -oP 'S:\K[^;]+')
	  		password=$(cat "$TEXT.txt" | sed -n 's/.*;P:\(.*\);;/\1/p')
	  		notify-send "wifi=> $name" "pass=> $password"
	  		wl-copy $password
  		else
	 		notify-send "$(cat $TEXT.txt)"
     		cat $TEXT.txt | wl-copy
		fi
	fi
}

tesseract_reader(){
	rm $TEXT.txt
  	# sends image to ocr and extracts text 
	tesseract -l eng+rus $IMAGE $TEXT
	notify-send "$(cat $TEXT.txt)"
	cat $TEXT.txt | wl-copy
}

# temp dir/files
IMAGE=/tmp/ocr_tmp.png
TEXT=/tmp/ocr_tmp

screenshot
qr_reader

if ! [ -s $TEXT.txt ]; then
#	echo "empty"
	tesseract_reader
fi
  
# cleanup
rm $IMAGE
rm $TEXT.txt

exit 0
