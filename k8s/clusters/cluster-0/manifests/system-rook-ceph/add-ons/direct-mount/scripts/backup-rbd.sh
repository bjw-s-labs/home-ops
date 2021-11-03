#!/bin/bash

# Set defaults
rbd_mountpath="/mnt/data"
target_folder="/mnt/nas-backup"
rbd=""
application=""

# Collect command line parameters
while [ $# -gt 0 ]; do
   if [[ "$1" == *"--"* ]]; then
        param="${1/--/}"
        declare "$param"="$2"
   fi
  shift
done

if [ -z "${rbd}" ]; then
  echo "Required parameter 'rbd' not set!"
  exit 1
fi

if [ -z "${application}" ]; then
  echo "Required parameter 'application' not set!"
  exit 1
fi

if [ -f "${target_folder}/${application}.tar.gz" ]; then
  echo "File '${target_folder}/${application}.tar.gz' already exists"
  exit 1
fi

if [ ! -d "${rbd_mountpath}" ]; then
  mkdir -p "${rbd_mountpath}"
fi

if [ ! -d "${target_folder}" ]; then
  mkdir -p "${target_folder}"
fi

rbd map -p replicapool "${rbd}" | xargs -I{} mount {} "${rbd_mountpath}"
tar czvf "${target_folder}/${application}.tar.gz" -C "${rbd_mountpath}/" .
umount "${rbd_mountpath}"
rbd unmap -p replicapool "${rbd}"
