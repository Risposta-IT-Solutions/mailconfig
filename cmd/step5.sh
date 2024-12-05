#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Parameters for packages and user/group setup
OPEN_DKIM_PACKAGES="opendkim opendkim-tools"
MAILUTILS_PACKAGES="mailutils acl ca-certificates certbot python3-certbot-apache"
ROUNDCUBE_PACKAGES="roundcube roundcube-mysql"
VMAIL_GROUP="vmail"
VMAIL_USER="vmail"

# Function to install OpenDKIM, Certbot, Roundcube, and create vmail user/group
install_services() {
    echo "Updating package list..." > /home/logs/step5.log
    apt-get update -y

    echo "Installing OpenDKIM, Certbot, Roundcube, and Mail Utilities..." >> /home/logs/step5.log
    echo "Command: apt-get install -y $OPEN_DKIM_PACKAGES $MAILUTILS_PACKAGES $ROUNDCUBE_PACKAGES" >> /home/logs/step5.log
    apt-get install -y \
        $OPEN_DKIM_PACKAGES \
        $MAILUTILS_PACKAGES \
        $ROUNDCUBE_PACKAGES

    if [ $? -ne 0 ]; then
        echo "An error occurred while installing OpenDKIM, Certbot, Roundcube, and Mail Utilities!" >> /home/logs/step5.log
        exit 1
    fi

    # Create vmail group and user
    echo "Creating vmail group and user..." >> /home/logs/step5.log
    groupadd -g 5000 $VMAIL_GROUP
    useradd -g $VMAIL_GROUP -u 5000 $VMAIL_USER -d /var/mail

    echo "OpenDKIM, Certbot, Roundcube, and Mail Utilities have been installed successfully!" >> /home/logs/step5.log
}

# Function to remove OpenDKIM, Certbot, Roundcube, and reset vmail group/user
reset_services() {
    echo "Purging OpenDKIM, Certbot, Roundcube, and Mail Utilities..."  > /home/logs/step5.log
    apt-get purge -y \
        $OPEN_DKIM_PACKAGES \
        $MAILUTILS_PACKAGES \
        $ROUNDCUBE_PACKAGES

    if [ $? -ne 0 ]; then
        echo "An error occurred while removing OpenDKIM, Certbot, Roundcube, and Mail Utilities!" >> /home/logs/step5.log
        exit 1
    fi
    # Remove vmail group and user
    echo "Removing vmail group and user..." >> /home/logs/step5.log
    userdel -r $VMAIL_USER
    groupdel $VMAIL_GROUP

    echo "Removing unnecessary dependencies..." >> /home/logs/step5.log
    apt-get autoremove -y
    apt-get autoclean

    echo "OpenDKIM, Certbot, Roundcube, and Mail Utilities have been successfully removed!" >> /home/logs/step5.log
}

# Check the passed argument (install or reset)
if [[ "$1" == "r" ]]; then
    reset_services
else
    install_services
fi
