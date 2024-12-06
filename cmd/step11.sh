#!/bin/bash

# Restart Postfix and Dovecot services
echo "Restarting Postfix and Dovecot services..." > /home/logs/step11.log
sudo systemctl restart postfix dovecot

# Check if the services were restarted successfully
if systemctl is-active --quiet postfix && systemctl is-active --quiet dovecot; then
  echo "Postfix and Dovecot services restarted successfully." >> /home/logs/step11.log 
else
  echo "Failed to restart Postfix or Dovecot services." >> /home/logs/step11.log
  exit 1
fi

