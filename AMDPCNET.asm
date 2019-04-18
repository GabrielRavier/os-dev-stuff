%include "macros.inc"
extern _memcpy	; Should work like libc memcpy
global _PCNET_ioBase ; IO base address of the first BAR read from configuration space (uint16_t), not initialized here
global _PCNET_pRxBuffer	; (int)
global _PCNET_pTxBuffer	; Pointers to transmit/receive buffers (int)
global _PCNET_rxBufferCount	; Total number of receive buffers (int)
global _PCNET_txBufferCount	; Total number of transmit buffers (int)
global _PCNET_rDes	; Pointer to ring buffer of receive DEs (uint8_t *)
global _PCNET_tDes	; Pointer to ring buffer of transmit DEs (uint8_t *)
global _PCNET_rxBuffers	; Physical address of actual receive buffers (< 4 GiB) (uint32_t)
global _PCNET_txBuffers	; Physical address of actual transmit buffers (< 4 GiB) (uint32_t)

global _PCNET_init
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
global _PCNET_driverOwns
global _PCNET_nextTxIdx
global _PCNET_nextRxIdx
global _PCNET_initDE
global _PCNET_sendPacket

section .bss align=16

	_PCNET_ioBase resw 1
	resw 1	; align

	_PCNET_rDes resd 1

	_PCNET_tDes resd 1

	_PCNET_rxBuffers resd 1

	_PCNET_txBuffers resd 1

section .data align=16

	align 16
	_PCNET_pRxBuffer dd 0

	align 16
	_PCNET_pTxBuffer dd 0

	align 16
	_PCNET_rxBufferCount dd 32

	align 16
	_PCNET_txBufferCount dd 8

section .text align=16

	align 16
_PCNET_init:
	movzx edx, word [_PCNET_ioBase]
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

	multimov ecx, eax, eax, 58
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

	multimov ecx, eax, eax, 2
	or ecx, 2
	sub edx, 8
	out dx, eax

	mov eax, ecx
	add edx, 8
	out dx, eax
	ret
	




	align 16
_PCNET_enableASEL:
	movzx edx, word [_PCNET_ioBase]
	mov eax, 2
	add edx, 0x14
	out dx, eax

	add edx, 8
	in eax, dx

	multimov ecx, eax, eax, 2
	or ecx, 2
	sub edx, 8
	out dx, eax

	mov eax, ecx
	add edx, 8
	out dx, eax
	ret





	align 16
_PCNET_swStyleTo2:
	movzx edx, word [_PCNET_ioBase]
	mov eax, 58
	add edx, 0x14
	out dx, eax

	sub edx, 4
	in eax, dx

	multimov ecx, eax, eax, 58
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
	movzx edx, word [_PCNET_ioBase]
	xor eax, eax
	add edx, 0x10
	out dx, eax
	ret





	align 16
_PCNET_resetCard:
	mov cx, [_PCNET_ioBase]
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
	mov cx, [_PCNET_ioBase]
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
	mov ax, [_PCNET_ioBase]
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





	align 16
_PCNET_driverOwns:	; does the driver own the particular buffer?
	mov eax, [esp + 8]
	sal eax, 4
	add eax, [esp + 4]
	movsx eax, byte [eax + 7]
	not eax
	shr eax, 31
	ret




%macro makeNextThingo 2
	align 16
%1:
	mov ecx, [esp + 4]
	xor eax, eax
	inc ecx
	cmp ecx, [%2]
	cmovne eax, ecx
	ret
%endmacro

	makeNextThingo _PCNET_nextTxIdx, _PCNET_txBufferCount
	makeNextThingo _PCNET_nextRxIdx, _PCNET_rxBufferCount





	align 16
_PCNET_initDE:	; initialize a DE
	multipush esi, edi

	xor ecx, ecx

	multimov esi, [esp + 16], eax, esi
	shl eax, 4
	multimov edx, [esp + 12], [eax + edx], ecx, [eax + edx + 4], ecx, [eax + edx + 8], ecx, [eax + edx + 12], ecx

	imul esi, 0x60C

	mov edi, [esp + 20]
	test edi, edi

	mov ecx, [_PCNET_rxBuffers]
	cmovne ecx, [_PCNET_txBuffers]
	add esi, ecx

	multimov ecx, 0xF9F4, [eax + edx], esi, [eax + edx + 4], cx

	test edi, edi
	jne .return

	mov byte [eax + edx + 7], 0x80

.return:
	multipop esi, edi
	ret
	




	align 16
_PCNET_sendPacket:
	multimov eax, [_PCNET_pTxBuffer], ecx, [_PCNET_tDes], edx, eax

	shl edx, 4

	cmp byte [ecx + edx + 7], 0
	js .ret0

	prolog esi, 8

	imul eax, 0x60C
	mov esi, [esp + 20]
	add eax, [_PCNET_txBuffers]
	sub esp, 4
	multipush esi, dword [esp + 24], eax
	call _memcpy
	add esp, 16

	multimov ecx, [_PCNET_pTxBuffer], eax, [_PCNET_tDes]

	neg esi
	or esi, 0xF000

	shl ecx, 4
	or byte [eax + ecx + 7], 2

	multimov ecx, [_PCNET_pTxBuffer], eax, [_PCNET_tDes]

	shl ecx, 4
	or byte [eax + ecx + 7], 1

	multimov ecx, [_PCNET_pTxBuffer], eax, [_PCNET_tDes]
	shl ecx, 4
	mov [eax + ecx + 7], si

	or byte [eax + ecx + 7], 0x80
	xor ecx, ecx

	mov eax, [_PCNET_pTxBuffer]
	inc eax
	cmp eax, [_PCNET_txBufferCount]
	cmovne ecx, eax
	
	multimov eax, 1, [_PCNET_pTxBuffer], ecx
	epilog esi, 8
	ret

	align 16
.ret0:
	xor eax, eax
	ret
