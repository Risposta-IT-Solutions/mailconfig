#!/bin/bash
echo "Securing MySQL installation..." > /home/logs/step3.log
# Check if expect is installed
if ! command -v expect &>/dev/null; then
  echo "'expect' is not installed. Installing now..." >> /home/logs/step3.log
  if sudo apt update && sudo apt install -y expect; then
    echo "'expect' installed successfully." >> /home/logs/step3.log
  else
    echo "Failed to install 'expect'. Please install it manually and try again." >> /home/logs/step3.log
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

echo "MySQL secure installation completed with predefined responses." > /home/logs/step3.log
