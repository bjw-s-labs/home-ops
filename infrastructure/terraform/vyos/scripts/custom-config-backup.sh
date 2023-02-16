#!/bin/bash
#
# Description: Backup config directory and configuration commands to a USB device
#

dest=/media/usb-backup

# Only backup if $dest is a mount
if mountpoint -q $dest; then
    # Backup /config
    tar --exclude="overlay*" -zvcf $dest/config.$(date +%Y%m%d%H%M%S).tar.gz /config
fi
