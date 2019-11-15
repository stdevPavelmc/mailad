#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
#
# Goals:
#   - Create the vmail user

# locate the source file (makefile or run by hand)
if [ -f mailad.conf ] ; then 
    source mailad.conf
else
    source ../mailad.conf
fi

# force the removal in any case
sudo userdel -rf "$VMAILNAME" &> /dev/null
sudo groupdel -f "$VMAILNAME" &> /dev/null

# create the user
echo "Creating the VMAILUSER"
sudo groupadd "$VMAILNAME" -g "$VMAILGID"
sudo useradd "$VMAILNAME" -u "$VMAILUID" -g "$VMAILGID"

# create the storage folder
echo "Creating the mail storage and setting perms"
sudo mkdir -p "$VMAILSTORAGE" &> /dev/null
sudo chown -R "$VMAILUID:$VMAILGID" "$VMAILSTORAGE"
sudo find "$VMAILSTORAGE" -type f -exec chmod 0660 {} \;
sudo find "$VMAILSTORAGE" -type d -exec chmod 0770 {} \;
