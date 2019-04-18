%include "macros.inc"

global _CMOS_centuryRegister
global _CMOS_second
global _CMOS_minute
global _CMOS_hour
global _CMOS_day
global _CMOS_month
global _CMOS_year
global _CMOS_getUpdateInProgressFlag
global _CMOS_getRTCRegister
global _CMOS_readRTC

section .data align=16

	align 16
	_CMOS_centuryRegister dd 0

	align 16
	_CMOS_second db 0

	align 16
	_CMOS_minute db 0

	align 16
	_CMOS_hour db 0

	align 16
	_CMOS_day db 0

	align 16
	_CMOS_month db 0

	align 16
	_CMOS_year dd 0

section .text align=16

%macro makeGetRTCRegisterRaw 0
	out 0x70, al
	in al, 0x71
%endmacro

%macro makeGetRTCRegister 1
	mov eax, %1
	makeGetRTCRegisterRaw
%endmacro

%macro makeGetRTCRegisterIntoVar 2
	makeGetRTCRegister %1
	mov %2, al
%endmacro

	align 16
_CMOS_getUpdateInProgressFlag:
	makeGetRTCRegister 10

	and al, 0x80
	movzx eax, al
	ret





	align 16
_CMOS_getRTCRegister:
	mov al, [esp + 4]
	makeGetRTCRegisterRaw
	ret





%macro makeGetDate 0

	xor eax, eax
	makeGetRTCRegisterRaw
	mov [_CMOS_second], al
	
	makeGetRTCRegisterIntoVar 2, [_CMOS_minute]
	makeGetRTCRegisterIntoVar 4, [_CMOS_hour]
	makeGetRTCRegisterIntoVar 7, [_CMOS_day]
	makeGetRTCRegisterIntoVar 8, [_CMOS_month]

	makeGetRTCRegister 9
	movzx eax, al
	mov [_CMOS_year], eax

%endmacro

%macro makeWaitUpdate 0
%%.updateWaitLoop:
	makeGetRTCRegister 10

	test al, al
	js %%.updateWaitLoop
%endmacro

%macro makeDateCheck 2

	cmp %1, %2
	jne .loop

%endmacro

%macro mulBy5 2
	lea %1, [%2 + %2 * 4]
%endmacro

%macro mulBy10 2
	add %2, %2
	mulBy5 %1, %2
%endmacro

%macro BCDToNormCore 6

%if %6 == 0
	mov %2, [%1]
%else
	mov %3, [%1]
%endif
	mov %5, %3
	shr %2, 4
	movzx %3, %2
	and %4, 0xF
	mulBy10 %3, %3
	add %2, %4
	mov [%1], %3

%endmacro

%macro BCDToNorm 1
	BCDToNormCore %1, cl, ecx, dl, edx, 0
%endmacro

%define getDateFromMem multimov bh, [_CMOS_second], cl, [_CMOS_minute], ah, [_CMOS_hour], ch, [_CMOS_day], al, [_CMOS_month]

%macro mulBy3 2
	lea %1, [%2 + %2 * 2]
%endmacro

	align 16
_CMOS_readRTC:
	makeWaitUpdate

	makeGetDate

	mov eax, [_CMOS_centuryRegister]
	test eax, eax
	je .centuryRegNot0

	makeGetRTCRegisterRaw
	mov dh, al

.centuryRegNot0:
	prolog ebx, edi, esi, 8
	getDateFromMem

.loop:
	movzx esi, byte [_CMOS_year]
	multimov dl, dh, [esp + 3], ah, [esp + 2], ch, [esp + 1], al, [esp + 4], edx, edx, ecx

	makeWaitUpdate

	makeGetDate

	multimov ecx, [_CMOS_centuryRegister], eax, [esp + 4]
	test ecx, ecx
	mov dh, al
	je .centuryRegNot02
	
	mov eax, ecx
	makeGetRTCRegisterRaw

	mov dh, al

.centuryRegNot02:
	getDateFromMem

	cmp bh, bl
	mov bh, bl
	jne .loop

	makeDateCheck dl, cl
	makeDateCheck [esp + 3], ah
	makeDateCheck [esp + 2], ch
	makeDateCheck [esp + 1], al

	mov edi, [_CMOS_year]
	makeDateCheck [esp + 4], dh
	makeDateCheck esi, edi

	makeGetRTCRegister 11
	movzx eax, al

	test al, 4
	jne .bcdEnd

	BCDToNorm _CMOS_second
	BCDToNorm _CMOS_minute
	
	multimov cl, [_CMOS_hour], ch, cl
	mov edx, ecx
	and cl, 0x80
	shr ch, 4
	and dl, 0xF
	and ch, 7
	movzx esi, ch
	mulBy10 ebx, esi

	add bl, dl
	or cl, bl
	mov [_CMOS_hour], cl

	BCDToNorm _CMOS_day
	BCDToNorm _CMOS_month

	multimov ecx, [_CMOS_year], edx, ecx
	shr ecx, 4
	and edx, 0xF
	cmp dword [_CMOS_centuryRegister], 0
	mulBy5 ecx, ecx
	lea ecx, [edx + ecx * 2]
	mov [_CMOS_year], ecx
	je .bcdEnd

	BCDToNormCore esp + 4, dl, edx, cl, ecx, 1

.bcdEnd:
	test al, 2
	jne .noConvert12To24

	mov al, [_CMOS_hour]
	test al, al
	js .convert12To24

.noConvert12To24:
	cmp dword [_CMOS_centuryRegister], 0
	je .centuryReg0

.centuryRegNot03:
	movzx eax, byte [esp + 4]
	imul eax, 100
	add eax, [_CMOS_year]
	jmp .eaxToYearAndRet

	align 16
.convert12To24:
	and al, 0x7F
	add al, 12
	movzx ecx, al
	imul ecx, 171
	shr ecx, 9
	and ecx, -8
	mulBy3 ecx, ecx
	sub al, cl
	mov [_CMOS_hour], al

	cmp dword [_CMOS_centuryRegister], 0
	jne .centuryRegNot03

.centuryReg0:
	mov eax, [_CMOS_year]
	lea eax, [eax + 2000]
	cmp ecx, 2018
	mov [_CMOS_year], ecx
	ja .return

	add eax, 2100

.eaxToYearAndRet:
	mov [_CMOS_year], eax

.return:
	epilog ebx, edi, esi, 8
	ret