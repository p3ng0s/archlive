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
HISTSIZE=10000
HISTFILESIZE=20000

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
alias mocp='mocp -T /usr/share/moc/themes/transparent-background'

# Interpreters
alias powershell="pwsh"

# shortcuts
alias c='clear'
alias r='cd $(cat ~/.last_dir)'
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

# pacman
alias pacstore="pacman -Slq | fzf -m --preview 'cat <(pacman -Si {1}) <(pacman -Fl {1} | awk \"{print \$2}\")' | xargs -ro sudo pacman -S"
alias yaystore="paru -Slq | fzf -m --preview 'cat <(paru -Si {1}) <(paru -Fl {1} | awk \"{print \$2}\")' | xargs -ro  paru -S"
alias yayskip='paru -S --mflags --skipinteg'

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
alias alert='notify-send -u critical "✓ Done" "$(history 1 | sed s/^[0-9]*\ //)"'

# All of the Functions:

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
function hashcatverify()
{
	HASHCAT_MODE=${1##*.}

	hashcat -m $HASHCAT_MODE -a 0 $1 /opt/pentest/SecLists/Passwords/Leaked-Databases/rockyou.txt
}
function pwshenc()
{
	python3 -c "import base64;print(base64.b64encode('${@}'.encode('utf16')[2:]).decode())"
}
function xfreerdp()
{
	xfreerdp /dynamic-resolution /drive:win,/opt/windows/ ${@}
}
function keesave()
{
	HOST=$(cat $HOME/.p3ng0s.json | jq -r .host)
	UNAME=$(cat $HOME/.p3ng0s.json | jq -r .user)
	DB=$HOME/Database.kdbx

	scp $DB $UNAME@$HOST:/home/$UNAME/Database.kdbx
}
function keedl()
{
	HOST=$(cat $HOME/.p3ng0s.json | jq -r .host)
	UNAME=$(cat $HOME/.p3ng0s.json | jq -r .user)
	DB=$HOME/Database.kdbx

	scp $UNAME@$HOST:/home/$UNAME/Database.kdbx $DB
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

# Merge Checklist data into .bash_history
function merge_checklist() {
	local md_result
	local checklist_path=$HOME/Documents/notes/Checklists/Tactic\ Techniques\ Procedures/

	[[ "$(cat /etc/hostname)" = "p3ng0s-live" || -d /home/p4p1-live/ ]] && checklist_path=$HOME/loot/notes/Checklists/Tactic\ Techniques\ Procedures/
	[[ -d "$checklist_path" ]] || { return 1; }
	md_result=$(find "$checklist_path" -name "*.md" \
	| xargs -I {} awk 'tolower($0) ~ /^```bash/{found=1; next} /^```/{found=0} found' '{}' \
	| sort -u)

	local tmp="$(mktemp)"
	grep -vxFf <(echo "$md_result") ~/.bash_history > "$tmp"
	{ echo "$md_result"; cat "$tmp"; } > ~/.bash_history
	rm "$tmp"
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
	history -a
	history -c
	history -r
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
export BROWSER=/usr/bin/qutebrowser
export TERMINAL=/usr/local/bin/st
export LANG=en_US.UTF-8
export SSLKEYLOGFILE=~/.ssl-key.log
export QT_QPA_PLATFORMTHEME=qt5ct

# checklist
{ sleep 1 && merge_checklist; } &
disown
# Banner script
sh banner.sh

# SDK and bin packages
export CHROME_EXECUTABLE=/usr/bin/chromium

