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

# import he common file with the list of default pkgs
source ./common.conf || source common.conf

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

    ## Distros check
    case "$VERSION_CODENAME" in
        bionic|focal|jammy|noble|buster|bullseye|bookworm)
            # install dependencies
            export DEBIAN_FRONTEND=noninteractive
            apt update -q
            apt-get install -qy ${COMMON_DEPS_PKGS}

            # checking for success
            R=$?
            if [ $R -eq 0 ] ; then
                # success finish
                echo "done" > deps
            else
                # install failed; collect some logs and save it for inspection
                debug_services

                # warn the user
                echo "==========================================================================="
                echo "ERROR: The update and install of the dependencies failed, this is mostly"
                echo "       a problem related to a bad configured repository or a not reacheable"
                echo "       one, please fix that and try again."
                echo "==========================================================================="
                echo "       The deps install process will stop now"
                echo "==========================================================================="

                # exit 1
                exit 1
            fi
            ;;
        *)
            # not supported OS
            os_not_supported
            ;;
    esac
else
    # not supported OS
    os_not_supported
fi
