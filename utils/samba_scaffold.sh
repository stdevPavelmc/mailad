#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2022 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later
#
# This script is meant to be run in the SAMBA4 DC, not in the MailAD server
#
# Goals:
#   - Install and configure samba4 on an ubuntu based system
#   - Scaffold a domain from the parameter in the /etc/mailad/mailad.conf
#   - Create the admin user and move it to the correct place
#   - Create the test users stated on the test credentials inside /test/.mailadmin.ath
#   - Create the groups related to mail access and move the users of the last step
#
# WARNING!:
# - This script is intended to be used on an isolated/test env, so will have not
#   provision to run on a production environment!
# - This script will rip-off any previous samba deployment!
#

# testing for mailad.conf
if [ ! -f /etc/mailad/mailad.conf ] ; then
    echo "======================================================"
    echo "ERROR: can't find the /etc/mailad/mailad.conf file!"
    echo " "
    echo "COMMENT: We use that config file to load the config"
    echo "         run 'make config' to create it and adapt it"
    echo "         to your needs, the procced with this again."
    echo " "
    echo "======================================================"
    exit 1
fi

# testing for credentials
if [ ! -f .mailadmin.auth ] ; then
    echo "======================================================="
    echo "ERROR: can't find the .mailadmin.auth credentials file!"
    echo " "
    echo "COMMENT: That file holds the password of the test mail-"
    echo "         admin an other test users, please read the"
    echo "         README.md file inside the test folder."
    echo " "
    echo "======================================================="
    exit 1
fi

# load files
source /etc/mailad/mailad.conf
source .mailadmin.auth

### Some var casting
# Administrator PASSWD!
APSWD=${PASS}
NETBIOS=$(echo ${DOMAIN} | cut -d '.' -f 1 | tr [:lower:] [:upper:])
ADMINUSER=$(echo ${ADMINMAIL} | cut -d '@' -f 1)
LUCU=$(echo ${LOCUSER} | cut -d '@' -f 1)
NATU=$(echo ${NACUSER} | cut -d '@' -f 1)

# Set default DNS forwarder if not already set
if [ -z "$DNSFWD" ] ; then
    DNSFWD=1.1.1.1
fi

echo "==== DEBUG: VARS SETTED ===="
echo "NETBIOS: ${NETBIOS}"
echo "ADMINUSER: ${ADMINUSER}"
echo "LUCU: ${LUCU}"
echo "NATU: ${NATU}"
echo "DNSFWD: ${DNSFWD}"
echo "==== END DEBUG ===="

# update the package data
apt-get update

# install samba and winbind
apt-get install samba winbind python3-setproctitle -yq

# config samba related services
for a in stop disable mask ; do
    systemctl $a smbd nmbd winbind systemd-resolved
done

# unmask the winbind daemon & samba DC
systemctl unmask winbind samba-ad-dc
systemctl enable samba-ad-dc

# do some cleaning steps
systemctl stop samba-ad-dc
rm -rdf /var/lib/samba/*
rm /etc/samba/smb.conf

# provision the samba domain
echo ">>> provision samba"
samba-tool domain provision \
    --use-rfc2307 \
    --realm ${DOMAIN} \
    --domain ${NETBIOS} \
    --server-role=dc \
    --dns-backend=SAMBA_INTERNAL \
    --adminpass=${APSWD}

# fix the DNS to point to myself and alternatives
echo "search mailad.cu" > /etc/resolv.conf
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# set the forwarder
if [ "${DNSFWD}" ] ; then
    sed s/"^dns forwarder .*$"/"dns forwarder = ${DNSFWD}"/ -i  /etc/samba/smb.conf
fi

# start the new domain
echo ">>> start samba"
systemctl start samba-ad-dc

# create the link user
echo ">>> create user linux"
samba-tool user create linux "${LDAPBINDPASSWD}"

# Create the OU
echo ">>> create Base OU ${NETBIOS}"
samba-tool ou create "ou=${NETBIOS}"

# create the admin user
echo ">>> create user Admin"
samba-tool user create ${ADMINUSER} ${PASS} --userou="ou=${NETBIOS}" --mail-address="${ADMINMAIL}"

# create the test users
echo ">>> create user Local"
samba-tool user create ${LUCU} "${LOCUSERPASSWORD}" --userou="ou=${NETBIOS}" --mail-address="${LOCUSER}"
echo ">>> create user National"
samba-tool user create ${NATU} "${NACUSERPASSWD}" --userou="ou=${NETBIOS}" --mail-address="${NACUSER}"

# create the Access Groups OU & groups
echo ">>> create OU access"
samba-tool ou create "ou=MAIL_ACCESS,ou=${NETBIOS}"
echo ">>> create local group"
samba-tool group create Local_mail --groupou="ou=MAIL_ACCESS,ou=${NETBIOS}"
echo ">>> create national group"
samba-tool group create National_mail --groupou="ou=MAIL_ACCESS,ou=${NETBIOS}"

# Add users to the groups
echo ">>> add local to local group"
samba-tool group addmembers Local_mail ${LUCU}
echo ">>> add national to national group"
samba-tool group addmembers National_mail ${NATU}
