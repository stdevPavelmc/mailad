# Instrucciones de Instalación de MailAD

Consulta esta [grabación simple de consola](https://asciinema.org/a/fD1LuVLfeb8RPCHOIgbR1J9d8) para ver cómo se ve una instalación normal.

⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️

**ADVERTENCIA:** Desde finales de febrero de 2021, simplificamos la integración con AD, **necesitas** consultar [este documento](Simplify-AD-config.md) si deseas actualizar tu configuración antigua.

Los usuarios de nuevas instalaciones no tendrán problemas, simplemente sigue el procedimiento de instalación a continuación y estarás seguro.

## Un aviso sobre la compatibilidad con sistemas operativos

Se recomienda instalar MailAD en la última versión LTS de Ubuntu o la última versión estable de Debian. Cualquier distribución más antigua es compatible (consulta README para la matriz de compatibilidad de sistemas operativos) pero no se recomienda para nuevas instalaciones, solo para operaciones y actualizaciones.

¿Qué pasa si tengo MailAD instalado en una distribución más antigua, como 2 versiones LTS de Ubuntu o 2 versiones de Debian anteriores?

Fácil: simplemente actualiza la distribución a la última versión (sigue la forma preferida para tu distribución), reinicia y luego ejecuta `make force-provision` en la carpeta del repositorio de MailAD. Solo eso.

**Aviso:** Debes evitar que los usuarios utilicen los servicios de correo durante el proceso de actualización, de lo contrario, los usuarios pueden perder sus buzones debido a la corrupción.

## Introducción y Verificaciones

Para evitar problemas de permisos, recomendamos que mantengas los archivos en el directorio `/root`, por lo que a partir de este momento necesitas ser root para ejecutar los siguientes comandos, `sudo -i` es tu amigo si no eres root.

Si estás detrás de un proxy, recuerda que puedes usar apt a través de él para actualizar, mejorar e instalar las aplicaciones necesarias. Solo exporta las siguientes variables y todo el tráfico se enrutará a la red externa a través de tu proxy declarado, aquí tienes un ejemplo:

``` sh
export http_proxy="http://usuario:contraseña@proxy.empresa.cu:3128/"
export https_proxy="http://usuario:contraseña@proxy.empresa.cu:3128/"
```

También necesitas configurar un proxy para que git funcione, simplemente haz esto (si no lo has hecho ya):

``` sh
echo "[http]" >> ~/.gitconfig
echo "    proxy = http://usuario:contraseña@proxy.empresa.cu:3128/" >> ~/.gitconfig
```

Si tu configuración utiliza un proxy sin autenticación de nombre de usuario y contraseña, simplemente omite la parte "usuario:contraseña@" en las líneas anteriores, así: `http://proxy.empresa.cu:3128/`

Recuerda sustituir `usuario`, `contraseña`, `proxy.empresa.cu` (nombre de dominio completo del servidor proxy) y `3128` (puerto) con los valores correctos para tu entorno.

## Configuración Inicial

Simplemente actualiza y mejora tu sistema, instala las dependencias y clona este repositorio en `/root`, así:

**¡Advertencia! la rama recomendada para entornos de producción es la rama master, ¡no uses ninguna otra rama en producción!**

``` sh
cd /root
apt update
apt upgrade
apt install git make -y
git clone https://github.com/stdevPavelmc/mailad
cd mailad
git checkout master
git pull
```

## Prepara Tu Servidor

Para preparar tu servidor para la instalación, primero debes crear la configuración predeterminada. Para eso, simplemente ejecuta este comando:

``` sh
make conf
```

Este paso creará la carpeta /etc/mailad y colocará un archivo mailad.conf predeterminado en ella. Ahora estás listo para comenzar a configurar tu sistema.

## Configuración Inicial

Lee y completa todas las variables necesarias en el archivo `/etc/mailad/mailad.conf`, ¡por favor lee cuidadosamente y elige sabiamente!

_En este punto, los rápidos y furiosos pueden simplemente ejecutar `make all` y seguir las pistas, el resto de los mortales simplemente sigue los siguientes pasos_

## Manejo de Dependencias

Llama a las dependencias para instalar todas las herramientas necesarias, así:

``` sh
make deps
```

Esto instalará un grupo de herramientas necesarias para ejecutar los scripts de aprovisionamiento, si todo va bien, no debe mostrarse ningún error; si se muestra un error, entonces debes solucionarlo, ya que el 99% de las veces será un problema relacionado con el enlace del repositorio y las actualizaciones.

## Verificaciones

Una vez que hayas instalado las dependencias, es hora de verificar la configuración local en busca de errores:

``` sh
make conf-check
```

Esto verificará algunos de los escenarios y configuraciones predefinidos, si se encuentra algún problema, se te advertirá al respecto.

### Problemas Más Comunes

- Nombre de host: tu servidor necesita conocer tu nombre de host completo, consulta [este tutorial](https://gridscale.io/en/community/tutorials/hostname-fqdn-ubuntu/) para saber cómo resolver ese problema
- Errores de ldapsearch: el 100% de las veces se debe a un error tipográfico en el archivo mailad.conf, revísalo cuidadosamente

Estamos listos para instalar ahora... ¡Oh, espera! Necesitamos generar los certificados SSL primero ;-)

## Creación de Certificados

Todas las comunicaciones del cliente deben estar cifradas, por lo que necesitarás al menos un certificado autofirmado para uso interno. Este certificado será utilizado por postfix y dovecot.

Si procedes, el script de MailAD generará un certificado autofirmado que durará 10 años, o si tienes certificados de Let's Encrypt (LE para abreviar), también puedes usarlos, tanto independientes como comodín son buenas opciones.

En caso de que tengas certificados LE, usarlos es simple. Simplemente toma aquellos llamados "fullchain*" y "privkey*" y colócalos en la carpeta `/etc/mailad/le/`, nómbralos `fullchain.pem` y `privkey.pem` respectivamente para que los scripts de aprovisionamiento puedan usarlos.

``` sh
make certs
```

Los certificados finales estarán en este lugar (si estás usando certificados LE, serán copiados y asegurados):

- Certificado: `/etc/ssl/certs/mail.crt`
- Clave Privada: `/etc/ssl/private/mail.key`
- Certificado CA: `/etc/ssl/certs/cacert.pem`

Si obtienes certificados LE para tu servidor después de usar los autofirmados, necesitas actualizarlos o reemplazarlos. Luego, simplemente colócalos (como describimos anteriormente) en la carpeta `/etc/mailad/le/` en la configuración y haz lo siguiente desde la carpeta donde has clonado la instalación de MailAD:

``` sh
rm certs &2> /dev/null
make certs
systemctl restart postfix dovecot
systemctl status postfix dovecot
```

Los últimos dos pasos reinician los servicios relacionados con el correo electrónico y muestran su estado, para que puedas verificar si todo salió bien. Si tienes problemas, simplemente elimina los archivos de `/etc/mailad/le/` y repite los pasos anteriores, eso volverá a crear un certificado autofirmado y lo pondrá en servicio.

## Instalación de Software

``` sh
make install
```

Este paso instala todo el software necesario. Ten en cuenta que **SIEMPRE** purgamos el software y las configuraciones antiguas en este paso. De esta manera, siempre comenzamos con un conjunto nuevo de archivos para la etapa de aprovisionamiento. Si tienes un entorno no limpio, el script sugerirá pasos para limpiarlo.

## Aprovisionamiento de Servicios

Después de la instalación del software, debes aprovisionar la configuración, eso se logra con un solo comando:

``` sh
make provision
```

Esta etapa copiará los archivos de plantilla en la carpeta var de este repositorio, reemplazando los valores con los de tu archivo `mailad.conf`. Si se encuentra algún problema, se te advertirá al respecto y necesitarás volver a ejecutar el comando `make provision` para continuar. También hay un objetivo `make force-provision` en caso de que necesites forzar el aprovisionamiento manualmente.

Cuando llegues a un mensaje de éxito después del aprovisionamiento, estás listo para probar tu nuevo servidor de correo, ¡felicidades!

## Reconfiguración

Debe haber algún momento en el futuro cuando necesites cambiar algún parámetro de configuración de MailAD sin reinstalar/actualizar el servidor. El objetivo make `force-provision` fue creado para eso, cambia el/los parámetro(s) que deseas en tu archivo de configuración (`/etc/mailad/mailad.conf`), ve a la carpeta del repositorio de MailAD (`/root/mailad` por defecto) y ejecuta:

``` sh
make force-provision
```

Verás cómo hace una copia de seguridad de toda la configuración y luego reinstala todo el servidor con los nuevos parámetros _(este proceso durará unos 8 minutos en hardware actualizado)_. Eso está bien, ya que es la forma en que está desarrollado. Echa un vistazo a la última parte del proceso de instalación, verás algo como esto:

```
[...]
===> La última copia de seguridad es: /var/backups/mailad/20200912_033525.tar.gz
===> Extrayendo archivos personalizados de la copia de seguridad...
etc/postfix/aliases/alias_virtuales
etc/postfix/rules/body_checks
etc/postfix/rules/header_checks
etc/postfix/rules/lista_negra
[...]
```

Sí, el `force-provision` así como los objetivos make `upgrade` preservan los datos modificados por el usuario.

Si necesitas restablecer algunos de esos archivos a los valores predeterminados, simplemente bórralos del sistema de archivos y haz un force-provision, así de simple.

Para los cambios generados por actualizaciones a MailAD, consulta actualizaciones sin problemas en el archivo [Features.es.md](i18n/Features.es.md#actualizaciones-sin-problemas)

## Actualización

Eventualmente habrá una nueva versión y querrás actualizar para obtener nuevas características o simplemente correcciones de errores, para forzar una actualización simplemente haz esto:

``` sh
cd /root/mailad # cd a la carpeta donde clonaste el repositorio
git checkout master
git pull --rebase
make upgrade
```

Eso es todo, simplemente sigue las instrucciones... Si solo actualizaste para estar al día, has terminado.

Si actualizaste para obtener una nueva característica, entonces ve al archivo `/etc/mailad/mailad.conf` y echa un vistazo a las opciones que necesitas habilitar. Sí, las nuevas características estarán deshabilitadas por defecto para no romper tu configuración actual.

Una vez que hayas habilitado/configurado las opciones, ve a la carpeta clonada [/root/mailad en este ejemplo] y ejecuta una reconfiguración:

``` sh
cd /root/mailad # cd a la carpeta donde clonaste el repositorio
make force-provision
```

Has terminado.

## ¿Y Ahora Qué?

Hay un archivo [FAQ.es.md](i18n/FAQ.es.md) para buscar problemas comunes; o puedes contactarme a través de Telegram bajo mi apodo: [@pavelmc](https://t.me/pavelmc)

