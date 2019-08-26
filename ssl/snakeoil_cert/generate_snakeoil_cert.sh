#!/usr/bin/env bash
# Generate a snakeoil SSL certificate

SCRIPTDIR=$(dirname $0)

REQ_CONF_PATH="$SCRIPTDIR/req.conf"

if [ ! -f "$REQ_CONF_PATH" ]; then
    echo "ERROR: no configured req.conf file exists"
    exit 1
fi

openssl req \
    -x509 \
    -nodes \
    -days 3650 \
    -extensions "v3_req" \
    -newkey rsa:2048 \
    -config "$REQ_CONF_PATH" \
    -keyout cert.key \
    -out cert.crt
