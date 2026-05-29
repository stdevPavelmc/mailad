#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Pass or Fail by logging into the AD with the bind DN provided
#   - Search for the admin user by its declares email and test the following parameters
#       - Office = VMAILSTORAGE
#       - Telephone = not empty
#       - WebPage = not empty and end in "/"

# source the common config
source common.conf

# load conf file
source /etc/mailad/mailad.conf

# get the LDAP URI
LDAPURI=$(get_ldap_uri)

# Helper function to perform LDAP search with TLS handling
perform_ldap_search() {
    local FILTER=$1
    local OUTPUT_FILE=$2
    local USE_TLS=${3:-"auto"}
    
    # Base command
    local CMD="ldapsearch -o ldif-wrap=no -H \"$LDAPURI\" -D \"$LDAPBINDUSER\" -w \"$LDAPBINDPASSWD\" -b \"$LDAPSEARCHBASE\""
    
    # Add TLS options if needed
    if [ "$SECURELDAP" == "yes" -o "$SECURELDAP" == "Yes" -o "$SECURELDAP" == "true" -o "$SECURELDAP" == "True" ]; then
        if [ "$USE_TLS" == "auto" ] || [ "$USE_TLS" == "yes" ]; then
            CMD="$CMD -ZZ"
        fi
    fi
    
    # Add TLS_REQCERT if set in environment
    if [ -n "$LDAPTLS_REQCERT" ]; then
        export LDAPTLS_REQCERT="$LDAPTLS_REQCERT"
    fi
    
    # Execute command
    eval $CMD "$FILTER" > $OUTPUT_FILE 2>&1
    return $?
}

# Function to check if response has TLS/encryption errors
has_tls_error() {
    local FILE=$1
    grep -q "TLS certificate verification\|encryption required\|certificate verify failed" $FILE
    return $?
}

# Function to check if response has ACL/connection errors
has_acl_error() {
    local FILE=$1
    grep -q "acl_read\|Can't contact LDAP server\|ldap_sasl_bind" $FILE
    return $?
}

echo "===> Searching for the user that owns the email: $ADMINMAIL"

TEMP=$(mktemp)

# Try initial search without forcing TLS
perform_ldap_search "(&(objectClass=user)(mail=$ADMINMAIL))" $TEMP "no"

# Check if encryption is required
if has_tls_error $TEMP && grep -q "encryption required" $TEMP; then
    echo "===> LDAP server requested encryption. Retrying with StartTLS (-ZZ)..."
    perform_ldap_search "(&(objectClass=user)(mail=$ADMINMAIL))" $TEMP "no"
    
    # Check for TLS verification errors and retry with relaxed verification
    if has_tls_error $TEMP && grep -q "TLS certificate verification\|certificate verify failed" $TEMP; then
        echo "===> TLS certificate verification failed, retrying with relaxed verification..."
        export LDAPTLS_REQCERT=never
        perform_ldap_search "(&(objectClass=user)(mail=$ADMINMAIL))" $TEMP "no"
    fi
fi

# Extract results
RESULTS=$(grep "numEntries: " $TEMP | awk '{print $3}')

if [ -z "$RESULTS" ] ; then
    # Check for different types of errors
    if has_acl_error $TEMP; then
        # Connection/LDAP base error
        echo "================================================================================="
        echo "ERROR!:"
        echo "    Cannot connect to LDAP server or invalid search base."
        echo "    This is most likely a problem with LDAPSEARCHBASE or network connectivity."
        echo " "
        echo "    LDAPSEARCHBASE value: $LDAPSEARCHBASE"
        echo "    LDAPURI value: $LDAPURI"
        echo " "
        echo "    Common fixes:"
        echo "    1. Verify LDAPSEARCHBASE matches your AD structure (e.g., dc=domain,dc=com)"
        echo "    2. Check if LDAP server is reachable: nc -zv mail.mailad.cu 389"
        echo "    3. Verify credentials: $LDAPBINDUSER"
        echo "================================================================================="
        echo " "
        echo "Debug output (first 10 lines):"
        head -10 $TEMP
        rm $TEMP
        exit 1
    else
        # No results found
        echo "================================================================================="
        echo "ERROR!:"
        echo "    There is no user in the AD with the email you provided in the ADMINMAIL setting"
        echo "    Please check and set the correct value."
        echo " "
        echo "    Current ADMINMAIL: $ADMINMAIL"
        echo "    Search base: $LDAPSEARCHBASE"
        echo "================================================================================="
        echo " "
        rm $TEMP
        exit 1
    fi
else
    # Success, we found entries
    echo "===> Found $RESULTS object(s), parsing the data..."
    
    # If more than one result, warn but continue with first
    if [ $RESULTS -gt 1 ]; then
        echo "===> Warning: Found $RESULTS users with email $ADMINMAIL, using first one"
    fi
fi

# Extract the office parameter "physicalDeliveryOfficeName"
OFFICE=$(grep "physicalDeliveryOfficeName:" $TEMP | head -1 | awk '{print $2}' | tr -d '\r')
if [ "$OFFICE" == "$VMAILSTORAGE" ] ; then
    # Legacy config detected
    echo "================================================================================="
    echo "ERROR!:"
    echo "    Office property has the VMAILSTORAGE parameter ($VMAILSTORAGE), this is a"
    echo "    legacy system configuration. You need to upgrade by following the steps in"
    echo "    Simplify_AD_config.md before continuing with the install/upgrade."
    echo "================================================================================="
    echo " "
    rm $TEMP
    exit 1
fi

# Extract the web page parameter "wWWHomePage"
WP=$(grep "wWWHomePage:" $TEMP | head -1 | awk '{print $2}' | tr -d '\r')
if [ -n "$WP" ] ; then
    # Has webpage parameter
    echo "===> Found text in wWWHomePage parameter: $WP"
    LAST="${WP: -1}"
    if [ "$LAST" == "/" ] ; then
        # Legacy config with trailing slash
        echo "================================================================================="
        echo "ERROR!:"
        echo "    wWWHomePage property ends with '/' which typically indicates it contains the"
        echo "    home folder path for the user. This is a legacy system configuration."
        echo " "
        echo "    Please review Simplify_AD_config.md and update your AD configuration before"
        echo "    continuing with the installation/upgrade."
        echo "================================================================================="
        echo " "
        rm $TEMP
        exit 1
    fi
fi

# Extract telephone number (optional check, just informative)
TELEPHONE=$(grep "telephoneNumber:" $TEMP | head -1 | awk '{print $2}' | tr -d '\r')
if [ -z "$TELEPHONE" ]; then
    echo "===> Note: No telephone number found for $ADMINMAIL (optional)"
else
    echo "===> Telephone number found: $TELEPHONE"
fi

# Success message
echo "================================================================================="
echo "SUCCESS: User $ADMINMAIL is configured correctly"
echo " "
echo "  - Email: $ADMINMAIL"
echo "  - Office field: ${OFFICE:-'(not set)'}"
echo "  - Telephone: ${TELEPHONE:-'(not set)'}"
echo "  - Web page: ${WP:-'(not set)'}"
echo " "
echo "  You can use this user as a template for configuring other mail users!"
echo "================================================================================="

rm $TEMP || true

# Test DEFAULT_MAILBOX_SIZE format
echo " "
echo "===> Testing DEFAULT_MAILBOX_SIZE format..."

# Check if variable exists and is not empty
if [ -z "$DEFAULT_MAILBOX_SIZE" ]; then
    echo "================================================================================="
    echo "WARNING!:"
    echo "    DEFAULT_MAILBOX_SIZE is not set in mailad.conf"
    echo "    Will use default value: 100M"
    echo "================================================================================="
    DEFAULT_MAILBOX_SIZE="100M"
fi

# Test IEC format
echo "$DEFAULT_MAILBOX_SIZE" | numfmt --from=iec >/dev/null 2>&1
R=$?
if [ $R -ne 0 ] ; then
    echo "================================================================================="
    echo "ERROR!:"
    echo "    DEFAULT_MAILBOX_SIZE is not in IEC format: '$DEFAULT_MAILBOX_SIZE'"
    echo " "
    echo "    You must use a number followed by a unit (case-insensitive):"
    echo "    - Valid examples: 100M, 1G, 500M, 2T"
    echo "    - For fractions use lower unit: 1.5G = 1500M"
    echo "    - Valid units: K, M, G, T (Kilobytes, Megabytes, Gigabytes, Terabytes)"
    echo "================================================================================="
    exit 1
else
    # Get value in bytes for confirmation
    BYTES=$(echo "$DEFAULT_MAILBOX_SIZE" | numfmt --from=iec)
    echo "===> DEFAULT_MAILBOX_SIZE: $DEFAULT_MAILBOX_SIZE ($BYTES bytes) - Valid format ✓"
fi

# Show TLS mode if secure LDAP is enabled
if [ "$SECURELDAP" == "yes" -o "$SECURELDAP" == "Yes" -o "$SECURELDAP" == "true" -o "$SECURELDAP" == "True" ]; then
    if [ -n "$LDAPTLS_REQCERT" ] && [ "$LDAPTLS_REQCERT" = "never" ]; then
        echo "===> Note: Running in INSECURE TLS mode (certificate verification disabled)"
        echo "===> For production, install proper CA certificates from your AD server"
    else
        echo "===> Running in SECURE TLS mode with certificate verification"
    fi
fi

exit 0