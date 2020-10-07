<!-- Traducido originalmente por: @stdevPavelmc "Pavel Milanes" <pavelmc@gmail.com> -->
# Traducciones

Este documento es una ayuda o referencia para las traducciones en MailAD.

## Objetivo

El principal objetivo es establecer las pautas o guía para contribuir con las traducciones, para que todo el mundo que quiera aportar pueda hacerlo y su trabajo no sea en vano o duplicado.

Inicialmente nos enfocamos en la documentación, luego en las informaciones interactivas.

## Pautas de documentación

Estas son las pautas principales, pueden sufrir modificaciones a lo largo del tiempo:

0. Las traducciones de documentación se harán en un fichero con el mismo nombre del original con la adición de el sufijo .es antes de la extensión .md. "es" es para el caso del español, en otros idiomas se debe usar el [código internacional del 2 caracteres por idiomas](https://es.wikipedia.org/wiki/ISO_639-1) Así `README.md` se convertiría en `README.es.md` y deben ser puestos en el directorio `i18n`.
0. Las traducciones deben realizarse sobre el fichero original y solo se deben traducir los textos explicativos, cualquier texto en ingles producido por un script debe permanecer en el idioma original.
0. Los PR para contribuir documentación se deben hacer contra la rama `development` y no contra el `master`. Yo revisaré, validaré y aprobaré los cambios contra master de manera manual.
0. Los PR deben ser con documentos completos traducidos, por favor evite enviar traducciones parciales, esto genera trabajo doble en revisión.
0. Para mantener la autoría de las traducciones se permite y respetará un tag oculto de primer renglón con el formato de la primera línea de este documento _(no se ve desde github, ábralo en el local una vez clonado)_
0. El [issue 10](https://github.com/stdevPavelmc/mailad/issues/10) es el relativo a las traducciones, cuando usted quiera contribuir por favor comente en este issue que comenzará la traducción de algún documento para que otos sepan que está trabajando en ello y no duplicar esfuerzos.
