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

# loading the os-release file
if [ -f /etc/os-release ] ; then
    # import the file
    source /etc/os-release

    ## Distros check
    case "$VERSION_CODENAME" in
        bionic|focal)
            # load the correct pkgs to be installed
            craft_pkg_list "ubuntu"

            # check
            already_installed_debs

            # Install
            install_debs
            ;;
        buster)
            # load the correct pkgs to be installed
            craft_pkg_list "debian"

            # check
            already_installed_debs

            # Install
            install_debs
            ;;
        *)
            echo "==========================================================================="
            echo "ERROR: This linux box has a not known distro, if you feel this is wrong"
            echo "       please visit ttps://github.com/stdevPavelmc/mailad/ and raise an"
            echo "       issue about this."
            echo "==========================================================================="
            echo "       The install process will stop now"
            echo "==========================================================================="
            ;;
    esac

    # fix permissions for clamav into amavis if AV is enabled
    if [ "$ENABLE_AV" == "yes" -o "$ENABLE_AV" == "Yes" ] ; then
        # Ad the clamav user to the amavis group, or it will not be able to reach emails to scan
        echo "===> Setting correct Perms for clamav and amavis to work together"
        adduser clamav amavis
    fi
fi