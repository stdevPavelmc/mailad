#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
#
# Goal: Pass or Fail by logging into the AD with the bind DN provided
#       Search ffor the admin user by its declares email and test the followinf parameters
#           Office = VMAILSTORAGE
#           Telephone = not empty
#           WebPage = not empty and end in "/"

# locate the source file (makefile or run bu hand)
if [ -f mailad.conf ] ; then 
    source mailad.conf
else
    source ../mailad.conf
fi

echo "Searching for the user that owns the email: $ADMINMAIL"

TEMP=`mktemp`
ldapsearch -h "$HOSTAD" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectClass=person)(mail=$ADMINMAIL))" > $TEMP
VALID=`cat $TEMP | grep "numResponses"`

if [ "$VALID" == "" ] ; then
    # empy result: Fail
    rm $TEMP
    exit 1
else
    # Success
    echo "Found at least one Object, parsing the data..."
fi

# Extract the office parameter "physicalDeliveryOfficeName"
OFFICE=`cat $TEMP | grep physicalDeliveryOfficeName | awk '{print $2}'`
if [ "$OFFICE" == "$VMAILSTORAGE" ] ; then
    # success
    echo "Found the vmail storage and it's configured ok..."
else
    # fail
    echo "ERROR!:"
    echo "    VMAILSTORAGE parameter in mailad.conf does not match the one in the user field 'Office'"
    echo "    Config file vs AD value: '$VMAILSTORAGE' != '$OFFICE'"
    rm $TEMP
    exit 1
fi

# Extract the telephone parameter "telephoneNumber"
TELEF=`cat $TEMP | grep telephoneNumber | awk '{print $2}'`
if [ "$TELEF" == "" ] ; then
    # fail
    echo "ERROR!:"
    echo "    The user has no quota value configured, it will not work!"
    echo "    You must use the field Telephone to store a value like '100M' or '1T'"
    rm $TEMP
    exit 1
else
    # success
    echo "Quota value configured ok..."
fi

# Extract the web page arameter "wWWHomePage"
WP=`cat $TEMP | grep wWWHomePage | awk '{print $2}'`
if [ "$WP" != "" ] ; then
    # success 1/2
    echo "Found the users folder on the 'WebPage' attribute..."
    LAST=`echo "${WP: -1}"`
    if [ "$LAST" == "/" ] ; then
        # success
        echo "and it ends with '/' as expected..."
    else
        # fail
        echo "ERROR!:"
        echo "    WebPage is configured for this user, but does not end with '/', please put an '/' at the end"
        rm $TEMP
        exit 1
    fi
else
    # fail
    echo "ERROR!:"
    echo "    WebPage is not configured for this user, you must put a folder, ussually the username followed by a '/'"
    rm $TEMP
    exit 1
fi

# succcess
USER=`cat $TEMP | grep givenName`
echo "User $USER is configured ok, use it as an example to set up the other!"
echo "Success!"
rm $TEMP
exit 0
