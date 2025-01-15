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

echo "" > /home/delete_email.log

echo "Deleting mail for $email." >> /home/delete_email.log
echo "Email: $email" >> /home/delete_email.log
echo "Domain: $DOMAIN" >> /home/delete_email.log
echo "Prefix: $PREFIX" >> /home/delete_email.log

# Remove the email directory if it exists
if [ -d "/var/mail/vhosts/$DOMAIN/$PREFIX" ]; then
  sudo rm -rf /var/mail/vhosts/$DOMAIN/$PREFIX

  if [ $? -ne 0 ]; then
    echo "Failed to delete the directory for $email." >> /home/delete_email.log
    exit 1
  fi

else
  echo "Directory does not exist for $email." >> /home/delete_email.log
fi

mysql -u root postfix_db <<EOF
DELETE FROM virtual_users WHERE email='$email';
EOF

if [ $? -ne 0 ]; then
  echo "Failed to delete $email from the database." >> /home/delete_email.log
  exit 1
else
  echo "Deleted $email from the database." >> /home/delete_email.log
fi


(cd /home/mailconfig/cmd && ./flush_email.sh "$email")

if [ $? -ne 0 ]; then
  echo "Failed to delete mail for $email." >> /home/delete_email.log
fi

echo "Mail deleted successfully for $email." >> /home/delete_email.log
exit 0
