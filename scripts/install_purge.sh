#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goals:
#   - Uninstall mail install pkgs and purge configs

# load the conf file
source /etc/mailad/mailad.conf
source common.conf

PKGS=""

# list of pkgs to install came from common.conf, pick the list to uninstall
if [ -f /etc/os-release ] ; then
    # import the file
    source /etc/os-release

    ##### Distros check

    # Ubuntu bionic/focal (18.04/20.04) LTS
    if [ "$VERSION_CODENAME" == "bionic" -o "$VERSION_CODENAME" == "focal" ] ; then
        # notice
        echo "===> We are working with $PRETTY_NAME"

        # load the correct pkgs to be installed
        PKGS=${UBUNTU_PKGS}
    fi

    # Debian Buster (10.x)
    if [ "$VERSION_CODENAME" == "buster"  ] ; then
        # notice
        echo "===> We are working with $PRETTY_NAME"

        # load the correct pkgs to be installed
        PKGS=${DEBIAN_PKGS}
    fi
else
    # not known
    echo "==========================================================================="
    echo "ERROR: This linux box has a not known distro, if you feel this is wrong"
    echo "       please visit ttps://github.com/stdevPavelmc/mailad/ and raise an"
    echo "       issue about this."
    echo "==========================================================================="
    echo "       The uninstall process will stop now"
    echo "==========================================================================="
fi

# add and sterisk at the end of the PKGS to wipe al related packages
P=`echo "$PKGCOMMON $PKGS" | sed s/" "/"* "/g`

# remove all pkgs letting apt build the tree
env DEBIAN_FRONTEND=noninteractive apt-get purge $P* -y

# autoremove some of the pkgs left over
env DEBIAN_FRONTEND=noninteractive apt autoremove -y
