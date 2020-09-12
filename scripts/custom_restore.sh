#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Check for updates/upgrades and if needed
#   - Create a backup of the postfix and dovecot folders in /var/backups/mailad

# import the common vars
source ./common.conf

# some local vars
LIBFOLDER="/var/lib/mailad"
LASTBACKUPFILE="${LIBFOLDER}/latest_backup"

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

# advice
echo "===> Starting a selective restore of custom data"

# check if the last backup file exist
if [ -f "${LASTBACKUPFILE}" ] ; then
    # check if the content exist
    BKPFILE=`cat ${LASTBACKUPFILE}`

    if [ ! -f "${BKPFILE}" ] ; then
        # backup trace there but no backup?
        echo "==========================================================================="
        echo "ERROR: The backup trace points to a non-existent file, so will reset it"
        echo "       and no custom restore will be made"
        echo " "
        echo "       This is only a notice, no custom restore will be made"
        echo "==========================================================================="

        rm "${LASTBACKUPFILE}"
        sleep 5
        exit 0
    fi
else
    # no latest backup detected
    echo "==========================================================================="
    echo "NOTICE: There is no trace of a latest backup made, this is not an error,"
    echo "        maybe you have not made a backup or upgrade process yet"
    echo " "
    echo "       This is only a notice, no custom restore will be made"
    echo "==========================================================================="

    sleep 5
    exit 0
fi

# show the properties
echo "===> Latest backup is: ${BKPFILE}"

# extract some user modified files
echo "===> Extracting custom files from the backup..."

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

# extract some user modified files
echo "===> Restarting services to apply changes"

# restart services
services restart
