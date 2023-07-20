#!/bin/bash
# xvwm.sh
# Created on: 18 April 2020
# tutorial: https://p4p1.github.io/posts/xvwm.html
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#   A bash script to run a window manager
#   inside of xephyr, with a dmenu prompt
#   to choose the window manager from.
#
# Usage:
#   xvwm.sh [-i] [-v] [-w width] [-h height] [-f window manager] [-d DISPLAY value]
#
# Configure:
#   To configure xvwm you can edit the ~/.xvwm/xvwm.bash file
#   and add the following line to your bashrc:
#   [ ! -z "$XVWM" ] && source ~/.xvwm/xvwm.bash
#   this will allow you to add commands to your nested X sessions
#   easily watch out thow it can break your system if you are not carreful
#
# Dependencies:
#    libx11-dev libxinerama-dev libxft-dev build-essential xserver-xephyr

# path to .xsession files change if needed
XPATH=/usr/share/xsessions
# Configuration path and files
XVPATH=/home/$USER/.xvwm/
XVBASH=$XVPATH/xvwm.bash
XVEXIT=$XVPATH/exit.bash
# dmenu settings:
L_NO="5"
L_HEIGHT="25"
BG_COLOR="#222222"
FG_COLOR="#bbbbbb"
SBG_COLOR="#ff9d14"
SFG_COLOR="#222222"
BRD_WIDTH="5"
# nested window size
WIDTH=800
HEIGHT=600
# set the display variables for the nested session
DISPLAY_INTERFACE=:1
TMP_DISPLAY=$DISPLAY
# windowm manager
WM=
# valgrind trigger
VALGRIND=
VALGRIND_ARG="valgrind"
# Path to my config for dmenu
config="https:/p4p1.github.io/backup.tar.xz"

function usage() {
	echo -e "Usage:" 1>&2
	echo -e "\t$0 [-i] [-v] [-w width] [-h height] [-f window manager] [-d DISPLAY value]" 1>&2
	echo -e "Options:" 1>&2
	echo -e "\t$0 -> classic run" 1>&2
	echo -e "\t$0 -i -> install (must run as root)" 1>&2
	echo -e "\t$0 -v -> run with valgrind (might slow down runtime)" 1>&2
	echo -e "\t$0 -w -> set width (default: 800)" 1>&2
	echo -e "\t$0 -h -> set height (default: 600)" 1>&2
	echo -e "\t$0 -f -> set the window manager" 1>&2
	echo -e "\t$0 -d -> set the DISPLAY value" 1>&2
	exit -1
}

function install() {
	PACKAGE=$1
	TMP_DIR=$(pwd)

	if [ "$PACKAGE" = "Xephyr" ]; then
		if [ "$EUID" -ne 0 ]; then
			echo -e "\e[1;31mPlease run as root to install\e[m"
			rm -rf $XVPATH
			exit -1
		fi
		apt update
		apt install xserver-xephyr libx11-dev libxinerama-dev libxft-dev build-essential
	elif [ "$PACKAGE" = "dmenu" ]; then
		cd /tmp/
		curl $config --output /tmp/backup.tar.xz
		tar xf ./backup.tar.xz
		make -C /tmp/backup/.source/dmenu-4.9
		cd $TMP_DIR
		rm -rf /tmp/backup.tar.xz
		cp -r /tmp/backup/.source/dmenu-4.9/dmenu $XVPATH/
		rm -rf /tmp/backup/
	elif [ "$PACKAGE" = "$0" ]; then
		sudo cp -r $TMP_DIR/$0 /usr/bin/$0
	else
		echo -e "\e[1;31mError:\e[m Unknown $PACKAGE"
	fi
}

function check_dependancies() {
	DEP=(Xephyr)

	for item in ${DEP[@]}; do
		echo -n "Checking for $item -> "
		if hash $item &> /dev/null; then
			echo -e "\e[1;34m:)\e[m"
		else
			echo -e "\e[1;31m:(\e[m"
			install $item
		fi
	done
}

function xsession() {
	XSESS=($(ls $XPATH))
	STR=

	for item in ${XSESS[@]}; do
		VAL=$(cat $XPATH/$item | grep Exec | head -n 1 | cut -c 6-)
		if [ -z "$STR" ]; then
			STR="$VAL"
		else
			STR="$STR\n$VAL"
		fi
	done
	WM=$(echo -e "$STR" | $XVPATH/dmenu -nb $BG_COLOR -nf $FG_COLOR \
		-sb $SBG_COLOR -sf $SFG_COLOR -c -bw $BRD_WIDTH -h $L_HEIGHT -l $L_NO)
}

# Command parser
while getopts "ivw:h:d:f:" o; do
	case "${o}" in
		i)
			install $0
			exit 0
			;;
		v)
			VALGRIND=$VALGRIND_ARG
			;;
		w)
			WIDTH=${OPTARG}
			;;
		h)
			HEIGHT=${OPTARG}
			;;
		d)
			DISPLAY_INTERFACE=${OPTARG}
			;;
		f)
			WM=${OPTARG}
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

# beginning of script
if [ ! -d "$XVPATH" ]; then
	echo "Welcome to $0 this is your first install..."
	echo "Creating path in $XVPATH"
	mkdir $XVPATH
	echo -e "# __  ____   ____      ___ __ ___\n# \\ \\/ /\\ \\ / /\\ \\ /\\ / / \'_ \` _ \\ \n#  >  <  \\ V /  \\ V  V /| | | | | |\n# /_/\\_\\  \\_/    \\_/\\_/ |_| |_| |_|\n#\n# File for configuring xvwm nested Xsession\n\nWIDTH=800\nHEIGHT=600\n\nxrandr -s \${WIDTH}x\${HEIGHT -d \${XVWM}" > $XVBASH
	echo -e "# __  ____   ____      ___ __ ___\n# \\ \\/ /\\ \\ / /\\ \\ /\\ / / \'_ \` _ \\ \n#  >  <  \\ V /  \\ V  V /| | | | | |\n# /_/\\_\\  \\_/    \\_/\\_/ |_| |_| |_|\n#\n# File run when xsession closed" > $XVEXIT
	echo "Installing custom dmenu..."
	install dmenu
	echo -n "Do you wish to install $0 as a system app? [Y/n] "
	read a
	[ "$a" = "Y" ] && install $0
fi

if [ -z "$WM" ]; then
	xsession
fi
check_dependancies

echo "Interface set as $DISPLAY_INTERFACE"

# Lanch Xephyr in background
Xephyr -br -ac -reset -screen ${WIDTH}x${HEIGHT} ${DISPLAY_INTERFACE} &
echo -n "Waiting for X session to start       "
let i=5
while [ $i -gt 0 ]; do
	echo -ne "\b\b\b\b\b\b(${i}sec)"
	notify-send "starting in: ${i}sec" -u critical -t 1000
	sleep 1
	let i=$i-1
done
echo

# Run Window Manager and export display vars for dwm
export XVWM=$DISPLAY_INTERFACE
#export DISPLAY=$DISPLAY_INTERFACE
if [ ! -z $VALGRIND ]; then
	sh -c "DISPLAY=$DISPLAY_INTERFACE $VALGRIND_ARG $WM"
else
	sh -c "DISPLAY=$DISPLAY_INTERFACE $WM"
fi

source $XVEXIT
echo "Reseting display back to $TMP_DISPLAY"
# revert DISPLAY setting
export XVWM=
export DISPLAY=$TMP_DISPLAY
echo "All done :)"

exit
