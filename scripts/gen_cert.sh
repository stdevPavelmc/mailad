#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
#
# Goal:
#   - Generate a 3 years valid self-signed certificate
#   - Generate a safe dhparm file to protect forward secrecy

# locate the source file (makefile or run by hand)
if [ -f mailad.conf ] ; then 
    source mailad.conf
else
    source ../mailad.conf
fi

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
sudo mv mail.key /etc/ssl/private/
sudo mv mail.crt /etc/ssl/certs/
sudo mv cacert.pem /etc/ssl/certs/
sudo chmod 0600 /etc/ssl/private/mail.key
sudo chmod 0600 /etc/ssl/certs/mail.crt
sudo chmod 0600 /etc/ssl/certs/cacert.pem

# clan the workspace for dhparam generation
rm *

## dhparms generation
echo "Generation of SAFE dhparam, this will take a time, be patient..."
openssl dhparam -out RSA2048.pem -5 2048
openssl dhparam -dsaparam -out DSA2048.pem 2048
openssl dhparam -out RSA4096.pem -5 4096
openssl dhparam -dsaparam -out DSA4096.pem 4096

# copy to final destination
sudo mkdir /etc/ssl/dh & > /dev/null
sudo mv -f *.pem /etc/ssl/dh/ 

# clean the house
cd ~
rm -rdf "$TMP"

echo "All certs generated and in place..."
echo "Success!"

exit 0
