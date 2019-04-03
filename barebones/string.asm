global _strlen

section .text align=16

    align 16
_strlen:
    push ebx
    mov ecx, [esp + 8]
    
    mov edx, ecx
    mov eax, ecx
    and edx, 3
    je .loop

    cmp edx, 2
    je .skip
    ja .skip2

    cmp byte [ecx], 0
    je .return

    lea eax, [ecx + 1]

.skip:
    cmp byte [eax], 0
    je .return

    inc eax

.skip2:
    cmp byte [eax], 0
    je .return

    inc eax

.loop:
    mov ebx, [eax]
    add eax, 4
    lea edx, [ebx - 0xFEFEFEFF]
    not ebx
    and edx, ebx
    and edx, -0x80808080
    je .loop

    mov ebx, edx
    shr ebx, 16
    test edx, 0x8080
    cmove edx, ebx

    lea ebx, [eax + 2]
    cmove eax, ebx

    mov ebx, edx
    add bl, dl
    sbb eax, 3

.return:
    sub eax, ecx
    pop ebx
    ret