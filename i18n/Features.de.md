# MailAD Funktionen erklärt

Dies ist eine lange Seite, hier ist ein Inhaltsverzeichnis:

* [Webmails](Features.md#webmails)
* [Geringer Ressourcenverbrauch](Features.md#low-resource-footprint)
* [Sicherheitsschutz gegen bekannte SSL- und Mail-Angriffe](Features.md#security-protection-against-well-known-SSL-and-mail-attacks)
* [Active Directory Integration und Verwaltung](Features.md#active-directory-integration-and-management)
* [Allgemeines und spezifisches Kontingentsystem](Features.md#general-and-specific-quota-system)
* [Tägliche Zusammenfassung des E-Mail-Verkehrs](Features.md#daily-mail-traffic-summary)
* [Daten von gelöschten Benutzern werden mit äußerster Sorgfalt behandelt](Features.md#data-from-deleted-users-is-handled-with-extreme-care)
* [Let's Encrypt Zertifikatsunterstützung](Features.md#lets-encrypt-certificates-support)
* [Automatische Aliase mit AD-Gruppen](Features.md#automatic-alias-using-ad-groups)
* [Dovecot-Filterung (Sieve)](Features.md#dovecot-filtering-sieve)
* [Erweiterte Mail-Filterung: Erweiterungen, MIME-Typen und optionale AV-, SPAM- und SPF-Prüfung](Features.md#advanced-mail-filtering-extensions-mime-types-and-optional-av-spam-and-spf)
* [Zentralisierter Mail-Speicher](Features.md#centralized-mail-storage)
* [Optionaler SPAM-Schutz über DNSBL und andere Techniken](Features.md#optional-spam-protection-extras-via-dnsbl-and-other-tricks)
* [Optionale Verschlüsselung für LDAP-Kommunikation](Features.md#optional-encryption-for-LDAP-communications)
* [Optionale Benachrichtigungen an Gruppen statt nur an den Mail-Administrator](Features.md#optional-notifications-to-groups-instead-of-only-the-mail-admin)
* [Optionaler Haftungsausschluss bei jeder ausgehenden E-Mail](Features.md#optional-disclaimer-on-every-outgoing-mail)
* [Optionale Alle-Liste mit benutzerdefinierter Adresse](Features.md#optional-everyone-list-with-custom-address)
* [Optionaler Benutzerprivilegien-Zugriff über AD-Gruppen](Features.md#optional-user-privilege-access-via-ad-groups)
* [Manuelle Aliase für Tippfehler oder Unternehmenspositionen](Features.md#manual-alias-to-handle-typos-or-enterprise-positions)
* [Manuelle Sperrliste für problematische Adressen](Features.md#manual-ban-list-for-troublesome-address)
* [Manuelle Header- und Body-Prüflisten](Features.md#manual-headers-and-body-check-lists)
* [Test-Suite](Features.md#test-suite)
* [Rohe Backup- und Wiederherstellungsoptionen](Features.md#raw-backup-and-restore-options)
* [Problemlose Upgrades](Features.md#painless-upgrades)
* [Wöchentliche Update-Prüfungen](Features.md#weekly-update-checks)
* [Physisches Postfach der Benutzer nach Standort aufgeteilt](Features.md#physical-mailbox-of-the-users-split-by-location)

## Webmails

Seit April 2025 unterstützt MailAD die Verwendung eines Webmails auf demselben Host wie der Mail-Server. Hier sind einige Funktionen und Dinge, die Sie darüber wissen sollten.

Diese Funktion ist optional und standardmäßig deaktiviert, um die Kompatibilität mit älteren Versionen zu gewährleisten; aktualisieren Sie auf die neueste MailAD-Version mit den [Upgrade-Anweisungen](INSTALL.md#upgrading)

- Es verwendet standardmäßig den Hostnamen des Mailservers, wenn Ihr Mailserver also mail.empresa.cu ist, dann ist das Webmail https://mail.empresa.cu
- Es verwendet den Nginx-Webserver mit php-fpm und verwendet die Standard-php-fpm-Version in Ihrem Betriebssystem.
- Es verwendet standardmäßig HTTPS mit dem von MailAD generierten SSL-Zertifikat oder den Let's Encrypt-Zertifikaten, falls vorhanden, siehe Installation für Details.
- Wenn Sie HTTP benötigen, weil Sie einen Reverse-Proxy mit HTTPS verwenden, um es der Außenwelt zugänglich zu machen... gibt es eine Einstellung, um HTTP zu erzwingen, überprüfen Sie den Abschnitt in /etc/mailad/mailad.conf
- Wir bieten zwei beliebte und kostenlos nutzbare Webmail-Lösungen an: RoundCube und SnappyMail.
- Beide Webmails verwenden E-Mail-Autovervollständigung vom LDAP-Server.

### RoundCube

Dies wird aus dem Repository Ihres Betriebssystems installiert, es ist also nicht hochmodern, aber stabil und bewährt. Dies ist die Standardoption, da es in den Betriebssystem-Repositories enthalten ist und leicht zu installieren sein wird.

Weitere Details finden Sie auf der [Offiziellen Website](https://roundcube.net/)

### SnappyMail

Dies ist eine alternative Option und wird aus dem Internet heruntergeladen, daher müssen Sie die Proxy-Optionen in der Datei `/etc/mailad/mailad.conf` einrichten, wenn Sie einen in Ihrem Netzwerk verwenden. Es ist ein frisches, leichtes und reaktionsschnelles modernes Webmail, das sich aus RainLoop entwickelt hat, als es nicht mehr gepflegt wurde.

SnappyMail hat eine spezielle Admin-Seite (https://yourmail.domain.cu/?admin), auf der Sie zusätzliche Plugins installieren können usw.; während der Installation wird Ihnen das Skript das Standardpasswort mitteilen, wenn Sie es nicht sehen, ist es auch in der Datei `/etc/mailad/snappy_admin_pass` gespeichert, der Benutzer ist immer `admin`.

Hinweis: Nach einer Neukonfiguration, einem Upgrade oder einer Neubereitstellung können alle von Ihnen installierten Plugins gelöscht werden; Entschuldigung dafür.

Weitere Details finden Sie auf der [Offiziellen Website](https://snappymail.eu/)

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Geringer Ressourcenverbrauch

Diese Lösung wird in der Produktion eingesetzt und die Mindestanforderungen mit allen Funktionen sind:

- RAM: 2GB
- CPU: 2 Kerne
- HDD: 2GB frei (ohne E-Mail-Speicher, da dies von Ihren Bedürfnissen abhängt)

Die anspruchsvollste Funktion ist die SPAM- und Antiviren-Filterung (AV), ohne diese kann der RAM auf 1GB reduziert werden. Dennoch hängen die tatsächlichen Hardwareanforderungen von Ihren Mailserver-Nutzungsmustern ab und müssen vor Ort angepasst werden.

Wenn Sie bereit sind, teilen Sie bitte einige Statistiken und Hardware-Details mit mir, um diesen Abschnitt zu aktualisieren (Hardware-Setup, aktivierte Funktionen, täglicher/monatlicher Mail-Fluss usw.).

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Sicherheitsschutz gegen bekannte SSL- und Mail-Angriffe

- Bekannte SSL/TLS-Schwachstellen wie LOGJAM, SSL FREAK, POODLE usw. sind abgedeckt.
- Auch bekannte Schwachstellen von Postfix und Dovecot sind abgedeckt.
- Aufgebaut nach bewährten Sicherheitspraktiken.
- Wir werden es gegen aufkommende Bedrohungen aktualisiert halten:
  - Fix für einen kürzlichen Spammer-Trick: Fälschung des From/Return-Path, um die Benutzer glauben zu lassen, dass die E-Mails legitim sind, wenn sie es nicht sind.
  - Verbot (Ablehnung) von E-Mails ohne Betreff, ein häufiger Spammer-Trick
  - SMTP-Schmuggelangriff [https://www.postfix.org/smtp-smuggling.html]

Unterstützt durch das kollektive Wissen der [SysAdminsdeCuba](https://t.me/sysadmincuba) SysAdmins-Community.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Active Directory Integration und Verwaltung

Dieses Skript soll einen Unternehmens-Mailserver innerhalb einer DMZ und hinter einer Perimeter-Mail-Gateway-Lösung bereitstellen (ich verwende die neuere Version von Proxmox Mail Gateway).

Die grundlegenden Benutzerdetails (E-Mail und Passwort) werden von einem Windows- oder Samba-basierten Active Directory (AD)-Server abgerufen (ich empfehle Samba 4 unter Linux). Stattdessen wird die Benutzerverwaltung an die Schnittstelle delegiert, die Sie zur Steuerung von Active Directory verwenden, es wird kein anderer Dienst benötigt. Berühren Sie den Mailserver NICHT für Änderungen im Zusammenhang mit Benutzern.

Für einen Windows-Sysadmin wird dies einfach sein, konfigurieren und stellen Sie einfach den Mailserver bereit, dann steuern Sie die Benutzer in der AD-Schnittstelle Ihres PCs (RSAT), siehe die Details in der Datei [AD_Requirements.md](AD_Requirements.md).

Wenn Sie ein Linux-Benutzer sind, können Sie `samba-tool` verwenden, um Domänenbenutzer in der Shell zu verwalten oder RSAT in einer Windows-VM mit Fernzugriff zu verwenden.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Allgemeines und spezifisches Kontingentsystem

_**Hinweis:** Diese Funktion wurde im Februar 2021 eingeführt, und wenn Sie MailAD aus einer früheren Version haben, lesen Sie dies zuerst und gehen Sie dann zur Datei [Simplify_AD_config.md](Simplify_AD_config.md), um Anweisungen zur Migration zu sehen._

Irgendwann oder von Anfang an werden Sie ein Kontingentsystem benötigen. E-Mails sammeln sich in Benutzer-Postfächern an, wir schlagen ein allgemeines und ein spezifisches (individuelles oder benutzerbezogenes) Kontingentsystem vor.

### Allgemeines Kontingent

Es gibt ein allgemeines Kontingent, das standardmäßig für jedes einzelne Benutzer-Postfach deklariert ist, Sie finden es in der Datei `/etc/mailad/mailad.conf` als Variable mit dem Namen `DEFAULT_MAILBOX_SIZE` und es ist standardmäßig auf 200 MB eingestellt. Jeder neue Benutzer wird also ohne zusätzliche Konfiguration an dieses Kontingent gebunden.

Aber was passiert mit diesen Benutzern mit hohem Volumen? Wenn Sie die Grenze für einige bestimmte Benutzer erhöhen müssen... (oder für andere senken...):

### Spezifisches Kontingent

Wenn Sie das Kontingentlimit für einen bestimmten Benutzer erhöhen (oder senken) müssen, gehen Sie einfach zu seinen Eigenschaften im AD und setzen Sie den neuen Wert in der Eigenschaft namens "Web Page" ("Webseite" auf Deutsch, "wWWHomePage" ldap-Attribut) wie in diesem Bild für den Benutzer "Pavel", der ein spezifisches 1G (1 GByte) Kontingent hat.

![Admin-Benutzerdetails](imgs/admin_user_details.png)

Die Einheiten sind Standard:

- #K: KBytes wie 800K
- #M: MBytes wie 500M
- #G: GBytes wie 1G
- #T: TBytes wie 1T

Es gibt hier eine weiche Einschränkung: Sie dürfen keine Dezimalzahlen verwenden, aber Sie können die niedrigere Einheit verwenden, um den gleichen Effekt zu erzielen: anstelle von 1.5G können Sie 1500M sagen.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Tägliche Zusammenfassung des E-Mail-Verkehrs

Das als Mail-Systemadministrator konfigurierte Konto _(oder die mit der SYSADMINS-Gruppe verknüpften, falls angegeben)_ erhält eine (tägliche) Zusammenfassung des E-Mail-Verkehrs des Vortages. Die Zusammenfassung wird mit dem pflogsumm-Tool erstellt.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Daten von gelöschten Benutzern werden mit äußerster Sorgfalt behandelt

In den meisten Mailservern wird, wenn Sie einen Benutzer aus dem System entfernen, sein Mail-Speicher (maildir in unserem Fall) automatisch gelöscht. In unserem Fall haben wir uns entschieden, mit mehr Vorsicht zu handeln: Das Maildir des Benutzers wird nicht sofort gelöscht.

Wir lassen das Maildir des Benutzers intakt, damit Sie geschäftskritische E-Mails überprüfen oder wiederherstellen können. Sie können die E-Mails wiederherstellen, indem Sie das Benutzerkonto im AD neu erstellen und sich mit den Anmeldedaten anmelden.

Jeden Monat erhalten Sie eine E-Mail von Ihrem Mailserver, die Sie über zurückgelassene Maildirs informiert. Sie können frei entscheiden, was Sie damit tun möchten (normalerweise reicht es aus, ein Backup zu erstellen und dann das betreffende Maildir zu löschen).

Hier spielen wir einen Trick:

- Administratoren mit Maildirs für gelöschte Benutzer zwischen 0 und 10 Monaten (tatsächlich 9,7) werden benachrichtigt, um Maßnahmen zu ergreifen.
- Administratoren mit Maildirs für gelöschte Benutzer zwischen 10 und 11,999 Monaten werden vor dem bevorstehenden Entfernen gewarnt.
- Maildirs für gelöschte Benutzer, die älter als 365 Tage (1 Jahr) sind, werden automatisch entfernt.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Let's Encrypt Zertifikatsunterstützung

Seit Juni 2020 unterstützt MailAD Let's Encrypt-Zertifikate. Wenn Sie ein gültiges Let's Encrypt-Zertifikat auf Ihrem Server haben, wird MailAD es erkennen und verwenden.

Damit dies funktioniert, müssen Sie ein gültiges Zertifikat im Pfad `/etc/letsencrypt/live/mail.domain.tld/` haben, wobei mail.domain.tld der Hostname Ihres Mailservers ist.

Wenn Sie kein Let's Encrypt-Zertifikat haben, wird MailAD ein selbstsigniertes Zertifikat für Sie generieren.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Automatische Aliase mit AD-Gruppen

Seit Juni 2020 unterstützt MailAD automatische Aliase mit AD-Gruppen. Das bedeutet, dass Sie eine Gruppe in Ihrem AD erstellen können und alle Mitglieder dieser Gruppe E-Mails erhalten, die an diese Gruppe gesendet werden.

Damit dies funktioniert, müssen Sie eine Gruppe in Ihrem AD mit einem Namen erstellen, der mit "mail-" beginnt, und dann Benutzer zu dieser Gruppe hinzufügen. Wenn Sie beispielsweise eine Gruppe namens "mail-developers" erstellen, erhalten alle Mitglieder dieser Gruppe E-Mails, die an developers@domain.tld gesendet werden.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Dovecot-Filterung (Sieve)

Seit Juni 2020 unterstützt MailAD Dovecot-Filterung (Sieve). Das bedeutet, dass Benutzer Filterregeln für ihre E-Mails erstellen können.

Damit dies funktioniert, müssen Benutzer eine Datei namens `.dovecot.sieve` in ihrem Home-Verzeichnis erstellen. Diese Datei muss gültige Sieve-Filterregeln enthalten.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Erweiterte Mail-Filterung: Erweiterungen, MIME-Typen und optionale AV-, SPAM- und SPF-Prüfung

MailAD unterstützt erweiterte Mail-Filterung. Dies umfasst:

- Erweiterungsfilterung: Sie können E-Mails mit Anhängen mit bestimmten Erweiterungen blockieren.
- MIME-Typ-Filterung: Sie können E-Mails mit Anhängen bestimmter MIME-Typen blockieren.
- AV-Filterung: Sie können E-Mails mit ClamAV auf Viren scannen.
- SPAM-Filterung: Sie können E-Mails mit SpamAssassin auf SPAM scannen.
- SPF-Filterung: Sie können überprüfen, ob der Absender berechtigt ist, E-Mails von seiner Domain zu senden.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Zentralisierter Mail-Speicher

MailAD verwendet einen zentralisierten Mail-Speicher. Das bedeutet, dass alle E-Mails an einem Ort gespeichert werden, was Backup und Wiederherstellung erleichtert.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Optionaler SPAM-Schutz über DNSBL und andere Techniken

MailAD unterstützt optionalen SPAM-Schutz. Dies umfasst:

- DNSBL: Sie können E-Mails von bekannten SPAM-Absendern mit DNS-Blacklists blockieren.
- Andere Techniken: Sie können verschiedene Tricks verwenden, um SPAM zu blockieren, wie das Blockieren von E-Mails ohne Betreff, das Blockieren von E-Mails mit bestimmten Mustern im Betreff usw.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Optionale Verschlüsselung für LDAP-Kommunikation

MailAD unterstützt optionale Verschlüsselung für LDAP-Kommunikation. Das bedeutet, dass Sie die Kommunikation zwischen MailAD und Ihrem LDAP-Server verschlüsseln können.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Optionale Benachrichtigungen an Gruppen statt nur an den Mail-Administrator

MailAD unterstützt optionale Benachrichtigungen an Gruppen statt nur an den Mail-Administrator. Das bedeutet, dass Sie Benachrichtigungen an eine Gruppe von Benutzern statt nur an den Mail-Administrator senden können.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Optionaler Haftungsausschluss bei jeder ausgehenden E-Mail

MailAD unterstützt einen optionalen Haftungsausschluss bei jeder ausgehenden E-Mail. Das bedeutet, dass Sie jedem E-Mail, das Ihren Server verlässt, einen Haftungsausschluss hinzufügen können.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Optionale Alle-Liste mit benutzerdefinierter Adresse

MailAD unterstützt eine optionale Alle-Liste mit benutzerdefinierter Adresse. Das bedeutet, dass Sie eine Liste erstellen können, die alle Benutzer Ihrer Domain enthält.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Optionaler Benutzerprivilegien-Zugriff über AD-Gruppen

MailAD unterstützt optionalen Benutzerprivilegien-Zugriff über AD-Gruppen. Das bedeutet, dass Sie steuern können, welche Benutzer Zugriff auf welche Ressourcen haben, indem Sie AD-Gruppen verwenden.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Manuelle Aliase für Tippfehler oder Unternehmenspositionen

MailAD unterstützt manuelle Aliase für Tippfehler oder Unternehmenspositionen. Das bedeutet, dass Sie Aliase für häufig falsch geschriebene Adressen oder für Unternehmenspositionen erstellen können.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Manuelle Sperrliste für problematische Adressen

MailAD unterstützt eine manuelle Sperrliste für problematische Adressen. Das bedeutet, dass Sie E-Mails von bestimmten Adressen blockieren können.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Manuelle Header- und Body-Prüflisten

MailAD unterstützt manuelle Header- und Body-Prüflisten. Das bedeutet, dass Sie E-Mails basierend auf Mustern in den Headern oder im Body der E-Mail blockieren können.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Test-Suite

MailAD enthält eine Test-Suite, um zu überprüfen, ob Ihr Mailserver korrekt funktioniert.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Rohe Backup- und Wiederherstellungsoptionen

MailAD enthält rohe Backup- und Wiederherstellungsoptionen. Das bedeutet, dass Sie ein Backup Ihres Mailservers erstellen und ihn im Falle eines Ausfalls wiederherstellen können.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Problemlose Upgrades

MailAD unterstützt problemlose Upgrades. Das bedeutet, dass Sie Ihren Mailserver aktualisieren können, ohne Daten oder Konfiguration zu verlieren.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Wöchentliche Update-Prüfungen

MailAD führt wöchentliche Update-Prüfungen durch. Das bedeutet, dass Ihr Mailserver prüft, ob Updates verfügbar sind, und Sie benachrichtigt, wenn dies der Fall ist.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

## Physisches Postfach der Benutzer nach Standort aufgeteilt

MailAD unterstützt die Aufteilung des physischen Postfachs der Benutzer nach Standort. Das bedeutet, dass Sie die Postfächer der Benutzer nach Büro, Provinz, Stadt usw. aufteilen können.

[Zurück zum Inhaltsverzeichnis](Features.md#mailad-features-explained)

ENDE DER DATEI

