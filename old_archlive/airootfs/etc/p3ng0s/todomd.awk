{
if ($1 == "[x]") print " ${color orange}" substr($0, index($0, " ")+1)
else print " ${color}" substr($0, index($0, " ")+1)
}
