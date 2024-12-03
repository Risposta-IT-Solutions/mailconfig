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


#!/bin/bash


LOCK_FILE="/var/lib/dpkg/lock-frontend"

# Function to kill the process holding the lock
release_lock() {
  # Get the PID of the process holding the lock
  LOCK_PID=$(lsof $LOCK_FILE | awk 'NR==2 {print $2}')
  
  if [ -n "$LOCK_PID" ]; then
    echo "Process $LOCK_PID is holding the lock. Killing it..."
    kill -9 $LOCK_PID
    if [ $? -eq 0 ]; then
      echo "Successfully killed process $LOCK_PID."
    else
      echo "Failed to kill process $LOCK_PID. Exiting."
      exit 1
    fi
  else
    echo "No process is holding the lock."
  fi
}

if [ -f "$LOCK_FILE" ]; then
  echo "Lock file detected: $LOCK_FILE"
  release_lock
else
  echo "No lock file detected."
fi


