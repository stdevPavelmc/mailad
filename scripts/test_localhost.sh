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
source common.conf

echo "===> Testing the configurations on the local host"

# test /sbin on some envs (Debian 10/11)
SBIN=`echo $PATH | grep "/sbin"`
if [ -z "$SBIN" ] ; then
    # warn the user of the lack of /sbins in the PATH
    echo "================================================================================="
    echo "ERROR!"
    echo "    On some modern distros you end with no /sbin or /usr/sbin paths on the \$PATH"
    echo "    env vars, that as a result of a strict policy of su/sudo. To fix that you can"
    echo "    do one of these tricks:"
    echo ""
    echo "    1. If you logged in as a normal user and then do su or sudo commands to gain"
    echo "       root privileges, you need to set the PATH on /etc/environment, see 2:"
    echo "    2. Set the path on /etc/environment, this sencence on that file will make it"
    echo ""
    echo "    PATH=\"/sbin:/usr/sbin:\$PATH\""
    echo "================================================================================="
    echo " "
    exit 1
fi

# HOSTAD may be multiple host, check the DNS and by then find the IP/host of the SOA
# listed on the HOSTAD var
H=`get_soa`
if [ -z "${H}" ] ; then
    # fail verbose, no soa FOUND
    get_soa_verbose
else
    echo "===> DNS working and SOA listed on HOSTAD var, using '${H}' for tests"
fi

# No ping, some users have VLANs with no ping allowed, we switch to nc to test if
# the port is open, but we need to know the correct por if LDAP or LDAPS
# secure ldap by default
PORT=636
if [ "$SECURELDAP" == "" -o "$SECURELDAP" == "no" -o "$SECURELDAP" == "No" ] ; then
    # no sec, plain ldap
    PORT=389
fi

# command
nc "${H}" "$PORT" -vz  2> /dev/null

# testing
R=$?
if [ $R -eq 0 ] ; then
    echo "===> We can reach the domain server listed in the configs!"
else
    # fail
    echo "================================================================================="
    echo "ERROR!"
    echo "    We can't connect to the port $PORT of the AD server ($H) specified in"
    echo "    the config, check your network settings, firewalls, etc"
    echo ""
    echo "    HOSTAD is: ${HOSTAD}"
    echo "================================================================================="
    echo " "

    exit 1
fi


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
    echo " "
    echo "    hostname: ${HOST}"
    echo "    hostname -f: ${FQDN}"
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

# testing if a working DNS is configured if AV is set to enabled
if [ "$ENABLE_AV" == "yes" -o "$ENABLE_AV" == "Yes" ] ; then
    # But only if no proxy, if proxy, skip this check
    if [ "$PROXY_HOST" -a "$PROXY_PORT" -a "$AV_UPDATES_USE_PROXY" == "yes" ] ; then
        # AV must use proxy so skip this test
        echo "===> Skip DNS test for ClamAV as we will use proxy for updates"
    else
        # direct no proxy...
        # check if we can get the database fingerprint for clamav
        DBF=`dig +short TXT current.cvd.clamav.net | grep -P "([0-9]+:){7}"`
        if [ -z "$DBF" ] ;  then
            # DNS not working
            echo "================================================================================="
            echo "ERROR!"
            echo "    You enabled the AV in the config file but no working DNS server is configured"
            echo "    in the PC, if we don't have a working DNS to check for AV updates or internet"
            echo "    access, we can not provide a working ClamAV configuration."
            echo " "
            echo "    Please check your DNS with this command:"
            echo "        dig +short TXT current.cvd.clamav.net"
            echo " "
            echo "    If that does not return a long string you have a not working DNS, and must"
            echo "    set the var 'ENABLE_AV=no' in the /etc/mailad/mailad.conf file until you fix"
            echo "    that, or use a proxy server to get the updates."
            echo "================================================================================="
            echo " "

            exit 1
        else
            echo "===> Working DNS for ClamAV found!"
        fi
    fi
fi


# testing if a working DNS is configured if SPAMD is set to enabled
if [ "$ENABLE_SPAMD" == "yes" -o "$ENABLE_SPAMD" == "Yes" ] ; then
    # check if we can get the database fingerprint for spamassassin
    DBF=`dig TXT +short 2.4.3.updates.spamassassin.org | grep -P "\"[0-9]{5,}\""`
    if [ -z "$DBF" ] ;  then
        # DNS not working
        echo "================================================================================"
        echo "ERROR!"
        echo "    You enabled the SPAMD in the config file but no working DNS server is"
        echo "    detected in the PC, if we don't have a working DNS to check for updates or"
        echo "    internet access, we can not provide a working SpamAssassin configuration."
        echo " "
        echo "    Please check your DNS with this command:"
        echo "        dig TXT +short 2.4.3.updates.spamassassin.org"
        echo " "
        echo "    If that doest not return a number like \"1881840\" you have a not working"
        echo "    DNS and must set the var 'ENABLE_SPAMD=no' in the /etc/mailad/mailad.conf"
        echo "    file until you fix that, or the installation will not work."
        echo "================================================================================"
        echo " "

        exit 1
    else
        echo "===> Working DNS for SpamAssassin found!"
    fi
fi

# testing if a working DNS is configured if DNSBL is set to enabled
if [ "$ENABLE_DNSBL" == "yes" -o "$ENABLE_DNSBL" == "Yes" ] ; then
    # check if we can get the database fingerprint for spamassassin
    DNSBL=`dig 2.0.0.127.zen.spamhaus.org +short | grep -P "127"`
    if [ -z "$DNSBL" ] ;  then
        # DNS not working
        echo "================================================================================"
        echo "ERROR!"
        echo "    You enabled the DNSBL in the config file but no working DNS server is"
        echo "    detected in the PC, if we don't have a working DNS to ask a DNS query about"
        echo "    a domain or IP, we can not provide a working DNSBL configuration."
        echo " "
        echo "    Please check your DNS with this command:"
        echo "        dig 2.0.0.127.zen.spamhaus.org +short "
        echo " "
        echo "    If that doest not return some 127.* IPs you have a not working DNS and must"
        echo "    set he var 'ENABLE_DNSBL=no' in the /etc/mailad/mailad.conf file until you"
        echo "    fix that, or the installation will not work."
        echo " "
        echo "    Please take into account that using the google DNS is a bad idea when you"
        echo "    use the DNSBL, as this services has a quota and are registered per DNS"
        echo "    server and as you can imagine the 8.8.8.8 & 8.8.4.4 server are always over"
        echo "    due in the quota, please use your ISP DNS server or 1.0.0.1 from CloudFlare"
        echo "================================================================================"
        echo " "

        exit 1
    else
        echo "===> Working DNS for DNSBL found!"
    fi
fi
