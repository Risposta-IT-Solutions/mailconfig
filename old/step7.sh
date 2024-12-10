#!/bin/bash

if [ -f /home/config.env ]; then
  source /home/config.env
else
  echo "Configuration file not found!"
  exit 1
fi

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
