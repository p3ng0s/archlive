#!/bin/bash
# locker.sh
# Created on: Fri 28 Jul 2023 06:34:58 PM CEST
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
# a shell scrip to not run lock even if running

PID=$(pgrep i3lock)

[ -z "$PID" ] && i3lock-fancy -p -t "Oh hell no!"
