# MailAD

[![Chat on Telegram](https://img.shields.io/badge/Chat%20on-Telegram-brightgreen?style=flat-square)](https://t.me/MailAD_dev) [![Twitter Follow](https://img.shields.io/twitter/follow/co7wt?label=Follow&style=flat-square)](https://twitter.com/co7wt) [![GitHub Issues](https://img.shields.io/github/issues/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues) [![GitHub Issues Closed](https://img.shields.io/github/issues-closed/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues?q=is%3Aissue+is%3Aclosed) [![GitHub repo size](https://img.shields.io/github/repo-size/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/archive/master.zip) [![GitHub last commit](https://img.shields.io/github/last-commit/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![GitHub commit rate](https://img.shields.io/github/commit-activity/m/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![Financial contributors](https://opencollective.com/mailad/tiers/badge.svg)](https://opencollective.com/mailad)

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-11-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

Dies ist ein praktisches Tool, um einen Mailserver unter Linux bereitzustellen, der mit einem Active Directory-Server (Samba oder Windows, das spielt keine Rolle) verbunden ist, wobei einige Einschränkungen zu berücksichtigen sind, da dies eine typische Mail-Konfiguration ist, die unter bestimmten Gesetzen in Kuba verwendet wird und Sicherheitsanforderungen.

## Begründung

Dieses Repository soll auf Ihrer neuen Betriebssysteminstallation unter `/root` geklont werden (Sie können eine LXC-Instanz, VM, CT usw. verwenden) und gemäß den Dateikommentaren in einer Hauptkonf-Datei eingerichtet werden. Führen Sie dann die Schritte auf a aus Makefile und befolgen Sie die Schritte zum Konfigurieren Ihres Servers.

Nach ein paar Schritten ist ein Mailserver in ca. 15 Minuten einsatzbereit. _(Diese Zeit basiert auf einer 2-Mbit/s-Internetverbindung zu einem Repository. Wenn Sie ein lokales Repository haben, ist diese geringer.)_

Dieses Tool wird getestet und unterstützt auf:

- Ubuntu Bionic 18.04 (früher LTS).
- Ubuntu Focal 20.04 (tatsächliche LTS und tatsächliche Entwicklungsumgebung).
- Debian Buster 10 (siehe Hinweis unten, bitte).
- Debian Bullseye 11 (siehe Hinweis unten, bitte).

_**Hinweis:** Wenn Sie einen Debian Buster-Container unter LXC verwenden (z. B. Proxmox), müssen Sie die Dovecot-Installation optimieren, da dies sonst nicht funktioniert. Weitere Informationen finden Sie unter [dieses Update](https://serverfault.com/questions/976250/dovecot-lxc-Apparmor-Denied-Buster) für weitere Informationen_

Es wird empfohlen, dass sich die MailAD-Instanz in Ihrem DMZ-Netz mit einer Firewall zwischen ihr und Ihren Benutzern und einem Mail-Gateway wie [Proxmox Mail Gateway](https://www.proxmox.com/de/proxmox-mail-gateway) dazwischen befindet es und die Außenwelt.

## Eigenschaften

Dadurch wird ein Mailserver in einem Unternehmen als realer Server für die Benutzer bereitgestellt. Die wichtigsten Funktionen finden Sie in der Datei [Features.md](Features.md). Unter anderem finden Sie Folgendes:

0. Geringer Ressourcenbedarf.
0. Erweiterte (und optionale) E-Mail-Filterfunktionen, einschließlich Anhänge, SPF, AntiVirus und Spam.
0. Tägliche Zusammenfassung des E-Mail-Verkehrs in Ihrem Posteingang.
0. Optionale verschlüsselte LDAP-Kommunikation.
0. In-Place-Schutz vor größeren und bekannten SSL- und Mail-Service-Angriffen.
0. Optionaler Zugriff auf Benutzerrechte über AD-Gruppen (lokal/national/international).
0. Automatischer Alias mit AD-Gruppen.
0. Optionaler Haftungsausschluss/Hinweis/Werbung für jede ausgehende Mail.
0. Manueller Alias, manuelles Verbot, manuelle Header und Mail-Body-Checks.
0. On Demand Sicherung und Wiederherstellung von Rohkonfigurationen.
0. Schmerzlose Upgrades (Wirklich!).

## TODO

Es gibt eine [TODO-Liste](TODO.md), eine Art "Roadmap" für neue Funktionen, aber da ich (bisher nur ein Entwickler) ein Leben, eine Familie und einen täglichen Job habe, wissen Sie ...

Alle Entwickler werden am Wochenende oder spät in der Nacht erstellt (werfen Sie einen ernsthaften Blick auf die Festschreibungstermine!). Wenn Sie eine Funktion benötigen oder ASAP reparieren möchten, berücksichtigen Sie bitte eine Spende oder haben Sie mich gefunden. Meine Kontaktinformationen finden Sie unten auf dieser Seite.

## Einschränkungen und Anforderungen

Denken Sie an den Kommentar oben auf der Seite über _"... mit einigen Einschränkungen ..."_ Ja, hier sind sie:

0. Ihre Benutzerbasis und Konfiguration stammten wie erwähnt aus einem Active Directory (AD von nun an). Wir bevorzugen ein Samba AD, funktionieren aber auch unter Windows. Siehe [AD-Anforderungen für dieses Tool](AD_Requirements.md)
0. Der E-Mail-Speicher ist ein Ordner in `/home/vmail`. Alle E-Mails gehören einem Benutzer mit dem Namen `vmail` mit der UID: 5000 & GID: 5000. Tipp: Dieser Ordner kann ein NFS-Mount oder eine andere Art von Netzwerkspeicher sein (konfigurierbar).
0. Sie verwenden einen Windows-PC zur Steuerung und Verwaltung der Domäne (muss ein Domänenmitglied sein und RSAT installiert und aktiviert haben). Wir empfehlen Windows 10 LTSC / Professional
0. Der Server erlaubt standardmäßig alle Kommunikationsprotokolle _(POP3, POP3S, IMAP, IMAPS, SMTP, SSMTP und SUBMISSION)_. Es **liegt an Ihnen**, den Benutzerzugriff so einzuschränken, dass sie nur die sicheren Versionen (POP3S verwenden , IMAPS & SUBMISSION. Beachten Sie, dass der SMTP-Dienst nur zum Senden/Empfangen von E-Mails von außen verwendet werden darf)

## Wie installiere ich es oder probiere es aus?

Dafür haben wir eine Datei [INSTALL.md](INSTALL.md) und eine Datei [FAQ](FAQ.md) mit häufigen Problemen.

## Diese ist freie Software!

Haben Sie einen Kommentar, eine Frage, Beiträge oder einen Fix?

Verwenden Sie die Registerkarte "Probleme" in der Repository-URL oder senden Sie mir eine Nachricht über [Twitter](https://twitter.com/co7wt) oder [Telegramm](https://t.me/pavelmc).

Wir haben eine [Datei zum Registrieren der Beiträge](Contributors.md) zu dieser Software.

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

Dieses Projekt folgt dem [alle Mitwirkenden](https://github.com/all-contributors/all-contributors) Spezifikation. Beiträge jeglicher Art sind willkommen!
