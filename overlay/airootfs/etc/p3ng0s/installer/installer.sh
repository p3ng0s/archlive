#!/bin/bash
# installer.sh
# Created on: Fri 27 Feb 2026 08:28:57 PM CET
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#

SESSION="arch_install"
PIPE="/tmp/install_log.pipe"

# Create the pipe if it doesn't exist
[[ -p $PIPE ]] || mkfifo $PIPE

# Start tmux, hide the status bar for that "Bashtop" fullscreen look
tmux new-session -d -s $SESSION -n 'Installer'
tmux set-option -t $SESSION status off

# Split: Left (80%) for UI, Right (20%) for Logs
tmux split-window -h -p 25

# Right Pane (Pane 1): Just read the pipe forever
tmux send-keys -t $SESSION:0.1 "clear && cat $PIPE" C-m

# Left Pane (Pane 0): Run the actual installer logic
tmux send-keys -t $SESSION:0.0 "bash logic.sh" C-m

tmux select-pane -t $SESSION:0.0

# Attach to the session
tmux attach-session -t $SESSION
