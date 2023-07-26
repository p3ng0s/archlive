#/bin/bash
# arch_install.sh
# Created on: Tue, 16 Jun 2020
# https://p4p1.github.io/#config
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  Installation script to install and configure the softwares I used the
#  most. I also propose a list of packages for different working environements.
#
# Dependencies:
#  This script will only work on archlinux
#
# Usage:
#  ./install.sh -u $(whoami) -s # basic installation w/ pentesting tools

# list of packages
base=(base linux linux-firmware grub networkmanager xorg xorg-xinit unzip)
packages=(firefox kdenlive audacity calibre linux-headers exa vim git emacs pkg-config tmux openssh xorg zathura zathura-ps zathura-pdf-poppler aircrack-ng apache2 bluez blueman clang gcc make dfu-util dfu-programmer docker feh gdb radare2 gimp gparted nautilus i3lock hashcat irssi newsboat libx11 compton neofetch networkmanager nmap nikto nodejs npm openvpn perl php pulseaudio python python-pip ranger ruby scrot smbclient sudo tar thefuck tig tmux tor tree valgrind vlc w3m whois xclip netcat redshift nvidia virtualbox virtualbox-host-modules-arch xautolock go discord pavucontrol)
aur_packager=(vivaldi binwalk fritzing teams wireshark ghidra wfuzz amass xmind android-studio postman)


config="https://leosmith.xyz/rice/backup.tar.xz"

function usage () {
	echo -e "\e[1;31mUsage:\e[m" 1>&2
	echo "$0 -u \$(whoami) -> default install" 1>&2
	exit 84
}

# install the AUR helper
function install_AUR() {
	TMP_DIR=$(pwd)

	if ! hash yay &> /dev/null; then
		cd /tmp/
		git clone https://aur.archlinux.org/yay.git
		cd yay
		makepkg -si
		cd $TMP_DIR
	fi
}

# function to install aur packages
function aur_package_install() {
	for item in $@; do
		echo -n "Checking $item -> "
		if hash $item &> /dev/null; then
			echo -e "\e[1;34m:)\e[m"
		else
			echo -e "\e[1;31m:(\e[m"
			yay -S $item
		fi
	done
}

# function to install different packages
function package_install() {
	for item in $@; do
		echo -n "Checking $item -> "
		if hash $item &> /dev/null; then
			echo -e "\e[1;34m:)\e[m"
		else
			echo -e "\e[1;31m:(\e[m"
			pacman -S --noconfirm $item
		fi
	done
}

# function to install the configuration
function config_install() {
	curl $config --output ./backup.tar.xz
	tar xf ./backup.tar.xz

	for item in $(ls -a ./backup/ | sed 1,2d); do
		echo -e "\e[1;34mAdding\e[m $item in /home/$1/ directory"
		[ ! -f /home/$1/$item ] && cp -r ./backup/$item /home/$1/$item
		[ ! -d /home/$1/$item ] && cp -r ./backup/$item /home/$1/$item
		chown $1 -R /home/$1/$item
	done
	rm -rf ./backup.tar.xz
	rm -rf ./backup/
}


# function to install fonts
function font_install() {
	cp -r /home/$1/.dwm/font/* /usr/share/fonts/
	fc-cache -vf
}

# Command parser
while getopts "u:" o; do
	case "${o}" in
		u)
			u=${OPTARG}
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))
if [ -z "${u}" ]; then
	usage
fi

# Do the basic checks to see if root and on supported systems and if the user exitsts
if [ "$EUID" -ne 0 ]; then
	echo -e "\e[1;31mPlease run as root\e[m"
	exit 84
fi
if [ ! -d /home/$1 ]; then
	echo -e "\e[1;31mError: /home/$1. Folder not found!\e[m"
	exit 84
fi

# beginning of script
echo "Installing Leo's Stuff :)"

pacman -Syy
pacman -Syu

install_AUR

package_install ${packages[*]}
aur_package_install ${aur_packages[*]}

config_install $u
font_install $u

echo "Now run PlugInstall in vim"
echo "Press [Enter]"
read a
su $u -c "vim /home/$u/.vimrc"

echo -n "Checking for shh key -> "
if [ -f /home/$u/.ssh/id_rsa.pub -a -f /home/$u/.ssh/id_rsa ]; then
	echo -e "\e[1;34m:)\e[m"
else
	echo -e "\e[1;31m:(\e[m"
	su $u -c "ssh-keygen"
fi

[ ! -f /home/$u/.xinitrc ] && echo "exec dwm" > /home/$u/.xinitrc

echo "All done :)"

exit 0
