#!/bin/bash

# Check if both arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <email> <display_name>"
    exit 1
fi

# Store arguments to variables
email="$1"
display_name="$2"

# Escape special characters in the email
email=$(printf '%s' "$email" | jq -R .)
email=$(echo $email | sed 's/\"//g')

# Escape special characters in the display name
display_name=$(printf '%s' "$display_name" | jq -R .)
display_name=$(echo $display_name | sed 's/\"//g')

# Split email to get domain and prefix
IFS='@' read -r PREFIX DOMAIN <<< "$email"


sudo mkdir -p /var/mail/vhosts/$DOMAIN/$PREFIX

if [ $? -ne 0 ]; then
  echo "An error occurred while creating the directory for $email." >> $LOG_FILE
  exit 1
fi

echo "Directory created successfully for $email." >> $LOG_FILE


sudo chown -R vmail:vmail /var/mail/vhosts/$DOMAIN/$PREFIX

if [ $? -ne 0 ]; then
  echo "An error occurred while changing ownership of the directory for $email." >> $LOG_FILE
  exit 1
fi

echo "Ownership changed successfully for $email." >> $LOG_FILE

./save_mail.sh "$email" "$display_name"

if [ $? -ne 0 ]; then
  echo "Failed to save mail for $email." >> $LOG_FILE
  exit 1
else 
    echo "Mail saved successfully for $email." >> $LOG_FILE
    exit 0
fi