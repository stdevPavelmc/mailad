<!-- Traducido por: @cz9dev "Carlos Zaldivar" <cz9dev@gmail.com> -->
# Requisitos de Active Directory para esta herramienta

Como mencionamos anteriormente, esta herramienta supone que tiene acceso administrativo a un servidor Active Directory bien configurado.

Recomendamos el uso de Samba 4 AD. Internet está lleno de buenos tutoriales sobre cómo usar Samba como controlador AD; pero si solo está probando MailAD, eche un vistazo al  [Utils README](utils/README.md) for a recipe to deploy a testing Samba 4 domain.

## LDAPS o cómo proteger sus comunicaciones LDAP

Si utiliza Samba 4, puede comenzar a utilizar LDAP seguro (LDAPS) desde el principio. Solo tiene que especificar `SECURELDAP=yes` en el archivo `/etc/mailad/mailad.conf` al configurar la provisión.

Si necesita o desea ejecutarlo en texto simple, debe realizar un cambio en la configuración de Samba (a partir de la versión 4.x, el valor predeterminado es LDAPS, es decir: el LDAP simple está deshabilitado). Para habilitar el LDAP simple, busque la sección [global] en su archivo `/etc/samba/smb.conf` y agregue esto al final de la sección. Tenga en cuenta que debe evitar usar LDAP simple en cualquier escenario: use LDAPS en su lugar.

``` sh
[global]
    ... your configs ...

    # to allow to talk with the linux boxes in an insecure way (only in DMZ envs)
    ldap server require strong auth = no

```

Si utiliza un servidor Windows AD, de manera predeterminada debe utilizar LDAP simple (sin seguridad); para habilitar LDAPS, debe leer la sección [Cifrado opcional para comunicaciones LDAP](Features.md#optional-encryption-for-LDAP-communications) en el archivo Features.md para saber cómo habilitarlo

## RSAT (Kit de herramientas de administración de servidores remotos)

Para gestionar la administración de usuarios recomendamos utilizar una PC con Windows con las herramientas RSAT instaladas. Seguro que puedes utilizar la interfaz de línea de comandos (CLI) en Linux para gestionar eso, pero es difícil para los principiantes. Si quieres aventurarte en ese campo, el comando es `samba-tool` y tiene todas las opciones que necesitas, pero no cubriremos ese tema aquí.

## Linux - Enlace AD

Para vincular el servidor de correo Linux con el AD, utilizamos un usuario simple (¡no un administrador!). Los detalles predeterminados para este usuario se muestran a continuación:

- Nombre de usuario: `linux`.
- Contraseña: `Passw0rd---` _**Advertencia**: `(¡Este es el valor predeterminado, debe cambiarlo!)`_.
- Ese usuario debe estar ubicado en la carpeta del árbol de AD predeterminada `Usuarios`, NO en la unidad organizativa organizativa (consulte la imagen a continuación).

![linux user image](imgs/sample_ad_listing_linux_user.png)

## Configuración de Active Directory

El directorio activo debe estar organizado de manera que tenga una OU principal que contenga todos los usuarios del dominio, en este ejemplo esta OU se llama `CO7WT` y dentro de ella puede crear la estructura de organización que se ajuste a sus necesidades. En mi caso el usuario "Pavel" pertenece a la OU "Informática" (ver imagen a continuación)

Debe declarar al menos un usuario para fines de administración en la etapa de configuración, en la imagen a continuación podemos ver una muestra de ello.

![admin use details](imgs/admin_user_details.png)

El único detalle que debes tener en cuenta aquí es la propiedad Email del usuario ("Correo electrónico" en este caso); para que un usuario esté activo en el servidor de correo solo necesitas lo siguiente:

- Usuario activo y no bloqueado.
- Propiedad Email configurada y que coincida con el dominio que estás configurando.
- Opcionalmente, una cuota específica para este usuario en la propiedad "Página Web" ("Página Web" en este caso, consulta el archivo Features para más detalles)

## Configuración de usuario

La configuración del usuario se realiza igual que la del usuario administrador, un usuario ubicado dentro del árbol de la OU base y un conjunto de propiedades de correo electrónico.

En el pasado (antes de febrero de 2020), teníamos otro esquema para la configuración del usuario. Si venía de una configuración anterior a esa fecha, **debe** leer esto: [Simplificar la configuración de AD](Simplify_AD_config.md)
