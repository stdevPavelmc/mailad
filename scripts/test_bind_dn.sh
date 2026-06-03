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

LDAPURI=$(get_ldap_uri)
H=$(get_soa)

# if secure LDAP you must get and setup the sslcert of the addc
if is_enabled SECURELDAP ; then
    # SSL it's
    echo "===> Settings mandate SSL ldap connection"

    # get the certificate of the server
    echo "===> Getting & Installing the server certificate for ldap connection"
    for DC in $(echo "${HOSTAD}") ; do
        echo "===> Getting the certificate from ${DC}"

        # update the certificates, for any user changes
        /usr/sbin/update-ca-certificates

        # Fix for newer releases with stricter CA cert policies (Trixie, Resolute, etc.)
        . /etc/os-release
        case "${VERSION_CODENAME}" in
            trixie|resolute)
                # new way to extract the CA cert not the server cert
                # this command will fethc the server cert + the CA cert
                # but we need only the CA cert, so we need to extract the second one
                openssl s_client -connect ${DC}:636 -showcerts </dev/null 2>/dev/null | \
                    awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' | \
                    awk '/-----BEGIN CERTIFICATE-----/{c++} c==2' \
                    > /usr/local/share/ca-certificates/${DC}.crt

                # but some self signed ones DO NOT EXPOSE THE CA cert, so we can't use it
                # if the file is empty need to copy from the server and it did not copied the cert by hand yet...
                if [ ! -s /usr/local/share/ca-certificates/${DC}.crt ] ; then
                    # if the user did not copied the cert yet
                    if [ ! -f /usr/local/share/ca-certificates/samba-ca.crt ] ; then
                        # Warn the user that needs to copy the cert from the server
                        echo "======================================================"
                        echo "NOTICE: This is a recent release and new secure policies"
                        echo "        are in place, so we can't get the CA cert"
                        echo " "
                        echo "TODO: You need to copy the CA certificate from the"
                        echo "      server by yourself and install it in the system"
                        echo " "
                        echo "      If you use a samba server as DC you need to check"
                        echo "      the /etc/samba/smb.conf file for a property named"
                        echo "      'tls cafile', if not defined you can use the"
                        echo "      default one: '/var/lib/samba/private/tls/ca.pem'."
                        echo "      Once identified just copy it from that server"
                        echo "      to this server on the following path:"
                        echo "      '/usr/local/share/ca-certificates/samba-ca.crt'"
                        echo "      and re-run this script."
                        echo "======================================================"
                        exit 1
                    fi
                fi
                ;;
            *)
                # old way to extract the CA cert
                echo | openssl s_client -connect ${DC}:636 2>&1 | sed --quiet '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /usr/local/share/ca-certificates/${DC}.crt
                ;;
        esac
    done
    # update the certificates for script changes
    /usr/sbin/update-ca-certificates

    # testing
    R=$?
    if [ ${R} -ne 0 ] ; then
        # error, can get the certificate
        echo "======================================================"
        echo "ERROR: You selected to use a secure layer with LDAP"
        echo "       but we can't get the certificate from the host"
        echo " "
        echo "COMMENT: Please check your configuration or try it"
        echo "         without encryption"
        echo "======================================================"

        # exit with and error
        exit 1
    fi

    # notice
    echo "===> LDAP connections are secured!"
fi

echo "===> Trying to login as ${LDAPBINDUSER}"
echo "===> in any of the servers: '${HOSTAD}'"
echo "===> with the LDAP URI: '${LDAPURI}'"

# LDAP query
R=$(ldapsearch -d 256 -o ldif-wrap=no -H "${LDAPURI}" -D "${LDAPBINDUSER}" -w "${LDAPBINDPASSWD}" -b "${LDAPSEARCHBASE}" 2>&1 )
EMPTY=$(echo "${R}" | grep numResponses)
ERROR=$(echo "${R}" | grep "encryption required")

if [ "${ERROR}" ] ; then
    # empty: Fail
    echo "======================================================"
    echo "ERROR: LDAP server refused the connection, maybe you"
    echo "       need to swith to use 'SECURELDAP=yes' in the"
    echo "       /etc/mailad/mailad.conf file?"
    echo "======================================================"
    exit 1
fi

if [ -z "${EMPTY}" ] ; then
    # empty result: Fail
    echo "======================================================"
    echo "ERROR: Undefined response from the LDAP query, humm..."
    echo "       Strange, typical errors are:"
    echo "       - Wrong credentials."
    echo "       - SOA server in HOSTAD variable in IP format,"
    echo "         all DC server must be as FQDN not IPs, this"
    echo "         due to SSL cert restrictions."
    echo "       - AD-DC server ssl certificate is expired."
    echo ""
    echo "       Response:"
    echo "${R}"
    echo "======================================================"
    exit 1
else
    # Success
    echo "===> LDAP bind succeeded!"
fi

exit 0