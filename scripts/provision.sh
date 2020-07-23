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

# locate the source file (makefile or run by hand)
if [ -f mailad.conf ] ; then 
    source mailad.conf
    source common.conf
    PATHPREF=$(realpath "./")
else
    source ../mailad.conf
    source ../common.conf
    PATHPREF=$(realpath "../")
fi

# mailad install path
echo " "
echo "NOTICE: mailad install is: $PATHPREF"
echo " "

# postfix files to make postmap (not the path just the names)
PMFILES="lista_negra alias_virtuales auto_aliases"

# Control services, argument $1 is the action (start/stop)
function services() {
    for s in `echo $SERVICENAMES | xargs` ; do
        # do it
        echo "Doing $1 with $s..."
        sudo systemctl --no-pager $1 $s
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
sudo rsync -rv "${PATHPREF}/var/postfix/" /etc/postfix/
echo "Sync dovecot files..."
sudo rsync -rv "${PATHPREF}/var/dovecot/" /etc/dovecot/

# replace the vars in the folders
for f in `echo "/etc/postfix /etc/dovecot" | xargs` ; do
    echo "On folder $f..."
    for v in `echo $VARS | xargs` ; do
        # get the var content
        CONTp=${!v}
         #escape possible / in the files
        CONT=`echo ${CONTp//\//\\\\/}`
        # note
        echo "replace $v by \"$CONT\""

        sudo find "$f/" -type f -exec \
            sed -i s/"\_$v\_"/"$CONT"/g {} \;
    done
done

### install the group.sh scripts as a daily task and run it
# rm if there
rm -f /etc/cron.daily/mail_groups_update > /dev/null
# fix exec perms just in case it was lost
chmod +x "${PATHPREF}/scripts/groups.sh"
# create the link
ln -s "${PATHPREF}/scripts/groups.sh" /etc/cron.daily/mail_groups_update
# run it
/etc/cron.daily/mail_groups_update

# process some of the files, aka postfix postmap
PWD=`pwd`
cd /etc/postfix
for f in `echo "$PMFILES" | xargs` ; do
    sudo postmap $f
done
cd $PWD

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

# improve dh crypto for dovecot
dd if=/var/lib/dovecot/ssl-parameters.dat bs=1 skip=88 | openssl dhparam -inform der > /etc/dovecot/dh.pem

# start services
services start
