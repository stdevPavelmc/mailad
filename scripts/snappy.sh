#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2024 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goals:
#   - Install the SnappyMail webmail and try to configure most of the things it needs
#

# source the common config
source common.conf

# locate the conf files
source "/etc/mailad/mailad.conf"

# use apt in non interactive way
export DEBIAN_FRONTEND=noninteractive

# notice
echo "===> Remove RoundCube if it was previosly installed"
apt-get remove -y "roundcube*"

# notice
echo "===> Installing SnappyMail webmail"

SNAPPY_VERSION="2.36.4"
SNAPPY_FILE="snappymail-${SNAPPY_VERSION}.tar.gz"
SNAPPY_URL="https://github.com/the-djmaze/snappymail/releases/download/v${SNAPPY_VERSION}/${SNAPPY_FILE}"
#SNAPPY_URL="http://172.17.0.1:8081/$SNAPPY_FILE"

function fixperms {
    # just one parameter, the directory to apply the perms
    find "$1/" -type f -exec chmod -R 0660 {} \;
    find "$1/" -type d -exec chmod -R 0770 {} \;
    chown -R www-data:www-data "$1/"
}

# Handle http proxy if set
if [ ! -z "$PROXY_HOST" -a ! -z "$PROXY_PORT" ] ; then
    # ok, by all means add proxy
    export HTTP_PROXY="http://$PROXY_HOST:$PROXY_PORT"

    # check for auth
    if [ ! -z "$PROXY_USER" -a ! -z "$PROXY_PASS" ] ; then
        export HTTP_PROXY="http://$PROXY_USER:$PROXY_PASS@$PROXY_HOST:$PROXY_PORT"
    fi
fi

# install php dependencies:
apt-get install -y $SNAPPY_PKGS

# preserve PWD
BPWD=$(pwd)

# create log folder
LOGS="/var/log/snappymail"
mkdir -p $LOGS
chown -R www-data:www-data $LOGS
chmod -R 755 $LOGS

# Install Snappy Webmail
mkdir -p $SNAPPY_DIR
cd $SNAPPY_DIR
wget -q --no-clobber "$SNAPPY_URL"
# check if doenload fails
if [ $? -ne 0 ]; then
    echo "===> Error!"
    echo "  Download of the snappymail package failed"
    echo "  URL is: $SNAPPY_URL"
    echo "  This is a connectivity issue, if you use a proxy go to /etc/mailad/mailad.conf"
    echo "  and configure the proxy there."
    echo ""
    echo "  Installation aborted"
    exit 1
fi
tar xzf ${SNAPPY_FILE}
fixperms /var/www
rm snappymail-${SNAPPY_VERSION}.tar.gz

# back to base pwd
cd $BPWD

# install the default site config
NGINX_CONFIG=/etc/nginx/sites-available/default
NGINX_TEMPLATE=./var/nginx/default
WEBPROTO=https
if [ "$WEBSERVER_HTTP_ENABLED" == "yes" ]; then
    NGINX_TEMPLATE=./var/nginx/default_http
    WEBPROTO=http

    # User notice:
    echo ""
    echo "####################  WARNING  WARNING  WARNING ######################"
    echo "#                                                                    #"
    echo "# You selected an HTTP only web server, this is dangerous unless you #"
    echo "#    use a reverse proxy with a TLS/SSL wrapper [HTTPS wrapper]      #"
    echo "#                                                                    #"
    echo "#                      You has been warned!                          #"
    echo "#                                                                    #"
    echo "#####################  WARNING  WARNING  WARNING #####################"
    echo ""
fi
cp ${NGINX_TEMPLATE} ${NGINX_CONFIG}

# add the some local vars to the list
WWW_ROOT="/var/www/snappymail"
VARS="${VARS} WWW_ROOT"

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

# setup SnappyMail
echo "===> Setup Snappy app"

# defaults
DEFAULTFOLDER="$SNAPPY_DIR/data/_data_/_default_"
CONFIGFOLDER="$DEFAULTFOLDER/configs"
DOMAINSFOLDER="$DEFAULTFOLDER/domains"

# default password & config file:
PASS="${DEFAULTFOLDER}/admin_password.txt"
CONFIG="${CONFIGFOLDER}/application.ini"

# small delay to allow the service to create the default config
while [ ! -f "$PASS" ] ; do
    wget -q --no-check-certificate "$WEBPROTO://$HOSTNAME/?admin" -O /dev/null
    wget -q --no-check-certificate "$WEBPROTO://$HOSTNAME/?/AdminAppData/0/5220854561746323/" -O /dev/null
    sleep 2
    echo "."
done

# Expose for the admin user the default password file
echo "======================================================================"
echo "|| SnappyMail default admin password: $(cat ${PASS})"
echo "======================================================================"
cat ${PASS} > /etc/mailad/snappy_admin_pass

# Load default passhash from filem before overwrite
PASSHASH=$(grep admin_password ${CONFIG} | awk '{print $3}' | tr -d '"')

# clean domains configs
cd ${DOMAINSFOLDER}
for f in $(ls ${DOMAINSFOLDER}/*.json) ; do
    rm -f ${f}
done

# change to base path to copy template file and plugins
cd $BPWD
cp -Rf --update=all ./var/snappy/* ${DEFAULTFOLDER}/
mv -f "${DOMAINSFOLDER}/template.json" "${DOMAINSFOLDER}/${DOMAIN}.json"
fixperms ${DEFAULTFOLDER}

# ldap vars
LDAP_PORT=389
LDAP_PREFIX="ldap://"
if [ "$SECURELDAP" == 'yes' ] ; then
    LDAP_PORT=636
    LDAP_PREFIX="ldaps://"
fi

# if more than one host
LDAP_HOSTS=""
for h in $(echo $HOSTAD | xargs); do
    LDAP_HOSTS="${LDAP_PREFIX}${h}:$LDAP_PORT ${LDAP_HOSTS}"
done

# Get datetime in php way
DATETIME=$(date +"%a, %d %b %Y %T %z")

# setup files
echo "===> Setup template files [Snappy app config]"

# replace vars
VARS="${VARS} PASSHASH LDAP_HOSTS LOGS DATETIME"

for f in $(find "${DEFAULTFOLDER}/" -type f -type f \( -name "*.json" -o -name "*.ini" \)) ; do
    echo "===> Provisioning $(echo $f | rev | cut -d '/' -f 1 | rev)..."
    for v in `echo $VARS | xargs` ; do
        # get the var content
        CONTp=${!v}

        # escape possible "/" in there
        CONT=`echo ${CONTp//\//\\\\/}`

        sed -i s/"\_$v\_"/"$CONT"/g ${f}
    done
done

# clean
echo "===> Cleaning..."
apt-get autoremove -y
