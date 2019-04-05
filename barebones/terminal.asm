global _terminalInitialize
global _terminalSetColor
global _terminalPutEntryAt

segment .bss align=16

    align 16
    terminalBuffer resd 1

    align 16
    terminalColor resb 1

    align 16
    terminalColumn resd 1

    align 16
    terminalRow resd 1

segment .text align=16

    align 16
terminalInitialize:
    push ebx
    push ebp
    
    xor edx, edx
    xor ecx, ecx

    mov ebp, 0x720
    mov [terminalRow], edx
    xor eax, eax
    mov [terminalColumn], edx
    mov byte [terminalColor], 7
    mov dword [terminalBuffer], 0xB8000

.loop:
    mov ebx, edx

.loop2:
    mov word [0xB8000 + eax + ebx * 4], bp
    mov word [0xB8002 + eax + ebx * 4], bp

    inc ebx
    cmp ebx, 40
    jb .loop2

    inc ecx
    add eax, 0xA0
    cmp ecx, 0x19
    jb .loop

    pop ebp
    pop ebx
    ret





    align 16
_terminalSetColor:
    mov eax, [esp + 4]
    mov [terminalColor], al
    ret





    align 16
_terminalPutEntryAt:
    mov ecx, [esp + 16]
    mov edx, [esp + 12]
    movzx eax, byte [esp + 4]
    
    lea ecx, [ecx + ecx * 4]
    shl edx, 8
    shl ecx, 4
    or edx, eax

    mov eax, [terminalBuffer]
    add ecx, [esp + 12]
    mov [eax + ecx * 2], dx
    ret
    