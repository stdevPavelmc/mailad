# MailAD v1.2.7

[![Chat on Telegram](https://img.shields.io/badge/Chat%20on-Telegram-brightgreen?style=flat-square)](https://t.me/MailAD_dev) [![GitHub Issues](https://img.shields.io/github/issues/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues) [![GitHub Issues Closed](https://img.shields.io/github/issues-closed/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues?q=is%3Aissue+is%3Aclosed) [![GitHub repo size](https://img.shields.io/github/repo-size/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/archive/master.zip) [![GitHub last commit](https://img.shields.io/github/last-commit/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![GitHub commit rate](https://img.shields.io/github/commit-activity/m/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![Financial contributors](https://opencollective.com/mailad/tiers/badge.svg?style=flat-square)](https://opencollective.com/mailad) [![Develop Testing Status](https://img.shields.io/github/actions/workflow/status/stdevPavelmc/mailad/mailad-tests.yml?branch=develop&label=Develop+Testing+Status&style=flat-square)](https://github.com/stdevPavelmc/mailad/actions/workflows/mailad-tests.yml) [![Production Testing Status](https://img.shields.io/github/actions/workflow/status/stdevPavelmc/mailad/mailad-tests.yml?branch=master&label=Production+Testing+Status&style=flat-square)](https://github.com/stdevPavelmc/mailad/actions/workflows/mailad-tests.yml)

![MailAD Logo](./logos/MailAD-logo-full_white_background.png)

Diese Seite ist auch in folgenden Sprachen verfügbar: [ [English](README.md) 🇺🇸 🇬🇧] [ [Español](i18n/README.es.md) 🇪🇸 🇨🇺] *Warnung: Übersetzungen können veraltet sein.*

Dies ist ein praktisches Werkzeug, um einen Mailserver unter Linux einzurichten, der mit einem Active Directory (AD) Server (Samba oder Windows) verknüpft ist und dabei einige Einschränkungen berücksichtigt. Dies ist eine typische Mail-Konfiguration für den Einsatz in Kuba, wie sie von Gesetz und Sicherheitsvorschriften vorgeschrieben wird, kann aber in jeder Domain verwendet werden. Sie können eine einfache Einrichtung in [diesem Asciinema-Film](https://asciinema.org/a/fD1LuVLfeb8RPCHOIgbR1J9d8) sehen.

## Hinweis

Wir haben auch einige abgeleitete Projekte, die Sie interessieren könnten:

- [MailAD-Docker](https://github.com/stdevPavelmc/mailad-docker/) - Eine Docker Compose-Version dieser Software.
- [MailD](https://github.com/stdevPavelmc/maild/) - Eine Multi-Domain Docker-Lösung ohne AD-Verknüpfung, eine vollständig webbasierte Lösung.
- [MailAD ansible role](https://github.com/stdevPavelmc/mailad-ansible-role) - Eine Ansible-Rolle für den Mailserver.

## Wer nutzt MailAD

MailAD wird hauptsächlich in Kuba eingesetzt, was sein spezifischer Zielmarkt ist. Im Dezember 2025 gab es mindestens 50 gemeldete Domains, die es nutzen (beachten Sie, dass die Statistikberichterstattung optional ist).

![Benutzer-Mosaik](./logos/mosaic.png)

Das gezeigte Mosaik ist ein Beitrag von Benutzern, die berichtet haben, es zu nutzen. Wenn Sie es nutzen und Ihr Logo aufnehmen möchten, gehen Sie zur [Telegram-Gruppe](https://t.me/MailAD_dev) und stellen Sie Ihr Logo zur Aufnahme bereit. Wenn ein Logo eine Kette oder Gruppe von Unternehmen darstellt, bedeutet dies nicht, dass alle sie nutzen, sondern dass mehr als ein Unternehmen innerhalb dieser Kette es tut.

## Begründung

Dieses Repository soll unter `/root` auf Ihrer frischen OS-Installation geklont werden (Sie können eine LXC-Instanz, VM usw. verwenden) und über eine Hauptkonfigurationsdatei gemäß den Dateikommentaren eingerichtet werden. Führen Sie dann die Schritte in einer Makefile aus und befolgen Sie die Anweisungen, um Ihren Server zu konfigurieren.

Nach einigen Schritten haben Sie in etwa 15 Minuten einen funktionierenden Mailserver. *(Diese Zeit basiert auf einer 2-Mbps-Internetverbindung zu einem Repository. Bei einem lokalen Repository ist es weniger.)*

Die empfohlene OS-Auswahl ist wie folgt:

| OS | Aktiver Support | Legacy | Eingestellt |
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

> *Legende:*
> - ⚙️:  Support in Arbeit, bleiben Sie dran!
> - Aktiver Support ✅: Dies ist die empfohlene Version für die Installation
> - Legacy ⚠️: funktioniert, aber nicht empfohlen, kein Support und keine Updates
> - Eingestellt 🚫: funktioniert möglicherweise, aber nicht mehr unterstützt, es ist EOL

***Hinweis:** Wenn Sie Debian Buster oder Bullseye in einem LXC-Container (z. B. Proxmox) verwenden, müssen Sie die Dovecot-Installation anpassen, sonst funktioniert sie nicht. Weitere Informationen finden Sie in [diesem Fix](https://serverfault.com/questions/976250/dovecot-lxc-apparmor-denied-buster).*

Es wird empfohlen, dass die MailAD-Instanz in Ihrem DMZ-Segment sitzt, mit einer Firewall zwischen ihr und Ihren Benutzern und einem Mail-Gateway wie [Proxmox Mail Gateway](https://www.proxmox.com/en/proxmox-mail-gateway) zwischen ihr und dem externen Netzwerk.

## Funktionen

Dies richtet einen Mailserver für ein Unternehmen ein, das Unternehmensbenutzer bedient. Die wichtigsten Funktionen finden Sie in der Datei [Features.md](Features.md). Darunter finden Sie unter anderem:

1. Geringer Ressourcenverbrauch.
2. Fortgeschrittene (und optionale) Mail-Filterfunktionen, die Anhänge, SPF, Antivirus & Spam umfassen.
3. Verschlüsselte LDAP-Kommunikation als Option.
4. In-situ-Schutz vor großen und bekannten SSL- und Mail-Service-Angriffen.
5. Automatische Aliase mit AD-Gruppen.
6. Manuelle Aliase, manuelles Verbot, manuelle Header- und Body-Checks.
7. Auf Abruf Backup und Wiederherstellung von Rohkonfigurationen.
8. Wirklich schmerzlose Upgrades.
9. Tägliche Mail-Verkehrszusammenfassung in Ihrem Posteingang.
10. Optionaler Benutzerprivilegien-Zugriff über AD-Gruppen (lokal/national/international).
11. Optionaler Haftungsausschluss/Vermerk/Warnung in jeder ausgehenden Mail.
12. Optionale aggressive SPAM-Bekämpfungsmaßnahmen.
13. Wöchentliche Hintergrundprüfung auf neue Versionen mit detaillierter E-Mail, wenn Sie ein Upgrade benötigen.
14. Optionale Aufteilung des Postfachs nach Büro/Stadt/Land.
15. Optionaler Webmail, Sie haben die Wahl zwischen Roundcube und SnappyMail.

## TODO

Es gibt eine [TODO-Liste](TODO.md), die als eine Art "Roadmap" für neue Funktionen dient. Aber da ich (der einzige Entwickler bisher) ein Leben, eine Familie und einen Vollzeitjob habe, wissen Sie...

Die gesamte Entwicklung erfolgt am Wochenende oder spät in der Nacht (ernsthaft, werfen Sie einen Blick auf die Commit-Daten!). Wenn Sie dringend ein Feature oder ein Fix benötigen, erwägen Sie bitte eine Spende oder kontaktieren Sie mich, und ich helfe Ihnen gerne so schnell wie möglich weiter. Meine Kontaktdaten finden Sie am Ende dieser Seite.

## Einschränkungen und Anforderungen

Erinnern Sie sich an den Kommentar oben auf der Seite über *"...mit einigen Einschränkungen im Hinterkopf..."*? Ja, hier sind sie:

1. Ihre Benutzerbasis und Konfiguration stammen von AD wie erwähnt. Wir bevorzugen Samba AD, funktioniert aber auch unter Windows; siehe [die AD-Anforderungen für dieses Tool](AD_Requirements.md).
2. Der Benutzername-Teil der E-Mail darf 20 Zeichen nicht überschreiten, daher wird `thisisalongemailaddress@domain.com` zu `thisisalongemailaddr@domain.com` gekürzt. Dies ist nicht unsere Regel, sondern eine Einschränkung des LDAP-Verzeichnisses, wie vom Windows-Schema vorgegeben.
3. Die Mail-Speicherung erfolgt in einem Ordner unter `/home/vmail`. Die gesamte Mail gehört einem Benutzer namens `vmail` mit uid:5000 & gid:5000. Tipp: Dieser Ordner kann ein NFS-Mount oder jede andere Art von Netzwerkspeicher sein (konfigurierbar).
4. Sie verwenden einen Windows-PC, um die Domain zu steuern und zu verwalten (muss ein Domänenmitglied sein und RSAT installiert und aktiviert haben). Wir empfehlen Windows 10 LTSC/Professional.
5. Die Kommunikation mit dem Server erfolgt auf diese Weise: (Siehe [diese Frage](FAQ.md#what-ports-i-need-to-get-open-to-make-sure-the-servers-works-ok) in der FAQ-Datei für weitere Informationen)
    - Port 25 (SMTP) wird verwendet, um eingehenden Verkehr von der Außenwelt oder von einem Mail-Gateway zu empfangen.
    - Port 587 (SUBMISSION) wird verwendet, um E-Mails von Benutzern zu empfangen, die lokal zugestellt oder an andere Server weitergeleitet werden sollen.
    - Port 465 (SMTPS) wird wie Port 587 verwendet, ist aber nur als Legacy-Option aktiviert; seine Verwendung wird zugunsten von Port 587 abgeraten.
    - Port 993 (IMAPS) ist die bevorzugte Methode, um E-Mails vom Server abzurufen.
    - Port 995 (POP3S) wird wie 993 verwendet, aber IMAPS wird gegenüber POP3S empfohlen (es sei denn, Sie befinden sich in einer sehr langsamen Verbindung).

## Wie installiert oder testet man es?

Wir haben eine [INSTALL.md](INSTALL.md)-Datei genau dafür, und auch eine [FAQ](FAQ.md)-Datei mit häufigen Problemen.

## Dies ist freie Software!

Haben Sie einen Kommentar, eine Frage, einen Beitrag oder ein Fix?

Verwenden Sie die Issues-Registerkarte in der Repository-URL oder senden Sie mir eine Nachricht über [Twitter](https://twitter.com/co7wt) oder [Telegram](https://t.me/pavelmc).

## Mitwirkende ✨

Vielen Dank an diese wunderbaren Menschen ([Emoji-Schlüssel](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-11-orange.svg?style=flat-square)](#mitwirkende-)
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

Bitte lesen Sie die [CONTRIBUTING.md](CONTRIBUTING.md)-Datei, wenn Sie zu MailAD beitragen möchten, um die Details zu erfahren. Alle Arten von Beiträgen sind willkommen: Ideen, Fixes, Fehlerberichte, Verbesserungen und sogar ein Guthabenaufladung für das Telefon, um mich online zu halten.

Dieses Projekt folgt der [all-contributors](https://github.com/all-contributors/all-contributors)-Spezifikation. Jede Art von Beiträgen ist willkommen!