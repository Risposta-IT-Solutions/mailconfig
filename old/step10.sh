#!/bin/bash

echo "Configuring webmail, SSL, and Maildir for $PREFIX@$DOMAIN..." > /home/logs/step10.log

if [ -f /home/config.env ]; then
  source /home/config.env
else
  echo "Configuration file not found!"
  exit 1
fi

# Check if DOMAIN and PREFIX are defined in the configuration
if [ -z "$DOMAIN" ] || [ -z "$PREFIX" ]; then
  echo "DOMAIN or PREFIX not defined in config.env. Please set them and try again."
  exit 1
fi

# Step 1: Enable the Apache site for webmail
echo "Enabling Apache site for webmail.$DOMAIN..." >> /home/logs/step10.log
sudo a2ensite webmail.$DOMAIN
sudo systemctl reload apache2

if [ $? -ne 0 ]; then
  echo "An error occurred while enabling the Apache site for webmail.$DOMAIN." >> /home/logs/step10.log
  exit 1
fi

# Step 2: Obtain SSL certificate for webmail
echo "Obtaining SSL certificate for webmail.$DOMAIN..." >> /home/logs/step10.log
sudo certbot --apache -d webmail.$DOMAIN --non-interactive --agree-tos --email "$PREFIX@$DOMAIN" --no-eff-email

if [ $? -ne 0 ]; then
  echo "An error occurred while obtaining an SSL certificate for webmail.$DOMAIN." >> /home/logs/step10.log
  exit 1
fi

sudo certbot --apache -d mail.$DOMAIN -d smtp.$DOMAIN -d imap.$DOMAIN --email "$PREFIX@$DOMAIN" --agree-tos --non-interactive

if [[ $? -eq 0 ]]; then
    echo "Certificate successfully created for domains mail.$DOMAIN, smtp.$DOMAIN, imap.$DOMAIN."
else
    echo "Certificate creation failed."
    exit 1
fi

# Step 3: Setup Maildir directories
echo "Setting up Maildir for domain $DOMAIN and prefix $PREFIX..." >> /home/logs/step10.log
sudo mkdir -p /var/mail/vhosts/$DOMAIN/$PREFIX
sudo maildirmake.dovecot /var/mail/vhosts/$DOMAIN/$PREFIX
sudo chown -R vmail:vmail /var/mail/vhosts/$DOMAIN/$PREFIX

# Create a Maildir for the root user

sudo maildirmake.dovecot /var/mail/vhosts/$DOMAIN/root
sudo chown -R vmail:vmail /var/mail/vhosts/$DOMAIN/root

if [ $? -ne 0 ]; then
  echo "An error occurred while setting up Maildir for $PREFIX@$DOMAIN." >> /home/logs/step10.log
  exit 1
fi

echo "Setup completed for webmail.$DOMAIN and Maildir for $PREFIX@$DOMAIN." >> /home/logs/step10.log
