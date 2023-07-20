#!/bin/bash
# banner.sh
# Created on: Fri 22 Jan 2021 03:52:55 AM CET
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:

NO=$(( $RANDOM % 8 + 1 ))

case $NO in
	1)
		bullshit | cowsay -f /usr/share/cows/$(/bin/ls /usr/share/cows/ | shuf -n 1) | lolcat
		;;
	2)
		sh ghosts.sh
		;;
	3)
		pfetch
		;;
	4)
		sh pacman.sh
		;;
	5)
		sh darthvader.sh
		;;
	6)
		doge
		;;
	7)
		fortune | cowsay -f /usr/share/cows/$(/bin/ls /usr/share/cows/ | shuf -n 1) | lolcat
		;;
	8)
		date "+%D %T" | figlet | lolcat
		;;
esac
