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
	xrandr | awk -v d="$1" '$1==d && $2=="connected" {
		split($3,a,"+"); print a[1]
	}'
}

mapfile -t FOUND_X_DISPLAYS < <(xrandr | awk '/ connected / {print $1}')

# if there is an extra screen found other than built in
if (( ${#FOUND_X_DISPLAYS[*]} == 2 )); then
	PRIMARY=${FOUND_X_DISPLAYS[0]}
	OTHER=${FOUND_X_DISPLAYS[1]}
	res=$(get_resolution $OTHER)

	# if the screen resolution matches my home monitor
	if [[ "$res" == "2560x1440" ]]; then
		# setting the correct positions
		xrandr --output $OTHER --left-of $PRIMARY
		feh --bg-fill $HOME/.wallpaper.png
	fi
fi
# the previous command might break the wallpaper don't forget to re-run
# feh --bg-fill $HOME/.wallpaper.png
