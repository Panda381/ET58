; ****************************************************************************
;
;                            Execute flags
;
; ****************************************************************************

#include "include.inc"

	.text

; ----------------------------------------------------------------------------
;                               Set flag
; ----------------------------------------------------------------------------
; B0: F_INV ... INV flag
; B1: F_EE ... EE mode (not set together with Eng)
; B2: F_ENG ... Eng mode (not set together with EE)
; B3: F_RESDEC ... restart DecNum function
; B4: F_DP ... decimal point entered
; B5: F_EXP ... entering exponent
; B6: F_INKEY ... waiting input keys
; B7: F_OLDTRACE ... old trace state

; B0: F2_ERRDEC ... overflow error in DecNum function
; B1: F2_OLDERR old error flag during DecNum
; B2: F2_DEBUG debug mode, display HEX mantissa
; B3: F2_OLDRUN old running flag during ExecPr
; B4: F2_DISP_REGT display mode reg T (or flags otherwise)
; B5: F2_DISP_TEXT display mode text (or T/flags otherwise, reset by CLR)

; set flag INV
; DESTROYS: -
.global FlagSetInv
FlagSetInv:
	push	r25
	ldi	r25,BIT(F_INV)
FlagSet:
	push	r24
	ldd	r24,Y+DATA_FLAGS
	or	r24,r25
	std	Y+DATA_FLAGS,r24
	pop	r24
	pop	r25
	ret

; set flag 'EE mode'
; DESTROYS: -
.global FlagSetEE
FlagSetEE:
	push	r25
	ldi	r25,BIT(F_EE)
	rjmp	FlagSet

; set flag 'Eng mode'
; DESTROYS: -
.global FlagSetEng
FlagSetEng:
	push	r25
	ldi	r25,BIT(F_ENG)
	rjmp	FlagSet

; set flag 'restart DecNum'
; DESTROYS: -
.global FlagSetResDec
FlagSetResDec:
	push	r25
	ldi	r25,BIT(F_RESDEC)
	rjmp	FlagSet

; set flag 'decimal point'
; DESTROYS: -
.global FlagSetDP
FlagSetDP:
	push	r25
	ldi	r25,BIT(F_DP)
	rjmp	FlagSet

; set flag 'exponent'
; DESTROYS: -
.global FlagSetExp
FlagSetExp:
	push	r25
	ldi	r25,BIT(F_EXP)
	rjmp	FlagSet

; set flag 'input keys'
; DESTROYS: -
.global FlagSetInKey
FlagSetInKey:
	push	r25
	ldi	r25,BIT(F_INKEY)
	rjmp	FlagSet

; set flag 'old trace' (served in DispTrace)
; DESTROYS: -
;.global FlagSetOldTrace
;FlagSetOldTrace:
;	push	r25
;	ldi	r25,BIT(F_OLDTRACE)
;	rjmp	FlagSet

; set flag ErrDec
; DESTROYS: -
.global FlagSetErrDec
FlagSetErrDec:
	push	r25
	ldi	r25,BIT(F2_ERRDEC)
FlagSet2:
	push	r24
	ldd	r24,Y+DATA_FLAGS2
	or	r24,r25
	std	Y+DATA_FLAGS2,r24
	pop	r24
	pop	r25
	ret

; set flag OldErr
; DESTROYS: -
.global FlagSetOldErr
FlagSetOldErr:
	push	r25
	ldi	r25,BIT(F2_OLDERR)
	rjmp	FlagSet2

; set flag Debug
; DESTROYS: -
.global FlagSetDebug
FlagSetDebug:
	push	r25
	ldi	r25,BIT(F2_DEBUG)
	rjmp	FlagSet2

; set flag OldRun
; DESTROYS: -
.global FlagSetOldRun
FlagSetOldRun:
	push	r25
	ldi	r25,BIT(F2_OLDRUN)
	rjmp	FlagSet2

; set flag DispRegT
; DESTROYS: -
.global FlagSetDispRegT
FlagSetDispRegT:
	push	r25
	ldi	r25,BIT(F2_DISP_REGT)
	rjmp	FlagSet2

; set flag DispText
; DESTROYS: -
.global FlagSetDispText
FlagSetDispText:
	push	r25
	ldi	r25,BIT(F2_DISP_TEXT)
	rjmp	FlagSet2

; ----------------------------------------------------------------------------
;                               Clear flag
; ----------------------------------------------------------------------------

; clear flag INV
; DESTROYS: -
.global FlagClrInv
FlagClrInv:
	push	r25
	ldi	r25,~BIT(F_INV)
FlagClr:
	push	r24
	ldd	r24,Y+DATA_FLAGS
	and	r24,r25
	std	Y+DATA_FLAGS,r24
	pop	r24
	pop	r25
	ret

; clear flag 'EE mode'
; DESTROYS: -
.global FlagClrEE
FlagClrEE:
	push	r25
	ldi	r25,~BIT(F_EE)
	rjmp	FlagClr

; clear flag 'Eng mode'
; DESTROYS: -
.global FlagClrEng
FlagClrEng:
	push	r25
	ldi	r25,~BIT(F_ENG)
	rjmp	FlagClr

; clear flag 'restart DecNum'
; DESTROYS: -
.global FlagClrResDec
FlagClrResDec:
	push	r25
	ldi	r25,~BIT(F_RESDEC)
	rjmp	FlagClr

; clear flag 'decimal point'
; DESTROYS: -
.global FlagClrDP
FlagClrDP:
	push	r25
	ldi	r25,~BIT(F_DP)
	rjmp	FlagClr

; clear flag 'exponent'
; DESTROYS: -
.global FlagClrExp
FlagClrExp:
	push	r25
	ldi	r25,~BIT(F_EXP)
	rjmp	FlagClr

; clear flag 'input keys'
; DESTROYS: -
.global FlagClrInKey
FlagClrInKey:
	push	r25
	ldi	r25,~BIT(F_INKEY)
	rjmp	FlagClr

; clear flag 'old trace' (served in DispTrace)
; DESTROYS: -
;.global FlagClrOldTrace
;FlagClrOldTrace:
;	push	r25
;	ldi	r25,~BIT(F_OLDTRACE)
;	rjmp	FlagClr

; clear flag ErrDec
; DESTROYS: -
.global FlagClrErrDec
FlagClrErrDec:
	push	r25
	ldi	r25,~BIT(F2_ERRDEC)
FlagClr2:
	push	r24
	ldd	r24,Y+DATA_FLAGS2
	and	r24,r25
	std	Y+DATA_FLAGS2,r24
	pop	r24
	pop	r25
	ret

; clear flag OldErr
; DESTROYS: -
.global FlagClrOldErr
FlagClrOldErr:
	push	r25
	ldi	r25,~BIT(F2_OLDERR)
	rjmp	FlagClr2

; clear flag Debug
; DESTROYS: -
.global FlagClrDebug
FlagClrDebug:
	push	r25
	ldi	r25,~BIT(F2_DEBUG)
	rjmp	FlagClr2

; clear flag OldRun
; DESTROYS: -
.global FlagClrOldRun
FlagClrOldRun:
	push	r25
	ldi	r25,~BIT(F2_OLDRUN)
	rjmp	FlagClr2

; clear flag DispRegT
; DESTROYS: -
.global FlagClrDispRegT
FlagClrDispRegT:
	push	r25
	ldi	r25,~BIT(F2_DISP_REGT)
	rjmp	FlagClr2

; clear flag DispText
; DESTROYS: -
.global FlagClrDispText
FlagClrDispText:
	push	r25
	ldi	r25,~BIT(F2_DISP_TEXT)
	rjmp	FlagClr2

; ----------------------------------------------------------------------------
;                               Test flag
; ----------------------------------------------------------------------------

; test flag INV
; OUTPUT: NZ = flag is set
; DESTROYS: -
.global FlagTestInv
FlagTestInv:
	push	r25
	ldi	r25,BIT(F_INV)
FlagTest:
	push	r24
	ldd	r24,Y+DATA_FLAGS
	and	r24,r25
	pop	r24
	pop	r25
	ret

; test flag 'EE mode'
; OUTPUT: NZ = flag is set
; DESTROYS: -
.global FlagTestEE
FlagTestEE:
	push	r25
	ldi	r25,BIT(F_EE)
	rjmp	FlagTest

; test flag 'Eng mode'
; OUTPUT: NZ = flag is set
; DESTROYS: -
.global FlagTestEng
FlagTestEng:
	push	r25
	ldi	r25,BIT(F_ENG)
	rjmp	FlagTest

; test flag 'EE mode' and 'Eng mode'
; OUTPUT: NZ = flag is set
; DESTROYS: -
.global FlagTestEEEng
FlagTestEEEng:
	push	r25
	ldi	r25,BIT(F_EE)+BIT(F_ENG)
	rjmp	FlagTest

; test flag 'restart DecNum'
; OUTPUT: NZ = flag is set
; DESTROYS: -
.global FlagTestResDec
FlagTestResDec:
	push	r25
	ldi	r25,BIT(F_RESDEC)
	rjmp	FlagTest

; test flag 'decimal point'
; OUTPUT: NZ = flag is set
; DESTROYS: -
.global FlagTestDP
FlagTestDP:
	push	r25
	ldi	r25,BIT(F_DP)
	rjmp	FlagTest

; test flag 'exponent'
; OUTPUT: NZ = flag is set
; DESTROYS: -
.global FlagTestExp
FlagTestExp:
	push	r25
	ldi	r25,BIT(F_EXP)
	rjmp	FlagTest

; test flag 'input keys'
; OUTPUT: NZ = flag is set
; DESTROYS: -
.global FlagTestInKey
FlagTestInKey:
	push	r25
	ldi	r25,BIT(F_INKEY)
	rjmp	FlagTest

; test flag 'old trace' (served in DispTrace)
;.global FlagTestOldTrace
;FlagTestOldTrace:
;	push	r25
;	ldi	r25,BIT(F_OLDTRACE)
;	rjmp	FlagTest

; test flag ErrDec
; OUTPUT: NZ = flag is set
; DESTROYS: -
.global FlagTestErrDec
FlagTestErrDec:
	push	r25
	ldi	r25,BIT(F2_ERRDEC)
FlagTest2:
	push	r24
	ldd	r24,Y+DATA_FLAGS2
	and	r24,r25
	pop	r24
	pop	r25
	ret

; test flag OldErr
; OUTPUT: NZ = flag is set
; DESTROYS: -
.global FlagTestOldErr
FlagTestOldErr:
	push	r25
	ldi	r25,BIT(F2_OLDERR)
	rjmp	FlagTest2

; test flag Debug
; OUTPUT: NZ = flag is set
; DESTROYS: -
.global FlagTestDebug
FlagTestDebug:
	push	r25
	ldi	r25,BIT(F2_DEBUG)
	rjmp	FlagTest2

; test flag OldRun
; OUTPUT: NZ = flag is set
; DESTROYS: -
.global FlagTestOldRun
FlagTestOldRun:
	push	r25
	ldi	r25,BIT(F2_OLDRUN)
	rjmp	FlagTest2

; test flag DispRegT
; OUTPUT: NZ = flag is set
; DESTROYS: -
.global FlagTestDispRegT
FlagTestDispRegT:
	push	r25
	ldi	r25,BIT(F2_DISP_REGT)
	rjmp	FlagTest2

; test flag DispText
; OUTPUT: NZ = flag is set
; DESTROYS: -
.global FlagTestDispText
FlagTestDispText:
	push	r25
	ldi	r25,BIT(F2_DISP_TEXT)
	rjmp	FlagTest2

; ----------------------------------------------------------------------------
;                          Test user flag
; ----------------------------------------------------------------------------
; INPUT: R24 = index of user flag (0..15)
; OUTPUT: R24 = flag state (1 or 0)
;	  Z flag set if bit not set (breq = not set '0', brne = set '1')
; ----------------------------------------------------------------------------
; 7=error on Op18/19, 8=stop on error, 9=print log, 15=error

.global UserFlagTest
UserFlagTest:

	; error flag
	cpi	r24,15
	breq	9f

	push	r25

	mov	r25,r24		; flag index
	ldd	r24,Y+DATA_USERFLAGS ; flags low
	cpi	r25,8		; flag 8 or more?
	brcs	4f		; flag < 8
	ldd	r24,Y+DATA_USERFLAGS+1 ; flags high
	sub	r25,8		; index correction
	rjmp	4f

2:	lsr	r24		; shift flags right
4:	dec	r25		; index counter
	brpl	2b		; index >= 0, do next shift
	andi	r24,1		; mask bit

	pop	r25
	ret

	; test error flag
9:	clr	r24		; not set
	IF_ERROR		; if error flag
	inc	r24		; set
  	ret

; ----------------------------------------------------------------------------
;                          Set user flag
; ----------------------------------------------------------------------------
; INPUT: R24 = index of user flag (0..15)
; DESTROYS: -
; ----------------------------------------------------------------------------
; 7=error on Op18/19, 8=stop on error, 9=print log, 15=error

.global UserFlagSet
UserFlagSet:

	; error flag
	cpi	r24,15
	breq	9f

	push	r24
	push	r25

	ldi	r25,1		; bit mask
	cpi	r24,8
	brcs	4f		; flag < 8

	; flag 8..15
	subi	r24,8
	rjmp	2f

1:	lsl	r25
2:	dec	r24
	brpl	1b
	ldd	r24,Y+DATA_USERFLAGS+1
	or	r24,r25
	std	Y+DATA_USERFLAGS+1,r24
	rjmp	8f

	; flag 0..7	
3:	lsl	r25
4:	dec	r24
	brpl	3b
	ldd	r24,Y+DATA_USERFLAGS
	or	r24,r25
	std	Y+DATA_USERFLAGS,r24

8:      pop	r25
	pop	r24
	ret

	; set error flag
9:	SET_ERROR		; set error flag
  	ret

; ----------------------------------------------------------------------------
;                          Clear user flag
; ----------------------------------------------------------------------------
; INPUT: R24 = index of user flag (0..15)
; DESTROYS: -
; ----------------------------------------------------------------------------
; 7=error on Op18/19, 8=stop on error, 9=print log, 15=error

.global UserFlagClr
UserFlagClr:

	; error flag
	cpi	r24,15
	breq	9f

	push	r24
	push	r25

	ldi	r25,1		; bit mask
	cpi	r24,8
	brcs	4f		; flag < 8

	; flag 8..15
	subi	r24,8
	rjmp	2f

1:	lsl	r25
2:	dec	r24
	brpl	1b
	ldd	r24,Y+DATA_USERFLAGS+1
	or	r24,r25
	eor	r24,r25
	std	Y+DATA_USERFLAGS+1,r24
	rjmp	8f

	; flag 0..7	
3:	lsl	r25
4:	dec	r24
	brpl	3b
	ldd	r24,Y+DATA_USERFLAGS
	or	r24,r25
	eor	r24,r25
	std	Y+DATA_USERFLAGS,r24

8:      pop	r25
	pop	r24
	ret

	; clear error flag
9:	CLR_ERROR		; clear error flag
  	ret
