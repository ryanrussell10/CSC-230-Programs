; CSC 230 Assignment 6 Part 1 Programming
; Interrupt Programming
;
; YOUR NAME GOES HERE:  Ryan Russell
; Date: November 29th, 2017
; Description: This program flashes one LED once per second, flashes another
; LED 3 times per second, and flashes a third LED 5 times per second.

.equ PORTB = 0x25
.equ DDRB = 0x24
.equ PORTL = 0x10B
.equ DDRL = 0x10A
.equ SPH=0x5E
.equ SPL=0x5D

; First timer
.equ TCCR1A = 0x80
.equ TCCR1B = 0x81
.equ TCCR1C = 0x82
.equ TCNT1H = 0x85
.equ TCNT1L = 0x84
.equ TIFR1  = 0x36
.equ TIMSK1 = 0x6F
.equ SREG	= 0x5F

.def temp5 = r20
.def temp3 = r19
.def temp1 = r18

.org 0x0000
	jmp setup

.org 0x0028
	jmp timer1_isr
    
.org 0x0050
	
setup:
	; Initializes SP
	ldi r16, high(0x21FF)
	sts SPH, r16
	ldi r16, low(0x21FF)
	sts SPL, r16

	; Sets PORTL for output
	ldi r16, 0xFF
	sts DDRL, r16
	sts DDRB, r16

	; Turns on one LED
	ldi temp5, 3
	ldi temp3, 5
	ldi temp1, 15

	call timer_init

done: rjmp done


; This subroutine first runs once while interrupts are disabled.
; Interrupts are then enabled at the end.
timer_init:

	ldi r16, 0x00
	sts TCCR1A, r16

	ldi r16, 0b00000011	
	sts TCCR1B, r16

	; Set timer counter to 57202, leaving 8333 ticks until overflow.
	; This is equivalent to 1/30 second:
	; 16000000/64/30 = 0xFFFF - 57202
	ldi r16, 0xDF
	sts TCNT1H, r16 	; High
	ldi r16, 0x72
	sts TCNT1L, r16		; Low

	; Enable timer interrupts (CPU interrupt on overflow)
	ldi r16, 0x01
	sts TIMSK1, r16

	; Enable CPU interrupts
	sei

	ret


timer1_isr:

	push r16
	push r17
	lds r16, SREG
	push r16

	dec temp1
	dec temp3
	dec temp5

	; Compare the 1 flash per second counter
	compare1: 
		cpi temp1, 0
		brne compare3
		lds r16, PORTL
		ldi r17, 0b00000010
		eor r16, r17
		sts PORTL, r16
		ldi temp1, 15

	; Compare the 3 flash per second counter
	compare3:
		cpi temp3, 0 
		brne compare5
		lds r16, PORTB
		ldi r17, 0b00001000
		eor r16, r17
		sts PORTB, r16
		ldi temp3, 5

	; Compare the 5 flash per second counter
	compare5: 
		cpi temp5, 0 
		brne reset
		lds r16, PORTB
		ldi r17, 0b00000010
		eor r16, r17
		sts PORTB, r16
		ldi temp5, 3	

	reset:		
		; Reset timer counter to 57202, to make it 1/30 second exactly
		ldi r16, 0xDF
		sts TCNT1H, r16 	; High
		ldi r16, 0x72
		sts TCNT1L, r16		; Low
		
	; Pop it all off
	pop r16
	sts SREG, r16
	pop r17
	pop r16
	reti