#!/bin/bash
# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
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
userdel -rf "$VMAILNAME" &> /dev/null
groupdel -f "$VMAILNAME" &> /dev/null

# create the user
echo "Creating the VMAILUSER"
groupadd "$VMAILNAME" -g "$VMAILGID"
useradd "$VMAILNAME" -u "$VMAILUID" -g "$VMAILGID"

# create the storage folder
echo "Creating the mail storage and setting perms"
mkdir -p "$VMAILSTORAGE" &> /dev/null
chown -R "$VMAILUID:$VMAILGID" "$VMAILSTORAGE"
find "$VMAILSTORAGE" -type f -exec chmod 0660 {} \;
find "$VMAILSTORAGE" -type d -exec chmod 0770 {} \;
