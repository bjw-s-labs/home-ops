#!/bin/bash
set -o nounset
set -o errexit

IP4=$(curl -s https://ipv4.icanhazip.com/)

for domain in $(jq -r '.[] | @base64' ./ddns_data.json ); do
    _jq() {
        echo "${domain}" | base64 --decode | jq -r "$1"
    }

    TOKEN=$(_jq '.token')
    ZONE=$(_jq '.zone')
    RECORD=$(_jq '.record')

    zone_details=$(
        curl -s -X GET \
            "https://api.cloudflare.com/client/v4/zones?name=${ZONE}" \
            -H "Authorization: Bearer ${TOKEN}" \
            -H "Content-Type: application/json"
    )

    if echo "${zone_details}" | grep -q '\"success\":false'; then
        printf "%s - Yikes - Getting details for zone '%s' has failed\n" "$(date -u)" "${ZONE}"
        exit 1
    fi
    zone_identifier=$(echo "$zone_details" | jq -c -r '.result[0].id')

    record4=$(
        curl -s -X GET \
            "https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records?name=${RECORD}&type=A" \
            -H "Authorization: Bearer ${TOKEN}" \
            -H "Content-Type: application/json"
    )
    old_ip4=$(echo "${record4}" | sed -n 's/.*"content":"\([^"]*\).*/\1/p')
    if [ "${IP4}" = "${old_ip4}" ]; then
        printf "%s - Success - IP Address '%s' has not changed for '%s' in zone '%s'\n" "$(date -u)" "${IP4}" "${RECORD}" "${ZONE}"
        continue
    fi

    record4_identifier=$(echo "${record4}" | sed -n 's/.*"id":"\([^"]*\).*/\1/p')
    update4=$(
        curl -s -X PUT \
            "https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records/${record4_identifier}" \
            -H "Authorization: Bearer ${TOKEN}" \
            -H "Content-Type: application/json" \
            --data "{\"id\":\"${zone_identifier}\",\"type\":\"A\",\"proxied\":true,\"name\":\"${RECORD}\",\"content\":\"${IP4}\"}"
    )

    if echo "${update4}" | grep -q '\"success\":false'; then
        printf "%s - Yikes - Updating IP Address '%s' has failed for '%s' in zone '%s'\n" "$(date -u)" "${IP4}" "${RECORD}" "${ZONE}"
        exit 1
    else
        printf "%s - Success - IP Address '%s' has been updated for '%s' in zone '%s'\n" "$(date -u)" "${IP4}" "${RECORD}" "${ZONE}"
    fi
done
