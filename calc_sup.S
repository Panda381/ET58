; ****************************************************************************
;
;                    Calculator support operations
;
; ****************************************************************************

#include "include.inc"

	.text

; ----------------------------------------------------------------------------
;                    Push registers R4..R27, R30, R31
; ----------------------------------------------------------------------------
; OUTPUT: R1 = 0
; DESTROYS: R0
; STACK: push 26 bytes
; ----------------------------------------------------------------------------

.global PushAll
PushAll:

; ----- save return address

	pop	r1		; (HIGH)
	pop	r0		; (LOW) get return address from the stack

; ----- push registers

	push	r4
	push	r5
	push	r6
	push	r7
	push	r8
	push	r9
	push	r10
	push	r11
	push	r12
	push	r13
	push	r14
	push	r15
	push	r16
	push	r17
	push	r18
	push	r19
	push	r20
	push	r21
	push	r22
	push	r23
	push	r24
	push	r25
	push	r26
	push	r27
	push	r30
	push	r31

; ----- restore return address

PushAll2:
	push	r0		; (LOW)
	push	r1		; (HIGH)
	clr	r1		; restore R1
	ret

; ----------------------------------------------------------------------------
;                    Pop registers R4..R27, R30, R31
; ----------------------------------------------------------------------------
; OUTPUT: R1 = 0
; DESTROYS: R0
; STACK: pop 26 bytes
; ----------------------------------------------------------------------------
; Use rcall, not rjmp!

.global PopAll
PopAll:

; ----- save return address

	pop	r1		; (HIGH)
	pop	r0		; (LOW) get return address from the stack

; ----- pop registers

	pop	r31
	pop	r30
	pop	r27
	pop	r26
	pop	r25
	pop	r24
	pop	r23
	pop	r22
	pop	r21
	pop	r20
	pop	r19
	pop	r18
	pop	r17
	pop	r16
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	r11
	pop	r10
	pop	r9
	pop	r8
	pop	r7
	pop	r6
	pop	r5
	pop	r4

; ----- restore return address

	rjmp	PushAll2	; return

; ----------------------------------------------------------------------------
;                     Load number from Z into R_M1..R_M10
; ----------------------------------------------------------------------------
; INPUT: R31:R30 (Z) = pointer to number
; OUTPUT: R_M1..R_M10 number
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcLoadNum
CalcLoadNum:
	ldd	R_M1,Z+0
	ldd	R_M2,Z+1
	ldd	R_M3,Z+2
	ldd	R_M4,Z+3
	ldd	R_M5,Z+4
	ldd	R_M6,Z+5
	ldd	R_M7,Z+6
	ldd	R_M8,Z+7
	ldd	R_M9,Z+8
	ldd	R_M10,Z+9
	ret

; ----------------------------------------------------------------------------
;                     Save number from R_M1..R_M10 to Z
; ----------------------------------------------------------------------------
; INPUT: R31:R30 (Z) = pointer to number
;	 R_M1..R_M10 number
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcSaveNum
CalcSaveNum:
	std	Z+0,R_M1
	std	Z+1,R_M2
	std	Z+2,R_M3
	std	Z+3,R_M4
	std	Z+4,R_M5
	std	Z+5,R_M6
	std	Z+6,R_M7
	std	Z+7,R_M8
	std	Z+8,R_M9
	std	Z+9,R_M10
	ret

; ----------------------------------------------------------------------------
; Round pre-correction (add little correction to mantissa of top number) (C_PRECOR)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10
; ----------------------------------------------------------------------------

.global CalcPreCor
CalcPreCor:

; ----- get pointer to top number -> Z
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop		; get last number -> Z

; ----- load number
; INPUT: R31:R30 (Z) = pointer to number
; OUTPUT: R_M1..R_M10 number
; DESTROYS: -
	rcall	CalcLoadNum

; ----- save sign

	mov	r25,R_M3	; save sign
	ori	R_M3,0x80	; restore hidden bit

; ----- add correction to round up

	ldi	r24,PRECOR	; rounding pre-correction
	add	R_M10,r24
	adc	R_M9,R_ZERO
	adc	R_M8,R_ZERO
	adc	R_M7,R_ZERO
	adc	R_M6,R_ZERO
	adc	R_M5,R_ZERO
	adc	R_M4,R_ZERO
	adc	R_M3,R_ZERO
	brcc	2f		; no carry

; ----- carry, shift mantissa right

	rcall	CalcMantRor
	inc	R_M2
	brne	2f
	inc	R_M1
	brne	2f

; ----- overflow
; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10
	call	CalcZOver	; set overflow

; ----- restore sign

2:	andi	r25,0x80	; old sign bit
	andi	R_M3,0x7f	; clear hidden bit
	or	R_M3,r25	; restore sign

; ----- save number
; INPUT: R31:R30 (Z) = pointer to number
;	 R_M1..R_M10 number
; DESTROYS: -
	rjmp	CalcSaveNum

; ----------------------------------------------------------------------------
;                         Clear number R_M1..R_M10
; ----------------------------------------------------------------------------
; OUTPUT: R_M1..R_M10 number (= 0)
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcClearNum
CalcClearNum:
	clr	R_M1
.global CalcClearNum2
CalcClearNum2:
	clr	R_M2
	clr	R_M3
	clr	R_M4
	movw	R_M6,R_M4
	movw	R_M8,R_M4
	movw	R_M10,R_M4
	ret

; ----------------------------------------------------------------------------
;                           Copy number (Z -> X)
; ----------------------------------------------------------------------------
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
; ----------------------------------------------------------------------------

.global CalcCopyNum
CalcCopyNum:
	ldi	r25,NUM_BYTES	; length of a number
1:	ld	r24,Z+
	st	X+,r24
	dec	r25
	brne	1b
	ret

; ----------------------------------------------------------------------------
;         Fetch top number from calculator stack and delete it
; ----------------------------------------------------------------------------
; OUTPUT: R_M1..R_M10 = number
; DESTROYS: R30, R31
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------

.global CalcFetch
CalcFetch:

; ----- get pointer to top number -> Z
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop		; get last number -> Z

; ----- load number

CalcFetch1: ; jump here from CalcFetch2
; INPUT: R31:R30 (Z) = pointer to number
; OUTPUT: R_M1..R_M10 number
; DESTROYS: -
	rcall	CalcLoadNum

; ----- delete top number
; DESTROYS: R31, R30
; CALCULATOR STACK: -1
	rjmp	CalcDel

; ----------------------------------------------------------------------------
;               Fetch 2 numbers and delete top number
; ----------------------------------------------------------------------------
; INPUT: R31:R30 (Z) = pointer to 1st number
;	 R27:R26 (X) = pointer to 2nd number
; OUTPUT: R_M1..R_M10 = 1st number (from Z)
;	  R_N1..R:N10 = 2nd number (from X)
; DESTROYS: R31, R30, R27, R26
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------
; None of the numbers need to be top number.

.global CalcFetch2
CalcFetch2:

; ----- fetch 2nd number

	ld	R_N1,X+
	ld	R_N2,X+
	ld	R_N3,X+
	ld	R_N4,X+
	ld	R_N5,X+
	ld	R_N6,X+
	ld	R_N7,X+
	ld	R_N8,X+
	ld	R_N9,X+
	ld	R_N10,X

	rjmp	CalcFetch1	; fetch 1st number and delete top number

; ----------------------------------------------------------------------------
;                 Store unsigned integer number into calculator stack
; ----------------------------------------------------------------------------
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
; ----------------------------------------------------------------------------

.global CalcStackB		; stack unsigned byte R24
CalcStackB:
	clr	r25		; clear number HIGH

.global CalcStackW		; stack unsigned word R25:R24
CalcStackW:

; ----- create new number 0 on end of calculator stack -> Z
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; create number -> Z

; ----- clear number R_M1..R_M10
; OUTPUT: R_M1..R_M10 number (= 0)
; DESTROYS: -
	rcall	CalcClearNum	; clear number

; ----- number is zero

	mov	r0,r25		; HIGH byte
	or	r0,r24		; check zero
	breq	CalcStack9	; zero number

; ----- preset exponent to maximum value 65535

	ldi	R_M1,hi8(EXP_BIAS+16)
	ldi	R_M2,lo8(EXP_BIAS+16)

; ----- normalize number

CalcStack2:
	subi	R_M2,1		; decrement exponent
	sbc	R_M1,R_ZERO
	lsl	r24		; rotate mantissa left
	rol	r25
	brcc	CalcStack2	; until find highest bit set

; ----- correct mantissa (clear sign bit)

	lsr	r25		; shift mantissa back
	ror	r24

; ----- save number

	movw	R_M4,r24

CalcStack9:
; INPUT: R31:R30 (Z) = pointer to number
;	 R_M1..R_M10 number
; DESTROYS: -
	rjmp	CalcSaveNum

; ----------------------------------------------------------------------------
;                 Store signed integer number into calculator stack
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = signed integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
; ----------------------------------------------------------------------------

.global CalcStackS16		; stack signed word R25:R24
CalcStackS16:

; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	tst	r25		; is number negative?
	brpl	CalcStackW	; number is not negative, store it

; INPUT/OUTPUT: R25:R24 = number to negate
; DESTROYS: -
	rcall	NegW		; negate number R25:R24
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	rcall	CalcStackW	; store negate number

; DESTROYS: R31, R30, R25, R24
	rjmp	CalcNeg		; negate number

; ----------------------------------------------------------------------------
;                 Store unsigned integer number into calculator stack
; ----------------------------------------------------------------------------
; INPUT: R27:R26:R25:R24 = unsigned integer
; DESTROYS: R31, R30, R27, R26, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
; ----------------------------------------------------------------------------

.global CalcStackD		; stack unsigned word R27:R26:R25:R24
CalcStackD:

; ----- create new number 0 on end of calculator stack -> Z
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; create number -> Z

; ----- clear number R_M1..R_M10
; OUTPUT: R_M1..R_M10 number (= 0)
; DESTROYS: -
	rcall	CalcClearNum	; clear number

; ----- number is zero

	mov	r0,r27		; HIGH byte
	or	r0,r26
	or	r0,r25
	or	r0,r24		; check zero
	breq	CalcStackD9	; zero number

; ----- preset exponent to maximum value

	ldi	R_M1,hi8(EXP_BIAS+32)
	ldi	R_M2,lo8(EXP_BIAS+32)

; ----- normalize number

CalcStackD2:
	subi	R_M2,1		; decrement exponent
	sbc	R_M1,R_ZERO
	lsl	r24		; rotate mantissa left
	rol	r25
	rol	r26
	rol	r27
	brcc	CalcStackD2	; until find highest bit set

; ----- correct mantissa (clear sign bit)

	lsr	r27		; shift mantissa back
	ror	r26
	ror	r25
	ror	r24

; ----- save number

	movw	R_M6,r24
	movw	R_M4,r26

CalcStackD9:
; INPUT: R31:R30 (Z) = pointer to number
;	 R_M1..R_M10 number
; DESTROYS: -
	rjmp	CalcSaveNum

; ----------------------------------------------------------------------------
;            Get unsigned integer number word (rounded towards zero)
; ----------------------------------------------------------------------------
; OUTPUT: R25:R24 = unsigned integer
;	  R_M3 = negative flag (0 or B7)
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R23, R_M1..R_M10
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------
; Valid range is 0..65535.9999 (negative or positive)

.global CalcUnstackW
CalcUnstackW:

; ------ round pre-correction
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10
	rcall	CalcPreCor

; ---- fetch number from stack and delete it
; OUTPUT: R_M1..R_M10 = number
; DESTROYS: R30, R31
; CALCULATOR STACK: -1
	rcall	CalcFetch

; ----- check minimal exponent: number is zero or < 1

	clr	r25		; clear result HIGH
	clr	r24		; clear result LOW

	subi	R_M2,lo8(EXP_BIAS) ; minimal exponent
	sbci	R_M1,hi8(EXP_BIAS) ; check value < 1 (including zero)
	brcs	CalcUnstack7	; number is zero or < 1
	; R_M1:R_M2 = exponent 0..32767

; ----- get mantissa high and restore hidden bit '1' -> R25:R24

	movw	r24,R_M4	; get first 2 bytes of mantissa R_M3:R_M4
	ori	r25,B7		; set implied hidden bit '1'

; ----- check maximal exponent

	subi	R_M2,lo8(16)
	sbci	R_M1,hi8(16)	; subtract max. exponent of 65535
	brcc	CalcUnstack8	; overflow exponent (>= 65535)
	; R_M1:R_M2 = exponent -16..-1

; ----- number of shifts to normalize

	com	R_M2		; negate and decrement exponent -> value 0..15
	breq	CalcUnstack7	; already maximal exponent 0

; ----- normalize mantissa

CalcUnstack4:
	lsr	r25		; rotate mantissa HIGH right
	ror	r24		; rotate mantissa LOW right
	dec	R_M2		; decrement exponent
	brne	CalcUnstack4	; normalize

; ----- result is OK

CalcUnstack7:
	clc			; clear carry flag (=OK)
	rjmp	CalcUnstack9

; ----- overflow

CalcUnstack8:
	ldi	r24,0xff	; max. value
	ldi	r25,0xff
	sec			; set carry flag (=overflow)

; ----- check sign

CalcUnstack9:
	andi	R_M3,B7		; check negative flag (set Z = number is positive or 0); C flag stays unchanged
CalcUnstack10:
	ret

; ----------------------------------------------------------------------------
;             Get unsigned integer number byte (rounded towards zero)
; ----------------------------------------------------------------------------
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R23, R_M1..R_M10
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------
; Valid range is 0..255.9999 (negative or positive)

.global CalcUnstackB
CalcUnstackB:

; OUTPUT: R25:R24 = unsigned integer
;	  R_M3 = negative flag (0 or B7)
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
	rcall	CalcUnstackW
	brcs	CalcUnstack10	; overflow

	tst	r25		; check number HIGH
	breq	CalcUnstack7	; number is <= 255, result is OK
	rjmp	CalcUnstack8	; overflow

; ----------------------------------------------------------------------------
;           Get signed integer number from calculator stack (signed word)
; ----------------------------------------------------------------------------
; OUTPUT: R25:R24 = signed integer
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------

.global CalcUnstackS16
CalcUnstackS16:

; ----- get unsigned number
; OUTPUT: R25:R24 = unsigned integer
;	  R_M3 = negative flag (0 or B7)
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
	rcall	CalcUnstackW	; get number -> R25:R24
	breq	4f		; number is positive

; ----- number is negatve - limit to 0x8000 and negate

	ldi	R_M1,0x80
	cpi	r24,1
	cpc	r25,R_M1	; check overflow (compare 0x8001)
	brcs	2f		; number is OK
	ldi	r24,0
	ldi	r25,0x80	; limit number to 0x8000

; INPUT/OUTPUT: R25:R24 = number to negate
; DESTROYS: -
2:	rjmp	NegW		; negate number R25:R24

; ----- number is positive - limit to 0x7FFF

4:	ldi	R_M1,0x80
	cpi	r24,0
	cpc	r25,R_M1	; check overflow (compare 0x8000)
	brcs	5f		; number is OK
	ldi	r24,0xff
	ldi	r25,0x7f	; limit number to 0x7FFF
5:	ret

; ----------------------------------------------------------------------------
;            Get unsigned integer number dword (rounded towards zero)
; ----------------------------------------------------------------------------
; OUTPUT: R27:R26:R25:R24 = unsigned integer
;	  R_M3 = negative flag (0 or B7)
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------

.global CalcUnstackD
CalcUnstackD:

; ------ round pre-correction
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10
	rcall	CalcPreCor

; ---- fetch number from stack and delete it
; OUTPUT: R_M1..R_M10 = number
; DESTROYS: R30, R31
; CALCULATOR STACK: -1
	rcall	CalcFetch

; ----- check minimal exponent: number is zero or < 1

	clr	r27		; clear result HIGH
	clr	r26
	clr	r25
	clr	r24		; clear result LOW

	subi	R_M2,lo8(EXP_BIAS) ; minimal exponent
	sbci	R_M1,hi8(EXP_BIAS) ; check value < 1 (including zero)
	brcs	CalcUnstackD7	; number is zero or < 1
	; R_M1:R_M2 = exponent 0..32767

; ----- get mantissa high and restore hidden bit '1' -> R27:R26:R25:R24

	movw	r26,R_M4
	movw	r24,R_M6	; get first 4 bytes of mantissa R_M3:R_M4:R_M5:R_M6
	ori	r27,B7		; set implied hidden bit '1'

; ----- check maximal exponent

	subi	R_M2,lo8(32)
	sbci	R_M1,hi8(32)	; subtract max. exponent
	brcc	CalcUnstackD8	; overflow exponent
	; R_M1:R_M2 = exponent -32..-1

; ----- number of shifts to normalize

	com	R_M2		; negate and decrement exponent -> value 0..31
	breq	CalcUnstackD7	; already maximal exponent 0

; ----- normalize mantissa

CalcUnstackD4:
	lsr	r27		; rotate mantissa HIGH right
	ror	r26
	ror	r25
	ror	r24		; rotate mantissa LOW right
	dec	R_M2		; decrement exponent
	brne	CalcUnstackD4	; normalize

; ----- result is OK

CalcUnstackD7:
	clc			; clear carry flag (=OK)
	rjmp	CalcUnstackD9

; ----- overflow

CalcUnstackD8:
	ldi	r24,0xff	; max. value
	ldi	r25,0xff
	ldi	r26,0xff
	ldi	r27,0xff
	sec			; set carry flag (=overflow)

; ----- check sign

CalcUnstackD9:
	andi	R_M3,B7		; check negative flag (set Z = number is positive or 0); C flag stays unchanged
;CalcUnstackD10:
	ret

; ----------------------------------------------------------------------------
;                        Exchange literal pointer and Z
; ----------------------------------------------------------------------------
; INPUT/OUTPUT: R31:R30, R_LITH:R_LITL
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcLitExc
CalcLitExc:
	eor	r30,R_LITL	; R30 ^ LITL
	eor	R_LITL,r30	; R30
	eor	r30,R_LITL	; LITL

	eor	r31,R_LITH	; R31 ^ LITH
	eor	R_LITH,r31	; R31
	eor	r31,R_LITH	; LITH
	ret

; ----------------------------------------------------------------------------
;                       Load next literal
; ----------------------------------------------------------------------------
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
;	 R24 = next literal
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcLit
CalcLit:
; INPUT/OUTPUT: R31:R30, R_LITH:R_LITL
; DESTROYS: -
	rcall	CalcLitExc	; exchange literal pointer and Z	
	lpm	r24,Z+		; R24 <- load next literal
; INPUT/OUTPUT: R31:R30, R_LITH:R_LITL
; DESTROYS: -
	rcall	CalcLitExc	; exchange literal pointer and Z	
	ret
