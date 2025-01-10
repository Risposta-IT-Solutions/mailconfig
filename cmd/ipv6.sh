#!/bin/bash

source /home/config.env

# Check if IPv6 is enabled
ipv6_status=$(sysctl net.ipv6.conf.all.disable_ipv6 | awk '{print $3}')
if [[ $ipv6_status -eq 1 ]]; then
    echo "IPv6 is already disabled."
    exit 0
fi

echo "IPv6 is enabled. Disabling now..." >> $LOG_FILE

# Disable IPv6
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1

# Persist the changes in /etc/sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf

if [[ -f /etc/sysctl.d/99-sysctl.conf ]]; then
    echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf
else
   echo "File /etc/sysctl.d/99-sysctl.conf does not exist. Skipping..." >> $LOG_FILE
   echo "Failed to disable IPv6." >> $LOG_FILE
   exit 1
fi

echo "IPv6 disabled successfully." >> $LOG_FILE
# Reboot the system
echo "Rebooting the system in 1 minute to apply changes..." >> $LOG_FILE

sudo shutdown -r +1 
