#!/bin/bash
# logic.sh
# Created on: Fri 27 Feb 2026 08:21:05 PM CET
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  This script is managed by installer.sh
#
PIPE="/tmp/install_log.pipe"

# Function to run a command and log it to the right pane
function run_command() {
    echo "# $1" > $PIPE
    #eval "$1" >> $PIPE 2>&1
    return $?
}

function log_output() {
    eval "echo -e '$1'" >> $PIPE 2>&1
    return $?
}

dialog --title "p3ng0s Installer ^^" --msgbox "\nYou are now going to take the final step and install p3ng0s on a machine.\n\nNote that Installing p3ng0s will nuke everything you previously had and is irreversible this is not something you should take lightly!" 10 40

partitions=$(lsblk -dnpo NAME,SIZE --sort SIZE)
partition_options=()
while read -r name size; do
    partition_options+=( "$name" "$name ($size)" )
done <<< "$partitions"
selected_partition=$(dialog --title "Select a Disk" \
                            --menu "Select a disk to flash the iso (ordered by size)" 20 70 15 \
                            "${partition_options[@]}" \
                            2>&1 >/dev/tty)
if [[ -z "$selected_partition" ]]; then
    echo -e "\e[1;31m[!]\e[m No partition selected. Exiting.. ^^"
    true > $PIPE
    exit 0
fi

log_output "Got drive $selected_partition -> \e[36m:)\e[0m"

# 1. Create a new GPT partition table
run_command "parted $selected_partition mklabel gpt"

# 2. Create the EFI System Partition (1 GiB)
# Note: Starting at 1MiB for optimal sector alignment
run_command "parted $selected_partition mkpart 'EFI system partition' fat32 1MiB 1025MiB"
run_command "parted $selected_partition set 1 esp on"

# 3. Create the SWAP partition (4 GiB)
run_command "parted $selected_partition mkpart 'linux-swap' linux-swap 1025MiB 5121MiB"

# 4. Create the Root partition (Remainder of the device)
# Using -1s tells parted to use the very last sector of the disk
run_command "parted $selected_partition mkpart "root" ext4 5121MiB 100%"

true > $PIPE
