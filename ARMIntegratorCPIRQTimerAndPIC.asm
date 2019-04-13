
	code32

	format ELF
	public _entry
	public _kSerDbgPutc
	public _arm4CpsrGet
	public _arm4CpsrSet
	public _arm4XrqEnableFiq
	public _kExpHandler
	public _kExpHandlerIrqEntry

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





_arm4XrqEnableFiq:
	mrs r3, cpsr
	bic r3, #0x40
	msr cpsr, r3
	bx lr





_arm4XrqEnableIrq:
	mrs r3, cpsr
	bic r3, #0x80
	msr cpsr, r3
	bx lr





_kExpHandler:
	push {r4, r5, r6, lr}
	mov r4, r1
	mov r5, r0

	mov r0, #72
	bl _kSerDbgPutc

	mov r3, #0x13000000
	mov r2, #1
	cmp r4, #2
	str r2, [r3, #12]
	beq .gotXrqSwint

	sub r4, #6
	cmp r4, #1
	popls {r4, r5, r6, pc}

	mov r0, #33
	bl _kSerDbgPutc

.infLoop:
	b .infLoop

.gotXrqSwint:
	ldrh r3, [r5, #-4]
	cmp r3, #4
	popne {r4, r5, r6, pc}

	mov r0, #64
	pop {r4, r5, r6, lr}
	b _kSerDbgPutc





_kExpHandlerIrqEntry:
	mov sp, #0x4000
	sub lr, #4
	
	push {lr}
	push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}

	mov r0, lr
	mov r1, #6

	bl _kExpHandler

	pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}
	ldm sp!, {pc}^