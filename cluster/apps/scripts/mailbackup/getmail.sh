#!/bin/bash
apt update
apt install -y --no-install-recommends gosu getmail
ln -s /usr/bin/python2.7 /usr/bin/python2
useradd --no-log-init -r -u $UID -g $GID getmail
mkdir -p /data/new
mkdir -p /data/cur
mkdir -p /data/tmp
chown -R "$UID:$GID" "/data/new"
chown -R "$UID:$GID" "/data/cur"
chown -R "$UID:$GID" "/data/tmp"
COMMAND="getmail --getmaildir=/config"
gosu getmail $COMMAND
