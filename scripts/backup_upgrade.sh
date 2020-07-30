#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Check for updates/upgrades and if needed
#   - Create a backup of the postfix and dovecot folders in /var/backups/mailad

# locate the source file (makefile or run by hand)
source /etc/mailad/mailad.conf
if [ -f mailad.conf ] ; then 
    source common.conf
    PATHPREF=$(realpath "./")
else
    source ../common.conf
    PATHPREF=$(realpath "../")
fi

# Control services, argument $1 is the action (start/stop)
function services() {
    for s in `echo $SERVICENAMES | xargs` ; do
        # do it
        echo "Doing $1 with $s..."
        systemctl --no-pager $1 $s
        sleep 2
        systemctl --no-pager status $s
    done
}

# move to the mailad root to work on
cd $PATHPREF

# some local vars
FOLDERS="/etc/postfix /etc/dovecot /etc/mailad"
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

# stoping services
services stop

# remove old install
make install-purge

# force a re-provision
make all

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

# restarting services
services start
