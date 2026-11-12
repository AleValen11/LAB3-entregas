.ORIG x4000      ; Ubicacion separada en memoria para el modulo

; =====================================================================
; MODULO: SQRT_NR (Grupo 23)
; Interfaz: Recibe radicando en R0 (Q7.8). Devuelve raiz en R0 (Q6.9).
; =====================================================================
SQRT_NR     ST R1, SQ_S1     ; Resguardo de registros
            ST R2, SQ_S2
            ST R3, SQ_S3
            ST R4, SQ_S4
            ST R5, SQ_S5
            
            AND R1, R1, #0
            ADD R1, R1, #13  ; k = 13 (Autogestionado)
            
            ADD R0, R0, #0
            BRn SQ_NEG       ; X < 0 -> error (x8000)
            AND R2, R2, #0
            AND R3, R3, #0

SQ_LAZO     ADD R2, R2, R2
            ADD R0, R0, #0
            BRzp SQ_B1
            ADD R2, R2, #1

SQ_B1       ADD R0, R0, R0
            ADD R2, R2, R2
            ADD R0, R0, #0
            BRzp SQ_B2
            ADD R2, R2, #1

SQ_B2       ADD R0, R0, R0
            ADD R4, R3, R3
            ADD R4, R4, R4
            ADD R2, R2, #0
            BRn SQ_SUMA
            
            ADD R4, R4, #1
            NOT R4, R4
            ADD R4, R4, #1
            ADD R2, R2, R4
            BRnzp SQ_BIT

SQ_SUMA     ADD R4, R4, #3
            ADD R2, R2, R4

SQ_BIT      ADD R3, R3, R3
            ADD R2, R2, #0
            BRn SQ_SIG
            ADD R3, R3, #1

SQ_SIG      ADD R1, R1, #-1
            BRp SQ_LAZO

            ADD R2, R2, #0
            BRzp SQ_RED
            ADD R4, R3, R3
            ADD R4, R4, #1
            ADD R2, R2, R4

SQ_RED      NOT R4, R3
            ADD R4, R4, #1
            ADD R4, R2, R4
            BRnz SQ_FIN
            ADD R3, R3, #1

SQ_FIN      ADD R0, R3, #0
            BRnzp SQ_REST

SQ_NEG      LD R0, SQ_ERR

SQ_REST     LD R1, SQ_S1
            LD R2, SQ_S2
            LD R3, SQ_S3
            LD R4, SQ_S4
            LD R5, SQ_S5
            RET

; ---------- variables locales del modulo ----------
SQ_ERR      .FILL x8000
SQ_S1       .BLKW #1
SQ_S2       .BLKW #1
SQ_S3       .BLKW #1
SQ_S4       .BLKW #1
SQ_S5       .BLKW #1
            .END