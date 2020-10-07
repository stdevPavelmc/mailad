#!/bin/sh

PERCENT=$1
USER=$2
cat << EOF | /usr/lib/dovecot/dovecot-lda -d $USER -o "plugin/quota=maildir:User quota:noenforcing"
From: postmaster@_DOMAIN_
Subject: Advertencia de buzon de correos / Mail quota warning

Tu buzon de correo esta al $PERCENT% lleno, por favor elimine correos viejos.

Si no lo hace puede empezar a perder correos, es decir reboratán porque ha excedido su cuota 

Your mailbox is now $PERCENT% full, please clean up your mailbox.
EOF
