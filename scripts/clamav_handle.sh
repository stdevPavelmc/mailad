#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Check if there is an update in the DatabaseDirectory and make a backup of it [default action]
#       - If you pass a 'backup' argument then create a backup file
#       - If you pass a 'restore' argument then restore the backup data

# do nothing if no freshclam present
if [ ! -f /etc/clamav/freshclam.conf ] ; then exit 0 ; fi

# vars:
DBDIR=$(grep DatabaseDirectory /etc/clamav/freshclam.conf | awk '{print $2}')
BKPFILE='/tmp/clamavbkp.tar'

# backup
if [ "$1" == "backup" ] ;  then
    # Make a backup

    # notice
    echo "===> Making a ClamAV database backup"

    # check if there is an update, we measure the folder size, if it's more than 1Mb then there is an update
    cd ${DBDIR}
    R=$(du ./ -sh)
    if [[ "$R" == *"M"* ]] ; then
        # there is at leas a few Mb of data
        tar -cvf ${BKPFILE} ./*
    fi
fi

# restore
if [ "$1" == "restore" ] ;  then
    # restore a backup

    # notice
    echo "===> Restoring the ClamAV database backup"

    # restore a backup if there
    if [ -f ${BKPFILE} ] ; then
        # restore
        cd ${DBDIR}
        tar -xvf ${BKPFILE}

        # remove the backup
        rm ${BKPFILE}
    fi
fi

# usage
if [ -z "$1" ] ;  then
    echo "Make and restore a clamav database backup..."
    echo "$0 backup"
    echo "    Creates a backup file in $BKPFILE from $DBDIR"
    echo "$0 restore"
    echo "    Restore the backup file in $BKPFILE into $DBDIR"
fi
