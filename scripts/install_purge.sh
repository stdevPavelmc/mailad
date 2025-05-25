#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020-2025 Pavel Milanes Costa <pavelmc@gmail.com>
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
    else
        # Un supported distro
        echo "==========================================================================="
        echo "ERROR: This linux box has an unknown distro, if you feel this is wrong"
        echo "       please visit https://github.com/stdevPavelmc/mailad/ and raise an"
        echo "       issue about this."
        echo "==========================================================================="
        echo "       The install process will stop now"
        echo "==========================================================================="
        exit 1
    fi

    # Remove the pkgs
    debian_remove_pkgs

    # remove packages from deps.sh
    apt-get purge -yq ${COMMON_DEPS_PKGS}

    # remove webmails packages and data if there
    apt-get purge -yq ${ROUNDCUBE_PKGS} ${SNAPPY_PKGS}
    rm -rdf ${SNAPPY_DIR} || true

    # Remove webmail
    apt-get purge -yq ${WEBSERVER_PKGS}

    # autoremove
    apt-get autoremove -yq
else
    # Unknown
    echo "==========================================================================="
    echo "ERROR: This Linux box has an unknown distro, if you feel this is wrong"
    echo "       please visit https://github.com/stdevPavelmc/mailad/ and raise an"
    echo "       issue about this."
    echo "==========================================================================="
    echo "       The uninstall process will stop now"
    echo "==========================================================================="
    exit 1
fi
