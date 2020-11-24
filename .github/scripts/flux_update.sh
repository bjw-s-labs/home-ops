#!/usr/bin/env bash

set -eou pipefail

if [[ ! $(flux) ]]; then
  echo "flux needs to be installed - https://toolkit.fluxcd.io/get-started/#install-the-toolkit-cli"
  exit 1
fi

flux install \
  --version=latest \
  --components=source-controller,kustomize-controller,helm-controller,notification-controller \
  --namespace=system-flux \
  --network-policy=false \
  --log-level=info \
  --export > "./cluster/system-flux/gotk-components.yaml"
