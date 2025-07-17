#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goals:
#   - Create a resume of yesterday mail services
#   - Send it to the mail admin

# import config
source /etc/mailad/mailad.conf

# loading vars
PFSL=$(which pflogsumm)
OPTS="-d yesterday -e -i --iso-date-time --problems-first"
FILE="/var/log/mail.log /var/log/mail.log.1"
TMP=$(mktemp)

# check for soft
if [ "$PFSL" == "" ] ; then
    # no soft installed, warning
    echo "MailAD: Can't make the mail traffic summary because pflogsumm software is missing!" \
        | mail -s "MailAD: Yesterday's mail traffic Summary" ${SYSADMINS}
    exit 1
fi

# ejecutando
$PFSL $OPTS $FILE > $TMP

# emails to the sysadmins group or the mailadmin?
if [ "$SYSADMINS" == "" ] ; then
    SYSADMINS=$ADMINMAIL
fi

# enviar el correo
cat $TMP | mail -s "MailAD: Yesterday's mail traffic Summary" ${SYSADMINS}
rm $TMP
