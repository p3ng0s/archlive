#!/bin/bash
# bash script to set wallpaper according to time


while [ 1 ]; do
	PIC=($(ls ./wallpaper/))
	offset=$(bc -l <<< "24/${#PIC[@]}")
	CURRENT_HOUR=$(date "+%H")
	val=$(python -c "import math; print math.trunc(float(($CURRENT_HOUR/$offset)%${#PIC[@]}))")
	feh --bg-fill ./wallpaper/${PIC[$val]}
	sleep 60
done
