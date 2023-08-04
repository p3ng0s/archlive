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

ISO_BUILD_DIR=$PWD/build_dir/
BACKUP_FILE=./backup.tar.xz
LINK_TO_BACKUP=https://leosmith.wtf/rice/$BACKUP_FILE
HOME_ARCHLIVE=./archlive/airootfs/etc/skel
ROOT_ARCHLIVE=./archlive/airootfs
BIN_ARCHLIVE=./archlive/airootfs/usr/local/bin
BACKUP_FOLDER=./backup/
PACKAGER_FOLDER=./packager
PACKAGER_REPO=https://github.com/p3ng0s/packager

# Display usage information
function usage () {
	echo -e "\e[1;31mUsage:\e[m" 1>&2
	echo "$0 -b -> Build only." 1>&2
	echo "$0 -p -> Pakcages only." 1>&2
	echo "$0 -d -> Delete all temp folder and build folder." 1>&2
	exit -1
}

while getopts "bdp" o; do
	case "${o}" in
		b)
			whoami
			echo -e "SUDO Big .iso build see you tomorrow -> \e[36m:)\e[0m"
			sudo mkarchiso -v -w $ISO_BUILD_DIR $PWD/archlive/
			echo -e "All done -> \e[36m:)\e[0m"
			exit 0
			;;
		p)
			git clone $PACKAGER_REPO
			BUILD_TMP_DIR=$(pwd)
			cd $PACKAGER_FOLDER
			./setup.sh
			cd $BUILD_TMP_DIR
			echo -e "Installed p3ng0s repositories -> \e[36m:)\e[0m"
			exit 0
			;;
		d)
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
if [ "$EUID" -eq 0 ]; then
	echo -e "\e[1;31mPlease do not run as root\e[m"
	exit -1
fi

# Download backup
echo -e "Fetching backup -> \e[36m:)\e[0m"
curl $LINK_TO_BACKUP --output $PWD/$BACKUP_FILE
tar -xf $BACKUP_FILE


## move config
[ -d "$BACKUP_FOLDER/.vim/" ] && cp -r $BACKUP_FOLDER/.vim/ $HOME_ARCHLIVE
[ -d "$BACKUP_FOLDER/.tmux/" ] && cp -r $BACKUP_FOLDER/.tmux/ $HOME_ARCHLIVE
[ -d "$BACKUP_FOLDER/.fzf/" ] && cp -r $BACKUP_FOLDER/.fzf/ $HOME_ARCHLIVE
[ -f "$BACKUP_FOLDER/.gdbinit" ] && cp -r $BACKUP_FOLDER/.gdbinit $HOME_ARCHLIVE
[ -f "$BACKUP_FOLDER/.Xresources" ] && cp -r $BACKUP_FOLDER/.Xresources $HOME_ARCHLIVE
[ -f "$BACKUP_FOLDER/.tmux.conf" ] && cp -r $BACKUP_FOLDER/.tmux.conf $HOME_ARCHLIVE
[ -f "$BACKUP_FOLDER/.vimrc" ] && cp -r $BACKUP_FOLDER/.vimrc $HOME_ARCHLIVE
[ -f "$BACKUP_FOLDER/.bashrc" ] && cp -r $BACKUP_FOLDER/.bashrc $HOME_ARCHLIVE
[ -f "$BACKUP_FOLDER/.tigrc" ] && cp -r $BACKUP_FOLDER/.tigrc $HOME_ARCHLIVE
[ -f "$BACKUP_FOLDER/.wallpaper.png" ] && cp -r $BACKUP_FOLDER/.wallpaper.png $HOME_ARCHLIVE

echo -e "Moved terminal config to archlive -> \e[36m:)\e[0m"

# setup for startx with the live version of the windows manager
[ ! -f $HOME_ARCHLIVE/.xinitrc ] && echo "exec dwm-live" > $HOME_ARCHLIVE/.xinitrc


git clone $PACKAGER_REPO
BUILD_TMP_DIR=$(pwd)
cd $PACKAGER_FOLDER
./setup.sh
cd $BUILD_TMP_DIR
echo -e "Installed p3ng0s repositories -> \e[36m:)\e[0m"

# Last step build iso
whoami
echo -e "SUDO Big .iso build see you tomorrow -> \e[36m:)\e[0m"
sudo mkarchiso -v -w $ISO_BUILD_DIR $PWD/archlive/

echo -e "All done -> \e[36m:)\e[0m"

exit 0
