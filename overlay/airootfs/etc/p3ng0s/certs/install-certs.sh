#!/bin/bash
# install-certs.sh
# Created on: Wed 11 Mar 2026 11:14:31 AM CET
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
CERTS_FOLDER=/home/p4p1-live/loot/certs
#CERTS_FOLDER=/home/p4p1/loot/certs/
DEBUG_LOG=$CERTS_FOLDER/debug.log

if [[ -z "$TERM" || "$TERM" == "linux" ]]; then
    # Direct hijack of the console to ensure it BLOCKS
    #exec < /dev/tty1 > /dev/tty1 2>&1
    exec > >(tee -a "$DEBUG_LOG" > /dev/tty1) 2>&1
fi

echo "--- Certificates ---"

if [ ! -d $CERTS_FOLDER ]; then
    echo -e "\e[1;31m[!]\e[0m Cannot find the certificate folder exiting"
    sleep 5
    exit -1
fi
CERT_COUNT=0
for CERT in $CERTS_FOLDER/*.cer; do
    [ -f "$CERT" ] || continue
    CERT_NAME=$(basename "$CERT" .cer)
    echo -e "\e[36m[*]\e[0m Installing $CERT_NAME"

    # Convert DER to PEM if needed (most .cer files are DER encoded)
    if file "$CERT" | grep -q "PEM"; then
        cp -r $CERT /etc/ca-certificates/trust-source/anchors/$CERT_NAME.crt
        echo -e "\e[32m[-]\e[0m Installed $CERT_NAME as PEM"
    elif file "$CERT" | grep -q "Certificate"; then
        cp -r $CERT /etc/ca-certificates/trust-source/anchors/$CERT_NAME.crt
        echo -e "\e[32m[-]\e[0m Installed $CERT_NAME as Certificate"
    elif file "$CERT" | grep -q "DER"; then
        TEMP_CERT=$(mktemp)
        cp -r $CERT $TEMP_CERT
        openssl x509 -inform DER -in "$TEMP_CERT" -out "/etc/ca-certificates/trust-source/anchors/$CERT_NAME.crt"
        echo -e "\e[32m[-]\e[0m Installed $CERT_NAME as DER"
    else
        echo -e "\e[1;31m[!]\e[0m Failed to install $CERT_NAME"
    fi

    CERT_COUNT=$((CERT_COUNT + 1))
done

if [ $CERT_COUNT -gt 0 ]; then
    trust extract-compat
    update-ca-trust
    echo -e "\e[36m[*]\e[0m Installed $CERT_COUNT certificates."
fi
