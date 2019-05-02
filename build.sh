MIPSEL_AS=mipsel-unknown-linux-gnu-as
RISCV_AS=riscv-unknown-linux-gnu-as

assembleX86()
{
	nasm -f elf32 ${1}
}

assembleARM()
{
	fasmarm ${1}
}

assembleGAS()
{
	$1 $2 -o `basename $2 .asm`.o
}

assembleMIPSEL()
{
	assembleGAS $MIPSEL_AS $1
}

assembleRISCV()
{
	assembleGAS $RISCV_AS $1
}

assembleX86 CPUReset.asm &
assembleX86 8259PIC.asm &
assembleX86 AHCI.asm &
assembleX86 AMDPCNET.asm &
assembleX86 APIC.asm &
assembleARM ARMIntegratorCPBareBonesPutcPuts.asm &
assembleARM ARMIntegratorCPIRQTimerAndPIC.asm &
assembleARM ARMIntegratorCPIRQTimerAndPICAndTaskSwitch.asm &
assembleARM ARMIntegratorCPIRQTimerPICTasksMMAndMods.asm &
assembleARM ARMIntegratorCPITPTMMEPhase2.asm &
assembleARM ARMString.asm &
assembleX86 ATAPI.asm &
assembleMIPSEL CREBareBonesPrint.asm &
assembleX86 CMOS.asm &
assembleX86 CPUID.asm &
assembleX86 CRC32.asm &
assembleX86 DetectColorMonochromeMonitor.asm &
assembleX86 DrawProtectedMode.asm &
assembleX86 FPU.asm &
assembleX86 GamePort.asm &
assembleRISCV HiFiveBareBonesUtils.asm &
assembleX86 InlineAssemblyExamples.asm &
assembleX86 JulianDayNumber.asm