	.text
	.globl mmio_read_u32
	.type mmio_read_u32, @function

mmio_read_u32:
	add a0, a0, a1
	lw a0, 0(a0)
	ret
