#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goals:
#   - Provision the system followinf this tasks
#       - stop the services
#       - copy over the relevant config files
#       - setup the vars in the files
#       - post process the files if needed (postfix postmap)
#       - start the services
#       - run a series of tests
#           - services init wwith no fail
#           - send an email and verify it's placed on the users folder

# locate the conf files
source "/etc/mailad/mailad.conf"

# source the common config
source common.conf

# postfix files to make postmap, with full path
PMFILES="/etc/postfix/rules/lista_negra /etc/postfix/rules/everyone_list_check /etc/postfix/aliases/alias_virtuales"

# capture the local path
P=`pwd`

# Control services, argument $1 is the action (start/stop)
function services() {
    for s in `echo $SERVICENAMES | xargs` ; do
        # do it
        echo "Doing $1 with $s..."
        systemctl --no-pager $1 $s
        sleep 2
        systemctl --no-pager status $s
    done
}

# warna about a not supported dovecot version
function devecot_version {
    echo "==========================================================================="
    echo "ERROR: can't locate the dovecot version or it's a not supported one"
    echo "       detected version is: '$1' and it must be v2.2 or v 2.3"
    echo "==========================================================================="
    echo "       The install process will stop now, please fix that"
    echo "==========================================================================="

    # exit
    exit 1
}

#### Some previous processing of the vars

# calc the max size of the message from the MB paramater in the vars
t="$MESSAGESIZE"
MESSAGESIZE=`echo "$t*1024*1024*1.08" | bc -q | cut -d '.' -f 1`

# stop the runnig services
services stop

# detect the dovecot version to pick the right files to sync
DOVERSION=`dpkg -l | grep dovecot-core | awk '{print $3}' | cut -c3-5`
if [ "$DOVERSION" == "" ] ; then
    # error, must not be empty
    dovecot_version
else
    # ok, check if it's a supported version
    if [ "$DOVERSION" == "2.2" -o "$DOVERSION" == "2.3" ] ; then
        # supported versions
        echo "===> Detected a compatible dovecot version: $DOVERSION"
    else
        # error not compatible
        dovecot_version $DOVERSION
    fi
fi

# copy over the relevan files
echo "Sync postfix files..."
rsync -r ./var/postfix/ /etc/postfix/
echo "Sync dovecot files..."
rsync -r ./var/dovecot-${DOVERSION}/ /etc/dovecot/

# Generate the LDAPURI based on the settings of the mailad.conf file
if [ "$SECURELDAP" == "" -o "$SECURELDAP" == "no" -o "$SECURELDAP" = "No" ] ; then
    # not secure
    LDAPURI="ldap://${HOSTAD}:389/"
else
    # use a secure layer
    LDAPURI="ldaps://${HOSTAD}:636/"
fi

# add the LDAPURI to the vars
VARS="${VARS} LDAPURI"

# replace the vars in the folders
for f in `echo "/etc/postfix /etc/dovecot" | xargs` ; do
    echo " "
    echo "Provisioning on folder $f..."
    for v in `echo $VARS | xargs` ; do
        # get the var content
        CONTp=${!v}

        # escape possible "/" in there
        CONT=`echo ${CONTp//\//\\\\/}`

        find "$f/" -type f -exec \
            sed -i s/"\_$v\_"/"$CONT"/g {} \;
    done
done

# Special case variables with complicated scaping and specific files
#   $ESCLOCAL > /etc/postfix/filtro_loc
#   $ESCNATIONAL > /etc/postfix/filtro_nac
#
# escaped domain for the local restrictions on postfix
ESCDOMAIN=${DOMAIN//./\\\\\\.}
# escaped national or enterprise wide domain
ESCNATIONAL=${ESCNATIONAL//./\\\\\\.}

# action goes here
sed -i s/"_ESCDOMAIN_"/"$ESCDOMAIN"/g /etc/postfix/rules/filter_loc
sed -i s/"_ESCNATIONAL_"/"$ESCNATIONAL"/g /etc/postfix/rules/filter_nat

#notice
echo "===> Installing the daily group update task"

# install the group.sh scripts as a daily task and run it
# rm if there
rm -f /etc/cron.daily/mail_groups_update > /dev/null
# fix exec perms just in case it was lost
chmod +x "$P/scripts/groups.sh"
# create the link
ln -s "$P/scripts/groups.sh" /etc/cron.daily/mail_groups_update
# run it
/etc/cron.daily/mail_groups_update

#notice
echo "===> Installing the daily stats resume"

# configure the daily mail summary
rm -f /etc/cron.daily/daily_mail_resume > /dev/null
# fix exec perms just in case it was lost
chmod +x "$P/scripts/resume.sh"
# create the link
ln -s "$P/scripts/resume.sh" /etc/cron.daily/daily_mail_resume
# run it
/etc/cron.daily/daily_mail_resume

# Dovecot Sieve config: create the directory if not present
mkdir -p /var/lib/dovecot/sieve/ || exit 0

# Create a default junk filter if required to
if [ "$SPAM_FILTER_ENABLED" == "yes" -o "$SPAM_FILTER_ENABLED" == "Yes" -o "$SPAM_FILTER_ENABLED" == "YES" ] ; then
    # create the default filter
    FILE=/var/lib/dovecot/sieve/default.sieve
    echo 'require "fileinto";' > $FILE
    echo 'if header :contains "X-Spam-Flag" "YES" {' >> $FILE
    echo '    fileinto "Junk";' >> $FILE
    echo '}' >> $FILE

    # fix ownership
    chown -R vmail:vmail /var/lib/dovecot

    # compile it
    sievec /var/lib/dovecot/sieve/default.sieve
fi

# everyone list protection from outside (blank file as default)
FILE=/etc/postfix/rules/everyone_list_check
echo '# DO NOT EDIT BY HAND' > $FILE
echo '# this file is used to protect the inside everyone list from outside' >> $FILE
echo ' ' >> $FILE

if [ "$EVERYONE" != "" ] ; then
    # alias active

    # check no access from outside
    if [ "$EVERYONE_ALLOW_EXTERNAL_ACCESS" == "no" -o "$EVERYONE_ALLOW_EXTERNAL_ACCESS" == "No" ] ; then
        # need protection from outside
        echo "$EVERYONE         everyone_list" >> $FILE
    fi

    # grant access from outside
    if [ "$EVERYONE_ALLOW_EXTERNAL_ACCESS" == "yes" -o "$EVERYONE_ALLOW_EXTERNAL_ACCESS" == "Yes" ] ; then
        # disable the outside protection from the main.cf file
        T=`mktemp`
        cat /etc/postfix/main.cf | grep -v "veryone" > $T
        cat $T > /etc/postfix/main.cf
        rm $T
    fi
fi

# process postmap files
for f in `echo "$PMFILES" | xargs` ; do
    postmap $f
done

# start services
services start
