#!/bin/bash
# raro.sh
# Created on: Thu 13 Aug 2020 06:07:34 AM CEST
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
# run script as root from dmenu

pass=$(echo -n "" | dmenu -p "password:" -c -nb "#443166" -nf "#393939" -sb "#393939" -sf "#bbbbbb")

echo $pass | sudo -S $@
