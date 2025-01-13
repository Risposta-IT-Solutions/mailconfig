#!/bin/bash

if [[ -f "/home/config.env" ]]; then
    source /home/config.env
else 
    echo "Error: Configuration file not found" >> /home/jenkins.log
    exit 1
fi 

IP=$(hostname -I | awk '{print $1}')

#signature = content from /etc/opendkim/keys/$DOMAIN/mail.txt

KEY_FILE="/etc/opendkim/keys/$DOMAIN/mail.txt"

$signature = $(cat "$KEY_FILE")


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
# Escape special characters in the mail
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

# Check the HTTP status code
if [ "$response_status" -eq 200 ]; then
    if [ "$saved" == "true" ]; then
        echo "Mail saved [Response: $response_text]" >> $LOG_FILE
        exit 1
    else
        echo "Mail not saved [Response: $response_text]" >> $LOG_FILE
        exit 0
    fi
else
    echo "Mail save request failed with status code $response_status [Response: $response_text]" >> $LOG_FILE
    exit 1
fi