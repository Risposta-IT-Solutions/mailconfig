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



echo "Created database '$DB_NAME' and user '$DB_USER' successfully." > /home/logs/step7.log;


# Step 1: Create directories and generate DKIM keys
echo "Creating DKIM directories and generating keys for $DOMAIN..." > /home/logs/step7.log
sudo mkdir -p /etc/opendkim/keys/$DOMAIN
cd /etc/opendkim/keys/$DOMAIN
sudo opendkim-genkey -s mail -d $DOMAIN

if [ $? -ne 0 ]; then
  echo "Error generating DKIM keys for $DOMAIN!" >> /home/logs/step7.log
  exit 1
else
  echo "DKIM keys generated successfully for $DOMAIN" >> /home/logs/step7.log
fi

echo "Setting permissions for DKIM keys - Done" >> /home/logs/step7.log
