
	code32

	format ELF
	public _entry
	public _kSerDbgPutc
	public _arm4CpsrGet
	public _arm4CpsrSet

section '.text' executable align 16

_entry:
	mov sp, #0x4000
	mov r1, #0x16000000
	mov r2, #65
	str r2, [r1]
	bl _start





_kSerDbgPutc:
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





_arm4CpsrGet:
	mrs r0, cpsr
	bx lr





_arm4CpsrSet:
	msr cpsr, r0
	bx lr
