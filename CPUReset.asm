global _PSE2CPUReset

%define PSE2StatusCommandRegister 0x64
%define PSE2StatusRegInputBufferStatus 00000010b

section .text align=16

_PSE2CPUReset:
.wait:	; Wait for an empty input buffer
	in al, PSE2StatusCommandRegister
	test al, PSE2StatusRegInputBufferStatus
	jne .wait

	; Reset CPU
	mov al, 0xFE
	out PSE2StatusCommandRegister, al
