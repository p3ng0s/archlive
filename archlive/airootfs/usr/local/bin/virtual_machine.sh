#!/bin/bash
# virtual_machine.sh
# Created on: Tue 11 Aug 2020 10:28:44 AM CEST
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  installation script for Ubuntu virtual machine testing environment

packages=(build-essential vim exa ranger git tor ssh gdb radare2 wireshark proxychains clang bless valgrind hashcat curl virtualbox-guest-utils virtualbox-guest-dkms cargo)

function package_install() {
	for item in $@; do
		echo -n "Checking $item -> "
		if hash $item &> /dev/null; then
			echo -e "\e[1;34m:)\e[m"
		else
			apt install -y $item
			echo -e "\e[1;31m:(\e[m"
		fi
	done
}

if [ "$EUID" -ne 0 ]; then
	echo -e "\e[1;31mPlease run as root\e[m"
	exit -1
fi

echo -e "\e[96m  ___________________________________________\e[m"
echo -e "\e[96m |  _______________________________________  |\e[m"
echo -e "\e[96m | / .-----------------------------------. \\ |\e[m"
echo -e "\e[96m | | | /\\ :                        90 min| | |\e[m"
echo -e "\e[96m | | |/--\\:....................... NR [ ]| | |\e[m"
echo -e "\e[96m | | '-----------------------------------' | |\e[m"
echo -e "\e[96m | |      //-\\   |         |   //-\\      | |\e[m"
echo -e "\e[96m | |     ||( )||  |_________|  ||( )||     | |\e[m"
echo -e "\e[96m | |      \\\\-//   :....:....:   \\\\-//      | |\e[m"
echo -e "\e[96m | |       _ _ ._  _ _ .__|_ _.._  _       | |\e[m"
echo -e "\e[96m | |      (_(_)| |(_(/_|  |_(_||_)(/_      | |\e[m"
echo -e "\e[96m | |               \e[101;39mlow noise\e[49;96m   |           | |\e[m"
echo -e "\e[96m | '______ ____________________ ____ ______' |\e[m"
echo -e "\e[96m |        /    []             []    \\        |\e[m"
echo -e "\e[96m |       /  ()                   ()  \\       |\e[m"
echo -e "\e[96m !______/_____________________________\\______!\e[m"

echo "Setting up virtual machine :)"

apt update
apt -y upgrade

echo -e "\e[96;5;4mInstalling Packages...\e[m"
package_install ${packages[*]}


echo -e "\e[96;5;4mInstalling GDB Peda...\e[m"
git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >> ~/.gdbinit
echo "DONE! debug your program with gdb and enjoy"

usermod -a -G vboxsf `whoami`
for USERH in $(ls /home/); do
	echo "alias ls='exa -la'" >> /home/$USERH/.bashrc
	echo "alias vi='vim'" >> /home/$USERH/.bashrc
	echo "export PATH=\$PATH:/home/$USERH/.cargo/bin" >> /home/$USERH/.bashrc
	su $USERH -c "cargo install exa"
done

exit 0
