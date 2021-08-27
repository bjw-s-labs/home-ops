#!/bin/bash
apt update
apt install -y --no-install-recommends gosu python3-pip
pip3 install getmail6
useradd --no-log-init -r -u $UID -g $GID getmail
mkdir -p /data/new
mkdir -p /data/cur
mkdir -p /data/tmp
chown "$UID:$GID" "/data/new"
chown "$UID:$GID" "/data/cur"
chown "$UID:$GID" "/data/tmp"
COMMAND="getmail --getmaildir=/config"
gosu getmail $COMMAND
