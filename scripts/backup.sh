#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Create a backup of all config files and folders in /var/backups/mailad/ as a tar.gz
#   - At the end it will update the file /var/lib/mailad/bkpfile and will write inside
#     the full path of the backup file 

# some local vars
FOLDERS="/etc/postfix /etc/dovecot /etc/mailad /etc/ssl/certs/mail* /etc/ssl/private/mail* /etc/amavis /etc/clamav/"
BKPFOLDER="/var/backups/mailad"
LIBFOLDER="/var/lib/mailad"
LASTBACKUPFILE="${LIBFOLDER}/latest_backup"
LASTWORKINGBACKUPFILE="${LIBFOLDER}/latest_working_backup"

# advice
echo "===> Starting a backup of all actual configs to $BKPFOLDER"

# create the backup folder 
mkdir -p ${BKPFOLDER} 2> /dev/null || exit 0
mkdir -p ${LIBFOLDER} 2> /dev/null || exit 0

# check if a non ideal backup is left behind
if [ -f "$LASTBACKUPFILE" ] ; then
    #use cases
    if [ -f "$LASTWORKINGBACKUPFILE" ] ; then
        # case one: backup & working backup
        # erase it only if points to different files
        LAST=`cat "$LASTBACKUPFILE"`
        WORKING=`cat "$LASTWORKINGBACKUPFILE"`
        if [ "$LAST" != "$WORKING" ] ; then
            # erase the file
            rm -f "$LAST" || exit 0
        fi
    else
        # case two: backup & no working backup, erase the file
        rm -f `cat "$LASTBACKUPFILE"` || exit 0
    fi
fi

# create the backup
TIMESTAMP=`date +%Y%m%d_%H%M%S`
BKPFILE="${BKPFOLDER}/${TIMESTAMP}.tar.gz"
tar -cvzf ${BKPFILE} ${FOLDERS}

# secure the file
chown root:root ${BKPFILE}
chmod 0440 ${BKPFILE}

# set the lib file
echo "${BKPFILE}" > "${LASTBACKUPFILE}"

# show the properties
echo "===> Your backup is on: ${BKPFILE}"
