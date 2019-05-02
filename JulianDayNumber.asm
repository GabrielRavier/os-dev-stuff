%include "macros.inc"

global _days2Years
global _buildDaysTable
global _jdnToGregYear
global _gregYearToJdn

section .data align=16

	_days2Years times 401 dd 0

section .text align=16

	align 16
_buildDaysTable:
	mov dword [_days2Years], 0x80000000
	multipush esi, ebx
	xor esi, esi
	mov ebx, 0x8A66

.loop:
	lea eax, [ebx - 0x88F8]
	mov edx, esi

.smallLoop:
	lea ecx, [eax + 365]
	mov [_days2Years + edx * 4 + 4], eax
	mov [_days2Years + edx * 4 + 8], ecx

	lea ecx, [eax + (365 * 2)]
	mov [_days2Years + edx * 4 + 12], ecx

	lea ecx, [eax + (365 * 3)]
	add edx, 4
	add eax, 1461
	or ecx, 0x80000000
	mov [_days2Years + edx * 4], ecx

	cmp ebx, eax
	jne .smallLoop

	lea eax, [ebx + 365]
	mov [_days2Years + esi * 4 + 388], ebx
	mov [_days2Years + esi * 4 + 392], eax

	lea eax, [ebx + 730]
	mov [_buildDaysTable + esi * 4 + 396], eax

	lea eax, [ebx + 0x10000447]
	add esi, 100
	add ebx, 0x10008EAC
	mov [_days2Years + esi * 4], eax

	cmp esi, 400
	jne .loop

	multipop esi, ebx
	ret





	align 16
_jdnToGregYear:
	multipush ebx, edi, esi

	xor eax, eax
	test dword [_days2Years + 4], 0xFFFFFFF
	multimov ecx, [esp + 20], esi, [esp + 24]
	sete al

	multimov edi, [_days2Years + eax * 4], ebx, edi, edx, edi
	shr ebx, 24
	neg ebx
	and ebx, 0x30
	test edi, edi
	multimov [ecx], dx, [esi], ebx
	js .tempLess0

	multipop ebx, edi, esi
	ret

	align 16
.tempLess0:
	or edx, 0x8000
	mov [ecx], dx
	
	multipop ebx, edi, esi
	ret





	align 16
_gregYearToJdn:
	multimov ecx, [esp + 4], edx, 0x51EB851F, eax, ecx
	mul edx
	shr edx, 7
	imul eax, edx, 400
	imul edx, 0x23AB1
	sub ecx, eax

	multimov eax, [_days2Years + ecx * 4], ecx, eax
	and eax, 0x80000000
	and ecx, 0xFFFFFFF
	lea edx, [edx + 0x1A42E4 + ecx]
	or eax, edx
	ret
	