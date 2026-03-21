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
RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RAM_GiB=$(( RAM_KB / 1024 / 1024 ))
SWAP_GiB=$(( RAM_GiB * 2 ))

EFI_START="1MiB"
EFI_END="1025MiB"
SWAP_START="1025MiB"
SWAP_END="$(( 1025 + (SWAP_GiB * 1024) ))MiB"
ROOT_START="$SWAP_END"
ROOT_END="100%"

# Function to run a command and log it to the right pane
function run_command() {
    echo "# $1" > $PIPE
    #eval "$1" >> $PIPE 2>&1
    return $?
}

function log_output() {
    echo -e "$1" >> $PIPE 2>&1
    return $?
}

dialog --title "p3ng0s Installer ^^" --msgbox "\nYou are now going to take the final step and install p3ng0s on a machine.\n\nNote that Installing p3ng0s will nuke everything you previously had and is irreversible this is not something you should take lightly!" 20 70

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

install_mode=$(dialog --title "Installation Mode" \
    --menu "Select installation type:" 10 50 2 \
    1 "Bare metal (daily driver)" \
    2 "VM (keep live user + loot partition)" \
    2>&1 >/dev/tty)

if [ "$install_mode" = "2" ]; then
    log_output "Install mode is set to VM -> \e[36m:)\e[0m"
    SWAP_GiB=4
    SWAP_END="$(( 1025 + (SWAP_GiB * 1024) ))MiB"
    LOOT_START="$SWAP_END"
    LOOT_END="$(( 1025 + (SWAP_GiB * 1024) + 10240 ))MiB"
    ROOT_START="$LOOT_END"
fi

log_output "Partition layout:"
log_output "  EFI:  $EFI_START -> $EFI_END"
log_output "  SWAP: $SWAP_START -> $SWAP_END (${SWAP_GiB}GiB)"
[ "$install_mode" = "2" ] && log_output "  LOOT: $LOOT_START -> $LOOT_END (10GiB)"
log_output "  ROOT: $ROOT_START -> $ROOT_END"

dialog --title "FINAL WARNING" \
    --yesno "\nYou are about to COMPLETELY WIPE:\n\n  $selected_partition\n\nMode: $([ "$install_mode" = "2" ] && echo 'VM' || echo 'Bare Metal')\nSwap: ${SWAP_GiB}GiB\n\nTHIS CANNOT BE UNDONE!\nAre you absolutely sure?" 15 50
[ $? -ne 0 ] && exit 0


# Nuke drive
run_command "wipefs -a $selected_partition"
run_command "sgdisk -Z $selected_partition"

partprobe $selected_partition
sleep 3

# Partition Drive:
run_command "parted -s $selected_partition mklabel gpt"
run_command "parted -s $selected_partition mkpart 'EFI' fat32 $EFI_START $EFI_END"
run_command "parted -s $selected_partition set 1 esp on"
run_command "parted -s $selected_partition mkpart 'SWAP' linux-swap $SWAP_START $SWAP_END"
if [ "$install_mode" = "2" ]; then
    run_command "parted -s $selected_partition mkpart 'LOOT' $LOOT_START $LOOT_END"
fi
run_command "parted -s $selected_partition mkpart 'ROOT' ext4 $ROOT_START $ROOT_END"

partprobe $selected_partition
sleep 3

# Generate the variables for the flashing and install:
EFI_NUM=$(parted -s $selected_partition print | grep 'EFI' | awk '{print $1}')
SWAP_NUM=$(parted -s $selected_partition print | grep 'SWAP' | awk '{print $1}')
ROOT_NUM=$(parted -s $selected_partition print | grep 'ROOT' | awk '{print $1}')
if [[ $selected_partition == *"nvme"* ]] || [[ $selected_partition == *"mmcblk"* ]]; then
    SEP="p"
else
    SEP=""
fi
EFI_PART="${selected_partition}${SEP}${EFI_NUM}"
SWAP_PART="${selected_partition}${SEP}${SWAP_NUM}"
ROOT_PART="${selected_partition}${SEP}${ROOT_NUM}"

run_command "mkfs.fat -F32 -n EFI $EFI_PART"
run_command "mkswap -L SWAP $SWAP_PART"
run_command "mkfs.ext4 -F -L ROOT $ROOT_PART"

if [ "$install_mode" = "2" ]; then
    LOOT_NUM=$(parted -s $selected_partition print | grep 'LOOT' | awk '{print $1}')
    LOOT_PART="${selected_partition}${SEP}${LOOT_NUM}"
    run_command "mkfs.exfat -n LOOT $LOOT_PART"
fi

run_command "swapon $SWAP_PART"

run_command "mount $ROOT_PART /mnt"
run_command "mkdir -p /mnt/boot/efi"
run_command "mount $EFI_PART /mnt/boot/efi"

log_output "Started Rsync on: $selected_partition. Please wait it usually takes ~20min (~40min VM) -> \e[36m:)\e[0m"
if [ "$install_mode" = "2" ]; then
    clear
    rsync -aAX --info=progress2 \
        --exclude={'/dev/*','/proc/*','/sys/*','/tmp/*','/run/*','/mnt/*','/media/*','/lost+found','/boot/efi/*','/boot/grub/*','/home/*/loot/*'} \
        / /mnt/ 2>/dev/null
else
    clear
    rsync -aAX --info=progress2 \
        --exclude={'/dev/*','/proc/*','/sys/*','/tmp/*','/run/*','/mnt/*','/media/*','/lost+found','/boot/efi/*','/boot/grub/*','/home/*'} \
        / /mnt/ 2>/dev/null
fi
log_output "Rsync completed on: $selected_partition -> \e[36m:)\e[0m"
if [ "$install_mode" = "2" ]; then
    log_output "Copying the LOOT data to $LOOT_PART -> \e[36m:)\e[0m"
    # we assume that if on a VM it's a .iso so the LOOT is in /tmp/loot since its a network option
    run_command "mkdir -p /mnt/loot/"
    run_command "mount $LOOT_PART /mnt/loot"
    run_command "cp -r /tmp/loot/. /mnt/loot/"
    run_command "umount /mnt/loot"
    run_command "rmdir /mnt/loot/"
fi

run_command "cp /run/archiso/bootmnt/arch/boot/x86_64/vmlinuz-linux /mnt/boot/"
run_command "cp /run/archiso/bootmnt/arch/boot/x86_64/initramfs-linux.img /mnt/boot/"
#run_command "arch-chroot /mnt pacman -Sy --noconfirm linux"

run_command "genfstab -L /mnt >> /mnt/etc/fstab"

run_command "mount --bind /dev /mnt/dev"
run_command "mount --bind /proc /mnt/proc"
run_command "mount --bind /sys /mnt/sys"

log_output "Generating correct linux.preset for mkinitcpio.d in: /mnt/etc/mkinitcpio.d/linux.preset -> \e[36m:)\e[0m"
cat > /mnt/etc/mkinitcpio.d/linux.preset << 'EOF'
PRESETS=('default')
ALL_kver='/boot/vmlinuz-linux'
ALL_config='/etc/mkinitcpio.conf'
default_image="/boot/initramfs-linux.img"
EOF

run_command "arch-chroot /mnt mkinitcpio -P"

log_output "Installing grub -> \e[36m:)\e[0m"
cat > /mnt/etc/default/grub << 'EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="p3ng0s"
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
GRUB_CMDLINE_LINUX=""
GRUB_PRELOAD_MODULES="part_gpt part_msdos"
GRUB_TIMEOUT_STYLE=menu
EOF

run_command "arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=p3ng0s"
run_command "arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg"
run_command "mkdir -p /mnt/boot/efi/EFI/BOOT"
log_output "Creating backup in case EFI breaks -> \e[36m:)\e[0m"
run_command "cp /mnt/boot/efi/EFI/p3ng0s/grubx64.efi /mnt/boot/efi/EFI/BOOT/BOOTX64.EFI"

if [ "$install_mode" != "2" ]; then
    # Get username for bare metal
    BM_USER=$(dialog --title "Create User" --inputbox "Enter username:" 8 40 2>&1 >/dev/tty)
    BM_PASS=$(dialog --title "Create User" --passwordbox "Enter password:" 8 40 2>&1 >/dev/tty)

    # Set hostname
    BM_HOSTNAME=$(dialog --title "Hostname" --inputbox "Enter hostname:" 8 40 "p3ng0s" 2>&1 >/dev/tty)

    run_command "echo '$BM_HOSTNAME' > /mnt/etc/hostname"

    # Create user
    run_command "arch-chroot /mnt useradd -m -G wheel,lp,uucp,kvm,wireshark -s /bin/bash $BM_USER"
    log_output "Creating account -> \e[36m:)\e[0m"
    echo "$BM_USER:$BM_PASS" | arch-chroot /mnt chpasswd
    echo "root:$BM_PASS" | arch-chroot /mnt chpasswd

    log_output "Remove live user -> \e[36m:)\e[0m"
    run_command "arch-chroot /mnt userdel -r p4p1-live"

    log_output "Disabling p3ng0s-live triggers -> \e[36m:)\e[0m"
    run_command "arch-chroot /mnt systemctl disable p3ng0s-cracker-watcher.path"
    run_command "arch-chroot /mnt systemctl disable p3ng0s-certs-watcher.path"
    run_command "arch-chroot /mnt systemctl disable p3ng0s-dropbox-isolate-trigger.service"
fi

log_output "Removing autologon -> \e[36m:)\e[0m"
run_command "arch-chroot /mnt pacman -Rns --noconfirm autologon-p3ng0s"

run_command "umount /mnt/dev"
run_command "umount /mnt/proc"
run_command "umount /mnt/sys"
run_command "umount /mnt/boot/efi"
run_command "umount /mnt/"
run_command "swapoff $SWAP_PART"

log_output "Install Completed please reboot! -> \e[36m:)\e[0m"
dialog --title "Installation Complete!" \
    --yesno "\np3ng0s has been successfully installed to $selected_partition\n\nWould you like to reboot now?" 10 50
[ $? -eq 0 ] && reboot
