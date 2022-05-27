#!/bin/vbash
# shellcheck shell=bash
# shellcheck source=/dev/null
source /opt/vyatta/etc/functions/script-template

if pidof -o %PPID -x "add-container-images.sh">/dev/null; then
    echo "add-container-images.sh script is already running"
    exit
fi

set -e

pull_image() {
  # shellcheck disable=SC2076
  if [[ ! " ${AVAILABLE_IMAGES[*]} " =~ " ${1} " ]]; then
    if ! sudo podman pull "$1" > /dev/null 2>&1 ; then
      echo "Failed to download image $1"
      exit
    fi
  fi
}

# shellcheck disable=SC2207
AVAILABLE_IMAGES=($(run show container image | awk '{ if ( NR > 1  ) { print $1 ":" $2} }'))
# shellcheck disable=SC2207
NEW_IMAGES=($(show container name | grep image | uniq | awk '{ print $2}'))

for image in "${NEW_IMAGES[@]}"
do
  pull_image "${image}"
done

exit
