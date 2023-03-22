#!/usr/bin/env bash

anchor="/mnt/merged/gdrive.anchor"
mountPoint="/mnt/merged"
mountName="Merged Media"

umount_merge() {
  echo "Unmounting ${mountName}..."
  trap - SIGINT SIGTERM # clear the trap
  /bin/fusermount -uz ${mountPoint}
  kill -KILL "$pid"
  # kill -- -$$ # Sends SIGTERM to child/sub processes
}

trap unmount_merge SIGTERM
trap unmount_merge SIGKILL
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
  ${mountPoint}

# check if mergerfs mount successful
echo "$(date "+%d.%m.%Y %T") INFO: Checking if ${mountName} mergerfs mount created."
if [[ -f "$anchor" ]]; then
	echo "$(date "+%d.%m.%Y %T") INFO: Check successful, ${mountName} mergerfs mount created."
else
  echo "$(date "+%d.%m.%Y %T") INFO: Mount Failed!, ${mountName} mergerfs mount NOT created."
fi

echo "Script is running! waiting for signals."

sleep infinity &
pid=$!
wait $pid