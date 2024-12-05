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

# Add ServerName and ServerAlias if not already present
if [ -f "$VHOST_FILE" ]; then
    echo "Processing Apache vhost file: $VHOST_FILE"

    # Variable to hold the directives to add
    ADD_DIRECTIVES=""

    # Check and add ServerName
    if ! grep -q "ServerName mail.${DOMAIN}" "$VHOST_FILE"; then
        echo "ServerName mail.${DOMAIN} not found. Adding to directives."
        ADD_DIRECTIVES="${ADD_DIRECTIVES}    ServerName mail.${DOMAIN}\n"
    fi

    # Check and add ServerAlias for smtp.${DOMAIN}
    if ! grep -q "ServerAlias.*smtp.${DOMAIN}" "$VHOST_FILE"; then
        echo "ServerAlias smtp.${DOMAIN} not found. Adding to directives."
        ADD_DIRECTIVES="${ADD_DIRECTIVES}    ServerAlias smtp.${DOMAIN}\n"
    fi

    # Check and add ServerAlias for imap.${DOMAIN}
    if ! grep -q "ServerAlias.*imap.${DOMAIN}" "$VHOST_FILE"; then
        echo "ServerAlias imap.${DOMAIN} not found. Adding to directives."
        ADD_DIRECTIVES="${ADD_DIRECTIVES}    ServerAlias imap.${DOMAIN}\n"
    fi

    # Add the collected directives inside the <VirtualHost> tag
    if [ -n "$ADD_DIRECTIVES" ]; then
        if grep -q "<VirtualHost" "$VHOST_FILE"; then
            echo "Adding directives inside <VirtualHost> tag..."
            sed -i "/<VirtualHost.*>/a \\$ADD_DIRECTIVES" "$VHOST_FILE"
        else
            echo "VirtualHost tag not found in $VHOST_FILE. Exiting."
            exit 1
        fi
    else
        echo "All required directives are already present in $VHOST_FILE."
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
