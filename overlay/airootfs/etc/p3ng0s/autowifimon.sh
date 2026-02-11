#!/bin/bash
# autowifimon.sh
# Created on: Wed 11 Feb 2026 09:50:40 PM CET
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  A bash script that will automatically take the provided interface and enable
#  monitor mode on it with airmon-ng
#
INTERFACE=$1
if [[ "$INTERFACE" == *mon* ]]; then
    echo "exit first" >> /tmp/exit.txt
    exit 0
fi
sleep 1
/usr/bin/airmon-ng start $INTERFACE &> /tmp/autowifi.log
