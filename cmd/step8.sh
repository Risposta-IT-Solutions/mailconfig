#!/bin/bash
echo "Configuring Postfix, Dovecot, Roundcube, and OpenDKIM..." > /home/step8.log
# Source the configuration file for DOMAIN
if [ -f /home/config.env ]; then
  source /home/config.env
else
  echo "Configuration file not found!"
  exit 1
fi

cd /home/mailconfig/

if [ -z "$DOMAIN" ]; then
  echo "Error: DOMAIN is not set in $CONF_FILE."
  exit 1
fi

# Check if the ./sample directory exists
if [ ! -d "./sample" ]; then
  echo "Error: The source directory './sample/' does not exist."
  exit 1
fi

# Execute postfix_db.sql with MySQL
SQL_FILE="./sample/postfix_db.sql"
if [ -f "$SQL_FILE" ]; then
  echo "Executing postfix_db.sql with MySQL..." >> /home/step8.log
  mysql -u root postfix_db< "$SQL_FILE"
  if [ $? -eq 0 ]; then
    echo "Database initialized successfully."  >> /home/step8.log
  else
    echo "Error: Failed to execute postfix_db.sql." >> /home/step8.log
    exit 1
  fi
else
  echo "Error: File postfix_db.sql not found in ./sample/." >> /home/step8.log
  exit 1
fi

# Rename and move webmail.{{_domain_}}.conf to /etc/apache2/sites-available
SRC_CONF_FILE="./sample/webmail.{{_domain_}}.conf"
DEST_CONF_FILE="/etc/apache2/sites-available/webmail.$DOMAIN.conf"

if [ -f "$SRC_CONF_FILE" ]; then
  echo "Renaming and moving webmail.{{_domain_}}.conf to webmail.$DOMAIN.conf..." >> /home/step8.log
  sudo cp -rf "$SRC_CONF_FILE" "$DEST_CONF_FILE"
else
  echo "Error: File webmail.{{_domain_}}.conf not found in ./sample/." >> /home/step8.log
fi

# Move opendkim.conf to /etc
if [ -f "./sample/opendkim.conf" ]; then
  echo "Moving opendkim.conf to /etc..." >> /home/step8.log
  sudo cp -rf ./sample/opendkim.conf /etc
else
  echo "Error: File opendkim.conf not found in ./sample/." >> /home/step8.log
fi

# Move dovecot, roundcube, and postfix directories to /etc
for dir in dovecot roundcube postfix; do
  if [ -d "./sample/$dir" ]; then
    echo "Moving $dir directory to /etc..." >> /home/step8.log
    sudo cp -rf ./sample/$dir /etc
  else
    echo "Warning: Directory $dir not found in ./sample/." >> /home/step8.log
  fi
done

echo "All specified operations have been completed successfully." >> /home/step8.log
