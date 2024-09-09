; ****************************************************************************
;
;          Calculator arithmetics and bitwise operations (2 operands)
;
; ****************************************************************************

#include "include.inc"

	.text

; ----------------------------------------------------------------------------
;               Prepare number for multiplication and division
; ----------------------------------------------------------------------------
; INPUT: R23 = previous sign flag
;	 R31:R30 (Z) = pointer to the number
;	 R_ZERO = 0
; OUTPUT: R23 = new sign flag
;	  flag Z = number is zero (and C is not set)
;	  flag C = number is overflow (and Z is not set)
; DESTROYS: R24, R25
; ----------------------------------------------------------------------------
; Get sign bit and restore hidden bit '1' of mantissa.

CalcPrepMul:

; ----- get exponent

	ldd	r25,Z+0		; fetch exponent HIGH
	ldd	r24,Z+1		; fetch exponent LOW

; ----- test for overflow (set C) and zero (set Z)

	adiw	r24,1
	sbiw	r24,1		; check for zero (0x0001->0x0000->ZY) and overflow (0x0000->0xFFFF->CY)
	breq	CalcPrepMul9	; number is zero

; ----- check sign and restore highest bit of the mantissa
; C will be not affected

	ldd	r24,Z+2		; highest byte of the mantissa
	eor	r23,r24		; flip sign flag
	ori	r24,B7		; restore hidden highest bit of the mantissa
	std	Z+2,r24		; save new highest byte
	; here is Z flag cleared

CalcPrepMul9:
	ret

; ===== here is rest of CalcMul function

; ----- 2nd number is overflow

CalcMul6:
; INPUT and OUTPUT: R31:R30 (Z), R27:R26 (X) = registers to exchange
; DESTROYS: -
	rcall	ExcXZ		; exchange pointers
; INPUT: R23 = previous sign flag
;	 R31:R30 (Z) = pointer to the number
;	 R_ZERO = 0
; OUTPUT: R23 = new sign flag
;	  flag Z = number is zero (and C is not set)
;	  flag C = number is overflow (and Z is not set)
; DESTROYS: R24, R25
	rcall	CalcPrepMul	; prepare 1st number
	breq	CalcMul7	; 1st number is 0, result will be 1

; ----- 1st number is not 0, result will be overflow

CalcMul62:
; OUTPUT: CY = error flag
; DESTROYS: -
	rcall	CalcError	; set error flag

; OUTPUT: R31:R30 (Z) = pre-last number on calculator stack
; DESTROYS: -
	rcall	CalcPreTop	; get pre-last number -> Z

; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10
	rcall	CalcZOver	; set number Z to overflow
	rjmp	CalcDel		; delete 2nd operand

; ----- result is 1 with error

CalcMul7:
; OUTPUT: CY = error flag
; DESTROYS: -
	rcall	CalcError	; set error flag

; OUTPUT: R31:R30 (Z) = pre-last number on calculator stack
; DESTROYS: -
	rcall	CalcPreTop	; get pre-last number -> Z

; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10
	push	r23
	rcall	CalcZ1		; set number Z to 1
	pop	r23

	tst	r23		; check sign
	brpl	2f		; result is positive
; DESTROYS: R31, R30, R25, R24
	rcall	CalcNeg		; result will be -1

; DESTROYS: R31, R30
; CALCULATOR STACK: -1
2:	rjmp	CalcDel		; delete 2nd operand

; ----- 2nd number is 0

CalcMul81:
; INPUT and OUTPUT: R31:R30 (Z), R27:R26 (X) = registers to exchange
; DESTROYS: -
	rcall	ExcXZ		; exchange pointers
; INPUT: R23 = previous sign flag
;	 R31:R30 (Z) = pointer to the number
;	 R_ZERO = 0
; OUTPUT: R23 = new sign flag
;	  flag Z = number is zero (and C is not set)
;	  flag C = number is overflow (and Z is not set)
; DESTROYS: R24, R25
	rcall	CalcPrepMul	; prepare 1st number
	brcs	CalcMul7	; 1st number is overflow, result will be 1

; ----- result will be 0

CalcMul82:

; OUTPUT: R31:R30 (Z) = pre-last number on calculator stack
; DESTROYS: -
	rcall	CalcPreTop	; get pre-last number -> Z

; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10
	rcall	CalcZ0		; clear number Z
	rjmp	CalcDel		; delete 2nd operand

; ----------------------------------------------------------------------------
;              Multiplicate two numbers on top of stack (C_MUL)
; ----------------------------------------------------------------------------
; DESTROYS: all
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------

.global CalcMul
CalcMul:

; ----- get last 2 numbers (1st -> X, 2nd -> Z)
; OUTPUT: R27:R26 (X) = pre-last number on calculator stack
;	  R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop2

; ----- prepare numbers for multiplication; -> 1st number Z, 2nd number X, sign bit R_MS (not masked)
; INPUT: R23 = previous sign flag
;	 R31:R30 (Z) = pointer to the number
;	 R_ZERO = 0
; OUTPUT: R23 = new sign flag
;	  flag Z = number is zero (and C is not set)
;	  flag C = number is overflow (and Z is not set)
; DESTROYS: R24, R25
	clr	r23		; prepare sign flag = 0
	rcall	CalcPrepMul	; prepare 2nd number
	brcs	CalcMul6	; 2nd number is overflow
	breq	CalcMul81	; 2nd number is zero

; INPUT and OUTPUT: R31:R30 (Z), R27:R26 (X) = registers to exchange
; DESTROYS: -
	rcall	ExcXZ		; exchange pointers
; INPUT: R23 = previous sign flag
;	 R31:R30 (Z) = pointer to the number
;	 R_ZERO = 0
; OUTPUT: R23 = new sign flag
;	  flag Z = number is zero (and C is not set)
;	  flag C = number is overflow (and Z is not set)
; DESTROYS: R24, R25
	rcall	CalcPrepMul	; prepare 1st number
	brcs	CalcMul62	; 1st number is overflow, result is overflow
	breq	CalcMul82	; 1st number is zero, result will be 0

	mov	R_MS,r23	; sign flag

; ----- fetch 2 numbers and delete 2nd number:
;			1st number Z -> R_M1..R_M10
;			2nd number X -> R_N1..R_N10
; INPUT: R31:R30 (Z) = pointer to 1st number
;	 R27:R26 (X) = pointer to 2nd number
; OUTPUT: R_M1..R_M10 = 1st number (from Z)
;	  R_N1..R:N10 = 2nd number (from X)
; DESTROYS: R31, R30, R27, R26
; CALCULATOR STACK: -1
	rcall	CalcFetch2

; ----- sum exponents -> R_MT:R_M1:R_M2

	clr	R_MT		; exponent HIGH
	add	R_M2,R_N2	; sum both exponents
	adc	R_M1,R_N1
	adc	R_MT,R_MT	; high carry

; ----- multiplication of mantissas, R_M3..R_M10 * R_N3..R_N10 -> R_M3..R_M10, R_M11
; INPUT: R_M3..R_M10 = 1st multiplier
;	 R_N3..R_N10 = 2nd multiplier
; OUTPUT: R_M3..R_M10, R_M11 = result (not rounded)
;	  R1 = 0
; DESTROYS: R_A3 (R31), R_A4 (R30), R_A7 (R27), R_A8 (R26), R0
	rcall	MulMant

; ----- prepare exponent -> R_MT:R_EXH:R_EXL

	movw	R_EXL,R_M2	; exponent
	subi	R_EXL,lo8(EXP_BIAS-1) ; subtract exponent bias
	sbci	R_EXH,hi8(EXP_BIAS-1)
	sbc	R_MT,R_ZERO

; ----- normalize number: R_MS sign, R_M3..R_M10(:R_M11) mantissa, R_MT:R_EXH:R_EXL exponent

CalcMulNorm:
	ldi	R_M1,MANT_BITS-TRIM ; max. number of shifts (trim last bits for case of small differences)
CalcMulNorm2:
	sbrc	R_M3,7		; check highest bit of mantissa
	rjmp	CalcMulNorm5	; highest bit is on the position, number is normalized
	lsl	R_M11		; get lower bit to round

; INPUT: R_M3..R_M10 mantissa
;	 C = input carry
; OUTPUT: R_M3..R_M10 mantissa shifted left
;	 C = output carry
; DESTROYS: -
	rcall	CalcMantRol	; rotate mantissa left (with carry)
	sbiw	R_EXL,1		; decrement exponent
	sbc	R_MT,R_ZERO	; carry

	dec	R_M1		; bit counter
	brne	CalcMulNorm2

; ----- underflow, reset result to 0
; OUTPUT: R_M1..R_M10 number (= 0)
; DESTROYS: -
CalcMulUnder:
	rcall	CalcClearNum	; clear result
	rjmp	CalcMulSave	; save result

; ----- round up

CalcMulNorm5:
	lsl	R_M11		; check lowest bit
	brcc	CalcMulNorm6	; no carry

; INPUT: R_M3..R_M10 = mantissa
;	 R_ZERO = 0
; OUTPUT: returns Z flag if result is 0 (overflow from 0xFF 0xFF 0xFF...)
; DESTROYS: -
	rcall	CalcMantInc	; increment mantissa
	brne	CalcMulNorm6	; result is not 0
	ldi	R_M3,0x80	; overflow, set value to 0x80 0x00 0x00 0x00 0x00 0x00
	adiw	R_EXL,1		; increment exponent R_EXH:R_EXL
	adc	R_MT,R_ZERO	; carry

; ----- check exponent

CalcMulNorm6:
	tst	R_MT		; check exponent HIGH
	brmi	CalcMulUnder	; underflow
	brne	CalcMulOver	; overflow

	cp	R_EXL,R_ZERO	; check minimal exponent
	cpc	R_EXH,R_ZERO
	breq	CalcMulUnder	; underflow

	ldi	R_M1,hi8(EXP_MAX+1)
	cpi	R_EXL,lo8(EXP_MAX+1) ; check maximal exponent
	cpc	R_EXH,R_M1
	brcc	CalcMulOver	; overflow

; ----- prepare 1st byte of mantissa -> R_M3

	andi	R_M3,0x7f	; reset hidden highest bit "1"
	andi	R_MS,0x80	; mask sign flag
	or	R_M3,R_MS	; put bits together

; ----- exponent -> R_M1:R_M2

	movw	R_M2,R_EXL

; ----- save result R_M1..R_M9
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
CalcMulSave:
	rcall	CalcTop		; get pointer to top number -> Z
; INPUT: R31:R30 (Z) = pointer to number
;	 R_M1..R_M10 number
; DESTROYS: -
	rjmp	CalcSaveNum	; save number

; ----- overflow error

CalcMulOver:
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop		; get pointer to top number -> Z
	rcall	CalcZOver	; set overflow value
; OUTPUT: CY = error flag
; DESTROYS: -
	rjmp	CalcError	; set error flag

; ----------------------------------------------------------------------------
;                          divide/2/4/8/16 (C_DIV2)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; ----------------------------------------------------------------------------

.global CalcDiv16
CalcDiv16:
	rcall	CalcDiv2

.global CalcDiv8
CalcDiv8:
	rcall	CalcDiv2

.global CalcDiv4
CalcDiv4:
	rcall	CalcDiv2

.global CalcDiv2
CalcDiv2:

; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get top number -> Z, R24
	brcs	CalcMulOver	; number is overflow
	breq	CalcDiv29	; number is zero

	sbiw	r24,1		; decrement exponent
CalcDiv26:
	std	Z+1,r24		; set new exponent
	std	Z+0,r25
CalcDiv29:
	ret

; ----------------------------------------------------------------------------
;                        multiply*2/4/8/16 (C_MUL2)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; ----------------------------------------------------------------------------

.global CalcMul16
CalcMul16:

	rcall	CalcMul2

.global CalcMul8
CalcMul8:

	rcall	CalcMul2

.global CalcMul4
CalcMul4:

	rcall	CalcMul2

.global CalcMul2
CalcMul2:

; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get top number -> Z, R24
	brcs	CalcMulOver	; number is overflow
	breq	CalcDiv29	; number is zero

	adiw	r24,1		; increment exponent
	rjmp	CalcDiv26	; set new exponent

; ----------------------------------------------------------------------------
;                           < (C_LEFT)
; ----------------------------------------------------------------------------

.global CalcLeft
CalcLeft:

; ----- load 2nd operand - number of shifts
; OUTPUT: R25:R24 = unsigned integer
;	  R_M3 = negative flag (0 or B7)
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
	rcall	CalcUnstackW
	brcs	CalcMulOver	; number is overflow
	movw	r22,r24		; save number of shifts

; ----- load current exponent
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get top number -> Z, R24
	brcs	CalcMulOver	; number is overflow
	breq	CalcDiv29	; number is zero

; ----- shift exponent

	add	r24,r22
	adc	r25,r23
	brcs	CalcMulOver	; overflow
	rjmp	CalcDiv26	; set new exponent

; ----------------------------------------------------------------------------
;                           > (C_RIGHT)
; ----------------------------------------------------------------------------

.global CalcRight
CalcRight:

; ----- load 2nd operand - number of shifts
; OUTPUT: R25:R24 = unsigned integer
;	  R_M3 = negative flag (0 or B7)
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
	rcall	CalcUnstackW
	brcs	CalcMulOver	; number is overflow
	movw	r22,r24		; save number of shifts

; ----- load current exponent
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get top number -> Z, R24
	brcs	CalcMulOver	; number is overflow
	breq	CalcDiv29	; number is zero

; ----- shift exponent

	sub	r24,r22
	sbc	r25,r23
	brcc	CalcDiv26	; set new exponent
	clr	r24
	clr	r25		; number will be 0
	rjmp	CalcDiv26	; set new exponent

; ===== here is rest of CalcDiv function

; ----- 2nd number is 0

CalcDiv6:
; INPUT and OUTPUT: R31:R30 (Z), R27:R26 (X) = registers to exchange
; DESTROYS: -
	rcall	ExcXZ		; exchange pointers
; INPUT: R23 = previous sign flag
;	 R31:R30 (Z) = pointer to the number
;	 R_ZERO = 0
; OUTPUT: R23 = new sign flag
;	  flag Z = number is zero (and C is not set)
;	  flag C = number is overflow (and Z is not set)
; DESTROYS: R24, R25
	rcall	CalcPrepMul	; prepare 1st number
	breq	CalcDiv7	; 1st number is 0, result will be 1

; ----- 1st number is not zero, result will be overflow

CalcDiv62:
	rjmp	CalcMul62

; ----- result is 1 with error

CalcDiv7:
	rjmp	CalcMul7

; ----- 2nd number is overflow

CalcDiv81:
; INPUT and OUTPUT: R31:R30 (Z), R27:R26 (X) = registers to exchange
; DESTROYS: -
	rcall	ExcXZ		; exchange pointers
; INPUT: R23 = previous sign flag
;	 R31:R30 (Z) = pointer to the number
;	 R_ZERO = 0
; OUTPUT: R23 = new sign flag
;	  flag Z = number is zero (and C is not set)
;	  flag C = number is overflow (and Z is not set)
; DESTROYS: R24, R25
	rcall	CalcPrepMul	; prepare 1st number
	brcs	CalcDiv7	; 1st number is overflow, result will be 1

; ----- result will be 0

CalcDiv82:
	rjmp	CalcMul82

; ----------------------------------------------------------------------------
;                          Division (C_DIV)
; ----------------------------------------------------------------------------
; DESTROYS: all
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------

.global CalcDiv
CalcDiv:

; ----- get last 2 numbers (1st -> X, 2nd -> Z)
; OUTPUT: R27:R26 (X) = pre-last number on calculator stack
;	  R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop2

; ----- prepare numbers for division; -> 1st number Z, 2nd number X, sign bit R_MS (not masked)
; INPUT: R23 = previous sign flag
;	 R31:R30 (Z) = pointer to the number
;	 R_ZERO = 0
; OUTPUT: R23 = new sign flag
;	  flag Z = number is zero (and C is not set)
;	  flag C = number is overflow (and Z is not set)
; DESTROYS: R24, R25
	clr	r23		; prepare sign flag = 0
	rcall	CalcPrepMul	; prepare 2nd number
	brcs	CalcDiv81	; 2nd number is overflow
	breq	CalcDiv6	; 2nd number is zero

; INPUT and OUTPUT: R31:R30 (Z), R27:R26 (X) = registers to exchange
; DESTROYS: -
	rcall	ExcXZ		; exchange pointers
; INPUT: R23 = previous sign flag
;	 R31:R30 (Z) = pointer to the number
;	 R_ZERO = 0
; OUTPUT: R23 = new sign flag
;	  flag Z = number is zero (and C is not set)
;	  flag C = number is overflow (and Z is not set)
; DESTROYS: R24, R25
	rcall	CalcPrepMul	; prepare 1st number
	brcs	CalcDiv62	; 1st number is overflow, result is overflow
	breq	CalcDiv82	; 1st number is zero, result will be 0

	mov	R_MS,r23	; sign flag

; ----- fetch 2 numbers and delete 2nd number:
;			1st number Z -> R_M1..R_M10
;			2nd number X -> R_N1..R_N10
; INPUT: R31:R30 (Z) = pointer to 1st number
;	 R27:R26 (X) = pointer to 2nd number
; OUTPUT: R_M1..R_M10 = 1st number (from Z)
;	  R_N1..R_N10 = 2nd number (from X)
; DESTROYS: R31, R30, R27, R26
; CALCULATOR STACK: -1
	rcall	CalcFetch2

; ----- division of mantissas, dividend R_M3..R_M10 / divisor R_N3..R_N10 -> quotient R_R3..R_R10

	push	R_MS		; push result sign

	; push registers
	push	r28
	push	r29

	; prepare loop counter
	ldi	r31,-(MANT_BITS+1) ; negative 'number of loops + 1'
	mov	r1,r31		; loop counter

	; clear quotient result LOW
	clr	R_R10
	clr	r0		; accumulator of 2 extra bits

	rjmp	CalcDivLoop4	; start loop (carry is undefined, but not needed now)

CalcDivLoop:
	; shift quotient left, adding result carry from right
	rol	R_R10
	rol	R_R9
	rol	R_R8
	rol	R_R7
	rol	R_R6
	rol	R_R5
	rol	R_R4
	rol	R_R3

CalcDivLoop2:
	; shift dividend left
	clc			; clear carry
; INPUT: R_M3..R_M10 mantissa
;	 C = input carry
; OUTPUT: R_M3..R_M10 mantissa shifted left
;	 C = output carry
; DESTROYS: -
	rcall	CalcMantRol	; rotate mantissa left
	brcs	CalcDivLoop6	; carry - dividend is higher than divisor, subtract only (result bit will be 1)

CalcDivLoop4:
	; try to subtract divisor from dividend

; INPUT: R_M3..R_M10 mantissa 1
;	 R_N3..R_N10 mantissa 2
; OUTPUT: R_M3..R_M10 result
;	  C = output borrow
; DESTROYS: -
	rcall	CalcMantSub
	brcc	CalcDivLoop8	; no cary, no restore (dividend is not smaller than divisor, result bit will be 1)

	; carry is set - dividend is smaler than divisor, restore dividend (result bit will be 0)
; INPUT: R_M3..R_M10 mantissa 1
;	 R_N3..R_N10 mantissa 2
; OUTPUT: R_M3..R_M10 result
;	  C = output carry
; DESTROYS: -
	rcall	CalcMantAdd
	clc			; clear carry flag
	rjmp	CalcDivLoop9	; result bit will be 0

CalcDivLoop6:
	; subtract only, result bit will be 1

; INPUT: R_M3..R_M10 mantissa 1
;	 R_N3..R_N10 mantissa 2
; OUTPUT: R_M3..R_M10 result
;	  C = output borrow
; DESTROYS: -
	rcall	CalcMantSub

CalcDivLoop8:
	; result bit is 1
	sec			; set carry flag, result bit is 1

CalcDivLoop9:
	; loop counter
	inc	r1		; loop counter (C stays untouched)
	brmi	CalcDivLoop	; do MANT_BITS loops, while loop counter is negativ

	; one extra loop, to get one extra bit (we already have one bit in carry)
	rol	r0		; save last 2 bits
	tst	r1		; check loop counter
	breq	CalcDivLoop2	; one extra loop

; ----- difference of exponents (warning R_M11 = R_N1)

	sub	R_M2,R_N2	; difference of exponents
	sbc	R_M1,R_N1
	sbc	r1,r1		; high carry

; ----- prepare extra result byte -> R_M11 (extra 2 bits)

	mov	R_M11,r0	; extra bits accumulator
	ror	R_M11
	ror	R_M11
	ror	R_M11		; sihft last 2 bits to position 6 and 7

; ----- prepare mantissa -> R_M3..R_M10

	movw	R_M10,R_R10
	movw	R_M8,R_R8
	movw	R_M6,R_R6
	movw	R_M4,R_R4

; ----- prepare exponent -> R1:R_EXH:R_EXL

	ldi	r28,-1
	movw	R_EXL,R_M2	; exponent
	subi	R_EXL,lo8(-EXP_BIAS) ; add exponent bias
	sbci	R_EXH,hi8(-EXP_BIAS)
	sbc	r1,r28
	mov	R_MT,r1		; exponent HIGH

; ----- pop registers

	pop	r29
	pop	r28
	clr	R_ZERO		; restore R1

; ----- prepare sign -> R_MS

	pop	R_MS		; pop result sign

; ----- normalize number: R_MS sign, R_M3..R_M10(:R_M11) mantissa, R_MT:R_EXH:R_EXL exponent

	rjmp	CalcMulNorm

; ----------------------------------------------------------------------------
;                      Modulus with trunc rounding (C_MOD)
; ----------------------------------------------------------------------------
; DESTROYS: stack, R31, R30
; ----------------------------------------------------------------------------
; - result has same sign as divisor

.global CalcMod
CalcMod:
	rcall	Calc
	.byte	C_DUP2		; pre-duplicate (a,b,a)
	.byte	C_DUP2		; pre-duplicate (a,b,a,b)
	.byte	C_DIV		; division (a,b,a/b)
	.byte	C_TRUNC		; trunc (a,b,trunc(a/b))
	.byte	C_MUL		; multiply (a,b*trunc(a/b))
	.byte	C_SUB		; subtract (a-b*trunc(a/b))
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;                      Modulus with floor rounding (C_MOD2)
; ----------------------------------------------------------------------------
; DESTROYS: stack, R31, R30
; ----------------------------------------------------------------------------
; - result has same sign as dividend

.global CalcMod2
CalcMod2:
	rcall	Calc
	.byte	C_DUP2		; pre-duplicate (a,b,a)
	.byte	C_DUP2		; pre-duplicate (a,b,a,b)
	.byte	C_DIV		; division (a,b,a/b)
	.byte	C_FLOOR		; floor (a,b,floor(a/b))
	.byte	C_MUL		; multiply (a,b*floor(a/b))
	.byte	C_SUB		; subtract (a-b*floor(a/b))
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;               Prepare number for addition and bit operation
; ----------------------------------------------------------------------------
; INPUT: R31:R30 (Z) = pointer to the number
; OUTPUT: R_R9:R_R10 = exponent
; DESTROYS: R_M1..R_M10
; ----------------------------------------------------------------------------
; Clear exponent and expand mantissa to 9 bytes signed.

CalcPrepAdd:

; ----- load number -> R_M1..R_M10
; INPUT: R31:R30 (Z) = pointer to number
; OUTPUT: R_M1..R_M10 number
; DESTROYS: -
	rcall	CalcLoadNum

; ----- get exponent and test for zero, clear 2nd byte - next highest byte of mantissa

	movw	R_R10,R_M2	; exponent LOW and HIGH
	clr	R_M2		; clear exponent LOW byte
	adiw	R_R10,0		; zero number?
	breq	CalcPrepAdd9	; number is zero

; ----- check sign and restore highest bit of the mantissa

	bst	R_M3,7		; load sign bit into T flag
	ori	R_M3,B7		; restore hidden highest bit of the mantissa
	brtc	CalcPrepAdd8	; number is positive, all ok

; ----- negate extended mantissa (R_M2..R_M10)
; INPUT: R_M2..R_M10 extended mantissa
;	 R_ZERO = 0
; OUTPUT: R_M2..R_M10 extended mantissa negated
;	  CY = carry set if result is not 0
; DESTROYS: -
	rcall	CalcMantNeg	; negate number R_M2..R_M10

; ----- save number

CalcPrepAdd8:
; INPUT: R31:R30 (Z) = pointer to number
;	 R_M1..R_M10 number
; DESTROYS: -
	rjmp	CalcSaveNum

; ----- number is 0 (need to clear - mantissa may be not zeroed)
; OUTPUT: R_M1..R_M10 number (= 0)
; DESTROYS: -
CalcPrepAdd9:
	rcall	CalcClearNum	; clear number R_M1..R_M10
; INPUT: R31:R30 (Z) = pointer to number
;	 R_M1..R_M10 number
; DESTROYS: -
	rjmp	CalcSaveNum

; ----------------------------------------------------------------------------
;                       Shift 1st number right
; ----------------------------------------------------------------------------
; INPUT: R_R9:R_R10 = number of shifts
;	 R_M2..R_M10 = extended mantissa (R_M2=0x00 or 0xFF)
; DESTROYS: R_R10
; ----------------------------------------------------------------------------

CalcAddShift:

; ----- check number of shifts

	adiw	R_R10,0		; check zero
	breq	CalcAddShift9	; no shift needed

; ----- check overflow

	tst	R_R9		; check number of shifts HIGH
	brne	CalcAddShift6	; overflow, clear number R_M2..R_M10
	cpi	R_R10,MANT_BITS+1 ; max. size of mantissa
	brcc	CalcAddShift6	; overflow difference, clear the number R_M2..R_M10

; ----- rotate mantissa right

CalcAddShift2:
	asr	R_M2		; bit 7 unchanged
; INPUT: R_M3..R_M10 mantissa
;	 C = input carry
; OUTPUT: R_M3..R_M10 mantissa shifted right
;	 C = output carry
; DESTROYS: -
	rcall	CalcMantRor	; rotate mantissa right (with carry)

	dec	R_R10
	brne	CalcAddShift2

; ----- round up, if last shiftet bit was set
; INPUT: R_M3..R_M10 = mantissa
; OUTPUT: returns Z flag if result is 0 (overflow from 0xFF 0xFF 0xFF 0xFF 0xFF)

	brcc	CalcAddShift9	; no carry bits
; INPUT: R_M3..R_M10 = mantissa
;	 R_ZERO = 0
; OUTPUT: returns Z flag if result is 0 (overflow from 0xFF 0xFF 0xFF...)
; DESTROYS: -
	rcall	CalcMantInc	; increment mantissa
	sbci	R_M2,0xff
	brne	CalcAddShift9	; no overflow
CalcAddShift6:
; OUTPUT: R_M2..R_M10 number (= 0)
; DESTROYS: -
	rjmp	CalcClearNum2	; clear result R_M2..R_M10

CalcAddShift9:
	ret

; ----------------------------------------------------------------------------
;                            Subtraction (C_SUB)
; ----------------------------------------------------------------------------
; DESTROYS: all
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------

.global CalcSub
CalcSub:

; ----- negate second number
; DESTROYS: R31, R30, R25, R24
	rcall	CalcNeg

; CalcAdd must follow

; ----------------------------------------------------------------------------
;                            Addition (C_ADD)
; ----------------------------------------------------------------------------
; DESTROYS: all
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------

.global CalcAdd
CalcAdd:

; ----- get last 2 numbers (1st -> X, 2nd -> Z)
; OUTPUT: R27:R26 (X) = pre-last number on calculator stack
;	  R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop2

; ----- prepare numbers for addition; 1st exponent -> R_R9:R_R10/Z, 2nd exponent -> R_N9:R_N10/X
; INPUT: R31:R30 (Z) = pointer to the number
; OUTPUT: R_R9:R_R10 = exponent
; DESTROYS: R_M1..R_M10

	rcall	CalcPrepAdd	; prepare 2nd number
	movw	R_N10,R_R10	; save 2nd exponent -> R_N9:R_N10
; INPUT and OUTPUT: R31:R30 (Z), R27:R26 (X) = registers to exchange
; DESTROYS: -
	rcall	ExcXZ		; exchange pointers
	rcall	CalcPrepAdd	; prepare 1st number, 1st exponent -> R_R9:R_R10

; ----- sort numbers - 2nd exponent must not be less than 1st one

	cp	R_N10,R_R10	; compare exponents
	cpc	R_N9,R_R9	; compare exponents
	brcc	CalcAdd2	; 2nd exponent is higher or equal, it is OK

; INPUT and OUTPUT: R31:R30 (Z), R27:R26 (X) = registers to exchange
; DESTROYS: -
	rcall	ExcXZ		; exchange pointers

	eor	R_R10,R_N10	; exchange exponents
	eor	R_N10,R_R10
	eor	R_R10,R_N10

	eor	R_R9,R_N9	; exchange exponents
	eor	R_N9,R_R9
	eor	R_R9,R_N9

CalcAdd2:

; ----- fetch 2 numbers and delete 2nd number:
;			1st number Z -> (R_R9:R_R10) R_M1..R_M10
;			2nd number X -> (R_R7:R_R8) R_N1..R_N10
; INPUT: R31:R30 (Z) = pointer to 1st number
;	 R27:R26 (X) = pointer to 2nd number
; OUTPUT: R_M1..R_M10 = 1st number (from Z)
;	  R_N1..R_N10 = 2nd number (from X)
; DESTROYS: R31, R30, R27, R26
; CALCULATOR STACK: -1
	push	R_N9
	push	R_N10
	rcall	CalcFetch2
	pop	R_R8
	pop	R_R7

; ----- save new exponent (= exponent of 2nd number) -> R_EXH:R_EXL
; ... already R_EXH:R_EXL = R_R7:R_R8
;	movw	R_EXL,R_R8

; ----- difference of exponents (= 2nd exponent - 1st exponent; result is >= 0) -> R_R9:R_R10

	sub	R_R10,R_R8	; 1st exponent - 2nd exponent
	sbc	R_R9,R_R7

	com	R_R9
	neg	R_R10
	sbci	R_R9,0xff	; negate difference

; ----- shift 1st number right to normalize numbers to the same exponent
; INPUT: R_R9:R_R10 = number of shifts
;	 R_M2..R_M10 = extended mantissa (R_M2=0x00 or 0xFF)
; DESTROYS: R_R10

	rcall	CalcAddShift

; ----- add both numbers (here is R_M2=0x00 or 0xFF, R_N2=0x00 or 0xFF)
; INPUT: R_M3..R_M10 mantissa 1
;	 R_N3..R_N10 mantissa 2
; OUTPUT: R_M3..R_M10 result
;	  C = output carry
; DESTROYS: -
	rcall	CalcMantAdd	; add mantissas
	adc	R_M2,R_N2

; ----- negate result

	mov	R_MS,R_M2	; get sign
	andi	R_MS,B7		; isolate sign sign
	breq	CalcAdd3	; number is not negative

; INPUT: R_M2..R_M10 extended mantissa
;	 R_ZERO = 0
; OUTPUT: R_M2..R_M10 extended mantissa negated
;	  CY = carry set if result is not 0
; DESTROYS: -
	rcall	CalcMantNeg	; negate mantissa
	brcs	CalcAdd3	; result is not 0

	rjmp	CalcMulUnder	; underflow (difference is 0)

; ----- check overflow = highest byte is 0x01

CalcAdd3:
	clr	R_MT		; exponent HIGH = 0
	tst	R_M2
	breq	CalcAdd6	; no overflow

; ----- overflow - shift result right and increment exponent
; INPUT: R_R9:R_R10 = number of shifts
;	 R_M2..R_M10 = normalized number (mantissa, R_M2=0x00 or 0xFF)
; DESTROYS: R_R10

	ldi	R_R10,1		; number of shifts = 1
	rcall	CalcAddShift2	; shift result right
	adiw	R_EXL,1		; increment exponent R_EXH:R_EXL
	adc	R_MT,R_MT	; exponent HIGH

; ----- normalize number: R_MS sign, R_M3..R_M10(:R_M11) mantissa, R_MT:R_EXH:R_EXL exponent

CalcAdd6:
	clr	R_M11		; R_M11 <- 0, mantissa extra lowest byte
	rjmp	CalcMulNorm	; normalize result

; ----------------------------------------------------------------------------
;                           Square root (C_SQRT)
; ----------------------------------------------------------------------------
; DESTROYS: all
; USES: TEMP_1, TEMP_2, TEMP_3, TEMP_4
; ----------------------------------------------------------------------------

.global CalcSqrt
CalcSqrt:

	rcall	Calc
; offset 0: number is zero, result will be zero
	.byte	C_JUMPZ		; jump if zero
	.byte	9		; jump to offset 5 of CalcPow (5 + 6 - 2 = 9)
; offset 2
	.byte	C_CONST(CONST_05) ; load constant 0.5 (x,0.5)
	.byte	C_END		; end
; offset 4
	.balign 2		; align
; offset 4

; CalcPow must follow

; ----------------------------------------------------------------------------
;                             Power (C_POW)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R4
; USES: TEMP_1, TEMP_2, TEMP_3, TEMP_4
; ----------------------------------------------------------------------------
; Calculate power x^y. Special cases: 0^0=1, 0^+n=0, 0^-n=overflow.

.global CalcPow
CalcPow:
				; (x,y) ... want to get x^y
	rcall	Calc		; calculator
; CalcSqrt offset 6

; ===== check exponent 0 (x^0) -> result is 1
; offset 0: exponent is 0, result will be 1
	.byte	C_JUMPNZ	; jump if not zero (x,y)
	.byte	6		; jump to offset 8 (8-2=6) (x,y)
; offset 2
	.byte	C_DEL		; delete y (x)
	.byte	C_DEL		; delete x ()
	.byte	C_CONST(CONST_1) ; load constant 1
; offset 5
	.byte	C_END		; end
; offset 6
	.balign 2		; align
; offset 6
	ret

; ===== check base 0 (0^N) -> result is 0 or overflow
; offset 8: base is 0
	.byte	C_EXC		; exchange (y,x)
	.byte	C_JUMPNZ	; jump if not zero (y,x)
	.byte	11		; jump to offset 22 (22-11=11)
; offset 11: exponent is > 0, result is 0
	.byte	C_DEL		; delete (y)
	.byte	C_GR0		; check y > 0 (0/1)
	.byte	C_JUMPF		; jump if y < 0
	.byte	3		; jump to offset 18 (18-15=3)
; offset 15: 0^+N result will be 0
	.byte	C_CONST(CONST_0) ; result will be 0
	.byte	C_JMP		; jump back
	.byte	-13		; jump to offset 5 (5-18=-13)
; offset 18: 0^-N result will be overflow
	.byte	C_OVER		; load overflow number
	.byte	C_ERROR		; set error flag
	.byte	C_JMP		; jump back
	.byte	-17		; jump to offset 5 (5-22=-17)

; ===== check if base is positive, calculate x^y
; offset 22:
	.byte	C_DUP		; duplicate base (y,x,x)
	.byte	C_GR0		; check x > 0 (y,x,0/1)
	.byte	C_JUMPF		; jump if base is <= 0 (y,x)
	.byte	6		; jump to offset 32 (32-26=6)
; offset 26:
	.byte	C_ABS		; absolute value of base (y,x)
	.byte	C_LN		; ln (y,ln(x)) ... uses TEMP_1, TEMP_2, TEMP_3, TEMP_4
	.byte	C_MUL		; multiply (y*ln(x))
	.byte	C_END		; end
; offset 30:
	.balign 2		; align
; offset 30:
	rjmp	CalcExp		; calculate exp(x) ... uses TEMP_1, TEMP_2, TEMP_3

; ===== base is negative - allowed only if exponent is integer
; offset 32: check if exponent is integer
	.byte	C_DUP2		; pre-duplicate (y,x,y)
	.byte	C_DUP		; duplicate (y,x,y,y)
	.byte	C_TRUNC		; truncate (y,x,y,trunc(y))
	.byte	C_SUB		; subtract (y,x,y-trunc(y))
	.byte	C_JUMPF		; jump if number is integer, difference = 0 (y,x)
	.byte	3		; jump to offset 41 (41-38=3)
; offset 38: exponent is not integer, error
	.byte	C_ERROR		; set error flag (y,x)
	.byte	C_JMP		; jump back (y,x)
	.byte	-15		; jump to offset 26 (26-41=-15)
; offset 41: exponent is integer, check if exponent if even
	.byte	C_DUP2		; pre-duplicate (y,x,y)
	.byte	C_DIV2		; divide / 2 (y,x,y/2)
	.byte	C_DUP		; duplicate (y,x,y/2,y/2)
	.byte	C_TRUNC		; truncate (y,x,y/2,trunc(y/2))
	.byte	C_SUB		; subtract (y,x,y/2-trunc(y/2))
	.byte	C_JUMPF		; jump if exponent is even, difference = 0 (y,x)
	.byte	-22		; jump to offset 26 (26-48=-22)
; offset 48: exponent is odd, result will be negative
	.byte	C_ABS		; absolute value of base (y,x)
	.byte	C_LN		; ln (y,ln(x)) ... uses TEMP_1, TEMP_2, TEMP_3, TEMP_4
	.byte	C_MUL		; multiply (y*ln(x))
	.byte	C_EXP		; exponent ... uses TEMP_1, TEMP_2, TEMP_3
	.byte	C_NEG		; negate result
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;                           Bit operation
; ----------------------------------------------------------------------------
; INPUT: R24 operation (OPER_AND, OPER_OR or OPER_XOR)
; ----------------------------------------------------------------------------
; in stack: 2 numbers

.global CalcBit
CalcBit:

; ----- save required operation

	push	r24

; ----- get last 2 numbers (1st -> X, 2nd -> Z)
; OUTPUT: R27:R26 (X) = pre-last number on calculator stack
;	  R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop2

; ----- prepare numbers for bit operation; 1st exponent -> R_R9:R_R10/Z, 2nd exponent -> R_N9:R_N10/X
; - Clear exponent and expand mantissa to 9 bytes signed.
; INPUT: R31:R30 (Z) = pointer to the number
; OUTPUT: R_R9:R_R10 = exponent
; DESTROYS: R_M1..R_M10

	rcall	CalcPrepAdd	; prepare 2nd number
	movw	R_N10,R_R10	; save 2nd exponent -> R_N9:R_N10
; INPUT and OUTPUT: R31:R30 (Z), R27:R26 (X) = registers to exchange
; DESTROYS: -
	rcall	ExcXZ		; exchange pointers
	rcall	CalcPrepAdd	; prepare 1st number, 1st exponent -> R_R9:R_R10

; ----- sort numbers - 2nd exponent must not be less than 1st one

	cp	R_N10,R_R10	; compare exponents
	cpc	R_N9,R_R9	; compare exponents
	brcc	CalcBit2	; 2nd exponent is higher or equal, it is OK

; INPUT and OUTPUT: R31:R30 (Z), R27:R26 (X) = registers to exchange
; DESTROYS: -
	rcall	ExcXZ		; exchange pointers

	eor	R_R10,R_N10	; exchange exponents
	eor	R_N10,R_R10
	eor	R_R10,R_N10

	eor	R_R9,R_N9	; exchange exponents
	eor	R_N9,R_R9
	eor	R_R9,R_N9

CalcBit2:

; ----- fetch 2 numbers and delete 2nd number:
;			1st number Z -> (R_R9:R_R10) R_M1..R_M10
;			2nd number X -> (R_R7:R_R8) R_N1..R_N10
; INPUT: R31:R30 (Z) = pointer to 1st number
;	 R27:R26 (X) = pointer to 2nd number
; OUTPUT: R_M1..R_M10 = 1st number (from Z)
;	  R_N1..R_N10 = 2nd number (from X)
; DESTROYS: R31, R30, R27, R26
; CALCULATOR STACK: -1
	push	R_N9
	push	R_N10
	rcall	CalcFetch2
	pop	R_R8
	pop	R_R7

; ----- save new exponent (= exponent of 2nd number) -> R_EXH:R_EXL
; ... already R_EXH:R_EXL = R_R7:R_R8
;	movw	R_EXL,R_R8

; ----- difference of exponents (= 2nd exponent - 1st exponent; result is >= 0) -> R_R9:R_R10

	sub	R_R10,R_R8	; 1st exponent - 2nd exponent
	sbc	R_R9,R_R7

	com	R_R9
	neg	R_R10
	sbci	R_R9,0xff	; negate difference

; ----- shift 1st number right to normalize numbers to the same exponent
; INPUT: R_R9:R_R10 = number of shifts
;	 R_M2..R_M10 = extended mantissa (R_M2=0x00 or 0xFF)
; DESTROYS: R_R10

	rcall	CalcAddShift

; ----- bit operation

	pop	r24		; required operation

	; AND
	cpi	r24,OPER_AND	; AND?
	brne	2f
	and	R_M10,R_N10
	and	R_M9,R_N9
	and	R_M8,R_N8
	and	R_M7,R_N7
	and	R_M6,R_N6
	and	R_M5,R_N5
	and	R_M4,R_N4
	and	R_M3,R_N3
	and	R_M2,R_N2
	rjmp	4f

	; OR
2:	cpi	r24,OPER_OR	; OR?
	brne	3f
	or	R_M10,R_N10
	or	R_M9,R_N9
	or	R_M8,R_N8
	or	R_M7,R_N7
	or	R_M6,R_N6
	or	R_M5,R_N5
	or	R_M4,R_N4
	or	R_M3,R_N3
	or	R_M2,R_N2
	rjmp	4f

	; XOR
3:	eor	R_M10,R_N10
	eor	R_M9,R_N9
	eor	R_M8,R_N8
	eor	R_M7,R_N7
	eor	R_M6,R_N6
	eor	R_M5,R_N5
	eor	R_M4,R_N4
	eor	R_M3,R_N3
	eor	R_M2,R_N2

; ----- negate result

4:	mov	R_MS,R_M2	; get sign
	andi	R_MS,B7		; isolate sign sign
	breq	5f		; number is not negative

; INPUT: R_M2..R_M10 extended mantissa
;	 R_ZERO = 0
; OUTPUT: R_M2..R_M10 extended mantissa negated
;	  CY = carry set if result is not 0
; DESTROYS: -
	rcall	CalcMantNeg	; negate mantissa
	brcs	5f		; result is not 0

	rjmp	CalcMulUnder	; underflow (difference is 0)

; ----- normalize number: R_MS sign, R_M3..R_M10(:R_M11) mantissa, R_MT:R_EXH:R_EXL exponent

5:	clr	R_MT		; exponent HIGH = 0
	clr	R_M11		; R_M11 <- 0, mantissa extra lowest byte
	rjmp	CalcMulNorm	; normalize result

; ----------------------------------------------------------------------------
;                           Bitwise AND (C_BITAND)
; ----------------------------------------------------------------------------

.global CalcBitAnd
CalcBitAnd:
	ldi	r24,OPER_AND
	rjmp	CalcBit

; ----------------------------------------------------------------------------
;                           Bitwise OR (C_BITOR)
; ----------------------------------------------------------------------------

.global CalcBitOr
CalcBitOr:
	ldi	r24,OPER_OR
	rjmp	CalcBit

; ----------------------------------------------------------------------------
;                           Bitwise XOR (C_BITXOR)
; ----------------------------------------------------------------------------

.global CalcBitXor
CalcBitXor:
	ldi	r24,OPER_XOR
	rjmp	CalcBit

; ----------------------------------------------------------------------------
;                          Integer factorial
; ----------------------------------------------------------------------------

.global CalcFactInt
CalcFactInt:

; ----- load constant 1

	ldi	r24,CONST_1
	rcall	CalcConst	; load constant 1
	rcall	CalcExc		; exchange

; ----- load number of steps (absolute value)
; OUTPUT: R25:R24 = unsigned integer
;	  R_M3 = negative flag (0 or B7)
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
	rcall	CalcUnstackW
	adiw	r24,0		; check 0!
	breq	9f		; zero

; ----- multiply accumulator by coefficient

2:	push	r24
	push	r25		; push coefficient

; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	rcall	CalcStackW	; stack coefficient

	rcall	CalcMul		; multiply

; ----- next coefficient

	pop	r25
	pop	r24

	sbiw	r24,1		; decrement
	brne	2b		; next loop

9:	ret

; ----------------------------------------------------------------------------
;  Factorial checks: returns ((int,)cor,x) and ZY=no correction
; ----------------------------------------------------------------------------

#define FACTCORR 12		// factorial correction for numbers < 4096

CalcFactCheck:

; ----- check if do correction for small numbers
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; get exponent
	ldi	r26,hi8(EXP_BIAS+FACTCORR)
	cpi	r24,lo8(EXP_BIAS+FACTCORR) ; check correction
	cpc	r25,r26
	ldi	r24,0		; flag - no correction
	brcc	2f		; no correction
	ldi	r24,1		; flag - do correction
2:	push	r24		; push flag 'cor'
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	rcall	CalcStackB	; stack flag (int,x,cor)
	rcall	CalcExc		; exchange (int,cor,x) ... cor: 1=do correction for small numbers
	pop	r24		; pop flag 'cor'
	tst	r24		; do correction?
	ret

; ----------------------------------------------------------------------------
;  Factorial correction: returns ((int,)q,cor,x)
; ----------------------------------------------------------------------------

CalcFactCorr:

; ----- correction for small numbers
; work-around to raise precission of low numbers - shift calculations to higher values

	; prepare registers for correction
	ldi	r24,CONST_1	; constant 1
	rcall	CalcConst	; load constant 1 (int,cor,x,1)
	rcall	CalcExc2	; pre-exchange (int,1,x,cor)
	rcall	CalcExc		; exchange (int,1,cor,x)
	rcall	CalcTopCheck	; get exponent -> R25:R24
	ldi	r25,lo8(EXP_BIAS+FACTCORR) ; max. correction
	sub	r25,r24		; number of shifts

	; do correction - multiply higher numbers
3:	push	r25		; loop counter
	rcall	CalcInc		; increment number (int,q,cor,x+1)
	rcall	CalcExc		; pre-exchange (int,q,x+1,cor)
	rcall	CalcExc2	; pre-pre-exchange (int,cor,x+1,q)
	rcall	CalcDup2	; pre-duplicate (int,cor,x+1,q,x+1)
	rcall	CalcMul		; multiply (int,cor,x+1,q*(x+1))
	rcall	CalcExc2	; pre-exchange (int,q,x,cor)
	rcall	CalcExc		; exchange (int,q,cor,x)
	pop	r25		; loop counter
	dec	r25		; count
	brne	3b		; next loop
	ret

; ----------------------------------------------------------------------------
; Factorial main: returns ((int,)(q,)cor,ln n!)
; ----------------------------------------------------------------------------

CalcFactMain:

; ----- main calculation (xi+1 = (x + ai/xi))

	rcall	CalcDup		; duplicate (int,(q,)cor,x,x=p)
	ldi	r30,lo8(FactATab+11*NUM_BYTES) ; last coefficient in factorial table
	ldi	r31,hi8(FactATab+11*NUM_BYTES)

	; load coefficient from the table and divide member
5:	push	r30		; (int,(q,)cor,x,p)
	push	r31
; INPUT: R31:R30 = constant in ROM
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcConstROM	; load constant (int,(q,)cor,x,p,a)
	rcall	CalcExc		; exchange (int,(q,)cor,x,a,p)
	rcall	CalcDiv		; divide coefficient by member (int,(q,)cor,x,a/p)
	rcall	CalcDup2	; pre-duplicate x (int,(q,)cor,x,a/p,x)
	rcall	CalcAdd		; add x+ai/xi (int,(q,)cor,x,p)

	pop	r31
	pop	r30

	; next coefficient (loop to coefficient a[1])
	sbiw	r30,NUM_BYTES	; shift pointer
	cpi	r30,lo8(FactATab)
	brne	5b		; stop on coefficient a[0]

	; divide last member a0/x0
	rcall	CalcConstROM	; load constant a0 (int,(q,)cor,x,p,a0)

	rcall	Calc		; calculator
	.byte	C_EXC		; exchange (int,(q,)cor,x,a0,p)
	.byte	C_DIV		; divide coefficient by member (int,(q,)cor,x,a0/p=p)
	; add ln(2*pi)/2 - x
	.byte	C_CONST(CONST_LNPI22) ; constant ln(PI*2)/2
	.byte	C_ADD		; add (int,(q,)cor,x,p+ln(2*pi)/2)
	.byte	C_DUP2		; pre-duplicate (int,(q,)cor,x,p,x)
	.byte	C_SUB		; subtract (int,(q,)cor,x,p-x)
	; logarithm of x
	.byte	C_DUP2		; pre-duplicate (int,(q,)cor,x,p,x)
	.byte	C_LN		; logarithm (int,(q,)cor,x,p,lnx)
	; num + 0.5
	.byte	C_EXC2		; pre-exchange (int,(q,)cor,lnx,p,x)
	.byte	C_CONST(CONST_05) ; load constant 0.5 (int,(q,)cor,lnx,p,x,0.5)
	.byte	C_ADD		; add (int,(q,)cor,lnx,p,x+0.5)
	; multiply ln(x)*(x + 0.5)
	.byte	C_EXC		; exchange (int,(q,)cor,lnx,x,p)
	.byte	C_EXC2		; pre-exchange (int,(q,)cor,p,x,lnx)
	.byte	C_MUL		; multiply (int,(q,)cor,p,lnx*x)
	.byte	C_ADD		; add member (int,(q,)cor,p+lnx*x)
	.byte	C_END		; end
	.balign 2		; align
	ret

; ----------------------------------------------------------------------------
;    non-integer factorial approximation (precission 27 digits or more)
; ----------------------------------------------------------------------------
; Stieltjes, Gamma function, continued fraction:
; p = a0/(x + a1/(x + a2/(x + ... an/x
;		a0 = 1 / 12
;		a1 = 1 / 30
;		a2 = 53 / 210
;		a3 = 195 / 371
;		a4 = 22999 / 22737
;		a5 = 29944523 / 19733142
;		a6 = 109535241009 / 48264275462
;		a7 = 29404527905795295658 / 9769214287853155785
;		a8 = 455377030420113432210116914702 / 113084128923675014537885725485
;		a9 = 26370812569397719001931992945645578779849 / 5271244267917980801966553649147604697542
;		a10 = 152537496709054809881638897472985990866753853122697839 / 24274291553105128438297398108902195365373879212227726
;		a11 = 100043420063777451042472529806266909090824649341814868347109676190691 / 13346384670164266280033479022693768890138348905413621178450736182873
; q = p + ln(2*pi)/2 - x + (x + 1/2)*ln(x)
; y = exp(p)
; precision digits, without work-around correction: 1: 6, 2: 10, 3: 13, 4: 15, 5: 17, 6: 19, 7: 20, 8: 22, 9: 23, 10: 24, 11: 25, 12: 26, 13..14: 27, 15: 28, 100: 48, 1000: 73
; precision digits with work-around correction: 1..4: 27, 5: 28, 6..8: 29, 9: 30, 10..11: 31, 12..13: 32, 14..17: 33, 18..19: 34, 100: 49, 1000: 74

.global CalcFact
CalcFact:

; ----- check if number is integer

	rcall	CalcDup		; duplicate (x,x)
	rcall	CalcDup		; duplicate (x,x,x)
	rcall	CalcTrunc	; truncate (x,x,trunc(x))
	rcall	CalcSub		; subtract (x,x-trunc(x)=int) ... int: 0=number is integer
	rcall	CalcExc		; exchange (int,x)

;  ---- Factorial checks: returns (int,cor,x) and ZY=no correction

	rcall	CalcFactCheck	; (int,cor,x)
	breq	4f		; no correction

; ----- Factorial correction: returns ((int,)q,cor,x)

	rcall	CalcFactCorr	; (int,q,cor,x)

; ----- main calculation (xi+1 = (x + ai/xi))

4:	rcall	CalcFactMain	; main (int,(q,)cor,ln n!)

	; exponent
	rcall	CalcExp		; exponent
	rcall	CalcExc		; exchange (int,(q,)n!,cor)

; ----- check correction
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	rcall	CalcUnstackB	; get corr flag
	tst	r24		; check corr flag (1=do correction)
	breq	7f		; no correction
	; here is now (int,q,n!)
	rcall	CalcExc		; exchange (int,n!,q)
	rcall	CalcDiv		; divide (int,n!/q)
	; here is now (int,n!)
7:	rcall	CalcExc		; exchange (n!,int)
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck	; check zero number
	rcall	CalcDel2	; delete number (saves SREG)
	brne	8f		; number is not integer
	rcall	CalcRound	; round number to integer
8:	ret

; ----------------------------------------------------------------------------
;                     natural logarithm factorial
; ----------------------------------------------------------------------------

.global CalcFactLn
CalcFactLn:

;  ---- Factorial checks: returns (cor,x) and ZY=no correction

	rcall	CalcFactCheck	; (cor,x)
	breq	4f		; no correction

; ----- Factorial correction: returns (q,cor,x)

	rcall	CalcFactCorr	; (q,cor,x)
	rcall	CalcExc2	; pre-exchange (x,cor,q)
	rcall	CalcLn		; logatihm (x,cor,ln(q))
	rcall	CalcExc2	; pre-exchange (q,cor,x)

; ----- main calculation (xi+1 = (x + ai/xi))

4:	rcall	CalcFactMain	; main ((q,)cor,ln n!)
	rcall	CalcExc		; exchange ((q,)n!,cor)

; ----- check correction
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	rcall	CalcUnstackB	; get corr flag
	tst	r24		; check corr flag (1=do correction)
	breq	7f		; no correction
	; here is now (int,q,n!)
	rcall	CalcExc		; exchange (n!,q)
	rcall	CalcSub		; subtract (n!-q)
7:	ret

; ----------------------------------------------------------------------------
;                    Convert polar to cartesian (C_PR)
; ----------------------------------------------------------------------------
; INPUT: pre-top (T) = radius r
;	  top (X) = angle in radians a
; OUTPUT: pre-top (T) = real x
;	  top (X) = imaginary y
; ----------------------------------------------------------------------------
; x = r*cos(a)
; y = r*sin(a)

.global CalcPR
CalcPR:
	rcall	Calc		; calculator (r,a)
	.byte	C_DUP2		; pre-duplicate (r,a,r)
	.byte	C_DUP2		; pre-duplicate (r,a,r,a)
	.byte	C_COS		; cosinus (r,a,r,cos(a))
	.byte	C_MUL		; multiply (r,a,r*cos(a)=x)
	.byte	C_EXC2		; pre-exchange (x,a,r)
	.byte	C_EXC		; exchange (x,r,a)
	.byte	C_SIN		; sinus (x,r,sin(a))
	.byte	C_MUL		; multiply (x,r*sin(a)=y)
	.byte	C_END		; (x,y)
	.balign 2
	ret

; ----------------------------------------------------------------------------
;                    Convert cartesian to polar (C_RP)
; ----------------------------------------------------------------------------
; INPUT: pre-top (T) = real x
;	  top (X) = imaginary y
; OUTPUT: pre-top (T) = radius r
;	  top (X) = angle in radians a
; ----------------------------------------------------------------------------
; r = sqrt(x^2 + y^2)
; a = atan(y/x) ... if X < 0 then a = a + pi

.global CalcRP
CalcRP:

; ----- save error and running flag (atan(y/0) can raise error)
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

; ----- convert R->P (cartesian -> polar)

	rcall	Calc		; calculator (x,y)
; offset 0: check if x is 0
	.byte	C_EXC		; exchange (y,x)
	.byte	C_JUMPNZ	; jump if x is not 0 (y,x)
	.byte	10		; jump to offset 13 (13-3=10)
; offset 3: x is zero, angle will be PI/2 or -PI/2
	.byte	C_DEL		; delete (y)
	.byte	C_DUP		; duplicate (y,y)
	.byte	C_SGN		; signum (y,-1/0/1)
	.byte	C_CONST(CONST_PI05) ; constant PI/2 (y,-1/0/1,pi)
	.byte	C_MUL		; multiply (y,a)
	.byte	C_EXC		; exchange (a,y)
	.byte	C_ABS		; absolute value (a,r)
	.byte	C_EXC		; exchange (r,a)
	.byte	C_JMP		; jump
	.byte	19		; jump to offset 32 (32-13=19)
; offset 13
	.byte	C_EXC		; exchange (x,y)
; offset 14: calculate radius
	.byte	C_DUP2		; pre-duplicate (x,y,x)
	.byte	C_DUP2		; pre-duplicate (x,y,x,y)
	.byte	C_SQR		; square (x,y,x,y^2)
	.byte	C_EXC		; exchange (x,y,y^2,x)
	.byte	C_SQR		; square (x,y,y^2,x^2)
	.byte	C_ADD		; add (x,y,y^2+x^2)
	.byte	C_SQRT		; square root = radius (x,y,sqrt(y^2+x^2) = r)
; offset 21: calculate angle
	.byte	C_EXC2		; pre-exchange (r,y,x)
	.byte	C_EXC		; exchange (r,x,y)
	.byte	C_DUP2		; pre-duplicate (r,x,y,x)
	.byte	C_DIV		; divide (r,x,y/x)
	.byte	C_ATN		; arcus tangent (r,x,atan(y/x)) = (a))
; offset 26: angle correction
	.byte	C_EXC		; exchange (r,a,x)
	.byte	C_LT0		; check if X < 0 (r,a,0/1)
	.byte	C_JUMPF		; skip if not X < 0 (r,a)
	.byte	2		; jump to offset 32 (32-30=2)
; offset 30: X is negative
	.byte	C_CONST(CONST_PI) ; load constant PI (r,a,PI)
	.byte	C_ADD		; add (r,a+PI)
; offset 32:
	.byte	C_END		; (r,a)
	.balign 2

; ----- restore error and running flag

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

2:	ret

; ----------------------------------------------------------------------------
;                   Standard normal distribution Z(x) (C_SND)
; ----------------------------------------------------------------------------
;  Z(x) = 1 / sqrt(2*pi*exp(x^2))

.global CalcSND
CalcSND:
	rcall	Calc		; calculator (x)
	.byte	C_SQR		; square (x^2)
	.byte	C_EXP		; exponent (exp(x^2))
	.byte	C_CONST(CONST_PI2) ; constant PI*2 (exp(x^2),PI*2)
	.byte	C_MUL		; multiply
	.byte	C_SQRT		; square root
	.byte	C_REC		; reciprocal value 
	.byte	C_END
	.balign 2
	ret

; ----------------------------------------------------------------------------
;    Complementary Gaussian distribution Q(x) (C_CGD) ... range x = -8..+8
; ----------------------------------------------------------------------------

.global CalcCGD
CalcCGD:
	rcall	Calc		; calculator (x)
	.byte	C_CND		; cumulative normal distribution (p)
	.byte	C_CONST(CONST_1) ; constant 1 (p,1)
	.byte	C_SUB		; subtract (p-1)
	.byte	C_NEG		; negate (1-p = q)
	.byte	C_END		; (q)
	.balign 2
	ret

; ----------------------------------------------------------------------------
;         Cumulative normal distribution P(x) (C_CND) ... range x = -8..+8
; ----------------------------------------------------------------------------
; Interpolation using Taylor serie:
;    P(x) = 0.5 + Z(x)*(x + x^3/3 + x^5/3/5 + x^7/3/5/7 + x^9/3/5/7/9 + ... )

.global CalcCND
CalcCND:
	rcall	Calc		; calculator (x)
	; offset 0: limit to +8
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_BYTE,8	; load byte 8 (x,x,8)
	.byte	C_GR		; compare if > 8 (x,1/0)
	.byte	C_JUMPT		; jump if > 8 (x)
	.byte	40		; jump to offset 46 (46-6=40)

	; offset 6: limit to -8
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_BYTE,8	; load byte 8 (x,x,8)
	.byte	C_NEG		; negate (x,x,-8)
	.byte	C_LT		; compare if < -8 (x,1/0)
	.byte	C_JUMPT		; jump if < -8 (x)
	.byte	37		; jump to offset 50 (50-13=37)

	; offset 13: prepare Z(x)
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_SND		; standard normal distribution Z(x) (x,z)
	.byte	C_EXC		; exchange (z,x)

	; offset 16
	.byte	C_DUP		; duplicate (z,x,x)
	.byte	C_SQR		; square (z,x,x^2 = x2)
	.byte	C_CONST(CONST_1) ; constant 1 (z,x,x2,1)
	.byte	C_EXC2		; pre-exchange (z,1,x2,x)
	.byte	C_DUP		; duplicate (z,c,x2,acc,mem) ... Z(x),distr., constant, x^2, accumulator, member
	.byte	C_EXC		; exchange (z,c,x2,mem,acc)

	; offset 22: start of loop (here is z,c,x2,mem,acc)
	.byte	C_EXC		; exchange (z,c,x2,acc,mem)
	.byte	C_DUP3		; pre-duplicate (z,c,x2,acc,mem,x2)
	.byte	C_MUL		; multiply (z,c,x2,acc,mem*x2)
	.byte	C_EXC3		; pre-exchange (z,mem,x2,acc,c)
	.byte	C_CONST(CONST_2) ; constant 2 (z,mem,x2,acc,c,2)
	.byte	C_ADD		; add (z,mem,x2,acc,c+2)
	.byte	C_EXC3		; pre-exchange (z,c,x2,acc,mem)
	.byte	C_DUP4		; pre-duplicate (z,c,x2,acc,mem,c)
	.byte	C_DIV		; divide (z,c,x2,acc,mem/c)
	.byte	C_EXC		; exchange (z,c,x2,mem,acc)
	.byte	C_DUP2		; pre-duplicate (z,c,x2,mem,acc,mem)
	.byte	C_ADDLOOP	; add and loop (z,c,x2,mem,acc+mem)
	.byte	-13		; jump to offset 22 (22-35=-13) (z,c,x2,mem,acc)

	; offset 35: 
	.byte	C_EXC3		; pre-exchange (z,acc,x2,mem,c)
	.byte	C_DEL		; delete (z,acc,x2,mem)
	.byte	C_DEL		; delete (z,acc,x2)
	.byte	C_DEL		; delete (z,acc)
	.byte	C_MUL		; multiply (z*acc)
	.byte	C_CONST(CONST_05) ; load constant 0.5 (z,0.5)
	.byte	C_ADD		; add (z)
	; offset 42
	.byte	C_END
	; offset 43
	.balign 2
	; offset 44
	ret
	; offset 46

; ===== limits

	; offset 46: limit to 1 for x > 8
	.byte	C_DEL		; delete ()
	.byte	C_CONST(CONST_1) ; load constant 1
	.byte	C_JMP		; jump
	.byte	-8		; jump to offset 42 (42-50=-8)

	; offset 50: limit to 0 fo x < -8
	.byte	C_DEL		; delete ()
	.byte	C_CONST(CONST_0) ; load constant 0
	.byte	C_JMP		; jump
	.byte	-12		; jump to offset 42 (42-54=-12)
	; offset 54
	.balign 2

; ----------------------------------------------------------------------------
;     find greatest common divisor (GCD) of two integer numbers (C_GCD)
; ----------------------------------------------------------------------------
; DESTROYS: all
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------
; - Returns 1 if any of numbers is 0.
; - Uses Euclidean algorithm
;     https://en.wikipedia.org/wiki/Euclidean_algorithm
;     https://cs.wikipedia.org/wiki/Eukleid%C5%AFv_algoritmus

.global CalcGcd
CalcGcd:
	rcall	Calc		; calculator (u,w)
	; offset 0: check w
	.byte	C_ROUND		; round (u,round(w))
	.byte	C_JUMPZ		; jump if w = 0 (u,w)
	.byte	17		; jump to offset 20 (20-3=17) (u,w)
	; offset 3: check u
	.byte	C_EXC		; exchange (w,u)
	.byte	C_ROUND		; round (w,round(u))
	.byte	C_JUMPZ		; jump if u = 0 (w,u)
	.byte	13		; jump to offset 20 (20-7=13) (w,u)
	; offset 7: u modulo w
	.byte	C_DUP2		; pre-duplicate (w,u,w)
	.byte	C_MOD		; u modulo w (w,r)
	.byte	C_ROUND		; round (w,r)
	.byte	C_JUMPZ		; jump if r = 0 (w,r)
	.byte	3		; jump to offset 15 (15-12=3) (w,r)
	; offset 12
	.byte	C_EXC		; exchange (r,w)
	.byte	C_JMP		; jump to loop (r,w)
	.byte	-8		; jump to offset 7 (7-15=-8) (r,w)
	; offset 15
	.byte	C_DEL		; delete (x)
	.byte	C_END
	; offset 17
	.balign 2
	; offset 18
	ret

	; offset 20: result will be 1
	.byte	C_DEL		; delete (u)
	.byte	C_DEL		; delete ()
	.byte	C_CONST(CONST_1) ; load constant 1
	; offset 23
	.balign 2
	; offset 24
	ret

; ----------------------------------------------------------------------------
;  normalize fraction number in calculator stack (pre-top and top) (C_FRANORM)
; ----------------------------------------------------------------------------

.global CalcFraNorm
CalcFraNorm:
	rcall	Calc		; calculator (u,w)
	.byte	C_DUP2		; pre-duplicate (u,w,u)
	.byte	C_DUP2		; pre-duplicate (u,w,u,w)
	.byte	C_GCD		; find greatest common divider (u,w,d)
	.byte	C_DUP		; duplicate (u,w,d,d)
	.byte	C_EXC3		; pre-exchange (d,w,d,u)
	.byte	C_EXC		; exchange (d,w,u,d)
	.byte	C_DIV		; divide (d,w,u2)
	.byte	C_ROUND		; round (d,w,u2)
	.byte	C_EXC2		; pre-exchange (u2,w,d)
	.byte	C_DIV		; divide (u2,w2)
	.byte	C_ROUND		; round (u2,w2)
	.byte	C_END
	.balign 2
	ret
