#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Show a list of files to restore
#   - Pick one and restore it

# loading commons
source common.conf
source /etc/mailad/mailad.conf

# some local vars
LIBFOLDER="/var/lib/mailad"
LASTWORKINGBACKUPFILE="${LIBFOLDER}/latest_working_backup"
BKPFOLDER="/var/backups/mailad"

# Control services, argument $1 is the action (start/stop)
function services() {
    # disble optional AV
    if [ "$ENABLE_AV" == "no" -o "$ENABLE_AV" == "No" -o "$ENABLE_AV" == "" ] ; then
        SERVICENAMES=`echo "$SERVICENAMES" | tr ' ' '\n' |  grep -v 'clamav' | xargs`
    fi

    # disble optional spamassasin
    if [ "$ENABLE_SPAMD" == "no" -o "$ENABLE_SPAMD" == "No" -o "$ENABLE_SPAMD" == "" ] ; then
        SERVICENAMES=`echo "$SERVICENAMES" | tr ' ' '\n' |  grep -v 'spamassassin' | xargs`
    fi

    for S in `echo $SERVICENAMES | xargs` ; do
        # do it
        echo "===> Doing $1 with $S..."
        systemctl --no-pager $1 $S
        sleep 2
        systemctl --no-pager status $S
    done
}

# fun start here
LIST=`ls $BKPFOLDER`
if [ -z "$LIST" ] ; then
    # no backups
    echo "===> No backups found on the backup folder, exit."
    exit 0
fi

# notice
c=1
tf=`mktemp -d`
echo "===> We found the following backups, pick one to restore:"
for f in `echo "$LIST" | sort -r | xargs` ; do
    n=`echo $f | cut -d "." -f 1`
    printf "    %s)\t%s\n" $c $n
    echo "$f" > "$tf/$c"
    c=$(( $c+1 ))
done
echo "Pick the number of the backup file to restore, #1 is latest"
read -p "any other value or simply an enter to abort " BKPINDEX

# notice you selected a correct number
if [ $BKPINDEX -ge $c ] ; then
    # not valid
    echo "===> You selected a non valid option, abort!"
    exit 0
else
    # valid file
    F=`cat $tf/$BKPINDEX`
    FILE="$BKPFOLDER/$F"
    if [ ! -f "$FILE" ] ; then
        echo "===> You selected a non valid option, abort!"
        exit 0
    else
        echo "===> You selected the file:"
        echo "     $FILE"
    fi
fi

# starting the restore
echo "===> Starting to restore the selected backup..."
cd / && tar -xvzf "$FILE"

# restarting services
services restart

# notice
echo "===> Selected backup restored!"
