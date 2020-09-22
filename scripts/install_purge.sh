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

# list of pkgs to install came from common.conf

# remove all pkgs letting apt build the tree
env DEBIAN_FRONTEND=noninteractive apt-get purge $PKGCOMMON -y

# autoremove some of the pkgs left over
env DEBIAN_FRONTEND=noninteractive apt autoremove -y
