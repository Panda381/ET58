; ****************************************************************************
;
;                            Execute edit and display
;
; ****************************************************************************

#include "include.inc"

	.text

; ----------------------------------------------------------------------------
;                       Temporary save edit buffer
; ----------------------------------------------------------------------------

.global PushTempEdit
PushTempEdit:

	push	r24
	push	r26
	push	r27
	push	r30
	push	r31

	ldd	r24,Y+DATA_FLAGS
	sts	TempFlags,r24

	ldd	r24,Y+DATA_EDITDIG
	sts	TempEditDig,r24

	ldd	r24,Y+DATA_EXPDIG
	sts	TempExpDig,r24

	ldi	r26,lo8(EditBuf)
	ldi	r27,hi8(EditBuf)
	ldi	r30,lo8(TempEditBuf)
	ldi	r31,hi8(TempEditBuf)

2:	ld	r24,X+
	st	Z+,r24
	cpi	r26,lo8(EditBuf+EDITBUF_SIZE)
	brne	2b

PushTempEdit4:

	pop	r31
	pop	r30
	pop	r27
	pop	r26
	pop	r24
	ret

; ----------------------------------------------------------------------------
;                       Temporary restore edit buffer
; ----------------------------------------------------------------------------

.global PopTempEdit
PopTempEdit:

	push	r24
	push	r26
	push	r27
	push	r30
	push	r31

	lds	r24,TempFlags
	std	Y+DATA_FLAGS,r24

	lds	r24,TempEditDig
	std	Y+DATA_EDITDIG,r24

	lds	r24,TempExpDig
	std	Y+DATA_EXPDIG,r24

	ldi	r26,lo8(TempEditBuf)
	ldi	r27,hi8(TempEditBuf)
	ldi	r30,lo8(EditBuf)
	ldi	r31,hi8(EditBuf)

2:	ld	r24,X+
	st	Z+,r24
	cpi	r26,lo8(TempEditBuf+EDITBUF_SIZE)
	brne	2b

	rjmp	PushTempEdit4

; ----------------------------------------------------------------------------
;                          Display 3 digits
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = number
; DESTROYS: -
; ----------------------------------------------------------------------------

.global Disp3Dig
Disp3Dig:

	push	r22
	push	r24
	push	r25

; INPUT: R25:R24 = number 3 digits
; OUTPUT: R22 = digit hundreds '100'
;	  R24 = number 2 digits
;	  R25 = 0 (high byte of result)
; DESTROYS: -
	call	Split100	; split hundreds -> R22, R24
	mov	r25,r24		; number 2 digits
	mov	r24,r22		; hundreds
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	DispChar	; display hundreds

	mov	r24,r25		; number 2 digits
	rjmp	Disp2Sig2	; decode 2 digits

; ----------------------------------------------------------------------------
;                     Display 2 digits
; ----------------------------------------------------------------------------
; INPUT: R24 = number
; DESTROYS: -
; ----------------------------------------------------------------------------

.global Disp2Dig
Disp2Dig:
	push	r22
	push	r24
	push	r25

Disp2Sig2:

; INPUT: R24 = number 2 digits
; OUTPUT: R22 = digit tens '10'
;	  R24 = digit ones '1'
; DESTROYS: -
	call	Split10		; split tens -> R22, R24
	mov	r25,r24		; save low digit (ones)
	mov	r24,r22		; hight digit (tens)
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	DispChar	; display tens

	mov	r24,r25		; low digit (ones)
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	DispChar	; display ones

	pop	r25
	pop	r24
	pop	r22
	ret

; ----------------------------------------------------------------------------
;                  Clear edit buffer (set to value '0')
; ----------------------------------------------------------------------------
; DESTROYS: R27, R26, R24
; ----------------------------------------------------------------------------

.global EditBufClear
EditBufClear:

; DESTROYS: -
	rcall	FlagClrDP	; decimal point not entered
	ldi	r24,2		; 2 characters = sign and 0
	std	Y+DATA_EDITDIG,r24 ; set number of mantissa digits to 2 '+0'
	std	Y+DATA_EXPDIG,R_ZERO ; no exponent digits

	ldi	r26,lo8(EditBuf) ; buffer
	ldi	r27,hi8(EditBuf)
	ldi	r24,' '
1:	st	X+,r24		; write space character
	cpi	r26,lo8(EditBuf+EDITBUF_SIZE-1)
	brne	1b

	ldi	r24,'0'
	st	X+,r24		; write '0' digit
	st	X,R_ZERO	; terminating zero
	ret

; ----------------------------------------------------------------------------
;                    Shift mantissa in edit buffer left
; ----------------------------------------------------------------------------
; INPUT: R23 = new inserted charater
; OUTPUT: C flag is set if cannot move (buffer is full)
; DESTROYS: R31, R30, R25, R24
; ----------------------------------------------------------------------------

.global TextBufShiftL
TextBufShiftL:

; ----- buffer start address

	ldi	r30,lo8(EditBuf)
	ldi	r31,hi8(EditBuf)

; ----- check free space

	ldd	r24,Y+DATA_EDITDIG ; number of digits of mantissa
	ldd	r25,Y+DATA_EXPDIG ; number of digits of exponent, including sign
	add	r25,r24		; total characters in buffer
	cpi	r25,EDITBUF_SIZE ; check text size
	brcs	1f		; space is OK

; ----- check if number starts with sign

	ld	r25,Z		; get first character
	cpi	r25,'-'
	breq	2f		; starts with '-' sign
	cpi	r25,' '
	brne	4f		; does not start with sign, buffer is full

; ----- number starts with sign, try to reduce first zero digit, or reduce positive sign

2:	ldd	r25,Z+1		; get first digit after sign
	cpi	r25,'0'		; is first digit zero?
	ld	r25,Z		; get sign
	breq	6f		; first digit is zero
	cpi	r25,' '		; positive sign?
	breq	5f		; reduce positive sign (mantissa length stays unchanged)

4:	sec			; set error flag
	ret

6:	std	Z+1,r25		; shift sign instead first zero
	dec	r24		; decrease text length

; ----- increase text length

1:	inc	r24		; increase text length
	std	Y+DATA_EDITDIG,r24 ; save new number of digits

; ----- shift text

5:	ldd	r24,Y+DATA_EXPDIG ; number of digits of exponent, including sign
	ldi	r25,EDITBUF_SIZE-1 ; edit buffer length - 1
	sub	r25,r24		; mantissa length - 1
3:	ldd	r24,Z+1
	st	Z+,r24
	dec	r25
	brne	3b

; ----- add new character

	st	Z,r23
	clc			; clear error flag
	ret

; ----------------------------------------------------------------------------
;                    Shift mantissa in edit buffer right
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24, R23
; ----------------------------------------------------------------------------

.global TextBufShiftR
TextBufShiftR:

; ----- buffer start address

	ldi	r30,lo8(EditBuf)
	ldi	r31,hi8(EditBuf)

; ----- check if buffer was full

	ldi	r23,' '		; add space on first position
	ldd	r24,Y+DATA_EDITDIG ; number of digits of mantissa
	ldd	r25,Y+DATA_EXPDIG ; number of digits of exponent, including sign
	add	r25,r24		; total characters in buffer
	cpi	r25,EDITBUF_SIZE ; check text size
	brcs	1f		; buffer was not full

; ----- restore sign

	ld	r25,Z		; get first character
	cpi	r25,' '
	breq	2f		; start with '+' sign
	cpi	r25,'-'
	brne	4f		; does not start with sign, add '+' sign

; ----- restore first zero digit

2:	ldd	r25,Z+1		; get first character
	cpi	r25,'.'		; decimal point?
	brne	1f		; no
	ld	r23,Z		; load sign character
	ldi	r25,'0'
	st	Z,r25		; add zero digit on first place
	inc	r24		; increase text length

; ----- decrease text length

1:	dec	r24		; decrease text length
	std	Y+DATA_EDITDIG,r24 ; save new number of digits

; ----- shift text

4:	ldd	r24,Y+DATA_EXPDIG ; number of digits of exponent, including sign
	ldi	r25,EDITBUF_SIZE-1 ; edit buffer length - 1
	sub	r25,r24		; mantissa length - 1
	add	r30,r25
	adc	r31,R_ZERO	; shift to end of text
1:	ld	r24,-Z
	std	Z+1,r24
	dec	r25
	brne	1b

; ----- save first digit

	st	Z,r23		; save first digit
	ret

; ----------------------------------------------------------------------------
;                          Start edit mode
; ----------------------------------------------------------------------------
; DESTROYS: R27, R26, R25, R24, R20
; ----------------------------------------------------------------------------

.global EditStart
EditStart:
	SET_EDITON		; set edit mode flag
; DESTROYS: -
	rcall	FlagClrExp	; clear exponent flag
; DESTROYS: R27, R26, R24
	rcall	EditBufClear	; clear edit buffer
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                    Stop edit mode and validate X
; ----------------------------------------------------------------------------
; DESTROYS: R27, R26, R25, R24, R20
; ----------------------------------------------------------------------------

.global EditStop
EditStop:
	SET_XVALID		; set register X valid

.global EditStopNoX
EditStopNoX:
	IFN_EDITON		; if not edit mode
	ret			; not edit mode

	CLR_EDITON		; clear edit mode flag
	SET_XVALID		; set register X valid
	call	EncNum		; encode number
	ldi	r24,REG_X
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: -1
	rcall	_CalcSetMemDel	; set register X
; DESTROYS: R0
	rjmp	Disp		; display all

EditStop9:
	ret

; ----------------------------------------------------------------------------
;                Stop edit mode, validate X and display C
; ----------------------------------------------------------------------------
; DESTROYS: R27, R26, R25, R24, R20
; ----------------------------------------------------------------------------

.global EditStopC
EditStopC:
	rcall	EditStop	; stop edit mode and validate X
	IFN_RUNNING		; if not running
	rjmp	DispC		; display C
	ret

; ----------------------------------------------------------------------------
;                      Digit (0x00..0x0F, KEY_0..KEY_0F)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecDig
ExecDig:

; ----- convert key code to ASCII character -> R23

	cpi	r24,10
	brcs	2f
	subi	r24,-7		; add correction to get 'A'..'F'
2:	mov	r23,r24		; key code
	subi	r23,-'0'	; conver to character

; ----- start edit mode

	IFN_EDITON		; if not edit mode
	rcall	EditStart	; start edit mode (DESTROYS: R27, R26, R25, R24, R20)

; ----- check mode - entering mantissa or exponent
; OUTPUT: NZ = flag is set
; DESTROYS: -
	rcall	FlagTestExp	; entering exponent?
	breq	ExecDig4	; not exponent


; ===== entering exponent

; ----- invalid digit

	cpi	r23,'9'+1
	brcc	ExecDig3	; invalid digit	

; ----- prepare max. number of digits of exponent

	ldi	r25,6		; number of digits for BIN (max. 32767) and OCT (max. 10922)
	ldd	r24,Y+DATA_BASE
	cpi	r24,BASE_DEC	; dec
	breq	4f
	cpi	r24,BASE_HEX	; hex
	brne	5f
4:	ldi	r25,5		; number of digits for DEC (max. 9863) and HEX (8191)

; ----- check max. length of exponent (4 or 5 digits + sign)

5:	ldd	r24,Y+DATA_EXPDIG ; exponent length
	cp	r24,r25		; max. length
	brcc	ExecDig2	; already max. length

; ----- exponent is zero - replace with new digit

	cpi	r24,2		; sign + 1 digit
	brne	1f
	ldd	r25,Y+DATA_EDITBUF+EDITBUF_SIZE-1 ; get last digit
	cpi	r25,'0'		; exponent is 0 ?
	brne	1f		; not 0
	std	Y+DATA_EDITBUF+EDITBUF_SIZE-1,r23 ; set new digit
; DESTROYS: R0
	rjmp	Disp		; display all

; ----- shift mantissa with exponent (here is R24 = exponent length)

	; temporary hide exponent
1:	ldd	r25,Y+DATA_EDITDIG ; mantissa length
	add	r25,r24		; length mantissa + exponent
	std	Y+DATA_EDITDIG,r25 ; we temporary use it instead of mantissa length
	std	Y+DATA_EXPDIG,R_ZERO ; temporary hide exponent

	; shift mantissa with exponent left
; INPUT: R23 = new inserted charater
; OUTPUT: C flag is set if cannot move (buffer is full)
; DESTROYS: R31, R30, R25, R24
	push	r24		; save exponent length
	rcall	TextBufShiftL	; add new digit to exponent
	pop	r24
	ldd	r25,Y+DATA_EDITDIG ; new length
	brcs	2f		; cannot extend exponent

	; validate new position
	inc	r24		; increase exponent length
	sub	r25,r24		; mantissa length
	std	Y+DATA_EDITDIG,r25 ; mantissa length
	std	Y+DATA_EXPDIG,r24 ; exponent length
; DESTROYS: R0
	rjmp	Disp		; display all

	; cannot extend exponent, restore lengths
2:	sub	r25,r24		; old mantissa length
	std	Y+DATA_EDITDIG,r25 ; return mantissa length
	std	Y+DATA_EXPDIG,r24 ; exponent length

; ----- rotate digits of exponent (here is R24 = exponent length)

ExecDig2:
	ldi	r30,lo8(EditBuf+EDITBUF_SIZE) ; end of edit buffer
	ldi	r31,hi8(EditBuf+EDITBUF_SIZE)
	dec	r24		; length without sign
5:	ld	r25,-Z		; load digit
	st	Z,r23		; save new digit
	mov	r23,r25
	dec	r24		; length counter
	brne	5b		; next digit
; DESTROYS: R0
	rjmp	Disp		; display all

ExecDig3:
	ret

; ----- entering mantissa (here is R23 = new digit)

ExecDig4:
	; check digit of mantissa
;#define BASE_DEC	0	// decimal
;#define BASE_BIN	1	// binary
;#define BASE_OCT	2	// octal
;#define BASE_HEX	3	// hexadecimal
	ldd	r24,Y+DATA_BASE	; radix base
	cpi	r24,BASE_DEC	; dec
	brne	2f
	cpi	r23,'9'+1
	brcc	ExecDig3	; invalid DEC digit

2:	cpi	r24,BASE_BIN	; bin
	brne	2f
	cpi	r23,'1'+1
	brcc	ExecDig3	; invalid BIN digit

2:	cpi	r24,BASE_OCT	; oct
	brne	2f
	cpi	r23,'7'+1
	brcc	ExecDig3	; invalid OCT digit

	; delete first zero
2:	ldd	r24,Y+DATA_EDITDIG ; number of digits of mantissa
	cpi	r24,2		; only 2 characters (sign + 1 digit)?
	brne	5f		; no

	; check if first digit is zero
	ldi	r30,lo8(EditBuf+EDITBUF_SIZE-1) ; end of edit buffer
	ldi	r31,hi8(EditBuf+EDITBUF_SIZE-1)
	ldd	r24,Y+DATA_EXPDIG ; number of digits of exponent, including sign
	sub	r30,r24
	sbc	r31,R_ZERO	; address behind end of mantissa

	ld	r24,Z		; read last character
	cpi	r24,'0'		; is it zero?
	brne	5f		; no

	st	Z,r23		; substitute by new digit
	rjmp	8f

; ----- add new digit to end of buffer
; INPUT: R23 = new inserted charater
; OUTPUT: C flag is set if cannot move (buffer is full)
; DESTROYS: R31, R30, R25, R24

5:	rcall   TextBufShiftL	; add new digit to the mantissa

; ----- display new edit buffer

8:
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                      Restart edit of current number X
; ----------------------------------------------------------------------------

.global EditRestart
EditRestart:
	; decode number into buffer
	ldi	r24,REG_X	; register X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load number X into calculator stack
; CALCULATOR STACK: -1
; DESTROYS: all
	call	DecNumDef	; decode number (with default size of edit buffer)

	; set flags
	SET_EDITON		; set edit mode flag

	call	EncNum		; encode number
	ldi	r24,REG_X
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: -1
	rjmp	_CalcSetMemDel	; set register X

; ----------------------------------------------------------------------------
;                           EE (0x52)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecEe
ExecEe:

	breq	ExecEe2		; not INV flag

; ----- end of exponent mode

; OUTPUT: NZ = flag is set
; DESTROYS: -
	rcall	FlagTestEng
	brne	2f		; ENG mode is active
; DESTROYS: -
	rcall	FlagClrEE	; clear exponent mode (but not ENG mode)

	SET_XVALID		; set register X valid

; DESTROYS: -
	IF_EDITON		; if edit mode
	rcall	StopExp		; stop exponent mode and clear exponent if 0
2:
; DESTROYS: R0
	rjmp	Disp		; display all

; ----- not in edit mode - cut number and start edit mode

ExecEe2:
	IFN_EDITON		; if not edit mode
	rcall	EditRestart	; restart edit of current number X

; ----- start exponent mode (if not in engineer mode)

ExecEe4:
; OUTPUT: NZ = flag is set
; DESTROYS: -
	rcall	FlagTestEng	; test engineer mode
	brne	ExecEe6		; already exponent mode
; DESTROYS: -
	rcall	FlagSetEE	; set exponent mode
; DESTROYS: -
	SET_XVALID		; set register X valid
	rcall	DispFlags	; display flags

; ----- initialize exponent

ExecEe6:
	ldd	r24,Y+DATA_EXPDIG ; exponent length
	tst	r24		; already valid?
	brne	ExecEe9		; exponent is valid

	ldi	r23,'+'		; sign flag
; INPUT: R23 = new inserted charater
; OUTPUT: C flag is set if cannot move (buffer is full)
; DESTROYS: R31, R30, R25, R24
	rcall   TextBufShiftL	; add new digit to the mantissa
	brcs	1f		; error, cannot enter exponent
	ldi	r23,'0'		; exponent digit
; INPUT: R23 = new inserted charater
; OUTPUT: C flag is set if cannot move (buffer is full)
; DESTROYS: R31, R30, R25, R24
	rcall   TextBufShiftL	; add new digit to the mantissa
	brcc	2f		; exponent is OK

	rcall	TextBufShiftR	; delete sign flag
; DESTROYS: R0
	rjmp	Disp		; display all

2:	ldd	r24,Y+DATA_EDITDIG ; mantissa lenth
	subi	r24,2		; correct mantissa length
	std	Y+DATA_EDITDIG,r24
	ldi	r24,2		; exponent length
	std	Y+DATA_EXPDIG,r24 ; set exponent length

ExecEe9:
; DESTROYS: -
	rcall	FlagSetExp	; entering exponent mode
1:
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                           Eng (0x57)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecEng
ExecEng:

	breq	1f		; not INV flag

; DESTROYS: -
	rcall	FlagClrEng	; clear Eng
	rjmp	3f

; DESTROYS: -
1:	rcall	FlagSetEng	; set Eng

; DESTROYS: -
3:	rcall	FlagClrEE	; clear exponent mode
ExecFix4:
	rcall	EditStop	; stop edit mode and set X valid
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                           Fix (0x58)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecFix
ExecFix:

	breq	1f		; not INV flag

	; INV - turn FIX off
	rcall	EditStop	; stop edit mode and set X valid

3:	ldi	r24,FIX_OFF
2:	std	Y+DATA_FIX,r24	; switch fix off
; DESTROYS: R0
	rjmp	Disp		; display all

	; not INV flag
1:	rcall	EditStop	; stop edit mode and set X valid
; OUTPUT: R24 = typically digit 0..15 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
	rcall	Load1Dig	; load 1 key from program or from user, with indirect
	brcc	2b		; valid fix
	ret

; ----------------------------------------------------------------------------
;                Stop exponent mode (and delete exponent if 0)
; ----------------------------------------------------------------------------

StopExp:

; DESTROYS: -
	rcall	FlagClrExp	; clear exponent flag

	ldd	r24,Y+DATA_EXPDIG ; number of exponent digits
	cpi	r24,2		; is exponent 2 characters?
	brne	1f		; not 2 characters

	ldd	r24,Y+DATA_EDITBUF+EDITBUF_SIZE-1 ; get exponent digit
	cpi	r24,'0'		; zero exponent?
	brne	1f

	std	Y+DATA_EXPDIG,R_ZERO ; clear exponent
	ldd	r24,Y+DATA_EDITDIG ; number of digits of mantissa
	subi	r24,-2		; increase length of mantissa
	std	Y+DATA_EDITDIG,r24 ; correct mantissa length

	rcall	TextBufShiftR	; shift mantissa right
	rcall	TextBufShiftR
1:	ret

; ----------------------------------------------------------------------------
;                            . (0x93)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecDot
ExecDot:

	brne	ExecDot8	; only start edit mode

; ----- start edit mode

	IFN_EDITON		; if not edit mode
	rcall	EditStart	; start edit mode (DESTROYS: R27, R26, R25, R24, R20)

; ----- stop exponent mode

1:	rcall	StopExp		; stop exponent mode and clear exponent if 0

; ----- add decimal point

; OUTPUT: NZ = flag is set
; DESTROYS: -
	rcall	FlagTestDP	; check decimal point
	brne	4f		; decimal point already entered
	ldi	r23,'.'
; INPUT: R23 = new inserted charater
; OUTPUT: C flag is set if cannot move (buffer is full)
; DESTROYS: R31, R30, R25, R24
	rcall	TextBufShiftL	; add new digit to the mantissa
	brcs	4f		; buffer is full
; DESTROYS: -
	rcall	FlagSetDP	; set dot flag

; ----- display new edit buffer

4:
; DESTROYS: R0
	rjmp	Disp		; display all

; ----- start edit mode

ExecDot8:
	IFN_EDITON		; if not edit mode
	rcall	EditRestart	; restart edit of current number X
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                            +/- (0x94)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecNeg
ExecNeg:

	IF_EDITON		; if edit mode
	rjmp	4f		; edit mode is set

	; negate X
	SET_XVALID		; set register X valid
	rcall	_Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_NEG		; negate X
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	Disp		; display all

	; edit mode - change sign
4:	ldi	r30,lo8(EditBuf+EDITBUF_SIZE) ; buffer end
	ldi	r31,hi8(EditBuf+EDITBUF_SIZE)

	ldi	r25,'+'		; exponent plus
	ldd	r24,Y+DATA_EXPDIG ; exponent length
	sub	r30,r24		; shift to start of exponent
	sbc	r31,R_ZERO

; OUTPUT: NZ = flag is set
; DESTROYS: -
	rcall	FlagTestExp	; exponent mode?
	brne	6f		; exponent

	ldi	r25,' '		; mantissa plus
	ldd	r24,Y+DATA_EDITDIG ; mantissa lenth
	sub	r30,r24		; shift to start of exponent
	sbc	r31,R_ZERO

	ld	r24,Z		; get sign
	cpi	r24,'-'		; minus?
	breq	7f		; change to ' '
	cpi	r24,' '		; plus?
	breq	8f		; change to '-'
	ret			; invalid sign, do not change

6:	ld	r24,Z		; get sign
	cpi	r24,'-'		; minus?
	breq	7f		; no, plus
8:	ldi	r25,'-'		; minus
7:	st	Z,r25		; set new sign

; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                      Register correction on overflow
; ----------------------------------------------------------------------------
; INPUT: R24 = register index
; DESTROYS: R31, R30, R25, R24, R_M1,...R_M10, R0
; ----------------------------------------------------------------------------

.global ExecOverOff
ExecOverOff:

; ----- get address of the number -> R31:R30 (Z)
; INPUT: R24 = index of variable 0..MEM_NUM-1
; OUTPUT: R31:R30 = address of variable
;	  R1 = 0
; DESTROYS: R0
	call	CalcAddrMem

; ----- check overflow

	ldd	r25,Z+0		; R25 <- exponent HIGH
	ldd	r24,Z+1		; R24 <- exponent LOW
	adiw	r24,1		; check overflow 0xFFFF -> 0x0000
	brne	9f		; no overflow

; ----- set number to max. value
; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10

	ldd	r24,Z+2		; save sign
	call	CalcZMax
	ori	r24,0x7f
	std	Z+2,r24		; set sign
9:	ret

; ----------------------------------------------------------------------------
;                     Clear error flag
; ----------------------------------------------------------------------------
; DESTROYS: R27, R26, R25, R24
; ----------------------------------------------------------------------------

.global ClearErr
ClearErr:

	CLR_ERROR		; clear error flag
	CLR_FATAL		; clear fatal error
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;           Delete decimal part of edited number and exponent
; ----------------------------------------------------------------------------

.global DelDot
DelDot:

; ----- must be edit mode

	IFN_EDITON	; if not edit mode
	ret		; return if not edit mode

; ----- delete exponent

2:	ldd	r21,Y+DATA_EXPDIG ; number of exponent digits
	tst	r21		; exponent?
	breq	3f		; no exponent
	rcall	FlagSetExp	; start edit exponent
	rjmp	4f	

; ----- delete decimal places

3:	rcall	FlagTestDP	; check decimal point
	breq	5f		; no decimal point

; ----- delete one character

4:	rcall	ExecCe4		; delete one digit
	rjmp	2b		; new check

5:	ret

; ----------------------------------------------------------------------------
;                           CE (0x24)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecCe
ExecCe:

; ----- check error mode

	IF_ERROR		; if error
	rjmp	2f		; error flag
	IFN_FATAL		; if not fatal
	rjmp	ExecCe2

; ----- clear error

2:	rcall	ClearErr	; clear error

; ----- correct registers on overflow

	ldi	r24,REG_X
; INPUT: R24 = register index
; DESTROYS: R31, R30, R25, R24, R_M1,...R_M10, R0
	rcall	ExecOverOff

	ldi	r24,REG_T
; INPUT: R24 = register index
; DESTROYS: R31, R30, R25, R24, R_M1,...R_M10, R0
	rcall	ExecOverOff

	ldi	r24,REG_LAST
; INPUT: R24 = register index
; DESTROYS: R31, R30, R25, R24, R_M1,...R_M10, R0
	rcall	ExecOverOff
; DESTROYS: R0
	rjmp	Disp		; display all

; ----- must be in edit mode

ExecCe2:
	IFN_EDITON		; if not in edit mode
	rjmp	ExecCe9		; only validate X

; called from DelDot
ExecCe4:
	ldd	r21,Y+DATA_EXPDIG ; number of exponent digits

; ----- exponent mode - clear one digit
; OUTPUT: NZ = flag is set
; DESTROYS: -
	rcall	FlagTestExp	; entering exponent?
	breq	4f		; not exponent

; ----- will be last exponent digit?

	cpi	r21,2		; last digit with sign?
	brne	2f		; not 2 digits

	; delete exponent +0
	ldd	r25,Y+DATA_EDITBUF+EDITBUF_SIZE-1 ; last digit in buffer
	cpi	r25,'0'		; is it zero?
	brne	1f		; not last 0
	rcall	StopExp		; stop exponent mode, delete +0 exponent
	rjmp	ExecCe10

	; set last digit to 0
1:	ldi	r25,'0'
	std	Y+DATA_EDITBUF+EDITBUF_SIZE-1,r25 ; set last digit to 0
	rjmp	ExecCe10

; ----- delete last exponent digit

2:	tst	r21		; zero exponent? (=internal error)
	breq	ExecCe10

	ldd	r22,Y+DATA_EDITDIG ; length of mantissa
	add	r22,r21		; length of mantissa + exponent
	std	Y+DATA_EDITDIG,r22 ; new mantissa length
	std	Y+DATA_EXPDIG,R_ZERO ; delete exponent
; DESTROYS: R31, R30, R25, R24, R23
	rcall	TextBufShiftR	; shift mantissa with exponent right
	ldd	r22,Y+DATA_EDITDIG ; length of mantissa
	dec	r21		; decrement exponent length
	sub	r22,r21
	std	Y+DATA_EDITDIG,r22 ; new mantissa length
	std	Y+DATA_EXPDIG,r21 ; set exponent
	rjmp	ExecCe10

; ----- address of last character of mantissa

4:	ldi	r30,lo8(EditBuf+EDITBUF_SIZE-1)
	ldi	r31,hi8(EditBuf+EDITBUF_SIZE-1)
	sub	r30,r21		; subtract exponent length
	sbc	r31,R_ZERO

; ----- minimal mantissa - set last digit to zero

	ldd	r22,Y+DATA_EDITDIG ; length of mantissa
	cpi	r22,2		; 2 last characters?
	brne	5f
	ldi	r24,'0'
	st	Z,r24		; set last digit to zero
; DESTROYS: R0
	rjmp	Disp		; display all

; ----- delete last character

5:	ld	r24,Z		; load last character
	cpi	r24,'.'		; deleteing decimal point?
	brne	6f		; not decimal point
	rcall	FlagClrDP	; clear decimal point flag
6:	rcall	TextBufShiftR	; shift mantissa right
; DESTROYS: R0
	rjmp	Disp		; display all

; ----- not in edit mode - only validate X (used after left parenthesis)

ExecCe9:
	SET_XVALID
ExecCe10:
; DESTROYS: R0
	rjmp	Disp		; display all

