# MailAD v1.2.7

[![Chat on Telegram](https://img.shields.io/badge/Chat%20on-Telegram-brightgreen?style=flat-square)](https://t.me/MailAD_dev) [![GitHub Issues](https://img.shields.io/github/issues/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues) [![GitHub Issues Closed](https://img.shields.io/github/issues-closed/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues?q=is%3Aissue+is%3Aclosed) [![GitHub repo size](https://img.shields.io/github/repo-size/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/archive/master.zip) [![GitHub last commit](https://img.shields.io/github/last-commit/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![GitHub commit rate](https://img.shields.io/github/commit-activity/m/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![Financial contributors](https://opencollective.com/mailad/tiers/badge.svg?style=flat-square)](https://opencollective.com/mailad) [![Develop Testing Status](https://img.shields.io/github/actions/workflow/status/stdevPavelmc/mailad/mailad-tests.yml?branch=develop&label=Develop+Testing+Status&style=flat-square)](https://github.com/stdevPavelmc/mailad/actions/workflows/mailad-tests.yml) [![Production Testing Status](https://img.shields.io/github/actions/workflow/status/stdevPavelmc/mailad/mailad-tests.yml?branch=master&label=Production+Testing+Status&style=flat-square)](https://github.com/stdevPavelmc/mailad/actions/workflows/mailad-tests.yml)

![MailAD Logo](./logos/MailAD-logo-full_white_background.png)

Esta página también está disponible en los siguientes idiomas: [ [English](README.md) 🇺🇸 🇬🇧] [ [Deutsch](i18n/README.de.md) 🇩🇪] *Advertencia: las traducciones pueden estar desactualizadas.*

Esta es una herramienta útil para aprovisionar un servidor de correo en Linux vinculado a un servidor Active Directory (AD a partir de ahora) (Samba o Windows) con algunas restricciones en mente. Esta es una configuración de correo típica para ser utilizada en Cuba según lo regulado por la ley y los requisitos de cumplimiento de seguridad, pero puede ser utilizada en cualquier dominio. Puedes ver un aprovisionamiento simple en [esta película de asciinema](https://asciinema.org/a/fD1LuVLfeb8RPCHOIgbR1J9d8).

## Aviso

También tenemos algunos proyectos derivados que podrían interesarte:

- [MailAD-Docker](https://github.com/stdevPavelmc/mailad-docker/) - Una versión Docker Compose de este software.
- [MailD](https://github.com/stdevPavelmc/maild/) - Una solución Docker multi-dominio sin enlace AD, una solución completamente web.
- [MailAD ansible role](https://github.com/stdevPavelmc/mailad-ansible-role) - Un rol Ansible para el servidor de correo.

## Quién utiliza MailAD

MailAD se utiliza principalmente en Cuba, que es su mercado objetivo específico. A diciembre de 2025, había al menos 50 dominios reportados que lo utilizan (ten en cuenta que el reporte de estadísticas es opcional).

![Mosaico de Usuarios](./logos/mosaic.png)

El mosaico mostrado es una contribución de usuarios que han reportado usarlo. Si lo utilizas y deseas incluir tu logotipo, ve al [grupo de Telegram](https://t.me/MailAD_dev) y proporciona tu logotipo para su inclusión. Cuando un logotipo representa una cadena o grupo de empresas, no significa que todas ellas lo utilicen, sino que más de una empresa dentro de esa cadena lo hace.

## Razonamiento

Este repositorio está destinado a ser clonado en tu instalación fresca de SO bajo `/root` (puedes usar una instancia LXC, VM, etc.) y configurado mediante un archivo de configuración principal según los comentarios del archivo. Luego ejecuta los pasos en un makefile y sigue las instrucciones para configurar tu servidor.

Después de algunos pasos, tendrás un servidor de correo en funcionamiento en unos 15 minutos como máximo. *(Este tiempo se basa en una conexión a internet de 2Mbps a un repositorio. Si tienes un repositorio local, será menos.)*

La selección recomendada de SO es la siguiente:

| SO | Soporte Activo | Legado | Descontinuado |
|:--- |:---:|:---:|:---:|
| Ubuntu Resolute 26.04 rc | ⚙️ |  |  |
| Debian Trixie 13 | ✅ |  |  |
| Ubuntu Noble 24.04 LTS | ✅ |  |  |
| Debian Bookworm 12 | ✅ |  |  |
| Ubuntu Jammy 22.04 LTS |  | ⚠️ |  |
| Debian Bullseye 11 |  | ⚠️ |  |
| Ubuntu Focal 20.04 LTS |  |  | 🚫 |
| Debian Buster 10 |  |  | 🚫 |
| Ubuntu Bionic 18.04 LTS |  |  | 🚫 |

> *Leyenda:*
> - ⚙️:  ¡Soporte en desarrollo, mantente atento!
> - Soporte Activo ✅: Esta es la versión recomendada para instalar
> - Legado ⚠️: funciona pero no se recomienda, sin soporte ni actualizaciones
> - Descontinuado 🚫: puede funcionar pero ya no es compatible, está en EOL

***Nota:** Si estás utilizando Debian Buster o Bullseye en un Contenedor LXC (Proxmox por ejemplo), necesitas ajustar la instalación de Dovecot o no funcionará. Consulta [este fix](https://serverfault.com/questions/976250/dovecot-lxc-apparmor-denied-buster) para más información.*

Se recomienda que la instancia de MailAD se sitúe dentro de tu segmento DMZ con un firewall entre ella y tus usuarios, y una puerta de enlace de correo como [Proxmox Mail Gateway](https://www.proxmox.com/en/proxmox-mail-gateway) entre ella y la red externa.

## Características

Esto aprovisionará un servidor de correo para una empresa que sirve a usuarios corporativos. Puedes ver las principales características en el archivo [Features.md](Features.md). Entre otras, encontrarás:

1. Bajo consumo de recursos.
2. Características avanzadas (y opcionales) de filtrado de correo que incluyen adjuntos, SPF, Antivirus y Spam.
3. Comunicación LDAP encriptada como opción.
4. Protección in-situ contra ataques mayores y conocidos de SSL y servicios de correo.
5. Alias automático usando grupos AD.
6. Alias manual, prohibición manual, verificación manual de encabezados y cuerpo.
7. Copia de seguridad y restauración bajo demanda de configuraciones en crudo.
8. Actualizaciones realmente indoloras.
9. Resumen diario de tráfico de correo en tu bandeja de entrada.
10. Acceso opcional a privilegios de usuario mediante grupos AD (local/nacional/internacional).
11. Descargo de responsabilidad/aviso/advertencia opcional en cada correo saliente.
12. Medidas agresivas opcionales de lucha contra el SPAM.
13. Verificación semanal en segundo plano de nuevas versiones con un correo detallado si necesitas actualizar.
14. División opcional de buzón por oficina/ciudad/país.
15. Webmail opcional, tienes Roundcube o SnappyMail para elegir.

## TODO

Hay una [lista de TODO](TODO.md), que sirve como una especie de "hoja de ruta" para nuevas características. Pero como yo (el único desarrollador hasta ahora) tengo una vida, una familia y un trabajo diario, ya sabes...

Todo el desarrollo se hace los fines de semana o tarde en la noche (en serio, echa un vistazo a las fechas de los commits). Si necesitas una característica o arreglo lo antes posible, por favor considera hacer una donación o contactarme, y estaré encantado de ayudarte lo antes posible. Mi información de contacto está al final de esta página.

## Restricciones y requisitos

¿Recuerdas el comentario en la parte superior de la página sobre *"...con algunas restricciones en mente..."*? Sí, aquí están:

1. Tu base de usuarios y configuración provienen de AD como se mencionó. Preferimos Samba AD, pero funciona en Windows también; consulta [los requisitos de AD para esta herramienta](AD_Requirements.md).
2. La parte del nombre de usuario del correo no debe exceder 20 caracteres, por lo que `thisisalongemailaddress@domain.com` será truncado a `thisisalongemailaddr@domain.com`. Esta no es nuestra regla, sino una limitación del directorio LDAP según lo especificado por el Esquema de Windows.
3. El almacenamiento de correo será una carpeta en `/home/vmail`. Todo el correo pertenecerá a un usuario llamado `vmail` con uid:5000 & gid:5000. Consejo: esa carpeta puede ser un montaje NFS o cualquier otro tipo de almacenamiento en red (configurable).
4. Utilizas una PC con Windows para controlar y gestionar el dominio (debe ser un miembro del dominio y tener RSAT instalado y activado). Recomendamos Windows 10 LTSC/Professional.
5. La comunicación con el servidor se realiza de esta manera: (Consulta [esta pregunta](FAQ.md#what-ports-i-need-to-get-open-to-make-sure-the-servers-works-ok) en el archivo FAQ para saber más)
    - El puerto 25 (SMTP) se utiliza para recibir tráfico entrante del mundo exterior o de una puerta de enlace de correo.
    - El puerto 587 (SUBMISSION) se utiliza para recibir correos de los usuarios para ser entregados localmente o retransmitidos a otros servidores.
    - El puerto 465 (SMTPS) se utiliza como el puerto 587 pero solo está habilitado como una opción heredada; su uso se desaconseja en favor del puerto 587.
    - El puerto 993 (IMAPS) es el método preferido para recuperar correo del servidor.
    - El puerto 995 (POP3S) se utiliza como el 993, pero se desaconseja en favor de IMAPS (a menos que estés en un enlace muy lento).

## ¿Cómo instalarlo o probarlo?

Tenemos un archivo [INSTALL.md](INSTALL.md) justo para eso, y también un archivo [FAQ](FAQ.md) con problemas comunes.

## ¡Este es software gratuito!

¿Tienes un comentario, pregunta, contribución o arreglo?

Utiliza la pestaña Issues en la URL del repositorio o envíame un mensaje a través de [Twitter](https://twitter.com/co7wt) o [Telegram](https://t.me/pavelmc).

## Colaboradores ✨

Gracias a estas maravillosas personas ([clave de emojis](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-11-orange.svg?style=flat-square)](#colaboradores-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

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

Por favor lee el archivo [CONTRIBUTING.md](CONTRIBUTING.md) si deseas contribuir a MailAD para conocer los detalles de cómo hacerlo. Se agradecen todo tipo de contribuciones: ideas, arreglos, reportes de errores, mejoras e incluso una recarga telefónica para mantenerme en línea.

¡Este proyecto sigue la especificación [all-contributors](https://github.com/all-contributors/all-contributors)! ¡Toda clase de contribuciones son bienvenidas!