#!/bin/bash
# build.sh
# Created on: Sat 24 Sep 2022 02:07:07 AM BST
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
# Generate pacman ignore list
#  /bin/ls archlive/airootfs/usr/lib/ | xargs -l -I {} echo /tmp/build_dir/x86_64/airootfs/usr/lib/{} > ignore.txt
#  cat ignore.txt | tr '\n' ' ' > ignore2.t

ISO_BUILD_DIR=/tmp/build_dir/
BACKUP_FILE=./backup.tar.xz
LINK_TO_BACKUP=https://leosmith.wtf/rice/$BACKUP_FILE
HOME_ARCHLIVE=./archlive/airootfs/root
ROOT_ARCHLIVE=./archlive/airootfs
OPT_ARCHLIVE=./archlive/airootfs/opt
BIN_ARCHLIVE=./archlive/airootfs/usr/local/bin
BACKUP_FOLDER=./backup/
SOURCE_FOLDER=./backup/.source
DWM_FOLDER=$SOURCE_FOLDER/dwm-6.2
ST_FOLDER=$SOURCE_FOLDER/st-0.8.2
DMENU_FOLDER=$SOURCE_FOLDER/dmenu-4.9
WMNAME_FOLDER=$SOURCE_FOLDER/wmname
XMENU_FOLDER=$SOURCE_FOLDER/xmenu
CUSTOM_REPO=("https://github.com/p4p1/larp.git" "https://github.com/p4p1/dwmstat.git" "https://github.com/lgandx/Responder.git" "https://github.com/Hackplayers/evil-winrm" "https://github.com/HavocFramework/Havoc")
TGZ_FILES=("https://dl.pstmn.io/download/latest/linux_64")

# Display usage information
function usage () {
	echo -e "\e[1;31mUsage:\e[m" 1>&2
	echo "$0 -c -> force compile no dependency work." 1>&2
	echo "$0 -r -> Delete all temp folder and build folder." 1>&2
	exit -1
}

# Install repository
function install_repo() {
	mkdir $OPT_ARCHLIVE
	for item in $@; do
		if [[ ! -d "$OPT_ARCHLIVE/$(echo "$item" | cut -d'/' -f5 | cut -d'.' -f1)" ]]; then
			git clone $item $OPT_ARCHLIVE/$(echo "$item" | cut -d'/' -f5 | cut -d'.' -f1)
		else
			git -C $OPT_ARCHLIVE/$(echo "$item" | cut -d'/' -f5 | cut -d'.' -f1) pull
		fi
	done
}

while getopts "cr" o; do
	case "${o}" in
		c)
			mkarchiso -v -w /tmp/build_dir/ $PWD/archlive/
			echo -e "All done -> \e[36m:)\e[0m"
			exit 0
			;;
		r)
			echo -e "Delete $ISO_BUILD_DIR -> \e[36m:)\e[0m"
			rm -rf $ISO_BUILD_DIR
			echo -e "Delete $PWD/out/ -> \e[36m:)\e[0m"
			rm -rf $PWD/out/
			exit 0
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

# Do the basic checks to see if root and on supported systems and if the user exitsts
if [ "$EUID" -ne 0 ]; then
	echo -e "\e[1;31mPlease run as root\e[m"
	exit -1
fi

 Download backup
echo -e "Fetching backup -> \e[36m:)\e[0m"
curl $LINK_TO_BACKUP --output $PWD/$BACKUP_FILE
tar -xf $BACKUP_FILE

# compile programs
make -C $DWM_FOLDER
make -C $ST_FOLDER
make -C $DMENU_FOLDER
make -C $WMNAME_FOLDER
make -C $XMENU_FOLDER
echo -e "Compiled custom software -> \e[36m:)\e[0m"

# move binaries in specific folders
cp -r $DWM_FOLDER/dwm $BIN_ARCHLIVE
cp -r $DWM_FOLDER/dwm-light $BIN_ARCHLIVE
cp -r $DWM_FOLDER/dwm-live $BIN_ARCHLIVE
cp -r $ST_FOLDER/st $BIN_ARCHLIVE
cp -r $DMENU_FOLDER/dmenu $BIN_ARCHLIVE
cp -r $DMENU_FOLDER/dmenu_run $BIN_ARCHLIVE
cp -r $DMENU_FOLDER/stest $BIN_ARCHLIVE
cp -r $WMNAME_FOLDER/wmname $BIN_ARCHLIVE
cp -r $XMENU_FOLDER/xmenu $BIN_ARCHLIVE
cp -r $XMENU_FOLDER/xmenu_run $BIN_ARCHLIVE
# Remove makefile to remove clutter
rm -rf $SOURCE_FOLDER/scripts/Makefile
#move all scripts into bin
cp -r $SOURCE_FOLDER/scripts/* $BIN_ARCHLIVE

echo -e "Moved software to archlive -> \e[36m:)\e[0m"

# move config
cp -r $BACKUP_FOLDER/.bashrc $HOME_ARCHLIVE
cp -r $BACKUP_FOLDER/.vimrc $HOME_ARCHLIVE
cp -r $BACKUP_FOLDER/.vim/ $HOME_ARCHLIVE
cp -r $BACKUP_FOLDER/.tmux.conf $HOME_ARCHLIVE
cp -r $BACKUP_FOLDER/.tmux/ $HOME_ARCHLIVE
cp -r $BACKUP_FOLDER/.wallpaper.png $HOME_ARCHLIVE
cp -r $BACKUP_FOLDER/.inputrc $HOME_ARCHLIVE
cp -r $BACKUP_FOLDER/.conkyrc $HOME_ARCHLIVE
cp -r $BACKUP_FOLDER/.fzf/ $HOME_ARCHLIVE
cp -r $BACKUP_FOLDER/.dwm/ $HOME_ARCHLIVE
cp -r $BACKUP_FOLDER/.tint2rc $HOME_ARCHLIVE
cp -r $BACKUP_FOLDER/.tigrc $HOME_ARCHLIVE

echo -e "Moved terminal config to archlive -> \e[36m:)\e[0m"

# move fonts
cp -r $BACKUP_FOLDER/.dwm/fonts/* $ROOT_ARCHLIVE/usr/share/fonts
echo -e "Setup the fonts -> \e[36m:)\e[0m"

# setup for startx with the live version of the windows manager
[ ! -f $HOME_ARCHLIVE/.xinitrc ] && echo "exec dwm-live" > $HOME_ARCHLIVE/.xinitrc

#install_repo ${CUSTOM_REPO[*]}
echo -e "Installed tools from public repositories -> \e[36m:)\e[0m"

# Last step build iso
whoami
echo -e "Big .iso build see you tomorrow -> \e[36m:)\e[0m"
mkarchiso -v -w $ISO_BUILD_DIR $PWD/archlive/

echo -e "All done -> \e[36m:)\e[0m"

exit 0
