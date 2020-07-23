#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Pass or Fail by logging into the AD with the bind DN provided

# locate the source file (makefile or run by hand)
if [ -f mailad.conf ] ; then 
    source mailad.conf
else
    source ../mailad.conf
fi

echo "Trying to login into $HOSTAD as $LDAPBINDUSER"

# LDAP query
RESULT=`ldapsearch -h "$HOSTAD" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" | grep "numResponses"`

if [ "$RESULT" == "" ] ; then
    # empy result: Fail
    exit 1
else
    # Success
    echo "Success!"
    exit 0
fi
