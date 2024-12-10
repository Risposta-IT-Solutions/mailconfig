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
echo "LOG_FILE='$LOG_FILE'" >> $CONF_FILE

# Print a success message
echo "Configuration file '$CONF_FILE' created" >> $LOG_FILE
cat $CONF_FILE


#allow ports
ufw allow http > /dev/null 2>&1
ufw allow https > /dev/null 2>&1
ufw allow smtp > /dev/null 2>&1
ufw allow imaps > /dev/null 2>&1
ufw allow 587 > /dev/null 2>&1
ufw allow 465 > /dev/null 2>&1
ufw allow ssh > /dev/null 2>&1

ufw --force enable

echo "Ufw enabled and ports allowed" >> $LOG_FILE

sudo apt-get update -y

echo "System updated"