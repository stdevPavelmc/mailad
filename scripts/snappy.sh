#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2024-2025 Pavel Milanes Costa <pavelmc@gmail.com>
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
apt-get remove ${APT_OPTS} $ROUNDCUBE_PKGS

# notice
echo "===> Installing SnappyMail webmail"

SNAPPY_VERSION="2.38.2"
SNAPPY_FILE="snappymail-${SNAPPY_VERSION}.tar.gz"
SNAPPY_URL="https://github.com/the-djmaze/snappymail/releases/download/v${SNAPPY_VERSION}/${SNAPPY_FILE}"
#SNAPPY_URL="http://10.0.3.1:8081/$SNAPPY_FILE"

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
apt-get install ${APT_OPTS} $SNAPPY_PKGS

# preserve PWD
BPWD=$(pwd)

# create log folder
LOGS="/var/log/snappymail/"
mkdir -p $LOGS
sudo chown -R root:www-data $LOGS
sudo chmod -R 775 $LOGS

# notice
echo "===> Pre-setup done, downloading SnappyMail package..."

# Install Snappy Webmail
FILE=$(mktemp)
R=0
# test if snappy is here to use in develop
if [ -f "./$SNAPPY_FILE" -a "$DOMAIN" == "mailad.cu" ]; then
    cp "./$SNAPPY_FILE" "/tmp/$SNAPPY_FILE"
else
    wget -q --no-clobber "$SNAPPY_URL" -O "/tmp/$SNAPPY_FILE"
    R=$?
fi

# check if download fails
if [ $R -ne 0 -a $R -ne 1 ]; then
    echo "===> Error!" > $FILE
    echo "  Download of the snappymail package failed" >> $FILE
    echo "  URL is: $SNAPPY_URL" >> $FILE
    echo "  This is a connectivity issue, if you use a proxy go to /etc/mailad/mailad.conf" >> $FILE
    echo "  and configure the proxy there." >> $FILE
    echo "" >> $FILE
    echo "  Webmail Installation aborted" >> $FILE

    # dump msg $FILE
    cat $FILE

    # add some instructions for the email
    echo "" >> $FILE
    echo "  You can try later with the command: make webmail" >> $FILE
    echo "" >> $FILE

    # send the email as a reminder
    send_email "MailAD provision error." "$ADMINMAIL" "$FILE"

    exit 1
fi
mkdir -p ${SNAPPY_DIR}
cd ${SNAPPY_DIR}
cp /tmp/$SNAPPY_FILE ./
tar xzf ${SNAPPY_FILE}
fixperms /var/www
rm $SNAPPY_FILE

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

# add the some local vars to the list
WWW_ROOT="/var/www/snappymail"
VARS="${VARS} WWW_ROOT"

# replace vars
echo "===> Provisioning Nginx..."
for v in $(echo $VARS | xargs) ; do
    # get the var content
    CONTp=${!v}

    # escape possible "/" in there [KEEP THE BACKTICKS]
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

# small delay to allow the service to create the default config; options
OPTS="--no-check-certificate"
if [ "$WEBSERVER_HTTP_ENABLED" == "yes" ]; then OPTS="--no-hsts" ; fi
while [ ! -f "$PASS" ] ; do
    # get it...
    wget -q ${OPTS} "$WEBPROTO://$HOSTNAME/?admin" -O /dev/null
    sleep 2
    wget -q ${OPTS} "$WEBPROTO://$HOSTNAME/?/AdminAppData/0/5220854561746323/" -O /dev/null
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
cp -Rf ./var/snappy/* ${DEFAULTFOLDER}/
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
    for v in $(echo $VARS | xargs) ; do
        # get the var content
        CONTp=${!v}

        # escape possible "/" in there [KEEP THE BACKTICKS]
        CONT=`echo ${CONTp//\//\\\\/}`

        sed -i s/"\_$v\_"/"$CONT"/g ${f}
    done
done

# clean
echo "===> Cleaning..."
apt-get autoremove ${APT_OPTS}
