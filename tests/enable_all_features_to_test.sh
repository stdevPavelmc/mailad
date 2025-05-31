#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2025 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Enable all features we want to test on the default mailad.conf file
#     for the guthub actions testing
#
# Warning, this script must be called from the root of the repository

# load vars
source .mailadmin.auth

# some local vars
MAILAD_CONF_FILE=./mailad.conf


# Mandatory for testing: secure LDAP
sed -i "s/^SECURELDAP=.*$/SECURELDAP=yes/" $MAILAD_CONF_FILE

# Disable feedback
sed -i "s/^OPT_STATS=.*$/OPT_STATS=no/" $MAILAD_CONF_FILE

# Set default DC to myself for testing
sed -i "s/^HOSTAD=.*$/HOSTAD=mail.mailad.cu/" $MAILAD_CONF_FILE

# Set the LDAPBINDPASSWD
sudo sed -i "s/^LDAPBINDPASSWD=.*$/LDAPBINDPASSWD=${LDAPBINDPASSWD}/" $MAILAD_CONF_FILE

## OPTIONAL FEATURES

# spamd
sed -i "s/^ENABLE_SPAMD=.*$/ENABLE_SPAMD=yes/" $MAILAD_CONF_FILE

# DNSBL
sed -i "s/^ENABLE_DNSBL=.*$/ENABLE_DNSBL=yes/" $MAILAD_CONF_FILE

# AV
sed -i "s/^ENABLE_AV=.*$/ENABLE_AV=yes/" $MAILAD_CONF_FILE
sed -i "s/^AV_UPDATES_USE_PROXY=.*$/AV_UPDATES_USE_PROXY=no/" $MAILAD_CONF_FILE

# Disclaimer
sed -i "s/^ENABLE_DISCLAIMER=.*$/ENABLE_DISCLAIMER=yes/" $MAILAD_CONF_FILE

