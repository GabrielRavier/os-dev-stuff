%ifndef MACROS_INC
%define MACROS_INC

; bool value definitions
%define false 0
%define true 1
%define FALSE false
%define TRUE true

%define nullptr 0
%define NULL nullptr

; Push multiple values (from left to right)
%macro multipush 2-*

	%rep %0	; Repeat number of arguments times
		push %1	; Push next argument
		%rotate 1	; Rotate all arguments to the left
	%endrep
	
%endmacro

; Pop to multiple (from right to left)
%macro multipop 2-*

	%rep %0	; Repeat number of arguments times
		%rotate -1	; Rotate all arguments to the right
		pop %1	; Pop next argument
	%endrep

%endmacro

; Make a prologue (this is a fuse of multipush and a sub esp, x)
%macro prolog 2-*

	%rep (%0)-1	; Repeat number of arguments times minus 1
		push %1	; Push next argument
		%rotate 1	; Rotate all arguments to the left
	%endrep

	sub esp, %1	; Sub size of stack from esp

%endmacro

; Make an epilog (this is a fuse of multipop and a add esp, x)
%macro epilog 2-*

	%rotate -1
	add esp, %1

	%rep (%0)-1	; Repeat number of arguments times minus 1
		%rotate -1	; Rotate all arguments to the right
		pop %1	; Pop next argument
	%endrep

%endmacro

; Zero a thing
%macro zero 1
	xor %1, %1
%endmacro

; Zero multiple things
%macro multizero 2-*

	%rep %0
		zero %1
		%rotate 1
	%endrep

%endmacro

; Mov multiple times in a row (from left to right)
%macro multimov 2-*

	%rep (%0/2)	; Repeat number of arguments / 2
		mov %1, %2	; Mov next arguments
		%rotate 2	; Rotate all arguments to the left twice
	%endrep

%endmacro

; Extensive macro to return a float
%macro makeRetFloatingPoint 4

	%3 [%1], %2
	fld %4 [%1]

%endmacro

; Return a float from xmmX through a memory location into st0
%macro retFloat 2

	makeRetFloatingPoint %1, %2, movss, dword

%endmacro

; Return a double from xmmX through a memory location into st0
%macro retDouble 2

	makeRetFloatingPoint %1, %2, movsd, qword

%endmacro

; Return a float from xmmX through a memory location into st0, in AVX
%macro retFloatAVX 2

	makeRetFloatingPoint %1, %2, vmovss, dword

%endmacro

; Return a double from xmmX through a memory location into st0, in AVX
%macro retDoubleAVX 2

	makeRetFloatingPoint %1, %2, vmovsd, qword

%endmacro

%endif