## Auditoría de Software Orientada a Compiladores
### Caso de Estudio: Solidity

Una tésis presentada para el título de Ingeniería en Sistemas.
Ciencias Exactas, UNICEN\, Argentina.

Versiones disponibles
- [Versión en PDF.](./mre_thesis.pdf)
- [Versión en Markdown](./thesis.md) (experimental).

**Abstract**

Con el advenimiento de nuevas tecnologías y la necesidad constante de
seguir desarrollando software debido a las demandas del mercado, es
inevitable depender cada vez de más herramientas externas para
mantenerse al día. Pero realmente quienes desarrollan, ¿entienden la
gravedad que posee cada vez depender más, ciegamente, de otras
tecnologías para crear nuevas? Con tanto acoplamiento, sólo basta que un
eslabón de la cadena sea inseguro para que todo el desarrollo también lo
sea. Debido a que el compilador es el unico software que tiene la
posibilidad de mirar (casi) todas las lıneas de un software, el enfoque
que propone esta tésis parte de una observación a la responsabilidad que
se deposita del lado del lenguaje en el que programan desarrolladores,
sin preguntarse si lo que están compilando introduce posibles
problemáticas. El documento de tesis comprende una puesta al día de las
técnicas disponibles para realizar auditorías de sistemas de software en
general y en particular de aquellas utilizables en el análisis de
compiladores. Asimismo, se presenta el trabajo de auditoría sobre el
lenguaje de programación Solidity y su compilador solc. Éste comprende
en detalle tanto los procesos como las herramientas utilizadas para la
auditoría. El lenguaje Solidity se encuentra dentro de aquellos
lenguajes orientados al manejo de Smart Contracts y su importancia es
crítica debido a que deben poseer una ejecución verificable y
observable. Algunas de las aplicaciones de los Smart Contracts son en el
campo de las finanzas, los seguros y contratos en general. Se presentan
además algunas soluciones y tecnologías existentes que pueden ser
aplicadas a la auditoría de compiladores, luego se propone una
metodología específica para la auditoría objeto de esta tesis y
finalmente se presentan los resultados obtenidos desde el punto de vista
del cliente interesado en esta auditoría, junto con las conclusiones, y
posibles extensiones de este trabajo.

Introducción
============

Prólogo
-------

Considerando que el mundo de la tecnología informática es un campo
relativamente nuevo, que día a día crece exponencialmente, hay que
destacar que dentro de él también se encuentran campos como el de la
*seguridad informática*, que son mucho más recientes.

La explotación de vulnerabilidades existentes y nuevas permite el acceso
no autorizado a los bienes de una empresa, siendo un problema de
seguridad de alta gravedad. *Una gran proporción de todos los incidentes
de seguridad de software son causados por atacantes que explotan
vulnerabilidades conocidas.*

*"Romper algo es más fácil que diseñar algo que no se puede romper.\"*

Por eso es fundamental que se realice la comprobación de las
aplicaciones, redes, sistemas nuevos y ya presentes, en búsqueda de
vulnerabilidades para asegurarse que nadie sin acceso autorizado haya
accedido previamente ni lo haga en el futuro.

Los análisis de seguridad comúnmente no llegan a cubrir el total de la
infraestructura de una empresa. Hay dos principales razones por las
cuales esto sucede: la inmensidad de las mismas y los plazos breves de
tiempo disponibles para el trabajo. No obstante, los mecanismos utilizados
son efectivos, lo suficiente como para identificar vulnerabilidades conocidas,
y comprobar cómo un atacante podría acceder a sus sistemas.

Las técnicas de testeo empleadas en el ciclo de vida del desarrollo
seguro de un software se pueden distinguir en cuatro categorías: **(1)**
*pruebas de seguridad basadas en modelos que se basan en los requisitos
y los modelos de diseño creados durante la fase de análisis y diseño*,
**(2)** *pruebas basadas en código y análisis estático en el código
fuente y bytecode creado durante el desarrollo*, **(3)** *pruebas de
penetración y análisis dinámico en sistemas en ejecución, ya sea en un
entorno de prueba o producción*, así como **(4)** *pruebas de regresión
de seguridad realizadas durante el mantenimiento*. A pesar
de que algunos mecanismos eran utilizados específicamente en el mundo de
la seguridad informática, *dejando de lado la revisión de código por
supuesto*, desarrolladores y DevOps están utilizando cada vez más
estrategias como *fuzzing y análisis estático de código* para probar la
calidad de su software.

Motivación
----------

En las carreras universitarias las cuestiones de seguridad no se tratan
con profundidad y de una manera enfocada al problema, sino desde los
aspectos subyacentes que permiten entender los problemas de seguridad y
sus posibles soluciones. Es por ello que los graduados que decidan
dedicarse a la seguridad informática, deben especializarse por su cuenta
a través de cursos, o mediante el aprendizaje profesional que se da a
través de la resolución de problemáticas de los clientes.

Esta propuesta surge por un interés personal originado gracias a las
materias *Lenguajes de Programación y Diseño de Compiladores*, y al
incremento que ha habido últimamente en desarrollo de nuevos lenguajes,
que poseen propósitos y contextos
distintos.

### Contexto

Los *Smart Contracts*, son programas que poseen una ejecución
completamente verificable y observable. Esto permite que exista la
certeza de que la ejecución del mismo no pueda ser alterada, abriendo
una nueva posibilidad de casos de usos que en las plataformas de cómputo
tradicionales no existían.

*Ethereum Network* fue desarrollada para ser una plataforma de
`smart contracts`, siendo la primera que posee un lenguaje (del estilo
bytecode) con característica *Turing complete* (permite que un el
lenguaje pueda llegar a programarse para realizar cualquier tipo de
operación) que corre en una máquina virtual llamada *Ethereum Virtual
Machine (EVM)*.

Si bien hay diversos lenguajes de programación que son compilados a la
representación en bytecode para EVM, el que es oficialmente desarrollado
y posee financiación por parte de la *Ethereum Foundation* es
**Solidity**.

`Solidity`, que si bien se puede percibir como un lenguaje medianamente
similar a `Javascript` en cuanto a sus aspectos sintácticos y en menor
medida semánticos, nació de la necesidad de tener un lenguaje de alto
nivel orientado a desarrollar *Smart Contracts* que permita interactuar
con la `Ethereum Network`.

Los `smart contracts` hoy en día manipulan y almacenan caudales de
dinero de gran magnitud, es por eso que es inevitable que la seguridad
en estos casos se haga presente.

Ha habido ya muchos casos registrados de pérdidas de miles de millones
de dólares, debido a descuidos a la hora de desarrollar y por no
entender este muy reciente *"paradigma"*:

-   Uno de los clientes más populares utilizado para facilitar a los
    usuarios la interacción con la red, congeló fondos valuados en \$100
    millones de dólares debido a un error en su
    código.

-   En julio del 2017, días después de que un hacker obtuviera más de 7
    millones de dólares explotando una vulnerabilidad, debido a otro
    error en el mismo cliente, otro hacker obtuvo acceso a fondos de
    algunas cuentas, valuado en un total de \$37 millones de dólares.

-   Un ejemplo de un error de diseño del lenguaje con impacto a gran
    escala es el caso del famoso llamado, en este ambiente,
    `reentrancy bug`. Permitía a un atacante retirar una gran cantidad
    de veces su balance de un contrato, volviendo a llamar a la misma
    funcionalidad en medio de su ejecución, logrando así multiplicar sus
    fondos.

Así es como que desde el lado de los estudios de los lenguajes de
programación, parece de suma relevancia poseer lenguajes y compiladores
correspondientes que funcionen de manera esperada, sin permitirle a los
desarrolladores la posibilidad de cometer errores catastróficos.

En este contexto un error en la generación del bytecode podría detener
el funcionamiento de una red de miles de máquinas virtuales, o
financieramente impactar de formas inesperadas en el contrato
desarrollado.

Objetivos
---------

*Realizar una investigación de las estrategias y metodologías existentes
para auditar compiladores, brindando primero una introducción a la
auditoría de software, luego una introducción a auditoría
específicamente de compiladores, comentando las técnicas más
populares.*

*Finalmente evaluar como caso de uso una auditoría al lenguaje
**Solidity** y a su compilador **solc**, explicando el proceso y
herramientas utilizadas, mostrando los resultados obtenidos.*
