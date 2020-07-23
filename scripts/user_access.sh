#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Search and identify the users that belong to national or local restriction
#   - Create the lists acording to that (postmap it)
#   - Reload postfix to apply changes
#

echo $ADGROUPS

# locate the source file (makefile or run by hand)
if [ -f mailad.conf ] ; then 
    source mailad.conf
elif [ -f ../mailad.conf ] ; then
    source ../mailad.conf
elif [ -f /root/mailad/mailad.conf ] ; then
    source /root/mailad/mailad.conf
else
    echo "Can't find the mailad.conf file, default path is /root/mailad/mailad/conf"
    exit 1
fi

# Get email members of a passed group
function get_emails {
    # first and only parameter is the name of the group
    # return the user's emails or EMPTY if none

    # Get group DN
    GROUPDN=`ldapsearch -h "$HOSTAD" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectCategory=group)(sAMAccountName=$1))" distinguishedName | grep "^dn" | awk '{print $2}'`

    # Get emails of the group members
    MEMBERS=`ldapsearch -h "$HOSTAD" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectCategory=person)(memberOf=$GROUPDN))" mail | grep "^mail" | awk '{print $2}'`

    echo $MEMBERS
}

# reset the passed file with a header
function reset_file {
    # only one argument, the file to reset

    echo "# Auto generated file, DO NOT EDIT BY HAND" > $1
}

# update files
function update_files {
    # Parameters
    #   $1 group name to request users from "Mail_national|Mail_local"
    #   $2 file start "nacionales|locales"
    #   $3 action "in|out"
    #   $4 user's emails as a single text string (no \n!)

    # static vars
    PPATH="/etc/postfix"
    ACTION=$2
    AVSCOPE=${ACTION:0:3}

    # Get members of the group
    MEMBERS=`get_emails "$1"`
    
    # file to process
    FILE="$PPATH/$2_$3"

    # reset the file (empty and add banner)
    reset_file $FILE

    # only if returned something
    if [ "$4" != "" ] ; then
        for u in `echo $4 | xargs` ; do
            # just for non empty ones
            if [ "$u" != "" ] ; then 
                echo "$u            ${AVSCOPE}_${3}" >> $FILE 
            fi
        done
    fi

    # postmap the file
    postmap $FILE
}

# processing: fun start here
for G in `echo "Mail_local Mail_national" | xargs` ; do
    # get members only once
    M=`get_emails "$G"`
    for S in `echo "nacionales locales" | xargs` ; do
        for A in `echo "in out" | xargs` ; do
            # update_files arguments
            #   $1 group name to request users from "Mail_national|Mail_local"
            #   $2 file start "nacionales|locales"
            #   $3 action "in|out"
            #   $4 user's emails as a single text string (no \n!)

            update_files "$G" "$S" "$A" "$M"
        done
    done
done

# updating postfix about the change
postfix reload
