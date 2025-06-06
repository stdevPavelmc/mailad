#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goals:
#   - Provision the system following this tasks
#       - stop the services
#       - copy over the relevant config files
#       - setup the vars in the files
#       - post process the files if needed (postfix postmap)
#       - start the services
#       - run a series of tests
#           - services init with no fail
#           - send an email and verify it's placed on the users folder

# source the common config
source common.conf

# locate the conf files
source "/etc/mailad/mailad.conf"

# postfix files to make postmap, with full path
PMFILES="/etc/postfix/rules/lista_negra /etc/postfix/rules/everyone_list_check /etc/postfix/aliases/alias_virtuales"

# use apt in non interactive way
export DEBIAN_FRONTEND=noninteractive

# capture the local path
P=`pwd`

#### Some previous processing of the vars

# Calc the max size of the message from the MB parameter in the vars
# plus a little percent to allow for encoding grow
t="$MESSAGESIZE"
MESSAGESIZE=`echo $(( $t * 1132462))`

# detect the dovecot version to pick the right files to sync
DOVERSION=`dpkg -l | grep dovecot-core | awk '{print $3}' | cut -c3-5`
if [ "$DOVERSION" == "" ] ; then
    # error, must not be empty
    dovecot_version
else
    # ok, check if it's a supported version
    if [ "$DOVERSION" == "2.2" -o "$DOVERSION" == "2.3" ] ; then
        # supported versions
        echo "===> Detected a compatible dovecot version: $DOVERSION"
    else
        # error not compatible
        dovecot_version $DOVERSION
    fi
fi

# copy over the relevan files
echo "===> Sync postfix files..."
rsync -r ./var/postfix/ /etc/postfix/
echo "===> Sync dovecot files..."
rsync -r ./var/dovecot-${DOVERSION}/ /etc/dovecot/
echo "===> Sync amavis files..."
rsync -r ./var/amavis/ /etc/amavis/

# Check the SYSADMINS var and populate it if needed
if [ -z "$SYSADMINS" ] ; then
    SYSADMINS=$ADMINMAIL
fi

# add the escaped sysadmins var
ESC_SYSADMINS=`echo $SYSADMINS | sed s/"@"/"\\\@"/`

# get the LDAP URI
LDAPURI=`get_ldap_uri`

# check if the optional mail storage is enabled
MBSUBFOLDER=''
if [ "${USE_MS_SUBFOLDER}" == "yes" -o "${USE_MS_SUBFOLDER}" == "Yes" ] ; then
    # set the var, must end in /, a escaped /
    MBSUBFOLDER='%{ldap:physicalDeliveryOfficeName:}/'
fi

# add the LDAPURI & ESC_SYSADMINS to the vars
VARS="${VARS} LDAPURI ESC_SYSADMINS MBSUBFOLDER"

# replace the vars in the folders
for f in `echo "/etc/postfix /etc/dovecot /etc/amavis" | xargs` ; do
    echo "===> Provisioning $f..."
    for v in `echo $VARS | xargs` ; do
        # get the var content
        CONTp=${!v}

        # escape possible "/" in there
        CONT=`echo ${CONTp//\//\\\\/}`

        find "$f/" -type f -exec \
            sed -i s/"\_$v\_"/"$CONT"/g {} \;
    done
done

# force dovecot conf perms
chmod 0644 /etc/dovecot/conf.d/*

# Special case variables with complicated scaping and specific files
#   $ESCLOCAL > /etc/postfix/filtro_loc
#   $ESCNATIONAL > /etc/postfix/filtro_nac
#
# escaped domain for the local restrictions on postfix
ESCDOMAIN=${DOMAIN//./\\\\\\.}
# escaped national or enterprise wide domain
ESCNATIONAL=${ESCNATIONAL//./\\\\\\.}

# action goes here
sed -i s/"_ESCDOMAIN_"/"$ESCDOMAIN"/g /etc/postfix/rules/filter_loc
sed -i s/"_ESCNATIONAL_"/"$ESCNATIONAL"/g /etc/postfix/rules/filter_nat

#notice
echo "===> Installing the daily group update task"

# install the group.sh scripts as a daily task and run it
# rm if there
rm -f /etc/cron.daily/mail_groups_update > /dev/null
# fix exec perms just in case it was lost
chmod +x "$P/scripts/groups.sh"
# create the link
ln -s "$P/scripts/groups.sh" /etc/cron.daily/mail_groups_update
# run it
/etc/cron.daily/mail_groups_update

#notice
echo "===> Installing the daily stats resume"

# configure the daily mail summary
rm -f /etc/cron.daily/daily_mail_resume > /dev/null
# fix exec perms just in case it was lost
chmod +x "$P/scripts/resume.sh"
# create the link
ln -s "$P/scripts/resume.sh" /etc/cron.daily/daily_mail_resume

# configure the left behind maildirs check/alert/warn
rm -f /etc/cron.monthly/check_maildirs > /dev/null
# fix exec perms just in case it was lost
chmod +x "$P/scripts/check_maildirs.sh"
# create the link
ln -s "$P/scripts/check_maildirs.sh" /etc/cron.monthly/check_maildirs

# Dovecot Sieve config: create the directory if not present
mkdir -p /var/lib/dovecot/sieve/ || exit 0

# Create a default junk filter if required to
if [ "$DOVECOT_SPAM_FILTER_ENABLED" == "yes" -o "$DOVECOT_SPAM_FILTER_ENABLED" == "Yes" -o "$DOVECOT_SPAM_FILTER_ENABLED" == "YES" ] ; then
    # create the default filter
    FILE=/var/lib/dovecot/sieve/default.sieve
    echo 'require "fileinto";' > $FILE
    echo 'if header :contains "X-Spam-Flag" "YES" {' >> $FILE
    echo '    fileinto "Junk";' >> $FILE
    echo '}' >> $FILE

    # fix ownership
    chown -R vmail:vmail /var/lib/dovecot

    # compile it
    sievec /var/lib/dovecot/sieve/default.sieve
fi

# everyone list protection from outside (blank file as default)
FILE=/etc/postfix/rules/everyone_list_check
echo '# DO NOT EDIT BY HAND' > $FILE
echo '# this file is used to protect the inside everyone list from outside' >> $FILE
echo ' ' >> $FILE

if [ "$EVERYONE" != "" ] ; then
    # alias active

    # check no access from outside
    if [ "$EVERYONE_ALLOW_EXTERNAL_ACCESS" == "no" -o "$EVERYONE_ALLOW_EXTERNAL_ACCESS" == "No" ] ; then
        # need protection from outside
        echo "$EVERYONE         everyone_list" >> $FILE
    fi

    # grant access from outside
    if [ "$EVERYONE_ALLOW_EXTERNAL_ACCESS" == "yes" -o "$EVERYONE_ALLOW_EXTERNAL_ACCESS" == "Yes" ] ; then
        # disable the outside protection from the main.cf file
        T=`mktemp`
        cat /etc/postfix/main.cf | grep -v "veryone" > $T
        cat $T > /etc/postfix/main.cf
        rm $T
    fi
fi

# process postmap files
for f in `echo "$PMFILES" | xargs` ; do
    postmap $f
done

# local aliases and redirect to sysadmins all local mail
ALIASES="/etc/aliases"
rm -rdf $ALIASES || exit 0
echo "# File modified at provision time, #MailAD" > $ALIASES
echo "postmaster:       root" >> $ALIASES
echo "clamav:		root" >> $ALIASES
echo "amavis:       root" >> $ALIASES
echo "spamasassin:       root" >> $ALIASES
echo "root:     $SYSADMINS" >> $ALIASES
# apply changes
newaliases

# check for SPF activation
if [ "$ENABLE_SPF" == "no" -o "$ENABLE_SPF" == "No" -o -z "$ENABLE_SPF" ] ; then
    # disable SPF
    FILE="/etc/postfix/main.cf"
    cat $FILE | grep -v "spf" > /tmp/1

    # dump
    cat /tmp/1 > $FILE

    # notice
    echo "===> Disabing SPF as requested by the config"
fi

### check if AV activation is needed
if [ "$ENABLE_AV" == "no" -o "$ENABLE_AV" == "No" -o -z "$ENABLE_AV" ] ; then
    # disable AV services to save resources
    disable_av

    # remove the link for the test of AV activation
    rm -f /etc/cron.hourly/av_filter_on_clamav_alive || exit 0
else
    # subject config file
    FILE="/etc/clamav/freshclam.conf"

    ### Configure the services
    if [ "$USE_AV_ALTERNATE_MIRROR" != "no" -o "$USE_AV_ALTERNATE_MIRROR" != "No" -o "$USE_AV_ALTERNATE_MIRROR" != "" ] ; then
        # check if the alternates mirror haves an address
        R=`echo "${AV_ALT_MIRRORS}" | grep -P "(.*\.)+"`
        if [ -z "$R" ] ; then
            # no alternate mirror detected on the config file
            echo "========================================================================"
            echo "                             WARNING NOTICE!!!"
            echo " "
            echo "You especified an alternate mirror on the AV, but we can't detect a"
            echo "valid address on that variable, please check 'AV_ALT_MIRRORS' in the"
            echo "config file"
            echo " "
            echo "We will continue, but no alternate AV mirror will be set in palce, do"
            echo "not abort the install, Intead let it finish, fix the issue and make a"
            echo "'make force-provision' to apply the new changes"
            echo " "
            echo "======================================================================="
            sleep 10
        else
            # must activate the alternate mirror, but first clean the actual values
            cat $FILE | grep -v DatabaseMirror | grep -v PrivateMirror | grep -v DatabaseCustomURL | grep -v Proxy > /tmp/1
            cat /tmp/1 > $FILE

            # dump the config
            for M in `echo "${AV_ALT_MIRRORS}" | xargs` ;  do
                # if a proxy is set remove the 'http://' and 'https://' from the variables

                if [ ! -z "$PROXY_HOST" -a ! -z "$PROXY_PORT" ] ; then
                    # general proxy, but we must use it ?
                    if [ "$AV_UPDATES_USE_PROXY" == "yes" -o "$AV_UPDATES_USE_PROXY" == "Yes" ] ; then
                        # ok, by all means add proxy remove the prefix
                        Mm=`echo ${M} | sed s/'http:\/\/'//g | sed s/'https:\/\/'//g`
                        echo "DatabaseMirror ${Mm}" >> $FILE
                    else
                        # no proxy
                        echo "DatabaseMirror ${M}" >> $FILE
                    fi
                else
                    # no proxy
                    echo "DatabaseMirror ${M}" >> $FILE
                fi
            done
        fi
    fi

    ### configure proxy if needed
    if [ ! -z "$PROXY_HOST" -a ! -z "$PROXY_PORT" ] ; then
        # general proxy, but we must use it ?
        if [ "$AV_UPDATES_USE_PROXY" == "yes" -o "$AV_UPDATES_USE_PROXY" == "Yes" ] ; then
            # ok, by all means add proxy
            echo "HTTPProxyServer $PROXY_HOST" >> $FILE
            echo "HTTPProxyPort $PROXY_PORT" >> $FILE

            # check for auth
            if [ ! -z "$PROXY_USER" -a ! -z "$PROXY_PASS" ] ; then
                echo "HTTPProxyUsername $PROXY_USER" >> $FILE
                echo "HTTPProxyPassword $PROXY_PASS" >> $FILE
            fi
        fi
    fi

    # increase the Timeouts
    cat $FILE | grep -v ConnectTimeout | grep -v ReceiveTimeout > /tmp/1
    cat /tmp/1 > $FILE
    echo "ConnectTimeout 300" >> $FILE
    echo "ReceiveTimeout 3600" >> $FILE

    ### Activating the services
    enable_av

    # set the hourly task to activate the filtering when fresclam end the update
    rm -f /etc/cron.hourly/av_filter_on_clamav_alive || exit 0
    ln -s "$P/var/clamav/activate_clamav_on_alive.sh" /etc/cron.hourly/av_filter_on_clamav_alive
    echo "===> AV filtering provision is in place, but activation is delayed, we must wait for freshclam"
    echo "===> to update the AV database before enabling it or you will lose emails in the mean time"
    echo "===> you will be notified by mail when it's activated."

    # set asked perms to the freshclam file as debian12 & ubuntu24 complains about it
    chmod 0700 ${FILE}
    chown freshclam.adm ${FILE}
fi

### SPAMD setting
# maintenance service cron
SPAMD_MTT_FILE=/etc/default/spamassassin

# Fail safe
if [ -z "$SPAMD_VERSION"  ] ; then
    # different file
    SPAMD_VERSION=$(dpkg -l spamassassin | grep spam | awk '{print $3}' | cut -d '.' -f 1)
fi

# select the correct file
if [ "$SPAMD_VERSION" == "4" ] ; then
    # different file
    SPAMD_MTT_FILE=/etc/cron.daily/spamassassin

    # disable converting the maintenance into a systemd timer in moder version
    touch /etc/spamassassin/skip-timer-conversion
fi

# do the dance
if [ "$ENABLE_SPAMD" == "yes" -o "$ENABLE_SPAMD" == "Yes" ] ; then
    # enable the SPAMD

    # notice
    echo "===> Enabling SpamAssassin"

    # Copy the template file
    cp "${P}/var/spamassassin/spamassassin-${SPAMD_VERSION}" $SPAMD_MTT_FILE

    # set the CRON maintenace task
    sed -i s/"^CRON=.*$"/"CRON=1"/ ${SPAMD_MTT_FILE}
    
    # configure SMA filtering on amavis if not already active
    FILE="/etc/amavis/conf.d/15-content_filter_mode"
    ACTIVE=$(grep "^#@bypass_spam_checks_maps.*" $FILE)
    if [ ! -z "$ACTIVE" ] ; then
        # not active, activating
        sed -i s/"#@bypass_spam_checks_maps"/"@bypass_spam_checks_maps"/g $FILE

        # reload services
        systemctl restart amavis
    fi

    ### configure proxy if needed
    SA_PROXY=""

    # build the chain
    if [ "$PROXY_HOST" -a "$PROXY_PORT" ] ; then
        # notice
        echo "===> SpamAssassin need proxy"

        # check for auth
        if [ "$PROXY_USER" -a "$PROXY_PASS" ] ; then
            # notice
            echo "===> SpamAssassin proxy needs auth"
            SA_PROXY="http://${PROXY_USER}:${PROXY_PASS}@${PROXY_HOST}:${PROXY_PORT}/"
        else
            SA_PROXY="http://${PROXY_HOST}:${PROXY_PORT}/"
        fi
    fi

    # set it up if needed
    if [ "${SA_PROXY}" ] ; then
        # notice
        echo "===> Setting the SpamAssassin proxy in the default config file"

        # clean proxy if there and then set
        sed -i s/"^.*SA_PROXY=.*$"/"SA_PROXY=${SA_PROXY}"/g ${SPAMD_MTT_FILE}
    fi

    # enable the service
    enable_sa
else
    # disable the SPAMD

    # disable spamassasin on amavis
    FILE="/etc/amavis/conf.d/15-content_filter_mode"
    ACTIVE=$(grep "^@bypass_spam_checks_maps.*" $FILE)
    if [ ! -z "$ACTIVE" ] ; then
        # not active, activating
        sed -i s/"@bypass_spam_checks_maps"/"#@bypass_spam_checks_maps"/g $FILE

        # reload services
        systemctl restart amavis
    fi

    # disable the service
    disable_sa

    # remove the daily job if there
    test -x "${SPAMD_MTT_FILE}" && rm -f "${SPAMD_MTT_FILE}"
fi

### altermime
if [ "$ENABLE_DISCLAIMER" == "yes" -o "$ENABLE_DISCLAIMER" == "Yes" ] ; then
    # enable disclaimer
    echo "===> Disclaimer enabled on config, installing altermime..."

    apt-get install $DEBIAN_DISCLAIMER_PKGS -y

    # notice
    echo "===> Enabling Altermime tweaks for disclaimer addition"

    # creating the users's space
    useradd -r -c "Postfix Filters" -d /var/spool/filter filter
    mkdir -p /var/spool/filter || exit 0
    chown filter:filter /var/spool/filter
    chmod 750 /var/spool/filter

    # copy the script
    cp var/disclaimer/disclaimer.sh /etc/postfix/disclaimer
    chgrp filter /etc/postfix/disclaimer
    chmod 750 /etc/postfix/disclaimer

    # file vars
    DIS_FOLDER='/etc/mailad'
    DIS_TXT="${DIS_FOLDER}/disclaimer.txt"

    # copy the default disclaimer if not set (to the user config /etc/mailad/)
    if [ ! -f ${DIS_TXT} ] ; then
        # no default disclaimer, copy the template
        cp var/disclaimer/default_disclaimer.txt ${DIS_TXT}
    fi
else
    # Disable the disclaimer
    echo "===> Disclaimer disabled on config, disabling"

    # remove the altermime package
    apt-get purge $DEBIAN_DISCLAIMER_PKGS -y || exit 0

    # disable the dfilt line in the master.cf file on postfix
    sed -i s/"content_filter=dfilt:"/"content_filter="/g /etc/postfix/master.cf
fi

### DNSBL
FILE='/etc/postfix/master.cf'
if [ "$ENABLE_DNSBL" == "yes" -o "$ENABLE_DNSBL" == "Yes" ] ; then
    # notice
    echo "===> Enabling DNSBL filtering "

    # disable simple smtp
    sed -i s/"^smtp      inet  n       -       y       -       -       smtpd"/"#smtp      inet  n       -       y       -       -       smtpd"/ ${FILE}

    # enables postscreen, smtpd, dnsblog & tlsproxy
    sed -i s/"^#smtp      inet  n       -       y       -       1       postscreen"/"smtp      inet  n       -       y       -       1       postscreen"/ ${FILE}
    sed -i s/"^#smtpd     pass  -       -       y       -       -       smtpd"/"smtpd     pass  -       -       y       -       -       smtpd"/ ${FILE}
    sed -i s/"^#dnsblog   unix  -       -       y       -       0       dnsblog"/"dnsblog   unix  -       -       y       -       0       dnsblog"/ ${FILE}
    sed -i s/"^#tlsproxy  unix  -       -       y       -       0       tlsproxy"/"tlsproxy  unix  -       -       y       -       0       tlsproxy"/ ${FILE}
else
    # notice
    echo "===> DNSBL filtering disabled"

    # enables simple smtp
    sed -i s/"^#smtp      inet  n       -       y       -       -       smtpd"/"smtp      inet  n       -       y       -       -       smtpd"/ ${FILE}

    # disables postscreen, smtpd, dnsblog & tlsproxy
    sed -i s/"^smtp      inet  n       -       y       -       1       postscreen"/"#smtp      inet  n       -       y       -       1       postscreen"/ ${FILE}
    sed -i s/"^smtpd     pass  -       -       y       -       -       smtpd"/"#smtpd     pass  -       -       y       -       -       smtpd"/ ${FILE}
    sed -i s/"^dnsblog   unix  -       -       y       -       0       dnsblog"/"#dnsblog   unix  -       -       y       -       0       dnsblog"/ ${FILE}
    sed -i s/"^tlsproxy  unix  -       -       y       -       0       tlsproxy"/"#tlsproxy  unix  -       -       y       -       0       tlsproxy"/ ${FILE}
fi

# Webmails
./scripts/webmails.sh

# start services
services restart

# install counter
INSTALLS=1
if [ ! -f "$INSTFILE" ]; then
    # initialize
    echo "===> Initialize install counters"

    # first install is the creation date of the /etc/mailad/ folder
    FIRST_INSTALL=$(stat -c '%w' /etc/mail | sed -E 's/\.\d+//; s/ /T/; s/ ([+-])/\1/' | xargs -I {} date -u -d "{}" "+%Y/%m/%d %I:%M:%S %p UTC")

    # initialize
    echo "INSTALLS=$INSTALLS" > $INSTFILE
    echo "FIRST_INSTALL=$FIRST_INSTALL" >> $INSTFILE
    echo "LAST_INSTALL=$(date)" >> $INSTFILE
else
    # New data on installs
    echo "===> Update install counters"

    # count +1
    INSTCOUNT=$(grep '^INSTALLS=' "$INSTFILE" | cut -d'=' -f2)
    INCCOUNT=$((INSTCOUNT + 1))
    LAST=$(date)
    # update
    sed -i "s/^INSTALLS=.*$/INSTALLS=$INCCOUNT/" "$INSTFILE"
    sed -i "s/^LAST_INSTALL=.*$/LAST_INSTALL=$LAST/" "$INSTFILE"
fi

# optional stats
if [ "$OPT_STATS" != "No" -o "$OPT_STATS" != "no" ] ; then
    # install swaks to handle the forged email as the mailadmin
    apt-get install swaks
    # and we have stats, thanks
    echo "===> Sending feedback to the creator & $ADMINMAIL"
    ./scripts/feedback.sh
fi

# copy the CHANGELOG to the local storage as latest
cp CHANGELOG.md /etc/mailad/changelog.latest

# copy the version script to bin path and set the cron job
cp ./scripts/check_new_version.sh /usr/local/bin/check_new_version.sh
chmod +x /usr/local/bin/check_new_version.sh
rm /etc/cron.weekly/mailad_check 2>/dev/null
ln -s /usr/local/bin/check_new_version.sh /etc/cron.weekly/mailad_check
