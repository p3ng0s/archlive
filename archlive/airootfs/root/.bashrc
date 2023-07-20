#.bashrc
# Created on: Wed, 21 Jun 2017
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  My bash configuration file made to work more efficiently
#
# Important bindings:
#  CRTL-T -> fzf completion
#  ALT-C -> fzf cd
#  CTRL-R -> fzf history
#  [Esc] || [Caps-lock] -> Normal mode
#  i -> Insert mode
#  v -> Visual mode

# If not running interactively, don't do anything
[ -z "$PS1" ] && return
# set fzf config if exists
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
# if on display :1 set the screen size, (for Xephyr)
[ ! -z "$XVWM" ] && source ~/.xvwm/xvwm.bash
# set stty to raw when tmux is not enabled
#[ -z "$TMUX" ] && stty raw -echo
# set the window manager name for java apps
[ -z "$(wmname 2> /dev/null)" ] && wmname LG3D &> /dev/null
# Change to this name if java apps still dont work
# wmname compiz

#xhost si:localuser:root &> /dev/null

# set the transset, uncomment if needed
#if hash transset &> /dev/null; then
#	transset -a --min 0.91 --max 0.92 --dec 0 &> /dev/null
#fi

# options:

HISTCONTROL=ignoredups:ignorespace
HISTSIZE=1000
HISTFILESIZE=2000

set -o vi
shopt -s histappend
shopt -s autocd

# Releod last dir on purpose:
#if [ -f ~/.last_dir ]; then
#	cd `cat ~/.last_dir`
#fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	if hash exa; then
		alias ls='exa --long --git'
	else
		alias ls='ls --color=auto -hGF'
	fi
	alias l='ls'
	alias la='ls -a'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
else
	alias ls='ls -hGF'
	alias l='ls'
	alias la='ls -ha'
	alias ll='ls -hl'
fi

# human readable
alias du='du -h'
alias df='df -h'

# All of the aliases:
alias vi='/usr/bin/vim'
alias emacs='/usr/bin/emacs -nw'
alias mocp='mocp -T /usr/share/moc/themes/transparent-background'

# Interpreters
alias powershell="pwsh"

# shortcuts
alias c='clear'
alias r='cd $(cat ~/.last_dir)'
alias less='bat'
alias tojwt="base64 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//"
alias j="journalctl -xe"
alias yay="paru"
alias nightime="redshift -l48.856613:2.352222 -b 1.0:0.2 &"

# fun commands
alias fuck='eval $(thefuck $( fc -ln -1 )); history -r'
alias cls='clear && pwd && ls -h'
alias tb='nc termbin.com 9999'
alias caps='setxkbmap -option caps:escape'
alias keys='screenkey --scr 1 --opacity 0.2 -f "Hack Nerd Font:size=13"'

# network information
alias wifi-scan="nmcli dev wifi"
alias wifi-check="ping -c 3 8.8.8.8"

# bluetooth
alias headphones-connect="echo 'connect B8:F6:53:69:B1:BC' | bluetoothctl"

# pacman
alias pacstore="pacman -Slq | fzf -m --preview 'cat <(pacman -Si {1}) <(pacman -Fl {1} | awk \"{print \$2}\")' | xargs -ro sudo pacman -S"
alias yaystore="paru -Slq | fzf -m --preview 'cat <(paru -Si {1}) <(paru -Fl {1} | awk \"{print \$2}\")' | xargs -ro  paru -S"
alias yayskip='paru -S --mflags --skipinteg'

alias androidemu="$HOME/Android/Sdk/emulator/emulator @Pixel_4_API_S"

# Directories and movement
alias ...="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../../.."
alias .5="cd ../../../../.."

# Compilation
alias gcc='gcc -std=gnu11 -Wall -Wextra -Werror'
alias g++='g++ -Wall -Wextra -Werror'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# All of the Functions:

# Python in interpreter use ptpython
function python() {
	[ -z $@ ] && ptpython || python3 $@
}
# check if you are connected to tor
function tor-check()
{
	SITE_SRC=$(proxychains -q curl -s 'https://check.torproject.org/')
	CONGRATS=$(echo $SITE_SRC | grep 'Congratulations')
	LOCATION=$(geoiplookup $(echo $SITE_SRC | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | tail -n 1))

	[ -z "${CONGRATS}" ] && echo -e "Tor check:[\e[91mKO\e[0m]" || echo -e "Tor check: [\e[92mOK\e[0m], ${LOCATION}"
}
function cd()
{
	builtin cd "$@";
	pwd > ~/.last_dir
}
function md()
{
	/bin/mkdir $@
	cd $@
}
ex ()
{
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2)   tar xjf $1   ;;
			*.tar.gz)    tar xzf $1   ;;
			*.bz2)       bunzip2 $1   ;;
			*.rar)       unrar x $1   ;;
			*.gz)        gunzip $1    ;;
			*.tar)       tar xf $1    ;;
			*.tbz2)      tar xjf $1   ;;
			*.tgz)       tar xzf $1   ;;
			*.zip)       unzip $1     ;;
			*.Z)         uncompress $1;;
			*.7z)        7z x $1      ;;
			*.deb)       ar x $1      ;;
			*.tar.xz)    tar xf $1    ;;
			*.tar.zst)   unzstd $1    ;;
			*)           echo "'$1' cannot be extracted via ex()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

# Prompt with git configuration
function prompt()
{
	# Adding user name
	PROMPT="[\[\e[;31m\]$(whoami)\[\e[m\]"
	# Adding '@' sepparator
	PROMPT="$PROMPT\[\e[;32m\]@\[\e[m\]"
	# Adding hostname or git: branch
	POS=$(git branch 2>/dev/null | grep '^*' | colrm 1 2)
	ISOK=$(git status -s --ignore-submodules=dirty 2> /dev/null)
	if [[ $POS ]]; then
		PROMPT="$PROMPT\[\e[34m\]${PWD##*/}\[\e[m\]"
		if [[ $ISOK ]]; then
			PROMPT="$PROMPT \[\e[35m\]untracked/\[\e[m\]]"
		else
			PROMPT="$PROMPT \[\e[35m\]$POS/\[\e[m\]]"
		fi
	else
		PROMPT="$PROMPT\[\e[34m\]$(cat /etc/hostname)\[\e[m\]"
		PROMPT="$PROMPT \[\e[35m\]${PWD##*/}/\[\e[m\]]"
	fi
	export PS1="$PROMPT\$ "
}

#Seting up color prompt:
PROMPT_COMMAND="prompt"
PS2="[\[\e[;34m\]\W\[\e[m\]] \[\e[;31m\]->\[\e[m\] "
PS3="[\w] -> "
PS4=" \$ "

# All of the exports:
export PROMPT_COMMAND=$PROMPT_COMMAND
export PS2=$PS2
export PS3=$PS3
export PS4=$PS4

export TERM="st-256color"
export SHELL=/bin/bash
export EDITOR=/usr/bin/vim
export BROWSER=/usr/bin/vivaldi-stable
export TERMINAL=/usr/local/bin/st
export LANG=en_US.UTF-8
export SSLKEYLOGFILE=~/.ssl-key.log
export TSHARK_FILTER="(not udp and not tls and not dns) and not (tcp.srcport eq 443 or tcp.dstport eq 443) and not (ip.src eq 95.179.212.68 or ip.dst eq 95.179.212.68) and not (tcp.srcport eq 80 or tcp.dstport eq 80)"

# SDK and bin packages
export PATH=$PATH:$HOME/go/bin/
export ANDROID_SDK_ROOT=$HOME/Android/Sdk/
export CHROME_EXECUTABLE=/usr/bin/chromium

# For Xephyr need to change to :num instead of 0
# export DISPLAY=:0
# generate wallpaper pacwall -X -s "#7f7f7f00" -y "#ff9d14"


# Banner script
sh banner.sh

PATH="$HOME/perl5/bin${PATH:+:${PATH}}"; export PATH;
PATH="$PATH:$HOME/Documents/TECH/flutter/flutter/bin"; export PATH;
PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;
