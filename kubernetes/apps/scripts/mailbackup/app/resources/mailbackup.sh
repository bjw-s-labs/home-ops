#!/bin/bash

RCFILES="/config/*"
for rcfile in $RCFILES; do
    echo "Processing ${rcfile}..."

    filename=$(basename -- "${rcfile}")

    mkdir -p "/data/nas-backup/Bernd/Email/${filename}/new"
    mkdir -p "/data/nas-backup/Bernd/Email/${filename}/cur"
    mkdir -p "/data/nas-backup/Bernd/Email/${filename}/tmp"

    getmail --getmaildir "/data/nas-backup/Bernd/Email/${filename}/" --rcfile "/config/${filename}"
done
