#!/bin/bash
# routing.sh
# Created on: Fri 13 Feb 2026 09:57:19 PM CET
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  A script to handle the routing of openvpn through stunnel. If on live usb the
#  SERVER_IP will be captured by the config file present in the mounted loot folder.
#
if [ -d "/home/p4p1/loot/dropbox" ]; then
    DROPBOX_FOLDER="/home/p4p1/loot/dropbox"
elif [ -d "/home/p4p1-live/loot/dropbox" ]; then
    DROPBOX_FOLDER="/home/p4p1-live/loot/dropbox"
else
    echo "CRITICAL: Loot directory not found!" > /tmp/routing_error.log
fi

if [ -f "$DROPBOX_FOLDER/config" ]; then
	SERVER_IP=$(grep -oP 'SERVER_IP="\K[^"]+' $DROPBOX_FOLDER/config)
else
	SERVER_IP="VPS_IP_ADDRESS"
fi
#GATEWAY=$(/usr/bin/ip route get 8.8.8.8 | grep -oP 'via \K\S+')
GATEWAY=$(/usr/bin/ip route show default | awk '/default/ {print $3}' | head -n1)
# you could use this ip route technique: /usr/bin/ip route show default | awk '/default/ {print $3}' | head -n1
#GATEWAY=$(ip route get 8.8.8.8 | cut -d' ' -f3 | head -n1) # edit for lanturtle
sudo /usr/bin/ip route add $SERVER_IP/32 via $GATEWAY
sudo /usr/bin/ip route add 0.0.0.0/1 via 10.8.0.1
sudo /usr/bin/ip route add 128.0.0.0/1 via 10.8.0.1
echo $SERVER_IP - $GATEWAY
