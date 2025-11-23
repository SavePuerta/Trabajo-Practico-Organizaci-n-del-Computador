global codificar

section .data
    tabla db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

section .text
codificar:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    ; rdi = input
    ; rsi = input_len
    ; rdx = output

    mov r12, rdi        ; input
    mov r13, rsi        ; len
    mov r14, rdx        ; output
    mov rbx, tabla

    xor rcx, rcx        ; index

.loop:
    cmp rcx, r13
    jge .done

    ;--------------------------------------
    ; Cargar BYTE 1
    ;--------------------------------------
    movzx eax, byte [r12 + rcx]
    inc rcx
    shl eax, 16         ; guardar en los bits altos

    ;--------------------------------------
    ; Cargar BYTE 2 si existe
    ;--------------------------------------
    mov edx, eax        ; backup
    cmp rcx, r13
    jge .one_remaining

    movzx r8d, byte [r12 + rcx]
    inc rcx
    shl r8d, 8
    or eax, r8d

    ;--------------------------------------
    ; Cargar BYTE 3 si existe
    ;--------------------------------------
    cmp rcx, r13
    jge .two_remaining

    movzx r8d, byte [r12 + rcx]
    inc rcx
    or eax, r8d
    jmp .encode_3bytes

;===============================================
; 1 BYTE RESTANTE
;===============================================
.one_remaining:
    ; EAX: XX 00 00 (bits útiles arriba)

    mov r8d, eax
    shr r8d, 18
    and r8d, 0x3F
    mov al, [rbx + r8]
    mov [r14], al
    inc r14

    mov r8d, eax
    shr r8d, 12
    and r8d, 0x3F
    mov al, [rbx + r8]
    mov [r14], al
    inc r14

    mov byte [r14], '='
    inc r14
    mov byte [r14], '='
    inc r14
    jmp .done

;===============================================
; 2 BYTES RESTANTES
;===============================================
.two_remaining:
    ; EAX: XX YY 00

    mov r8d, eax
    shr r8d, 18
    and r8d, 0x3F
    mov al, [rbx + r8]
    mov [r14], al
    inc r14

    mov r8d, eax
    shr r8d, 12
    and r8d, 0x3F
    mov al, [rbx + r8]
    mov [r14], al
    inc r14

    mov r8d, eax
    shr r8d, 6
    and r8d, 0x3F
    mov al, [rbx + r8]
    mov [r14], al
    inc r14

    mov byte [r14], '='
    inc r14
    jmp .done

;===============================================
; 3 BYTES COMPLETOS
;===============================================
.encode_3bytes:
    mov r8d, eax
    shr r8d, 18
    and r8d, 0x3F
    mov al, [rbx + r8]
    mov [r14], al
    inc r14

    mov r8d, eax
    shr r8d, 12
    and r8d, 0x3F
    mov al, [rbx + r8]
    mov [r14], al
    inc r14

    mov r8d, eax
    shr r8d, 6
    and r8d, 0x3F
    mov al, [rbx + r8]
    mov [r14], al
    inc r14

    mov r8d, eax
    and r8d, 0x3F
    mov al, [rbx + r8]
    mov [r14], al
    inc r14

    jmp .loop

.done:
    mov byte [r14], 0

    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
