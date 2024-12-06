#!/bin/bash

# Check if the domain parameter is provided
if [ -f /home/config.env ]; then
  source /home/config.env
else
  echo "Configuration file not found!"
  exit 1
fi

cd /home/mailconfig/

# Define the target directory
TARGET_DIR="./sample"

# Loop through all files in the target directory and replace the placeholder
find "$TARGET_DIR" -type f -exec sed -i -e "s/{{_domain_}}/$DOMAIN/g" -e "s/{{_company_}}/$COMPANY/g" {} +

if [ $? -ne 0 ]; then
  echo "An error occurred while replacing placeholders in files in $TARGET_DIR."
  exit 1
fi

echo "Replaced {{_domain_}} with $DOMAIN in all files in $TARGET_DIR." > /home/logs/step8.log
