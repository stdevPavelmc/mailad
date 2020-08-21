#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Check for updates/upgrades and if needed
#   - Create a backup of the postfix and dovecot folders in /var/backups/mailad

# locate the source file (makefile or run by hand)
source source ./common.conf

# advice
echo "===> Check if we have to upgrade the config"

# upgrade the user's mailad.conf
./scripts/confupgrade.sh

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

# restore a individual files
function extract() {
    # 3 Arguments
    #   1 - backup file full path
    #   2 - file to extract
    #   3 - [optional] alternative path to extract

    BKPFILE="$1"
    FILE="$2"
    ALT="$3"

    # move to root
    cd /

    ISTHERE=`tar -ztf ${BKPFILE} | grep "$FILE" | grep -v .db`
    if [ "$ISTHERE" == "$FILE" ] ; then
        # it's there
        if [ "$ALT" != "" ] ; then
            # place it under $ALT
            tar -zxvf ${BKPFILE} ${FILE}
            mv ${FILE} ${ALT}
            echo "Moved to ${ALT}"
        else
            # place it on the default file path
            tar -zxvf ${BKPFILE} ${FILE}
        fi
    fi
}

# some local vars
FOLDERS="/etc/postfix /etc/dovecot /etc/mailad /etc/ssl/certs/mail* /etc/ssl/private/mail*"
BKPFOLDER="/var/backups/mailad"

# advice
echo "===> Starting a backup of all actual configs to $BKPFOLDER"

# create the backup folder 
mkdir -p ${BKPFOLDER} 2> /dev/null || exit 0

# create the backup
TIMESTAMP=`date +%Y%m%d_%H%M%S`
BKPFILE="${BKPFOLDER}/${TIMESTAMP}.tar.gz"
tar -cvzf ${BKPFILE} ${FOLDERS}

# secure the file
chown root:root ${BKPFILE}
chmod 0440 ${BKPFILE}

# show the properties
echo "===> Your backup is on: ${BKPFILE}"

# stoping services
services stop

# remove old install
make install-purge

# force a re-provision
make all

# extract some user modified files
echo "===> Extracting custom domain files from the backup: ${BKPFILE}"

# try to extract the old one
# alias
extract "${BKPFILE}" "etc/postfix/alias_virtuales" "etc/postfix/aliases/alias_virtuales"
extract "${BKPFILE}" "etc/postfix/aliases/alias_virtuales"
# body checks
extract "${BKPFILE}" "etc/postfix/body_checks" "etc/postfix/rules/body_checks"
extract "${BKPFILE}" "etc/postfix/rules/body_checks"
#header checks
extract "${BKPFILE}" "etc/postfix/header_checks" "etc/postfix/rules/header_checks"
extract "${BKPFILE}" "etc/postfix/rules/header_checks"
# lista negra
extract "${BKPFILE}" "etc/postfix/lista_negras" "etc/postfix/rules/lista_negra"
extract "${BKPFILE}" "etc/postfix/rules/lista_negra"

# postmap to the alias virtuales & reload postfix
cd /etc/postfix
postmap aliases/alias_virtuales
postmap rules/lista_negra

# restarting services
services start
