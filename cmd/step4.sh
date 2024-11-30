#!/bin/bash

# Check if the domain parameter is provided
if [ -f /home/config.env ]; then
  source /home/config.env
else
  echo "Configuration file not found!"
  exit 1
fi

# Define the target directory
TARGET_DIR="../sample"

# Loop through all files in the target directory and replace the placeholder
find "$TARGET_DIR" -type f -exec sed -i "s/{{_domain_}}/$DOMAIN/g" {} +

# Optional: Print a success message
echo "Replaced {{_domain_}} with $DOMAIN in all files in $TARGET_DIR."
