#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Install dependencies of the provision process, depending on what OS and flavour you are in
#
# Notice: You need to provide a line like this after a success
#    echo "done" > deps
#
# And not doing that after failure, that way it will not install on a unknown distro

# default error when I hit a distro I can't identify
function os_not_supported {
    # not known
    echo "==========================================================================="
    echo "ERROR: This linux box has a not known distro, if you feel this is wrong"
    echo "       please visit ttps://github.com/stdevPavelmc/mailad/ and raise an"
    echo "       issue about this."
    echo "==========================================================================="
    echo "       The install process will stop now"
    echo "==========================================================================="

    # exit 1
    exit 1
}

# loading the os-release file
if [ -f /etc/os-release ] ; then
    # import the file
    source /etc/os-release

    ##### Distros check

    # Ubuntu bionic/focal (18.04/20.04) LTS & Debian Buster10.x
    if [ "$VERSION_CODENAME" == "bionic" -o "$VERSION_CODENAME" == "focal" -o "$VERSION_CODENAME" == "buster" ] ; then
        # notice
        echo "===> We are working with $PRETTY_NAME"

        # install dependencies
        apt update -q && apt install ldap-utils dnsutils

        # checking for success
        R=$?
        if [ $R -eq 0 ] ; then
            # success finish
            echo "done" > deps
        fi
    else
        # not supported OS
        os_not_supported
    fi

else
    # not supported OS
    os_not_supported
fi
