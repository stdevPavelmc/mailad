#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2019..2022 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later
#
# Goal:
#   - Check if there is a new version of the software
#   - If so, get the new changes from the CHANGELOG.md file against the actual CHANGELOG.md
#   - Warn the sysadmins/postmaster about the new changes
#
# NOTE: This file does not link to the common.conf as this is run as standalone
# in the system...

# load conf files
source /etc/mailad/mailad.conf

# Vars
CHANGELOG="/etc/mailad/changelog.latest"
REPO_URL="https://github.com/stdevPavelmc/mailad"
UPSTREAM_VERSION_URL="${REPO_URL}/raw/master/VERSION"
UPSTREAM_VERSION_TMP="/tmp/VERSION"
UPSTREAM_VERSION='v1.0.0'
VERSION='v0.1.0'
MAIL=`mktemp`

# TODO
# - Add the proxy settings if present, data from /etc/mailad/mailad.conf

# check if we was run on debug mode
DEBUG=''
if [ "$1" == "-d" ] ; then
    DEBUG=1
    echo "Script ran in DEBUG mode, no mail will be sent, just info."
fi

# proxy detection
PROXY=''
if [ "${PROXY_HOST}" -a "${PROXY_PORT}" ] ; then
    # user/passwd?
    if [ "${PROXY_USER}" -a "${PROXY_PASS}" ] ; then
        # user and password
        PROXY="http://${PROXY_USER}:${PROXY_PASS}@${PROXY_HOST}:${PROXY_PORT}/"
    else
        # no user
        # user and password
        PROXY="http://${PROXY_HOST}:${PROXY_PORT}/"
    fi

    # Set the env var
    export http_proxy="${PROXY}"
    export https_proxy="${PROXY}"
fi

# Get actual changelog version
if [ -f "${CHANGELOG}" ] ; then
    # sample:
    # ## [v1.0.0] - 2022-09-04 v1.0.0
    VERSION=`cat "${CHANGELOG}" | grep "##" | head -n 1 | awk '{print $2}' | tr -d "[]"`
    
    # DEBUG
    if [ "${DEBUG}" ] ; then
        echo "Found Local version: ${VERSION}"
    fi
else
    # nothing to do, exit
    exit 0
fi

# Get upstream version
if wget -q "${UPSTREAM_VERSION_URL}" -O "${UPSTREAM_VERSION_TMP}" ; then
    # All fine, got file
    UPSTREAM_VERSION=`cat "${UPSTREAM_VERSION_TMP}" | head -n 1`

    # DEBUG
    if [ "${DEBUG}" ] ; then
        echo "Found UPSTREAM VERSION: ${UPSTREAM_VERSION}"
    fi

    # Compare versions
    if [ "${UPSTREAM_VERSION}" != "${VERSION}" ] ; then
        # new version!

        # Get the notable changes
        TMPCGL="/tmp/CHANGELOG.md"
        rm "${TMPCGL}" 2>/dev/null
        wget -q "${REPO_URL}/raw/master/CHANGELOG.md" -O ${TMPCGL}
        CHANGES=`diff "${TMPCGL}" "${CHANGELOG}" | sed s/"^< "/''/g | egrep -v -E -i '^.{1,3},.{1,3}d.{1,3}'`

        # output message
        echo "Hi there" > ${MAIL}
        echo "" >> ${MAIL}
        echo "Great news: there is a new version of MailAD!" >> ${MAIL}
        echo "Actual version: ${VERSION}" >> ${MAIL}
        echo "Upstream version: ${UPSTREAM_VERSION}" >> ${MAIL}
        echo "" >> ${MAIL}
        echo "Please go to ${REPO_URL}" >> ${MAIL}
        echo "To see instructions for upgrading, latest changes follows:" >> ${MAIL}
        echo "" >> ${MAIL}
        echo "${CHANGES}" >> ${MAIL}
    fi
else
    # DEBUG
    if [ "${DEBUG}" ] ; then
        echo ""
        echo "Error: can download ${UPSTREAM_VERSION_URL}"
        echo "Will try to do it here for you to catch up the error"
        echo ""
        wget ${UPSTREAM_VERSION_URL} -O /dev/null
    fi

    # Error...
    echo "" > ${MAIL}
    echo "ERROR!" >> ${MAIL}
    echo "" >> ${MAIL}
    echo "There was an error downloading the VERSION file from the MailAD Repository!" >> ${MAIL}
    echo "" >> ${MAIL}
    echo "Please check your internet connection, the proxy settings or any other config" >> ${MAIL}
    echo "That can prevent to reaching to the internet, to check for new version of MailAD" >> ${MAIL}
    echo "" >> ${MAIL}
    echo "This is a weekly task, cu next week if the trouble remains" >> ${MAIL}
    echo "                                                             MailAD services" >> ${MAIL}
    echo "" >> ${MAIL}

    # advice if not in debug mode
    if [ ! "${DEBUG}" ] ; then
        echo ""
        echo "PS: you can test/debug this script by running it like this:"
        echo ""
        echo "$0 -d"
        echo ""
    fi
fi

# send the data in $MAIL if not in debug mode
if [ ! "${DEBUG}" ] ; then
    cat ${MAIL} | mail ${ADMINMAIL} -s "MailAD: checking for a new version..."
    rm ${MAIL}
fi
