#!/bin/bash
#
# Description: Backup config directory and configuration commands to a USB device
#

dest=/media/usb-backup

# Only backup if $dest is a mount
if mountpoint -q $dest; then
    # Backup # VyOS /config
    backup_dest="$dest/vyos"
    if [ ! -d "$backup_dest" ]; then
        mkdir "$backup_dest"
    fi
    tar --exclude="overlay*" --exclude="unifi*" -zvcf "$backup_dest/config.$(date +%Y%m%d%H%M%S).tar.gz" /config

    # Unifi backups
    backup_dest="$dest/unifi"
    if [ ! -d "$backup_dest" ]; then
        mkdir "$backup_dest"
    fi
    tar -zvcf "$backup_dest/unifi-backup.$(date +%Y%m%d%H%M%S).tar.gz" /config/unifi/data/data/backup
fi
