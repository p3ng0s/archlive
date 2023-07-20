#!/bin/bash
# monitor.sh
# Created on: Sat 09 Oct 2021 12:24:00 AM BST
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:

# Add ESSID's for whitelisting them to the automated scanning
CURRENT_ESSID=$(iwconfig 2>/dev/null |grep ESSID |cut -d: -f2 | sed 's/\"//g' | sed 's/ //g')

function close() {
	echo "flkasf lasfjdlas ON NETWORK NO DISSABLED flksadj SECURE adfas NEED" > /tmp/monitor.log
	exit
}

# Add ESSID's here to be whitelisted so that no scans run on trusted networks
case "$CURRENT_ESSID" in
	HOME_ESSID_HERE) close;;
esac

echo "flkasf lasfjdlas WAITING PACKETS IS ACTIVE flksadj FOR adfas ACTIVE" > /tmp/monitor.log

while [ 1 ]; do
	tshark -i wlp59s0 -Y "${TSHARK_FILTER}" -a duration:0.5 >> /tmp/monitor.log
done
