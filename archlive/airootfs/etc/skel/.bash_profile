export DIALOGRC="/etc/p3ng0s/dialogrc"
unset SKIP
MAIN_WM=dwm
[[ "$(cat /etc/hostname)" = "p3ng0s-live" ]] && MAIN_WM=dwm-live
if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
	exec 3>&1
	WM=$(dialog --title "Welcome to p3ng0s!" --menu "Select:" 25 90 5 \
		1 "dwm (Dynamic Window Manager)" \
		2 "dwm-light(A lightweight WM for shitty laptops)" \
		3 "tty only like a G" \
		4 "nuke installed OS" \
		2>&1 1>&3)
	exit_state=$?
	exec 3>&-
	[ $WM = 1 ] && echo "exec $MAIN_WM" > $HOME/.xinitrc
	[ $WM = 2 ] && echo "exec dwm-light" > $HOME/.xinitrc
	[ $WM = 3 ] && SKIP=1
	[ $WM = 4 ] && bash /etc/p3ng0s/os_killer.sh

	[ -z "$SKIP" ] && exec startx
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
