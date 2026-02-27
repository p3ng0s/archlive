#!/bin/bash
# installer.sh
# Created on: Thu 26 Feb 2026 09:06:24 PM CET
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  A bash script to install the OS from. Do not use this scripts!

# 1. Select Disk (Simple TUI)
#
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
    exit 0
fi

echo -e "Got drive $selected_partition -> \e[36m:)\e[0m"
echo -e "\e[1;31mYou are going to take serious actions against that drive is this okay?\e[m"
read -p "Continue? (y/n): " confirm
[[ $confirm != "y" ]] && exit 1

echo -e "\e[1;31mWiping drive!\e[m"
wipefs -a "$selected_partition"

# 2. Partitioning (EFI + Root)
echo "[+] Partitioning $TARGET..."
sgdisk -Z $TARGET
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI" $TARGET
sgdisk -n 2:0:0 -t 2:8300 -c 2:"p3ng0s" $TARGET

# 3. Formatting
echo "[+] Formatting..."
mkfs.fat -F32 "${TARGET}1"
mkfs.ext4 -F "${TARGET}2"

# 4. Mounting
echo "[+] Mounting..."
mount "${TARGET}2" /mnt
mkdir -p /mnt/boot/efi
mount "${TARGET}1" /mnt/boot/efi

# 5. The "Copy" (Replacing UnpackFS)
echo "[+] Copying system (this will take a while)..."
# We exclude the live-only parts
rsync -aAXv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found", "/boot/*"} / /mnt/

# 6. Fixing the System (Chroot)
echo "[+] Finalizing configuration..."
# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Remove the autologon package in the new system
arch-chroot /mnt pacman -Rns --noconfirm autologon-p3ng0s

# Install GRUB
echo "[+] Installing Bootloader..."
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=p3ng0s
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo "[!] DONE! Reboot and unplug the USB."
