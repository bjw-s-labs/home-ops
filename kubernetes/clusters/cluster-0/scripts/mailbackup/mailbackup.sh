#!/bin/bash

RCFILES="/config/*"
for rcfile in $RCFILES; do
    echo "Processing ${rcfile}..."

    filename=$(basename -- "${rcfile}")

    mkdir -p "/data/${filename}/new"
    mkdir -p "/data/${filename}/cur"
    mkdir -p "/data/${filename}/tmp"

    getmail --getmaildir "/data/${filename}/" --rcfile "/config/${filename}"
done
