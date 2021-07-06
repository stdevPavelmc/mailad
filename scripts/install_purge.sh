#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goals:
#   - Uninstall pkgs installed by MailAD and purge configs

# Load the conf file
source /etc/mailad/mailad.conf
source common.conf

PKGS=""

# List of pkgs to install came from common.conf, pick the list to uninstall
if [ -f /etc/os-release ] ; then
    # Import the file
    source /etc/os-release

    ## Distro check
    case "$VERSION_CODENAME" in
        bionic|focal)
            # Load the correct pkgs to be installed
            craft_pkg_list "ubuntu"

            # Remove the pkgs
            debian_remove_pkgs
            ;;
        buster)
            # Load the correct pkgs to be installed
            craft_pkg_list "debian"

            # Remove the pkgs
            debian_remove_pkgs
            ;;
        *)
            echo "==========================================================================="
            echo "ERROR: This Linux box has an unknown distro, if you feel this is wrong"
            echo "       please visit https://github.com/stdevPavelmc/mailad/ and raise an"
            echo "       issue about this."
            echo "==========================================================================="
            echo "       The uninstall process will stop now"
            echo "==========================================================================="
            ;;
    esac
else
    # Unknown
    echo "==========================================================================="
    echo "ERROR: This Linux box has an unknown distro, if you feel this is wrong"
    echo "       please visit https://github.com/stdevPavelmc/mailad/ and raise an"
    echo "       issue about this."
    echo "==========================================================================="
    echo "       The uninstall process will stop now"
    echo "==========================================================================="
fi
