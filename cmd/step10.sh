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

