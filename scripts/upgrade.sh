#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Check for upgrades in the /etc/mailad/mailad.conf file and do that if needed
#   - Create a backup of the files and folders in /var/backups/mailad
#   - Full remove and install from zero
#   - Restore the custom files from the latest backup

# import the common vars
source ./common.conf

# Control services, argument $1 is the action (start/stop)
function services() {
    for s in `echo $SERVICENAMES | xargs` ; do
        # do it
        echo "Doing $1 with $s..."
        systemctl --no-pager $1 $s
        sleep 2
        systemctl --no-pager status $s
    done
}

# advice
echo "===> Check if we have to upgrade the config"

# upgrade the user's mailad.conf
./scripts/confupgrade.sh

# do the backup
./scripts/backup.sh

# stoping services
services stop

# remove old install
make install-purge

# force a re-provision
make all

# do a custom restore
./scripts/custom_restore.sh
