; ****************************************************************************
;
;                        Calculator macro interpreter
;
; ****************************************************************************

#include "include.inc"

	.text

; ----------------------------------------------------------------------------
;                         Shift random generator
; ----------------------------------------------------------------------------
; OUTPUT: R25:R24:R23:R22 = new seed
;         R1 = 0
; DESTROYS: R31, R30, R27, R26, R21..R18, R0
; ----------------------------------------------------------------------------
; RandSeed = RandSeed * 214013 + 2531011;

.global RandShift
RandShift:

; ----- load seed -> R25:R24:R23:R22

	ldd	r22,Y+DATA_RANDSEED+0
	ldd	r23,Y+DATA_RANDSEED+1
	ldd	r24,Y+DATA_RANDSEED+2
	ldd	r25,Y+DATA_RANDSEED+3

; ----- prepare multiplier 214013 = 0x000343FD -> R21:R20:R19:R18

	ldi	r18,0xfd
	ldi	r19,0x43
	ldi	r20,0x03
	ldi	r21,0x00

; ----- multiply
; INPUT: R25:R24:R23:R22 = 1st multiplier (N3:N2:N1:N0)
;        R21:R20:R19:R18 = 2nd multiplier (N7:N6:N5:N4)
; OUTPUT: R25:R24:R23:R22 = result (M3:M2:M1:M0)
;         R1=0
; DESTROYS: R31, R30, R27, R26, R0

	rcall	MulDD

; ----- add 2531011 = 0x00269EC3, neg -2531011 = 0xFFD9613D

	subi	r22,0x3d
	sbci	r23,0x61
	sbci	r24,0xd9
	sbci	r25,0xff

; ----- save seed

	std	Y+DATA_RANDSEED+0,r22
	std	Y+DATA_RANDSEED+1,r23
	std	Y+DATA_RANDSEED+2,r24
	std	Y+DATA_RANDSEED+3,r25
	ret

; ----------------------------------------------------------------------------
;                    Random number (0 inc. .. 1 exc., C_RAND)
; ----------------------------------------------------------------------------
; CALCULATOR STACK: +1
; ----------------------------------------------------------------------------

.global CalcRand
CalcRand:

; ----- shift random generator, get random number
; OUTPUT: R25:R24:R23:R22 = new seed
;         R1 = 0
; DESTROYS: R31, R30, R27, R26, R21..R18, R0
	rcall	RandShift

; ----- prepare number (R_M1..R_M10 = R23..R14)

	clr	R_M10
	clr	R_M9
	movw	R_M8,R_M10
	movw	R_M6,r22
	movw	R_M4,r24
	ldi	R_M2,lo8(EXP_BIAS-1) ; exponent 0.xxxx
	ldi	R_M1,hi8(EXP_BIAS-1)

; ----- normalize number
		
	ldi	r24,33		; max. number of shifts
2:	sbrc	R_M3,7		; check highest bit of mantissa
	rjmp	4f		; highest bit is on the position, number is normalized

	clc			; clear carry
; INPUT: R_M3..R_M10 mantissa
;	 C = input carry
; OUTPUT: R_M3..R_M10 mantissa shifted left
;	 C = output carry
; DESTROYS: -
	rcall	CalcMantRol	; rotate mantissa left (with carry)
	subi	R_M2,1		; decrement exponent LOW
	sbc	R_M1,R_ZERO
	dec	r24		; bit counter
	brne	2b

; underflow, number is zero
; OUTPUT: R_M1..R_M10 number (= 0)
; DESTROYS: -
	rcall	CalcClearNum	; clear result

; ----- clear hidden bit

4:	andi	R_M3,0x7f

; ----- create new number on top of stack
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; create new number -> Z

; ----- save number
; INPUT: R31:R30 (Z) = pointer to number
;	 R_M1..R_M10 number
; DESTROYS: -
	rjmp	CalcSaveNum

; ----------------------------------------------------------------------------
;                           Square x^2 (C_SQR)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R4
; ----------------------------------------------------------------------------

.global CalcSqr
CalcSqr:
; DESTROYS: R31, R30, R27..R24
; CALCULATOR STACK: +1
	rcall	CalcDup		; duplicate
; DESTROYS: all
; CALCULATOR STACK: -1
	rjmp	CalcMul		; multiplication

; ----------------------------------------------------------------------------
;                       Reciprocal value 1/x (C_REC)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R4
; ----------------------------------------------------------------------------

.global CalcRec
CalcRec:
	ldi	r24,CONST_1
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst	; load constant "1"
; DESTROYS: R31, R30, R27..R23
	rcall	CalcExc		; exchange operands
; DESTROYS: all
; CALCULATOR STACK: -1
	rjmp	CalcDiv		; divide

; ----------------------------------------------------------------------------
;                       Increment +1 (C_INC)
; ----------------------------------------------------------------------------
; DESTROYS: all
; ----------------------------------------------------------------------------

.global CalcInc
CalcInc:
	ldi	r24,CONST_1
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst	; load constant "1"
; DESTROYS: all
; CALCULATOR STACK: -1
	rjmp	CalcAdd		; add 1

; ----------------------------------------------------------------------------
;                       Decrement -1 (C_DEC)
; ----------------------------------------------------------------------------
; DESTROYS: all
; ----------------------------------------------------------------------------

.global CalcDec
CalcDec:
	ldi	r24,CONST_M1
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst	; load constant "-1"
; DESTROYS: all
; CALCULATOR STACK: -1
	rjmp	CalcAdd		; sub 1

; ----------------------------------------------------------------------------
;                          Compare (C_LTEQ..C_EQU)
; ----------------------------------------------------------------------------
; INPUT: R24 = literal
; DESTROYS: R31, R30, R27..R10
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------
; Leaves 0/1 on top of calculator stack.

.global CalcCmp
CalcCmp:

; ----- get last 2 numbers -> 1st number X, 2nd number Z
; OUTPUT: R27:R26 (X) = pre-last number on calculator stack
;	  R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop2

; ----- prepare comparison code -> R24
; <= 000, >= 001, <> 010
;  > 100,  < 101,  = 110

	subi	r24,C_LTEQ

; ----- swap operands in cases >= and <
; <= 00, <> 01
;  > 10,  = 11

	lsr	r24		; shift right
; <= xx00, <> xx01
;  > xx10,  = xx11
	brcc	1f		; skip if bit 0 is clear

; DESTROYS: R31, R30, R27..R23

	push	r24		; push comparison flags
; DESTROYS: R31, R30, R27..R23
	rcall	CalcExc		; swap two numbers on the stack
	pop	r24		; pop comparison flags

; ----- substract numbers (result leaves on top of stack)
;   top number: 0 if numbers are equal

1:	push	r24
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcSub
	pop	r24		; pop comparison flags

; ----- process result
; top number = 1st number - 2nd number
; <= 00, <> 01, > 10, = 11

; DESTROYS: R31, R30, R25, R24

	push	r24		; push comparison flags
	sbrc	r24,0		; skip if bit 0 is clear (= equal flag)
	rcall	CalcNot		; invert result number if bit 0 is set

; top number = 1st number - 2nd number = dif
; dif = 0 (numbers are equal): <= 00 (->0), <> 01 (->1), > 10 (->0), = 11 (->1)
; dif <> 0: <= 00 (dif), <> 01 (->0), > 10 (dif), = 11 (->0)

; DESTROYS: R31, R30, R27..R23, R1, R0

	rcall	CalcGr0		; greater-0, sets 1 if number was > 0, or 0 otherwise

; dif > 0: <= 00 (->1), <> 01 (->0), > 10 (->1), = 11 (->0)
; dif < 0: <= 00 (->0), <> 01 (->0), > 10 (->0), = 11 (->0)

	pop	r24		; pop comparison flags

; ----- apply a terminal NOT by bit 2 of comparison flag - inverts meaning of <= and <>

; DESTROYS: R31, R30, R25, R24

	sbrs	r24,1		; skip if bit 1 (old bit 2) is set
	rcall	CalcNot		; NOT result if bit 1 is clear

; dif = 0: <= 00 (->1), <> 01 (->0), > 10 (->0), = 11 (->1)
; dif > 0: <= 00 (->0), <> 01 (->1), > 10 (->1), = 11 (->0)
; dif < 0: <= 00 (->1), <> 01 (->1), > 10 (->0), = 11 (->0)

CalcCmp9:
	ret

; ----------------------------------------------------------------------------
;             Check if number if less than zero (C_LT0)
; ----------------------------------------------------------------------------
; Set number to 1 if number is < 0 (not equ), or 0 otherwise.

.global CalcLt0
CalcLt0:

; ----- get last number on calculator stack -> Z
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop

; ----- prepare mask for check

	ldi	r24,0		; XOR mask

; ----- check sign bit

CalcLt02: ; jump here from CalcGr0
	ldd	r25,Z+2		; get sign bit (from first byte of mantissa)
	eor	r25,r24		; check sign bit

; ----- set result
; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10

	brmi	CalcZ1		; set to 1 in case of negative number (or positive from CalcGr0)

; CalcZ0 must follow

; ----------------------------------------------------------------------------
;                      Set number in Z to value 0
; ----------------------------------------------------------------------------
; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10
; ----------------------------------------------------------------------------

.global CalcZ0
CalcZ0:
; OUTPUT: R_M1..R_M10 number (= 0)
; DESTROYS: -
	rcall	CalcClearNum	; clear number R_M1..R_M10
; INPUT: R31:R30 (Z) = pointer to number
;	 R_M1..R_M10 number
; DESTROYS: -
	rjmp	CalcSaveNum	; save number into Z

; ----------------------------------------------------------------------------
;                      Set number in Z to value 1
; ----------------------------------------------------------------------------
; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10
; ----------------------------------------------------------------------------

.global CalcZ1
CalcZ1:
; OUTPUT: R_M1..R_M10 number (= 0)
; DESTROYS: -
	rcall	CalcClearNum	; clear number R_M1..R_M10
	ldi	R_M1,hi8(EXP_BIAS)
; INPUT: R31:R30 (Z) = pointer to number
;	 R_M1..R_M10 number
; DESTROYS: -
	rjmp	CalcSaveNum	; save number into Z

; ----------------------------------------------------------------------------
;                      Set number in Z to max. value
; ----------------------------------------------------------------------------
; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10
; ----------------------------------------------------------------------------

.global CalcZMax
CalcZMax:
	ldi	R_M2,lo8(EXP_MAX)
CalcZMax2:
	ldi	R_M1,hi8(EXP_MAX)
	ldi	R_M3,0x7f
	ldi	R_M4,0xff
	ldi	R_M5,0xff
	ldi	R_M6,0xff
	movw	R_M8,R_M6
	movw	R_M10,R_M6
; INPUT: R31:R30 (Z) = pointer to number
;	 R_M1..R_M10 number
; DESTROYS: -
	rjmp	CalcSaveNum	; save number

; ----------------------------------------------------------------------------
;                      Set number in Z to overflow value
; ----------------------------------------------------------------------------
; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10
; ----------------------------------------------------------------------------

.global CalcZOver
CalcZOver:
	ldi	R_M2,lo8(EXP_OVER)
	rjmp	CalcZMax2

; ----------------------------------------------------------------------------
;            Check if number if greater than zero (C_GR0)
; ----------------------------------------------------------------------------
; Set number to 1 if number is > 0 (not equ), or 0 otherwise.

.global CalcGr0
CalcGr0:

; ----- get last number and check if zero -> Z, R24
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck
	breq	CalcCmp9	; zero number left unchanged

; ----- prepare mask for check

	ldi	r24,0xff	; negative mask
	rjmp	CalcLt02

; ----------------------------------------------------------------------------
;             Check if number if less or equ zero (C_LTEQ0)
; ----------------------------------------------------------------------------
; Set number to 1 if number is <= 0, or 0 otherwise.

.global CalcLtEq0
CalcLtEq0:
	rcall	CalcGr0		; set to 1 if number is > 0 (not equ), or 0 otherwise
	rjmp	CalcNot		; inverse result

; ----------------------------------------------------------------------------
;             Check if number if greater or equ zero (C_GREQ0)
; ----------------------------------------------------------------------------
; Set number to 1 if number is >= 0, or 0 otherwise.

.global CalcGrEq0
CalcGrEq0:
	rcall	CalcLt0		; set to 1 if number is < 0 (not equ), or 0 otherwise

; CalcNot must follow

; ----------------------------------------------------------------------------
;                            NOT operator (C_NOT)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24, R_M1,...R_M10
; ----------------------------------------------------------------------------
; Returns value 0 or 1.

.global CalcNot
CalcNot:

; ----- get last number and check if zero -> Z, R24
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck

; ----- set result
; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10

	breq	CalcZ1		; set to 1 in case of zero
	rjmp	CalcZ0		; set to 0 in case of not zero

; ----------------------------------------------------------------------------
;                            OR operator (C_OR)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------
; Result is zero, if both values are zero; else a non-zero value.
; e.g.    0 OR 0  returns 0.
;        -3 OR 0  returns -3.
;         0 OR -3 returns 1.
;        -3 OR 2  returns 1.

.global CalcOr
CalcOr:

; ----- get last number and check if zero -> Z, R24
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck

; ----- destroy last number (saves SREG)

	rcall	CalcDel2	; set new end of stack (saves SREG)

; ----- if second number is zero, first operand will stay unchanged

	breq	CalcCmp9	; second number is zero -> first number will contain result (0 or nonzero number)

; ----- second number is not zero, result will be TRUE - set number in Z to +1
; OUTPUT: R31:R30 (Z) = last number on calculator stack (=STKEND-NUM_BYTES)
; DESTROYS: R24, R_M1..R_M10

; CalcTopZ1 must follow

; ----------------------------------------------------------------------------
;                   Set number on top of the stack to 1
; ----------------------------------------------------------------------------
; OUTPUT: R31:R30 (Z) = last number on calculator stack (=STKEND-NUM_BYTES)
; DESTROYS: R24, R_M1..R_M10
; ----------------------------------------------------------------------------

.global CalcTopZ1
CalcTopZ1:
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop		; get last number -> Z

; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10

	rjmp	CalcZ1		; set new last number to 1

; ----------------------------------------------------------------------------
;                            AND operator (C_AND)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24, R_M1,...R_M10
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------
; Result is zero, if any of the values is zero; else a non-zero value.
; e.g.    -3 AND 2  returns -3.
;         -3 AND 0  returns 0.
;          0 and -2 returns 0.
;          0 and 0  returns 0.

.global CalcAnd
CalcAnd:

; ----- get last number and check if zero -> Z, R24
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck

; ----- destroy last number (saves SREG)

	rcall	CalcDel2	; set new end of stack (saves SREG)

; ----- if second number is not zero, first operand will stay unchanged

	brne	CalcCmp9	; second number is not zero -> first number will containg result

; ----- second number is zero, result will be FALSE - set number in Z to 0

; CalcTopZ0 must follow

; ----------------------------------------------------------------------------
;                   Set number on top of the stack to 0
; ----------------------------------------------------------------------------
; OUTPUT: R31:R30 (Z) = last number on calculator stack (=STKEND-NUM_BYTES)
; DESTROYS: R_M1,...R_M10
; ----------------------------------------------------------------------------

.global CalcTopZ0
CalcTopZ0:

; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop		; get last number -> Z

; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10

	rjmp	CalcZ0		; set number Z to 0

; ----------------------------------------------------------------------------
;                             Signum (C_SGN)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10
; ----------------------------------------------------------------------------
; Replace number on top of calculator stack by value -1, 0, 1.

.global CalcSgn
CalcSgn:

; ----- get last number and check if zero -> Z, R24
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck
	breq	CalcSgn9	; zero number left unchanged

; ----- load sign (bit 7 in 1st byte of mantissa)

	ldd	r25,Z+2		; R25 <- first byte of mantissa

; ----- set number in Z to +1
; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10

	rcall	CalcZ1

; ----- save sign of the number back to mantissa

	andi	r25,0x80	; mask sign bit (= number +1 or -1)
CalcSgn8:
	std	Z+2,r25		; set sign back to mantissa
CalcSgn9:
	ret

; ----------------------------------------------------------------------------
;                           Unary minus, Negate (C_NEG)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; ----------------------------------------------------------------------------

.global CalcNeg
CalcNeg:

; ----- get last number and check if zero -> Z, R24
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck
	breq	CalcSgn9	; zero number left unchanged

; ----- load sign (bit 7 in 1st byte of mantissa)

	ldd	r25,Z+2		; R25 <- first byte of mantissa
	subi	r25,0x80	; flip sign
	rjmp	CalcSgn8	; set new sign

; ----------------------------------------------------------------------------
;                             Absolute value (C_ABS)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25
; ----------------------------------------------------------------------------

.global CalcAbs
CalcAbs:

; ----- get last number on calculator stack -> Z
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop

; ----- load sign (bit 7 in 1st byte of mantissa)

	ldd	r25,Z+2		; R25 <- first byte of mantissa
	andi	r25,0x7f	; reset sign bit
	rjmp	CalcSgn8	; set new sign

; ----------------------------------------------------------------------------
;            Integer precise truncation towards zero (C_TRUNCPREC)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R23, R_M1,...R_M10
; ----------------------------------------------------------------------------
; - no rounding epsilon delta, simple clears fractional bits

.global CalcTruncPrec
CalcTruncPrec:

; ----- get last number and check if zero -> Z, R25:R24
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck
	subi	r24,lo8(EXP_BIAS) ; check bias
	sbci	r25,hi8(EXP_BIAS)
	brcc	CalcTruncPrec2	; 1 or greater

; ----- number is smaller than +-1, can be made zero
; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10

	rjmp	CalcZ0		; clear number to 0

; ----- prepare number of bits to clear

CalcTruncPrec2:
	tst	r25		; check exponent HIGH
	brne	CalcTruncPrec9	; number is too high, always integer (no fractional part)
	subi	r24,MANT_BITS-1 ; subtract max. bits from exponent
	brcc	CalcTruncPrec9	; number is too high, always integer (no fractional part)

	neg	r24		; number of bits = MANT_BITS-1..1

; ----- prepare number of bytes to clear

CalcTruncPrec3:
	adiw	r30,NUM_BYTES	; shift pointer behind end of number
	mov	r22,r24		; R22 <- number of bits
	lsr	r22
	lsr	r22
	lsr	r22		; number of bits / 8 = number of bytes
	breq	CalcTruncPrec6	; no whole byte

; ----- reset whole bytes to 0

CalcTruncPrec4:
	st	-Z,R_ZERO	; set 8 bits to 0
	dec	r22		; byte counter
	brne	CalcTruncPrec4	; next byte

; ----- reset remaining bits

CalcTruncPrec6:
	andi	r24,7		; remaining bits
	breq	CalcTruncPrec9	; no bits

	ldi	r22,0xff	; mask
CalcTruncPrec8:
	lsl	r22
	dec	r24
	brne	CalcTruncPrec8	; prepare mask

	ld	r24,-Z
	and	r24,r22		; mask bits
	st	Z,r24

CalcTruncPrec9:
	ret

; ----------------------------------------------------------------------------
;                           Round nearest (C_ROUND)
; ----------------------------------------------------------------------------

.global CalcRound
CalcRound:

	rcall	Calc
; offset 0
	.byte	C_CONST(CONST_05) ; load 0.5 constant (x,0.5)
	.byte	C_DUP2		; pre-duplicate (x,0.5,x)
	.byte	C_GR0		; greater 0 (x,0.5,1/0)
	.byte	C_JUMPT		; jump if true, jump if > 0 (x,0.5)
	.byte	1		; jump to offset 6 (6-5=1)
; offset 5
	.byte	C_NEG		; negate if < 0 (x,-0.5)
; offset 6
	.byte	C_ADD		; add rounding correction
	.byte	C_PRECOR	; add pre-correction
	.byte	C_TRUNCPREC	; precise truncation
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;                     Round nearest fraction -0.5..+0.5 (C_ROUNDFRAC)
; ----------------------------------------------------------------------------

.global CalcRoundFrac
CalcRoundFrac:

	rcall	Calc
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_ROUND		; round nearest (x,round(x))
	.byte	C_SUB		; difference -0.5..+0.5 (x-round(x))
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;                  Integer truncation towards zero (C_TRUNC)
; ----------------------------------------------------------------------------

.global CalcTrunc
CalcTrunc:

	rcall	Calc
; offset 0: calculate round nearest and its difference
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_ROUND		; round nearest (x,r) ... r=round(x)
	.byte	C_DUP2		; pre-duplicate (x,r,x)
	.byte	C_DUP2		; pre-duplicate (x,r,x,r)
	.byte	C_SUB		; subtract (x,r,d) ... d=x-round(x)

; offset 5: check if number was negative
	.byte	C_EXC		; exchange (x,d,r)
	.byte	C_EXC2		; exchange (r,d,x)
	.byte	C_LT0		; less 0 (r,d,0/1)
	.byte	C_JUMPT		; jump if true, jump if x < 0 (r,d)
	.byte	6		; jump to offset 16 (16-10=6)

; offset 10: number is positive
	.byte	C_LT0		; difference is less 0 (r,0/1)
	.byte	C_JUMPF		; jump if false, jump if difference not < 0 (r)
	.byte	7		; jump to offset 20 (20-13=7)
; offset 13: decrement if difference < 0
	.byte	C_DEC		; decrement (r-1)
	.byte	C_JMP		; jump to end
	.byte	4		; jump to offset 20 (20-16=4)

; offset 16: number is negative
	.byte	C_GR0		; greater 0 (r,0/1)
	.byte	C_JUMPF		; jump if false, jump if difference not > 0 (r)
	.byte	1		; jump to offset 20 (20-19=1)
; offset 19: increment if difference > 0
	.byte	C_INC		; increment

; offset 20: end
	.byte	C_END		; end
; offset 21:
	.balign 2		; align
; offset 22:
	ret

; ----------------------------------------------------------------------------
;                           Round down (C_FLOOR)
; ----------------------------------------------------------------------------

.global CalcFloor
CalcFloor:
	rcall	Calc
; offset 0: calculate round nearest and its difference
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_ROUND		; round nearest (x,r) ... r=round(x)
	.byte	C_EXC		; exchange (r,x)
	.byte	C_DUP2		; duplicate (r,x,r)
	.byte	C_SUB		; subtract (r,x-r)
	.byte	C_LT0		; less 0 (r,0/1)
	.byte	C_JUMPF		; jump if false, jump if difference not < 0 (r)
	.byte	1		; jump to offset 9 (9-8=1)
; offset 8: decrement if difference < 0
	.byte	C_DEC		; decrement
; offset 9: end
	.byte	C_END		; end
; offset 10:
	.balign 2		; align
; offset 10:
	ret

; ----------------------------------------------------------------------------
;                           Round up (C_CEIL)
; ----------------------------------------------------------------------------

.global CalcCeil
CalcCeil:
	rcall	Calc
; offset 0: calculate round nearest and its difference
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_ROUND		; round nearest (x,r) ... r=round(x)
	.byte	C_EXC		; exchange (r,x)
	.byte	C_DUP2		; duplicate (r,x,r)
	.byte	C_SUB		; subtract (r,x-r)
	.byte	C_GR0		; greater 0 (r,0/1)
	.byte	C_JUMPF		; jump if false, jump if difference not > 0 (r)
	.byte	1		; jump to offset 9 (9-8=1)
; offset 8: increment if difference > 0
	.byte	C_INC		; increment
; offset 9: end
	.byte	C_END		; end
; offset 10:
	.balign 2		; align
; offset 10:
	ret

; ----------------------------------------------------------------------------
;                   Normalize angle argument (C_ARG)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R23, R1, R0
; ----------------------------------------------------------------------------
; Result lies in range 0..2*PI

.global CalcArg
CalcArg:

	rcall	Calc		; (x)
	.byte	C_CONST(CONST_PI2) ; add 2*PI constant
	.byte	C_MOD2		; modulus floor
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;     Add serie member to accumulator and loop if meaningful (C_ADDLOOP)
; ----------------------------------------------------------------------------
; INPUT: R_LITH:R_LITL = pointer to literals
;	 R_ZERO = 0
; OUTPUT: R_LITH:R_LITL = new pointer to literals
; DESTROYS: R31, R30, R27..R22
; ----------------------------------------------------------------------------

.global CalcAddLoop
CalcAddLoop:

; ----- get 2 top numbers
; OUTPUT: R27:R26 (X) = pre-last number on calculator stack
;	  R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop2

; ----- 1st number (accumulator) is infinity - stop iteration

	ld	r23,X+		; exponent HIGH
	ld	r22,X		; exponent LOW
	ldi	r24,hi8(EXP_OVER)
	cpi	r22,lo8(EXP_OVER)
	cpc	r23,r24
	breq	CalcAddLoop6	; infinity

; ----- 2nd number (serie member) is zero or infinity - stop iteration

	ldd	r25,Z+0		; exponent HIGH
	ldd	r24,Z+1		; exponent LOW
	adiw	r24,1
	sbiw	r24,1
	breq	CalcAddLoop6	; 2nd number is zero - end iteration
	brcs	CalcAddLoop6	; infinity

; ----- compare exponents

	sub	r22,r24
	sbc	r23,r25		; difference of exponents
	brcs	CalcAddLoop4	; member is greater than accumulator - continue
	cpi	r22,MANT_BITS + MANT_BITS/16 ; check distance
	cpc	r23,R_ZERO	
	brcc	CalcAddLoop6	; member is too small, break

; ----- add numbers

CalcAddLoop4:
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcAdd		; add numbers

; ----- jump to loop begin
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
; DESTROYS: R25, R24
; NOTES: Jump offset is relative to next byte after JUMP intruction
	rjmp	CalcJump

; ----- stop loop - only destroy literal with jump offset

CalcAddLoop6:
; DESTROYS: R31, R30
; CALCULATOR STACK: -1
	rcall	CalcDel		; delete member

; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
;	 R24 = next literal
; DESTROYS: -
	rjmp	CalcLit		; load literal -> R24

; ----------------------------------------------------------------------------
;                             Cosine (C_COS)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; USES: TEMP_1, TEMP_2, TEMP_3, TEMP_4
; ----------------------------------------------------------------------------
; cos(x) = sin(x+PI/2)

.global CalcCos
CalcCos:

; ----- add angle PI/2

	rcall	Calc		; calculator
	.byte	C_CONST(CONST_PI05) ; load constant PI/2
	.byte	C_ADD		; add PI/2 to angle
	.byte	C_END		; end
	.balign 2		; align

; CalcSin must follow

; ----------------------------------------------------------------------------
;                             Sine (C_SIN)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; USES: TEMP_1, TEMP_2, TEMP_3, TEMP_4
; ----------------------------------------------------------------------------
; Taylor serie xi+1 = xi * -x^2/((2*i)*(2*i+1)) ... x0 = x
; sin(x) = x/1! - x^3/3! + x^5/5! - x^7/7! + x^9/9! - ...

.global CalcSin
CalcSin:

	rcall	Calc		; calculator
; offset 0: normalize angle into range 0..PI*2
	.byte	C_ARG		; normalize angle (x) (uses TEMP_1, TEMP_2)
; offset 1: normalize angle into range 0..PI (if x >= PI then x = 2*PI - x)
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_CONST(CONST_PI) ; load constant PI (x,x,PI)
	.byte	C_LT		; check if x < PI (x,1/0)
	.byte	C_SETMEM(TEMP_1) ; save 1/0 into temp 1 (0=result will be negative)
	.byte	C_JUMPT		; skip if x < PI (x)
	.byte	3		; jump to offset 10 (10-7=3)
; offset 7:
	.byte	C_CONST(CONST_PI2) ; load constant PI*2 (x,PI*2)
	.byte	C_EXC		; exchange (PI*2,x)
	.byte	C_SUB		; subtract (PI*2-x)
; offset 10: number is zero, result will be zero
	.byte	C_JUMPZ		; skip if x = 0 (x)
	.byte	39		; jump to offset 51 (51-12=39)
; offset 12: number is PI, result will be zero
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_CONST(CONST_PI) ; load constant PI (x,x,PI)
	.byte	C_SUB		; subtract (x,x-PI)
	.byte	C_JUMPF		; jump if x = PI, result will be 0
	.byte	34		; jump to offset 51 (51-17=34)
; offset 17: prepare square -x^2 into TEMP_2
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_SQR		; square (x, x^2)
	.byte	C_NEG		; negate (x, -x^2)
	.byte	C_SETMEMDEL(TEMP_2) ; save -x^2 into TEMP_2
; offset 21: prepare factorial coefficient 1 into TEMP_3
	.byte	C_CONST(CONST_1) ; load constant 1 (x,1)
	.byte	C_SETMEMDEL(TEMP_3) ; save 1 into TEMP_3
; offset 23: prepare member x into TEMP_4
	.byte	C_SETMEM(TEMP_4) ; save x into TEMP 4

; ===== start of loop
; offset 24: multiply member by -x^2
	.byte	C_GETMEM(TEMP_4) ; load member (res,mem)
	.byte	C_GETMEM(TEMP_2) ; load -x^2 (res,mem,-x^2)
	.byte	C_MUL		; multiply member by -x^2 (res,mem*-x^2)
; offset 27: increment factorial coefficient
	.byte	C_GETMEM(TEMP_3) ; load factorial coefficient form TEMP_3 (res,mem2,coef)
	.byte	C_INC		; increment (res,mem2,coef+1)
	.byte	C_SETMEM(TEMP_3) ; save new factorial coefficient
; offset 30: divide member by factorial coefficient
	.byte	C_DIV		; divide (res,mem2/coef2)
; offset 31: increment factorial coefficient again
	.byte	C_GETMEM(TEMP_3) ; load factorial coefficient form TEMP_3 (res,mem3,coef2)
	.byte	C_INC		; increment (res,mem3,coef2+1)
	.byte	C_SETMEM(TEMP_3) ; save new factorial coefficient (res,mem3,coef3)
; offset 34: divide member by factorial coefficient
	.byte	C_DIV		; divide (res,mem3/coef3)
; offset 35: save new member
	.byte	C_SETMEM(TEMP_4) ; save member
; offset 36: add member to accumulator and loop if meaningful
	.byte	C_ADDLOOP	; add and loop
	.byte	-14		; jump to offset 24 (24-38=-14)

; ===== clip result to range -1..+1
; offset 38:
	.byte	C_DUP		; duplicate (res,res)
	.byte	C_CONST(CONST_1) ; load constant 1 (res,res,1)
	.byte	C_LT		; check if res < 1 (res,0/1)
	.byte	C_JUMPT		; skip if res < 1 (res)
	.byte	2		; skip to offset 45 (45-43=2)
; offset 43:
	.byte	C_DEL		; delete result
	.byte	C_CONST(CONST_1) ; load constant 1 (1)

; ====== negate result
; offset 45:
	.byte	C_GETMEM(TEMP_1) ; load memory 0 ("positive flag")
	.byte	C_JUMPT		; skip if result is positive
	.byte	1		; jump to offset 49 (49-48=1)
; offset 48
	.byte	C_NEG		; negate result
; offset 49
	.byte	C_END		; end
; offset 50
	.balign 2		; align
; offset 50
	ret

; ===== result will be 0
; offset 51:
	.byte	C_DEL		; delete x
	.byte	C_CONST(CONST_0) ; load constant 0
	.byte	C_END		; end
	.balign 2		; align

	ret

; ----------------------------------------------------------------------------
;                             Tangent (C_TAN)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; USES: TEMP_1, TEMP_2, TEMP_3, TEMP_4
; ----------------------------------------------------------------------------
; tan(x) = sin(x)/cos(x)

.global CalcTan
CalcTan:

	rcall	Calc		; calculator (x)
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_SIN		; sinus (x,sin(x))
	.byte	C_EXC		; exchange (sin(x),x)
	.byte	C_COS		; cosinus (sin(x),cos(x))
	.byte	C_DIV		; divide
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;                             CoTangent (C_COTAN)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; USES: TEMP_1, TEMP_2, TEMP_3, TEMP_4
; ----------------------------------------------------------------------------
; cotan(x) = cos(x)/sin(x)

.global CalcCoTan
CalcCoTan:

	rcall	Calc		; calculator (x)
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_COS		; cosinus (x,cos(x))
	.byte	C_EXC		; exchange (cos(x),x)
	.byte	C_SIN		; sinus (cos(x),sin(x))
	.byte	C_DIV		; divide
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;                             Arcus Sine (C_ASN)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; USES: TEMP_1, TEMP_2, TEMP_3
; ----------------------------------------------------------------------------
; result is in range -PI/2..+PI/2
;  Taylor serie xi+1 = xi * (2*i-1)^2*x^2 / ((2*i)*(2*i+1)) ... x0 = x
;  arcsin(x) = x + x^3/2/3 + 3*x^5/2/4/5 + 3*5*x^7/2/4/6/7 +
;  For x > 0.75 we use alternate method via arccos: sqrt(1 - x^2)

.global CalcAsn
CalcAsn:

	rcall	Calc		; calculator (x)
; offset 0: number is zero, result will be zero
	.byte	C_JUMPZ		; jump if number is zero (x)
	.byte	55		; jump to offset 57 (57-2=55)
; offset 2: save sign (1 if number is > 0)
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_GR0		; check if x > 0 (x,1/0)
	.byte	C_EXC		; exchange (S,x)
; offset 5: absolute value
	.byte	C_ABS		; absolute value (S,x)
; offset 6: number > 1 is invalid
	.byte	C_DUP		; duplicate (S,x,x)
	.byte	C_CONST(CONST_1) ; load constant 1 (S,x,x,1)
	.byte	C_GR		; check if x > 1 (S,x,0/1)
	.byte	C_JUMPT		; jump if x > 1 (argument error) (S,x)
	.byte	49		; jump to offset 60 (60-11=49)
; offset 11: check if use alternate method (1 if not using alternate method)
; - if x > 0.75, we use sqrt(1 - x^2)
	.byte	C_DUP		; duplicate (S,x,x)
	.byte	C_CONST(CONST_075) ; constant 0.75 (S,x,x,0.75)
	.byte	C_LTEQ		; check if x <= 0.75 (S,x,0/1)
	.byte	C_JUMPNZ	; jump if x <= 0.75 (S,x,A)
	.byte	6		; jump to offset 22 (22-16=6)
; offset 16: prepare alternative method - use sqrt(1 - x^2)
	.byte	C_EXC		; exchange (S,A,x)
	.byte	C_SQR		; square (S,A,x^2)
	.byte	C_DEC		; decrement (S,A,x^2-1)
	.byte	C_NEG		; negate (S,A,1 - x^2)
	.byte	C_SQRT		; square root (S,A,sqrt(1 - x^2))
	.byte	C_EXC		; exchange (S,sqrt(1 - x^2),A)
; offset 22: square -> TEMP_1
	.byte	C_EXC		; exchange (S,A,x)
	.byte	C_DUP		; duplicate (S,A,x,x)
	.byte	C_SQR		; square (S,A,x,x^2)
	.byte	C_SETMEMDEL(TEMP_1) ; save temp3 (S,A,x)
; offset 26: prepare factorial coefficient -> TEMP_2
	.byte	C_CONST(CONST_1) ; load constant 1 (S,A,x,1)
	.byte	C_SETMEMDEL(TEMP_2) ; save factorial coefficient (S,A,x)
; offset 28: prepare member -> TEMP_3
	.byte	C_SETMEM(TEMP_3) ; save member (S,A,x)

; ===== start of loop
; offset 29: multiply member by x^2
	.byte	C_GETMEM(TEMP_3) ; get member (S,A,res,mem)
	.byte	C_GETMEM(TEMP_1) ; get square (S,A,res,mem,x^2)
	.byte	C_MUL		; multiply (S,A,res,mem*x^2)
; offset 32: multiply member by coefficient^2
	.byte	C_GETMEM(TEMP_2) ; load factorial coefficient (S,A,res,mem*x^2,fac)
	.byte	C_MUL		; multiply (S,A,res,mem*x^2*fac)
	.byte	C_GETMEM(TEMP_2) ; load factorial coefficient (S,A,res,mem2,fac)
	.byte	C_MUL		; multiply (S,A,res,mem2*fac)
; offset 36: increment factorial coefficient
	.byte	C_GETMEM(TEMP_2) ; load factorial coefficient (S,A,res,mem3,fac)
	.byte	C_INC		; increment coefficient
	.byte	C_SETMEM(TEMP_2) ; save coefficient
; offset 39: divide nember by coefficient
	.byte	C_DIV		; divide (S,A,res,mem3/fac)
; offset 40: increment factorial coefficient
	.byte	C_GETMEM(TEMP_2) ; load factorial coefficient (S,A,res,mem4,fac)
	.byte	C_INC		; increment coefficient
	.byte	C_SETMEM(TEMP_2) ; save coefficient
; offset 43: divide nember by coefficient
	.byte	C_DIV		; divide (S,A,res,mem4/fac)
; offset 44: save member
	.byte	C_SETMEM(TEMP_3) ; save member
; offset 45: add member to accumulator and loop if meaningful
	.byte	C_ADDLOOP	; add and loop
	.byte	-18		; jump to offset 29 (29-47=-18)

; offset 47: correction for alternate method (PI/2 - y)
	.byte	C_EXC		; exchange (S,y,A)
	.byte	C_JUMPT		; jump if not alternative flag
	.byte	3		; jump to offset 53 (53-50=3)
; offset 50:
	.byte	C_NEG		; negate
	.byte	C_CONST(CONST_PI05) ; load constant PI/2
	.byte	C_ADD		; add constant PI/2
; offset 53: negate result
	.byte	C_EXC		; exchange (y,S)
	.byte	C_JUMPT		; jump if not negative
	.byte	1		; jump to offset 57 (57-56=1)
; offset 56
	.byte	C_NEG		; negate result
; offset 57
	.byte	C_END		; end
; offset 58
	.balign 2		; align
; offset 58
	ret

; offset 60: argument error (> 1)
	.byte	C_DEL		; delete x (S)
	.byte	C_CONST(CONST_PI05) ; load constant PI/2 (S,PI/2)
	.byte	C_ERROR		; set error flag
	.byte	C_JMP		; jump back
	.byte	-12		; jump to offset 53 (53-65=-12)
; offset 65
	.balign 2		; align

; ----------------------------------------------------------------------------
;                             Arcus Cosine (C_ACS)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; USES: TEMP_1, TEMP_2, TEMP_3
; ----------------------------------------------------------------------------
; acs(x) = pi/2 - asn(x)

.global CalcAcs
CalcAcs:

	rcall	Calc		; calculator
	.byte	C_ASN		; arcus sinus (asn(x))
	.byte	C_CONST(CONST_PI05) ; stack pi/2 (asn(x),pi/2)
	.byte	C_SUB		; subtract (asn(x)-pi/2)
	.byte	C_NEG		; negate (pi/2-asn(x))
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;                             Arcus Tangent (C_ATN)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; USES: TEMP_1, TEMP_2, TEMP_3
; ----------------------------------------------------------------------------
; atan(x) = asin(x / sqrt(1 + x^2))

.global CalcAtn
CalcAtn:
	rcall	Calc		; calculator (x)
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_SQR		; square (x,x^2)
	.byte	C_INC		; increment (x,x^2+1)
	.byte	C_SQRT		; square root (x,sqrt(x^2+1))
	.byte	C_DIV		; divide (x/sqrt(x^2+1))
	.byte	C_ASN		; arcus sine
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;                             Ln (C_LN)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; USES: TEMP_1, TEMP_2, TEMP_3, TEMP_4
; ----------------------------------------------------------------------------
;  Taylor serie D = (x-1)/(x+1),  xi+1 = xi*D^2*(i*2-1)/(i*2+1) ... x0 = 2*D
;  ln(x) = 2*D*(1 + D^2/3 + D^4/5 + D^6/7 ...)

; offset -16: number is 1, result will be 0
	.byte	C_DEL		; delete number
	.byte	C_CONST(CONST_0) ; load constant 0
	.byte	C_END		; end
; offset -13
	.balign 2		; align
; offset -12
	ret

; offset -10: error, ln(0)
	.byte	C_DEL		; delete number
	.byte	C_OVER		; load overflow value
	.byte	C_NEG		; negate (to indicate -9.99+99)
	.byte	C_ERROR		; error
	.byte	C_END		; end
; offset -5
	.balign 2		; align
; offset -4
	ret
; offset -2

.global CalcLn
CalcLn:
	rcall	Calc		; calculator (x)
; offset 0: number is = zero, invalid
	.byte	C_JUMPZ		; jump if number is = 0 (x)
	.byte	-12		; jump to offset -10 (-10-2 = -12)
; offset 2: number is = 1, result will be 0
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_CONST(CONST_1) ; load constant 1 (x,x,1)
	.byte	C_EQU		; check if number is x = 1 (x,0/1)
	.byte	C_JUMPT		; jump if x = 1
	.byte	-23		; jump to offset -16 (-16-7 = -23)
; offset 7: check if number is > 0
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_GR0		; check if number is > 0 (x,1/0)
	.byte	C_JUMPT		; jump if number is > 0, OK (x)
	.byte	2		; jump to offset 13 (13-11=2)
; offset 11: error, argument is < 0
	.byte	C_ABS		; absolute value
	.byte	C_ERROR		; error
; offset 13: check if number is < 1 (result will be negative)
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_CONST(CONST_1) ; load constant 1 (x,x,1)
	.byte	C_GREQ		; check if number is >= 1 (x,0/1)
	.byte	C_SETMEM(TEMP_1) ; save 1/0 into temp 1 (0=result will be negative)
	.byte	C_JUMPT		; skip if x >= 1 (x)
	.byte	1		; jump to offset 20 (20-19=1)
; offset 19: reciprocal value (result will be negative)
	.byte	C_REC		; reciprocal value (1/x)
; offset 20:
	.byte	C_END		; end
	.balign 2		; align

; ----- load exponent and set current exponent to "1" (to get range 1.000...1.999)
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop		; get top number -> Z
	ldd	r25,Z+0
	ldd	r24,Z+1		; exponent -> R25:R24
	adiw	r24,1
	sbiw	r24,1		; check overflow
	brcs	CalcLn9		; overflow, exit
	ldi	r22,lo8(EXP_BIAS)
	ldi	r23,hi8(EXP_BIAS)
	std	Z+0,r23
	std	Z+1,r22		; set exponent to "1"

; ----- add exponent to the stack
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	rcall	CalcStackW	; add exponent (x,e2B)

; ----- add bias to the stack

	ldi	r24,lo8(EXP_BIAS)
	ldi	r25,hi8(EXP_BIAS)
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	rcall	CalcStackW	; add bias (x,e2B,BIAS)

; ----- subtract bias from exponent

	rcall	Calc
; offset 0:
	.byte	C_SUB		; subtract BIAS (x,e2B-BIAS)
; offset 1: convert exponent to decimal value - multiply by ln(2)
	.byte	C_CONST(CONST_LN2) ; load constant ln(2) (x,e2,ln2)
	.byte	C_MUL		; multiply (x,e2*ln2)
	.byte	C_EXC		; exchange (e,x)
; offset 4: prepare number D = (x-1)/(1+x) -> TEMP_2 (member) and result accumulator
	.byte	C_DUP		; duplicate (e,x,x)
	.byte	C_DEC		; decrement (e,x,x-1)
	.byte	C_EXC		; exchange (e,x-1,x)
	.byte	C_INC		; increment (e,x-1,x+1)
	.byte	C_DIV		; divide (e,(x-1)/(x+1)=D)
	.byte	C_SETMEM(TEMP_2) ; save D into temp2 (e,D)
; offset 10: square D^2 -> TEMP_3
	.byte	C_SQR		; square (e,D^2)
	.byte	C_SETMEMDEL(TEMP_3) ; save D^2 (e)
	.byte	C_GETMEM(TEMP_2) ; get D to accumulator (e,D)
; offset 13: prepare factorial ocefficient 1 -> TEMP_4
	.byte	C_CONST(CONST_1) ; load constant 1 (e,D,1)
	.byte	C_SETMEMDEL(TEMP_4) ; save factorial coefficient (e,D)

; ===== start of loop
; offset 15: multiply member by D^2
	.byte	C_GETMEM(TEMP_2) ; load member (e,res,mem)
	.byte	C_GETMEM(TEMP_3) ; load D^2 (e,res,mem,D^2)
	.byte	C_MUL		; multiply member by D^2 (e,res,mem*D^2)
	.byte	C_SETMEM(TEMP_2) ; save new member (e,res,mem*D^2)
; offset 19: increase factorial coefficient by 2
	.byte	C_GETMEM(TEMP_4) ; load factorial coefficient (e,res,mem*D^2,fac)
	.byte	C_CONST(CONST_2) ; constant 2 (e,res,mem*D^2,fac,2)
	.byte	C_ADD		; add (e,res,mem*D^2,fac+2)
	.byte	C_SETMEM(TEMP_4) ; save new factorial coefficient (e,res,mem*D^2,fac+2)
; offset 23: divide member by factorial coefficieint
	.byte	C_DIV		; divide (e,res,mem*D^2/(fac+2)
; offset 24: add member to accumulator and loop if meaningful
	.byte	C_ADDLOOP	; add and loop (e,res2)
	.byte	-11		; jump to offset 15 (15-26=-11)

; offset 26: multiply result by 2
	.byte	C_MUL2		; multiply * 2 (e,2*res2)
; offset 27: add exponent
	.byte	C_ADD		; add (e+res3)
; offset 28: negate result
	.byte	C_GETMEM(TEMP_1) ; load negative flag
	.byte	C_JUMPT		; jump if number was >= 1
	.byte	1		; jump to offset 32 (32-31=1)
; offset 31:
	.byte	C_NEG		; negate result
; offset 32:
	.byte	C_END		; end
	.balign 2		; align
CalcLn9:
	ret

; ----------------------------------------------------------------------------
;                             Exp (C_EXP)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; USES: TEMP_1, TEMP_2, TEMP_3
; ----------------------------------------------------------------------------
;  Taylor serie xi+1 = xi * x / (i+1) ... x0 = 1
;  exp(x) = 1 + x/1! + x^2/2! + x^3/3! + x^4/4! + x^5/5! + ...

; offset -6: number is 0, result will be 1
	.byte	C_INC		; set constant 1
	.byte	C_END		; end
; offset -4
	.balign 2		; align
; offset -4
	ret
; offset -2

.global CalcExp
CalcExp:
	rcall	Calc		; calculator (x)
; offset 0: zero -> result is 1
	.byte	C_JUMPZ		; jump if zero, result will be 1
	.byte	-8		; jump to offset -6 (-6-2=-8)
; offset 2: check overflow
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_CONST(CONST_EXPMAX) ; constant exponent max (x,x,max)
	.byte	C_LT		; check < (x,0/1)
	.byte	C_JUMPT		; number is OK (x < expmax)
	.byte	7		; jump to offset 14 (14-7=7)
; offset 7: overflow
	.byte	C_DEL		; delete number ()
	.byte	C_OVER		; set overflow value
	.byte	C_ERROR		; error
	.byte	C_END		; end
; offset 11
	.balign 2		; align
; offset 12
	ret

; offset 14: check underflow
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_CONST(CONST_EXPMIN) ; constant exponent min (x,x,min)
	.byte	C_GR		; check > (x,0/1)
	.byte	C_JUMPT		; number is OK
	.byte	5		; jump to offset 24 (24-19=5)
; offset 19: underflow
	.byte	C_DEL		; delete number ()
	.byte	C_CONST(CONST_0) ; constant 0
	.byte	C_END		; end
; offset 22
	.balign 2		; align
; offset 22
	ret

; offset 24: extract integer part of exponent
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_CONST(CONST_RLN2) ; constant 1/ln(2) (x,x,1/ln(2))
	.byte	C_MUL		; multiply (x,x/ln(2))
	.byte	C_TRUNCPREC	; truncate (x,int(x/ln(2)))
	.byte	C_SETMEM(TEMP_2) ; save exponent -> temp2
	.byte	C_CONST(CONST_LN2) ; constant ln(2) (x,int(x/ln(2)), ln(2))
	.byte	C_MUL		; multiply (x,int(x/ln(2))*ln(2) = e)
	.byte	C_SUB		; subtract (x-e)
; offset 32: save multiplier -> TEMP_1
	.byte	C_SETMEMDEL(TEMP_1) ; save multiplier x -> temp1 ()
	.byte	C_GETMEM(TEMP_2) ; load exponent (e)
; offset 34: prepare factorial coefficient -> TEMP_2
	.byte	C_CONST(CONST_0) ; constant 1 (e,0)
	.byte	C_SETMEMDEL(TEMP_2) ; save factorial coefficient -> temp2 (e,0)
; offset 36: save member -> TEMP_3
	.byte	C_CONST(CONST_1) ; constant 1 (e,1)
	.byte	C_SETMEM(TEMP_3) ; save member '1' -> temp3 (e,1)

; ===== start of loop
; offset 38: multiply member by x
	.byte	C_GETMEM(TEMP_3) ; get member temp3 (e,res,mem)
	.byte	C_GETMEM(TEMP_1) ; get multiplier x temp1 (e,res,mem,x)
	.byte	C_MUL		; multiply (e,res,mem*x)
; offset 41: increase factrorial coefficient
	.byte	C_GETMEM(TEMP_2) ; get factorial temp2 (e,res,mem*x,fac)
	.byte	C_INC		; increment (e,res,mem*x,fac+1)
	.byte	C_SETMEM(TEMP_2) ; save new factorial temp2 (e,res,mem*x,fac+1)
; offset 44: divide member by factorial coefficient
	.byte	C_DIV		; divide (e,res,mem*x/(fac+1))
	.byte	C_SETMEM(TEMP_3) ; save member temp3 (e,res,mem2)
; offset 46: add member to accumulator and loop if meaningful
	.byte	C_ADDLOOP	; add and loop (e,res2)
	.byte	-10		; jump to offset 38 (38-48=-10)

; offset 48:
	.byte	C_EXC		; exchange (res2,e)
	.byte	C_END		; end
	.balign 2		; align

; ----- add bias to exponent
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R27..R24
; CALCULATOR STACK: +1

	ldi	r24,lo8(EXP_BIAS)
	ldi	r25,hi8(EXP_BIAS)
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	rcall	CalcStackW
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcAdd

; ----- get exponent
; OUTPUT: R25:R24 = unsigned integer
;	  R_M3 = negative flag (0 or B7)
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
	rcall	CalcUnstackW	; get exponent

; ----- multiply result by integer part
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; new number

; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M8
	rcall	CalcZ1		; set number to "1"
	std	Z+0,r25		; set exponent
	std	Z+1,r24

; DESTROYS: all
; CALCULATOR STACK: -1
	rjmp	CalcMul		; multiply

; ----------------------------------------------------------------------------
;                             Log10 (C_LOG10)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; USES: TEMP_1, TEMP_2, TEMP_3, TEMP_4
; ----------------------------------------------------------------------------

.global CalcLog10
CalcLog10:
	rcall	Calc
	.byte	C_LN		; logarithm
	.byte	C_CONST(CONST_RLN10) ; constant 1/ln(10)
	.byte	C_MUL		; multiply
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;                             Exp10 (C_EXP10)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; USES: TEMP_1, TEMP_2, TEMP_3, TEMP_4
; ----------------------------------------------------------------------------

.global CalcExp10
CalcExp10:
	rcall	Calc
	.byte	C_CONST(CONST_LN10) ; constant ln(10)
	.byte	C_MUL		; multiply
	.byte	C_EXP		; exponent
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;                             Log2 (C_LOG2)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; USES: TEMP_1, TEMP_2, TEMP_3, TEMP_4
; ----------------------------------------------------------------------------

.global CalcLog2
CalcLog2:
	rcall	Calc
	.byte	C_LN		; logarithm
	.byte	C_CONST(CONST_RLN2) ; constant 1/ln(2)
	.byte	C_MUL		; multiply
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;                             Exp2 (C_EXP2)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; USES: TEMP_1, TEMP_2, TEMP_3, TEMP_4
; ----------------------------------------------------------------------------

.global CalcExp2
CalcExp2:
	rcall	Calc
	.byte	C_CONST(CONST_LN2) ; constant ln(2)
	.byte	C_MUL		; multiply
	.byte	C_EXP		; exponent
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;                             ToRad (C_TORAD)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R4
; ----------------------------------------------------------------------------
;#define UNIT_DEG	0	// degrees
;#define UNIT_RAD	1	// radians
;#define UNIT_GRAD	2	// grads

.global CalcToRad
CalcToRad:
	ldd	r24,Y+DATA_UNIT	; get current angle unit
	cpi	r24,UNIT_RAD	; radians?
	breq	CalcToRad9	; angle is already in radians
	ldi	r24,CONST_PI180	; conversion from degrees
	brcs	CalcToRad4	; unit is degree
	ldi	r24,CONST_PI200	; conversion from grads
CalcToRad4:
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst	; load constant to the stack
; DESTROYS: all
; CALCULATOR STACK: -1
	rcall	CalcMul		; multiply angle by the constant
CalcToRad9:
	ret

; ----------------------------------------------------------------------------
;                             FromRad (C_FROMRAD)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R4
; ----------------------------------------------------------------------------

.global CalcFromRad
CalcFromRad:
	ldd	r24,Y+DATA_UNIT	; get current angle unit
	cpi	r24,UNIT_RAD	; radians?
	breq	CalcToRad9	; angle is already in radians
	ldi	r24,CONST_180PI	; conversion to degrees
	brcs	CalcToRad4	; unit is degree
	ldi	r24,CONST_200PI	; conversion to grads
	rjmp	CalcToRad4	; conversion

; ----------------------------------------------------------------------------
;                       Stack tabled constant (C_CONSTAB)
; ----------------------------------------------------------------------------
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
; ----------------------------------------------------------------------------

.global CalcConst
CalcConst:

; ----- create new number on top of stack
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; create new number -> Z
	movw	r26,r30		; X <- new number

; ----- prepare constant address -> Z

	ldi	r25,NUM_BYTES	; length of number
	mul	r25,r24		; recalculate number index to offset
	movw	r30,r0		; R31:R30 <- number offset
	clr	r1		; restore R1 (R_ZERO)
	subi	r30,lo8(-(ConstTab)) ; number address -> R31:R30
	sbci	r31,hi8(-(ConstTab))

; ----- load constant

CalcConst2:
	lpm	r24,Z+
	st	X+,r24
	dec	r25
	brne	CalcConst2
	ret

; ----------------------------------------------------------------------------
;                       Stack constant by address
; ----------------------------------------------------------------------------
; INPUT: R31:R30 = constant in ROM
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
; ----------------------------------------------------------------------------

.global CalcConstROM
CalcConstROM:

; ----- create new number on top of stack
; INPUT and OUTPUT: R31:R30 (Z), R27:R26 (X) = registers to exchange
; DESTROYS: -
	rcall	ExcXZ		; X <- constant in ROM
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; create new number -> Z
; INPUT and OUTPUT: R31:R30 (Z), R27:R26 (X) = registers to exchange
; DESTROYS: -
	rcall	ExcXZ		; X <- new number, Z <- constant in ROM
	ldi	r25,NUM_BYTES
	rjmp	CalcConst2	; copy number

; ----------------------------------------------------------------------------
;                       Load constant (C_CONSTLOAD)
; ----------------------------------------------------------------------------

.global CalcConstLoad
CalcConstLoad:

; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; create new number -> Z

	ldi	r25,NUM_BYTES	; length of the number

; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
;	 R24 = next literal
; DESTROYS: -
2:	rcall	CalcLit		; load literal -> R24
	st	Z+,r24		; save number
	dec	r25		; loop counter
	brne	2b		; next byte
	ret

; ----------------------------------------------------------------------------
;                          max number (C_MAX)
; ----------------------------------------------------------------------------

.global CalcMax
CalcMax:
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; new number
	rjmp	CalcZMax	; set max. number

; ----------------------------------------------------------------------------
;                          overflow number (C_OVER)
; ----------------------------------------------------------------------------

.global CalcOver
CalcOver:
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; new number
	rjmp	CalcZOver	; set overflow number

; ----------------------------------------------------------------------------
;                        HIR instruction (C_HIR)
; ----------------------------------------------------------------------------

.global CalcHir
CalcHir:

; ----- load register index
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
;	 R24 = next literal
; DESTROYS: -
	rcall	CalcLit		; load literal -> R24

; ----- prepare address of the number -> R27:R26

	mov	r25,r24		; byte
	andi	r25,0x0f	; low nibble
	ldi	r26,NUM_BYTES	; bytes per number
	mul	r25,r26		; offset of number
	movw	r26,r0		; offset of number
	subi	r26,lo8(-(HirReg)) ; address of variable
	sbci	r27,hi8(-(HirReg))
	clr	r1		; clear R_ZERO

; ----- indirect

	andi	r24,0xf0	; command
	brpl	2f

	push	r24		; push command
	movw	r30,r26		; register address
	call	CalcGetMemZ	; load register R31:R30 into stack
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; get number

	cpi	r24,USER_NUM	; check memory index
	brcs	1f		; register is OK
	jmp	Fatal		; error

1:	subi	r24,-USER_FIRST	; index of memory register
; INPUT: R24 = index of variable 0..MEM_NUM-1
; OUTPUT: R31:R30 = address of variable
;	  R1 = 0
; DESTROYS: R0
	call	CalcAddrMem	; get register address
	movw	r26,r30		; register address

	pop	r24		; pop command

	andi	r24,0x70	; clear indirect flag

; ----- STO

2:	cpi	r24,HIR_STO
	brne	3f

; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	call	CalcTop		; get top number
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	jmp	CalcCopyNum	; copy number from Z to X

; ----- RCL

3:	cpi	r24,HIR_RCL
	brne	4f

; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	call	CalcNew		; create new number -> Z
; INPUT and OUTPUT: R31:R30 (Z), R27:R26 (X) = registers to exchange
; DESTROYS: -
	call	ExcXZ		; exchange pointers X and Z
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	jmp	CalcCopyNum	; copy number from Z to X

; ----- STO DEL

4:	;cpi	r24,HIR_STODEL
	;brne	5f

; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	call	CalcTop		; get top number
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	call	CalcCopyNum	; copy number from Z to X
	jmp	CalcDel		; delete number

; ----------------------------------------------------------------------------
;                  call user function A' (X -> X)  (C_USER)
; ----------------------------------------------------------------------------

.global CalcUser
CalcUser:

; ----- store input parameter into X

	call	EditStop	; stop edit mode
	call	_CalcSetMemDelX ; set register X from the stack
	SET_XVALID		; set X valid

; ----- save current level (do not check if not running)

	ldd	r24,Y+DATA_PROGLEVEL ; current level
	IFN_RUNNING		; if not running
	ldi	r24,0xff	; do not check if not running
	push	r24

; ----- start user function

	std	Y+DATA_PROGNEXT,R_ZERO ; next program index = main program
	ldi	r24,KEY_A2	; function A'
	clr	r23		; no INV
	call	ExecSbrLab	; call user function

; ----- if not running, stop

2:	IFN_RUNNING		; if not running
	rjmp	8f		; stop

; ----- execute function

	call	DispTrace	; display trace
	call	LoadPrg		; load byte of program
	call	Exec		; execute one key
	call	BreakKey	; check break program

; ----- check current level (do not check if was not running)

	pop	r24
	push	r24
	ldd	r25,Y+DATA_PROGLEVEL ; current level
	cp	r24,r25		; compare level
	brne	2b		; until return to original level

; ----- stop

8:	pop	r24

; ----- save new X into stack

	call	EditStop	; stop edit mode
	ldi	r24,REG_X	; register X
	jmp	CalcGetMem	; load reg X into stack

; ----------------------------------------------------------------------------
;                  Load unsigned byte (C_BYTE)
; ----------------------------------------------------------------------------

.global CalcByte
CalcByte:

; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
;	 R24 = next literal
; DESTROYS: -
	rcall	CalcLit		; load literal -> R24

; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
	rjmp	CalcStackB

; ----------------------------------------------------------------------------
;                      Calculator macro jump table
; ----------------------------------------------------------------------------

.global CalcJmpTab
CalcJmpTab:

; Relative jumps: signed offset in next byte is relative to following byte

; ... control operations
	.word	CalcNop		; #define C_NOP		// no function (required by byte align)
	.word	CalcEnd		; #define C_END		// end macro
	.word	CalcDel		; #define C_DEL		// delete top number from calculator stack
	.word	CalcDup		; #define C_DUP		// duplicate number on calculator stack
	.word	CalcDup2	; #define C_DUP2	// duplicate pre2-last number on calculator stack
	.word	CalcDup3	; #define C_DUP3	// duplicate pre3-last number on calculator stack
	.word	CalcDup4	; #define C_DUP4	// duplicate pre4-last number on calculator stack
	.word	CalcDup5	; #define C_DUP5	// duplicate pre5-last number on calculator stack
	.word	CalcDup6	; #define C_DUP6	// duplicate pre6-last number on calculator stack
	.word	CalcExc		; #define C_EXC		// exchange 2 numbers on top of calculator stack
	.word	CalcExc2	; #define C_EXC2	// exchange 2 numbers on pre-top of calculator stack
	.word	CalcExc23	; #define C_EXC23	// exchange 2 numbers on pre-pre-top of calculator stack
	.word	CalcExc3	; #define C_EXC3	// exchange 2 numbers on pre-pre-top of calculator stack
	.word	CalcExc4	; #define C_EXC4	// exchange 2 numbers on pre-pre-pre-top of calculator stack
	.word	CalcExc5	; #define C_EXC5	// exchange 2 numbers on pre-pre-pre-pre-top of calculator stack
	.word	CalcJump	; #define C_JMP		// relative jump
	.word	CalcJumpT	; #define C_JUMPT	// relative jump if top number is true, <> 0, delete it
	.word	CalcJumpF	; #define C_JUMPF	// relative jump if top number is false, = 0, delete it
	.word	CalcJumpNZ	; #define C_JUMPNZ	// relative jump if top number is non zero, do not delete it
	.word	CalcJumpZ	; #define C_JUMPZ	// relative jump if top number is zero, do not delete it
	.word	CalcJumpErr	; #define C_JUMPERR	// jump if error
	.word	CalcJumpBreak	; #define C_JUMPBREAK	// jump if not running
	.word	CalcError	; #define C_ERROR	// set error flag
	.word	CalcAddLoop	; #define C_ADDLOOP	// add serie member to accumulator and loop if meaningful
	.word	CalcPreCor	; #define C_PRECOR	// round pre-correction (add little correction to mantissa of top number)
	.word	CpxGetTop	; #define C_CPXGETTOP	// Get top complex number into calculator stack (pre-top=real, top=imaginary)
	.word	CpxGetPreTop	; #define C_CPXGETPRETOP // Get pre-top complex number into calculator stack (pre-top=real, top=imaginary)
	.word	CpxSetTop	; #define C_CPXSETTOP	// Set top complex number from calculator stack (pre-top=real, top=imaginary)
	.word	CpxSetPreTop	; #define C_CPXSETPRETOP // Set pre-top complex number from calculator stack (pre-top=real, top=imaginary)
	.word	CpxDel		; #define C_CPXDEL	// delete top complex number
	.word	CalcFraNorm	; #define C_FRANORM	// normalize fraction number in calculator stack (pre-top and top)
	.word	CalcByte	; #define C_BYTE	// load unsigned byte, will follow
	.word	CalcConstLoad	; #define C_CONSTLOAD	// load constant number from ROM, 10 bytes follow
	.word	CalcHir		; #define C_HIR		// HIR instruction, follows parameter

; ... arithmetics and bitwise operations (2 operands)
	.word	CalcMul		; #define C_MUL		// * multiply
	.word	CalcDiv		; #define C_DIV		// / division
	.word	CalcMul2	; #define C_MUL2	// multiply*2
	.word	CalcDiv2	; #define C_DIV2	// division/2
	.word	CalcMod		; #define C_MOD		// modulus with trunc rounding
	.word	CalcMod2	; #define C_MOD2	// modulus with floor rounding
	.word	CalcSub		; #define C_SUB		// - subtract
	.word	CalcAdd		; #define C_ADD		// + addition
	.word	CalcPow		; #define C_POW		// ^ power (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
	.word	CalcBitAnd	; #define C_BITAND	// bitwise AND
	.word	CalcBitOr	; #define C_BITOR	// bitwise OR
	.word	CalcBitXor	; #define C_BITXOR	// bitwise XOR
	.word	CalcLeft	; #define C_LEFT	// < shift left
	.word	CalcRight	; #define C_RIGHT	// > shift right
	.word	CalcGcd		; #define C_GCD		// find greatest common divisor (GCD) of two integer numbers

; ... comparisons (do not change order of comparison codes - hardcoded in function CalcCmp)
	.word	CalcCmp		; #define C_LTEQ	// <=
	.word	CalcCmp		; #define C_GREQ	// >=
	.word	CalcCmp		; #define C_NEQU	// <>
	.word	CalcLt0		; #define C_LT0		// < 0 (less 0 but not equ 0)
	.word	CalcCmp		; #define C_GR		// >
	.word	CalcCmp		; #define C_LT		// <
	.word	CalcCmp		; #define C_EQU		// =
	.word	CalcGr0		; #define C_GR0		// > 0 (greater 0 but not equ 0)
	.word	CalcLtEq0	; #define C_LTEQ0	// <= 0 (less or equ 0)
	.word	CalcGrEq0	; #define C_GREQ0	// >= 0 (greater or equ 0)

; ... logic operations
	.word	CalcNot		; #define C_NOT		// NOT
	.word	CalcOr		; #define C_OR		// OR
	.word	CalcAnd		; #define C_AND		// AND

; ... functions 1 (misc)
	.word	CalcRec		; #define C_REC		// 1/x reciprocal value
	.word	CalcInc		; #define C_INC		// increment +1
	.word	CalcDec		; #define C_DEC		// decrement -1
	.word	CalcNeg		; #define C_NEG		// unary- (NEG)
	.word	CalcSgn		; #define C_SGN		// SGN
	.word	CalcAbs		; #define C_ABS		// ABS
	.word	CalcTruncPrec	; #define C_TRUNCPREC	// precise truncate (round towards zero)
	.word	CalcTrunc	; #define C_TRUNC	// truncate (round towards zero)
	.word	CalcFloor	; #define C_FLOOR	// round down (uses TEMP_1)
	.word	CalcCeil	; #define C_CEIL	// round up
	.word	CalcRound	; #define C_ROUND	// round nearest
	.word	CalcRoundFrac	; #define C_ROUNDFRAC	// round nearest fraction -0.5..+0.5
	.word	CalcMax		; #define C_MAX		// load max number
	.word	CalcOver	; #define C_OVER	// load overflow number
	.word	CalcRand	; #define C_RAND	// random number (0 inc. .. 1 exc.)
	.word	CalcUser	; #define C_USER	// call user function A' (X -> X, delete stack)
	.word	CalcSND		; #define C_SND		// standard normal distribution Z(x) (C_SND)
	.word	CalcCGD		; #define C_CGD		// complementary Gaussian distribution Q(x) (C_CGD)
	.word	CalcCND		; #define C_CND		// cumulative normal distribution P(x) (C_CND)

; ... functions 2 (angle)
	.word	CalcArg		; #define C_ARG		// normalize angle argument (uses TEMP_1, TEMP_2)
	.word	CalcSin		; #define C_SIN		// SIN (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
	.word	CalcCos		; #define C_COS		// COS (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
	.word	CalcTan		; #define C_TAN		// TAN (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
	.word	CalcCoTan	; #define C_COTAN	// COTAN (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
	.word	CalcAsn		; #define C_ASN		// ASN (uses TEMP_1, TEMP_2, TEMP_3)
	.word	CalcAcs		; #define C_ACS		// ACS (uses TEMP_1, TEMP_2, TEMP_3)
	.word	CalcAtn		; #define C_ATN		// ATN (uses TEMP_1, TEMP_2, TEMP_3)
	.word	CalcToRad	; #define C_TORAD	// TORAD - angle to radians
	.word	CalcFromRad	; #define C_FROMRAD	// FROMRAD - angle from radians
	.word	CalcPR		; #define C_PR		// Convert polar to cartesian (r,a in radians) -> (x,y)
	.word	CalcRP		; #define C_RP		// Convert cartesian to polar (x,y) -> (r,a in radians)

; ... functions 3 (logarithm)
	.word	CalcLn		; #define C_LN		// LN (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
	.word	CalcExp		; #define C_EXP		// EXP (uses TEMP_1, TEMP_2, TEMP_3)
	.word	CalcLog10	; #define C_LOG10	// LOG10 (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
	.word	CalcExp10	; #define C_EXP10	// EXP10 (uses TEMP_1, TEMP_2, TEMP_3)
	.word	CalcLog2	; #define C_LOG2	// LOG2 (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
	.word	CalcExp2	; #define C_EXP2	// EXP2 (uses TEMP_1, TEMP_2, TEMP_3)
	.word	CalcSqrt	; #define C_SQRT	// SQRT (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
	.word	CalcSqr		; #define C_SQR		// x^2 square

; ... groups (compound literals)
;	bit 7: flag of compound literal
;	bit 5..6: group 0..3
;	bit 0..4: parameter 0..31
	.word	CalcConst	; #define C_CONST_GRP	// stack tabled constant (parameter is index in ConstTab)
	.word	CalcSetMem	; #define C_SETMEM_GRP	// set memory from stack (parameter is index of the number)
	.word	CalcGetMem	; #define C_GETMEM_GRP	// get number from memory into stack (parameter is index of the number)
	.word	CalcSetMemDel	; #define C_SETMEMDEL_GRP // set memory from stack and delete (parameter is index of the number)

.global CalcJmpTabEnd ; end of table
CalcJmpTabEnd:

; ----------------------------------------------------------------------------
;                     Calculator macro interpreter
; ----------------------------------------------------------------------------
; INPUT: stack = RCALL return address 2 bytes, calculator literals follow RCALL.
; ----------------------------------------------------------------------------
; Return address will be word-aligned (use ".balign 2" after program block).

; RCALL procedure: [SP] <- addr LOW, SP-1, [SP] <- addr HIGH, SP-1
; To load byte after rcall: pop ZH, pop ZL, add ZL, adc ZH, lpm r24,Z+
; To jump back: lsr ZH, ror ZL, ijmp (or push ZL, push ZH, ret)

; ----- get pointer to literals from the stack and push registers -> R_LITH:R_LITL

.global Calc
Calc:
	pop	r25		; (HIGH)
	pop	r24		; (LOW) get return address from the stack

	push	R_LITL		; push current literal pointer
	push	R_LITH

	movw	R_LITL,r24	; R_LITL <- return address
	add	R_LITL,R_LITL
	adc	R_LITH,R_LITH	; convert to byte offset

; ----- load next literal -> R24
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
;	 R24 = next literal

.global CalcReEnter
CalcReEnter:

; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
;	 R24 = next literal
; DESTROYS: -
	rcall	CalcLit		; get literal -> R24

; ----- compound literal (bit 7 is set)
; bit 7: flag of compound literal
; bit 5..6: subgroup 0..3
; bit 0..4: parameter 0..31

; Enter function by R24

.global CalcEnter
CalcEnter:
	mov	r25,r24		; save literal
	tst	r24		; compound literal?
	brpl	Calc4		; no

	andi	r25,0x1f	; isolate parameter bits
	swap	r24		; swap bits
	lsr	r24		; rotate to bit position 0
	andi	r24,B0+B1	; isolate bits of the subgroup
	subi	r24,-C_GROUP_BASE ; add group base

; ----- jump to operation R24 (destroys R0, R31, R30)

Calc4:
;.global CalcEnter
;CalcEnter:
	ldi	r30,lo8(CalcJmpTab) ; Z <- jump table
	ldi	r31,hi8(CalcJmpTab)
	add	r30,r24
	adc	r31,R_ZERO
	add	r30,r24		; Z <- offset in jump table
	adc	r31,R_ZERO
	lpm	r0,Z+		; R25 <- load jump address LOW
	lpm	r31,Z		; R31 <- load jump address HIGH
	mov	r30,r0		; Z <- jump address (byte offset)
	lsr	r31
	ror	r30		; convert address to word index
	mov	r24,r25		; R24 <- function parameter or literal
	icall			; rcall function (R_LITH:R_LITL=literal pointer, R24=parameter or literal)
	rjmp	CalcReEnter	; process next literal

; ----------------------------------------------------------------------------
;                          Reset calculator stack
; ----------------------------------------------------------------------------

.global CalcInit
CalcInit:
	ldi	r24,lo8(CalcStack)
	std	Y+DATA_STKEND,r24
	ldi	r24,hi8(CalcStack)
	std	Y+DATA_STKEND+1,r24

	std	Y+DATA_LEVEL,R_ZERO ; current level of arithmetics operations

	ldi	r24,CONST_0
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConst	; constant 0

;	ldi	r24,REG_T
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
;	rcall	CalcSetMem	; clear T register

	ldi	r24,REG_X
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
	rcall	CalcSetMem	; clear X register
	ldi	r24,REG_LAST
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: -1
	rcall	CalcSetMemDel	; clear Last register

	std	Y+DATA_LAST,R_ZERO ; no last operation

	jmp	ExecLevelInit	; initialize base level of arithmetics operations
