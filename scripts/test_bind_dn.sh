#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Pass or Fail by logging into the AD with the bind DN provided

# load conf files
source /etc/mailad/mailad.conf
source common.conf

LDAPURI=`get_ldap_uri`
H=`get_soa`

# if secure LDAP you must get and setup the sslcert of the addc
if [ "$SECURELDAP" == "yes" -o "$SECURELDAP" == "Yes" -o "$SECURELDAP" == "true" -o "$SECURELDAP" == "True" ] ; then
    # SSL it's
    echo "===> Settings mandate SSL ldap connection"

    # get the certificate of the server
    echo "===> Getting & Installing the server certificate for ldap connection"
    for DC in `echo "${HOSTAD}"` ; do
        echo | openssl s_client -connect ${DC}:636 2>&1 | sed --quiet '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /usr/local/share/ca-certificates/${DC}.crt
    done
    # update the certificates deposit
    /usr/sbin/update-ca-certificates

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
fi

echo "===> Trying to login as $LDAPBINDUSER"
echo "===> in any of the servers: '$HOSTAD'"

# LDAP query
R=`ldapsearch -d 256 -o ldif-wrap=no -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" 2>&1 `
EMPTY=`echo $R | grep numResponses`
ERROR=`echo $R | grep "encryption required"`

if [ "$ERROR" ] ; then
    # empty: Fail
    echo "======================================================"
    echo "ERROR: LDAP server refused the connection, maybe you"
    echo "       need to swith to use 'SECURELDAP=yes' in the"
    echo "       /etc/mailad/mailad.conf file?"
    echo "======================================================"
    exit 1
fi

if [ -z "$EMPTY" ] ; then
    # empty result: Fail
    echo "======================================================"
    echo "ERROR: Undefined response from the LDAP query, humm..."
    echo "       Strange, typical errors are:"
    echo "       - Wrong credentials"
    echo "       - SOA server in HOSTAD variable in IP format,"
    echo "         all DC server must be as FQDN not IPs, this"
    echo "         due to SSL cert restrictions"
    echo ""
    echo "       Response:"
    echo "$R"
    echo "======================================================"
    exit 1
else
    # Success
    echo "===> LDAP bind succeeded!"
fi
