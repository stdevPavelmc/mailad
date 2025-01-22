<!-- Traducido originalmente por: @stdevPavelmc "Pavel Milanes" <pavelmc@gmail.com> -->
# MailAD

[![Chat on Telegram](https://img.shields.io/badge/Chat%20on-Telegram-brightgreen?style=flat-square)](https://t.me/MailAD_dev) [![Twitter Follow](https://img.shields.io/twitter/follow/co7wt?label=Follow&style=flat-square)](https://twitter.com/co7wt) [![GitHub Issues](https://img.shields.io/github/issues/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues) [![GitHub Issues Closed](https://img.shields.io/github/issues-closed/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues?q=is%3Aissue+is%3Aclosed) [![GitHub repo size](https://img.shields.io/github/repo-size/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/archive/master.zip) [![GitHub last commit](https://img.shields.io/github/last-commit/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![GitHub commit rate](https://img.shields.io/github/commit-activity/m/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![Financial contributors](https://opencollective.com/mailad/tiers/badge.svg)](https://opencollective.com/mailad)

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-11-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

Esta es una cómoda herramienta para desplegar un server de correos en Linux, vinculado a un Directorio Activo (da igual un Windows Server o SAMBA 4), con algunas restricciones en mente; la idea es que sea una configuración básica para ser usada en Cuba bajo ciertas leyes y restricciones. Puedes ver un ejemplo de un despliegue básico en esta [animación de aciinema](https://asciinema.org/a/fD1LuVLfeb8RPCHOIgbR1J9d8).

## Fundamentos

Este software está ideado para ser clonado desde el repositorio en la carpeta `/root` de tu futuro servidor de correo (puedes usar una instancia LXC, una máquina virtual un CT de Proxmox, etc) luego instalas la configuración básica, llenas las opciones particulares, ejecutas el despliegue y sigues los pasos para instalar tu servidor. Luego de esto tendrás un servidor de correo funcionando en 15 minutos máximo si dispones de un repo de linux local o una buena conexión de internet.

Este software está probado y soportado en:

- Ubuntu Bionic 18.04 (antigua LTS).
- Ubuntu Focal 20.04 (actual LTS and actual dev env).
- Debian Buster 10 (ver nota debajo).
- Debian Bullseye 11 (ver nota debajo).

_**Nota:** Si estas usando Debian Buster en un contenedor de Proxmox o LXC local vas a tener que retocar el sistema para que funcione Dovecot, mira [este link](https://serverfault.com/questions/976250/dovecot-lxc-apparmor-denied-buster) para más información._

Se recomienda que MailAD esté dentro de una DMZ, detrás de un firewall y que uses una pasarela de correos como [Proxmox Mail Gateway](https://www.proxmox.com/en/proxmox-mail-gateway) entre MailAD y el mundo exterior cuando estás de cara a internet; aunque ya MailAD es lo suficientemente robusto para estar online en internet si no puedes poner una pasarela.

## Prestaciones

La idea es desplegar un server final de correos de cara a los usuarios, como son muchas prestaciones te haremos un resumen pero puedes consultarlas todas con sus detalles en su [propio documento](../Features.md):

0. Bajo consumo de recursos.
0. Filtro avanzados y opcionales de filtrado de adjuntos, DPF, Anti Virus y anti Spam.
0. Puedes encriptar las comunicaciones LDAP si lo deseas.
0. Protección por defecto para los principales tipos de ataques a server de correos, criptográficos, etc.
0. Alias de grupos automáticos con los grupos del Direcotrio Activo. 
0. Alias manuales, bloqueos manuales para cuantas y dominios, chequeo de cabeceras y cuerpo.
0. Fácil manera de hacer un backup y restauralos.
0. Actualizaciones simples y sin complicaciones.
0. Resumen de correo diario en tu buzón.
0. Accesos Locales, Nacionales e Internacionales por grupos del directorio Aativo.
0. Puedes configurar un pie de firma en cada correo saliente.
0. Medidas agresivas para luchar contra el SPAM, cuando estás de cara a internet.

## Por hacer

Hay una lista de las cosas que tenemos [planeadas o por hacer](../TODO.md), son una guía sin orden, como una lista de deseos y no hay compromiso ya que desarrollar este software es diversión para mi y no gano nada con ello, además hay que dejar tiempo a la familia, amigos, el trabajo...

Todo el desarrollo se hace en mi tiempo libre, en serio, revisa las fechas y horas de los commits. Si tienes algún problema y necesitas ayuda con tu despliegue o solución con MailAD para tu caso en específico ten en cuenta que esto lo hago por diversión y pasión, si haces unas donación para mantenerme conectado estaré más que dispuesto a resolver tu problema.

## Requisitos y restricciones

Recuerdas que más arriba dije _"... con algunas restricciones en mente..."_ pues estas son:

0. La base de usuarios del servidor de correos viene del Directorio Activo, de este lado preferimos SAMBA 4, pero funciona también con Windows Server, debes verificar los [requisitos del directorio activo para integrarlo con MailAD](../AD_Requirements.md)
0. El almacenamiento o buzón global para todos los usarios estará en `/home/vmail`, el usario `vmail` con uid:5000 y gid:5000 será el dueño de esta carpeta. Truco: esta carpeta puede estar montada en un NFS o con cualquier otro truco "en la red" y no realmente en el server.
0. Debes usar una Pc con Windows y el kit RSAT instalado y activado para controlar el dominio, nosotros recomendamos que corras el RSAT en la mayor versión de Windows posible.
0. La comunicación entre el MailAD y el resto del mundo se hace de esta manera: ([revisa esta pregunta frecuente](../FAQ.md#what-ports-i-need-to-get-open-to-make-sure-the-servers-works-ok) para tener más detalles)
    - Puerto 25 (SMTP) es usado solamente para recibir emails desde el exterior.
    - Puerto 587 (SUBMISSION) es el recomendado para que los usuarios envíen correos hacia el server.
    - Puerto 465 (SMTPS) similar al 587, se desaconseja su uso, se mantiene por compatibilidad.
    - Puerto 993 (IMAPS) es el puerto recomendado para revosar correos en el servidor.
    - Puerto 995 (POP3S) similar el 993, se desaconseja su uso a menos que tenga muy poco ancho de banda, use 993 (IMAPS) en su lugar. 

## Como lo instalo y pruebo?

Tenemos un fichero específico para eso: [INSTALL.md](../INSTALL.md), existen también un grupo de [Preguntas Frecuentes](../FAQ.md) con la solución a algunos problemas comunes.

## Esto es Software Libre!

Tienes algún comentario, pregunta, contribución, traducción o parche?

Usa la pestaña "Issues" en el repositorio o déjamelo saber vía mensajes directos en [Twitter](https://twitter.com/co7wt) o [Telegram](https://t.me/pavelmc)

## Honor a los que contribuyen ✨

Gracias a todos los que de alguna manera contribuyen con desarrollo de MailAD ([significado de los emojis](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/danny920825"><img src="https://avatars2.githubusercontent.com/u/33090194?v=4?s=100" width="100px;" alt="danny920825"/><br /><sub><b>danny920825</b></sub></a><br /><a href="https://github.com/stdevPavelmc/mailad/commits?author=danny920825" title="Tests">⚠️</a> <a href="#ideas-danny920825" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/HugoFlorentino"><img src="https://avatars0.githubusercontent.com/u/11479345?v=4?s=100" width="100px;" alt="HugoFlorentino"/><br /><sub><b>HugoFlorentino</b></sub></a><br /><a href="#ideas-HugoFlorentino" title="Ideas, Planning, & Feedback">🤔</a> <a href="#example-HugoFlorentino" title="Examples">💡</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.sysadminsdecuba.com"><img src="https://avatars1.githubusercontent.com/u/12705691?v=4?s=100" width="100px;" alt="Armando Felipe"/><br /><sub><b>Armando Felipe</b></sub></a><br /><a href="#ideas-armandofcom" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Koratsuki"><img src="https://avatars0.githubusercontent.com/u/20727446?v=4?s=100" width="100px;" alt="Koratsuki"/><br /><sub><b>Koratsuki</b></sub></a><br /><a href="#ideas-Koratsuki" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/stdevPavelmc/mailad/commits?author=Koratsuki" title="Code">💻</a> <a href="#translation-Koratsuki" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://www.daxslab.com"><img src="https://avatars0.githubusercontent.com/u/13596248?v=4?s=100" width="100px;" alt="Gabriel A. López López"/><br /><sub><b>Gabriel A. López López</b></sub></a><br /><a href="#translation-glpzzz" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/oneohthree"><img src="https://avatars0.githubusercontent.com/u/7398832?v=4?s=100" width="100px;" alt="oneohthree"/><br /><sub><b>oneohthree</b></sub></a><br /><a href="#ideas-oneohthree" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://iskra.ml"><img src="https://avatars3.githubusercontent.com/u/6555851?v=4?s=100" width="100px;" alt="Eddy Ernesto del Valle Pino"/><br /><sub><b>Eddy Ernesto del Valle Pino</b></sub></a><br /><a href="https://github.com/stdevPavelmc/mailad/commits?author=edelvalle" title="Documentation">📖</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dienteperro"><img src="https://avatars.githubusercontent.com/u/5240140?v=4?s=100" width="100px;" alt="dienteperro"/><br /><sub><b>dienteperro</b></sub></a><br /><a href="https://github.com/stdevPavelmc/mailad/commits?author=dienteperro" title="Documentation">📖</a> <a href="#financial-dienteperro" title="Financial">💵</a> <a href="#ideas-dienteperro" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://jjrweb.byethost8.com/"><img src="https://avatars.githubusercontent.com/u/11667019?v=4?s=100" width="100px;" alt="Joe1962"/><br /><sub><b>Joe1962</b></sub></a><br /><a href="#ideas-Joe1962" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/stdevPavelmc/mailad/commits?author=Joe1962" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/sandy-cmg"><img src="https://avatars.githubusercontent.com/u/101523070?v=4?s=100" width="100px;" alt="Sandy Napoles Umpierre"/><br /><sub><b>Sandy Napoles Umpierre</b></sub></a><br /><a href="#ideas-sandy-cmg" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/stdevPavelmc/mailad/commits?author=sandy-cmg" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://cz9dev.github.io/"><img src="https://avatars.githubusercontent.com/u/97544746?v=4?s=100" width="100px;" alt="Carlos Zaldívar"/><br /><sub><b>Carlos Zaldívar</b></sub></a><br /><a href="https://github.com/stdevPavelmc/mailad/commits?author=cz9dev" title="Code">💻</a> <a href="#translation-cz9dev" title="Translation">🌍</a> <a href="https://github.com/stdevPavelmc/mailad/commits?author=cz9dev" title="Tests">⚠️</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

Por favor lee el fichero [CONTRIBUTING.es.md](CONTRIBUTING.es.md) si es que planeas contribuir a MailAD. Aceptamos todo tipo de contribuciones, ideas, parches, fallos e incluso recargas de celular para poder mantenerme conectado y desarrollando este proyecto.

Este proyecto sigue las recomendaciones [all-contributors](https://github.com/all-contributors/all-contributors), cualquier tipo de contribución es bien recibida!
