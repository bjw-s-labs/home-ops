#!/bin/vbash
# shellcheck shell=bash
# shellcheck source=/dev/null
source /opt/vyatta/etc/functions/script-template

if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

log() {
  echo "$1"
}

if pidof -o %PPID -x "add-container-images.sh">/dev/null; then
    log "add-container-images.sh script is already running"
    exit
fi

set -e

pull_image() {
  # shellcheck disable=SC2076
  if [[ ! " ${AVAILABLE_IMAGES[*]} " =~ " ${1} " ]]; then
    log "Pulling image $1"
    if ! sudo podman pull "$1" > /dev/null 2>&1 ; then
      log "[ERROR] Failed to download image $1"
      exit 1
    fi
  fi
}

# shellcheck disable=SC2207
AVAILABLE_IMAGES=($(run show container image | awk '{ if ( NR > 1  ) { print $1 ":" $2} }'))

# shellcheck disable=SC2207
CONFIG_IMAGES=($(show container name | grep image | uniq | awk '{ print $2}'))

for image in "${CONFIG_IMAGES[@]}"
do
  pull_image "${image}"
done
