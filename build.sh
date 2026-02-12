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

PART=

UPSTREAM_SYS_FOLDER=/usr/share/archiso/configs/releng/
UPSTREAM_FOLDER=$PWD/upstream/
ISO_BUILD_DIR=$PWD/build/

BACKUP_FILE=$PWD/backup.tar.xz
BACKUP_FOLDER=$PWD/backup/

WORK_FOLDER=$PWD/work
ROOT_ARCHLIVE=$WORK_FOLDER/airootfs
HOME_ARCHLIVE=$ROOT_ARCHLIVE/etc/skel
BIN_ARCHLIVE=$ROOT_ARCHLIVE/usr/local/bin

OVERLAY_FOLDER=$PWD/overlay
OVERLAY_ROOTFS=$OVERLAY_FOLDER/airootfs

PACKAGER_REPO=https://github.com/p3ng0s/packager
PACKAGER_FOLDER=$PWD/packager

DOCKER=false

# Display usage information
function usage () {
	echo -e "\e[1;31mUsage:\e[m" 1>&2
	echo "$0 -b -> Build only." 1>&2
	echo "$0 -p -> Pakcages only." 1>&2
	echo "$0 -c -> Delete all temp folder and build folder." 1>&2
	echo "$0 -u -> Update etc/skel to the latest content of backup.tar.xz requires a link to the file provided" 1>&2
	echo "$0 -d -> Only used for docker! do not use this!!" 1>&2
	echo "$0 -f -> Flash a USB stick with the selected iso." 1>&2
	echo -e "\e[1;31mExamples:\e[m" 1>&2
	echo "$0" 1>&2
	echo "$0 -p" 1>&2
	echo "$0 -b" 1>&2
	echo "$0 -c" 1>&2
	echo "$0 -u http://leosmith.wtf/" 1>&2
	echo "$0 -f" 1>&2
	exit -1
}

function is_this_okay() {
	while true; do
		read -p "Continue? (Y/n): " answer
		case "$answer" in
			n|N) exit -1 ;;
			*) return 0
		esac
	done
}
function is_this_not_okay() {
	while true; do
		read -p "Continue? (y/N): " answer
		case "$answer" in
			y|Y) return 0 ;;
			*) exit -1
		esac
	done
}

function flash_iso() {
	if [ "$EUID" -ne 0 ]; then
		echo -e "\e[1;31mYou are flashing an iso you obviously need root here...\e[m"
		exit -1
	fi
	partitions=$(lsblk -dnpo NAME,SIZE --sort SIZE | grep -v "nvme*")
	partition_options=()
	while read -r name size; do
		partition_options+=( "$name" "$name ($size)" )
	done <<< "$partitions"
	selected_partition=$(dialog --title "Select a Disk" \
								--menu "Select a disk to flash the iso (ordered by size)" 20 70 15 \
								"${partition_options[@]}" \
								2>&1 >/dev/tty)
	if [[ -z "$selected_partition" ]]; then
		echo -e "\e[1;31m[!]\e[m No partition selected. Exiting.. ^^"
		exit 0
	fi
	$selected_partition
	options=( "None" "" )
	for item in "$PWD/out/"*; do
		[ -e "$item" ] || continue  # Skip non-existent files
		options+=("$item" "")
	done
	isofile=$(dialog --menu "Select the iso to flash" 0 70 0 "${options[@]}" 2>&1 >/dev/tty)
	echo -e "Got drive $selected_partition -> \e[36m:)\e[0m"
	echo -e "Got iso file $isofile -> \e[36m:)\e[0m"
	echo -e "\e[1;31mYou are going to take serious actions against that drive is this okay?\e[m"
	is_this_not_okay
	echo -e "\e[1;31mWiping drive!\e[m"
	wipefs -a "$selected_partition"
	sleep 1
	echo -e "\e[1;31mInstalling OS!\e[m"
	pv "$isofile" | sudo dd of="$selected_partition" bs=4M conv=fsync
	partprobe "$selected_partition"
	sleep 1
	echo -e "\e[1;31mCreating partition!\e[m"
	parted --script "$selected_partition" mkpart primary ext4 4GB 100%
	fdisk -l
	echo
	echo -e "\e[1;31mIs this the correct loot partition?\e[m"
	partition_to_crypt=$(lsblk -npo NAME,FSTYPE "$selected_partition" --sort SIZE | grep -vE "vfat|iso9660" | awk '{print $1}')
	echo $partition_to_crypt
	echo "If not please do the following manually:"
	echo "mkfs.exfat -L LOOT /dev/sdaX"
	echo "cryptsetup luksFormat <replace with correct partition>"
	echo "cryptsetup open <replace with correct partition> p3ng0s_unlocked"
	echo "mkfs.exfat -L LOOT /dev/mapper/p3ng0s_unlocked"
	echo "cryptsetup close p3ng0s_unlocked"
	is_this_not_okay
	cryptsetup luksFormat --label VAULT $partition_to_crypt
	cryptsetup open $partition_to_crypt p3ng0s_unlocked
	mkfs.exfat -L LOOT /dev/mapper/p3ng0s_unlocked
	sleep 1
	cryptsetup close p3ng0s_unlocked
	echo -e "All done -> \e[36m:)\e[0m"
}

function package_builder () {
	branch=$(git rev-parse --abbrev-ref HEAD)
	git clone $PACKAGER_REPO
	BUILD_TMP_DIR=$(pwd)
	cd $PACKAGER_FOLDER
	git checkout $branch
	if [ "$DOCKER" = true ]; then
		chown builder:builder . -R
		sudo -u builder ./setup.sh
	else
		./setup.sh
	fi
	cd $BUILD_TMP_DIR
	echo -e "Installed p3ng0s repositories -> \e[36m:)\e[0m"
}

function build() {
	if [ ! -d "$ROOT_ARCHLIVE" ]; then
		echo -e "Work directory missing -> \e[1;31m:(\e[0m"
		exit -1
	fi
	whoami
	echo -e "SUDO Big .iso build see you tomorrow -> \e[36m:)\e[0m"
	if [ "$EUID" -eq 0 ]; then
		mkarchiso -v -w $ISO_BUILD_DIR $WORK_FOLDER
	else
		sudo mkarchiso -v -w $ISO_BUILD_DIR $WORK_FOLDER
	fi
	echo -e "All done -> \e[36m:)\e[0m"
}

while getopts "bdfpcu:" o; do
	case "${o}" in
		c)
			echo -e "Removing the $PACKAGER_FOLDER folder -> \e[36m:)\e[0m"
			rm -rf $PACKAGER_FOLDER
			echo -e "Removing the $BACKUP_FOLDER folder -> \e[36m:)\e[0m"
			rm -rf $BACKUP_FOLDER
			echo -e "Delete $ISO_BUILD_DIR -> \e[36m:)\e[0m"
			rm -rf $ISO_BUILD_DIR
			echo -e "Delete $PWD/out/ -> \e[36m:)\e[0m"
			rm -rf $PWD/out/
			echo -e "Removing $WORK_FOLDER -> \e[36m:)\e[0m"
			rm -rf $WORK_FOLDER
			echo -e "Removing $UPSTREAM_FOLDER -> \e[36m:)\e[0m"
			rm -rf $UPSTREAM_FOLDER
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
		f)
			flash_iso
			exit 0
			;;
		u)
			LINK_TO_BACKUP=$OPTARG
			;;
		d)
			DOCKER=true
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

# Do the basic checks to see if root and on supported systems and if the user exitsts
#if [ "$EUID" -eq 0 ]; then
#	echo -e "\e[1;31mPlease do not run as root\e[m"
#	exit -1
#fi

# Get base arch linux system and create the work folder
cp -r $UPSTREAM_SYS_FOLDER $UPSTREAM_FOLDER
cp -r $UPSTREAM_FOLDER/ $WORK_FOLDER/

# create the patch files
diff -u $UPSTREAM_FOLDER/profiledef.sh $OVERLAY_FOLDER/profiledef.sh > $WORK_FOLDER/profiledef.sh.patch
cat $WORK_FOLDER/profiledef.sh.patch
is_this_okay
patch $WORK_FOLDER/profiledef.sh < $WORK_FOLDER/profiledef.sh.patch

diff -u $UPSTREAM_FOLDER/pacman.conf $OVERLAY_FOLDER/pacman.conf > $WORK_FOLDER/pacman.conf.patch
cat $WORK_FOLDER/pacman.conf.patch
is_this_okay
patch $WORK_FOLDER/pacman.conf < $WORK_FOLDER/pacman.conf.patch
# setting the PWD for pacman p3ng0s dependencies
sed -i 's|<CHANGE_PWD>|'"$PWD"'|g' $WORK_FOLDER/pacman.conf

# Combining packages
cat $UPSTREAM_FOLDER/packages.x86_64 $OVERLAY_FOLDER/packages.x86_64 > $WORK_FOLDER/packages.x86_64

# Merge the file systems
rsync -a $OVERLAY_ROOTFS/ $ROOT_ARCHLIVE/
# remove autologin this will be setup by the autologin package of p3ng0s
rm -rf $ROOT_ARCHLIVE/etc/systemd/system/getty\@tty1.service.d/autologin.conf

if [ ! -z $LINK_TO_BACKUP ]; then
	# Download backup
	echo -e "Fetching backup from $LINK_TO_BACKUP -> \e[36m:)\e[0m"
	curl $LINK_TO_BACKUP --output $BACKUP_FILE
	tar -xf $BACKUP_FILE -C $BACKUP_FOLDER

	## move config
	[ -d "$BACKUP_FOLDER/.vim/" ] && cp -r $BACKUP_FOLDER/.vim/ $HOME_ARCHLIVE
	[ -d "$BACKUP_FOLDER/.tmux/" ] && cp -r $BACKUP_FOLDER/.tmux/ $HOME_ARCHLIVE
	[ -f "$BACKUP_FOLDER/.gdbinit" ] && cp -r $BACKUP_FOLDER/.gdbinit $HOME_ARCHLIVE
	[ -f "$BACKUP_FOLDER/.Xresources" ] && cp -r $BACKUP_FOLDER/.Xresources $HOME_ARCHLIVE
	[ -f "$BACKUP_FOLDER/.tmux.conf" ] && cp -r $BACKUP_FOLDER/.tmux.conf $HOME_ARCHLIVE
	[ -f "$BACKUP_FOLDER/.vimrc" ] && cp -r $BACKUP_FOLDER/.vimrc $HOME_ARCHLIVE
	[ -f "$BACKUP_FOLDER/.bashrc" ] && cp -r $BACKUP_FOLDER/.bashrc $HOME_ARCHLIVE
	[ -f "$BACKUP_FOLDER/.tigrc" ] && cp -r $BACKUP_FOLDER/.tigrc $HOME_ARCHLIVE
	[ -f "$BACKUP_FOLDER/.wallpaper.png" ] && cp -r $BACKUP_FOLDER/.wallpaper.png $HOME_ARCHLIVE
	echo -e "Moved terminal config to archlive -> \e[36m:)\e[0m"
fi


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


# setup for startx with the live version of the windows manager
[ ! -f $HOME_ARCHLIVE/.xinitrc ] && echo -e "xrdb -merge ~/.Xresources\nexec dwm-live" > $HOME_ARCHLIVE/.xinitrc

# Build all packages
package_builder

# Last step build iso
build

exit 0
