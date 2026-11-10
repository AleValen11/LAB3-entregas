# Grupo 23 · SQRT

**Consigna:** Non restoring

## Integrantes
- De Los Santos, Dahiara Claribel (@dahizz)
- Kamchem, Melina (@melika2332)
- Wereszczuk, Danna Maira (@wereszczukdanna-cell)

## Archivos
- `alto_nivel/lab3a.cpp`: Programa en C++ con la demostración de conversión a formato Q, compatibilización de formatos (Q3.12 y Q7.8) y operaciones de suma, resta, producto y división.
- `asm/lab3a.asm`: Implementación en assembly LC-3 de las conversiones de formato y multiplicación en punto fijo, utilizando subrutinas de corrimiento (`SHL32`) y suma (`MULS`).
- `alto_nivel/sqrt_nr.cpp`: Análisis en C++ de la raíz cuadrada non-restoring, evaluación de formato, rango y precisión.
- `asm/modulo_sqrt_nr.asm`: Subrutina `SQRT_NR` en assembly LC-3 (diseñada como caja negra con gestión autónoma de registros y resguardo en memoria) lista para ser enlazada al menú principal.
- `bitacora_3a.md` y `bitacora_sqrt_nr.md`: Registros diarios de las sesiones de trabajo y optimización.

## Documentación Técnica (Lab 3b - SQRT Non-Restoring)
- **Algoritmo:** Raíz cuadrada "non-restoring" dígito a dígito (Li y Chu, 1996).
- **Ubicación en Memoria:** Segmento asignado en `0x4000` (Aislamiento total del kernel y del programa principal del sistema).
- **Integración y Compatibilidad:** Diseño encapsulado en "Caja Negra", 100% compatible con la interfaz del menú de la cátedra (`main_menu_one_q7_8`). La subrutina recibe el radicando exclusivamente en `R0`, devuelve la raíz en `R0`, y gestiona internamente sus iteraciones resguardando todos los registros del llamador (`R1` a `R5`) mediante directivas `ST` y `LD`.
- **Iteraciones (k):** 13 fijas inicializadas de forma interna. Es el máximo permitido para que el resto intermedio no desborde los registros de 16 bits con signo de la LC-3.
- **Formato Punto Fijo:**
  - **Entrada:** `Q7.8` (El radicando se carga en la mitad alta para ganar precisión sin usar más registros).
  - **Salida:** `Q6.9` (Calculado con la fórmula $f = n/2 + k - 8 = 9$ bits fraccionarios).
- **Rango de entrada aceptado:** `[0; 127.996]` (Si la entrada es negativa, la rutina devuelve `x8000` indicando error al sistema central).
- **Rango de salida:** `[0; 11.3145]`.
- **Precisión alcanzada:** Resolución (1 LSB) de `0.00195`, con un error máximo de `0.00098` (½ LSB) gracias al redondeo implementado en el último paso.

## Cómo probarlo
**Para Lab 3a:**
1. Cargar el archivo `asm/lab3a.asm` en el simulador de la LC-3 (LC3Tools o lc3web).
2. Poner un breakpoint en `ST R1, X_Q8` para verificar el corrimiento aritmético a la derecha.
3. Poner un breakpoint en `M_SIG` dentro de la subrutina `MULS` para observar cómo crece el producto parcial en los registros R1 y R2.
4. Ejecutar paso a paso y revisar los valores guardados en memoria (ej. `PROD_Q8` debe dar `xFC2C`).

**Para Lab 3b (SQRT Non-Restoring Integrado):**
1. Loguearse en la plataforma `lc3.lgrum.xyz` y cargar el archivo `asm/modulo_sqrt_nr.asm` junto con el menú base de la cátedra (`main.asm` y dependencias de entrada/salida).
2. Poner un breakpoint en la etiqueta `SQRT_NR` para observar el desarrollo vuelta por vuelta y comprobar el resguardo inicial de los registros.
3. Ejecutar el programa y navegar por la consola interactiva: seleccionar la opción de Raíz Cuadrada (Non-Restoring) e ingresar un valor decimal.
4. Inspeccionar la correcta impresión del resultado Q6.9 traducido a decimal en la consola.

## Arquitectura y Métricas de Desempeño (Benchmark)
El módulo fue sometido a pruebas de estrés y optimización a nivel de ISA, arrojando las siguientes métricas de rendimiento en la máquina virtual LC-3:

| Métrica | Valor Alcanzado | Observación |
| :--- | :--- | :--- |
| **Uso de Memoria** | 55 Palabras (Código) | Altamente eficiente, sin tablas LUT anexas. |
| **Complejidad Temporal** | 276 a 334 instrucciones | Ejecución acotada por $k=13$ ciclos fijos (determinista), ideal para tiempo real. |
| **Optimización ISA** | 0 Multiplicaciones / 0 Divisiones | Solo requiere Sumas, Complemento a 2 y saltos por bit de signo. |
| **Resolución LSB** | 0,00195 | Salida maximizada en formato Q6.9. |
| **Error Máximo** | 0,00098 (½ LSB) | Redondeo al más cercano garantizado. |

## Diagrama de Flujo: Lazo Principal SQRT Non-Restoring

```mermaid
flowchart TD
    A([Inicio: R=0, Q=0, k=13]) --> B
    
    B[Bajar 2 bits del radicando:<br>T = 4R + par] --> C{¿Resto anterior<br>>= 0?}
    
    C -- Sí --> D[R = T - 4Q - 1]
    C -- No --> E[R = T + 4Q + 3]
    
    D --> F
    E --> F
    
    F[Pegar bit a la raíz:<br>Q = 2Q + bit_nuevo] --> G{¿Faltan<br>iteraciones?}
    
    G -- Sí --> B
    G -- No --> H[Corrección final:<br>Si R < 0, R = R + 2Q + 1]
    
    H --> I[Redondeo:<br>Si R > Q, Q = Q + 1]
    I --> J([Fin: Resultado en Q])
```

## Integración de la Interfaz (Black-Box)

```mermaid
flowchart LR
    A["Controlador Principal<br>(Menú / Grupo 27)"] -- "R0 (Radicando Q7.8)" --> B
    
    subgraph Grupo 23
    B(("SQRT_NR<br>(Auto-gestionado en x4000)"))
    end
    
    B -- "R0 (Raíz Q6.9)" --> A
    B -. "x8000 (Error: x < 0)" .-> A
```