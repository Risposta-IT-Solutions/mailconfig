#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Parameters
PHP_VERSION="8.1"

# Function to install PHP 8.1 and its modules
install_php() {
    echo "Updating package list..."
    apt-get update -y

    echo "Installing PHP $PHP_VERSION and modules..."
    apt-get install -y \
        php$PHP_VERSION \
        php$PHP_VERSION-common \
        php$PHP_VERSION-cli \
        php$PHP_VERSION-fpm \
        php$PHP_VERSION-mbstring \
        php$PHP_VERSION-xml \
        php$PHP_VERSION-curl \
        php$PHP_VERSION-zip \
        php$PHP_VERSION-gd \
        php$PHP_VERSION-intl \
        php$PHP_VERSION-soap \
        php$PHP_VERSION-opcache \
        php$PHP_VERSION-readline \
        php$PHP_VERSION-mysql \
        libapache2-mod-php$PHP_VERSION

    # Verify installation
    echo "PHP $PHP_VERSION and its modules have been installed successfully!"
    php$PHP_VERSION -v
}

# Function to remove PHP 8.1 and its modules
reset_php() {
    echo "Purging PHP $PHP_VERSION and its modules..."
    apt-get purge -y \
        php$PHP_VERSION \
        php$PHP_VERSION-common \
        php$PHP_VERSION-cli \
        php$PHP_VERSION-fpm \
        php$PHP_VERSION-mbstring \
        php$PHP_VERSION-xml \
        php$PHP_VERSION-curl \
        php$PHP_VERSION-zip \
        php$PHP_VERSION-gd \
        php$PHP_VERSION-intl \
        php$PHP_VERSION-soap \
        php$PHP_VERSION-opcache \
        php$PHP_VERSION-readline \
        php$PHP_VERSION-mysql \
        libapache2-mod-php$PHP_VERSION

    echo "Removing unnecessary dependencies..."
    apt-get autoremove -y
    apt-get autoclean

    echo "PHP $PHP_VERSION and its modules have been successfully removed!"
}

# Check the passed argument (install or reset)
if [[ "$1" == "r" ]]; then
    reset_php
else
   install_php
fi
