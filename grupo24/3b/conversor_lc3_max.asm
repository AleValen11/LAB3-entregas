; ============================================================
; Conversor decimal -> binario / hexadecimal para LC-3
; Version MAX: conversion totalmente desenrollada, sin JSR/JMP
; ni bucles en las rutinas de salida. Pensada para competencia.
; Los JMP externos solo cruzan el limite de BR de 9 bits; no hay
; JSR, JMP ni bucles dentro de CONV_AMBOS.
; PAUSA: MODO_BENCHMARK=0 la activa; distinto de 0 la omite.
; ============================================================

        .ORIG x3000
        BRnzp MAIN              ; salta sobre los textos y datos

; Textos del programa.
PROMPT_NUMERO          .STRINGZ "Ingresar un numero (-32768 a 32767): " ; pide el numero
MSG_NUMERO_INVALIDO    .STRINGZ "Numero invalido o fuera de rango." ; error de numero
MSG_PAUSA              .STRINGZ "Presione Enter para continuar..." ; espera Enter

; Programa principal: convierte automaticamente a binario y hexadecimal.
MAIN
        LEA R0, PROMPT_NUMERO   ; carga el pedido de numero
        PUTS                    ; lo escribe
        JSR LEER_DECIMAL        ; parsea el numero decimal
        ADD R5, R5, #0          ; mira si fue valido
        BRz NUMERO_INVALIDO     ; numero invalido
        ADD R5, R5, #-2         ; comprueba linea vacia
        BRz FIN_PROGRAMA        ; linea vacia termina
        LD R7, PTR_AMBOS        ; carga la conversion combinada
        JMP R7                  ; salta a la conversion
NUMERO_INVALIDO
        LEA R0, MSG_NUMERO_INVALIDO ; carga mensaje de numero
        PUTS                    ; lo escribe
        LD R0, NL_MAIN          ; carga salto de linea
        OUT                     ; lo escribe
        BRnzp MAIN              ; pide otro numero
FIN_PROGRAMA
        HALT                    ; termina el programa

NL_MAIN                .FILL #10            ; salto de linea
MODO_BENCHMARK         .FILL #0             ; 0 = pausa, distinto de 0 = sin pausa
PTR_AMBOS              .FILL CONV_AMBOS     ; direccion de la conversion combinada

; Parser decimal: R1 = valor, R5 = valido, R2 lleva signo/digitos.
LEER_DECIMAL
        ST R7, SAVE_R7_LEER     ; guarda retorno del parser
        AND R1, R1, #0          ; inicializa resultado
        AND R2, R2, #0          ; inicializa cuenta y signo
        LD R5, NEG_3277         ; carga -3277 para el rango
        LD R6, NEG_ZERO_LEER    ; carga -48
        GETC                    ; lee primer caracter
        OUT                     ; lo ecoa
        LD R3, NEG_MENOS        ; carga -53
        ADD R3, R0, R3          ; compara con menos
        BRnp LEER_SIGNO_MAS     ; si no es menos, prueba mas
        LD R2, PATRON_8000      ; marca el signo negativo
        GETC                    ; lee primer digito
        OUT                     ; lo ecoa
        BRnzp PROCESAR_CARACTER ; procesa el digito
LEER_SIGNO_MAS
        LD R3, NEG_MAS          ; carga -43
        ADD R3, R0, R3          ; compara con mas
        BRnp PROCESAR_CARACTER  ; si no es mas, procesa directo
        GETC                    ; consume el mas
        OUT                     ; lo ecoa
PROCESAR_CARACTER
        ADD R3, R0, R6          ; convierte caracter a digito
        BRn CARACTER_BAJO       ; puede ser Enter u otro bajo
        ADD R4, R3, #-10        ; compara digito con 10
        BRzp CARACTER_INVALIDO  ; digito fuera de rango
        ADD R2, R2, #1          ; cuenta un digito mas
        ADD R4, R1, R5          ; compara valor con 3277
        BRzp CARACTER_INVALIDO  ; se saldria de rango
        ADD R4, R1, R1          ; R4 = valor * 2
        ADD R4, R4, R4          ; R4 = valor * 4
        ADD R4, R4, R1          ; R4 = valor * 5
        ADD R4, R4, R4          ; R4 = valor * 10
        ADD R1, R4, R3          ; suma el nuevo digito
        BRn COMPROBAR_8000      ; solo -32768 puede ser negativo
SIGUIENTE_CARACTER
        GETC                    ; lee siguiente caracter
        OUT                     ; lo ecoa
        BRnzp PROCESAR_CARACTER ; vuelve a procesar
CARACTER_BAJO
        ADD R4, R0, #-10        ; compara con Enter
        BRz FIN_LEER_DECIMAL    ; fin de la linea
        BRnzp CARACTER_INVALIDO ; caracter no valido
COMPROBAR_8000
        LD R4, PATRON_8000      ; carga x8000
        ADD R4, R1, R4          ; comprueba si es x8000
        BRnp CARACTER_INVALIDO  ; otro negativo es invalido
        ADD R4, R2, #0          ; mira el signo
        BRzp CARACTER_INVALIDO  ; x8000 positivo es invalido
        BRnzp SIGUIENTE_CARACTER ; x8000 negativo es valido
CARACTER_INVALIDO
        AND R2, R2, #0          ; limpia la cuenta
        ADD R2, R2, #-1         ; marca error con -1
CONSUMIR_RESTO
        ADD R4, R0, #-10        ; comprueba fin de linea
        BRz FIN_LEER_DECIMAL    ; termina de consumir
        GETC                    ; lee siguiente caracter
        OUT                     ; lo ecoa
        BRnzp CONSUMIR_RESTO    ; sigue consumiendo
FIN_LEER_DECIMAL
        ADD R4, R2, #0          ; mira la cuenta o el signo
        BRz DECIMAL_VACIO       ; linea sin digitos
        ADD R4, R2, #1          ; comprueba marca de error
        BRz DECIMAL_INVALIDO    ; entrada invalida
        BRp DECIMAL_VALIDO      ; positivo con digitos
        LD R4, PATRON_8000      ; carga x8000
        ADD R4, R2, R4          ; comprueba signo sin digitos
        BRz DECIMAL_INVALIDO    ; menos sin digitos
        NOT R1, R1              ; complementa el valor
        ADD R1, R1, #1          ; termina complemento a dos
        BRnzp DECIMAL_VALIDO    ; resultado negativo listo
DECIMAL_VACIO
        AND R5, R5, #0          ; prepara fin por linea vacia
        ADD R5, R5, #2          ; marca salida del programa
        BRnzp FIN_LEER_OK       ; termina el parser
DECIMAL_VALIDO
        AND R5, R5, #0          ; prepara validez
        ADD R5, R5, #1          ; marca valido
        BRnzp FIN_LEER_OK       ; termina
DECIMAL_INVALIDO
        AND R5, R5, #0          ; marca invalido
FIN_LEER_OK
        LD R7, SAVE_R7_LEER     ; recupera retorno
        JMP R7                  ; vuelve al programa principal

SAVE_R7_LEER           .FILL #0             ; retorno del parser
NEG_ZERO_LEER          .FILL xFFD0          ; -48
NEG_MENOS              .FILL xFFD3          ; -53
NEG_MAS                .FILL xFFD5          ; -43
NEG_3277               .FILL xF333          ; -3277
PATRON_8000            .FILL x8000          ; patron -32768

; Salida combinada: calcula cada nibble una sola vez.
CONV_AMBOS
        LEA R0, AMBL_BIN        ; carga etiqueta binaria
        PUTS                    ; la escribe
        LEA R4, BUF_HEX         ; apunta al buffer hexadecimal
        ADD R2, R1, #0          ; copia el valor y fija banderas
        BRn A0_1                ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A0_01               ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A0_001              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A0_0001             ; si el bit alto es 1, va a la rama alta
        LEA R0, T0BSTR_0000     ; cadena binaria 0000
        LD R3, T0HEX_0          ; caracter hexadecimal 0
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_0001
        LEA R0, T0BSTR_0001     ; cadena binaria 0001
        LD R3, T0HEX_1          ; caracter hexadecimal 1
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_001
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A0_0011             ; si el bit alto es 1, va a la rama alta
        LEA R0, T0BSTR_0010     ; cadena binaria 0010
        LD R3, T0HEX_2          ; caracter hexadecimal 2
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_0011
        LEA R0, T0BSTR_0011     ; cadena binaria 0011
        LD R3, T0HEX_3          ; caracter hexadecimal 3
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_01
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A0_011              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A0_0101             ; si el bit alto es 1, va a la rama alta
        LEA R0, T0BSTR_0100     ; cadena binaria 0100
        LD R3, T0HEX_4          ; caracter hexadecimal 4
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_0101
        LEA R0, T0BSTR_0101     ; cadena binaria 0101
        LD R3, T0HEX_5          ; caracter hexadecimal 5
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_011
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A0_0111             ; si el bit alto es 1, va a la rama alta
        LEA R0, T0BSTR_0110     ; cadena binaria 0110
        LD R3, T0HEX_6          ; caracter hexadecimal 6
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_0111
        LEA R0, T0BSTR_0111     ; cadena binaria 0111
        LD R3, T0HEX_7          ; caracter hexadecimal 7
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_1
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A0_11               ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A0_101              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A0_1001             ; si el bit alto es 1, va a la rama alta
        LEA R0, T0BSTR_1000     ; cadena binaria 1000
        LD R3, T0HEX_8          ; caracter hexadecimal 8
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_1001
        LEA R0, T0BSTR_1001     ; cadena binaria 1001
        LD R3, T0HEX_9          ; caracter hexadecimal 9
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_101
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A0_1011             ; si el bit alto es 1, va a la rama alta
        LEA R0, T0BSTR_1010     ; cadena binaria 1010
        LD R3, T0HEX_10         ; caracter hexadecimal A
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_1011
        LEA R0, T0BSTR_1011     ; cadena binaria 1011
        LD R3, T0HEX_11         ; caracter hexadecimal B
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_11
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A0_111              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A0_1101             ; si el bit alto es 1, va a la rama alta
        LEA R0, T0BSTR_1100     ; cadena binaria 1100
        LD R3, T0HEX_12         ; caracter hexadecimal C
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_1101
        LEA R0, T0BSTR_1101     ; cadena binaria 1101
        LD R3, T0HEX_13         ; caracter hexadecimal D
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_111
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A0_1111             ; si el bit alto es 1, va a la rama alta
        LEA R0, T0BSTR_1110     ; cadena binaria 1110
        LD R3, T0HEX_14         ; caracter hexadecimal E
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_1111
        LEA R0, T0BSTR_1111     ; cadena binaria 1111
        LD R3, T0HEX_15         ; caracter hexadecimal F
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A0_OUT            ; imprime el binario de este nibble
A0_OUT
        PUTS                    ; escribe nibble binario 0
        ADD R4, R4, #1          ; avanza el buffer hexadecimal
        ADD R2, R2, R2          ; pasa al nibble 1
        BRnzp A1_START          ; salta la tabla del nibble 0

; Tabla local del nibble 0.
BUF_HEX                .FILL #0             ; caracter hex 0
                       .FILL #0             ; caracter hex 1
                       .FILL #0             ; caracter hex 2
                       .FILL #0             ; caracter hex 3
AMBL_BIN               .STRINGZ "Binario: " ; etiqueta binaria combinada
T0BSTR_0000            .STRINGZ "0000"      ; nibble binario 0000
T0BSTR_0001            .STRINGZ "0001"      ; nibble binario 0001
T0BSTR_0010            .STRINGZ "0010"      ; nibble binario 0010
T0BSTR_0011            .STRINGZ "0011"      ; nibble binario 0011
T0BSTR_0100            .STRINGZ "0100"      ; nibble binario 0100
T0BSTR_0101            .STRINGZ "0101"      ; nibble binario 0101
T0BSTR_0110            .STRINGZ "0110"      ; nibble binario 0110
T0BSTR_0111            .STRINGZ "0111"      ; nibble binario 0111
T0BSTR_1000            .STRINGZ "1000"      ; nibble binario 1000
T0BSTR_1001            .STRINGZ "1001"      ; nibble binario 1001
T0BSTR_1010            .STRINGZ "1010"      ; nibble binario 1010
T0BSTR_1011            .STRINGZ "1011"      ; nibble binario 1011
T0BSTR_1100            .STRINGZ "1100"      ; nibble binario 1100
T0BSTR_1101            .STRINGZ "1101"      ; nibble binario 1101
T0BSTR_1110            .STRINGZ "1110"      ; nibble binario 1110
T0BSTR_1111            .STRINGZ "1111"      ; nibble binario 1111
T0HEX_0                .FILL #48            ; ASCII hex 0
T0HEX_1                .FILL #49            ; ASCII hex 1
T0HEX_2                .FILL #50            ; ASCII hex 2
T0HEX_3                .FILL #51            ; ASCII hex 3
T0HEX_4                .FILL #52            ; ASCII hex 4
T0HEX_5                .FILL #53            ; ASCII hex 5
T0HEX_6                .FILL #54            ; ASCII hex 6
T0HEX_7                .FILL #55            ; ASCII hex 7
T0HEX_8                .FILL #56            ; ASCII hex 8
T0HEX_9                .FILL #57            ; ASCII hex 9
T0HEX_10               .FILL #65            ; ASCII hex A
T0HEX_11               .FILL #66            ; ASCII hex B
T0HEX_12               .FILL #67            ; ASCII hex C
T0HEX_13               .FILL #68            ; ASCII hex D
T0HEX_14               .FILL #69            ; ASCII hex E
T0HEX_15               .FILL #70            ; ASCII hex F

A1_START
        BRn A1_1                ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A1_01               ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A1_001              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A1_0001             ; si el bit alto es 1, va a la rama alta
        LEA R0, T1BSTR_0000     ; cadena binaria 0000
        LD R3, T1HEX_0          ; caracter hexadecimal 0
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_0001
        LEA R0, T1BSTR_0001     ; cadena binaria 0001
        LD R3, T1HEX_1          ; caracter hexadecimal 1
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_001
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A1_0011             ; si el bit alto es 1, va a la rama alta
        LEA R0, T1BSTR_0010     ; cadena binaria 0010
        LD R3, T1HEX_2          ; caracter hexadecimal 2
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_0011
        LEA R0, T1BSTR_0011     ; cadena binaria 0011
        LD R3, T1HEX_3          ; caracter hexadecimal 3
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_01
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A1_011              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A1_0101             ; si el bit alto es 1, va a la rama alta
        LEA R0, T1BSTR_0100     ; cadena binaria 0100
        LD R3, T1HEX_4          ; caracter hexadecimal 4
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_0101
        LEA R0, T1BSTR_0101     ; cadena binaria 0101
        LD R3, T1HEX_5          ; caracter hexadecimal 5
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_011
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A1_0111             ; si el bit alto es 1, va a la rama alta
        LEA R0, T1BSTR_0110     ; cadena binaria 0110
        LD R3, T1HEX_6          ; caracter hexadecimal 6
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_0111
        LEA R0, T1BSTR_0111     ; cadena binaria 0111
        LD R3, T1HEX_7          ; caracter hexadecimal 7
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_1
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A1_11               ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A1_101              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A1_1001             ; si el bit alto es 1, va a la rama alta
        LEA R0, T1BSTR_1000     ; cadena binaria 1000
        LD R3, T1HEX_8          ; caracter hexadecimal 8
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_1001
        LEA R0, T1BSTR_1001     ; cadena binaria 1001
        LD R3, T1HEX_9          ; caracter hexadecimal 9
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_101
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A1_1011             ; si el bit alto es 1, va a la rama alta
        LEA R0, T1BSTR_1010     ; cadena binaria 1010
        LD R3, T1HEX_10         ; caracter hexadecimal A
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_1011
        LEA R0, T1BSTR_1011     ; cadena binaria 1011
        LD R3, T1HEX_11         ; caracter hexadecimal B
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_11
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A1_111              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A1_1101             ; si el bit alto es 1, va a la rama alta
        LEA R0, T1BSTR_1100     ; cadena binaria 1100
        LD R3, T1HEX_12         ; caracter hexadecimal C
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_1101
        LEA R0, T1BSTR_1101     ; cadena binaria 1101
        LD R3, T1HEX_13         ; caracter hexadecimal D
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_111
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A1_1111             ; si el bit alto es 1, va a la rama alta
        LEA R0, T1BSTR_1110     ; cadena binaria 1110
        LD R3, T1HEX_14         ; caracter hexadecimal E
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_1111
        LEA R0, T1BSTR_1111     ; cadena binaria 1111
        LD R3, T1HEX_15         ; caracter hexadecimal F
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A1_OUT            ; imprime el binario de este nibble
A1_OUT
        PUTS                    ; escribe nibble binario 1
        ADD R4, R4, #1          ; avanza el buffer hexadecimal
        ADD R2, R2, R2          ; pasa al nibble 2
        BRnzp A2_START          ; salta la tabla del nibble 1

; Tabla local del nibble 1.
T1BSTR_0000            .STRINGZ "0000"      ; nibble binario 0000
T1BSTR_0001            .STRINGZ "0001"      ; nibble binario 0001
T1BSTR_0010            .STRINGZ "0010"      ; nibble binario 0010
T1BSTR_0011            .STRINGZ "0011"      ; nibble binario 0011
T1BSTR_0100            .STRINGZ "0100"      ; nibble binario 0100
T1BSTR_0101            .STRINGZ "0101"      ; nibble binario 0101
T1BSTR_0110            .STRINGZ "0110"      ; nibble binario 0110
T1BSTR_0111            .STRINGZ "0111"      ; nibble binario 0111
T1BSTR_1000            .STRINGZ "1000"      ; nibble binario 1000
T1BSTR_1001            .STRINGZ "1001"      ; nibble binario 1001
T1BSTR_1010            .STRINGZ "1010"      ; nibble binario 1010
T1BSTR_1011            .STRINGZ "1011"      ; nibble binario 1011
T1BSTR_1100            .STRINGZ "1100"      ; nibble binario 1100
T1BSTR_1101            .STRINGZ "1101"      ; nibble binario 1101
T1BSTR_1110            .STRINGZ "1110"      ; nibble binario 1110
T1BSTR_1111            .STRINGZ "1111"      ; nibble binario 1111
T1HEX_0                .FILL #48            ; ASCII hex 0
T1HEX_1                .FILL #49            ; ASCII hex 1
T1HEX_2                .FILL #50            ; ASCII hex 2
T1HEX_3                .FILL #51            ; ASCII hex 3
T1HEX_4                .FILL #52            ; ASCII hex 4
T1HEX_5                .FILL #53            ; ASCII hex 5
T1HEX_6                .FILL #54            ; ASCII hex 6
T1HEX_7                .FILL #55            ; ASCII hex 7
T1HEX_8                .FILL #56            ; ASCII hex 8
T1HEX_9                .FILL #57            ; ASCII hex 9
T1HEX_10               .FILL #65            ; ASCII hex A
T1HEX_11               .FILL #66            ; ASCII hex B
T1HEX_12               .FILL #67            ; ASCII hex C
T1HEX_13               .FILL #68            ; ASCII hex D
T1HEX_14               .FILL #69            ; ASCII hex E
T1HEX_15               .FILL #70            ; ASCII hex F

A2_START
        BRn A2_1                ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A2_01               ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A2_001              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A2_0001             ; si el bit alto es 1, va a la rama alta
        LEA R0, T2BSTR_0000     ; cadena binaria 0000
        LD R3, T2HEX_0          ; caracter hexadecimal 0
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_0001
        LEA R0, T2BSTR_0001     ; cadena binaria 0001
        LD R3, T2HEX_1          ; caracter hexadecimal 1
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_001
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A2_0011             ; si el bit alto es 1, va a la rama alta
        LEA R0, T2BSTR_0010     ; cadena binaria 0010
        LD R3, T2HEX_2          ; caracter hexadecimal 2
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_0011
        LEA R0, T2BSTR_0011     ; cadena binaria 0011
        LD R3, T2HEX_3          ; caracter hexadecimal 3
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_01
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A2_011              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A2_0101             ; si el bit alto es 1, va a la rama alta
        LEA R0, T2BSTR_0100     ; cadena binaria 0100
        LD R3, T2HEX_4          ; caracter hexadecimal 4
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_0101
        LEA R0, T2BSTR_0101     ; cadena binaria 0101
        LD R3, T2HEX_5          ; caracter hexadecimal 5
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_011
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A2_0111             ; si el bit alto es 1, va a la rama alta
        LEA R0, T2BSTR_0110     ; cadena binaria 0110
        LD R3, T2HEX_6          ; caracter hexadecimal 6
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_0111
        LEA R0, T2BSTR_0111     ; cadena binaria 0111
        LD R3, T2HEX_7          ; caracter hexadecimal 7
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_1
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A2_11               ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A2_101              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A2_1001             ; si el bit alto es 1, va a la rama alta
        LEA R0, T2BSTR_1000     ; cadena binaria 1000
        LD R3, T2HEX_8          ; caracter hexadecimal 8
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_1001
        LEA R0, T2BSTR_1001     ; cadena binaria 1001
        LD R3, T2HEX_9          ; caracter hexadecimal 9
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_101
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A2_1011             ; si el bit alto es 1, va a la rama alta
        LEA R0, T2BSTR_1010     ; cadena binaria 1010
        LD R3, T2HEX_10         ; caracter hexadecimal A
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_1011
        LEA R0, T2BSTR_1011     ; cadena binaria 1011
        LD R3, T2HEX_11         ; caracter hexadecimal B
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_11
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A2_111              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A2_1101             ; si el bit alto es 1, va a la rama alta
        LEA R0, T2BSTR_1100     ; cadena binaria 1100
        LD R3, T2HEX_12         ; caracter hexadecimal C
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_1101
        LEA R0, T2BSTR_1101     ; cadena binaria 1101
        LD R3, T2HEX_13         ; caracter hexadecimal D
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_111
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A2_1111             ; si el bit alto es 1, va a la rama alta
        LEA R0, T2BSTR_1110     ; cadena binaria 1110
        LD R3, T2HEX_14         ; caracter hexadecimal E
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_1111
        LEA R0, T2BSTR_1111     ; cadena binaria 1111
        LD R3, T2HEX_15         ; caracter hexadecimal F
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A2_OUT            ; imprime el binario de este nibble
A2_OUT
        PUTS                    ; escribe nibble binario 2
        ADD R4, R4, #1          ; avanza el buffer hexadecimal
        ADD R2, R2, R2          ; pasa al nibble 3
        BRnzp A3_START          ; salta la tabla del nibble 2

; Tabla local del nibble 2.
T2BSTR_0000            .STRINGZ "0000"      ; nibble binario 0000
T2BSTR_0001            .STRINGZ "0001"      ; nibble binario 0001
T2BSTR_0010            .STRINGZ "0010"      ; nibble binario 0010
T2BSTR_0011            .STRINGZ "0011"      ; nibble binario 0011
T2BSTR_0100            .STRINGZ "0100"      ; nibble binario 0100
T2BSTR_0101            .STRINGZ "0101"      ; nibble binario 0101
T2BSTR_0110            .STRINGZ "0110"      ; nibble binario 0110
T2BSTR_0111            .STRINGZ "0111"      ; nibble binario 0111
T2BSTR_1000            .STRINGZ "1000"      ; nibble binario 1000
T2BSTR_1001            .STRINGZ "1001"      ; nibble binario 1001
T2BSTR_1010            .STRINGZ "1010"      ; nibble binario 1010
T2BSTR_1011            .STRINGZ "1011"      ; nibble binario 1011
T2BSTR_1100            .STRINGZ "1100"      ; nibble binario 1100
T2BSTR_1101            .STRINGZ "1101"      ; nibble binario 1101
T2BSTR_1110            .STRINGZ "1110"      ; nibble binario 1110
T2BSTR_1111            .STRINGZ "1111"      ; nibble binario 1111
T2HEX_0                .FILL #48            ; ASCII hex 0
T2HEX_1                .FILL #49            ; ASCII hex 1
T2HEX_2                .FILL #50            ; ASCII hex 2
T2HEX_3                .FILL #51            ; ASCII hex 3
T2HEX_4                .FILL #52            ; ASCII hex 4
T2HEX_5                .FILL #53            ; ASCII hex 5
T2HEX_6                .FILL #54            ; ASCII hex 6
T2HEX_7                .FILL #55            ; ASCII hex 7
T2HEX_8                .FILL #56            ; ASCII hex 8
T2HEX_9                .FILL #57            ; ASCII hex 9
T2HEX_10               .FILL #65            ; ASCII hex A
T2HEX_11               .FILL #66            ; ASCII hex B
T2HEX_12               .FILL #67            ; ASCII hex C
T2HEX_13               .FILL #68            ; ASCII hex D
T2HEX_14               .FILL #69            ; ASCII hex E
T2HEX_15               .FILL #70            ; ASCII hex F

A3_START
        BRn A3_1                ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A3_01               ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A3_001              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A3_0001             ; si el bit alto es 1, va a la rama alta
        LEA R0, T3BSTR_0000     ; cadena binaria 0000
        LD R3, T3HEX_0          ; caracter hexadecimal 0
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_0001
        LEA R0, T3BSTR_0001     ; cadena binaria 0001
        LD R3, T3HEX_1          ; caracter hexadecimal 1
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_001
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A3_0011             ; si el bit alto es 1, va a la rama alta
        LEA R0, T3BSTR_0010     ; cadena binaria 0010
        LD R3, T3HEX_2          ; caracter hexadecimal 2
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_0011
        LEA R0, T3BSTR_0011     ; cadena binaria 0011
        LD R3, T3HEX_3          ; caracter hexadecimal 3
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_01
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A3_011              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A3_0101             ; si el bit alto es 1, va a la rama alta
        LEA R0, T3BSTR_0100     ; cadena binaria 0100
        LD R3, T3HEX_4          ; caracter hexadecimal 4
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_0101
        LEA R0, T3BSTR_0101     ; cadena binaria 0101
        LD R3, T3HEX_5          ; caracter hexadecimal 5
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_011
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A3_0111             ; si el bit alto es 1, va a la rama alta
        LEA R0, T3BSTR_0110     ; cadena binaria 0110
        LD R3, T3HEX_6          ; caracter hexadecimal 6
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_0111
        LEA R0, T3BSTR_0111     ; cadena binaria 0111
        LD R3, T3HEX_7          ; caracter hexadecimal 7
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_1
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A3_11               ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A3_101              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A3_1001             ; si el bit alto es 1, va a la rama alta
        LEA R0, T3BSTR_1000     ; cadena binaria 1000
        LD R3, T3HEX_8          ; caracter hexadecimal 8
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_1001
        LEA R0, T3BSTR_1001     ; cadena binaria 1001
        LD R3, T3HEX_9          ; caracter hexadecimal 9
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_101
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A3_1011             ; si el bit alto es 1, va a la rama alta
        LEA R0, T3BSTR_1010     ; cadena binaria 1010
        LD R3, T3HEX_10         ; caracter hexadecimal A
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_1011
        LEA R0, T3BSTR_1011     ; cadena binaria 1011
        LD R3, T3HEX_11         ; caracter hexadecimal B
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_11
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A3_111              ; si el bit alto es 1, va a la rama alta
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A3_1101             ; si el bit alto es 1, va a la rama alta
        LEA R0, T3BSTR_1100     ; cadena binaria 1100
        LD R3, T3HEX_12         ; caracter hexadecimal C
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_1101
        LEA R0, T3BSTR_1101     ; cadena binaria 1101
        LD R3, T3HEX_13         ; caracter hexadecimal D
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_111
        ADD R2, R2, R2          ; desplaza al siguiente bit
        BRn A3_1111             ; si el bit alto es 1, va a la rama alta
        LEA R0, T3BSTR_1110     ; cadena binaria 1110
        LD R3, T3HEX_14         ; caracter hexadecimal E
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_1111
        LEA R0, T3BSTR_1111     ; cadena binaria 1111
        LD R3, T3HEX_15         ; caracter hexadecimal F
        STR R3, R4, #0          ; guarda el hex para la segunda linea
        BRnzp A3_OUT            ; imprime el binario de este nibble
A3_OUT
        PUTS                    ; escribe nibble binario 3
        LD R0, AMNL             ; carga salto de linea
        OUT                     ; lo escribe
        LEA R0, AMBL_HEX        ; carga etiqueta hexadecimal
        PUTS                    ; la escribe
        LDR R0, R4, #-3         ; recupera caracter hex 0
        OUT                     ; lo escribe
        LDR R0, R4, #-2         ; recupera caracter hex 1
        OUT                     ; lo escribe
        LDR R0, R4, #-1         ; recupera caracter hex 2
        OUT                     ; lo escribe
        LDR R0, R4, #0          ; recupera caracter hex 3
        OUT                     ; lo escribe
        LD R0, AMNL             ; carga salto de linea final
        OUT                     ; lo escribe
        BRnzp FIN_AMBOS         ; termina la conversion combinada

; Tabla local del ultimo nibble.
AMBL_HEX               .STRINGZ "Hexadecimal: " ; etiqueta hexadecimal combinada
T3BSTR_0000            .STRINGZ "0000"      ; nibble binario 0000
T3BSTR_0001            .STRINGZ "0001"      ; nibble binario 0001
T3BSTR_0010            .STRINGZ "0010"      ; nibble binario 0010
T3BSTR_0011            .STRINGZ "0011"      ; nibble binario 0011
T3BSTR_0100            .STRINGZ "0100"      ; nibble binario 0100
T3BSTR_0101            .STRINGZ "0101"      ; nibble binario 0101
T3BSTR_0110            .STRINGZ "0110"      ; nibble binario 0110
T3BSTR_0111            .STRINGZ "0111"      ; nibble binario 0111
T3BSTR_1000            .STRINGZ "1000"      ; nibble binario 1000
T3BSTR_1001            .STRINGZ "1001"      ; nibble binario 1001
T3BSTR_1010            .STRINGZ "1010"      ; nibble binario 1010
T3BSTR_1011            .STRINGZ "1011"      ; nibble binario 1011
T3BSTR_1100            .STRINGZ "1100"      ; nibble binario 1100
T3BSTR_1101            .STRINGZ "1101"      ; nibble binario 1101
T3BSTR_1110            .STRINGZ "1110"      ; nibble binario 1110
T3BSTR_1111            .STRINGZ "1111"      ; nibble binario 1111
T3HEX_0                .FILL #48            ; ASCII hex 0
T3HEX_1                .FILL #49            ; ASCII hex 1
T3HEX_2                .FILL #50            ; ASCII hex 2
T3HEX_3                .FILL #51            ; ASCII hex 3
T3HEX_4                .FILL #52            ; ASCII hex 4
T3HEX_5                .FILL #53            ; ASCII hex 5
T3HEX_6                .FILL #54            ; ASCII hex 6
T3HEX_7                .FILL #55            ; ASCII hex 7
T3HEX_8                .FILL #56            ; ASCII hex 8
T3HEX_9                .FILL #57            ; ASCII hex 9
T3HEX_10               .FILL #65            ; ASCII hex A
T3HEX_11               .FILL #66            ; ASCII hex B
T3HEX_12               .FILL #67            ; ASCII hex C
T3HEX_13               .FILL #68            ; ASCII hex D
T3HEX_14               .FILL #69            ; ASCII hex E
T3HEX_15               .FILL #70            ; ASCII hex F
AMNL                   .FILL #10            ; salto de linea combinado


FIN_AMBOS
        LDI R0, FLAG_PTR_A      ; carga la bandera de pausa
        BRnp SKIP_PAUSA_A       ; si es benchmark, la omite
        LD R0, MSG_PTR_A        ; carga el mensaje de pausa
        PUTS                    ; lo escribe
LOOP_PAUSA_A
        GETC                    ; espera un caracter
        OUT                     ; lo ecoa
        ADD R0, R0, #-10        ; comprueba Enter
        BRnp LOOP_PAUSA_A       ; repite hasta Enter
SKIP_PAUSA_A
        LD R7, MAIN_PTR_A       ; carga retorno al menu
        JMP R7                  ; vuelve al menu
FLAG_PTR_A             .FILL MODO_BENCHMARK ; puntero local a la bandera
MSG_PTR_A              .FILL MSG_PAUSA     ; puntero local al mensaje
MAIN_PTR_A             .FILL MAIN           ; retorno local de combinada

        .END
