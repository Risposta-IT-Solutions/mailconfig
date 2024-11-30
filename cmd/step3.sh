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
    echo "Updating package list..."
    apt-get update -y

    echo "Installing OpenDKIM, Certbot, Roundcube, and Mail Utilities..."
    apt-get install -y \
        $OPEN_DKIM_PACKAGES \
        $MAILUTILS_PACKAGES \
        $ROUNDCUBE_PACKAGES

    # Create vmail group and user
    echo "Creating vmail group and user..."
    groupadd -g 5000 $VMAIL_GROUP
    useradd -g $VMAIL_GROUP -u 5000 $VMAIL_USER -d /var/mail

    echo "OpenDKIM, Certbot, Roundcube, and Mail Utilities have been installed successfully!"
}

# Function to remove OpenDKIM, Certbot, Roundcube, and reset vmail group/user
reset_services() {
    echo "Purging OpenDKIM, Certbot, Roundcube, and Mail Utilities..."
    apt-get purge -y \
        $OPEN_DKIM_PACKAGES \
        $MAILUTILS_PACKAGES \
        $ROUNDCUBE_PACKAGES

    # Remove vmail group and user
    echo "Removing vmail group and user..."
    userdel -r $VMAIL_USER
    groupdel $VMAIL_GROUP

    echo "Removing unnecessary dependencies..."
    apt-get autoremove -y
    apt-get autoclean

    echo "OpenDKIM, Certbot, Roundcube, and Mail Utilities have been successfully removed!"
}

# Check the passed argument (install or reset)
if [[ "$1" == "i" ]]; then
    install_services
elif [[ "$1" == "r" ]]; then
    reset_services
else
    echo "Usage: $0 {i|r} \n i: install services \n r: reset services"
    exit 1
fi
