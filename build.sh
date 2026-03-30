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

WORK_FOLDER=$PWD/work
ROOT_ARCHLIVE=$WORK_FOLDER/airootfs
HOME_ARCHLIVE=$ROOT_ARCHLIVE/etc/skel
BIN_ARCHLIVE=$ROOT_ARCHLIVE/usr/local/bin

OVERLAY_FOLDER=$PWD/overlay
OVERLAY_ROOTFS=$OVERLAY_FOLDER/airootfs

PACKAGER_REPO=https://github.com/p3ng0s/packager
PACKAGER_FOLDER=$PWD/packager

DOCKER=false
ENABLE_ALL=false
OPERATOR_STRING=""
GIT_APPOCALYPSE_OVERWRITE=

# Display usage information
function usage () {
	echo -e "\e[1;31mUsage:\e[m" 1>&2
	echo "$0 -a -> Support everything (This makes a big .iso don't use it)" 1>&2
	echo "$0 -o -> Multiple operator accounts." 1>&2
	echo "$0 -b -> Build only." 1>&2
	echo "$0 -p -> Pakcages only." 1>&2
	echo "$0 -c -> Delete all temp folder and build folder." 1>&2
	echo "$0 -u -> Update etc/skel to the latest content of backup.tar.xz requires a link to the file provided" 1>&2
	echo "$0 -d -> Only used for docker! do not use this!!" 1>&2
	echo "$0 -f -> Flash a USB stick with the selected iso." 1>&2
	echo -e "\e[1;31mExamples:\e[m" 1>&2
	echo "$0" 1>&2
	echo "$0 -o jakob:/home/backup.tar.xz,leo:/home/backup.tar.xz" 1>&2
	echo "$0 -u http://leosmith.wtf/" 1>&2
	echo "$0 -p" 1>&2
	echo "$0 -b" 1>&2
	echo "$0 -c" 1>&2
	echo "$0 -f" 1>&2
	echo "$0 -a" 1>&2
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
function is_this_okay_without_exit() {
	while true; do
		read -p "Continue? (Y/n): " answer
		case "$answer" in
			n|N) return 1 ;;
			*) return 0
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
	pv "$isofile" | dd of="$selected_partition" bs=4M conv=fsync oflag=direct iflag=fullblock
	sgdisk -e "$selected_partition"
	partprobe "$selected_partition"
	sleep 1
	ISO_SIZE=$(du -b "$isofile" | awk '{print $1}')
	ISO_SIZE_GiB=$(( ISO_SIZE / 1024 / 1024 / 1024 + 3 ))  # +1 for rounding up
	echo -e "\e[1;31mCreating partition after ${ISO_SIZE_GiB}GB!\e[m"
	parted --script "$selected_partition" mkpart primary ext4 ${ISO_SIZE_GiB}GB 100%
	fdisk -l $selected_partition
	echo "waiting 5 seconds for drive to be okay to mess around with"
	sleep 5
	echo -e "\e[1;31mDo you want to encrypt the drive?\e[m"
	is_this_okay_without_exit
	val=$?
	if [[ $val -eq 0 ]]; then
		echo -e "\e[1;31mIs this the correct loot partition?\e[m"
		partition_to_crypt=$(lsblk -npo NAME,FSTYPE "$selected_partition" --sort SIZE | grep -vE "vfat|iso9660" | awk '{print $1}')
		echo $partition_to_crypt
		echo "If not please do the following manually:"
		echo "wipefs -a /dev/sdaX"
		echo "mkfs.exfat -L LOOT /dev/sdaX"
		echo "cryptsetup luksFormat <replace with correct partition>"
		echo "cryptsetup open <replace with correct partition> p3ng0s_unlocked"
		echo "mkfs.exfat -L LOOT /dev/mapper/p3ng0s_unlocked"
		echo "cryptsetup close p3ng0s_unlocked"
		wipefs -a $partition_to_crypt
		cryptsetup luksFormat --label VAULT $partition_to_crypt
		cryptsetup open $partition_to_crypt p3ng0s_unlocked
		mkfs.exfat -L LOOT /dev/mapper/p3ng0s_unlocked
		sleep 1
		cryptsetup close p3ng0s_unlocked
	else
		loot_partition=$(lsblk -npo NAME,FSTYPE "$selected_partition" --sort SIZE | grep -vE "vfat|iso9660" | awk '{print $1}')
		wipefs -a $loot_partition
		mkfs.exfat -L LOOT $loot_partition
	fi
	echo -e "All done -> \e[36m:)\e[0m"
}

function package_builder () {
	branch=$(git rev-parse --abbrev-ref HEAD)
	[ -d $PACKAGER_REPO ] && return
	git clone $PACKAGER_REPO
	BUILD_TMP_DIR=$(pwd)
	cd $PACKAGER_FOLDER
	git checkout $branch
	if [ ! -z $GIT_APPOCALYPSE_OVERWRITE ]; then
		cp -r $GIT_APPOCALYPSE_OVERWRITE ./git-appocalypse/tools.json
	fi
	if [ "$DOCKER" = true ]; then
		chown builder:builder . -R
		[ "$ENABLE_ALL" = true ] && sudo -u builder ./setup.sh -a || sudo -u builder ./setup.sh
	else
		[ "$ENABLE_ALL" = true ] && ./setup.sh -a || ./setup.sh
	fi
	cd $BUILD_TMP_DIR
	echo -e "Installed p3ng0s repositories -> \e[36m:)\e[0m"
	notify-send -u critical "Critical" "p3ng0s Packages are built please re-enter root password!"
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
	notify-send -u critical "Critical" "p3ng0s build has been completed"
	echo -e "All done -> \e[36m:)\e[0m"
}

function driver_support() {
	if [ "$ENABLE_ALL" = true ]; then
		sed -i "s|^#\(.*nvidia.*\)|\1|" $WORK_FOLDER/packages.x86_64
		sed -i "s|^#\(.*cuda.*\)|\1|" $WORK_FOLDER/packages.x86_64
		sed -i "s|^#\(.*nvidia-utils.*\)|\1|" $WORK_FOLDER/packages.x86_64
		sed -i "s|^#\(.*opencl-nvidia.*\)|\1|" $WORK_FOLDER/packages.x86_64
		sed -i "s|^#\(.*rocm-opencl-runtime.*\)|\1|" $WORK_FOLDER/packages.x86_64
		sed -i "s|^#\(.*hip-runtime-amd.*\)|\1|" $WORK_FOLDER/packages.x86_64
		sed -i "s|^#\(.*rocm-hip-sdk.*\)|\1|" $WORK_FOLDER/packages.x86_64
		sed -i "s|^#\(.*intel-compute-runtime.*\)|\1|" $WORK_FOLDER/packages.x86_64
		return
	fi
	drivers=$(dialog --title "Driver support" \
		--checklist "...." 20 70 15 \
		"intel" "Intel ~2GB" on\
		"amd" "AMD ~8GB" on \
		"nvidia" "Nvidia + OpenCL ~4GB" off\
		2>&1 >/dev/tty)
	EXIT_STATUS=$?

	if [ $EXIT_STATUS -ne 0 ]; then
		echo "Exiting..."
		return
	fi
	if echo "$drivers" | grep -q "nvidia"; then
		sed -i "s|^#\(.*nvidia.*\)|\1|" $WORK_FOLDER/packages.x86_64
		sed -i "s|^#\(.*nvidia-utils.*\)|\1|" $WORK_FOLDER/packages.x86_64
		sed -i "s|^#\(.*opencl-nvidia.*\)|\1|" $WORK_FOLDER/packages.x86_64
		sed -i "s|^#\(.*cuda.*\)|\1|" $WORK_FOLDER/packages.x86_64
	fi
	if echo "$drivers" | grep -q "amd"; then
		sed -i "s|^#\(.*rocm-opencl-runtime.*\)|\1|" $WORK_FOLDER/packages.x86_64
		sed -i "s|^#\(.*hip-runtime-amd.*\)|\1|" $WORK_FOLDER/packages.x86_64
		sed -i "s|^#\(.*rocm-hip-sdk.*\)|\1|" $WORK_FOLDER/packages.x86_64
	fi
	if echo "$drivers" | grep -q "intel"; then
		sed -i "s|^#\(.*intel-compute-runtime.*\)|\1|" $WORK_FOLDER/packages.x86_64
	fi
}

function setup_accounts() {
	password=$(dialog --stdout --title "Set Root Password" \
		--passwordbox "Enter root and p4p1-live password:" 8 40)
	hashed=$(openssl passwd -6 "$password")
	local UID_COUNTER=1001

	sed -i "s|^root:[^:]*:|root:${hashed}:|" $WORK_FOLDER/airootfs/etc/shadow
	sed -i "s|^p4p1-live:[^:]*:|p4p1-live:${hashed}:|" $WORK_FOLDER/airootfs/etc/shadow
	IFS=',' read -ra OPERATORS <<< "$OPERATOR_STRING"
	for OPERATOR in "${OPERATORS[@]}"; do
		# Split by , to get name and tarball
		SHELL=/bin/bash
		IFS=':' read -r NAME TARBALL <<< "$OPERATOR"
		if [ -z "$NAME" ] || [ -z "$TARBALL" ]; then
			echo "Invalid operator format: $OPERATOR"
			continue
		fi
		if [ ! -f "$TARBALL" ]; then
			echo "Tarball not found: $TARBALL"
			continue
		fi
		echo -e "Creating operator: $OPERATOR -> \e[36m:)\e[0m"
		mkdir -p $WORK_FOLDER/airootfs/home/$NAME
		mkdir -p $WORK_FOLDER/airootfs/etc/tmpfiles.d/
		tar -xf "$TARBALL" -C $WORK_FOLDER/airootfs/home/$NAME
		echo "d /home/$NAME 0755 $NAME $NAME -" >> $WORK_FOLDER/airootfs/etc/tmpfiles.d/operators.conf
		[ -f $WORK_FOLDER/airootfs/home/$NAME/.zshrc ] && SHELL=/bin/zsh
		echo "$NAME:x:$UID_COUNTER:$UID_COUNTER::/home/$NAME:$SHELL" >> $WORK_FOLDER/airootfs/etc/passwd
		echo "$NAME:!:19000:0:99999:7:::" >> $WORK_FOLDER/airootfs/etc/shadow
		echo "$NAME:x:$UID_COUNTER:$NAME" >> $WORK_FOLDER/airootfs/etc/group
		sed -i "s/^wheel:x:10:.*/&,$NAME/" $WORK_FOLDER/airootfs/etc/group
		sed -i "s/^adm:x:4:.*/&,$NAME/" $WORK_FOLDER/airootfs/etc/group
		sed -i "s/^uucp:x:14:.*/&,$NAME/" $WORK_FOLDER/airootfs/etc/group
		sed -i "s/^lp:x:991:.*/&,$NAME/" $WORK_FOLDER/airootfs/etc/group
		sed -i "s/^kvm:x:994:.*/&,$NAME/" $WORK_FOLDER/airootfs/etc/group
		sed -i "s/^wireshark:x:150:.*/&,$NAME/" $WORK_FOLDER/airootfs/etc/group
		sed -i "s/^installer:x:2000:.*/&,$NAME/" $WORK_FOLDER/airootfs/etc/group
		UID_COUNTER=$((UID_COUNTER + 1))
	done
}

function network_loot_support() {
	while true; do
		CURL_CMD=$(dialog --stdout --title "Network Loot" \
			--inputbox "Paste full curl command for network loot (leave empty to disable):" \
			10 80)
		if [ -z "$CURL_CMD" ]; then
			break
		fi
		 if echo "$CURL_CMD" | grep -qE "(^| )(-o|--output)( |$)"; then
			dialog --msgbox "Do not include -o in your curl command, it is added automatically" 6 50
			continue
		fi
		sed -i "s|NETWORK_LOOT_CMD=.*|NETWORK_LOOT_CMD=\"$CURL_CMD\"|" \
			$WORK_FOLDER/airootfs/etc/p3ng0s/looter.sh
		break
	done
}

while getopts "g:abdfpcu:o:" o; do
	case "${o}" in
		c)
			#echo -e "Removing the $PACKAGER_FOLDER folder -> \e[36m:)\e[0m"
			#rm -rf $PACKAGER_FOLDER
			echo -e "Delete $ISO_BUILD_DIR -> \e[36m:)\e[0m"
			rm -rf $ISO_BUILD_DIR
			#echo -e "Delete $PWD/out/ -> \e[36m:)\e[0m"
			#rm -rf $PWD/out/
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
			# TODO: add a populate loot arguemnt to give it a loot template to test
			# out the different features
			flash_iso
			exit 0
			;;
		u)
			LINK_TO_BACKUP=$OPTARG
			;;
		g)
			GIT_APPOCALYPSE_OVERWRITE="$OPTARG"
			;;
		d)
			DOCKER=true
			;;
		a)
			ENABLE_ALL=true
			;;
		o)
			OPERATOR_STRING=$OPTARG
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
echo -e "Create profiledef.sh -> \e[36m:)\e[0m"

diff -u $UPSTREAM_FOLDER/pacman.conf $OVERLAY_FOLDER/pacman.conf > $WORK_FOLDER/pacman.conf.patch
cat $WORK_FOLDER/pacman.conf.patch
is_this_okay
patch $WORK_FOLDER/pacman.conf < $WORK_FOLDER/pacman.conf.patch
# setting the PWD for pacman p3ng0s dependencies
sed -i 's|<CHANGE_PWD>|'"$PWD"'|g' $WORK_FOLDER/pacman.conf
echo -e "Created the pacman.conf -> \e[36m:)\e[0m"

# Combining packages
cat $UPSTREAM_FOLDER/packages.x86_64 $OVERLAY_FOLDER/packages.x86_64 > $WORK_FOLDER/packages.x86_64
echo -e "Setup the packages -> \e[36m:)\e[0m"

# Merge the file systems
rsync -a $OVERLAY_ROOTFS/ $ROOT_ARCHLIVE/
echo -e "Setup the filesystem -> \e[36m:)\e[0m"

# remove autologin this will be setup by the autologin package of p3ng0s
[ -f $ROOT_ARCHLIVE/etc/systemd/system/getty\@tty1.service.d/autologin.conf ] && rm -rf $ROOT_ARCHLIVE/etc/systemd/system/getty\@tty1.service.d/autologin.conf || echo -e "Autologin not present-> \e[31m:(\e[0m"
echo -e "Removed old autologin if present -> \e[36m:)\e[0m"
[ -f $ROOT_ARCHLIVE/etc/systemd/system/multi-user.target.wants/sshd.service ] && rm -rf $ROOT_ARCHLIVE/etc/systemd/system/multi-user.target.wants/sshd.service || echo -e "Sshd.service not present-> \e[31m:(\e[0m"
echo -e "Removed old sshd.service if present -> \e[36m:)\e[0m"
# setup for startx with the live version of the windows manager
[ ! -f $HOME_ARCHLIVE/.xinitrc ] && echo -e "xrdb -merge ~/.Xresources\nexec dwm-live" > $HOME_ARCHLIVE/.xinitrc || echo -e ".xinitrc present -> \e[31m:(\e[0m"
echo -e "Set the .xinitrc if missing -> \e[36m:)\e[0m"

if [ ! -z $LINK_TO_BACKUP ]; then
	# Download backup
	echo -e "Fetching backup from $LINK_TO_BACKUP -> \e[36m:)\e[0m"
	curl $LINK_TO_BACKUP --output $BACKUP_FILE
	mkdir -p $ROOT_ARCHLIVE/home/p4p1-live/
	tar -xf $BACKUP_FILE -C $ROOT_ARCHLIVE/home/p4p1-live/

	echo -e "Change the config of the default user p4p1-live -> \e[36m:)\e[0m"
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

driver_support
setup_accounts
network_loot_support

echo $GIT_APPOCALYPSE_OVERWRITE
if [ ! -d $PACKAGER_FOLDER ]; then
	#if [ "$EUID" -eq 0 ]; then
	#	echo -e "\e[1;31mPlease do not run as root\e[m"
	#	exit -1
	#fi
	echo -e "Pachakes don't exist I will build them :)-> \e[36m:)\e[0m"
	# Build all packages
	package_builder
elif [ ! -z $GIT_APPOCALYPSE_OVERWRITE ]; then # package already built but found overwrite so rebuilding git-appocalypse
	PKG_TMP_DIR=$(pwd)
	cp -r $GIT_APPOCALYPSE_OVERWRITE ./packager/git-appocalypse/tools.json
	cd packager/git-appocalypse/
	rm -rf src/ pkg/
	makepkg
	repo-add -n ../repo/p3ng0s.db.tar.gz $(find . -name "*.tar.zst")
	mv *.tar.zst ../repo
	cd $PKG_TMP_DIR
fi

if [ "$ENABLE_ALL" = true ]; then
	sed -i "s|^#\(.*docker.*\)|\1|" $WORK_FOLDER/packages.x86_64
	sed -i "s|^#\(.*docker-compose.*\)|\1|" $WORK_FOLDER/packages.x86_64
	sed -i "s|^#\(.*qemu-full.*\)|\1|" $WORK_FOLDER/packages.x86_64
	sed -i "s|^#\(.*edk2-ovmf.*\)|\1|" $WORK_FOLDER/packages.x86_64
	sed -i "s|^#\(.*metasploit.*\)|\1|" $WORK_FOLDER/packages.x86_64
	sed -i "s|^#\(.*android-tools.*\)|\1|" $WORK_FOLDER/packages.x86_64
fi

# Last step build iso
build

exit 0
