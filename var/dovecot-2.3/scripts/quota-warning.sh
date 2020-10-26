#!/bin/sh

PERCENT=$1
USER=$2
cat << EOF | /usr/lib/dovecot/dovecot-lda -d $USER -o "plugin/quota=maildir:User quota:noenforcing"
From: postmaster@_DOMAIN_
Subject: =?UTF-8?Q?IMPORTANTE=3a_Advertencia_de_buz=c3=b3n_de_correos_al_llenarse!?=
MIME-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------33614E10DDD5815C41E63713"
Content-Language: es-CU

This is a multi-part message in MIME format.
--------------33614E10DDD5815C41E63713
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit

Saludos $USER, este es un mensaje automático del servidor de correos.

Su buzón de correo justo ha sobrepasado el $PERCENT% de capacidad,
eso significa que pronto se llenará y comenzará a perder correos.

Para evitar esto puede realizar las siguientes acciones:

 1. Borrar correos viejos.
 2. Borrar correos con adjuntos muy grandes que ya halla salvado.
 3. Vaciar la papelera de correos.
 4. Revisar el correo varias veces luego de hacer estas acciones.

Gracias, MailAD mail server.

--------------33614E10DDD5815C41E63713
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>

    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
  </head>
  <body>
    <p>Saludos $USER, este es un mensaje autom&aacute;tico del servidor de correos. </p>
    <p>Su buzón de correo justo ha sobrepasado el <b>$PERCENT%</b> de capacidad,
      eso significa que pronto se llenar&aacute; y comenzar&aacute; a perder correos.</p>
    <p>Para evitar esto puede realizar las siguientes acciones:</p>
    <ol>
      <li>Borrar correos viejos.</li>
      <li>Borrar correos con adjuntos muy grandes que ya halla salvado.</li>
      <li>Vaciar la papelera de correos.</li>
      <li>Revisar el correo varias veces luego de hacer estas acciones.</li>
    </ol>
    Gracias, MailAD mail server.
  </body>
</html>

--------------33614E10DDD5815C41E63713--
EOF
