#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2024 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goals:
#   - Install the roundcube webmail and try to configure most of the things it needs
#

# source the common config
source common.conf

# locate the conf files
source "/etc/mailad/mailad.conf"

# use apt in non interactive way
export DEBIAN_FRONTEND=noninteractive

# notice
echo "===> Remove SnappyMail if it was previosly installed"
apt-get remove -y "$SNAPPY_PKGS" 2> /dev/null
rm -rdf "$SNAPPY_DIR" || true
rm /etc/mailad/snappy_admin_pass || true

# install the default site config
NGINX_CONFIG=/etc/nginx/sites-available/default
NGINX_TEMPLATE=./var/nginx/default
HTTPS_ONLY=true
if [ "$WEBSERVER_HTTP_ENABLED" == "yes" ]; then
    NGINX_TEMPLATE=./var/nginx/default_http
    HTTPS_ONLY=false

    # User notice:
    echo ""
    echo "##### WARNING  WARNING  WARNING ######################################"
    echo "#                                                                    #"
    echo "# You selected an HTTP only web server, this is dangerous unless you #"
    echo "#    use a reverse proxy with a TLS/SSL wrapper [HTTPS wrapper]      #"
    echo "#                                                                    #"
    echo "#                      You has been warned!                          #"
    echo "#                                                                    #"
    echo "####################################  WARNING  WARNING  WARNING ######"
    echo ""
fi
cp ${NGINX_TEMPLATE} ${NGINX_CONFIG}

# vars
WWW_ROOT="/var/lib/roundcube/public_html"
VARS="${VARS} WWW_ROOT HTTPS_ONLY"

# replace vars
echo "===> Provisioning Nginx..."
for v in `echo $VARS | xargs` ; do
    # get the var content
    CONTp=${!v}

    # escape possible "/" in there
    CONT=`echo ${CONTp//\//\\\\/}`

    sed -i s/"\_$v\_"/"$CONT"/g ${NGINX_CONFIG}
done

# test the config
echo "===> Testing Nginx config..."
nginx -t

if [ "$?" != "0" ] ; then
    echo "===> Nginx config test failed, exiting"
    echo "     Copy the log on this console and go to https://t.me/MailAD_dev"
    echo "     and ask for help."
    exit 1  
fi

# restart nginx
echo "===> Restarting Nginx..."
PHP_FPM_VER=$(dpkg -l | grep php-fpm | awk '{print $3}' | cut -d ":" -f2 | cut -d "+" -f1)
systemctl restart nginx php${PHP_FPM_VER}-fpm

# notice
echo "===> Installing Roundcube webmail"

# install rainloop pkgs
apt-get install ${ROUNDCUBE_PKGS} -yq

# roundcube needs a stable an unique DES key per installation, check and create if needed
ROUNDCUBE_DESKEY_FILE=/etc/mailad/roudcube_des_key
if [ ! -f "${ROUNDCUBE_DESKEY_FILE}" ] ; then
    openssl rand -base64 32 > ${ROUNDCUBE_DESKEY_FILE}
    chmod 600 ${ROUNDCUBE_DESKEY_FILE}
fi
export ROUNDCUBE_DESKEY=$(cat ${ROUNDCUBE_DESKEY_FILE} | head -n1)

# Copy the default config and setup the vars
ROUNDCUBE_CONFIG_FOLDER=/etc/roundcube
rm "${ROUNDCUBE_CONFIG_FOLDER}/config.inc.php"
cp ./var/roundcube/config.inc.php ${ROUNDCUBE_CONFIG_FOLDER}/config.inc.php

# Create sqlite store for mailad
SQLITE_STORAGE=/var/lib/mailad
SQLITE_DB=roundcube.sqlite3
mkdir -p "${SQLITE_STORAGE}"
chown -R root:www-data ${SQLITE_STORAGE}
chmod 0770 ${SQLITE_STORAGE}
chmod 0660 "${SQLITE_STORAGE}/${SQLITE_DB}"*

# ldap vars
LDAP_PORT=389
LDAP_PREFIX=""
if [ "$SECURELDAP" == 'yes' ] ; then
    LDAP_PORT=636
    LDAP_PREFIX="ldaps://"
fi

# if more than one host
LDAP_HOSTS=""
for h in $(echo $HOSTAD | xargs); do
    LDAP_HOSTS="${LDAP_PREFIX}${h}:$LDAP_PORT ${LDAP_HOSTS}"
done

# add the some local vars to the list
VARS="${VARS} ROUNDCUBE_DESKEY LDAP_HOSTS SQLITE_STORAGE SQLITE_DB"

# replace the vars in the folders
for f in `echo "$ROUNDCUBE_CONFIG_FOLDER" | xargs` ; do
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


echo "===> Done!"