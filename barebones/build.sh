nasm -f elf32 barebones.asm &
nasm -f elf32 barebonesKernel.asm &
nasm -f elf32 string.asm &
nasm -f elf32 terminal.asm
gcc -T linker.ld -o barebones.bin -ffreestanding -O2 -nostdlib barebones.o barebonesKernel.o string.o terminal.o -lgcc -m32