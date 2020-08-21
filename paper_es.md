---
papersize: letter
margin-left: 25mm
margin-top: 15mm
margin-right: 15mm
margin-bottom: 15mm
documentclass: article
mainfont: Liberation Sans
fontsize: 12pt
colorlinks: true
---

# MailAD: una solución simple para desplegar un servidor de correo en Ubuntu/Debian Linux

<center style="font-weight: bold">Pavel Milanes Costa <sup>1</sup></center>

<center>
<small>
<sup>1</sup> Consultores Asociados S.A, Consultor "A" EP, Especialista en TI, pavel@conas.cu<br/>
</small>
</center>

## Temática
El desarrollo de aplicaciones y la provisión de servicios basados en Código Abierto.

## Resumen
Una de las principales barreras de los que llegan al mundo de GNU/Linux ya sea en Ubuntu o Debian linux es la provisión y configuración de servicios; esto por el principio de modularidad de los sistemas operativos linux que es un paradigma totalmente diferente al de Windows en cuanto a los servicios de este tipo. Es cierto qu existen soluciones empaquetadas como paquetes _all in one_ pero, estas generalmente no contienen opciones de configuraciones para algunos casos de usos típicos en Cuba. MailAD quiere ser esta solución, una solución para configurar un servicio de correos con las opciones más usadas en Cuba por defecto y ofrecer scripts para la ejecución de las tareas más comunes. En este _paper_ se explica el proceso de desarrollo y las opciones implementadas y en desarrollo; como es lógico se hace un llamado a la comunidad para contribuir con mejoras, críticas y comentarios.  

**Palabras claves:** Servidor de correos, email, provisión de correos, configuración de servidor de correos, postfix, dovecot

## Abstract

One of the main barriers of people arriving the GNU/Linux world either in Ubuntu or Debian linux, is the provision and configuration of services; This is because the modularity principle of Linux operating systems, which is a totally different paradigm from Windows in terms of services of this type. It is true that there are packaged solutions as _all in one_ packages, but these generally do not contain configuration options for some typical use cases in Cuba. MailAD wants to be this solution, a solution to configure a mail service with the most used options in Cuba by default, and offer scripts for the execution of the most common tasks. This _paper_ explains the development process and the options implemented and under development; as is logical, a call is made to the community to contribute improvements, criticisms and comments.

**Keywords:** Mail server, email, email provision, mailserver configuration, postfix, dovecot

## Introducción

Como se ha mencionado en el resumen, existen en el mercado soluciones para la configuración del servicio de correos de cara al cliente en diferentes formatos y con diferentes bondades y facilidades; entre las más comunes podemos encontrar:

- Zimbra [1]
- iRedMail [2]
- Zentyal [3]

Pero todas ellas tienen en común algún tipo de restricción a la hora de manejar las características y requisitos en el ambiente nacional, a continuación una breve lista de estos problemas:

- Imposibilidad de manejar restricciones como usuarios con correos locales (solo en la empresa), nacionales (solo dominio .cu) o incluso solo nacionales con algunas excepciones de direcciones internacionales
- Esquema de configuración demasiado genéricos que en Cuba por ley se exige restringir
- Muchas veces con opciones que tienen interdependencias que no usamos pero no podemos desactivas incrementando el consumo de recursos
- Todos presentan interfaz gráfica que facilita la configuración pero en entornos de bajos recursos esto es contraproducente
- Es trabajoso implementar estas soluciones de manera eficiente en Docker y como micro-servicios

Existen opciones _"a la cubana"_ y tutoriales para las modificaciones más empleadas para cada uno de estas plataformas pero al final estamos usando muchas veces un martillo para romper un huevo.

Por eso surge MailAD, para en el más simple de los casos facilitar el trabajo al autor en su desempeño.

El autor de este trabajo es consultor en tecnologías de la información y las comunicaciones en Consultores Asociados S.A. siendo su producto estrella la migración a soluciones Libres y abiertas (FLOSS [4]) en los nodos de empresas en Cuba. En estos casos siempre se instala un servidor de correos, en el 95% de los casos integrados al Directorio Activo; ya sea sobre Windows o sobre Linux.

## Materiales y métodos

El desarrollo del software se basa en la herramienta `make` del proyecto GNU [5], ya que permite la creación por partes de los diferentes targets u objetivos que se deben vencer para la satisfactoria instalación.

Por debajo de make se usará en venerable bash de GNU/Linux como lenguaje principal utilizando otras herramientas intrínsecas de sistema operativo como pueden ser: grep, sed, awk, cut, find, etc. De igual manera se usara el lenguaje Python [6] en la versión 3 para las tareas complejas

### Opciones y funcionalidades

Las opciones y funciones básicas incluidas son las siguientes:

- Instalación del server en menos de 30 minutos si tiene un repositorio local para la distro linux escogida
- Base de usuarios y credenciales desde el Directorio Activo con Samba o Windows
- Configuración del servicio desde un fichero de texto `mailad.conf` con todas las opciones necesarias (conservando el fichero y usando el mismo Directorio Activo se puede replicar el servidor en minutos con solo un comando: `make all`) esto además, facilita la provisión en ambientes docker
- Manejo de usuarios desde la herramienta de control del dominio, no es necesaria la administración en linea de comandos más que para funciones específicas
- La limitación de usuarios a accesos locales o nacionales se controla por la pertenencia del usuario a un grupo del directorio activo
- Cuotas personalizadas en el buzón de correos, con notificaciones al 85 y 90%
- El uso de la herramienta de administración de dominio de manera remota facilita a los novicios la administración de los usuarios
- Protección contra las principales deficiencias comunes de los servers de correo:
  - No repudio (Autenticación para envío e incluido de esa info en las cabeceras del mensaje)
  - No suplantación de identidad (inclusive luego de autenticado)
  - Todos los protocolos de comunicación usas SSL/TLS (con un certificado que se puede auto-generar con la herramienta)
  - Correo de copia para cuenta de inspección
- El almacenamiento de correos puede estar en un volumen de docker o en un NAS para seguridad y respaldo, haciendo esta configuración compatible con Docker, LXC, Proxmox CT, etc

### Ejemplos de interfaz de control

[photo]

### Funcionalidades a futuro

Algunas de las funcionalidades que se plantean a futuro para la herramienta

- Para los usuarios con algún tipo de restricción genérica se podrá añadir en la interfaz del Directorio Activo direcciones excepcionales para las que estas reglas no apliquen (caso usuario con correo solo nacional, peor autorizado a recibir/enviar a una o más direcciones en el extranjero)
- Backup de configs y correos para migración total (creación de un fichero sólido que al extraer contendrá un script que restablece la totalidad del servicio, incluido los correos de los usuarios)
- Otras que la comunidad plantee o contribuya

## Conclusiones

- Desarrollar soluciones FLOSS para las particularidades de Cuba es solo cuestión de voluntad, tiempo y conocimiento
- La solución aportada es una solución de compromiso para las particularidades de Cuba pero se ajusta a lo básico necesario por lo que podemos hablar de un 99% de cobertura de las funciones básicas en los casos normales

## Reconocimientos

- Inicialmente a mi empresa, Consultores Asociados S.A. por permitirme trabajar en algo que disfruto
- A [Gabriel Alejandro López López](https://about.me/glpzzz) por invitarme a participar en este evento 
- A muchos otros miembros de la comunidad [SysadminsdeCuba](https://www.sysadminsdecuba.com) por las ayudas y dudas solucionadas para la confección de esta herramienta

## Referencias

- [1] "Zimbra: the world's Leading Email Collboration Platform" [Online]. Available: https://www.zimbra.com. [Accessed: 14-Nov-2019].
- [2] "iRedMail - Free, Open Source Server Solution" [Online]. Available: https://www.iredmail.org. [Accessed: 14-Nov-2019].
- [3] "Zentyal: alternativa sencilla y libre a Windows Server" [Online]. Available: https://zentyal.com. [Accessed: 14-Nov-2019].
- [4] "Software Libre y de Código Abierto" [Online]. Available: https://es.wikipedia.org/wiki/Software_libre_y_de_c%C3%B3digo_abierto. [Accessed: 14-Nov-2019].
- [5] "El sistema operativo GNU" [Online]. Available: https://www.gnu.org. [Accessed: 14-Nov-2019].
- [6] "Welcome to Python" [Online]. Available: https://www.python.org. [Accessed: 14-Nov-2019].
