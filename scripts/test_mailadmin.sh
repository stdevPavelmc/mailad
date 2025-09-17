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

# source the common config
source common.conf

# load conf file
source /etc/mailad/mailad.conf

# get the LDAP URI
LDAPURI=$(get_ldap_uri)

echo "===> Searching for the user that owns the email: $ADMINMAIL"

TEMP=$(mktemp)
ldapsearch -o ldif-wrap=no -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectClass=person)(mail=$ADMINMAIL))" > $TEMP
RESULTS=$(cat $TEMP | grep "numEntries: " | awk '{print $3}')

if [ -z "$RESULTS" ] ; then
    # check for a bad LDAPSEARCHBASE
    BSD=$(cat $TEMP | grep "acl_read")
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
OFFICE=$(cat $TEMP | grep physicalDeliveryOfficeName | awk '{print $2}')
if [ "$OFFICE" == "$VMAILSTORAGE" ] ; then
    # fail, old config
    echo "================================================================================="
    echo "ERROR!:"
    echo "    Office property has the VMAILSTORAGE parameter, this is a legacy system, so"
    echo "    you need to upgrade, see the file Simplify_AD_config.md and do the changes"
    echo "    before continue with the install/upgrade."
    echo "================================================================================="
    echo " "
    rm $TEMP
    exit 1
fi

# Extract the web page parameter "wWWHomePage"
WP=$(cat $TEMP | grep wWWHomePage | awk '{print $2}')
if [ "$WP" != "" ] ; then
    # success 1/2
    echo "===> Found some text on the wWWHomePage parameter... hum..."
    LAST=$(echo "${WP: -1}")
    if [ "$LAST" == "/" ] ; then
        # fail old config
        echo "================================================================================="
        echo "ERROR!:"
        echo "    wWWHomePage property appears to have the home folder for the user, this is a"
        echo "    sign of a legacy system; you need to upgrade, see the file: "
        echo "    Simplify_AD_config.md and do the changes before continuing with the"
        echo "    install/upgrade."
        echo "================================================================================="
        echo " "
        rm $TEMP
        exit 1
    fi
fi

# succcess
echo "===> User $ADMINMAIL is configured ok"
echo "===> You can use that user as an example to set up the others!"
rm $TEMP || true
exit 0
