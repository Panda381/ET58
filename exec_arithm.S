; ****************************************************************************
;
;                                Execute arithmetics
;
; ****************************************************************************

#include "include.inc"

	.text


; bridges
.global _DispFlags
_DispFlags: jmp DispFlags

.global _EditStopNoX
_EditStopNoX: jmp EditStopNoX

; ----------------------------------------------------------------------------
;                     Get current operation
; ----------------------------------------------------------------------------
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
; ----------------------------------------------------------------------------

.global ExecLevel
ExecLevel:

	ldd	r24,Y+DATA_LEVEL ; current level of arithmetics operations
	ldi	r30,lo8(OperStack)
	ldi	r31,hi8(OperStack)
	add	r30,r24
	adc	r31,R_ZERO
	ld	r24,Z
	ret

; ----------------------------------------------------------------------------
;                 Calculate one level of arithmetics operations
; ----------------------------------------------------------------------------

.global ExecCalc
ExecCalc:

	; edit stop
	rcall	_EditStopNoX	; edit stop (not validating X)

	; load X into stack
	ldi	r24,REG_X	; register X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	call	CalcGetMem	; load X into stack

	; check if current operation is valid to save it
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current operation
	andi	r24,OPER_MASK | LEVEL_MASK ; check current operation
	breq	2f		; current operation is not valid

	; copy X into LAST, save last operation
	std	Y+DATA_LAST,r24	; save last operation (LOWER = 0)
	ldi	r24,REG_LAST	; register Last
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
	call	CalcSetMem	; save Last (does not delete it from the stack)


; ----- switch by current operation

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current operation

ExecCalcOn:
2:	andi	r24,OPER_MASK	; mask operation

	; +
	cpi	r24,OPER_PLUS
	brne	3f
; DESTROYS: all
; CALCULATOR STACK: -1
	call	CalcAdd		; add
	rjmp	9f

	; -
3:	cpi	r24,OPER_MINUS
	brne	4f
; DESTROYS: all
; CALCULATOR STACK: -1
	call	CalcSub		; sub
	rjmp	9f

	; *
4:	cpi	r24,OPER_MUL
	brne	5f
; DESTROYS: all
; CALCULATOR STACK: -1
	call	CalcMul		; multiply
	rjmp	9f

	; :
5:	cpi	r24,OPER_DIV
	brne	6f
; DESTROYS: all
; CALCULATOR STACK: -1
	call	CalcDiv		; divide
	rjmp	9f

	; ^
6:	cpi	r24,OPER_POWER
	brne	7f
	call	CalcPow		; power
	rjmp	9f

	; root
7:	cpi	r24,OPER_ROOT
	brne	8f
	call	CalcRec		; reciprocal
	call	CalcPow		; power
	rjmp	9f

	; &
8:	cpi	r24,OPER_AND
	breq	2f

	; |
	cpi	r24,OPER_OR
	breq	2f

	; ~
	cpi	r24,OPER_XOR
	brne	4f
2:	call	CalcBit
	rjmp	9f

	; mod (trunc)
4:	cpi	r24,OPER_MOD
	brne	5f
	call	CalcMod
	rjmp	9f

	; mod2 (floor)
5:	cpi	r24,OPER_MOD2
	brne	6f
	call	CalcMod2
	rjmp	9f

	; %
6:	cpi	r24,OPER_PERC
	brne	7f
	call	CalcMul		; multiply
	ldi	r24,CONST_001	; constant 0.01
	rcall	CalcConst	; load constant
	call	CalcMul		; multiply result by 0.01
	rjmp	9f

	; <
7:	cpi	r24,OPER_LEFT
	brne	2f
	call	CalcLeft
	rjmp	9f

	; >
2:	cpi	r24,OPER_RIGHT
	brne	8f
	call	CalcRight
	rjmp	9f

	; no operation - only delete 2nd operand
; DESTROYS: R31, R30
; CALCULATOR STACK: -1
8:	call	CalcDel		; delete 2nd operand

	; save result into X
9:	ldi	r24,REG_X	; register X
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
	call	CalcSetMem	; set X

	SET_XVALID		; set X valid

	; clear current operation
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK
	st	Z,r24		; clear current operation

; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                         Increase arithmetics level
; ----------------------------------------------------------------------------
; OUTPUT: R31:R30 = pointer into OperStack
; ----------------------------------------------------------------------------

.global ExecLevelInc
ExecLevelInc:

	; increase operation level (with overflow check)
	ldd	r24,Y+DATA_LEVEL ; current level of arithmetics operations
	cpi	r24,LEVEL_MAX	; check level
	brcc	ExecLevelDec2	; fatal error

	inc	r24		; increase level
	std	Y+DATA_LEVEL,r24 ; set new level

.global ExecLevelInit
ExecLevelInit:

	; load X into stack
	ldi	r24,REG_X	; register X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	call	CalcGetMem	; load X into stack

	; clear current operation
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current level
	st	Z,R_ZERO	; clear flag
	ret

; ----------------------------------------------------------------------------
;                         Decrease arithmetics level
; ----------------------------------------------------------------------------
; OUTPUT: R31:R30 = pointer into OperStack
; ----------------------------------------------------------------------------

.global ExecLevelDec
ExecLevelDec:
	ldd	r24,Y+DATA_LEVEL ; current number of arithmetics operations
	tst	r24		; already base level?
	brne	2f
ExecLevelDec2:
	jmp	Fatal		; fatal error

; DESTROYS: R31, R30
; CALCULATOR STACK: -1
2:	call	CalcDel	; delete number from stack

;	ldd	r24,Y+DATA_LEVEL ; current number of arithmetics operations
	dec	r24		; increase level
	std	Y+DATA_LEVEL,r24 ; set new level
ExecLevelDec9:
	ret

; ----------------------------------------------------------------------------
;                           ( (0x53)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecLpar
ExecLpar:

	; stop edit mode (not validating X)
	rcall	_EditStopNoX	; stop edit mode
	CLR_XVALID		; register X is NOT valid
	rcall	ExecLevelInc	; increate level
; DESTROYS: -
	rjmp	_DispFlags	; disp flags

; ----------------------------------------------------------------------------
;                           ) (0x54)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecRpar
ExecRpar:

	; stop edit mode (not validating X)
	rcall	_EditStopNoX	; edit stop (not validating X)

; ----- close levels of one parenthesis

2:	rcall	ExecCalc	; calculate current level

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current level
	push	r24

	ldd	r24,Y+DATA_LEVEL ; current level of arithmetics operations
	tst	r24		; already base level?
	breq	4f

	rcall	ExecLevelDec	; decrease level

4:	pop	r24

	andi	r24,LOWER_MASK	; mask lower level
	cpi	r24,LOWER_NONE ; level () ?
	brne	2b		; close up to () level

; DESTROYS: -
	rjmp	_DispFlags	; disp flags

; ----------------------------------------------------------------------------
;                                 + (0x85)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecAdd
ExecAdd:

	rcall	_EditStopNoX	; edit stop (not validating X)

	IFN_XVALID		; if X is not valid
	rjmp	8f		; only update operation

; ----- close higher level - power

	; close higher level - power
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current level
	andi	r24,LEVEL_MASK	; mask current level
	cpi	r24,LEVEL_POWER ; higher level - power?
	brne	4f
	rcall	ExecCalc	; calculate current level

	; decrease level, if lower level is */ or +-
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower level
	cpi	r24,LOWER_MULDIV ; level */ ?
	breq	3f		; decrease level
	cpi	r24,LOWER_PLUSMINUS ; level +- ?
	brne	4f
3:	rcall	ExecLevelDec	; decrease level

; ----- close higher level - multiply

	; close higher level - multiply
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
4:	rcall	ExecLevel	; get current level
	andi	r24,LEVEL_MASK	; mask operation
	cpi	r24,LEVEL_MULDIV ; higher level - multiply?
	brne	6f
	rcall	ExecCalc	; calculate current level

	; decrease level, if lower level is +-
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower level
	cpi	r24,LOWER_PLUSMINUS ; level +- ?
	brne	6f
	rcall	ExecLevelDec	; decrease level

; ----- close this level

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
6:	rcall	ExecLevel	; get current level
	andi	r24,LEVEL_MASK	; mask operation
	cpi	r24,LEVEL_PLUSMINUS ; this level - add?
	brne	7f
	rcall	ExecCalc	; calculate current level

; ----- update this level

; DESTROYS: R31, R30
; CALCULATOR STACK: -1
7:	call	CalcDel		; delete accumulator
	ldi	r24,REG_X	; register X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	call	CalcGetMem	; load X into stack

	CLR_XVALID		; register X is NOT valid

	; update this level - set +- operation
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
8:	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower operation
	ori	r24,LEVEL_PLUSMINUS | OPER_PLUS
	st	Z,r24		; set current operation

	; display flags with current operation
; DESTROYS: -
	rjmp	_DispFlags	; disp flags

; ----------------------------------------------------------------------------
;                           - (0x75)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecSub
ExecSub:
	rcall	ExecAdd		; close +/- operations

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
;	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower operation
	ori	r24,LEVEL_PLUSMINUS | OPER_MINUS
ExecSub2:
	st	Z,r24		; set current operation

; DESTROYS: -
	rjmp	_DispFlags	; disp flags

; ----------------------------------------------------------------------------
;                           & (0x6E)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecAnd
ExecAnd:
	rcall	ExecAdd		; close +/- operations

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
;	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower operation
	ori	r24,LEVEL_PLUSMINUS | OPER_AND
	rjmp	ExecSub2

; ----------------------------------------------------------------------------
;                           ~ (0x7E)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecXor
ExecXor:
	rcall	ExecAdd		; close +/- operations

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
;	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower operation
	ori	r24,LEVEL_PLUSMINUS | OPER_XOR
	rjmp	ExecSub2

; ----------------------------------------------------------------------------
;                           | (0x8E)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecOr
ExecOr:
	rcall	ExecAdd		; close +/- operations

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
;	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower operation
	ori	r24,LEVEL_PLUSMINUS | OPER_OR
	rjmp	ExecSub2

; ----------------------------------------------------------------------------
;                           x (0x65)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecMul
ExecMul:

	rcall	_EditStopNoX	; edit stop (not validating X)

	IFN_XVALID		; if X is not valid
	rjmp	8f		; only update operation

; ----- close higher level - power

	; close higher level - power
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current level
	andi	r24,LEVEL_MASK	; mask current level
	cpi	r24,LEVEL_POWER ; higher level - power?
	brne	4f
	rcall	ExecCalc	; calculate current level

	; decrease level, if lower level is */
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower level
	cpi	r24,LOWER_MULDIV ; level */ ?
	brne	4f
	rcall	ExecLevelDec	; decrease level

; ----- close this level - mul

	; close this level - mul
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
4:	rcall	ExecLevel	; get current level
	andi	r24,LEVEL_MASK	; mask operation
	cpi	r24,LEVEL_MULDIV ; this level - mul?
	brne	6f
	rcall	ExecCalc	; calculate current level

; ----- increase lower level +-

	; increase lower level +-
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
6:	rcall	ExecLevel	; get current level
	andi	r24,LEVEL_MASK	; mask current level
	cpi	r24,LEVEL_PLUSMINUS ; lower level - plus?
	brne	7f

	; increase level
	rcall	ExecLevelInc	; increase level
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current level
	ldi	r24,LOWER_PLUSMINUS
	st	Z,r24		; ser lower level

; ----- update this level

; DESTROYS: R31, R30
; CALCULATOR STACK: -1
7:	call	CalcDel		; delete accumulator
	ldi	r24,REG_X	; register X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	call	CalcGetMem	; load X into stack

	CLR_XVALID		; register X is NOT valid

	; update this level - set */ operation
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
8:	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower operation
	ori	r24,LEVEL_MULDIV | OPER_MUL
	st	Z,r24		; set current operation

	; display flags
; DESTROYS: -
	rjmp	_DispFlags	; disp flags

; ----------------------------------------------------------------------------
;                           : (0x55)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecDiv
ExecDiv:
	rcall	ExecMul		; close */ operations

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
;	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower operation
	ori	r24,LEVEL_MULDIV | OPER_DIV
ExecDiv2:
	st	Z,r24		; set current operation

; DESTROYS: -
	rjmp	_DispFlags	; disp flags

; ----------------------------------------------------------------------------
;                           mod trunc (0x5e)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecMod
ExecMod:
	rcall	ExecMul		; close */ operations

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
;	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower operation
	ori	r24,LEVEL_MULDIV | OPER_MOD
	rjmp	ExecDiv2

; ----------------------------------------------------------------------------
;                           mod2 floor (0x4e)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecMod2
ExecMod2:
	rcall	ExecMul		; close */ operations

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
;	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower operation
	ori	r24,LEVEL_MULDIV | OPER_MOD2
	rjmp	ExecDiv2

; ----------------------------------------------------------------------------
;                           % (0x9e)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecPerc
ExecPerc:

	; edit stop
	rcall	_EditStopNoX	; edit stop (not validating X)

	; load X into stack
	ldi	r24,REG_X	; register X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	call	CalcGetMem	; load X into stack

; ----- save last operation

	; check if current operation is valid to save it
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current operation
	andi	r24,OPER_MASK | LEVEL_MASK ; check current operation
	breq	1f		; current operation is not valid

	; copy X into LAST, save last operation
	std	Y+DATA_LAST,r24	; save last operation (LOWER = 0)
	ldi	r24,REG_LAST	; register Last
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
	call	CalcSetMem	; save Last (does not delete it from the stack)
	rjmp	2f

; ----- operation is not valid, save as operator a % b

1:	call	CalcDel		; delete X
	rcall	ExecMul		; close */ operations

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	andi	r24,LOWER_MASK	; mask lower operation
	ori	r24,LEVEL_MULDIV | OPER_PERC
	rjmp	ExecDiv2

; ----- switch by current operation

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
2:	rcall	ExecLevel	; get current operation
	andi	r24,OPER_MASK	; mask operation

	; +
	cpi	r24,OPER_PLUS
	brne	3f
	rcall	Calc		; calculator (x,y)
	.byte	C_DUP2		; pre-duplicate (x,y,x)
	.byte	C_MUL		; multiply (x,y*x)
	.byte	C_CONST(CONST_001) ; load constant 0.01 (x,y*x,0.01)
	.byte	C_MUL		; multiply (x,y*x*0.01)
	.byte	C_SETMEM(REG_LAST) ; save last operand
	.byte	C_ADD		; add (x + y*x*0.01)
	.byte	C_END
	.balign 2
	rjmp	9f

	; -
3:	cpi	r24,OPER_MINUS
	brne	4f
	rcall	Calc		; calculator (x,y)
	.byte	C_DUP2		; pre-duplicate (x,y,x)
	.byte	C_MUL		; multiply (x,y*x)
	.byte	C_CONST(CONST_001) ; load constant 0.01 (x,y*x,0.01)
	.byte	C_MUL		; multiply (x,y*x*0.01)
	.byte	C_SETMEM(REG_LAST) ; save last operand
	.byte	C_SUB		; sub (x - y*x*0.01)
	.byte	C_END
	.balign 2
	rjmp	9f

	; *
4:	cpi	r24,OPER_MUL
	brne	5f
	rcall	Calc		; calculator (x,y)
	.byte	C_CONST(CONST_001) ; load constant 0.01 (x,y,0.01)
	.byte	C_MUL		; multiply (x,y*0.01)
	.byte	C_SETMEM(REG_LAST) ; save last operand
	.byte	C_MUL		; multiply (x * y*0.01)
	.byte	C_END
	.balign 2
	rjmp	9f

	; :
5:	cpi	r24,OPER_DIV
	brne	6f
	rcall	Calc		; calculator (x,y)
	.byte	C_CONST(CONST_001) ; load constant 0.01 (x,y,0.01)
	.byte	C_MUL		; multiply (x,y*0.01)
	.byte	C_SETMEM(REG_LAST) ; save last operand
	.byte	C_DIV		; multiply (x / (y*0.01))
	.byte	C_END
	.balign 2
	rjmp	9f

	; no operation - only delete 2nd operand
; DESTROYS: R31, R30
; CALCULATOR STACK: -1
6:	call	CalcDel		; delete 2nd operand

	; save result into X
9:	ldi	r24,REG_X	; register X
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
	call	CalcSetMem	; set X

	SET_XVALID		; set X valid

	; clear current operation
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK
	st	Z,r24		; clear current operation

; DESTROYS: R0
	rjmp	_Disp		; display all

; ----------------------------------------------------------------------------
;                           left << (0x5b)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecLeft
ExecLeft:
	rcall	ExecMul		; close */ operations

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
;	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower operation
	ori	r24,LEVEL_MULDIV | OPER_LEFT
	rjmp	ExecDiv2

; ----------------------------------------------------------------------------
;                           right >> (0x5c)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecRight
ExecRight:
	rcall	ExecMul		; close */ operations

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
;	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower operation
	ori	r24,LEVEL_MULDIV | OPER_RIGHT
	rjmp	ExecDiv2

; ----------------------------------------------------------------------------
;                           y^x (0x45)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecYx
ExecYx:

	push	r23		; push INV flag

	rcall	_EditStopNoX	; edit stop (not validating X)

	IFN_XVALID		; if X is not valid
	rjmp	8f		; only update operation

; ----- close this level

	; close this level - power
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
2:	rcall	ExecLevel	; get current level
	andi	r24,LEVEL_MASK	; mask operation
	cpi	r24,LEVEL_POWER ; this level - power?
	brne	4f
	rcall	ExecCalc	; calculate current level

; ----- increase lower level */

	; increase lower level */
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
4:	rcall	ExecLevel	; get current level
	andi	r24,LEVEL_MASK	; mask current level
	cpi	r24,LEVEL_MULDIV ; lower level - mul?
	brne	5f

	rcall	ExecLevelInc	; increase level
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current level
	ldi	r24,LOWER_MULDIV
	st	Z,r24		; ser lower level

; ----- increase lower level +-

	; increase lower level +-
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
5:	rcall	ExecLevel	; get current level
	andi	r24,LEVEL_MASK	; mask current level
	cpi	r24,LEVEL_PLUSMINUS ; lower level - plus?
	brne	6f

	rcall	ExecLevelInc	; increase level
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current level
	ldi	r24,LOWER_PLUSMINUS
	st	Z,r24		; ser lower level

; ----- update this level - set ^ operation

; DESTROYS: R31, R30
; CALCULATOR STACK: -1
6:	call	CalcDel		; delete accumulator
	ldi	r24,REG_X	; register X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcGetMem	; load X into stack

	CLR_XVALID		; register X is NOT valid

; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
8:	rcall	ExecLevel	; get current level
	andi	r24,LOWER_MASK	; mask lower operation

	pop	r23		; pop INV flag

	tst	r23		; INV flag?
	ldi	r23,LEVEL_POWER | OPER_POWER
	breq	7f		; power
	ldi	r23,LEVEL_POWER | OPER_ROOT
7:	or	r24,r23
	st	Z,r24		; set current operation

; DESTROYS: -
	rjmp	_DispFlags	; disp flags

; ----------------------------------------------------------------------------
;                            = (0x95)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecRes
ExecRes:

	; stop edit mode (not validating X)
	rcall	_EditStopNoX	; edit stop (not validating X)

	; level = 0 ? (condition to repeat last operation)
	ldd	r24,Y+DATA_LEVEL ; current level of arithmetics operations
	tst	r24		; base level?
	brne	2f		; not base level, no repeat last operation

	; check open operation
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current operation
	andi	r24,OPER_MASK	; mask operation
	breq	4f		; no operation - repeat last operation

	; close all levels
2:	rcall	ExecRpar	; close one level )
	ldd	r24,Y+DATA_LEVEL ; current level of arithmetics operations
	tst	r24		; valid?
	brne	2b
	rjmp	ExecRpar	; close last level

; ===== repeat last operation (Level must be 0 and no open operation, OPER_NONE)

	; check if last operation is valid
4:	ldd	r24,Y+DATA_LAST ; valid last operation?
	tst	r24
	breq	9f		; not valid

	; delete accumulator and load X
; DESTROYS: R31, R30
; CALCULATOR STACK: -1
	call	CalcDel		; delete accumulator
	ldi	r24,REG_X	; register X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcGetMem	; load X into stack

	; load LAST as second operand
	ldi	r24,REG_LAST
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	CalcGetMem	; load register Last

	; set last operation as current operation
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	rcall	ExecLevel	; get current operation
	ldd	r24,Y+DATA_LAST
	st	Z,r24

	rjmp	ExecCalcOn	; calculate operation

9:	ret
