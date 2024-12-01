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

    # install the webmails
    if [ -z "$WEBMAIL_APP" -o "$WEBMAIL_APP" == "roundcube" ] ; then
        ./scripts/roundcube.sh
    elif [ "$WEBMAIL_APP" == "snappymail" ] ; then
        echo "[] roundcube"
        ./scripts/rainloop.sh
    else
        echo "Unknown webmail app: $WEBMAIL_APP"
    fi
else
    # make sure the webmails are disabled
    apt-get purge ${ROUNDCUBE_PKGS} -y
    rm -rdf ${SNAPPY_DIRS}
    apt-get remove ${WEBSERVER_PKGS} -y

    # clean
    apt-get autoremove -y
fi