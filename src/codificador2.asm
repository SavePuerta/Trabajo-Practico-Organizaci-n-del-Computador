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

section .data
    tablaDecodificada:
        db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
        db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
        db 255,255,255,255,255,255,255,255,255,255,255,62,255,255,255,63
        db 52,53,54,55,56,57,58,59,60,61,255,255,255,254,255,255
        db 255,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
        db 15,16,17,18,19,20,21,22,23,24,25,255,255,255,255,255
        db 255,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40
        db 41,42,43,44,45,46,47,48,49,50,51,255,255,255,255,255

section .text
    global decodificar

decodificar:
    sub rsp, 4096         ; Reserva espacio en la pila
    mov r8, rdi        ; input
    mov r9, rsi        ; input_size
    mov r10, rdx       ; output
    xor r11, r11       ; index input
    xor r12, r12       ; index output

decode_loop:
    cmp r11, r9
    jae end_decode

    movzx eax, byte [r8 + r11]
    cmp al, '='
    je padding

    movzx ebx, byte [tablaDecodificada + rax]
    cmp bl, 255
    je skip_invalid

    mov [rsp + r12], bl
    inc r12

skip_invalid:
    inc r11
    jmp decode_loop

padding:
    ; termina el procesamiento en padding
    jmp end_decode

end_decode:
    ; r12 = cantidad de bytes decodificados
    ; reconstruir los bytes originales de cada grupo de 4
    xor r11, r11
    xor r13, r13

rebuild_loop:
    cmp r11, r12
    jb process_group
    jmp finish

process_group:
    mov al, [rsp + r11]
    mov bl, [rsp + r11 + 1]
    mov cl, [rsp + r11 + 2]
    mov dl, [rsp + r11 + 3]

    ; byte 1
    mov esi, eax
    shl esi, 2
    mov edi, ebx
    shr edi, 4
    or esi, edi
    mov [r10 + r13], sil

    ; byte 2
    mov esi, ebx
    and esi, 0x0F
    shl esi, 4
    mov edi, ecx
    shr edi, 2
    or esi, edi
    mov [r10 + r13 + 1], sil

    ; byte 3
    mov esi, ecx
    and esi, 0x03
    shl esi, 6
    mov edi, edx
    or esi, edi
    mov [r10 + r13 + 2], sil

    add r11, 4
    add r13, 3
    jmp rebuild_loop

finish:
    add rsp, 4096         ; Libera espacio antes de retornar
    ret