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
