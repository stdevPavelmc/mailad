#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Check/setup/create the SS certificates
#   - Call the nginx & php install and config
#   - Call the webmail install
#

# rigor checks...
if [ ! -f /etc/mailad/mailad.conf ] ; then
    # no config
    echo "======================================================="
    echo "ERROR: no /etc/mailad/mailad.conf file on this host?"
    echo ""
    echo "This script is intendend to be run by the 'make *' way"
    echo "in a MailAD standard install, if not you are jumping"
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
    echo "in a MailAD standard install, if not you are jumping"
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

# check for certs, import them from /etc/mailad/mailad/le if there or create them
./scripts/gen_cert.sh

# install the webserver
./scripts/setup_nginx.sh

# install some utils
apt update
apt install ${WMUTILS} -yq

# install the selected webmail
if [ "${WMINSTALL}" == "yes" -o "${WMINSTALL}" == "Yes" ] ; then
    # run the webmail install but we need to know which one
    if [ "${WMCHOICE}" == "rainloop" ] ; then
        ./scripts/rainloop.sh
    fi
else
    echo ">>> No webmail will be installed"
fi
