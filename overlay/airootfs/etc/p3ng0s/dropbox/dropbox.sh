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

function keep_alive() {
    while true; do
        sleep 30
        if ! pgrep openvpn > /dev/null; then
            systemctl restart openvpn-client@client.service &> /dev/null
        fi
        if ! pgrep stunnel > /dev/null; then
            systemctl restart stunnel.service &> /dev/null
        fi
        # TODO: check for routes and fix up the routing table.
    done
}

function debug_shell() {
    echo -e "\e[36m[*]\e[0m Debug shell - type commands, 'exit' to continue"
    while true; do
        read -p "debug> " CMD < /dev/tty1
        [ "$CMD" = "exit" ] && break
        eval "$CMD"
    done
}

echo "--- dropbox ---"

if [ ! -d $DROPBOX_FOLDER ]; then
    echo -e "\e[1;31m[!]\e[0m Cannot find the dropbox folder exiting"
fi
source $DROPBOX_FOLDER/config
SERVER_IP=$(grep -oP 'SERVER_IP="\K[^"]+' $DROPBOX_FOLDER/config)
GATEWAY=$(/usr/bin/ip route show default | awk '/default/ {print $3}' | head -n1)
if [ -z "$GATEWAY" ]; then
    GATEWAY=$(ip route get 8.8.8.8 | grep -oP 'via \K\S+')
fi

echo -e "\e[36m[*]\e[0m Checking for configs..."
mkdir -p /etc/stunnel /etc/openvpn/client $DROPBOX_FOLDER/conquest_data/log/ $DROPBOX_FOLDER/conquest_data/loot/
touch /etc/stunnel/stunnel.conf /etc/openvpn/client/client.conf

echo -e "\e[36m[*]\e[0m Mounting files"
mount --bind $DROPBOX_FOLDER/stunnel.conf /etc/stunnel/stunnel.conf
mount --bind $DROPBOX_FOLDER/client.ovpn /etc/openvpn/client/client.conf
[ -f $DROPBOX_FOLDER/sshd_config ] && mount --bind $DROPBOX_FOLDER/sshd_config /etc/ssh/sshd_config
[ -f $DROPBOX_FOLDER/conquest.toml ] && mount --bind $DROPBOX_FOLDER/conquest.toml /etc/conquest/default.toml

sleep 2
echo -e "\e[36m[*]\e[0m Starting services"
systemctl start stunnel.service
systemctl start openvpn-client@client.service
systemctl start sshd.socket
systemctl start conquest.service

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
echo -e "\e[36m[*]\e[0m Starting GUI"
systemctl status p3ng0s-dropbox-gui-dwm.service
echo -e "\e[36m[*]\e[0m Starting keepalive"
keep_alive &

echo -e "\e[36m[*]\e[0m Entering splash screen..."
sleep 5
[ -f $DROPBOX_FOLDER/debug ] && debug_shell
/usr/bin/kbd_mode -s -C /dev/tty1
echo 0 > /proc/sys/kernel/printk
clear > /dev/tty1
while true; do
    if [ -f $DROPBOX_FOLDER/splash.png ]; then
        CURRENT=$DROPBOX_FOLDER/splash.png
    else
        if [ $((RANDOM % 10)) -eq 0 ]; then
            CURRENT=/etc/p3ng0s/wallpaper/zz_dropbox_meme.png
        else
            CURRENT=/etc/p3ng0s/wallpaper/p3ng0s_dropbox.png
        fi
    fi
    if [ -z "$(pgrep fbi)" ]; then
        fbi -T 1 -noverbose -u $CURRENT 2> /dev/null &
    fi
    sleep 5
done
