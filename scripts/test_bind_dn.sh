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

# Helper function to handle TLS certificate verification
handle_tls_cert() {
    local DC=$1
    local CERT_FILE="/usr/local/share/ca-certificates/${DC}.crt"
    
    # Check if certificate already exists
    if [ -f "$CERT_FILE" ] && [ -s "$CERT_FILE" ]; then
        echo "===> Certificate for ${DC} already exists, skipping download"
        return 0
    fi
    
    # Try to get certificate via LDAPS (port 636)
    echo "===> Attempting to get certificate from ${DC} via LDAPS..."
    echo | openssl s_client -connect ${DC}:636 -showcerts 2>/dev/null | \
        awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' > ${CERT_FILE}
    
    # If file is empty, try with StartTLS
    if [ ! -s ${CERT_FILE} ]; then
        echo "===> LDAPS failed, trying StartTLS on port 389..."
        echo | openssl s_client -connect ${DC}:389 -starttls ldap -showcerts 2>/dev/null | \
            awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' > ${CERT_FILE}
    fi
    
    # For self-signed certificates, try to extract CA cert
    if [ ! -s ${CERT_FILE} ]; then
        echo "===> Could not get server certificate, attempting to get CA certificate..."
        echo | openssl s_client -connect ${DC}:636 -showcerts 2>/dev/null | \
            awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' | \
            tail -n +2 > ${CERT_FILE}
    fi
    
    # Last resort: check if user provided custom CA cert
    if [ ! -s ${CERT_FILE} ] && [ -f "/usr/local/share/ca-certificates/samba-ca.crt" ]; then
        echo "===> Using user-provided CA certificate"
        cp /usr/local/share/ca-certificates/samba-ca.crt ${CERT_FILE}
    fi
    
    # If we still don't have a cert, warn but don't fail (allow insecure mode)
    if [ ! -s ${CERT_FILE} ]; then
        echo "======================================================"
        echo "WARNING: Could not obtain certificate from ${DC}"
        echo "         Will continue in INSECURE mode (TLS_REQCERT never)"
        echo "         For production, manually install the CA certificate:"
        echo "         1. Copy CA cert from DC to /usr/local/share/ca-certificates/samba-ca.crt"
        echo "         2. Run: sudo update-ca-certificates"
        echo "======================================================"
        rm -f ${CERT_FILE}
        export LDAPTLS_REQCERT=never
        return 1
    fi
    
    return 0
}

# if secure LDAP you must get and setup the sslcert of the addc
if [ "$SECURELDAP" == "yes" -o "$SECURELDAP" == "Yes" -o "$SECURELDAP" == "true" -o "$SECURELDAP" == "True" ] ; then
    # SSL it's
    echo "===> Settings mandate SSL ldap connection"

    # get the certificate of the server
    echo "===> Getting & Installing the server certificate for ldap connection"
    
    CERT_OK=0
    for DC in $(echo "${HOSTAD}") ; do
        echo "===> Processing certificate from ${DC}"
        if handle_tls_cert ${DC}; then
            CERT_OK=1
        fi
    done
    
    # Update certificates if we got any
    if [ $CERT_OK -eq 1 ]; then
        echo "===> Updating system CA certificates..."
        /usr/sbin/update-ca-certificates 2>/dev/null
        
        # Test if certificate works
        echo "===> Testing certificate installation..."
        TEST_CMD="ldapsearch -ZZ -d 0 -o ldif-wrap=no -H \"$LDAPURI\" -D \"$LDAPBINDUSER\" -w \"$LDAPBINDPASSWD\" -b \"$LDAPSEARCHBASE\" -s base 2>&1"
        TEST_RESULT=$(eval $TEST_CMD | grep -c "successful")
        
        if [ $TEST_RESULT -eq 0 ]; then
            echo "===> Certificate installed but verification still failing, falling back to insecure mode"
            export LDAPTLS_REQCERT=never
        else
            echo "===> LDAP connections are secured with valid certificates!"
        fi
    else
        echo "===> No certificates obtained, using insecure mode (TLS_REQCERT never)"
        export LDAPTLS_REQCERT=never
    fi
else
    # Not secure LDAP, warn but continue
    echo "===> SECURELDAP not enabled, using plain LDAP (not recommended for production)"
fi

echo "===> Trying to login as $LDAPBINDUSER"
echo "===> in any of the servers: '$HOSTAD'"
echo "===> with the LDAP URI: '$LDAPURI'"

# Function to perform LDAP search with retry logic
do_ldap_search() {
    local USE_TLS=$1
    local CMD="ldapsearch -d 256 -o ldif-wrap=no -H \"$LDAPURI\" -D \"$LDAPBINDUSER\" -w \"$LDAPBINDPASSWD\" -b \"$LDAPSEARCHBASE\""
    
    if [ "$USE_TLS" = "yes" ]; then
        CMD="$CMD -ZZ"
    fi
    
    # Add TLS_REQCERT if set in environment
    if [ -n "$LDAPTLS_REQCERT" ]; then
        export LDAPTLS_REQCERT="$LDAPTLS_REQCERT"
    fi
    
    eval $CMD 2>&1
}

# First attempt without StartTLS
R=$(do_ldap_search "no")
EMPTY=$(echo "$R" | grep -c "numResponses")
ERROR=$(echo "$R" | grep -c "encryption required")

if [ $ERROR -gt 0 ]; then
    echo "===> LDAP server requested encryption. Retrying with StartTLS (-ZZ)..."
    R=$(do_ldap_search "yes")
    EMPTY=$(echo "$R" | grep -c "numResponses")
    ERROR=$(echo "$R" | grep -c "encryption required")
    
    # Check for TLS verification errors
    TLS_ERROR=$(echo "$R" | grep -c "TLS certificate verification")
    if [ $TLS_ERROR -gt 0 ] && [ -z "$LDAPTLS_REQCERT" ]; then
        echo "===> TLS certificate verification failed, retrying with relaxed verification..."
        export LDAPTLS_REQCERT=never
        R=$(do_ldap_search "yes")
        EMPTY=$(echo "$R" | grep -c "numResponses")
        ERROR=$(echo "$R" | grep -c "encryption required")
    fi
    
    if [ $ERROR -gt 0 ]; then
        echo "======================================================"
        echo "ERROR: LDAP server refused the connection even with StartTLS (-ZZ)."
        echo "       Please check your LDAP configuration and whether the"
        echo "       server accepts STARTTLS or LDAPS."
        echo "======================================================"
        echo "Debug output:"
        echo "$R" | head -20
        exit 1
    fi
fi

if [ $EMPTY -eq 0 ] ; then
    # empty result: Fail
    echo "======================================================"
    echo "ERROR: Undefined response from the LDAP query, humm..."
    echo "       Strange, typical errors are:"
    echo "       - Wrong credentials."
    echo "       - SOA server in HOSTAD variable in IP format,"
    echo "         all DC server must be as FQDN not IPs, this"
    echo "         due to SSL cert restrictions."
    echo "       - AD-DC server ssl certificate is expired."
    echo "       - Network/firewall blocking LDAP ports (389/636)"
    echo ""
    echo "       Response (first 20 lines):"
    echo "$R" | head -20
    echo "======================================================"
    exit 1
else
    # Success
    echo "===> LDAP bind succeeded!"
    
    # Show connection mode
    if [ -n "$LDAPTLS_REQCERT" ] && [ "$LDAPTLS_REQCERT" = "never" ]; then
        echo "===> Note: Running in INSECURE mode (TLS verification disabled)"
        echo "===> For production, install proper CA certificates"
    elif [ "$SECURELDAP" == "yes" ]; then
        echo "===> Running in SECURE mode with TLS verification"
    fi
fi

exit 0