global _terminalInitialize

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
    