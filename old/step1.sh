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
    echo "Updating package list..." > /home/logs/step1.log
    apt-get update -y

    echo "Installing PHP $PHP_VERSION and modules..." >> /home/logs/step1.log
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


    if [ $? -ne 0 ]; then
        echo "An error occurred while installing PHP $PHP_VERSION and its modules!" >> /home/logs/step1.log
        exit 1
    fi

    echo "PHP $PHP_VERSION and its modules have been installed successfully!" >> /home/logs/step1.log
    php$PHP_VERSION -v
}

# Function to remove PHP 8.1 and its modules
reset_php() {
    echo "Purging PHP $PHP_VERSION and its modules..." > /home/logs/step1.log
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

    echo "Removing unnecessary dependencies..." >> /home/logs/step1.log
    apt-get autoremove -y
    apt-get autoclean

    if [ $? -ne 0 ]; then
        echo "An error occurred while removing PHP $PHP_VERSION and its modules!" >> /home/logs/step1.log
        exit 1
    fi

    echo "PHP $PHP_VERSION and its modules have been successfully removed!" >> /home/logs/step1.log
}

# Check the passed argument (install or reset)
if [[ "$1" == "r" ]]; then
    reset_php
else
   install_php
fi
