/* Bootloader will load this as the start symbol */
ENTRY(_start)

SECTIONS
{
	/* Sections start at 1 MiB */
	. = 1M;

	/* First is the multiboot header, otherwise bootloader won't recognise */
	.text BLOCK(4K) : ALIGN(4K)
	{
		*(.multiboot)
		*(.text)
	}

	/* Read-only data */
	.rodata BLOCK(4K) : ALIGN(4K)
	{
		*(.rodata)
	}

	/* Initialized read-write data */
	.data BLOCK(4K) : ALIGN(4K)
	{
		*(.data)
	}

	/* Uninitialized read-write data and stack */
	.bss BLOCK(4K) : ALIGN(4K)
	{
		*(COMMON)
		*(.bss)
	}

	/* Compiler may generate more sections */
}