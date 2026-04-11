#!/bin/bash
# shimmyyay.sh
# Created on: Fri 10 Apr 2026 03:50:35 PM CEST
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
# p3ng0s shim signing
# remove from airootfs!


echo -e "Signing kernel -> \e[36m:)\e[0m"
sbsign --key "/etc/p3ng0s/shim/MOK.key" \
    --cert "/etc/p3ng0s/shim/MOK.crt" \
    --output /boot/vmlinuz-linux \
    /boot/vmlinuz-linux

# Shred keys
shred -u "/etc/p3ng0s/shim/MOK.key"
shred -u "/etc/p3ng0s/shim/MOK.crt"

