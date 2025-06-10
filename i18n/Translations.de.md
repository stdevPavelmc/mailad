# Übersetzungen

Dieses Dokument ist ein Referenzleitfaden für Übersetzungen in MailAD.

## Ziel

Das Hauptziel ist es, Richtlinien oder einen Leitfaden für Übersetzungsbeiträge festzulegen, damit jeder, der beitragen möchte, dies tun kann und seine Arbeit nicht vergeblich oder doppelt ist.

Zunächst konzentrieren wir uns auf die Dokumentation, dann auf interaktive Informationen.

## Dokumentationsrichtlinien

Dies sind die Hauptrichtlinien, die im Laufe der Zeit Änderungen erfahren können:

1. Dokumentationsübersetzungen werden in einer Datei mit demselben Namen wie das Original erstellt, wobei vor der Erweiterung .md das Suffix .de hinzugefügt wird. "de" steht für Deutsch; für andere Sprachen sollte der [internationale 2-Zeichen-Sprachcode](https://de.wikipedia.org/wiki/ISO_639-1) verwendet werden. So würde `README.md` zu `README.de.md` und sollte im Verzeichnis `i18n` platziert werden.

2. Übersetzungen sollten auf der Originaldatei basieren, und nur erklärende Texte sollten übersetzt werden. Jeder von einem Skript erzeugte englische Text sollte in der Originalsprache bleiben.

3. PRs für Dokumentationsbeiträge sollten gegen den `development`-Branch und nicht gegen den `master`-Branch gerichtet sein. Ich werde die Änderungen gegen master manuell überprüfen, validieren und genehmigen.

4. PRs sollten mit vollständig übersetzten Dokumenten erfolgen. Bitte vermeiden Sie das Einreichen von Teilübersetzungen, da dies bei der Überprüfung doppelte Arbeit verursacht.

5. Um die Urheberschaft von Übersetzungen zu erhalten, ist ein verstecktes Tag in der ersten Zeile im Format der ersten Zeile dieses Dokuments erlaubt und wird respektiert *(nicht sichtbar von GitHub aus, öffnen Sie es lokal nach dem Klonen)*.

6. [Issue 10](https://github.com/stdevPavelmc/mailad/issues/10) bezieht sich auf Übersetzungen. Wenn Sie beitragen möchten, kommentieren Sie bitte in diesem Issue, dass Sie mit der Übersetzung eines Dokuments beginnen werden, damit andere wissen, dass Sie daran arbeiten, und keine Arbeit doppelt gemacht wird.

