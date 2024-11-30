#!/bin/bash

# Step 0: Load configuration
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
echo "Enabling Apache site for webmail.$DOMAIN..."
sudo a2ensite webmail.$DOMAIN
sudo systemctl reload apache2

# Step 2: Obtain SSL certificate for webmail
echo "Obtaining SSL certificate for webmail.$DOMAIN..."
sudo certbot --apache -d webmail.$DOMAIN --non-interactive --agree-tos --email "$PREFIX@$DOMAIN" --no-eff-email

# Step 3: Setup Maildir directories
echo "Setting up Maildir for domain $DOMAIN and prefix $PREFIX..."
sudo mkdir -p /var/mail/vhosts/$DOMAIN/$PREFIX
sudo maildirmake.dovecot /var/mail/vhosts/$DOMAIN/$PREFIX
sudo chown -R vmail:vmail /var/mail/vhosts/$DOMAIN/$PREFIX

sudo maildirmake.dovecot /var/mail/vhosts/$DOMAIN/root
sudo chown -R vmail:vmail /var/mail/vhosts/$DOMAIN/root

echo "Setup completed for webmail.$DOMAIN and Maildir for $PREFIX@$DOMAIN."
