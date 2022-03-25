#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Check for updates/upgrades and if needed
#   - Create a backup of the postfix and dovecot folders in /var/backups/mailad

# import the common vars
source common.conf

# test /sbin on some envs (Debian 10/11)
SBIN=`echo $PATH | grep "/sbin"`
if [ -z "$SBIN" ] ; then
    # export sbins silently
    PATH="/sbin:/usr/sbin:$PATH"
    export PATH
fi

# some local vars
LIBFOLDER="/var/lib/mailad"
LASTWORKINGBACKUPFILE="${LIBFOLDER}/latest_working_backup"

# advice
echo "===> Starting a selective restore of custom data"

# check if the last backup file exist
if [ -f "${LASTWORKINGBACKUPFILE}" ] ; then
    # check if the content exist
    BKPFILE=`cat ${LASTWORKINGBACKUPFILE}`

    if [ ! -f "${BKPFILE}" ] ; then
        # backup trace there but no backup?
        echo "==========================================================================="
        echo "ERROR: The backup trace points to a non-existent file, so will reset it"
        echo "       and no custom restore will be made"
        echo " "
        echo "       This is only a notice, no custom restore will be made"
        echo "==========================================================================="

        rm "${LASTWORKINGBACKUPFILE}"
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
services restart
