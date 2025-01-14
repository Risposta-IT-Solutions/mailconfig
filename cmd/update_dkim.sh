#!/bin/bash

if [[ -f "/home/config.env" ]]; then
    source /home/config.env
else 
    echo "Error: Configuration file not found" >> /home/jenkins.log
    exit 1
fi 

IP=$(hostname -I | awk '{print $1}')

KEY_FILE="/etc/opendkim/keys/$DOMAIN/mail.txt"

if [ ! -f "$KEY_FILE" ]; then
    echo "Error: Key file not found" >> $LOG_FILE
    exit 1
fi

signature=$(cat "$KEY_FILE")

if [ -z "$signature" ]; then
    echo "Error: Signature is empty" >> $LOG_FILE
    exit 1
fi

if [ "$ENVIRONMENT" == "production" ]; then
    URL="https://api.pay-per-lead.co.uk/mailConfig/saveSignature"
else
    URL="https://beta.api.pay-per-lead.co.uk/mailConfig/saveSignature"
fi

if ! command -v jq > /dev/null 2>&1; then
    echo "jq not found. Installing jq..."
    sudo apt update && sudo apt install -y jq
fi

if ! command -v curl > /dev/null 2>&1; then
    echo "curl not found. Installing curl..."
    sudo apt update && sudo apt install -y curl
fi

# Escape special characters in the signature
escaped_signature=$(printf '%s' "$signature" | jq -R .)

escaped_signature=$(echo $escaped_signature | sed 's/\"//g')

# Build JSON data
DATA=$(jq -n \
    --arg ip "$IP" \
    --arg domain "$DOMAIN" \
    --arg signature "$escaped_signature" \
    '{"ip": $ip, "domain": $domain, "signature": $signature}')

# Send POST request and capture response text and status code
response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "$DATA" "$URL")

# Separate the response body and status code
response_text=$(echo "$response" | sed '$d')
response_status=$(echo "$response" | tail -n1)

saved=$(echo $response_text | jq -r '.status')

if [ ! -f /home/dkim.log ]; then
    touch /home/dkim.log
fi

# Check the HTTP status code
if [ "$response_status" -eq 200 ]; then
    if [ "$saved" == "true" ]; then
        echo "DKIM signature saved" >> $LOG_FILE
        echo "Response: $response_text" >> /home/dkim.log
    else
        echo "DKIM signature not saved" >> $LOG_FILE
        echo "Response: $response_text" >> /home/dkim.log
    fi
else
    echo "DKIM signature save request failed with status code $response_status [Response: $response_text]" >> $LOG_FILE
    echo "Response: $response_text" >> /home/dkim.log
fi