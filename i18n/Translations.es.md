<!-- Traducido originalmente por: @stdevPavelmc "Pavel Milanes" <pavelmc@gmail.com> -->
# Traducciones

Este documento es una guía de referencia para las traducciones en MailAD.

## Objetivo

El principal objetivo es establecer las pautas o guía para contribuir con las traducciones, para que todo el mundo que quiera aportar pueda hacerlo y su trabajo no sea en vano o duplicado.

Inicialmente nos enfocamos en la documentación, luego en las informaciones interactivas.

## Pautas de documentación

Estas son las pautas principales, que pueden sufrir modificaciones a lo largo del tiempo:

1. Las traducciones de documentación se harán en un fichero con el mismo nombre del original con la adición del sufijo .es antes de la extensión .md. "es" es para el caso del español; en otros idiomas se debe usar el [código internacional de 2 caracteres por idioma](https://es.wikipedia.org/wiki/ISO_639-1). Así, `README.md` se convertiría en `README.es.md` y debe ser colocado en el directorio `i18n`.

2. Las traducciones deben realizarse sobre el fichero original y solo se deben traducir los textos explicativos. Cualquier texto en inglés producido por un script debe permanecer en el idioma original.

3. Los PR para contribuir documentación se deben hacer contra la rama `development` y no contra la rama `master`. Yo revisaré, validaré y aprobaré los cambios contra master de manera manual.

4. Los PR deben ser con documentos completos traducidos. Por favor, evite enviar traducciones parciales, esto genera trabajo doble en revisión.

5. Para mantener la autoría de las traducciones, se permite y respetará un tag oculto en la primera línea con el formato de la primera línea de este documento *(no se ve desde GitHub, ábralo localmente una vez clonado)*.

6. El [issue 10](https://github.com/stdevPavelmc/mailad/issues/10) es el relativo a las traducciones. Cuando quiera contribuir, por favor comente en este issue que comenzará la traducción de algún documento para que otros sepan que está trabajando en ello y no dupliquen esfuerzos.

