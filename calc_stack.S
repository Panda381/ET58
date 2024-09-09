; ****************************************************************************
;
;                        Calculator stack manipulation
;
; ****************************************************************************

#include "include.inc"

	.text

; ----------------------------------------------------------------------------
;                    Get end of calculator stack -> Z
; ----------------------------------------------------------------------------
; OUTPUT: R31:R30 (Z) = end of calculator stack
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcStkEnd
CalcStkEnd:
	ldd	r30,Y+DATA_STKEND
	ldd	r31,Y+DATA_STKEND+1 ; end of calculator stack
	ret

; ----------------------------------------------------------------------------
;                  Get last number on calculator stack -> Z
; ----------------------------------------------------------------------------
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcTop
CalcTop:
; OUTPUT: R31:R30 (Z) = end of calculator stack
; DESTROYS: -
	rcall	CalcStkEnd	; get end of calculator stack -> Z
	sbiw	r30,NUM_BYTES	; Z <- last number on calculator stack
	ret

; ----------------------------------------------------------------------------
;             Get exponent and check zero number -> Z, R25:R24
; ----------------------------------------------------------------------------
; OUTPUT: R31:R30 (Z) = last number on calculator stack
;	  R25:R24 = exponent (0 = number is zero, 0xFFFF = overflow)
;	  ZY = number is 0
;	  CY = number is overflow
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcTopCheck
CalcTopCheck:

; ----- get last number on calculator stack -> Z
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop

; ----- check zero and overflow

	ldd	r25,Z+0		; R25 <- exponent HIGH
	ldd	r24,Z+1		; R24 <- exponent LOW

	adiw	r24,1
	sbiw	r24,1		; check overflow (C) and zero (Z)
	ret

; ----------------------------------------------------------------------------
;                 Get pre-last number on calculator stack -> Z
; ----------------------------------------------------------------------------
; OUTPUT: R31:R30 (Z) = pre-last number on calculator stack
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcPreTop
CalcPreTop:
; OUTPUT: R31:R30 (Z) = end of calculator stack
; DESTROYS: -
	rcall	CalcStkEnd	; get end of calculator stack -> Z
	sbiw	r30,2*NUM_BYTES ; Z <- pre-last number on calculator stack
	ret

; ----------------------------------------------------------------------------
;               Get last 2 numbers on calculator stack -> X, Z
; ----------------------------------------------------------------------------
; OUTPUT: R27:R26 (X) = pre-last number on calculator stack
;	  R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
; ----------------------------------------------------------------------------

.global CalcTop2
CalcTop2:
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop		; get last number on calculator stack -> Z
	movw	r26,r30		; X <- last number
	sbiw	r26,NUM_BYTES	; X <- pre-last number
	ret

; ----------------------------------------------------------------------------
;                    Exchange registers X and Z
; ----------------------------------------------------------------------------
; INPUT and OUTPUT: R31:R30 (Z), R27:R26 (X) = registers to exchange
; DESTROYS: -
; ----------------------------------------------------------------------------

.global ExcXZ
ExcXZ:
	eor	r30,r26		; R30 <- ZL^XL
	eor	r26,r30		; R26 <- ZL
	eor	r30,r26		; R30 <- XL

	eor	r31,r27		; R31 <- ZH^XH
	eor	r27,r31		; R27 <- ZH
	eor	r31,r27		; R31 <- XH
ExcXZ2:
	ret

; ----------------------------------------------------------------------------
;                 Create new number on end of calculator stack
; ----------------------------------------------------------------------------
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
; ----------------------------------------------------------------------------
; Does not check stack overflow.

.global CalcNew
CalcNew:

; ----- get current end of calculator stack
; OUTPUT: R31:R30 (Z) = end of calculator stack
; DESTROYS: -
	rcall	CalcStkEnd	; get end of calculator stack -> Z

; ----- shift pointer and save new pointer

	adiw	r30,NUM_BYTES	; increase pointer
	rcall	CalcDel2	; set new pointer

; ----- shift back to last number

	sbiw	r30,NUM_BYTES

; ----- internal check overflow

	push	r24
	ldi	r24,hi8(CalcStack+CALC_MAX*NUM_BYTES)
	cpi	r30,lo8(CalcStack+CALC_MAX*NUM_BYTES)
	cpc	r31,r24
	pop	r24
	brcs	ExcXZ2
	jmp	Fatal		; fatal error

; ----------------------------------------------------------------------------
;                    Get address of memory variable
; ----------------------------------------------------------------------------
; INPUT: R24 = index of variable 0..MEM_NUM-1
; OUTPUT: R31:R30 = address of variable
;	  R1 = 0
; DESTROYS: R0
; ----------------------------------------------------------------------------

.global CalcAddrMem
CalcAddrMem:
        ldi	r30,NUM_BYTES
	mul	r30,r24		; convert to offset
	movw	r30,r0
	subi	r30,lo8(-(MemReg))
	sbci	r31,hi8(-(MemReg))
	clr	r1		; restore R1=R_ZERO
	ret

; ----------------------------------------------------------------------------
;                   Set memory from stack (C_SETMEM)
; ----------------------------------------------------------------------------
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; ----------------------------------------------------------------------------
; Does not delete the number from calculator stack.

.global CalcSetMem
CalcSetMem:

; ----- get address of the number -> R27:R26
; INPUT: R24 = index of variable 0..MEM_NUM-1
; OUTPUT: R31:R30 = address of variable
;	  R1 = 0
; DESTROYS: R0
	rcall	CalcAddrMem	; get number address -> Z
	movw	r26,r30		; R27:R26 (X) <- destination address

; ----- get address of last number
; OUTPUT: R31:R30 (Z) = last number on calculator stack
; DESTROYS: -
	rcall	CalcTop		; get number in stack -> Z

; ----- copy number (Z -> X)
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	rjmp	CalcCopyNum	; copy number from Z to X

; ----------------------------------------------------------------------------
;                Set memory from stack and delete (C_SETMEMDEL)
; ----------------------------------------------------------------------------
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: -1
; ----------------------------------------------------------------------------

.global CalcSetMemDel
CalcSetMemDel:
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
	rcall	CalcSetMem
; DESTROYS: R31, R30
; CALCULATOR STACK: -1
	rjmp	CalcDel

; ----------------------------------------------------------------------------
;             Get number from memory into stack (C_GETMEM)
; ----------------------------------------------------------------------------
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
; ----------------------------------------------------------------------------

.global CalcGetMem
CalcGetMem:

; ----- get address of the number -> R31:R30 (Z)
; INPUT: R24 = index of variable 0..MEM_NUM-1
; OUTPUT: R31:R30 = address of variable
;	  R1 = 0
; DESTROYS: R0
	rcall	CalcAddrMem


; INPUT: R31:R30 = register address
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
.global CalcGetMemZ
CalcGetMemZ:

; ----- create new number on top of stack (and save Z pointer)

	movw	r24,r30		; save source address Z
; OUTPUT: R31:R30 (Z) = new number
; DESTROYS: -
; CALCULATOR STACK: +1
	rcall	CalcNew		; create new number -> Z
	movw	r26,r30		; X <- new number, destination address
	movw	r30,r24		; restore source address Z

; ----- copy number Z -> X
; INPUT: R31:R30 (Z) = source address in RAM
;	 R27:R26 (X) = destination address in RAM
; OUTPUT: R31:R30 (Z) = next source address in RAM
;	 R27:R26 (X) = next destination address in RAM
; DESTROYS: R25, R24
	rjmp	CalcCopyNum	; copy number from Z to X
