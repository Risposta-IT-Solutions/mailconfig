#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Parameters
MYSQL_PACKAGE="mysql-server"
POSTFIX_PACKAGES="postfix postfix-mysql"
DOVECOT_PACKAGES="dovecot-core dovecot-imapd dovecot-mysql"

# Function to install Postfix, Dovecot, and MySQL
install_services() {
    echo "Updating package list..." > /home/logs/step2.log
    apt-get update -y

    # Set DEBIAN_FRONTEND to noninteractive to avoid popups
    export DEBIAN_FRONTEND=noninteractive

    echo "Installing Postfix, Dovecot, and MySQL..." >> /home/logs/step2.log
    apt-get install -y \
        $POSTFIX_PACKAGES \
        $DOVECOT_PACKAGES \
        $MYSQL_PACKAGE

    echo "Postfix, Dovecot, and MySQL have been installed successfully!" >> /home/logs/step2.log
}

# Function to remove Postfix, Dovecot, and MySQL
reset_services() {
    echo "Purging Postfix, Dovecot, and MySQL..." > /home/logs/step2.log
    apt-get purge -y \
        $POSTFIX_PACKAGES \
        $DOVECOT_PACKAGES \
        $MYSQL_PACKAGE

    echo "Removing unnecessary dependencies..." >> /home/logs/step2.log
    apt-get autoremove -y
    apt-get autoclean

    echo "Postfix, Dovecot, and MySQL have been successfully removed!" >> /home/logs/step2.log
}

# Check the passed argument (install or reset)
if [[ "$1" == "r" ]]; then
    reset_services
else
    install_services
fi
