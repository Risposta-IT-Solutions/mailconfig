#!/bin/bash
if [[ -f "/home/config.env" ]]; then
    source /home/config.env
else 
    DOMAIN=$(hostname -d)
    tmp_conf_file="/home/tmp.env"
    if [[ -f "$tmp_conf_file" ]]; then
        source $tmp_conf_file
    fi
fi 

if [ ! -f /home/status.log ]; then
    touch /home/status.log
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

escaped_message=$(echo $escaped_message | sed 's/\"//g')

# Get optional argument field, default to "server"
prefix=${2:-"server"}

echo "$prefix status: $escaped_message" >> /home/status.log

# Build JSON data
DATA=$(jq -n \
    --arg ip "$IP" \
    --arg domain "$DOMAIN" \
    --arg status "$escaped_message" \
    --arg prefix "$prefix" \
    '{"ip": $ip, "domain": $domain, "status": $status, "prefix": $prefix}'
    )

# Send POST request and capture response text and status code
response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "$DATA" "$URL")

# Separate the response body and status code
response_text=$(echo "$response" | sed '$d')
response_status=$(echo "$response" | tail -n1)


# Check the HTTP status code
if [ "$response_status" -eq 200 ]; then
    echo "Status update request successful [ $URL ] with status $response_status"
    echo "Response: $response_text" >> /home/status.log
else
    echo "Status update failed with status code $response_status"
    echo "Response: $response_text" >> /home/status.log
fi

