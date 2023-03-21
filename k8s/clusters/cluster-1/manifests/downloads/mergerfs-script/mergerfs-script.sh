#!/bin/sh

/usr/local/bin/mergerfs \
  -o category.create=lfs \
  -o async_read=false \
  -o cache.files=full \
  -o dropcacheonclose=true \
  -o use_ino \
  -o minfreespace=0 \
  -o xattr=nosys \
  -o statfs=full \
  -o statfs_ignore=ro \
  -o allow_other \
  -o umask=002 \
  -o noatime \
  /mnt/remotes/nas00-media/Plex/Local-Media=RW:/mnt/remotes/google=NC \
  /mnt/merged     