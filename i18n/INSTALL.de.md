# MailAD Installationsanleitung

Schauen Sie sich diese [einfache Konsolenaufzeichnung](https://asciinema.org/a/fD1LuVLfeb8RPCHOIgbR1J9d8) an, um zu sehen, wie eine reguläre Installation aussieht.

⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️

**WARNUNG:** Seit Ende Februar 2021 haben wir die Integration mit AD vereinfacht, Sie **müssen** [dieses Dokument](Simplify-AD-config.md) überprüfen, wenn Sie Ihre alte Einrichtung aktualisieren möchten.

Benutzer neuer Installationen werden keine Probleme haben, folgen Sie einfach der Installationsanleitung unten und Sie sind auf der sicheren Seite.

## Ein Hinweis zur Betriebssystemunterstützung

Es wird empfohlen, MailAD auf der neuesten LTS-Version von Ubuntu oder der neuesten stabilen Version von Debian zu installieren. Jede ältere Distribution wird unterstützt (siehe README für die Betriebssystemunterstützungsmatrix), wird aber für neue Installationen nicht empfohlen, sondern nur für Betrieb und Upgrades.

Was ist, wenn ich MailAD auf einer älteren Distribution wie 2 Ubuntu LTS oder 2 Debian-Versionen zurück installiert habe?

Einfach: Aktualisieren Sie einfach die Distribution auf die neueste Version (folgen Sie dem bevorzugten Weg für Ihre Distribution), starten Sie neu und führen Sie dann ein `make force-provision` im MailAD-Repo-Ordner aus. Nur das.

**Hinweis:** Sie müssen verhindern, dass die Benutzer während des Upgrade-Prozesses die Mail-Dienste nutzen, andernfalls könnten Benutzer ihre Postfächer aufgrund von Beschädigung verlieren.

## Einführung & Überprüfungen

Um Berechtigungsprobleme zu vermeiden, empfehlen wir Ihnen, die Dateien im Verzeichnis `/root` zu halten. Ab diesem Moment müssen Sie root sein, um die folgenden Befehle auszuführen. `sudo -i` ist Ihr Freund, wenn Sie nicht root sind.

Wenn Sie hinter einem Proxy sind, denken Sie daran, dass Sie apt darüber verwenden können, um zu aktualisieren, zu upgraden und die benötigten Apps zu installieren. Exportieren Sie einfach die folgenden Variablen und der gesamte Verkehr wird über Ihren deklarierten Proxy zum externen Netzwerk geleitet. Hier ist ein Beispiel:

``` sh
export http_proxy="http://benutzer:passwort@proxy.unternehmen.de:3128/"
export https_proxy="http://benutzer:passwort@proxy.unternehmen.de:3128/"
```

Sie müssen auch einen Proxy für git einrichten, machen Sie einfach Folgendes (falls noch nicht geschehen):

``` sh
echo "[http]" >> ~/.gitconfig
echo "    proxy = http://benutzer:passwort@proxy.unternehmen.de:3128/" >> ~/.gitconfig
```

Wenn Ihre Einrichtung einen Proxy ohne Benutzername und Passwort-Authentifizierung verwendet, lassen Sie einfach den Teil "benutzer:passwort@" in den obigen Zeilen weg, wie hier: `http://proxy.unternehmen.de:3128/`

Denken Sie daran, `benutzer`, `passwort`, `proxy.unternehmen.de` (vollständig qualifizierter Domänenname des Proxy-Servers) und `3128` (Port) durch die korrekten Werte für Ihre Umgebung zu ersetzen.

## Anfängliche Einrichtung

Aktualisieren Sie einfach Ihr System, installieren Sie Abhängigkeiten und klonen Sie dieses Repository unter `/root`, wie folgt:

**Warnung! Der empfohlene Branch für Produktionsumgebungen ist der Master-Branch, verwenden Sie keinen anderen Branch in der Produktion!**

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

## Bereiten Sie Ihren Server vor

Um Ihren Server für die Installation vorzubereiten, müssen Sie zuerst die Standardkonfiguration erstellen. Führen Sie dazu einfach diesen Befehl aus:

``` sh
make conf
```

Dieser Schritt erstellt den Ordner /etc/mailad und platziert eine Standard-mailad.conf-Datei darin. Jetzt sind Sie bereit, mit der Konfiguration Ihres Systems zu beginnen.

## Anfängliche Konfiguration

Lesen und füllen Sie alle benötigten Variablen in der Datei `/etc/mailad/mailad.conf` aus, bitte lesen Sie sorgfältig und wählen Sie weise!

_An diesem Punkt können die Schnellen und Wütenden einfach `make all` ausführen und den Hinweisen folgen, der Rest der Sterblichen folgt einfach den nächsten Schritten_

## Umgang mit Abhängigkeiten

Rufen Sie die Abhängigkeiten auf, um alle benötigten Tools zu installieren, wie folgt:

``` sh
make deps
```

Dies installiert eine Gruppe von benötigten Tools, um die Bereitstellungsskripte auszuführen. Wenn alles gut geht, sollte kein Fehler angezeigt werden; wenn ein Fehler angezeigt wird, müssen Sie ihn beheben, da es zu 99% der Zeit ein Problem im Zusammenhang mit dem Repository-Link und Updates sein wird.

## Überprüfungen

Sobald Sie die Abhängigkeiten installiert haben, ist es Zeit, die lokale Konfiguration auf Fehler zu überprüfen:

``` sh
make conf-check
```

Dies überprüft einige der vordefinierten Szenarien und Konfigurationen. Wenn ein Problem gefunden wird, werden Sie darüber gewarnt.

### Häufigste Fallstricke

- Hostname: Ihr Server muss Ihren vollständig qualifizierten Hostnamen kennen, siehe [dieses Tutorial](https://gridscale.io/en/community/tutorials/hostname-fqdn-ubuntu/), um zu erfahren, wie Sie dieses Problem lösen können
- ldapsearch-Fehler: 100% der Zeit ist es aufgrund eines Tippfehlers in der mailad.conf-Datei, überprüfen Sie sie sorgfältig

Wir sind jetzt bereit für die Installation... Oh warte! Wir müssen zuerst die SSL-Zertifikate generieren ;-)

## Zertifikatserstellung

Alle Client-Kommunikationen müssen verschlüsselt sein, daher benötigen Sie mindestens ein selbstsigniertes Zertifikat für den internen Gebrauch. Dieses Zertifikat wird von postfix & dovecot verwendet.

Wenn Sie fortfahren, wird das MailAD-Skript ein selbstsigniertes Zertifikat generieren, das 10 Jahre hält, oder wenn Sie Zertifikate von Let's Encrypt (kurz LE) haben, können Sie diese auch verwenden, Standalone und Wildcard sind beides gute Optionen.

Falls Sie LE-Zertifikate haben, ist deren Verwendung einfach. Nehmen Sie einfach diejenigen mit dem Namen "fullchain*" und "privkey*" und platzieren Sie sie im Ordner `/etc/mailad/le/`, benennen Sie sie entsprechend `fullchain.pem` und `privkey.pem`, damit die Bereitstellungsskripte sie verwenden können.

``` sh
make certs
```

Die endgültigen Zertifikate werden an diesem Ort liegen (wenn Sie LE-Zertifikate verwenden, werden sie kopiert und gesichert):

- Zertifikat: `/etc/ssl/certs/mail.crt`
- Privater Schlüssel: `/etc/ssl/private/mail.key`
- CA-Zertifikat: `/etc/ssl/certs/cacert.pem`

Wenn Sie LE-Zertifikate für Ihren Server nach der Verwendung von selbstsignierten erhalten, müssen Sie sie aktualisieren oder ersetzen. Platzieren Sie sie dann einfach (wie oben beschrieben) im Ordner `/etc/mailad/le/` in der Konfiguration und führen Sie Folgendes aus dem Ordner aus, in dem Sie die MailAD-Installation geklont haben:

``` sh
rm certs &2> /dev/null
make certs
systemctl restart postfix dovecot
systemctl status postfix dovecot
```

Die letzten beiden Schritte starten E-Mail-bezogene Dienste neu und zeigen ihren Status an, damit Sie überprüfen können, ob alles gut gelaufen ist. Wenn Sie Probleme haben, entfernen Sie einfach die Dateien aus `/etc/mailad/le/` und wiederholen Sie die obigen Schritte, das wird ein selbstsigniertes Zertifikat neu erstellen und in Betrieb nehmen.

## Software-Installationen

``` sh
make install
```

Dieser Schritt installiert alle benötigte Software. Beachten Sie, dass wir in diesem Schritt **IMMER** die Software und alte Konfigurationen bereinigen. Auf diese Weise beginnen wir immer mit einem frischen Satz von Dateien für die Bereitstellungsphase. Wenn Sie eine nicht saubere Umgebung haben, wird das Skript Schritte vorschlagen, um sie zu säubern.

## Dienste-Bereitstellung

Nach der Software-Installation müssen Sie die Konfiguration bereitstellen, das wird mit einem einzigen Befehl erreicht:

``` sh
make provision
```

Diese Phase kopiert die Vorlagendateien im var-Ordner dieses Repos und ersetzt die Werte durch die in Ihrer `mailad.conf`-Datei. Wenn ein Problem gefunden wird, werden Sie darüber gewarnt und müssen den Befehl `make provision` erneut ausführen, um fortzufahren. Es gibt auch ein `make force-provision`-Ziel, falls Sie die Bereitstellung manuell erzwingen müssen.

Wenn Sie nach der Bereitstellung eine Erfolgsmeldung erhalten, sind Sie bereit, Ihren neuen Mailserver zu testen, Glückwunsch!

## Neukonfiguration

Es muss irgendwann in der Zukunft einen Zeitpunkt geben, an dem Sie einige MailAD-Konfigurationsparameter ändern müssen, ohne den Server neu zu installieren/zu aktualisieren. Das make-Ziel `force-provision` wurde dafür erstellt. Ändern Sie den/die Parameter, die Sie in Ihrer Konfigurationsdatei (`/etc/mailad/mailad.conf`) ändern möchten, gehen Sie zum MailAD-Repo-Ordner (`/root/mailad` standardmäßig) und führen Sie aus:

``` sh
make force-provision
```

Sie werden sehen, wie es ein Backup der gesamten Konfiguration erstellt und dann den gesamten Server mit den neuen Parametern neu installiert _(dieser Prozess dauert etwa 8 Minuten auf aktueller Hardware)_. Das ist in Ordnung, da es so entwickelt wurde. Werfen Sie einen Blick auf den letzten Teil des Installationsprozesses, Sie werden etwas wie dies sehen:

```
[...]
===> Neuestes Backup ist: /var/backups/mailad/20200912_033525.tar.gz
===> Extrahieren benutzerdefinierter Dateien aus dem Backup...
etc/postfix/aliases/alias_virtuales
etc/postfix/rules/body_checks
etc/postfix/rules/header_checks
etc/postfix/rules/lista_negra
[...]
```

Ja, das `force-provision` sowie die `upgrade`-Make-Ziele bewahren die vom Benutzer modifizierten Daten.

Wenn Sie einige dieser Dateien auf die Standardwerte zurücksetzen müssen, löschen Sie sie einfach aus dem Dateisystem und machen Sie ein force-provision, so einfach ist das.

Für Änderungen, die durch Upgrades auf MailAD generiert wurden, siehe schmerzlose Upgrades in der [Features.de.md](i18n/Features.de.md#problemlose-upgrades)-Datei)

## Aktualisierung

Irgendwann wird es eine neue Version geben und Sie möchten für neue Funktionen oder nur Fehlerbehebungen aktualisieren. Um ein Upgrade zu erzwingen, tun Sie einfach Folgendes:

``` sh
cd /root/mailad # cd zum Ordner, in dem Sie das Repository geklont haben
git checkout master
git pull --rebase
make upgrade
```

Das ist alles, folgen Sie einfach den Anweisungen... Wenn Sie nur aktualisiert haben, um auf dem neuesten Stand zu sein, sind Sie fertig.

Wenn Sie aktualisiert haben, um eine neue Funktion zu erhalten, gehen Sie zur Datei `/etc/mailad/mailad.conf` und schauen Sie sich die Optionen an, die Sie aktivieren müssen. Ja, neue Funktionen werden standardmäßig deaktiviert sein, um Ihre aktuelle Einrichtung nicht zu beschädigen.

Sobald Sie die Optionen aktiviert/konfiguriert haben, gehen Sie zum geklonten Ordner [/root/mailad in diesem Beispiel] und führen Sie eine Neukonfiguration durch:

``` sh
cd /root/mailad # cd zum Ordner, in dem Sie das Repository geklont haben
make force-provision
```

Sie sind fertig.

## Was nun?

Es gibt eine [FAQ.de.md](i18n/FAQ.de.md)-Datei, um nach häufigen Problemen zu suchen; oder Sie können mich über Telegram unter meinem Nickname erreichen: [@pavelmc](https://t.me/pavelmc)

