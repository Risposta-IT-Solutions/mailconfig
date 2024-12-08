#!/bin/bash

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

# MySQL commands to insert new email user into virtual_users table
echo "Inserting new email into the database..." > /home/logs/step12.log

# Securely run the MySQL command
mysql -u root -e "
USE postfix_db;
DELETE FROM virtual_users WHERE email = '$PREFIX@$DOMAIN' OR email = 'root@$DOMAIN';
INSERT INTO virtual_users (domain_id, password, email) VALUES 
  (1, 'a84f69cdf4c0cac5e6c8bb8043f5655b3c5ae5bd1908397c873c72a32ebff30a', '$PREFIX@$DOMAIN'),
  (1, '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'root@$DOMAIN');"

# Check if MySQL query was successful
if [ $? -eq 0 ]; then
  echo "Email '$PREFIX@$DOMAIN' inserted into the database successfully." >> /home/logs/step12.log
else
  echo "Failed to insert email into the database." >> /home/logs/step12.log
  exit 1
fi

# Create the directory for the new email
echo "Creating directory for email $PREFIX@$DOMAIN..." >> /home/logs/step12.log
sudo mkdir -p /var/mail/vhosts/$DOMAIN/$PREFIX

# Make directories for Dovecot mail storage
echo "Creating Dovecot mail directories..." >> /home/logs/step12.log
sudo maildirmake.dovecot /var/mail/vhosts/$DOMAIN/$PREFIX

# Change ownership of the email directories
echo "Changing ownership of mail directories..." >> /home/logs/step12.log
sudo chown -R vmail:vmail /var/mail/vhosts/$DOMAIN/$PREFIX

# Confirm the operations were successful
if [ $? -eq 0 ]; then
  echo "Directory and permissions set up successfully for $PREFIX@$DOMAIN." >> /home/logs/step12.log
else
  echo "Failed to set up directory or permissions for $PREFIX@$DOMAIN." >> /home/logs/step12.log
  exit 1
fi
