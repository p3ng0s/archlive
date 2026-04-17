#!/bin/bash
# p3ng0s-panic.sh
# Created on: Fri 17 Apr 2026 01:17:09 PM CEST
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
# panic mode running from udev if the USB drive is unplugged!

for dev in $(dmsetup ls --target crypt | awk '{print $1}'); do
    cryptsetup close $dev
done

# wipe RAM
echo 3 > /proc/sys/vm/drop_caches

# kill all user processes
pkill -9 -u operator

# shutdown immediately
shutdown -h now
