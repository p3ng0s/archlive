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

mapfile -t FOUND_X_DISPLAYS < <(xrandr | awk '/ connected / {print $1}')

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
	# if the screen resolution matches my other monitor
	if [[ "$res" == "1920x1080" ]]; then
		# setting the correct positions
		xrandr --output $OTHER --auto --above $PRIMARY
		feh --bg-fill $HOME/.wallpaper.png
	fi
else # no displays
	xrandr --auto
	feh --bg-fill $HOME/.wallpaper.png
fi
# the previous command might break the wallpaper don't forget to re-run
# feh --bg-fill $HOME/.wallpaper.png
