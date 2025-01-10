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

# Check if a message is provided
if [ -z "$1" ]; then
    echo "Error: No message provided"
    exit 1
fi

if [ "$ENVIRONMENT" == "production" ]; then
    URL="https://api.pay-per-lead.co.uk/mailConfig/log"
else
    URL="https://beta.api.pay-per-lead.co.uk/mailConfig/log"
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
    --arg message "$escaped_message" \
    '{"ip": $ip, "domain": $domain, "message": $message}')

# Send POST request and capture response text and status code
response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "$DATA" "$URL")

# Separate the response body and status code
response_text=$(echo "$response" | sed '$d')
response_status=$(echo "$response" | tail -n1)

# Check the HTTP status code
if [ "$response_status" -eq 200 ]; then
    echo "Log request successful [ $URL ] with status $response_status"
    echo "Response: $response_text"
    exit 0
else
    echo "Log request failed with status code $response_status"
    echo "Response: $response_text"
    exit 1
fi
