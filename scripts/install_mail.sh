#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goals:
#   - Check if there is pkgs already installed and warn & fail
#   - otherwise install the pkgs
#
# Notice: You need to provide a line like this after a success
#    echo "done" > install
#
# And not doing that after failure, that way it will not install on a unknown distro

# load the conf file
source /etc/mailad/mailad.conf
source common.conf

# this is the list to handle, will load it from the specific OS below
PKGS=""

# debian alike pkgs already installed check
function already_installed_debs {
    # list of pkgs are dynamically assigned by the code below

    # Check if there is already one of them installed and warn the user about it
    # offering a way to uninstall
    for p in `echo $PKGCOMMON | xargs` ; do
        # test if the pkg is installed
        LIST=`dpkg -l | grep $p`
        if [ "$LIST" != "" ] ; then
            # fail, some of the packages are installed
            echo "===> ERROR!"
            echo "     Some of the pkgs we are about to install are already installed"
            echo "     so, this system is dirty and it's not recommended to install it"
            echo "     here; or you can force a purge runnig: 'make install-purge'"
            echo "     and run 'make install' again"
            echo " "
            exit 1
        fi
    done
}

# debian packages install
function install_debs {
    # do it
    env DEBIAN_FRONTEND=noninteractive apt-get install $PKGS -y

    # checking for success
    R=$?
    if [ $R -ne 0 ] ; then
        # apt install failed on any way
        echo "===> Oops! Install failed, please check your repo configuration"
        exit 1
    fi
}

# loading the os-release file
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

        # check
        already_installed_debs

        # Install
        install_debs

        # Ad the clamav user to the amavis group, or it will not be able to reach emails to scan
        echo "===> Setting correct Perms for clamav and amavis."
        adduser clamav amavis
    fi

    # Debian Buster (10.x)
    if [ "$VERSION_CODENAME" == "buster"  ] ; then
        # notice
        echo "===> We are working with $PRETTY_NAME"

        # load the correct pkgs to be installed
        PKGS=${DEBIAN_PKGS}

        # check
        already_installed_debs

        # Install
        install_debs

        # Ad the clamav user to the amavis group, or it will not be able to reach emails to scan
        echo "===> Setting correct Perms for clamav and amavis."
        adduser clamav amavis
    fi
else
    # not known
    echo "==========================================================================="
    echo "ERROR: This linux box has a not known distro, if you feel this is wrong"
    echo "       please visit ttps://github.com/stdevPavelmc/mailad/ and raise an"
    echo "       issue about this."
    echo "==========================================================================="
    echo "       The install process will stop now"
    echo "==========================================================================="
fi
