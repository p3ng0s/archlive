#!/bin/bash
# cracker.sh
# Created on: Mon 16 Feb 2026 08:55:24 AM CET
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  This is the cracking script used to do hashcat on the /home/p4p1-live/loot/hashcat
#  folder. Current supported hardware: SteamDeck, beelink ser5 pro

HASHCAT_FOLDER=/home/p4p1-live/loot/hashcat
#HASHCAT_FOLDER=/home/p4p1/loot/hashcat
SECLIST_FOLDER=/opt/pentest/SecLists/Passwords/

draw_status_bar() {
    while true; do
        # Get terminal dimensions
        cols=$(tput cols)
        rows=$(tput lines)
        bar_row=$((rows - 1))

        # Get Stats (AMD GPU specific)
        temp=$(sensors | grep -Ei 'edge|gpu|composite' | grep '°C' | awk '{print $2}' | tr -d '+°C' | head -n 1 | cut -d. -f1)
        clock=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs)
        cpu_load=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')

        # Format the string
        status_str=" [ GPU Temp: ${temp}°C | Clock: $clock | CPU: ${cpu_load}% ] "

        # Draw the bar (reverse video mode)
        tput cup $bar_row 0
        tput rev
        printf "%-${cols}s" "$status_str"
        tput sgr0

        sleep 1
    done
}

draw_status_bar &
BAR_PID=$!
if [[ -z "$TERM" || "$TERM" == "linux" ]]; then
    # Direct hijack of the console to ensure it BLOCKS
    exec < /dev/tty1 > /dev/tty1 2>&1
fi

echo "--- Cracker ---"

if [ ! -d $HASHCAT_FOLDER ]; then
    ls $HASHCAT_FOLDER
    ls /home/
    ls /home/p4p1-live
    echo $HASHCAT_FOLDER
    echo -e "\e[1;31m[!]\e[0m Cannot find the hashcat folder exiting"
    sleep 5
    exit -1
fi

if lspci | grep -qi "1507" || lspci | grep -qi "Vangogh"; then
    # Steam Deck / RDNA 2
    export HSA_OVERRIDE_GFX_VERSION=10.3.0
elif lspci | grep -qi "15bf" || lspci | grep -qi "Phoenix"; then
    # Legion Go / ROG Ally / RDNA 3
    export HSA_OVERRIDE_GFX_VERSION=11.0.0
fi

mapfile -d '\n' hash_files < <(find $HASHCAT_FOLDER -name hash.* -type f | grep -v 'completed')
[ ! -d $HASHCAT_FOLDER/completed ] && mkdir -p $HASHCAT_FOLDER/completed/

for file in ${hash_files[*]}; do
    HASHCAT_MODE=${file##*.}

    hashcat --status --status-timer=5 -o "$HASHCAT_FOLDER/completed/cracked.$HASHCAT_MODE" --outfile-format 2 -a 0 -m "$HASHCAT_MODE" "$file" $(find $HASHCAT_FOLDER/wordlist/ -name '*.txt' -type f -printf '%p ') #$(find $SECLIST_FOLDER -name '*.txt' -type f -printf '%p')
    mv $file $HASHCAT_FOLDER/completed/
    clear
done
kill $BAR_PID
shutdown now
exit
