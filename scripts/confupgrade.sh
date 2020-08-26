#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Upgrade the /etc/mailad/mailad.conf file if needed
#   - Warn the user about a new features or config var he need to know

# Get all the vars
CONVARS=`cat /etc/mailad/mailad.conf | grep -v "#" | grep "=" | cut -d "=" -f 1 | tr '\n' ' '`

# load the actual confver
source ./mailad.conf

# store it on another var and erase it
NCONFVER=$CONFVER
unset CONFVER

# load the one on the file
source /etc/mailad/mailad.conf

# compare
if [ "$CONFVER" == "$NCONFVER" ] ; then
    # Same version, no upgrade needed
    echo "===> Same version, no upgrade needed"
    exit 0  
fi

### needs upgrade
echo "===> Different versions of config file, doing upgrade"

### Update the version for the update
CONFVER=$NCONFVER

# backup the actual config with a timestamp
TS=`date +"%Y%m%d_%H%M%S"`
cp /etc/mailad/mailad.conf /etc/mailad/mailad.conf_$TS

# create a target file to work with
cat mailad.conf > /etc/mailad/mailad.conf

# loop in the options and switch them as needed
for O in `echo $CONVARS | xargs` ; do
    # get the raw content of the var
    Vr=${!O}
    # excape possibles / in the string
    V=`echo ${Vr//\//\\\\/}`

    # substitute in the file
    sed -i s/"^${O}=.*$"/"${O}=\"${V}\""/ /etc/mailad/mailad.conf 
done

#advice
echo "===> Upgrade done"

# Warning: 
echo "############################################################"
echo "# Configuration file /etc/mailad/mailad.conf was upgraded! #"
echo "#                                                          #"
echo "# Please take a peek on the file, usually a new config     #"
echo "# option is added for a new feature, also take a peek on   #"
echo "# the CHANGELOG.md file to see that was the change         #"
echo "############################################################"
echo " "
echo "===> Upgrade will resume in short (15 seconds)"

sleep 10

