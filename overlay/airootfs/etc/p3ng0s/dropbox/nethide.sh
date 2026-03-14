#!/bin/bash
# nethide.sh
# Created on: Thu 12 Mar 2026 10:26:41 PM CET
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  Change the network interface ip address

DROPBOX_FOLDER=/home/p4p1-live/loot/dropbox
DEBUG_LOG=$DROPBOX_FOLDER/network_rotate.log
if [ -f "$DROPBOX_FOLDER/config" ]; then
    INTERFACE=$(/usr/bin/grep -oP 'INTERFACE="\K[^"]+' $DROPBOX_FOLDER/config)
else
    INTERFACE=$(ip route show default | awk '/default/ {print $5}' | head -n1)
fi

exec > >(tee -a "$DEBUG_LOG" > /dev/tty1) 2>&1

# Bring interface down
ip link set $INTERFACE down

if [ -f $DROPBOX_FOLDER/hostnames.txt ]; then
    NEW_HOSTNAME=$(shuf -n1 $DROPBOX_FOLDER/hostnames.txt)
    hostnamectl set-hostname $NEW_HOSTNAME
    echo "$(date) - Hostname rotated to $NEW_HOSTNAME"
fi

# Generate random MAC
macchanger -r $INTERFACE

dhclient -r $INTERFACE
dhclient $INTERFACE

# Bring back up
ip link set $INTERFACE up

# Log it
echo "$(date) - MAC rotated on $INTERFACE to $(cat /sys/class/net/$INTERFACE/address)"
