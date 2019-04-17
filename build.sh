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
nasm -f elf32 ATAPI.asm