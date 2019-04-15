
	code32
	format ELF
	public _ll_add
	public _ll_rem
	public _ksleep
	public _kthread
	public _kidle
	extrn _kSerDbgPutc

section '.text' executable align 16

_ll_add:
	ldr r3, [r0]
	cmp r3, #0
	str r3, [r1]
	
	ldrne r3, [r3, #4]
	str r3, [r1, #4]

	str r1, [r0]
	bx lr





_ll_rem:
	ldr r2, [r1, #4]
	ldr r3, [r1]
	cmp r2, #0

	strne r3, [r2]
	ldrne r3, [r1]

	cmp r3, #0
	strne r2, [r3, #4]

	cmp r0, #0
	bxeq lr

	ldr r2, [r0]
	cmp r2, r1
	bxne lr

	ldr r2, [r1, #4]
	cmp r2, #0
	moveq r2, r3
	str r2, [r0]
	bx lr





_ksleep:
	swi #101
	bx lr





_kthread:
	push {r4, lr}
	mov r4, #0x10000
	sub r4, #1

.infLoop:
	mov r0, r4
	swi #101

	mov r0, #36
	bl _kSerDbgPutc
	b .infLoop





_kidle:
.infLoop:
	swi #102
	b .infLoop