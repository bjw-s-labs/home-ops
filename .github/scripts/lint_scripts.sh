#!/bin/bash
set -e

REPO_ROOT=$(git rev-parse --show-toplevel)

if [[ -z "$SHELLCHECK_ERROR_LEVEL" ]]; then
  SHELLCHECK_ERROR_LEVEL="style"
fi

need() {
    command -v "$1" &>/dev/null || (echo "Binary '$1' is missing but required" && exit 1)
}

need "shellcheck"

message() {
  echo -e "\n######################################################################"
  echo "# $1"
  echo "######################################################################"
}

message "Running ShellCheck on all script files in repository"

FILES_TO_PROCESS=$(find "${REPO_ROOT}" -name '*.sh')

# Loop over the files that should be processed
set +e
FAILED=0
while IFS= read -r file; do
  echo "- Processing $file"
  shellcheck -S "$SHELLCHECK_ERROR_LEVEL" "$file"
  if [[ $? == 1 ]]; then
    FAILED=1
  fi
done <<< "$FILES_TO_PROCESS"
set -e

message "all done!"

if [[ $FAILED != 0 ]]; then
  exit $FAILED
fi