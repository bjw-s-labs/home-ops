#!/usr/bin/env bash

MERGERFS_ANCHOR="${VARIABLE:=/mnt/unionfs/gdrive.anchor}"
MERGERFS_MOUNTPOINT="${VARIABLE:=/mnt/unionfs}"
MERGERFS_MOUNTNAME="${VARIABLE:=Merged Media}"

unmount_merge() {
  echo "Unmounting ${MERGERFS_MOUNTNAME}..."
  trap - SIGINT SIGTERM # clear the trap
  /bin/fusermount -uz "${MERGERFS_MOUNTPOINT}"
  kill -KILL "$pid"
}

trap unmount_merge SIGTERM
trap unmount_merge SIGQUIT

sleep 15

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
  "${MERGERFS_MOUNTPOINT}"

# check if mergerfs mount successful
echo "$(date "+%d.%m.%Y %T") INFO: Checking if ${MERGERFS_MOUNTNAME} mergerfs mount created."
if [[ -f "$MERGERFS_ANCHOR" ]]; then
	echo "$(date "+%d.%m.%Y %T") INFO: Check successful, ${MERGERFS_MOUNTNAME} mergerfs mount created."
else
  echo "$(date "+%d.%m.%Y %T") INFO: Mount Failed!, ${MERGERFS_MOUNTNAME} mergerfs mount NOT created."
fi

echo "Script is running! waiting for signals."

sleep infinity &
pid=$!

wait $pid