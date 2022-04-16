#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Install the rainloop webmail and try to configure most of the things it needs
#

# rigor checks if some users gire it directly
if [ ! -f /etc/mailad/mailad.conf ] ; then
    # no config
    echo "======================================================="
    echo "ERROR: no /etc/mailad/mailad.conf file on this host?"
    echo ""
    echo "This script is intendend to be run by the 'make *' way"
    echo "in a MailAD standard install, if so you are jumping"
    echo "over a few steps, see the INSTALL.md file on the repo"
    echo "folder..."
    echo ""
    echo "Tip: if you are on a dedicated webmail host you must"
    echo "run 'make conf' and copy the /etc/mailad/mailad.conf"
    echo "file from the server to this host..."
    echo "======================================================="
    exit 1
fi
if [ ! -f ./common.conf ] ; then
    # no config
    echo "======================================================="
    echo "ERROR: no common.conf file on this folder?"
    echo ""
    echo "This script is intendend to be run by the 'make *' way"
    echo "in a MailAD standard install, if so you are jumping"
    echo "over a few steps, see the INSTALL.md file on the repo"
    echo "folder..."
    echo ""
    echo "Tip: don't run this script directly, see webmail"
    echo "options of a 'make' command for details"
    echo "======================================================="
    exit 1
fi

# source the config
source common.conf
source /etc/mailad/mailad.conf

# variables
RAINLOOPURI=https://www.rainloop.net/repository/webmail/rainloop-community-latest.zip
WEBROOT=/var/www/html
RLCONF="${WEBROOT}/data/_data_/_default_"

#### some functions
# fix permissions on the webmail
function fixrperms() {
    # fix perms and owners
    chown -R 33:33 ${WEBROOT}
    find ${WEBROOT} -type f -exec chmod 660 {} \;
    find ${WEBROOT} -type d -exec chmod 750 {} \;
}

# update and install
apt update
apt install ${RAINLOOPDEPS} -yq

# configure nginx
cp -f ./var/nginx/default /etc/nginx/sites-available/default
nginx -t || exit 1
systemctl restart nginx

# download the zip file if not there already
if [ ! -f /tmp/rainloop-community-latest.zip ] ; then
    # we need to download the zip file
    echo ">>> Downloading the rainloop zip"
    wget ${RAINLOOPURI} -O /tmp/rainloop-community-latest.zip
fi

# unzipping to final place
unzip -oqq /tmp/rainloop-community-latest.zip -d ${WEBROOT}
fixrperms

# first request for create the local config
wget -q http://${WMHOST}/ -O /dev/null

# place template config file
cp -f ./var/rainloop/application.ini ${RLCONF}/configs/

# remove all default domains registered
rm ${RLCONF}/domains/*.ini
echo /dev/null > ${RLCONF}/domains/disabled

# copy the configured email domain config
cp ./var/rainloop/mailad.ini ${RLCONF}/domains/${DOMAIN}.ini

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

# send email notice on default webmail admin credentials change
BODY=`mktemp`
echo "Hey!" >> $BODY
echo "" >> $BODY
echo "You installed a webmail on your server, we have configured it with the minimal settings for this domain," >> $BODY
echo "you can find the admin interface is on http://${WMHOST}/?admin you can find the initial credentials" >> $BODY
echo "on the /etc/mailad/mailad.conf file." >> $BODY
echo "" >> $BODY
echo "For security reasons you MUST login on the interface and update/change the webmail credentials (user/password)" >> $BODY
echo "don't let it for later, doit now, as this is a security issue you must address." >> $BODY
echo "" >> $BODY
echo "Thanks for using MailAD, the dev team." >> $BODY

echo ">>> Sending \"webmail auth credetials needs change\" email..."
swaks -s ${HOSTNAME} \
    --protocol SMTP \
    -t postmaster@${DOMAIN} \
    -f postmaster@${DOMAIN} \
    --h-Subject "ALERT: you **MUST** change the webmail credenatials right now" \
    --body "$BODY" \
    -ha

# done
echo "Done"