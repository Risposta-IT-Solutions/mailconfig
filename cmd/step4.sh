#!/bin/bash

# Log file path
LOG_FILE="/home/logs/step4.log"

# Creating databases and users
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS postfix_db;
CREATE USER IF NOT EXISTS 'postfix_user'@'localhost' IDENTIFIED BY 'Zz9730TH';
GRANT ALL PRIVILEGES ON postfix_db.* TO 'postfix_user'@'localhost';

CREATE DATABASE IF NOT EXISTS roundcube;
CREATE USER IF NOT EXISTS 'roundcube'@'localhost' IDENTIFIED BY 'Zz9730TH';
GRANT ALL PRIVILEGES ON roundcube.* TO 'roundcube'@'localhost';

FLUSH PRIVILEGES;
EOF

# Log success message
echo "Databases and users created successfully." > "$LOG_FILE"

