%include "macros.inc"

global _fillrect

section .text align=16

	align 16
_fillrect:
	multipush ebp, ebx, edi, esi

	movzx eax, byte [esp + 36]
	test eax, eax
	je .return

	mov dh, [esp + 40]
	test dh, dh
	je .return

	multimov cl, [esp + 32], dl, [esp + 28], ch, [esp + 24], esi, [esp + 20]
	movzx edi, dh
	xor ebx, ebx

.bigLoop:
	xor ebp, ebp

.loop:
	multimov [esi + ebp * 4], ch, [esi + ebp * 4 + 1], dl, [esi + ebp * 4 + 2], cl

	inc ebp
	cmp edi, ebp
	jne .loop

	inc ebx
	add esi, 0xC80
	cmp ebx, eax
	jne .bigLoop

.return:
	multipop ebp, ebx, edi, esi
	ret