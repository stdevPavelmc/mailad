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

# Capture the destination server or use the default
if [ "$1" == "" ] ; then
    SERVER="10.0.3.3"
else
    SERVER="$1"
fi

# internal vars
SOFT=`which swaks`
if [ "$SOFT" == "" ] ; then
    echo "======================================================"
    echo "ERROR: main tool not found: swaks"
    echo "======================================================"
    exit 1
fi

# others
LOG=./test.log
cat /dev/null > $LOG

# Reset the locales
LANGUAGE="en_US"
LC_ALL=C
LANG="en_US.UTF-8"
export LANGUAGE
export LC_ALL
export LANG

# advice
echo " "
echo "Using server: $SERVER"
echo " "

### Send an email to the mail admin: port 25
$SOFT -s $SERVER --protocol SMTP -t $ADMINMAIL >> $LOG
R=$?
if [ $R -ne 0 ] ; then
    # error
    echo "======================================================"
    echo "ERROR: can't send a mail to a valid local email via"
    echo "       using SMTP (25)"
    echo " "
    echo "COMMENT: it's expected that your server can receive"
    echo "         emails for it's domain, please check your"
    echo "         configuration"
    echo " "
    echo "Exit code: $R"
    echo "Logs follow"
    echo "======================================================"
    tail -n 20 $LOG
    exit 1
else
    # ok
    echo "===> Ok: You can receive emails for your domain"
fi

### Send an email to the mail admin with auth as sender
. $PATHPREF/.mailadmin.auth
$SOFT -s "$SERVER" -p 587 -tls -a PLAIN -au "$ADMINMAIL" -ap "$PASS" -t "$ADMINMAIL" -f "$ADMINMAIL"  >> $LOG
R=$?
if [ $R -ne 0 ] ; then
    # error
    echo "========================================================="
    echo "ERROR: can't relay a mail to a valid local recipient with"
    echo "       authentication (as sender) over SUBMISSION (587)"
    echo " "
    echo "COMMENT: it's expected that your server can receive"
    echo "         emails for it's domain via SUBMISSION from an"
    echo "         authenticated user, please check your"
    echo "         configuration"
    echo " "
    echo "Exit code: $R"
    echo "Logs follow"
    echo "========================================================="
    tail -n 20 $LOG
    exit 1
else
    # ok
    echo "===> Ok: Authenticated users can send local emails"
fi

### Send an email to the outside as a valid user with auth
$SOFT -s "$SERVER" -p 587 -tls -a PLAIN -au "$ADMINMAIL" -ap "$PASS" -t "fake@example.com" -f "$ADMINMAIL"  >> $LOG
R=$?
if [ $R -ne 0 ] ; then
    # error
    echo "=========================================================="
    echo "ERROR: can't send a mail to an outside recipient using"
    echo "       authentication (as sender) from a local user over"
    echo "       SUBMISSION (587)"
    echo " "
    echo "COMMENT: it's expected that your server can send an"
    echo "         email to the outside world via SUBMISSION from"
    echo "         an authenticated local user, please check your"
    echo "         configuration"
    echo " "
    echo "Exit code: $R"
    echo "Logs follow"
    echo "=========================================================="
    tail -n 20 $LOG
    exit 1
else
    # ok
    echo "===> Ok: Authenticated users can send emails to the outside world"
fi

### Send an email to a non-existent user, port 25
USER=`mktemp | cut -d '/' -f 3`
$SOFT -s $SERVER --protocol SMTP -t "$USER@$DOMAIN" >> $LOG
R=$?
if [ $R -ne 24 ] ; then
    # error
    echo "=========================================================="
    echo "ERROR: can send a mail to a non-valid local email via SMTP"
    echo " "
    echo "COMMENT: it's expected that your server bounce mails for"
    echo "         unknown recipients of your domain, please check"
    echo "         your configuration"
    echo " "
    echo "Exit code: $R"
    echo "Logs follow"
    echo "=========================================================="
    tail -n 20 $LOG
    exit 1
else
    # ok
    echo "===> Ok: Your server reject unknown recipients"
fi

### Send an email to an external user as an outsider domain, port 25 (open relay)
USER=`mktemp | cut -d '/' -f 3`
USER1=`mktemp | cut -d '/' -f 3`
$SOFT -s $SERVER --protocol SMTP -t "$USER@example" -f "$USER1@example" >> $LOG
R=$?
if [ $R -ne 24 ] ; then
    # error
    echo "========================================================"
    echo "ERROR: can relay a mail not for your domain and comming"
    echo "       from a external domain"
    echo " "
    echo "COMMENT: it's expected that your server does not relay"
    echo "         mails for other domains than the configured one"
    echo "         so you are an OPEN REALY server, and that is"
    echo "         bad, very bad, please check your configuration"
    echo " "
    echo "Exit code: $R"
    echo "Logs follow"
    echo "========================================================"
    tail -n 20 $LOG
    exit 1
else
    # ok
    echo "===> Ok: Your server is not and open relay"
fi

### Send an email to the mail admin: port SSMTP
$SOFT -s "$SERVER" --protocol SSMTP -t $ADMINMAIL >> $LOG
R=$?
if [ $R -ne 24 ] ; then
    # error
    echo "======================================================="
    echo "ERROR: can send a mail to a valid local email via SSMTP"
    echo "       with no authentication"
    echo " "
    echo "COMMENT: it's expected that your server bounce emails"
    echo "         via secure channel with no authentication;"
    echo "         by doing this mails for other domains, if so you are an OPEN"
    echo "         RELAY and that is bad, very bad, please check your"
    echo "         configuration"
    echo " "
    echo "Exit code: $R"
    echo "Logs follow"
    echo "======================================================"
    tail -n 20 $LOG
    exit 1
else
    # ok
    echo "===> Ok: The server rejects relaying mail though unauthenticated SMTPS"
fi

### Send an email as an user and auth as other (id spoofing)
$SOFT -s "$SERVER" -p 587 -tls -a PLAIN -au "$ADMINMAIL" -ap "$PASS" -t "$ADMINMAIL" -f "$USER@$DOMAIN" >> $LOG
R=$?
if [ $R -ne 24 ] ; then
    # error
    echo "========================================================="
    echo "ERROR: can send a mail to a valid local email using"
    echo "       SUBMISSION and a valid authentication that does"
    echo "       not match the sender address, please check your"
    echo "       configuration"
    echo " "
    echo "COMMENT: it's expected that your server bounce emails"
    echo "         from a sender that authenticated as another user"
    echo "         this is a id spoofing technique, please check"
    echo "         your configuration"
    echo " "
    echo "Exit code: $R"
    echo "Logs follow"
    echo "========================================================="
    tail -n 20 $LOG
    exit 1
else
    # ok
    echo "===> Ok: The server does NOT allow id spoofing"
fi

### Send an email to the mail admin with an attachment bigger than the allowed: port 25
MS=`echo "$MESSAGESIZE*1024*1024*1.2" | bc -q | cut -d '.' -f 1`
TMP=`mktemp`
dd if=/dev/zero of=$TMP bs=1 count="$MS" 2>/dev/null
$SOFT -s $SERVER --protocol SMTP -t $ADMINMAIL --attach "$TMP" >> $LOG
rm $TMP
R=$?
if [ $R -ne 0 ] ; then
    # error
    echo "======================================================"
    echo "ERROR: can send a mail to a valid local email via SMTP"
    echo "    with an attachement bigger than the allowed"
    echo " "
    echo "COMMENT: it's expected that your server bounce emails"
    echo "         that are bigger that the maximium allowed,"
    echo "         please check your configuration"
    echo " "
    echo "Exit code: $R"
    echo "Logs follow"
    echo "======================================================"
    tail -n 20 $LOG
    exit 1
else
    # ok
    echo "===> Ok: Mail size restriction is working"
fi