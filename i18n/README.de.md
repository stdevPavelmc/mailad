# MailAD v1.2.0

[![Chat on Telegram](https://img.shields.io/badge/Chat%20on-Telegram-brightgreen?style=flat-square)](https://t.me/MailAD_dev) [![Twitter Follow](https://img.shields.io/twitter/follow/co7wt?label=Follow&style=flat-square)](https://twitter.com/co7wt) [![GitHub Issues](https://img.shields.io/github/issues/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues) [![GitHub Issues Closed](https://img.shields.io/github/issues-closed/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues?q=is%3Aissue+is%3Aclosed) [![GitHub repo size](https://img.shields.io/github/repo-size/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/archive/master.zip) [![GitHub last commit](https://img.shields.io/github/last-commit/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![GitHub commit rate](https://img.shields.io/github/commit-activity/m/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![Financial contributors](https://opencollective.com/mailad/tiers/badge.svg)](https://opencollective.com/mailad)

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-11-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

![MailAD Logo](../logos/MailAD-logo-full_white_background.png)

Dies ist ein praktisches Tool, um einen Mailserver unter Linux bereitzustellen, der mit einem Active Directory-Server (im Folgenden AD genannt, Samba oder Windows) verbunden ist, wobei einige Einschränkungen zu berücksichtigen sind. Dies ist eine typische Mail-Konfiguration, die in Kuba gemäß gesetzlichen Vorschriften und Sicherheitsanforderungen verwendet wird, kann aber in jeder Domain eingesetzt werden. Sie können eine einfache Bereitstellung in [diesem Asciinema-Film](https://asciinema.org/a/fD1LuVLfeb8RPCHOIgbR1J9d8) sehen.

## Hinweis

Wir haben auch einige abgeleitete Projekte, die Sie interessant finden könnten:

- [MailAD-Docker](https://github.com/stdevPavelmc/mailad-docker/) - Eine Docker Compose-Version dieser Software.
- [MailD](https://github.com/stdevPavelmc/maild/) - Eine Multi-Domain-Docker-Lösung ohne AD-Anbindung, eine reine Web-Lösung.
- [MailAD ansible role](https://github.com/stdevPavelmc/mailad-ansible-role) - Eine Ansible-Rolle für den Mailserver.

## Begründung

Dieses Repository soll auf Ihrer neuen Betriebssysteminstallation unter `/root` geklont werden (Sie können eine LXC-Instanz, VM, etc. verwenden) und gemäß den Dateikommentaren in einer Hauptkonfigurationsdatei eingerichtet werden. Führen Sie dann die Schritte in einem Makefile aus und befolgen Sie die Anweisungen zur Konfiguration Ihres Servers.

Nach ein paar Schritten haben Sie einen Mailserver, der in etwa 15 Minuten einsatzbereit ist. *(Diese Zeit basiert auf einer 2-Mbit/s-Internetverbindung zu einem Repository. Wenn Sie ein lokales Repository haben, ist diese geringer.)*

Dieses Tool wird auf folgenden Systemen getestet und unterstützt:

| OS | Aktiver Support | Legacy |
|:--- |:---:|:---:|
| Ubuntu Noble 24.04 LTS | ✅ |  |
| Debian Bookworm 12 | ✅ |  |
| Ubuntu Jammy 22.04 LTS |  | ⚠️ |
| Debian Bullseye 11 |  | ⚠️ |
| Ubuntu Focal 20.04 LTS |  | ⚠️ |
| Debian Buster 10 |  | ⚠️ |
| Ubuntu Bionic 18.04 LTS |  | ⚠️ |

Legacy bedeutet, dass es funktioniert, aber nicht mehr unterstützt wird. Es wird empfohlen, die neueste Version zu verwenden.

***Hinweis:** Wenn Sie Debian Buster oder Bullseye in einem LXC-Container verwenden (z.B. Proxmox), müssen Sie die Dovecot-Installation anpassen, sonst funktioniert sie nicht. Siehe [diese Lösung](https://serverfault.com/questions/976250/dovecot-lxc-apparmor-denied-buster) für weitere Informationen.*

Es wird empfohlen, dass die MailAD-Instanz in Ihrem DMZ-Segment mit einer Firewall zwischen ihr und Ihren Benutzern und einem Mail-Gateway wie [Proxmox Mail Gateway](https://www.proxmox.com/de/proxmox-mail-gateway) zwischen ihr und dem externen Netzwerk platziert wird.

## Eigenschaften

Dadurch wird ein Mailserver für ein Unternehmen bereitgestellt, der Unternehmensbenutzer bedient. Die wichtigsten Funktionen finden Sie in der Datei [Features.md](../Features.md). Unter anderem finden Sie Folgendes:

1. Geringer Ressourcenbedarf.
2. Erweiterte (und optionale) E-Mail-Filterfunktionen, die Anhänge, SPF, AntiVirus und Spam umfassen.
3. Verschlüsselte LDAP-Kommunikation als Option.
4. Integrierter Schutz vor größeren und bekannten SSL- und Mail-Service-Angriffen.
5. Automatischer Alias mit AD-Gruppen.
6. Manueller Alias, manuelles Verbot, manuelle Header- und Body-Checks.
7. Bedarfsgerechte Sicherung und Wiederherstellung von Rohkonfigurationen.
8. Wirklich schmerzlose Upgrades.
9. Tägliche Zusammenfassung des E-Mail-Verkehrs in Ihrem Posteingang.
10. Optionaler Zugriff auf Benutzerrechte über AD-Gruppen (lokal/national/international).
11. Optionaler Haftungsausschluss/Hinweis/Warnung bei jeder ausgehenden E-Mail.
12. Optionale aggressive SPAM-Bekämpfungsmaßnahmen.
13. Wöchentliche Hintergrundprüfung auf neue Versionen mit einer detaillierten E-Mail, wenn Sie ein Upgrade durchführen müssen.
14. Optionale Postfachtrennung nach Büro/Stadt/Land.
15. Optionales Webmail, Sie können zwischen Roundcube oder SnappyMail wählen.

## TODO

Es gibt eine [TODO-Liste](../TODO.md), die als eine Art "Roadmap" für neue Funktionen dient. Aber da ich (bisher der einzige Entwickler) ein Leben, eine Familie und einen täglichen Job habe, wissen Sie...

Die gesamte Entwicklung erfolgt am Wochenende oder spät in der Nacht (schauen Sie sich ernsthaft die Commit-Daten an!). Wenn Sie eine Funktion oder eine Fehlerbehebung ASAP benötigen, denken Sie bitte darüber nach, eine Spende zu machen oder mich zu kontaktieren, und ich werde Ihnen gerne so schnell wie möglich helfen. Meine Kontaktinformationen finden Sie am Ende dieser Seite.

## Einschränkungen und Anforderungen

Erinnern Sie sich an den Kommentar am Anfang der Seite über *"...mit einigen Einschränkungen im Hinterkopf..."*? Ja, hier sind sie:

1. Ihre Benutzerbasis und Konfiguration stammen wie erwähnt aus AD. Wir bevorzugen Samba AD, aber es funktioniert auch unter Windows; siehe [die AD-Anforderungen für dieses Tool](../AD_Requirements.md).
2. Der Benutzernameteil der E-Mail darf 20 Zeichen nicht überschreiten, daher wird `thisisalongemailaddress@domain.com` auf `thisisalongemailaddr@domain.com` gekürzt. Dies ist nicht unsere Regel, sondern eine Einschränkung des LDAP-Verzeichnisses gemäß Windows-Schema.
3. Der E-Mail-Speicher wird ein Ordner in `/home/vmail` sein. Alle E-Mails gehören einem Benutzer namens `vmail` mit uid:5000 & gid:5000. Tipp: Dieser Ordner kann ein NFS-Mount oder eine andere Art von Netzwerkspeicher sein (konfigurierbar).
4. Sie verwenden einen Windows-PC zur Steuerung und Verwaltung der Domäne (muss ein Domänenmitglied sein und RSAT installiert und aktiviert haben). Wir empfehlen Windows 10 LTSC/Professional.
5. Die Kommunikation mit dem Server erfolgt auf folgende Weise: (Siehe [diese Frage](../FAQ.md#what-ports-i-need-to-get-open-to-make-sure-the-servers-works-ok) in der FAQ-Datei, um mehr zu erfahren)
    - Port 25 (SMTP) wird verwendet, um eingehenden Verkehr von der Außenwelt oder von einem Mail-Gateway zu empfangen.
    - Port 587 (SUBMISSION) wird verwendet, um E-Mails von den Benutzern zu empfangen, die lokal zugestellt oder an andere Server weitergeleitet werden sollen.
    - Port 465 (SMTPS) wird wie Port 587 verwendet, ist aber nur als Legacy-Option aktiviert; seine Verwendung wird zugunsten von Port 587 nicht empfohlen.
    - Port 993 (IMAPS) die bevorzugte Methode zum Abrufen von E-Mails vom Server.
    - Port 995 (POP3S) wird wie 993 verwendet, wird aber zugunsten von IMAPS nicht empfohlen (es sei denn, Sie haben eine sehr langsame Verbindung).

## Wie installiere ich es oder probiere es aus?

Wir haben eine [INSTALL.md](../INSTALL.md)-Datei genau dafür und auch eine [FAQ](../FAQ.md)-Datei mit häufigen Problemen.

## Dies ist freie Software!

Haben Sie einen Kommentar, eine Frage, Beiträge oder eine Korrektur?

Verwenden Sie die Registerkarte "Issues" in der Repository-URL oder senden Sie mir eine Nachricht über [Twitter](https://twitter.com/co7wt) oder [Telegram](https://t.me/pavelmc).

## Mitwirkende ✨

Vielen Dank an diese wunderbaren Menschen ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

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

Bitte lesen Sie die [CONTRIBUTING.md](../CONTRIBUTING.md)-Datei, wenn Sie zu MailAD beitragen möchten, um die Details zu erfahren, wie Sie dies tun können. Alle Arten von Beiträgen sind willkommen: Ideen, Korrekturen, Fehlerberichte, Verbesserungen und sogar eine Telefonaufladung, um mich online zu halten.

Dieses Projekt folgt der [all-contributors](https://github.com/all-contributors/all-contributors)-Spezifikation. Beiträge jeder Art sind willkommen!

