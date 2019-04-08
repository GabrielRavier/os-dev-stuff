%define FIS_TYPE_REG_H2D 0x27, ; Register FIS - host to device
%define FIS_TYPE_REG_D2H 0x34, ; Register FIS - device to host
%define FIS_TYPE_DMA_ACT 0x39, ; DMA activate FIS - device to host
%define FIS_TYPE_DMA_SETUP 0x41, ; DMA setup FIS - bidirectional
%define FIS_TYPE_DATA 0x46, ; Data FIS - bidirectional
%define FIS_TYPE_BIST 0x58, ; BIST activate FIS - bidirectional
%define FIS_TYPE_PIO_SETUP 0x5F, ; PIO setup FIS - device to host
%define FIS_TYPE_DEV_BITS 0xA1, ; Set device bits FIS - device to host
%define ATA_CMD_IDENTIFY 0xEC

global _FIS_REG_H2D_init

section .text align=16

_FIS_REG_H2D_init:
	mov eax, [esp + 4]
	mov dword [eax + 3], 0
	mov dword [eax + 7], 0
	mov dword [eax + 15], 0
	mov dword [eax + 11], 0
	mov byte [eax + 19], 0
	
	mov word [eax], 0x8000 | FIS_TYPE_REG_H2D
	mov byte [eax + 2], ATA_CMD_IDENTIFY
	ret