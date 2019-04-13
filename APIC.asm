global _APIC_check
global _APIC_setBase
global _APIC_getBase
global _APIC_ioRead
global _APIC_ioWrite

%define IA32_APIC_BASE_MSR 0x1B
%define IA32_APIC_BASE_MSR_BSP 0x100	; Processor is a BSP
%define IA32_APIC_BASE_MSR_ENABLE 0x800

section .text align=16

_APIC_check:
	push ebx

	mov eax, 1
	cpuid
	mov eax, edx

	shr eax, 9
	and eax, 1
	pop ebx
	ret





	align 16
_APIC_setBase:
	mov eax, 0xFFFFF000

	xor edx, edx
	mov ecx, IA32_APIC_BASE_MSR

	and eax, [esp + 4]
	or eax, IA32_APIC_BASE_MSR_ENABLE
	
	wrmsr
	ret





	align 16
_APIC_getBase:
	mov ecx, IA32_APIC_BASE_MSR
	rdmsr

	and eax, 0xFFFFF000
	ret
	




	align 16
_APIC_ioRead:
	mov eax, [esp + 4]
	movzx edx, byte [esp + 8]
	mov [eax], edx
	mov eax, [eax + 16]
	ret





	align 16
_APIC_ioWrite:
	mov eax, [esp + 12]
	movzx ecx, byte [esp + 8]
	mov edx, [esp + 4]

	mov [edx], ecx
	mov [edx + 16], eax
	ret