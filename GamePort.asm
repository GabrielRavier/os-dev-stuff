%include "macros.inc"

global _joystickButton
global _joystickStatus
global _joystickDump
extern _jst

section .text align=16

_joystickButton:
	mov cl, [esp + 4]
	xor eax, eax

	cmp cl, 31
	jg .greaterThan31

	cmp cl, 0x80
	je .gotMatch

	cmp cl, 16
	je .gotMatch

.return:
	ret

	align 16
.greaterThan31:
	cmp cl, 64
	je .gotMatch

	cmp cl, 32
	jne .return

.gotMatch:
	mov dx, 0x201
	in al, dx

	test al, cl
	sete al

	ret





	align 16
_joystickStatus:
	cli

	mov dx, 0x201
	in al, dx

	multimov ecx, eax, al, 0x55, dx, 0x201
	out dx, al

	mov eax, dword [_jst]
	and cl, [esp + 4]
	je .ret0

	mov byte [eax + 12], 1
	movzx eax, cl
	sti
	ret

	align 16
.ret0:
	mov byte [eax + 12], 0
	xor eax, eax
	sti
	ret





%macro makeBetweenStatusCalls 3
	multimov ecx, [_jst], [ecx + %1], %3, dword [esp], %2
%endmacro

%macro makeBetweenButtonCalls 0
	movzx eax, al
	mov [esp], eax
%endmacro
	align 16
_joystickDump:
	sub esp, 12

	mov dword [esp], 1
	call _joystickStatus
	
	makeBetweenStatusCalls 0, 2, ax
	call _joystickStatus

	makeBetweenStatusCalls 2, 4, ax
	call _joystickStatus

	makeBetweenStatusCalls 4, 8, ax
	call _joystickStatus

	makeBetweenStatusCalls 6, 0x10, ax
	call _joystickStatus

	makeBetweenButtonCalls
	call _joystickButton

	makeBetweenStatusCalls 8, 0x20, al
	call _joystickStatus

	makeBetweenButtonCalls
	call _joystickButton

	makeBetweenStatusCalls 9, 0x40, al
	call _joystickStatus

	makeBetweenButtonCalls
	call _joystickButton

	makeBetweenStatusCalls 10, 0x80, al
	call _joystickStatus

	makeBetweenButtonCalls
	call _joystickButton

	mov ecx, [_jst]
	mov [ecx + 11], al

	add esp, 12
	ret
	