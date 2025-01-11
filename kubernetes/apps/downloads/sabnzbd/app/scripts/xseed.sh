#!/usr/bin/env bash

XSEED_HOST=${XSEED_HOST:-crossseed}
XSEED_PORT=${XSEED_PORT:-8080}
XSEED_APIKEY=${XSEED_APIKEY:-unset}
XSEED_SLEEP_INTERVAL=${CROSS_SEED_SLEEP_INTERVAL:-30}

SEARCH_PATH=$1

response=$(curl \
  --silent \
  --output /dev/null \
  --write-out "%{http_code}" \
  --request POST \
  --data-urlencode "path=${SEARCH_PATH}" \
  --header "X-Api-Key: ${XSEED_APIKEY}" \
  "http://${XSEED_HOST}:${XSEED_PORT}/api/webhook"
)

if [[ "${response}" != "204" ]]; then
  printf "Failed to search cross-seed for '%s'\n" "${SEARCH_PATH}"
  exit 1
fi

printf "Successfully searched cross-seed for '%s'\n" "${SEARCH_PATH}"

sleep "${XSEED_SLEEP_INTERVAL}"
