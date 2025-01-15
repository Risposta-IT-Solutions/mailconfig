#!/bin/bash

echo "" > /home/add_email.log

# Check if both arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Error: Both email and display name are required." >> /home/add_email.log
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

echo "Email: $email" >> /home/add_email.log
echo "Display Name: $display_name" >> /home/add_email.log
echo "Domain: $DOMAIN" >> /home/add_email.log
echo "Prefix: $PREFIX" >> /home/add_email.log


sudo mkdir -p /var/mail/vhosts/$DOMAIN/$PREFIX

if [ $? -ne 0 ]; then
  echo "An error occurred while creating the directory for $email." >> /home/add_email.log
  exit 1
fi

echo "Directory created successfully for $email." >> /home/add_email.log


sudo chown -R vmail:vmail /var/mail/vhosts/$DOMAIN/$PREFIX

if [ $? -ne 0 ]; then
  echo "An error occurred while changing ownership of the directory for $email." >> /home/add_email.log
  exit 1
fi

echo "Ownership changed successfully for $email." >> /home/add_email.log

(cd /home/mailconfig/cmd && ./save_mail.sh "$email" "$display_name")

if [ $? -ne 0 ]; then
  echo "Failed to save mail for $email." >>  /home/add_email.log
  exit 1
else 
    echo "Mail saved successfully for $email." >> /home/add_email.log
    exit 0
fi