%include "macros.inc"

global _cpuid
global _cpuidString

section .text align=16

	align 16
_cpuid:
	push ebx

	mov eax, [esp + 8]
	cpuid

	multimov ecx, [esp + 12], [ecx], eax, eax, [esp + 16], [eax], edx
	
	pop ebx
	ret





	align 16
_cpuidString:
	multipush esi, ebx
	multimov eax, [esp + 12], esi, [esp + 16]

	cpuid

	multimov [esi], eax, [esi + 4], ebx, [esi + 8], ecx, [esi + 12], edx
	multipop esi, ebx

	ret