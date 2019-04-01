; Constants for multiboot header
MBALIGN equ 1 << 0  ; loaded modules align
MEMINFO equ 1 << 1  ; provide memory map
FLAGS equ MBALIGN | MEMINFO ; Multiboot 'flag' field
MAGIC equ 0x1BADB002    ; magic number so bootloader loads the kernel
CHECKSUM equ -(MAGIC + FLAGS)   ; checksum to prove multiboot

; Multiboot header
section .multiboot
    align 4
    dd MAGIC
    dd FLAGS
    dd CHECKSUM

; Stack stuff
section .bss
    align 16
stackBottom:
    resb 16384  ; 16 KiB
stackTop:

; Start stuff
section .text
global _start:function (_start.end - _start)
_start:
    ; We're in 32-bit protected mode on x86, but with nothing. Interrupts and paging are disabled.
    mov esp, stackTop

    extern kernel_main
    call kernel_main

    ; End of kernel
    cli

.hang:
    hlt
    jmp .hang

.end: