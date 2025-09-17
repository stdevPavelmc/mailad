#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Search and create the groups as aliases in the postfix MTA
#   - You can create a everyone@domain or whatever you like for all the users
#   - You can create instantaneous group aliases if you fill the "Email"
#     property of a group
#
# NOTE: This file does not link to the common.conf as this is run as standalone
# in the system...

# load conf files
source /etc/mailad/mailad.conf

# Get the ldap uri based on the file options
# same function on common.conf file
function get_ldap_uri {
    PROTO="ldaps"
    PORT=636
    # detect if NOT secure ldap and change the proto and port of the uri
    if [ "$SECURELDAP" == "" -o "$SECURELDAP" == "no" -o "$SECURELDAP" == "No" ] ; then
        # Use a not secure ldap
        PROTO="ldap"
        PORT=389
    fi

    SOUT=""
    # Fun start here
    for DC in $(echo "${HOSTAD}") ; do
        SOUT="${SOUT} ${PROTO}://${DC}:${PORT}"
    done

    echo "${SOUT}"
}

# get the files' fingerprint
function getfp {
    sha1sum /etc/postfix/aliases/auto_aliases | awk '{print $1}'
}

# Get the file's fingerprint to know if it changed
INITIALFP=$(getfp)
REPORT=$(mktemp)
LDAPURI=$(get_ldap_uri)
ERROR=""

# check if we need to get the everyone group
if [ -z "$EVERYONE" ] ; then
    # empy result: Fail
    echo "===> EVERYONE group disabled, skiping..." >> $REPORT
    echo "# Everyone list DISABLED in config" > /etc/postfix/aliases/auto_aliases
    echo " " >> /etc/postfix/aliases/auto_aliases
else
    echo "===> Trying to retrieve all the emails to form the EVERYONE list" >> $REPORT
    echo "===> login into some of the '$HOSTAD' servers" >> $REPORT
    echo "===> as $LDAPBINDUSER" >> $REPORT

    # LDAP query
    RESULT=$(ldapsearch -o ldif-wrap=no -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectCategory=person)(objectClass=user)(sAMAccountName=*))" mail | grep "mail: " | grep "@$DOMAIN" | awk '{print $2}' | tr '\n' ',')

    if [ "$RESULT" == "" ] ; then
        # empy result: Fail
        echo "===> Error, something failed..." >> $REPORT
        echo $RESULT >> $REPORT 
        ERROR="ujum..."
    else
        # Success
        echo "===> Success, $EVERYONE list created/updated" >> $REPORT
        echo "# Everyone list" > /etc/postfix/aliases/auto_aliases
        echo "$EVERYONE     $RESULT" >> /etc/postfix/aliases/auto_aliases
        echo " " >> /etc/postfix/aliases/auto_aliases
    fi
fi

# Getting the list of the groups in the search base
TEMP=$(mktemp)
ldapsearch -o ldif-wrap=no -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectClass=group)(mail=*))" dn | grep "^dn:" > $TEMP

declare -a RES
# parsing the group names, as it can be coded in base64 when non default charset is used
while IFS= read -r line ; do
    L=$(echo $line | grep '::')
    if [ -z "$L" ] ; then
        R=$(echo $line | cut -d " " -f 2- )
    else
        R=$(echo $line | cut -d " " -f 2-  | base64 -d)
    fi

    # aggregate
    RES+=("$R")
done < $TEMP

rm $TEMP

for G in "${RES[@]}"; do
    # search the group dn
    GEM=$(ldapsearch -o ldif-wrap=no -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectClass=group)(distinguishedName=$G))" mail | grep "mail: " | awk '{print $2}')

    if [ "$GEM" ] ; then
        RESULT=$(ldapsearch -o ldif-wrap=no -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectCategory=person)(objectClass=user)(sAMAccountName=*)(memberOf=$G))" mail | grep "mail: " | awk '{print$2}' | tr '\n' ',')

        echo "===> Parsing members of the group: $G" >> $REPORT
        echo "# Group: $G" >> /etc/postfix/aliases/auto_aliases
        echo "$GEM   $RESULT" >> /etc/postfix/aliases/auto_aliases
        echo " " >> /etc/postfix/aliases/auto_aliases
    fi 
done

# updating postfix about the change
cd /etc/postfix/aliases && postmap auto_aliases
postfix reload 2> /dev/null

FINALFP=$(getfp)
if [ "$INITIALFP" != "$FINALFP" ] ; then
    # need to send the email
    cat $REPORT
    rm $REPORT
fi

# check for the sysadmin group alias if set
if [ "$SYSADMINS" ] ; then
    # search for it on the aliases files
    R=$(cat /etc/postfix/aliases/auto_aliases /etc/postfix/aliases/alias_virtuales | awk '{print $1}' | grep "$SYSADMINS")
    if [ -z "$R" ] ; then
        # build the email
        F=$(mktemp)
        echo "You have a SYSADMIN group configured to recieve notifications in /etc/mailad/mailad.conf" > $F
        echo "but the group checking & updating procedure can't find the group you mention in the config," >> $F
        echo "that means you are losing notification emails, daily mail summaries, etc." >> $F
        echo " " >> $F
        echo "The non-existent group is: $SYSADMINS" >> $F
        echo " " >> $F
        echo "Please check here https://github.com/stdevPavelmc/mailad/blob/master/Features.md to know" >> $F
        echo "how to create the needed group, or simply empty the var in the mailad.conf file and force" >> $F
        echo "a provision of mailad to apply the changes \"make force-provision\"" >> $F
        echo " " >> $F
        echo "Cheers, MailAD dev team." >> $F
        echo " " >> $F
        echo "PS: you will recieve this email daily until you solve that issue." >> $F

        # sending the email to the ADMINMAIL declared
        cat $F | mail ${ADMINMAIL} -s "MailAD need your attention: incomplete configuration detected!"
        rm $F
    fi
fi
