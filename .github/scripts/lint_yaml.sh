#!/bin/bash
set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
YAMLLINT_CONFIG="${REPO_ROOT}/.github/yamllint.config.yaml"

need() {
    command -v "$1" &>/dev/null || (echo "Binary '$1' is missing but required" && exit 1)
}

need "yamllint"

message() {
  echo -e "\n######################################################################"
  echo "# $1"
  echo "######################################################################"
}

message "Running YAML lint on all YAML files in repository based on ${YAMLLINT_CONFIG}"

yamllint -c "$YAMLLINT_CONFIG" .
rv=$?
message "all done!"
exit $rv
