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

    ## Distros check
    case "$VERSION_CODENAME" in
        bionic|focal)
            # load the correct pkgs to be installed
            craft_pkg_list "ubuntu"

            # remove the pkgs
            debian_remove_pkgs
            ;;
        buster)
            # load the correct pkgs to be installed
            craft_pkg_list "debian"

            # remove the pkgs
            debian_remove_pkgs
            ;;
        *)
            echo "==========================================================================="
            echo "ERROR: This linux box has a not known distro, if you feel this is wrong"
            echo "       please visit ttps://github.com/stdevPavelmc/mailad/ and raise an"
            echo "       issue about this."
            echo "==========================================================================="
            echo "       The un-install process will stop now"
            echo "==========================================================================="
            ;;
    esac
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
