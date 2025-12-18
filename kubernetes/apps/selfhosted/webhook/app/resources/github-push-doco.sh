#!/usr/bin/env bash
set -euo pipefail

# Incoming arguments
GITHUB_REF=${1:?}
GITHUB_SHA_BEFORE=${2:?}
GITHUB_SHA_AFTER=${3:?}
GITHUB_REPOSITORY=${4:?}
GITHUB_ACTOR_NAME=${5:?}
GITHUB_ACTOR_EMAIL=${6:?}
WEBHOOK_URL="${7:?}"

export WEBHOOK_SECRET=${GITHUB_WEBHOOK_SECRET:?missing secret}

CLONE_URL="https://github.com/${GITHUB_REPOSITORY}.git"

PAYLOAD=$(jq -n \
  --arg ref "${GITHUB_REF}" \
  --arg before "${GITHUB_SHA_BEFORE}" \
  --arg after "${GITHUB_SHA_AFTER}" \
  --arg clone_url "${CLONE_URL}" \
  --arg reponame "${GITHUB_REPOSITORY##*/}" \
  --arg repo_fullname "${GITHUB_REPOSITORY}" \
  --arg pusher_name "${GITHUB_ACTOR_NAME}" \
  --arg pusher_email "${GITHUB_ACTOR_EMAIL}" \
  '{
    ref: $ref,
    before: $before,
    after: $after,
    repository: {
      name: $reponame,
      full_name: $repo_fullname,
      clone_url: $clone_url
    },
    pusher: {
      name: $pusher_name,
      email: $pusher_email
    }
  }'
)

SIGNATURE="sha256=$(echo -n "${PAYLOAD}" | openssl dgst -sha256 -hmac "${WEBHOOK_SECRET}" | sed 's/^.* //')"

curl -s "${WEBHOOK_URL}" \
  -H "X-GitHub-Event: push" \
  -H "Content-Type: application/json" \
  -H "X-Hub-Signature-256: ${SIGNATURE}" \
  -d "${PAYLOAD}"
