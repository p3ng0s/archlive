#!/bin/bash
# git_apocalypse.sh
# Created on: Tue 01 Aug 2023 07:53:45 PM CEST
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  A ridiculous script that will cause an apocalypse on the network because it will
#  just do a ton of git pulls nothing fancy just entertainement

PENTEST_OPT=/opt/pentest
DEV_OPT=/opt/dev

echo -e "\e[91m                       \e[37m                                  c=====e\e[0m"
echo -e "\e[91m                       \e[37m                                     H\e[0m"
echo -e "\e[91m   ____________   \e[0m\e[37m                                      _,,_H__\e[0m"
echo -e "\e[91m  (__((__((___()\e[0m \e[33m                                      //\e[37m|     |\e[0m"
echo -e "\e[91m (__((__((___()()\e[0m\e[33m_____________________________________// \e[37m|\e[31mPULL\e[37m |\e[0m"
echo -e "\e[91m(__((__((___()()()\e[0m\e[33m------------------------------------'  \e[37m|_____|\e[0m"
echo -e "\e[0m"
echo -e "\e[95m ██████╗ ██╗████████╗      █████╗ ██████╗  ██████╗  ██████╗ █████╗ ██╗  ██╗   ██╗██████╗ ███████╗███████╗   ███████╗██╗  ██╗\e[0m"
echo -e "\e[95m██╔════╝ ██║╚══██╔══╝     ██╔══██╗██╔══██╗██╔═══██╗██╔════╝██╔══██╗██║  ╚██╗ ██╔╝██╔══██╗██╔════╝██╔════╝   ██╔════╝██║  ██║\e[0m"
echo -e "\e[95m██║  ███╗██║   ██║        ███████║██████╔╝██║   ██║██║     ███████║██║   ╚████╔╝ ██████╔╝███████╗█████╗     ███████╗███████║\e[0m"
echo -e "\e[95m██║   ██║██║   ██║        ██╔══██║██╔═══╝ ██║   ██║██║     ██╔══██║██║    ╚██╔╝  ██╔═══╝ ╚════██║██╔══╝     ╚════██║██╔══██║\e[0m"
echo -e "\e[95m╚██████╔╝██║   ██║███████╗██║  ██║██║     ╚██████╔╝╚██████╗██║  ██║███████╗██║   ██║     ███████║███████╗██╗███████║██║  ██║\e[0m"
echo -e "\e[95m ╚═════╝ ╚═╝   ╚═╝╚══════╝╚═╝  ╚═╝╚═╝      ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝     ╚══════╝╚══════╝╚═╝╚══════╝╚═╝  ╚═╝\e[0m"


git clone "https://github.com/danielmiessler/SecLists" $PENTEST_OPT/SecLists
git clone "https://github.com/Nicocha30/ligolo-ng" $PENTEST_OPT/ligolo-ng
git clone "https://github.com/Hackplayers/evil-winrm" $PENTEST_OPT/evil-winrm
git clone "https://github.com/topotam/PetitPotam" $PENTEST_OPT/PetitPotam
git clone "https://github.com/carlospolop/PEASS-ng" $PENTEST_OPT/PEASS-ng
git clone "https://github.com/blacklanternsecurity/TREVORspray" $PENTEST_OPT/TREVORspray
git clone "https://github.com/PowerShellMafia/PowerSploit" $PENTEST_OPT/PowerSploit
git clone "https://github.com/beefproject/beef" $PENTEST_OPT/beef
git clone "https://github.com/projectdiscovery/nuclei-templates" $PENTEST_OPT/nuclei-templates
git clone "https://github.com/itm4n/PrintSpoofer" $PENTEST_OPT/PrintSpoofer
git clone "https://github.com/NationalSecurityAgency/ghidra" $PENTEST_OPT/ghidra
git clone "https://github.com/dafthack/MFASweep" $PENTEST_OPT/MFASweep
git clone "https://github.com/sensepost/ruler" $PENTEST_OPT/ruler
git clone "https://github.com/gentilkiwi/mimikatz/" $PENTEST_OPT/mimikatz
git clone "https://github.com/gentilkiwi/kekeo" $PENTEST_OPT/kekeo
git clone "https://github.com/DominicBreuker/pspy" $PENTEST_OPT/pspy
git clone "https://github.com/BloodHoundAD/SharpHound" $PENTEST_OPT/SharpHound

git clone "https://github.com/neurobin/shc" $DEV_OPT/shc
git clone "https://github.com/p3ng0s/xmenu" $DEV_OPT/xmenu
git clone "https://github.com/p3ng0s/dwm-6.2" $DEV_OPT/dwm-6.2
git clone "https://github.com/p3ng0s/st-0.8.2" $DEV_OPT/st-0.8.2
git clone "https://github.com/p3ng0s/scripts" $DEV_OPT/script
git clone "https://github.com/p4p1/xss_bomb" $DEV_OPT/xss_bomb