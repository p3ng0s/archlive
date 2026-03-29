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
GATEWAY=$(ip route show default | awk '/default/ {print $3}' | head -n1)
SERVER_IP=$(grep -oP 'SERVER_IP="\K[^"]+' $DROPBOX_FOLDER/config)
VPN_INTERFACE=$(ip route get $SERVER_IP | awk '{print $5}' | head -n1)
if [ -f "$DROPBOX_FOLDER/config" ]; then
    INTERFACE=$(/usr/bin/grep -oP 'INTERFACE="\K[^"]+' $DROPBOX_FOLDER/config)
    if [ -z "$INTERFACE" ]; then
        INTERFACE=$(ip route show default | awk '/default/ {print $5}' | head -n1)
    fi
else
    INTERFACE=$(ip route show default | awk '/default/ {print $5}' | head -n1)
fi

exec > >(tee -a "$DEBUG_LOG" > /dev/tty1) 2>&1
if [ "$VPN_INTERFACE" = "$INTERFACE" ]; then
    echo "$(date) - VPN running on same interface, will restart services after rotation"
    RESTART_VPN=true
else
    echo "$(date) - VPN on separate interface ($VPN_INTERFACE), skipping service restart"
    RESTART_VPN=false
fi

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

sleep 5

if [ "$RESTART_VPN" = true ]; then
    # Restart stunnel and openvpn
    systemctl restart stunnel.service
    systemctl restart openvpn-client@client.service

    # Wait for tun0 to come back
    for i in $(seq 1 30); do
        ip link show tun0 &>/dev/null && break
        echo "$(date) - Waiting for tun0... $i"
        sleep 2
    done

    # Reconfigure routes
    ip route add $SERVER_IP/32 via $GATEWAY 2>/dev/null
    ip route add 0.0.0.0/1 via 10.8.0.1 2>/dev/null
    ip route add 128.0.0.0/1 via 10.8.0.1 2>/dev/null

    # Restart sshd socket on new tun0
    systemctl restart sshd.socket
fi

echo "$(date) - Network rotation complete"

