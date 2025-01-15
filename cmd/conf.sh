#!/bin/bash

# Check if the required parameters are provided
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <domain> <prefix> <company> <environment> <display_name>"
  exit 1
fi

# Get the parameters
DOMAIN="$1"
PREFIX="$2"
COMPANY="$3"
ENVIRONMENT="$4"
DISPLAY_NAME="${5:-$PREFIX}"
CONF_FILE="/home/config.env"
LOG_FILE="/home/jenkins.log"

# Create or overwrite the configuration file
echo "DOMAIN='$DOMAIN'" > $CONF_FILE
echo "PREFIX='$PREFIX'" >> $CONF_FILE
echo "COMPANY='$COMPANY'" >> $CONF_FILE
echo "LOG_FILE='$LOG_FILE'" >> $CONF_FILE
echo "ENVIRONMENT='$ENVIRONMENT'" >> $CONF_FILE
echo "DISPLAY_NAME='$DISPLAY_NAME'" >> $CONF_FILE

# Print a success message
echo "Configuration file '$CONF_FILE' created" > $LOG_FILE

cat $CONF_FILE

#empty the log file
truncate -s 0 $LOG_FILE

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

sudo apt-get update -y > /dev/null 2>&1

echo "System updated"