#!/bin/bash
# dmenu_finder.sh
# Created on: Sun 07 Nov 2021 01:35:18 AM GMT
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  Script to recreate a finder functionality like modern desktop managers
# Configure:
#  set this cronjob:
#   0 * * * * find / > /tmp/dirlist

DIR_LIST_FILE=/tmp/dirlist
LONG_LINE=$(python -c "print('a' * 4000)")
SELECTED=$((cat /tmp/dirlist ; dmenu_path ; echo $LONG_LINE) | dmenu -fn "Hack Nerd Font Mono:size=12" -nb "#393939" -nf "#bbbbbb" -sb "#FF875F" -sf "#393939" -h 25 -bw 5 -l 10 -c)

if [ -z "$SELECTED" ];then
	exit
fi

if [ -d "$SELECTED" ];then
	nautilus $SELECTED &
	exit
fi

if [ -f "$SELECTED" ];then
	xdg-open $SELECTED &
	exit
fi

if hash "$SELECTED"; then
	echo $SELECTED | ${SHELL:-"/bin/sh"} &
	exit
fi

[ ! -z $BROWSER ] && $BROWSER "https://duckduckgo.com/?q=$SELECTED" || vivaldi-stable "https://duckduckgo.com/?q=$SELECTED" &
