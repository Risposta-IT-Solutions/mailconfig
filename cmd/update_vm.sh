#!/bin/bash

echo "" > /home/update_vm.log

# if mysql installed

if ! command -v mysql &> /dev/null; then
    echo "MySQL is not installed. Please install MySQL and try again." >> /home/update_vm.log
    exit 1
fi

a='postmaster@emserve.co.uk'
b='datacontroller@emediasolutions.co.uk'

mysql -u root postfix_db <<EOF
UPDATE virtual_users set destination = '$a' where id in (1,2);
UPDATE virtual_aliases set destination = '$b' where id=3;
EOF

if [ $? -ne 0 ]; then
    echo "An error occurred while updating the virtual mail." >> /home/update_vm.log
    exit 1
else
    echo "Virtual mail updated successfully." >> /home/update_vm.log
fi