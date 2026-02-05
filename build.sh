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

UPSTREAM_FOLDER=/usr/share/archiso/configs/releng/
ISO_BUILD_DIR=$PWD/build/

BACKUP_FILE=./backup.tar.xz
LINK_TO_BACKUP=https://leosmith.wtf/rice/$BACKUP_FILE
BACKUP_FOLDER=./backup/

ROOT_ARCHLIVE=$PWD/work/airootfs
HOME_ARCHLIVE=$ROOT_ARCHLIVE/etc/skel
BIN_ARCHLIVE=$ROOT_ARCHLIVE/usr/local/bin

OVERLAY=$PWD/overlay
OVERLAY_ROOTFS=$PWD/overlay/airootfs

PACKAGER_REPO=https://github.com/p3ng0s/packager
PACKAGER_FOLDER=./packager

# Display usage information
function usage () {
	echo -e "\e[1;31mUsage:\e[m" 1>&2
	echo "$0 -b -> Build only." 1>&2
	echo "$0 -p -> Pakcages only." 1>&2
	echo "$0 -c -> Delete all temp folder and build folder." 1>&2
	exit -1
}

function package_builder () {
	git clone $PACKAGER_REPO
	BUILD_TMP_DIR=$(pwd)
	cd $PACKAGER_FOLDER
	./setup.sh
	cd $BUILD_TMP_DIR
	echo -e "Installed p3ng0s repositories -> \e[36m:)\e[0m"
}

function build() {
	whoami
	echo -e "SUDO Big .iso build see you tomorrow -> \e[36m:)\e[0m"
	sudo mkarchiso -v -w $ISO_BUILD_DIR $PWD/archlive/
	echo -e "All done -> \e[36m:)\e[0m"
}

while getopts "bpc" o; do
	case "${o}" in
		c)
			echo -e "Removing the $PACKAGER_FOLDER folder -> \e[36m:)\e[0m"
			rm $PACKAGER_FOLDER
			echo -e "Removing the $BACKUP_FOLDER folder -> \e[36m:)\e[0m"
			rm $BACKUP_FOLDER
			echo -e "Delete $ISO_BUILD_DIR -> \e[36m:)\e[0m"
			rm -rf $ISO_BUILD_DIR
			echo -e "Delete $PWD/out/ -> \e[36m:)\e[0m"
			rm -rf $PWD/out/
			exit
			;;
		b)
			build
			exit 0
			;;
		p)
			package_builder
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
#echo -e "Fetching backup -> \e[36m:)\e[0m"
#curl $LINK_TO_BACKUP --output $PWD/$BACKUP_FILE
#tar -xf $BACKUP_FILE
#
#
### move config
#[ -d "$BACKUP_FOLDER/.vim/" ] && cp -r $BACKUP_FOLDER/.vim/ $HOME_ARCHLIVE
#[ -d "$BACKUP_FOLDER/.tmux/" ] && cp -r $BACKUP_FOLDER/.tmux/ $HOME_ARCHLIVE
#[ -d "$BACKUP_FOLDER/.fzf/" ] && cp -r $BACKUP_FOLDER/.fzf/ $HOME_ARCHLIVE
#[ -f "$BACKUP_FOLDER/.gdbinit" ] && cp -r $BACKUP_FOLDER/.gdbinit $HOME_ARCHLIVE
#[ -f "$BACKUP_FOLDER/.Xresources" ] && cp -r $BACKUP_FOLDER/.Xresources $HOME_ARCHLIVE
#[ -f "$BACKUP_FOLDER/.tmux.conf" ] && cp -r $BACKUP_FOLDER/.tmux.conf $HOME_ARCHLIVE
#[ -f "$BACKUP_FOLDER/.vimrc" ] && cp -r $BACKUP_FOLDER/.vimrc $HOME_ARCHLIVE
#[ -f "$BACKUP_FOLDER/.bashrc" ] && cp -r $BACKUP_FOLDER/.bashrc $HOME_ARCHLIVE
#[ -f "$BACKUP_FOLDER/.tigrc" ] && cp -r $BACKUP_FOLDER/.tigrc $HOME_ARCHLIVE

# Pick a wallpaper
options=( "None" "" )
for item in "$OVERLAY_ROOTFS/etc/p3ng0s/wallpaper/"*; do
	[ -e "$item" ] || continue  # Skip non-existent files
	options+=("$item" "")
done
choice=$(dialog --menu "Select a wallpaper" 0 0 0 "${options[@]}" 2>&1 >/dev/tty)
if [ ! $choice = "None" ]; then
	cp -r $choice $HOME_ARCHLIVE/.wallpaper.png
fi

echo -e "Moved terminal config to archlive -> \e[36m:)\e[0m"

# setup for startx with the live version of the windows manager
[ ! -f $HOME_ARCHLIVE/.xinitrc ] && echo -e "xrdb -merge ~/.Xresources\nexec dwm-live" > $HOME_ARCHLIVE/.xinitrc

# Build all packages
#package_builder

# Last step build iso
#build

exit 0
