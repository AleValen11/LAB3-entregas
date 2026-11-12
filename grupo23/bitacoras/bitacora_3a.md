# Bitácora de Investigación - Grupo 23 (Lab 3a)

## Sesión 1
- *Fecha y hora:* 30/09/2026 - 18:00 hs a 20:15 hs 
- *Objetivo del día:* Analizar los formatos de representación de números en punto fijo en alto nivel (Lab 3a).
- *Actividades realizadas:* 
  - Creación de la estructura de carpetas (grupo23/alto_nivel y grupo23/asm).
  - Análisis del código lab3a.cpp. Pruebas de conversión de float a formatos Q3.12 y Q7.8 y manejo de desbordes.
- *Observaciones y hallazgos:* Observamos que la división requiere agrandar el dividendo (corrimiento de 16 bits a la izquierda) para no perder resolución en la parte fraccionaria.
- *Dificultades u obstáculos:* Comprender que al multiplicar dos números de 16 bits en C++ debíamos hacer un cast a int32_t a los operandos antes de la multiplicación, ya que de lo contrario el resultado se desbordaba y perdíamos la parte alta.
- *Plan para la siguiente sesión:* Traducir los conceptos de corrimiento y multiplicación a Assembly de la LC-3.

## Sesión 2
- *Fecha y hora:* 06/10/2026 - 18:00 hs a 20:15 hs
- *Objetivo del día:* Implementar las operaciones aritméticas de punto fijo en Assembly LC-3 (lab3a.asm).
- *Actividades realizadas:*
  - Codificación de lab3a.asm.
  - Implementación de la subrutina SHL32 para simular corrimientos, ya que la LC-3 carece de esta instrucción nativa.
  - Implementación de la subrutina MULS para la multiplicación de 16x16 bits con resultado en 32 bits.
- *Observaciones y hallazgos:* Para lograr un corrimiento a la derecha (necesario para pasar de Q20 a Q7.8 en el producto), utilizamos el truco de correr 12 bits a la izquierda en un par de 32 bits y tomar la parte alta.
- *Dificultades u obstáculos:* Entender cómo detectar y propagar el acarreo en la suma de 32 bits dentro de la LC-3. Lo solucionamos monitoreando el bit 15 de los registros antes de la suma.
- *Plan para la siguiente sesión:* Entregar el Pull Request del Lab 3a y comenzar el algoritmo SQRT non-restoring en C++ para el Lab 3b.
