; ****************************************************************************
;
;                            Execute display
;
; ****************************************************************************

#include "include.inc"

	.text

.global _PushAll
_PushAll: jmp	PushAll

.global _PopAll
_PopAll: jmp	PopAll


; switches
; --- pos 0
TextDeg:
	.asciz	"Deg"
	.balign 2

TextRad:
	.asciz	"Rad"
	.balign 2

TextGrd:
	.asciz	"Grd"
	.balign 2

; --- pos 3
TextBin:
	.asciz	"Bin"
	.balign 2

TextOct:
	.asciz	"Oct"
	.balign 2

TextHex:
	.asciz	"Hex"
	.balign 2

; --- pos 6
;.global TextFix
;TextFix:
;	.asciz	"F"
;	.balign 2

; --- pos 8
TextEE:
	.asciz	" EE"
	.balign 2

TextEng:
	.asciz	"Eng"
	.balign 2

; --- pos 11
Text2nd:
	.asciz	"2n"
	.balign 2

Text3rd:
	.asciz	"3d"
	.balign 2

; --- pos 13
TextInv:
	.asciz	"In"
	.balign 2

Text3spc:
	.asciz	"   "
	.balign 2

; --- pos 15

; operators
OperTab:
	.byte	' '		; #define OPER_NONE	0	// no arithmetics operation
	.byte	'+'		; #define OPER_PLUS	1	// +
	.byte	'-'		; #define OPER_MINUS	2	// -
	.byte	'&'		; #define OPER_AND	3	// &
	.byte	'|'		; #define OPER_OR	4	// |
	.byte	CHAR_WAVE	; #define OPER_XOR	5	// ~
	.byte	'*'		; #define OPER_MUL	6	// *
	.byte	':'		; #define OPER_DIV	7	// :
	.byte	CHAR_BACKSLASH	; #define OPER_MOD	8	// backslash (mod trunc)
	.byte	'/'		; #define OPER_MOD2	9	// / (mod floor)
	.byte	'%'		; #define OPER_PERC	10	// %
	.byte	'<'		; #define OPER_LEFT	11	// <
	.byte	'>'		; #define OPER_RIGHT	12	// >
	.byte	'^'		; #define OPER_POWER	13	// ^
	.byte	CHAR_ROOT	; #define OPER_ROOT	14	// root
	.byte	' '		; 15
	.balign 2

; ----------------------------------------------------------------------------
;              Display flags (not if running or programming)
; ----------------------------------------------------------------------------
; DESTROYS: R0
; ----------------------------------------------------------------------------

.global DispFlags
DispFlags:

; ----- must not be running

	IF_RUNNING		; program running?
	ret			; program is running

; ----- must not be programming

	IF_PROGRAM		; programming?
3:	ret			; programming


.global DispFlags2
DispFlags2:

; ----- not in debug mode

	rcall	FlagTestDebug	; debug mode?
	brne	3b		; not in debug mode

; ----- display text

	rcall	FlagTestDispText ; display text?
	breq	4f		; not text mode

	push	r24
	push	r30
	push	r31
; DESTROYS: -
	rcall	DispSetRow1	; set cursor to start of ROW1
; INPUT: R31:R30 = text in ROM (terminated with 0)
; DESTROYS: R31, R30, R24
	ldi	r30,lo8(PrintBuf3)
	ldi	r31,hi8(PrintBuf3)
	rcall	DispTextRam
	pop	r31
	pop	r30
	pop	r24
	ret

; ----- display T register

4:	rcall	FlagTestDispRegT ; display T?
	breq	6f		; not T mode

	rcall	_PushAll	; push all registers
	rcall	PushTempEdit	; push edit buffer
	ldi	r24,REG_T	; register T
	rcall	_CalcGetMem	; load number X into calculator stack
	call	DecNumDef	; decode number (with default size of edit buffer)
	rcall	DispSetRow1	; set cursor to start of ROW1
	ldi	r30,lo8(EditBuf)
	ldi	r31,hi8(EditBuf)
	rcall	DispTextRam	; display edit buffer
	rcall	PopTempEdit	; pop edit buffer
	rcall	_PopAll		; pop all registers (do not use jmp!)
	ret

; ----- push registers

6:	push	r24
	push	r30
	push	r31

; ----- set start position
; DESTROYS: -
	rcall	DispSetRow1	; set cursor to start of ROW1

; ----- angle unit (3 characters)
;#define UNIT_DEG	0	// degrees
;#define UNIT_RAD	1	// radians
;#define UNIT_GRAD	2	// grads
	ldd	r24,Y+DATA_UNIT		; angle unit
	ldi	r30,lo8(TextDeg)
	ldi	r31,hi8(TextDeg)
	cpi	r24,UNIT_RAD		; radians?
	brcs	1f			; deg
	ldi	r30,lo8(TextRad)
	ldi	r31,hi8(TextRad)
	breq	1f			; rad
	ldi	r30,lo8(TextGrd)
	ldi	r31,hi8(TextGrd)
; INPUT: R31:R30 = text in ROM (terminated with 0)
; DESTROYS: R31, R30, R24
1:	rcall	DispTextRom		; display text

; ----- base radix
;#define BASE_DEC	0	// decimal
;#define BASE_BIN	1	// binary
;#define BASE_OCT	2	// octal
;#define BASE_HEX	3	// hexadecimal
	ldd	r24,Y+DATA_BASE		; base radix
	ldi	r30,lo8(TextOct)
	ldi	r31,hi8(TextOct)
	cpi	r24,BASE_OCT		; octal?
	breq	2f			; octal
	ldi	r30,lo8(TextHex)
	ldi	r31,hi8(TextHex)
	brcc	2f			; hex
	ldi	r30,lo8(TextBin)
	ldi	r31,hi8(TextBin)
	cpi	r24,BASE_BIN		; binary?
	breq	2f			; binary
	ldi	r30,lo8(Text3spc)
	ldi	r31,hi8(Text3spc)	; decimal
; INPUT: R31:R30 = text in ROM (terminated with 0)
; DESTROYS: R31, R30, R24
2:	rcall	DispTextRom		; display text

; ----- fix decimal places (2 characters)

	ldd	r30,Y+DATA_FIX
	cpi	r30,FIX_OFF	; fix off?
	brne	3f		; not off
; DESTROYS: -
	rcall	DispSpc
	rcall	DispSpc		; print 2 spaces
	rjmp	4f
3:	ldi	r24,'F'
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	DispChar	; print 'F'
	mov	r24,r30
; INPUT: R24 = nibble
; DESTROYS: -
	rcall	DispHexDig	; display fix

; ----- EE/Eng flag (3 characters)

4:	ldi	r30,lo8(TextEng)
	ldi	r31,hi8(TextEng)
; OUTPUT: NZ = flag is set
; DESTROYS: -
	rcall	FlagTestEng	; test Eng mode
	brne	5f		; Eng mode is on
	ldi	r30,lo8(TextEE)
	ldi	r31,hi8(TextEE)
; OUTPUT: NZ = flag is set
; DESTROYS: -
	rcall	FlagTestEE	; test EE mode
	brne	5f		; EE mode is on
	ldi	r30,lo8(Text3spc)
	ldi	r31,hi8(Text3spc)
; INPUT: R31:R30 = text in ROM (terminated with 0)
; DESTROYS: R31, R30, R24
5:	rcall	DispTextRom

; ----- 2nd flag (2 characters)
;#define F_NONE		0	// no 2nd flag
;#define F_2ND		1	// 2nd flag
;#define F_3RD		2	// 3rd flag
	ldi	r30,lo8(Text2nd)
	ldi	r31,hi8(Text2nd)
	ldd	r24,Y+DATA_FLAG2ND ; get 2nd flag
	cpi	r24,F_2ND
	breq	6f		; 2nd flag is on
	ldi	r30,lo8(Text3rd)
	ldi	r31,hi8(Text3rd)
	brcc	6f		; 3rd flag is on
	ldi	r30,lo8(Text3spc+1)
	ldi	r31,hi8(Text3spc+1)
; INPUT: R31:R30 = text in ROM (terminated with 0)
; DESTROYS: R31, R30, R24
6:	rcall	DispTextRom

; ----- INV flag (2 characters)

	ldi	r30,lo8(TextInv)
	ldi	r31,hi8(TextInv)
; OUTPUT: NZ = flag is set
; DESTROYS: -
	rcall	FlagTestInv	; test Inv flag
	brne	7f		; Inv flag is on
	ldi	r30,lo8(Text3spc+1)
	ldi	r31,hi8(Text3spc+1)
; INPUT: R31:R30 = text in ROM (terminated with 0)
; DESTROYS: R31, R30, R24
7:	rcall	DispTextRom

; ----- open arithmetics operation (1 character)
; OUTPUT: NZ = flag is set
; DESTROYS: -
	rcall	FlagTestInKey	; user input
	ldi	r24,'?'
	brne	8f		; waiting input
; OUTPUT: R31:R30 = pointer into OperStack
;	 R24 = current operation
	call	ExecLevel	; get current operation
	andi	r24,OPER_MASK	; mask operation
	ldi	r30,lo8(OperTab)
	ldi	r31,hi8(OperTab) ; table of operators
	add	r30,r24
	adc	r31,R_ZERO
	lpm	r24,Z		; load character from table

	cpi	r24,' '
	brne	8f		; operator is valid

	ldd	r30,Y+DATA_LEVEL ; current level
	tst	r30		; base level?
	breq	8f		; base level

	ldi	r24,'('		; open parenthessis
; INPUT: R24 = character or data
; DESTROYS: -
8:	rcall	DispChar

; ----- pop registers

	pop	r31
	pop	r30
	pop	r24
	ret

; ----------------------------------------------------------------------------
;                Display one program byte (2 digits or 2 spaces)
; ----------------------------------------------------------------------------
; INPUT: R27:R26 = source address
; OUTPUT: R24 = program byte (only if address is valid)
;	  R27:R26 = new address (+1)
; ----------------------------------------------------------------------------

DispPrgMem:

; ---- Load one byte from program
; INPUT: R27:R26 (X) = address (can be out of range)
; OUTPUT: R24 = byte (0 if invalid)
;	  R27:R26 (X+1) = new address, increased by 1 (not changed on error)
;	  CY = invalid address (R27:R26 not changed)
; DESTROYS: -
	rcall	LoadByte
	brcs	2f		; invalid address
; INPUT: R24 = byte
; DESTROYS: -
	rjmp	DispHexB	; display byte

2:	adiw	r26,1		; increase address
; DESTROYS: -
	rcall	DispSpc		; display 2 spaces
; DESTROYS: -
	rjmp	DispSpc

; ----------------------------------------------------------------------------
;                      Display current program row
; ----------------------------------------------------------------------------
; INPUT: R24 = start cursor position
; DESTROYS: R31, R30, R27, R26, R25, R24
; ----------------------------------------------------------------------------

DispProg2:

; ----- set cursor position
; INPUT: R24 = position 0..15, add ROW1 or ROW2
; DESTROYS: -
	rcall	DispSetPos	; set cursor position

; ----- prepare and check address

	ldd	r26,Y+DATA_ADDR
	ldd	r27,Y+DATA_ADDR+1
	ldd	r24,Y+DATA_PROGEND
	ldd	r25,Y+DATA_PROGEND+1
	cp	r26,r24
	cpc	r27,r25
	brcc	9f		; invalid address

; ----- display address (3 digits)

	movw	r24,r26
	ldd	r30,Y+DATA_PROGBEG
	sub	r24,r30
	ldd	r30,Y+DATA_PROGBEG+1
	sbc	r25,r30
; INPUT: R25:R24 = number
; DESTROYS: -
	rcall	Disp3Dig	; display address

; ----- display asterisk if program is read-only (module), or space otherwise

	ldd	r24,Y+DATA_PROGINX ; current program index
	tst	r24		; main program?
	ldi	r24,'*'
	brne	2f		; not main program
	ldi	r24,' '
; INPUT: R24 = character or data
; DESTROYS: -
2:	rcall	DispChar	; display character

; ----- display program content
; INPUT: R27:R26 = source address
; OUTPUT: R24 = program byte (only if address is valid)
;	  R27:R26 = new address (+1)
	rcall	DispPrgMem	; display program content
; DESTROYS: -
	rcall	DispSpc		; display space

; ----- display name of program byte
; INPUT: R24 = code
; OUTPUT: R31:R30 = ASCIIZ text in ROM
; DESTROYS: R25
	rcall	GetDispName	; get text of key

; INPUT: R31:R30 = text in ROM (terminated with 0)
; DESTROYS: R31, R30, R24
	rcall	DispTextRom	; display text

; ----- clear rest of line
; DESTROYS: -
9:	rjmp	DispSpcClr

; ----------------------------------------------------------------------------
;           Display flags, number X or programming (not if running)
; ----------------------------------------------------------------------------
; DESTROYS: R0
; ----------------------------------------------------------------------------

.global Disp
Disp:

; ----- display flags (not if running, not if programming)
; DESTROYS: -
	rcall	DispFlags

; ----- display X or edit buffer (not if running, not if programming)
; DESTROYS: R0

	rcall	DispEdit

; ----- display programming (only if programming)
; DESTROYS: -

; DispProg must follow

; ----------------------------------------------------------------------------
;                Display programming mode (only if programming)
; ----------------------------------------------------------------------------
; DESTROYS: -
; ----------------------------------------------------------------------------

.global DispProg
DispProg:

; ----- check programming

	IFN_PROGRAM		; programming?
	ret			; no programming

; ----- push registers

	push	r24
	push	r25
	push	r26
	push	r27
	push	r30
	push	r31

; ----- display 1st row

	; set cursor position
; DESTROYS: -
	rcall	DispSetRow1	; set cursor to start of ROW1

	; prepare address
	ldd	r26,Y+DATA_ADDR
	ldd	r27,Y+DATA_ADDR+1

	; limit range (may point behind last byte)
	ldd	r24,Y+DATA_PROGEND
	ldd	r25,Y+DATA_PROGEND+1
	cp	r26,r24
	cpc	r27,r25
	brcs	1f		; address is OK
	movw	r26,r24		; R27:R26 <- memory end
	sbiw	r26,1		; decrease address to last byte
	std	Y+DATA_ADDR,r26	; limit address
	std	Y+DATA_ADDR+1,r27

	; display byte -2
1:	sbiw	r26,2
; INPUT: R27:R26 = source address
; OUTPUT: R24 = program byte (only if address is valid)
;	  R27:R26 = new address (+1)
	rcall	DispPrgMem	; display memory content
; DESTROYS: -
	rcall	DispSpc

	; display byte -1
; INPUT: R27:R26 = source address
; OUTPUT: R24 = program byte (only if address is valid)
;	  R27:R26 = new address (+1)
	rcall	DispPrgMem	; display memory content
; DESTROYS: -
	rcall	DispSpc

	; display byte [0]
	ldi	r24,'['
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	DispChar
; INPUT: R27:R26 = source address
; OUTPUT: R24 = program byte (only if address is valid)
;	  R27:R26 = new address (+1)
	rcall	DispPrgMem	; display memory content
	ldi	r24,']'
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	DispChar
; DESTROYS: -
	rcall	DispSpc

	; display byte +1
; INPUT: R27:R26 = source address
; OUTPUT: R24 = program byte (only if address is valid)
;	  R27:R26 = new address (+1)
	rcall	DispPrgMem	; display memory content
; DESTROYS: -
	rcall	DispSpc

	; display byte +2
; INPUT: R27:R26 = source address
; OUTPUT: R24 = program byte (only if address is valid)
;	  R27:R26 = new address (+1)
	rcall	DispPrgMem	; display memory content

; ----- display 2nd row

	ldi	r24,ROW2+0	; address of ROW2
; INPUT: R24 = start cursor position
; DESTROYS: R31, R30, R27, R26, R25, R24
	rcall	DispProg2	; display program

; ----- pop registers

9:	pop	r31
	pop	r30
	pop	r27
	pop	r26
	pop	r25
	pop	r24
	ret

; ----------------------------------------------------------------------------
;         Display X or edit buffer (not if running or programming)
; ----------------------------------------------------------------------------
; OUTPUT: R1 = 0
; DESTROYS: R0
; ----------------------------------------------------------------------------

.global DispEdit
DispEdit:

; ----- must not be running

	IF_RUNNING		; running?
	ret			; program is running, no display

; ----- must not be programming

	IF_PROGRAM		; programming?
	ret			; programming, no display
	
; ----- if not edit mode, decode X into edit buffer
; DESTROYS: R0

.global DispEdit2
DispEdit2:

; ----- push registers R4..R27, R30, R31
; OUTPUT: R1 = 0
; DESTROYS: R0
; STACK: push 26 bytes
	rcall	_PushAll	; push all registers

	IF_EDITON		; if edit mode
	rjmp	2f		; skip decode X

	ldi	r24,REG_X	; register X
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; load number X into calculator stack
; CALCULATOR STACK: -1
; DESTROYS: all
	call	DecNumDef	; decode number (with default size of edit buffer)

; ----- display mantissa in debug mode

2:	rcall	FlagTestDebug	; debug mode?
	breq	6f		; not debug mode

	rcall	DispSetRow1	; set cursor to start of ROW1
	ldi	r30,lo8(MemReg + REG_X*NUM_BYTES + 2)
	ldi	r31,hi8(MemReg + REG_X*NUM_BYTES + 2)
	ldi	r25,8
4:	ld	r24,Z+
	rcall	DispHexB
	dec	r25
	brne	4b

; ----- set cursor to start of row 2
	; set cursor position
; DESTROYS: -
6:	rcall	DispSetRow2	; set cursor to start of ROW2

; ----- display edit buffer (buffer is terminated by 0)
; INPUT: R31:R30 = text in RAM (terminated with 0)
; DESTROYS: R31, R30, R24
	ldi	r30,lo8(EditBuf)
	ldi	r31,hi8(EditBuf)
	rcall	DispTextRam

; ----- pop registers R4..R27, R30, R31
; OUTPUT: R1 = 0
; DESTROYS: R0
; STACK: pop 26 bytes
	rcall	_PopAll		; pop all registers (do not use jmp!)
	ret

; ----------------------------------------------------------------------------
;                          display C
; ----------------------------------------------------------------------------

.global DispC
DispC:

	push	r24
	push	r30
	push	r31

;------ clear 1st row
; DESTROYS: -
	rcall	DispSetRow1	; set cursor to start of ROW1
; INPUT: R31:R30 = text in ROM (terminated with 0)
; DESTROYS: R31, R30, R24
	ldi	r30,lo8(PrintBuf1)
	ldi	r31,hi8(PrintBuf1)
	rcall	DispTextRam

; ----- set cursor to start of row 2
; DESTROYS: -
	rcall	DispSetRow2	; set cursor to start of ROW2
; INPUT: R31:R30 = text in ROM (terminated with 0)
; DESTROYS: R31, R30, R24
	ldi	r30,lo8(PrintBuf2)
	ldi	r31,hi8(PrintBuf2)
	rcall	DispTextRam

	pop	r31
	pop	r30
	pop	r24
	ret
 
; ----------------------------------------------------------------------------
;                            Indicate error
; ----------------------------------------------------------------------------
; DESTROYS: R27, R26, R25, R24
; ----------------------------------------------------------------------------

.global DispErr
DispErr:

; ----- display running flag

	IF_RUNNING		; if running
	rjmp	DispC		; display "C"

; ----- not if programming
	
	IF_PROGRAM		; programming?
	ret			; programming, no display

; ----- display flags

	rcall	DispFlags2

; ----- check time to indicate error (granularity 10 ms, blinking period 0.6 sec)

	ldd	r25,Y+DATA_TIME
	andi	r25,0x3f
	cpi	r25,21
	brcs	2f		; time is < 33%

; ----- display X or edit buffer

	rjmp	DispEdit

; ----- set cursor to start of row 2
; DESTROYS: -
2:	rcall	DispSetRow2	; set cursor to start of ROW2

; ----- display character 'F' or 'E'

	ldi	r24,'E'		; Error mark
	IF_FATAL		; if fatal error
	ldi	r24,'F'		; Fatal mark
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	DispChar

; ----- clear rest of row

; DESTROYS: -
	rjmp	DispSpcClr

; ----------------------------------------------------------------------------
;                    Display trace (holding GTO, only if running)
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R27, R26, R25, R24, T flag
; ----------------------------------------------------------------------------

.global DispTrace
DispTrace:

; ----- must be running

	IFN_RUNNING		; if not running
	ret			; program is not running

; ----- load old trace flag -> T

	ldd	r25,Y+DATA_FLAGS	; get flags
	bst	r25,F_OLDTRACE		; load old trace flag into T

; ----- update old trace flag

	ori	r25,BIT(F_OLDTRACE)	; set old trace flag
	IFN_TRACE			; if not trace
	andi	r25,~BIT(F_OLDTRACE)	; if not trace, clear old trace flag
	std	Y+DATA_FLAGS,r25	; save new flags

; ----- display 'C' if was tracing and not now

	brtc	2f			; skip if was not tracing previously
	IFN_TRACE			; if not trace
	rcall	DispC			; if not trace, display C and clear 1st row

; ----- check if tracing

2:	IFN_TRACE			; if not trace
	ret				; return if not trace

; ----- display program code on 1st row

	rcall	FlagTestDebug		; debug mode?
	brne	3f			; skip in debug mode

	ldi	r24,0+ROW1
; INPUT: R24 = start cursor position
; DESTROYS: R31, R30, R27, R26, R25, R24
	rcall	DispProg2		; display program code

; ----- display X or edit buffer on 2nd row

3:	rcall	DispEdit2		; display X or edit buffer

; ----- wait some time
; DESTROYS: R24
	jmp	Wait250ms	; wait 250 ms

; ----------------------------------------------------------------------------
;                     Clear running print buffer
; ----------------------------------------------------------------------------
; DESTROYS: R27, R26, R24
; ----------------------------------------------------------------------------

.global ClrPrintBuf
ClrPrintBuf:

	; clear print buffer 1
	ldi	r26,lo8(PrintBuf1) ; buffer in row 1
	ldi	r27,hi8(PrintBuf1)
	ldi	r24,' '
1:	st	X+,r24		; write space character
	cpi	r26,lo8(PrintBuf1+LCD_COLNUM)
	brne	1b
	st	X,R_ZERO	; terminating zero

	; clear print buffer 2
	ldi	r26,lo8(PrintBuf2) ; buffer in row 2
	ldi	r27,hi8(PrintBuf2)
	ldi	r24,'C'
	st	X+,r24
	ldi	r24,' '
1:	st	X+,r24		; write space character
	cpi	r26,lo8(PrintBuf2+LCD_COLNUM)
	brne	1b
	st	X,R_ZERO	; terminating zero
	ret
