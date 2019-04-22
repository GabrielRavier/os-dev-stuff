	.text
	.globl mmio_read_u32
	.globl mmio_write_u8
	.globl mmio_write_u32
	.globl uart_init
	.globl __uart_write
	.globl uart_write
	.globl uart_write_string
	.globl prci_init
	.type mmio_read_u32, @function
	.type mmio_write_u8, @function
	.type mmio_write_u32, @function
	.type uart_init, @function
	.type __uart_write, @function
	.type uart_write, @function
	.type uart_write_string, @function
	.type prci_init, @function

mmio_read_u32:
	add a0, a0, a1
	lw a0, 0(a0)
	ret





mmio_write_u8:
mmio_write_u32:
	add a0, a0, a1
	sw a2, 0(a0)
	ret





uart_init:
	addi sp, sp, -16
	lui a0, 0xFFFD0
	addi a0, a0, -1
	lui a1, 0x10012
	lw a2, 60(a1)

	and a0, a0, a2

	sw a0, 60(a1)
	
	lw a0, 56(a1)
	
	lui a2, 48
	
	or a0, a0, a2

	sw a0, 56(a1)
	lui a0, 0x10013
	li a1, 138
	sw a1, 24(a0)

	lw a1, 8(a0)

	ori a1, a1, 1

	sw a1, 8(a0)

	sw zero, 12(sp)
	lui a0, 244
	addi a0, a0, 0x240

$uartIloop:
	lw a1, 12(sp)
	addi a2, a1, 1
	sw a2, 12(sp)
	blt a1, a0, $uartIloop

	addi sp, sp, 16
	ret





__uart_write:
	lui a1, 0x10013

$_loop:
	lw a2, 0(a1)
	bltz a2, $_loop

	lui a1, 0x10013
	sw a0, 0(a1)
	ret





uart_write:
	beqz a1, $return

	lui a2, 0x10013
	li a7, 10
	li a6, 13
	li a5, 0

$uartWloop:
	add a4, a0, a5
	lbu t0, 0(a4)

$waitUartReadyLoop:
	lw a3, 0(a2)
	bltz a3, $waitUartReadyLoop

	sw t0, 0(a2)
	lbu a3, 0(a4)
	bne a3, a7, $notEndl

$waitUartReadyLoop2:
	lw a3, 0(a2)
	bltz a3, $waitUartReadyLoop2

	sw a6, 0(a2)

$notEndl:
	addi a5, a5, 1
	bne a5, a1, $uartWloop

$return:
	ret





uart_write_string:
	addi sp, sp, -16
	sw ra, 12(sp)
	sw s0, 8(sp)
	add s0, zero, a0

	call strlen
	add a1, zero, a0
	add a0, zero, s0
	lw s0, 8(sp)
	lw ra, 12(sp)
	addi sp, sp, 16
	tail uart_write
	




prci_init:
	lui a0, 0x10008
	lw a1, 0(a0)
	lui a2, 0x40000
	
	or a1, a1, a2
	sw a1, 0(a0)

	lw a1, 8(a0)
	lui a2, 0x60
	or a1, a1, a2
	sw a1, 8(a0)

	lui a1, 0x10
	lw a2, 8(a0)
	or a1, a1, a2
	sw a1, 8(a0)

	lui a1, 0xC0000
	li a1, -1

	lw a2, 0(a0)
	and a1, a1, a2
	sw a1, 0(a0)
	
	ret
