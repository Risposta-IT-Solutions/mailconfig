#!/bin/bash

echo ""> /home/default_trusted.log

TRUSTED_HOSTS_FILE="/etc/opendkim/TrustedHosts"

# Hosts to add
DEFAULT_HOSTS=(
  "127.0.0.1"  # IPv4 localhost
  "::1"        # IPv6 localhost
)

# Check if the file exists
if [ ! -f "$TRUSTED_HOSTS_FILE" ]; then
  echo "File $TRUSTED_HOSTS_FILE does not exist. Creating it..."  >> /home/default_trusted.log
  
  # Create the file with default entries
  {
    echo "# OpenDKIM Trusted Hosts"
    echo "# The local machine"
    for host in "${DEFAULT_HOSTS[@]}"; do
      echo "$host"
    done
  } > "$TRUSTED_HOSTS_FILE"

  # Set correct permissions
  chown opendkim:opendkim "$TRUSTED_HOSTS_FILE"

  if [ $? -ne 0 ]; then
    echo "Failed to set permissions on $TRUSTED_HOSTS_FILE." >> /home/default_trusted.log
    exit 1
  else
    echo "Permissions set on $TRUSTED_HOSTS_FILE." >> /home/default_trusted.log
  fi

  chmod 640 "$TRUSTED_HOSTS_FILE"

  if [ $? -ne 0 ]; then
    echo "Failed to set permissions on $TRUSTED_HOSTS_FILE." >> /home/default_trusted.log
    exit 1
  else
    echo "Permissions set on $TRUSTED_HOSTS_FILE." >> /home/default_trusted.log
  fi

  echo "$TRUSTED_HOSTS_FILE created and initialized with default entries." >> /home/default_trusted.log
else
  echo "File $TRUSTED_HOSTS_FILE exists. Ensuring required hosts are present..." >> /home/default_trusted.log
  
  # Add missing entries
  for host in "${DEFAULT_HOSTS[@]}"; do
    if ! grep -q "^$host$" "$TRUSTED_HOSTS_FILE"; then
      echo "$host" >> "$TRUSTED_HOSTS_FILE"
      echo "$host added to $TRUSTED_HOSTS_FILE." >> /home/default_trusted.log
    else
      echo "$host is already in $TRUSTED_HOSTS_FILE." >> /home/default_trusted.log
    fi
  done
fi

echo "Trusted hosts configuration is complete." >> /home/default_trusted.log

exit 0
