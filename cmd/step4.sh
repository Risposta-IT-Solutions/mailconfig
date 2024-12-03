#!/bin/bash

DB_NAME="postfix_db"
DB_USER="postfix_user"
DB_PASSWORD="Zz9730TH"

mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

echo "Database '$DB_NAME' and user '$DB_USER' created successfully." > /home/step4.log
