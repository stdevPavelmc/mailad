# FAQ de Mailad

Aquí puedes encontrar las preguntas más frecuentes, este archivo crecerá con los comentarios de los usuarios.

## Instalación

- [He instalado según las instrucciones en el archivo INSTALL.md, puedo comprobar y enviar los correos, pero no llegan a la bandeja de entrada de los usuarios](FAQ.es.md#he-instalado-seg%C3%BAn-las-instrucciones-en-el-archivo-installmd-puedo-comprobar-y-enviar-los-correos-pero-no-llegan-a-la-bandeja-de-entrada-de-los-usuarios)
- [Utilizo Debian Buster y puedo enviar emails pero no puedo revisar los emails a través de IMAPS/POP3S](FAQ.es.md#utilizo-debian-buster-y-puedo-enviar-emails-pero-no-puedo-revisar-los-emails-a-trav%C3%A9s-de-imapspop3s)
- [¿Por qué MailAD se niega a instalar ClamAV y/o SpamAssassin alegando algún problema de DNS?](FAQ.es.md#por-qu%C3%A9-mailad-se-niega-a-instalar-clamav-yo-spamassassin-alegando-alg%C3%BAn-problema-de-dns)
- [¿Qué puertos debo abrir para asegurarme de que los servidores funcionen bien?](FAQ.es.md#qu%C3%A9-puertos-debo-abrir-para-asegurarme-de-que-los-servidores-funcionen-bien)
- [He instalado según las instrucciones, todo funciona correctamente pero los usuarios no pueden autenticarse, utilizo Windows server 2019](FAQ.es.md#he-instalado-según-las-instrucciones-todo-funciona-correctamente-pero-algunos-usuario-no-pueden-autenticarse-utilizo-windows-server-2019)

## Utilización

- [Todo funciona bien con algunos clientes de correo electrónico, pero otros fallan con errores relacionados con el SSL y los cifrados](FAQ.es.md#todo-funciona-bien-con-algunos-clientes-de-correo-electr%C3%B3nico-pero-otros-fallan-con-errores-relacionados-con-el-ssl-y-los-cifrados)
- [El servidor se niega a aceptar o a retransmitir correos electrónicos de los usuarios en el puerto 25](FAQ.es.md#el-servidor-se-niega-a-aceptar-o-a-retransmitir-correos-electr%C3%B3nicos-de-los-usuarios-en-el-puerto-25)

**============================== Respuestas =========================**

## He instalado según las instrucciones en el archivo INSTALL.md, puedo comprobar y enviar los correos, pero no llegan a la bandeja de entrada de los usuarios

Eso suele estar relacionado con que el filtrado de correos no funciona, si compruebas en los registros `/var/log/mail.logs` puedes ver algunas líneas como esta:

```
[...] postfix/smtp[1354]: [...] to=<user@domain.tld>, [...] status=deferred (connect to 127.0.0.1[127.0.0.1]:10024: Connection refused)
```

Si ejecutas un comando `mailq` puedes ver algo como esto:

```
[...] amavis@cdomain.tld (connect to 127.0.0.1[127.0.0.1]:10024: Connection refused) [...]
```

Que por lo general debido a que el amavis no funciona porque el spammassasin o el clamav se instalaron pero no se configuraron correctmente o no pueden acceder a los updates (eso debe suceder en la etapa de provisión...)

### Lista de comprobación:

- Si estás detrás de un proxy asegúrate de haber configurado el host, el puerto, el nombre de usuario y la contraseña en el archivo `/etc/mailad/mailad.conf`, si no está configurado, hazlo y forza un re-provisionamiento (`make force-provision` en la carpeta del repositorio)
- Tal vez `spamassassin` falló en la primera compilación de reglas en la etapa de provisión (¿Internet lento?), ejecuta esto como root: `sa-update` hasta que funcione sin ninguna queja, luego reinicia el amavisd-new.

Eso debe resolver este problema.

## Utilizo Debian Buster y puedo enviar emails pero no puedo revisar los emails a través de IMAPS/POP3S

Mirando más de cerca el registro de correo verás algunos errores en el registro de correo relacionados con el __dovecot__ que no se inicia correctamente. ¿Por casualidad estás ejecutando el OS sobre un LXC CT?

Hay un error conocido de __dovecot__ ejecutándose sobre un TC sin privilegios que produce estos errores en el archivo de registro:

```
[...] Failed at step NAMESPACE spawning /usr/sbin/dovecot: Permission denied
```

Lo más común es permitir el anidamiento para ese CT:

- Revisa las opciones/características para la CT.
- Habilitar la anidación.
- Reinicie el CT.

Comprueba ahora, debe funcionar.

## ¿Por qué MailAD se niega a instalar ClamAV y/o SpamAssassin alegando algún problema de DNS?

Hay un hecho simple detrás de eso: ambos (SpamAssassin & ClamAV) usan una consulta DNS a un registro TXT específico para obtener los detalles de su base de datos.

Si no tienes un DNS que funcione, SpamAssassin y ClamAV funcionarán algún tiempo después de la provisión y en 12-48 horas uno de ellos se negará a trabajar, entonces Amavis fallará y todo tu correo (entrando o saliendo del dominio) quedará atrapado en la cola de postfix a amavis durante 4 horas, entonces los usuarios comenzarán a ver las notificaciones de MAILER-DAEMON y te meterás en problemas...

Para evitarlo, hemos colocado un mecanismo de seguridad en la fase de comprobación de la instalación: si se activa el filtrado AV o SA en el archivo de configuración, entonces comprobaremos si podemos obtener las respectivas actualizaciones de la base de datos a través del DNS, si no es así, se verán los errores.

Para resolverlo debes configurar un DNS válido en la PC del correo.

## ¿Qué puertos debo abrir para asegurarme de que los servidores funcionen bien?

Esta pregunta está relacionada con firewalls y DMZ, la respuesta es simple:

### Tráfico entrante

- Puerto 25/TCP (SMTP) solo del mundo exterior o de una puerta de correo, ver comentarios debajo.
- Puerto 465/TCP (STMPTS) de la red de usuarios para clientes antiguos, no recomendado en favor del siguiente (SUBMISSION)
- Puerto 587/TCP (SUBMISSION) de la red de usuarios para enviar correos electrónicos.
- Puerto 993/TCP (IMAPS), forma preferida por los usuarios para comprobar y descargar los correos electrónicos.
- Puerto 995/TCP (POP3S) funcionando pero no recomendado en favor del 993.

### Tráfico saliente

- Puerto 53/UDP/TCP (DNS) para consultar los servidores de entrega de correos, y también para las actualizaciones de las bases de datos de AV y SPAM (si están habilitadas)
- Puertos 80/TCP y 443/TCP (HTTP/HTTPS) para obtener actualizaciones de la AV y SPAMD (si están activados) y para actualizar el sistema operativo.
- Puertos 25/TCP para enviar correos electrónicos al mundo exterior.

Tenga en cuenta que en el tráfico entrante no se permite el tráfico de ningún usuario en el puerto 25. NO PERMITAS a los usuarios utilizar el puerto 25 para enviar correos electrónicos, este puerto está reservado para recibir el tráfico entrante del mundo exterior.

## Todo funciona bien con algunos clientes de correo electrónico, pero otros fallan con errores relacionados con el SSL y los cifrados

Eso es principalmente a causa de un cliente de correo anticuado o de un sistema operativo antiguo, obtendrás estos errores en Windows desde las versiones XP hasta las primeras versiones de Win10 y en clientes de Microsoft; algunos otros clientes de correo electrónico como Thunderbird o Evolution pueden dar estos errores si son muy antiguos (3 años o más).

Problema: MailAD tiene algunas opciones de cifrado deshabilitadas que se sabe que causan problemas de seguridad, puedes aprender sobre eso buscando por términos como "SSL FREAK attack", "POODLE attack", ataques SSL, etc en internet.

Soluciones:

- Actualiza tu cliente de correo, esto normalmente lo arregla si usas software no de Microsoft.
- Si usas el cliente de correo de Microsoft Windows y Outlook, la solución es un poco más difícil:
    - Descarga [IISCrypto](https://www.nartac.com/Products/IISCrypto).
    - Instálalo y ejecútalo.
    - Elija la opción llamada "Mejores prácticas" y luego "Aplicar".
    - Reinicia la computadora.

## El servidor se niega a aceptar o a retransmitir correos electrónicos de los usuarios en el puerto 25

Ese puerto está reservado para recibir correos electrónicos del mundo exterior, los usuarios no pueden usarlo para enviar correos electrónicos, por favor revise [esta otra pregunta](FAQ.es.md#qu%C3%A9-puertos-debo-abrir-para-asegurarme-de-que-los-servidores-funcionen-bien) para saber más.

## He instalado según las instrucciones, todo funciona correctamente, pero algunos usuario no pueden autenticarse, utilizo Windows server 2019

Puede deberse a que los códigos de control de cuenta de usuario (UAC) no son los comunes, esto puede deber a muchas razones, pero las razones no las veremos aquí, veremos mas bien como solucionar el problema:

Normalmente el control de cuenta de usuario veremos que la propiedad **userAccountControl** tiene los valores:

| Código | Descripción |
|---------:|:---------------|
| 512 | Usuario normal|
| 66048| Habilitado, contraseña nunca expira|

En muchos casos, cuando nuestro servidor para autenticarnos es un Windows Server 2019 aparecerán estas propiedades en **userAccountControl**

| Código | Descripción |
|---------:|:---------------|
| 544 | Habilitado, cambio de contraseña en el próximo inicio de sección|
| 66080| Habilitado, contraseña nunca expira, contraseña no requerida|

Para solucionar el problema de autenticación de los usuarios que tienen estas propiedades es necesario agregar en las variables estas propiedades al parámetro **userAccountControl**, es decir cambiar los filtros ¿donde debemos cambiar?

en la raíz de nuestro mailad, buscamos estos archivos y los dejamos como motrámos

```bash
cd var/dovecot-2.2/
nano dovecot_ldap.conf.ext
 .
 .
 .
# Comentamos lo siguiente y la dejamos entonces así
# user_filter = (&(sAMAccountName=%n)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)))
user_filter = (&(sAMAccountName=%n)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)(userAccountControl=544)(userAccountControl=66080)))
.
.
.
# Comentamos lo siguiente y la dejamos entonces así
# pass_filter = (&(mail=%u)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)))
pass_filter = (&(mail=%u)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)(userAccountControl=544)(userAccountControl=66080)))

# Ctrl+X y guardamos los cambios

cd var/dovecot-2.3/
nano dovecot_ldap.conf.ext
.
 .
 .
# Comentamos lo siguiente y la dejamos entonces así
# user_filter = (&(sAMAccountName=%n)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)))
user_filter = (&(sAMAccountName=%n)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)(userAccountControl=544)(userAccountControl=66080)))
.
.
.
# Comentamos lo siguiente y la dejamos entonces así
# pass_filter = (&(mail=%u)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)))
pass_filter = (&(mail=%u)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)(userAccountControl=544)(userAccountControl=66080)))

# Ctrl+X y guardamos los cambios

cd var/postfix/ldap/
nano email2user.cf
.
.
.
# Comentamos lo siguiente y la dejamos entonces así
# query_filter = (&(mail=%u@%d)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)))
query_filter = (&(mail=%u@%d)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)(userAccountControl=544)(userAccountControl=66080)))

# Ctrl+X y guardamos los cambios

nano mailbox_map.cf
.
.
.
# Comentamos lo siguiente y la dejamos entonces así
# query_filter = (&(mail=%u@%d)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)))
query_filter = (&(mail=%u@%d)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)(userAccountControl=544)(userAccountControl=66080)))

# Ctrl+X y guardamos los cambios

cd var/roundcube/
nano config.inc.php
.
.
.
# Lo dejamos como sigue a continuación
'filter'        => '(&(mail=*)(|(objectClass=group)(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)(userAccountControl=66080)(userAccountControl=544)))',

# Ctrl+X y guardamos los cambios
```

Así mismo si tu entidad posee otros atributos (UAC) debes modificar todos los filtros dentro de *var* para adaptarlas a tus necesidades.

### Actualizar a una nueva versión si hemos modificado (adactado) los filtros a nuestra entidad

Luego de hacer el **upgrade** a la nueva versión, debemos nuevamente ir a todos estos filtros y cambiarlos a nuestra necesidades y luego hacer un **provition** para que ponga nuestras propiedades de filtros (UAC)
