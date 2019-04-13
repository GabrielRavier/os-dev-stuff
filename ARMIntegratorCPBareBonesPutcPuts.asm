
	code32

	format ELF
	public _putc
	public _puts

section '.text' executable align 16

_putc:
	mov r2, #0x16000000

.loop:
	ldr r3, [r2, #24]
	tst r3, #32
	bne .loop

	cmp r0, #10
	str r0, [r2]
	bxne lr

	mov r0, #13
	b .loop





_puts:
	push {r4, lr}
	mov r4, r0

	ldrb r0, [r0]
	cmp r0, #0
	popeq {r4, pc}

.loop:
	bl _putc
	ldrb r0, [r4, #1]!

	cmp r0, #0
	bne .loop
	
	pop {r4, pc}