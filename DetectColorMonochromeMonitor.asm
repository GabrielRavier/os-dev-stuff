global _detectBIOSAreaHardware
global _getBIOSAreaVideoType

section .text align=16

	align 16
_detectBIOSAreaHardware:
	movzx eax, word [0x410]
	ret





	align 16
_getBIOSAreaVideoType:
	movzx eax, word [0x410]
	and eax, 0x30
	ret