#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# This script is meant to be run in the SAMBA4 DC, not in the MailAD server
#
# Goals:
#   - Run this on the Samba4 DC (NOT in the mailserver)
#   - It will search the user base and migrate them to the new property schema
#
# The old schema: (for every user)
#   - General Mail Storage: ldap:physicalDeliveryOfficeName
#   - maildirHome: ldap:wWWHomePage
#   - User quota (mandatory): ldap:telephoneNumber
#
# The new schema: (for every user)
#   - Genaral Mail Storage: variable in /etc/mailad/mailad.conf
#   - maildirHome: dynamic from ldap:sAMAccountName
#   - User quota (optional): ldap:ldap:wWWHomePage
#

# get the parameters or fail with an usage
# Initialize our own variables:
DOMAIN=""
DOU=""

# install ldb-tools
env DEBIAN_FRONTEND=noninteractive apt-get install ldb-tools -y

# function to show help
function show_help() {
    echo "$1 script help"
    echo "  -d DOMAIN of your DC, like 'mail.mailad.cu'"
    echo "  -o Base OU name of your users inside your domian structure"
    echo "     surround it with \"quotes\" if it has spaces in the name"
    echo "     like 'MAILAD' or \"USUARIOS del DOMINIO\""
    echo " "
}

# Process the parameters
while getopts "h:d:o:" opt; do
    case ${opt} in
    h)
        show_help $0
        exit 0
        ;;
    d)  DOMAIN=$OPTARG
        ;;
    o)  DOU=$OPTARG
        ;;
    :)  show_help $0
        exit 0
        ;;
    esac
done
shift $((OPTIND-1))

# no arguments
if [ ! "$DOMAIN" -o ! "$DOU" ] ; then
    show_help $0
    exit 0
fi

# check if samba is running
SAMBA=$(ps aux | grep samba | grep -v grep)
if [ -z "$SAMBA" ] ; then
    # not running
    echo " "
    echo "========================================================================="
    echo "NOTICE!!!"
    echo ""
    echo " This script is intended to be run on the SAMBA 4 Domain controller and"
    echo " no running samba process was found in the local PC"
    echo ""
    echo " This script must be used only ONCE and with extreme caution! Please see"
    echo " https://github.com/stdevPavelmc/mailad/blob/master/Simplify_AD_config.md"
    echo " for the explanation." 
    echo " "
    echo "========================================================================"

    exit 1
fi

# check samba service name
SAMBASVR=$(systemctl --no-pager list-units --type=service | grep samba | awk '{print $1}')
if [ -z "$SAMBASVR" ] ; then
    # not running
    echo " "
    echo "========================================================================="
    echo "NOTICE!!!"
    echo ""
    echo " This script is intended to be run on the SAMBA 4 Domain controller and"
    echo " no systemd samba unit was found in the local PC"
    echo ""
    echo " please rename the systemd service to contains the word 'samba' in the"
    echo " name or contact the author for instructions/fix/help"
    echo " " 
    echo "========================================================================"
    
    exit 1
fi

# first time run, we force a read of the help files
if [ ! -f "/tmp/mad_1_run" ] ; then
    # not running
    echo " "
    echo "========================================================================="
    echo "NOTICE!!!"
    echo ""
    echo " This script must be used only ONCE and with extreme caution! Please see"
    echo " https://github.com/stdevPavelmc/mailad/blob/master/Simplify_AD_config.md"
    echo " for the explanation." 
    echo ""
    echo " Run it again to perform the indended migration, again: This SCRIPT is"
    echo " only to migrate from the old schema to the simplified one."
    echo ""
    echo "========================================================================"

    touch /tmp/mad_1_run
    exit 0
fi

#### Fun start here

# find the correct ldb file, defults to system installed one
S4LDB="/var/lib/samba/private/sam.ldb"
if [ ! -f "$S4LDB" ] ; then
    # going for the compiled default path
    if [ -f "/usr/local/samba/private/sam.ldb" ] ; then
        echo "===> Samba 4 sam.ldb found in compiled default path"
        S4LDB="/usr/local/samba/private/sam.ldb"
    else
        echo " "
        echo "========================================================================="
        echo "ERROR!!!"
        echo " "
        echo " This script needs th sam.ldb file and we can't find it in the default"
        echo " locations:"
        echo "   - /var/lib/samba/private/sam.ldb"
        echo "   - /usr/local/samba/private/sam.ldb"
        echo " "
        echo " If you use a non default install, just create a soft link from the sam"
        echo " file to one of that locations and try again"
        echo " "
        echo "========================================================================="
        
        exit 1
    fi
else
    # default path
    echo "===> Samba 4 sam.ldb found in default path"
fi

# craft the LDAP base var
BDN="ou=$DOU"
IFS='.' read -r -a array <<< "$DOMAIN"
for s in "${array[@]}" ; do
    BDN="$BDN,dc=$s"
done

# get samba users list
UL=$(samba-tool user list)
FILE=$(mktemp)
CHANGE=$(mktemp)
for U in $(echo $UL | xargs) ; do
    echo " "
    echo "===> Parsing '$U' data..."
    # get the data for the user
    ldbsearch -o ldif-wrap=no -H "$S4LDB" -b "$BDN" "SAMAccountName=$U" > $FILE

    # parse only if mail is present
    MAIL=$(cat $FILE | grep "mail: " | cut -d ' ' -f 2-)
    if [ "$MAIL" ] ; then
        # user with mail found
        DN=$(cat $FILE | grep "dn:" | cut -d ' ' -f 2-)
        STORAGE=$(cat $FILE | grep "physicalDeliveryOfficeName:" | cut -d ' ' -f 2-)
        HOME=$(cat $FILE | grep  "wWWHomePage:" | cut -d ' ' -f 2-)
        QUOTA=$(cat $FILE | grep "telephoneNumber:" | cut -d ' ' -f 2-)

        # if any of them is empty is a sign of a bad confgured or already migrated user
        if [ -z "$STORAGE" -o -z "$HOME" -o -z "$QUOTA" ] ; then
            echo "   > No data or already migrated"
        else
            # user with old settings
            echo " ==> User needs migration"

            # delete 'physicalDeliveryOfficeName', 'telephoneNumber'
            echo "  => Deleting old properties"
            echo "dn: $DN" > $CHANGE
            echo "changetype: modify" >> $CHANGE
            echo "delete: physicalDeliveryOfficeName" >> $CHANGE
            echo "physicalDeliveryOfficeName: $STORAGE" >> $CHANGE
            echo "-" >> $CHANGE
            echo "delete: telephoneNumber" >> $CHANGE
            echo "telephoneNumber: $QUOTA" >> $CHANGE

            # apply
            R=$(ldbmodify -H $S4LDB $CHANGE | grep " 1 record")
            if [ -z "$R" ] ; then
                echo "   ####> ERROR: user '$MAIL' failed to modify, plase check it by hand"
            fi

            # change 'wWWHomePage' to hold the quota
            echo "  => Change quota to HomePage"
            echo "dn: $DN" > $CHANGE
            echo "changetype: modify" >> $CHANGE
            echo "replace: wWWHomePage" >> $CHANGE
            echo "wWWHomePage: $QUOTA" >> $CHANGE

            # # apply
            R=$(ldbmodify -H $S4LDB $CHANGE | grep " 1 record")
            if [ -z "$R" ] ; then
                echo "   ####> ERROR: user '$MAIL' failed to modify, plase check it by hand"
            fi
        fi
    fi
done
