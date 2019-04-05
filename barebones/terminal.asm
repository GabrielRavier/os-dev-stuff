global _terminalInitialize
global _terminalSetColor
global _terminalPutEntryAt
global _terminalPutChar
global _terminalWrite
global _terminalWriteString
extern _strlen

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
    




    align 16
_terminalPutChar:
    sub esp, 12
    mov al, [esp + 16]

    cmp al, 10  ; newline
    je .endLine

    movzx ecx, byte [terminalColor]
    movsx eax, al

    push dword [terminalRow]
    push dword [terminalColumn]
    push ecx
    push eax
    call _terminalPutEntryAt
    add esp, 16

    mov eax, [terminalColumn]
    inc eax
    cmp eax, 80
    mov [terminalColumn], eax
    jne .return

.endLine:
    mov eax, [terminalRow]
    xor ecx, ecx
    mov dword [terminalColumn], 0
    inc eax
    cmp eax, 25
    cmovne ecx, eax
    mov [terminalRow], ecx

.return:
    add esp, 12
    ret





    align 16
_terminalWrite:
    push edi
    push esi
    push eax
    mov esi, [esp + 20]

    test esi, esi
    je .return

    mov edi, [esp + 16]

.loop:
    movsx eax, byte [edi]
    mov [esp], eax
    call _terminalPutChar

    inc edi
    dec esi
    jne .loop

.return:
    add esp, 4
    pop esi
    pop edi
    ret





    align 16
_terminalWriteString:
    push esi
    sub esp, 8
    mov esi, [esp + 16]

    mov [esp], esi
    call _strlen

    mov [esp + 4], eax
    mov [esp], esi
    call _terminalWrite

    add esp, 8
    pop esi
    ret