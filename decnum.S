; ****************************************************************************
;
;                          Decode number to/from text
;
; ****************************************************************************

#include "include.inc"

	.text

; ----------------------------------------------------------------------------
;                    Decode unsigned word into buffer TempEditBuf
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = number
; OUTPUT: R31:R30 = start of number in TempEditBuf
;	 R23 = length of number
; DESTROYS: R25:R24
; ----------------------------------------------------------------------------

#if 0
.global DecW
DecW:
	push	r26
	push	r27	
	push	r20
	push	r21

	; end of buffer
	ldi	r30,lo8(TempEditBuf+EDITBUF_SIZE)
	ldi	r31,hi8(TempEditBuf+EDITBUF_SIZE)
	clr	r23		; length counter

2:	movw	r26,r24		; save number
; INPUT: R25:R24 = dividend (N1:N0)
; OUTPUT: R25:R24 = quotient (Q1:Q0), 0..6553
;         R1=0
; DESTROYS: R0
	rcall	DivW10		; divide number by 10
	movw	r20,r24
; INPUT: R25:R24 = multiplier (N1:N0)
; OUTPUT: R25:R24 = result (M1:M0)
;         R1=0
; DESTROYS: R0
	rcall	MulW10		; multiply number by 10

	sub	r26,r24
	subi	r26,-'0'	; convert to digit
	st	-Z,r26		; save digit
	inc	r23		; increase length counter

	mov	r24,r20
	adiw	r24,0
	brne	2b		; next digit

	pop	r21
	pop	r20
	pop	r27
	pop	r26
	ret
#endif

; ----------------------------------------------------------------------------
;                     Split number by thousands
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = number 4 digits
; OUTPUT: R22 = digit thousands '1000'
;	  R25:R24 = number 3 digits
; DESTROYS: -
; ----------------------------------------------------------------------------

.global Split1000
Split1000:
	ldi	r22,'0'-1
1:	inc	r22
	subi	r24,lo8(1000)
	sbci	r25,hi8(1000)
	brcc	1b
	subi	r24,lo8(-1000)
	sbci	r25,hi8(-1000)

Split1000Hex:
	cpi	r22,'0'+10
	brcs	2f
	subi	r22,-7		; convert to HEX character
2:	ret

; ----------------------------------------------------------------------------
;                     Split number by hundreds
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = number 3 digits
; OUTPUT: R22 = digit hundreds '100'
;	  R24 = number 2 digits
;	  R25 = 0 (high byte of result)
; DESTROYS: -
; ----------------------------------------------------------------------------

.global Split100
Split100:
	ldi	r22,'0'-1
1:	inc	r22
	subi	r24,lo8(100)
	sbci	r25,hi8(100)
	brcc	1b
	subi	r24,lo8(-100)
	sbci	r25,hi8(-100)
	rjmp	Split1000Hex

; ----------------------------------------------------------------------------
;                     Split number by tens
; ----------------------------------------------------------------------------
; INPUT: R24 = number 2 digits
; OUTPUT: R22 = digit tens '10'
;	  R24 = digit ones '1'
; DESTROYS: -
; ----------------------------------------------------------------------------

.global Split10
Split10:
	ldi	r22,'0'-1
1:	inc	r22
	subi	r24,10
	brcc	1b
	subi	r24,lo8(-10-'0')
	rjmp	Split1000Hex

; ----------------------------------------------------------------------------
;                      Decrement exponent
; ----------------------------------------------------------------------------

Split_DecExp:
	ldd	r24,Y+DATA_EXP	; load exponent
	ldd	r25,Y+DATA_EXP+1
	sbiw	r24,1		; decrement exponent
	std	Y+DATA_EXP,r24	; save exponent
	std	Y+DATA_EXP+1,r25
	ret

; ----------------------------------------------------------------------------
;                      Increment exponent
; ----------------------------------------------------------------------------

Split_IncExp:
	ldd	r24,Y+DATA_EXP	; load exponent
	ldd	r25,Y+DATA_EXP+1
	adiw	r24,1		; increment exponent
	std	Y+DATA_EXP,r24	; save exponent
	std	Y+DATA_EXP+1,r25
	ret

; ----------------------------------------------------------------------------
; Split number on top of stack to mantissa and exponent (number must not be 0)
; ----------------------------------------------------------------------------
; DESTROYS: all
; ----------------------------------------------------------------------------

.global SplitNum
SplitNum:

; =============== Prepare exponent ==================
; 1) convert to signed (subtract bias)
; 2) rounding correction
; 3) convert to decimal base (divide by log2 of base radix)


; ----- load exponent and convert to signed
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get top number and check zero
	subi	r24,lo8(EXP_BIAS) ; subtract bias
	sbci	r25,hi8(EXP_BIAS)

; ----- stack signed exponent
; INPUT: R25:R24 = signed integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	push	r25		; save exponent HIGH
	call	CalcStackS16	; stack exponent (as signed)
	pop	r25		; exponent HIGH

; ----- negative exponent: sub 1, positive exponent: add 2

	tst	r25		; is exponent negative?
	brmi	3f		; exponent is negative

; DESTROYS: all
	rcall	CalcInc		; increment positive exponent
; DESTROYS: all
	rcall	CalcInc
	rjmp	4f

; DESTROYS: all
3:	rcall	CalcDec		; decrement negative exponent

; ----- convert binary exponent to decimal (divide by log2 of radix base)

4:	ldd	r24,Y+DATA_BASE	; radix base

	; decimal base: multiply by log10(2)
	cpi	r24,BASE_DEC	; decimal exponent?
	brne	5f		; not decimal exponent

	ldi	r24,CONST_LOG2	; constat log10(2)
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst	; stack constant log10(2)
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcMul		; multiply (multiply by log10(2) = divide by log2(10)
	rjmp	SplitNum2

	; hexadecimal base: divide by 4
5:	cpi	r24,BASE_HEX	; hexadecimal base?
	brne	6f		; not hexadecimal base

; DESTROYS: R31, R30, R25, R24
	rcall	CalcDiv4	; divide/4 (divide by log2(16) = 4)
	rjmp	SplitNum2

	; octal base: divide by 3
6:	cpi	r24,BASE_OCT	; octal base?
	brne	SplitNum2	; not octal base ... binary base stays untouched

	ldi	r24,3
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	call	CalcStackB	; load constant 3
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcDiv		; divide by 3 (divide by log2(8) = 3)

; ----- load signed exponent (as rounded signed integer)
; OUTPUT: R25:R24 = signed integer
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
SplitNum2:
	call	CalcUnstackS16	; get exponent
	std	Y+DATA_EXP,r24	; save exponent
	std	Y+DATA_EXP+1,r25


; ============ Normalize mantissa: divide mantissa by exponent base ==========

	movw	r22,r24		; R23:R22 <- save exponent

; ----- divide mantissa by HEX exponent * 4 (base log2(16)=4)

	ldd	r26,Y+DATA_BASE	; radix base
	cpi	r26,BASE_HEX	; hex?
	brne	SplitNum3	; not hex

; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	; subtract new exponent * 4
	rcall	CalcTopCheck	; get top number and check zero
	movw	r20,r22		; R21:R20 <- new exponent

	add	r20,r20
	adc	r21,r21
	add	r20,r20
	adc	r21,r21		; R21:R20 <- new exponent * 4

	sub	r24,r20
	sbc	r25,r21		; old expnent - new exponent * 4

	std	Z+0,r25		; save new exponent
	std	Z+1,r24

; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	; check if mantissa is < 1
2:	rcall	CalcTopCheck	; get top number and check zero
	cpi	r25,hi8(EXP_BIAS) ; check if mantissa is < 1
	brcc	3f		; mantissa is not < 1

	; while mantissa is < 1, multiply it by 16
; DESTROYS: R31, R30, R25, R24
	rcall	CalcMul16	; multiply mantissa by 16
	rcall	Split_DecExp	; decrement exponent
	rjmp	2b		; next loop

; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	; check if mantissa is >= 16
3:	rcall	CalcTopCheck	; get top number and check zero
	cpi	r24,lo8(EXP_BIAS+4) ; check if mantissa is >= 16
	brcs	4f		; mantissa is not >= 16

	; while mantissa is >= 16, divide it by 16
; DESTROYS: R31, R30, R25, R24
	rcall	CalcDiv16	; divide mantissa by 16
	rcall	Split_IncExp	; increment exponent
	rjmp	3b		; next loop

4:	ret

; ----- divide mantissa by OCT exponent

SplitNum3:
	cpi	r26,BASE_OCT	; oct?
	brne	SplitNum4	; not oct

; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	; subtract new exponent * 3
	rcall	CalcTopCheck	; get top number and check zero

	sub	r24,r22
	sbc	r25,r23

	sub	r24,r22
	sbc	r25,r23

	sub	r24,r22
	sbc	r25,r23		; old expnent - new exponent * 3

	std	Z+0,r25		; save new exponent
	std	Z+1,r24

; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	; check if mantissa is < 1
2:	rcall	CalcTopCheck	; get top number and check zero
	cpi	r25,hi8(EXP_BIAS) ; check if mantissa is < 1
	brcc	3f		; mantissa is not < 1

	; while mantissa is < 1, multiply it by 8
; DESTROYS: R31, R30, R25, R24
	rcall	CalcMul8	; multiply mantissa by 8
	rcall	Split_DecExp	; decrement exponent
	rjmp	2b		; next loop

; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	; check if mantissa is >= 8
3:	rcall	CalcTopCheck	; get top number and check zero
	cpi	r24,lo8(EXP_BIAS+3) ; check if mantissa is >= 8
	brcs	4f		; mantissa is not >= 8

	; while mantissa is >= 8, divide it by 8
; DESTROYS: R31, R30, R25, R24
	rcall	CalcDiv8	; divide mantissa by 8
	rcall	Split_IncExp	; increment exponent
	rjmp	3b		; next loop

4:	ret

; ----- divide mantissa by BIN exponent

SplitNum4:
	cpi	r26,BASE_BIN	; bin?
	brne	SplitNum5	; not bin

; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	; subtract new exponent
	rcall	CalcTopCheck	; get top number and check zero

	sub	r24,r22
	sbc	r25,r23		; old expnent - new exponent

	std	Z+0,r25		; save new exponent
	std	Z+1,r24

; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	; check if mantissa is < 1
2:	rcall	CalcTopCheck	; get top number and check zero
	cpi	r25,hi8(EXP_BIAS) ; check if mantissa is < 1
	brcc	3f		; mantissa is not < 1

	; while mantissa is < 1, multiply it by 2
; DESTROYS: R31, R30, R25, R24
	rcall	CalcMul2	; multiply mantissa by 2
	rcall	Split_DecExp	; decrement exponent
	rjmp	2b		; next loop

; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	; check if mantissa is >= 2
3:	rcall	CalcTopCheck	; get top number and check zero
	cpi	r24,lo8(EXP_BIAS+1) ; check if mantissa is >= 2
	brcs	4f		; mantissa is not >= 2

	; while mantissa is >= 2, divide it by 2
; DESTROYS: R31, R30, R25, R24
	rcall	CalcDiv2	; divide mantissa by 2
	rcall	Split_IncExp	; increment exponent
	rjmp	3b		; next loop

4:	ret

; ----- divide mantissa by decimal exponent (here is R25_R24 = new exponent)
; Exponent table ExpTab:
;  0: 1e-8192
;  ...
;  14: 1
;  ...
;  28: 1e+8192

SplitNum5:
	ldi	r30,lo8(ExpTab+14*NUM_BYTES) ; address of '1'
	ldi	r31,hi8(ExpTab+14*NUM_BYTES)
	ldi	r22,-NUM_BYTES ; negative increment
	ldi	r23,0xff

	; prepare direction increment and absolute exponent
	tst	r25		; is exponent negative?
	brpl	2f		; exponent is not negative

; INPUT/OUTPUT: R25:R24 = number to negate
; DESTROYS: -
	rcall	NegW		; negate number R25:R24

	ldi	r22,NUM_BYTES	; positive increment
	ldi	r23,0

	; shift pointer in exponent table
2:	add	r30,r22
	adc	r31,r23

	; divide exponent / 2
	lsr	r25
	ror	r24
	brcc	4f		; bit is not set

	; push registers: increment, exponent and pointer to table
	push	r22
	push	r23
	push	r24
	push	r25
	push	r30
	push	r31

; INPUT: R31:R30 = constant in ROM
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConstROM	; load decimal exponent
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcMul		; multiply number by exponent

	; pop registers
	pop	r31
	pop	r30
	pop	r25
	pop	r24
	pop	r23
	pop	r22

	; check if exponent is = 0
4:	mov	r26,r24
	or	r26,r25		; all done?
	brne	2b		; next bit

; ----- mantissa is now in range 0.25..5 (or 0), correction to get into range 1..9.99999
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get top number
	cpi	r25,hi8(EXP_BIAS) ; is number 1 or more?
	brcc	5f		; number is OK

	ldi	r24,CONST_10	; constant 10
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst	; load constant 10
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcMul		; multiply mantissa by 10

	rcall	Split_DecExp	; decrement exponent
5:	ret

; ----------------------------------------------------------------------------
;   Decode number into edit buffer EditBuf, with default size of edit buffer
; ----------------------------------------------------------------------------
; CALCULATOR STACK: -1
; DESTROYS: all
; ----------------------------------------------------------------------------

.global DecNumDef
DecNumDef:

	ldi	r24,EDITBUF_SIZE
	std	Y+DATA_EDITMAX,r24

; DecNum must follow

; ----------------------------------------------------------------------------
;                 Decode number into edit buffer EditBuf
; ----------------------------------------------------------------------------
; CALCULATOR STACK: -1
; DESTROYS: all
; ----------------------------------------------------------------------------

.global DecNum
DecNum:

; ----- clear edit buffer

	std	Y+DATA_EXP,R_ZERO ; clear exponent
	std	Y+DATA_EXP+1,R_ZERO
; DESTROYS: R27, R26, R24
	call	EditBufClear	; clear edit buffer

; ----- save error and running flag (to ignore overflow error)

; DESTROYS: -
	call	FlagClrOldErr	; clear OldErr flag
	IF_ERROR		; if error
; DESTROYS: -
	call	FlagSetOldErr	; set OldErr flag

; DESTROYS: -
	call	FlagClrOldRun	; clear OldRun flag
	IF_RUNNING		; if running
; DESTROYS: -
	call	FlagSetOldRun	; set OldRun flag

; ----- save overflow flag

; DESTROYS: -
	call	FlagClrErrDec	; clear ErrDec flag
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	; check if mantissa is < 1
	call	CalcTopCheck	; get top number and check zero
	brcc	1f		; no overflow
; DESTROYS: -
	call	FlagSetErrDec	; set ErrDec flag

; ----- check negative number, do absolute value, store sign

1:	ldd	r25,Z+2		; get first byte of mantissa
	ldi	r24,'-'		; negative sign
	sbrs	r25,7		; skip if sign flag is set
	ldi	r24,' '		; positive sign (space)
	andi	r25,0x7f	; clear sign
	std	Z+2,r25		; save absolute value

	std	Y+DATA_EDITBUF,r24 ; output sign character


; ================ split number to mantissa and exponent ============

; ----- check if number is zero
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get top number and check zero
	breq	2f		; number is zero, skip splitting

; ----- split number to exponent and mantissa
; DESTROYS: all
	rcall	SplitNum	; split number

; ----- clear restart flag

; DESTROYS: -
2:	call	FlagClrResDec	; clear restart flag

; ============================= prepare engineer mode ==========================

; ----- Engineer mode - prepare exponent, -> R19 (number of integer digits)

	ldi	r19,1		; number of digits of integer part
; OUTPUT: NZ = flag is set
; DESTROYS: -
	call	FlagTestEng	; Eng technical mode?
	breq	DecNumRestart	; not technical mode

	; load exponent
	ldd	r24,Y+DATA_EXP	; get exponent
	ldd	r25,Y+DATA_EXP+1
; INPUT: R25:R24 = signed integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	call	CalcStackS16	; stack exponent
	; prepare grouping
	ldd	r25,Y+DATA_BASE	; radix base
	ldi	r24,3		; 3-digits for DEC and OCT
	cpi	r25,BASE_DEC	; dec base?
	breq	2f		; dec
	cpi	r25,BASE_OCT	; oct base?
	breq	2f		; oct
	ldi	r24,4		; 4-digits for BIN and HEX

	; prepare exponent grouping: modulo floor, delete integer part, load integer digits
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
2:	call	CalcStackB	; stack constant 3
	rcall	CalcMod2	; modulo with floor rounding
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; get number of integer digits-1 -> R24
	; subtract integer digits-1 from exponent
	ldd	r22,Y+DATA_EXP	; get exponent
	ldd	r23,Y+DATA_EXP+1
	sub	r22,r24		; subtract integer digits-1 (= round to multiply of 3)
	sbc	r23,R_ZERO
	std	Y+DATA_EXP,r22	; save exponent
	std	Y+DATA_EXP+1,r23

	; prepare integer digits -> R19
	inc	r24		; number of digits + 1
	mov	r19,r24		; number of digits of integer part

; =================== Prepare number of digits, decode exponent ==========================


; ----- prepare flags

DecNumRestart:

; R23: total number of digits of mantissa
; R21: number of exponent digits (including sign)
; R20: number of additional zeroes on start of number (between decimal point and valid digits)
; R19: number of integer digits
; R18: number of decimal digits

	ldd	r23,Y+DATA_EDITMAX ; size of edit buffer
	subi	r23,2		; without sign and point = total number of digits of mantissa
	ldi	r21,0		; number of exponent digits
	ldi	r20,0		; number of additional zeroes

	; load exponent
	ldd	r24,Y+DATA_EXP	; get exponent (signed)
	ldd	r25,Y+DATA_EXP+1

; ===== exponent mode

; ----- check if use exponent mode
; OUTPUT: NZ = flag is set
; DESTROYS: -
	call	FlagTestEEEng	; check EE and Eng flags
	brne	5f		; use exponent mode

	; check maximal exponent
	cp	r24,r23		; check exponent size
	cpc	r25,R_ZERO
	brge	5f		; exponent is greater than display (>= 14)

	; check minimal exponent - not in fixed mode
	ldd	r26,Y+DATA_FIX	; fixed decimals
	cpi	r26,FIX_OFF	; is fixed mode?
	brne	DecNum2		; fixed mode, do not use exponent mode
	ldi	r26,-1
	cpi	r24,-3		; check minimal exponent
	cpc	r25,r26
	brge	DecNum2		; exponent is ok

; ----- decode exponent

	; absolute value of exponent
5:	mov	r22,r25		; save exponent HIGH (with sign)
	tst	r25		; is exponent negative?
	brpl	6f		; exponent is not negative
; INPUT/OUTPUT: R25:R24 = number to negate
; DESTROYS: -
	rcall	NegW		; negate exponent R25:R24

	; destination addres
6:	ldd	r30,Y+DATA_EDITMAX ; size of edit buffer
	clr	r31
	subi	r30,lo8(-(EditBuf))
	sbci	r31,hi8(-(EditBuf))

	; divide exponent / 10
; INPUT: R25:R24 = dividend (N1:N0)
; OUTPUT: R25:R24 = quotient (Q1:Q0), 0..6553
;         R1=0
; DESTROYS: R0
2:	movw	r26,r24		; R27:R26 <- exponent
	rcall	DivW10		; divide exponent / 10
	movw	r16,r24		; save quotient

	; multiply exponent back * 10
; INPUT: R25:R24 = multiplier (N1:N0)
; OUTPUT: R25:R24 = result (M1:M0)
;         R1=0
; DESTROYS: R0
	rcall	MulW10		; multiply * 10

	; get digit
	sub	r26,r24
	subi	r26,-'0'

	; on error, substitute digit by '9'
; OUTPUT: NZ = flag is set
; DESTROYS: -
	call	FlagTestErrDec	; test ErrDec
	breq	1f		; error flag not set
	ldi	r26,'9'		; use digit '9'	

	; save digit into buffer
1:	st	-Z,r26

	; increase exponent length
	inc	r21

	; check if exponent is 0
	movw	r24,r16		; R25:R24 <- exponent
	or	r16,r25		; check zero
	brne	2b		; decode next digit

	; store sign
	tst	r22		; is exponent negative?
	ldi	r24,'+'		; positive sign
	brpl	3f		; exponent is positive
	ldi	r24,'-'		; negative sign
3:	st	-Z,r24		; save sign
	inc	r21		; increase exponent length

	; decrease length of mantissa
	sub	r23,r21		; decrease total length

	; nmber of decimal digits
	mov	r18,r23		; number of total digits
	sub	r18,r19		; subtract number of integer digits

	; limit by fix
	ldd	r26,Y+DATA_FIX	; fixed decimals
	cpi	r26,FIX_OFF	; fix mode off?
	breq	DecNum3		; fix mode off
	cp	r26,r18		; check digits
	brge	DecNum3		; number of digits is OK
	mov	r18,r26		; limit number of decimal digits
	rjmp	DecNum3


; ===== Normal mode

; ----- prepare normal mode
; R23: total number of digits of mantissa
; R21: number of exponent digits (including sign)
; R20: number of additional zeroes on start of number (between decimal point and valid digits)
; R19: number of integer digits
; R18: number of decimal digits

DecNum2:
	; integer digits = exponent + 1, zero digits
	mov	r19,r24		; exponen LOW (exponent is < 14 here)

	ldi	r26,-1
	cpi	r19,-20		; check minimal exponent
	cpc	r25,r26
	brge	3f		; exponent is >= -20
5:	ldi	r19,-20		; minimal exponent

3:	inc	r19		; exponent + 1
	brmi	1f		; exponen is < 0, integer digits < 0
	brne	2f		; exponent is > 0, integer digits > 1

	; no integer digits, prepare zero digits
1:	mov	r20,r19		; zeroes
	neg	r20		; number of zero digits, 0..
	clr	r19		; no integer digit

	; limit max. number of zeroes
	ldd	r18,Y+DATA_EDITMAX ; max. size of edit buffer
	dec	r18
	neg	r18		; minimal exponent
	ldi	r26,-1		; minimal exponent HIGH
	cp	r24,r18
	cpc	r25,r26
	brge	2f		; exponent is OK
	ldd	r20,Y+DATA_EDITMAX ; max. size of edit buffer
	dec	r20		; limit number of zeroes

	; decimal digits
2:	mov	r18,r23		; number of total digits -> number of decimal digits
	sub	r18,r19		; subtract number of integer digits
	sub	r18,r20		; subtract zero digits
	brpl	8f		; ok
	add	r20,r18		; limit zero digits
	clr	r18		; limit number of decimal digits to 0
8:	add	r18,r20		; add zero digits

	; limit by fix
	ldd	r26,Y+DATA_FIX	; fixed decimals
	cpi	r26,FIX_OFF	; fix mode off?
	breq	DecNum3		; fix mode off

	cp	r26,r20		; check number of zero digits
	brge	4f		; number of zero digits is OK
	mov	r20,r26		; limit number of zero digits

4:	add	r18,r20		; add zero digits to decimal digits
	cp	r26,r18		; check digits
	brge	3f		; number of digits is OK
	mov	r18,r26		; limit number of decimal digits
3:	sub	r18,r20		; subtract zero digits

; ----- limit by display length
; R23: total number of digits of mantissa
; R21: number of exponent digits (including sign)
; R20: number of additional zeroes on start of number (between decimal point and valid digits)
; R19: number of integer digits
; R18: number of decimal digits

DecNum3:
	std	Y+DATA_EXPDIG,r21 ; save number of exponent digits

	; buffer size without exponent, sign and point
	ldd	r26,Y+DATA_EDITMAX ; total length
	subi	r26,2		; without sign and point
	sub	r26,r21		; subtract exponent

	; check integer digits
	sub	r26,r19		; subtract integer digits
	brpl	1f
	add	r19,r26		; limit integer digits if too much
	clr	r26		; no space left

	; check zero digits
1:	sub	r26,r20		; subtract zero digits
	brpl	2f
	add	r20,r26		; limit zero digits
	clr	r26		; no space left

	; check decimal digits
2:	sub	r26,r18		; subtract decimal digits
	brpl	3f
	add	r18,r26		; limit decimal digits


; ========================= Rounding ====================================
; R23: total number of digits of mantissa
; R21: number of exponent digits (including sign)
; R20: number of additional zeroes on start of number (between decimal point and valid digits)
; R19: number of integer digits
; R18: number of decimal digits

; ----- new total number of valid digits (without zero digits)

3:	mov	r23,r19		; integer digits
	add	r23,r18		; add decimal digits

; ----- check index of rounding coefficient

	cpi	r23,MAXROUND
	brcc	DecNum21	; invalid rounding coefficient

; ----- number 0 do not round

	rcall	CalcTopCheck	; get top number and check zero
	breq	DecNum21	; number 0

; ----- already rounded if restarting, do not repeat
; OUTPUT: NZ = flag is set
; DESTROYS: -
	call	FlagTestResDec	; check restart flag
	breq	DecNum22	; do rounding
DecNum21:
	rjmp	DecNum34	; no rounding

; ----- we will do rounding

DecNum22:
	; save registers
	push	r18
	push	r20
	push	r21
	push	r23		; total number of digits
	push	r19		; number of integer digits

; ----- rounding DEC number

	; check radix mode
	ldd	r24,Y+DATA_BASE	; radix base
	cpi	r24,BASE_DEC
	brne	DecNum23	; no dec radix

	; add rounding correction 0.00...005
	ldi	r24,NUM_BYTES
	mul	r23,r24		; offset of correction by total number of digits
	movw	r30,r0		; offset
	clr	r1		; restore zero register
	subi	r30,lo8(-(RoundTab))
	sbci	r31,hi8(-(RoundTab))
; INPUT: R31:R30 = constant in ROM
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConstROM	; load constant to stack
; DESTROYS: all
; CALCULATOR STACK: -1
	call	CalcAdd		; add rounding correction

	; check overflow mantissa to 10.0000
; DESTROYS: R31, R30, R27..R24
; CALCULATOR STACK: +1
	call	CalcDup		; duplicate number
	ldi	r24,CONST_10	; constant 10
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst
	ldi	r24,C_GREQ	; compare >= with constant 10
	rcall	CalcCmp		; compare -> 1=true
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; get result
	tst	r24		; check result
	breq	DecNum224	; result is OK (number is < 10), continue

	; divide mantissa by 10
	ldi	r24,CONST_01	; constant 0.1
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcMul		; divide mantissa

DecNum222:

	; increase exponent
	rcall	Split_IncExp

	; set restart flag
; DESTROYS: -
	call	FlagSetResDec	; set restart flag

	; correct engineering mode
	call	FlagTestEng	; check Eng mode
	breq	DecNum224	; not Eng mode

	pop	r19		; number of integer digits
	inc	r19		; increase number of integer digits
	rcall	Split_DecExp	; decrement exponent
	cpi	r19,4		; overflow integer?
	brcs	2f		; low number of digits
	subi	r19,3		; correct number of integer digits
	rcall	Split_IncExp	; increment exponent
	rcall	Split_IncExp	; increment exponent
	rcall	Split_IncExp	; increment exponent + 3
2:	push	r19		; number of integer digits
DecNum224:
	rjmp	DecNum28

; ----- rounding HEX number

DecNum23:
	cpi	r24,BASE_HEX
	brne	DecNum24	; no hex radix

	; load number 0
	ldi	r24,CONST_0	; constant 0
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst
	; set exponent to: EXP_1 - 1 - (totnum-1)*4
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get top number and check zero
	add	r23,r23
	add	r23,r23		; total number of digits * 4
	ldi	r24,lo8(EXP_BIAS - 1 + 4) ; EXP_1 - 1 + 4
	ldi	r25,hi8(EXP_BIAS - 1 + 4)
	sub	r24,r23		; exponent - 4*totnum
	sbc	r25,R_ZERO
	std	Z+0,r25		; save new exponent
	std	Z+1,r24
	; add rounding correction
; DESTROYS: all
; CALCULATOR STACK: -1
	call	CalcAdd		; add rounding correction

	; check overflow F.FFFF -> 10.0000
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get top number and check zero
	cpi	r24,lo8(EXP_BIAS+4) ; check overflow
	brcs	DecNum28	; number is OK

	; divide mantissa by 16
; DESTROYS: R31, R30, R25, R24
	rcall	CalcDiv16
	rjmp	DecNum252	; correct Engineer mode

; ----- rounding OCT number

DecNum24:
	cpi	r24,BASE_OCT
	brne	DecNum25	; no oct radix

	; load number 0
	ldi	r24,CONST_0	; constant 0
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst
	; set exponent to: EXP_1 - 1 - (totnum-1)*3
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get top number and check zero
	mov	r24,r23
	add	r23,r23
	add	r23,r24		; total number of digits * 3
	ldi	r24,lo8(EXP_BIAS - 1 + 3) ; EXP_1 - 1 + 3
	ldi	r25,hi8(EXP_BIAS - 1 + 3)
	sub	r24,r23		; exponent - 3*totnum
	sbc	r25,R_ZERO
	std	Z+0,r25		; save new exponent
	std	Z+1,r24
	; add rounding correction
; DESTROYS: all
; CALCULATOR STACK: -1
	call	CalcAdd		; add rounding correction

	; check overflow 7.7777 -> 10.0000
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get top number and check zero
	cpi	r24,lo8(EXP_BIAS+3) ; check overflow
	brcs	DecNum28	; number is OK

	; divide mantissa by 8
; DESTROYS: R31, R30, R25, R24
	rcall	CalcDiv8
	rjmp	DecNum222	; correct Engineer mode

; ----- rounding BIN number

DecNum25:
	; load number 0
	ldi	r24,CONST_0	; constant 0
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst
	; set exponent to: EXP_1 - 1 - (totnum-1)
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get top number and check zero
	ldi	r24,lo8(EXP_BIAS) ; EXP_1 - 1 + 1
	ldi	r25,hi8(EXP_BIAS)
	sub	r24,r23		; exponent - totnum
	sbc	r25,R_ZERO
	std	Z+0,r25		; save new exponent
	std	Z+1,r24
	; add rounding correction
; DESTROYS: all
; CALCULATOR STACK: -1
	call	CalcAdd		; add rounding correction

	; check overflow 1.1111 -> 10.0000
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get top number and check zero
	cpi	r24,lo8(EXP_BIAS+1) ; check overflow
	brcs	DecNum28	; number is OK

	; divide mantissa by 8
; DESTROYS: R31, R30, R25, R24
	rcall	CalcDiv2

DecNum252:

	; increase exponent
	rcall	Split_IncExp

	; set restart flag
; DESTROYS: -
	call	FlagSetResDec	; set restart flag

	; correct engineering mode
	call	FlagTestEng	; check Eng mode
	breq	DecNum28	; not Eng mode

	pop	r19		; number of integer digits
	inc	r19		; increase number of integer digits
	rcall	Split_DecExp	; decrement exponent
	cpi	r19,5		; overflow integer?
	brcs	2f		; low number of digits
	subi	r19,4		; correct number of integer digits
	rcall	Split_IncExp	; increment exponent
	rcall	Split_IncExp	; increment exponent
	rcall	Split_IncExp	; increment exponent
	rcall	Split_IncExp	; increment exponent + 4
2:	push	r19		; number of integer digits

	; pop registers
DecNum28:
 	pop	r19		; number of integer digits
	pop	r23
	pop	r21
	pop	r20
	pop	r18

	call	FlagTestResDec	; check restart flag
	breq	DecNum34	; continue, no overflow
	rjmp	DecNumRestart	; restart decode



; ==================== decode mantissa digits =======================
; R23: total number of digits of mantissa
; R21: number of exponent digits (including sign)
; R20: number of additional zeroes on start of number (between decimal point and valid digits)
; R19: number of integer digits
; R18: number of decimal digits

; ----- starting decimal point if integer digits = 0

DecNum34:
	call	FlagSetDP	; set decimal point flag

	ldi	r26,lo8(EditBuf+1) ; buffer
	ldi	r27,hi8(EditBuf+1)

	; if no integer digit, start with decimal point
	tst	r19		; check number of integer digits
	brne	2f		; integer digits are valid
	ldi	r24,'.'
	st	X+,r24		; store decimal point

; ----- store initial zeroes (R20)

2:	tst	r20		; check number of digits
	breq	DecNum36	; no initial zero

	ldi	r24,'0'
1:	st	X+,r24		; write zero
	dec	r20
	brne	1b

; ----- decode digits of mantissa (R23)
; R23: total digits of mantissa
; R19: number of integer digits
; R18: number of decimal digits

DecNum36:
	tst	r23		; some valid digits?
	breq	DecNum4		; no digits

	; push registers
5:	push	r23		; digit counter
	push	r19
	push	r18

	push	r26
	push	r27

; DESTROYS: R31, R30, R27..R24
; CALCULATOR STACK: +1
	rcall	CalcDup		; duplicate
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; get integer part of the number (= digit)
	mov	r23,r24		; save number

	; convert to valid digit
	cpi	r24,10
	brcs	2f
	subi	r24,-7		; HEX digit
2:	subi	r24,-'0'

	; on error substitute by '9'
; OUTPUT: NZ = flag is set
; DESTROYS: -
	call	FlagTestErrDec	; check error flag
	breq	3f		; error flag not set
	ldi	r24,'9'		; substitute by '9'
3:
	; write digit into buffer
	pop	r27
	pop	r26
	st	X+,r24		; write digit
	push	r26
	push	r27

	; stack digit back to the stack
	mov	r24,r23		; restore number
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	call	CalcStackB	; stack number

	; subtract digit from mantissa
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcSub		; subtract integer part

	; multiply mantissa by radix base
	ldd	r24,Y+DATA_BASE
	cpi	r24,BASE_DEC	; decimal base?
	brne	6f		; not dec base

	; multiply mantissa by 10
	ldi	r24,CONST_10	; constant 10
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcMul		; multiply mantissa by10
	rjmp	9f

	; multiply mantissa by 8
6:	cpi	r24,BASE_OCT	; octal base?
	brne	7f		; not octal base
	rcall	CalcMul8	; multiply by 8
	rjmp	9f

	; multiply mantissa by 16
7:	cpi	r24,BASE_HEX	; hex base?
	brne	8f		; not hex base
	rcall	CalcMul16	; multiply by 16
	rjmp	9f

	; multiply mantissa by 2
8:	rcall	CalcMul2	; multiply by 2

	; pop registers
9:	pop	r27
	pop	r26
	
	pop	r18
	pop	r19
	pop	r23

	; store decimal point
	dec	r19		; integer digits counter
	brne	2f
	ldi	r24,'.'
	st	X+,r24		; store decimal point

	; digit counter, next digit
2:	dec	r23		; digit counter
	brne	5b


; ======================= delete ending zeroes ========================
; R18: number of decimal digits

DecNum4:

; ----- delete ending zeroes of decimal part

	ldd	r24,Y+DATA_FIX	; fixed decimals
	cpi	r24,FIX_OFF	; fix mode off?
	brne	DecNum6		; fix mode on

	tst	r18		; any valid decimal digit?
	breq	3f		; no digit

	; delete zeroes of decimal part
1:	ld	r24,-X		; load previous character
	cpi	r24,'0'
	brne	2f		; not zero
	ldi	r24,' '
	st	X,r24		; set space
	dec	r18
	brne	1b		; next

	; check decimal point
3:	ld	r24,-X		; load previous character
2:
	cpi	r24,'.'		; last character is decimal point?
	brne	5f		; not decimal point

	; clear last decimal point
	ldi	r24,' '
	st	X,r24		; clear decimal point
	call	FlagClrDP	; clear flag of decimal point
	rjmp	DecNum6

5:	adiw	r26,1		; return behind last valid character


; ========================= shift mantissa right ======================

; ----- shift number right

DecNum6:
	; length of mantissa
	mov	r24,r26		; end of text
	subi	r24,lo8(EditBuf)
	std	Y+DATA_EDITDIG,r24 ; length of mantissa

	; offset of exponent
	ldd	r20,Y+DATA_EDITMAX ; buffer length
	ldd	r25,Y+DATA_EXPDIG ; exponent length
	sub	r20,r25		; offset of start of exponent

	; check if some shift is needed
	cp	r24,r20
	brcc	DecNum8		; no shift needed	

	; prepare pointers
	ldi	r30,lo8(EditBuf) ; buffer start
	ldi	r31,hi8(EditBuf)
	add	r30,r20		; start of exponent
	adc	r31,R_ZERO

	sub	r20,r24		; shift offset

	; shift text
1:	ld	r25,-X
	st	-Z,r25
	dec	r24
	brne	1b	

	; insert first '0'
	ldd	r24,Z+1		; last character before sign
	cpi	r24,' '
	breq	4f		; starting with ' '
	cpi	r24,'.'
	brne	3f		; it was not decimal point (it was digit)

4:	ldi	r24,'0'
	st	Z,r24		; save '0' instead of sign
	st	-Z,r25		; save sign again
	dec	r20		; decrease number of old characters
	breq	DecNum8		; no other old character left

	; clear old characters
3:	ldi	r24,' '
2:	st	-Z,r24
	dec	r20
	brne	2b

; ----- restore error and running flag

DecNum8:
	; ending 0
	ldd	r30,Y+DATA_EDITMAX ; buffer length
	clr	r31
	subi	r30,lo8(-(EditBuf))
	sbci	r31,hi8(-(EditBuf))
	st	Z,R_ZERO

; OUTPUT: NZ = flag is set
; DESTROYS: -
	call	FlagTestOldErr	; test old error
	brne	3f		; flag was set
	CLR_ERROR		; clear error flag

; OUTPUT: NZ = flag is set
; DESTROYS: -
3:	call	FlagTestOldRun	; test old running
	breq	2f		; flag was not set
	SET_RUNNING		; set running flag

; ----- delete number
; DESTROYS: R31, R30
; CALCULATOR STACK: -1
2:	rjmp	CalcDel		; delete number

; ----------------------------------------------------------------------------
;        Encode number from formated edit buffer to calculator stack
; ----------------------------------------------------------------------------
; CALCULATOR STACK: +1
; uses TEMP_1
; ----------------------------------------------------------------------------

.global EncNum
EncNum:

; ----- create new number
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; create new number
	rcall	CalcZ0		; clear number Z

; ----- prepare decimal multiplier -> TEMP_1

	ldi	r24,CONST_1	; constant 1
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst	; load constant
	ldi	r24,TEMP_1
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: -1
	rcall	CalcSetMemDel	; set memory 1 to value "1"

; ----- prepare pointer to start of mantissa -> R31:R30 (Z)

	ldd	r25,Y+DATA_EDITDIG ; length of mantissa
	ldd	r24,Y+DATA_EXPDIG ; length of exponent
	add	r24,r25		; length of mantissa + exponent

	ldi	r30,lo8(EditBuf+EDITBUF_SIZE) ; buffer
	ldi	r31,hi8(EditBuf+EDITBUF_SIZE)
	sub	r30,r24		; start of mantissa
	sbc	r31,R_ZERO

; ----- push sign into stack, for later usage

	ld	r24,Z+		; load sign
	cpi	r24,' '
	breq	2f		; valid '+' sign
	cpi	r24,'-'
	breq	2f		; valid '-' sign

	ldi	r24,' '		; not valid sign, we use '+'
	sbiw	r30,1		; return pointer
	inc	r25		; return length

2:	push	r24		; push sign
	dec	r25		; decrement length of mantissa

; ----- add integer digits to the mantissa

1:	push	r25		; digit counter

	; load character; decimal point switches to decimal digits
	ld	r24,Z+		; load digit
	cpi	r24,'.'		; decimal point?
	brne	3f		; not decimal point
	rjmp	EncNum3		; switch to decimal digits

	; we will multiply accumulator by 10/16/...
3:	push	r24		; character
	push	r30		; destination pointer
	push	r31

	; DEC radix, multiply by 10
	ldd	r25,Y+DATA_BASE	; radix base
	cpi	r25,BASE_DEC	; decimal base?
	brne	5f		; no dec base	

	ldi	r24,CONST_10	; constant 10
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst	; load constant to the stack
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcMul		; multiply mantissa by 10
	rjmp	8f

	; HEX radix, multiply by 16
5:	cpi	r25,BASE_HEX
	brne	6f
; DESTROYS: R31, R30, R25, R24
	rcall	CalcMul16	; multiply by 16
	rjmp	8f

	; OCT radix, multiply by 8
6:	cpi	r25,BASE_OCT
	brne	7f
; DESTROYS: R31, R30, R25, R24
	rcall	CalcMul8	; multiply by 8
	rjmp	8f

	; BIN radix, multiply by 2
7:	rcall	CalcMul2	; multiply by 2

8:	pop	r31
	pop	r30
	pop	r24

	; convert ASCII character to a number
	subi	r24,'0'
	cpi	r24,10
	brcs	9f
	subi	r24,7		; HEX digit

	; add digit to the accumulator
9:	push	r30
	push	r31
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	call	CalcStackB	; stack byte
; DESTROYS: all
; CALCULATOR STACK: -1
	call	CalcAdd		; add new digit to the mantissa
	pop	r31
	pop	r30

	; next digit of integer part
	pop	r25
	dec	r25		; digit counter
	brne	1b		; next digit of integer part
	rjmp	EncNum4		; no mantissa digit lefts

; ----- add decimal digits to the mantissa

2:	push	r25		; digit counter

	; we will divide multiplier by 10/16/...
	push	r30
	push	r31

	; load multiplier
	ldi	r24,TEMP_1
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	call	CalcGetMem	; load decimal multiplier

	; DEC radix, multiply by 0.1
	ldd	r25,Y+DATA_BASE	; radix base
	cpi	r25,BASE_DEC	; decimal base?
	brne	5f		; no dec base	

	ldi	r24,CONST_01	; constant 0.1
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst	; load constant
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcMul		; multiply multiplier by 0.1	
	rjmp	8f

	; HEX radix, divide by 16
5:	cpi	r25,BASE_HEX
	brne	6f
; DESTROYS: R31, R30, R25, R24
	rcall	CalcDiv16	; divide by 16
	rjmp	8f

	; OCT radix, divide by 8
6:	cpi	r25,BASE_OCT
	brne	7f
; DESTROYS: R31, R30, R25, R24
	rcall	CalcDiv8	; divide by 8
	rjmp	8f

	; BIN radix, divide by 2
7:	rcall	CalcDiv2	; divide by 2

	; save multiplier, but leave it on the stack
8:	ldi	r24,TEMP_1
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
	rcall	CalcSetMem	; save decimal multiplier

	pop	r31
	pop	r30

	; load digit and convert to a number
	ld	r24,Z+		; load digit
	subi	r24,'0'
	cpi	r24,10
	brcs	9f
	subi	r24,7		; HEX digit

	; multiply multiplier by digit and add it to the accumulator
9:	push	r30
	push	r31
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	call	CalcStackB	; stack byte
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcMul		; multiply by multiplier
; DESTROYS: all
; CALCULATOR STACK: -1
	call	CalcAdd		; add new digit to the mantissa
	pop	r31
	pop	r30

EncNum3:
	; next digit of decimal part
	pop	r25
	dec	r25		; digit counter
	brne	2b		; next digit

; ----- set sign of the mantissa

EncNum4:
	pop	r24		; sign, we had pushed it into stack more earlier

	cpi	r24,'-'		; minus?
	brne	EncNum5		; not minus
	push	r30
	push	r31
; DESTROYS: R31, R30, R25, R24
	rcall	CalcNeg		; negate mantissa
	pop	r31
	pop	r30

; ----- prepare to decode exponent

EncNum5:
	ldd	r22,Y+DATA_EXPDIG ; length of exponent
	tst	r22		; is any exponent?
	breq	EncNum7		; no exponent, finish

; ----- push sign of the exponent

	ld	r23,Z+		; load sign
	push	r23		; push sign
	dec	r22		; decrement length of exponent

; ----- load exponent digits -> R25:R24

	; clear accumulator
	clr	r25		; exponent accumulator HIGH
	clr	r24		; exponent accumulator LOW

	; multiply accumulator by 10
; INPUT: R25:R24 = multiplier (N1:N0)
; OUTPUT: R25:R24 = result (M1:M0)
;         R1=0
; DESTROYS: R0
1:	rcall	MulW10		; multiply by 10

	; add next digit to the accumulator
	ld	r21,Z+		; load digit
	subi	r21,'0'
	add	r24,r21		; add digit to the accumulator
	adc	r25,R_ZERO

	; next digit
	dec	r22		; digit counter
	brne	1b		; next digit

; ----- check radix base 10

	ldd	r22,Y+DATA_BASE	; radix base
	cpi	r22,BASE_DEC	; decimal base?
	breq	EncNum8		; add decimal exponent

; ----- binary exponents - convert to 2-base

	; hex base * 4
	cpi	r22,BASE_HEX	; hex base?
	brne	3f		; not hex
	add	r24,r24
	adc	r25,r25
	add	r24,r24
	adc	r25,r25		; exponent * 4

	; oct base * 4
3:	cpi	r22,BASE_OCT	; oct base?
	brne	4f		; not oct
	movw	r22,r24
	add	r24,r24
	adc	r25,r25
	add	r24,r22
	adc	r25,r23		; exponent * 3

; ----- set sign of binary exponent

4:	pop	r21		; sign of exponent
	cpi	r21,'-'		; minus?
	brne	5f		; exponent is not negative
; INPUT/OUTPUT: R25:R24 = number to negate
; DESTROYS: -
	rcall	NegW		; negate R25:R24

; ----- add exponent to mantissa

5:	movw	r22,r24
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get top number -> Z, R24
	add	r24,r22		; add exponent
	adc	r25,r23
	std	Z+0,r25		; save exponent
	std	Z+1,r24
EncNum7:
	ret

; ----- multiply mantissa by exponent R25:R24
; Exponent table ExpTab:
;  0: 1e-8192
;  ...
;  14: 1
;  ...
;  28: 1e+8192

EncNum8:
	ldi	r30,lo8(ExpTab+14*NUM_BYTES) ; address of '1'
	ldi	r31,hi8(ExpTab+14*NUM_BYTES)

	; prepare direction increment
	ldi	r22,-NUM_BYTES ; negative increment
	ldi	r23,0xff
	pop	r21		; sign of exponent
	cpi	r21,'-'		; minus?
	breq	2f		; exponent is negative
	ldi	r22,NUM_BYTES	; positive increment
	ldi	r23,0

	; shift pointer
2:	add	r30,r22		; shift pointer
	adc	r31,r23

	; shift exponent and check one bit
	lsr	r25
	ror	r24		; shift exponent
	brcc	4f		; bit is not set

	; multiply accumulator by decimal exponent
	push	r22
	push	r23
	push	r24
	push	r25
	push	r30
	push	r31

; INPUT: R31:R30 = constant in ROM
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConstROM	; stack constant
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcMul		; multiply number by exponent

	pop	r31
	pop	r30
	pop	r25
	pop	r24
	pop	r23
	pop	r22

	; check if exponent is 0
4:	mov	r26,r24
	or	r26,r25		; all done?
	brne	2b		; next bit

EncNum9:
	ret
