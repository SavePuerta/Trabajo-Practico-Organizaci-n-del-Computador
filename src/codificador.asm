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
    push r15
    
    ; rdi = input, rsi = input_len, rdx = output
    mov r12, rdi        ; input pointer
    mov r13, rsi        ; input length
    mov r14, rdx        ; output pointer
    mov rbx, tabla
    xor rcx, rcx        ; contador de bytes procesados

.encode_loop:
    cmp rcx, r13
    jge .encode_done
    
    ; Cargar 3 bytes de manera segura
    xor eax, eax
    mov al, [r12 + rcx]
    shl eax, 16
    inc rcx
    cmp rcx, r13
    jge .load_remaining
    
    mov al, [r12 + rcx]
    shl eax, 8
    inc rcx
    cmp rcx, r13
    jge .load_remaining
    
    mov al, [r12 + rcx]
    inc rcx
    
.encode_triplet:
    ; Reordenar bytes (big-endian)
    bswap eax
    shr eax, 8
    
    ; Extraer los 4 grupos de 6 bits
    mov r8, rax
    shr r8, 18
    and r8, 0x3F
    mov r15b, [rbx + r8]
    mov [r14], r15b
    inc r14
    
    mov r8, rax
    shr r8, 12
    and r8, 0x3F
    mov r15b, [rbx + r8]
    mov [r14], r15b
    inc r14
    
    mov r8, rax
    shr r8, 6
    and r8, 0x3F
    mov r15b, [rbx + r8]
    mov [r14], r15b
    inc r14
    
    mov r8, rax
    and r8, 0x3F
    mov r15b, [rbx + r8]
    mov [r14], r15b
    inc r14
    
    jmp .encode_loop

.load_remaining:
    cmp rcx, r13
    je .one_byte_remaining
    
.two_bytes_remaining:
    ; 2 bytes restantes
    bswap eax
    shr eax, 8
    
    mov r8, rax
    shr r8, 18
    and r8, 0x3F
    mov r15b, [rbx + r8]
    mov [r14], r15b
    inc r14
    
    mov r8, rax
    shr r8, 12
    and r8, 0x3F
    mov r15b, [rbx + r8]
    mov [r14], r15b
    inc r14
    
    mov r8, rax
    shr r8, 6
    and r8, 0x3F
    mov r15b, [rbx + r8]
    mov [r14], r15b
    inc r14
    
    mov byte [r14], '='
    inc r14
    jmp .encode_done

.one_byte_remaining:
    ; 1 byte restante
    bswap eax
    shr eax, 8
    
    mov r8, rax
    shr r8, 18
    and r8, 0x3F
    mov r15b, [rbx + r8]
    mov [r14], r15b
    inc r14
    
    mov r8, rax
    shr r8, 12
    and r8, 0x3F
    mov r15b, [rbx + r8]
    mov [r14], r15b
    inc r14
    
    mov byte [r14], '='
    inc r14
    mov byte [r14], '='
    inc r14

.encode_done:
    mov byte [r14], 0   ; Null terminator
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret