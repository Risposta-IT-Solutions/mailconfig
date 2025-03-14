#!/bin/bash
set -e  # Exit immediately on error

# Check if required parameters are provided
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <domain> <prefix> <company> <environment> <display_name>"
  exit 1
fi

# Get the parameters
DOMAIN="$1"
PREFIX="$2"
COMPANY="$3"
ENVIRONMENT="$4"
DISPLAY_NAME="${5:-$PREFIX}"
CONF_FILE="/home/config.env"
LOG_FILE="/home/jenkins.log"

# Create or overwrite the configuration file safely
printf "DOMAIN=\"%s\"\nPREFIX=\"%s\"\nCOMPANY=\"%s\"\nLOG_FILE=\"%s\"\nENVIRONMENT=\"%s\"\nDISPLAY_NAME=\"%s\"\n" \
    "$DOMAIN" "$PREFIX" "$COMPANY" "$LOG_FILE" "$ENVIRONMENT" "$DISPLAY_NAME" > "$CONF_FILE"

# Print success message
echo "Configuration file '$CONF_FILE' created" >> "$LOG_FILE"
cat "$CONF_FILE"

# Empty the log file safely
truncate -s 0 "$LOG_FILE" || { echo "Error: Failed to clear log file" >&2; exit 1; }

# Allow necessary ports using UFW (firewall)
ufw allow http > /dev/null 2>&1
ufw allow https > /dev/null 2>&1
ufw allow smtp > /dev/null 2>&1
ufw allow imaps > /dev/null 2>&1
ufw allow 587 > /dev/null 2>&1
ufw allow 465 > /dev/null 2>&1
ufw allow ssh > /dev/null 2>&1

# Enable UFW (force mode)
ufw --force enable || { echo "Error: Failed to enable UFW" >&2; exit 1; }

echo "UFW enabled and ports allowed" >> "$LOG_FILE"

# Update the system safely
sudo apt-get update -y > /dev/null 2>&1 || { echo "Error: System update failed" >&2; exit 1; }

echo "System updated" >> "$LOG_FILE"