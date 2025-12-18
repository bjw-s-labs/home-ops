#!/usr/bin/env bash
set -euo pipefail

# Incoming arguments
JOB=${1:-}
NAMESPACE=${2:-}
PROJECT=${3:-}
RENOVATE_OPERATOR_WEBHOOK_URL=${4:-}

# URL encode the project name
PROJECT=$(echo "${PROJECT}" | jq -Rr @uri)

curl -s -X POST \
  "${RENOVATE_OPERATOR_WEBHOOK_URL}/webhook/v1/schedule?job=${JOB}&namespace=${NAMESPACE}&project=${PROJECT}"
