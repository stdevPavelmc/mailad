# Beitrag zu MailAD

## Entwicklungsprozess & Arbeitsabläufe

Dieses Dokument legt den Prozess und die Arbeitsabläufe gemäß den guten Praktiken von GitHub und Gitflow fest (in einigen Fällen vereinfacht und gelockert). Bei Zweifeln schauen Sie bitte [hier](https://medium.com/@devmrin/learn-complete-gitflow-workflow-basics-how-to-from-start-to-finish-8756ad5b7394) oder [hier](https://nvie.com/posts/a-successful-git-branching-model/) nach.

Diese Praktiken mögen zunächst "elitär" oder "kathedralenartig" erscheinen, aber glauben Sie mir, Sie werden mir dankbar sein, dass ich Ihnen das beigebracht habe, wenn Sie vorhaben, für ein größeres oder professionelles Softwareunternehmen zu arbeiten. Am Ende und mit der Zeit werden Sie sehen, wie einfach es ist, jede Information aus dem Gewirr von Branches, Issues, Travis usw. herauszupicken.

Zunächst werden wir damit locker umgehen, aber Leute, bitte erfassen Sie den (Git)Flow so schnell wie möglich.

## Issues!

Es dreht sich alles um Issues. Jede Änderung muss ein Referenz-Issue haben, in dem das Entwicklungsteam diskutieren kann, und Branches, die den Benutzer und das Issue benennen, an dem gearbeitet wird.

Wenn Sie also eine Änderung vornehmen, etwas beheben oder eine neue Funktion hinzufügen müssen, öffnen Sie bitte ein Issue oder Feature dafür. Sobald Sie eine Issue-Nummer haben, mit der Sie arbeiten können, erstellen Sie einen Branch aus dem neuesten Entwicklungsstand in IHREM eigenen Fork und nennen Sie ihn user_t#_short_description_of_issue. Hier sehen Sie, wo ich einen Branch namens stdevPavelmc_t8_travis_integration erstellt habe, wobei die Nummer die Issue-Nummer ist.

## Commits

Alle Commit-Kommentare müssen mit "Refs #8, ...." beginnen, wobei sich #8 in diesem Fall auf das Issue bezieht, an dem Sie arbeiten. Warum? Sehen Sie es [hier in Aktion](https://github.com/swl-x/MystiQ/issues/8).

Fahren Sie mit der Maus über den Namen, die Nummer und die Kommentare des Commits d4a19cd. GitHub macht einen großartigen Job, indem es alles miteinander verknüpft. Dies ist möglich, weil wir das Issue im Branch-Namen und auch im Commit-Kommentar erwähnen.

## Pull Request

Pull Requests sind Absichten, Code in den Hauptbaum zu integrieren. Sie können jederzeit einen Pull Request für Ihre lokale Arbeit öffnen, die einzige Bedingung ist, dass Sie mindestens einen Commit für ein Issue gepusht haben.

Tatsächlich ist es eine empfohlene Praxis, ein Issue zu öffnen, zu analysieren, Ihren ersten Commit zu machen und den Pull Request sofort zu öffnen; auf diese Weise werden Änderungen von Travis aufgegriffen und CI/CD wird ausgelöst, um Ihnen mitzuteilen, ob Ihre Änderungen gut sind oder etwas kaputt gegangen ist.

Als allgemeine Regel sollte ein Pull Request mit einem Kommentar enden, in dem Sie @stdevPavelmc erwähnen und erklären, dass der Pull Request bereit zum Zusammenführen ist.

Die Merge-Aktion durch den Repository-Besitzer (@stdevPavelmc) schließt automatisch den entsprechenden Pull Request und das Issue, indem einfach ein Kommentar wie "Closing issue #8..." zum Kommentar des Merges hinzugefügt wird. GitHub wird die Magie vollbringen und (wenn der Travis-Build erfolgreich ist) den PR und das passende Issue schließen, alles an einem Ort.

## Monetäre Beiträge

Dies ist freie Software und Sie können sie kostenlos nutzen, aber wenn Sie Ihre Dankbarkeit in monetärer Form ausdrücken möchten, hier ist wie:

### Open Collective

Ja, wir haben eine Organisation, die unter der Open Collective-Initiative für offene und öffentliche Finanzierung registriert ist. Sie können ein Unterstützer für dieses Projekt sein, besuchen Sie uns einfach auf unserer [OpenCollective-Seite](https://opencollective.com/mailad)

### Laden Sie mein Handy auf!

Das ermöglicht es mir, online zu bleiben, um MailAD zu entwickeln und zu verbessern. Meine Handynummer ist: **`(+53) 53 847 819`**. Sie können den Betrag spenden, den Sie möchten.

Tipp: Mein Dienstanbieter hat fast jede zweite Woche Aktionen, die jeden Betrag über 20,00 USD verdoppeln!

- Die offiziellen Auflade-Seiten sind diese (Sie können auch www.etecsa.cu besuchen, um sie zu überprüfen):
    - [Ding](https://www.ding.com)
    - [Recargas a Cuba](https://www.recargasacuba.com)
    - [CSQWorl](https://www.csqworld.com)
    - [Compra dtodo](https://moviles.compra-dtodo.com)
    - [Global DSD](https://www.globaldsd.com)
    - [Boss Revolution](https://www.bossrevolution.com)
    - [E-Topup Online](https://cubacel.etopuponline.com)
- Durch die Verwendung von **Kryptowährungen**, nutzen Sie [BitRefill](https://www.bitrefill.com/buy/cubacel-cuba/?hl=en) dafür.

### Direkte Geldspenden

- Sie können über eines der verfügbaren Zahlungsgateways spenden, wählen Sie das für Sie bequemste.

<p>
    <table>
        <tr>
            <td style="text-align=center">
                Mit Transfermovil
            </td>
            <td style="text-align=center">
                Mit EnZona
            </td>
            <td style="text-align=center">
                Mit <a href="https://qvapay.com/payme/pavelmc">QvaPay</a>
            </td>
        </tr>
        <tr>
            <td>
                <img src="../imgs/donation_transfermovil_cup.png" alt="Transfermovil"></img>
            </td>
            <td>
                <img src="../imgs/donation_enzona_cup.jpg" alt="EnZona"></img>
            </td>
            <td>
                <img src="../imgs/donation_qvapay.png" alt="QvaPay"></img>
            </td>
        </tr>
    </table>
</p>

**Vielen Dank im Voraus!**

