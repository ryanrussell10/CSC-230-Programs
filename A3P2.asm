.include "m2560def.inc"

; *********************************************************
; * Ryan Russell                                          *               
; * CSC 230 Assignment 3 Part 2                           *
; * Created: September 30th, 2017                         *
; * Updated: October 5th, 2017                            *
; * A3P2.asm is a program that writes decrementing        *
; * hexadecimal numbers into consecutive memory           * 
; * locations and displays each number in binary on       *
; * LEDs attached to PORT L.			                  *	  				  
; *********************************************************


; Code segment follows: 
.cseg

; Code starts here:
.def number = R16

	; number = /* choose a number in (0x00, 0x0F] */
	ldi number, 0x0F

	; count = 0
	ldi R26, low(data)
	ldi R27, high(data)

loop:
	; while (number > 0)
	cpi number, 0x00
	breq done	


	; dest[count++] = number
	st X+, number


	; * Output number on LEDs *

	; configure PORTL as output by setting DDRL
	ldi R17, 0xFF	
	sts DDRL, R17

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

	; output the number now that it is spread out on every other bit
	sts PORTL, R18
	

	; * delay 0.5 second *
			ldi r24, 0x2A	; approx. 0.5 second delay
	outer:  ldi r23, 0xFF
	middle: ldi r22, 0xFF
	inner:  dec r22
			
			brne inner 
			dec r23
			brne middle 
			dec r24
			brne outer
	
	; number --
	dec number

	rjmp loop

; Code finishes here.
; compile this file with: "C:\WinAVR\bin\avrdude" -C "C:WinAVR\bin\avrdude.conf" 
; -p atmega2560 -c wiring -P COM4 -b 115200 -D -F -U flash:w:A3P2.hex



done: jmp done

; Data segment follows:
.dseg
.org 0x200
data: .byte 22

