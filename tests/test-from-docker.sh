#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2025 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - run make test $IP from inside a virgin docker container
#   - get a IP to test the server from the first command.

# update the system
apt-get update

# install make
apt-get install -y make swaks coreutils mawk bc curl netcat-openbsd

# move to working dir
cd /home/mailad/

# install base conf
make conf

# Ran tests
./tests/test.sh
