#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goals:
#   - Check, warn & fail if there are some pkgs already installed,
#   - otherwise install the pkgs
#
# Notice: You need to provide a line like this after a success
#    echo "done" > install
#
# And do nothing in case of failure, this prevents installation on an unknown distro

# Load the conf file
source /etc/mailad/mailad.conf
source common.conf

# This is the list to handle, will be loaded from the specific OS below
PKGS=""

# Loading the os-release file
if [ -f /etc/os-release ] ; then
    # import the file
    source /etc/os-release

    # Distros check
    if [[ " ${OS_WORKING[*]} " =~ " $VERSION_CODENAME " ]]; then
        # Ubuntu
        if [[ " ${OS_WORKING_U[*]} " =~ " $VERSION_CODENAME " ]]; then
            craft_pkg_list "ubuntu"
        fi

        # Debian
        if [[ " ${OS_WORKING_D[*]} " =~ " $VERSION_CODENAME " ]]; then
            craft_pkg_list "debian"
        fi

        # Check
        already_installed_debs

        # Install
        install_debs
    else
        # Un supported distro
        echo "==========================================================================="
        echo "ERROR: This linux box has an unknown distro, if you feel this is wrong"
        echo "       please visit https://github.com/stdevPavelmc/mailad/ and raise an"
        echo "       issue about this."
        echo "==========================================================================="
        echo "       The install process will stop now"
        echo "==========================================================================="
    fi

    # Fix permissions for clamav into amavis if AV is enabled
    if [ "$ENABLE_AV" == "yes" -o "$ENABLE_AV" == "Yes" ] ; then
        # Add the clamav user to the amavis group, or it will not be able to reach emails to scan
        echo "===> Setting correct Perms for clamav and amavis to work together"
        adduser clamav amavis
    fi
fi
