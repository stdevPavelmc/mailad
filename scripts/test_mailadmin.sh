#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  

# source the common config
source common.conf

# load conf file
source /etc/mailad/mailad.conf

# get the LDAP URI
LDAPURI=$(get_ldap_uri)

echo "===> Searching for the user that owns the email: $ADMINMAIL"

# Create temp file
TEMP=$(mktemp)

# Direct ldapsearch command - this works!
LDAPTLS_REQCERT=never ldapsearch -ZZ -o ldif-wrap=no \
    -H "$LDAPURI" \
    -D "$LDAPBINDUSER" \
    -w "$LDAPBINDPASSWD" \
    -b "$LDAPSEARCHBASE" \
    "(mail=$ADMINMAIL)" > $TEMP 2>&1

# Extract results
RESULTS=$(grep "^# numEntries:" $TEMP | awk '{print $3}')

if [ -z "$RESULTS" ] || [ "$RESULTS" == "0" ]; then
    # Try with userPrincipalName
    echo "===> Trying with userPrincipalName..."
    LDAPTLS_REQCERT=never ldapsearch -ZZ -o ldif-wrap=no \
        -H "$LDAPURI" \
        -D "$LDAPBINDUSER" \
        -w "$LDAPBINDPASSWD" \
        -b "$LDAPSEARCHBASE" \
        "(userPrincipalName=$ADMINMAIL)" > $TEMP 2>&1
    
    RESULTS=$(grep "^# numEntries:" $TEMP | awk '{print $3}')
fi

if [ -z "$RESULTS" ] || [ "$RESULTS" == "0" ]; then
    # Try with sAMAccountName
    USERNAME=$(echo $ADMINMAIL | cut -d@ -f1)
    echo "===> Trying with sAMAccountName=$USERNAME..."
    LDAPTLS_REQCERT=never ldapsearch -ZZ -o ldif-wrap=no \
        -H "$LDAPURI" \
        -D "$LDAPBINDUSER" \
        -w "$LDAPBINDPASSWD" \
        -b "$LDAPSEARCHBASE" \
        "(sAMAccountName=$USERNAME)" > $TEMP 2>&1
    
    RESULTS=$(grep "^# numEntries:" $TEMP | awk '{print $3}')
fi

if [ -z "$RESULTS" ] || [ "$RESULTS" == "0" ]; then
    echo "================================================================================="
    echo "ERROR!:"
    echo "    No user found with email: $ADMINMAIL"
    echo " "
    echo "    Search base: $LDAPSEARCHBASE"
    echo "    LDAP URI: $LDAPURI"
    echo "    Bind user: $LDAPBINDUSER"
    echo " "
    echo "    Listing all users in this OU for debugging:"
    echo "    -------------------------------------------"
    
    # List all users for debugging
    LDAPTLS_REQCERT=never ldapsearch -ZZ -o ldif-wrap=no \
        -H "$LDAPURI" \
        -D "$LDAPBINDUSER" \
        -w "$LDAPBINDPASSWD" \
        -b "$LDAPSEARCHBASE" \
        "(|(objectClass=user)(objectClass=person))" mail cn sAMAccountName 2>/dev/null | \
        awk '
            /^dn:/ {dn=$0}
            /^mail:/ {print dn; print "    " $0}
            /^cn:/ && !/^mail:/ {print "    " $0}
            /^sAMAccountName:/ {print "    " $0}
        '
    
    echo "================================================================================="
    rm $TEMP
    exit 1
fi

echo "===> Found $RESULTS object(s), parsing the data..."

# Extract the office parameter
OFFICE=$(grep "^physicalDeliveryOfficeName:" $TEMP | head -1 | awk '{print $2}' | tr -d '\r')
if [ "$OFFICE" == "$VMAILSTORAGE" ] ; then
    echo "================================================================================="
    echo "ERROR!:"
    echo "    Office property has the VMAILSTORAGE parameter ($VMAILSTORAGE)"
    echo "    This is a legacy system configuration."
    echo "    Please review Simplify_AD_config.md"
    echo "================================================================================="
    rm $TEMP
    exit 1
fi

# Extract the web page parameter
WP=$(grep "^wWWHomePage:" $TEMP | head -1 | awk '{print $2}' | tr -d '\r')
if [ -n "$WP" ] ; then
    echo "===> Found wWWHomePage: $WP"
    LAST="${WP: -1}"
    if [ "$LAST" == "/" ] ; then
        echo "================================================================================="
        echo "ERROR!:"
        echo "    wWWHomePage property ends with '/' indicating legacy configuration."
        echo "    Please review Simplify_AD_config.md"
        echo "================================================================================="
        rm $TEMP
        exit 1
    fi
fi

# Extract telephone number (optional)
TELEPHONE=$(grep "^telephoneNumber:" $TEMP | head -1 | awk '{print $2}' | tr -d '\r')
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
echo "  - DN: $(grep "^dn:" $TEMP | head -1)"
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

if [ -z "$DEFAULT_MAILBOX_SIZE" ]; then
    echo "================================================================================="
    echo "WARNING: DEFAULT_MAILBOX_SIZE is not set in mailad.conf"
    echo "         Will use default value: 100M"
    echo "================================================================================="
    DEFAULT_MAILBOX_SIZE="100M"
fi

# Test IEC format
echo "$DEFAULT_MAILBOX_SIZE" | numfmt --from=iec >/dev/null 2>&1
if [ $? -ne 0 ] ; then
    echo "================================================================================="
    echo "ERROR!:"
    echo "    DEFAULT_MAILBOX_SIZE is not in IEC format: '$DEFAULT_MAILBOX_SIZE'"
    echo " "
    echo "    Valid examples: 100M, 1G, 500M, 2T"
    echo "    For fractions use lower unit: 1.5G = 1500M"
    echo "================================================================================="
    exit 1
else
    BYTES=$(echo "$DEFAULT_MAILBOX_SIZE" | numfmt --from=iec)
    echo "===> DEFAULT_MAILBOX_SIZE: $DEFAULT_MAILBOX_SIZE ($BYTES bytes) - Valid format ✓"
fi

# Show TLS mode info
if [ -n "$LDAPTLS_REQCERT" ] && [ "$LDAPTLS_REQCERT" = "never" ]; then
    echo "===> Note: Running in INSECURE TLS mode (certificate verification disabled)"
    echo "===> For production, install proper CA certificates from your AD server"
fi

exit 0