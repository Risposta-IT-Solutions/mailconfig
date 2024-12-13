#!/bin/bash
source /home/config.env

# Check if a message is provided
if [ -z "$1" ]; then
    echo "Error: No message provided"
    exit 1
fi

# Check if IP and DOMAIN variables are set
if [ -z "$IP" ] || [ -z "$DOMAIN" ]; then
    echo "Error: IP or DOMAIN is not set in /home/config.env"
    exit 1
fi

URL="https://api.pay-per-lead.co.uk/EmailConfig/log"

# Escape special characters in the message
escaped_message=$(printf '%s' "$1" | jq -R .)

# Build JSON data
DATA=$(jq -n \
    --arg ip "$IP" \
    --arg domain "$DOMAIN" \
    --arg message "$escaped_message" \
    '{"ip": $ip, "domain": $domain, "message": $message}')

# Send POST request
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "$DATA" "$URL")

# Check the HTTP status code
if [ "$response" -eq 200 ]; then
    echo "Request successful"
    exit 0
else
    echo "Request failed with status code $response"
    exit 1
fi
