#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Pass or Fail by logging into the AD with the bind DN provided

# load conf files
source /etc/mailad/mailad.conf

echo "===> Trying to login into $HOSTAD as $LDAPBINDUSER"

# Generate the LDAPURI based on the settings of the mailad.conf file
if [ "$SECURELDAP" == "" -o "$SECURELDAP" == "no" -o "$SECURELDAP" = "No" ] ; then
    # not secure
    LDAPURI="ldap://${HOSTAD}:389/"

    # notice
    echo "===> WARNING: LDAP connection are in plain text!"
else
    # use a secure layer
    LDAPURI="ldaps://${HOSTAD}:636/"

    # get the certificate of the server
    echo "===> Getting & Installing the server certificate for ldap connection"
    echo | openssl s_client -connect ${HOSTAD}:636 2>&1 | sed --quiet '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/ssl/certs/samba.crt

    # testing
    R=$?
    if [ $R -ne 0 ] ; then
        # error can get eh certificate
            # error
        echo "======================================================"
        echo "ERROR: You selected to use a secure layer with LDAP"
        echo "       but we can't get the certificate from the host"
        echo " "
        echo "COMMENT: Please check your configuration or try it"
        echo "         without encription"
        echo "======================================================"

        # exit with and error
        exit 1
    fi

    # notice
    echo "===> LDAP connections are secured!"

    # install the cert into the LDAP client setting
    cat /etc/ldap/ldap.conf | grep -v TLS_CACERT > /tmp/1
    echo "TLS_CACERT /etc/ssl/certs/samba.crt" >> /tmp/1
    cat /tmp/1 > /etc/ldap/ldap.conf
fi

# LDAP query
RESULT=`ldapsearch -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" | grep "numResponses"`

if [ "$RESULT" == "" ] ; then
    # empy result: Fail
    exit 1
else
    # Success
    echo "===> LDAP bind succeeded!"
fi
