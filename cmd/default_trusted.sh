#!/bin/bash

LOG_FILE="/home/default_trusted.log"
echo "" > "$LOG_FILE"

TRUSTED_HOSTS_FILE="/etc/opendkim/TrustedHosts"
OPENDKIM_CONF="/etc/opendkim.conf"

# Hosts to add
DEFAULT_HOSTS=(
  "127.0.0.1"  # IPv4 localhost
  "::1"        # IPv6 localhost
)

# Check if the TrustedHosts file exists
if [ ! -f "$TRUSTED_HOSTS_FILE" ]; then
  echo "File $TRUSTED_HOSTS_FILE does not exist. Creating it..."  >> "$LOG_FILE"
  
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
    echo "Failed to set permissions on $TRUSTED_HOSTS_FILE." >> "$LOG_FILE"
    exit 1
  else
    echo "Permissions set on $TRUSTED_HOSTS_FILE." >> "$LOG_FILE"
  fi

  chmod 640 "$TRUSTED_HOSTS_FILE"

  if [ $? -ne 0 ]; then
    echo "Failed to set permissions on $TRUSTED_HOSTS_FILE." >> "$LOG_FILE"
    exit 1
  else
    echo "Permissions set on $TRUSTED_HOSTS_FILE." >> "$LOG_FILE"
  fi

  echo "$TRUSTED_HOSTS_FILE created and initialized with default entries." >> "$LOG_FILE"
else
  echo "File $TRUSTED_HOSTS_FILE exists. Ensuring required hosts are present..." >> "$LOG_FILE"
  
  # Add missing entries
  for host in "${DEFAULT_HOSTS[@]}"; do
    if ! grep -q "^$host$" "$TRUSTED_HOSTS_FILE"; then
      echo "$host" >> "$TRUSTED_HOSTS_FILE"
      echo "$host added to $TRUSTED_HOSTS_FILE." >> "$LOG_FILE"
    else
      echo "$host is already in $TRUSTED_HOSTS_FILE." >> "$LOG_FILE"
    fi
  done
fi

# Ensure ExternalIgnoreList and InternalHosts exist in /etc/opendkim.conf
echo "Checking OpenDKIM configuration..." >> "$LOG_FILE"

if ! grep -qxF "ExternalIgnoreList $TRUSTED_HOSTS_FILE" "$OPENDKIM_CONF"; then
  echo "ExternalIgnoreList $TRUSTED_HOSTS_FILE" >> "$OPENDKIM_CONF"
  echo "Added ExternalIgnoreList to $OPENDKIM_CONF." >> "$LOG_FILE"
else
  echo "ExternalIgnoreList is already set in $OPENDKIM_CONF." >> "$LOG_FILE"
fi

if ! grep -qxF "InternalHosts $TRUSTED_HOSTS_FILE" "$OPENDKIM_CONF"; then
  echo "InternalHosts $TRUSTED_HOSTS_FILE" >> "$OPENDKIM_CONF"
  echo "Added InternalHosts to $OPENDKIM_CONF." >> "$LOG_FILE"
else
  echo "InternalHosts is already set in $OPENDKIM_CONF." >> "$LOG_FILE"
fi

# Restart OpenDKIM service
echo "Restarting OpenDKIM service..." >> "$LOG_FILE"
systemctl restart opendkim

if [ $? -eq 0 ]; then
  echo "OpenDKIM restarted successfully." >> "$LOG_FILE"
else
  echo "Failed to restart OpenDKIM." >> "$LOG_FILE"
  exit 1
fi

echo "Trusted hosts configuration and OpenDKIM setup are complete." >> "$LOG_FILE"
exit 0