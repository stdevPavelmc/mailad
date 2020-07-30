#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Generate a 3 years valid self-signed certificate
#   - Generate a safe dhparm file to protect forward secrecy

# load the conf file
source /etc/mailad/mailad.conf

# generate the cers only of not present already
if [ -f /etc/ssl/private/mail.key -a -f /etc/ssl/certs/mail.crt -a -f /etc/ssl/certs/cacert.pem ] ; then
    # already present, not generating the certs
    echo "===> Certs aready present, skiping the generation"
    exit 0
fi

# Check if a LE certificate is on the config
if [ -f /etc/mailad/le/fullchain.pem -a -f /etc/mailad/le/privkey.key ] ; then
    echo "Let's Encrypt certificates found, using them"

    # erase in place certificates if found
    rm -f /etc/ssl/private/mail.key &2> /dev/null
    rm -f /etc/ssl/certs/mail.crt &2> /dev/null
    rm -f /etc/ssl/certs/cacert.pem &2> /dev/null

    # linking the LE certificates
    ln -s /etc/mailad/le/fullchain.pem /etc/ssl/certs/mail.crt
    ln -s /etc/mailad/le/fullchain.pem /etc/ssl/certs/cacert.pem
    ln -s /etc/mailad/le/privkey.key /etc/ssl/private/mail.key

else
    echo "Generating a Self Signed Certificate for this node"

    # moving to a temp dir to work
    TMP=`mktemp -d`
    cd "$TMP"

    # Generate self signed root CA cert
    openssl req -nodes -x509 -newkey rsa:2048 -keyout ca.key -out ca.crt -subj \
        "/C=$SSLPAIS/ST=$SSLESTADO/L=$SSLCIUDAD/O=$SSLEMPRESA/OU=$SSLUEB/CN=$SSLHOSTNAME/emailAddress=$ADMINMAIL"

    # Generate server cert to be signed
    openssl req -nodes -newkey rsa:2048 -keyout mail.key -out mail.csr -subj \
        "/C=$SSLPAIS/ST=$SSLESTADO/L=$SSLCIUDAD/O=$SSLEMPRESA/OU=$SSLUEB/CN=$SSLHOSTNAME/emailAddress=$ADMINMAIL"

    # Sign the server cert (valid by 3 years)
    openssl x509 -req -days 1095 -in mail.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out mail.crt

    # create the server pem file
    cat ca.key ca.crt > cacert.pem

    #move it to the final places & fix perms
    mv -f mail.key /etc/ssl/private/
    mv -f mail.crt /etc/ssl/certs/
    mv -f cacert.pem /etc/ssl/certs/
    chmod 0600 /etc/ssl/private/mail.key
    chmod 0600 /etc/ssl/certs/mail.crt
    chmod 0600 /etc/ssl/certs/cacert.pem

    # clan the workspace for dhparam generation
    rm *
fi

## dhparms generation
echo "Generation of SAFE dhparam, this will take a time, be patient..."
openssl dhparam -out RSA2048.pem -5 2048

# copy to final destination
mkdir -p /etc/ssl/dh &> /dev/null
mv -f RSA2048.pem /etc/ssl/dh
chmod 0644 /etc/ssl/dh/RSA2048.pem

# clean the house
cd ~
rm -rdf "$TMP"
