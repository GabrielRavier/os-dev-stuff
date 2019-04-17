	.text

	.globl _putchar
	.globl _printk
	.type _putchar, @function
	.type _printk, @function

_putchar:
	sll $4, 24
	sra $4, 24
	li $3, 0xB0400000

$puLoop:
	lw $2, 0xB14($3)
	nop

	andi $2, 0x20
	beq $2, $0, $puLoop

	li $2, 0xB0400000

	sw $4, 0xB00($2)
	j $31
	nop





_printk:
	addiu $sp, -32
	sw $16, 24($sp)
	sw $31, 28($sp)
	move $16, $4

	lb $4, 0($4)
	nop

	beq $4, $0, $prReturn
	nop

$prLoop:
	jal _putchar
	addiu $16, 1

	lb $4, 0($16)
	nop

	bne $4, $0, $prLoop
	nop

$prReturn:
	lw $31, 28($sp)
	lw $16, 24($sp)
	
	j $31
	addiu $sp, 32
