; ****************************************************************************
;
;                                Execute buttons
;
; ****************************************************************************

#include "include.inc"

	.text

; bridges
.global _CalcGetMem
_CalcGetMem: jmp CalcGetMem

.global _Calc
_Calc: jmp Calc

.global _CalcSetMemDelX	; set register X
_CalcSetMemDelX:
	ldi	r24,REG_X

.global _CalcSetMemDel ; set register and delete stack
_CalcSetMemDel:
	jmp	CalcSetMemDel

.global _DispChar
_DispChar:
	jmp	DispChar

.global _CalcConst
_CalcConst:
	jmp	CalcConst

.global _EditStop
_EditStop:
	jmp	EditStop

.global __Disp
__Disp: jmp Disp

MainProgText:
	.asciz	"Main Program"
	.balign 2

ClearTxt:
	.asciz	" Clear? (1=YES) "
	.balign 2

; ----- compare operations of ExecIf

ExecIfTab:
	.byte	C_LTEQ	; 0 (8) <=
	.byte	C_LT	; 1 (9) <
	.byte	C_EQU	; 2 (A) =
	.byte	C_LTEQ	; 3 (B) <=
	.byte	C_GR	; 4 (C) >
	.byte	C_NEQU	; 5 (D) <> (not equal)
	.byte	C_GREQ	; 6 (E) >=
	.byte	C_GR	; 7 (F) >
	.balign 2

; ----------------------------------------------------------------------------
;                           CLR (0x25)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecClr
ExecClr:
; CLR do not clear T register!
	call	CalcInit	; reset calculator stack

	rcall	ClearErr	; clear error

	rcall	FlagClrDispText	; clear text mode

	call	LCD_SetFontDef	; set default font

	std	Y+DATA_FLAG2ND,R_ZERO ; clear 2nd flag
; DESTROYS: -
	rcall	FlagClrEE	; clear EE flag (but not ENG mode)

	rcall	EditStart	; start edit mode
; DESTROYS: -
	rjmp	DispFlags	; display flags

; ----------------------------------------------------------------------------
;                           2nd (0x21)
; ----------------------------------------------------------------------------
; INPUT: R24 = key code
;	 R23 = INV flag (1=set) ... in this '2nd' case flag INV is not cleared
;	 Z = clear if INV flag was set (=brne)
; DESTROYS: R31, R30, R25, R24
; ----------------------------------------------------------------------------

.global Exec2nd
Exec2nd:
;   2nd flag
; #define F_NONE	0	// no 2nd flag
; #define F_2ND		1	// 2nd flag
; #define F_3RD		2	// 3rd flag
	ldd	r24,Y+DATA_FLAG2ND ; load 2nd flag
	inc	r24		; increase 2nd flag
	cpi	r24,F_3RD+1	; check overflow
	brcs	2f		; ok
	ldi	r24,F_NONE	; overflow to no 2nd flag
2:	std	Y+DATA_FLAG2ND,r24 ; set new 2nd flag
; DESTROYS: -
	rjmp	DispFlags	; display flags

; ----------------------------------------------------------------------------
;                           INV (0x22, 0x27)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecInv
ExecInv:
	tst	r23		; was INV set?
	breq	2f		; INV was not set

; DESTROYS: -
	rcall	FlagClrInv	; clear INV flag
; DESTROYS: -
	rjmp	DispFlags	; display flags

; DESTROYS: -
2:	rcall	FlagSetInv	; set INV flag
; DESTROYS: -
	rjmp	DispFlags	; display flags

; ----------------------------------------------------------------------------
;                           CP (0x29)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecCp
ExecCp:

	rcall	_EditStop	; stop edit mode

	ldi	r24,CONST_0	; constant 0
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcConst
	ldi	r24,REG_T
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: -1
	rcall	_CalcSetMemDel	; clear register T

	IF_RUNNING		; running?
	ret			; running program

	ldd	r24,Y+DATA_PROGINX ; current program index
	tst	r24		; main program?
	brne	9f		; not main program

	; diplay prompt to confirm operation
	call	DispSetRow1	; set cursor to ROW1
	ldi	r30,lo8(ClearTxt)
	ldi	r31,hi8(ClearTxt)
	call	DispTextRom	; display text
	ldi	r24,NOKEY
	call	ReturnKey	; flush old key
	call	WaitKey		; wait for a key
	cpi	r24,KEY_1	; check key '1'
	brne	8f

	rcall	DispC		; display C

	ldi	r26,lo8(PROG_NUM-1)
	ldi	r27,hi8(PROG_NUM-1)
	ldi	r25,CLEARKEY

; INPUT: R27:R26 = destination address
;	 R25 = data
; OUTPUT: R24 = old byte
1:	call	EEWrite		; clear byte
	sbiw	r26,1
	brpl	1b

	std	Y+DATA_ADDR,R_ZERO
	std	Y+DATA_ADDR+1,R_ZERO
; DESTROYS: R0
8:
	rjmp	Disp		; display all

9:	ret

; ----------------------------------------------------------------------------
;                             Code (0x2b)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecCode
ExecCode:

; ----- return if running

	IF_RUNNING		; if running, no operation
	ret

; ----- load 2 hex digits: from program, 2 digits from user, or as a key
; OUTPUT: R24 = byte
; DESTROYS: R25
	call	Load2Hex

; ----- save key into keyboad buffer
; INPUT: R24 = key HEX code
; DESTROYS: -
	jmp	ReturnKey

; ----------------------------------------------------------------------------
;                           x<>t (0x32)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecXt
ExecXt:

	rcall	_EditStop	; stop edit mode

	rcall	_Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_GETMEM(REG_T) ; load T into stack
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_SETMEMDEL(REG_T) ; set T back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                           x<>y (0x3B)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecXy
ExecXy:

	rcall	_EditStop	; stop edit mode

	; exchange last operation
	ldd	r25,Y+DATA_LEVEL ; current number of arithmetics operations
	tst	r25		; already base level?
	brne	2f		; not base level
	; check oper level
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	call	ExecLevel	; get current level
	andi	r24,OPER_MASK	; mask current level
	brne	2f		; not invalid operation

	; exchange X and LAST
	rcall	_Calc
	.byte	C_GETMEM(REG_X) ; load X into stack
	.byte	C_GETMEM(REG_LAST) ; load last into stack
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_SETMEMDEL(REG_LAST) ; set last back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	Disp		; display all

2:	; exchange X and current operand
	ldi	r24,REG_X
; INPUT: R24 = index of variable 0..MEM_NUM-1
; OUTPUT: R31:R30 = address of variable
;	  R1 = 0
; DESTROYS: R0
	call	CalcAddrMem

	ldi	r26,NUM_BYTES	; bytes per number
	mul	r25,r26		; offset of number
	movw	r26,r0		; offset of number
	subi	r26,lo8(-(CalcStack)) ; address in calculator stack
	sbci	r27,hi8(-(CalcStack))
	clr	r1		; restore R1 (R_ZERO)
	call	CalcExcXZ	; exchange numbers at X and Z (destroys R25, r24, R23)
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                            Pgm Ind (0x62)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecPgmInd
ExecPgmInd:

; ----- get program index

; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20
	rcall	ExecMemNum	; get memory index, with indirect from keyboard
	brcs	ExecPgm9	; error

; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load number into stack

; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; load byte from the stack
	brcs	ExecPgm9	; overflow
	brne	ExecPgm9	; negative
	rjmp	ExecPgm2

; ----------------------------------------------------------------------------
;                             Pgm (0x36)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecPgm
ExecPgm:

; ----- INV - load current program index

	breq	1f		; INV not set

	rcall	_EditStop	; stop edit mode
	ldd	r24,Y+DATA_PROGINX ; current program index
	rcall	ExecLoadByte	; load byte into X
	IF_RUNNING
	ret
	rjmp	ExdecPgm6

; ----- get program index
; OUTPUT: R24 = typically 0..159 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
1:	call	Load2Dig	; load 2 digits (from user with indirect or from program)
	brcs	ExecPgm9	; error

; ----- check program index

ExecPgm2:
	ldd	r25,Y+DATA_PROGNUM ; number of programs in library module
	cp	r25,r24		; check program index
	brcc	2f		; program index is OK
; OUTPUT: CY = error flag
; DESTROYS: -
	jmp	CalcError	; error

; ----- if running, open program later

2:	IF_RUNNING		; if running
	std	Y+DATA_PROGNEXT,r24 ; next program index
	IF_RUNNING		; if running
ExecPgm9:
	ret

; ----- save address in main program

	ldd	r25,Y+DATA_PROGINX ; current program index
	tst	r25		; main program
	brne	4f		; not main program
	ldd	r25,Y+DATA_ADDR
	std	Y+DATA_SAVEADDR,r25
	ldd	r25,Y+DATA_ADDR+1
	std	Y+DATA_SAVEADDR+1,r25

; ----- open program
; INPUT: R24 = program index (0=main)
; DESTROYS: R31, R30, R24, R0
4:	rcall	OpenProg

; ----- inicialize current address (reset to begin, or restore main address)

	ldd	r24,Y+DATA_PROGINX ; current program index
	tst	r24		; main program?
	ldd	r24,Y+DATA_SAVEADDR ; saved address
	ldd	r25,Y+DATA_SAVEADDR+1
	breq	5f		; main program, restore old address
	ldd	r24,Y+DATA_PROGBEG ; program begin
	ldd	r25,Y+DATA_PROGBEG+1
5:	std	Y+DATA_ADDR,r24 ; set new current address
	std	Y+DATA_ADDR+1,r25

; ----- display program
ExdecPgm6:
; DESTROYS: -
	call	DispSetRow1	; set cursor to start of ROW1

; ----- main program

	ldd	r24,Y+DATA_PROGINX ; current program index
	tst	r24		; main program?
	brne	2f		; not main program

; INPUT: R31:R30 = text in ROM (terminated with 0)
; DESTROYS: R31, R30, R24
	ldi	r30,lo8(MainProgText)
	ldi	r31,hi8(MainProgText)
	call	DispTextRom	; display text from ROM
	rjmp	3f

; ----- module program
; INPUT: R24 = program index (1,...)
; OUTPUT: R31:R30 = program address in ROM
; DESTROYS: R0
2:	ldd	r24,Y+DATA_PROGNUM ; number of programs
	inc	r24		; end of programs
	rcall	GetProgAddr	; get address of program end

	; module name
	lpm	r24,Z+		; module name
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	_DispChar
	lpm	r24,Z
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	_DispChar

	; separator
	ldi	r24,'-'
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	_DispChar

	; program number
; INPUT: R24 = number
; DESTROYS: -
	ldd	r24,Y+DATA_PROGINX
	rcall	Disp2Dig	; display program number

; DESTROYS: -
	call	DispSpc

	; program length
	ldi	r24,'('
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	_DispChar

	ldd	r24,Y+DATA_PROGEND
	ldd	r25,Y+DATA_PROGEND+1
	ldd	r30,Y+DATA_PROGBEG
	sub	r24,r30
	ldd	r30,Y+DATA_PROGBEG+1
	sbc	r25,r30
; INPUT: R25:R24 = number
; DESTROYS: -
	rcall	Disp3Dig

	ldi	r24,')'
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	_DispChar

	; clear rest of line
; DESTROYS: -
3:	call	DispSpcClr

	; wait some time (0.75 sec)
; DESTROYS: R24
	call	Wait250ms	; wait 250 ms
; DESTROYS: R24
	call	Wait250ms	; wait 250 ms
; DESTROYS: R24
	call	Wait250ms	; wait 250 ms
	
	; restore display
; DESTROYS: -
	rjmp	DispFlags

; ----------------------------------------------------------------------------
;                           P->R (0x37)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecPr
ExecPr:

	breq	ExecPr4		; not INV

; ----- INV, convert R->P (cartesian -> polar)
; input cartesian: x=Y, t=X
; output polar: x=angle, t=radius

	; stop edit mode, validate X and display C if not running
	rcall	_EditStop	; stop edit mode

	rcall	_Calc		; calculator
	.byte	C_GETMEM(REG_T)	; load T (x) ... X
	.byte	C_GETMEM(REG_X)	; load X (x,y) ... Y
	.byte	C_RP		; convert to polar (r,a)
	.byte	C_FROMRAD	; convert from radians (r,a)
	.byte	C_SETMEMDEL(REG_X) ; save angle (r)
	.byte	C_SETMEMDEL(REG_T) ; save radius ()
	.byte	C_END
	.balign 2

	rjmp	Disp		; display

; ----- not INV, convert P->R (polar -> cartesian)
; input polar: x=angle, t=radius
; output cartesian: x=Y, t=X

ExecPr4:
	; stop edit mode, validate X and display C if not running
	rcall	_EditStop

	rcall	_Calc		; calculator
	.byte	C_GETMEM(REG_T)	; load radius (r)
	.byte	C_GETMEM(REG_X)	; load angle (r,a)
	.byte	C_TORAD		; convert to radians (r,a)
	.byte	C_PR		; convert to cartesian (x,y)
	.byte	C_SETMEMDEL(REG_X) ; save Y (x)
	.byte	C_SETMEMDEL(REG_T) ; save X ()
	.byte	C_END
	.balign 2

	rjmp	Disp		; display

; ----------------------------------------------------------------------------
;                           LCD display contrast (0x5A)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecLCD
ExecLCD:

	brne	4f		; INV is set

	; set LCD contrast
; OUTPUT: R24 = typically digit 0..15 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
	rcall	Load1Dig	; load 1 key from program or from user, with indirect
	brcs	2f		; key is invalid
	cpi	r24,10		; check max. value
	brcc	2f		; out of range
	std	Y+DATA_LCDVO,r24 ; set contrast

; INPUT: R27:R26 = destination address
;	 R25 = data
; OUTPUT: R24 = old byte
	mov	r25,r24
	ldi	r26,lo8(CFG_LCD)
	ldi	r27,hi8(CFG_LCD)
	call	EEWrite		; write correction to EEPROM

; DESTROYS: R31, R30, R25..R20 
;	call	LCD_Update	; update display

; ----- Restore LCD display

	call	LCD_Restore
	rcall	Disp

2:	ret

	; get LCD contrast
4:	rcall	_EditStop	; stop edit mode
	ldd	r24,Y+DATA_LCDVO ; current contrast

ExecLoadByte:
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	call	CalcStackB	; stack unsigned byte R24
	rcall	_CalcSetMemDelX	; set X
	SET_XVALID		; set X valid
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                           Ind (0x40)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecInd
ExecInd:

; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20
	rcall	ExecMemNum	; get memory index, with indirect from keyboard
	brcs	9f		; error

; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load number into stack

; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; load byte from the stack
	brcs	8f		; overflow
	brne	8f		; negative

	rjmp	Exec		; execute key code

; OUTPUT: CY = error flag
; DESTROYS: -
8:	call	CalcError	; error
9:	ret

; ----------------------------------------------------------------------------
;              Get memory index, with indirect from keyboard
; ----------------------------------------------------------------------------
; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20
; ----------------------------------------------------------------------------

.global ExecMemNum
ExecMemNum:

	push	r23
; DESTROYS: R27, R26, R25, R24, R20
	rcall	_EditStop	; stop edit mode
; OUTPUT: R24 = typically 0..159 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
	call	Load2Dig	; load 2 digits, with indirect from keyboard
	brcs	1f		; error

	cpi	r24,USER_NUM	; max. memory
	brcs	2f		; OK
; OUTPUT: CY = error flag
; DESTROYS: -
	call	CalcError	; error
1:	pop	r23
	ret

2:	subi	r24,-USER_FIRST
	clc
	pop	r23
	ret

; ----------------------------------------------------------------------------
;                     Get memory index indirected
; ----------------------------------------------------------------------------
; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20, R_M1..R_M10
; ----------------------------------------------------------------------------

.global ExecMemNumInd
ExecMemNumInd:

	push	r23

; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20
	rcall	ExecMemNum	; get memory index, with indirect from keyboard
	brcs	9f		; error

; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load number into stack

; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; load byte from the stack
	brcs	8f		; overflow
	brne	8f		; negative

	cpi	r24,USER_NUM	; max. memory
	brcc	8f		; invalid index

	subi	r24,-USER_FIRST ; real index

	pop	r23
	clc
	ret

; OUTPUT: CY = error flag
; DESTROYS: -
8:	call	CalcError	; error

9:	pop	r23
	ret

; ----------------------------------------------------------------------------
;                           STO Ind (0x72)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecStoInd
ExecStoInd:

; ---- get memory index indirected
; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20, R_M1..R_M10
	rcall	ExecMemNumInd
	brcs	ExecSto9	; error
	rjmp	ExecSto2

; ----------------------------------------------------------------------------
;                           STO (0x42)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecSto
ExecSto:

; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20
	rcall	ExecMemNum	; get memory index
	brcs	ExecSto9	; error

ExecSto2:
	push	r24
	ldi	r24,REG_X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load X into stack
	pop	r24
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: -1
	rjmp	_CalcSetMemDel	; set memory

ExecSto9:
	ret

; ----------------------------------------------------------------------------
;                           RCL Ind (0x73)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecRclInd
ExecRclInd:

; ---- get memory index indirected
; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20, R_M1..R_M10
	rcall	ExecMemNumInd
	brcs	ExecSto9	; error
	rjmp	ExecRcl2

; ----------------------------------------------------------------------------
;                           RCL (0x43)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecRcl
ExecRcl:

; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20
	rcall	ExecMemNum	; get memory index
	brcs	ExecSto9	; error

ExecRcl2:
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load memory into stack
	rcall	_CalcSetMemDelX	; set X from stack
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                           SUM Ind (0x74)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecSumInd
ExecSumInd:

; ---- get memory index indirected
; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R23, R20, R_M1..R_M10
	rcall	ExecMemNumInd
	brcs	ExecSto9	; error
	rjmp	ExecSum2

; ----------------------------------------------------------------------------
;                           SUM (0x44)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecSum
ExecSum:

; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20
	rcall	ExecMemNum	; get memory index
	brcs	ExecSto9	; error

ExecSum2:
	push	r24

	push	r23
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load memory into stack
	ldi	r24,REG_X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load X into stack
	pop	r23

	tst	r23		; INV ?
	breq	2f		; INV not set

; DESTROYS: R31, R30, R25, R24
	call	CalcNeg		; negate X

; DESTROYS: all
; CALCULATOR STACK: -1
2:	call	CalcAdd		; add or subtract
	pop	r24
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: -1
	rjmp	_CalcSetMemDel	; set memory

; ----------------------------------------------------------------------------
;                           Inc Ind (0x6B)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecIncInd
ExecIncInd:

; ---- get memory index indirected
; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20, R_M1..R_M10
	rcall	ExecMemNumInd
	brcs	ExecSto9	; error
	rjmp	ExecInc2

; ----------------------------------------------------------------------------
;                           Inc (0x9c)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecInc
ExecInc:

; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20
	rcall	ExecMemNum	; get memory index
	brcs	ExecSto9	; error

ExecInc2:
	push	r24

	push	r23
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load memory into stack
	pop	r23

	tst	r23		; INV ?
	breq	2f		; INV not set

; DESTROYS: R31, R30, R25, R24
	call	CalcDec		; decrement
	rjmp	3f

; DESTROYS: all
; CALCULATOR STACK: -1
2:	call	CalcInc		; increment

3:	pop	r24
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: -1
	rjmp	_CalcSetMemDel	; set memory

; ----------------------------------------------------------------------------
;                           CMs (0x47)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecCms
ExecCms:
	push	r23
	rcall	_EditStop	; stop edit mode

	; load constant 0
	ldi	r24,CONST_0
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcConst	; load constant 0

	pop	r23
	tst	r23		; INV ?
	breq	4f		; not INV, clear whole memory

	rcall	_EditStop	; stop edit mode

	; clear registers X and T
	ldi	r24,REG_X
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
	call	CalcSetMem	; clear register X

	ldi	r24,REG_T
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
	call	CalcSetMem	; clear register T

	; clear only STAT registers 1..6
	ldi	r24,USER_FIRST+1 ; first register
	ldi	r25,USER_FIRST+6 ; last register
	rjmp	1f

; clear registers from R24 to R25

	; clear registers of whole user memory
4:	ldi	r24,USER_FIRST
	ldi	r25,USER_FIRST+USER_NUM-1

1:	push	r24
	push	r25
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
	call	CalcSetMem	; set memory from stack
	pop	r25
	pop	r24

	; next register index
	inc	r24
	cp	r24,r25
	brne	1b

	; clear last register and empty stack
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: -1
	rcall	_CalcSetMemDel

ExecCms9:
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                           Exc Ind (0x63)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecExcInd
ExecExcInd:

; ---- get memory index indirected
; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20, R_M1..R_M10
	rcall	ExecMemNumInd
	brcs	ExecCms9	; error
	rjmp	ExecExc2

; ----------------------------------------------------------------------------
;                           Exc (0x48)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecExc
ExecExc:

; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20
	rcall	ExecMemNum	; get memory index
	brcs	ExecCms9	; error

ExecExc2:
	push	r24
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; get memory
	ldi	r24,REG_X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; get X
	pop	r24
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: -1
	rcall	_CalcSetMemDel	; set memory
	rcall	_CalcSetMemDelX	; set X
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                           Prd Ind (0x64)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecPrdInd
ExecPrdInd:

; ---- get memory index indirected
; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20, R_M1..R_M10
	rcall	ExecMemNumInd
	brcs	ExecCms9	; error
	rjmp	ExecPrd2

; ----------------------------------------------------------------------------
;                           Prd (0x49)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecPrd
ExecPrd:

; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20
	rcall	ExecMemNum	; get memory index
	brcs	ExecCms9	; error

ExecPrd2:
	push	r24

	push	r23
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; get memory
	ldi	r24,REG_X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; get X
	pop	r23

	tst	r23		; INV ?
	breq	2f		; INV not set

; DESTROYS: all
; CALCULATOR STACK: -1
	call	CalcDiv		; divide
	rjmp	4f

; DESTROYS: all
; CALCULATOR STACK: -1
2:	call	CalcMul		; multiply

4:	pop	r24
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: -1
	rjmp	_CalcSetMemDel	; set memory

; ----------------------------------------------------------------------------
;                       Bat - get battery voltage (0x4A)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecBat
ExecBat:
	; stop edit mode
	push	r23
	rcall	_EditStop	; stop edit mode

	; get battery voltage in 0.01V
	call	ADC_Vcc
	pop	r23

	; check INV
	tst	r23		; INV?
	breq	6f		; INV not set

	; recalculate battery voltage to percentage (2.4..2.9V -> 240..290 -> 0..100)
	subi	r24,240
	sbci	r25,0
	brpl	2f
	clr	r24
	clr	r25
2:	cpi	r24,50
	cpc	r25,R_ZERO
	brcs	3f
	ldi	r24,50
	clr	r25
3:	add	r24,r24		; * 2 (range 0..100%)

	; store to X
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	call	CalcStackW	; stack unsigned word R25:R24
	rjmp	8f

	; divide / 100 and store to X
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
6:	call	CalcStackW	; stack unsigned word R25:R24
	ldi	r24,CONST_001
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcConst	; load constant "0.01"
; DESTROYS: all
; CALCULATOR STACK: -1
	call	CalcMul		; multiply

8:	rcall	_CalcSetMemDelX	; set X

	; validate and display X
	SET_XVALID		; set X valid
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                       Temp - temperature (0x3A)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecTemp
ExecTemp:
	; stop edit mode
	push	r23
	rcall	_EditStop	; stop edit mode
	pop	r23

	; check INV
	tst	r23		; INV?
	brne	4f		; INV is set

	; load temperature
; OUTPUT: R25:R24 temperature in C with offset 245, uncalibrated
; DESTROYS: R23
	call	ADC_Temp

	; substract normalized offset
	subi	r24,245
	sbc	r25,R_ZERO
	movw	r30,r24

	; add correction from EEPROM
	ldi	r26,lo8(CFG_TEMP)
	ldi	r27,hi8(CFG_TEMP)
; INPUT: R27:R26 = source address
; OUTPUT: R24 = data
; DESTROYS: -
	call	_EERead		; read temperature correction
	clr	r25
	tst	r24
	brpl	2f
	ldi	r25,-1
2:	add	r24,r30
	adc	r25,r31

	; store to calculator stack
; INPUT: R25:R24 = signed integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	call	CalcStackS16

	; load X
	rcall	_CalcSetMemDelX	; set X

	; validate and display X
	SET_XVALID		; set X valid
; DESTROYS: R0
	rjmp	Disp		; display all

; calibrate temperature

4:	; not if running
	IF_RUNNING		; if running
	ret			; disabled

	; load required temperature from X
	ldi	r24,REG_X	; register X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load X into stack
; OUTPUT: R25:R24 = signed integer
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackS16	; get signed number -> R25:R24
	mov	r26,r24		; R26 <- required temperature

	; load temperature
; OUTPUT: R25:R24 temperature in °C with offset 245, uncalibrated
; DESTROYS: R23
	call	ADC_Temp

	; save correction to EEPROM
	subi	r24,245		; R24 <- measured temperature
	sub	r26,r24		; R26 <- correction
	mov	r25,r26

; INPUT: R27:R26 = destination address
;	 R25 = data
; OUTPUT: R24 = old byte
	ldi	r26,lo8(CFG_TEMP)
	ldi	r27,hi8(CFG_TEMP)
	jmp	_EEWrite	; write correction to EEPROM

; ----------------------------------------------------------------------------
;                             Factorial n! (0x4B)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecFact
ExecFact:

; ----- stop edit mode and load X

	push	r23
	rcall	EditStopC	; stop edit mode and display C
	; load X
	ldi	r24,REG_X	; register X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load X into stack
	pop	r23

; ----- check INV

	tst	r23		; INV?
	brne	4f		; INV is set

; ----- INV not set - calculate non-integer factorial

	call	CalcFact	; non-integer factorial
	rjmp	6f

; ----- INV is set - calculate integer factorial

4:	call	CalcFactInt	; integer factorial

; ----- save result

ExecFact8:
	; set X
6:	rcall	_CalcSetMemDelX	; set X

	; validate and display X
	SET_XVALID		; set X valid
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                             ln n! (0x4C)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecLnFact
ExecLnFact:

	rcall	EditStopC	; stop edit mode and display C

	; load X
	ldi	r24,REG_X	; register X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load X into stack

	; ln n!
	call	CalcFactLn	; ln factorial
	rjmp	ExecFact8

; ----------------------------------------------------------------------------
;                             log n! (0x4D)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecLogFact
ExecLogFact:

	rcall	EditStopC	; stop edit mode and display C

	; load X
	ldi	r24,REG_X	; register X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load X into stack

	; ln n!
	call	CalcFactLn	; ln factorial

	ldi	r24,CONST_RLN10 ; constant 1/ln(10)
	call	CalcConst

	call	CalcMul		; multiply

	rjmp	ExecFact8

; ----------------------------------------------------------------------------
;                           Deg (0x60)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecDeg
ExecDeg:

	ldi	r24,UNIT_DEG
ExecDeg2:
	std	Y+DATA_UNIT,r24
; DESTROYS: -
	rjmp	DispFlags

; ----------------------------------------------------------------------------
;                              GTO Ind (0x83)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecGtoInd
ExecGtoInd:

; ----- get address

; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20
	rcall	ExecMemNum	; get memory index, with indirect from keyboard
	brcs	ExecGto9	; error

; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load number into stack

; OUTPUT: R25:R24 = unsigned integer
;	  R_M3 = negative flag (0 or B7)
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
ExecGto8:
	call	CalcUnstackW	; load word from the stack
	movw	r26,r24
	brcs	ExecGto9	; overflow
	breq	ExecGto2	; not negative
ExecGto9:
	jmp	Fatal		; invalid address

; ----------------------------------------------------------------------------
;                               GTO (0x61)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecGto
ExecGto:

; ----- load address
; OUTPUT: R27:R26 (X) = relative decimal address 0..1665 (should be max. 1599 or 999)
;			or key*256 (if high byte is > 15)
;	  R1 = 0
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
	call	LoadAddr
ExecGto2:
	rcall	ExecGoSbr	; find label, check address

; ----- save new address

	std	Y+DATA_ADDR,r26
	std	Y+DATA_ADDR+1,r27
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                           Pause (0x66)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecPause
ExecPause:

	; only if running
	IFN_RUNNING		; if not running
	ret			; return if not running

	; temporary disable runnung
	CLR_RUNNING

	; display
	rcall	Disp

	; wait for a while
	call	Wait250ms

	; return running flag
	SET_RUNNING

	; display C again
	rjmp	DispC

; ----------------------------------------------------------------------------
;                           x=t (0x67)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecEqu
ExecEqu:
	push	r23

	; stop edit mode, validate X and display C if not running
	rcall	_EditStop	; stop edit mode

	; compare registers X and T if equal
	rcall	_Calc		; calculator
	.byte	C_GETMEM(REG_X)	; load X
	.byte	C_GETMEM(REG_T)	; load T
	.byte	C_SUB		; subtract to compare
	.byte	C_END
	.balign 2

; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
	call	CalcTopCheck	; check zero

ExecEqu2: ; here is 0 = base condition is TRUE
	pop	r23

	breq	2f		; result is 0, numbers are equal

	; numbers are not equal, check INV
	tst	r23		; INV flag?	
	brne	6f		; INV flag is set, different numbers are OK

	; false condition, no jump, only skip address
; OUTPUT: R27:R26 (X) = relative decimal address 0..1665 (should be max. 1599 or 999)
;			or key*256 (if high byte is > 15)
;	  R1 = 0
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
4:	call	CalcDel		; delete result of comparison
	jmp	LoadAddr

	; number are equal, check INV
2:	tst	r23		; INV flag?
	brne	4b		; INV flag is set, equal numbers are not OK

	; condition is OK, jump
6:	call	CalcDel		; delete result of comparison
	rjmp	ExecGto

; ----------------------------------------------------------------------------
;                           x>=t (0x77)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecGre
ExecGre:

	push	r23

	; stop edit mode, validate X and display C if not running
	rcall	_EditStop	; stop edit mode

	; compare registers X and T if equal
	rcall	_Calc		; calculator
	.byte	C_GETMEM(REG_X)	; load X
	.byte	C_GETMEM(REG_T)	; load T
	.byte	C_SUB		; subtract to compare
	.byte	C_END
	.balign 2

	call	CalcTop		; get top number
	ldd	r24,Z+2		; get mantissa high
	andi	r24,B7		; check sign

	rjmp	ExecEqu2	; 0 if base condition is TRUE, x>=t

; ----------------------------------------------------------------------------
;                           If (0x7A), If Ind (0x6D)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecIfInd
ExecIfInd:

.global ExecIf
ExecIf:

	push	r24		; key code

; ----- prepare 1st operand
; OUTPUT: R31:R30 = register address
;	 R25 = operation code
;	 R24 = register index
	rcall	ExecRegPrep1

; ----- indirect 1st operand

	pop	r24		; key code
	push	r24

	cpi	r24,KEY_IF_IND	; indirect address?
	brne	ExecIf2		; no

; INPUT: R31:R30 = register address
; OUTPUT: R31:R30 = register address
; saves R25
	rcall	ExecRegPrep2

; ----- prepare address of 2nd operand -> R27:R26

ExecIf2:
	cpi	r25,0	; mem <= c
	breq	2f
	cpi	r25,7	; mem > c
	breq	2f
	cpi	r25,8	; hir <= c
	breq	2f
	cpi	r25,0xf	; hir > c
	brne	ExecIf3

; ----- load 2nd operand if it is constant
; INPUT: R31:R30 = address of 1st register
; OUTPUT: CY = break
; saves R25, R31:R30
2:	rcall	ExecRegPrep6

ExecIf22:
	pop	r24		; key code
	brcc	ExecIf5		; OK
	ret			; break

ExecIf3:
; INPUT: R25 = operation code, bit 3 = use HIR register
; OUTPUT: R27:R26 = address of 2nd register
;	 CY = break
	rcall	ExecRegPrep3
	brcs	ExecIf22	; break

; ----- 2nd operand is indirect

	pop	r24		; key code
	cpi	r24,KEY_IF_IND	; indirect?
	brne	ExecIf4		; no

; INPUT: R27:R26 = address of 2nd register
; OUTPUT: R27:R26 = register address
	rcall	ExecRegPrep4

; ----- load numbers into stack (Z=1st operand, X=2nd operand)
; INPUT: R31:R30 = address of 1st number
;	 R27:R26 = address of 2nd number
; Saves R25, R31:R30, R27:R26
ExecIf4:
	rcall	ExecRegPrep5

ExecIf5:
	andi	r25,7		; operation

; ----- operation code

	ldi	r30,lo8(ExecIfTab)
	ldi	r31,hi8(ExecIfTab)
	add	r30,r25
	adc	r31,R_ZERO
	lpm	r24,Z

; ----- compare operands

	call	CalcCmp

; ----- check if jump
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB
	tst	r24
	breq	4f		; invalid

	rjmp	ExecGto		; jump

; ----- invalid condition, only skip address

4:	jmp	LoadAddr


; ----- prepare 1st operand of If and Reg
; OUTPUT: R31:R30 = register address
;	 R25 = operation code
;	 R24 = register index
ExecRegPrep1:

; ----- load parameter (2 HEX digits)
; OUTPUT: R24 = byte
; DESTROYS: R25
	call	Load2Hex
	mov	r25,r24		; save operation code
	swap	r25
	andi	r25,0x0f	; operation code
	andi	r24,0x0f	; register index

; ----- prepare destination operand -> R31:R30

	sbrc	r25,3		; memory registers?
	rjmp	2f		; no

; INPUT: R24 = index of variable 0..MEM_NUM-1
; OUTPUT: R31:R30 = address of variable
;	  R1 = 0
; DESTROYS: R0
	subi	r24,-USER_FIRST
	jmp	CalcAddrMem	; get register address

	; HIR register
2:	ldi	r30,NUM_BYTES	; bytes per number
	mul	r24,r30		; offset of number
	movw	r30,r0		; offset of number
	clr	r1		; restore R1 (R_ZERO)
	subi	r30,lo8(-(HirReg)) ; address of variable
	sbci	r31,hi8(-(HirReg))
	ret


; ----- prepare 1st operand indirect
; INPUT: R31:R30 = register address
; OUTPUT: R31:R30 = register address
; saves R25

ExecRegPrep2:

	push	r25
	call	CalcGetMemZ	; load register R31:R30 into stack
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; get number
	pop	r25

	cpi	r24,USER_NUM	; check memory index
	brcc	ExecRegPrepErr	; error

	subi	r24,-USER_FIRST
; INPUT: R24 = index of variable 0..MEM_NUM-1
; OUTPUT: R31:R30 = address of variable
;	  R1 = 0
; DESTROYS: R0
	jmp	CalcAddrMem	; get register address


; ----- prepare 2nd operand of If and Reg
; INPUT: R25 = operation code, bit 3 = use HIR register
; OUTPUT: R27:R26 = address of 2nd register
;	 CY = break

ExecRegPrep3:

	push	r30
	push	r31

; OUTPUT: R24 = typically 0..159 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
	push	r25
	call	Load2Dig	; load 2 digits, with indirect from keyboard
	pop	r25

	brcs	1f		; error

	cpi	r24,USER_NUM	; max. memory
	brcs	2f		; OK

ExecRegPrepErr:
	jmp	Fatal

1:	pop	r31
	pop	r30
	sec			; break
	ret

2:	sbrs	r25,3		; memory register?
	rjmp	3f		; memory

	; HIR register
	cpi	r24,HIR_NUM
	brcc	ExecRegPrepErr	; error

	ldi	r26,NUM_BYTES	; bytes per number
	mul	r24,r26		; offset of number
	movw	r26,r0		; offset of number
	clr	r1		; restore R1 (R_ZERO)
	subi	r26,lo8(-(HirReg)) ; address of variable
	sbci	r27,hi8(-(HirReg))
	rjmp	5f

3:	subi	r24,-USER_FIRST
; INPUT: R24 = index of variable 0..MEM_NUM-1
; OUTPUT: R31:R30 = address of variable
;	  R1 = 0
; DESTROYS: R0
	call	CalcAddrMem	; get register address
	movw	r26,r30		; R27:R26 <- address

5:	pop	r31
	pop	r30
	clc			; OK
	ret

; ----- prepare 2nd operand indirect
; INPUT: R27:R26 = address of 2nd register
; OUTPUT: R27:R26 = register address

ExecRegPrep4:

	push	r25
	push	r30
	push	r31

	movw	r30,r26
	call	CalcGetMemZ	; load register R31:R30 into stack
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; get number

	cpi	r24,USER_NUM	; check memory index
	brcc	ExecRegPrepErr	; error

	subi	r24,-USER_FIRST
; INPUT: R24 = index of variable 0..MEM_NUM-1
; OUTPUT: R31:R30 = address of variable
;	  R1 = 0
; DESTROYS: R0
	call	CalcAddrMem	; get register address
	movw	r26,r30

	pop	r31
	pop	r30
	pop	r25
	ret

; ----- load numbers into stack (Z=1st operand, X=2nd operand)
; INPUT: R31:R30 = address of 1st number
;	 R27:R26 = address of 2nd number
; Saves R25, R31:R30, R27:R26

ExecRegPrep5:
	push	r25

	push	r30
	push	r31
	push	r26
	push	r27

; INPUT: R31:R30 = register address
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	call	CalcGetMemZ	; load 1st number into stack

	pop	r27
	pop	r26
	pop	r31
	pop	r30

	push	r30
	push	r31
	push	r26
	push	r27

	movw	r30,r26
; INPUT: R31:R30 = register address
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	call	CalcGetMemZ	; load 2nd number into stack

	pop	r27
	pop	r26
	pop	r31
	pop	r30

	pop	r25
	ret

; ----- load 2nd operand if it is constant
; INPUT: R31:R30 = address of 1st register
; OUTPUT: CY = break
; saves R25, R31:R30

ExecRegPrep6:
	push	r30
	push	r31
	push	r25

; INPUT: R31:R30 = register address
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	call	CalcGetMemZ	; load 1st number into stack

; OUTPUT: R24 = typically 0..159 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
	call	Load2Dig	; load 2 digits, with indirect from keyboard
	brcs	5f		; break
	
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	call	CalcStackB	; stack byte R24
	clc			; OK

5:	pop	r25
	pop	r31
	pop	r30
	ret

; ----------------------------------------------------------------------------
;                           Reg (0x8A), Reg Ind (0x6C)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecRegInd
ExecRegInd:

.global ExecReg
ExecReg:

	push	r23		; INV flag
	push	r24		; key code

; ----- prepare 1st operand
; OUTPUT: R31:R30 = register address
;	 R25 = operation code
;	 R24 = register index
	rcall	ExecRegPrep1

; ----- indirect register

	sbrs	r25,2		; indirect address?
	rjmp	ExecReg2	; no

; INPUT: R31:R30 = register address
; OUTPUT: R31:R30 = register address
; saves R25
	rcall	ExecRegPrep2

; ----- prepare address of 2nd operand -> R27:R26

ExecReg2:
	sbrc	r25,0	; skip if bit 0 is cleared
	sbrs	r25,1	; skip if bit 1 is set
	rjmp	ExecReg3 ; not constant (operation is not = 3)

; ----- load 2nd operand if it is constant
; INPUT: R31:R30 = address of 1st register
; OUTPUT: CY = break
; saves R25, R31:R30
	rcall	ExecRegPrep6

	pop	r24		; key code
	brcc	ExecReg5	; OK
ExecReg22:
	pop	r23
	ret			; break

	; 2nd operand is memory
; INPUT: R25 = operation code, bit 3 = use HIR register
; OUTPUT: R27:R26 = address of 2nd register
;	 CY = break
ExecReg3:
	rcall	ExecRegPrep3
	pop	r24		; key code
	brcs	ExecReg22	; break

; ----- 2nd operand is indirect

	cpi	r24,KEY_REG_IND	; indirect?
	brne	4f		; no

; INPUT: R27:R26 = address of 2nd register
; OUTPUT: R27:R26 = register address
	rcall	ExecRegPrep4

; ----- load numbers into stack (Z=1st operand, X=2nd operand)
; INPUT: R31:R30 = address of 1st number
;	 R27:R26 = address of 2nd number
; Saves R25, R31:R30, R27:R26

4:	rcall	ExecRegPrep5

; ----- prepare operation

ExecReg5:
	pop	r23

	; add inversion flag as bit 2
	andi	r25,3
	tst	r23
	breq	2f
	ori	r25,4

; ----- do operation

2:	push	r30
	push	r31

	; 0: MOV
	cpi	r25,0
	brne	2f
	call	CalcExc
	call	CalcDel
	rjmp	ExecReg8

	; 1: SUM
2:	cpi	r25,1
	brne	2f
	call	CalcAdd
	rjmp	ExecReg8

	; 2: Prd
2:	cpi	r25,2
	brne	2f
	call	CalcMul
	rjmp	ExecReg8

	; 3: const
2:	cpi	r25,3
	brne	2f
	call	CalcExc
	rjmp	ExecReg7

	; 4: Exc
2:	cpi	r25,4
	brne	2f
	push	r26
	push	r27
	call	CalcExc
	pop	r27
	pop	r26
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	call	CalcTop
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	call	CalcCopyNum	; copy number from Z to X
ExecReg7:
	call	CalcDel
	rjmp	ExecReg8

	; 5: Inv SUM
2:	cpi	r25,5
	brne	2f
	call	CalcSub
	rjmp	ExecReg8

	; 6: INV Prd
2:	cpi	r25,6
	brne	2f
	call	CalcDiv
	rjmp	8f

	; 7: const negate
2:	call	CalcExc
	call	CalcDel
	call	CalcNeg

; ----- save result

ExecReg8:
	pop	r27
	pop	r26

; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	call	CalcTop
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	call	CalcCopyNum	; copy number from Z to X
	jmp	CalcDel

; ----------------------------------------------------------------------------
;                           Nop (0x68)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecNop
ExecNop:
	ret

; ----------------------------------------------------------------------------
;                           REL (0x6A)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecRel
ExecRel:

	push	r23

	; load 2 digits (jump offset)
; OUTPUT: R24 = typically 0..159 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
	call	Load2Dig

	; destination address
	ldd	r26,Y+DATA_ADDR
	ldd	r27,Y+DATA_ADDR+1

	pop	r23		; INV flag
	tst	r23		; jump back?
	breq	2f		; jump forward

	; jump back
	sub	r26,r24
	sbc	r27,R_ZERO
	rjmp	ExecRel2

	; jump forward
2:	add	r26,r24
	adc	r27,R_ZERO

	; check address
ExecRel2:
	ldd	r24,Y+DATA_PROGBEG ; program start
	ldd	r25,Y+DATA_PROGBEG+1
	cp	r26,r24
	cpc	r27,r25
	brcs	4f		; invalid address

	ldd	r24,Y+DATA_PROGEND ; program end
	ldd	r25,Y+DATA_PROGEND+1
	cp	r26,r24
	cpc	r27,r25
	brcs	6f		; address is OK

; ----- invalid address

4:	call	CalcError	; set error flag
	rjmp	StopProg	; stop program

; ----- save new address

6:	std	Y+DATA_ADDR,r26
	std	Y+DATA_ADDR+1,r27
; DESTROYS: R0
	ret

; ----------------------------------------------------------------------------
;                           Rad (0x70)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecRad
ExecRad:
	ldi	r24,UNIT_RAD
	rjmp	ExecDeg2

; ----------------------------------------------------------------------------
;                      RTN (0x92) - return from program
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; DESTROYS: R31, R30, R27..R24
; ----------------------------------------------------------------------------

.global ExecRtn
ExecRtn:

; ----- stop program on base level

	ldd	r24,Y+DATA_PROGLEVEL	; current level of program stack
	tst	r24
	brne	2f			; not base level

.global StopProg
StopProg:
	CLR_RUNNING		; clear running flag

	rcall	ClrPrintBuf	; clear print buffer
; DESTROYS: R0
	rjmp	Disp		; display all

; ----- decrease current level

2:	dec	r24		; decrease current level
	std	Y+DATA_PROGLEVEL,r24 ; save new level

; ----- return program address

	ldi	r30,lo8(ProgStackAddr)
	ldi	r31,hi8(ProgStackAddr)
	add	r30,r24
	adc	r31,R_ZERO
	add	r30,r24
	adc	r31,R_ZERO
	ld	r0,Z+
	ld	r31,Z
	std	Y+DATA_ADDR,r0	; return address
	std	Y+DATA_ADDR+1,r31

; ----- open old program
; INPUT: R24 = program index (0=main)
; DESTROYS: R31, R30, R24, R0
	ldi	r30,lo8(ProgStackInx)
	ldi	r31,hi8(ProgStackInx)
	add	r30,r24
	adc	r31,R_ZERO
	ld	r24,Z
	jmp	OpenProg

; ----------------------------------------------------------------------------
;                            A...E'', F (0x10..0x1f)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecSbrLab
ExecSbrLab:
	mov	r27,r24		; key code
	clr	r26
	rjmp	ExecSbr2

; ----------------------------------------------------------------------------
;                          SBR Ind (0x26)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecSbrInd
ExecSbrInd:

; ----- get address
; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20
	rcall	ExecMemNum	; get memory index, with indirect from keyboard
	brcs	ExecGoSbr9	; error

; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load number into stack

; OUTPUT: R25:R24 = unsigned integer
;	  R_M3 = negative flag (0 or B7)
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
ExecSbr8:
	call	CalcUnstackW	; load word from the stack
	movw	r26,r24
	brcs	ExecGoSbr9	; overflow
	brne	ExecGoSbr9	; negative
	rjmp	ExecSbr2

; ----------------------------------------------------------------------------
;                               SBR (0x71)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecSbr
ExecSbr:

; ----- substitute by return

	brne	ExecRtn		; INV set, usert RTN

; ----- load address
; OUTPUT: R27:R26 (X) = relative decimal address 0..1665 (should be max. 1599 or 999)
;			or key*256 (if high byte is > 15)
;	  R1 = 0
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
1:	call	LoadAddr
ExecSbr2:

; ----- switch to new program

	ldd	r24,Y+DATA_PROGINX ; index of current program
	push	r24
	ldd	r24,Y+DATA_PROGNEXT
; INPUT: R24 = program index (0=main)
; DESTROYS: R31, R30, R24, R0
	call	OpenProg	; open program

; ----- find label, check address

	rcall	ExecGoSbr2	; find label, check address

; ----- save current address into stack

	; increase stack level
	IFN_RUNNING		; if not running
	std	Y+DATA_PROGLEVEL,R_ZERO ; clear current level if not running
	ldd	r24,Y+DATA_PROGLEVEL ; current level in stack
	cpi	r24,PROGSTACK_NUM ; check max. level
	brcc	ExecGoSbr9	; stack overflow - go to Fatal
	inc	r24		; increase level
	IF_RUNNING		; if not running, do not increase current level
	std	Y+DATA_PROGLEVEL,r24

	; save index of current program (R24 = level + 1)
	ldi	r30,lo8(ProgStackInx-1) ; program indices
	ldi	r31,hi8(ProgStackInx-1)
	add	r30,r24
	adc	r31,R_ZERO	; address of entry
	pop	r25		; old index of current program
	st	Z,r25		; save index

	; save address of current program
	add	r24,r24		; current level * 2
	ldi	r30,lo8(ProgStackAddr-2) ; program addresses
	ldi	r31,hi8(ProgStackAddr-2)
	add	r30,r24
	adc	r31,R_ZERO	; address of entry
	ldd	r25,Y+DATA_ADDR	; current address
	st	Z+,r25		; save address
	ldd	r25,Y+DATA_ADDR+1
	st	Z,r25

; ----- save new address

	std	Y+DATA_ADDR,r26
	std	Y+DATA_ADDR+1,r27

; ----- if not running, run program and display C

	IF_RUNNING		; if running
	ret

	SET_RUNNING		; set running flag
	rcall	DispC		; display C
	jmp	Wait100ms	; short delay

; ----------------------------------------------------------------------------
;  local function for ExecGto and ExecSbr
; ----------------------------------------------------------------------------

ExecGoSbr:

; ----- find label

ExecGoSbr2:
	cpi	r27,16		; label?
	brcs	2f		; address is valid

; INPUT: R24 = label
; OUTPUT: R27:R26 = absolute address
; DESTROYS: -
	mov	r24,r27		; label
	call	FindLab
	brcc	3f		; label found OK
ExecGoSbr9:
	jmp	Fatal		; invalid address

; ----- convert relative address to absolute

2:	ldd	r24,Y+DATA_PROGBEG
	add	r26,r24
	ldd	r24,Y+DATA_PROGBEG+1
	adc	r27,r24

; ----- check if address is valid

3:	ldd	r24,Y+DATA_PROGBEG
	ldd	r25,Y+DATA_PROGBEG+1
	cp	r26,r24
	cpc	r27,r25
	brcs	ExecGoSbr9	; invalid address

	ldd	r24,Y+DATA_PROGEND
	ldd	r25,Y+DATA_PROGEND+1
	cp	r26,r24
	cpc	r27,r25
	brcc	ExecGoSbr9	; invalid address
	ret

; ----------------------------------------------------------------------------
;                           Lbl (0x76)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecLbl
ExecLbl:

	; restore INV flag
	breq	2f		; INV flag not set
	rcall	FlagSetInv	; set INV flag
; DESTROYS: -
	rcall	DispFlags	; display flags

2:
	; skip label, if running
	IF_RUNNING
; OUTPUT: R24 = byte (0 on error)
;	  CY = invalid address (address not changed)
; DESTROYS: -
	jmp	LoadPrg		; load byte of progam, increment address
	ret

; ----------------------------------------------------------------------------
;                           Stat+ (0x78)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------
; input: y in RegX, x in RegT
; output: N in RegX, x+1 in RegT
;  mem 1: sum y
;  mem 2: sum y^2
;  mem 3: N
;  mem 4: sum x
;  mem 5: sum x^2
;  mem 6: sum x*y

.global ExecStat
ExecStat:

	breq	4f		; INV not set

; ----- INV set, subtract number

	rcall	_EditStop	; stop edit mode

	rcall	_Calc		; calculator
	; mem1 -= y
	.byte	C_GETMEM(MEM_1) ; load mem 1 (m1)
	.byte	C_GETMEM(REG_X) ; load Y from reg. x (m1,y)
	.byte	C_SUB		; subtract (m1-y)
	.byte	C_SETMEMDEL(MEM_1) ; save mem 1 ()
	; mem2 -= y^2
	.byte	C_GETMEM(MEM_2) ; load mem 2 (m2)
	.byte	C_GETMEM(REG_X) ; load Y from reg. x (m2,y)
	.byte	C_SQR		; square (m2,y^2)
	.byte	C_SUB		; subtract (m2-y^2)
	.byte	C_SETMEMDEL(MEM_2) ; save mem 2 ()
	; mem3 -= 1
	.byte	C_GETMEM(MEM_3) ; load mem 3 (m3)
	.byte	C_DEC		; decrement (m3-1)
	.byte	C_SETMEMDEL(MEM_3) ; save mem 3 ()
	; mem4 -= x
	.byte	C_GETMEM(MEM_4) ; load mem 4 (m4)
	.byte	C_GETMEM(REG_T) ; load X from reg. t (m4,x)
	.byte	C_SUB		; subtract (m4-x)
	.byte	C_SETMEMDEL(MEM_4) ; save mem 4 ()
	; mem5 -= x^2
	.byte	C_GETMEM(MEM_5) ; load mem 5 (m5)
	.byte	C_GETMEM(REG_T) ; load X from reg. t (m5,x)
	.byte	C_SQR		; square (m5,x^2)
	.byte	C_SUB		; subtract (m5-x^2)
	.byte	C_SETMEMDEL(MEM_5) ; save mem 5 ()
	; mem6 -= x*y
	.byte	C_GETMEM(MEM_6) ; load mem 6 (m6)
	.byte	C_GETMEM(REG_T) ; load X from reg. t (m6,x)
	.byte	C_GETMEM(REG_X) ; load Y from reg. x (m6,x,y)
	.byte	C_MUL		; multiply (m6,x*y)
	.byte	C_SUB		; subtract (m6-x*y)
	.byte	C_SETMEMDEL(MEM_6) ; save mem 6 ()
	; load reg X from mem 3
	.byte	C_GETMEM(MEM_3) ; load mem 3 (m3)
	.byte	C_SETMEMDEL(REG_X) ; save reg X
	; decrement X (reg T)
	.byte	C_GETMEM(REG_T) ; load X from reg. t (x)
	.byte	C_DEC		; decrement (x-1)
	.byte	C_SETMEMDEL(REG_T) ; save reg t
	.byte	C_END
	.balign 2

	rjmp	Disp		; display

; ----- INV not set, add number

4:	rcall	_EditStop	; stop edit mode

	rcall	_Calc		; calculator
	; mem1 += y
	.byte	C_GETMEM(MEM_1) ; load mem 1 (m1)
	.byte	C_GETMEM(REG_X) ; load Y from reg. x (m1,y)
	.byte	C_ADD		; add (m1+y)
	.byte	C_SETMEMDEL(MEM_1) ; save mem 1 ()
	; mem2 += y^2
	.byte	C_GETMEM(MEM_2) ; load mem 2 (m2)
	.byte	C_GETMEM(REG_X) ; load Y from reg. x (m2,y)
	.byte	C_SQR		; square (m2,y^2)
	.byte	C_ADD		; add (m2+y^2)
	.byte	C_SETMEMDEL(MEM_2) ; save mem 2 ()
	; mem3 += 1
	.byte	C_GETMEM(MEM_3) ; load mem 3 (m3)
	.byte	C_INC		; increment (m3+1)
	.byte	C_SETMEMDEL(MEM_3) ; save mem 3 ()
	; mem4 += x
	.byte	C_GETMEM(MEM_4) ; load mem 4 (m4)
	.byte	C_GETMEM(REG_T) ; load X from reg. t (m4,x)
	.byte	C_ADD		; add (m4+x)
	.byte	C_SETMEMDEL(MEM_4) ; save mem 4 ()
	; mem5 += x^2
	.byte	C_GETMEM(MEM_5) ; load mem 5 (m5)
	.byte	C_GETMEM(REG_T) ; load X from reg. t (m5,x)
	.byte	C_SQR		; square (m5,x^2)
	.byte	C_ADD		; add (m5+x^2)
	.byte	C_SETMEMDEL(MEM_5) ; save mem 5 ()
	; mem6 += x*y
	.byte	C_GETMEM(MEM_6) ; load mem 6 (m6)
	.byte	C_GETMEM(REG_T) ; load X from reg. t (m6,x)
	.byte	C_GETMEM(REG_X) ; load Y from reg. x (m6,x,y)
	.byte	C_MUL		; multiply (m6,x*y)
	.byte	C_ADD		; add (m6+x*y)
	.byte	C_SETMEMDEL(MEM_6) ; save mem 6 ()
	; load reg X from mem 3
	.byte	C_GETMEM(MEM_3) ; load mem 3 (m3)
	.byte	C_SETMEMDEL(REG_X) ; save reg X
	; increment X (reg T)
	.byte	C_GETMEM(REG_T) ; load X from reg. t (x)
	.byte	C_INC		; increment (x+1)
	.byte	C_SETMEMDEL(REG_T) ; save reg t
	.byte	C_END
	.balign 2

	rjmp	Disp		; display

; ----------------------------------------------------------------------------
;                           Avrg x, Mean (0x79)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------
; output: average y in RegX, average x in RegT (average, arithmetic mean)
; inv output: standard deviation y in RegX, standard deviation x in RegT
;    standard deviation x = sqrt((sum(x^2) - sum(x)^2/N)/(N-1))
;    standard deviation y = sqrt((sum(y^2) - sum(y)^2/N)/(N-1))
;    (op 11) variation x ^2 = sum(x^2)/N - (sum(x)/N)^2
;  mem 1: sum y
;  mem 2: sum y^2
;  mem 3: N
;  mem 4: sum x
;  mem 5: sum x^2
;  mem 6: sum x*y

.global ExecAvrg ; Mean
ExecAvrg:

	breq	4f		; INV not set

; ----- INV set, standard deviation [x,y] ([RegT, RegX])

	rcall	_EditStop	; stop edit mode

	rcall	_Calc		; calculator
	; standard deviation x = sqrt((sum(x^2) - sum(x)^2/N)/(N-1))
	.byte	C_GETMEM(MEM_5)	; load mem 5 = sum x^2 (m5)
	.byte	C_GETMEM(MEM_4)	; load mem 4 = sum x (m5,m4)
	.byte	C_SQR		; square (m5,m4^2)
	.byte	C_GETMEM(MEM_3) ; load mem 3 = N (m5,m4^2,N)
	.byte	C_DIV		; divide (m5,m4^2/N)
	.byte	C_SUB		; subtract (m5-m4^2/N)
	.byte	C_GETMEM(MEM_3) ; load mem 3 = N (m5-m4^2/N,N)
	.byte	C_DEC		; decrement (m5-m4^2/N,N-1)
	.byte	C_DIV		; divide
	.byte	C_SQRT		; square root
	.byte	C_SETMEMDEL(REG_T) ; save deviation into T
	; standard deviation y = sqrt((sum(y^2) - sum(y)^2/N)/(N-1))
	.byte	C_GETMEM(MEM_2)	; load mem 2 = sum y^2 (m2)
	.byte	C_GETMEM(MEM_1)	; load mem 1 = sum y (m2,m1)
	.byte	C_SQR		; square (m2,m1^2)
	.byte	C_GETMEM(MEM_3) ; load mem 3 = N (m2,m1^2,N)
	.byte	C_DIV		; divide (m2,m1^2/N)
	.byte	C_SUB		; subtract (m2-m1^2/N)
	.byte	C_GETMEM(MEM_3) ; load mem 3 = N (m2-m1^2/N,N)
	.byte	C_DEC		; decrement (m2-m1^2/N,N-1)
	.byte	C_DIV		; divide
	.byte	C_SQRT		; square root
	.byte	C_SETMEMDEL(REG_X) ; save deviation into X
	.byte	C_END
	.balign 2

	rjmp	Disp		; display

; ----- INV not set, average [x,y] ([RegT, RegX])

4:	rcall	_EditStop	; stop edit mode

	rcall	_Calc		; calculator
	; average x
	.byte	C_GETMEM(MEM_4)	; load mem 4 = sum x (m4)
	.byte	C_GETMEM(MEM_3) ; load mem 3 = N (m4,N)
	.byte	C_DIV		; divide (m4/N)
	.byte	C_SETMEMDEL(REG_T) ; save average into T
	; average y
	.byte	C_GETMEM(MEM_1)	; load mem 1 = sum y (m1)
	.byte	C_GETMEM(MEM_3) ; load mem 3 = N (m1,N)
	.byte	C_DIV		; divide (m1/N)
	.byte	C_SETMEMDEL(REG_X) ; save average into X

	.byte	C_END
	.balign 2

	rjmp	Disp		; display

; ----------------------------------------------------------------------------
;                           Grad (0x80)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecGrad
ExecGrad:
	ldi	r24,UNIT_GRAD
	rjmp	ExecDeg2

; ----------------------------------------------------------------------------
;                           RST (0x81)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecRst
ExecRst:
	std	Y+DATA_PROGLEVEL,R_ZERO ; clear program level

	; reset flags
	std	Y+DATA_USERFLAGS,R_ZERO
	std	Y+DATA_USERFLAGS+1,R_ZERO

	; stop program if running from module
	ldd	r24,Y+DATA_PROGINX ; current program index
	tst	r24		; main program?
	breq	2f		; main program

	CLR_RUNNING		; clear running flag

	; open Main program
	clr	r24
; INPUT: R24 = program index (0=main)
; DESTROYS: R31, R30, R24, R0
	call	OpenProg

; ----- reset address to start of program

2:	ldd	r24,Y+DATA_PROGBEG ; program begin
	std	Y+DATA_ADDR,r24 ; reset address
	ldd	r24,Y+DATA_PROGBEG+1
	std	Y+DATA_ADDR+1,r24
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                         HIR (0x82), HIR Ind (0x27)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecHirInd
ExecHirInd:

.global ExecHir
ExecHir:

	push	r24

; ----- load parameter (2 HEX digits)
; OUTPUT: R24 = byte
; DESTROYS: R25

	call	Load2Hex

; ----- prepare address of the number -> R27:R26

	mov	r25,r24		; byte
	andi	r25,0x0f	; low nibble
	ldi	r26,NUM_BYTES	; bytes per number
	mul	r25,r26		; offset of number
	movw	r26,r0		; offset of number
	subi	r26,lo8(-(HirReg)) ; address of variable
	sbci	r27,hi8(-(HirReg))
	clr	r1		; clear R_ZERO

	pop	r25

; ----- indirect

	cpi	r25,KEY_HIR_IND
	brne	ExecHir2

	push	r24

	movw	r30,r26
	call	CalcGetMemZ	; load register R31:R30 into stack
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; get number

	cpi	r24,USER_NUM	; check memory index
	brcs	1f
	jmp	Fatal		; error

1:	subi	r24,-USER_FIRST
; INPUT: R24 = index of variable 0..MEM_NUM-1
; OUTPUT: R31:R30 = address of variable
;	  R1 = 0
; DESTROYS: R0
	call	CalcAddrMem	; get register address
	movw	r26,r30

	pop	r24

; ----- save pointer to the number

ExecHir2:
	push	r26
	push	r27

	push	r24		; byte

; ----- load number into stack
	
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
	call	CalcCopyNum	; copy number from Z to X

; ----- switch to operation

	pop	r24
	andi	r24,0xf0	; operation code

	; 0x: STO
	brne	1f
	call	CalcDel		; delete old number
	rcall	_EditStop	; stop edit mode, validate X
	ldi	r24,REG_X	; register X
	rcall	_CalcGetMem	; load X into stack
	rjmp	ExecHir9

	; 1x: RCL
1:	cpi	r24,0x10
	brne	2f
	rcall	_EditStop	; stop edit mode, validate X
	ldi	r24,REG_X	; register X
	call	CalcSetMem	; save X
	rjmp	ExecHir9

	; 2x: Round
2:	cpi	r24,0x20
	brne	3f
	call	CalcRound
	rjmp	ExecHir9

	; 3x: SUM
3:	cpi	r24,0x30
	brne	4f
	rcall	_EditStop	; stop edit mode, validate X
	ldi	r24,REG_X	; register X
	rcall	_CalcGetMem	; load X into stack
	call	CalcAdd		; add
	rjmp	ExecHir9

	; 4x: Prd
4:	cpi	r24,0x40
	brne	5f
	rcall	_EditStop	; stop edit mode, validate X
	ldi	r24,REG_X	; register X
	rcall	_CalcGetMem	; load X into stack
	call	CalcMul		; multiply
	rjmp	ExecHir9

	; 5x: INV SUM
5:	cpi	r24,0x50
	brne	6f
	rcall	_EditStop	; stop edit mode, validate X
	ldi	r24,REG_X	; register X
	rcall	_CalcGetMem	; load X into stack
	call	CalcSub		; sub
	rjmp	ExecHir9

	; 6x: INV Prd
6:	cpi	r24,0x60
	brne	7f
	rcall	_EditStop	; stop edit mode, validate X
	ldi	r24,REG_X	; register X
	rcall	_CalcGetMem	; load X into stack
	call	CalcDiv		; divide
	rjmp	ExecHir9

	; 7x: Inc
7:	cpi	r24,0x70
	brne	8f
	call	CalcInc		; increment
	rjmp	ExecHir9

	; 8x: Dec
8:	cpi	r24,0x80
	brne	1f
	call	CalcDec		; decrement
	rjmp	ExecHir9

	; 9x: Exc
1:	cpi	r24,0x90
	brne	2f
	rcall	_EditStop	; stop edit mode, validate X
	ldi	r24,REG_X	; register X
	rcall	_CalcGetMem	; load X into stack
	call	CalcExc		; exchange
	rcall	_CalcSetMemDelX	; save X
	rjmp	ExecHir9

	; Cx: x<=0
2:	cpi	r24,0xC0
	brne	3f
	call	CalcGr0		; check if number is > 0
	rjmp	7f

	; Dx: x>0
3:	cpi	r24,0xD0
	brne	4f
	call	CalcLtEq0	; check if number is <= 0
7:	pop	r27
	pop	r26
	rjmp	ExecHir6	; do jump

	; Ex: DJNZ (DSZ)
4:	cpi	r24,0xE0
	brne	5f
	ldi	r24,CONST_0
	rjmp	ExecHir5

	; Fx: DJZ (INV DSZ)
5:	cpi	r24,0xF0
	brne	6f
	ldi	r24,CONST_1
ExecHir5:
	call	CalcConst	; add constant 1 (= INV)
	call	CalcExc		; exchange registers
; ----- inc/dec register
; stack INPUT: inv, x
; stack OUTPUT: 0/1, x2
	rcall	DjnzReg

	pop	r27
	pop	r26
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	call	CalcTop		; get top number
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	call	CalcCopyNum	; copy number from Z to X
	call	CalcDel		; delete number

ExecHir6:

; ----- get operation result
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; load result
	tst	r24		; check if skip condition is TRUE
	brne	5f		; condition is TRUE

	; skip condition is FALSE, loop jump
	rjmp	ExecGto

	; skip condition is TRUE, skip address
5:	jmp	LoadAddr	; load address

	; Ax: GTO
6:	pop	r27
	pop	r26

	cpi	r24,0xA0
	brne	7f
	rjmp	ExecGto8

	; Bx: SBR
7:	rjmp	ExecSbr8

; ----- save new number

ExecHir9:
	pop	r27
	pop	r26
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	call	CalcTop		; get top number
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	call	CalcCopyNum	; copy number from Z to X
	call	CalcDel		; delete number
	rjmp	Disp		; display

; ----------------------------------------------------------------------------
;                            St Flg (0x86)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecStFlg
ExecStFlg:

	breq	4f		; INV not set

; ----- INV set, clear flag

	; load flag index
; OUTPUT: R24 = typically digit 0..15 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
	call	Load1Dig
	brcs	9f

	cpi	r24,16		; check index
	brcc	8f		; invalid flag

	jmp	UserFlagClr	; clear user flag

; ----- INV not set, set flag

	; load flag index
; OUTPUT: R24 = typically digit 0..15 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
4:	call	Load1Dig
	brcs	9f

	cpi	r24,16		; check index
	brcc	8f		; invalid flag

	jmp	UserFlagSet	; set user flag


	; invalid flag
8:	call	CalcError
9:	ret

; ----------------------------------------------------------------------------
;                            If Flg (0x87)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecIfFlg
ExecIfFlg:

	breq	4f		; INV not set

; ----- INV set, jump if flag not set

	; load flag index
; OUTPUT: R24 = typically digit 0..15 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
	call	Load1Dig
	brcs	9f

	cpi	r24,16		; check index
	brcc	7f		; invalid flag

	; test flag
; INPUT: R24 = index of user flag (0..15)
; OUTPUT: R24 = flag state (1 or 0)
;	  Z flag set if bit not set (breq = not set '0', brne = set '1')
	call	UserFlagTest	; test flag
	brne	8f		; flag is set, only skip address

	; jump
	rjmp	ExecGto

; ----- INV not set, jump if flag set

	; load flag index
; OUTPUT: R24 = typically digit 0..15 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
4:	call	Load1Dig
	brcs	9f

	cpi	r24,16		; check index
	brcc	7f		; invalid flag

	; test flag
; INPUT: R24 = index of user flag (0..15)
; OUTPUT: R24 = flag state (1 or 0)
;	  Z flag set if bit not set (breq = not set '0', brne = set '1')
	call	UserFlagTest	; test flag
	breq	8f		; flag not set, only skip address

	; jump
	rjmp	ExecGto


	; invalid flag
7:	call	CalcError
8:	call	LoadAddr	; load address
9:	ret

; ----------------------------------------------------------------------------
;                            D.MS (0x88)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecDms
ExecDms:

	breq	4f		; INV not set

; ----- INV set, convert degrees.decimals -> degrees.minutes_seconds

	rcall	_EditStop	; stop edit mode

	; load constant 60
	ldi	r24,60
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	call	CalcStackB	; stack constant 60

	rcall	_Calc		; calculator
	; degrees integer
	.byte	C_GETMEM(REG_X)	; load reg X (60,deg.dec)
	.byte	C_DUP		; duplicate (60,deg.dec,deg.dec)
	.byte	C_TRUNC		; truncate (60,deg.dec,deg.) ... to get degrees integer
	.byte	C_SETMEM(REG_X) ; save degrees integer (60,deg.dec,deg.) ... result accumulator
	; minutes integer
	.byte	C_SUB		; sub (60,.dec) ... to get degrees decimals
	.byte	C_DUP2		; pre-duplicate (60,.dec,60)
	.byte	C_MUL		; multiply*60 to get minutes with decimals (60,min.dec)
	.byte	C_DUP		; duplicate (60,min.dec,min.dec)
	.byte	C_TRUNC		; truncate, to get minutes integer (60,min.dec,min.)
	.byte	C_DUP		; duplicate (60,min.dec,min.,min.)
	.byte	C_CONST(CONST_001) ; load constant 0.01 (60,min.dec,min.,min.,0.01)
	.byte	C_MUL		; multiply (60,min.dec,min.,.min)
	.byte	C_GETMEM(REG_X) ; load result accumulator (60,min.dec,min.,.min,a)
	.byte	C_ADD		; add (60,min.dec,min.,a)
	.byte	C_SETMEMDEL(REG_X) ; save accumulator (60,min.dec,min.)
	; seconds
	.byte	C_SUB		; subtract, to get minuts decimal (60,.min)
	.byte	C_MUL		; multiply*60 to get seconds (sec.dec)
	.byte	C_CONST(CONST_00001) ; load constant 0.0001 (sec.dec,0.0001)
	.byte	C_MUL		; multiply (.00sec)
	.byte	C_GETMEM(REG_X) ; load accumulator (.00sec,a)
	.byte	C_ADD		; add (a)
	.byte	C_SETMEMDEL(REG_X) ; save result ()
	.byte	C_END
	.balign 2

	rjmp	__Disp		; display

; ----- INV not set, convert degrees.minutes_seconds -> degrees.decimals

4:	rcall	_EditStop	; stop edit mode

	; load constant 36
	ldi	r24,36
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	call	CalcStackB	; stack constant 36

	; load constant 60
	ldi	r24,60
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	call	CalcStackB	; stack constant 60

	rcall	_Calc		; calculator
	; degrees integer
	.byte	C_GETMEM(REG_X)	; load reg X (36,60,deg.min_sec)
	.byte	C_DUP		; duplicate (36,60,deg.min_sec,deg.min_sec)
	.byte	C_TRUNC		; truncate (36,60,deg.min_sec,deg.) ... to get degrees integer
	.byte	C_SETMEM(REG_X) ; save degrees integer (36,60,deg.min_sec,deg.) ... result accumulator
	; minutes
	.byte	C_SUB		; sub (36,60,.min_sec) ... to get degrees decimals
	.byte	C_CONST(CONST_100) ; load constant 100 (36,60,.min_sec,100)
	.byte	C_MUL		; multiply (36,60,min.sec)
	.byte	C_EXC		; exchange (36,min.sec,60)
	.byte	C_DUP2		; pre-duplicate (36,min.sec,60,min.sec)
	.byte	C_TRUNC		; truncate to get minutes (36,min.sec,60,min.)
	.byte	C_DUP		; duplicate (36,min.sec,60,min.,min.)
	.byte	C_EXC2		; pre-exchange (36,min.sec,min.,min.,60)
	.byte	C_DIV		; divide (36,min.sec,min.,.min)
	.byte	C_GETMEM(REG_X) ; load result accumulator (36,min.sec,min.,.min,a)
	.byte	C_ADD		; add (36,min.sec,min.,a) ... degrees + minutes/60
	.byte	C_SETMEMDEL(REG_X) ; save accumulator (36,min.sec,min.)
	; seconds
	.byte	C_SUB		; subtract (36,.sec) ... to get seconds / 100
	.byte	C_EXC		; exchange (.sec,36)
	.byte	C_DIV		; divide (.00sec) ... convert seconds to decimals (=seconds*100/3600)
	.byte	C_GETMEM(REG_X) ; load accumulator (.00sec,a)
	.byte	C_ADD		; add (a) ... degrees + minutes/60 + seconds/3600
	.byte	C_SETMEMDEL(REG_X) ; save result ()
	.byte	C_END
	.balign 2

	rjmp	__Disp		; display

; ----------------------------------------------------------------------------
;                            pi (0x89)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecPi
ExecPi:

	rcall	_EditStop	; stop edit mode

	rcall	_Calc
	.byte	C_CONST(CONST_PI) ; constant Pi
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	__Disp		; display all

; ----------------------------------------------------------------------------
;                            Hex (0x8b)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecHex
ExecHex:
	breq	2f		; INV not set
	call	FlagSetDebug	; set debug mode
	rjmp	3f	

2:	call	FlagClrDebug	; clear debug mode

3:	rcall	_EditStop	; stop edit mode, validate X
	ldi	r24,BASE_HEX	; HEX base
	std	Y+DATA_BASE,r24	; set new radit base
; DESTROYS: R0
	rjmp	__Disp		; display all

; ----------------------------------------------------------------------------
;                            Bin (0x8c)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecBin
ExecBin:
	breq	2f		; INV not set
	call	FlagSetDebug	; set debug mode
	rjmp	3f	

2:	call	FlagClrDebug	; clear debug mode

3:	rcall	_EditStop	; stop edit mode, validate X
	ldi	r24,BASE_BIN	; BIN base
	std	Y+DATA_BASE,r24	; set new radit base
; DESTROYS: R0
	rjmp	__Disp		; display all

; ----------------------------------------------------------------------------
;                            Oct (0x8d)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecOct
ExecOct:
	breq	2f		; INV not set
	call	FlagSetDebug	; set debug mode
	rjmp	3f	

2:	call	FlagClrDebug	; clear debug mode

3:	rcall	_EditStop	; stop edit mode, validate X
	ldi	r24,BASE_OCT	; OCT base
	std	Y+DATA_BASE,r24	; set new radit base
; DESTROYS: R0
	rjmp	__Disp		; display all

; ----------------------------------------------------------------------------
;                            List (0x90)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecList
ExecList:
	rcall	EditStop	; stop edit mode and set X valid

	ret

; ----------------------------------------------------------------------------
;                            R/S (0x91)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecRs
ExecRs:

; ----- break program

	IF_RUNNING		; if running
	rjmp	StopProg	; stop program

; ----- start program

.global StartProg
StartProg:
	SET_RUNNING		; set running
	rcall	_DispC		; display "C"
	jmp	Wait100ms	; short delay

; ----------------------------------------------------------------------------
;                            Write (0x96)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecWrite
ExecWrite:
	rcall	EditStop	; stop edit mode and set X valid

	ret

; ----------------------------------------------------------------------------
;                      DJNZ process register
; ----------------------------------------------------------------------------
; stack INPUT: inv, x
; stack OUTPUT: 0/1, x2
; ----------------------------------------------------------------------------

.global DjnzReg
DjnzReg:

; ----- inc/dec register

	rcall	_Calc		; calculator (inv,x)
	; offset 0: check if number is already zero
	.byte	C_DUP		; duplicate (inv,x,x)
	.byte	C_NOT		; invert, check if number is zero (inv,x,0/1)
	.byte	C_JUMPNZ	; jump if x = 0 (inv,x,0/1)
	.byte	13		; jump to offset 17 (17-4=13)
	; offset 4: check if number is negative
	.byte	C_DEL		; delete
	.byte	C_DUP		; duplicate (inv,x,x)
	.byte	C_LT0		; check if number is < 0 (inv,x,0/1)
	.byte	C_JUMPT		; jump if x < 0 (inv,x)
	.byte	5		; jump to offset 14 (14-9=5)
	; offset 9: number is positive or 0 - decrement
	.byte	C_DEC		; decrement (inv,x-1)
	; offset 10: check if result is <= 0 (=skip condition TRUE)
	.byte	C_DUP		; duplicate (inv,x-1,x-1)
	.byte	C_LTEQ0		; check if number is <= 0 (inv,x-1,0/1)
	.byte	C_JMP		; jump
	.byte	3		; jump to offset 17 (17-14=3)
	; offset 14: number is negative - increment
	.byte	C_INC		; increment (inv,x+1)
	; offset 15: check if result is >= 0 (=skip condition TRUE)
	.byte	C_DUP		; duplicate (inv,x+1,x+1)
	.byte	C_GREQ0		; check if number is >= 0 (inv,x+1,0/1)
	; ofrfset 17: invert result
	.byte	C_EXC		; exchange (inv,0/1,x2)
	.byte	C_EXC2		; pre-exchange (x2,0/1,inv)
	.byte	C_JUMPF		; skip if not invert (x2,0/1)
	.byte	1		; jump to offset 22 (22-21=1)
	; offset 21
	.byte	C_NOT		; inverse result (x2,0/1)
	; offset 22: exchange
	.byte	C_EXC		; exchange (0/1,x2)
	.byte	C_ROUND		; round (0/1,x2)
	.byte	C_END
	.balign 2
	ret

; ----------------------------------------------------------------------------
;                            Dsz (0x97)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecDsz
ExecDsz:

; ----- load register index (saves R23)
; OUTPUT: R24 = typically digit 0..15 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
	call	Load1Dig
	brcs	9f		; break

; ----- check register index 0..15

	cpi	r24,16		; check register index
	brcc	8f		; invalid register

; ----- load INV flag into stack
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	push	r24
	mov	r24,r23		; INV flag (1=INV)
	call	CalcStackB	; stack byte
	pop	r24

; ----- load register into stack
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	subi	r24,-USER_FIRST	; register index
	push	r24		; save index
	rcall	_CalcGetMem

; ----- inc/dec register
; stack INPUT: inv, x
; stack OUTPUT: 0/1, x2

	rcall	DjnzReg

; ----- save result

	pop	r24		; number index
	rcall	_CalcSetMemDel	; save number

; ----- operation result
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; load result
	tst	r24		; check if skip condition is TRUE
	brne	4f		; condition is TRUE

	; skip condition is FALSE, loop jump
	rjmp	ExecGto

	; skip condition is TRUE, skip address
4:	jmp	LoadAddr	; load address

	; invalid register
8:	call	CalcError
	call	LoadAddr	; load address
9:	ret

; ----------------------------------------------------------------------------
;                            Adv (0x98)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecAdv
ExecAdv:
	rcall	EditStop	; stop edit mode and set X valid

	ret

; ----------------------------------------------------------------------------
;                            Prt (0x99)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecPrt
ExecPrt:
	rcall	EditStop	; stop edit mode and set X valid

	ret

; ----------------------------------------------------------------------------
;                            phi (0x9a)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecPhi
ExecPhi:

	rcall	_EditStop	; stop edit mode

	rcall	_Calc
	.byte	C_CONST(CONST_PHI) ; constant Phi
	.byte	C_SETMEMDEL(REG_X) ; set X back from stack
	.byte	C_END
	.balign 2
; DESTROYS: R0
	rjmp	__Disp		; display all

; ----------------------------------------------------------------------------
;                            Dec (0x9b)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecDec
ExecDec:
	breq	2f		; INV not set
	call	FlagSetDebug	; set debug mode
	rjmp	3f	

2:	call	FlagClrDebug	; clear debug mode

3:	rcall	_EditStop	; stop edit mode, validate X
	ldi	r24,BASE_DEC	; DEC base
	std	Y+DATA_BASE,r24	; set new radit base
; DESTROYS: R0
	rjmp	__Disp		; display all

; ----------------------------------------------------------------------------
;                            NOT (0x9d)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecNot
ExecNot:

	rcall	_EditStop	; stop edit mode

	; bitwise NOT
	ldi	r24,REG_X	; register X
	rcall	_CalcGetMem	; load X into stak
	call	CalcNeg		; negate
	call	CalcDec		; decrement

	; check: base not DEC and number is negative
	ldd	r24,Y+DATA_BASE	; base radix
	cpi	r24,BASE_DEC	; decimal base?
	breq	9f		; decimal base
	call	CalcTop		; get top number
	ldd	r24,Z+2		; sign of register X
	tst	r24		; is register X negative?
	brpl	9f		; register X is not negative

	; prepare correction - max. exponent to fill-up display digits
	ldi	r24,CONST_1
	call	CalcConst	; load constant 1
	ldd	r23,Y+DATA_BASE	; base radix	
;#define BASE_BIN	1	// binary
;#define BASE_OCT	2	// octal
;#define BASE_HEX	3	// hexadecimal
	ldi	r24,lo8(EXP_BIAS+14) ; BIN
	cpi	r23,BASE_OCT
	brcs	2f		; BIN
	ldi	r24,lo8(EXP_BIAS+14*3) ; OCT
	breq	2f		; OCT
	ldi	r24,lo8(EXP_BIAS+14*4) ; HEX
2:	ldi	r25,hi8(EXP_BIAS)
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	call	CalcTop		; get top number 1
	std	Z+0,r25		; exponent HIGH
	std	Z+1,r24		; exponent LOW

	; add correction to register X
	call	CalcAdd		; add

9:	rcall	_CalcSetMemDelX	; save X
	
	jmp	Disp		; display all

; ----------------------------------------------------------------------------
;                            OFF (0x20)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecOff
ExecOff:
	jmp	GoSleep

; ----------------------------------------------------------------------------
;                            Execute table
; ----------------------------------------------------------------------------

.global ExecTab
ExecTab:
	.word	ExecDig		; #define KEY_0		0x00 // digit 0
	.word	ExecDig		; #define KEY_1		0x01 // digit 1
	.word	ExecDig		; #define KEY_2		0x02 // digit 2
	.word	ExecDig		; #define KEY_3		0x03 // digit 3
	.word	ExecDig		; #define KEY_4		0x04 // digit 4
	.word	ExecDig		; #define KEY_5		0x05 // digit 5
	.word	ExecDig		; #define KEY_6		0x06 // digit 6
	.word	ExecDig		; #define KEY_7		0x07 // digit 7
	.word	ExecDig		; #define KEY_8		0x08 // digit 8
	.word	ExecDig		; #define KEY_9		0x09 // digit 9
	.word	ExecDig		; #define KEY_0A	0x0a // digit 0A
	.word	ExecDig		; #define KEY_0B	0x0b // digit 0B
	.word	ExecDig		; #define KEY_0C	0x0c // digit 0C
	.word	ExecDig		; #define KEY_0D	0x0d // digit 0D
	.word	ExecDig		; #define KEY_0E	0x0e // digit 0E
	.word	ExecDig		; #define KEY_0F	0x0f // digit 0F

	.word	ExecSbrLab	; #define KEY_E2	0x10 // label E'
	.word	ExecSbrLab	; #define KEY_A		0x11 // label A
	.word	ExecSbrLab	; #define KEY_B		0x12 // label B
	.word	ExecSbrLab	; #define KEY_C		0x13 // label C
	.word	ExecSbrLab	; #define KEY_D		0x14 // label D
	.word	ExecSbrLab	; #define KEY_E		0x15 // label E
	.word	ExecSbrLab	; #define KEY_A2	0x16 // label A'
	.word	ExecSbrLab	; #define KEY_B2	0x17 // label B'
	.word	ExecSbrLab	; #define KEY_C2	0x18 // label C'
	.word	ExecSbrLab	; #define KEY_D2	0x19 // label D'
	.word	ExecSbrLab	; #define KEY_A3	0x1a // label A''
	.word	ExecSbrLab	; #define KEY_B3	0x1b // label B''
	.word	ExecSbrLab	; #define KEY_C3	0x1c // label C''
	.word	ExecSbrLab	; #define KEY_D3	0x1d // label D''
	.word	ExecSbrLab	; #define KEY_E3	0x1e // label E''
	.word	ExecSbrLab	; #define KEY_F		0x1f // label F

	.word	ExecOff		; #define KEY_OFF	0x20 // OFF (ON)
	.word	Exec2nd		; #define KEY_2ND	0x21 // 2nd
	.word	ExecInv		; #define KEY_INV	0x22 // INV
	.word	ExecLnx		; #define KEY_LNX	0x23 // Ln x
	.word	ExecCe		; #define KEY_CE	0x24 // CE
	.word	ExecClr		; #define KEY_CLR	0x25 // CLR
	.word	ExecSbrInd	; #define KEY_SBR_IND	0x26 // SBR Ind
	.word	ExecHirInd	; #define KEY_HIR_IND	0x27 // HIR Ind
	.word	ExecLog		; #define KEY_LOG	0x28 // log
	.word	ExecCp		; #define KEY_CP	0x29 // CP
	.word	ExecNop		; 			0x2a //
	.word	ExecCode	; #define KEY_CODE	0x2b // code
	.word	ExecLg2		; #define KEY_LG2	0x2c // log2
	.word	ExecRnd		; #define KEY_RND	0x2d // rnd
	.word	ExecNop		; 			0x2e //
	.word	ExecNop		; 			0x2f // 

	.word	ExecTan		; #define KEY_TAN	0x30 // tan
	.word	ExecLrn		; #define KEY_LRN	0x31 // LRN
	.word	ExecXt		; #define KEY_XT	0x32 // x<>t
	.word	ExecX2		; #define KEY_X2	0x33 // x^2
	.word	ExecVx		; #define KEY_SQR	0x34 // Vx
	.word	Exec1x		; #define KEY_1X	0x35 // 1/x
	.word	ExecPgm		; #define KEY_PGM	0x36 // Pgm
	.word	ExecPr		; #define KEY_PR	0x37 // P->R
	.word	ExecSin		; #define KEY_SIN	0x38 // sin
	.word	ExecCos		; #define KEY_COS	0x39 // cos
	.word	ExecTemp	; #define KEY_TEMP	0x3a // Temp
	.word	ExecXy		; #define KEY_XY	0x3b // x<>y
	.word	ExecSinH	; #define KEY_SINH	0x3c // sinh
	.word	ExecCosH	; #define KEY_COSH	0x3d // cosh
	.word	ExecTanH	; #define KEY_TANH	0x3e // tanh
	.word	ExecNop		; 			0x3f // 

	.word	ExecInd		; #define KEY_IND	0x40 // Ind
	.word	ExecSst		; #define KEY_SST	0x41 // SST
	.word	ExecSto		; #define KEY_STO	0x42 // STO
	.word	ExecRcl		; #define KEY_RCL	0x43 // RCL
	.word	ExecSum		; #define KEY_SUM	0x44 // SUM
	.word	ExecYx		; #define KEY_POW	0x45 // y^x
	.word	ExecIns		; #define KEY_INS	0x46 // Ins
	.word	ExecCms		; #define KEY_CMS	0x47 // CMs
	.word	ExecExc		; #define KEY_EXC	0x48 // Exc
	.word	ExecPrd		; #define KEY_PRD	0x49 // Prd
	.word	ExecBat		; #define KEY_BAT	0x4a // Bat
	.word	ExecFact	; #define KEY_FACT	0x4b // n!
	.word	ExecLnFact	; #define KEY_LNFACT	0x4c // ln n!
	.word	ExecLogFact	; #define KEY_LOGFACT	0x4d // log n!
	.word	ExecMod2	; #define KEY_MOD2	0x4e // mod2 (floor)
	.word	ExecNop		; 			0x4f // 

	.word	ExecAbs		; #define KEY_ABS	0x50 // |x|
	.word	ExecBst		; #define KEY_BST	0x51 // BST
	.word	ExecEe		; #define KEY_EE	0x52 // EE
	.word	ExecLpar	; #define KEY_LPAR	0x53 // (
	.word	ExecRpar	; #define KEY_RPAR	0x54 // )
	.word	ExecDiv		; #define KEY_DIV	0x55 // :
	.word	ExecDel		; #define KEY_DEL	0x56 // Del
	.word	ExecEng		; #define KEY_ENG	0x57 // Eng
	.word	ExecFix		; #define KEY_FIX	0x58 // Fix
	.word	ExecInt		; #define KEY_INT	0x59 // Int
	.word	ExecLCD		; #define KEY_LCD	0x5a // LCD
	.word	ExecLeft	; #define KEY_LEFT	0x5b // <<
	.word	ExecRight	; #define KEY_RIGHT	0x5c // >>
	.word	ExecRound	; #define KEY_ROUND	0x5d // round
	.word	ExecMod		; #define KEY_MOD	0x5e // mod (trunc)
	.word	ExecNop		; 			0x5f // 

	.word	ExecDeg		; #define KEY_DEG	0x60 // Deg
	.word	ExecGto		; #define KEY_GTO	0x61 // GTO
	.word	ExecPgmInd	; #define KEY_PGM_IND	0x62 // Pgm Ind
	.word	ExecExcInd	; #define KEY_EXC_IND	0x63 // Exc Ind
	.word	ExecPrdInd	; #define KEY_PRD_IND	0x64 // Prd Ind
	.word	ExecMul		; #define KEY_MUL	0x65 // x
	.word	ExecPause	; #define KEY_PAU	0x66 // Pause
	.word	ExecEqu		; #define KEY_EQ	0x67 // x=t
	.word	ExecNop		; #define KEY_NOP	0x68 // Nop
	.word	ExecOp		; #define KEY_OP	0x69 // Op
	.word	ExecRel		; #define KEY_REL	0x6a //
	.word	ExecIncInd	; #define KEY_INC_IND	0x6b // Inc Ind
	.word	ExecRegInd	; #define KEY_REG_IND	0x6c // Reg Ind
	.word	ExecIfInd	; #define KEY_IF_IND	0x6d // If Ind
	.word	ExecAnd		; #define KEY_AND	0x6e // AND &
	.word	ExecNop		; 			0x6f // 

	.word	ExecRad		; #define KEY_RAD	0x70 // Rad
	.word	ExecSbr		; #define KEY_SBR	0x71 // SBR
	.word	ExecStoInd	; #define KEY_STO_IND	0x72 // STO Ind
	.word	ExecRclInd	; #define KEY_RCL_IND	0x73 // RCL Ind
	.word	ExecSumInd	; #define KEY_SUM_IND	0x74 // SUM Ind
	.word	ExecSub		; #define KEY_SUB	0x75 // -
	.word	ExecLbl		; #define KEY_LBL	0x76 // Lbl
	.word	ExecGre		; #define KEY_GE	0x77 // x>=t
	.word	ExecStat	; #define KEY_STA	0x78 // Stat+
	.word	ExecAvrg	; #define KEY_AVR	0x79 // Avrg x (Mean)
	.word	ExecIf		; #define KEY_IF	0x7a // If
	.word	ExecNop		; 			0x7b // 
	.word	ExecNop		; 			0x7c // 
	.word	ExecNop		; 			0x7d // 
	.word	ExecXor		; #define KEY_XOR	0x7e // XOR ~
	.word	ExecNop		; 			0x7f // 

	.word	ExecGrad	; #define KEY_GRD	0x80 // Grad
	.word	ExecRst		; #define KEY_RST	0x81 // RST
	.word	ExecHir		; #define KEY_HIR	0x82 // HIR
	.word	ExecGtoInd	; #define KEY_GTO_IND	0x83 // GTO Ind
	.word	ExecOpInd	; #define KEY_OP_IND	0x84 // Op Ind
	.word	ExecAdd		; #define KEY_ADD	0x85 // +
	.word	ExecStFlg	; #define KEY_STF	0x86 // St Flg
	.word	ExecIfFlg	; #define KEY_IFF	0x87 // If Flg
	.word	ExecDms		; #define KEY_DMS	0x88 // D.MS
	.word	ExecPi		; #define KEY_PI	0x89 // pi
	.word	ExecReg		; #define KEY_REG	0x8a // Reg
	.word	ExecHex		; #define KEY_HEX	0x8b // HEX
	.word	ExecBin		; #define KEY_BIN	0x8c // BIN
	.word	ExecOct		; #define KEY_OCR	0x8d // OCT
	.word	ExecOr		; #define KEY_OR	0x8e // OR |
	.word	ExecNop		; 			0x8f // 

	.word	ExecList	; #define KEY_LST	0x90 // List
	.word	ExecRs		; #define KEY_RS	0x91 // R/S
	.word	ExecRtn		; #define KEY_RTN	0x92 // RTN
	.word	ExecDot		; #define KEY_DOT	0x93 // .
	.word	ExecNeg		; #define KEY_NEG	0x94 // +/-
	.word	ExecRes		; #define KEY_RES	0x95 // =
	.word	ExecWrite	; #define KEY_WRT	0x96 // Write
	.word	ExecDsz		; #define KEY_DSZ	0x97 // Dsz
	.word	ExecAdv		; #define KEY_ADV	0x98 // Adv
	.word	ExecPrt		; #define KEY_PRT	0x99 // Prt
	.word	ExecPhi		; #define KEY_PHI	0x9a // phi
	.word	ExecDec		; #define KEY_DEC	0x9b // DEC
	.word	ExecInc		; #define KEY_INC	0x9c // Inc
	.word	ExecNot		; #define KEY_NOT	0x9d // NOT
	.word	ExecPerc	; #define KEY_PERC	0x9e // %
	.word	ExecNop		; 			0x9f // 

; ----------------------------------------------------------------------------
;                            Execute key code
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code
; ----------------------------------------------------------------------------

.global Exec
Exec:

; ----- read and clear INV flag

	clr	r23		; R23 <- 0, no INV flag
; OUTPUT: NZ = flag is set
; DESTROYS: -
	call	FlagTestInv	; test INV flag
	breq	1f		; INV flag not set

; DESTROYS: -
	call	FlagClrInv	; clear INV flag
	push	r24
; DESTROYS: -
	call	DispFlags	; display flags (DESTROYS: R27, R26, R25, R24, R23, R20)
	pop	r24
	ldi	r23,1		; INV flag

; ----- check code

1:	cpi	r24,MAXKEY+1	; check max. code
	brcc	9f		; invalid code

; ----- jump to code

	ldi	r30,lo8(ExecTab) ; Z <- jump table
	ldi	r31,hi8(ExecTab)
	add	r30,r24
	adc	r31,R_ZERO
	add	r30,r24		; Z <- offset in jump table
	adc	r31,R_ZERO
	lpm	r0,Z+		; R0 <- load jump address LOW
	lpm	r31,Z		; R31 <- load jump address HIGH
	mov	r30,r0		; Z <- jump address (byte offset)
	lsr	r31
	ror	r30		; convert address to word index
	tst	r23		; test INV flag
	ijmp			; jump to function (R24=key code, ZY and R23=old INV state 0 or 1)

9:	ret
