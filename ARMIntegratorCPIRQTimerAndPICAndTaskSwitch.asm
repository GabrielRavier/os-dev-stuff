
	code32

	format ELF
	public _entry
	public _kSerDbgPutc
	public _kSerDbgPuts
	public _itoh
	public _ksprintf
	public _arm4CpsrGet
	public _arm4SpsrGet
	public _arm4CpsrSet
	public _arm4XrqEnableFiq
	public _kExpHandler
	public _kExpHandlerIrqEntry
	public _kExpHandlerFiqEntry
	public _kExpHandlerResetEntry
	public _kExpHandlerUndefEntry
	public _kExpHandlerAbrtPEntry
	public _kExpHandlerAbrtDEntry
	public _kExpHandlerSwiEntry
	public _arm4XrqInstall
	public _start

section '.rodata' align 16

	aAllHex db '0123456789ABCDEF', 0

	aPicmmioArrIdx db 'picmmio[PIC_IRQ_STATUS]:%x', 12, 10

	aKtlrThreadNdx db 'kt->lr:%x threadndx:%x', 12, 10

	aThreadNdxSpPcLr db '<---threadndx:%x kt->sp:%x kt->pc:%x kt->lr:%x', 12, 10

	aThreadNdxPcLr db '<---threadndx:%x kt->pc:%x kt->lr:%x', 12, 10

	aSwiCpsrSpsrInfo db 'SWI cpsr:%x spsr:%x code%x', 12, 10

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





_kSerDbgPuts:
	push {r4, lr}
	mov r4, r0

	ldrb r0, [r0]
	cmp r0, #0
	popeq {r4, pc}

.loop:
	bl _kSerDbgPuts

	ldrb r0, [r4, #1]!
	cmp r0, #0
	bne .loop

	pop {r4, pc}





macro toByte where
{
	and where, #0xF
}
_itoh:
	mov r3, #32
	mov ip, #0
	
	push {r4, r5, r6, r7, lr}
	asr r2, r0, r3

	ldr r3, [.pAAllHex]
	and r2, #0xF
	ldrb r7, [r3, r2]

	asr r4, r0, #24
	asr lr, r0, #20
	asr r2, r0, #16

	toByte r4
	toByte lr
	toByte r2

	ldrb r5, [r3, r4]
	ldrb r6, [r3, lr]
	ldrb lr, [r3, r2]

	asr r2, r0, #12
	toByte r2

	ldrb r4, [r3, r0, lsr #28]
	strb r5, [r1, #2]
	ldrb r5, [r3, r2]

	asr r2, r0, #8
	toByte r2

	strb r4, [r1, #1]
	ldrb r4, [r3, r2]

	asr r2, r0, #4
	toByte r2
	toByte r0

	ldrb r2, [r3, r2]
	ldrb r3, [r3, r0]
	strb r7, [r1]
	strb r6, [r1, #3]
	strb lr, [r1, #4]
	strb r5, [r1, #5]
	strb r4, [r1, #6]
	strb r2, [r1, #7]
	strb r3, [r1, #8]
	strb ip, [r1, #9]

	mov r0, r1
	pop {r4, r5, r6, r7, pc}

.pAAllHex:
	dw aAllHex





_ksprintf:
	push {r1, r2, r3}
	push {r4, r5, r6, r7, r8, r9, r10, fp, lr}
	sub sp, #264
	ldr r4, [sp, #300]

	add r2, sp, #304
	ldrb r3, [r4]
	str r2, [sp, #4]

	cmp r3, #0
	beq .retR0

	mov r8, r0
	mov r5, #0
	mov r6, r0

	mov r10, #10
	rsb r9, r0, #2
	b .startLoop

.notPercent:
	mov r2, r7
	add r5, #1
	strb r3, [r6]
	add r6, r8, r5
	mov r7, r4
	mov fp, r6
	mov r4, r2

.continue:
	ldrb r3, [r7, #1]
	cmp r3, #0
	beq .return


.startLoop:
	cmp r3, #92
	add r7, r4, #1
	mov fp, r6
	beq .gotBackSlash

	cmp r3, #37
	bne .notPercent

	ldrb r2, [r4, #1]
	add r4, #2
	cmp r2, #99
	beq .gotC
	bls .more

	cmp r2, #115
	beq .gotS

	cmp r2, #120
	bne .continue

	ldr r3, [sp, #4]
	add r1, sp, #8
	add r2, r3, #4
	ldr r0, [r3]
	str r2, [sp, #4]
	bl _itoh

	ldrb r2, [r0]
	cmp r2, #0
	beq .continue

	sub r5, #1
	add r3, r8, r5

.loop:
	add r5, r9, r3
	strb r2, [r3, #1]!
	ldrb r2, [r0, #1]!
	cmp r2, #0
	bne .loop

.beforeContinue:
	add r6, r8, r5
	mov fp, r6

.continue2:
	ldrb r3, [r7, #1]
	cmp r3, #0
	bne .startLoop

.return:
	mov r3, #0
	strb r3, [fp]

	add sp, #264
	pop {r4, r5, r6, r7, r8, r9, r10, fp, lr}
	add sp, #12
	bx lr

.more:
	cmp r2, #37
	addeq r5, #1
	strbeq r3, [r6]
	bne .continue

	add r6, r8, r5
	mov fp, r6
	b .continue2

.gotBackSlash:
	ldrb r3, [r4, #1]
	add r4, #2
	cmp r3, #110

	addeq r5, #1
	strbeq r10, [r6]
	addeq r6, r8, r5
	moveq fp, r6
	b .continue

.gotS:
	ldr r3, [sp, #4]
	ldr r1, [r3]
	add r3, #4
	ldrb r2, [r1]
	str r3, [sp, #4]

	cmp r2, #0
	beq .continue

	sub r5, #1
	add r3, r8, r5

.loop2:
	add r5, r9, r3
	strb r2, [r3, #1]!
	ldrb r2, [r1, #1]!
	cmp r2, #0
	bne .loop2
	b .beforeContinue

.gotC:
	ldr r3, [sp, #4]
	add r5, #1

	ldr r2, [r3]
	add r3, #4

	strb r2, [r6]
	add r6, r8, r5
	
	str r3, [sp, #4]
	mov fp, r6
	b .continue

.retR0:
	mov fp, r0
	b .return





_arm4CpsrGet:
	mrs r0, cpsr
	bx lr





_arm4SpsrGet:
	mrs r0, spsr
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
	push {r4, r5, lr}
	mov r4, r1
	sub sp, #140
	mov r5, r0

	mov r0, #72
	bl _kSerDbgPutc

	cmp r4, #6
	beq .gotIRQ

	cmp r4, #2
	beq .gotSWINT

	sub r4, #6
	cmp r4, #1
	bhi .notFIQSWINTIRQ

.return:
	add sp, #140
	pop {r4, r5, pc}

.notFIQSWINTIRQ:
	mov r0, #33
	bl _kSerDbgPutc

.infLoop:
	b .infLoop

.gotIRQ:
	mov r4, #0x14000000
	add r0, sp, #8
	ldr r2, [r4]
	ldr r1, [.pAPicmmioArrIdx]
	bl _ksprintf

	add r0, sp, #8
	bl _kSerDbgPuts

	ldr r3, [r4]
	tst r3, #0x20
	beq .return

	mov r5, #0x1000
	mov r2, #0x13000000
	mov r1, #1
	ldrb r3, [r5, #0x481]
	str r1, [r2, #12]
	
	cmp r3, #0
	beq .iSwitch0

.after0:
	mov r3, #0x1000
	mov r1, #0
	ldrb r2, [r3, #0x480]
	strb r1, [r3, #0x481]
	add r4, r2, r2, lsl #3
	lsl r4, #3
	add r4, r3
	ldr r1, [r4, #60]
	ldr r3, [r4, #68]
	add r0, sp, #8
	str r1, [sp]
	ldr r1, [.pAThreadNdxPcLr]
	bl _ksprintf

	add r0, sp, #8
	bl _kSerDbgPuts

	mov r3, #0x2000
	ldr r2, [r4, #68]
	str r2, [r3, #0xFFC]

	ldr r2, [r4, #52]
	str r2, [r3, #0xFF8]

	ldr r2, [r4, #48]
	str r2, [r3, #0xFF4]

	ldr r2, [r4, #44]
	str r2, [r3, #0xFF0]

	ldr r2, [r4, #40]
	str r2, [r3, #0xFEC]

	ldr r2, [r4, #36]
	str r2, [r3, #0xFE8]

	ldr r2, [r4, #32]
	str r2, [r3, #0xFE4]

	ldr r2, [r4, #28]
	str r2, [r3, #0xFE0]

	ldr r2, [r4, #24]
	str r2, [r3, #0xFDC]

	ldr r2, [r4, #20]
	str r2, [r3, #0xFD8]

	ldr r2, [r4, #16]
	str r2, [r3, #0xFD4]

	ldr r2, [r4, #12]
	str r2, [r3, #0xFD0]

	ldr r2, [r4, #8]
	str r2, [r3, #0xFCC]

	ldr r2, [r4, #4]
	str r2, [r3, #0xFC8]

	ldr r2, [r4, #64]
	str r2, [r3, #0xFC4]

	ldr r3, [r4, #56]
	ldr r2, [r4, #60]

	mrs r0, cpsr
	bic r0, #0x1F
	orr r0, #0x1F
	msr cpsr, r0

	mov sp, r3
	mov lr, r2

	bic r0, #0x1F
	orr r0, #0x12
	msr cpsr, r0

	b .return

.gotSWINT:
	ldrh r1, [r5, #-4]
	cmp r1, #4
	bne .return

	mrs r2, cpsr
	mrs r3, spsr

	str r1, [sp]
	add r0, sp, #8
	ldr r1, [.pASwiCpsrSpsrInfo]
	bl _ksprintf

	add r0, sp, #8
	bl _kSerDbgPuts

	mov r0, #64
	bl _kSerDbgPutc
	b .return

.iSwitch0:
	mov r0, #0x2000
	ldrb r3, [r5, #0x480]
	ldr r2, [r0, #0xFFC]
	add r4, r3, r3, lsl #3
	lsl r4, #3
	add r4, r5
	str r2, [r4, #68]

	ldr r2, [r0, #0xFF8]
	str r2, [r4, #52]

	ldr r1, [r0, #0xFF4]
	ldr r2, [r4, #60]
	str r1, [r4, #48]
	
	ldr ip, [r0, #0xFF0]
	ldr r1, [.pAKtLrThreadNdx]
	str ip, [r4, #44]

	ldr ip, [r0, #0xFEC]
	str ip, [r4, #40]
	
	ldr ip, [r0, #0xFE8]
	str ip, [r4, #36]
	
	ldr ip, [r0, #0xFE4]
	str ip, [r4, #32]
	
	ldr ip, [r0, #0xFE0]
	str ip, [r4, #28]
	
	ldr ip, [r0, #0xFDC]
	str ip, [r4, #24]
	
	ldr ip, [r0, #0xFD8]
	str ip, [r4, #20]
	
	ldr ip, [r0, #0xFD4]
	str ip, [r4, #16]
	
	ldr ip, [r0, #0xFD0]
	str ip, [r4, #12]
	
	ldr ip, [r0, #0xFCC]
	str ip, [r4, #8]
	
	ldr ip, [r0, #0xFC8]
	str ip, [r4, #4]
	
	ldr ip, [r0, #0xFC4]
	add r0, sp, #8
	str ip, [r4, #64]
	bl _ksprintf
	
	add r0, sp, #8
	bl _kSerDbgPuts

	mrs r0, cpsr
	bic r0, #0x1F
	orr r0, #0x1F
	msr cpsr, r0

	mov r3, sp
	mov r1, lr
	bic r0, #0x1F
	orr r0, #0x12
	msr cpsr, r0

	mov r3, sp
	mov r1, lr
	bic r0, #0x1F
	orr r0, #0x12
	msr cpsr, r0

	str r3, [r4, #56]
	str r1, [r4, #60]

	ldr r3, [r4, #68]
	ldrb r2, [r5, #1152]
	add r0, sp, #8
	str r1, [sp]
	ldr r1, [.pAThreadNdxSpPcLr]
	bl _ksprintf

	add r0, sp, #8
	bl _kSerDbgPuts

	ldrb r3, [r5, #0x481]
	cmp r3, #0
	bne .after0

	ldrb r3, [r5, #0x480]
	add r3, #1
	toByte r3
	add r2, r3, r3, lsl #3
	lsl r2, #3
	strb r3, [r5, #0x480]
	add r2, r5

	ldrb r2, [r2]
	cmp r2, #0
	bne .after0

.loop:
	add r3, #1
	toByte r3
	add r2, r3, r3, lsl #3
	lsl r2, #3
	add r2, #0x1000
	ldrb r2, [r2]
	cmp r2, #0
	beq .loop

	strb r3, [r5, #0x480]
	b .after0

.pAKtLrThreadNdx:
	dw aKtlrThreadNdx

.pASwiCpsrSpsrInfo:
	dw aSwiCpsrSpsrInfo

.pAPicmmioArrIdx:
	dw aPicmmioArrIdx

.pAThreadNdxSpPcLr:
	dw aThreadNdxSpPcLr

.pAThreadNdxPcLr:
	dw aThreadNdxPcLr





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





_kExpHandlerFiqEntry:
	mov sp, #0x4000
	sub lr, #4
	
	push {lr}
	push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}

	mov r0, lr
	mov r1, #7

	bl _kExpHandler

	pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}
	ldm sp!, {pc}^





_kExpHandlerResetEntry:
	mov sp, #0x4000
	sub lr, #4
	
	push {lr}
	push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}

	mov r0, lr
	mov r1, #0

	bl _kExpHandler

	pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}
	ldm sp!, {pc}^





_kExpHandlerUndefEntry:
	mov sp, #0x4000
	sub lr, #4
	
	push {lr}
	push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}

	mov r0, lr
	mov r1, #1

	bl _kExpHandler

	pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}
	ldm sp!, {pc}^





_kExpHandlerAbrtPEntry:
	mov sp, #0x4000
	sub lr, #4
	
	push {lr}
	push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}

	mov r0, lr
	mov r1, #3

	bl _kExpHandler

	pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}
	ldm sp!, {pc}^





_kExpHandlerAbrtDEntry:
	mov sp, #0x4000
	sub lr, #4
	
	push {lr}
	push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}

	mov r0, lr
	mov r1, #4

	bl _kExpHandler

	pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}
	ldm sp!, {pc}^





_kExpHandlerSwiEntry:
	mov sp, #0x4000
	
	push {lr}
	push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}

	mov r0, lr
	mov r1, #2

	bl _kExpHandler

	pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12}
	ldm sp!, {pc}^





_arm4XrqInstall:
	add r0, #2
	lsl r0, #2
	sub r1, r0
	lsr r1, #2
	orr r1, 0xEA000000
	str r1, [r0, #-8]
	bx lr





_start:
	push {r4, lr}

	ldr r1, [.dat]
	mov r0, #0
	bl _arm4XrqInstall

	ldr r1, [.dat + 4]
	mov r0, #1
	bl _arm4XrqInstall

	ldr r1, [.dat + 8]
	mov r0, #2
	bl _arm4XrqInstall

	ldr r1, [.dat + 12]
	mov r0, #3
	bl _arm4XrqInstall

	ldr r1, [.dat + 16]
	mov r0, #4
	bl _arm4XrqInstall

	ldr r1, [.dat + 20]
	mov r0, #6
	bl _arm4XrqInstall

	ldr r1, [.dat + 24]
	mov r0, #7
	bl _arm4XrqInstall

	mov r0, #90
	bl _kSerDbgPutc

	swi #4

	mrs r3, cpsr
	bic r3, #0x80
	msr cpsr, r3

	mov r3, #0x13000000
	mvn r2, #0xFF000000
	
	mov ip, #0x14000000
	mov lr, #0xE0
	mvn r1, #0

	str lr, [ip, #8]
	str r0, [r3, #8]
	str r1, [r3, #12]

	mov r0, #75
	str r2, [r3]
	str r2, [r3, #24]
	bl _kSerDbgPutc

	mov r0, #10
	bl _kSerDbgPutc

.infLoop:
	b .infLoop

.dat:
	dw _kExpHandlerResetEntry
	dw _kExpHandlerUndefEntry
	dw _kExpHandlerSwiEntry
	dw _kExpHandlerAbrtPEntry
	dw _kExpHandlerAbrtDEntry
	dw _kExpHandlerIrqEntry
	dw _kExpHandlerFiqEntry