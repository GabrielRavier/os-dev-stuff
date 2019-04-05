global _kernelMain
extern _terminalInitialize
extern _terminalWriteString

section .rdata align=16

    align 16
    aHelloKernelWorld db "Hello, kernel World!", 10, 0

section .text align=16

    align 16
_kernelMain:
    sub esp, 12
    call _terminalInitialize
    mov [esp], aHelloKernelWorld
    call _terminalWriteString
    add esp, 12
    ret