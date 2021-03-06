%include "macros.inc"

global _ATAPI_driveReadSector
extern _ataGrab
extern _ataRelease
extern _schedule

section .text align=16

%macro MAKE_ATA_DELAY 0

	in al, dx
	in al, dx
	in al, dx
	in al, dx

%endmacro

_ATAPI_driveReadSector:
	prolog ebp, edi, esi, ebx, 28

	multimov ebp, [esp + 48], dword [esp + 4], 168, dword [esp + 8], 0, dword [esp + 12], 0

	call _ataGrab

	mov edx, [esp + 52]
	lea eax, [ebp + 6]
	and edx, 0x10

	out dx, al

	lea edx, [ebp + 518]
	MAKE_ATA_DELAY

	xor edx, edx
	lea eax, [ebp + 1]
	out dx, al

	lea eax, [ebp + 4]
	out dx, al

	mov edx, 8
	lea eax, [ebp + 5]
	out dx, al

	mov edx, 0xA0
	lea eax, [ebp + 7]
	out dx, al

	lea ebx, [ebp + 7]
	mov edx, ebx
	in al, dx

	test al, al
	jns .startPauseLoop2

.pauseLoop:
	pause

	mov edx, ebx
	in al, dx

	test al, al
	js .pauseLoop
	jmp .startPauseLoop2

	align 16
.pauseLoop2:
	pause

.startPauseLoop2:
	mov edx, eax
	in al, dx

	test al, 9
	je .pauseLoop2

	test al, 1
	jne .error

	multimov eax, [esp + 56], byte [esp + 13], 1

	lea esi, [esp + 4]
	multimov edx, ebp, ecx, 6

	bswap eax
	mov [esp + 6], eax

	rep outsw

	call _schedule

	lea edx, [ebp + 5]
	in al, dx
	movzx esi, al
	lea edx, [ebp + 4]
	in al, dx

	sal esi, 8
	movzx eax, al
	or esi, eax

	cmp esi, 0x800
	jne .error

	multimov edi, [esp + 60], ecx, 0x400, edx, ebp
	rep insw

	call _schedule

	mov edx, ebx
	in al, dx

	test al, 0x88
	je .return

.pauseLoop3:
	pause

	mov edx, ebx
	in al, dx

	test al, 0x88
	jne .pauseLoop3

.return:
	call _ataRelease

	mov eax, esi
	epilog ebp, edi, esi, ebx, 28
	ret

	align 16
.error:
	mov esi, -1
	jmp .return