; =====================================================================
; Lab 3b - Grupo 23 - SQRT por el metodo NON-RESTORING (Li y Chu, 1996)
; Arquitectura de Computadoras (IC221) - FI-UNaM - 2026
;
; Programa de prueba: toma CANT valores de la tabla ENTRADAS (Q7.8),
; calcula la raiz con k = 13 iteraciones y la deja en SALIDAS (Q6.9).
; Para pasar a otro formato solo cambian los datos y k (ver SQRT_NR).
; =====================================================================
            .ORIG x3000
MAIN        LEA R6, ENTRADAS ; puntero a las entradas
            LEA R5, SALIDAS  ; puntero a las salidas
            LD R4, CANT      ; cantidad de valores

LAZO        LDR R0, R6, #0   ; R0 = x (Q7.8)
            AND R1, R1, #0
            ADD R1, R1, #13  ; k = 13 -> raiz en Q(8/2 + 13 - 8) = Q6.9
            JSR SQRT_NR
            STR R0, R5, #0   ; guardar la raiz
            ADD R6, R6, #1
            ADD R5, R5, #1
            ADD R4, R4, #-1
            BRp LAZO
            HALT

; =====================================================================
; SQRT_NR: raiz cuadrada en punto fijo, metodo no restaurador.
; Entrada: R0 = X >= 0 en Qm.n (n par)
; R1 = k = cantidad de iteraciones (1 a 13)
; Salida: R0 = raiz redondeada, en Q(15-f).f con f = n/2 + k - 8
; R0 = x8000 si X < 0 (no hay raiz real)
; Guarda y restaura R1 a R5. Usa R7 para volver (no llama a nadie).
;
; Registros adentro:
; R0 = radicando: X en la parte alta, la parte baja vale 0, por eso
; alcanza con un registro (se corre 2 bits por iteracion)
; R1 = contador R2 = resto parcial (con signo) R3 = raiz parcial
; R4 = 4Q+1 / 4Q+3 y temporales
; =====================================================================
SQRT_NR     ST R1, SQ_S1
            ST R2, SQ_S2
            ST R3, SQ_S3
            ST R4, SQ_S4
            ST R5, SQ_S5
            
            ADD R0, R0, #0
            BRn SQ_NEG       ; X < 0 -> error
            AND R2, R2, #0   ; resto = 0
            AND R3, R3, #0   ; raiz = 0

SQ_LAZO     ; ---- 1) bajar los 2 bits mas altos del radicando: R = 4R + par
            ADD R2, R2, R2   ; R << 1
            ADD R0, R0, #0
            BRzp SQ_B1
            ADD R2, R2, #1   ; entra el bit 15 del radicando

SQ_B1       ADD R0, R0, R0   ; radicando << 1
            ADD R2, R2, R2   ; R << 1
            ADD R0, R0, #0
            BRzp SQ_B2
            ADD R2, R2, #1

SQ_B2       ADD R0, R0, R0
            ; ---- 2) restar o sumar segun el signo del resto
            ADD R4, R3, R3   ; 2Q
            ADD R4, R4, R4   ; 4Q
            ADD R2, R2, #0   ; signo del resto (correrlo no lo cambia)
            BRn SQ_SUMA
            
            ADD R4, R4, #1   ; resto >= 0: R = R - (4Q + 1)
            NOT R4, R4
            ADD R4, R4, #1
            ADD R2, R2, R4
            BRnzp SQ_BIT

SQ_SUMA     ADD R4, R4, #3   ; resto < 0: R = R + (4Q + 3)
            ADD R2, R2, R4

            ; ---- 3) nuevo bit de la raiz: 1 si R >= 0
SQ_BIT      ADD R3, R3, R3   ; Q << 1
            ADD R2, R2, #0
            BRn SQ_SIG
            ADD R3, R3, #1

SQ_SIG      ADD R1, R1, #-1
            BRp SQ_LAZO

            ; ---- correccion final del resto (si quedo negativo) ----
            ADD R2, R2, #0
            BRzp SQ_RED
            ADD R4, R3, R3
            ADD R4, R4, #1
            ADD R2, R2, R4   ; R = R + 2Q + 1 -> R = D - Q*Q

            ; ---- redondeo al mas cercano: si R > Q, Q = Q + 1 ----
SQ_RED      NOT R4, R3
            ADD R4, R4, #1   ; -Q
            ADD R4, R2, R4   ; R - Q
            BRnz SQ_FIN
            ADD R3, R3, #1

SQ_FIN      ADD R0, R3, #0   ; resultado en R0
            BRnzp SQ_REST

SQ_NEG      LD R0, SQ_ERR

SQ_REST     LD R1, SQ_S1
            LD R2, SQ_S2
            LD R3, SQ_S3
            LD R4, SQ_S4
            LD R5, SQ_S5
            RET

; ---------- variables y datos en memoria ----------
SQ_ERR      .FILL x8000
SQ_S1       .BLKW 1
SQ_S2       .BLKW 1
SQ_S3       .BLKW 1
SQ_S4       .BLKW 1
SQ_S5       .BLKW 1

; ---------- datos de prueba (Q7.8) ----------
CANT        .FILL #9
ENTRADAS    .FILL x0200      ; 2.0
            .FILL x0A80      ; 10.5
            .FILL x0000      ; 0
            .FILL x0001      ; 0.00390625 (el menor positivo)
            .FILL x7FFF      ; 127.99609375 (el mayor)
            .FILL x4000      ; 64.0
            .FILL x0300      ; 3.0
            .FILL x0040      ; 0.25
            .FILL xFC00      ; -4.0 (debe dar x8000)

SALIDAS     .BLKW 9
            .END