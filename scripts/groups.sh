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

# load the conf file
source /etc/mailad/mailad.conf

# Generate the LDAPURI based on the settings of the mailad.conf file
if [ "$SECURELDAP" == "" -o "$SECURELDAP" == "no" -o "$SECURELDAP" = "No" ] ; then
    # not secure
    LDAPURI="ldap://${HOSTAD}:389/"
else
    # use a secure layer
    LDAPURI="ldaps://${HOSTAD}:636/"
fi

# check if we need to get the everyone group
if [ -z "$EVERYONE" ] ; then
    # empy result: Fail
    echo "===> EVERYONE group disabled, skiping..."
    echo "# Everyone list DISABLED in config" > /etc/postfix/aliases/auto_aliases
    echo " " >> /etc/postfix/aliases/auto_aliases
else
    echo "===> Trying to retrieve all the emails to form login into $HOSTAD as $LDAPBINDUSER"

    # LDAP query
    RESULT=`ldapsearch -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectCategory=person)(objectClass=user)(sAMAccountName=*))" mail | grep "mail: " | grep "@$DOMAIN" | awk '{print $2}' | tr '\n' ','`

    if [ "$RESULT" == "" ] ; then
        # empy result: Fail
        echo "===> Error, something failed..."
        exit 1
    else
        # Success
        echo "Success, $EVERYONE list created"
        echo "# Everyone list" > /etc/postfix/aliases/auto_aliases
        echo "$EVERYONE     $RESULT" >> /etc/postfix/aliases/auto_aliases
        echo " " >> /etc/postfix/aliases/auto_aliases
    fi
fi

# Getting the list of the groups in the search base
TEMP=`mktemp`
ldapsearch -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectClass=group)(mail=*))" dn | grep "^dn:" > $TEMP

RESULT=""
# parsing the group names, as it can be coded in base64 when non default charset is used
while IFS= read -r line ; do
    L=`echo $line | grep '::'`
    if [ -z "$L" ] ; then
        R=`echo $line | awk '{print $2}'`
    else
        R=`echo $line | awk '{print $2}' | base64 -d`
    fi

    # aggregate
    RESULT="$R $RESULT"
done < $TEMP

rm $TEMP

for G in `echo $RESULT | xargs `; do
    # search the group dn
    GEM=`ldapsearch -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectClass=group)(distinguishedName=$G))" mail | grep "mail: " | awk '{print $2}'`

    if [ "$GEM" != "" ] ; then
        RESULT=`ldapsearch -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectCategory=person)(objectClass=user)(sAMAccountName=*)(memberOf=$G))" mail | grep "mail: " | awk '{print$2}' | tr '\n' ','`

        echo "# Group: $G" >> /etc/postfix/aliases/auto_aliases
        echo "$GEM   $RESULT" >> /etc/postfix/aliases/auto_aliases
        echo " " >> /etc/postfix/aliases/auto_aliases
    fi 
done

# updating postfix about the change
cd /etc/postfix/aliases && postmap auto_aliases
postfix reload

# check foir the sysadmin group alias if set
if [ "$SYSADMINS" != "" ] ; then
    # search for it on the aliases files
    R=`cat /etc/postfix/aliases/auto_aliases /etc/postfix/aliases/alias_virtuales | awk '{print $1}' | grep "$SYSADMINS"`
    if [ "$R" == "" ] ; then
        # notice
        echo "===> Warning: SYSADMIN group not configured, check your mail for details!"

        # build the email
        F=`mktemp`
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