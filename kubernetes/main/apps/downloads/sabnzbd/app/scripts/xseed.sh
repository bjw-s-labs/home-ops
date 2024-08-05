#!/bin/bash
echo "${1}"
curl -X POST --silent --data-urlencode "path=${1}" "http://cross-seed.downloads.svc.cluster.local:2468/api/webhook?apikey=${CROSS_SEED__API_KEY}"
sleep 30
