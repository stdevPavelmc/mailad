#!/bin/bash

export PERCENT=$1
export USER=$2
BASE=/etc/dovecot/scripts
MESSAGE=almost.eml

# Over quota - short message
if [ "$PERCENT" == "over" ] ; then
  MESSAGE=over.eml
fi

# Back under quota
if [ "$PERCENT" == "under" ] ; then
  MESSAGE=under.eml
fi

# Send it, by default the persent based one
cat $BASE/$MESSAGE | envsubst | /usr/lib/dovecot/dovecot-lda -d $USER -o "plugin/quota=maildir:User quota:noenforcing"
