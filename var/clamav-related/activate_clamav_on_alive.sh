#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goals:
#   - This script must be soft linked as 'av_filter_on_clamav_alive' in /etc/cron.hourly/
#   - The script checks if the clamav-daemon service is runnig and activate the av filtering on amavis
#   - Reloading the config of amavis & postfix when done
#   - Rrasing itself from the /etc/cron.hourly/ to avoid execution
#   - Sending a warning about clamav not started, most likely freshclam not being able to fill /var/lib/clamav with updates

# load configs
source /etc/mailad/mailad.conf

# Check the SYSADMINS var and populate it if needed
if [ -z "$SYSADMINS" ] ; then
    SYSADMINS=$ADMINMAIL
fi

# test if clamav-daemon is runnig already, it will run only when freshclam manages to get a full db download
R=`systemctl show -p SubState --value clamav-daemon`
if [ "$R" == "running" ] ; then
    # it's alive!, doing our thing

    # configure AV filtering on amavis if not already active
    FILE="/etc/amavis/conf.d/15-content_filter_mode"
    ACTIVE=`cat $FILE | grep "^#@bypass_virus_checks_maps.*"`
    if [ ! -z "$ACTIVE" ] ; then
        # not active, activating
        sed -i s/"#@bypass_virus_checks_maps"/"@bypass_virus_checks_maps"/g $FILE

        # reload services
        systemctl restart amavis
        systemctl reload postfix

        # send notice of activation
        echo "ClamAV-Daemon came active as ClamAV-FreshClam updated his database, AV filtering was activated" | \
            mail $SYSADMINS -s "MailAD notice: AV filtering activated!"

        rm -f /etc/cron.hourly/av_filter_on_clamav_alive
    fi
else
    # it's not activated yet, send notice
    echo "ClamAV-Daemon is not active, keep watching it to activate email filtering when it came active..." | \
        mail $SYSADMINS -s "MailAD notice: AV filtering pending..."
fi
