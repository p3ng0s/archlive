#!/bin/bash
# tmuxer.sh
# Created on: Fri 02 Feb 2024 12:27:27 PM CET
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  A script to connect to broken tmux sessions

#mapfile -t SESSIONS < <(tmux ls -F '#{session_name} #{session_attached}' 2>/dev/null | awk '$2 == 0 {print $1}')
SESSION_NAME=$(tmux ls -F '#{session_name} #{session_attached}' 2>/dev/null | awk '$2 == 0 {print $1; exit}')



if [ ! -z "$SESSION_NAME" ]; then
	tmux a -t "$SESSION_NAME"
else
	tmux
fi
