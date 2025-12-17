#!/usr/bin/env bash
set -euo pipefail

# Incoming arguments
JOB=${1:-}
NAMESPACE=${2:-}
PROJECT=${3:-}

# URL encode the project name
PROJECT=$(echo "${PROJECT}" | jq -Rr @uri)

curl -s -X POST \
  "http://renovate-operator-webhook.renovate.svc.cluster.local:8082/webhook/v1/schedule?job=${JOB}&namespace=${NAMESPACE}&project=${PROJECT}"
