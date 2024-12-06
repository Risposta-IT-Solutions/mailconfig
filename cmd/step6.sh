#!/bin/bash
echo "Installing Roundcube with predefined inputs" > /home/lgs/step6.log
# Exit script on any error
set -e

# Set non-interactive frontend for apt
export DEBIAN_FRONTEND=noninteractive

# Predefine inputs for Roundcube installation
# Replace the values with your actual database credentials
DB_ROOT_PASSWORD="Zz9730TH"
DB_NAME="roundcube"
DB_USER="roundcube"
DB_PASSWORD="Zz9730TH"

# Preconfigure MySQL root password to avoid prompts
echo "mysql-server mysql-server/root_password password $DB_ROOT_PASSWORD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DB_ROOT_PASSWORD" | debconf-set-selections

# Preconfigure Roundcube database settings
echo "roundcube-core roundcube/dbconfig-install boolean true" | debconf-set-selections
echo "roundcube-core roundcube/mysql/admin-pass password $DB_ROOT_PASSWORD" | debconf-set-selections
echo "roundcube-core roundcube/mysql/app-pass password $DB_PASSWORD" | debconf-set-selections
echo "roundcube-core roundcube/app-password-confirm password $DB_PASSWORD" | debconf-set-selections
echo "roundcube-core roundcube/database-type select mysql" | debconf-set-selections
echo "roundcube-core roundcube/mysql/admin-user string root" | debconf-set-selections

echo "Predefined inputs configured. Starting installation..." >> /home/lgs/step6.log

# Update the package list
apt update -y

# Install Roundcube and MySQL dependency
apt install -y roundcube roundcube-mysql

if [ $? -ne 0 ]; then
  echo "Failed to install Roundcube and MySQL dependency" >> /home/lgs/step6.log
  exit 1
fi

# Restart Apache to apply changes
systemctl restart apache2

if [ $? -ne 0 ]; then
  echo "Failed to restart Apache" >> /home/lgs/step6.log
  exit 1
fi

# Print success message
echo "Roundcube installation with predefined inputs completed successfully!" >> /home/lgs/step6.log
