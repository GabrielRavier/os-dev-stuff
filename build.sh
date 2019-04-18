MIPSEL_AS=mipsel-unknown-linux-gnu-as

nasm -f elf32 CPUReset.asm &
nasm -f elf32 8259PIC.asm &
nasm -f elf32 AHCI.asm &
nasm -f elf32 AMDPCNET.asm &
nasm -f elf32 APIC.asm &
fasmarm ARMIntegratorCPBareBonesPutcPuts.asm &
fasmarm ARMIntegratorCPIRQTimerAndPIC.asm &
fasmarm ARMIntegratorCPIRQTimerAndPICAndTaskSwitch.asm &
fasmarm ARMIntegratorCPIRQTimerPICTasksMMAndMods.asm &
fasmarm ARMIntegratorCPITPTMMEPhase2.asm &
fasmarm ARMString.asm &
nasm -f elf32 ATAPI.asm &
$MIPSEL_AS CREBareBonesPrint.asm -o CREBareBonesPrint.o 
nasm -f elf32 CMOS.asm &
nasm -f elf32 CPUID.asm &
nasm -f elf32 CRC32.asm &
nasm -f elf32 DetectColorMonochromeMonitor.asm &
nasm -f elf32 DrawProtectedMode.asm &
nasm -f elf32 FPU.asm