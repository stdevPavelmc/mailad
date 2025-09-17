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
source common.conf || source ../common.conf
source /etc/mailad/mailad.conf

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

# Do update, and upgrade only if not in mailad.cu domain
apt-get update ${APT_OPTS}
if [ $DOMAIN != "mailad.cu" ] ; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get upgrade ${APT_OPTS}
fi

# loading the os-release file
if [ -f /etc/os-release ] ; then
    # import the file
    source /etc/os-release

    # Notice on discontinued OS
    if [[ " ${OS_DISCONTINUED[*]} " =~ " $VERSION_CODENAME " ]]; then
        echo ""
        echo "##### WARNING  WARNING  WARNING ######################################"
        echo "#                                                                    #"
        echo "#    You are installing on a discontinued OS, this is dangerous,     #"
        echo "#      as the OS version my be outdated and vulnerable, please       #"
        echo "#           go here and read how to upgrade your OS:                 #"
        echo "#  https://github.com/stdevPavelmc/mailad/blob/develop/INSTALL.md    #"
        echo "#                                                                    #"
        echo "#                      You has been warned!                          #"
        echo "#                                                                    #"
        echo "####################################  WARNING  WARNING  WARNING ######"
        echo ""

        # delay notice
        echo "This is just a warning, it will be dismissed in 10 seconds, and installation will continue"
        sleep 10
    fi

    # Notice on legacy OS
    if [[ " ${OS_LEGACY[*]} " =~ " $VERSION_CODENAME " ]]; then
        echo ""
        echo "##### WARNING  WARNING  WARNING ######################################"
        echo "#                                                                    #"
        echo "#       You are installing on a legacy OS, be aware that it may      #"
        echo "#  be outdated soon, please go here and read how to upgrade your OS: #"
        echo "#  https://github.com/stdevPavelmc/mailad/blob/develop/INSTALL.md    #"
        echo "#                                                                    #"
        echo "#                      You has been warned!                          #"
        echo "#                                                                    #"
        echo "####################################  WARNING  WARNING  WARNING ######"
        echo ""

        # delay notice
        echo "This is just a warning, it will be dismissed in 10 seconds, and installation will continue"
        sleep 10
    fi

    if [[ " ${OS_WORKING[*]} " =~ " $VERSION_CODENAME " ]]; then
        # Load the correct pkgs to be installed
        export DEBIAN_FRONTEND=noninteractive
        apt-get install ${APT_OPTS} ${COMMON_DEPS_PKGS}

        # checking for success
        R=$?
        if [ $R -eq 0 ] ; then
            # success finish
            echo "done" > deps
        else
            # install failed
            echo "==========================================================================="
            echo "ERROR: The update and install of the dependencies failed, this is mostly"
            echo "       a problem related to a bad configured repository or a not reacheable"
            echo "       one, please fix that and try again."
            echo "==========================================================================="
            echo "       The deps install process will stop now"
            echo "==========================================================================="

            # exit
            exit 1
        fi
    else
        # no support
        os_not_supported
    fi
else
    # not supported OS
    os_not_supported
fi
