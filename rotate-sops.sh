#!/usr/bin/env bash
# TODO: Turn this in to a taskfile

# Find all the *.sops.yaml files recursively in the current directory and apply the decrypt and encrypt commands to them
find . -name "*.sops.yaml" ! -name ".sops.yaml" -type f -print0 | while IFS= read -r -d '' file; do
  echo "Re-encrypting ${file}"
  sops --decrypt --in-place "${file}"
  sops --encrypt --in-place "${file}"
done
