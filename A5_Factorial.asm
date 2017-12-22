; CSC 230 Assignment 5 Part 2 Programming
; Factorial
;
; YOUR NAME GOES HERE:  Ryan Russell
; Date: November 7th, 2017
; Description: This program includes the multiply and factorial functions
; which multiply two bytes and compute the factorial of a given 
; number n in the program memory location 'init', where the arguments are passed 
; on the stack and the functions utilize the Addw MACRO. Overall, the 
; program calculates the factorial of a given n and stores the result in 
; the data memory location 'result' before displaying the lower nybble 
; of the result on PORTL.

; NOTE: The definition of "recursive function" is vague.


.include "m2560def.inc"


.equ SPHI = 0x5E
.equ SPLO = 0x5D

.cseg

;  Obtain the constant from location init
        ldi ZH, high(init<<1)
        ldi ZL, low(init<<1)
        lpm r16, Z

;***
; YOUR CODE GOES HERE:
;


; this is the Addw MACRO from Assignment 5 Part 1
.MACRO Addw

        add @1, @3
        adc @0, @2

.ENDMACRO


; register definitions
.def multiplier = R17
.def factor = R18
.def top = R19
.def n = R20
.def result_low = R21
.def result_high = R22
.def temp_register = R23
.def number = R24

ldi top, 0x00

; Initialize SP
ldi temp_register, low(RAMEND)
sts SPLO, temp_register
ldi temp_register, high(RAMEND)
sts SPHI, temp_register


mov n, R16 ; moves the loaded value from init to the register n

push n ; push the required parameters onto the stack

rcall factorial ; this function calls the multiply function within

pop n ; pop the parameters off the stack


; store the result of factorial in the result data space
sts result, result_high
sts result+1, result_low

mov number, result_low ; copy the lower byte of the result into number

rcall flash_nybble

jmp done


; This is the factorial function that performs the factorial operation
factorial:
	
	; protect the register that will be used in this function
	push ZL
	push ZH
	push multiplier
	push factor

	; load the SP into the Z register
	lds ZH, SPHI
	lds ZL, SPLO

	; load the multiplier and factor (n and n-1) using the stack
	ldd multiplier, Z+8
	ldd factor, Z+8
	dec factor

	; initialize the result to the value of n
	; this is effectively: word answer = 0
	mov result_low, multiplier 
	ldi result_high, 0x00

	; if the value of n is 1 or 2, that is the result
	cpi multiplier, 0x03
	brlo set_result

	recursive_loop:

		; put n-1 in the temporary register while performing the factorial
		mov temp_register, factor 

		rcall multiply

		; if the upper two bytes contain anything other than 0, we 
		; need to include that in the multiplication
		cpi result_high, 0x00 
		breq continue
		mov top, result_high 

		continue:

			dec factor
			cpi factor, 0x01
			brne recursive_loop

	factorial_complete:

		pop factor
		pop multiplier
		pop ZH
		pop ZL
		ret
	
	set_result:

		mov result_low, multiplier
		pop factor
		pop multiplier
		pop ZH
		pop ZL
		ret


; This is an updated (and heavily simplified) version of
; the multiply function from Assignment 5 Part 1
; word multiply (byte factor, byte multiplier) {
multiply:

	; word answer = 0 (done before inside the factorial function)
	
	; while  factor--  > 0) answer += multiplier
	Addw result_high, result_low, top, multiplier
	dec temp_register
	cpi temp_register, 0x01
	breq multiplication_complete

	rjmp multiply ; if the factor is greater than 1, continue

	; return answer
	multiplication_complete:

		mov multiplier, result_low
		ret


; This function flashes the lights corresponding to the
; lower nybble of the result
flash_nybble:
	
	; configure PORTL as output by setting DDRL
	ldi temp_register, 0xFF
	sts DDRL, temp_register

	; copy the current number to 4 registers so each 
	; bit of the number can be separated
	mov R18, number
	mov R19, number
	mov R20, number
	mov R21, number
	
	; separate every bit and shift it to the correct position for output
	cbr R18, 0xFE	; uses a mask to clear all bits except for the 1st bit
	lsl R18
	cbr R19, 0xFD	; uses a mask to clear all bits except for the 2nd bit
	lsl R19
	lsl R19
	cbr R20, 0xFB	; uses a mask to clear all bits except for the 3rd bit
	lsl R20
	lsl R20
	lsl R20
	cbr R21, 0xF7	; uses a mask to clear all bits except for the 4th bit
	lsl R21
	lsl R21
	lsl R21
	lsl R21

	; combine all the bits using OR instructions
	or R18, R21
	or R18, R20
	or R18, R19




	constant_flash:
		; output the number now that it is spread out on every other bit
		sts PORTL, R18
		rjmp constant_flash


; YOUR CODE FINISHES HERE
;****

done:   jmp done

; The constant, named init, holds the starting number.
init:   .db 0x02

; This is in the data segment (ie. SRAM)
; The first real memory location in SRAM starts at location 0x200 on
; the ATMega 2560 processor.
;
.dseg
.org 0x200

result: .byte 2




