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

echo "Installing the server certificate for ldap connection"
openssl s_client -connect ${HOSTAD}:636 -showcerts < /dev/null > /etc/ssl/certs/samba.crt
cat /etc/ldap/ldap.conf | grep -v TLS_CACERT > /tmp/1
echo "TLS_CACERT /etc/ssl/certs/samba.crt" >> /tmp/1
cat /tmp/1 > /etc/ldap/ldap.conf

echo "Trying to login into $HOSTAD as $LDAPBINDUSER"

# LDAP query
RESULT=`ldapsearch -H "ldaps://${HOSTAD}:636/" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" | grep "numResponses"`

if [ "$RESULT" == "" ] ; then
    # empy result: Fail
    exit 1
else
    # Success
    echo "Success!"
    exit 0
fi
