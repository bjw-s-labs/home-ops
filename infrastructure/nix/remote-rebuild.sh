#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash git openssh nixos-rebuild
# shellcheck shell=bash

FLAKE=${1}
USER=${2}
TARGET=${3}

NIX_SSHOPTS="-A" \
nixos-rebuild switch \
  --flake ".#${FLAKE}" \
  --fast \
  --use-remote-sudo \
  --build-host "${USER}"@"${TARGET}" \
  --target-host "${USER}"@"${TARGET}"
