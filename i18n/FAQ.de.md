# MailAD FAQ

Hier finden Sie die häufigsten Fragen. Diese Datei wird mit dem Feedback der Benutzer wachsen.

## FRAGEN

## Installationsbezogen

- [Ich habe gemäß den Anweisungen in der INSTALL.md-Datei installiert, ich kann E-Mails überprüfen und senden, aber sie erreichen nicht den Posteingang der Benutzer](FAQ.de.md#ich-habe-gemäß-den-anweisungen-in-der-installmd-datei-installiert-ich-kann-e-mails-überprüfen-und-senden-aber-sie-erreichen-nicht-den-posteingang-der-benutzer)
- [Ich verwende Debian Buster und kann E-Mails senden, aber keine E-Mails über IMAPS/POP3S überprüfen?](FAQ.de.md#ich-verwende-debian-buster-und-kann-e-mails-senden-aber-keine-e-mails-über-imapspop3s-überprüfen)
- [Warum weigert sich MailAD, ClamAV und/oder SpamAssassin zu installieren und behauptet ein DNS-Problem?](FAQ.de.md#warum-weigert-sich-mailad-clamav-undoder-spamassassin-zu-installieren-und-behauptet-ein-dns-problem)
- [Welche Ports muss ich öffnen, um sicherzustellen, dass die Server ordnungsgemäß funktionieren?](FAQ.de.md#welche-ports-muss-ich-öffnen-um-sicherzustellen-dass-die-server-ordnungsgemäß-funktionieren)
- [Warum beschwert es sich und schlägt fehl, wenn IPs für den DC-Server verwendet werden?](FAQ.de.md#warum-beschwert-es-sich-und-schlägt-fehl-wenn-ips-für-den-dc-server-verwendet-werden)
- [Konfiguration stoppt und meldet, dass sbin fehlt?](FAQ.de.md#konfiguration-stoppt-und-meldet-dass-sbin-fehlt)
- [Ich habe gemäß den Anweisungen installiert, alles funktioniert korrekt, aber Benutzer können sich nicht authentifizieren, ich verwende Windows Server 2019](FAQ.de.md#ich-habe-gemäß-den-anweisungen-installiert-alles-funktioniert-korrekt-aber-benutzer-können-sich-nicht-authentifizieren-ich-verwende-windows-server-2019)

## Nutzungsbezogen

- [Alles funktioniert gut mit einigen E-Mail-Clients, aber andere scheitern mit Fehlern im Zusammenhang mit SSL und Verschlüsselungen](FAQ.de.md#alles-funktioniert-gut-mit-einigen-e-mail-clients-aber-andere-scheitern-mit-fehlern-im-zusammenhang-mit-ssl-und-verschlüsselungen)
- [Der Server weigert sich, E-Mails von den Benutzern auf Port 25 anzunehmen oder weiterzuleiten](FAQ.de.md#der-server-weigert-sich-e-mails-von-den-benutzern-auf-port-25-anzunehmen-oder-weiterzuleiten)

## ANTWORTEN

## Ich habe gemäß den Anweisungen in der INSTALL.md-Datei installiert, ich kann E-Mails überprüfen und senden, aber sie erreichen nicht den Posteingang der Benutzer

Das ist normalerweise auf eine nicht funktionierende amavisd-new-Filterung zurückzuführen. Wenn Sie in den Protokollen `/var/log/mail.log` nachsehen, sehen Sie möglicherweise Zeilen wie diese:

```
[...] postfix/smtp[1354]: [...] to=<user@domain.tld>, [...] status=deferred (connect to 127.0.0.1[127.0.0.1]:10024: Connection refused)
```

Wenn Sie einen `mailq`-Befehl ausführen, sehen Sie möglicherweise so etwas:

```
[...] amavis@cdomain.tld (connect to 127.0.0.1[127.0.0.1]:10024: Connection refused) [...]
```

Das liegt normalerweise daran, dass amavis nicht funktioniert, weil spammassasin oder clamav eingestellt, aber nicht konfiguriert sind (das könnte in der Bereitstellungsphase passiert sein...)

### Zu überprüfende Dinge:

- Wenn Sie sich hinter einem Proxy befinden, stellen Sie sicher, dass Sie Host, Port, Benutzername und Passwort in der Datei `/etc/mailad/mailad.conf` konfiguriert haben. Wenn das nicht eingestellt ist, tun Sie es und erzwingen Sie eine erneute Bereitstellung (`make force-provision` im Repository-Ordner).
- Vielleicht ist spamassassin bei der ersten Regelkompilierung in der Bereitstellungsphase fehlgeschlagen (langsames Internet?). Führen Sie dies als Root aus: `sa-update`, bis es ohne Beschwerden funktioniert, und starten Sie dann amavisd-new neu.

Das sollte es tun.

## Ich verwende Debian Buster und kann E-Mails senden, aber keine E-Mails über IMAPS/POP3S überprüfen?

Bei genauerer Betrachtung des Mail-Logs werden Sie einige Fehler im Mail-Log sehen, die sich auf dovecot beziehen, das nicht richtig startet. Läuft es wahrscheinlich in einem LXC-Container?

Es gibt einen bekannten Fehler von dovecot, der in einem unprivilegierten Container läuft und diese Fehler in der Protokolldatei erzeugt:

```
[...] Failed at step NAMESPACE spawning /usr/sbin/dovecot: Permission denied
```

Die häufigste Lösung besteht darin, Nesting für diesen Container zu aktivieren:

- Überprüfen Sie die Optionen/Funktionen für den Container.
- Aktivieren Sie Nesting.
- Starten Sie den Container neu.

Überprüfen Sie jetzt, es sollte funktionieren.

## Warum weigert sich MailAD, ClamAV und/oder SpamAssassin zu installieren und behauptet ein DNS-Problem?

Dahinter steckt eine einfache Tatsache: Beide (SpamAssassin & ClamAV) verwenden eine DNS-Abfrage an einen bestimmten TXT-Datensatz, um die Details des Datenbank-Fingerabdrucks zu erhalten.

Wenn Sie kein funktionierendes DNS haben, wird es einige Zeit nach der Bereitstellung funktionieren, und in 12-48 Stunden wird sich einer von ihnen weigern zu arbeiten, dann wird Amavis sterben und all Ihre E-Mails (die in die Domain hinein- oder aus ihr herausgehen) werden 4 Stunden lang in der Postfix-Warteschlange zu amavis gefangen, dann werden Benutzer anfangen, MAILER-DAEMON-Benachrichtigungen zu sehen, und Sie werden in Schwierigkeiten geraten...

Um das zu vermeiden, haben wir in der Überprüfungsphase der Installation eine Sicherheitsmaßnahme eingebaut: Wenn Sie die ClamAV- oder SpamAssassin-Filterung in der Konfigurationsdatei aktivieren, überprüfen wir, ob wir die jeweiligen Datenbankaktualisierungen über DNS erhalten können. Wenn nicht, sehen Sie die Fehler.

## Welche Ports muss ich öffnen, um sicherzustellen, dass die Server ordnungsgemäß funktionieren?

Erforderliche Ports:

### Eingehender Verkehr

- Port 25/TCP (SMTP) vom externen Netzwerk oder von einem Perimeter-Mail-Gateway.
- Port 465/TCP (SMTPS) vom Benutzernetzwerk für Legacy-Clients, nicht empfohlen, vorzugsweise Submission verwenden.
- Port 587/TCP (SUBMISSION) vom Benutzernetzwerk, bevorzugte Methode für Benutzer zum Senden von E-Mails.
- Port 993/TCP (IMAPS) vom Benutzernetzwerk, bevorzugte Methode für Benutzer zum Abrufen von E-Mails.
- Port 995/TCP (POP3S) vom Benutzernetzwerk, nicht empfohlen, vorzugsweise IMAPS verwenden.

### Ausgehender Verkehr

- Port 53/UDP/TCP (DNS) zur Abfrage von Upstream-DNS-Servern
- Ports 80/TCP (HTTP) und 443/TCP (HTTPS) zum Abrufen von Updates des AV & SPAMD (falls aktiviert) und zum Aktualisieren des Betriebssystems.
- Port 25/TCP (SMTP) zum Senden von E-Mails an das externe Netzwerk.

Bitte beachten Sie, dass im eingehenden Verkehr kein Benutzerverkehr auf Port 25 erlaubt ist. Erlauben Sie Benutzern NICHT, Port 25 zum Senden von E-Mails zu verwenden, dieser Port ist für den Empfang des eingehenden Verkehrs aus dem externen Netzwerk reserviert.

## Warum beschwert es sich und schlägt fehl, wenn IPs für den DC-Server verwendet werden?

Wenn Sie die HOSTAD-Variable in der Datei /etc/mailad/mailad.conf festlegen, verwendet MailAD diesen AD-Server (oder diese Server) für Authentifizierung und Einstellungen, und Sie **müssen** ihn mit dem vollqualifizierten Domainnamen (FQDN) des AD-Servers (oder der Server) einrichten; der Grund ist einfach:

Der FQDN des DC-Servers ist bedeutsam für die LDAP-Gespräche. Es funktionierte in der Vergangenheit mit IP, aber neuere Betriebssysteme liefern strengere Überprüfungen, und wir werden das durchsetzen, um mit alter und neuer Software konform zu sein. Darüber hinaus ist es kritisch, wenn Sie LDAP über Secure Socket Layer (SSL) verwenden, da der Server möglicherweise die Kommunikation mit dem DC verweigert, wenn die Namen auf dem Server nicht mit denen in den bekannten Zertifikaten übereinstimmen.

**Frage:** Ok, ich verstehe, aber ich habe hier eine komplizierte Einrichtung und habe keinen Nameserver, der für den DC-Server richtig antworten kann, also was kann ich tun, um das zu beheben?

Wenn Sie eine Einrichtung wie die in der Frage haben, müssen Sie das Netzwerk neu gestalten, um MailAD den Zugriff auf einen funktionierenden DNS-Server zu ermöglichen, aber in extremen Fällen, wenn Sie das nicht tun können **(ich wiederhole: extreme Fälle)**, können Sie Folgendes tun:

Fügen Sie eine Zeile am Ende der Datei `/etc/hosts` auf dem MailAD-Server mit folgendem Format hinzu:

```sh
1.2.3.4     dc.domain.cu dc
```

Wobei `1.2.3.4` die IP des Servers ist und `dc.domain.cu` der Name, der auf dem tatsächlichen Namen des von Ihnen verwendeten Domänenservers steht; und `dc` ist nur der Host-Teil des FQDN.

## Konfiguration stoppt und meldet, dass sbin fehlt?

Sie sehen, Debian (zumindest Debian 11) hat entschieden, dass Benutzer keine /sbin- oder /usr/sbin-Pfade im Ausführungspfad ($PATH-Variable in der Umgebung) haben, und einige Administratoren verwenden Legacy-Methoden, um Root-Rechte zu erhalten (`su root` ist Legacy, verwenden Sie stattdessen `su -`), was zu einer Root-Sitzung führt, aber ohne /sbin oder /usr/sbin im Ausführungspfad.

Das ist gleichbedeutend damit, dass einige Tools nicht installiert sind, sodass die Konfiguration und Bereitstellung mit Fehlern enden wird. Der Workaround besteht darin, den Benutzer vor diesem Problem zu warnen und eine Korrektur für die gesamte Maschine vorzunehmen:

Ein bedingtes Codesegment in der Datei /etc/environment, das die fehlenden Pfade in der Umgebung lädt, wenn sie nicht geladen sind. Dieses Skript ist eine Korrektur für die gesamte Maschine.

Sie müssen den Anweisungen folgen und sich von der Root-Sitzung abmelden und erneut Root-Zugriff erhalten. Diesmal wird es die richtigen Pfade haben und Sie können mit dem Bereitstellungsprozess fortfahren.

## Alles funktioniert gut mit einigen E-Mail-Clients, aber andere scheitern mit Fehlern im Zusammenhang mit SSL und Verschlüsselungen?

Das ist hauptsächlich ein veralteter E-Mail-Client oder ein Legacy-Betriebssystem. Sie erhalten diese Fehler in Windows von XP bis zu frühen Win10-Versionen und Microsoft-Clients; einige andere E-Mail-Clients wie Thunderbird oder Evolution können diese Fehler geben, wenn sie sehr alt sind (3 Jahre oder mehr).

Problem: MailAD hat einige Verschlüsselungsoptionen deaktiviert, die bekanntermaßen Probleme verursachen. Sie können darüber mehr erfahren, indem Sie nach Begriffen wie "SSL FREAK attack", "POODLE attack", SSL-Angriffe usw. suchen.

Lösungen:

- Aktualisieren Sie Ihren E-Mail-Client, dies behebt normalerweise die Probleme.
- Wenn Sie Microsoft Windows und den Outlook-E-Mail-Client verwenden, ist die Lösung etwas komplizierter:
    - Laden Sie [IISCrypto](https://www.nartac.com/Products/IISCrypto) herunter.
    - Installieren Sie es und führen Sie es aus.
    - Wählen Sie die Option "Best practices" und dann "Apply".
    - Starten Sie Ihren Computer neu.

## Der Server weigert sich, E-Mails von den Benutzern auf Port 25 anzunehmen oder weiterzuleiten?

Dieser Port ist für den Empfang von E-Mails aus dem externen Netzwerk reserviert. Benutzer sollten ihn nicht zum Senden von E-Mails verwenden. Bitte überprüfen Sie [diese andere Frage](FAQ.de.md#welche-ports-muss-ich-öffnen-um-sicherzustellen-dass-die-server-ordnungsgemäß-funktionieren), um mehr zu erfahren.

## Ich habe gemäß den Anweisungen installiert, alles funktioniert korrekt, aber Benutzer können sich nicht authentifizieren, ich verwende Windows Server 2019

Das kann daran liegen, dass die Benutzerkontensteuerungscodes (UAC) nicht die üblichen sind. Dies kann viele Gründe haben, aber wir werden hier nicht die Gründe betrachten, sondern vielmehr sehen, wie man das Problem löst:

Normalerweise sehen wir in der Benutzerkontensteuerung, dass die Eigenschaft **userAccountControl** die Werte hat:

| Code | Beschreibung |
|---------:|:---------------|
| 512 | Normaler Benutzer|
| 66048| Aktiviert, Passwort läuft nie ab|

In vielen Fällen, wenn unser Server zur Authentifizierung ein Windows Server 2019 ist, erscheinen diese Eigenschaften in **userAccountControl**

| Code | Beschreibung |
|---------:|:---------------|
| 544 | Aktiviert, Passwort bei nächster Anmeldung ändern|
| 66080| Aktiviert, Passwort läuft nie ab, Passwort nicht erforderlich|

Um das Authentifizierungsproblem für Benutzer zu lösen, die diese Eigenschaften haben, ist es notwendig, diese Eigenschaften zum Parameter **userAccountControl** in den Variablen hinzuzufügen, d.h. die Filter zu ändern. Wo sollten wir sie ändern?

Im Root-Verzeichnis unseres mailad suchen wir nach diesen Dateien und lassen sie wie gezeigt:

```bash
cd var/dovecot-2.2/
nano dovecot_ldap.conf.ext
.
.
.
# Wir kommentieren das Folgende und lassen es so
# user_filter = (&(sAMAccountName=%n)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)))
user_filter = (&(sAMAccountName=%n)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)(userAccountControl=544)(userAccountControl=66080)))
.
.
.
# Wir kommentieren das Folgende und lassen es so
# pass_filter = (&(mail=%u)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)))
pass_filter = (&(mail=%u)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)(userAccountControl=544)(userAccountControl=66080)))

# Strg+X und speichern Sie die Änderungen

cd var/dovecot-2.3/
nano dovecot_ldap.conf.ext
.
.
.
# Wir kommentieren das Folgende und lassen es so
# user_filter = (&(sAMAccountName=%n)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)))
user_filter = (&(sAMAccountName=%n)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)(userAccountControl=544)(userAccountControl=66080)))
.
.
.
# Wir kommentieren das Folgende und lassen es so
# pass_filter = (&(mail=%u)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)))
pass_filter = (&(mail=%u)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)(userAccountControl=544)(userAccountControl=66080)))

# Strg+X und speichern Sie die Änderungen

cd var/postfix/ldap/
nano email2user.cf
.
.
.
# Wir kommentieren das Folgende und lassen es so
# query_filter = (&(mail=%u@%d)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)))
query_filter = (&(mail=%u@%d)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)(userAccountControl=544)(userAccountControl=66080)))

# Strg+X und speichern Sie die Änderungen

nano mailbox_map.cf
.
.
.
# Wir kommentieren das Folgende und lassen es so
# query_filter = (&(mail=%u@%d)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)))
query_filter = (&(mail=%u@%d)(|(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)(userAccountControl=544)(userAccountControl=66080)))

# Strg+X und speichern Sie die Änderungen

cd var/roundcube/
nano config.inc.php
.
.
.
# Wir lassen es wie folgt unten
'filter' => '(&(mail=*)(|(objectClass=group)(userAccountControl=512)(userAccountControl=66048)(userAccountControl=8398120)(userAccountControl=66080)(userAccountControl=544)))',

# Strg+X und speichern Sie die Änderungen
```

Ebenso, wenn Ihre Einrichtung andere Attribute (UAC) hat, müssen Sie alle Filter innerhalb von *var* ändern, um sie an Ihre Bedürfnisse anzupassen.

### Upgrade auf eine neue Version, wenn wir die Filter an unsere Einrichtung angepasst haben

Nach dem **Upgrade** auf die neue Version müssen wir wieder zu all diesen Filtern gehen und sie an unsere Bedürfnisse anpassen und dann ein **provision** machen, um unsere Filtereigenschaften (UAC) zu setzen.

