#!/bin/bash
# os_killer.sh
# Created on: Sat 29 Jul 2023 08:18:34 PM CEST
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  A script that will let you take a partition mount it and do a few simple
#  attacks on it. For windows partitions it will dump the SAM database to the
#  tmp of the p3ng0s system and will also let you change cmd.exe to utilman.exe.
#  For linux it will allow you to have a copy of etc/shadow and etc/passwd on the
#  tmp of the p3ng0s system and will also allow you to chroot inside of  the system
#  for extra control ^^
# Usage:
#  This script is usually run by .bash_profile during the welcome page of p3ng0s
#  but can be run independantly.

function list_hard_drives() {
    partitions=$(lsblk -npo NAME,SIZE --sort SIZE | tac)
    partition_options=()
    while read -r name size; do
        partition_options+=( "$name" "$name ($size)" )
    done <<< "$partitions"
    selected_partition=$(dialog --title "Select a Partition" \
                                 --menu "Choose a partition to proceed (ordered by size):" 20 70 15 \
                                 "${partition_options[@]}" \
                                 2>&1 >/dev/tty)
    if [[ -z "$selected_partition" ]]; then
        echo -e "\e[1;31m[!]\e[m No partition selected. Exiting.. ^^"
        exit 0
    fi
    sudo mount $selected_partition /mnt
}

export DIALOGRC="/etc/p3ng0s/dialogrc"

list_hard_drives

sleep 5
exit
