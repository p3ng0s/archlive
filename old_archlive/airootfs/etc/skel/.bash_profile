export DIALOGRC="/etc/p3ng0s/dialogrc"
export GTK_THEME=Dracula
unset SKIP

function first_install() {
	[[ "$(cat /etc/hostname)" = "p3ng0s-live" ]] && return
	[ -f ~/.p3ng0s.json ] && return
	dialog --title "Welcome to p3ng0s!" --yes-label "Proceed" --no-label "Skip" --yesno "Hello! Welcome to p3ng0s. This message is shown because this is the first time you boot into the OS, this OS has a few features that require a server or VPS to manage them this is optional but know that you will be missing these features with the default install if it is not configure:
- BloodHound Community Edition
- Havoc C2 server
- KeePass Database sync
- On desktop status check

These features are 100% optional and can just be skipped. If you do want to proceed know that during the install we will generate ssh keys and host the private file on a server make sure you are on a secure network to copy that file somewhere safe and add it inside of a safe environment." 25 90
	if [ $? -eq 0 ]; then
		IP=$(ifconfig| grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | tr -d "\n")
		dialog --title "Welcome to p3ng0s!" --msgbox "Brilliant! We will first start by generating the sshkeys for your machine and we will then host the .ssh folder on the following url:
http://$IP:8000/

You will be able to connect using your phone or an other laptop save the id_rsa.pub file and copy it's content inside of the .ssh/authorized_keys file inside of your server!" 25 90
		while [ ! -f ~/.ssh/id_rsa.pub ]; do
			echo -e "\e[1;31m[!]\e[m Make sure you save the files in ~/.ssh as id_rsa and id_rsa.pub"
			echo -e "\e[1;31m[!]\e[m for this to be configured properly!"
			ssh-keygen
		done
		echo -e "\e[1;31m[!]\e[m You will now need to retrieve the content of the id_rsa.pub file."
		echo -e "\e[1;31m[!]\e[m Provided is a ifconfig to know which IP address to connect to,"
		echo -e "\e[1;31m[!]\e[m and the content of the id_rsa.pub file:"
		echo -e "\e[1;36m[*]\e[m IFCONFIG:"
		ifconfig
		echo -e "\e[1;36m[*]\e[m ID_RSA.PUB:"
		cat ~/.ssh/id_rsa.pub
		echo -e "\e[1;31m[!]\e[m Once completed do a CTRL-C to leave."
		python -m http.server -d ~/.ssh/
		dialog --title "Welcome to p3ng0s!" --msgbox "Amazing! We now need you to fill in a few things so make sure you are correct on these things!" 25 90
		domain_name=$(dialog --title "Welcome to p3ng0s!" --inputbox "Enter your server domain name:" 8 40 --stdout)
		user_name=$(dialog --title "Welcome to p3ng0s!" --inputbox "Enter your server user name:" 8 40 --stdout)

		blood_hound=$(dialog --title "Welcome to p3ng0s!" --inputbox "Enter your bloodhound server instance (if same as before just reenter it):" 8 50 --stdout)
		blood_hound_username=$(dialog --title "Welcome to p3ng0s!" --inputbox "Enter your bloodhound server instance username (if same as before just reenter it):" 8 50 --stdout)
		blood_hound_lport=$(dialog --title "Welcome to p3ng0s!" --inputbox "Enter your bloodhound local web ui port (default: 8080)" 8 50 --stdout)
		blood_hound_rport=$(dialog --title "Welcome to p3ng0s!" --inputbox "Enter your bloodhound remote web ui port (default: 8080)" 8 50 --stdout)

		soc=$(dialog --title "Welcome to p3ng0s!" --inputbox "Enter your SOC server instance (if same as before just reenter it):" 8 50 --stdout)
		soc_username=$(dialog --title "Welcome to p3ng0s!" --inputbox "Enter your SOC server instance username (if same as before just reenter it):" 8 50 --stdout)
		soc_lport=$(dialog --title "Welcome to p3ng0s!" --inputbox "Enter your SOC local web ui port (default: 8081)" 8 50 --stdout)
		soc_rport=$(dialog --title "Welcome to p3ng0s!" --inputbox "Enter your SOC remote web ui port (default: 443)" 8 50 --stdout)

		echo "{\"host\":\"$domain_name\",\"user\":\"$user_name\",\"soc\":{\"server\":\"$soc\",\"user\":\"$soc_username\",\"lport\":\"$soc_lport\",\"rport\":\"$soc_rport\"},\"bloodhound\":{\"server\":\"$blood_hound\",\"user\":\"$blood_hound_username\",\"lport\":\"$blood_hound_lport\",\"rport\":\"$blood_hound_rport\"}}" > ~/.p3ng0s.json
		dialog --title "Welcome to p3ng0s!" --ok-label "Exit" --msgbox "Congratulations! You now have completed the setup for p3ng0s below is the json config that you can find in ~/.p3ng0s.json feel free to edit in the future with what you would need!

$(cat ~/.p3ng0s.json | jq .)
" 25 90

	else
		echo '{"host":"leosmith.wtf","user":"p4p1","bloodhound":"localhost","bloodhound_port":8080}' > ~/.p3ng0s.json
	fi
}

MAIN_WM=dwm
[[ "$(cat /etc/hostname)" = "p3ng0s-live" ]] && MAIN_WM=dwm-live

[ ! -f ~/.p3ng0s.json ] && first_install
if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
	exec 3>&1
	WM=$(dialog --title "Welcome to p3ng0s!" --menu "Select:" 25 90 5 \
		1 "dwm (Dynamic Window Manager)" \
		2 "dwm-light(A lightweight WM for shitty laptops)" \
		3 "kodi (Media player)" \
		4 "tty only like a G" \
		5 "cmatrix" \
		6 "nuke installed OS" \
		7 "shutdown now :/" \
		2>&1 1>&3)
	exit_state=$?
	exec 3>&-
	[ $WM = 1 ] && echo -e "xrdb -merge ~/.Xresources\nexec $MAIN_WM" > $HOME/.xinitrc
	[ $WM = 2 ] && echo -e "xrdb -merge ~/.Xresources\nexec dwm-light" > $HOME/.xinitrc
	[ $WM = 3 ] && echo "exec kodi" > $HOME/.xinitrc
	[ $WM = 4 ] && SKIP=1
	[ $WM = 5 ] && cmatrix
	[ $WM = 6 ] && bash /etc/p3ng0s/os_killer.sh
	[ $WM = 7 ] && shutdown now

	[ -z "$SKIP" ] && exec startx
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
