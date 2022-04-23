#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Install the nginx server and secure it as much as possible
#   - Install he php-fpm module and related php-dependencies

# source the config
source common.conf
source /etc/mailad/mailad.conf

# variables
WEBROOT=/var/www/html

# update and install
apt update
apt install ${NGINX_PHP} -yq

# configure nginx
cp -f ./var/nginx/default /etc/nginx/sites-available/default
cp -f ./var/nginx/ssl.conf /etc/nginx/
cp -f ./var/nginx/exploits_fight.conf /etc/nginx/

# replace template vars
for v in `echo $VARS | xargs` ; do
    # get the var content
    CONTp=${!v}

    # escape possible "/" in there
    CONT=`echo ${CONTp//\//\\\\/}`

    sed -i s/"\_$v\_"/"$CONT"/g /etc/nginx/sites-available/default
done

nginx -t || {
    echo ">>> ERROR, some of the nginx parameters are not correct, please go to"
    echo "https://t.me/MailAD_dev and report this issue."
    exit 1
}

# restart nginx and php-fpm
systemctl restart nginx
systemctl restart `systemctl list-units | grep php | grep fpm | awk '{print$1}'`
