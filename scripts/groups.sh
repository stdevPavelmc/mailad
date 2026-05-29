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

# Helper function to perform LDAP search with TLS handling
ldap_search() {
    local FILTER=$1
    local ATTRS=$2
    local EXTRA_ARGS=$3
    
    # Build base command with environment
    local CMD=""
    
    # Always use relaxed TLS verification for compatibility
    CMD="LDAPTLS_REQCERT=never "
    
    # Add ldapsearch command
    CMD="${CMD}ldapsearch -o ldif-wrap=no"
    
    # Add StartTLS if using standard LDAP (not LDAPS)
    if [[ "$LDAPURI" == ldap://* ]] && [ "$SECURELDAP" != "no" ]; then
        CMD="$CMD -ZZ"
    fi
    
    # Add remaining parameters
    CMD="$CMD -H \"$LDAPURI\" -D \"$LDAPBINDUSER\" -w \"$LDAPBINDPASSWD\" -b \"$LDAPSEARCHBASE\""
    
    if [ -n "$EXTRA_ARGS" ]; then
        CMD="$CMD $EXTRA_ARGS"
    fi
    
    CMD="$CMD \"$FILTER\""
    
    if [ -n "$ATTRS" ]; then
        CMD="$CMD $ATTRS"
    fi
    
    # Execute and return output
    eval $CMD 2>/dev/null
}

# Simplified LDAP search for single attribute
ldap_search_simple() {
    local FILTER=$1
    local ATTRIBUTE=$2
    
    LDAPTLS_REQCERT=never ldapsearch -o ldif-wrap=no -ZZ \
        -H "$LDAPURI" \
        -D "$LDAPBINDUSER" \
        -w "$LDAPBINDPASSWD" \
        -b "$LDAPSEARCHBASE" \
        "$FILTER" "$ATTRIBUTE" 2>/dev/null | grep "^$ATTRIBUTE:" | awk '{print $2}'
}

# Simplified LDAP search for multiple results
ldap_search_list() {
    local FILTER=$1
    local ATTRIBUTE=$2
    
    LDAPTLS_REQCERT=never ldapsearch -o ldif-wrap=no -ZZ \
        -H "$LDAPURI" \
        -D "$LDAPBINDUSER" \
        -w "$LDAPBINDPASSWD" \
        -b "$LDAPSEARCHBASE" \
        "$FILTER" "$ATTRIBUTE" 2>/dev/null | grep "^$ATTRIBUTE:" | awk '{print $2}'
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

echo "===> Starting group aliases generation" > $REPORT
echo "===> LDAP URI: $LDAPURI" >> $REPORT

# check if we need to get the everyone group
if [ -z "$EVERYONE" ] ; then
    # empty result: Fail
    echo "===> EVERYONE group disabled, skipping..." >> $REPORT
    echo "# Everyone list DISABLED in config" > /etc/postfix/aliases/auto_aliases
    echo " " >> /etc/postfix/aliases/auto_aliases
else
    echo "===> Trying to retrieve all the emails to form the EVERYONE list" >> $REPORT
    echo "===> Login into some of the '$HOSTAD' servers" >> $REPORT
    echo "===> as $LDAPBINDUSER" >> $REPORT

    # LDAP query - get all users with mail attribute
    RESULT=$(ldap_search_list "(&(objectCategory=person)(objectClass=user)(mail=*))" "mail" | grep "@$DOMAIN" | tr '\n' ',' | sed 's/,$//')

    if [ -z "$RESULT" ] ; then
        # empty result: Fail
        echo "===> Error, something failed or no users found..." >> $REPORT
        ERROR="ujum..."
    else
        # Success
        echo "===> Success, found users for EVERYONE list" >> $REPORT
        echo "# Everyone list" > /etc/postfix/aliases/auto_aliases
        echo "$EVERYONE:    $RESULT" >> /etc/postfix/aliases/auto_aliases
        echo " " >> /etc/postfix/aliases/auto_aliases
    fi
fi

# Getting the list of the groups in the search base that have email defined
echo "===> Searching for groups with email defined..." >> $REPORT
TEMP=$(mktemp)

ldap_search_list "(&(objectClass=group)(mail=*))" "dn" > $TEMP

declare -a RES
# parsing the group names, as it can be coded in base64 when non default charset is used
while IFS= read -r line ; do
    if [ -n "$line" ]; then
        # Check if line is base64 encoded (contains '::')
        if [[ "$line" == *"::"* ]]; then
            R=$(echo "$line" | awk -F':: ' '{print $2}' | base64 -d 2>/dev/null)
            if [ -z "$R" ]; then
                R=$(echo "$line" | awk -F':: ' '{print $2}')
            fi
        else
            R="$line"
        fi
        RES+=("$R")
    fi
done < $TEMP

rm $TEMP

echo "===> Found ${#RES[@]} groups with email defined" >> $REPORT

for G in "${RES[@]}"; do
    # Get the group email address
    GEM=$(ldap_search_simple "(&(objectClass=group)(distinguishedName=$G))" "mail")
    
    if [ -n "$GEM" ] ; then
        # Get all members of this group (direct members)
        RESULT=$(ldap_search_list "(&(objectCategory=person)(objectClass=user)(mail=*)(memberOf=$G))" "mail" | tr '\n' ',' | sed 's/,$//')
        
        # Also try nested groups (members that are groups themselves)
        NESTED_MEMBERS=$(ldap_search_list "(&(objectClass=group)(mail=*)(memberOf=$G))" "mail" | tr '\n' ',' | sed 's/,$//')
        
        # Combine direct and nested members
        if [ -n "$NESTED_MEMBERS" ]; then
            if [ -n "$RESULT" ]; then
                RESULT="$RESULT,$NESTED_MEMBERS"
            else
                RESULT="$NESTED_MEMBERS"
            fi
        fi
        
        echo "===> Parsing members of the group: $G (email: $GEM)" >> $REPORT
        echo "# Group: $G" >> /etc/postfix/aliases/auto_aliases
        if [ -n "$RESULT" ]; then
            echo "$GEM:    $RESULT" >> /etc/postfix/aliases/auto_aliases
            echo "===>   Found $(echo $RESULT | tr ',' '\n' | wc -l) members" >> $REPORT
        else
            echo "# WARNING: No members found for group $G" >> /etc/postfix/aliases/auto_aliases
            echo "$GEM:    postmaster@$DOMAIN" >> /etc/postfix/aliases/auto_aliases
            echo "===>   WARNING: No members found, redirecting to postmaster" >> $REPORT
        fi
        echo " " >> /etc/postfix/aliases/auto_aliases
    else
        echo "===> WARNING: Group $G has no email attribute, skipping" >> $REPORT
    fi 
done

# updating postfix about the change
echo "===> Updating postfix aliases..." >> $REPORT
cd /etc/postfix/aliases && postmap auto_aliases
postfix reload 2> /dev/null

FINALFP=$(getfp)
if [ "$INITIALFP" != "$FINALFP" ] ; then
    # need to send the email
    cat $REPORT
    rm $REPORT
fi

# check for the sysadmin group alias if set
if [ -n "$SYSADMINS" ] ; then
    # search for it on the aliases files
    R=$(cat /etc/postfix/aliases/auto_aliases /etc/postfix/aliases/alias_virtuales 2>/dev/null | awk '{print $1}' | grep "^$SYSADMINS:$")
    if [ -z "$R" ] ; then
        # build the email
        F=$(mktemp)
        echo "You have a SYSADMIN group configured to receive notifications in /etc/mailad/mailad.conf" > $F
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
        echo "PS: you will receive this email daily until you solve that issue." >> $F

        # sending the email to the ADMINMAIL declared
        cat $F | mail -s "MailAD need your attention: incomplete configuration detected!" ${ADMINMAIL}
        rm $F
    fi
fi

exit 0