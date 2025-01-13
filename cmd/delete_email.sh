#!/bin/bash

# Check if both arguments are provided
if [ -z "$1" ]; then
    echo "Usage: $0 <email>"
    exit 1
fi

# Store arguments to variables
email="$1"

# Escape special characters in the email
email=$(printf '%s' "$email" | jq -R .)
email=$(echo $email | sed 's/\"//g')

# Split email to get domain and prefix
IFS='@' read -r PREFIX DOMAIN <<< "$email"

# Remove the email directory
sudo rm -rf /var/mail/vhosts/$DOMAIN/$PREFIX

if [ $? -ne 0 ]; then
  echo "Failed to delete the directory for $email." >> $LOG_FILE
  exit 1
fi

./flush_email.sh "$email"

if [ $? -ne 0 ]; then
  echo "Failed to delete mail for $email." >> $LOG_FILE
  exit 1
fi

echo "Mail deleted successfully for $email." >> $LOG_FILE
exit 0
