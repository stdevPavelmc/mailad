#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Test a few properties of the email server
#     see the README.md on this directory for deatils

# load conf file and detect the common one
    source /etc/mailad/mailad.conf
if [ -f mailad.conf ] ; then 
    source common.conf
    PATHPREF=$(realpath "./")
elif [ -f ../mailad.conf ] ; then
    source ../common.conf
    PATHPREF=$(realpath "../")
else
    echo "Can't find the common config file, aborting"
    exit 1
fi

# vars
CONFTEST=$PATHPREF/.mailad.test
CONFPATH=/etc/mailad/

# setup the env
echo "=== setup the test conf ==="
cd $CONFPATH
mv mailad.conf mailad.conf.old
cp $CONFTEST $CONFPATH/
