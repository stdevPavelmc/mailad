#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2024 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goals:
#   - Parse the webmails vars and act as needed
#

# source the common config
source common.conf

# locate the conf files
source "/etc/mailad/mailad.conf"

if [ "$WEBMAIL_ENABLED" == "yes" -o "$ENABLE_WEBMAILS" == "Yes" ] ; then
    # notice
    echo "===> Enabling Webmails!"

    # install the webmails
    apt-get install ${WEBSERVER_PKGS} -y

    # configure php post and upload size
    #
    # /etc/php/8.x/fpm/php.ini
    # post_max_size = 8M
    # upload_max_filesize = 2M
    #
    # Get active php-fpm version
    PHP_FPM_VER=$(dpkg -l | grep php-fpm | awk '{print $3}' | cut -d ":" -f2 | cut -d "+" -f1)
    PHP_INI="/etc/php/${PHP_FPM_VER}/fpm/php.ini"
    sed -i s/"^post_max_size.*$"/"post_max_size = ${MESSAGESIZE}M"/ ${PHP_INI}
    sed -i s/"^upload_max_filesize.*$"/"upload_max_filesize = ${MESSAGESIZE}M"/ ${PHP_INI}
    systemctl restart php${PHP_FPM_VER}-fpm

    # install the webmails
    if [ -z "$WEBMAIL_APP" -o "$WEBMAIL_APP" == "roundcube" ] ; then
        ./scripts/roundcube.sh
    elif [ "$WEBMAIL_APP" == "snappy" ] ; then
        ./scripts/snappy.sh
    else
        echo "===> WARNING!!!"
        echo "Unknown webmail app: $WEBMAIL_APP"
        echo "Maybe wrongly typed?"
    fi
else
    # notice
    echo "===> No Webmails!"
    echo "     purging any related config..."

    # make sure the webmails are disabled
    apt-get purge ${ROUNDCUBE_PKGS} ${SNAPPY_PKGS} ${WEBSERVER_PKGS} -y
    rm -rdf ${SNAPPY_DIR} 2>/dev/null

    # clean
    apt-get autoremove -y
fi
