
	code32

	format ELF
	public _kPkgGetNextMod
	public _kPkgGetTotalLength
	public _kPkgGetFirstMod
	extrn _kprintf
	extrn __EOI

section '.rodata' align 16

	aNextModNotFound db 'next mod not found', 12, 0

section '.text' executable align 16

_kPkgGetNextMod:
	ldr r2, [r0]
	ldr r3, [.sigA]
	add r0, r2
	add r0, #16

	ldr r2, [r0, #4]
	cmp r2, r3
	bne .nextModNotFound

	ldr r3, [.sigA2]
	ldr r2, [r0, #8]
	cmp r2, r3
	bxeq lr

.nextModNotFound:
	push {r4, lr}
	ldr r0, [.pANextModNotFound]
	bl _kprintf

	mov r0, #0
	pop {r4, pc}

.sigA:
	dw 0x12345678

.sigA2:
	dw 0xEDCBA987

.pANextModNotFound:
	dw aNextModNotFound





_kPkgGetTotalLength:
	push {r4, lr}
	bl _kPkgGetNextMod
	subs r4, r0, #0
	bne .startLoop
	b .retPEOI

.loop:
	mov r4, r0

.startLoop:
	mov r0, r4
	bl _kPkgGetNextMod

	cmp r0, #0
	bne .loop

	ldr r0, [r4]
	add r0, r4, r0
	add r0, #17
	pop {r4, pc}

.retPEOI:
	ldr r0, [.pEOI]
	pop {r4, pc}

.pEOI:
	dw __EOI





_kPkgGetFirstMod:
	ldr r3, [.pEOIMin80]

	push {r4, lr}
	bic r3, #3

	mov r1, #0
	mov r0, r3

	ldr lr, [.sig]
	ldr r4, [.sig2]
	b .startLoop

.loop:
	cmp r2, #256
	add r3, #4
	mov r1, r2
	beq .ret0

.startLoop:
	ldr ip, [r3]
	add r2, r1, #1
	cmp ip, lr
	bne .loop

	ldr ip, [r3, #4]
	cmp ip, r4
	bne .loop

	sub r1, #0xC0000001
	add r0, r1, lsl #2
	pop {r4, pc}

.ret0:
	mov r0, #0
	pop {r4, pc}

.pEOIMin80:
	dw __EOI - 80

.sig:
	dw 0x12345678

.sig2:
	dw 0xEDCBA987