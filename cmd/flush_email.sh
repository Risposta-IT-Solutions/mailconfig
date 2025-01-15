#!/bin/bash
echo "" > /home/flush_email.log

if [[ -f "/home/config.env" ]]; then
    source /home/config.env
else 
    echo "Error: Configuration file not found" >> /home/flush_email.log
    exit 1
fi 

IP=$(hostname -I | awk '{print $1}')

# Check if email is provided
if [ -z "$1" ]; then
    echo "Error: No email provided" >> /home/flush_email.log
    exit 1
fi

email="$1"

if [ "$ENVIRONMENT" == "production" ]; then
    URL="https://api.pay-per-lead.co.uk/mailConfig/deleteEmail"
else
    URL="https://beta.api.pay-per-lead.co.uk/mailConfig/deleteEmail"
fi

if ! command -v jq > /dev/null 2>&1; then
echo "jq not found. Installing jq..."
sudo apt update && sudo apt install -y jq
fi

if ! command -v curl > /dev/null 2>&1; then
echo "curl not found. Installing curl..."
sudo apt update && sudo apt install -y curl
fi

# Escape special characters in the email
escaped_email=$(printf '%s' "$email" | jq -R .)
escaped_email=$(echo $escaped_email | sed 's/\"//g')

# Build JSON data
DATA=$(jq -n \
    --arg ip "$IP" \
    --arg domain "$DOMAIN" \
    --arg email "$escaped_email" \
    '{"ip": $ip, "domain": $domain, "email": $email}')

# Send DELETE request and capture response text and status code
response=$(curl -s -w "\n%{http_code}" -X DELETE \
    -H "Content-Type: application/json" \
    -d "$DATA" "$URL")

# Separate the response body and status code
response_text=$(echo "$response" | sed '$d')
response_status=$(echo "$response" | tail -n1)

deleted=$(echo $response_text | jq -r '.status')

# Check the HTTP status code
if [ "$response_status" -eq 200 ]; then
    if [ "$deleted" == "true" ]; then
        echo "Mail deleted [Response: $response_text]" >> /home/flush_email.log
        exit 0
    else
        echo "Mail not deleted [Response: $response_text]" >> /home/flush_email.log
        exit 1
    fi
else
    echo "Mail delete request failed with status code $response_status [Response: $response_text]" >> /home/flush_email.log
    exit 1
fi