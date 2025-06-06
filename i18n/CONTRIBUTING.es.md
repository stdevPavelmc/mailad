# Contribuciones a MailAD

## Proceso y flujo de trabajo de desarrollo

Este documento establece el proceso y los flujos de trabajo según las buenas prácticas de Github y gitflow (en algunos casos simplificadas y relajadas), si tiene alguna duda por favor eche un vistazo [aquí](https://medium.com/@devmrin/learn-complete-gitflow-workflow-basics-how-to-from-start-to-finh-8756ad5b7394) o [aquí](https://nvie.com/posts/a-successful-git-branching-model/).

Estas prácticas pueden parecer de "élite" o "estilo catedral" al principio, pero créeme que me agradecerás que te enseñe esto si pretendes trabajar para una compañía más grande o profesional de software. Al final y con el tiempo verán lo fácil que es señalar cualquier información del enredo de ramas, issues, travis, etc.

Al principio no seremos estrictos con esto, pero por favor, estudia el (git)flow lo antes posible.

## Issues!

Todo gira alrededor de los issues, cada cambio debe tener un issue de referencia en el que el equipo de desarrollo pueda debatir, y las ramas con el  nombre del usuario y el issue en el que está trabajando.

Así que si necesitas hacer un cambio, arreglar algo o añadir una nueva característica, por favor abre un nuevo issue para esto. Una vez que tengas un número de issue para trabajar, crea una rama del último desarrollo en TU fork y llámala user_t#_short_description_of_issue, por ejemplo una rama llamada stdevPavelmc_t8_travis_integration donde el número 8 es el número de issue al que está relacionada.

## Commits

Todos los comentarios de los commits deben comenzar con "Refs #8, ...." donde en este caso el #8 se refiere al issue en el que estás trabajando, ¿por qué? puedes verlo [aquí en acción](https://github.com/swl-x/MystiQ/issues/8).

Pasa el ratón por encima del nombre, número y comentarios del commit d4a19cd. Github hace un gran trabajo enlazando todo, y esto es posible porque mencionamos el issue en el nombre de la rama y también en el comentario del commit.

## Pull request (PR)

Los pull requests son intenciones de fusionar algún código en el árbol principal del proyecto, puedes abrir un pull request con tu trabajo local en cualquier momento, la única condición es que hayas enviado al menos un commit para un issue.

De hecho es una práctica recomendada, abrir un issue, analizar, hacer su primer commit y abrir el pull request en ese momento; de esta manera los cambios serán elegidos por Travis y el CI / CD se ejecutará para decirle si sus cambios son buenos o si se rompió algo.

Como regla general, un pull requests debe terminar con un comentario en el que se menciona a @stdevPavelmc e informando que el pull request está listo para fusionarse.

El __merge__ por parte del dueño del repo (@stdevPavelmc) cerrará automáticamente el correspondiente __pull requests__ y el __issue__ con sólo añadir un comentario como este al comentario de la fusión "Cerrando el issue #8..." Github hará la magia y (si la construcción de Travis es un éxito) cerrará el __pull request__ y el __issue__ correspondiente, todo en un paso.

## Contribuciones monetarias

Este es un software libre y puedes usarlo sin cargos, pero si quieres expresar tu gratitud en forma monetaria estamos agradecidos por ello:

### Open Collective

Sí, tenemos una organización registrada bajo la iniciativa Open Collective para financiamiento público y abierto. Puedes ser un patrocinador de este proyecto, solo visítanos en nuestra [Página de OpenCollective](https://opencollective.com/mailad)

### Ponme una recarga a mi celular para mantenerme conectado

Mi número de celular es: **`(+53) 53 847 819`**, puedes donar el monto que quieras.

- Los sitios oficiales para realizar las recargas son los siguientes:
    - [Ding](https://www.ding.com)
    - [Recargas a Cuba](https://www.recargasacuba.com)
    - [CSQWorl](https://www.csqworld.com)
    - [Compra dtodo](https://moviles.compra-dtodo.com)
    - [Global DSD](https://www.globaldsd.com)
    - [Boss Revolution](https://www.bossrevolution.com)
    - [E-Topup Online](https://cubacel.etopuponline.com)
- Usando **Criptomonedas** usando [BilRefill](https://www.bitrefill.com/buy/cubacel-cuba/?hl=es)

### Donaciones en dinero

- Puedes donar usando cualquiera de las pasarelas de pago disponibles, escoge la más conveniente para ti.

<p>
    <table>
        <tr>
            <td style="text-align=center">
                Con Transfermovil
            </td>
            <td style="text-align=center">
                Con EnZona
            </td>
            <td style="text-align=center">
                Con <a href="https://qvapay.com/payme/pavelmc">QvaPay</a>
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

**Gracias por su contribución!**
