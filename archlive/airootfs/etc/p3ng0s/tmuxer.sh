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
#  A quick script for tmux setup

if [ -z "$(tmux ls | grep desktop)" ]; then
	tmux new-session -d -s desktop
	tmux rename-window -t desktop:0 'main'
	tmux splitw -h -p 30 -t desktop:0.0
	tmux splitw -v -p 30 -t desktop:0.0
	tmux splitw -v -p 70 -t desktop:0.2
	tmux send-keys -t desktop:0.2 'tmux clock -t desktop:0.2' Enter
	tmux send-keys -t desktop:0.1 'newsboat' Enter
	tmux send-keys -t desktop:0.0 'ranger' Enter
	tmux new-window -t desktop
	tmux rename-window -t desktop:1 'dev'
	tmux send-keys -t desktop:1 'vim' Enter
	tmux select-window -t desktop:0.0
	tmux a -t desktop
else
	tmux
fi
