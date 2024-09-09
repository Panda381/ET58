; ****************************************************************************
;
;                                Execute functions
;
; ****************************************************************************

#include "include.inc"

	.text

.global _Disp
_Disp: jmp Disp

.global __EditStop
__EditStop:
	jmp	EditStop

; ----------------------------------------------------------------------------
;                           ln x (0x23)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecLnx
ExecLnx:

	breq	1f		; no INV

	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_EXP		; exp x
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

1:
	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_LN		; ln x
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                           log (0x28)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecLog
ExecLog:

	breq	1f		; no INV

	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_EXP10		; exp10 x
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

1:
	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_LOG10		; log10 x
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                           log2 (0x2C)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecLg2
ExecLg2:

	breq	1f		; no INV

	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_EXP2		; exp2 x
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

1:
	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_LOG2		; log2 x
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                          random rnd (0x2d)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecRnd
ExecRnd:

	breq	1f		; no INV

	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_RAND		; random number
	.byte	C_GETMEM(REG_X)	; load X into stack
	.byte	C_MUL		; multiply
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----- calculate random number 0..1

1:
	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_RAND		; random number
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                           tan (0x30)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecTan
ExecTan:

	breq	1f		; no INV

	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_ATN		; atan x
	.byte	C_FROMRAD	; angle from radians
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

1:	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_TORAD		; angle to radians
	.byte	C_TAN		; tan x
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                           x^2 (0x33)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecX2
ExecX2:

	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_SQR		; x^2
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                           Vx (0x34)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecVx
ExecVx:

	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_SQRT		; Vx
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                           1/x (0x35)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global Exec1x
Exec1x:

	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_REC		; 1/x
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                           sin (0x38)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecSin
ExecSin:

	breq	1f		; no INV

	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_ASN		; asin x
	.byte	C_FROMRAD	; angle from radians
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

1:	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_TORAD		; angle to radians
	.byte	C_SIN		; sin x
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                           cos (0x39)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecCos
ExecCos:

	breq	1f		; no INV

	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_ACS		; acos x
	.byte	C_FROMRAD	; angle from radians
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

1:	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_TORAD		; angle to radians
	.byte	C_COS		; cos x
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                           |x| (0x50)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecAbs
ExecAbs:

	; INV is set - sign
	brne	ExecSign	; INV is set

	rcall	__EditStop	; stop edit mode

	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_ABS		; abs x
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all


.global ExecSign
ExecSign:
	rcall	__EditStop	; stop edit mode and set X valid

	; sign X
	SET_XVALID		; set register X valid
	rcall	Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_SGN		; sign X
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                           Int (0x59)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecInt
ExecInt:
	breq	1f		; not INV

; ----- INV, fraction

	rcall	__EditStop	; stop edit mode
	rcall	Calc
; offset 0
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_DUP		; duplicate
	.byte	C_TRUNC		; trunc x
	.byte	C_SUB		; subtract
	.byte	C_JMP		; jump
	.byte	6		; jump to offset 12 (12-6=6)
; offset 6
	.balign 2
; offset 6

; ----- not INV, integer

1:	rcall	__EditStop	; stop edit mode
	rcall	Calc
; offset 0 (10)
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_TRUNC		; trunc x
; offset 2 (12)
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                           Round (0x5d)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecRound
ExecRound:

	brne	4f		; INV flag set

; ----- not INV, calculate round(x)

	rcall	__EditStop	; stop edit mode
	rcall	Calc
; offset 0
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_ROUND		; round
	.byte	C_JMP		; jump
	.byte	8		; jump to offset 12 (12-4=8)
; offset 4

; ----- INV, fractional of floor(x)

4:	rcall	__EditStop	; stop edit mode
	rcall	Calc
; offset 0 (8)
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_FLOOR		; round down (x,floor(x))
	.byte	C_SUB		; difference 0..1 (x-floor(x))
; offset 4 (12)
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END		; end
	.balign 2		; align
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                           sinh (0x3C)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecSinH
ExecSinH:

	breq	1f		; no INV

	; INV - arsh(x) = ln(x + sqrt(x^2 + 1))
	rcall	__EditStop	; stop edit mode
	rcall	Calc
; offset 0
	.byte	C_GETMEM(REG_X) ; load X into stack (x)
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_SQR		; square (x,x^2)
	.byte	C_INC		; increment (x,x^2+1)
	.byte	C_SQRT		; square root (x,sqrt(x^2+1))
	.byte	C_ADD		; add (x+sqrt(x^2+1))
	.byte	C_LN		; logarithm (y)
	.byte	C_JMP		; jump
	.byte	11		; jump to offset 20 (20-9=11)
; offset 9
	.balign 2
; offset 10

	; not INV: sinh(x) = (e^x - e^-x)/2
1:	rcall	__EditStop	; stop edit mode
	rcall	Calc
; offset 0 (14)
	.byte	C_GETMEM(REG_X) ; load X into stack (x)
	.byte	C_EXP		; exponent (e)
	.byte	C_DUP		; duplicate (e,e)
	.byte	C_REC		; reciprocal value (e,1/e)
	.byte	C_SUB		; subtract (e-1/e)
	.byte	C_DIV2		; divide/2 ((e-1/e)/2)
; offset 6 (20)
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all
                
; ----------------------------------------------------------------------------
;                           cosh (0x3D)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecCosH
ExecCosH:

	breq	1f		; no INV

	; INV - arch(x) = ln(x + sqrt(x^2 - 1))
	rcall	__EditStop	; stop edit mode
	rcall	Calc
; offset 0
	.byte	C_GETMEM(REG_X) ; load X into stack (x)
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_SQR		; square (x,x^2)
	.byte	C_DEC		; decrement (x,x^2-1)
	.byte	C_SQRT		; square root (x,sqrt(x^2-1))
	.byte	C_ADD		; add (x+sqrt(x^2-1))
	.byte	C_LN		; logarithm (y)
	.byte	C_JMP		; jump
	.byte	11		; jump to offset 20 (20-9=11)
; offset 9
	.balign 2
; offset 10

	; not INV: cosh(x) = (e^x + e^-x)/2
1:	rcall	__EditStop	; stop edit mode
	rcall	Calc
; offset 0 (14)
	.byte	C_GETMEM(REG_X) ; load X into stack (x)
	.byte	C_EXP		; exponent (e)
	.byte	C_DUP		; duplicate (e,e)
	.byte	C_REC		; reciprocal value (e,1/e)
	.byte	C_ADD		; add (e+1/e)
	.byte	C_DIV2		; divide/2 ((e+1/e)/2)
; offset 6 (20)
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                           tanh (0x3E)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecTanH
ExecTanH:

	breq	1f		; no INV

	; INV - arth(x) = ln((1 + x)/(1 - x))/2
	rcall	__EditStop	; stop edit mode
	rcall	Calc
; offset 0
	.byte	C_GETMEM(REG_X) ; load X into stack (x)
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_INC		; increment (x,x+1)
	.byte	C_EXC		; exchange (x+1,x)
	.byte	C_DEC		; decrement (x+1,x-1)
	.byte	C_NEG		; negate (1+x,1-x)
	.byte	C_DIV		; divide ((1+x)/(1-x))
	.byte	C_LN		; logarithm (ln((1+x)/(1-x)))
	.byte	C_DIV2		; divide/2
	.byte	C_JMP		; jump
	.byte	13		; jump to offset 24 (24-11=13)
; offset 11
	.balign 2
; offset 12

	; not INV: tanh(x) = (e^2x - 1) / (e^2x + 1)
1:	rcall	__EditStop	; stop edit mode
	rcall	Calc
; offset 0 (16)
	.byte	C_GETMEM(REG_X) ; load X into stack (x)
	.byte	C_MUL2		; multiply*2 (x*2)
	.byte	C_EXP		; exponent (e^2x)
	.byte	C_DUP		; duplicate (e,e)
	.byte	C_DEC		; decrement (e,e-1)
	.byte	C_EXC		; exchange (e-1,e)
	.byte	C_INC		; increment (e-1,e+1)
	.byte	C_DIV		; divide (y)
; offset 8 (24)
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	_Disp		; display all
