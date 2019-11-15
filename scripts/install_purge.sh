#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
#
# Goals:
#   - Uninstall mail install pkgs and purge configs

# locate the source file (makefile or run by hand)
if [ -f mailad.conf ] ; then 
    source mailad.conf
    source common.conf
else
    source ../mailad.conf
    source ../common.conf
fi

# list of pkgs to install came from common.conf

# iterate over the common name of the pkgs
for p in `echo $PKGCOMMON | xargs` ; do
    # do it
    sudo env DEBIAN_FRONTEND=noninteractive apt-get purge "$p*" -y
done

# autoremove some of the pkgs left over
sudo env DEBIAN_FRONTEND=noninteractive apt autoremove -y
