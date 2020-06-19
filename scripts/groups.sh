#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
#
# Goal:
#   - Search and create the groups as aliases in the postfix MTA
#   - You can create a everyone@domain or whatever you like for all the users
#   - You can create instantaneous group aliases if you fill the "Email"
#     property of a group
#

echo $ADGROUPS

# locate the source file (makefile or run by hand)
if [ -f mailad.conf ] ; then 
    source mailad.conf
elif [ -f ../mailad.conf ] ; then
    source ../mailad.conf
else
    source /root/mailad/mailad.conf
else
    echo "Can't find the mailad.conf file, default path is /root/mailad/mailad/conf"
fi

# check if we need to get the everyone group
if [ "$EVERYONE" == "" ] ; then
    # empy result: Fail
    echo "EVERYONE group disabled, skiping..."
else
    echo "Trying to retrieve all the emails to form login into $HOSTAD as $LDAPBINDUSER"

    # LDAP query
    RESULT=`ldapsearch -h "$HOSTAD" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectCategory=person)(objectClass=user)(sAMAccountName=*))" mail | grep "mail: " | grep "@$DOMAIN" | awk '{print $2}' | tr '\n' ','`

    if [ "$RESULT" == "" ] ; then
        # empy result: Fail
        echo "Error, something failed..."
        exit 1
    else
        # Success
        echo "Success, $EVERYONE list crearted"
        echo "# Everyone list" > /etc/postfix/auto_aliases
        echo "$EVERYONE     $RESULT" >> /etc/postfix/auto_aliases
    fi
fi

# Obteniendo el listado de grupos que tienen mail definido
RESULT=`ldapsearch -h "$HOSTAD" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectClass=group)(mail=*))" dn | grep "dn: " | awk '{print $2}' | tr '\n' ' '`
for G in `echo $RESULT | xargs `; do
    # search the group dn
    GEM=`ldapsearch -h "$HOSTAD" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectClass=group)(distinguishedName=$G))" | grep "mail: " | awk '{print $2}'`

    if [ "$GEM" != "" ] ; then
        RESULT=`ldapsearch -h "$HOSTAD" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectCategory=person)(objectClass=user)(sAMAccountName=*)(memberOf=$G))" mail | grep "mail: " | awk '{print$2}' | tr '\n' ','`

        echo "# Group: $G" >> /etc/postfix/auto_aliases
        echo "$GEM   $RESULT" >> /etc/postfix/auto_aliases
    fi 
done

# updating postfix about the change
cd /etc/postfix && postmap auto_aliases
postfix reload
