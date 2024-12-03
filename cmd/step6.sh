#!/bin/bash

if [ -f /home/config.env ]; then
  source /home/config.env
else
  echo "Configuration file not found!"
  exit 1
fi

EMAIL="$PREFIX@$DOMAIN"

# Step 1: Create directories and generate DKIM keys
echo "Creating DKIM directories and generating keys for $DOMAIN..." > /home/step6.log
sudo mkdir -p /etc/opendkim/keys/$DOMAIN
cd /etc/opendkim/keys/$DOMAIN
sudo opendkim-genkey -s mail -d $DOMAIN

# Step 2: Obtain SSL certificates using Certbot without interaction
echo "Obtaining SSL certificates for mail services..." >> /home/step6.log
sudo certbot --apache -d mail.$DOMAIN -d smtp.$DOMAIN -d imap.$DOMAIN \
  --non-interactive --agree-tos --email $EMAIL --no-eff-email

# Optional: Print a success message
echo "DKIM keys generated and SSL certificates obtained for $DOMAIN with email $EMAIL." >> /home/step6.log
