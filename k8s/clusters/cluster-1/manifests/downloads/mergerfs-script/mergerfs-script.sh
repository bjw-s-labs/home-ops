#!/usr/bin/env bash

anchor="/mnt/merged/gdrive.anchor"
mountPoint="/mnt/merged"
mountName="Merged Media"

umount_merge() {
  echo "Unmounting ${mountName}..."
  umount ${mountPoint}
}

catch_kill() {
  echo "Caught SIGKILL signal!"
  umount_merge
  kill -KILL "$pid" 2>/dev/null
}

catch_term() {
  echo "Caught SIGTERM signal!"
  umount_merge
  kill -TERM "$pid" 2>/dev/null
}

catch_quit() {
  echo "Caught SIGTERM signal!"
  umount_merge
  kill -QUIT "$pid" 2>/dev/null
}

catch_ctrlc() {
  echo "Caught ctrl+c!"
  umount_merge
  kill -KILL "$pid" 2>/dev/null
}

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

trap catch_term SIGTERM
trap catch_kill SIGKILL
trap catch_quit SIGQUIT
trap catch_ctrlc INT

echo "Script is running! waiting for signals."

pid=$$

sleep infinity