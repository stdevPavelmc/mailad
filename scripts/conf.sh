#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Create the /etc/mailad folder and copy a default conf to it
#

# Create the dir with no warning
mkdir -p /etc/mailad/le 2> /dev/null

function make_it {
    echo "===> Installing default conf file en /etc/mailad/"
    cp mailad.conf /etc/mailad/
    rm /tmp/conf-already 2>/dev/null || exit 0
}

# Check if there is a MailAD config there
if [ -f /etc/mailad/mailad.conf ] ; then
    if [ -f /tmp/conf-already ] ; then
        # Just copy the default MailAD config
        make_it
    else
        echo "===> There is a mailad.conf file already in place!"
        echo "     so maybe you want to edit that one."
        echo ""
        echo "     If you just want to reset it with the default one"
        echo "     just run 'make conf' one more time to do it"
    fi
else
    # Just copy the default MailAD config
    make_it
fi
