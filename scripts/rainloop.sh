#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Install the rainloop webmail and try to configure most of the things it needs
#

# source the config
source common.conf
source /etc/mailad/mailad.conf

# variables
RAINLOOPURI=https://www.rainloop.net/repository/webmail/rainloop-community-latest.zip
WEBROOT=/var/www/html
RLCONF="${WEBROOT}/data/_data_/_default_"

#### some functions
# fix permissions on the webmail
function fixperms() {
    # fix perms and owners
    chown -R 33:33 ${WEBROOT}
    find ${WEBROOT} -type f -exec chmod 660 {} \;
    find ${WEBROOT} -type d -exec chmod 750 {} \;
}

# download the zip file if not there already
if [ ! -f /tmp/rainloop-community-latest.zip ] ; then
    # we need to download the zip file
    echo ">>> Downloading the rainloop zip"
    wget ${RAINLOOPURI} -O /tmp/rainloop-community-latest.zip
fi

# unzipping to final place
unzip -oqq /tmp/rainloop-community-latest.zip -d ${WEBROOT}
fixperms

# first request for create the local config
wget -q http://${WMHOST}/ -O /dev/null

# place template config file
cp -f ./var/rainloop/application.ini ${RLCONF}/configs/

# remove all default domains registered
rm ${RLCONF}/domains/*.ini
echo /dev/null > ${RLCONF}/domains/disabled

# copy the configured email domain config
cp ./var/rainloop/mailad.ini ${RLCONF}/domains/${DOMAIN}.ini

# create the RLPASSWD temop password
RLADMIN=`mktemp | cut -d '/' -f 3 | cut -d '.' -f 2`

# add RLPASSWD to the var list
VARS="${VARS} RLADMIN"

# replace vars
for f in "${RLCONF}/configs/application.ini" "${RLCONF}/domains/${DOMAIN}.ini";  do
    echo "===> Provisioning ${f}..."
    for v in `echo $VARS | xargs` ; do
        # get the var content
        CONTp=${!v}

        # escape possible "/" in there
        CONT=`echo ${CONTp//\//\\\\/}`

        sed -i s/"\_$v\_"/"$CONT"/g ${f}
    done
done

# fixt perms again
fixperms

# send email notice on default webmail admin credentials change
BODY=`mktemp`
echo "Hey!" >> $BODY
echo "" >> $BODY
echo "You installed a webmail on your server, we have configured it with the minimal settings for this domain," >> $BODY
echo "you can find the admin interface is on http://${WMHOST}/?admin the default credetials are this:" >> $BODY
echo "" >> $BODY
echo "User: ${RLADMIN}" >> $BODY
echo "Pass: 12345" >> $BODY
echo "" >> $BODY
echo "For security reasons you MUST login on the interface and change the webmail credentials (user/password)" >> $BODY
echo "don't let it for later, doit now, as this is a security issue you must address; you will see a yellow banner" >> $BODY
echo "on top of the page inviting you to change the credentials" >> $BODY
echo "" >> $BODY
echo "Thanks for using MailAD, the dev team." >> $BODY

echo ">>> Sending \"webmail auth credetials needs change\" email..."
swaks -s ${HOSTNAME} \
    --protocol SMTP \
    -t postmaster@${DOMAIN} \
    -f postmaster@${DOMAIN} \
    --h-Subject "ALERT: You webmail admin credentials, **Change it right now!**" \
    --body "$BODY" \
    -ha

# backup initial creds storage
echo "Initial webmail credentials:" > /etc/mailad/webmail.auth
echo "" >> /etc/mailad/webmail.auth
echo "User: ${RLADMIN}" >> /etc/mailad/webmail.auth
echo "Pass: 12345" >> /etc/mailad/webmail.auth
echo "" >> /etc/mailad/webmail.auth
echo "Webmail admin interface is at http://${WMHOST}/?admin" >> /etc/mailad/webmail.auth

# done
echo "Done"