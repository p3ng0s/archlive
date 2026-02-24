#!/bin/bash
# dropbox.sh
# Created on: Fri 20 Feb 2026 10:31:31 PM CET
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  The shell script that will handle the dropbox

#DROPBOX_FOLDER=/home/p4p1/loot/dropbox
DROPBOX_FOLDER=/home/p4p1-live/loot/dropbox
DEBUG_LOG=$DROPBOX_FOLDER/debug.log

if [[ -z "$TERM" || "$TERM" == "linux" ]]; then
    # Direct hijack of the console to ensure it BLOCKS
    #exec < /dev/tty1 > /dev/tty1 2>&1
    exec > >(tee -a "$DEBUG_LOG" > /dev/tty1) 2>&1
fi

echo "--- dropbox ---"

if [ ! -d $DROPBOX_FOLDER ]; then
    echo -e "\e[1;31m[!]\e[0m Cannot find the dropbox folder exiting"
fi
SERVER_IP=$(grep -oP 'SERVER_IP="\K[^"]+' $DROPBOX_FOLDER/config)
GATEWAY=$(/usr/bin/ip route show default | awk '/default/ {print $3}' | head -n1)

echo -e "\e[36m[*]\e[0m Checking for configs..."
mkdir -p /etc/stunnel /etc/openvpn/client
touch /etc/stunnel/stunnel.conf /etc/openvpn/client/client.conf

echo -e "\e[36m[*]\e[0m Mounting files"
mount --bind $DROPBOX_FOLDER/stunnel.conf /etc/stunnel/stunnel.conf
mount --bind $DROPBOX_FOLDER/client.ovpn /etc/openvpn/client/client.conf

sleep 2
echo -e "\e[36m[*]\e[0m Starting services"
systemctl start stunnel.service
systemctl start openvpn-client@client.service
systemctl start sshd.service

echo -e "\e[36m[*]\e[0m Checking Setting"
systemctl status stunnel.service
sleep 2
systemctl status openvpn-client@client.service
sleep 2
ip a s
sleep 2
echo -e "\e[36m[*]\e[0m Force setting routes in case the openvpn script bugged."
/usr/bin/ip route add $SERVER_IP/32 via $GATEWAY
/usr/bin/ip route add 0.0.0.0/1 via 10.8.0.1
/usr/bin/ip route add 128.0.0.0/1 via 10.8.0.1
sleep 2
echo -e "\e[36m[*]\e[0m Checking routes"
ip route
echo -e "\e[36m[*]\e[0m Variables"
echo "SERVER_IP=$SERVER_IP"
echo "GATEWAY=$GATEWAY"

echo -e "\e[36m[*]\e[0m Entering splash screen..."
sleep 5
/usr/bin/kbd_mode -s -C /dev/tty1
while true; do
    if [ -f $DROPBOX_FOLDER/splash.png ]; then
        fbi -noverbose -u $DROPBOX_FOLDER/splash.png
    else
        fbi -noverbose -u /etc/p3ng0s/wallpaper/dropbox.png
    fi
done
