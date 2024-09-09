; ****************************************************************************
;
;                        Calculator mantissa operations
;
; ****************************************************************************

#include "include.inc"

	.text

; ----------------------------------------------------------------------------
;                     Shift mantissa left (to higher bits)
; ----------------------------------------------------------------------------
; INPUT: R_M3..R_M10 mantissa
;	 C = input carry
; OUTPUT: R_M3..R_M10 mantissa shifted left
;	 C = output carry
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcMantRol
CalcMantRol:
	rol	R_M10
	rol	R_M9
	rol	R_M8
	rol	R_M7
	rol	R_M6
	rol	R_M5
	rol	R_M4
	rol	R_M3
	ret

; ----------------------------------------------------------------------------
;                  Shift mantissa right (to lower bits)
; ----------------------------------------------------------------------------
; INPUT: R_M3..R_M10 mantissa
;	 C = input carry
; OUTPUT: R_M3..R_M10 mantissa shifted right
;	 C = output carry
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcMantRor
CalcMantRor:
	ror	R_M3
	ror	R_M4
	ror	R_M5
	ror	R_M6
	ror	R_M7
	ror	R_M8
	ror	R_M9
	ror	R_M10
	ret

; ----------------------------------------------------------------------------
;                           Add mantissas
; ----------------------------------------------------------------------------
; INPUT: R_M3..R_M10 mantissa 1
;	 R_N3..R_N10 mantissa 2
; OUTPUT: R_M3..R_M10 result
;	  C = output carry
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcMantAdd
CalcMantAdd:
	add	R_M10,R_N10
	adc	R_M9,R_N9
	adc	R_M8,R_N8
	adc	R_M7,R_N7
	adc	R_M6,R_N6
	adc	R_M5,R_N5
	adc	R_M4,R_N4
	adc	R_M3,R_N3
	ret

; ----------------------------------------------------------------------------
;                           Subtract mantissas
; ----------------------------------------------------------------------------
; INPUT: R_M3..R_M10 mantissa 1
;	 R_N3..R_N10 mantissa 2
; OUTPUT: R_M3..R_M10 result
;	  C = output borrow
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcMantSub
CalcMantSub:
	sub	R_M10,R_N10
	sbc	R_M9,R_N9
	sbc	R_M8,R_N8
	sbc	R_M7,R_N7
	sbc	R_M6,R_N6
	sbc	R_M5,R_N5
	sbc	R_M4,R_N4
	sbc	R_M3,R_N3
	ret

; ----------------------------------------------------------------------------
;                           OR mantissas
; ----------------------------------------------------------------------------
; INPUT: R_M3..R_M10 mantissa 1
;	 R_N3..R_N10 mantissa 2
; OUTPUT: R_M3..R_M10 result
;	  C = output borrow
; DESTROYS: -
; ----------------------------------------------------------------------------

#if 0
.global CalcMantOr
CalcMantOr:
	or	R_M10,R_N10
	or	R_M9,R_N9
	or	R_M8,R_N8
	or	R_M7,R_N7
	or	R_M6,R_N6
	or	R_M5,R_N5
	or	R_M4,R_N4
	or	R_M3,R_N3
	ret

; ----------------------------------------------------------------------------
;                           AND mantissas
; ----------------------------------------------------------------------------
; INPUT: R_M3..R_M10 mantissa 1
;	 R_N3..R_N10 mantissa 2
; OUTPUT: R_M3..R_M10 result
;	  C = output borrow
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcMantAnd
CalcMantAnd:
	and	R_M10,R_N10
	and	R_M9,R_N9
	and	R_M8,R_N8
	and	R_M7,R_N7
	and	R_M6,R_N6
	and	R_M5,R_N5
	and	R_M4,R_N4
	and	R_M3,R_N3
	ret

; ----------------------------------------------------------------------------
;                           XOR mantissas
; ----------------------------------------------------------------------------
; INPUT: R_M3..R_M10 mantissa 1
;	 R_N3..R_N10 mantissa 2
; OUTPUT: R_M3..R_M10 result
;	  C = output borrow
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcMantXor
CalcMantXor:
	eor	R_M10,R_N10
	eor	R_M9,R_N9
	eor	R_M8,R_N8
	eor	R_M7,R_N7
	eor	R_M6,R_N6
	eor	R_M5,R_N5
	eor	R_M4,R_N4
	eor	R_M3,R_N3
	ret
#endif

; ----------------------------------------------------------------------------
;                      SBC R_M9..R_3,R_ZERO
; ----------------------------------------------------------------------------
; INPUT: R_M3..R_M9 mantissa
;	 R_ZERO = subtractes register
;	 C = input borrow
; OUTPUT: R_M3..R_M9 result
;	  C = output borrow
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcMantSbc0
CalcMantSbc0:
	sbc	R_M9,R_ZERO
	sbc	R_M8,R_ZERO
	sbc	R_M7,R_ZERO
	sbc	R_M6,R_ZERO
	sbc	R_M5,R_ZERO
	sbc	R_M4,R_ZERO
	sbc	R_M3,R_ZERO
	ret

; ----------------------------------------------------------------------------
;                         Increment mantissa
; ----------------------------------------------------------------------------
; INPUT: R_M3..R_M10 = mantissa
;	 R_ZERO = 0
; OUTPUT: returns Z flag if result is 0 (overflow from 0xFF 0xFF 0xFF...)
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcMantInc
CalcMantInc:
	push	R_ZERO
	dec	R_ZERO		; R_ZERO <- 0xff, subtracted number = -1 (= add +1)
	sub	R_M10,R_ZERO
; INPUT: R_M3..R_M9 mantissa
;	 R_ZERO = subtractes register
;	 C = input borrow
; OUTPUT: R_M3..R_M9 result
;	  C = output borrow
; DESTROYS: -
	rcall	CalcMantSbc0	; SBC R_M9..R_3,R_ZERO
	pop	R_ZERO
	ret

; ----------------------------------------------------------------------------
;                         Complement mantissa
; ----------------------------------------------------------------------------
; INPUT/OUTPUT: R_M3..(R_M9) R_M10 = mantissa
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcMantNot
CalcMantNot:
	com	R_M10

.global CalcMantNot2
CalcMantNot2:
	com	R_M9
	com	R_M8
	com	R_M7
	com	R_M6
	com	R_M5
	com	R_M4
	com	R_M3
	ret

; ----------------------------------------------------------------------------
;                       Negate extended mantissa
; ----------------------------------------------------------------------------
; INPUT: R_M2..R_M10 extended mantissa
;	 R_ZERO = 0
; OUTPUT: R_M2..R_M10 extended mantissa negated
;	  CY = carry set if result is not 0
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcMantNeg
CalcMantNeg:
	dec	R_ZERO		; R_ZERO <- 0xff

; Complement: here we get number -1 - X, but we need 0 - X, so we must add +1 later

	; complement mantissa (0xff -> 0x00, we'll get -1 - X)
	com	R_M2
; INPUT/OUTPUT: R_M3..(R_M9) R_M10 = mantissa
; DESTROYS: -
	rcall	CalcMantNot2	; complement mantissa

	; negate lowest byte of mantissa: complement R_M10 and add 1 (<>0 -> CY, 0 -> NC)
	neg	R_M10		; carry will be set if number was NOT 0 (R_M10 = 0 - R_M10, CARRY <- (R_M10 != 0))

	; add +1 (sub -1) with carry from R_M10
; INPUT: R_M3..R_M9 mantissa
;	 R_ZERO = subtractes register
;	 C = input borrow
; OUTPUT: R_M3..R_M9 result
;	  C = output borrow
; DESTROYS: -
	rcall	CalcMantSbc0	; R_Mx + 1 - C
	sbc	R_M2,R_ZERO	; increment if lower byte was 0, set carry if result is NOT 0 (R_M2 = R_M2 - (0xFF + CARRY))

	inc	R_ZERO
	ret
