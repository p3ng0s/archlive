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
DEBUG_LOG=$HASHCAT_FOLDER/debug.log

WORDLISTS=()

if [[ -z "$TERM" || "$TERM" == "linux" ]]; then
    # Direct hijack of the console to ensure it BLOCKS
    #exec < /dev/tty1 > /dev/tty1 2>&1
    exec > >(tee -a "$DEBUG_LOG" > /dev/tty1) 2>&1
fi

echo "--- Cracker ---"

if [ ! -d $HASHCAT_FOLDER ]; then
    echo -e "\e[1;31m[!]\e[0m Cannot find the hashcat folder exiting"
    sleep 5
    exit -1
fi

if lspci | grep -qi "1507" || lspci | grep -qi "Vangogh"; then
    # Steam Deck / RDNA 2
    echo -e "\e[36m[*]\e[0m Runing of steam deck this hardware has RDNA2 activating OVERRIDE!"
    export HSA_OVERRIDE_GFX_VERSION=10.3.0
elif lspci | grep -qi "15bf" || lspci | grep -qi "Phoenix"; then
    # Legion Go / ROG Ally / RDNA 3
    export HSA_OVERRIDE_GFX_VERSION=11.0.0
fi

mapfile -d '\n' hash_files < <(find $HASHCAT_FOLDER -name hash.* -type f | grep -v 'completed')
[ ! -d $HASHCAT_FOLDER/completed ] && mkdir -p $HASHCAT_FOLDER/completed/

echo -e "\e[36m[*]\e[0m Creating wordlists."
shopt -s globstar
if [ -d "$HASHCAT_FOLDER/wordlist/" ]; then
    for f in "$HASHCAT_FOLDER"/wordlist/**/*.txt; do
        if [ -e "$f" ]; then
            echo "found: $f"
            WORDLISTS+=("$f")
        fi
    done
fi
if [ -d "$SECLIST_FOLDER/" ]; then
    for f in "$SECLIST_FOLDER"/**/*.txt; do
        if [ -e "$f" ]; then
            echo "found: $f"
            WORDLISTS+=("$f")
        fi
    done
fi

echo -e "\e[36m[*]\e[0m Setting the cpu to performance mode."
cpupower frequency-set -g performance

for file in ${hash_files[*]}; do
    HASHCAT_MODE=${file##*.}

    hashcat --status --status-timer=5 -o "$HASHCAT_FOLDER/completed/cracked.$HASHCAT_MODE" --outfile-format 2 -a 0 -m "$HASHCAT_MODE" "$file" "${WORDLISTS[@]}"
    /bin/bash
    echo -e "\e[36m[*]\e[0m moving $file to completed/"
    mv $file $HASHCAT_FOLDER/completed/
    sleep 5
done
echo -e "\e[36m[*]\e[0m Putting the cpu back to powersave mode"
cpupower frequency-set -g powersave
shutdown now
exit
