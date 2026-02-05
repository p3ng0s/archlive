#!/bin/bash
# Created on: jeu. 16 avril 2020 02:32:41  CEST
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  script that start on boot of dwm

function bat {
	batteries=($(ls /sys/class/power_supply/))
	slider=""
	val=""

	for item in ${batteries[@]}; do
		if [ "$item" = "AC" ]; then
			is_on=$(cat /sys/class/power_supply/$item/online)
			if [ "$is_on" = "1" ]; then
				val="\x02\x01"
			fi
		else
			let left=$(cat /sys/class/power_supply/$item/capacity)
			let i=(${#slider} * $left / 100)
			if [ $left -le 20 ]; then
				val="$val \x04$left${slider:$i:1}\x01"
			elif [ $left  -le 45 ]; then
				val="$val \x03$left${slider:$i:1}\x01"
			else
				val="$val $left${slider:$i - 1:1}"
			fi
		fi
	done
	echo -n $val;
}

function OS {
	# arch fedora ubuntu suse manjaro gento redhat centos elementary debian mint tux
	OS_ICONS="           "
	echo " $(cat /etc/hostname | tr '\n' ' ')"
}

if hash dwmstat; then
	dwmstat &
	exit 0
fi
 
# The status loop
while true; do
	ip=$(ifconfig| grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | tr "\n" " ")
	battery=$(bat)
	volume=$(amixer get Master| grep -o "\[[0-9]\+%\]" | sed 's/[^0-9]*//g')
	mute=$(amixer get Master | grep "\[off\]")
	memory=$(free -m | awk 'NR==2{printf "%.1f\n", $3*100/$2 }')
	mem=$(free -m | awk 'NR==2{printf "%d\n", $3*100/$2 }')
	date=$(date +"%d/%m/%Y %H:%M")
	OS=$(OS $POS)

	if ! [ -z "$mute" ]; then
		volume="\x05MUTE\x01"
	else
		volume="$volume%"
	fi
	if [ "$ip" = "" ]; then
		ip="\x04No Wifi :(\x01"
	else
		ip="${ip::-1}"
	fi
	if (( $mem < 40 )); then
		memory="\x06$memory\x01"
	elif (( $mem >= 40 && $mem < 60 )); then
		memory="\x03$memory\x01"
	else
		memory="\x04$memory\x01"
	fi
	status="[$OS] [$date] [$battery] [$ip] [$volume] [$memory]"
	xsetroot -name "$(echo -e $status)"
	sleep 1
done
