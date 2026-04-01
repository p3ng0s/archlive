#!/bin/bash
# display.sh
# Created on: Fri 09 Jan 2026 09:36:18 AM CET
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  A p3ng0s script to handle external displays plugged in to the laptop.
#

function get_resolution() {
    xrandr | awk -v d="$1" '
    $1==d && $2=="connected" {flag=1; next}
    flag && /^[[:space:]]+[0-9]+x[0-9]+/ {
        gsub(/^[[:space:]]+/, "", $1)
        split($1,res,"x")
        w=res[1]; h=res[2]
        area=w*h
        if (area > max_area) {
            max_area = area
            max_res = $1
        }
    }
    flag && $1=="" {flag=0}
    END { print max_res }
    '
}

if [[ "$TRIGGERED_BY_UDEV" == "1" ]]; then
	USER=$(who | grep 'tty1' | awk '{print $1}' | head -n1)
	[ -z $USER ] && exit
	export DISPLAY=:0
	export HOME="/home/$USER"
	export XAUTHORITY=$HOME/.Xauthority
	sleep 1
fi

mapfile -t FOUND_X_DISPLAYS < <(xrandr | awk '/ connected / {print $1}')
kill $(pgrep conky)

echo ${FOUND_X_DISPLAYS[*]}

# if there is an extra screen found other than built in
if (( ${#FOUND_X_DISPLAYS[*]} == 2 )); then
	PRIMARY=${FOUND_X_DISPLAYS[0]}
	OTHER=${FOUND_X_DISPLAYS[1]}
	res=$(get_resolution $OTHER)

	# if the screen resolution matches my home monitor
	if [[ "$res" == "3840x2160" ]]; then
		# setting the correct positions
		xrandr --output $OTHER --auto --left-of $PRIMARY
		feh --bg-fill $HOME/.wallpaper.png
	fi
	# if the screen resolution matches my portable monitor
	if [[ "$res" == "2560x1600" ]]; then
		xrandr --output $OTHER --auto --primary --output $PRIMARY --off
		feh --bg-fill $HOME/.wallpaper.png
	fi
	# if the screen resolution matches my other monitor
	if [[ "$res" == "1920x1080" ]]; then
		# setting the correct positions
		xrandr --output $OTHER --auto --above $PRIMARY
		feh --bg-fill $HOME/.wallpaper.png
	fi

else # no displays
	PRIMARY=${FOUND_X_DISPLAYS[0]}
	res=$(get_resolution $PRIMARY)

	# steam deck resolution rotation
	if [[ "$res" == "800x1280" ]]; then
		xrandr --output $PRIMARY --rotate right
		TOUCH_DEVICE=$(xinput list --name-only | grep -i "FTS3528\|touchscreen" | head -n1)
		[ -n "$TOUCH_DEVICE" ] && xinput set-prop "$TOUCH_DEVICE" "Coordinate Transformation Matrix" 0 1 0 -1 0 1 0 0 1
		feh --bg-fill $HOME/.wallpaper.png
	else
		xrandr --auto
		feh --bg-fill $HOME/.wallpaper.png
	fi
fi
/usr/bin/conky -c /etc/p3ng0s/conkyconf
