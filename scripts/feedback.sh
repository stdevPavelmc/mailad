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
source common.conf
source /etc/mailad/mailad.conf

# Infos to send
TO="pavelmc@gmail.com,$ADMINMAIL"
DATE=`date +"%Y/%m/%d %X %Z"`
VERSION=`cat CHANGELOG.md  | grep "##" | head -n 1 | cut -d ' ' -f 2`

# build the email
BODY=`mktemp`
echo "Hi!" > $BODY
echo " " >> $BODY
echo "This is an instance of MailAD giving you feedback!" >> $BODY
echo " " >> $BODY
echo "Date: $DATE" >> $BODY
echo "Domain: $DOMAIN" >> $BODY
echo "Mailserver: $HOSTNAME" >> $BODY
echo "Mail_Admin: $ADMINMAIL" >> $BODY
echo "MailAD_version: $VERSION" >> $BODY
echo " " >> $BODY
echo "EOT, thanks!" >> $BODY

# sent mail
swaks -s 127.0.0.1 --protocol SMTP -t "$TO" -f "$ADMINMAIL" --body "$BODY" --h-Subject "MailAD stats service." -ha
