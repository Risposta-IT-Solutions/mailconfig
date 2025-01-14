#!/bin/bash

(cd /home/mailconfig/cmd/ && ./status.sh "in_progress")

LOG_FILE="/home/jenkins.log"

# Check if the configuration file exists
if [[ ! -f "$LOG_FILE" ]]; then
    touch "$LOG_FILE"
fi

# Check if IPv6 is already disabled
ipv6_status=$(sysctl net.ipv6.conf.all.disable_ipv6 | awk '{print $3}')
if [[ $ipv6_status -eq 1 ]]; then
    echo "IPv6 is already disabled" >> $LOG_FILE
    exit 0
fi

echo "IPv6 is enabled. Disabling now..." >> $LOG_FILE

# Disable IPv6 temporarily
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1

# Persist the changes in /etc/sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf

# Check if /etc/sysctl.d/99-sysctl.conf exists, and append configuration if it does
if [[ -f /etc/sysctl.d/99-sysctl.conf ]]; then
    echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf
else
    echo "File /etc/sysctl.d/99-sysctl.conf does not exist. Skipping..." >> $LOG_FILE
    echo "Failed to disable IPv6." >> $LOG_FILE
    exit 1
fi

# Reload sysctl settings without rebooting
sudo sysctl -p

sudo systemctl restart networking

# Log the successful disable of IPv6
echo "IPv6 disabled successfully." >> $LOG_FILE
