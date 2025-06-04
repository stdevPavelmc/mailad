#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later
#
# Source and idea taken from here: https://www.howtoforge.com/how-to-automatically-add-a-disclaimer-to-outgoing-emails-with-altermime-postfix-on-debian-squeeze
# but modified to meet our goals
#
# Goals:
#   - Filter the emails and test if it's from my domain, if so, add the disclaimer

# include the local config
source /etc/mailad/mailad.conf

# Localize these.
INSPECT_DIR=/var/spool/filter
SENDMAIL=/usr/sbin/sendmail
ALTERMIME=/usr/bin/altermime

# disclaimer domain to filter
DISCLAIMER_DOMAINS=/etc/postfix/rules/disclaimer_domains

# Exit codes from <sysexits.h>
EX_TEMPFAIL=75
EX_UNAVAILABLE=69

# Clean up when done or when aborting.
trap "rm -f in.$$" 0 1 2 3 15

# Start processing.
cd $INSPECT_DIR || { echo $INSPECT_DIR does not exist; exit $EX_TEMPFAIL; }
cat >in.$$ || { echo Cannot save mail to file; exit $EX_TEMPFAIL; }

# Test if we have an html disclaimer to use, or use the default txt
DIS_FOLDER='/etc/mailad'
DIS_TXT="${DIS_FOLDER}/disclaimer.txt"
DIS_HTML="${DIS_FOLDER}/disclaimer.html.txt"

# arguments to altermine
TXT="--disclaimer=${DIS_TXT}"
HTML="--disclaimer-html=${DIS_TXT}"

# Failsafe, if no disclaimer exit
if [ -f ${DIS_TXT} ] ; then
    # ok, there is a disclaimer

    # HTML one?
    if [ -f ${DIS_HTML} ] ; then
        HTML="--disclaimer-html=${DIS_HTML}"
    fi

    # Obtain the domain source & destination of the message
    from_domain=$(grep -m 1 "From:" in.$$ | cut -d "<" -f 2 | cut -d ">" -f 1 | cut -d "@" -f 2)
    to_domain=$(grep -m 1 "To:" in.$$ | cut -d "<" -f 2 | cut -d ">" -f 1 | cut -d "@" -f 2)

    # result vars
    LOCAL=$(grep -wi "^${from_domain}$" ${DISCLAIMER_DOMAINS})
    DEST=$(grep -wi "^${to_domain}$" ${DISCLAIMER_DOMAINS})

    # work out
    if [ "$DISCLAIMER_REACH_LOCALS" == "yes" -o "$DISCLAIMER_REACH_LOCALS" == "Yes" ] ; then
        # if it's generated here attach the disclaimer, no matter the recipient 
        if [ "$LOCAL" ]; then
            ${ALTERMIME} --input=in.$$ $TXT $HTML || { echo Message content rejected; exit $EX_UNAVAILABLE; }
        fi
    else
        # only if generated here and not for here
        if [ "$LOCAL" -a -z "$DEST" ] ; then
            ${ALTERMIME} --input=in.$$ $TXT $HTML || { echo Message content rejected; exit $EX_UNAVAILABLE; }
        fi
    fi
fi

# exit gracefuly
$SENDMAIL "$@" <in.$$
exit $?
