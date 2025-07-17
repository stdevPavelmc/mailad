<!-- Traducido originalmente por: @stdevPavelmc "Pavel Milanes" <pavelmc@gmail.com> -->
# MailAD v1.2.2

[![Chat on Telegram](https://img.shields.io/badge/Chat%20on-Telegram-brightgreen?style=flat-square)](https://t.me/MailAD_dev) [![GitHub Issues](https://img.shields.io/github/issues/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues) [![GitHub Issues Closed](https://img.shields.io/github/issues-closed/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues?q=is%3Aissue+is%3Aclosed) [![GitHub repo size](https://img.shields.io/github/repo-size/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/archive/master.zip) [![GitHub last commit](https://img.shields.io/github/last-commit/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![GitHub commit rate](https://img.shields.io/github/commit-activity/m/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![Financial contributors](https://opencollective.com/mailad/tiers/badge.svg?style=flat-square)](https://opencollective.com/mailad) [![Develop Testing Status](https://img.shields.io/github/actions/workflow/status/stdevPavelmc/mailad/mailad-tests.yml?branch=develop&label=Develop+Testing+Status&style=flat-square)](https://github.com/stdevPavelmc/mailad/actions/workflows/mailad-tests.yml) [![Production Testing Status](https://img.shields.io/github/actions/workflow/status/stdevPavelmc/mailad/mailad-tests.yml?branch=master&label=Production+Testing+Status&style=flat-square)](https://github.com/stdevPavelmc/mailad/actions/workflows/mailad-tests.yml)

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-11-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

![MailAD Logo](../logos/MailAD-logo-full_white_background.png)

Esta es una cómoda herramienta para desplegar un servidor de correos en Linux, vinculado a un Directorio Activo (DA de ahora en adelante, ya sea Windows Server o SAMBA 4), con algunas restricciones en mente. La idea es que sea una configuración básica para ser usada en Cuba bajo ciertas leyes y restricciones, pero puede ser usada en cualquier dominio. Puedes ver un ejemplo de un despliegue básico en esta [animación de asciinema](https://asciinema.org/a/fD1LuVLfeb8RPCHOIgbR1J9d8).

## Aviso

También tenemos algunos proyectos derivados que podrían interesarte:

- [MailAD-Docker](https://github.com/stdevPavelmc/mailad-docker/) - Una versión en Docker Compose de este software.
- [MailD](https://github.com/stdevPavelmc/maild/) - Una solución Docker multi-dominio sin vinculación con DA, una solución completamente web.
- [MailAD ansible role](https://github.com/stdevPavelmc/mailad-ansible-role) - Un rol de Ansible para el servidor de correo.

## Fundamentos

Este software está ideado para ser clonado desde el repositorio en la carpeta `/root` de tu futuro servidor de correo (puedes usar una instancia LXC, una máquina virtual, un CT de Proxmox, etc.). Luego instalas la configuración básica, llenas las opciones particulares, ejecutas el despliegue y sigues los pasos para instalar tu servidor. Después de esto, tendrás un servidor de correo funcionando en 15 minutos máximo si dispones de un repositorio de Linux local o una buena conexión de internet.

Este software está probado y soportado en:

| OS | Soporte Activo | Legado |
|:--- |:---:|:---:|
| Ubuntu Noble 24.04 LTS | ✅ |  |
| Debian Bookworm 12 | ✅ |  |
| Ubuntu Jammy 22.04 LTS |  | ⚠️ |
| Debian Bullseye 11 |  | ⚠️ |
| Ubuntu Focal 20.04 LTS |  | ⚠️ |
| Debian Buster 10 |  | ⚠️ |
| Ubuntu Bionic 18.04 LTS |  | ⚠️ |

Legado significa que funciona pero ya no está soportado. Se recomienda usar la versión más reciente.

***Nota:** Si estás usando Debian Buster o Bullseye en un contenedor LXC (Proxmox por ejemplo), necesitarás ajustar la instalación de Dovecot o no funcionará. Consulta [esta solución](https://serverfault.com/questions/976250/dovecot-lxc-apparmor-denied-buster) para más información.*

Se recomienda que MailAD esté dentro de una DMZ, detrás de un firewall y que uses una pasarela de correos como [Proxmox Mail Gateway](https://www.proxmox.com/en/proxmox-mail-gateway) entre MailAD y el mundo exterior cuando estás de cara a internet.

## Prestaciones

La idea es desplegar un servidor final de correos de cara a los usuarios corporativos. Como son muchas prestaciones, te haremos un resumen, pero puedes consultarlas todas con sus detalles en su [propio documento](../Features.md):

1. Bajo consumo de recursos.
2. Filtros avanzados y opcionales de filtrado de adjuntos, SPF, Anti Virus y anti Spam.
3. Puedes encriptar las comunicaciones LDAP si lo deseas.
4. Protección por defecto para los principales tipos de ataques a servidores de correos, criptográficos, etc.
5. Alias de grupos automáticos con los grupos del Directorio Activo.
6. Alias manuales, bloqueos manuales para cuentas y dominios, chequeo de cabeceras y cuerpo.
7. Fácil manera de hacer un backup y restaurarlo.
8. Actualizaciones simples y sin complicaciones.
9. Resumen de correo diario en tu buzón.
10. Accesos Locales, Nacionales e Internacionales por grupos del Directorio Activo.
11. Puedes configurar un pie de firma en cada correo saliente.
12. Medidas agresivas para luchar contra el SPAM, cuando estás de cara a internet.
13. Comprobación semanal en segundo plano de nuevas versiones con un correo detallado si necesitas actualizar.
14. División opcional de buzones por oficina/ciudad/país.
15. Webmail opcional, puedes elegir entre Roundcube o SnappyMail.

## Por hacer

Hay una lista de las cosas que tenemos [planeadas o por hacer](../TODO.md), son una guía sin orden, como una lista de deseos y no hay compromiso ya que desarrollar este software es diversión para mí y no gano nada con ello. Además, hay que dejar tiempo a la familia, amigos, el trabajo...

Todo el desarrollo se hace en mi tiempo libre, en serio, revisa las fechas y horas de los commits. Si tienes algún problema y necesitas ayuda con tu despliegue o solución con MailAD para tu caso específico, ten en cuenta que esto lo hago por diversión y pasión. Si haces una donación para mantenerme conectado, estaré más que dispuesto a resolver tu problema lo antes posible.

## Requisitos y restricciones

¿Recuerdas que más arriba dije *"... con algunas restricciones en mente..."*? Pues estas son:

1. La base de usuarios del servidor de correos viene del Directorio Activo, como se mencionó. De este lado preferimos SAMBA 4, pero funciona también con Windows Server; debes verificar los [requisitos del directorio activo para integrarlo con MailAD](../AD_Requirements.md).
2. La parte del nombre de usuario del correo no debe exceder los 20 caracteres, por lo que `thisisalongemailaddress@domain.com` se truncará a `thisisalongemailaddr@domain.com`. Esta no es nuestra regla, sino una limitación del directorio LDAP según lo especificado por el esquema de Windows.
3. El almacenamiento o buzón global para todos los usuarios estará en `/home/vmail`. El usuario `vmail` con uid:5000 y gid:5000 será el dueño de esta carpeta. Truco: esta carpeta puede estar montada en un NFS o con cualquier otro tipo de almacenamiento en red (configurable).
4. Debes usar una PC con Windows y el kit RSAT instalado y activado para controlar el dominio (debe ser miembro del dominio). Nosotros recomendamos Windows 10 LTSC/Professional.
5. La comunicación entre MailAD y el resto del mundo se hace de esta manera: (Revisa [esta pregunta frecuente](../FAQ.md#what-ports-i-need-to-get-open-to-make-sure-the-servers-works-ok) para tener más detalles)
    - Puerto 25 (SMTP) es usado solamente para recibir emails desde el exterior o desde una pasarela de correo.
    - Puerto 587 (SUBMISSION) es el recomendado para que los usuarios envíen correos hacia el servidor.
    - Puerto 465 (SMTPS) similar al 587, se desaconseja su uso, se mantiene por compatibilidad.
    - Puerto 993 (IMAPS) es el puerto recomendado para revisar correos en el servidor.
    - Puerto 995 (POP3S) similar al 993, se desaconseja su uso a menos que tengas muy poco ancho de banda; usa 993 (IMAPS) en su lugar.

## ¿Cómo lo instalo y pruebo?

Tenemos un fichero específico para eso: [INSTALL.md](../INSTALL.md), y también un grupo de [Preguntas Frecuentes](../FAQ.md) con la solución a algunos problemas comunes.

## ¡Esto es Software Libre!

¿Tienes algún comentario, pregunta, contribución, traducción o parche?

Usa la pestaña "Issues" en el repositorio o déjamelo saber vía mensajes directos en [Twitter](https://twitter.com/co7wt) o [Telegram](https://t.me/pavelmc).

## Honor a los que contribuyen ✨

Gracias a todos los que de alguna manera contribuyen con el desarrollo de MailAD ([significado de los emojis](https://allcontributors.org/docs/en/emoji-key)):

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

Por favor lee el fichero [CONTRIBUTING.es.md](CONTRIBUTING.es.md) si es que planeas contribuir a MailAD. Aceptamos todo tipo de contribuciones: ideas, parches, reportes de fallos, mejoras e incluso recargas de celular para poder mantenerme conectado y desarrollando este proyecto.

Este proyecto sigue las recomendaciones [all-contributors](https://github.com/all-contributors/all-contributors). ¡Cualquier tipo de contribución es bien recibida!
