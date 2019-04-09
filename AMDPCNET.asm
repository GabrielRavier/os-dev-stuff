global _ioBase ; IO base address of the first BAR read from configuration space (uint16_t), not initialized here

global _PCNET_initCard
global _PCNET_enableASEL
global _PCNET_swStyleTo2
global _PCNET_to32Bit
global _PCNET_resetCard
global _PCNET_writeBCR16
global _PCNET_writeBCR32
global _PCNET_readBCR16
global _PCNET_readBCR32
global _PCNET_writeCSR16
global _PCNET_writeCSR32
global _PCNET_readCSR16
global _PCNET_readCSR32
global _PCNET_writeRAP16
global _PCNET_writeRAP32

section .bss align=16

	_ioBase resw 1

section .text align=16

	align 16
_PCNET_initCard:
	movzx edx, word [_ioBase]
	add edx, 0x18
	in eax, dx

	sub edx, 4
	in ax, dx

	xor eax, eax
	sub edx, 4
	out dx, eax

	mov eax, 58
	add edx, 4
	out dx, eax

	sub edx, 4
	in eax, dx

	mov ecx, eax
	mov eax, 58
	and ecx, 0xFFF0
	or ecx, 2
	add edx, 4
	out dx, eax

	mov eax, ecx
	sub edx, 4
	out dx, eax

	mov eax, 2
	add edx, 4
	out dx, eax

	add edx, 8
	in eax, dx

	mov ecx, eax
	mov eax, 2
	or ecx, 2
	sub edx, 8
	out dx, eax

	mov eax, ecx
	add edx, 8
	out dx, eax
	ret
	




	align 16
_PCNET_enableASEL:
	movzx edx, word [_ioBase]
	mov eax, 2
	add edx, 0x14
	out dx, eax

	add edx, 8
	in eax, dx

	mov ecx, eax
	mov eax, 2
	or ecx, 2
	sub edx, 8
	out dx, eax

	mov eax, ecx
	add edx, 8
	out dx, eax
	ret





	align 16
_PCNET_swStyleTo2:
	movzx edx, word [_ioBase]
	mov eax, 58
	add edx, 0x14
	out dx, eax

	sub edx, 4
	in eax, dx

	mov ecx, eax
	mov eax, 58
	and ecx, 0xFFF0
	or ecx, 2
	add edx, 4
	out dx, eax

	mov eax, ecx
	sub edx, 4
	out dx, eax
	ret





	align 16
_PCNET_to32Bit:
	movzx edx, word [_ioBase]
	xor eax, eax
	add edx, 0x10
	out dx, eax
	ret





	align 16
_PCNET_resetCard:
	mov cx, [_ioBase]
	lea edx, [ecx + 0x18]
	in eax, dx

	lea edx, [ecx + 0x14]
	in ax, dx
	ret





; %1 : false : 32-bit, true : 16-bit
; %2 : false : out, true : in
%macro make16Or32InOrOut 2
%if %1 == 1
%if %2 == 0
	out dx, ax
%else
	in ax, dx
%endif
%else
%if %2 == 0
	out dx, eax
%else
	in eax, dx
%endif
%endif
%endmacro

; %1 : false : 32-bit, true : 16-bit
%macro make16Or32Out 1
	make16Or32InOrOut %1, 0
%endmacro

; %1 : false : 32-bit, true : 16-bit
%macro make16Or32In 1
	make16Or32InOrOut %1, 1
%endmacro

; %1 : Name of function
; %2 : First offset
; %3 : false : 32-bit, true : 16-bit
; %4 : Second offset
; %5 : false : write, true : read
%macro makeReadOrWrite 5
	align 16
%1:
	mov cx, [_ioBase]
%if %5 == 1 && %3 == 1
	movzx eax, word [esp + 4]
%else
	mov eax, [esp + 4]
%endif
	lea edx, [ecx + %2]
	make16Or32Out %3

%if %5 == 0
	mov eax, [esp + 8]
%endif
	lea edx, [ecx + %4]
	make16Or32InOrOut %3, %5
	ret
%endmacro

; %1 : Name of function
; %2 : First offset
; %3 : false : 32-bit, true : 16-bit
; %4 : Second offset
%macro makeWrite 4
	makeReadOrWrite %1, %2, %3, %4, 0
%endmacro

; %1 : Name of function
; %2 : First offset
; %3 : false : 32-bit, true : 16-bit
; %4 : Second offset
%macro makeRead 4
	makeReadOrWrite %1, %2, %3, %4, 1
%endmacro

	makeWrite _PCNET_writeBCR16, 0x12, 1, 0x16
	makeWrite _PCNET_writeBCR32, 0x14, 0, 0x1C
	makeRead _PCNET_readBCR16, 0x14, 1, 0x16
	makeRead _PCNET_readBCR32, 0x14, 0, 0x1C
	
	makeWrite _PCNET_writeCSR16, 0x12, 1, 0x10
	makeWrite _PCNET_writeCSR32, 0x14, 0, 0x10
	makeRead _PCNET_readCSR16, 0x14, 1, 0x10
	makeRead _PCNET_readCSR32, 0x14, 0, 0x10

%macro makeRAP 3
	align 16
%1:
	mov ax, [_ioBase]
	lea edx, [eax + %2]

	mov eax, [esp + 4]
%if %3 == 0
	out dx, ax
%else
	out dx, eax
%endif
	ret
%endmacro

	makeRAP _PCNET_writeRAP16, 0x12, 0
	makeRAP _PCNET_writeRAP32, 0x14, 1