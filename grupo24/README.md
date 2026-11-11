# Conversor Multidireccional Decimal / Binario / Hexadecimal en LC-3

**Materia:** Arquitectura de Computadoras  
**Implementación:** Ensamblador LC-3

## Integrantes
- Garay, Carlos Ezequiel (@ezegaray14)
- Leopolino, Joaquín Fabián (@joakoleo)
- Pacheco, Agustin Santiago Ramón (@agusspachecoo)

## Principio de funcionamiento

El programa recibe un valor numérico en una de las tres bases admitidas y genera automáticamente su representación en las otras dos. La selección de la base de entrada se realiza mediante un menú inicial o mediante prefijos distintivos: `#` para decimal, `b` para binario y `x` para hexadecimal.

El parseo multidireccional se apoya en una representación interna única: un entero de 16 bits en complemento a dos. Cada rutina de lectura interpreta la entrada según la base seleccionada y construye ese valor de forma acumulativa:

- **Decimal:** se procesa el signo opcional y cada dígito se incorpora mediante la acumulación `valor × 10 + dígito`, controlando el rango antes de cada multiplicación.
- **Binario:** cada bit leído se incorpora desplazando el acumulador una posición a la izquierda y sumando el nuevo bit, completando exactamente 16 posiciones.
- **Hexadecimal:** cada dígito se valida como nibble y se incorpora desplazando el acumulador cuatro posiciones a la izquierda y sumando su valor entre 0 y 15.

Una vez obtenido el valor interno, una única rutina de conversión calcula los cuatro nibbles que lo componen y genera las salidas correspondientes. En la salida por pantalla se aplica una optimización extrema basada en **desenrollado total de bucles (loop unrolling)** y en un **árbol de decisión en cascada** para el cálculo de cada nibble. De esta manera, las rutinas de impresión no utilizan bucles ni llamadas internas `JSR`, ni saltos `JMP` dentro de la conversión: cada nibble se resuelve una sola vez mediante comparaciones y ramificaciones encadenadas, seleccionando directamente la cadena binaria o el carácter hexadecimal ya precalculado. Esta estructura reduce al mínimo los ciclos de reloj, evita el costo de administración de subrutinas y elimina recálculos innecesarios.

## Rango de valores que acepta la función

| Base de entrada | Formato admitido | Límites exactos |
|---|---|---|
| Decimal | Entero con signo opcional | `-32768` a `32767` |
| Binario | Exactamente 16 bits | `0000 0000 0000 0000` a `1111 1111 1111 1111` |
| Hexadecimal | Prefijo `x` y 4 dígitos hexadecimales | `x0000` a `xFFFF` |

Los valores binarios y hexadecimales se interpretan como patrones de 16 bits en complemento a dos. Por ello, los patrones `x8000` a `xFFFF` corresponden a los valores decimales negativos `-32768` a `-1`, mientras que `x0000` a `x7FFF` representan el rango `0` a `32767`.

El programa valida que todos los caracteres pertenezcan a la base seleccionada, que la cantidad de dígitos sea la adecuada y que el resultado no exceda los límites representables en 16 bits. Ante una entrada inválida, se informa el error y se descarta el resto de la línea para evitar interpretaciones incorrectas.

## Formato punto fijo

El sistema utiliza exclusivamente enteros de 16 bits en **complemento a dos**, en formato **Q15.0**. Esto significa que la palabra se interpreta como un número entero sin parte fraccionaria: **1 bit de signo y 15 bits de magnitud**.

- El bit más significativo indica el signo: `0` para valores no negativos y `1` para valores negativos.
- Los 15 bits restantes representan la magnitud, con el valor negativo expresado mediante complemento a dos.
- Al no existir bits fraccionarios, el escalamiento es `2^0 = 1`; el entero almacenado coincide exactamente con el valor numérico representado.

Este formato permite cubrir el rango completo `-32768` a `32767` y sirve como representación común para las tres bases de entrada y salida.

## Rango de valores de la salida

La salida se acota siempre al mismo universo de 16 bits:

- **Binario:** se imprimen exactamente 16 caracteres, desde `0000000000000000` hasta `1111111111111111`, conservando los ceros a la izquierda.
- **Hexadecimal:** se imprimen exactamente 4 dígitos hexadecimales en mayúsculas, desde `0000` hasta `FFFF`, conservando los ceros a la izquierda. El signo queda implícito en el bit más significativo.
- **Decimal:** se imprime el valor entero con signo, desde `-32768` hasta `32767`; los valores negativos incluyen el signo `-` y los positivos no llevan signo explícito.

Cada representación se muestra precedida por su etiqueta identificatoria (`Binario: `, `Hexadecimal: ` o `Decimal: `), de modo que la salida en pantalla resulta inequívoca y conserva el ancho fijo necesario para comparar patrones de 16 bits.

## Precisión alcanzada

La conversión posee **precisión absoluta**. Al operar exclusivamente con aritmética entera de 16 bits, no existen errores de redondeo, pérdida de información ni truncamiento fraccionario: cada valor de entrada se transforma en una representación exacta y biunívoca dentro del rango admitido.

La validación previa de rango impide desbordamientos, y las conversiones entre decimal, binario y hexadecimal se realizan mediante acumulaciones, desplazamientos y extracción de nibbles que preservan todos los bits del valor original. En consecuencia, para toda entrada válida, la salida generada representa exactamente el mismo número en las otras dos bases.
