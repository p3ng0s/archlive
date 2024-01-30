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
RELAX_OPT=/opt/relax
WINDOWS_OPT=/opt/windows/

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

[ ! -d "$PENTEST_OPT" ] && mkdir -p $PENTEST_OPT
[ ! -d "$DEV_OPT" ] && mkdir -p $DEV_OPT
[ ! -d "$RELAX_OPT" ] && mkdir -p $RELAX_OPT
[ ! -d "$WINDOWS_OPT" ] && mkdir -p $WINDOWS_OPT

echo -e "\e[94m[*]\e[0m Installing Pentesting Things..."

git clone "https://github.com/danielmiessler/SecLists" $PENTEST_OPT/SecLists
git clone "https://github.com/jakobfriedl/precompiled-binaries" $PENTEST_OPT/precompiled-binaries
git clone "https://github.com/Nicocha30/ligolo-ng" $PENTEST_OPT/ligolo-ng
git clone "https://github.com/Hackplayers/evil-winrm" $PENTEST_OPT/evil-winrm
git clone "https://github.com/topotam/PetitPotam" $PENTEST_OPT/PetitPotam
git clone "https://github.com/carlospolop/PEASS-ng" $PENTEST_OPT/PEASS-ng
git clone "https://github.com/blacklanternsecurity/TREVORspray" $PENTEST_OPT/TREVORspray
git clone "https://github.com/PowerShellMafia/PowerSploit" $PENTEST_OPT/PowerSploit
git clone "https://github.com/beefproject/beef" $PENTEST_OPT/beef
git clone "https://github.com/projectdiscovery/nuclei" $PENTEST_OPT/nuclei
git clone "https://github.com/projectdiscovery/nuclei-templates" $PENTEST_OPT/nuclei-templates
git clone "https://github.com/NationalSecurityAgency/ghidra" $PENTEST_OPT/ghidra
git clone "https://github.com/dafthack/MFASweep" $PENTEST_OPT/MFASweep
git clone "https://github.com/sensepost/ruler" $PENTEST_OPT/ruler
git clone "https://github.com/DominicBreuker/pspy" $PENTEST_OPT/pspy
#git clone "https://github.com/BloodHoundAD/SharpHound" $PENTEST_OPT/SharpHound # removed since bloodhound community edition
git clone "https://github.com/icyguider/Shhhloader" $PENTEST_OPT/Shhhloader
git clone "https://github.com/hashcat/kwprocessor" $PENTEST_OPT/kwprocessor
git clone "https://github.com/tokyoneon/Chimera" $PENTEST_OPT/Chimera
git clone "https://github.com/mertdas/PrivKit/" $PENTEST_OPT/PrivKit
git clone "https://github.com/Kevin-Robertson/Inveigh" $PENTEST_OPT/Inveigh
git clone "https://github.com/fortra/impacket" $PENTEST_OPT/impacket
git clone "https://github.com/lgandx/Responder" $PENTEST_OPT/Responder
git clone "https://github.com/dirkjanm/krbrelayx" $PENTEST_OPT/krbrelayx
git clone "https://github.com/Kevin-Robertson/Sharpmad" $PENTEST_OPT/Sharpmad

echo -e "\e[94m[*]\e[0m Installing Development Things..."

git clone "https://github.com/neurobin/shc" $DEV_OPT/shc
git clone "https://github.com/p3ng0s/xmenu" $DEV_OPT/xmenu
git clone "https://github.com/p3ng0s/dwm-6.2" $DEV_OPT/dwm-6.2
git clone "https://github.com/p3ng0s/st-0.8.2" $DEV_OPT/st-0.8.2
git clone "https://github.com/p3ng0s/scripts" $DEV_OPT/script
git clone "https://github.com/p4p1/xss_bomb" $DEV_OPT/xss_bomb
git clone "https://github.com/p4p1/dwmstat" $DEV_OPT/dwmstat
curl "https://gist.githubusercontent.com/p4p1/1ab9b63925cfe860e8634f75243d32ef/raw/1da6e96aaf99f65516db567c80b28e87bcb8e918/bof_template.py" --output $DEV_OPT/bof_template.py
curl "https://gist.githubusercontent.com/p4p1/5020987a78c227de512bf32e938e0c61/raw/9e5a4098946d6d4dd94f4e3bb204ca8aa5c19d1b/blind_sql.sh" --output $DEV_OPT/blind_sql.sh
curl "https://gist.githubusercontent.com/p4p1/b2e829a9e75c344e055584ae8ffc29bd/raw/09387f0fe12392a360b7f9aa419a04c39167afeb/stager.c" --output $DEV_OPT/stager.c

echo -e "\e[94m[*]\e[0m Installing Windows Things..."

git clone "https://github.com/GhostPack/Rubeus" $WINDOWS_OPT/Rubeus
git clone "https://github.com/itm4n/PrintSpoofer" $WINDOWS_OPT/PrintSpoofer
git clone "https://github.com/sevagas/macro_pack" $WINDOWS_OPT/macro_pack
git clone "https://github.com/bugch3ck/SharpEfsPotato" $WINDOWS_OPT/SharpEfsPotato
git clone "https://github.com/gentilkiwi/mimikatz/" $WINDOWS_OPT/mimikatz
git clone "https://github.com/gentilkiwi/kekeo" $WINDOWS_OPT/kekeo
git clone "https://github.com/rvazarkar/GMSAPasswordReader" $WINDOWS_OPT/GMSAPasswordReader
git clone "https://github.com/GhostPack/KeeThief" $WINDOWS_OPT/KeeThief
git clone "https://github.com/GhostPack/SharpDPAPI" $WINDOWS_OPT/SharpDPAPI

echo -e "\e[94m[*]\e[0m Installing Entertainement Things..."

curl "https://github.com/assaultcube/AC/releases/download/v1.3.0.2/AssaultCube_v1.3.0.2_LockdownEdition_RC1.tar.bz2" --output $RELAX_OPT/AssaultCute.tar.bz2
curl -Ls "https://api.github.com/repos/Anuken/Mindustry/releases/latest" | jq -r '.assets[0].browser_download_url' | xargs -I {} curl '{}' --output $RELAX_OPT/mindustry.jar
