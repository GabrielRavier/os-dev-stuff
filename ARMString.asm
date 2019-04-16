
	code32
	format ELF
	public _memset

section '.text' executable align 16

_memset:	; Generically optimized
	cmp r2, #0
	bxeq lr

	sub r3, r2, #1
	cmp r3, #5
	rsb r3, r0, #0

	push {r4, r5, r6, lr}
	and r3, #3
	bls .small

	cmp r3, #0
	beq .skip

	cmp r3, #1
	strb r1, [r0]
	beq .skip

	strb r1, [r0, #1]
	strbne r1, [r0, #2]
	
	movne r4, #3
	bne .skip2

.skip:
	mov r4, r3

.skip2:
	and r5, r1, #0xFF
	sub r6, r2, r3
	orr ip, r5, r5, lsl #8
	orr ip, r5, lsl #16
	add r3, r0, r3
	bic lr, r6, #3
	orr ip, r5, lsl #24
	add lr, r3, lr

.bigLoop:
	str ip, [r3], #4
	cmp lr, r3
	bne .bigLoop

	bic r3, r6, #3
	cmp r6, r3
	add r3, r4, r3
	popeq {r4, r5, r6, pc}

.finish:
	add ip, r3, #1
	cmp r2, ip
	strb r1, [r0, r3]
	popls {r4, r5, r6, pc}

	add lr, r3, #2
	cmp r2, lr
	strb r1, [r0, ip]
	popls {r4, r5, r6, pc}

	add ip, r3, #3
	cmp r2, ip
	strb r1, [r0, lr]
	popls {r4, r5, r6, pc}

	add lr, r3, #4
	cmp r2, lr
	strb r1, [r0, ip]
	popls {r4, r5, r6, pc}

	add r3, #5
	cmp r2, r3
	strb r1, [r0, lr]
	strbhi r1, [r0, r3]
	pop {r4, r5, r6, pc}

.small:
	mov r3, #0
	b .finish





_memsetARMv2:
	cmp r2, #0
	bxeq lr

	rsb r3, r0, #0
	and r3, #3
	sub ip, r2, #1
	cmp ip, #5
	bls .small

	push {r4, r5, lr}
	cmp r3, #0
	beq .skip

	strb r1, [r0]
	cmp r3, #1
	beq .skip

	strb r1, [r0, #1]
	cmp r3, #2
	strbne r1, [r0, #2]

	movne r4, #3
	bne .skip2

.skip:
	mov r4, r3

.skip2:
	sub r5, r2, r3
	and lr, r1, #0xFF
	orr ip, lr, lr, lsl #8
	orr ip, lr, lsl #16
	orr ip, lr, lsl #24
	add r3, r0, r3
	bic lr, r5, #3
	add lr, r3, lr

.bigLoop:
	str ip, [r3], #4
	cmp lr, r3
	bne .bigLoop

	bic ip, r5, #3
	add r3, r4, ip
	cmp r5, ip
	popeq {r4, r5, pc}

	strb r1, [r0, r3]
	add ip, r3, #1
	cmp r2, ip
	popls {r4, r5, pc}

	strb r1, [r0, ip]
	add ip, r3, #2
	cmp r2, ip
	popls {r4, r5, pc}

	strb r1, [r0, ip]
	add ip, r3, #3
	cmp r2, ip
	popls {r4, r5, pc}

	strb r1, [r0, ip]
	add ip, r3, #4
	cmp r2, ip
	popls {r4, r5, pc}

	strb r1, [r0, ip]
	add r3, #5
	cmp r2, r3
	strbhi r1, [r0, r3]
	pop {r4, r5, pc}

.small:
	mov r3, #0
	strb r1, [r0, r3]
	add ip, r3, #1
	cmp r2, ip
	bxls lr
	
	strb r1, [r0, ip]
	add ip, r3, #2
	cmp r2, ip
	bxls lr
	
	strb r1, [r0, ip]
	add ip, r3, #3
	cmp r2, ip
	bxls lr
	
	strb r1, [r0, ip]
	add ip, r3, #4
	cmp r2, ip
	bxls lr

	strb r1, [r0, ip]
	add r3, #5
	cmp r2, r3
	strbhi r1, [r0, r3]
	bx lr





_memsetARMv6:
	cmp r2, #0
	bxeq lr

	sub r3, r2, #1
	cmp r3, #2
	bls .small

	str lr, [sp, #4]!
	uxtb lr, r1
	mov r3, lr
	orr lr, lr, lsl #8
	orr lr, r3, lsl #16
	bic ip, r2, #3
	orr lr, r3, lsl #24
	add ip, r0
	mov r3, r0

.bigLoop:
	str lr, [r3], #4
	cmp r3, ip
	bne .bigLoop

	bic r3, r2, #3
	cmp r2, r3
	ldreq pc, [sp], #4

	add ip, r3, #1
	cmp r2, ip
	strb r1, [r0, r3]
	ldrls pc, [sp], #4

	add r3, #2
	cmp r2, r3
	strb r1, [r0, ip]
	strbhi r1, [r0, r3]

	ldr pc, [sp], #4

.small:
	mov r3, #0
	add ip, r3, #1

	cmp r2, ip
	strb r1, [r0, r3]
	bxls lr

	add r3, #2
	cmp r2, r3

	strb r1, [r0, ip]
	strbhi r1, [r0, r3]
	bx lr
	