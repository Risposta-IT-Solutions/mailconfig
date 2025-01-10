#!/bin/bash
if [[ -f "/home/config.env" ]]; then
    source /home/config.env
else 
    DOMAIN="0"
    tmp_conf_file="/home/tmp.env"
    if [[ -f "$tmp_conf_file" ]]; then
        source $tmp_conf_file
    fi
fi 

IP=$(hostname -I | awk '{print $1}')

# Check if a status is provided
if [ -z "$1" ]; then
    echo "Error: No status provided"
    exit 1
fi

if [ "$ENVIRONMENT" == "production" ]; then
    URL="https://api.pay-per-lead.co.uk/mailConfig/updateStatus"
else
    URL="https://beta.api.pay-per-lead.co.uk/mailConfig/updateStatus"
fi

if ! command -v jq > /dev/null 2>&1; then
echo "jq not found. Installing jq..."
sudo apt update && sudo apt install -y jq
fi

if ! command -v curl > /dev/null 2>&1; then
echo "curl not found. Installing curl..."
sudo apt update && sudo apt install -y curl
fi

# Escape special characters in the message
escaped_message=$(printf '%s' "$1" | jq -R .)

# Build JSON data
DATA=$(jq -n \
    --arg ip "$IP" \
    --arg domain "$DOMAIN" \
    --arg status "$escaped_message" \
    '{"ip": $ip, "domain": $domain, "status": $status}')

# Send POST request
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "$DATA" "$URL")

# Check the HTTP status code
if [ "$response" -eq 200 ]; then
    echo "Status update request successful"
    exit 0
else
    echo "Status update request failed with status code $response"
    exit 1
fi

