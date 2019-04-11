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
		pop %1	; pop next argument
	%endrep

%endmacro

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