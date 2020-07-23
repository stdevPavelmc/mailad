#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Test a few properties of the email server
#     see the README.md on this directory for deatils

# locate the source file (makefile or run by hand)
if [ -f mailad.conf ] ; then 
    source mailad.conf
    source common.conf
    PATHPREF=$(realpath "./")
elif [ -f ../mailad.conf ] ; then
    source ../mailad.conf
    source ../common.conf
    PATHPREF=$(realpath "../")
elif [ -f /root/mailad/mailad.conf ] ; then
    source /root/mailad/mailad.conf
    source /root/mailad/common.conf
    PATHPREF="/root/mailad"
else
    echo "Can't find the config file, aborting"
    exit 1
fi

# help if not a valid command
if [ "$1" != "" -a "$1" != "up" -a "$1" != "down" ] ; then
    # Warn and show breif help
    echo "You must pass one argument 'up' or 'down'"
    echo "    up: setup the env for tests"
    echo "  down: reset the env to defaults"
    echo " "
fi

if [ "$1" == "" -o "$1" == "up" ] ; then
    # prepare the env for the tests
    ACTION="up"
fi

if [ "$1" == "down" ] ; then
    # prepare the env for the tests
    ACTION="down"
fi

# vars
CONF=$PATHPREF/mailad.conf
CONFTEST=$PATHPREF/.mailad.test

## Action goes here

# set up the environment
if [ "$ACTION" == "up" ] ; then
    # setup the env
    echo "=== setup the test conf ==="

    rm $CONF 2> /dev/null
    cp $CONFTEST $CONF
fi

# step down the environment
if [ "$ACTION" == "down" ] ; then
    # step down the env
    echo "=== reset the test conf ==="

    rm $CONF 2> /dev/null
    FILE=mailad.conf
    git checkout $(git rev-list -n 1 HEAD -- "$FILE")^ -- "$FILE"
fi
