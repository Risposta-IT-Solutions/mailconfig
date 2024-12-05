#!/bin/bash

if [ -f /home/config.env ]; then
  source /home/config.env
else
  echo "Configuration file not found!"
  exit 1
fi

EMAIL="$PREFIX@$DOMAIN"
CERT_NAME="mail.${DOMAIN}"
VHOST_FILE="/etc/apache2/sites-available/000-default.conf"
LETSENCRYPT_LOG="/var/log/letsencrypt/letsencrypt.log"

# Ensure script runs as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Step 1: Add ServerName and ServerAlias to Apache configuration
if [ -f "$VHOST_FILE" ]; then
  echo "Updating Apache vhost configuration: $VHOST_FILE"

  # Backup the original vhost file
  cp "$VHOST_FILE" "${VHOST_FILE}.bak"

  # Add ServerName and ServerAlias if not already present
  if ! grep -q "ServerName mail.${DOMAIN}" "$VHOST_FILE"; then
    echo "Adding ServerName to vhost file."
    if grep -q "<VirtualHost" "$APACHE_CONF"; then
        echo "Adding ServerName and ServerAlias inside <VirtualHost> tag..."
        sed -i "/<VirtualHost.*>/a \\    ServerName mail.$DOMAIN\\n    ServerAlias smtp.$DOMAIN imap.$DOMAIN" "$APACHE_CONF"
    else
        echo "VirtualHost tag not found in $APACHE_CONF. Exiting."
        exit 1
    fi
  fi
else
  echo "Error: Apache vhost file $VHOST_FILE not found."
  exit 1
fi

# Step 2: Reload Apache configuration
echo "Reloading Apache configuration."
systemctl reload apache2
if [ $? -ne 0 ]; then
  echo "Error reloading Apache. Check configuration syntax."
  exit 1
fi

# Step 3: Run Certbot to install certificates
echo "Running Certbot to obtain and install certificates."
certbot --apache -d mail.${DOMAIN} -d smtp.${DOMAIN} -d imap.${DOMAIN} \
  --non-interactive --agree-tos --email ${EMAIL} --no-eff-email

if [ $? -ne 0 ]; then
  echo "Certbot encountered an issue. Check the log: ${LETSENCRYPT_LOG}"
  exit 1
fi

# Step 4: Verify the certificate installation
echo "Verifying the certificate installation."
certbot certificates --cert-name ${CERT_NAME}

if [ $? -ne 0 ]; then
  echo "Certificate verification failed. Manual intervention might be required."
  exit 1
fi

# Final Step: Restart Apache
echo "Restarting Apache to apply changes."
systemctl restart apache2
if [ $? -ne 0 ]; then
  echo "Error restarting Apache. Check configuration and logs."
  exit 1
fi

echo "Certificate installation and vhost configuration completed successfully!"
