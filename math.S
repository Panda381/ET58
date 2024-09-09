; ****************************************************************************
;
;                           Base mathematics
;
; ****************************************************************************

#include "include.inc"

	.text

; ----------------------------------------------------------------------------
;                              Negate word
; ----------------------------------------------------------------------------
; INPUT/OUTPUT: R25:R24 = number to negate
; DESTROYS: -
; ----------------------------------------------------------------------------

.global NegW
NegW:
	com	r25
	neg	r24
	sbci	r25,0xff
	ret

; ----------------------------------------------------------------------------
;            Divide unsigned BYTE by 10, result is BYTE
; ----------------------------------------------------------------------------
; INPUT: R24 = dividend (N0)
; OUTPUT: R24 = quotient (Q0), 0..25
;         R1=0
; DESTROYS: R0
; ----------------------------------------------------------------------------

.global DivB10
DivB10:
	mov	r0,r24
; result will be max. 25, 5 bits, we cas use (8-5)+8=11 bit result, multiply by 2048
	ldi	r24,0xcd	; multiply by 205 = 8*256/10 round up
	mul	r0,r24		; dividend * 8 * 256 / 10
	mov	r24,r1		; dividend * 8 / 10
	lsr	r24
	lsr	r24
	lsr	r24		; dividend / 10
	eor	r1,r1		; R1: register 0
	ret

; DivB10 test
#if 0
	call	DispSetRow2

	clr	r25	; 1 index
	clr	r26	; 10 index
2:	ldi	r27,10	; number of 1 per 10
3:	mov	r24,r25
; INPUT: R24 = dividend (N0)
; OUTPUT: R24 = quotient (Q0), 0..25
;         R1=0
; DESTROYS: R0
	call	DivB10	; divide
	cp	r24,r26
	brne	4f	; err
	inc	r25
	breq	5f	; ok
	dec	r27
	brne	3b
	inc	r26
	rjmp	2b

4:	ldi	r24,'N'	; not
	rjmp	6f

5:	ldi	r24,'A'	; OK
6:	call	DispChar
7:	rjmp	7b
#endif

; ----------------------------------------------------------------------------
;               Multiply unsigned WORD x WORD, result is DWORD
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = 1st multiplier (N1:N0)
;        R23:R22 = 2nd multiplier (N3:N2)
; OUTPUT: R25:R24:R23:R22 = result (M3:M2:M1:M0)
;         R1=0
; DESTROYS: R0
; ----------------------------------------------------------------------------
; Result accumulator: R31:R30:R27:R26

.global MulDWW
MulDWW:

	push	r26
	push	r27
	push	r30
	push	r31

; ----- N0*N2 (level M1:M0) -> R27:R26

	mul	r24,r22
	movw	r26,r0

; ----- N1*N3 (level M3:M2) -> R31:R30

	mul	r25,r23
	movw	r30,r0

; ----- N2*N1 (level M2:M1) add to R31:R30:R27

	mul	r22,r25
	eor	r25,r25
	add	r27,r0
	adc	r30,r1 
	adc	r31,r25

; ----- N3*N0 (level M2:M1) add to R31:R30:R27

	mul	r23,r24
	add	r27,r0
	adc	r30,r1 
	adc	r31,r25

; ----- store result R31:R30:R27:R26 -> R25:R24:R23:R22

	movw	r22,r26
	movw	r24,r30

; ----- R1 <- 0 (set to standard value)

	eor	r1,r1		; R1: register 0

	pop	r31
	pop	r30
	pop	r27
	pop	r26
	ret

; ----------------------------------------------------------------------------
;                                 Shift WORD right
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = operand
;        R22 = shifts (signed, do shifts only if > 0)
; OUTPUT: R25:R24 = result
; DESTROYS: R22
; ----------------------------------------------------------------------------

.global ShrW
ShrW2:	lsr	r25
	ror	r24
ShrW:	dec	r22
	brpl	ShrW2
	ret

; ----------------------------------------------------------------------------
;                        Divide unsigned WORD by 10
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = dividend (N1:N0)
; OUTPUT: R25:R24 = quotient (Q1:Q0), 0..6553
;         R1=0
; DESTROYS: R0
; ----------------------------------------------------------------------------

.global DivW10
DivW10:
	push	r22
	push	r23

; result will be max. 6553, 13 bits, we can use (16-13)+16=19 bit result, multiply by 2^19
	ldi	r22,0xcd	; multiply by 0xCCCD = 52429 = (2^19=524288)/10 round up
	ldi	r23,0xcc
; INPUT: R25:R24 = 1st multiplier (N1:N0)
;        R23:R22 = 2nd multiplier (N3:N2)
; OUTPUT: R25:R24:R23:R22 = result (M3:M2:M1:M0)
;         R1=0
; DESTROYS: R0
	rcall	MulDWW		; multiply word*word->dword

	ldi	r22,3		; number of shits HIGH result = 19 - 16 = 3
; INPUT: R25:R24 = operand
;        R22 = shifts (signed, do shifts only if > 0)
; OUTPUT: R25:R24 = result
; DESTROYS: R22
	rcall	ShrW		; shift result HIGH right >> (19 - 16 =) 3

	pop	r23
	pop	r22
	ret

; ----------------------------------------------------------------------------
;                        Divide unsigned WORD by 100
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = dividend (N1:N0)
; OUTPUT: R25:R24 = quotient (Q1:Q0), 0..655
;         R1=0
; DESTROYS: R0
; ----------------------------------------------------------------------------

.global DivW100
DivW100:
	push	r22
	push	r23

; result will be max. 655, 10 bits, we can use (16-10)+16=22 bit result, multiply by 2^22
	ldi	r22,0xd8	; multiply by 0xA3D8 = 41944 = (2^22=4194304)/100 round up
	ldi	r23,0xa3
; INPUT: R25:R24 = 1st multiplier (N1:N0)
;        R23:R22 = 2nd multiplier (N3:N2)
; OUTPUT: R25:R24:R23:R22 = result (M3:M2:M1:M0)
;         R1=0
; DESTROYS: R0
	rcall	MulDWW		; multiply word*word->dword

	ldi	r22,6		; number of shits HIGH result = 22 - 16 = 6
; INPUT: R25:R24 = operand
;        R22 = shifts (signed, do shifts only if > 0)
; OUTPUT: R25:R24 = result
; DESTROYS: R22
	rcall	ShrW		; shift result HIGH right >> (22 - 16 =) 6

	pop	r23
	pop	r22
	ret

; ----------------------------------------------------------------------------
;              Multiply unsigned WORD x 10, result is WORD
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = multiplier (N1:N0)
; OUTPUT: R25:R24 = result (M1:M0)
;         R1=0
; DESTROYS: R0
; ----------------------------------------------------------------------------

.global MulW10
MulW10:
	push	r22
	ldi	r22,10
; INPUT: R25:R24 = 1st multiplier (N1:N0)
;        R22 = 2nd multiplier (N2)
; OUTPUT: R25:R24 = result (M1:M0)
;         R1=0
; DESTROYS: R0
	rcall	MulWB
	pop	r22
	ret

; ----------------------------------------------------------------------------
;             Multiply unsigned WORD x BYTE, result is WORD
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = 1st multiplier (N1:N0)
;        R22 = 2nd multiplier (N2)
; OUTPUT: R25:R24 = result (M1:M0)
;         R1=0
; DESTROYS: R0
; ----------------------------------------------------------------------------

.global MulWB
MulWB:

	push	r18
	push	r19

; ----- save 1st multiplier to R19:R18

	movw	r18,r24

; ----- N0*N2 (level M1:M0) -> R24:R25

	mul	r22,r18
	movw	r24,r0

; ----- N1*N2 (level M1) add to R25

	mul	r22,r19
	add	r25,r0

; ----- R1 <- 0 (set to standard value)

	clr	r1	; restore R1
	pop	r19
	pop	r18
	ret

; ----------------------------------------------------------------------------
;            Divide unsigned WORD by BYTE, result is BYTE
;          - Highest byte of dividend must be smaller than divisor.
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = dividend (N1:N0)
;        R22 = divisor (D0)
; OUTPUT: R24 = quotient (Q0)
; DESTROYS: R25
; ----------------------------------------------------------------------------

#if 0
.global DivWBB
DivWBB:

	push	r31

; ----- number of loops

	ldi	r31,8

; ----- shift dividend LOW left, get highest bit

	add	r24,r24

; ----- shift dividend HIGH left (on input: carry from dividend LOW)

DivWBB2:adc	r25,r25
	brcs	DivWBB3

; ----- compare dividend HIGH with divisor

	cp	r25,r22
	brcs	DivWBB4		; skip if dividend HIGH < divisor

; ----- subtract divisor from dividend HIGH (only in case if dividend HIGH >= divisor)

DivWBB3:sub	r25,r22
	clc

; ----- shift dividend LOW left (add Carry on input if dividend HIGH < divisor)

DivWBB4:adc	r24,r24

; ----- next loop

	dec	r31
	brne	DivWBB2

; ----- invert quotient bits

	com	r24

	pop	r31
	ret
#endif

; ----------------------------------------------------------------------------
;                          Multiply 2 mantissas
; ----------------------------------------------------------------------------
; INPUT: R_M3..R_M10 = 1st multiplier
;	 R_N3..R_N10 = 2nd multiplier
; OUTPUT: R_M3..R_M10, R_M11 = result
;	  R1 = 0
; DESTROYS: R_A3 (R31), R_A4 (R30), R_A7 (R27), R_A8 (R26), R0
; ----------------------------------------------------------------------------
; Accumulator: R_A3..R_A10, Temporary: R_T3..R_T8 and R1:R0

.global MulMant
MulMant:

; ----- push registers

	push	R_A5
	push	R_A6
	push	R_A9
	push	R_A10
	push	R_T3
	push	R_T4
	push	R_T5
	push	R_T6
	push	R_T7
	push	R_T8

; ----- prepare loop counter

	ldi	R_A3,MANT_BYTES	; size of mantissa in number of bytes
	mov	r1,R_A3

; ----- clear accumulator R_A3..R_A10

	clr	R_A3
	clr	R_A4
	movw	R_A6,R_A4
	movw	R_A8,R_A4
	movw	R_A10,R_A4

; ----- save loop counter and extra result

MulMant2:
	push	r1		; loop counter
	push	R_M11		; extra result

; ----- R_M10 * even -> temporary

	mul	R_M10,R_N4
	movw	R_T4,r0

	mul	R_M10,R_N6
	movw	R_T6,r0

	mul	R_M10,R_N8
	movw	R_T8,r0

	mul	R_M10,R_N10

; ----- add temporary to accumulator

	add	R_A10,r0
	adc	R_A9,r1
	adc	R_A8,R_T8
	adc	R_A7,R_T7
	adc	R_A6,R_T6
	adc	R_A5,R_T5
	adc	R_A4,R_T4
	adc	R_A3,R_T3
	
; ----- save extra result

	pop	r0		; destroy old extra result
	push	R_A10		; save new extra result

; ----- rotate accumulator right

	mov	R_A10,R_A9
	mov	R_A9,R_A8
	mov	R_A8,R_A7
	mov	R_A7,R_A6
	mov	R_A6,R_A5
	mov	R_A5,R_A4
	mov	R_A4,R_A3

; ----- carry to new highest byte

	ldi	R_A3,0
	adc	R_A3,R_A3	; R_A3 <- carry 0 or 1

; ----- R_M10 * odd -> temporary

	mul	R_M10,R_N3
	movw	R_T4,r0

	mul	R_M10,R_N5
	movw	R_T6,r0

	mul	R_M10,R_N7
	movw	R_T8,r0

	mul	R_M10,R_N9

; ----- add temporary to accumulator (no output carry)

	add	R_A10,r0
	adc	R_A9,r1
	adc	R_A8,R_T8
	adc	R_A7,R_T7
	adc	R_A6,R_T6
	adc	R_A5,R_T5
	adc	R_A4,R_T4
	adc	R_A3,R_T3

; ----- rotate M right

	mov	R_M10,R_M9
	mov	R_M9,R_M8
	mov	R_M8,R_M7
	mov	R_M7,R_M6
	mov	R_M6,R_M5
	mov	R_M5,R_M4
	mov	R_M4,R_M3

; ----- loop counter (-> R1 = 0)

	pop	R_M11		; extra result
	pop	r1		; loop counter
	dec	r1
	brne	MulMant2	; next loop

; ----- move accumulator to result (here is R_M11 extra result, R1 = 0)

	movw	R_M10,R_A10
	movw	R_M8,R_A8
	movw	R_M6,R_A6
	movw	R_M4,R_A4

; ----- pop registers

	pop	R_T8
	pop	R_T7
	pop	R_T6
	pop	R_T5
	pop	R_T4
	pop	R_T3
	pop	R_A10
	pop	R_A9
	pop	R_A6
	pop	R_A5
	ret

; ----------------------------------------------------------------------------
;    Multiply unsigned DWORD x DWORD, result is DWORD (ignore high DWORD)
; ----------------------------------------------------------------------------
; INPUT: R25:R24:R23:R22 = 1st multiplier (N3:N2:N1:N0)
;        R21:R20:R19:R18 = 2nd multiplier (N7:N6:N5:N4)
; OUTPUT: R25:R24:R23:R22 = result (M3:M2:M1:M0)
;         R1=0
; DESTROYS: R31, R30, R27, R26, R0
; ----------------------------------------------------------------------------
; accumulator: R31:R30:R27:R26

.global MulDD
MulDD:

; ----- N0*N4 (level M1:M0) -> (R31:R30:)R27:R26

	mul	r22,r18
	movw	r26,r0

; ----- N1*N5 (level M3:M2) -> R31:R30(:R27:R26)

	mul	r23,r19
	movw	r30,r0

; ----- N2*N4 (level M3:M2) add to R31:R30(:R27:R26)

	mul	r24,r18
	add	r30,r0
	adc	r31,r1

; ----- N0*N6 (level M3:M2) add to R31:R30(:R27:R26)

	mul	r22,r20
	add	r30,r0
	adc	r31,r1

; ----- N3*N4 (level M3) add to R31

	mul	r25,r18
	add	r31,r0

; ----- N2*N5 (level M3) add to R31

	mul	r24,r19
	add	r31,r0

; ----- N1*N6 (level M3) add to R31

	mul	r23,r20
	add	r31,r0

; ----- N0*N7 (level M3) add to R31

	mul	r22,r21
	add	r31,r0

; ----- R25 <- 0 (N3 no more needed)

	eor	r25,r25

; ----- N1*N4 (level M2:M1) add to R31:R30:R27

	mul	r23,r18
	add	r27,r0
	adc	r30,r1
	adc	r31,r25

; ----- N0*N5 (level M2:M1) add to R31:R30:R27

	mul	r22,r19
	add	r27,r0
	adc	r30,r1
	adc	r31,r25

; ----- store result R31:R30:R27:R26 -> R25:R24:R23:R22

	movw	r22,r26
	movw	r24,r30

; ----- R1 <- 0 (set to standard value)

	eor	r1,r1
	ret

; ----------------------------------------------------------------------------
;               Divide unsigned DWORD by WORD, result is WORD
;          - Highest word of dividend must be smaller than divisor.
; ----------------------------------------------------------------------------
; INPUT: R25:R24:R23:R22 = dividend (N3:N2:N1:N0)
;        R21:R20 = divisor (D1:D0)
; OUTPUT: R25:R24 = quotient (Q1:Q0)
; DESTROYS: R31, R23, R22
; ----------------------------------------------------------------------------

.global DivDWW
DivDWW:	

; ----- number of loops

	ldi	r31,16

; ----- shift dividend LOW left

	add	r22,r22
	adc	r23,r23

; ----- shift dividend HIGH left (on input: carry from dividend LOW)

DivDWW2:adc	r24,r24
	adc	r25,r25
	brcs	DivDWW3

; ----- compare dividend HIGH with divisor

	cp	r24,r20
	cpc	r25,r21
	brcs	DivDWW4		; skip if dividend HIGH < divisor

; ----- subtract divisor from dividend HIGH (only in case if dividend HIGH >= divisor)

DivDWW3:sub	r24,r20
	sbc	r25,r21
	clc

; ----- shift dividend LOW left (add Carry on input if dividend HIGH < divisor)

DivDWW4:adc	r22,r22
	adc	r23,r23

; ----- next loop

	dec	r31
	brne	DivDWW2

; ----- invert quotient bits

	com	r22
	com	r23

; ----- get result

	movw	r24,r22
	ret

; ----------------------------------------------------------------------------
;          Divide unsigned DWORD by BYTE, result is DWORD
; ----------------------------------------------------------------------------
; INPUT: R25:R24:R23:R22 = dividend (N3:N2:N1:N0)
;        R20 = divisor (D0)
;        R1=0
; OUTPUT: R25:R24:R23:R22 = quotient (Q3:Q2:Q1:Q0)
; DESTROYS: R31, R26
; ----------------------------------------------------------------------------

.global DivD10
DivD10:
	ldi	r20,10

; ----- number of loops

.global DivDB
DivDB:	ldi	r31,32

; ----- clear dividend HIGH R26

	sub	r26,r26

; ----- shift dividend LOW left

	add	r22,r22
	adc	r23,r23
	adc	r24,r24
	adc	r25,r25

; ----- shift dividend HIGH left (on input: carry from dividend LOW)
; 12 or 13 clock cycles per loop, total 383 to 415 clock cycles

DivDB2:	adc	r26,r26
	brcs	DivDB3

; ----- compare dividend HIGH with divisor

	cp	r26,r20
	brcs	DivDB4		; skip if dividend HIGH < divisor

; ----- subtract divisor from dividend HIGH (only in case if dividend HIGH >= divisor)

DivDB3:	sub	r26,r20
	clc

; ----- shift dividend LOW left (add Carry on input if dividend HIGH < divisor)

DivDB4:	adc	r22,r22
	adc	r23,r23
	adc	r24,r24
	adc	r25,r25

; ----- next loop

	dec	r31
	brne	DivDB2

; ----- invert quotient bits

	com	r22
	com	r23
	com	r24
	com	r25
	ret

; ----------------------------------------------------------------------------
;            Multiply unsigned DWORD x 10, result is DWORD
; ----------------------------------------------------------------------------
; INPUT: R25:R24:R23:R22 = multiplier (N3:N2:N1:N0)
; OUTPUT: R25:R24:R23:R22 = result (M3:M2:M1:M0)
;         R1=0
; DESTROYS: R27, R26, R20, R0
; ----------------------------------------------------------------------------

.global MulD10
MulD10:	ldi	r20,10

; MulDB must follow

; ----------------------------------------------------------------------------
;          Multiply unsigned DWORD x BYTE, result is DWORD
; ----------------------------------------------------------------------------
; INPUT: R25:R24:R23:R22 = 1st multiplier (N3:N2:N1:N0)
;        R20 = 2nd multiplier (N4)
; OUTPUT: R25:R24:R23:R22 = result (M3:M2:M1:M0)
;         R1=0
; DESTROYS: R27, R26, R0
; ----------------------------------------------------------------------------

; ----- N2*N4 (level M3:M2) -> R27:R26

.global MulDB
MulDB:	mul	r24,r20
	movw	r26,r0

; ----- N3*N4 (level M3) add to R27

	mul	r25,r20
	add	r27,r0

; ----- save HIGH result to R25:R24

	movw	r24,r26

; ----- set N1:N0 to R27:R26

	movw	r26,r22

; ----- N0:N4 (level M1:M0) -> R23:R22

	mul	r26,r20
	movw	r22,r0

; ----- R26 <- 0

	eor	r26,r26

; ----- N1*N4 (level M2:M1) add to R25:R24:R23

	mul	r27,r20
	add	r23,r0
	adc	r24,r1
	adc	r25,r26

; ----- R1 <- 0 (set to standard value)

	eor	r1,r1
	ret
