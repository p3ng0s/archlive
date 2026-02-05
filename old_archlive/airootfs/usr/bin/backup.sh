#!/bin/bash
# backup.sh
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  Backup script made to save my config to a tar ball for
#  later unpacking

BDIR=/tmp/backup
CONF_FILES=(.vimrc .tmux.conf .fzf.bash .tigrc .gdbinit .wallpaper.png .Xresources)
CONF_DIRS=(.vim/ .tmux/ .fzf/ .peda/ .xvwm/)

function move_to_folder() {
	for item in $@; do
		IN_FILE=$HOME/$item
		TO_FILE=$BDIR/$item

		echo -ne "Copying \e[1;31m$IN_FILE\e[m to: \e[1;34m$TO_FILE\e[m -> "
		cp -r $IN_FILE $TO_FILE &> /dev/null
		check_if_moved $IN_FILE $TO_FILE
	done
}

function check_if_moved() {
	if [ -f $1 ]; then
		if [ -f $2 ]; then
			echo -e "\e[1;34m:)\e[m"
		else
			echo -e "\e[1;31m:(\e[m"
			echo "File was not created"
		fi
		return
	fi
	if [ -d $1 ]; then
		if [ -d $2 ]; then
			echo -e "\e[1;34m:)\e[m"
		else
			echo -e "\e[1;31m:(\e[m"
			echo "Folder was not created"
		fi
		return
	fi
	echo -e "\e[1;31m:(\e[m"
	echo "Error: $1 Does not exist"
}

function remove() {
	for item in $@; do
		FILE=$BDIR/$item
		rm -rf $FILE &> /dev/null
	done
}

echo "Saving config files to backup.tar.xz :)"

echo -n "Checking for $BDIR -> "
if [ ! -d "$BDIR" ]; then
	echo -e "\e[1;31m:(\e[m"
	mkdir $BDIR
else
	echo -e "\e[1;34m:)\e[m"
	echo "Clearing dir..."
	remove ${CONF_FILES[*]}
	remove ${CONF_DIRS[*]}
fi


move_to_folder ${CONF_FILES[*]}
move_to_folder ${CONF_DIRS[*]}

echo -n "Moving $BDIR to ./backup -> "
cp -r $BDIR/ ./backup &> /dev/null && echo -e "\e[1;34m:)\e[m" ||
	echo -e "\e[1;31m:(\e[m"

echo -n "Creating tar ball -> "
tar -cf backup.tar.xz backup &>/dev/null && echo -e "\e[1;34m:)\e[m" ||
	echo -e "\e[1;31m:(\e[m"

let size=$(du ./backup.tar.xz | cut -f1 -d'	')
echo -n "checking size -> "
(($size < 500000)) && echo -e "\e[1;34m:)\e[m" ||
	echo -e "\e[1;31m:(\nError:\e[m Please consider having a smaller backup file"

rm -rf ./backup/
echo "All done :)"

exit