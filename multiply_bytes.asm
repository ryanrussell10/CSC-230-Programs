.include "m2560def.inc"

; *********************************************************
; * CSC 230 Assignment 5 Part 1                           *
; * Created: November 3rd, 2017                           *
; * Updated: November 6th, 2017                           *
; * multiply_bytes.asm is a program that defines a macro  *
; * that takes 4 arguments in 4 registers representing    * 
; * two 16-bit integers and places the result of adding   *
; * them together into 2 of the registers.                *	  				  
; *********************************************************

.equ SPHI = 0x5E
.equ SPLO = 0x5D


.MACRO Addw

	add @0, @2
	add @1, @3

.ENDMACRO

.cseg

; word multiply (byte factor, byte multiplier) {

; defines and loads two registers with placeholder
; values used when multiplication results in overflow
.def zero = R19
.def one = R20
ldi zero, 0x00
ldi one, 0x01

; defines and loads the function arguments
.def factor = R17
.def multiplier = R18
ldi factor, 0xFF
ldi multiplier, 0x02

; word answer = 0
.def result_low = R24
.def result_high = R25
ldi result_low, 0x00
ldi result_high, 0x00

; pushes the function arguments to the stack
push factor
push multiplier

; calls the multiplication function
rcall multiplication

; pops the function arguments afterwards
pop factor
pop multiplier

done: jmp done



; word multiply (byte factor, byte multiplier) {
; while (factor-- > 0) answer += multiplier
multiplication:
	; protect all the registers that will be used
	push ZL
	push ZH
	push R0
	push R1

	; load the contents of the stack pointer into register Z
	lds ZH, SPHI
	lds ZL, SPLO

	; load the parameters that were pushed on the stack
	ldd R0, Z+9
	ldd R1, Z+8
	
	; transfer parameters to functions which will be operated on
	mov R22, R0
	mov R23, R1

	; while (factor-- > 0) answer += multiplier
	loop:
		cpi R23, 0x00
		breq complete
	
		; if no overflow occurs, add regularly
		no_overflow:
			Addw result_high, result_low, zero, R22
			brcs is_overflow
			rjmp decrement
	
		; if overflow occurs, must add with the carried one
		is_overflow:
			Addw result_high, result_low, one, zero
			rjmp decrement
	
		; decrement the multiplier
		decrement: 
			dec R23
			rjmp loop


		; return answer
		complete:
			pop R0
			pop R1
			pop ZH
			pop ZL
			ret




