#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
#
# Goals:
#   - Check if there is pkgs already installed and warn & fail
#   - otherwise install the pkgs

# locate the source file (makefile or run by hand)
if [ -f mailad.conf ] ; then 
    source mailad.conf
    source common.conf
else
    source ../mailad.conf
    source ../common.conf
fi

# list of pkgs to install came from common.conf

# Check if there is already one of them installed and warn the user about it
# offering a way to uninstall
for p in `echo $PKGCOMMON | xargs` ; do
    # test if the pkg is installed
    LIST=`dpkg -l | grep $p`
    if [ "$LIST" != "" ] ; then
        # fail, some of the packages are installed
        echo "ERROR!"
        echo "    Some of the pkgs we are about to install are already installed"
        echo "    so, this system is dirty and it's not recommended to install it"
        echo "    here; or you can force a purge runnig: 'make install-purge'"
        echo "    and run 'make install' again"
        echo " "
        exit 1
    fi
done

# do it
sudo env DEBIAN_FRONTEND=noninteractive apt install $PKGS -y
