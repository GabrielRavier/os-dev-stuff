%include "macros.inc"

global _PIC_send
global _PIC_remap
global _PIC_disable
global _IRQ_setMask
global _IRQ_clearMask
global _PIC_getIRR
global _PIC_getISR

%macro ioWait 0
	xor eax, eax
	out 0x80, al
%endmacro

%macro outNonAl 2
	mov al, %2
	out %1, al
%endmacro

%macro outNonAlAndWait 2
	outNonAl %1, %2
	ioWait
%endmacro

%define PIC1 0x20
%define PIC2 0xA0
%define PIC_EOI 0x20
%define PIC1_COMMAND PIC1
%define PIC1_DATA (PIC1+1)
%define PIC2_COMMAND PIC2
%define PIC2_DATA (PIC2+1)
%define ICW1_ICW4 0x01		; ICW4 (not) needed 
%define ICW1_SINGLE 0x02		; Single (cascade) mode 
%define ICW1_INTERVAL4 0x04		; Call address interval 4 (8) 
%define ICW1_LEVEL 0x08		; Level triggered (edge) mode 
%define ICW1_INIT 0x10		; Initialization - required! 
%define ICW4_8086 0x01		; 8086/88 (MCS-80/85) mode 
%define ICW4_AUTO 0x02		; Auto (normal) EOI 
%define ICW4_BUF_SLAVE 0x08		; Buffered mode/slave 
%define ICW4_BUF_MASTER 0x0C		; Buffered mode/master 
%define ICW4_SFNM 0x10		; Special fully nested (not) 
%define PIC_READ_IRR 0xA    ; OCW3 irq ready next CMD read
%define PIC_READ_ISR 0xB    ; OCW3 irq service next CMD read

section .text align=16

	align 16
_PIC_send:
	cmp byte [esp + 4], 8
	mov al, PIC_EOI
	jb .small

	out PIC2_COMMAND, al

.small:
	out PIC1_COMMAND, al
	ret





	align 16
_PIC_remap:
	multimov dl, [esp + 4], cl, [esp + 8]

	in al, PIC1_DATA
	mov ch, al
	in al, PIC2_DATA
	mov dh, al

	outNonAlAndWait PIC1_COMMAND, ICW1_INIT | ICW1_ICW4
	outNonAlAndWait PIC2_COMMAND, ICW1_INIT | ICW1_ICW4

	mov eax, edx
	out PIC1_DATA, al
	ioWait

	mov eax, ecx
	out PIC2_DATA, al
	ioWait

	outNonAlAndWait PIC1_DATA, 4
	outNonAlAndWait PIC2_DATA, 2

	outNonAlAndWait PIC1_DATA, ICW4_8086
	out PIC2_DATA, al
	ioWait

	outNonAl PIC1_DATA, ch
	outNonAl PIC2_DATA, dh

	ret





	align 16
_PIC_disable:
	outNonAl PIC2_DATA, 0xFF
	out PIC1_DATA, al
	ret





	align 16
_IRQ_setMask:
	push edi
	mov ecx, PIC1_DATA
	movzx edi, byte [esp + 8]

	mov edx, PIC2_DATA
	cmp edi, 8
	cmovl edx, ecx

	lea ecx, [edi + 24]
	cmovl ecx, edi

	in al, dx
	movzx eax, al
	bts eax, ecx

	out dx, al

	pop edi
	ret





	align 16
_IRQ_clearMask:
	push edi
	mov ecx, PIC1_DATA
	movzx edi, byte [esp + 8]
	
	mov edx, PIC2_DATA
	cmp edi, 8
	cmovl edx, ecx

	lea ecx, [edi + 24]
	cmovl ecx, edi

	in al, dx
	movzx eax, al
	btr eax, ecx
	out dx, al
	
	pop edi
	ret





	align 16
_PIC_getIRR:
	mov eax, PIC_READ_IRR
	jmp picGetIRQ

	align 16
_PIC_getISR:
	mov eax, PIC_READ_ISR

picGetIRQ:
	out PIC1_COMMAND, al
	out PIC2_COMMAND, al

	in al, PIC2_COMMAND
	movzx edx, al
	in al, PIC1_COMMAND
	movzx eax, al

	shl edx, 8
	or eax, edx
	ret