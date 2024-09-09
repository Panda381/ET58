; ****************************************************************************
;
;                                Execute Op
;
; ****************************************************************************

#include "include.inc"

	.text

#define OP_MAX	0x8B		// max. Op number (HEX)

; bridges
.global _DispC
_DispC: jmp DispC

.global __Calc
__Calc: jmp Calc

.global __CalcGetMem
__CalcGetMem: jmp CalcGetMem

LoadTxt:
	.asciz	" Load?  (1=YES) "
	.balign 2

; ----- predefined numeric texts

NumTextTab:
	.ascii	"      OK"	; 0
	.ascii	"   ERROR"	; 1
	.ascii	"Diagnose"	; 2
	.ascii	"  Result"	; 3
	.ascii	"   Input"	; 4
	.ascii	"   Enter"	; 5
	.ascii	"   Index"	; 6
	.ascii	"     Row"	; 7
	.ascii	"  Column"	; 8
	.ascii	"Continue"	; 9
	.ascii	"    STOP"	; 10
	.ascii	"  Matrix"	; 11
	.ascii	" Complex"	; 12
	.ascii	"  Number"	; 13
	.ascii	" Element"	; 14
	.ascii	"    Item"	; 15
	.ascii	"   Print"	; 16
	.ascii	"    from"	; 17
	.ascii	"      to"	; 18
	.ascii	" Display"	; 19
	.ascii	" Program"	; 20
	.ascii	"    Load"	; 21
	.ascii	"    Save"	; 22
	.ascii	"     YES"	; 23
	.ascii	"      NO"	; 24
	.ascii	"     Add"	; 25
	.ascii	"Subtract"	; 26
	.ascii	"Multiply"	; 27
	.ascii	"  Divide"	; 28
	.ascii	"   Power"	; 29
	.ascii	"    Root"	; 30
	.ascii	"  Square"	; 31
	.ascii	"     Key"	; 32
	.ascii	"  Button"	; 33
	.ascii	" (1=YES)"	; 34
	.ascii	"  Vector"	; 35
	.ascii	" Library"	; 36
	.ascii	"   First"	; 37
	.ascii	"  Second"	; 38
	.ascii	"   Third"	; 39
	.ascii	"  Fourth"	; 40
	.ascii	"  Param."	; 41
	.ascii	"   Entry"	; 42
	.ascii	"  Output"	; 43
	.ascii	"    Rows"	; 44
	.ascii	" Columns"	; 45
	.ascii	"    Size"	; 46
	.ascii	"   Ready"	; 47
	.ascii	"  Lambda"	; 48
	.ascii	" Polynom"	; 49
	.ascii	"   Angle"	; 50
	.ascii	"    Side"	; 51
	.ascii	"Triangle"	; 52
	.ascii	"    Area"	; 53
	.ascii	" Perimet"	; 54
	.ascii	"  Radius"	; 55
	.ascii	"  ArcLen"	; 56
	.ascii	"   Chord"	; 57
	.ascii	"  S-Area"	; 58
	.ascii	"     Low"	; 59
	.ascii	"    High"	; 60
	.ascii	" Too Low"	; 61
	.ascii	" Correct"	; 62
	.ascii	"Too High"	; 63
	.ascii	"    Game"	; 64
	.ascii	"    Time"	; 65
	.ascii	" Working"	; 66
	.ascii	"     ..."	; 67
	.ascii	"     Win"	; 68
	.ascii	"    Loss"	; 69
	.ascii	"Bankroll"	; 70
	.ascii	" Success"	; 71
	.ascii	"   Crash"	; 72
	.ascii	"    Fail"	; 73
	.ascii	"   Speed"	; 74
	.ascii	"   Check"	; 75
	.ascii	" Landing"	; 76
	.ascii	" Mission"	; 77
	.ascii	"Complete"	; 78
	.ascii	" Failure"	; 79
	.ascii	"  Smooth"	; 80
	.ascii	"    Turn"	; 81
	.ascii	"   Turns"	; 82
	.ascii	"Computer"	; 83
	.ascii	"    Your"	; 84
	.ascii	"     You"	; 85
	.ascii	"      My"	; 86
	.ascii	"    Lost"	; 87
	.ascii	"   Count"	; 88
	.ascii	" Counter"	; 89
	.ascii	"    Calc"	; 90
	.ascii	"  Calcul"	; 91
	.ascii	"Calculer"	; 92
	.ascii	"     Won"	; 93
	.ascii	"    Wait"	; 94
	.ascii	"   Press"	; 95
	.ascii	"   a Key"	; 96
	.ascii	"Reaction"	; 97
	.ascii	"Response"	; 98
	.ascii	"   Alien"	; 99
	.ascii	" Running"	; 100
	.ascii	"    Test"	; 101
	.ascii	"    Help"	; 102
	.ascii	"   Hello"	; 103
	.ascii	"   World"	; 104
	.ascii	"   ET-58"	; 105
	.ascii	"Progress"	; 106
	.ascii	"   Graph"	; 107
	.ascii	"   Black"	; 108
	.ascii	"   White"	; 109
	.ascii	"  Height"	; 110
	.ascii	"   Width"	; 111
	.ascii	"     CRC"	; 112

#define NUMTEXT_MAX	112	// max. text index

	.balign 2

; ----------------------------------------------------------------------------
;                           Op Ind (0x84)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecOpInd
ExecOpInd:

; ----- load parameter indirect
; OUTPUT: R24 = memory index
;	  C = set if error
; DESTROYS: R31, R30, R27, R26, R25, R20
	rcall	ExecMemNum	; get memory index, with indirect from keyboard
	brcs	GetTB9		; error

; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	__CalcGetMem	; load number into stack

; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; load byte from the stack
	brcs	GetTB9		; overflow
	brne	GetTB9		; negative

	rjmp	ExecOp2

; ----------------------------------------------------------------------------
;                        Load byte from X register
; ----------------------------------------------------------------------------
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; ----------------------------------------------------------------------------

.global GetXB
GetXB:
	; stop edit mode
	call	__EditStop	; stop edit mode

	; load register X
	ldi	r24,REG_X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	__CalcGetMem	; load register X

; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	jmp	CalcUnstackB	; unstack byte

; ----------------------------------------------------------------------------
;                        Load byte from T register
; ----------------------------------------------------------------------------
; OUTPUT: R25 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10, saves register R24 (with X value)
; ----------------------------------------------------------------------------

.global GetTB
GetTB:
	push	r24
	ldi	r24,REG_T
	rcall	__CalcGetMem	; load register T
	call	CalcUnstackB	; unstack key code
	mov	r25,r24		; T value
	pop	r24
GetTB9:
	ret

; ----------------------------------------------------------------------------
;                    Output characters to print buffer
; ----------------------------------------------------------------------------
; INPUT: R27:R26 (X) = number
;	 R31:R30 (Z) = destination print buffer
; OUTPUT: R31:R30 (Z) = new pointer in buffer
; DESTROYS: many
; ----------------------------------------------------------------------------

AddPrintChar_1B:
	ldi	r30,lo8(PrintBuf3)
	ldi	r31,hi8(PrintBuf3)
	rjmp	AddPrintChar_11

AddPrintChar_3:
	ldi	r30,lo8(PrintBuf2)
	ldi	r31,hi8(PrintBuf2)
	ldi	r26,lo8(PrintReg+2*NUM_BYTES)
	ldi	r27,hi8(PrintReg+2*NUM_BYTES)
	rjmp	AddPrintChar

AddPrintChar_1:
	ldi	r30,lo8(PrintBuf1)
	ldi	r31,hi8(PrintBuf1)
AddPrintChar_11:
	ldi	r26,lo8(PrintReg+0*NUM_BYTES)
	ldi	r27,hi8(PrintReg+0*NUM_BYTES)

; AddPrintChar must follow

.global AddPrintChar
AddPrintChar:

	push	r30
	push	r31

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
	call	CalcAbs		; absolute value
	call	CalcRound
	call	CalcPreCor	; rounding pre-correction

; ----- divide by 10^16 (shift by 16 digits = 8 characters)
; INPUT: R31:R30 = constant in ROM
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	ldi	r30,lo8(ExpTab+9*NUM_BYTES)
	ldi	r31,hi8(ExpTab+9*NUM_BYTES)
	call	CalcConstROM
	call	CalcMul

; ----- decode digits

	ldi	r23,8
; DESTROYS: R31, R30, R27..R24
; CALCULATOR STACK: +1
2:	push	r23

	ldi	r24,CONST_100
	call	CalcConst
	call	CalcMul		; multiply number by 100

	call	CalcDup		; duplicate
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; get byte

; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	push	r24

	call	CalcStackB
	call	CalcNeg
	call	CalcAdd		; subtract integer part

	pop	r24

	pop	r23

	pop	r31
	pop	r30

	cpi	r24,100
	brcs	3f
	ldi	r24,0
3:	subi	r24,-32
	st	Z+,r24

	push	r30
	push	r31

	dec	r23
	brne	2b		; next digit

	call	CalcDel

	pop	r31
	pop	r30
	ret

; ----------------------------------------------------------------------------
;  Calculate regresion
; ----------------------------------------------------------------------------
; y = m*x + b, RegT = m, RegX = b
;  mem 1: sum y
;  mem 2: sum y^2
;  mem 3: N
;  mem 4: sum x
;  mem 5: sum x^2
;  mem 6: sum x*y

Regr:
	rcall	__Calc

	; sum(x*y) - sum(x)*sum(y)/N
	.byte	C_GETMEM(MEM_6)	; load mem 6 = sum x*y (m6)
	.byte	C_GETMEM(MEM_4)	; load mem 4 = sum x (m6,m4)
	.byte	C_GETMEM(MEM_1)	; load mem 1 = sum y (m6,m4,m1)
	.byte	C_MUL		; multiply (m6,m4*m1)
	.byte	C_GETMEM(MEM_3)	; load mem 3 = N (m6,m4*m1,N)
	.byte	C_DIV		; divide (m6,m4*m1/N)
	.byte	C_SUB		; subtract (m6-m4*m1/N = sum(x*y)-sum(x)*sum(y)/N = z)

	; sum(x^2) - sum(x)^2/N
	.byte	C_GETMEM(MEM_5)	; load mem 5 = sum x^2 (z,m5)
	.byte	C_GETMEM(MEM_4)	; load mem 4 = sum x (z,m5,m4)
	.byte	C_SQR		; square (z,m5,m4^2)
	.byte	C_GETMEM(MEM_3)	; load mem 3 = N (z,m5,m4^2,N)
	.byte	C_DIV		; divide (z,m5,m4^2/N)
	.byte	C_SUB		; subtract (z,m5-m4^2/N = sum(x^2) - sum(x)^2/N = w)

	; m = sum(x*y) - sum(x)*sum(y)/N) / (sum(x^2) - sum(x)^2/N) -> RegT
	.byte	C_DIV		; divide (z/w)
	.byte	C_SETMEM(REG_T)	; set register T (m)

	; b = (sum(y) - m*sum(x))/N -> RegX
	.byte	C_GETMEM(MEM_4)	; load mem 4 = sum x (m,m4)
	.byte	C_MUL		; multiply (m*m4)
	.byte	C_GETMEM(MEM_1)	; load mem 1 = sum y (m*m4,m1)
	.byte	C_SUB		; subtract (m*m4-m1)
	.byte	C_NEG		; negate (m1-m*m4)
	.byte	C_GETMEM(MEM_3)	; load mem 3 = N (m1-m*m4,N)
	.byte	C_DIV		; divide ((m1-m*m4)/N)
	.byte	C_SETMEMDEL(REG_X) ; set register X

	.byte	C_END
	.balign 2
	ret

; ----- decode register X into edit buffer (length R24)

ExecOpPrepX:
	std	Y+DATA_EDITMAX,r24
	rcall	__EditStop	; stop edit mode
	ldi	r24,REG_X
	rcall	__CalcGetMem	; load number X
	jmp	DecNum

; ----------------------------------------------------------------------------
;                     Delete top complex number (C_CPXDEL)
; ----------------------------------------------------------------------------

.global CpxDel
CpxDel:
	lds	r24,CpxInx	; current index
	tst	r24		; check
	brne	CpxDel2		; ok
CpxDel9:
	jmp	Fatal		; fatal error

CpxDel2:
	dec	r24		; decrement index
CpxDel3:
	sts	CpxInx,r24
	ret

; ----------------------------------------------------------------------------
;                     Create new complex number
; ----------------------------------------------------------------------------

CpxNew:
	lds	r24,CpxInx	; current index
	lds	r25,CpxNum	; max. number
	cp	r24,r25		; check number
	brcc	CpxDel9		; error
	inc	r24		; increase number
	rjmp	CpxDel3

; ----------------------------------------------------------------------------
; Get pre-top complex number into calculator stack (pre-top=real, top=imaginary) (C_CPXGETPRETOP)
; ----------------------------------------------------------------------------

.global CpxGetPreTop
CpxGetPreTop:

	; get memory index of top complex number
; OUTPUT: R24 = index of memory number
; DESTROYS: R25
	rcall	CpxPreTopInx
	rjmp	CpxGetTop2

; ----------------------------------------------------------------------------
; Get top complex number into calculator stack (pre-top=real, top=imaginary) (C_CPXGETTOP)
; ----------------------------------------------------------------------------

.global CpxGetTop
CpxGetTop:

	; get memory index of top complex number
; OUTPUT: R24 = index of memory number
; DESTROYS: R25
	rcall	CpxTopInx

CpxGetTop2:

	; Get number from memory into stack (C_GETMEM)
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	push	r24
	rcall	__CalcGetMem
	pop	r24

	; Get number from memory into stack (C_GETMEM)
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	inc	r24
	rjmp	__CalcGetMem

; ----------------------------------------------------------------------------
; Set pre-top complex number from calculator stack (pre-top=real, top=imaginary) (C_CPXSETPRETOP)
; ----------------------------------------------------------------------------

.global CpxSetPreTop
CpxSetPreTop:

	; get memory index of top complex number
; OUTPUT: R24 = index of memory number
; DESTROYS: R25
	rcall	CpxPreTopInx
	rjmp	CpxSetTop2

; ----------------------------------------------------------------------------
; Set top complex number from calculator stack (pre-top=real, top=imaginary) (C_CPXSETTOP)
; ----------------------------------------------------------------------------

.global CpxSetTop
CpxSetTop:

	; get memory index of top complex number
; OUTPUT: R24 = index of memory number
; DESTROYS: R25
	rcall	CpxTopInx

CpxSetTop2:

	; set number from stack (C_GETMEM)
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
	push	r24
	inc	r24
	call	CalcSetMem
	call	CalcExc
	pop	r24

	; set number from stack (C_GETMEM)
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
	call	CalcSetMem
	jmp	CalcExc

; ----------------------------------------------------------------------------
;               Get memory index of pre-top complex number
; ----------------------------------------------------------------------------
; OUTPUT: R24 = index of memory number
; DESTROYS: R25
; ----------------------------------------------------------------------------

CpxPreTopInx:

	lds	r24,CpxInx	; current index
	subi	r24,2
	rjmp	CpxToInx

; ----------------------------------------------------------------------------
;               Get memory index of top complex number
; ----------------------------------------------------------------------------
; OUTPUT: R24 = index of memory number
; DESTROYS: R25
; ----------------------------------------------------------------------------

CpxTopInx:

	lds	r24,CpxInx	; current index
	dec	r24

; CpxToInx must follow

; ----------------------------------------------------------------------------
;             Convert index of complex number to memory index
; ----------------------------------------------------------------------------
; INPUT: R24 = index of complex number
; OUTPUT: R24 = index of memory number
; DESTROYS: R25
; ----------------------------------------------------------------------------

CpxToInx:
	; check index
	lds	r25,CpxNum	; max. number
	cp	r24,r25		; check number
	brcc	CpxDel9		; error

	lds	r25,CpxBeg	; first register
	add	r25,r24
	brcs	CpxDel9
	add	r25,r24
	brcs	CpxDel9
	cpi	r25,USER_NUM-1	; check start index
	brcc	CpxDel9		; invalid start index

; INPUT: R24 = index of variable 0..MEM_NUM-1
; OUTPUT: R31:R30 = address of variable
;	  R1 = 0
; DESTROYS: R0
	subi	r25,-USER_FIRST
	mov	r24,r25
	ret

; ----------------------------------------------------------------------------
;                           Op (0x69)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
;	 Z = clear if INV flag was set (=brne)
; ----------------------------------------------------------------------------

.global ExecOp
ExecOp:

; ----- load parameter (2 HEX digits)
; OUTPUT: R24 = byte
; DESTROYS: R25
	call	Load2Hex

ExecOp2:
	cpi	r24,OP_MAX+1		; check max. opcode
	brcc	ExecOp_00_9		; invalid opcode

; ----- jump to operation

	ldi	r30,lo8(ExecOpTab)	; Z <- jump table
	ldi	r31,hi8(ExecOpTab)
	add	r30,r24
	adc	r31,R_ZERO
	add	r30,r24		; Z <- offset in jump table
	adc	r31,R_ZERO
	lpm	r0,Z+		; R0 <- load jump address LOW
	lpm	r31,Z		; R31 <- load jump address HIGH
	mov	r30,r0		; Z <- jump address (byte offset)
	lsr	r31
	ror	r30		; convert address to word index
	ijmp			; jump to function (R24=opcode)

; ----- 0: clear print registers 1..4

ExecOp_00:
	ldi	r30,lo8(PrintReg)
	ldi	r31,hi8(PrintReg)
	ldi	r24,4
; INPUT: R31:R30 = float number
; DESTROYS: R_M1,...R_M10
5:	call	CalcZ0
	adiw	r30,NUM_BYTES
	dec	r24
	brne	5b
ExecOp_00_9:
	ret

; ----- 1..4: set print register 1..4

ExecOp_01:
ExecOp_02:
ExecOp_03:
ExecOp_04:
	push	r24		; register index 1..4
; DESTROYS: R27, R26, R25, R24, R20
	rcall	__EditStop	; stop edit mode
	pop	r24

	ldi	r25,NUM_BYTES
	mul	r25,r24		; offet of register
	movw	r26,r0		; offset
	clr	r1		; restore R1 (R_ZERO)
	subi	r26,lo8(-(PrintReg-NUM_BYTES))
	sbci	r27,hi8(-(PrintReg-NUM_BYTES))

	ldi	r30,lo8(MemReg + REG_X*NUM_BYTES)
	ldi	r31,hi8(MemReg + REG_X*NUM_BYTES)

; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24

	call	CalcCopyNum

	rjmp	_Disp

; ----- 5: output print registers 1..4 to printer

ExecOp_05:
	rcall	__EditStop	; stop edit mode and set X valid
	ret

; ----- 6: output print register 1 with X to printer

ExecOp_06:
	rcall	__EditStop	; stop edit mode and set X valid
	ret

; ----- 7: print asterisk to X position 0..19 of the printer

ExecOp_07:
	rcall	__EditStop	; stop edit mode and set X valid
	ret

; ----- 8: print labels to the printer

ExecOp_08:
	rcall	__EditStop	; stop edit mode and set X valid
	ret

; ----- 9: load selected program into main memory

ExecOp_09:
	IF_RUNNING		; running?
9:	ret			; running program, no function

	ldd	r24,Y+DATA_PROGINX ; current program index
	tst	r24		; main program?
	breq	9b		; main program

	rcall	__EditStop	; stop edit mode and set X valid

	; diplay prompt to confirm operation
	call	DispSetRow1	; set cursor to ROW1
	ldi	r30,lo8(LoadTxt)
	ldi	r31,hi8(LoadTxt)
	call	DispTextRom	; display text
	ldi	r24,NOKEY
	call	ReturnKey	; flush old key
	call	WaitKey		; wait for a key
	cpi	r24,KEY_1	; check key '1'
	brne	8f

	rcall	_DispC		; display C

	ldd	r30,Y+DATA_PROGBEG ; begin of program
	ldd	r31,Y+DATA_PROGBEG+1
	clr	r26		; destination address
	clr	r27

1:	call	ExcXZ		; exchange X and Z
; INPUT: R27:R26 (X) = address (can be out of range)
; OUTPUT: R24 = byte (0 if invalid)
;	  R27:R26 (X+1) = new address, increased by 1 (not changed on error)
;	  CY = invalid address (R27:R26 not changed)
; DESTROYS: -
	call	LoadByte	; load byte
	brcc	2f		; address is OK
	ldi	r24,CLEARKEY	; clear key
2:	mov	r25,r24
	call	ExcXZ		; exchange X and Z
; INPUT: R27:R26 = destination address
;	 R25 = data
; OUTPUT: R24 = old byte
	call	EEWrite		; clear byte

	; increase destination address
	adiw	r26,1		; shift destination address
	cpi	r26,lo8(PROG_NUM)
	brne	1b
	cpi	r27,hi8(PROG_NUM)
	brne	1b

	clr	r24
; INPUT: R24 = program index (0=main)
; DESTROYS: R31, R30, R24, R0
	call	OpenProg	; open main program

	; reset current address
	std	Y+DATA_ADDR,R_ZERO
	std	Y+DATA_ADDR+1,R_ZERO
; DESTROYS: R0
8:  	rjmp	_Disp		; display all

; ----- 0x0A: print registers 1 and 2 on 1st row while running (cleared on stop) - full row

ExecOp_0A:
	rcall	AddPrintChar_1
	ldi	r26,lo8(PrintReg+1*NUM_BYTES)
	ldi	r27,hi8(PrintReg+1*NUM_BYTES)
; INPUT: R27:R26 (X) = number
;	 R31:R30 (Z) = destination print buffer
; OUTPUT: R31:R30 (Z) = new pointer in buffer
; DESTROYS: many
	rcall	AddPrintChar
	rjmp	ExecOp_0B_4

; ----- 0x0B: print register 1 on 1st row while running (cleared on stop) - half row + number

ExecOp_0B:
	ldi	r24,8
	rcall	ExecOpPrepX
	rcall	AddPrintChar_1

ExecOp_0B_2:
	ldi	r25,8
ExecOp_0B_3:
	ldi	r26,lo8(EditBuf)
	ldi	r27,hi8(EditBuf)
2:	ld	r24,X+
	st	Z+,r24	
	dec	r25
	brne	2b
ExecOp_0B_4:
	IF_RUNNING
	rcall	_DispC
	rcall	_Disp
	ret

; ----- 0x0C: print register 1 on 1st row while running (cleared on stop) - quart row + number

ExecOp_0C:
	ldi	r24,12
	rcall	ExecOpPrepX
	rcall	AddPrintChar_1
ExecOp_0C_2:
	sbiw	r30,4
	ldi	r25,12
	rjmp	ExecOp_0B_3

; ----- 0x0D: print registers 3 and 4 on 2nd row while running (set to 'C' on stop) - full row

ExecOp_0D:
	rcall	AddPrintChar_3
	ldi	r26,lo8(PrintReg+3*NUM_BYTES)
	ldi	r27,hi8(PrintReg+3*NUM_BYTES)
; INPUT: R27:R26 (X) = number
;	 R31:R30 (Z) = destination print buffer
; OUTPUT: R31:R30 (Z) = new pointer in buffer
; DESTROYS: many
	rcall	AddPrintChar
	rjmp	ExecOp_0B_4

; ----- 0x0E: print register 3 on 2nd row while running (set to 'C' on stop) - half row + number

ExecOp_0E:
	ldi	r24,8
	rcall	ExecOpPrepX
	rcall	AddPrintChar_3
	rjmp	ExecOp_0B_2

; ----- 0x0F: print register 3 on 2nd row while running (set to 'C' on stop) - quart row + number

ExecOp_0F:
	ldi	r24,12
	rcall	ExecOpPrepX
	rcall	AddPrintChar_3
	rjmp	ExecOp_0C_2

; ----- 0x10: sign function of X

ExecOp_10:
	jmp	ExecSign	; sign of X

; ----- 0x11: variation
;  mem 1: sum y
;  mem 2: sum y^2
;  mem 3: N
;  mem 4: sum x
;  mem 5: sum x^2
;  mem 6: sum x*y

ExecOp_11:
	rcall	__EditStop	; stop edit mode and set X valid
	rcall	__Calc

	; sum(x^2)/N
	.byte	C_GETMEM(MEM_5) ; load mem 5 = sum x^2 (m5)
	.byte	C_GETMEM(MEM_3)	; load mem 3 = N (m5,N)
	.byte	C_DIV		; divide (m5/N = xx)
	; (sum(x)/N)^2
	.byte	C_GETMEM(MEM_4) ; load mem 4 = sum x (xx,m4)
	.byte	C_GETMEM(MEM_3)	; load mem 3 = N (xx,m4,N)
	.byte	C_DIV		; divide (xx,m4/N)
	.byte	C_SQR		; square (xx,(m4/N)^2)
	; reg T = sum(x^2)/N - (sum(x)/N)^2)
	.byte	C_SUB		; subtract (xx-(m4/N)^2 = sum(x^2)/N - (sum(x)/N)^2)
	.byte	C_SETMEMDEL(REG_T) ; set register T

	; sum(y^2)/N
	.byte	C_GETMEM(MEM_2) ; load mem 2 = sum y^2 (m2)
	.byte	C_GETMEM(MEM_3)	; load mem 3 = N (m2,N)
	.byte	C_DIV		; divide (m2/N = yy)
	; (sum(y)/N)^2
	.byte	C_GETMEM(MEM_1) ; load mem 1 = sum y (yy,m1)
	.byte	C_GETMEM(MEM_3)	; load mem 3 = N (yy,m1,N)
	.byte	C_DIV		; divide (yy,m1/N)
	.byte	C_SQR		; square (yy,(m1/N)^2)
	; reg X = sum(y^2)/N - (sum(y)/N)^2)
	.byte	C_SUB		; subtract (yy-(m1/N)^2 = sum(y^2)/N - (sum(y)/N)^2)
	.byte	C_SETMEMDEL(REG_X) ; set register X

	.byte	C_END
	.balign 2
	rjmp	_Disp

; ----- 0x12: coefficients of linear regression
; linear regression, y = m*x + b
;	RegT = m = (sum(x*y) - sum(x)*sum(y)/N) / (sum(x^2) - sum(x)^2/N)
;	RegX = b = (sum(y) - m*sum(x))/N
; mem 1: sum y
; mem 2: sum y^2
; mem 3: N
; mem 4: sum x
; mem 5: sum x^2
; mem 6: sum x*y

ExecOp_12:
	rcall	__EditStop	; stop edit mode and set X valid
	rcall	Regr		; calculate regression
	rjmp	_Disp		; display

; ----- 0x13: correlation coefficient
; correlation coefficient R = m * devx / devy
; rise coefficient m = (sum(x*y) - sum(x)*sum(y)/N) / (sum(x^2) - sum(x)^2/N))
; standard deviation devx = sqrt((sum(x^2) - sum(x)^2/N)/(N-1))
; standard deviation devy = sqrt((sum(y^2) - sum(y)^2/N)/(N-1))
; R = (sum(x*y) - sum(x)*sum(y)/N) / sqrt((sum(x^2) - sum(x)^2/N)*(sum(y^2) - sum(y)^2/N))
; mem 1: sum y
; mem 2: sum y^2
; mem 3: N
; mem 4: sum x
; mem 5: sum x^2
; mem 6: sum x*y

ExecOp_13:
	rcall	__EditStop	; stop edit mode and set X valid
	rcall	__Calc

	; z = sum(x*y) - sum(x)*sum(y)/N
	.byte	C_GETMEM(MEM_6)	; load mem 6 = sum x*y (m6)
	.byte	C_GETMEM(MEM_4)	; load mem 4 = sum x (m6,m4)
	.byte	C_GETMEM(MEM_1)	; load mem 1 = sum y (m6,m4,m1)
	.byte	C_MUL		; multiply (m6,m4*m1)
	.byte	C_GETMEM(MEM_3)	; load mem 3 = N (m6,m4*m1,N)
	.byte	C_DIV		; divide (m6,m4*m1/N)
	.byte	C_SUB		; subtract (m6-m4*m1/N = sum(x*y) - sum(x)*sum(y)/N = z)

	; w = sum(x^2) - sum(x)^2/N
	.byte	C_GETMEM(MEM_5)	; load mem 5 = sum x^2 (z,m5)
	.byte	C_GETMEM(MEM_4)	; load mem 4 = sum x (z,m5,m4)
	.byte	C_SQR		; square (z,m5,m4^2)
	.byte	C_GETMEM(MEM_3)	; load mem 3 = N (z,m5,m4^2,N)
	.byte	C_DIV		; divide (z,m5,m4^2/N)
	.byte	C_SUB		; subtract (z,m5-m4^2/N = sum(x^2) - sum(x)^2/N = w)

	; s = sum(y^2) - sum(y)^2/N
	.byte	C_GETMEM(MEM_2)	; load mem 2 = sum y^2 (z,w,m2)
	.byte	C_GETMEM(MEM_1)	; load mem 1 = sum y (z,w,m2,m1)
	.byte	C_SQR		; square (z,w,m2,m1^2)
	.byte	C_GETMEM(MEM_3)	; load mem 3 = N (z,w,m2,m1^2,N)
	.byte	C_DIV		; divide (z,w,m2,m1^2/N)
	.byte	C_SUB		; subtract (z,w,m2-m1^2/N = sum(y^2) - sum(y)^2/N = s)

	; q = sqrt((sum(x^2) - sum(x)^2/N) * (sum(y^2) - sum(y)^2/N)) = sqrt(w*s)
	.byte	C_MUL		; multiply (z,w*s)

	; R = z/q
	.byte	C_DIV		; divide (z/(w*s))
	.byte	C_SETMEMDEL(REG_X) ; set register X

	.byte	C_END
	.balign 2
	rjmp	_Disp		; display

; ----- 0x14: calculate linear regression Y from X
; linear regression: y = m*x + b, RegT = m, RegX = b

ExecOp_14:
	rcall	__EditStop	; stop edit mode and set X valid

	ldi	r24,REG_T
	rcall	__CalcGetMem	; load register T into stack
	ldi	r24,REG_X
	rcall	__CalcGetMem	; load register X into stack
	rcall	Regr		; calculate regression

	rcall	__Calc
	.byte	C_GETMEM(REG_T)	; load register T = coefficient m (x,m)
	.byte	C_MUL		; multiply (x*m)
	.byte	C_GETMEM(REG_X)	; load register X = coefficient b (x*m,b)
	.byte	C_ADD		; add (x*m+b)
	.byte	C_SETMEMDEL(REG_X) ; save result into X
	.byte	C_SETMEMDEL(REG_T) ; save original value T
	.byte	C_END
	.balign 2
	rjmp	_Disp		; display

; ----- 0x15: calculate linear regression X from Y
; linear regression: y = m*x + b, RegT = m, RegX = b ... x = (y - b)/m

ExecOp_15:
	call	EditStop	; stop edit mode and set X valid

	ldi	r24,REG_T
	rcall	__CalcGetMem	; load register T into stack
	ldi	r24,REG_X
	rcall	__CalcGetMem	; load register X into stack
	rcall	Regr		; calculate regression

	rcall	__Calc
	.byte	C_GETMEM(REG_X)	; load register X = coefficient b (y,b)
	.byte	C_SUB		; subtract (y-b)
	.byte	C_GETMEM(REG_T)	; load register T = coefficient m (y-b,m)
	.byte	C_DIV		; divide ((y-b)/m)
	.byte	C_SETMEMDEL(REG_X) ; save result into X
	.byte	C_SETMEMDEL(REG_T) ; save original value T
	.byte	C_END
	.balign 2
	rjmp	_Disp		; display

; ----- 0x16,0x17: set/get memory organization 999.99

ExecOp_16:
ExecOp_17:
	call	EditStop
	ldi	r24,CONST_99999
; INPUT: R24 = index of the constant in ConstTab
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	call	CalcConst
	call	_CalcSetMemDelX
	rjmp	_Disp

; ----- 0x18: set flag 7 if no error

ExecOp_18:
	ldi	r24,7
	IFN_ERROR		; if not error
	jmp	UserFlagSet	; set flag 7 if not error
	ret

; ----- 0x19: set flag 7 if error

ExecOp_19:
	ldi	r24,7
	IF_ERROR		; if error
	jmp	UserFlagSet	; set flag 7 on error
	ret

; ----- 0x1A: print registers 1 and 2 on 1st row while stop - full row

ExecOp_1A:
	rcall	AddPrintChar_1B
	ldi	r26,lo8(PrintReg+1*NUM_BYTES)
	ldi	r27,hi8(PrintReg+1*NUM_BYTES)
; INPUT: R27:R26 (X) = number
;	 R31:R30 (Z) = destination print buffer
; OUTPUT: R31:R30 (Z) = new pointer in buffer
; DESTROYS: many
	rcall	AddPrintChar
	rjmp	ExecOp_0B_4

; ----- 0x1B: print register 1 on 1st row while stop - half row + number

ExecOp_1B:
	ldi	r24,8
	rcall	ExecOpPrepX
	rcall	AddPrintChar_1B
	rjmp	ExecOp_0B_2

; ----- 0x1C: print register 1 on 1st row while running (cleared on stop) - quart row + number

ExecOp_1C:
	ldi	r24,12
	rcall	ExecOpPrepX
	rcall	AddPrintChar_1B
	rjmp	ExecOp_0C_2

; ----- 0x1D: set display mode flags + X (default mode)

ExecOp_1D:
	call	FlagClrDispRegT		; clear T mode
	call	FlagClrDispText		; clear text mode
	rjmp	_Disp

; ----- 0x1E: set display mode T + X

ExecOp_1E:
	call	FlagSetDispRegT		; set T mode
	call	FlagClrDispText		; clear text mode
	rjmp	_Disp

; ----- 0x1F: set display mode text + X

ExecOp_1F:
	call	FlagSetDispText		; set text mode
	rjmp	_Disp

; ----- 0x2x: increment register

ExecOp_20:
ExecOp_21:
ExecOp_22:
ExecOp_23:
ExecOp_24:
ExecOp_25:
ExecOp_26:
ExecOp_27:
ExecOp_28:
ExecOp_29:
ExecOp_2A:
ExecOp_2B:
ExecOp_2C:
ExecOp_2D:
ExecOp_2E:
ExecOp_2F:
	andi	r24,0x0f	; memory index
	subi	r24,-USER_FIRST
	push	r24		; push memory index
	rcall	__CalcGetMem	; load memory
	call	CalcInc		; increment
1:	pop	r24		; memory index
	jmp	CalcSetMemDel	; save memory

; ----- 0x3x: decrement register

ExecOp_30:
ExecOp_31:
ExecOp_32:
ExecOp_33:
ExecOp_34:
ExecOp_35:
ExecOp_36:
ExecOp_37:
ExecOp_38:
ExecOp_39:
ExecOp_3A:
ExecOp_3B:
ExecOp_3C:
ExecOp_3D:
ExecOp_3E:
ExecOp_3F:
	andi	r24,0x0f	; memory index
	subi	r24,-USER_FIRST
	push	r24		; push memory index
	rcall	__CalcGetMem	; load memory
	call	CalcDec		; decrement
	rjmp	1b

; ----- 0x40: input key from keyboard into reg. X (0..0xFF, keys are remaped by 2nd, 0xff = no key)

ExecOp_40:
	call	_EditStop	; stop edit mode
; OUTPUT: R24 = hex key code (NZ brne) or Oxff no key (NOKEY, ZY breq)
;	  ZY = set if NOKEY
; DESTROYS: -
; NOTE: Enables interrupts
	call	GetKey		; get key
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
ExecOp_40B:
	call	CalcStackB	; stack key
	call	_CalcSetMemDelX	; set X
	rjmp	_Disp

; ----- 0x41: check if key is pressed, reg. X = key code (not remaped, 0xRC R=row 1..9, C=column 1..5, 0xFF=no key), returns 0 or 1 in X if key is pressed

ExecOp_41:
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
	rcall	GetXB		; load byte from X

	ldd	r25,Y+DATA_KEYRAW ; load current raw key
	cp	r24,r25		; check key
	ldi	r24,0		; flag - not pressed
	brne	ExecOp_40B	; not pressed
	ldi	r24,1		; flag - pressed
	rjmp	ExecOp_40B	; save result code

; ----- 0x42: print character to display, X=character code 0..99, T=position:
;	0..15 print on 1st row while running (1st row is cleared on program stop)
;	16..31 print on 2nd row while running (2nd row is set to 'C' on program stop)
;	32..47 print on 1st row while stop (need to activate Op 0x1F text mode, reset to default mode by CLR)

ExecOp_42:
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
	rcall	GetXB		; load byte from X

	; load position
; OUTPUT: R25 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10, saves register R24 (with X value)
	rcall	GetTB

	; check if character is valid
	cpi	r24,100		; check character
	brcs	1f		; character is OK
	clr	r24		; use space character
1:	subi	r24,-32		; convert to ASCII character

	; print to buffer 1
	ldi	r30,lo8(PrintBuf1)
	ldi	r31,hi8(PrintBuf1)
	cpi	r25,16
	brcs	2f		; use print buffer 1

	; print to buffer 1
	subi	r25,16
	ldi	r30,lo8(PrintBuf2)
	ldi	r31,hi8(PrintBuf2)
	cpi	r25,16
	brcs	2f		; use print buffer 2

	; print to buffer 3
	subi	r25,16
	cpi	r25,16
	brcc	5f		; invalid buffer
	ldi	r30,lo8(PrintBuf3)
	ldi	r31,hi8(PrintBuf3) ; use print buffer 3

	; write character to buffer
2:	add	r30,r25
	adc	r31,R_ZERO
	st	Z,r24		; save character

	; update display
	IF_RUNNING
	rjmp	_DispC
	rjmp	_Disp

5:	ret

; ----- 0x43: load font with index X (0=default characters, 1=column left, 2=column right, 3=lines, 4=pixels)

ExecOp_43:
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
	rcall	GetXB		; load byte from X

	cpi	r24,FONT_NUM	; check font index
	brcc	9f		; invalid font
; INPUT: R24 = required font (FONT_*)
; DESTROYS: R31, R30, R25, R24
	call	SetFont		; update font
9:	ret

; ----- 0x44: delay, X = 0..255 multiply of 10 ms

ExecOp_44:
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
	rcall	GetXB		; load byte from X

	tst	r24
	breq	9f

2:	push	r24
	ldi	r24,10
	call	Waitms		; wait 10 ms
	pop	r24
	dec	r24
	brne	2b

9:	ret

; ----- 0x45: display progress bar on 1st row if running, from the left, X=0..80

ExecOp_45:
	; load value
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
	rcall	GetXB		; load byte from X

	ldi	r30,lo8(PrintBuf1)
	ldi	r31,hi8(PrintBuf1)
ExecOp_45B:
	brcs	3f		; overflow
	breq	2f		; positive or 0

	clr	r24		; underflow
2:	cpi	r24,80		; overflow?
	brcs	2f		; OK
3:	ldi	r24,80		; overflow limit

2:	ldi	r25,16		; number of positions

ExecOp_45C:
2:	ldi	r26,' '		; right part
	tst	r24
	brmi	3f		; right part

	ldi	r26,0x80
	cpi	r24,5
	brcc	3f		; left part

	mov	r26,r24
	subi	r26,-0x7B

3:	subi	r24,5		; shift value

	st	Z+,r26		; save character
	dec	r25		; loop counter
	brne	2b		; next character

	ldi	r24,FONT_COLL
	call	SetFont		; update font

	IF_RUNNING
	rjmp	_DispC
	rjmp	_Disp

; ----- 0x46: display progress bar on 2nd row if running, from the left, X=0..80

ExecOp_46:
	; load value
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
	rcall	GetXB		; load byte from X

	ldi	r30,lo8(PrintBuf2)
	ldi	r31,hi8(PrintBuf2)
	rjmp	ExecOp_45B

; ----- 0x47: display progress bar on 1st row if stop, on right half from left, with text from print register 1 on left half, X=0..40

ExecOp_47:
	; display text
	rcall	AddPrintChar_1B

	call	FlagSetDispText		; set text mode

	; load value
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10

	rcall	GetXB		; load byte from X

	ldi	r30,lo8(PrintBuf3+8)
	ldi	r31,hi8(PrintBuf3+8)

	brcs	3f		; overflow
	breq	2f		; positive or 0

	clr	r24		; underflow
2:	cpi	r24,40		; overflow?
	brcs	2f		; OK
3:	ldi	r24,40		; overflow limit

2:	ldi	r25,8		; number of positions
	rjmp	ExecOp_45C

; ----- 0x48: display progress bar on 1st row if running, from the right, X=0..80

ExecOp_48:
	; load value
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
	rcall	GetXB		; load byte from X

	ldi	r30,lo8(PrintBuf1+LCD_COLNUM)
	ldi	r31,hi8(PrintBuf1+LCD_COLNUM)
ExecOp_48B:
	brcs	3f		; overflow
	breq	2f		; positive or 0

	clr	r24		; underflow
2:	cpi	r24,80		; overflow?
	brcs	2f		; OK
3:	ldi	r24,80		; overflow limit

2:	ldi	r25,16		; number of positions

ExecOp_48C:
2:	ldi	r26,' '		; left part
	tst	r24
	brmi	3f		; left part

	ldi	r26,0x80
	cpi	r24,5
	brcc	3f		; right part

	mov	r26,r24
	subi	r26,-0x7B

3:	subi	r24,5		; shift value

	st	-Z,r26		; save character
	dec	r25		; loop counter
	brne	2b		; next character

	ldi	r24,FONT_COLR
	call	SetFont		; update font

	IF_RUNNING
	rjmp	_DispC
	rjmp	_Disp

; ----- 0x49: display progress bar on 2nd row if running, from the right, X=0..80

ExecOp_49:
	; load value
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
	rcall	GetXB		; load byte from X

	ldi	r30,lo8(PrintBuf2+LCD_COLNUM)
	ldi	r31,hi8(PrintBuf2+LCD_COLNUM)
	rjmp	ExecOp_48B

; ----- 0x4A: display progress bar on 1st row if stop, on right half from right, with text from print register 1 on left half, X=0..40

ExecOp_4A:
	; display text
	rcall	AddPrintChar_1B

	call	FlagSetDispText		; set text mode

	; load value
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10

	rcall	GetXB		; load byte from X

	ldi	r30,lo8(PrintBuf3+LCD_COLNUM)
	ldi	r31,hi8(PrintBuf3+LCD_COLNUM)

	brcs	3f		; overflow
	breq	2f		; positive or 0

	clr	r24		; underflow
2:	cpi	r24,40		; overflow?
	brcs	2f		; OK
3:	ldi	r24,40		; overflow limit

2:	ldi	r25,8		; number of positions
	rjmp	ExecOp_48C

; ----- 0x4B: display graph column of value X=0..16 on position T=0..15, while running

ExecOp_4B:
	; load value from X
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
	rcall	GetXB		; load byte from X
	brcs	3f		; overflow
	breq	2f		; positive or 0

	clr	r24		; underflow
2:	cpi	r24,16		; overflow?
	brcs	2f		; OK
3:	ldi	r24,16		; overflow limit

2:
	; load position
; OUTPUT: R25 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10, saves register R24 (with X value)
	rcall	GetTB
	brcs	8f		; overflow
	brne	8f		; underflow
	cpi	r25,16		; check overflow
	brcc	8f		; overflow

	; set value
	ldi	r30,lo8(PrintBuf2)
	ldi	r31,hi8(PrintBuf2)
	add	r30,r25
	adc	r31,R_ZERO

	ldi	r26,0x83	; full box
	cpi	r24,8
	brcc	3f		; top part

	mov	r26,r24
	subi	r26,-0x7B

3:	subi	r24,8		; shift value

	st	Z,r26		; save character

	ldi	r30,lo8(PrintBuf1)
	ldi	r31,hi8(PrintBuf1)
	add	r30,r25
	adc	r31,R_ZERO

	ldi	r26,' '
	tst	r24
	brmi	3f		; top part

	ldi	r26,0x83	; full box
	cpi	r24,8
	brcc	3f		; top part

	mov	r26,r24
	subi	r26,-0x7B

3:	st	Z,r26		; save character

	ldi	r24,FONT_LINE
	call	SetFont		; update font

	IF_RUNNING
	rjmp	_DispC

8:	ret

; ----- 0x4C: display graph column of value X=0..8 on position T=0..7, if stop,
;	on right half, with text from register 1 on left half

ExecOp_4C:
	; display text
	rcall	AddPrintChar_1B

	call	FlagSetDispText		; set text mode

	; load value from X
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
	rcall	GetXB		; load byte from X
	brcs	3f		; overflow
	breq	2f		; positive or 0

	clr	r24		; underflow
2:	cpi	r24,8		; overflow?
	brcs	2f		; OK
3:	ldi	r24,8		; overflow limit

2:
	; load position
; OUTPUT: R25 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10, saves register R24 (with X value)
	rcall	GetTB
	brcs	8f		; overflow
	brne	8f		; underflow
	cpi	r25,8		; check overflow
	brcc	8f		; overflow

	; set value
	ldi	r30,lo8(PrintBuf3+8)
	ldi	r31,hi8(PrintBuf3+8)
	add	r30,r25
	adc	r31,R_ZERO

	ldi	r26,0x83	; full box
	cpi	r24,8
	brcc	3f		; top part

	mov	r26,r24
	subi	r26,-0x7B

3:	st	Z,r26		; save character

	ldi	r24,FONT_LINE
	call	SetFont		; update font

	rjmp	_Disp

8:	ret

; ----- 0x4D: set pixel on coordinate X=0..15 and T=0..5, while running

ExecOp_4D:
	; load X
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
	rcall	GetXB		; load byte from X
	brcs	8f		; overflow
	brne	8f		; negative
	cpi	r24,16		; overflow?
	brcc	8f		; overflow

	; load T
; OUTPUT: R25 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10, saves register R24 (with X value)
	rcall	GetTB
	brcs	8f		; overflow
	brne	8f		; underflow
	cpi	r25,6		; check overflow
	brcc	8f		; overflow

	ldi	r30,lo8(PrintBuf2)
	ldi	r31,hi8(PrintBuf2)
	cpi	r25,3
	brcs	2f

	ldi	r30,lo8(PrintBuf1)
	ldi	r31,hi8(PrintBuf1)
	subi	r25,3

2:	add	r30,r24
	adc	r31,R_ZERO

	ld	r24,Z
	cpi	r24,0x7b	; minimal valid value
	brcs	3f		; invalid value
	cpi	r24,0x82+1	; maximal valid value + 1
	brcs	4f		; value is OK
3:	ldi	r24,0x7b	; default value

4:	subi	r24,0x7b
	cpi	r25,0
	brne	1f
	ori	r24,B0
1:	cpi	r25,1
	brne	1f
	ori	r24,B1
1:	cpi	r25,2
	brne	1f
	ori	r24,B2
1:	subi	r24,-0x7b
	st	Z,r24

	ldi	r24,FONT_PIX
	call	SetFont		; update font

	IF_RUNNING
	rjmp	_DispC

8:	ret

; ----- 0x4E: reset pixel on coordinate X=0..15 and T=0..5, while running

ExecOp_4E:
	; load X
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
	rcall	GetXB		; load byte from X
	brcs	8f		; overflow
	brne	8f		; negative
	cpi	r24,16		; overflow?
	brcc	8f		; overflow

	; load T
; OUTPUT: R25 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10, saves register R24 (with X value)
	rcall	GetTB
	brcs	8f		; overflow
	brne	8f		; underflow
	cpi	r25,6		; check overflow
	brcc	8f		; overflow

	ldi	r30,lo8(PrintBuf2)
	ldi	r31,hi8(PrintBuf2)
	cpi	r25,3
	brcs	2f

	ldi	r30,lo8(PrintBuf1)
	ldi	r31,hi8(PrintBuf1)
	subi	r25,3

2:	add	r30,r24
	adc	r31,R_ZERO

	ld	r24,Z
	cpi	r24,0x7b	; minimal valid value
	brcs	3f		; invalid value
	cpi	r24,0x82+1	; maximal valid value + 1
	brcs	4f		; value is OK
3:	ldi	r24,0x7b	; default value

4:	subi	r24,0x7b
	cpi	r25,0
	brne	1f
	andi	r24,~B0
1:	cpi	r25,1
	brne	1f
	andi	r24,~B1
1:	cpi	r25,2
	brne	1f
	andi	r24,~B2
1:	subi	r24,-0x7b
	st	Z,r24

	ldi	r24,FONT_PIX
	call	SetFont		; update font

	IF_RUNNING
	rjmp	_DispC

8:	ret

; ----- 0x4F: flip pixel on coordinate X=0..15 and T=0..5, while running

ExecOp_4F:

	; load X
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
	rcall	GetXB		; load byte from X
	brcs	8f		; overflow
	brne	8f		; negative
	cpi	r24,16		; overflow?
	brcc	8f		; overflow

	; load T
; OUTPUT: R25 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10, saves register R24 (with X value)
	rcall	GetTB
	brcs	8f		; overflow
	brne	8f		; negative
	cpi	r25,6		; check overflow
	brcc	8f		; overflow

	ldi	r30,lo8(PrintBuf2)
	ldi	r31,hi8(PrintBuf2)
	cpi	r25,3
	brcs	2f

	ldi	r30,lo8(PrintBuf1)
	ldi	r31,hi8(PrintBuf1)
	subi	r25,3

2:	add	r30,r24
	adc	r31,R_ZERO

	ld	r24,Z
	cpi	r24,0x7b	; minimal valid value
	brcs	3f		; invalid value
	cpi	r24,0x82+1	; maximal valid value + 1
	brcs	4f		; value is OK
3:	ldi	r24,0x7b	; default value

4:	cpi	r25,0
	brne	1f
	ldi	r26,B0
1:	cpi	r25,1
	brne	1f
	ldi	r26,B1
1:	cpi	r25,2
	brne	1f
	ldi	r26,B2
1:	subi	r24,0x7b
	eor	r24,r26
	subi	r24,-0x7b
	st	Z,r24

	ldi	r24,FONT_PIX
	call	SetFont		; update font

	IF_RUNNING
	rjmp	_DispC

8:	ret

; ----- 0x50 ... find greatest common divisor (GCD) of two non-zero integer numbers X and T, result into X (Euclidean algorithm)
;    If T = 0, result will be 0. If X = 0, result will be T.
; https://en.wikipedia.org/wiki/Euclidean_algorithm
; https://cs.wikipedia.org/wiki/Eukleid%C5%AFv_algoritmus

ExecOp_50:
	rcall	__EditStop	; stop edit mode
	rcall	__Calc
	.byte	C_GETMEM(REG_T)	; load register T (w)
	.byte	C_GETMEM(REG_X)	; load register X (w,u)
	.byte	C_GCD		; find greatest common divider (d)
	.byte	C_SETMEMDEL(REG_X) ; save result into X ()
	.byte	C_END
	.balign 2
	rjmp	_Disp		; display

; ----- 0x51: get seed of random generator (into X, number 0..4294967295)

ExecOp_51:
	rcall	__EditStop	; stop edit mode
	ldd	r27,Y+DATA_RANDSEED+3
	ldd	r26,Y+DATA_RANDSEED+2
	ldd	r25,Y+DATA_RANDSEED+1
	ldd	r24,Y+DATA_RANDSEED+0
; INPUT: R27:R26:R25:R24 = unsigned integer
; DESTROYS: R31, R30, R27, R26, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	call	CalcStackD
	call	_CalcSetMemDelX	; set X
	rjmp	_Disp

; ----- 0x52: set seed of random generator (from X, number 0..4294967295)

ExecOp_52:
	rcall	__EditStop	; stop edit mode
	ldi	r24,REG_X
	rcall	__CalcGetMem	; load register X into stack
; OUTPUT: R27:R26:R25:R24 = unsigned integer
;	  R_M3 = negative flag (0 or B7)
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackD
	std	Y+DATA_RANDSEED+0,r24
	std	Y+DATA_RANDSEED+1,r25
	std	Y+DATA_RANDSEED+2,r26
	std	Y+DATA_RANDSEED+3,r27
	rjmp	_Disp

; ----- 0x53: load predefined text with index X into X, in editable form (add 00 to shift to the left) (0=OK, 1=ERROR,...)
;	  Decimal places x.N = shift text by N positions to the left.

ExecOp_53:
	; stop edit mode
	rcall	__EditStop	; stop edit mode

	rcall	__Calc
	.byte	C_GETMEM(REG_X)	; load register X (x)
	.byte	C_DUP		; duplicate (x,x)
	.byte	C_DUP		; duplicate (x,x,x)
	.byte	C_TRUNC		; trunc x (x,x,int)
	.byte	C_SUB		; subtract (x,frac)
	.byte	C_CONST(CONST_10) ; load constant 10 (x,frac,10)
	.byte	C_MUL		; multiply (x,frac*10)
	.byte	C_EXC		; exchange (frac*10,x)
	.byte	C_END
	.balign 2

; DESTROYS: R27, R26, R25, R24, R20
	call	EditStart	; start edit

; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; unstack byte

	cpi	r24,NUMTEXT_MAX+1 ; check max. index
	brcc	6f		; invalid index

	ldi	r25,8		; number of bytes per text
	mul	r25,r24		; offset of the text
	ldi	r30,lo8(NumTextTab)
	ldi	r31,hi8(NumTextTab)
	add	r30,r0
	adc	r31,r1		; address of the text
	clr	r1		; restore R1 (R_ZERO)

	; load ASCII character
2:	lpm	r24,Z+		; load 1 character

	push	r30
	push	r31

	; convert character to hex code
	subi	r24,32		; character index
; INPUT: R24 = BIN code
; OUTPUT: R24 = BCD code
;	  R1 = 0
; DESTROYS: R0
	call	Bin2Bcd		; convert to BCD code

	; enter digits
	push	r25
	push	r24
	swap	r24
	andi	r24,0x0f	; first digit
	call	ExecDig		; enter first digit
	pop	r24
	andi	r24,0x0f	; second digit
	call	ExecDig		; enter second digit
	pop	r25

	pop	r31
	pop	r30

	; next character
	dec	r25		; character counter
	brne	2b		; next character

	; get number of decimals
6:	call	CalcUnstackB	; unstack byte
	add	r24,r24
	breq	7f

5:	push	r24
	clr	r24
	call	ExecDig		; insert zero
	pop	r24
	dec	r24
	brne	5b		; next digit

7:	rjmp	_Disp		; display

9:	ret

; ----- 0x54: Add text of integer number from T to end of X

ExecOp_54:
	call	FlagClrEng	; clear Eng
	call	FlagClrEE	; clear exponent mode (but not ENG mode)
	IFN_EDITON		; if not edit mode
	call	EditRestart	; restart edit of current number X
	call	DelDot		; delete decimal places
; DESTROYS: -
;	call	FlagClrExp	; clear exponent flag

	; load dword from T
	ldi	r24,REG_T
	rcall	__CalcGetMem	; load register T

	; check in number is negative
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	call	CalcTop		; get top number -> Z
	ldd	r24,Z+2		; get sign bit (from first byte of mantissa)
	andi	r24,0x80	; check sign
	breq	1f		; number is not negative

	; add character '-' (code 13)
	ldi	r24,1
	call	ExecDig		; enter digit
	ldi	r24,3
	call	ExecDig		; enter digit

	; unstack integer number
1:	call	CalcAbs		; absolute value
	call	CalcRound	; round to integer
; OUTPUT: R27:R26:R25:R24 = unsigned integer
;	  R_M3 = negative flag (0 or B7)
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackD

	; decode number R25:R24:R23:R22 into stack, digit countr R19
	movw	r22,r24
	movw	r24,r26		; prepare number R27:R26:R25:R24 -> R25:R24:R23:R22
	clr	r19		; clear digit counter
2:	mov	r18,r22		; save lowest byte -> R18
; INPUT: R25:R24:R23:R22 = dividend (N3:N2:N1:N0)
;        R1=0
; OUTPUT: R25:R24:R23:R22 = quotient (Q3:Q2:Q1:Q0)
; DESTROYS: R31, R26, R20
	call	DivD10		; divide number by 10
	movw	r14,r22
	movw	r16,r24		; save quotient R25:R24:R23:R22 -> R17:R16:R15:R14
; INPUT: R25:R24:R23:R22 = multiplier (N3:N2:N1:N0)
; OUTPUT: R25:R24:R23:R22 = result (M3:M2:M1:M0)
;         R1=0
; DESTROYS: R27, R26, R20, R0
	call	MulD10		; multiply number by 10

	; save digit into stack
	sub	r18,r22
	push	r18		; save digit into stack
	inc	r19		; increase digit counter

	movw	r22,r14
	movw	r24,r16		; restore quotient R17:R16:R15:R14 -> R25:R24:R23:R22

	; check zero result
	or	r14,r15
	or	r14,r16
	or	r14,r17		; check zero resulz
	brne	2b		; next digit

2:	pop	r24		; get digit from the stack

	push	r19		; push digit counter

	; convert character to hex code
	subi	r24,-16		; character index
; INPUT: R24 = BIN code
; OUTPUT: R24 = BCD code
;	  R1 = 0
; DESTROYS: R0
	call	Bin2Bcd		; convert to BCD code

	; enter digits
	push	r24
	swap	r24
	andi	r24,0x0f	; first digit
	call	ExecDig		; enter first digit
	pop	r24
	andi	r24,0x0f	; second digit
	call	ExecDig		; enter second digit

	pop	r19		; pop digit counter

	; next character
	dec	r19		; digit counter
	brne	2b		; next character

	rjmp	_Disp		; display

; ----- 0x55: initialize stack of complex numbers: reg X = number of complex numbers, reg T = first memory register
;		(number of memory registers = number of complex numbers * 2)

ExecOp_55:

; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
	rcall	GetXB		; load byte from X

	; load position
; OUTPUT: R25 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10, saves register R24 (with X value)
	rcall	GetTB

	sts	CpxBeg,r25	; set first memory register
	sts	CpxNum,r24	; set number of complex numbers
	sts	CpxInx,R_ZERO	; clear current index
	ret

; ----- 0x56: get number of complex numbers in the stack

ExecOp_56:
	rcall	__EditStop	; stop edit mode
	lds	r24,CpxInx	; get current index
	call	CalcStackB
	call	_CalcSetMemDelX	; set X
	rjmp	_Disp

; ----- 0x57: store complex number to the stack: reg T = real part, reg X = imaginary part

ExecOp_57:
	rcall	__EditStop	; stop edit mode and set X valid
	rcall	CpxNew		; create new complex number

	rcall	__Calc
	.byte	C_GETMEM(REG_T)	; load register T (real)
	.byte	C_GETMEM(REG_X)	; load register X (imaginare)
	.byte	C_CPXSETTOP	; set top complex number
	.byte	C_DEL		; delete
	.byte	C_DEL		; delete
	.byte	C_END
	.balign 2
	ret

; ----- 0x58: load top complex number from the stack to the X+T, but does not delete it from the stack

ExecOp_58:
	rcall	__EditStop	; stop edit mode and set X valid

	rcall	__Calc
	.byte	C_CPXGETTOP	; get top complex number into calculator stack
	.byte	C_SETMEMDEL(REG_X) ; set register X (imaginare) and delete
	.byte	C_SETMEMDEL(REG_T) ; set register T (real) and delete
	.byte	C_END
	.balign 2
	rjmp	_Disp

; ----- 0x59: delete top complex number from the stack

ExecOp_59:
	rjmp	CpxDel

; ----- 0x5A: exchange last two complex numbers on the stack X<->Y

ExecOp_5A:
	rcall	__Calc
	.byte	C_CPXGETPRETOP	; get pre-top complex number into calculator stack
	.byte	C_CPXGETTOP	; get top complex number into calculator stack
	.byte	C_CPXSETPRETOP	; set pre-top complex number
	.byte	C_DEL		; delete
	.byte	C_DEL		; delete
	.byte	C_CPXSETTOP	; set top complex number
	.byte	C_DEL		; delete
	.byte	C_DEL		; delete
	.byte	C_END
	.balign 2
	ret

; ----- 0x5B: duplicate top complex number on the stack

ExecOp_5B:
	rcall	CpxGetTop	; get top number
	rcall	CpxNew		; create new complex number
	rcall	CpxSetTop	; set top number
	call	CalcDel
	jmp	CalcDel

; ----- 0x5C: add complex numbers X + Y (delete Y)
; X + Y = (a + bi) + (c + di) = (a + c) + (bi + di) = (e + fi)

ExecOp_5C:
	rcall	__Calc
	.byte	C_CPXGETPRETOP	; get pre-top complex number into calculator stack (a,bi)
	.byte	C_EXC		; exchange (bi,a)
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (bi,a,c,di)
	.byte	C_EXC2		; pre-exchange (bi,di,c,a)
	.byte	C_ADD		; add (bi,di,a+c)
	.byte	C_EXC2		; pre-exchange (a+c,di,bi)
	.byte	C_ADD		; add (a+c,bi+di) = (e,fi)
	.byte	C_CPXDEL	; delete last complex number (e,fi)
	.byte	C_CPXSETTOP	; set top complex number (e,fi)
	.byte	C_DEL		; delete (e)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x5D: subtract complex numbers X - Y (delete Y)
; X - Y = (a + bi) - (c + di) = (a - c) + (bi - di) = (e + fi)

ExecOp_5D:
	rcall	__Calc
	.byte	C_CPXGETPRETOP	; get pre-top complex number into calculator stack (a,bi)
	.byte	C_EXC		; exchange (bi,a)
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (bi,a,c,di)
	.byte	C_EXC2		; pre-exchange (bi,di,c,a)
	.byte	C_SUB		; add (bi,di,c-a)
	.byte	C_NEG		; negate (bi,di,a-c)
	.byte	C_EXC2		; pre-exchange (a+c,di,bi)
	.byte	C_SUB		; add (a+c,di-bi)
	.byte	C_NEG		; add (a+c,bi-di) = (e,fi)
	.byte	C_CPXDEL	; delete last complex number (e,fi)
	.byte	C_CPXSETTOP	; set top complex number (e,fi)
	.byte	C_DEL		; delete (e)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x5E: multiply complex numbers X * Y (delete Y)
; X * Y = (a + bi) * (c + di) = (ac - bd) + (ad + bc)i = (e + fi)

ExecOp_5E:
	rcall	__Calc
	; multiply X by c
	.byte	C_CPXGETPRETOP	; get pre-top complex number into calculator stack (a,bi)
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (a,bi,c,di)
	.byte	C_DEL		; delete (a,bi,c)
	.byte	C_EXC		; exchange (a,c,bi)
	.byte	C_DUP2		; pre-duplicate (a,c,bi,c)
	.byte	C_MUL		; multiply (a,c,bc)
	.byte	C_EXC2		; pre-exchange (bc,c,a)
	.byte	C_MUL		; multiply (bc,ac)
	; multiply X by d
	.byte	C_CPXGETPRETOP	; get pre-top complex number into calculator stack (bc,ac,a,bi)
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (bc,ac,a,bi,c,di)
	.byte	C_EXC		; exchange (bc,ac,a,bi,di,c)
	.byte	C_DEL		; delete (bc,ac,a,bi,di)
	.byte	C_EXC		; exchange (bc,ac,a,di,bi)
	.byte	C_DUP2		; pre-duplicate (bc,ac,a,di,bi,di)
	.byte	C_MUL		; multiply (bc,ac,a,di,bd)
	.byte	C_EXC2		; pre-exchange (bc,ac,bd,di,a)
	.byte	C_MUL		; multiply (bc,ac,bd,ad)
	; sum results
	.byte	C_EXC2		; exchange (bc,ad,bd,ac)
	.byte	C_SUB		; subtract (bc,ad,bd-ac)
	.byte	C_NEG		; negate (bc,ad,ac-bd)
	.byte	C_EXC2		; pre-exchange (ac-bd,ad,bc)
	.byte	C_ADD		; add (ac-bd,ad+bc) = (e,fi)
	; save result
	.byte	C_CPXDEL	; delete last complex number (e,fi)
	.byte	C_CPXSETTOP	; set top complex number (e,fi)
	.byte	C_DEL		; delete (e)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x5F: divide complex numbers X / Y (delete Y)
; X / Y = (a + bi) / (c + di) = (ac + bd)/(c^2 + d^2) + (bc - ad)/(c^2 + d^2) = (e + fi)

ExecOp_5F:
	rcall	__Calc
	; modulus of Y and change sign of 'd'
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (c,di)
	.byte	C_NEG		; negate (c,-di)
	.byte	C_CPXSETTOP	; set top number (c,-di)
	.byte	C_SQR		; square (c,d^2)
	.byte	C_EXC		; exchange (d^2,c)
	.byte	C_SQR		; square (d^2,c^2)
	.byte	C_ADD		; add (d^2+c^2) = (m)
	.byte	C_END
	.balign 2

	; multiply numbers
	rcall	ExecOp_5E	; multiply X * Y

	rcall	__Calc
	; divide X * Y / modulus
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (m,a,bi)
	.byte	C_EXC2		; pre-exchange (bi,a,m)
	.byte	C_EXC		; exchange (bi,m,a)
	.byte	C_DUP2		; pre-duplicagte (bi,m,a,m)
	.byte	C_DIV		; divide (bi,m,a/m)
	.byte	C_EXC2		; pre-exchange (a/m,m,bi)
	.byte	C_EXC 		; exchange (a/m,bi,m)
	.byte	C_DIV		; divide (a/m,bi/m) = (e,fi)
	; save result
	.byte	C_CPXSETTOP	; set top complex number (e,fi)
	.byte	C_DEL		; delete (e)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x60: power complex numbers X ^ Y (delete Y)
; X ^ Y = (a + bi) ^ (c + di) = e^(y*ln(x)), result will be 0 if X = 0

ExecOp_60:
	rcall	__Calc
	; offset 0: check if X is zero
	.byte	C_CPXGETPRETOP	; get pre-top complex number into calculator stack (a,bi)
	.byte	C_RP		; convert to polar (r,a)
	.byte	C_DEL		; delete (r)
	.byte	C_JUMPT		; skip if not zero ()
	.byte	9		; jump to offset 14 (14-5=9)
	; offset 5: X is zero, result will be 0
	.byte	C_CONST(CONST_0) ; load constant 1 (0)
	.byte	C_CONST(CONST_0) ; load constant 0 (0,0)
	.byte	C_CPXDEL	; delete 2nd operand
	.byte	C_CPXSETTOP	; set top complex number (e,fi)
	.byte	C_DEL		; delete (e)
	.byte	C_DEL		; delete ()
	.byte	C_END
	; offset 12
	.balign 2
	; offset 12
	ret

	; offset 14
	.byte	C_END
	.balign 2

	; exchange operands
	rcall	ExecOp_5A

	; logarithm of X
	rcall	ExecOp_67

	; multiply Y*ln(X)
	rcall	ExecOp_5E

	; exponent
	rjmp	ExecOp_66

; ----- 0x61: power root complex numbers X ^ 1/Y (delete Y)
; X ^ 1/Y = (a + bi) ^ (c + di) = e^(ln(x)/y), result will be 0 if X = 0

ExecOp_61:
	rcall	ExecOp_65	; reciprocal value
	rjmp	ExecOp_60	; power X ^ Y

; ----- 0x62: logarithm X with base Y log_Y(X) (delete Y)
; log_Y(X) = log(X)/log(Y)

ExecOp_62:
	rcall	ExecOp_67	; logarithm Y
	rcall	ExecOp_5A	; exchange numbers
	rcall	ExecOp_67	; logarithm X
	rcall	ExecOp_5A	; exchange numbers
	rjmp	ExecOp_5F	; divide

; ----- 0x63: square of complex number X^2

ExecOp_63:
	rcall	__Calc
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (x,y)
	.byte	C_RP		; convert to polar (r,a)
	.byte	C_EXC		; exchange (a,r)
	.byte	C_SQR		; square (a,r^2)
	.byte	C_EXC		; exchange (r^2,a)
	.byte	C_MUL2		; multiply 2 (r^2,2*a)
	.byte	C_PR		; convert from polar (x,y)
	.byte	C_CPXSETTOP	; set top complex number (x,y)
	.byte	C_DEL		; delete (x)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x64: square root of complex number VX

ExecOp_64:
	rcall	__Calc
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (x,y)
	.byte	C_RP		; convert to polar (r,a)
	.byte	C_EXC		; exchange (a,r)
	.byte	C_SQRT		; square root (a,sqrt(r))
	.byte	C_EXC		; exchange (sqrt(r),a)
	.byte	C_DIV2		; divide 2 (sqrt(r),a/2)
	.byte	C_PR		; convert from polar (x,y)
	.byte	C_CPXSETTOP	; set top complex number (x,y)
	.byte	C_DEL		; delete (x)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x65: reciprocal value of complex number 1/X

ExecOp_65:
	rcall	CpxNew		; create new complex number

	rcall	__Calc
	.byte	C_CONST(CONST_1) ; load constant 1 (1)
	.byte	C_CONST(CONST_0) ; load constant 0 (1,0)
	.byte	C_CPXSETTOP	; set top complex number
	.byte	C_DEL		; delete
	.byte	C_DEL		; delete
	.byte	C_END
	.balign 2

	rcall	ExecOp_5A	; exchange 2 numbers
	rjmp	ExecOp_5F	; divide numbers

; ----- 0x66: exponent of complex number e^X
; exp(X) = exp(a + bi) = exp(a)*cos(b) + exp(a)*sin(b)*i

ExecOp_66:
	rcall	__Calc
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (ln(r),a)
	.byte	C_EXC		; exchange (a,ln(r))
	.byte	C_EXP		; exponent (a,r)
	.byte	C_EXC		; exchange (r,a)
	.byte	C_PR		; convert from polar (x,y)
	.byte	C_CPXSETTOP	; set top complex number (x,y)
	.byte	C_DEL		; delete (x)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x67: logarithm of complex number ln(X)
; ln(X) = ln(a + bi) = ln(a) + bi

ExecOp_67:
	rcall	__Calc
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (x,y)
	.byte	C_RP		; convert to polar (r,a)
	.byte	C_EXC		; exchange (a,r)
	.byte	C_LN		; logaritm (a,ln(r))
	.byte	C_EXC		; exchange (ln(r),a)	
	.byte	C_CPXSETTOP	; set top complex number (ln(r),a)
	.byte	C_DEL		; delete (ln(r))
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- prepare m and n for sin(X) and cos(X)
;   m = (e^b + 1/(e^b))/2 ... hyperbolic cosine
;   n = (e^b - 1/(e^b))/2 ... hyperbolic sine
ExecOp_68_Prep:
	rcall	__Calc
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (a,b)
	; calculate n = (e^b - 1/(e^b))/2
	.byte	C_EXP		; exponent (a,e^b)
	.byte	C_DUP		; duplicate (a,e^b,e^b)
	.byte	C_REC		; reciprocal (a,e^b,1/(e^b))
	.byte	C_DUP2		; pre-duplicate (a,e^b,1/(e^b),e^b)
	.byte	C_DUP2		; pre-duplicate (a,e^b,1/(e^b),e^b,1/(e^b))
	.byte	C_SUB		; subtract (a,e^b,1/(e^b),e^b-1/(e^b))
	.byte	C_DIV2		; divide /2 (a,e^b,1/(e^b),(e^b-1/(e^b))/2 = n)
	; calculate m = (e^b + 1/(e^b))/2
	.byte	C_EXC2		; pre-exchange (a,n,1/(e^b),e^b)
	.byte	C_ADD		; add (a,n,e^b+1/(e^b))
	.byte	C_DIV2		; divide /2 (a,n,(e^b+1/(e^b))/2 = m)
	; multiply by sin, cos
	.byte	C_EXC2		; pre-exchange (m,n,a)
	.byte	C_DUP		; duplicate (m,n,a,a)
	.byte	C_END
	.balign 2
	ret

; ----- 0x68: sinus of complex number sin(X)
; sin(X) = sin(a + bi) = sin(a)*m + cos(a)*n*i = (e + fi)
;   m = (e^b + 1/(e^b))/2 ... hyperbolic cosine
;   n = (e^b - 1/(e^b))/2 ... hyperbolic sine

ExecOp_68:
	rcall	ExecOp_68_Prep  ; prepare

	rcall	__Calc
	; multiply by sin, cos
	.byte	C_SIN		; sinus (m,n,a,sin(a))
	.byte	C_EXC2		; pre-exchange (m,sin(a),a,n)
	.byte	C_EXC		; exchange (m,sin(a),n,a)
	.byte	C_COS		; cosinus (m,sin(a),n,cos(a))
	.byte	C_MUL		; multiply (m,sin(a),n*cos(a) = f)
	.byte	C_EXC2		; pre-exchange (f,sin(a),m)
	.byte	C_MUL		; multiply (f,sin(a)*m = e)
	.byte	C_EXC		; exchange (e,f)
	; save result
	.byte	C_CPXSETTOP	; set top complex number (e,f)
	.byte	C_DEL		; delete (e)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x69: cosinus of complex number cos(X)
; cos(X) = cos(a + bi) = cos(a)*m - sin(a)*n*i = (e + fi)
;   m = (e^b + 1/(e^b))/2 ... hyperbolic cosine
;   n = (e^b - 1/(e^b))/2 ... hyperbolic sine

ExecOp_69:
	rcall	ExecOp_68_Prep  ; prepare

	rcall	__Calc
	; multiply by sin, cos
	.byte	C_COS		; cosinus (m,n,a,cos(a))
	.byte	C_EXC2		; pre-exchange (m,cos(a),a,n)
	.byte	C_EXC		; exchange (m,cos(a),n,a)
	.byte	C_SIN		; sinus (m,cos(a),n,sin(a))
	.byte	C_MUL		; multiply (m,cos(a),n*sin(a))
	.byte	C_NEG		; negate (m,cos(a),-n*sin(a) = f)
	.byte	C_EXC2		; pre-exchange (f,cos(a),m)
	.byte	C_MUL		; multiply (f,cos(a)*m = e)
	.byte	C_EXC		; exchange (e,f)
	; save result
	.byte	C_CPXSETTOP	; set top complex number (e,f)
	.byte	C_DEL		; delete (e)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x6A: tangent of complex number tan(X)

ExecOp_6A:
	rcall	ExecOp_5B	; duplicate
	rcall	ExecOp_68	; sinus
	rcall	ExecOp_5A	; exchange
	rcall	ExecOp_69	; cosinus
	rjmp	ExecOp_5F	; divide

; ----- prepare p, q, s for asin(X) and acos(X)
ExecOp_6B_Prep:
	rcall	__Calc
	; calculate p
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (a,b)
	.byte	C_SQR		; square (a,b^2)
	.byte	C_DUP2		; pre-duplicate (a,b^2,a)
	.byte	C_INC		; increment (a,b^2,a+1)
	.byte	C_SQR		; square (a,b^2,(a+1)^2)
	.byte	C_DUP2		; pre-duplicate (a,b^2,(a+1)^2,b^2)
	.byte	C_ADD		; add (a,b^2,(a+1)^2+b^2)
	.byte	C_SQRT		; square root (a,b^2,sqrt((a+1)^2+b^2) = p)
	; calculate q
	.byte	C_EXC2		; pre-exchange (p,b^2,a)
	.byte	C_DEC		; decrement (p,b^2,a-1)
	.byte	C_SQR		; square (p,b^2,(a-1)^2)
	.byte	C_ADD		; add (p,(a-1)^2+b^2)
	.byte	C_SQRT		; square root (p,sqrt((a-1)^2+b^2) = q)
	; calculate s
	.byte	C_DUP2		; pre-duplicate (p,q,p)
	.byte	C_DUP2		; pre-duplicate (p,q,p,q)
	.byte	C_SUB		; add (p,q,p-q)
	.byte	C_DIV2		; divide /2 (p,q,(p-q)/2 = s)
	.byte	C_END
	.balign 2
	ret

; ----- 0x6B: arcus sinus of complex number asin(X)
; asin(X) = asin(a + bi) = asin(s) + ln(r + sqrt(r^2 - 1))*i = (e + fi)
;  p = sqrt((a+1)^2 + b^2)
;  q = sqrt((a-1)^2 + b^2)
;  r = (p + q)/2
;  s = (p - q)/2

ExecOp_6B:
	rcall	ExecOp_6B_Prep	; prepare p, q, s

	rcall	__Calc
	; calculate e
	.byte	C_ASN		; asin (p,q,asin(s) = e)
	; calculate r
	.byte	C_EXC2		; pre-exchange (e,q,p)
	.byte	C_ADD		; add (e,p+q)
	.byte	C_DIV2		; divide /2 (e,(p+q)/2 = r)
	; calculate f
	.byte	C_DUP		; duplicate (e,r,r)
	.byte	C_SQR		; square (e,r,r^2)
	.byte	C_DEC		; decrement (e,r,r^2-1)
	.byte	C_SQRT		; square root (e,r,sqrt(r^2-1))
	.byte	C_ADD		; add (e,r+sqrt(r^2-1))
	.byte	C_LN		; logarithm (e,ln(r+sqrt(r^2-1)) = f)
	; save result
	.byte	C_CPXSETTOP	; set top complex number (e,f)
	.byte	C_DEL		; delete (e)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x6C: arcus cosinus of complex number acos(X)
; acos(X) = acos(a + bi) = acos(s) - ln(r + sqrt(r^2 - 1))*i = (e + fi)
;  p = sqrt((a+1)^2 + b^2)
;  q = sqrt((a-1)^2 + b^2)
;  r = (p + q)/2
;  s = (p - q)/2

ExecOp_6C:
	rcall	ExecOp_6B_Prep	; prepare p, q, s

	rcall	__Calc
	; calculate e
	.byte	C_ACS		; acos (p,q,acos(s) = e)
	; calculate r
	.byte	C_EXC2		; pre-exchange (e,q,p)
	.byte	C_ADD		; add (e,p+q)
	.byte	C_DIV2		; divide /2 (e,(p+q)/2 = r)
	; calculate f
	.byte	C_DUP		; duplicate (e,r,r)
	.byte	C_SQR		; square (e,r,r^2)
	.byte	C_DEC		; decrement (e,r,r^2-1)
	.byte	C_SQRT		; square root (e,r,sqrt(r^2-1))
	.byte	C_ADD		; add (e,r+sqrt(r^2-1))
	.byte	C_LN		; logarithm (e,ln(r+sqrt(r^2-1)))
	.byte	C_NEG		; negate (e,-ln(r+sqrt(r^2-1)) = f)
	; save result
	.byte	C_CPXSETTOP	; set top complex number (e,f)
	.byte	C_DEL		; delete (e)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x6D: arcus tangent of complex number atan(X)
; atan(X) = atan(a + bi) = (e + fi)
; v = ((1 - a^2 - b^2) + 2*a*i
; R->P
; angle/2 -> e
; ln((a^2 + (b + 1)^2) / (a^2 + (b - 1)^2)) / 4 -> f

ExecOp_6D:
	rcall	__Calc
	; calculate v
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (a,b)
	.byte	C_DUP2		; pre-duplicate (a,b,a)
	.byte	C_SQR		; square (a,b,a^2)
	.byte	C_EXC		; exchange (a,a^2,b)
	.byte	C_SQR		; square (a,a^2,b^2)
	.byte	C_ADD		; add (a,a^2+b^2)
	.byte	C_DEC		; decrement (a,a^2+b^2-1)
	.byte	C_NEG		; negate (a,1-a^2-b^2 = v)
	; calculate e
	.byte	C_EXC		; exchange (v,a)
	.byte	C_MUL2		; multiply *2 (v,2*a)
	.byte	C_RP		; to polar (rad,ang)
	.byte	C_DIV2		; divide /2 (rad,ang/2 = e)
	.byte	C_EXC		; exchange (e,rad)
	.byte	C_DEL		; delete (e)
	; calculate f
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (e,a,b)
	.byte	C_EXC		; exchange (e,b,a)
	.byte	C_SQR		; square (e,b,a^2)
	.byte	C_EXC		; exchange (e,a^2,b)
	.byte	C_DUP2		; pre-duplicate (e,a^2,b,a^2)
	.byte	C_DUP2		; pre-duplicate (e,a^2,b,a^2,b)
	.byte	C_INC		; increment (e,a^2,b,a^2,b+1)
	.byte	C_SQR		; square (e,a^2,b,a^2,(b+1)^2)
	.byte	C_ADD		; add (e,a^2,b,a^2+(b+1)^2)
	.byte	C_EXC2		; pre-exchange (e,a^2+(b+1)^2,b,a^2)
	.byte	C_EXC		; exchange (e,a^2+(b+1)^2,a^2,b)
	.byte	C_DEC		; decrement (e,a^2+(b+1)^2,a^2,b-1)
	.byte	C_SQR		; square (e,a^2+(b+1)^2,a^2,(b-1)^2)
	.byte	C_ADD		; add (e,a^2+(b+1)^2,a^2+(b-1)^2)
	.byte	C_DIV		; divide (e,(a^2+(b+1)^2)/(a^2+(b-1)^2))
	.byte	C_LN		; logarithm (e,ln((a^2+(b+1)^2)/(a^2+(b-1)^2)))
	.byte	C_DIV2		; divide /2 (e,ln((a^2+(b+1)^2)/(a^2+(b-1)^2))/2)
	.byte	C_DIV2		; divide /2 (e,ln((a^2+(b+1)^2)/(a^2+(b-1)^2))/4 = f)
	; save result
	.byte	C_CPXSETTOP	; set top complex number (e,f)
	.byte	C_DEL		; delete (e)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x6E: convert complex number to polar number

ExecOp_6E:
	rcall	__Calc
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (x,y)
	.byte	C_RP		; convert to polar (r,a)
	.byte	C_CPXSETTOP	; set top complex number (r,a)
	.byte	C_DEL		; delete (r)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x6F: convert polar number to complex number

ExecOp_6F:
	rcall	__Calc
	.byte	C_CPXGETTOP	; get top complex number into calculator stack (r,a)
	.byte	C_PR		; convert from polar (x,y)
	.byte	C_CPXSETTOP	; set top complex number (x,y)
	.byte	C_DEL		; delete (x)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x70: search zero cross of user function A' (X=start x, T=end x, returns X new cross, or error)

ExecOp_70:
	rcall	__EditStop	; stop edit mode

	; set running flag
	clr	r24		; clear running flag
	IF_RUNNING
	ldi	r24,1		; set running flag
	SET_RUNNING		; set running
	push	r24

	rcall	__Calc
	; offset 0: prepare delta x 'dx'
	.byte	C_GETMEM(REG_T)	; load register T - end of interval (t)
	.byte	C_GETMEM(REG_X)	; load register X - start of interval (t,a)
	.byte	C_DUP2		; pre-duplicate (t,a,t)
	.byte	C_DUP2		; pre-duplicate (t,a,t,a)
	.byte	C_SUB		; subtract - get width of interval (t,a,t-a)
	.byte	C_CONST(CONST_001) ; load constant 0.01 (t,a,t-a,0.01)
	.byte	C_MUL		; multiply - get delta x (t,a,(t-a)/100 = dx)
	.byte	C_JUMPZ		; jump if dx = 0 (underflow)
	.byte	11		; jump to offset 20 (20-9=11)
	; offset 9: add small amount to not catch old value again
	.byte	C_EXC		; exchange (t,dx,a)
	.byte	C_DUP2		; pre-duplicate (t,dx,a,dx)
	.byte	C_CONST(CONST_001) ; load constant 0.01 (t,dx,a,dx,0.01)
	.byte	C_MUL		; multiply - get small delta x (t,dx,a,dx/100)
	.byte	C_ADD		; add small amount (t,dx,a+dx/100=a)

; start of loop to search interval with cross zero
	; offset 14: check range of interval
	.byte	C_DUP3		; pre-pre-duplicate (t,dx,a,t)
	.byte	C_DUP2		; pre-duplicate (t,dx,a,t,a)
	.byte	C_EXC		; exchange (t,dx,a,a,t)
	.byte	C_LT		; compare if a < t (t,dx,a,0/1)
	.byte	C_JUMPT		; jump if interval is OK, a < t (t,dx,a)
	.byte	6		; jump to offset 26 (26-20=6) (t,dx,a)
	; offset 20: error, not found
	.byte	C_DEL		; delete (t,dx)
	.byte	C_DEL		; delete (t)
	.byte	C_CONST(CONST_0) ; load constant 0 (t,0)
	.byte	C_REC		; reciprocal - set flag not found (t,x)
	.byte	C_JMP		; jump to end (t,x)
	.byte	75		; jump to offset 101 (95-26=75)
	; offset 26: prepare X at end of interval
	.byte	C_DUP2		; pre-duplicate (t,dx,a,dx)
	.byte	C_DUP2		; pre-duplicate (t,dx,a,dx,a)
	.byte	C_ADD		; add (t,dx,a,a+dx=b)
	; offet 29: check Y if cross zero
	.byte	C_DUP2		; pre-duplicate (t,dx,a,b,a)
	.byte	C_USER		; get user function at start of interval (t,dx,a,b,y1)
	.byte	C_JUMPBREAK	; jump if not running
	.byte	64		; jump to offset 97 (97-33=64)
	; offset 33
	.byte	C_JUMPZ		; jump if zero - zero has been found at 'a' (t,dx,a,b,y1)
	.byte	62		; jump to offset 97 (97-35=62) (t,dx,a,b,y1)
	; offset 35:
	.byte	C_DUP2		; pre-duplicate (t,dx,a,b,y1,b)
	.byte	C_USER		; get user function at end of interval (t,dx,a,b,y1,y2)
	.byte	C_JUMPBREAK	; jump if not running
	.byte	58		; jump to offset 97 (97-39=58)
	; offset 39
	.byte	C_JUMPNZ	; jump if not zero (t,dx,a,b,y1,y2)
	.byte	6		; jump to offset 47 (47-31=6)
	; offset 41: zero has been found at 'b'
	.byte	C_DEL		; delete (t,dx,a,b,y1)
	.byte	C_DEL		; delete (t,dx,a,b)
	.byte	C_EXC2		; pre-exchange (t,b,a,dx)
	.byte	C_DEL		; delete (t,b,a)
	.byte	C_JMP		; jump
	.byte	53		; jump to offset 100 (100-47=53)
	; offset 47:
	.byte	C_MUL		; multiply (t,dx,a,b,y12)
	.byte	C_LT0		; check if y12 < 0, cross zero (t,dx,a,b,1/0)
	.byte	C_JUMPT		; jump if < 0, zero cross has been found (t,dx,a,b)
	.byte	34		; jump to offset 85 (85-51=34) (t,dx,a,b)
	; offset 51: shift to next interval
	.byte	C_DEL		; delete (t,dx,a)
	.byte	C_DUP2		; pre-duplicate (t,dx,a,dx)
	.byte	C_ADD		; add (t,dx,a+dx=a2)
	.byte	C_JMP		; jump to start of loop (t,dx,a2)
	.byte	-42		; jump to offset 14 (14-56=-42)

; start of loop to iterate cross zero (here is: (t,dx,a,b,x))
	; offset 56: get y at start of interval
	.byte	C_DUP3		; pre-pre-duplicate (t,dx,a,b,x,a)
	.byte	C_USER		; get y at start of interval (t,dx,a,b,x,y1)
	.byte	C_JUMPBREAK	; jump if not running
	.byte	37		; jump to offset 97 (97-60=37)
	; offset 60
	.byte	C_JUMPNZ	; jump if y1 not zero
	.byte	3		; jump to offset 65 (65-62=3)
	; offset 62: zero has been found at 'a'
	.byte	C_DEL		; delete (t,dx,a,b,x)
	.byte	C_JMP		; jump (t,dx,a,b,x)
	.byte	32		; jump to offset 97 (97-65=32)
	; offset 65: get y at middle of interval
	.byte	C_DUP2		; pre-duplicate (t,dx,a,b,x,y1,x)
	.byte	C_USER		; get y at middle of interval (t,dx,a,b,x,y1,y2)
	.byte	C_JUMPBREAK	; jump if not running
	.byte	28		; jump to offset 97 (97-69=28)
	; offset 69
	.byte	C_JUMPNZ	; jump if y2 not zero (t,dx,a,b,x,y1,y2)
	.byte	5		; jump to offet 76 (76-71=5)
	; offset 71: zero has been found at 'x'
	.byte	C_DEL		; delete (t,dx,a,b,x,y1)
	.byte	C_DEL		; delete (t,dx,a,b,x)
	.byte	C_EXC2		; pre-exchange (t,dx,x,b,a)
	.byte	C_JMP		; jump (t,dx,x,b,a)
	.byte	21		; jump to offset 97 (97-76=21)
	; offset 76: check zero cross
	.byte	C_MUL		; multiply (t,dx,a,b,x,y1*y2)
	.byte	C_LT0		; is result < 0 ? (= sign changed) (t,dx,a,b,x,1/0)
	.byte	C_JUMPF		; jump if not < 0, jump if no sign change (t,dx,a,b,x)
	.byte	3		; jump to offset 83 (83-80=3)
	; offset 80: change sign between 'a' and 'x', 'x' will be next end of interval
	.byte	C_EXC		; exchange (t,dx,a,x,b)
	.byte	C_JMP		; jump
	.byte	1		; jump to offset 84 (84-83=1)
	; offset 83: no change sign between 'a' and 'x', 'x' will be next start of interval
	.byte	C_EXC2		; pre-exchange (t,dx,x,b,a)
	; offset 84:
	.byte	C_DEL		; delete (t,dx,a,b)
	; offet 85: half interval
	.byte	C_EXC2		; pre-exchange (t,b,a,dx)
	.byte	C_DIV2		; divide interval /2 (t,b,a,dx/2)
	.byte	C_DUP4		; pre-duplicate t (t,b,a,dx/2,t)
	.byte	C_ADD		; add to get zero roundind (t,b,a,dx/2+t)
	.byte	C_DUP4		; pre-duplicate t (t,b,a,dx/2+t,t)
	.byte	C_SUB		; subtract to get zero roundind (t,b,a,dx/2+t-t)
	.byte	C_EXC2		; pre-exchange (t,dx/2,a,b)
	.byte	C_DUP3		; pre-pre-duplicate (t,dx/2,a,b,dx/2)
	.byte	C_DUP3		; pre-pre-duplicate (t,dx/2,a,b,dx/2,a)
	.byte	C_EXC		; exchange (t,dx/2,a,b,a,dx/2)
	; offset 95: add dx to 'a' and loop if meaningful
	.byte	C_ADDLOOP	; add and loop (t,dx/2,a,b,a+dx/2=x)
	.byte	-41		; jump to offset 56 (56-97=-41)

; end of loop, save result (here is (t,dx,a,b,x))
	; offset 97: end of loop, zero has been found at 'a'
	.byte	C_DEL		; delete (t,dx,a,b)
	.byte	C_DEL		; delete (t,dx,a)
	.byte	C_EXC		; exchange (t,a,dx)
	; offset 100
	.byte	C_DEL		; delete (t,a)
	; offset 101: correction to round small result to 0
	.byte	C_DUP2		; pre-duplicate	(t,a,t)
	.byte	C_CONST(CONST_100) ; load constant 100 (t,a,t,100)
	.byte	C_MUL		; multiply (t,a,t*100)
	.byte	C_EXC		; exchange (t,t*100,a)
	.byte	C_DUP2		; pre-duplicate (t,t*100,a,t*100)
	.byte	C_SUB		; subtract for rounding (t,t*100,a-t*100)
	.byte	C_ADD		; add for roundig (t,t*100+a-t*100)
	; offset 108: save result X, restore T
	.byte	C_SETMEMDEL(REG_X) ; save result X (t)
	.byte	C_SETMEMDEL(REG_T) ; restore T ()
	; offset 110
	.byte	C_END
	.balign 2

	; restore running flag if was not running
	pop	r24
	tst	r24		; was running?
	brne	4f		; was running
	CLR_RUNNING		; stop running flag

4:	rjmp	_Disp

; ----- 0x71: Simpson's integral of user function A' (HIR H1=lower limit x0, HIR H2=upper limit xn, HIR H3=number of steps n)

ExecOp_71:
	rcall	__EditStop	; stop edit mode

	; set running flag
	clr	r24		; clear running flag
	IF_RUNNING
	ldi	r24,1		; set running flag
	SET_RUNNING		; set running
	push	r24

	rcall	__Calc
	; offset 0: load parameters
	.byte	C_HIR,HIR_RCL+1	; load H1 lower limit x0 (a)
	.byte	C_HIR,HIR_RCL+2	; load H2 upper limit xn (a,b)
	.byte	C_HIR,HIR_RCL+3	; load H3 number of steps n (a,b,n)
	; offset 6: round number of steps to even number / 2
	.byte	C_ABS		; absolute value (a,b,n)
	.byte	C_INC		; increment (a,b,n+1)
	.byte	C_DIV2		; divide / 2 (a,b,(n+1)/2)
	.byte	C_TRUNC		; truncate to integer (a,b,trunc((n+1)/2) = n)
	; offset 10: prepare delta dx
	.byte	C_EXC2		; pre-exchange (n,b,a)
	.byte	C_DUP2		; pre-duplicate (n,b,a,b)
	.byte	C_SUB		; subtract (n,b,a-b)
	.byte	C_NEG		; negate (n,b,b-a)
	.byte	C_DIV2		; divide / 2 (n,b,(b-a)/2)
	.byte	C_DUP3		; pre-duplicate (n,b,(b-a)/2,n)
	.byte	C_DIV		; divide (n,b,(b-a)/n/2 = dx)
	.byte	C_EXC2		; pre-exchange (dx,b,n)
	; offset 18 prepare first y
	.byte	C_DUP2		; pre-duplicate (dx,b,n,b)
	.byte	C_USER		; user function (dx,b,n,y)
	.byte	C_JUMPBREAK	; jump if not running (dx,b,n,y)
	.byte	40		; jump to offset 62 (62-22=40)
	; offset 22
	.byte	C_EXC23		; pre-exchange (dx,n,b,y)

; start of loop (here is (dx,n,b,y))
	; offset 23: shift x
	.byte	C_EXC		; pre-exchange (dx,n,y,b)
	.byte	C_DUP4		; pre-duplicate (dx,n,y,b,dx)
	.byte	C_SUB		; subtract, shift x (dx,n,y,b)
	; offset 26: add y to accumulator, weight 4
	.byte	C_DUP		; duplicate (dx,n,y,b,b)
	.byte	C_USER		; user function (dx,n,y,b,y2)
	.byte	C_MUL2		; multiply * 2 (dx,n,y,b,y2*2)
	.byte	C_MUL2		; multiply * 2 (dx,n,y,b,y2*4)
	.byte	C_EXC23		; exchange (dx,n,b,y,y2*4)
	.byte	C_ADD		; add (dx,n,b,y)
	.byte	C_JUMPBREAK	; jump if not running (dx,n,b,y)
	.byte	28		; jump to offset 62 (62-34=28)
	; offset 34: shift x
	.byte	C_EXC		; exchange (dx,n,y,b)
	.byte	C_DUP4		; pre-duplicate (dx,n,y,b,dx)
	.byte	C_SUB		; subtract, shift x (dx,n,y,b)
	; offset 37: loop counter
	.byte	C_EXC2		; exchange (dx,b,y,n)
	.byte	C_DEC		; decrement (dx,b,y,n-1)
	.byte	C_ROUND		; round (dx,b,y,n)
	.byte	C_JUMPZ		; jump if zero (dx,b,y,n)
	.byte	10		; jump to offset 52 (52-42=10)
	; offset 42:
	.byte	C_EXC2		; exchange (dx,n,y,b)
	; offset 43: add y to accumulator, weight 2
	.byte	C_DUP		; duplicate (dx,n,y,b,b)
	.byte	C_USER		; user function (dx,n,y,b,y2)
	.byte	C_MUL2		; multiply * 2 (dx,n,y,b,y2*2)
	.byte	C_EXC23		; exchange (dx,n,b,y,y2*2)
	.byte	C_ADD		; add (dx,n,b,y)
	.byte	C_JUMPBREAK	; jump if not running (dx,n,b,y)
	.byte	12		; jump to offset 62 (62-50=12)
	; offset 50: go loop
	.byte	C_JMP		; jump (dx,n,b,y)
	.byte	-29		; jump to offset 23 (23-52=-29)

; end of loop (here is (dx,b,y,n))
	; offset 52: add last y to accumulator
	.byte	C_EXC2		; exchange (dx,n,y,b)
	.byte	C_DUP		; duplicate (dx,n,y,b,b)
	.byte	C_USER		; user function (dx,n,y,b,y2)
	.byte	C_EXC23		; exchange (dx,n,b,y,y2)
	.byte	C_ADD		; add (dx,n,b,y)
	; offset 57: multiply by dx / 3
	.byte	C_DUP4		; pre-duplicate (dx,n,b,y,dx)
	.byte	C_BYTE,3	; load byte 3 (dx,n,b,y,dx,3)
	.byte	C_DIV		; divide (dx,n,b,y,dx/3)
	.byte	C_MUL		; multiply (dx,n,b,y*dx/3)
	; offset 62: clear result
	.byte	C_EXC3		; pre-exchange (y,n,b,dx)
	.byte	C_DEL		; delete (y,n,b)
	.byte	C_DEL		; delete (y,n)
	.byte	C_DEL		; delete (y)
	; offset 66: save result X
	.byte	C_SETMEMDEL(REG_X) ; save result X
	; offset 67
	.byte	C_END
	.balign 2

	; restore running flag if was not running
	pop	r24
	tst	r24		; was running?
	brne	4f		; was running
	CLR_RUNNING		; stop running flag

4:	rjmp	_Disp

; ----- 0x72: convert angle from current unit into radians

ExecOp_72:
	rcall	__EditStop	; stop edit mode
	rcall	__Calc
	.byte	C_GETMEM(REG_X)	; load register X = coefficient b (x*m,b)
	.byte	C_TORAD		; convert to radians
	.byte	C_SETMEMDEL(REG_X) ; save result into X
	.byte	C_END
	.balign 2
	rjmp	_Disp

; ----- 0x73: convert angle from radians into current unit

ExecOp_73:
	rcall	__EditStop	; stop edit mode
	rcall	__Calc
	.byte	C_GETMEM(REG_X)	; load register X = coefficient b (x*m,b)
	.byte	C_FROMRAD	; convert from radians
	.byte	C_SETMEMDEL(REG_X) ; save result into X
	.byte	C_END
	.balign 2
	rjmp	_Disp

; ----- 0x74: standard normal distribution Z(x)

ExecOp_74:
	rcall	__EditStop	; stop edit mode
	rcall	__Calc
	.byte	C_GETMEM(REG_X)	; load register X = coefficient b (x*m,b)
	.byte	C_SND		; standard normal ditribution Z(x)
	.byte	C_SETMEMDEL(REG_X) ; save result into X
	.byte	C_END
	.balign 2
	rjmp	_Disp

; ----- 0x75: complementary Gaussian distribution Q(x) (CGD)

ExecOp_75:
	rcall	__EditStop	; stop edit mode
	rcall	__Calc
	.byte	C_GETMEM(REG_X)	; load register X = coefficient b (x*m,b)
	.byte	C_CGD		; complementary Gaussian distribution Q(x) (C_CGD)
	.byte	C_SETMEMDEL(REG_X) ; save result into X
	.byte	C_END
	.balign 2
	rjmp	_Disp

; ----- 0x76: cumulative normal distribution P(x) (CND)

ExecOp_76:
	rcall	__EditStop	; stop edit mode
	rcall	__Calc
	.byte	C_GETMEM(REG_X)	; load register X = coefficient b (x*m,b)
	.byte	C_CND		; cumulative normal distribution P(x) (C_CND)
	.byte	C_SETMEMDEL(REG_X) ; save result into X
	.byte	C_END
	.balign 2
	rjmp	_Disp

; ----- 0x77: max - compare X and T and set X to greater value

ExecOp_77:
	rcall	__EditStop	; stop edit mode
	rcall	__Calc
	; offset 0
	.byte	C_GETMEM(REG_T)	; load register T (t)
	.byte	C_GETMEM(REG_X)	; load register X (t,x)
	.byte	C_DUP2		; pre-duplicate (t,x,t)
	.byte	C_GREQ		; compare x >= t (t,0/1)
	.byte	C_JMP		; jump
	.byte	10		; jump to offset 16 (16-6=10)
	; offset 6
	.balign 2
	; offset 6
	rjmp	_Disp
	; offset 8

; ExecOp_78 relative jump must follow

; ----- 0x78: min - compare X and T and set X to lower value

	; offset 8
ExecOp_78:
	rcall	__EditStop	; stop edit mode
	rcall	__Calc
	; offset 0 (12):
	.byte	C_GETMEM(REG_T)	; load register T (t)
	.byte	C_GETMEM(REG_X)	; load register X (t,x)
	.byte	C_DUP2		; pre-duplicate (t,x,t)
	.byte	C_LTEQ		; compare x <= t (t,0/1)
	; offset 4 (16)
	.byte	C_JUMPT		; skip if x >= t (t)
	.byte	1		; jump to offset 7 (7-6=1)
	; offset 6
	.byte	C_SETMEM(REG_X) ; set register X
	; offset 7
	.byte	C_DEL		; delete
	.byte	C_END
	.balign 2
	rjmp	_Disp

; ----- 0x79: clear all HIR registers

ExecOp_79:
	ldi	r30,lo8(HirReg)
	ldi	r31,hi8(HirReg)
	ldi	r25,hi8(HirReg+HIR_NUM*NUM_BYTES)
1:	st	Z+,R_ZERO
	cpi	r30,lo8(HirReg+HIR_NUM*NUM_BYTES)
	cpc	r31,r25
	brne	1b
	ret

; ----- 0x7A: convert decimal number in X to fraction number in X/T
; We will assume max. 8 digits of numerator and denominator.
; We will extend members by multiplies:
;   240 = 2^4 * 3 * 5
;   192 = 2^6 * 3
;   250 = 2 * 5^3
;   231 = 3 * 7 * 11
;   195 = 3 * 5 * 13
; Contains prime numbers:
;   2^11
;   3^4
;   5^5
;   7
;   11
;   13
; Total multiplier: 518 918 400 000 (12 digits)

ExecOp_7A:
	rcall	__EditStop	; stop edit mode
	rcall	__Calc
	.byte	C_BYTE,240	; load byte (240)
	.byte	C_BYTE,192	; load byte (192)
	.byte	C_MUL		; multiply (n)
	.byte	C_BYTE,250	; load byte (n,250)
	.byte	C_MUL		; multiply (n)
	.byte	C_BYTE,231	; load byte (n,231)
	.byte	C_MUL		; multiply (n)
	.byte	C_BYTE,195	; load byte (n,195)
	.byte	C_MUL		; multiply (n)
	.byte	C_ROUND		; round (n)
	.byte	C_DUP		; duplicate (n,n)
	.byte	C_GETMEM(REG_X)	; load register X (n,n,x)
	.byte	C_MUL		; multiply (n,x*n)
	.byte	C_FRANORM	; normalize result (f,e)
	.byte	C_SETMEMDEL(REG_T) ; save result T (f)
	.byte	C_SETMEMDEL(REG_X) ; save result X ()
	.byte	C_END
	.balign 2
	rjmp	_Disp

; ----- 0x7B: convert fraction number in X/T to decimal number in X

ExecOp_7B:
	rcall	__EditStop	; stop edit mode
	rcall	__Calc
	.byte	C_GETMEM(REG_T)	; load register T (a)
	.byte	C_GETMEM(REG_X)	; load register X (a,b)
	.byte	C_DIV		; divide (a/b=x)
	.byte	C_SETMEMDEL(REG_X) ; save result into X
	.byte	C_END
	.balign 2
	rjmp	_Disp

; ----- 0x7D: subtract fraction numbers X - Y (delete Y)

ExecOp_7D:
	; prepare negate value of number Y
	rcall	__Calc
	.byte	C_CPXGETTOP	; get top fraction number into calculator stack (c,d)
	.byte	C_EXC		; exchange (d,c)
	.byte	C_NEG		; negate (d,-c)
	.byte	C_EXC		; exchange (-c,d)
	.byte	C_CPXSETTOP	; set top complex number (-c,d)
	.byte	C_DEL		; delete (-c)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2

; ----- 0x7C: add fraction numbers X + Y (delete Y)
; X + Y = a/b + c/d = (a*d + b*c)/(b*d) = e/f

ExecOp_7C:
	rcall	__Calc
	.byte	C_CPXGETPRETOP	; get pre-top fraction number into calculator stack (a,b)
	.byte	C_CPXGETTOP	; get top fraction number into calculator stack (a,b,c,d)
	.byte	C_EXC		; exchange (a,b,d,c)
	.byte	C_DUP3		; pre-duplicate (a,b,d,c,b)
	.byte	C_MUL		; multiply (a,b,d,b*c)
	.byte	C_EXC3		; pre-exchange (b*c,b,d,a)
	.byte	C_DUP2		; pre-duplicate (b*c,b,d,a,d)
	.byte	C_MUL		; multiply (b*c,b,d,a*d)
	.byte	C_EXC2		; pre-exchange (b*c,a*d,d,b)
	.byte	C_MUL		; multiply (b*c,a*d,b*d)
	.byte	C_EXC2		; pre-exchange (b*d,a*d,b*c)
	.byte	C_ADD		; add (b*d,a*d+b*c) = (f,e)
	.byte	C_EXC		; exchange (e,f)
	.byte	C_FRANORM	; normalize result (e,f)
	.byte	C_CPXDEL	; delete last fraction number (e,f)
	.byte	C_CPXSETTOP	; set top complex number (e,f)
	.byte	C_DEL		; delete (e)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x7F: divide fraction numbers X / Y (delete Y)

ExecOp_7F:
	; prepare reciprocal value of number Y
	rcall	__Calc
	.byte	C_CPXGETTOP	; get top fraction number into calculator stack (c,d)
	.byte	C_EXC		; exchange = reciprocal value (d,c)
	.byte	C_CPXSETTOP	; set top complex number (d,c)
	.byte	C_DEL		; delete (d)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2

; ----- 0x7E: multiply fraction numbers X * Y (delete Y)
; X * Y = a/b * c/d = (a*c)/(b*d) = e/f

ExecOp_7E:
	rcall	__Calc
	.byte	C_CPXGETPRETOP	; get pre-top fraction number into calculator stack (a,b)
	.byte	C_CPXGETTOP	; get top fraction number into calculator stack (a,b,c,d)
	.byte	C_EXC3		; pre-exchange (d,b,c,a)
	.byte	C_MUL		; multiply (d,b,a*c)
	.byte	C_EXC2		; pre-exchange (a*c,b,d)
	.byte	C_MUL		; multiply (a*c,b*d) = (e,f)
	.byte	C_FRANORM	; normalize result (e,f)
	.byte	C_CPXDEL	; delete last fraction number (e,f)
	.byte	C_CPXSETTOP	; set top complex number (e,f)
	.byte	C_DEL		; delete (e)
	.byte	C_DEL		; delete ()
	.byte	C_END
	.balign 2
	ret

; ----- 0x80: short delay 10 msec (0.01 sec)

ExecOp_80:

	; if running
	IF_RUNNING		; if running
	call	Wait10ms
	IF_RUNNING		; if running
	ret			; return if not running

	; not running
	SET_RUNNING
	rcall	_DispC
	call	Wait10ms
	CLR_RUNNING
	rjmp	_Disp

; ----- 0x81: short delay 100 msec (0.1 sec)

ExecOp_81:

	; if running
	IF_RUNNING		; if running
	call	Wait100ms
	IF_RUNNING		; if running
	ret			; return if not running

	; not running
	SET_RUNNING
	rcall	_DispC
	call	Wait100ms
	CLR_RUNNING
	rjmp	_Disp

; ----- 0x82: cut hidden digits (similar to EE INV EE)

ExecOp_82:
	rcall	__EditStop	; stop edit mode
	; load register X
	ldi	r24,REG_X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	__CalcGetMem	; load register X

; CALCULATOR STACK: -1
; DESTROYS: all
	call	DecNumDef	; decode number (with default size of edit buffer)
	call	EncNum		; encode number

	call	_CalcSetMemDelX ; save register X
	rjmp	_Disp

; ----- 0x83: start measure time

ExecOp_83:
	lds	r24,Time
	lds	r25,Time+1
	sts	TimeMark,r24
	sts	TimeMark+1,r25
	ret

; ----- 0x84: get elapsed time (granularity 0.01 sec, max. 655 seconds = 10.9 minutes)

ExecOp_84:
	rcall	__EditStop	; stop edit mode

	; get elapsed time
	lds	r24,Time
	lds	r25,Time+1
	lds	r26,TimeMark
	lds	r27,TimeMark+1
	sub	r24,r26
	sbc	r25,r27

	; stack time
; INPUT: (R25:)R24 = unsigned integer
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; CALCULATOR STACK: +1
	call	CalcStackW	; stack word

	ldi	r24,CONST_001
	call	CalcConst	; load constant 0.01
	call	CalcMul		; multiply number by 0.01

	call	_CalcSetMemDelX ; save register X
	rjmp	_Disp

; ----- 0x85: get number of data registers (= max. register + 1)

ExecOp_85:
	rcall	__EditStop	; stop edit mode
	ldi	r24,USER_NUM	; number of data registers
	call	CalcStackB	; stack byte
	call	_CalcSetMemDelX ; save register X
	rjmp	_Disp

; ----- 0x86: get state of all user flags as 16-bit number (range 0..65535)

ExecOp_86:
	rcall	__EditStop	; stop edit mode
	ldd	r24,Y+DATA_USERFLAGS
	ldd	r25,Y+DATA_USERFLAGS+1
	andi	r25,~B7		; clear bit 15 (error flag)
	IF_ERROR		; if error flag
	ori	r25,B7		; set bit 15 (error flag)
	call	CalcStackW	; stack word
	call	_CalcSetMemDelX ; save register X
	rjmp	_Disp

; ----- 0x87: get CRC (16-bit word XModem) of program ROM (returns X = calculated CRC, T = expected CRC)

.global ExecOp_87
ExecOp_87:
	rcall	__EditStop	; stop edit mode

	; get calculated CRC into X register
	call	GetCrc		; get CRC -> R25:R24
	call	CalcStackW	; stack word
	call	_CalcSetMemDelX ; save register X

	; get expected CRC into T register
	ldi	r30,lo8(Crc)
	ldi	r31,hi8(Crc)
	lpm	r24,Z+		; get expected CRC
	lpm	r25,Z
	call	CalcStackW	; stack word
	ldi	r24,REG_T
	call	CalcSetMemDel	; save T register
	rjmp	_Disp

; ----- 0x88: set power off time in seconds (min 2.56 second, max. 650 seconds = almost 11 minutes, 0 = off)

ExecOp_88:
	rcall	__EditStop	; stop edit mode

	ldi	r24,REG_X
	rcall	__CalcGetMem	; load register X into stack
	ldi	r24,CONST_100
	call	CalcConst
	call	CalcMul		; multiply number by 100
	call	CalcUnstackW

	; 0 = off
	tst	r25
	breq	3f		; 0 = off

	; minimum 5 seconds
	ldi	r23,hi8(500)
	cpi	r24,lo8(500)
	cpc	r25,r23
	brcc	2f
	ldi	r24,lo8(500)	; minimum 5 seconds
	ldi	r25,hi8(500)

	; maximum
2:	cpi	r25,0xff
	brne	3f
	ldi	r24,0xff
	ldi	r25,0xfe

3:	sts	SleepMax,r24
	sts	SleepMax+1,r25

	; write to EEPROM
	ldi	r26,lo8(CFG_SLEEPMAX+1)
	ldi	r27,hi8(CFG_SLEEPMAX+1)
	push	r24
	call	_EEWrite
	pop	r25
	sbiw	r26,1	
	call	_EEWrite
	rjmp	_Disp

; ----- 0x89: get power off time in seconds

ExecOp_89:
	rcall	__EditStop	; stop edit mode
	lds	r24,SleepMax
	lds	r25,SleepMax+1
	call	CalcStackW	; stack sleep time in 0.01 seconds
	ldi	r24,CONST_001
	call	CalcConst
	call	CalcMul		; multiply number by 0.01
	call	_CalcSetMemDelX ; save register X
	rjmp	_Disp

; ----- 0x8A: display calculator firmware version

ExecOp_8A:
	jmp	DispBuild

; ----- 0x8B: do calculator reset (clears RAM: data registers and base initialize)

ExecOp_8B:

; ----- stop program

	IF_RUNNING		; if running
	call	StopProg	; stop program

; ----- wait until no key pressed

2:	ldd	r24,Y+DATA_KEYRAW
	cpi	r24,NOKEY
	brne	2b

; ----- terminate keyboard
; DESTROYS: -
	call	KEY_Term

; ----- stop generator of LCD contrast control

	out	_SFR_IO_ADDR(TCCR0A),R_ZERO
	out	_SFR_IO_ADDR(TCCR0B),R_ZERO


; ----- reset ports

	out	_SFR_IO_ADDR(PORTB),R_ZERO ; set pull-ups and outputs of port B
	out	_SFR_IO_ADDR(DDRB),R_ZERO ; no outputs
	out	_SFR_IO_ADDR(PORTC),R_ZERO ; all LOW, no pull-ups
	out	_SFR_IO_ADDR(DDRC),R_ZERO ; set COL5 output
	out	_SFR_IO_ADDR(PORTD),R_ZERO
	out	_SFR_IO_ADDR(DDRD),R_ZERO ; set outputs

	cli		; disable interrupts
	jmp	main

; ----- Op jump table

ExecOpTab:
	.word	ExecOp_00	; 00 ... clear print registers 1..4
	.word	ExecOp_01	; 01..04 ... set print register 1..4 from register X
	.word	ExecOp_02	;  Register is integer number of 16 digits, defining 8 characters.
	.word	ExecOp_03	;  Every 2 digits define 1 character of code 00..99 (see character table)
	.word	ExecOp_04
	.word	ExecOp_05	; 05 ... reserved (output print registers 1..4 to printer)
	.word	ExecOp_06	; 06 ... reserved (output print register 1 to printer with register X)
	.word	ExecOp_07	; 07 ... reserved (print asterisk to X position 0..19 of the printer)
	.word	ExecOp_08	; 08 ... reserved (print labels to the printer)
	.word	ExecOp_09	; 09 ... reserved (load selected program to main memory)
	.word	ExecOp_0A	; 0A ... print registers 1 and 2 on 1st row while running (cleared on stop) - full row
	.word	ExecOp_0B	; 0B ... print register 1 on 1st row while running (cleared on stop) - half row + number X
	.word	ExecOp_0C	; 0C ... print register 1 on 1st row while running (cleared on stop) - quart row + number X
	.word	ExecOp_0D	; 0D ... print registers 3 and 4 on 2nd row while running (set to 'C' on stop) - full row
	.word	ExecOp_0E	; 0E ... print register 3 on 2nd row while running (set to 'C' on stop) - half row + number X
	.word	ExecOp_0F	; 0F ... print register 3 on 2nd row while running (set to 'C' on stop) - quart row + number X
	.word	ExecOp_10	; 10 ... sign function of X ... beter use INV |x|
	.word	ExecOp_11	; 11 ... variation
	.word	ExecOp_12	; 12 ... coefficients of linear regression (y = m*x + b, RegT = m, RegX = b)
	.word	ExecOp_13	; 13 ... correlation coefficient
	.word	ExecOp_14	; 14 ... calculate linear regression Y from X (y = m*x + b)
	.word	ExecOp_15	; 15 ... calculate linear regression X from Y (x = (y - b)/m)
	.word	ExecOp_16	; 16,17: get memory organization 999.99 (original: 0x17 sets memory organization)
	.word	ExecOp_17
	.word	ExecOp_18	; 18 ... set flag 7 if no error (or unchanged if error)
	.word	ExecOp_19	; 19 ... set flag 7 if error (or unchanged if no error)
	.word	ExecOp_1A	; 1A ... print registers 1 and 2 on 1st row while stop - full row
	.word	ExecOp_1B	; 1B ... print register 1 on 1st row while stop - half row + number X
	.word	ExecOp_1C	; 1C ... print register 1 on 1st row while stop - quart row + number X
	.word	ExecOp_1D	; 1D ... set display mode flags + X (default after reset)
	.word	ExecOp_1E	; 1E ... set display mode T + X
	.word	ExecOp_1F	; 1F ... set display mode text + X (reset to default by CLR - to flags or T)
	.word	ExecOp_20	; 2x ... increment memory register x (0..15) ... only for compatibility, better use Inc instruction
	.word	ExecOp_21
	.word	ExecOp_22
	.word	ExecOp_23
	.word	ExecOp_24
	.word	ExecOp_25
	.word	ExecOp_26
	.word	ExecOp_27
	.word	ExecOp_28
	.word	ExecOp_29
	.word	ExecOp_2A
	.word	ExecOp_2B
	.word	ExecOp_2C
	.word	ExecOp_2D
	.word	ExecOp_2E
	.word	ExecOp_2F
	.word	ExecOp_30	; 3x ... decrement memory register x (0..15) ... only for compatibility, better use INV Inc instruction
	.word	ExecOp_31
	.word	ExecOp_32
	.word	ExecOp_33
	.word	ExecOp_34
	.word	ExecOp_35
	.word	ExecOp_36
	.word	ExecOp_37
	.word	ExecOp_38
	.word	ExecOp_39
	.word	ExecOp_3A
	.word	ExecOp_3B
	.word	ExecOp_3C
	.word	ExecOp_3D
	.word	ExecOp_3E
	.word	ExecOp_3F
	.word	ExecOp_40	; 40 ... input key from keyboard into reg. X (0..0xFF, keys are remaped by 2nd, 0xff = no key)
				;	monitor keys (display pressed key code):
				;	Lbl A HEX 0F 0F x<>t Lbl x=t Op 40 x=t x=t Pause GTO x=t
	.word	ExecOp_41	; 41 ... check if key is pressed, reg. X = key code (not remaped, 0xRC R=row 1..9, C=column 1..5), returns 0 or 1 in X if key is pressed
				;	monitor key (displays 1 while EE is pressed):
				;	Lbl A CP Lbl x=t HEX 5 2 Op 41 x=t x=t Pause GTO x=t
	.word	ExecOp_42	; 42 ... print character to display, X=character code 0..99, T=position:
				;	0..15 print on 1st row while running (1st row is cleared on program stop)
				;	16..31 print on 2nd row while running (2nd row is set to 'C' on program stop)
				;	32..47 print on 1st row while stop (need to activate Op 0x1F text mode, reset to default mode by CLR)
	.word	ExecOp_43	; 43 ... load font with index X (0=default characters, 1=column left, 2=column right, 3=lines, 4=pixels)
				;	- pseudo-graphics characters are indexed 91..99
				;	- font is restored to default by CLR
	.word	ExecOp_44	; 44 ... delay, X = 0..255 multiply of 10 ms
	.word	ExecOp_45	; 45 ... display progress bar on 1st row if running, from the left, X=0..80
	.word	ExecOp_46	; 46 ... display progress bar on 2nd row if running, from the left, X=0..80
	.word	ExecOp_47	; 47 ... display progress bar on 1st row if stop, on right half from left, with text from print register 1 on left half, X=0..40
	.word	ExecOp_48	; 48 ... display progress bar on 1st row if running, from the right, X=0..80
	.word	ExecOp_49	; 49 ... display progress bar on 2nd row if running, from the right, X=0..80
	.word	ExecOp_4A	; 4A ... display progress bar on 1st row if stop, on right half from right, with text from print register 1 on left half, X=0..40
	.word	ExecOp_4B	; 4B ... display graph column of value X=0..16 on position T=0..15, while running
	.word	ExecOp_4C	; 4C ... display graph column of value X=0..8 on position T=0..7 on 1st row if stop, on right half, with text from register 1 on left half
	.word	ExecOp_4D	; 4D ... set pixel on coordinate X=0..15 and T=0..5, while running
	.word	ExecOp_4E	; 4E ... reset pixel on coordinate X=0..15 and T=0..5, while running
	.word	ExecOp_4F	; 4F ... flip pixel on coordinate X=0..15 and T=0..5, while running
	.word	ExecOp_50	; 50 ... find greatest common divisor of two non-zero integer numbers X and T, result into X (Euclidean algorithm)
	.word	ExecOp_51	; 51 ... get seed of random generator (into X, number 0..4294967295)
	.word	ExecOp_52	; 52 ... set seed of random generator (from X, number 0..4294967295)
	.word	ExecOp_53	; 53 ... load predefined text with index X into X, in editable form (add 00 to shift to the left) (0=OK, 1=ERROR,...)
	.word	ExecOp_54	; 54 ... add text of integer number from T to end of X
	.word	ExecOp_55	; 55 ... initialize stack of complex numbers: reg X = number of complex numbers, reg T = first memory register
	.word	ExecOp_56	; 56 ... get number of complex numbers in the stack
	.word	ExecOp_57	; 57 ... store complex number to the stack: reg T = real part, reg X = imaginary part
	.word	ExecOp_58	; 58 ... load top complex number from the stack to the X+T, but does not delete it from the stack
	.word	ExecOp_59	; 59 ... delete top complex number from the stack
	.word	ExecOp_5A	; 5A ... exchange last two complex numbers on the stack X<->Y
	.word	ExecOp_5B	; 5B ... duplicate top complex number on the stack
	.word	ExecOp_5C	; 5C ... add complex numbers X + Y (delete Y)
	.word	ExecOp_5D	; 5D ... subtract complex numbers X - Y (delete Y)
	.word	ExecOp_5E	; 5E ... multiply complex numbers X * Y (delete Y)
	.word	ExecOp_5F	; 5F ... divide complex numbers X / Y (delete Y)
	.word	ExecOp_60	; 60 ... power complex numbers X ^ Y (delete Y)
	.word	ExecOp_61	; 61 ... power root complex numbers X ^ 1/Y (delete Y)
	.word	ExecOp_62	; 62 ... logarithm X with base Y log_Y(X) (delete Y)
	.word	ExecOp_63	; 63 ... square of complex number X^2
	.word	ExecOp_64	; 64 ... square root of complex number VX
	.word	ExecOp_65	; 65 ... reciprocal value of complex number 1/X
	.word	ExecOp_66	; 66 ... exponent of complex number e^X
	.word	ExecOp_67	; 67 ... logarithm of complex number ln(X)
	.word	ExecOp_68	; 68 ... sinus of complex number sin(X)
	.word	ExecOp_69	; 69 ... cosinus of complex number cos(X)
	.word	ExecOp_6A	; 6A ... tangent of complex number tan(X)
	.word	ExecOp_6B	; 6B ... arcus sinus of complex number asin(X)
	.word	ExecOp_6C	; 6C ... arcus cosinus of complex number acos(X)
	.word	ExecOp_6D	; 6D ... arcus tangent of complex number atan(X)
	.word	ExecOp_6E	; 6E ... convert complex number to polar number
	.word	ExecOp_6F	; 6F ... convert polar number to complex number
	.word	ExecOp_70	; 70 ... search zero cross of user function A' (X=start x, T=end x, returns X new cross, or error)
	.word	ExecOp_71	; 71 ... Simpson's integral of user function A' (HIR H1=lower limit x0, HIR H2=upper limit xn, HIR H3=number of steps n)
	.word	ExecOp_72	; 72 ... convert angle from current unit into radians
	.word	ExecOp_73	; 73 ... convert angle from radians into current unit
	.word	ExecOp_74	; 74 ... standard normal distribution - probability density Z(x)
	.word	ExecOp_75	; 75 ... complementary Gaussian distribution - upper cumulative Q(x)
	.word	ExecOp_76	; 76 ... cumulative normal distribution - lower cumulative P(x)
	.word	ExecOp_77	; 77 ... max - compare X and T and set X to greater value
	.word	ExecOp_78	; 78 ... min - compare X and T and set X to lower value
	.word	ExecOp_79	; 79 ... clear all HIR registers
	.word	ExecOp_7A	; 7A ... convert decimal number in X to fraction number in X/T
	.word	ExecOp_7B	; 7B ... convert fraction number in X/T to decimal number in X
	.word	ExecOp_7C	; 7C ... add fraction numbers X + Y (delete Y)
	.word	ExecOp_7D	; 7D ... subtract fraction numbers X - Y (delete Y)
	.word	ExecOp_7E	; 7E ... multiply fraction numbers X * Y (delete Y)
	.word	ExecOp_7F	; 7F ... divide fraction numbers X / Y (delete Y)
	.word	ExecOp_80	; 80 ... short delay 10 msec (0.01 sec)
	.word	ExecOp_81	; 81 ... short delay 100 msec (0.1 sec)
	.word	ExecOp_82	; 82 ... cut hidden digits (similar to EE INV EE)
	.word	ExecOp_83	; 83 ... start measure time
	.word	ExecOp_84	; 84 ... get elapsed time (granularity 0.01 sec, max. 655 seconds = 10.9 minutes)
	.word	ExecOp_85	; 85 ... get number of data registers (= max. register + 1)
	.word	ExecOp_86	; 86 ... get state of all user flags as 16-bit number (range 0..65535)
	.word	ExecOp_87	; 87 ... get CRC (16-bit word XModem) of program ROM (returns X = calculated CRC, T = expected CRC)
	.word	ExecOp_88	; 88 ... set power off time in seconds (min 2.56 second, max. 650 seconds = almost 11 minutes, 0 = off)
	.word	ExecOp_89	; 89 ... get power off time in seconds
	.word	ExecOp_8A	; 8A ... display calculator firmware version
	.word	ExecOp_8B	; 8B ... do calculator reset (clears RAM: data registers and base initialize)

; update OP_MAX !
