source /home/config.env

sudo apt install -y postfix postfix-mysql

if [ $? -ne 0 ]; then
  echo "An error occurred while installing Postfix!" >> $LOG_FILE
  exit 1
fi

echo "Postfix has been installed successfully!" >> $LOG_FILE

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

sudo apt-get install -y roundcube roundcube-mysql

if [ $? -ne 0 ]; then
  echo "An error occurred while installing Roundcube!" >> $LOG_FILE
  exit 1
fi

echo "Roundcube has been installed successfully!" >> $LOG_FILE

sudo groupadd -g 5000 vmail

if [ $? -ne 0 ]; then
  echo "An error occurred while creating the vmail group!" >> $LOG_FILE
  exit 1
fi

echo "The vmail group has been created successfully!" >> $LOG_FILE

sudo useradd -g vmail -u 5000 vmail -d /var/mail

if [ $? -ne 0 ]; then
  echo "An error occurred while creating the vmail user!" >> $LOG_FILE
  exit 1
fi

echo "The vmail user has been created successfully!" >> $LOG_FILE

#rename the default configuration file
cd /home/mailconfig/

# Define the target directory
TARGET_DIR="./sample"

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

sudo mkdir -p /etc/opendkim/keys/$DOMAIN

if [ $? -ne 0 ]; then
  echo "An error occurred while creating the DKIM directory!" >> $LOG_FILE
  exit 1
fi

echo "The DKIM directory has been created successfully!" >> $LOG_FILE


cd /etc/opendkim/keys/$DOMAIN && sudo opendkim-genkey -s mail -d bluehawkcreative.co.uk

if [ $? -ne 0 ]; then
  echo "An error occurred while generating the DKIM keys!" >> $LOG_FILE
  exit 1
fi

echo "The DKIM keys have been generated successfully!" >> $LOG_FILE


sudo certbot --apache -d mail.$DOMAIN -d smtp.$DOMAIN -d imap.$DOMAIN --email "$PREFIX@$DOMAIN" --agree-tos --non-interactive

if [ $? -ne 0 ]; then
  echo "An error occurred while obtaining an SSL certificate for mail.$DOMAIN, smtp.$DOMAIN, and imap.$DOMAIN." >> $LOG_FILE
  exit 1
fi

echo "SSL certificate obtained successfully for mail.$DOMAIN, smtp.$DOMAIN, and imap.$DOMAIN." >> $LOG_FILE

a2ensite webmail.bluehawkcreative.co.uk

if [ $? -ne 0 ]; then
  echo "An error occurred while enabling the Apache site for webmail.$DOMAIN." >> $LOG_FILE
  exit 1
fi

echo "Apache site enabled successfully for webmail.$DOMAIN." >> $LOG_FILE

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

# sudo mkdir -p /var/mail/vhosts/bluehawkcreative.co.uk/paul
# sudo maildirmake.dovecot /var/mail/vhosts/bluehawkcreative.co.uk/paul
# sudo chown -R vmail:vmail /var/mail/vhosts/bluehawkcreative.co.uk/paul
# sudo maildirmake.dovecot /var/mail/vhosts/bluehawkcreative.co.uk/root
# sudo chown -R vmail:vmail /var/mail/vhosts/bluehawkcreative.co.uk/root

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

echo "Setup completed successfully!" >> $LOG_FILE