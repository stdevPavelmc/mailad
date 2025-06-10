# Características de MailAD Explicadas

Esta es una página larga, así que aquí hay un índice:

* [Webmails](Features.md#webmails)
* [Bajo Consumo de Recursos](Features.md#low-resource-footprint)
* [Protección de Seguridad Contra Ataques Conocidos de SSL y Correo](Features.md#security-protection-against-well-known-SSL-and-mail-attacks)
* [Integración y Gestión con Active Directory](Features.md#active-directory-integration-and-management)
* [Sistema de Cuotas General y Específico](Features.md#general-and-specific-quota-system)
* [Resumen Diario de Tráfico de Correo](Features.md#daily-mail-traffic-summary)
* [Los Datos de Usuarios Eliminados se Manejan con Extremo Cuidado](Features.md#data-from-deleted-users-is-handled-with-extreme-care)
* [Soporte para Certificados Let's Encrypt](Features.md#lets-encrypt-certificates-support)
* [Alias Automáticos Usando Grupos de AD](Features.md#automatic-alias-using-ad-groups)
* [Filtrado Dovecot (Sieve)](Features.md#dovecot-filtering-sieve)
* [Filtrado Avanzado de Correo: Extensiones, Tipos MIME y AV, SPAM y SPF Opcionales](Features.md#advanced-mail-filtering-extensions-mime-types-and-optional-av-spam-and-spf)
* [Almacenamiento Centralizado de Correo](Features.md#centralized-mail-storage)
* [Extras Opcionales de Protección contra SPAM a través de DNSBL y Otros Trucos](Features.md#optional-spam-protection-extras-via-dnsbl-and-other-tricks)
* [Cifrado Opcional para Comunicaciones LDAP](Features.md#optional-encryption-for-LDAP-communications)
* [Notificaciones Opcionales a Grupos en Lugar de Solo al Administrador de Correo](Features.md#optional-notifications-to-groups-instead-of-only-the-mail-admin)
* [Descargo de Responsabilidad Opcional en Cada Correo Saliente](Features.md#optional-disclaimer-on-every-outgoing-mail)
* [Lista Opcional para Todos con Dirección Personalizada](Features.md#optional-everyone-list-with-custom-address)
* [Acceso Opcional de Privilegios de Usuario a través de Grupos de AD](Features.md#optional-user-privilege-access-via-ad-groups)
* [Alias Manuales para Manejar Errores Tipográficos o Posiciones Empresariales](Features.md#manual-alias-to-handle-typos-or-enterprise-positions)
* [Lista Manual de Prohibición para Direcciones Problemáticas](Features.md#manual-ban-list-for-troublesome-address)
* [Listas Manuales de Verificación de Encabezados y Cuerpo](Features.md#manual-headers-and-body-check-lists)
* [Suite de Pruebas](Features.md#test-suite)
* [Opciones de Copia de Seguridad y Restauración en Bruto](Features.md#raw-backup-and-restore-options)
* [Actualizaciones sin Problemas](Features.md#painless-upgrades)
* [Comprobaciones semanales de actualizaciones](Features.md#weekly-update-checks)
* [Buzón físico de los usuarios dividido por ubicación](Features.md#physical-mailbox-of-the-users-split-by-location)

## Webmails

Desde abril de 2025, MailAD admite el uso de un Webmail en el mismo host que el servidor de correo. Estas son algunas características y cosas que debe saber al respecto.

Esta característica es opcional, está deshabilitada de forma predeterminada para mantener la compatibilidad con versiones anteriores; actualice a la última versión de MailAD utilizando las [Instrucciones de actualización](INSTALL.md#upgrading)

- Utiliza de forma predeterminada el nombre de host del servidor de correo, por lo que si su servidor de correo es mail.empresa.cu, entonces el webmail será https://mail.empresa.cu
- Utiliza el servidor web Nginx con php-fpm, utiliza la versión predeterminada de php-fpm en su sistema operativo.
- Utilizará HTTPS de forma predeterminada con el certificado SSL generado por MailAD, o los de Let's Encrypt si están presentes, consulte la instalación para obtener más detalles.
- Si necesita HTTP porque utiliza un proxy inverso con HTTPS para exponerlo al mundo exterior... hay una configuración para forzar HTTP, consulte la sección en /etc/mailad/mailad.conf
- Ofrecemos dos soluciones de webmail populares y de uso gratuito, RoundCube y SnappyMail.
- Ambos webmails utilizarán la autocompletación de correo electrónico desde el servidor LDAP.

### RoundCube

Se instala desde el repositorio de su sistema operativo, por lo que no es de vanguardia pero es estable y probado. Esta es la opción predeterminada porque está en los repositorios del sistema operativo y será fácil de instalar.

Para más detalles, consulte el [Sitio Web Oficial](https://roundcube.net/)

### SnappyMail

Esta es una opción alternativa y se descargará de Internet, por lo que debe configurar las opciones de proxy en el archivo `/etc/mailad/mailad.conf` si utiliza uno en su red. Es un webmail moderno, ligero y receptivo, que evolucionó de RainLoop cuando dejó de mantenerse.

SnappyMail tiene una página de administración especial (https://yourmail.domain.cu/?admin) donde puede instalar complementos adicionales, etc.; durante la instalación, el script le notificará la contraseña predeterminada, si no la ve, también se almacena en el archivo `/etc/mailad/snappy_admin_pass`, el usuario siempre es `admin`.

Aviso: después de una reconfiguración, actualización o re-aprovisionamiento, cualquier complemento que haya instalado puede borrarse; lo siento por eso.

Para más detalles, consulte el [Sitio Web Oficial](https://snappymail.eu/)

[Volver al índice](Features.md#mailad-features-explained)

## Bajo Consumo de Recursos

Esta solución se está utilizando en producción y los requisitos mínimos con todas las características son:

- RAM: 2GB
- CPU: 2 núcleos
- HDD: 2GB libres (no incluye almacenamiento de correo electrónico, ya que depende de sus necesidades)

La característica más exigente es el filtrado de SPAM y Antivirus (AV), sin eso, la RAM puede reducirse a 1GB. Sin embargo, los requisitos de hardware reales dependen de los patrones de uso de su servidor de correo y deben ajustarse en el momento.

Si está dispuesto, por favor comparta algunas estadísticas y detalles de hardware conmigo para actualizar esta sección (configuración de hardware, características activadas, flujo de correo diario/mensual, etc.).

[Volver al índice](Features.md#mailad-features-explained)

## Protección de Seguridad Contra Ataques Conocidos de SSL y Correo

- Se cubren vulnerabilidades conocidas de SSL/TLS como LOGJAM, SSL FREAK, POODLE, etc.
- También se cubren las vulnerabilidades conocidas de Postfix y Dovecot.
- Construido utilizando las mejores prácticas de seguridad.
- Lo mantendremos actualizado contra amenazas emergentes:
  - Solución para un truco reciente de spammer: falsificación del From/Return-Path para hacer que los usuarios piensen que los correos son legítimos cuando no lo son.
  - Prohibición (rechazo) de correos electrónicos sin asunto, un truco común de spammer
  - Ataque de contrabando SMTP [https://www.postfix.org/smtp-smuggling.html]

Respaldado por el conocimiento colectivo de la comunidad de SysAdmins [SysAdminsdeCuba](https://t.me/sysadmincuba).

[Volver al índice](Features.md#mailad-features-explained)

## Integración y Gestión con Active Directory

Este script está destinado a aprovisionar un servidor de correo corporativo dentro de una DMZ y detrás de una solución de puerta de enlace de correo perimetral (uso la versión más reciente de Proxmox Mail Gateway).

Los detalles básicos del usuario (correo electrónico y contraseña) se obtienen de un servidor Active Directory (AD) basado en Windows o Samba (recomiendo Samba 4 en Linux). En lugar de eso, la gestión de usuarios se delega a la interfaz que utiliza para controlar Active Directory, no se necesita ningún otro servicio. NO toque el servidor de correo para cambios relacionados con los usuarios.

Para un administrador de Windows, esto será fácil, simplemente configure e implemente el servidor de correo, luego controle los usuarios en la interfaz AD de su PC (RSAT), consulte los detalles en el archivo [AD_Requirements.md](AD_Requirements.md).

Si es usuario de Linux, puede usar `samba-tool` para administrar usuarios de dominio en el shell o usar RSAT en una máquina virtual de Windows con acceso remoto.

[Volver al índice](Features.md#mailad-features-explained)

## Sistema de Cuotas General y Específico

_**Aviso:** Esta característica se introdujo en febrero de 2021 y si tiene MailAD de una versión anterior, lea esto primero y luego vaya al archivo [Simplify_AD_config.md](Simplify_AD_config.md) para ver instrucciones sobre cómo migrar._

Eventualmente o desde el principio, necesitará un sistema de cuotas. Los correos electrónicos se acumulan en los buzones de los usuarios, proponemos un sistema de cuotas General y Específico (individual o por usuario).

### Cuota General

Hay una cuota general declarada por defecto para el buzón de cada usuario individual, puede encontrarla en el archivo `/etc/mailad/mailad.conf` como una variable llamada `DEFAULT_MAILBOX_SIZE` y está establecida por defecto en 200 MB. Así que cualquier usuario nuevo estará vinculado a esa cuota sin configuración adicional.

Pero, ¿qué pasa con esos usuarios de alto volumen? Si necesita aumentar el límite para algunos usuarios específicos... (o reducirlo para otros...):

### Cuota Específica

Si necesita aumentar (o reducir) el límite de cuota para un usuario específico, simplemente vaya a sus propiedades en el AD y establezca el nuevo valor en la propiedad llamada "Página Web" ("Web Page" en inglés, atributo ldap "wWWHomePage") como en esta imagen para el usuario "Pavel" que tiene una cuota específica de 1G (1 GByte).

![detalles de usuario admin](imgs/admin_user_details.png)

Las unidades son estándar:

- #K: KBytes como 800K
- #M: MBytes como 500M
- #G: GBytes como 1G
- #T: TBytes como 1T

Hay una restricción leve aquí: no se le permite usar decimales, pero puede usar la unidad inferior para obtener el mismo efecto: en lugar de 1.5G puede decir 1500M.

[Volver al índice](Features.md#mailad-features-explained)

## Resumen Diario de Tráfico de Correo

La cuenta configurada como administrador del sistema de correo _(o las asociadas al grupo SYSADMINS, si se especifica)_ recibirá un resumen de tráfico de correo (diario) del día anterior. El resumen se construye con la herramienta pflogsumm.

[Volver al índice](Features.md#mailad-features-explained)

## Los Datos de Usuarios Eliminados se Manejan con Extremo Cuidado

En la mayoría de los servidores de correo, cuando elimina un usuario del sistema, su almacenamiento de correo (maildir en nuestro caso) se borra automáticamente. En nuestro caso, elegimos actuar con más precaución: el maildir del usuario no se eliminará instantáneamente.

Dejaremos el maildir del usuario intacto para que revise o recupere cualquier correo electrónico crítico para el negocio. Puede recuperar el correo volviendo a crear la cuenta de usuario en el AD e iniciando sesión con las credenciales.

Cada mes recibirá un correo de su servidor de correo notificándole sobre maildirs abandonados, es libre de tomar medidas al respecto (generalmente hacer una copia de seguridad y luego borrar el maildir ofensivo es suficiente).

Aquí jugamos un truco:

- Los administradores con maildirs para usuarios eliminados entre 0 y 10 meses (en realidad 9.7) serán notificados para tomar medidas.
- Los administradores con maildirs para usuarios eliminados entre 10 y 11.999 meses serán advertidos sobre la eliminación inminente.
- Los maildirs para usuarios eliminados con más de 365 días (1 año) serán eliminados automáticamente.

[Volver al índice](Features.md#mailad-features-explained)

## Soporte para Certificados Let's Encrypt

Desde junio de 2020, MailAD admite certificados Let's Encrypt. Si tiene un certificado Let's Encrypt válido en su servidor, MailAD lo detectará y lo utilizará.

Para que esto funcione, debe tener un certificado válido en la ruta `/etc/letsencrypt/live/mail.domain.tld/` donde mail.domain.tld es el nombre de host de su servidor de correo.

Si no tiene un certificado Let's Encrypt, MailAD generará un certificado autofirmado para usted.

[Volver al índice](Features.md#mailad-features-explained)

## Alias Automáticos Usando Grupos de AD

Desde junio de 2020, MailAD admite alias automáticos utilizando grupos de AD. Esto significa que puede crear un grupo en su AD y todos los miembros de ese grupo recibirán correos enviados a ese grupo.

Para que esto funcione, debe crear un grupo en su AD con un nombre que comience con "mail-" y luego agregar usuarios a ese grupo. Por ejemplo, si crea un grupo llamado "mail-developers", todos los miembros de ese grupo recibirán correos enviados a developers@domain.tld.

[Volver al índice](Features.md#mailad-features-explained)

## Filtrado Dovecot (Sieve)

Desde junio de 2020, MailAD admite filtrado Dovecot (Sieve). Esto significa que los usuarios pueden crear reglas de filtrado para sus correos.

Para que esto funcione, los usuarios deben crear un archivo llamado `.dovecot.sieve` en su directorio de inicio. Este archivo debe contener reglas de filtrado válidas de Sieve.

[Volver al índice](Features.md#mailad-features-explained)

## Filtrado Avanzado de Correo: Extensiones, Tipos MIME y AV, SPAM y SPF Opcionales

MailAD admite filtrado avanzado de correo. Esto incluye:

- Filtrado de extensiones: puede bloquear correos con archivos adjuntos con ciertas extensiones.
- Filtrado de tipos MIME: puede bloquear correos con archivos adjuntos de ciertos tipos MIME.
- Filtrado AV: puede escanear correos en busca de virus utilizando ClamAV.
- Filtrado SPAM: puede escanear correos en busca de SPAM utilizando SpamAssassin.
- Filtrado SPF: puede verificar si el remitente está autorizado a enviar correos desde su dominio.

[Volver al índice](Features.md#mailad-features-explained)

## Almacenamiento Centralizado de Correo

MailAD utiliza un almacenamiento centralizado de correo. Esto significa que todos los correos se almacenan en un solo lugar, lo que facilita la copia de seguridad y la restauración.

[Volver al índice](Features.md#mailad-features-explained)

## Extras Opcionales de Protección contra SPAM a través de DNSBL y Otros Trucos

MailAD admite extras opcionales de protección contra SPAM. Esto incluye:

- DNSBL: puede bloquear correos de remitentes conocidos de SPAM utilizando listas negras DNS.
- Otros trucos: puede utilizar varios trucos para bloquear SPAM, como bloquear correos sin asunto, bloquear correos con ciertos patrones en el asunto, etc.

[Volver al índice](Features.md#mailad-features-explained)

## Cifrado Opcional para Comunicaciones LDAP

MailAD admite cifrado opcional para comunicaciones LDAP. Esto significa que puede cifrar la comunicación entre MailAD y su servidor LDAP.

[Volver al índice](Features.md#mailad-features-explained)

## Notificaciones Opcionales a Grupos en Lugar de Solo al Administrador de Correo

MailAD admite notificaciones opcionales a grupos en lugar de solo al administrador de correo. Esto significa que puede enviar notificaciones a un grupo de usuarios en lugar de solo al administrador de correo.

[Volver al índice](Features.md#mailad-features-explained)

## Descargo de Responsabilidad Opcional en Cada Correo Saliente

MailAD admite un descargo de responsabilidad opcional en cada correo saliente. Esto significa que puede agregar un descargo de responsabilidad a cada correo que sale de su servidor.

[Volver al índice](Features.md#mailad-features-explained)

## Lista Opcional para Todos con Dirección Personalizada

MailAD admite una lista opcional para todos con dirección personalizada. Esto significa que puede crear una lista que incluya a todos los usuarios de su dominio.

[Volver al índice](Features.md#mailad-features-explained)

## Acceso Opcional de Privilegios de Usuario a través de Grupos de AD

MailAD admite acceso opcional de privilegios de usuario a través de grupos de AD. Esto significa que puede controlar qué usuarios tienen acceso a qué recursos utilizando grupos de AD.

[Volver al índice](Features.md#mailad-features-explained)

## Alias Manuales para Manejar Errores Tipográficos o Posiciones Empresariales

MailAD admite alias manuales para manejar errores tipográficos o posiciones empresariales. Esto significa que puede crear alias para direcciones comúnmente mal escritas o para posiciones empresariales.

[Volver al índice](Features.md#mailad-features-explained)

## Lista Manual de Prohibición para Direcciones Problemáticas

MailAD admite una lista manual de prohibición para direcciones problemáticas. Esto significa que puede bloquear correos de direcciones específicas.

[Volver al índice](Features.md#mailad-features-explained)

## Listas Manuales de Verificación de Encabezados y Cuerpo

MailAD admite listas manuales de verificación de encabezados y cuerpo. Esto significa que puede bloquear correos basados en patrones en los encabezados o el cuerpo del correo.

[Volver al índice](Features.md#mailad-features-explained)

## Suite de Pruebas

MailAD incluye una suite de pruebas para verificar que su servidor de correo esté funcionando correctamente.

[Volver al índice](Features.md#mailad-features-explained)

## Opciones de Copia de Seguridad y Restauración en Bruto

MailAD incluye opciones de copia de seguridad y restauración en bruto. Esto significa que puede hacer una copia de seguridad de su servidor de correo y restaurarlo en caso de fallo.

[Volver al índice](Features.md#mailad-features-explained)

## Actualizaciones sin Problemas

MailAD admite actualizaciones sin problemas. Esto significa que puede actualizar su servidor de correo sin perder datos o configuración.

[Volver al índice](Features.md#mailad-features-explained)

## Comprobaciones semanales de actualizaciones

MailAD realiza comprobaciones semanales de actualizaciones. Esto significa que su servidor de correo verificará si hay actualizaciones disponibles y le notificará si las hay.

[Volver al índice](Features.md#mailad-features-explained)

## Buzón físico de los usuarios dividido por ubicación

MailAD admite la división del buzón físico de los usuarios por ubicación. Esto significa que puede dividir los buzones de los usuarios por oficina, provincia, ciudad, etc.

[Volver al índice](Features.md#mailad-features-explained)

FIN DEL ARCHIVO

