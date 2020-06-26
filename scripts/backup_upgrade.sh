#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
#
# Goal:
#   - Check for updates/upgrades and if needed
#   - Create a backup of the postfix and dovecot folders in /var/backups/mailad

# locate the source file (makefile or run by hand)
if [ -f mailad.conf ] ; then 
    source mailad.conf
    source common.conf
    PATHPREF=$(realpath "./")
else
    source ../mailad.conf
    source ../common.conf
    PATHPREF=$(realpath "../")
fi

# move to the mailad root to work on
cd $PATHPREF

# some local vars
FOLDERS="/etc/postfix /etc/dovecot"
BKPFOLDER="/var/backups/mailad/"

# advice
echo "===> Starting a backup of all actual configs to $BKPFOLDER"

# create the backup folder 
mkdir -p /var/backups/mailad 2> /dev/null || exit 0

# create the backup
TIMESTAMP=`date +%Y%m%d_%H%M%S`
tar -cvzf /var/backups/mailad/${TIMESTAMP}.tar.gz ${FOLDERS}

# show the properties
echo "===> Your backup is on: ${BKPFOLDER}/${TIMESTAMP}.tar.gz"

# remove old install
make install-purge

# force a re-provision
make force-provision

# extract alias_virtuales
echo "===> Extracting the alias file from the backup: ${BKPFOLDER}/${TIMESTAMP}.tar.gz"
cd / && tar -zvxf ${BKPFOLDER}/${TIMESTAMP}.tar.gz etc/postfix/alias_virtuales

# postmap to the alias virtuales & reload postfix
cd /etc/postfix
postmap alias_virtuales
postfix reload
