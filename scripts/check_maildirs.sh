#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later
#
# Goal:
#   - Cycle trough the list of maildirs in the mail storage and check
#       - there is not an user with that maildir?
#       - check the time of the latest modification time
#           - Warn the sysadmins about the folder, size and stalled time
#
# NOTE: This file does not link to the common.conf as this is run as standalone
# in the system...

# load conf files
source /etc/mailad/mailad.conf

# Generate the LDAPURI based on the settings of the mailad.conf file
if [ "$SECURELDAP" == "" -o "$SECURELDAP" == "no" -o "$SECURELDAP" == "No" ] ; then
    # not secure
    LDAPURI="ldap://${HOSTAD}:389/"
else
    # use a secure layer
    LDAPURI="ldaps://${HOSTAD}:636/"
fi

function isthere () {
    # Just one parameter:
    #   -  the maildir folder, aka the sAMAccountName property of an existing user
    #
    # return empty string or num of entries found

    # LDAP query
    ldapsearch -o ldif-wrap=no -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectClass=person)(sAMAccountName=${1}))" | grep "numEntries: " | awk '{print $3}'
}

function getdetails() {
    # just one parameter the particular maildir
    # return an array:
    #   - size and name
    #   - age in days

    # folder
    folder="${VMAILSTORAGE}/${1}"

    # get the data
    size=`du -sh ${folder}`
    age=`echo $((($(date +%s) - $(date +%s -r ${folder})) / 86400))`

    # return
    echo "${size}|${age}"
}

# vars
stalledlist=`mktemp`
warnlist=`mktemp`
erasedlist=`mktemp`
mail=0

# check every mailbox
for md in `ls ${VMAILSTORAGE} | xargs` ; do
    maildir="$VMAILSTORAGE/$md"

    # only dirs
    if [ -f "$maildir" ] ; then
        continue
    fi

    R=`isthere ${md}`
    if [ -z "$R" ] ; then
        mail=1
        data=`getdetails ${md}`
        days=`echo $data | cut -d '|' -f2`
        months=$((${days} / 30))
        size=`echo $data | cut -d '|' -f1 | awk '{print $1}'`

        # check to see to what list it's sended
        if [ ${days} -gt 273 ] ; then
            # older than 75 % of a year
            if [ ${days} -gt 365 ] ; then
                # delete!
                printf "%s months/(%s days)\t%s\t%s\n" "${months}" "${days}" "${size}" "${maildir}" >> ${erasedlist}

                # check for real deletion
                if [ "$MAILDIRREMOVAL" == "" -o "$MAILDIRREMOVAL" == "no" -o "$MAILDIRREMOVAL" == "No" ] ; then
                    # no deletion, warn abut the option
                    echo  " " >> ${erasedlist}
                    echo  "WARNING!: There was no deletion at all, as it's a dangerous action it" >> ${erasedlist}
                    echo  "          cames disbled by default; you can enable this option in your"  >> ${erasedlist}
                    echo  "          /etc/mailad/mailad.conf file setting the option"  >> ${erasedlist}
                    echo  "          MAILDIRREMOVAL='yes', remember to make a 'make force-provision'"  >> ${erasedlist}
                    echo  "          in your mailad local repo folder to apply the change."  >> ${erasedlist}
                else
                    # delete it for good
                    rm -rdf "${maildir}"
                fi
            else
                # warn
                printf "%s months/(%s days)\t%s\t%s\n" "${months}" "${days}" "${size}" "${maildir}" >> ${warnlist}
            fi
        else
            # stalled on time, just notice
            printf "%s months/(%s days)\t%s\t%s\n" "${months}" "${days}" "${size}" "${maildir}" >> ${stalledlist}
        fi
    fi
done

# must create the email?
if [ $mail -ne 0 ] ; then
    mail=`mktemp`
    echo "Greetings, " >> $mail
    echo " " >> $mail
    echo "We detected some maildir folder(s) left behind, that's normal when you" >> $mail
    echo "delete a user from the AD, we could remove it automatically but you (or" >> $mail
    echo "the user) may lose valuable information, so we will limit our action to" >> $mail
    echo "sending you a monthly reminder of the unused maildirs for you to take action" >> $mail
    echo " " >> $mail
    # stalled less than 10 months
    if [ -s "${stalledlist}" ] ; then
        echo "=== MAILBOXES THAT NEED ATTENTION ========================================" >> $mail
        printf "Age\t\t\tSize\tMaildir\n" >> $mail
        cat "${stalledlist}" >> $mail
        echo " " >> $mail
        echo " " >> $mail
    fi
    # warn zone > 10 < 12 months
    if [ -s "${warnlist}" ] ; then
        echo "=== MAILBOXES THAT WILL BE ERASED SOON! ==================================" >> $mail
        printf "Age\t\t\tSize\tMaildir\n" >> $mail
        cat "${warnlist}" >> $mail
        echo " " >> $mail
        echo " " >> $mail
    fi
    # deleted
    if [ -s "${erasedlist}" ] ; then
        echo "=== ERASED MAILBOXES =====================================================" >> $mail
        printf "Age\t\t\tSize\tMaildir\n" >> $mail
        cat "${erasedlist}" >> $mail
        echo " " >> $mail
        echo " " >> $mail
    fi

    echo "Please take action to save what's important and erase the" >> $mail
    echo "used maildirs before they are cleaned automatically." >> $mail
    echo " " >> $mail
    echo "Kindly, MailAD server." >> $mail
    echo " " >> $mail

    # emails to the sysadmins group or the mailadmin?
    if [ "$SYSADMINS" == "" ] ; then
        SYSADMINS=$ADMINMAIL
    fi

    # send the email
    cat $mail | mail -s "MailAD about unused maildir folders..." "$SYSADMINS"
fi