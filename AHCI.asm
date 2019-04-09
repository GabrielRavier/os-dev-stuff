%define FIS_TYPE_REG_H2D 0x27, ; Register FIS - host to device
%define FIS_TYPE_REG_D2H 0x34, ; Register FIS - device to host
%define FIS_TYPE_DMA_ACT 0x39, ; DMA activate FIS - device to host
%define FIS_TYPE_DMA_SETUP 0x41, ; DMA setup FIS - bidirectional
%define FIS_TYPE_DATA 0x46, ; Data FIS - bidirectional
%define FIS_TYPE_BIST 0x58, ; BIST activate FIS - bidirectional
%define FIS_TYPE_PIO_SETUP 0x5F, ; PIO setup FIS - device to host
%define FIS_TYPE_DEV_BITS 0xA1, ; Set device bits FIS - device to host
%define ATA_CMD_IDENTIFY 0xEC

%define SATA_SIG_ATA 0x00000101 ; SATA drive
%define SATA_SIG_ATAPI 0xEB140101 ; SATAPI drive
%define SATA_SIG_SEMB 0xC33C0101 ; Enclosure management bridge
%define SATA_SIG_PM 0x96690101 ; Port multiplier
 
%define AHCI_DEV_NULL 0
%define AHCI_DEV_SATA 1
%define AHCI_DEV_SEMB 2
%define AHCI_DEV_PM 3
%define AHCI_DEV_SATAPI 4
 
%define HBA_PORT_IPM_ACTIVE 1
%define HBA_PORT_DET_PRESENT 3

%define	AHCI_BASE 0x400000 ; 4M
 
%define HBA_PxCMD_ST 0x0001
%define HBA_PxCMD_FRE 0x0010
%define HBA_PxCMD_FR 0x4000
%define HBA_PxCMD_CR 0x8000

global _FIS_REG_H2D_init
global _AHCI_probePort
global _AHCI_portRebase
global _AHCI_startCmd
global _AHCI_stopCmd
extern _trace_ahci	; From nowhere, implement this yourself (void trace_ahci(const char *fmt, ...);)

section .rodata align=16

	aGotSATA db "SATA drive found at port %d", 10, 0

	aGotSATAPI db "SATAPI drive found at port %d", 10, 0

	aGotSEMB db "SEMB drive found at port %d", 10, 0

	aGotPM db "PM drive found at port %d", 10, 0

	aNoDrive db "No drive found at port %d", 10, 0

section .text align=16

	align 16
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





	align 16
_AHCI_probePort:
	push ebp
	push ebx
	push edi
	push esi
	sub esp, 12
	mov esi, [esp + 32]
	xor edi, edi
	mov ebp, 0x0F0F
	mov ebx, [esi + 12]
	add esi, 0x128

.loop:
	test bl, 1
	je .piNotHas1

	mov eax, [esi]
	and eax, ebp
	cmp eax, (HBA_PORT_IPM_ACTIVE * 0x100) | HBA_PORT_DET_PRESENT
	jne .noDriveDetected

	mov eax, [esi - 4]
	sub esp, 8
	
	cmp eax, SATA_SIG_PM
	je .gotPM

	cmp eax, SATA_SIG_SEMB
	je .gotSEMB

	cmp eax, SATA_SIG_ATAPI
	jne .gotSATA

	push edi
	push aGotSATAPI
	jmp .continue

.noDriveDetected:
	sub esp, 8
	push edi
	push aNoDrive
	jmp .continue

.gotSEMB:
	push edi
	push aGotSEMB
	jmp .continue

.gotPM:
	push edi
	push aGotPM
	jmp .continue

.gotSATA:
	push edi
	push aGotSATA

.continue:
	call _trace_ahci
	add esp, 16

.piNotHas1:
	inc edi
	shr ebx, 1
	sub esi, -128
	cmp edi, 32
	jne .loop

	add esp, 12
	pop esi
	pop edi
	pop ebx
	pop ebp
	ret





_AHCI_startCmd:
	mov eax, [esp + 4]

.loop:
	mov ecx, [eax + 24]
	test cx, cx
	js .loop

	or dword [eax + 24], HBA_PxCMD_FRE
	or dword [eax + 24], HBA_PxCMD_ST
	ret





	align 16
_AHCI_stopCmd:
	mov eax, [esp + 4]
	and dword [eax + 24], ~HBA_PxCMD_ST

.loop:
	test dword [eax + 24], HBA_PxCMD_FR
	jne .loop

	mov ecx, [eax + 24]
	test cx, cx
	js .loop

	and dword [eax + 24], ~HBA_PxCMD_FRE
	ret





	align 16
_AHCI_portRebase:
	push ebp
	push edi
	push esi
	push ebx
	sub esp, 24

	mov ebp, [esp + 44]
	mov esi, [esp + 48]

	push ebp
	call _AHCI_stopCmd

	mov eax, esi
	add esp, 16
	sal eax, 10
	add eax, AHCI_BASE
	mov [ebp], eax

	xor eax, eax
	mov dword [ebp + 4], 0
	mov edx, [ebp]
	lea edi, [edx + 4]
	mov dword [edx], 0
	mov dword [edx + 1020], 0
	and edi, -4
	sub edx, edi
	lea ecx, [edx + 1024]

	mov edx, esi
	sal esi, 13
	shr ecx, 2
	sal edx, 8
	rep stosd

	add edx, AHCI_BASE
	mov [ebp + 8], edx

	mov dword [ebp + 12], 0

	mov edx, [ebp + 8]
	lea edi, [edx + 4]
	mov dword [edx], 0
	mov dword [edx + 252], 0
	and edi, -4
	sub edx, edi
	lea ecx, [edx + 256]

	lea edx, [esi + 0x40A000]
	add esi, 0x40C000

	shr ecx, 2
	rep stosd

	mov ebx, [ebp]

.loop:
	mov ecx, 8
	mov [ebx + 8], edx
	mov edi, edx
	add edx, 0x100
	mov [ebx + 2], cx
	mov ecx, 0x40
	add ebx, 0x20
	mov dword [ebx - 20], 0
	rep stosd

	cmp esi, edx
	jne .loop

	mov [esp + 32], ebp
	add esp, 12
	pop ebx
	pop esi
	pop edi
	pop ebp
	jmp _AHCI_startCmd
