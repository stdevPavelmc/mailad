#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Send a mail to the creator with the following info
#       - Date
#       - Domain
#       - Mailserver name
#       - Mail admin
#       - MailAD "version" provisioned

# load configs
source /etc/mailad/mailad.conf
source common.conf
source /etc/os-release

# get installs stats
FIRST_INSTALL=$(grep "^FIRST_INSTALL=" $INSTFILE | cut -d'=' -f2)
INSTALLS=$(grep "^INSTALLS=" $INSTFILE | cut -d'=' -f2)

# Infos to send
TO="$AUTHOR,$ADMINMAIL"
DATE=$(date +"%Y/%m/%d %X %Z")
VERSION=$(cat CHANGELOG.md  | grep "##" | head -n 1 | cut -d ' ' -f 2)

# build the email
GIT_TREE=$(echo $(git rev-parse --abbrev-ref HEAD)/$(git rev-parse --short HEAD))
BODY=$(mktemp)
echo "Hi!" > $BODY
echo " " >> $BODY
echo "This is an instance of MailAD giving you feedback!" >> $BODY
echo " " >> $BODY
echo "Date: $DATE" >> $BODY
echo "Domain: $DOMAIN" >> $BODY
echo "Mailserver: $HOSTNAME" >> $BODY
echo "Mail_Admin: $ADMINMAIL" >> $BODY
echo "OS: $PRETTY_NAME" >> $BODY
echo "MailAD version: $VERSION" >> $BODY
echo "Git tree anchor: $GIT_TREE" >> $BODY
echo "First install: $FIRST_INSTALL"  >> $BODY
echo "Install count: $INSTALLS"  >> $BODY
echo " " >> $BODY
echo "EOT, thanks!" >> $BODY

# sent mail
send_email "MailAD stats service." "$TO" "$BODY"
