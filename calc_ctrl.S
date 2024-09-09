; ****************************************************************************
;
;                        Calculator control operations
;
; ****************************************************************************

#include "include.inc"

	.text

; ----------------------------------------------------------------------------
;                          No function (C_NOP)
; ----------------------------------------------------------------------------
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcNop
CalcNop:
	ret

; ----------------------------------------------------------------------------
;                        End calculator macro (C_END)
; ----------------------------------------------------------------------------
; INPUT: R_LITH:R_LITL = pointer to current literals (jumps to next location)
; OUTPUT: R_LITH:R_LITL = pointer to previous literals
; DESTROYS: stack+4, R31, R30
; ----------------------------------------------------------------------------

.global CalcEnd
CalcEnd:
	pop	r31		; (HIGH)
	pop	r30		; (LOW) destroy return address

	movw	r30,R_LITL	; Z <- literal pointer

	pop	R_LITH		; pop registers
	pop	R_LITL

	adiw	r30,1		; round up
	lsr	r31
	ror	r30		; convert pointer back to word index
	ijmp			; jump back to the program

; ----------------------------------------------------------------------------
;                Delete number from top of the stack (C_DEL)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------

.global CalcDel
CalcDel:

; ----- get last number on calculator stack
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop		; get last number -> Z

; ----- internal check underflow

	push	r24
	ldi	r24,hi8(CalcStack-NUM_BYTES)
	cpi	r30,lo8(CalcStack-NUM_BYTES)
	cpc	r31,r24
	pop	r24
	brne	CalcDel2	; stack is OK
	jmp	Fatal		; fatal error

; ----- set new end of stack to Z (saves SREG)

.global CalcDel2
CalcDel2: ; jump here from CalcOr and CalcNew
	std	Y+DATA_STKEND,r30 ; save new end of stack
	std	Y+DATA_STKEND+1,r31
	ret

; ----------------------------------------------------------------------------
;       Duplicate pre6-last number on top of stack (C_DUP6)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R24
; CALCULATOR STACK: +1
; ----------------------------------------------------------------------------

.global CalcDup6
CalcDup6:

; ----- create new number on top of stack
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; create new number -> Z

; ----- copy number

	movw	r26,r30		; X <- Z
	sbiw	r30,6*NUM_BYTES	; shift to pre-pre-last number -> Z
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	rjmp	CalcCopyNum

; ----------------------------------------------------------------------------
;       Duplicate pre5-last number on top of stack (C_DUP5)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R24
; CALCULATOR STACK: +1
; ----------------------------------------------------------------------------

.global CalcDup5
CalcDup5:

; ----- create new number on top of stack
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; create new number -> Z

; ----- copy number

	movw	r26,r30		; X <- Z
	sbiw	r30,5*NUM_BYTES	; shift to pre-pre-last number -> Z
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	rjmp	CalcCopyNum

; ----------------------------------------------------------------------------
;           Duplicate pre4-last number on top of stack (C_DUP4)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R24
; CALCULATOR STACK: +1
; ----------------------------------------------------------------------------

.global CalcDup4
CalcDup4:

; ----- create new number on top of stack
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; create new number -> Z

; ----- copy number

	movw	r26,r30		; X <- Z
	sbiw	r30,4*NUM_BYTES	; shift to pre-pre-last number -> Z
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	rjmp	CalcCopyNum

; ----------------------------------------------------------------------------
;              Duplicate pre3-last number on top of stack (C_DUP3)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R24
; CALCULATOR STACK: +1
; ----------------------------------------------------------------------------

.global CalcDup3
CalcDup3:

; ----- create new number on top of stack
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; create new number -> Z

; ----- copy number

	movw	r26,r30		; X <- Z
	sbiw	r30,3*NUM_BYTES	; shift to pre-pre-last number -> Z
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	rjmp	CalcCopyNum

; ----------------------------------------------------------------------------
;              Duplicate pre2-last number on top of stack (C_DUP2)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R24
; CALCULATOR STACK: +1
; ----------------------------------------------------------------------------

.global CalcDup2
CalcDup2:

; ----- create new number on top of stack
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; create new number -> Z

; ----- copy number

	movw	r26,r30		; X <- Z
	sbiw	r30,2*NUM_BYTES	; shift to pre-last number -> Z
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	rjmp	CalcCopyNum

; ----------------------------------------------------------------------------
;                  Duplicate number on top of stack (C_DUP)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R24
; CALCULATOR STACK: +1
; ----------------------------------------------------------------------------

.global CalcDup
CalcDup:

; ----- create new number on top of stack
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; create new number -> Z

; ----- copy number

	movw	r26,r30		; X <- Z
	sbiw	r30,NUM_BYTES	; shift to last number -> Z
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	rjmp	CalcCopyNum

; ----------------------------------------------------------------------------
;                   Exchange two numbers on top of stack (C_EXC)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R23
; ----------------------------------------------------------------------------
; - exchange last number and pre-last number

.global CalcExc
CalcExc:

; OUTPUT: R27:R26 (X) = pre-last number on calculator stack
;	  R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop2	; get pre-last number -> X and last number -> Z
.global CalcExcXZ	; exchange numbers at X and Z (destroys R25, r24, R23)
CalcExcXZ:
	ldi	r23,NUM_BYTES	; R23 <- length of number
1:	ld	r24,Z
	ld	r25,X
	st	X+,r24
	st	Z+,r25
	dec	r23
	brne	1b
	ret

; ----------------------------------------------------------------------------
;              Exchange two numbers on pre-top of stack (C_EXC2)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R23
; ----------------------------------------------------------------------------
; - exchange last number and pre-pre-last number

.global CalcExc2
CalcExc2:

; OUTPUT: R27:R26 (X) = pre-last number on calculator stack
;	  R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop2	; get pre-last number -> X and last number -> Z
	sbiw	r26,NUM_BYTES	; pre-pre-last number -> X
	rjmp	CalcExcXZ

; ----------------------------------------------------------------------------
;       Exchange two numbers on pre-top and pre-pre-top of stack (C_EXC23)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R23
; ----------------------------------------------------------------------------
; - exchange pre-last number and pre-pre-last number

.global CalcExc23
CalcExc23:

; OUTPUT: R27:R26 (X) = pre-last number on calculator stack
;	  R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop2	; get pre-last number -> X and last number -> Z
	sbiw	r30,2*NUM_BYTES	; pre-pre-last number -> Z
	rjmp	CalcExcXZ
	
; ----------------------------------------------------------------------------
;            Exchange two numbers on pre-pre-top of stack (C_EXC3)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R23
; ----------------------------------------------------------------------------
; - exchange last number and pre-pre-pre-last number

.global CalcExc3
CalcExc3:

; OUTPUT: R27:R26 (X) = pre-last number on calculator stack
;	  R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop2	; get pre-last number -> X and last number -> Z
	sbiw	r26,2*NUM_BYTES	; pre-pre-pre-last number -> X
	rjmp	CalcExcXZ

; ----------------------------------------------------------------------------
;          Exchange two numbers on pre-pre-pre-top of stack (C_EXC4)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R23
; ----------------------------------------------------------------------------
; - exchange last number and pre-pre-pre-pre-last number

.global CalcExc4
CalcExc4:

; OUTPUT: R27:R26 (X) = pre-last number on calculator stack
;	  R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop2	; get pre-last number -> X and last number -> Z
	sbiw	r26,3*NUM_BYTES	; pre-pre-pre-pre-last number -> X
	rjmp	CalcExcXZ

; ----------------------------------------------------------------------------
;          Exchange two numbers on pre-pre-pre-pre-top of stack (C_EXC5)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27..R23
; ----------------------------------------------------------------------------
; - exchange last number and pre-pre-pre-pre-pre-last number

.global CalcExc5
CalcExc5:

; OUTPUT: R27:R26 (X) = pre-last number on calculator stack
;	  R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop2	; get pre-last number -> X and last number -> Z
	sbiw	r26,4*NUM_BYTES	; pre-pre-pre-pre-pre-last number -> X
	rjmp	CalcExcXZ

; ----------------------------------------------------------------------------
;                         Relative jump (C_JUMP)
; ----------------------------------------------------------------------------
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
; DESTROYS: R25, R24
; NOTES: Jump offset is relative to next byte after JUMP intruction
; ----------------------------------------------------------------------------

.global CalcJump
CalcJump:
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
;	 R24 = next literal
; DESTROYS: -
	rcall	CalcLit		; load literal -> R24

	ldi	r25,0		; jump HIGH positive offset
	tst	r24		; negative number?
	brpl	CalcJump2	; jump offset is positive
	ldi	r25,0xff	; HIGH negative offset
CalcJump2:
	add	R_LITL,r24	; add offset LOW
	adc	R_LITH,r25	; add offset HIGH
	ret

; ----------------------------------------------------------------------------
;   Relative jump if top number is true (<>0), delete top number (C_JUMPT)
; ----------------------------------------------------------------------------
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
; DESTROYS: R31, R30, R25, R24
; CALCULATOR STACK: -1
; NOTES: Jump offset is relative to next byte after JUMP intruction
; ----------------------------------------------------------------------------

.global CalcJumpT
CalcJumpT:

; ----- get last number and check if zero -> Z, R25:R24
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck

; ----- destroy last number (saves SREG)
; DESTROYS: -
	rcall	CalcDel2	; set stack end to Z (saves SREG)

; ----- jump if not zero
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
; DESTROYS: R25, R24
; NOTES: Jump offset is relative to next byte after JUMP intruction
CalcJumpT2:
	brne	CalcJump	; not zero, jump is valid

; ----- or only destroy literal with jump offset
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
;	 R24 = next literal
; DESTROYS: -
	rjmp	CalcLit		; load literal -> R24

; ----------------------------------------------------------------------------
;   Relative jump if top number is false (=0), delete top number (C_JUMPF)
; ----------------------------------------------------------------------------
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
; DESTROYS: R31, R30, R25, R24
; CALCULATOR STACK: -1
; NOTES: Jump offset is relative to next byte after JUMP intruction
; ----------------------------------------------------------------------------

.global CalcJumpF
CalcJumpF:

; ----- get last number and check if zero -> Z, R25:R24
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck

; ----- destroy last number (saves SREG)
; DESTROYS: -
	rcall	CalcDel2	; set stack end to Z (saves SREG)

; ----- jump if zero
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
; DESTROYS: R25, R24
; NOTES: Jump offset is relative to next byte after JUMP intruction
CalcJumpF2:
	breq	CalcJump	; zero, jump is valid

; ----- or only destroy literal with jump offset
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
;	 R24 = next literal
; DESTROYS: -
	rjmp	CalcLit		; load literal -> R24

; ----------------------------------------------------------------------------
; Relative jump if top number is not zero, do not delete top number (C_JUMPNZ)
; ----------------------------------------------------------------------------
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
; DESTROYS: R31, R30, R25, R24
; NOTES: Jump offset is relative to next byte after JUMP intruction
; ----------------------------------------------------------------------------

.global CalcJumpNZ
CalcJumpNZ:

; ----- get last number and check if zero -> Z, R25:R24
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck
	rjmp	CalcJumpT2

; ----------------------------------------------------------------------------
;   Relative jump if top number is zero, do not delete top number (C_JUMPZ)
; ----------------------------------------------------------------------------
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
; DESTROYS: R31, R30, R25, R24
; NOTES: Jump offset is relative to next byte after JUMP intruction
; ----------------------------------------------------------------------------

.global CalcJumpZ
CalcJumpZ:

; ----- get last number and check if zero -> Z, R25:R24
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	rcall	CalcTopCheck
	rjmp	CalcJumpF2

; ----------------------------------------------------------------------------
;                    Relative jump if error (C_JUMPERR)
; ----------------------------------------------------------------------------
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
; DESTROYS: R31, R30, R25, R24
; NOTES: Jump offset is relative to next byte after JUMP intruction
; ----------------------------------------------------------------------------

.global CalcJumpErr
CalcJumpErr:

; ----- jump if error
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
; DESTROYS: R25, R24
; NOTES: Jump offset is relative to next byte after JUMP intruction
	IF_ERROR		; if soft error
	rjmp	CalcJump	; jump if soft error
	IF_FATAL		; if fatal error
	rjmp	CalcJump	; jump if fatal error

; ----- or only destroy literal with jump offset
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
;	 R24 = next literal
; DESTROYS: -
	rjmp	CalcLit		; load literal -> R24

; ----------------------------------------------------------------------------
;                Relative jump if not running (C_JUMPBREAK)
; ----------------------------------------------------------------------------
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
; DESTROYS: R31, R30, R25, R24
; NOTES: Jump offset is relative to next byte after JUMP intruction
; ----------------------------------------------------------------------------

.global CalcJumpBreak
CalcJumpBreak:

; ----- jump if error
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
; DESTROYS: R25, R24
; NOTES: Jump offset is relative to next byte after JUMP intruction
	IFN_RUNNING		; if not running
	rjmp	CalcJump	; jump if not running

; ----- or only destroy literal with jump offset
; INPUT: R_LITH:R_LITL = pointer to literals
; OUTPUT: R_LITH:R_LITL = new pointer to literals
;	 R24 = next literal
; DESTROYS: -
	rjmp	CalcLit		; load literal -> R24

; ----------------------------------------------------------------------------
;                        Set error flag (C_ERROR)
; ----------------------------------------------------------------------------
; OUTPUT: CY = error flag
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcError
CalcError:

	SET_ERROR		; set error flag

	push	r24
	ldi	r24,8
; INPUT: R24 = index of user flag (0..15)
; OUTPUT: R24 = flag state (1 or 0)
;	  Z flag set if bit not set (breq = not set '0', brne = set '1')
; 7=error on Op18/19, 8=stop on error, 9=print log, 15=error
	call	UserFlagTest	; check flag "stop on error"
	pop	r24
	breq	CalcError2	; no stop on error
	call	StopProg	; stop program

CalcError2:
	sec			; set CY error flag
	ret
