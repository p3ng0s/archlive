#!/bin/bash
# get-tech.sh
# Created on: Sat 01 Mar 2025 10:40:34 AM GMT
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  a qutebrowser script to scan a url using nuclei

results=$(mktemp)
nuclei_cmd=$HOME/go/bin/nuclei
if [[ -z "$nuclei_cmd" ]]; then
	echo "message-error 'nuclei command not found edit this script with the nuclei path!'" >> $QUTE_FIFO
fi
echo "message-info 'scanning: $QUTE_URL'" >> "$QUTE_FIFO"
$nuclei_cmd -u $QUTE_URL -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:123.0) Gecko/20100101 Firefox/123.0' -t http/technologies/ -o $results &>/tmp/ret
if [[ $? -eq 0 ]]; then
	if [[ -z "$(cat $results)" ]]; then
		echo "message-warning 'Nothing was found by nuclei'" >> "$QUTE_FIFO"
	else
		while IFS= read -r line; do
			echo "message-info '$line'" >> $QUTE_FIFO
		done < $results
		echo "tab-clone" >> "$QUTE_FIFO"
		echo "messages" >> "$QUTE_FIFO"
	fi
fi
rm -rf $results
