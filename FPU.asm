global _FPU_loadControlWord

section .text align=16

_FPU_loadControlWord:
	fldcw [esp + 4]
	ret