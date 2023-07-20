# tshark.awk
# Created on: Fri, 08 Oct 2021
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description
#  Color config for todo output on conky


{
if ($1 == "[x]") print " ${color orange}" substr($0, index($0, " ")+1)
else print " ${color}" substr($0, index($0, " ")+1)
}
