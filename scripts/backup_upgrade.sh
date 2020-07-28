#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
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
BKPFOLDER="/var/backups/mailad"

# advice
echo "===> Starting a backup of all actual configs to $BKPFOLDER"

# create the backup folder 
mkdir -p /var/backups/mailad 2> /dev/null || exit 0

# create the backup
TIMESTAMP=`date +%Y%m%d_%H%M%S`
tar -cvzf /var/backups/mailad/${TIMESTAMP}.tar.gz ${FOLDERS}
# secure the file
chown root:root /var/backups/mailad/${TIMESTAMP}.tar.gz
chmod 0440 /var/backups/mailad/${TIMESTAMP}.tar.gz

# show the properties
echo "===> Your backup is on: ${BKPFOLDER}/${TIMESTAMP}.tar.gz"

# remove old install
make install-purge

# force a re-provision
make force-provision

# extract some user modified files
echo "===> Extracting custom domain files from the backup: ${BKPFOLDER}/${TIMESTAMP}.tar.gz"
cd / && tar -zvxf ${BKPFOLDER}/${TIMESTAMP}.tar.gz etc/postfix/aliases/alias_virtuales
cd / && tar -zvxf ${BKPFOLDER}/${TIMESTAMP}.tar.gz etc/postfix/rules/body_checks
cd / && tar -zvxf ${BKPFOLDER}/${TIMESTAMP}.tar.gz etc/postfix/rules/header_checks
cd / && tar -zvxf ${BKPFOLDER}/${TIMESTAMP}.tar.gz etc/postfix/rules/lista_negra

# postmap to the alias virtuales & reload postfix
cd /etc/postfix
postmap aliases/alias_virtuales
postmap rules/lista_negra
postfix reload
