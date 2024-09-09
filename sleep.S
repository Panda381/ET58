; ****************************************************************************
;
;                                 Sleep mode
;
; ****************************************************************************

#include "include.inc"

	.text

.global PCINT2_vect
PCINT2_vect:

	push	r24

	ldi	r24,0

; ----- disable power-down mode

	sts	SMCR,r24

; ----- disable pin change wakeup

	sts	PCICR,r24
	sts	PCMSK2,r24

; ----- disable unused units (TWI0, TIMER2, SPI, USART)

	ldi	r24,BIT(PRTWI)+BIT(PRTIM2)+BIT(PRSPI)+BIT(PRUSART0)
	sts	PRR,r24

	pop	r24
	reti

; ----------------------------------------------------------------------------
;                          Going to sleep
; ----------------------------------------------------------------------------

.global GoSleep
GoSleep:

; ----- stop programming mode

	CLR_PROGRAM		; clear programming

; ----- stop program

	IF_RUNNING		; if running
	rcall	StopProg	; stop program

; ----- wait until no key pressed

2:	ldd	r24,Y+DATA_KEYRAW
	cpi	r24,NOKEY
	brne	2b

; ----- terminate keyboard
; DESTROYS: -
	call	KEY_Term

; ----- stop generator of LCD contrast control

	out	_SFR_IO_ADDR(TCCR0A),R_ZERO
	out	_SFR_IO_ADDR(TCCR0B),R_ZERO

; ----- enable pin change wakeup from PCINT23 from PD7, PCIE2 (button CLR on COL5=PC3 and ROW2=PD7)

	ldi	r24,BIT(PCIE2)
	sts	PCICR,r24		; pin change interrupt 2
	ldi	r24,B7
	sts	PCMSK2,r24		; 

; ----- reset port B
; PB0: ROW4 input pull-up
; PB1: ROW6 input pull-up
; PB2: COL2 input
; PB3: ROW8 input pull-up
; PB4: ROW1 input pull-up
; PB5: COL3 input
; PB6: RS output LOW
; PB7: LCD output HIGH

	out	_SFR_IO_ADDR(PORTB),R_ZERO ; set pull-ups and outputs of port B
	out	_SFR_IO_ADDR(DDRB),R_ZERO ; no outputs

; ----- reset port C (set COL5 to LOW output)
; PC0: ROW9 input pull-up
; PC1: COL4 input
; PC2: ROW7 input pull-up
; PC3: COL5 input
; PC4: ROW5 input pull-up
; PC5: ROW3 input pull-up

	out	_SFR_IO_ADDR(PORTC),R_ZERO ; all LOW, no pull-ups
	ldi	r24,B3			; COL5 will be output
	out	_SFR_IO_ADDR(DDRC),r24	; set COL5 output

; ----- reset port D (set ROW2 to pull-up input)
; PD0: DB7 output LOW
; PD1: DB6 output LOW
; PD2: DB5 output LOW
; PD3: DB4 output LOW
; PD4: E output LOW
; PD5: COL1 input
; PD6: VO2 output LOW (OC0A)
; PD7: ROW2 input pull-up

	ldi	r24,B7			; only ROW2 is pull-ups
	out	_SFR_IO_ADDR(PORTD),r24 ; set pull-ups and outputs of port D
	out	_SFR_IO_ADDR(DDRD),R_ZERO ; set outputs

; ----- disable BOD

	ldi	r24,BIT(BODS)+BIT(BODSE) ; disable BOD, prepare
	ldi	r25,BIT(BODS)	; disable BOD
	sts	MCUCR,r24
	sts	MCUCR,r25

; ----- disable timers and ADC

	ldi	r24,BIT(PRTWI)+BIT(PRTIM2)+BIT(PRTIM0)+BIT(PRTIM1)+BIT(PRSPI)+BIT(PRUSART0)+BIT(PRADC)
	sts	PRR,r24

; ----- going to power-down mode

	ldi	r24,BIT(SE)
	sts	SMCR,r24
	ldi	r24,BIT(SE) + BIT(SM1)
	sts	SMCR,r24

; ----- sleep, until wake-up from CLR button

	sei		; enable interrupts
	sleep
	cli		; disable interrupts

; ----- disable unused units (TWI0, TIMER2, SPI, USART), enable Timer0 and Timer1

	ldi	r24,BIT(PRTWI)+BIT(PRTIM2)+BIT(PRSPI)+BIT(PRUSART0)+BIT(PRADC)
	sts	PRR,r24

; ----- disable power-down mode

	sts	SMCR,R_ZERO

; ----- disable pin change wakeup

	sts	PCICR,R_ZERO
	sts	PCMSK2,R_ZERO

; ----- initialize stack

	ldi	r24,lo8(STACK)	; end of stack (= last byte of RAM)
	ldi	r25,hi8(STACK)
	out	_SFR_IO_ADDR(SPH),r25
	out	_SFR_IO_ADDR(SPL),r24

; ----- initialize ports

	call	PortInit

; ----- some wait

	rcall	Wait250ms

; ----- Restore LCD display

	rcall	LCD_Restore

; ----- initialize keyboard
; DESTROYS: R24
	call	KEY_Init

; ----- display current state

	sei
	call	Disp

; ----- wait until no key pressed

	rcall	Wait100ms
2:	ldd	r24,Y+DATA_KEYRAW
	cpi	r24,NOKEY
	brne	2b
	std	Y+DATA_KEYSAVE,r24
	std	Y+DATA_KEY,r24

; ----- soft reset

	jmp	Restart
