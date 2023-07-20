# tshark.awk
# Created on: Fri, 08 Oct 2021
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description
#  Color config for tshark output on conky


{
if ($6 == "ARP") print strftime(" [%H:%M]") " ${color red}" $6 "${color}: " $3 " " $4 " " $5;
else if ($6 == "ICMP") print strftime(" [%H:%M]") " ${color green}" $6 "${color}: " $3 " " $4 " " $5;
else if ($6 == "ICMPv6") print strftime(" [%H:%M]") " ${color green}" $6 "${color}: " $3 " " $4 " " $5;
else if ($6 == "EAPOL") print strftime(" [%H:%M]") " ${color}" $6 "${color}: " $3 " " $4 " " $5;
else print strftime(" [%H:%M]") " ${color cyan}" $6 "${color}: " $3 ":" $8 " " $4 " " $5 ":" $10;
}
