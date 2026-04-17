#!/bin/bash
# looter.sh
# Created on: Wed 11 Feb 2026 08:07:52 PM CET
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  A script to automatically mount a drived labeled LOOT inside of /home/*/loot

sleep 2
NETWORK_LOOT_CMD=""
DEBUG=

function blink_confirm() {
	for i in {1..15}; do
		echo 1 | tee /sys/class/leds/input*::capslock/brightness > /dev/null
		sleep 0.1
		echo 0 | tee /sys/class/leds/input*::capslock/brightness > /dev/null
		sleep 0.1
	done
}

function self_provisioning_screen() {
	/usr/bin/kbd_mode -s -C /dev/tty1
	echo 0 > /proc/sys/kernel/printk
	clear > /dev/tty1
	while true; do
		if [ -z "$(pgrep fbi)" ]; then
			fbi -T 1 -noverbose -u /etc/p3ng0s/wallpaper/p3ng0s_selfprovisioning.png &
		fi
		sleep 5
	done

}

if [ "$1" == "-m" ]; then
	LOOT_PARTITION=$(blkid -L "LOOT")
	VAULT_PARTITION=$(blkid -L "VAULT")

	if [ -n "$LOOT_PARTITION" ] || [ -n "$VAULT_PARTITION" ]; then
		if cryptsetup isLuks "$VAULT_PARTITION" 2> /dev/null; then
			# 1. Check if we are running at boot (no real user session yet)
			if [[ -z "$TERM" || "$TERM" == "linux" ]]; then
				# Direct hijack of the console to ensure it BLOCKS
				exec < /dev/tty1 > /dev/tty1 2>&1
				echo -e "\e[36m[*]\e[0m Waiting 5 seconds for systemd to finish up."
				sleep 5
				read -rs -p "Unlock p3ng0s loot drive: " PASS
			else
				# If we are in a terminal or GUI, use the systemd agent
				PASS=$(systemd-ask-password "Unlock p3ng0s loot drive:")
			fi
			LOOP_DEV=$(losetup -fP --show $VAULT_PARTITION)
			echo $PASS | cryptsetup open "$LOOP_DEV" luks_loot -
			if [ ! -b "/dev/mapper/luks_loot" ]; then
				echo -e "\e[1;31m[!]\e[0m Incorrect password loot won't be mounted"
				exit 1
			else
				echo -e "\e[36m[*]\e[0m Correct password mounting loot!"
			fi
		else
			LOOP_DEV=$(losetup -fP --show $LOOT_PARTITION)
		fi
		for USER_HOME in /home/*; do
			[ -d "$USER_HOME" ] || continue
			LOOT_DIR=$USER_HOME/loot
			mkdir -p $LOOT_DIR
			USER_NAME=$(basename "$USER_HOME")
			chown "$USER_NAME:$USER_NAME" "$LOOT_DIR"
			USER_ID=$(id -u "$USER_NAME")
			GROUP_ID=$(id -g "$USER_NAME")
			if [ ! -b "/dev/mapper/luks_loot" ]; then
				mount -o "rw,nosuid,nodev,relatime,user,umask=000,uid=$USER_ID,gid=$GROUP_ID" "$LOOP_DEV" "$LOOT_DIR"
			else
				mount -o "rw,nosuid,nodev,relatime,user,umask=000,uid=$USER_ID,gid=$GROUP_ID" /dev/mapper/luks_loot "$LOOT_DIR"
			fi
		done
		blink_confirm &
	elif [ ! -z "$NETWORK_LOOT_CMD" ]; then
		[ -z "$DEBUG" ] && self_provisioning_screen &
		BOOT_DEV=$(lsblk -lnpo NAME,MOUNTPOINT | awk '$2=="/run/archiso/bootmnt" {print $1}' | sed 's/[0-9]*$//')
		UNFORMATED=$(lsblk $BOOT_DEV -lnpo NAME,FSTYPE,LABEL | awk '$2=="" && $3=="" {print $1}')
		[ "$DEBUG" ] && echo "BOOT_DEV=$BOOT_DEV"
		[ "$DEBUG" ] && echo "UNFORMATED=$UNFORMATED"
		sleep 5
		if [ -z "$UNFORMATED" ]; then # Boot cycle 1 -> create partition
			ISO_SIZE=$(lsblk -lnpo NAME,SIZE,FSTYPE | awk '$3=="iso9660" && $1!~/^\/dev\/[a-z]+$/ {print $2}' | head -n1 | tr -d 'G')
			LOOT_START=$(awk "BEGIN {printf \"%d\", ($ISO_SIZE + 5 + 0.999)}")G
			[ "$DEBUG" ] && echo -e "\e[36m[*]\e[0m Partitioning USB..."
			parted $BOOT_DEV ---pretend-input-tty mkpart primary $LOOT_START 100% <<<"I"
			#parted $BOOT_DEV ---pretend-input-tty mkpart primary exfat $LOOT_START 100% <<<"I"
			sleep 15
			USB_ENTRY=$(efibootmgr | grep -i "usb\|removable" | grep -vi "network" | head -n 1 | awk '{gsub(/Boot|\*/,"",$1); printf "%04s\n", $1}')
			[ -n "$USB_ENTRY" ] && efibootmgr --bootnext $USB_ENTRY
			reboot now
		else # Boot cycle 2 -> format and install loot
			LOOT_PART=$(lsblk $BOOT_DEV -lnpo NAME,FSTYPE,LABEL | awk '$2=="" && $3=="" {print $1}' | head -n1)
			[ "$DEBUG" ] && echo -e "\e[36m[*]\e[0m Creating LOOT ..."
			dd if=/dev/zero of=/tmp/loot.img bs=1M count=10
			mkfs.exfat -L LOOT /tmp/loot.img
			dd if=/tmp/loot.img of=$LOOT_PART bs=1M
			LOOP_LOOT=$(losetup -fP --show $LOOT_PART)
			mount $LOOP_LOOT /mnt/

			[ "$DEBUG" ] && echo -e "\e[36m[*]\e[0m Waiting for network..."
			until ping -c1 -W2 8.8.8.8 &>/dev/null; do
				echo 1 | tee /sys/class/leds/input*::capslock/brightness > /dev/null
				sleep 1
				echo 0 | tee /sys/class/leds/input*::capslock/brightness > /dev/null
				sleep 1
			done
			[ "$DEBUG" ] && echo -e "\e[32m[+]\e[0m Network ready"
			eval "$NETWORK_LOOT_CMD -o /tmp/loot.tar.xz"
			mkdir -p "/tmp/loot/"
			tar -xf "/tmp/loot.tar.xz" -C "/tmp/loot/"
			rm -rf /tmp/loot.tar.xz

			[ "$DEBUG" ] && echo -e "\e[36m[*]\e[0m Syncing Files ..."
			rsync -a /tmp/loot/ /mnt/
			umount /mnt/
			sleep 15
			USB_ENTRY=$(efibootmgr | grep -i "usb\|removable" | grep -vi "network" | head -n 1 | awk '{gsub(/Boot|\*/,"",$1); printf "%04s\n", $1}')
			[ -n "$USB_ENTRY" ] && efibootmgr --bootnext $USB_ENTRY
			reboot now
		fi
		#reboot now
	fi
else
		for USER_HOME in /home/*; do
			[ -d "$USER_HOME/loot" ] || continue
			LOOT_DIR=$USER_HOME/loot
			umount $LOOT_DIR
			rm -rf $LOOT_DIR
		done
		cryptsetup close luks_loot 2> /dev/null
fi
sleep 2
