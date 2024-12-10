#!/bin/bash

# Check if the required parameters are provided
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <domain> <prefix> <company>"
  exit 1
fi

# Get the parameters
DOMAIN="$1"
PREFIX="$2"
COMPANY="$3"
CONF_FILE="/home/config.env"
LOG_FILE="/home/jenkins.log"

# Create or overwrite the configuration file
echo "DOMAIN=$DOMAIN" > $CONF_FILE
echo "PREFIX=$PREFIX" >> $CONF_FILE
echo "COMPANY='$COMPANY'" >> $CONF_FILE
echo "LOG_FILE='$LOG_FILE'" >> $LOG_FILE

# Print a success message
echo "Configuration file '$CONF_FILE' created with the following content:"
cat $CONF_FILE


#allow ports
ufw allow http
ufw allow https
ufw allow smtp
ufw allow imaps
ufw allow 587
ufw allow 465
ufw allow ssh

ufw --force enable

echo "Ufw enabled and ports allowed"

#create logs folder  if not exist
[ -d /home/logs ] || mkdir /home/logs

#delete all files in logs folder
rm -rf /home/logs/*

sudo apt-get update -y

echo "System updated"