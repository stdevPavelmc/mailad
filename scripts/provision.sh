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
#           - services init wwith no fail
#           - send an email and verify it's placed on the users folder

# source the common config
source common.conf

# locate the conf files
source "/etc/mailad/mailad.conf"

# postfix files to make postmap, with full path
PMFILES="/etc/postfix/rules/lista_negra /etc/postfix/rules/everyone_list_check /etc/postfix/aliases/alias_virtuales"

# capture the local path
P=`pwd`

#### Some previous processing of the vars

# calc the max size of the message from the MB paramater in the vars
# plus a little percernt to allow for encoding grow
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

# add the mail gateway as a trusted source, aka the mynetworks
if [ ! -z "$RELAY" ] ; then
    MYNETWORK="$MYNETWORK $RELAY"
fi

# add the LDAPURI & ESC_SYSADMINS to the vars
VARS="${VARS} LDAPURI ESC_SYSADMINS"

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
    # diable AV services to save resources
    disable_av
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
                echo "DatabaseMirror ${M}" >> $FILE
            done
        fi
    fi

    ### configure proxy if needed
    if [ ! -z "$PROXY_HOST" -a ! -z "$PROXY_PORT" ] ; then
        # add proxy
        echo "HTTPProxyServer $PROXY_HOST" >> $FILE
        echo "HTTPProxyPort $PROXY_PORT" >> $FILE

        # check for auth
        if [ ! -z "$PROXY_USER" -a ! -z "$PROXY_PASS" ] ; then
            echo "HTTPProxyUsername $PROXY_USER" >> $FILE
            echo "HTTPProxyPassword $PROXY_PASS" >> $FILE
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
    rm -f /etc/cron.hourly/av_filter_on_clamav_alive
    ln -s "$P/var/clamav-related/activate_clamav_on_alive.sh" /etc/cron.hourly/av_filter_on_clamav_alive
    echo "===> AV filtering provision is in place, but activation is delayed, we must wait for frashclam"
    echo "===> to update the AV database before enabling it or you will lose emails in the mean time"
    echo "===> you will be notified by mail when it's activated."
fi

### SPAMD setting
if [ "$ENABLE_SPAMD" == "yes" -o "$ENABLE_SPAMD" == "Yes" ] ; then
    # enable the SPAMD

    # notice
    echo "===> Enabling SpamAssassin"

    # enable the cron job in the default
    sed -i s/"^CRON=.*$"/"CRON=1"/ /etc/default/spamassassin

    # configure SMA filtering on amavis if not already active
    FILE="/etc/amavis/conf.d/15-content_filter_mode"
    ACTIVE=`cat $FILE | grep "^#@bypass_spam_checks_maps.*"`
    if [ ! -z "$ACTIVE" ] ; then
        # not active, activating
        sed -i s/"#@bypass_spam_checks_maps"/"@bypass_spam_checks_maps"/g $FILE

        # reload services
        systemctl restart amavis
    fi

    ### configure proxy if needed
    SA_PROXY=""

    # build the chain
    if [ ! -z "$PROXY_HOST" -a ! -z "$PROXY_PORT" ] ; then
        # notice
        echo "===> SpamAssassin need proxy"

        # check for auth
        if [ ! -z "$PROXY_USER" -a ! -z "$PROXY_PASS" ] ; then
            SA_PROXY="http://${PROXY_USER}:${PROXY_PASS}@${PROXY_HOST}:${PROXY_PORT}/"

            # notice
            echo "===> SpamAssassin proxy needs auth"
        else
            SA_PROXY="http://${PROXY_HOST}:${PROXY_PORT}/"
        fi
    fi

    # set it up if needed
    if [ ! -z "${SA_PROXY}" ] ; then
        # clean proxy if there and then set
        sed -i s/"^.*SA_PROXY.*$"/""/g /etc/default/spamassassin

        # add it to the default config
        echo "SA_PROXY=${SA_PROXY}" >> /etc/default/spamassassin

        # notice
        echo "===> Setting the SpamAssassin proxy in the default config file"
    fi

    # enable the service
    systemctl unmask spamassassin
    systemctl enable spamassassin
    systemctl restart spamassassin

    # replace the default cron job if proxy enabled
    if [ ! -z "$SA_PROXY" ] ; then
        rm -f /etc/cron.daily/spamassassin
        cp "$P/var/spamassassin-related/spamassassin" /etc/cron.daily/spamassassin
    fi
else
    # disable the SPAMD

    # disable spamassasin on amavis
    FILE="/etc/amavis/conf.d/15-content_filter_mode"
    ACTIVE=`cat $FILE | grep "^@bypass_spam_checks_maps.*"`
    if [ ! -z "$ACTIVE" ] ; then
        # not active, activating
        sed -i s/"@bypass_spam_checks_maps"/"#@bypass_spam_checks_maps"/g $FILE

        # reload services
        systemctl restart amavis
    fi

    # disable the service
    systemctl stop spamassassin
    systemctl disable spamassassin
    systemctl mask spamassassin

    # remove the daily job if there
    test -x "/etc/cron.daily/spamassassin" && rm -f /etc/cron.daily/spamassassin
fi

### altermime
if [ "$ENABLE_DISCLAIMER" == "yes" -o "$ENABLE_DISCLAIMER" == "Yes" ] ; then
    # enable disclaimer
    echo "===> Disclaimer enabled on config, installing altermime..."

    export DEBIAN_FRONTEND=noninteractive
    apt-get install $DEBIAN_DISCLAIMER_PKGS -y

    # notice
    echo "===> Enabling Altermime tweaks for disclaimer addition"

    # creating the users's space
    useradd -r -c "Postfix Filters" -d /var/spool/filter filter
    mkdir -p /var/spool/filter || exit 0
    chown filter:filter /var/spool/filter
    chmod 750 /var/spool/filter

    # copy the script
    cp var/disclaimer_related/disclaimer.sh /etc/postfix/disclaimer
    chgrp filter /etc/postfix/disclaimer
    chmod 750 /etc/postfix/disclaimer

    # file vars
    DIS_FOLDER='/etc/mailad'
    DIS_TXT="${DIS_FOLDER}/disclaimer.txt"

    # copy the default disclaimer if not set (to the user config /etc/mailad/)
    if [ ! -f ${DIS_TXT} ] ; then
        # no default disclaimer, copy the template
        cp var/disclaimer_related/default_disclaimer.txt ${DIS_TXT}
    fi
else
    # Disable the disclaimer
    echo "===> Disclaimer disabled on config, disabling"
    
    # disable the dfilt line in the master.cf file on postfix
    sed -i s/"content_filter=dfilt:"/"content_filter="/g /etc/postfix/master.cf
fi

### DNSBL
if [ "$ENABLE_DNSBL" == "yes" -o "$ENABLE_DNSBL" == "Yes" ] ; then
    # DNSBL enabled by default, nothing to do 
    echo "===> DNSBL filtering enabled"
else
    # disable DNSBL in the /etc/postfix/main.cf
    sed -i s/"postscreen_dnsbl_sites =.*$"/"postscreen_dnsbl_sites ="/ /etc/postfix/main.cf
    echo "===> DNSBL filtering disabled"
fi

# start services
services restart

# optional stats
if [ "$OPT_STATS" == "yes" -o "$OPT_STATS" == "Yes" ] ; then
    # install swaks to handle the forged email as the mailadmin
    apt install swaks
    # and we have stats, thanks
    ./scripts/feedback.sh
fi
