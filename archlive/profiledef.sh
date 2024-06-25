#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="p3ng0s"
iso_label="PINGU_$(date +%Y%m)"
iso_publisher="p4p1 <https://leosmith.wtf>"
iso_application="p3ng0s USB / CD"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-ia32.grub.esp' 'uefi-x64.grub.esp'
           'uefi-ia32.grub.eltorito' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:0400"
  ["/root"]="0:0:750"
  ["/etc/skel/git_apocalypse.sh"]="0:0:755"
  ["/usr/bin/qFlipper"]="0:0:755"
  ["/usr/bin/backup.sh"]="0:0:755"
  ["/etc/p3ng0s/bar.sh"]="0:0:755"
  ["/etc/p3ng0s/ripdrag"]="0:0:755"
  ["/etc/p3ng0s/tmuxer.sh"]="0:0:755"
  ["/etc/skel/.fzf/bin/fzf-tmux"]="0:0:755"
  ["/etc/skel/.fzf/bin/fzf"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
)
