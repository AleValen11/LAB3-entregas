# Bitácora de Investigación - Grupo 23 (Laboratorio 3b: SQRT Non-Restoring)
- Tema asignado: SQRT (raíz cuadrada) por el método non-restoring.
- Alto nivel: el algoritmo se desarrolló en C++ (ZinjaI) y (Visual Studio Code).
- Bajo nivel: assembly de la ISA LC-3, ejecutado y depurado en el simulador de la LC-3.
- Control de versiones: Git y GitHub, sobre el fork del repositorio de la cátedra (carpetas grupo23/alto_nivel y grupo23/asm).

## Sesión 1
- *Fecha y hora:* 07/10/2026 - 18:00 hs a 20:15 hs
- *Objetivo del día:* Conocer el tema asignado al grupo y entender qué calcula el algoritmo SQRT non-restoring antes de implementarlo.
- *Actividades realizadas:* 
  - Sorteo de los temas del laboratorio entre los grupos: al Grupo 23 le tocó la raíz cuadrada por el método non-restoring.
  - Revisión de lo que pide la consigna para el análisis en alto nivel: funcionamiento del algoritmo, número de iteraciones, formato de punto fijo, rango y precisión.
  - Búsqueda de información sobre el algoritmo: qué objetivo tiene, cómo funciona y en qué se diferencia del método restoring.
- *Observaciones y hallazgos:* Es un método dígito a dígito que calcula la raíz cuadrada usando solamente sumas, restas y corrimientos, sin multiplicar ni dividir; esto resulta conveniente para la LC-3, que no tiene instrucciones de multiplicación ni de corrimiento. En cada iteración se incorporan dos bits del radicando y se obtiene un bit de la raíz. Cuando el resto parcial da negativo, el método restoring lo restaura sumando lo que se restó; el non-restoring conserva el resto negativo y en la iteración siguiente suma en lugar de restar, evitando ese paso extra.
- *Dificultades u obstáculos:* Comprender por qué conservar el resto negativo, en lugar de restaurarlo, no altera el resultado final.
- *Plan para la siguiente sesión:* Analizar el algoritmo en C++, depurarlo y verificar su funcionamiento.

## Sesión 2
- *Fecha y hora:* 21/10/2026 - 18:00 hs a 20:15 hs
- *Objetivo del día:* Implementar el algoritmo en un lenguaje de alto nivel para depurarlo, estudiarlo y entenderlo antes de pasar a assembly, como indica la consigna.
- *Actividades realizadas:* 
  - Análisis de cómo plantear el algoritmo non-restoring en C++ y escritura del código.
  - Ejecución y depuración paso a paso, siguiendo en cada iteración el valor del resto, de la raíz y de los dos bits incorporados del radicando.
  - Verificación de los resultados con distintos valores de entrada.
  - Desarrollo del código, una en C++ (ZinjaI) y otra en (Visual Studio Code).
- *Observaciones y hallazgos:* El algoritmo necesita una iteración por cada par de bits del radicando. Para cumplir con la consigna de punto fijo, definimos trabajar con 13 iteraciones ($k=13$). Al cargar la entrada (en formato Q7.8) en la mitad alta del registro, logramos ganar bits fraccionarios automáticamente, obteniendo el resultado en formato Q6.9. El límite de 13 iteraciones se eligió porque es el máximo posible antes de que el resto parcial desborde el límite de 16 bits con signo de la LC-3.
- *Dificultades u obstáculos:* Se trabajó con lenguajes y entornos distintos, por lo que hubo que definir cuál de las dos versiones se tomaba como base para pasar a assembly.
- *Plan para la siguiente sesión:* Pasar a assembly de la LC-3 el algoritmo verificado en C++ y comprobar que funcione correctamente.

## Sesión 3
- *Fecha y hora:* 28/10/2026 - 18:00 hs a 20:15 hs
- *Objetivo del día:* Pasar a assembly de la LC-3 el algoritmo ya verificado en C++ y comprobar que funcione correctamente.
- *Actividades realizadas:* 
  - Planificación del uso de los registros de la LC-3 para el radicando, la raíz, el resto y el contador de iteraciones.
  - Codificación de la rutina SQRT non-restoring en assembly de la LC-3.
  - Ejecución y depuración del programa en el simulador de la LC-3.
  - Comparación de los resultados del assembly con los de la versión en C++ para los mismos valores de entrada ; los resultados coincidieron en todos los casos.
- *Observaciones y hallazgos:* La LC-3 no tiene instrucciones de multiplicación ni de corrimiento, por lo que los desplazamientos que pide el algoritmo (multiplicar por 2 o por 4 el resto y la raíz) se resuelven sumando un registro consigo mismo. Contar con el código en C++ ya verificado sirvió como referencia para validar el resultado del assembly.
- *Dificultades u obstáculos:* La LC-3 no tiene instrucción de resta, por lo que las restas del algoritmo se resolvieron con complemento a dos (NOT, sumar 1 y luego sumar). Además, como no hay instrucciones de corrimiento, para extraer los bits del radicando utilizamos el truco de evaluar su signo (bit 15) mediante un ADD con cero y saltos condicionales, sumando luego el registro consigo mismo para desplazarlo a la izquierda.
- *Plan para la siguiente sesión:* Subir al repositorio los códigos de C++ y assembly, ya verificados.

## Sesión 4
- *Fecha y hora:* 06/11/2026 - 20:00 hs
- *Objetivo del día:* Subir al repositorio del grupo los códigos de SQRT non-restoring (C++ y assembly) una vez confirmado que funcionan correctamente.
- *Actividades realizadas:* 
  - Revisión final de ambos códigos antes de subirlos.
  - Subida de los archivos de C++ y de assembly al fork del repositorio de la cátedra, en las carpetas grupo23/alto_nivel y grupo23/asm creadas.
- *Observaciones y hallazgos:* Como el fork y la estructura de carpetas ya estaban configurados, solo fue necesario sumar los archivos. Subir el código recién después de verificarlo mantiene un historial limpio y permite volver atrás si una actualización posterior rompe el funcionamiento. Con esto, la rutina queda disponible para integrarse al benchmark junto con las de los demás grupos.
- *Dificultades u obstáculos:* Ninguna significativa en esta sesión.
- *Plan para la siguiente sesión:* Coordinar con los demás grupos la integración de la rutina al benchmark y preparar el informe y la defensa oral (15 minutos) del Laboratorio 3.

## Sesión 5
- *Fecha y hora:* 09/11/2026 - 20:00 hs
- *Objetivo del día:* Coordinar y aplicar actualizaciones al código Assembly para cumplir estrictamente con los requerimientos e interfaz del Grupo 27.
- *Actividades realizadas:* 
  - Coordinación de cambios estructurales en el código .asm.
  - Actualización de la subrutina para que reciba el radicando exclusivamente en R0 (formato Q7.8) y devuelva el resultado en R0 (formato Q6.9).
  - Implementación de la gestión autónoma de registros internos mediante instrucciones de resguardo (ST y LD), evitando interferencias con el entorno principal. 
- *Observaciones y hallazgos:* Al independizar los registros, la subrutina se comporta como una caja negra segura y lista para ser llamada desde cualquier controlador de menú sin efectos colaterales.
- *Dificultades u obstáculos:* Asegurar la compatibilidad exacta de la interfaz de registros con los parámetros esperados por la calculadora general.
- *Plan para la siguiente sesión:*  Probar la integración real del código actualizado en la plataforma de simulación web lc3.lgrum.xyz.

## Sesión 6
- *Fecha y hora:* 10/11/2026 - 08:30 hs
- *Objetivo del día:* Verificar el funcionamiento del nuevo código Assembly en el simulador web y presentarlo ante el jefe de la cátedra.
- *Actividades realizadas:* 
  - Verificación y corroboración del correcto funcionamiento de la rutina actualizada en lc3.lgrum.xyz.
  - Presentación de la actualización ante el Ing. Carballo (ante la ausencia temporal de la tutora Ing. Patricia Feltan), obteniendo su visto bueno y la directiva de subirlo como módulo.
  - Realización de una puesta en común con un integrante del Grupo 10 sobre el uso y comportamiento de los módulos en la plataforma.
  - Pruebas iniciales de integración utilizando el archivo main.asm y el menú principal provisto por el Grupo 27.
- *Observaciones y hallazgos:* El Ing. Carballo validó el progreso y orientó sobre el proceso formal de subida en la plataforma. La interacción con otros grupos facilitó el intercambio de experiencias sobre las herramientas del simulador.
- *Dificultades u obstáculos:* Ninguna significativa en esta sesión.
- *Plan para la siguiente sesión:* Configurar correctamente y resolver los requerimientos de sintaxis del enlazador web.

## Sesión 7
- *Fecha y hora:* 10/11/2026 - 10:30 hs
- *Objetivo del día:* Ejecutar pruebas funcionales de punta a punta en la consola de la calculadora y completar la publicación oficial del módulo en el servidor del aula.
- *Actividades realizadas:* 
  - Pruebas de ejecución interactiva en la pestaña Consola, navegando al menú de raíz cuadrada y seleccionando la opción correspondiente.
  - Autenticación en la plataforma utilizando las credenciales asignadas al Grupo 23.
  - Publicación formal del archivo modulo_sqrt_nr.asm en el servidor web mediante el botón "PUBLICAR".
  - Localización definitiva del módulo publicado dentro del apartado "Otros grupos" de la plataforma, confirmando su disponibilidad global para el proyecto.
- *Observaciones y hallazgos:* La calculadora procesa correctamente el flujo gracias a la integración del menú y los módulos de entrada. Se confirmó que el módulo del Grupo 23 ya se encuentra visible en el servidor de la cátedra.
- *Dificultades u obstáculos:* Confusión menor al buscar el módulo publicado en la sección ("Otros grupos").
- *Plan para la siguiente sesión:* Preparar el informe del Laboratorio 3 y ultimar los detalles del lab3 "b" para continuar con el lab3 "c".

## Sesión 8
- *Fecha y hora:* 10/11/2026 - 12:00 hs
- *Objetivo del día:* Optimización fina, análisis de métricas de rendimiento (ciclos de reloj y uso de memoria) y estructuración de la futura defensa oral del Laboratorio 3.
- *Activities realizadas:* 
  - Análisis de uso de memoria exacta del módulo (`.ORIG x4000`) y verificación de que no colisione con el segmento del sistema operativo ni con el menú principal.
  - Medición y validación de los ciclos de instrucción ejecutados ($k=13$ iteraciones exactas con saltos condicionales optimizados).
  - Estructuración de la presentación de 15 minutos para la defensa oral junto al Grupo 9, destacando el diseño modular como caja negra, la resiliencia ante ruido en registros y la compatibilidad con el formato Q7.8/Q6.9.
- *Observaciones y hallazgos:* El diseño modular como caja negra permite que la subrutina sea independiente del contexto de llamada, garantizando robustez ante cambios en el menú del sistema. El rendimiento en ciclos es óptimo al evitar multiplicaciones y divisiones por hardware.
- *Dificultades u obstáculos:* Ninguna significativa en esta sesión.
- *Plan para la siguiente sesión:* Seguir trabajando en la presentación final y prepararnos para la futura defensa del laboratorio ante la cátedra.