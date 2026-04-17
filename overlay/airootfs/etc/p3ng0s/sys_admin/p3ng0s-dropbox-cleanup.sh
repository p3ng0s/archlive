#!/bin/bash
# p3ng0s-dropbox-cleanup.sh
# Created on: Thu 16 Apr 2026 10:55:46 AM CEST
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#
[ ! -d /home/p4p1-live ] && exit

THRESHOLD="+1G"

# paths to exclude from cleanup check
EXCLUDE_PATHS=(
    "/home/*/loot"
    "/opt"
    "/usr"
    "/lib"
    "/lib64"
    "/boot"
    "/proc"
    "/sys"
    "/run"
)

# build find exclude arguments
EXCLUDE_ARGS=""
for path in "${EXCLUDE_PATHS[@]}"; do
    EXCLUDE_ARGS="$EXCLUDE_ARGS -not -path \"$path/*\""
done

# find big files
BIG_FILES=$(eval find /var /home /tmp $EXCLUDE_ARGS -type f -size $THRESHOLD 2>/dev/null)

if [ -z "$BIG_FILES" ]; then
    exit 0
fi

# wait for SSH connection
while true; do
    SSH_USERS=$(who | grep "pts")
    if [ -n "$SSH_USERS" ]; then
        wall "=== P3NG0S CLEANUP ALERT ===
The following files are over 1GB and should be reviewed:

$BIG_FILES

Please clean up manually.
==========================="
        break
    fi
    sleep 60
done

