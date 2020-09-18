#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goals:
#   - Test the local configuration for:
#       - is the vmail user setup correctly?
#       - fqdn & domain
#       - DNS resolution and HOSTAD config
#       - conectivity to the HOSTAD
#       - Check if we are in a non testing domain the password must be changed

# load conf files
source /etc/mailad/mailad.conf

echo "===> Testing the configurations on the local host"

#vmail user
GROUP=`cat /etc/group | grep $VMAILNAME | grep $VMAILGID`
USER=`cat /etc/passwd | grep $VMAILNAME | grep $VMAILUID`
if [ "$GROUP" == "" -o "$USER" == "" ] ; then
    # fix it!
    ./vmail_create.sh || scripts/vmail_create.sh
fi

# hostname vs fqdn
HOST=`hostname`
FQDN=`hostname -f`
if [ "$HOST" == "$FQDN" ] ; then
    # fail
    echo "================================================================================="
    echo "ERROR!"
    echo "    Your hostname does not have a domain or it's configured wrong!"
    echo "    A 'hostname' command must return just the name of the host with no domain"
    echo "    A 'hostname -f' command must return the name with the domain"
    echo "================================================================================="
    echo " "

    exit 1
else
    echo "===> You have a correct fqdn in the hostname"
fi

# localhost is localhost?
if [ "$HOSTNAME" == "$FQDN" ] ; then
    echo "===> You have a correct HOSTNAME configured"
else
    # fail
    echo "================================================================================="
    echo "ERROR!"
    echo "    Your HOSTNAME var in mailad.conf does not match the FQDN of this host!"
    echo "    Please fix that"
    echo "================================================================================="
    echo " "

    exit 1
fi

# ping the hostad
ping -c 3 "$HOSTAD"
R=$?
if [ $R -eq 0 ] ; then
    echo "===> The domain host listed in HOSTAD is network reacheable!"
else
    # fail
    echo "================================================================================="
    echo "ERROR!"
    echo "    Domain host seems to be down or not reacheable!"
    echo "    Check your network settings and cable"
    echo "================================================================================="
    echo " "

    exit 1
fi

# check if the DNS is working, by asking for the SOA of the domain
SOAREC=`dig SOA $DOMAIN +short`
if [ "$SOAREC" == "" ] ; then
    # fail
    echo "================================================================================="
    echo "ERROR!"
    echo "    The DOMAIN you declared in mailad.conf has no SOA record in the actual DNS"
    echo "    That, or your DNS is not configurated correctly in this host"
    echo "================================================================================="
    echo " "

    exit 1
else
    # returned values so DNS is configured OK, but need more testing
    echo "===> SOA record acquired, testing that HOSTAD points to the SOA..."

    HOST=`echo $SOAREC | grep $HOSTAD`
    if [ "$HOST" == "" ] ; then
        # maybe HOSTAD is an IP?
        HOST=`echo $SOAREC | awk '{print $1}' | rev | cut -d "." -f 2- | rev`
        IP=`dig A $HOST +short`
        if [ "IP" == "$HOSTAD" ] ; then
            # success
            echo "===> The SOA record points to the HOSTAD value (HOSTAD is an IP), nice!"
        else
            # fail
            echo "================================================================================="
            echo "ERROR!"
            echo "    The DNS answer with a value for the SOA of $DOMAIN, but the value does"
            echo "    not match the one configured in HOSTAD, please fix that"
            echo "    HOSTAD=$HOSTAD vs SOA_IP=$IP "
            echo "================================================================================="
            echo " "

            exit 1
        fi
    else
        # success
        echo "===> The SOA record points to the HOSTAD value (HOSTAD is a hostname), nice!"
    fi
fi


# testing that the password is different if we are in a non  testing domain
if [ $DOMAIN != "mailad.cu" -a "$LDAPBINDPASSWD" == "Passw0rd---" ] ; then
    echo "================================================================================="
    echo "ERROR!"
    echo "    You has a default password in the bind dn user 'LDAPBINDUSER', that's a very"
    echo "    bad practice, please change the password for the user in the AD and update"
    echo "    it on the file 'mailad.conf'"
    echo "================================================================================="
    echo " "

    exit 1
fi

# testing if a working DNS is configured if AV is set ton enabled
if [ "$ENABLE_AV" == "yes" -o "$ENABLE_AV" == "Yes" ] ; then
    # check if we can get the database fingerprint for clamav
    DBF=`dig +short TXT current.cvd.clamav.net | grep -P "([0-9]+:){7}"`
    if [ -z "$DBF" ] ;  then
        # DNS nor working
        echo "================================================================================="
        echo "ERROR!"
        echo "    You enabled the AV in the config file but no working DNS server is configured"
        echo "    in the PC, if we don't have a working DNS to check for AV updates or internet"
        echo "    access, we can not provide a working ClamAV configuration."
        echo " "
        echo "    Please check your DNS with this command: dig +short TXT current.cvd.clamav.net"
        echo " "
        echo "    If that doest not return a long string you have a not working DNS, and must"
        echo "    set the var 'ENABLE_AV=no' in the /etc/mailad/mailad.conf file until you fix"
        echo "    that, or the installation will not work."
        echo "================================================================================="
        echo " "

        exit 1
    else
        echo "===> Working DNS for ClamAV found!"
    fi
fi
