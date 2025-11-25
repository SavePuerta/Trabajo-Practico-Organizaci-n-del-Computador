section .data
    tablaCodificada: 
        db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    
section .text
    global codificar

codificar:

    mov r8, rdi        ; r8  puntero al input
    mov r9, rdx        ; r9  puntero al output
    mov rcx, rsi       ; rcx  tamaño del input

; Calcular cuántos bloques de 3 bytes hay
    mov rax, rcx
    mov rbx, 3
    xor rdx, rdx
    div rbx            ; rax = bloques de 3, rdx = resto (1 o 2 bytes)

    mov r10, rax       ; bloques de 3
    mov r11, rdx       ; resto (0,1,2) 

procesar_bloques:

    cmp r10, 0
    je procesar_resto

    ; carga 3 bytes
    mov al,  [r8]
    mov bl,  [r8+1]
    mov cl,  [r8+2]

    ; grupos de 6 bits, los g0, g1, g2 y g3
    ; g0 = bits 7..2 del primer byte
    mov edx, eax
    shr edx, 2
    mov dl, [tablaCodificada + rdx]
    mov [r9], dl

    ; g1 = (2 bits del primer byte) y (4 bits altos del segundo byte)
    mov edx, eax
    and edx, 0b00000011
    shl edx, 4
    mov esi, ebx
    shr esi, 4
    or  edx, esi
    mov dl, [tablaCodificada + rdx]
    mov [r9+1], dl

    ; g2 = (4 bits bajos del segundo byte) y (2 bits altos del tercero)
    mov edx, ebx
    and edx, 0b00001111
    shl edx, 2
    mov esi, ecx
    shr esi, 6
    or  edx, esi
    mov dl, [tablaCodificada + rdx]
    mov [r9+2], dl

    ; g3 = últimos 6 bits del tercer byte
    mov edx, ecx
    and edx, 0b00111111
    mov dl, [tablaCodificada + rdx]
    mov [r9+3], dl

    ; se avanza en los punteros de input y output
    ; para seguir con la codificación
    add r8, 3
    add r9, 4

    dec r10
    jmp procesar_bloques


procesar_resto:

    cmp r11, 0
    je fin_codificar

    cmp r11, 1
    je caso_un_byte

    cmp r11, 2
    je caso_dos_bytes



; 1 byte sobrante

caso_un_byte:

    mov al, [r8]

    ; g0 = bits 7..2
    mov edx, eax
    shr edx, 2
    mov dl, [tablaCodificada + rdx]
    mov [r9], dl

    ; g1 = últimos 2 bits << 4
    mov edx, eax
    and edx, 0b00000011
    shl edx, 4
    mov dl, [tablaCodificada + rdx]
    mov [r9+1], dl

    ; llenar los últimos como '='
    mov byte [r9+2], '='
    mov byte [r9+3], '='

    jmp fin_codificar



; 2 bytes sobrantes

caso_dos_bytes:

    mov al, [r8]
    mov bl, [r8+1]

    ; g0
    mov edx, eax
    shr edx, 2
    mov dl, [tablaCodificada + rdx]
    mov [r9], dl

    ; g1
    mov edx, eax
    and edx, 0b00000011
    shl edx, 4
    mov esi, ebx
    shr esi, 4
    or edx, esi
    mov dl, [tablaCodificada + rdx]
    mov [r9+1], dl

    ; g2
    mov edx, ebx
    and edx, 0b00001111
    shl edx, 2
    mov dl, [tablaCodificada + rdx]
    mov [r9+2], dl

    ; último char es '='
    mov byte [r9+3], '='

    jmp fin_codificar


fin_codificar:
    ret