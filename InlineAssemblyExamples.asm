global _farpeekl
global _farpokeb
global _outb
global _inb
global _ioWait
global _areInterruptsEnabled
global _saveIRQDisable
global _IRQRestore
global _lidt
global _cpuid
global _rdtsc
global _readCR0
global _invlpg
global _wrmsr
global _rdmsr

section .text align=16

	align 16
_farpeekl:
	mov eax, [esp + 8]
	push fs
	mov fs, [esp + 4]
	mov eax, [fs:eax]
	pop fs
	ret





	align 16
_farpokeb:
	mov eax, [esp + 8]
	mov edx, [esp + 12]
	push fs
	mov fs, [esp + 4]
	mov [ds:eax], dl
	pop fs
	ret





	align 16
_outb:
	mov edx, [esp + 4]
	mov eax, [esp + 8]
	out dx, al
	ret





	align 16
_inb:
	mov edx, [esp + 4]
	in al, dx
	ret





	align 16
_ioWait:
	xor eax, eax
	out 0x80, al
	ret





	align 16
_areInterruptsEnabled:
	pushf
	pop eax

	shr eax, 9
	and eax, 1
	ret





	align 16
_saveIRQDisable:
	pushf
	cli
	pop eax
	ret





	align 16
_IRQRestore:
	push dword [esp + 4]
	popf
	ret





	align 16
_lidt:
	sub esp, 16
	mov eax, [esp + 24]
	mov [esp + 10], ax

	mov eax, [esp + 20]
	mov [esp + 12], eax

	lidt [esp + 10]

	add esp, 16
	ret





	align 16
_cpuid:
	push ebx

	mov eax, [esp + 8]
	cpuid

	mov ecx, [esp + 12]
	mov [ecx], eax
	
	mov eax, [esp + 16]
	mov [eax], edx

	pop ebx
	ret





	align 16
_rdtsc:
	rdtsc
	ret





	align 16
_readCR0:
	mov eax, cr0
	ret





	align 16
_invlpg:
	push ebx
	
	mov ebx, [esp + 8]
	invlpg [ebx]

	pop ebx
	ret





	align 16
_wrmsr:
	mov ecx, [esp + 4]
	mov eax, [esp + 8]
	mov edx, [esp + 12]
	wrmsr
	ret





	align 16
_rdmsr:
	mov ecx, [esp + 4]
	rdmsr
	ret