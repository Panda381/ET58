; ****************************************************************************
;
;                                Keyboard
;
; ****************************************************************************

#include "include.inc"

	.text

; Keyboard pins:
;  PB0: ROW4
;  PB1: ROW6
;  PB2: COL2
;  PB3: ROW8
;  PB4: ROW1
;  PB5: COL3
;  PC0: ROW9
;  PC1: COL4
;  PC2: ROW7
;  PC3: COL5
;  PC4: ROW5
;  PC5: ROW3
;  PD5: COL1
;  PD7: ROW2

; COLs are 3D-LOW outputs:
;  COL1: PD5
;  COL2: PB2
;  COL3: PB5
;  COL4: PC1
;  COL5: PC3

; ROWs are pull-up intpus:
;  ROW1: PB4
;  ROW2: PD7
;  ROW3: PC5
;  ROW4: PB0
;  ROW5: PC4
;  ROW6: PB1
;  ROW7: PC2
;  ROW8: PB3
;  ROW9: PC0

; remap numeric keys
RemapDig:
	.byte	0x92 	; '0'
	.byte	0x82 	; '1'
	.byte	0x83 	; '2'
	.byte	0x84 	; '3'
	.byte	0x72 	; '4'
	.byte	0x73 	; '5'
	.byte	0x74 	; '6'
	.byte	0x62 	; '7'
	.byte	0x63 	; '8'
	.byte	0x64 	; '9'
	.byte	0x7b	; '0A'
	.byte	0x7c	; '0B'
	.byte	0x7d	; '0C'
	.byte	0x6b	; '0D'
	.byte	0x6c	; '0E'
	.byte	0x6d	; '0F'
	.balign 2
RemapDigEnd:

; ----------------------------------------------------------------------------
;                          Read keyboard rows
; ----------------------------------------------------------------------------
; INPUT: R30 = previous detected key code, 0=none, 0xff=multiply keys
;	 R31 = column
; OUTPUT: R30 = new key
;	  R31 = new column
; DESTROYS: R24
; ----------------------------------------------------------------------------
 
.global KeyInRow
KeyInRow:

; ----- short delay to stabilize signals
; DESTROYS: -
	rcall	Wait100us

; ----- prepare - no key

	ldi	r24,0x0f

; ----- detect rows (0x0f no key, 0xR0 key row)

	sbis	_SFR_IO_ADDR(PINB),4	; ROW1
	subi	r24,-0x01		; R24 <- 0x10
	sbis	_SFR_IO_ADDR(PIND),7	; ROW2
	subi	r24,-0x11		; R24 <- 0x20
	sbis	_SFR_IO_ADDR(PINC),5	; ROW3
	subi	r24,-0x21		; R24 <- 0x30
	sbis	_SFR_IO_ADDR(PINB),0	; ROW4
	subi	r24,-0x31		; R24 <- 0x40
	sbis	_SFR_IO_ADDR(PINC),4	; ROW5
	subi	r24,-0x41		; R24 <- 0x50
	sbis	_SFR_IO_ADDR(PINB),1	; ROW6
	subi	r24,-0x51		; R24 <- 0x60
	sbis	_SFR_IO_ADDR(PINC),2	; ROW7
	subi	r24,-0x61		; R24 <- 0x70
	sbis	_SFR_IO_ADDR(PINB),3	; ROW8
	subi	r24,-0x71		; R24 <- 0x80
	sbis	_SFR_IO_ADDR(PINC),0	; ROW9
	subi	r24,-0x81		; R24 <- 0x90

; ----- check no key

	cpi	r24,0x0f
	breq	8f		; no key

; ----- check if we have already some key

	tst	r30		; any key?
	brne	2f		; multiply keys

; ----- compose key code (R24 = key row 0xR0, R31 = key column 0x0C)

	mov	r30,r24		; key row
	or	r30,r31		; add key column

; ----- check if only 1 key is pressed

	andi	r24,0x0f	; number of pressed keys - 1
	breq	8f		; key is OK

; ----- flag - multiply keys

2:	ldi	r30,0xff	; flag - multiply keys

; ----- increase column

8:	inc	r31		; increase column
	ret

; ----------------------------------------------------------------------------
;                           Timer1 interrupt
; ----------------------------------------------------------------------------
; Interrupt every 10 ms

.global	TIMER1_COMPA_vect
TIMER1_COMPA_vect:

; ----- push registers

	push	r24
	in	r24,_SFR_IO_ADDR(SREG)	; status register
	push	r24
	push	r30
	push	r31

; ----- increment timer counter

	lds	r30,Time
	lds	r31,Time+1
	adiw	r30,1
	sts	Time,r30
	sts	Time+1,r31

; ----- scan keyboard (takes 500 us)
; INPUT: R30 = previous detected key code, 0=none, 0xff=multiply keys
;	 R31 = column
; OUTPUT: R30 = new key
;	  R31 = new column
; DESTROYS: R24

	clr	r30		; key code accumulator
	ldi	r31,1		; key column = 1

	sbi	_SFR_IO_ADDR(DDRD),5 ; set output to COL1
	rcall	KeyInRow	; detect keys of COL1
	cbi	_SFR_IO_ADDR(DDRD),5 ; clear output to COL1

	sbi	_SFR_IO_ADDR(DDRB),2 ; set output to COL2
	rcall	KeyInRow	; detect keys of COL2
	cbi	_SFR_IO_ADDR(DDRB),2 ; clear output to COL2

	sbi	_SFR_IO_ADDR(DDRB),5 ; set output to COL3
	rcall	KeyInRow	; detect keys of COL3
	cbi	_SFR_IO_ADDR(DDRB),5 ; clear output to COL3

	sbi	_SFR_IO_ADDR(DDRC),1 ; set output to COL4
	rcall	KeyInRow	; detect keys of COL4
	cbi	_SFR_IO_ADDR(DDRC),1 ; clear output to COL4

	sbi	_SFR_IO_ADDR(DDRC),3 ; set output to COL5
	rcall	KeyInRow	; detect keys of COL5
	cbi	_SFR_IO_ADDR(DDRC),3 ; clear output to COL5

; ----- check if exactly 1 key is pressed

	CLR_TRACE		; clear trace flag
	tst	r30		; no key?
	breq	4f		; no key - release key
	cpi	r30,0xff	; multiply keys?
	breq	4f		; multiply keys - release key
 
; ----- trace

	cpi	r30,KEY_GTO	; GTO key?
	brne	5f
	SET_TRACE		; set trace flag

; ----- check if new key is pressed

5:	lds	r31,KeyRaw	; old key
	cp	r31,r30		; is this key alreay in buffer?
	breq	2f		; key not changed
	sts	Key,r30		; output new key
2:	sts	KeyRaw,r30	; save new raw key

; ----- reset release counter

	ldi	r24,8		; release counter to time-out 80 ms
	sts	KeyCnt,r24	; set new release counter
	rjmp	8f

; ----- decrease release key counter

4:	lds	r24,KeyCnt	; key counter
	dec	r24		; decrease counter
	brmi	8f		; no key
	sts	KeyCnt,r24	; save new key counter
	brne	8f		; key is still valid

; ----- delete current key

	ldi	r24,NOKEY
	sts	KeyRaw,r24

; ----- pop registers

8:	pop	r31
	pop	r30
	pop	r24
	out	_SFR_IO_ADDR(SREG),r24
	pop	r24
	reti

; ----------------------------------------------------------------------------
;                   Initialize keyboard
; ----------------------------------------------------------------------------
; DESTROYS: R24
; ----------------------------------------------------------------------------
; Prescaler clk/64. Result interrupt frequency: 8000000/64/1250 = 4000000/64/625 = 100 Hz
; 1 timer tick = 10 ms

.global KEY_Init
KEY_Init:

; ----- Timer1: set CTC mode, prescaler 1/64

	sts	TCCR1A,R_ZERO
	ldi	r24,BIT(WGM12) + 3
	sts	TCCR1B,r24

; ----- set interval to 1250

#if F_CPU >= 6000000

	ldi	r24,hi8(1250-1)
	sts	OCR1AH,r24
	ldi	r24,lo8(1250-1)
	sts	OCR1AL,r24
	
#else

	ldi	r24,hi8(625-1)
	sts	OCR1AH,r24
	ldi	r24,lo8(625-1)
	sts	OCR1AL,r24

#endif

; ----- reset counter

	sts	TCNT1H,R_ZERO
	sts	TCNT1L,R_ZERO

; ----- Enable interrupt from Timer1 compare match

	lds	r24,TIMSK1
	ori	r24,BIT(OCIE1A)
	sts	TIMSK1,r24

; ----- clear key buffer

	ldi	r24,NOKEY
	std	Y+DATA_KEY,r24
	std	Y+DATA_KEYRAW,r24
	std	Y+DATA_KEYSAVE,r24
	ret

; ----------------------------------------------------------------------------
;               Terminate keyboard (before going to sleep)
; ----------------------------------------------------------------------------
; DESTROYS: -
; ----------------------------------------------------------------------------

.global KEY_Term
KEY_Term:

; ----- Disable interrupt from Timer1 compare match

	sts	TIMSK1,R_ZERO

; ----- stop Timer1

	sts	TCCR1A,R_ZERO
	sts	TCCR1B,R_ZERO
	ret

; ----------------------------------------------------------------------------
;         Remap 2nd key (change column 1..5 to 6..0 or A..E)
; ----------------------------------------------------------------------------
; INPUT/OUTPUT: R24 = key HEX code
; DESTROYS: R25
; ----------------------------------------------------------------------------

.global Remap2nd
Remap2nd:

; ----- check 2nd mode

	ldd	r25,Y+DATA_FLAG2ND ; current 2nd flag
	cpi	r25,F_NONE	; no 2nd
	breq	9f		; no 2nd flag

; ----- switch 2nd flag off

	std	Y+DATA_FLAG2ND,R_ZERO ; clear 2nd flag
; DESTROYS: -
	rcall	DispFlags	; display flags

; ----- prepare key

	push	r24		; push key code
	andi	r24,0x0f	; mask key column

; ----- check 3rd mode

	subi	r24,-9		; 3rd correction: +9, shift key column 1..5 to A..E
	cpi	r25,F_3RD
	breq	6f		; 3rd state

; ----- remap 2nd key

	subi	r24,4		; key column + 5, shift key column 1..5 to 6..10
	cpi	r24,10		; check key column	
	brne	6f
	clr	r24		; change column 10 to 0

; ----- add key row

6:	pop	r25		; pop key code
	andi	r25,0xf0	; mask key row
	or	r24,r25		; add key row to key code
9:	ret

; ----------------------------------------------------------------------------
;                     Read key from key buffer
; ----------------------------------------------------------------------------
; OUTPUT: R24 = hex key code (NZ brne) or Oxff no key (NOKEY, ZY breq)
;	  ZY = set if NOKEY
; DESTROYS: -
; NOTE: Enables interrupts
; ----------------------------------------------------------------------------

.global GetKey
GetKey:

; ----- push registers

	push	r25
	push	r30
	push	r31

; ----- get saved key

1:	ldi	r25,NOKEY
	ldd	r24,Y+DATA_KEYSAVE
	std	Y+DATA_KEYSAVE,r25
	cp	r24,r25
	brne	9f	; valid key

; ----- get key

	cli		; disable interrupts
	ldd	r24,Y+DATA_KEY
	std	Y+DATA_KEY,r25
	sei		; enable interrupts
	cp	r24,r25
	breq	9f	; no valid key

; ----- update sleep activity

	rcall	SleepUpdate

; ----- 2nd

	cpi	r24,KEY_2ND ; 2nd key
	brne	2f
	call	Exec2nd	; shift 2nd state
	rjmp	1b	; get next key

; ----- remap 2nd (shift column 1..5 to 6..0 or A..E)
; INPUT/OUTPUT: R24 = key HEX code
; DESTROYS: R25
2:	rcall	Remap2nd	; remap key R24

; ----- remap HIR (2nd INV)

	cpi	r24,0x27
	brne	3f
	ldi	r24,KEY_HIR
	rjmp	9f

; ----- remap numeric digits

3:	ldi	r30,lo8(RemapDig)
	ldi	r31,hi8(RemapDig)
4:	cpi	r30,lo8(RemapDigEnd)
	breq	9f		; end of table, key not found
	lpm	r25,Z+		; load key from the table
	cp	r24,r25		; is it this key?
	brne	4b		; next key

	mov	r24,r30		; key address + 1
	subi	r24,lo8(RemapDig+1) ; offset in table = key code

; ----- pop registers

9: 	cpi	r24,NOKEY	; test NOKEY
	pop	r31
	pop	r30
	pop	r25
	ret

; ----------------------------------------------------------------------------
;                 Return unused key into keyboard buffer
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code
; DESTROYS: -
; ----------------------------------------------------------------------------

.global ReturnKey
ReturnKey:
	std	Y+DATA_KEYSAVE,r24
	ret

; ----------------------------------------------------------------------------
;                            Wait for a key
; ----------------------------------------------------------------------------
; OUTPUT: R24 = key code
; DESTROYS: -
; NOTE: Enables interrupts
; ----------------------------------------------------------------------------

.global WaitKey
WaitKey:
; OUTPUT: R24 = hex key code (NZ brne) or Oxff no key (NOKEY, ZY breq)
;	  ZY = set if NOKEY
; DESTROYS: -
; NOTE: Enables interrupts
	rcall	GetKey
	breq	WaitKey
	ret

; ----------------------------------------------------------------------------
;                      Check break program R/S
; ----------------------------------------------------------------------------

.global BreakKey
BreakKey:

	; check only if running
	IFN_RUNNING		; if not running
2:	ret			; not running

	; get key
	rcall	GetKey		; get key
	breq	2b		; no key

	; check key
	cpi	r24,KEY_RS	; stop program?
	breq	4f		; R/S, stop program
	mov	r25,r24		; save key
	rcall	GetKey		; get another key (not from buffer)
	breq	3f		; no key, return previous key
	cpi	r24,KEY_RS	; stop program?
	brne	5f		; return key	

	;stop program
4:	jmp	StopProg	; stop program

	; return key
3:	mov	r24,r25		; previous key
5:	rjmp	ReturnKey	; return key
