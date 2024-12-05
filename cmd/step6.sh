#!/bin/bash

if [ -f /home/config.env ]; then
  source /home/config.env
else
  echo "Configuration file not found!"
  exit 1
fi

DB_NAME="roundcube"
DB_USER="roundcube"
DB_PASSWORD="Zz9730TH"


mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF


# Step 1: Create directories and generate DKIM keys
echo "Creating DKIM directories and generating keys for $DOMAIN..." > /home/logs/step6.log
sudo mkdir -p /etc/opendkim/keys/$DOMAIN
cd /etc/opendkim/keys/$DOMAIN
sudo opendkim-genkey -s mail -d $DOMAIN

if [ $? -ne 0 ]; then
  echo "Error generating DKIM keys for $DOMAIN!" >> /home/logs/step6.log
  exit 1
else
  echo "DKIM keys generated successfully for $DOMAIN" >> /home/logs/step6.log
fi

echo "Setting permissions for DKIM keys - Done" >> /home/logs/step6.log
