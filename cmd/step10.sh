#!/bin/bash

# Restart Postfix and Dovecot services
echo "Restarting Postfix and Dovecot services..."
sudo systemctl restart postfix dovecot

# Check if the services were restarted successfully
if systemctl is-active --quiet postfix && systemctl is-active --quiet dovecot; then
  echo "Postfix and Dovecot services restarted successfully."
else
  echo "Failed to restart Postfix or Dovecot services."
  exit 1
fi

# Change permissions of Dovecot log files to 0777
echo "Changing permissions of Dovecot log files..."
sudo chmod 0777 /var/log/dovecot.log /var/log/dovecot-info.log /var/log/dovecot-debug.log

# Confirm permissions were changed
if [ $? -eq 0 ]; then
  echo "Permissions changed successfully for Dovecot log files."
else
  echo "Failed to change permissions for Dovecot log files."
  exit 1
fi
