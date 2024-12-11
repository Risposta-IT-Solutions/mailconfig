source /home/config.env

#!/bin/bash

# Preconfigure the Postfix options
echo "postfix postfix/main_mailer_type select Internet Site" | sudo debconf-set-selections
echo "postfix postfix/mailname string $(hostname -f)" | sudo debconf-set-selections

# Update package lists
sudo apt-get update -y > /dev/null 2>&1

# Install Postfix and postfix-mysql without prompts
sudo DEBIAN_FRONTEND=noninteractive apt install -y postfix postfix-mysql

if [ $? -ne 0 ]; then
  echo "An error occurred while installing Postfix!" >> $LOG_FILE
  exit 1
fi

# Restart Postfix to apply changes
sudo systemctl restart postfix

if [ $? -ne 0 ]; then
  echo "An error occurred while restarting Postfix!" >> $LOG_FILE
  exit 1
fi

# Enable Postfix to start on boot
sudo systemctl enable postfix

if [ $? -ne 0 ]; then
  echo "An error occurred while enabling Postfix to start on boot!" >> $LOG_FILE
  exit 1
fi

echo "Postfix with postfix-mysql installed and configured as 'Internet Site'." >> $LOG_FILE

apt install -y dovecot-core dovecot-imapd dovecot-mysql

if [ $? -ne 0 ]; then
  echo "An error occurred while installing Dovecot!" >> $LOG_FILE
  exit 1
fi

echo "Dovecot has been installed successfully!" >> $LOG_FILE

apt install -y mysql-server

if [ $? -ne 0 ]; then
  echo "An error occurred while installing MySQL!" >> $LOG_FILE
  exit 1
fi

echo "MySQL has been installed successfully!" >> $LOG_FILE

sudo apt-get install -y opendkim opendkim-tools 

if [ $? -ne 0 ]; then
  echo "An error occurred while installing OpenDKIM!" >> $LOG_FILE
  exit 1
fi

echo "OpenDKIM has been installed successfully!" >> $LOG_FILE


sudo apt-get install -y mailutils acl

if [ $? -ne 0 ]; then
  echo "An error occurred while installing Mailutils!" >> $LOG_FILE
  exit 1
fi

echo "Mailutils has been installed successfully!" >> $LOG_FILE

apt-get install -y php8.1 php8.1-common php8.1-cli php8.1-fpm php8.1-mbstring php8.1-xml php8.1-curl php8.1-zip php8.1-gd php8.1-intl php8.1-soap php8.1-opcache php8.1-readline php8.1-mysql ca-certificates certbot python3-certbot-apache opendkim opendkim-tools libapache2-mod-php

if [ $? -ne 0 ]; then
  echo "An error occurred while installing PHP!" >> $LOG_FILE
  exit 1
fi

echo "PHP has been installed successfully!" >> $LOG_FILE

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

echo "Predefined inputs configured. Starting installation..." >> $LOG_FILE

# Update the package list
apt update -y

# Install Roundcube and MySQL dependency
apt install -y roundcube roundcube-mysql

if [ $? -ne 0 ]; then
  echo "Failed to install Roundcube and MySQL dependency" >> $LOG_FILE
  exit 1
fi

# Restart Apache to apply changes
systemctl restart apache2

if [ $? -ne 0 ]; then
  echo "Failed to restart Apache" >> $LOG_FILE
  exit 1
fi

# Print success message
echo "Roundcube installation with predefined inputs completed successfully!" >> $LOG_FILE

#if not exist groupadd vmail

if ! getent group vmail > /dev/null 2>&1; then
  sudo groupadd -g 5000 vmail
  if [ $? -ne 0 ]; then
    echo "An error occurred while creating the vmail group!" >> $LOG_FILE
    exit 1
  fi
  echo "The vmail group has been created successfully!" >> $LOG_FILE
else
  echo "The vmail group already exists." >> $LOG_FILE
fi

# Create the vmail user if it does not exist
if getent passwd vmail > /dev/null 2>&1; then
  echo "The vmail user already exists." >> $LOG_FILE
else
  sudo useradd -g vmail -u 5000 vmail -d /var/mail
  if [ $? -ne 0 ]; then
    echo "An error occurred while creating the vmail user!" >> $LOG_FILE
    exit 1
  fi
  echo "The vmail user has been created successfully!" >> $LOG_FILE
fi

#rename the default configuration file
cd /home/mailconfig/ || { echo "Directory '/home/mailconfig/' not found"; exit 1; }

# Define the target directory
TARGET_DIR="./sample"

echo "Replacing placeholders in all files in $TARGET_DIR..." >> $LOG_FILE

# Loop through all files in the target directory and replace the placeholder
find "$TARGET_DIR" -type f -exec sed -i \
    -e "s/{{_domain_}}/$DOMAIN/g" \
    -e "s/{{_company_}}/$COMPANY/g" \
    -e "s/{{_prefix_}}/$PREFIX/g" {} +


if [ $? -ne 0 ]; then
  echo "An error occurred while replacing placeholders in files in $TARGET_DIR."
  exit 1
fi

echo "Replaced placeholders in all files in $TARGET_DIR." >> $LOG_FILE

SRC_CONF_FILE="./sample/webmail.{{_domain_}}.conf"
DEST_CONF_FILE="/etc/apache2/sites-available/webmail.$DOMAIN.conf"

SRC_DEF_VHOST_FILE="./sample/000-default.conf"
DEF_VHOST_FILE="/etc/apache2/sites-available/000-default.conf"

SITE_CONF_FILE="/etc/apache2/sites-available/$DOMAIN.conf"
SITE_CONF_SRC="./sample/$DOMAIN.conf"

if [ -f "$SRC_CONF_FILE" ]; then
  echo "Renaming and moving webmail.{{_domain_}}.conf to webmail.$DOMAIN.conf..." >> $LOG_FILE
  sudo cp -rf "$SRC_CONF_FILE" "$DEST_CONF_FILE"
else
  echo "Error: File webmail.{{_domain_}}.conf not found in ./sample/." >> $LOG_FILE
  exit 1
fi

if [ -f "$SITE_CONF_SRC" ]; then
  echo "Renaming and moving $DOMAIN.conf to /etc/apache2/sites-available..." >> $LOG_FILE
  sudo cp -rf "$SITE_CONF_SRC" "$SITE_CONF_FILE"
else
  echo "Error: File $DOMAIN.conf not found in ./sample/." >> $LOG_FILE
  exit 1
fi

if [ -f "$SRC_DEF_VHOST_FILE" ]; then
  echo "Renaming and moving 000-default.conf" >> $LOG_FILE
  sudo cp -rf "$SRC_DEF_VHOST_FILE" "$DEF_VHOST_FILE"
else
  echo "Error: File 000-default.conf not found in ./sample/." >> $LOG_FILE
  exit 1
fi

# Move opendkim.conf to /etc
if [ -f "./sample/opendkim.conf" ]; then
  echo "Copying opendkim.conf to /etc..." >> $LOG_FILE
  sudo cp -rf ./sample/opendkim.conf /etc
else
  echo "Error: File opendkim.conf not found in ./sample/." >> $LOG_FILE
  exit 1
fi

# Move dovecot, roundcube, and postfix directories to /etc
for dir in dovecot roundcube postfix; do
  if [ -d "./sample/$dir" ]; then
    echo "Copying $dir directory to /etc..." >> $LOG_FILE
    sudo cp -rf ./sample/$dir /etc
  else
    echo "Warning: Directory $dir not found in ./sample/." >> $LOG_FILE
    exit 1
  fi
done

echo "Configuration files copied to /etc." >>  $LOG_FILE

sudo mkdir -p /etc/opendkim/keys/$DOMAIN

if [ $? -ne 0 ]; then
  echo "An error occurred while creating the DKIM directory!" >> $LOG_FILE
  exit 1
fi

echo "The DKIM directory has been created successfully!" >> $LOG_FILE


cd /etc/opendkim/keys/$DOMAIN && sudo opendkim-genkey -s mail -d $DOMAIN

if [ $? -ne 0 ]; then
  echo "An error occurred while generating the DKIM keys!" >> $LOG_FILE
  exit 1
fi

echo "The DKIM keys have been generated successfully!" >> $LOG_FILE

a2ensite webmail.$DOMAIN

if [ $? -ne 0 ]; then
  echo "An error occurred while enabling the Apache site for webmail.$DOMAIN." >> $LOG_FILE
  exit 1
fi

echo "Apache site enabled successfully for webmail.$DOMAIN." >> $LOG_FILE

sudo certbot certonly --apache -d mail.$DOMAIN -d smtp.$DOMAIN -d imap.$DOMAIN --email "$PREFIX@$DOMAIN" --agree-tos --non-interactive

if [ $? -ne 0 ]; then
  echo "An error occurred while obtaining an SSL certificate for mail.$DOMAIN, smtp.$DOMAIN, and imap.$DOMAIN." >> $LOG_FILE
  exit 1
fi

echo "SSL certificate obtained successfully for mail.$DOMAIN, smtp.$DOMAIN, and imap.$DOMAIN." >> $LOG_FILE


systemctl reload apache2

if [ $? -ne 0 ]; then
  echo "An error occurred while reloading Apache!" >> $LOG_FILE
  exit 1
fi

echo "Apache reloaded successfully!" >> $LOG_FILE

sudo certbot --apache -d webmail.$DOMAIN --non-interactive --agree-tos --email "$PREFIX@$DOMAIN" --no-eff-email

if [ $? -ne 0 ]; then
  echo "An error occurred while obtaining an SSL certificate for webmail.$DOMAIN." >> $LOG_FILE
  exit 1
fi

echo "SSL certificate obtained successfully for webmail.$DOMAIN." >> $LOG_FILE

sudo mkdir -p /var/mail/vhosts/$DOMAIN/$PREFIX

if [ $? -ne 0 ]; then
  echo "An error occurred while creating the directory for $PREFIX@$DOMAIN." >> $LOG_FILE
  exit 1
fi

echo "Directory created successfully for $PREFIX@$DOMAIN." >> $LOG_FILE


sudo chown -R vmail:vmail /var/mail/vhosts/$DOMAIN/$PREFIX

if [ $? -ne 0 ]; then
  echo "An error occurred while changing ownership of the directory for $PREFIX@$DOMAIN." >> $LOG_FILE
  exit 1
fi

echo "Ownership changed successfully for $PREFIX@$DOMAIN." >> $LOG_FILE

sudo maildirmake.dovecot /var/mail/vhosts/$DOMAIN/root

if [ $? -ne 0 ]; then
  echo "An error occurred while creating the Maildir for root@$DOMAIN." >> $LOG_FILE
  exit 1
fi

echo "Maildir created successfully for root@$DOMAIN." >> $LOG_FILE

sudo chown -R vmail:vmail /var/mail/vhosts/$DOMAIN/root

if [ $? -ne 0 ]; then
  echo "An error occurred while changing ownership of the Maildir for root@$DOMAIN." >> $LOG_FILE
  exit 1
fi

echo "Ownership changed successfully for root@$DOMAIN." >> $LOG_FILE

mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS postfix_db;
CREATE USER IF NOT EXISTS 'postfix_user'@'localhost' IDENTIFIED BY 'Zz9730TH';
GRANT ALL PRIVILEGES ON postfix_db.* TO 'postfix_user'@'localhost';
FLUSH PRIVILEGES;
EOF

if [ $? -ne 0 ]; then
  echo "An error occurred while creating the database and user for Postfix!" >> $LOG_FILE
  exit 1
fi

echo "Postfix Database and user created successfully!" >> $LOG_FILE

SQL_FILE="/home/mailconfig/sample/postfix_db.sql"

if [ -f "$SQL_FILE" ]; then
  mysql -u root postfix_db< "$SQL_FILE"
  if [ $? -ne 0 ]; then
    echo "An error occurred while importing the Postfix database!" >> $LOG_FILE
    exit 1
  fi
  echo "Postfix database imported successfully."  >> $LOG_FILE
else
  echo "Error: File $SQL_FILE not found." >> $LOG_FILE
  exit 1
fi


if ! command -v expect &>/dev/null; then
  echo "'expect' is not installed. Installing now..." >> $LOG_FILE
  if sudo apt update && sudo apt install -y expect; then
    echo "'expect' installed successfully." >> $LOG_FILE
  else
    echo "Failed to install 'expect'. Please install it manually and try again." >> $LOG_FILE
    exit 1
  fi
fi

# Run mysql_secure_installation with predefined responses
expect <<EOF
spawn mysql_secure_installation

# Set up VALIDATE PASSWORD component
expect "VALIDATE PASSWORD component?" { send "n\r" }

# Remove anonymous users
expect "Remove anonymous users?" { send "y\r" }

# Disallow root login remotely
expect "Disallow root login remotely?" { send "y\r" }

# Remove test database and access to it
expect "Remove test database and access to it?" { send "y\r" }

# Reload privilege tables
expect "Reload privilege tables now?" { send "y\r" }

# End
expect eof
EOF

if [ $? -ne 0 ]; then
  echo "Failed to secure MySQL installation." >> $LOG_FILE
  exit 1
fi

echo "MySQL secure installation completed with predefined responses." >> $LOG_FILE

sudo systemctl restart postfix dovecot

if [ $? -ne 0 ]; then
  echo "An error occurred while restarting Postfix and Dovecot!" >> $LOG_FILE
  exit 1
fi

echo "Postfix and Dovecot restarted successfully!" >> $LOG_FILE

chmod 0777  /var/log/dovecot.log /var/log/dovecot-info.log /var/log/dovecot-debug.log

if [ $? -ne 0 ]; then
  echo "An error occurred while changing permissions for Dovecot logs!" >> $LOG_FILE
  exit 1
fi

echo "Permissions changed successfully for Dovecot logs." >> $LOG_FILE


cd /var/www/ || { echo "Directory '/var/www/' not found"; exit 1; }

git clone https://github.com/dawn-risposta/phpemailer.git mailer || { echo "Failed to clone the phpmailer repository"; exit 1; }

cd mailer/ || { echo "Directory 'mailer/' not found"; exit 1; }

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y composer

if [ $? -ne 0 ]; then
  echo "An error occurred while installing Composer!" >> $LOG_FILE
  exit 1
fi

echo "Composer installed successfully!" >> $LOG_FILE

composer install --no-interaction --quiet

if [ $? -ne 0 ]; then
  echo "An error occurred while installing the PHPMailer dependencies!" >> $LOG_FILE
  exit 1
fi

echo "PHPMailer dependencies installed successfully!" >> $LOG_FILE

a2ensite $DOMAIN.conf  > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "An error occurred while enabling the Apache site for $DOMAIN." >> $LOG_FILE
  exit 1
fi

echo "Apache site enabled successfully for $DOMAIN." >> $LOG_FILE

systemctl reload apache2 > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "An error occurred while reloading Apache!" >> $LOG_FILE
  exit 1
fi

sudo certbot --apache -d $DOMAIN --non-interactive --agree-tos

if [ $? -ne 0 ]; then
  echo "An error occurred while obtaining an SSL certificate for $DOMAIN." >> $LOG_FILE
  exit 1
fi

echo "SSL certificate obtained successfully for $DOMAIN." >> $LOG_FILE

systemctl reload apache2 > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "An error occurred while reloading Apache!" >> $LOG_FILE
  exit 1
fi

echo "Apache reloaded successfully!" >> $LOG_FILE


echo "Setup completed successfully!" >> $LOG_FILE

exit 0