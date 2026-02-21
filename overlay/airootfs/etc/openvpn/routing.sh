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

if [ -f /home/p4p1-live/loot/dropbox/config ]; then
	source /home/p4p1-live/loot/dropbox/config
else
	SERVER_IP="VPS_IP_ADDRESS"
fi
GATEWAY=$(ip route get 8.8.8.8 | grep -oP 'via \K\S+')
#GATEWAY=$(ip route get 8.8.8.8 | cut -d' ' -f3 | head -n1) # edit for lanturtle
sudo /usr/bin/ip route add $SERVER_IP/32 via $GATEWAY
sudo /usr/bin/ip route add 0.0.0.0/1 via 10.8.0.1
sudo /usr/bin/ip route add 128.0.0.0/1 via 10.8.0.1
