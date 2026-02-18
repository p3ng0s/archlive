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

function blink_confirm() {
	for i in {1..15}; do
		echo 1 | tee /sys/class/leds/input*::capslock/brightness > /dev/null
		sleep 0.1
		echo 0 | tee /sys/class/leds/input*::capslock/brightness > /dev/null
		sleep 0.1
	done
}

get_password() {
    # If we are at boot (no TERM variable usually), we use 'read' directly on tty1

    return $PASS
}

if [ "$1" == "-m" ]; then
	LOOT_PARTITION=$(blkid -L "LOOT")
	if [ -n "$LOOT_PARTITION" ]; then
		for USER_HOME in /home/*; do
			[ -d "$USER_HOME" ] || continue
			LOOT_DIR=$USER_HOME/loot
			mkdir -p $LOOT_DIR
			USER_NAME=$(basename "$USER_HOME")
			chown "$USER_NAME:$USER_NAME" "$LOOT_DIR"
			USER_ID=$(id -u "$USER_NAME")
			GROUP_ID=$(id -g "$USER_NAME")
			mount -o "rw,nosuid,nodev,relatime,user,umask=000,uid=$USER_ID,gid=$GROUP_ID" "$LOOT_PARTITION" "$LOOT_DIR"
		done
		blink_confirm &
	fi

	VAULT_PARTITION=$(blkid -L "VAULT")
	if [ -n "$VAULT_PARTITION" ]; then
		if cryptsetup isLuks "$VAULT_PARTITION"; then
			# 1. Check if we are running at boot (no real user session yet)
			if [[ -z "$TERM" || "$TERM" == "linux" ]]; then
				# Direct hijack of the console to ensure it BLOCKS
				exec < /dev/tty1 > /dev/tty1 2>&1
				read -rs -p "Unlock p3ng0s loot drive: " PASS
			else
				# If we are in a terminal or GUI, use the systemd agent
				PASS=$(systemd-ask-password "Unlock p3ng0s loot drive:")
			fi
			echo $PASS | cryptsetup open "$VAULT_PARTITION" luks_loot -
			if [ -b "/dev/mapper/luks_loot" ]; then
				echo -e "\e[36m[*]\e[0m Correct password mounting loot!" 
				for USER_HOME in /home/*; do
					[ -d "$USER_HOME" ] || continue
					LOOT_DIR=$USER_HOME/loot
					mkdir -p $LOOT_DIR
					USER_NAME=$(basename "$USER_HOME")
					chown "$USER_NAME:$USER_NAME" "$LOOT_DIR"
					USER_ID=$(id -u "$USER_NAME")
					GROUP_ID=$(id -g "$USER_NAME")
					mount -o "rw,nosuid,nodev,relatime,user,umask=000,uid=$USER_ID,gid=$GROUP_ID" /dev/mapper/luks_loot "$LOOT_DIR"
				done
				blink_confirm &
			else
				echo -e "\e[1;31m[!]\e[0m Incorrect password loot won't be mounted"
			fi
		fi
	fi
else
		for USER_HOME in /home/*; do
			[ -d "$USER_HOME/loot" ] || continue
			LOOT_DIR=$USER_HOME/loot
			umount $LOOT_DIR
			rm -rf $LOOT_DIR
		done
		cryptsetup close luks_loot
fi
sleep 2
