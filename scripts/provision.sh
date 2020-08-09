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

# check the root of the repository
# try to use the localpath
if [ -f ./mailad.conf -a -f ./mailad.conf -a -f ./Features.md ] ; then
    # it appears that it's located on the repo
    PATHPREF=`pwd`
else
    # try the default path
    if [ -d "/root/mailad" ] ; then
        # default recommended path
        PATHPREF="/root/mailad"
    else
        # warn about that we can't locate the default path
        echo "==========================================================================="
        echo "ERROR: can't locate the default path for the repository, the default path"
        echo "       is /root/mailad/ this error is common when you cloned the repository"
        echo "       not in this path"
        echo "==========================================================================="
        echo "       The install process will stop now, please fix that"
        echo "==========================================================================="

        # exit
        exit 1
    fi
fi

# source the common config
source "${PATHPREF}/common.conf"

# mailad install path
echo " "
echo "NOTICE: mailad install is: $PATHPREF"
echo " "

# postfix files to make postmap, with full path
PMFILES="/etc/postfix/rules/lista_negra /etc/postfix/rules/everyone_list_check /etc/postfix/aliases/alias_virtuales"

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

#### Some previous processing of the vars

# calc the max size of the message from the MB paramater in the vars
t="$MESSAGESIZE"
MESSAGESIZE=`echo "$t*1024*1024*1.08" | bc -q | cut -d '.' -f 1`

# stop the runnig services
services stop

# copy over the relevan files
echo "Sync postfix files..."
rsync -rv "${PATHPREF}/var/postfix/" /etc/postfix/
echo "Sync dovecot files..."
rsync -rv "${PATHPREF}/var/dovecot/" /etc/dovecot/

# replace the vars in the folders
for f in `echo "/etc/postfix /etc/dovecot" | xargs` ; do
    echo " "
    echo "On folder $f..."
    for v in `echo $VARS | xargs` ; do
        # get the var content
        CONTp=${!v}

        # escape possible "/" in there
        CONT=`echo ${CONTp//\//\\\\/}`

        # note
        echo "replace $v by \"$CONT\""

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

### install the group.sh scripts as a daily task and run it
# rm if there
rm -f /etc/cron.daily/mail_groups_update > /dev/null
# fix exec perms just in case it was lost
chmod +x "${PATHPREF}/scripts/groups.sh"
# create the link
ln -s "${PATHPREF}/scripts/groups.sh" /etc/cron.daily/mail_groups_update
# run it
/etc/cron.daily/mail_groups_update

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
