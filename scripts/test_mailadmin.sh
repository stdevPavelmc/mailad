#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Pass or Fail by querying the AD with the configured bind DN
#   - Search for the admin user by its declared email, with AD-friendly fallbacks
#   - Detect legacy AD field values that still require migration
#   - Validate DEFAULT_MAILBOX_SIZE format

# source the common config
source common.conf

# load conf file
source /etc/mailad/mailad.conf

# get the LDAP URI
LDAPURI=$(get_ldap_uri)

echo "===> Searching for the user that owns the email: $ADMINMAIL"

# Create temp file
TEMP=$(mktemp)

# define a RESULT variable from start to avoid errors of not defined or empty
RESULTS=''

run_search() {
    local FILTER=$1

    ldapsearch -o ldif-wrap=no \
        -H "$LDAPURI" \
        -D "$LDAPBINDUSER" \
        -w "$LDAPBINDPASSWD" \
        -b "$LDAPSEARCHBASE" \
        "$FILTER" > "$TEMP" 2>&1

    SEARCH_RC=$?
    RESULTS=$(grep "^# numEntries:" "$TEMP" | awk '{print $3}')
}

SEARCH_RC=0
run_search "(&(objectClass=person)(mail=$ADMINMAIL))"

if [ -z "$RESULTS" ] || [ "$RESULTS" == "0" ]; then
    # Try with userPrincipalName
    echo "===> Trying with userPrincipalName..."
    run_search "(userPrincipalName=$ADMINMAIL)"
fi

if [ -z "$RESULTS" ] || [ "$RESULTS" == "0" ]; then
    # Try with sAMAccountName
    USERNAME=$(echo "$ADMINMAIL" | cut -d@ -f1)
    echo "===> Trying with sAMAccountName=$USERNAME..."
    run_search "(sAMAccountName=$USERNAME)"
fi

if [ -z "$RESULTS" ] || [ "$RESULTS" == "0" ]; then
    BSD=$(grep "acl_read" "$TEMP")

    if [ -n "$BSD" ] ; then
        echo "================================================================================="
        echo "ERROR!:"
        echo "    There is no valid data and the search returned an error, this in most cases is"
        echo "    a sign of a bad LDAPSEARCHBASE variable, please check that in your config and"
        echo "    try again. For reference the LDAPSEARCHBASE var value is this:"
        echo " "
        echo "    $LDAPSEARCHBASE"
        echo "================================================================================="
    elif [ $SEARCH_RC -ne 0 ] ; then
        echo "================================================================================="
        echo "ERROR!:"
        echo "    The LDAP query returned an error before any user could be matched."
        echo "    Please validate the bind and TLS setup first with scripts/test_bind_dn.sh"
        echo " "
        echo "    Search base: $LDAPSEARCHBASE"
        echo "    LDAP URI: $LDAPURI"
        echo "    Bind user: $LDAPBINDUSER"
        echo " "
        echo "    Response (first 20 lines):"
        sed -n '1,20p' "$TEMP"
        echo "================================================================================="
    else
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

        ldapsearch -o ldif-wrap=no \
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
    fi

    rm "$TEMP"
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
    echo "===> Note: No telephone number found for $ADMINMAIL"
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

rm "$TEMP" || true

# Test DEFAULT_MAILBOX_SIZE format
echo " "
echo "===> Testing DEFAULT_MAILBOX_SIZE format..."

if [ -z "$DEFAULT_MAILBOX_SIZE" ]; then
    echo "================================================================================="
    echo "ERROR!:"
    echo "    DEFAULT_MAILBOX_SIZE is not set in mailad.conf"
    echo "================================================================================="
    exit 1
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

exit 0