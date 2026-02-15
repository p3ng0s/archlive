#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="p3ng0s"
iso_label="PINGU_$(date +%Y%m)"
iso_publisher="p4p1 <https://leosmith.wtf>"
iso_application="p3ng0s USB / CD"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:0400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/etc/skel/git_apocalypse.sh"]="0:0:755"
  ["/etc/p3ng0s/bar.sh"]="0:0:755"
  ["/etc/p3ng0s/display.sh"]="0:0:755"
  ["/etc/p3ng0s/ripdrag"]="0:0:755"
  ["/etc/p3ng0s/tmuxer.sh"]="0:0:755"
  ["/etc/p3ng0s/looter.sh"]="0:0:755"
  ["/etc/p3ng0s/autowifimon.sh"]="0:0:755"
  ["/etc/openvpn/routing.sh"]="0:0:755"
  ["/etc/skel/.fzf/bin/fzf-tmux"]="0:0:755"
  ["/etc/skel/.fzf/bin/fzf"]="0:0:755"
)
