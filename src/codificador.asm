section .data
    tabla db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    
section .text
global codificar

codificar:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    
    ; rdi = input, rsi = input_len, rdx = output
    mov r12, rdi        ; input pointer
    mov r13, rsi        ; input length
    mov r14, rdx        ; output pointer
    
    mov rbx, tabla
    
    xor rcx, rcx        ; contador de bytes procesados
    
.encode_loop:
    cmp rcx, r13
    jge .encode_done
    
    ; Cargar 3 bytes
    xor rax, rax
    mov al, [r12 + rcx]
    shl eax, 16
    inc rcx
    cmp rcx, r13
    jge .load_remaining
    
    mov eax, [r12 + rcx]
    inc rcx
    cmp rcx, r13
    jge .load_remaining
    
    mov al, [r12 + rcx]
    inc rcx
    jmp .encode_triplet
    
.load_remaining:
    ; Manejar bytes restantes
    cmp rcx, r13
    je .one_byte_remaining
    jmp .two_bytes_remaining

.one_byte_remaining:
    ; Solo queda 1 byte
    shr eax, 8
    mov r8, rax
    and r8, 0x3F
    mov cl, [rbx + r8]
    mov [r14], cl
    inc r14
    
    mov r8, rax
    shr r8, 6
    and r8, 0x3F
    mov cl, [rbx + r8]
    mov [r14], cl
    inc r14
    
    mov byte [r14], '='
    inc r14
    mov byte [r14], '='
    inc r14
    jmp .encode_done

.two_bytes_remaining:
    ; Quedan 2 bytes
    shr eax, 8
    mov r8, rax
    and r8, 0x3F
    mov cl, [rbx + r8]
    mov [r14], cl
    inc r14
    
    mov r8, rax
    shr r8, 6
    and r8, 0x3F
    mov cl, [rbx + r8]
    mov [r14], cl
    inc r14
    
    mov r8, rax
    shr r8, 12
    and r8, 0x3F
    mov cl, [rbx + r8]
    mov [r14], cl
    inc r14
    
    mov byte [r14], '='
    inc r14
    jmp .encode_done

.encode_triplet:
    ; Codificar 3 bytes completos
    bswap eax           ; Reordenar bytes para procesamiento
    
    ; Primer caracter (6 bits superiores)
    mov r8, rax
    shr r8, 26
    and r8, 0x3F
    mov cl, [rbx + r8]
    mov [r14], cl
    inc r14
    
    ; Segundo caracter (siguientes 6 bits)
    mov r8, rax
    shr r8, 20
    and r8, 0x3F
    mov cl, [rbx + r8]
    mov [r14], cl
    inc r14
    
    ; Tercer caracter (siguientes 6 bits)
    mov r8, rax
    shr r8, 14
    and r8, 0x3F
    mov cl, [rbx + r8]
    mov [r14], cl
    inc r14
    
    ; Cuarto caracter (6 bits inferiores)
    mov r8, rax
    shr r8, 8
    and r8, 0x3F
    mov cl, [rbx + r8]
    mov [r14], cl
    inc r14
    
    jmp .encode_loop

.encode_done:
    mov byte [r14], 0   ; Null terminator
    
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


