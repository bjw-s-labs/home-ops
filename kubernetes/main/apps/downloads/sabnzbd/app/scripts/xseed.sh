#!/usr/bin/env bash

XSEED_HOST=${XSEED_HOST:-crossseed}
XSEED_PORT=${XSEED_PORT:-8080}

SEARCH_PATH=$1

# Function to log messages
log_message() {
    local log_type="$1"
    local message="$2"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "${timestamp} [${log_type}] ${message}"
}

# Function to send a request to Cross Seed API
cross_seed_request() {
    local endpoint="$1"
    local data="$2"
    local headers=(-X POST "http://${XSEED_HOST}:${XSEED_PORT}/api/${endpoint}" --data-urlencode "${data}")
    if [[ -n "${XSEED_APIKEY}" ]]; then
        headers+=(-H "X-Api-Key: ${XSEED_APIKEY}")
    fi
    response=$(curl --silent --output /dev/null --write-out "%{http_code}" "${headers[@]}")
    echo "${response}"
}

xseed_resp=$(cross_seed_request "webhook" "path=${SEARCH_PATH}")

if [[ "${xseed_resp}" == "204" ]]; then
  log_message "INFO" "Process completed successfully."
  sleep 30
else
  log_message "ERROR" "Process failed with API response: ${xseed_resp}"
  exit 1
fi
