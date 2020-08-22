#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Create the /etc/mailad folder and copy a default conf to it
#

# Create the dir with no warning
mkdir -p /etc/mailad/le &2> /dev/null

# check if there is a conf there
if [ -f /etc/mailad/mailad.conf ] ; then
    echo "===> There is a mailad.conf file already in place, move or erase it"
    echo "===> and run 'make conf' one more time to set a default one"
else
    # just compy the default
    echo "===> Installing default conf file en /etc/mailad/"
    cp mailad.conf /etc/mailad/
fi
