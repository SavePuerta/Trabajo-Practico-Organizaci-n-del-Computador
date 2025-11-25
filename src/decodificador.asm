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