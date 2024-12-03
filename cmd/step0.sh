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

# Define the configuration file path
CONF_FILE="/home/config.env"

# Create or overwrite the configuration file
echo "DOMAIN=$DOMAIN" > $CONF_FILE
echo "PREFIX=$PREFIX" >> $CONF_FILE
echo "COMPANY=$COMPANY" >> $CONF_FILE

# Print a success message
echo "Configuration file '$CONF_FILE' created with the following content:"
cat $CONF_FILE
