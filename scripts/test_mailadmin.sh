#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Pass or Fail by logging into the AD with the bind DN provided
#   - Search for the admin user by its declares email and test the followinf parameters
#       - Office = VMAILSTORAGE
#       - Telephone = not empty
#       - WebPage = not empty and end in "/"

# load conf file
source /etc/mailad/mailad.conf

# Generate the LDAPURI based on the settings of the mailad.conf file
if [ "$SECURELDAP" == "" -o "$SECURELDAP" == "no" -o "$SECURELDAP" == "No" ] ; then
    # not secure
    LDAPURI="ldap://${HOSTAD}:389/"
else
    # use a secure layer
    LDAPURI="ldaps://${HOSTAD}:636/"
fi

echo "===> Searching for the user that owns the email: $ADMINMAIL"

TEMP=`mktemp`
ldapsearch -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectClass=person)(mail=$ADMINMAIL))" > $TEMP
RESULTS=`cat $TEMP | grep "numEntries: " | awk '{print $3}'`

if [ -z "$RESULTS" ] ; then
    # check for a bad LDAPSEARCHBASE
    BSD=`cat $TEMP | grep "acl_read"`
    if [ -z "$BSD" ] ; then
        # fail
        echo "================================================================================="
        echo "ERROR!:"
        echo "    There is no user in the AD with the email you provided en the ADMINMAIL setting"
        echo "    please check and set the correct value"
        echo "================================================================================="
        echo " "
        rm $TEMP
        exit 1
    else
        # fail
        echo "================================================================================="
        echo "ERROR!:"
        echo "    There is no valid data and the search returned an error, this in most cases is"
        echo "    a sign of a bad LDAPSEARCHBASE variable, please check that in your config and"
        echo "    try again. For reference the LDAPSEARCHBASE var value is this:"
        echo " "
        echo "    $LDAPSEARCHBASE"
        echo "================================================================================="
        echo " "
        rm $TEMP
        exit 1
    fi
else
    # Success
    echo "===> Found at least one Object, parsing the data..."
fi

# Extract the office parameter "physicalDeliveryOfficeName"
OFFICE=`cat $TEMP | grep physicalDeliveryOfficeName | awk '{print $2}'`
if [ "$OFFICE" == "$VMAILSTORAGE" ] ; then
    # success
    echo "===> Found the vmail storage and it's configured ok..."
else
    # fail
    echo "================================================================================="
    echo "ERROR!:"
    echo "    VMAILSTORAGE parameter in mailad.conf does not match the one in the user field 'Office'"
    echo "    Config file vs AD value: '$VMAILSTORAGE' != '$OFFICE'"
    echo "================================================================================="
    echo " "
    rm $TEMP
    exit 1
fi

# Extract the telephone parameter "telephoneNumber"
TELEF=`cat $TEMP | grep telephoneNumber | awk '{print $2}'`
if [ "$TELEF" == "" ] ; then
    # fail
    echo "================================================================================="
    echo "ERROR!:"
    echo "    The user has no quota value configured, it will not work!"
    echo "    You must use the field Telephone to store a value like "
    echo "    '10M', 500M or '1G'"
    echo "================================================================================="
    echo " "
    rm $TEMP
    exit 1
else
    # success
    echo "===> Quota value configured ok..."
fi

# Extract the web page arameter "wWWHomePage"
WP=`cat $TEMP | grep wWWHomePage | awk '{print $2}'`
if [ "$WP" != "" ] ; then
    # success 1/2
    echo "===> Found the users folder on the 'WebPage' attribute..."
    LAST=`echo "${WP: -1}"`
    if [ "$LAST" == "/" ] ; then
        # success
        echo "===> And it ends with '/' as expected..."
    else
        # fail
        echo "================================================================================="
        echo "ERROR!:"
        echo "    WebPage is configured for this user, but does not end with '/'"
        echo "    please put an '/' at the end"
        echo "================================================================================="
        echo " "
        rm $TEMP
        exit 1
    fi
else
    # fail
    echo "================================================================================="
    echo "ERROR!:"
    echo "    WebPage is not configured for this user, you must "
    echo "    put a folder, ussually the username followed by a '/'"
    echo "================================================================================="
    echo " "
    rm $TEMP
    exit 1
fi

# succcess
USER=`cat $TEMP | grep givenName`
echo "===> User $USER is configured ok"
echo "===> You can use that user as an example to set up the others!"
rm $TEMP
exit 0
