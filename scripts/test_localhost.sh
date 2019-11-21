#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
#
# Goals:
#   - Test the local configuration for:
#       - is the vmail user setup correctly?
#       - fqdn & domain
#       - DNS resolution and HOSTAD config
#       - conectivity to the HOSTAD 

# locate the source file (makefile or run by hand)
if [ -f mailad.conf ] ; then 
    source mailad.conf
else
    source ../mailad.conf
fi

echo "Testing the configurations on the local host"

#vmail user
GROUP=`cat /etc/group | grep $VMAILNAME | grep $VMAILGID`
USER=`cat /etc/passwd | grep $VMAILNAME | grep $VMAILUID`
if [ "$GROUP" == "" -o "$USER" == "" ] ; then
    # fix it!
    ./vmail_create.sh
fi

# hostname vs fqdn
HOST=`hostname`
FQDN=`hostname -f`
if [ "$HOST" == "$FQDN" ] ; then
    # fail
    echo "ERROR!"
    echo "    Your hostname does not have a domain or it's configured wrong!"
    echo "    A 'hostname' command must return just the name of the host with no domain"
    echo "    A 'hostname -f' command must return the name with the domain"
    echo " "
    exit 1
else
    echo "You have a correct fqdn in the hostname"
    echo "Success!"
fi

# localhost is localhost?
if [ "$HOSTNAME" == "$FQDN" ] ; then
    echo "You have a correct HOSTNAME configured"
    echo "Success!"
else
     # fail
    echo "ERROR!"
    echo "    Your HOSTNAME var in mailad.conf does not match the FQDN of this host!"
    echo "    Please fix that"
    echo " "
    exit 1
fi

# ping the hostad
ping -c 3 "$HOSTAD"
R=$?
if [ $R -eq 0 ] ; then
    echo "The domain host listed in HOSTAD is network reacheable!"
    echo "Success!"
else
    # fail
    echo "ERROR!"
    echo "    Domain host seems to be down or not reacheable!"
    echo "    Check your network settings and cable"
    echo " "
    exit 1
fi

# check if the DNS is working, by asking for the SOA of the domain
SOAREC=`dig SOA $DOMAIN +short`
if [ "$SOAREC" == "" ] ; then
    # fail
    echo "ERROR!"
    echo "    The DOMAIN you declared in mailad.conf has no SOA record in the actual DNS"
    echo "    That, or your DNS is not configurated correctly in this host"

    exit 1
else
    # returned values so DNS is configured OK, but need more testing
    echo "SOA record acquired, testing that HOSTAD points to the SOA..."
    echo "Success!"

    HOST=`echo $SOAREC | grep $HOSTAD`
    if [ "$HOST" == "" ] ; then
        # maybe HOSTAD is an IP?
        HOST=`echo $SOAREC | awk '{print $1}' | rev | cut -d "." -f 2- | rev`
        IP=`dig A $HOST +short`
        if [ "IP" == "$HOSTAD" ] ; then
             # success
            echo "The SOA record points to the HOSTAD value (HOSTAD is an IP), nice!"
            echo "Success!"
        else
            # fail
            echo "ERROR!"
            echo "    The DNS answer with a value for the SOA of $DOMAIN, but the value does"
            echo "    not match the one configured in HOSTAD, please fix that"
            echo "    HOSTAD=$HOSTAD vs SOA_IP=$IP "
            echo " "
            exit 1
        fi
    else
        # success
        echo "The SOA record points to the HOSTAD value (HOSTAD is a hostname), nice!"
        echo "Success!"
    fi
fi
