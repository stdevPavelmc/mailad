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
    # Parameter
    #   Only one the group name to request users from
    #       - "Mail_national|Mail_local"
    
    # static vars
    PPATH="/etc/postfix"

    # detecting scope
    if [ "$1" == "Mail_national" ] ; then
        SCOPE="nacionales"
    else
        SCOPE="locales"
    fi

    AVSCOPE=${SCOPE:0:3}

    # Get members of the group
    MEMBERS=`get_emails "$1"`
    
    # Need to touch two files "SCOPE_in|$SCOPE_out" 
    # file to process
    for s in `echo "in out" | xargs` ; do
        FILE="$PPATH/${SCOPE}_${s}"

        # reset the file (empty and add banner)
        reset_file $FILE

        # only if returned something
        if [ "$MEMBERS" != "" ] ; then
            for u in `echo $MEMBERS | xargs` ; do
                # just for non empty ones
                if [ "$u" != "" ] ; then 
                    echo "$u            ${AVSCOPE}_${s}" >> $FILE 
                fi
            done
        fi

        # postmap the file
        postmap $FILE
    done
}

# Fun start here 
for S in `echo "Mail_national Mail_local" | xargs` ; do
    update_files "$S"
done

# updating postfix about the change
postfix reload 2> /dev/null
