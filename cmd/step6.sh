#!/bin/bash

if [ -f /home/config.env ]; then
  source /home/config.env
else
  echo "Configuration file not found!"
  exit 1
fi

EMAIL="$PREFIX@$DOMAIN"

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

# Step 2: Obtain SSL certificates using Certbot without interaction
echo "Obtaining SSL certificates for mail services..." >> /home/logs/step6.log

echo "Command: sudo certbot --apache -d mail.$DOMAIN -d smtp.$DOMAIN -d imap.$DOMAIN --non-interactive --agree-tos --email $EMAIL --no-eff-email" >> /home/logs/step6.log

sudo certbot --apache -d mail.$DOMAIN -d smtp.$DOMAIN -d imap.$DOMAIN --non-interactive --agree-tos --email $EMAIL --no-eff-email

if [ $? -ne 0 ]; then
  echo "Error obtaining SSL certificates for mail services!" >> /home/logs/step6.log

  echo "Fixing vhost configuration for mail services..." >> /home/logs/step6.log

  ./cmd/fix_vhost.sh

  sudo certbot --apache -d mail.$DOMAIN -d smtp.$DOMAIN -d imap.$DOMAIN --non-interactive --agree-tos --email $EMAIL --no-eff-email

  if [ $? -ne 0 ]; then
    echo "Fixing vhost failed!" >> /home/logs/step6.log
    exit 1
  fi

else
  echo "SSL certificates obtained successfully for: mail.$DOMAIN, smtp.$DOMAIN and imap.$DOMAIN" >> /home/logs/step6.log
fi

# Optional: Print a success message
echo "DKIM keys generated and SSL certificates obtained for $DOMAIN with email $EMAIL." >> /home/logs/step6.log
