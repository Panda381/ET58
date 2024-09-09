; ****************************************************************************
;
;                            Program
;
; ****************************************************************************

#include "include.inc"

	.text

; bridges
.global _EERead
_EERead: jmp EERead

.global _EEWrite
_EEWrite: jmp EEWrite

; key names for display
.global DispName
DispName:
	.asciz	"0"		; 0x00 digit 0
	.asciz	"1"		; 0x01 digit 1
	.asciz	"2"		; 0x02 digit 2
	.asciz	"3"		; 0x03 digit 3
	.asciz	"4"		; 0x04 digit 4
	.asciz	"5"		; 0x05 digit 5
	.asciz	"6"		; 0x06 digit 6
	.asciz	"7"		; 0x07 digit 7
	.asciz	"8"		; 0x08 digit 8
	.asciz	"9"		; 0x09 digit 9
	.asciz	"0A"		; 0x0a digit 0A
	.asciz	"0B"		; 0x0b digit 0B
	.asciz	"0C"		; 0x0c digit 0C
	.asciz	"0D"		; 0x0d digit 0D
	.asciz	"0E"		; 0x0e digit 0E
	.asciz	"0F"		; 0x0f digit 0F

	.asciz	"E'"		; 0x10 label E'
	.asciz	"A"		; 0x11 label A
	.asciz	"B"		; 0x12 label B
	.asciz	"C"		; 0x13 label C
	.asciz	"D"		; 0x14 label D
	.asciz	"E"		; 0x15 label E
	.asciz	"A'"		; 0x16 label A'
	.asciz	"B'"		; 0x17 label B'
	.asciz	"C'"		; 0x18 label C'
	.asciz	"D'"		; 0x19 label D'
	.asciz	"A''"		; 0x1a label A''
	.asciz	"B''"		; 0x1b label B''
	.asciz	"C''"		; 0x1c label C''
	.asciz	"D''"		; 0x1d label D''
	.asciz	"E''"		; 0x1e label E''
	.asciz	"F"		; 0x1f label F

	.asciz	""		; 0x20
	.asciz	"2nd"		; 0x21 2nd
	.asciz	"INV"		; 0x22 INV
	.asciz	"ln x"		; 0x23 Ln x
	.asciz	"CE"		; 0x24 CE
	.asciz	"CLR"		; 0x25 CLR
	.asciz	"SBR Ind"	; 0x26 SBR Ind
	.asciz	"HIR Ind"	; 0x27 HIR Ind
	.asciz	"log"		; 0x28 log
	.asciz	"CP"		; 0x29 CP
	.asciz	""		; 0x2a
	.asciz	"code"		; 0x2b code
	.asciz	"log2"		; 0x2c log2
	.asciz	"rand"		; 0x2d rand
	.asciz	""		; 0x2e
	.asciz	""		; 0x2f

	.asciz	"tan"		; 0x30 tan
	.asciz	"LRN"		; 0x31 LRN
	.asciz	"x<->t"		; 0x32 x<>t
	.asciz	"x^2"		; 0x33 x^2
	.byte CHAR_ROOT
	.asciz	"x"		; 0x34 Vx
	.asciz	"1/x"		; 0x35 1/x
	.asciz	"Pgm"		; 0x36 Pgm
	.asciz	"P->R"		; 0x37 P->R
	.asciz	"sin"		; 0x38 sin
	.asciz	"cos"		; 0x39 cos
	.asciz	"Temp"		; 0x3a Temp
	.asciz	"x<->y"		; 0x3b x<>y
	.asciz	"sinh"		; 0x3c sinh
	.asciz	"cosh"		; 0x3d cosh
	.asciz	"tanh"		; 0x3e tanh
	.asciz	""		; 0x3f

	.asciz	"Ind"		; 0x40 Ind
	.asciz	"SST"		; 0x41 SST
	.asciz	"STO"		; 0x42 STO
	.asciz	"RCL"		; 0x43 RCL
	.asciz	"SUM"		; 0x44 SUM
	.asciz	"y^x"		; 0x45 y^x
	.asciz	"Ins"		; 0x46 Ins
	.asciz	"CMs"		; 0x47 CMs
	.asciz	"Exc"		; 0x48 Exc
	.asciz	"Prd"		; 0x49 Prd
	.asciz	"Bat"		; 0x4a Bat
	.asciz	"x!"		; 0x4b n!
	.asciz	"ln x!"		; 0x4c ln n!
	.asciz	"log x!"	; 0x4d log n!
	.asciz	"mod2"		; 0x4e mod2 (floor)
	.asciz	""		; 0x4f

	.asciz	"|x|"		; 0x50 |x|
	.asciz	"BST"		; 0x51 BST
	.asciz	"EE"		; 0x52 EE
	.asciz	"("		; 0x53 (
	.asciz	")"		; 0x54 )
	.asciz	":"		; 0x55 :
	.asciz	"Del"		; 0x56 Del
	.asciz	"Eng"		; 0x57 Eng
	.asciz	"Fix"		; 0x58 Fix
	.asciz	"Int"		; 0x59 Int
	.asciz	"LCD"		; 0x5a LCD
	.asciz	"<<"		; 0x5b <<
	.asciz	">>"		; 0x5c >>
	.asciz	"round"		; 0x5d round
	.asciz	"mod"		; 0x5e mod (trunc)
	.asciz	""		; 0x5f

	.asciz	"Deg"		; 0x60 Deg
	.asciz	"GTO"		; 0x61 GTO
	.asciz	"Pgm Ind"	; 0x62 Pgm Ind
	.asciz	"Exc Ind"	; 0x63 Exc Ind
	.asciz	"Prd Ind"	; 0x64 Prd Ind
	.asciz	"x"		; 0x65 x
	.asciz	"Pause"		; 0x66 Pause
	.asciz	"x=t"		; 0x67 x=t
	.asciz	"Nop"		; 0x68 Nop
	.asciz	"Op"		; 0x69 Op
	.asciz	"Rel"		; 0x6a Rel
	.asciz	"Inc Ind"	; 0x6b Inc Ind
	.asciz	"Reg Ind"	; 0x6c Reg Ind
	.asciz	"IF Ind"	; 0x6d IF Ind
	.asciz	"AND"		; 0x6e & AND
	.asciz	""		; 0x6f

	.asciz	"Rad"		; 0x70 Rad
	.asciz	"SBR"		; 0x71 SBR
	.asciz	"STO Ind"	; 0x72 STO Ind
	.asciz	"RCL Ind"	; 0x73 RCL Ind
	.asciz	"SUM Ind"	; 0x74 SUM Ind
	.asciz	"-"		; 0x75 -
	.asciz	"Lbl"		; 0x76 Lbl
	.asciz	"x>=t"		; 0x77 x>=t
	.asciz	"Stat+"		; 0x78 Stat+
	.asciz	"Mean"		; 0x79 Avrg x (Mean)
	.asciz	"IF"		; 0x7a If
	.asciz	""		; 0x7b
	.asciz	""		; 0x7c
	.asciz	""		; 0x7d
	.asciz	"XOR"		; 0x7e ~ XOR
	.asciz	""		; 0x7f

	.asciz	"Grad"		; 0x80 Grad
	.asciz	"RST"		; 0x81 RST
	.asciz	"HIR"		; 0x82 HIR
	.asciz	"GTO Ind"	; 0x83 GTO Ind
	.asciz	"Op Ind"	; 0x84 Op Ind
	.asciz	"+"		; 0x85 +
	.asciz	"St flg"	; 0x86 St Flg
	.asciz	"If flg"	; 0x87 If Flg
	.asciz	"D.MS"		; 0x88 D.MS
	.asciz	"pi"		; 0x89 pi
	.asciz	"Reg"		; 0x8a Reg
	.asciz	"HEX"		; 0x8b HEX
	.asciz	"BIN"		; 0x8c BIN
	.asciz	"OCT"		; 0x8d OCT
	.asciz	"OR"		; 0x8e | OR
	.asciz	""		; 0x8f

	.asciz	"List"		; 0x90 List
	.asciz	"R/S"		; 0x91 R/S
	.asciz	"RTN"		; 0x92 RTN
	.asciz	"."		; 0x93 .
	.asciz	"+/-"		; 0x94 +/-
	.asciz	"="		; 0x95 =
	.asciz	"Write"		; 0x96 Write
	.asciz	"Dsz"		; 0x97 Dsz
	.asciz	"Adv"		; 0x98 Adv
	.asciz	"Prt"		; 0x99 Prt
	.asciz	""		; 0x9a
	.asciz	"DEC"		; 0x9b DEC
	.asciz	"Inc"		; 0x9c Inc
	.asciz	"NOT"		; 0x9d NOT
	.asciz	"%"		; 0x9e %
	.asciz	""		; 0x9f
	.balign 2

.global DispNameErr
DispNameErr:
	.asciz	""		; invalid code
	.balign 2

.global DispNameEmpty
DispNameEmpty:
	.asciz	"...empty"	; 0xff
	.balign 2

; ----- key instruction type, to get key code length

.global KeyLen
KeyLen:
	TYPE(1,1)	; #define KEY_0		0x00 // digit 0
			; #define KEY_1		0x01 // digit 1
	TYPE(1,1)	; #define KEY_2		0x02 // digit 2
			; #define KEY_3		0x03 // digit 3
	TYPE(1,1)	; #define KEY_4		0x04 // digit 4
			; #define KEY_5		0x05 // digit 5
	TYPE(1,1)	; #define KEY_6		0x06 // digit 6
			; #define KEY_7		0x07 // digit 7
	TYPE(1,1)	; #define KEY_8		0x08 // digit 8
			; #define KEY_9		0x09 // digit 9
	TYPE(1,1)	; #define KEY_0A	0x0a // digit 0A
			; #define KEY_0B	0x0b // digit 0B
	TYPE(1,1)	; #define KEY_0C	0x0c // digit 0C
			; #define KEY_0D	0x0d // digit 0D
	TYPE(1,1)	; #define KEY_0E	0x0e // digit 0E
			; #define KEY_0F	0x0f // digit 0F
                             
	TYPE(1,1)	; #define KEY_E2	0x10 // label E'
			; #define KEY_A		0x11 // label A
	TYPE(1,1)	; #define KEY_B		0x12 // label B
			; #define KEY_C		0x13 // label C
	TYPE(1,1)	; #define KEY_D		0x14 // label D
			; #define KEY_E		0x15 // label E
	TYPE(1,1)	; #define KEY_A2	0x16 // label A'
			; #define KEY_B2	0x17 // label B'
	TYPE(1,1)	; #define KEY_C2	0x18 // label C'
			; #define KEY_D2	0x19 // label D'
	TYPE(1,1)	; #define KEY_A3	0x1a // label A''
			; #define KEY_B3	0x1b // label B''
	TYPE(1,1)	; #define KEY_C3	0x1c // label C''
			; #define KEY_D3	0x1d // label D''
	TYPE(1,1)	; #define KEY_E3	0x1e // label E''
			; #define KEY_F		0x1f // label F
                             
	TYPE(1,1)	; #define KEY_FRAC	0x20 // a/b (fraction)
			; #define KEY_2ND	0x21 // 2nd
	TYPE(1,1)	; #define KEY_INV	0x22 // INV
			; #define KEY_LNX	0x23 // Ln x
	TYPE(1,1)	; #define KEY_CE	0x24 // CE
			; #define KEY_CLR	0x25 // CLR
	TYPE(2,2)	; #define KEY_SBR_IND	0x26 // SBR Ind
			; #define KEY_HIR_IND	0x27 // HIR Ind
	TYPE(1,1)	; #define KEY_LOG	0x28 // log
			; #define KEY_CP	0x29 // CP
	TYPE(1,1)	; 			0x2a //
			; #define KEY_CODE	0x2b // code
	TYPE(1,1)	; #define KEY_LG2	0x2c // log2
			; #define KEY_RAND	0x2d // rand
	TYPE(1,1)	; 			0x2e //
			;			0x2f // 
                             
	TYPE(1,1)	; #define KEY_TAN	0x30 // tan
			; #define KEY_LRN	0x31 // LRN
	TYPE(1,1)	; #define KEY_XT	0x32 // x<>t
			; #define KEY_X2	0x33 // x^2
	TYPE(1,1)	; #define KEY_SQR	0x34 // Vx
			; #define KEY_1X	0x35 // 1/x
	TYPE(2,1)	; #define KEY_PGM	0x36 // Pgm
			; #define KEY_PR	0x37 // P->R
	TYPE(1,1)	; #define KEY_SIN	0x38 // sin
			; #define KEY_COS	0x39 // cos
	TYPE(1,1)	; #define KEY_TEMP	0x3a // Temp
			; #define KEY_XY	0x3b // x<>y
	TYPE(1,1)	; #define KEY_SINH	0x3c // sinh
			; #define KEY_COSH	0x3d // cosh
	TYPE(1,1)	; #define KEY_TANH	0x3e // tanh
			;			0x3f // 
                             
	TYPE(2,1)	; #define KEY_IND	0x40 // Ind
			; #define KEY_SST	0x41 // SST
	TYPE(2,2)	; #define KEY_STO	0x42 // STO
			; #define KEY_RCL	0x43 // RCL
	TYPE(2,1)	; #define KEY_SUM	0x44 // SUM
			; #define KEY_POW	0x45 // y^x
	TYPE(1,1)	; #define KEY_INS	0x46 // Ins
			; #define KEY_CMS	0x47 // CMs
	TYPE(2,2)	; #define KEY_EXC	0x48 // Exc
			; #define KEY_PRD	0x49 // Prd
	TYPE(1,1)	; #define KEY_BAT	0x4a // Bat
			; #define KEY_FACT	0x4b // n!
	TYPE(1,1)	; #define KEY_LNFACT	0x4c // ln n!
			; #define KEY_LOGFACT	0x4d // log n!
	TYPE(1,1)	; #define KEY_MOD2	0x4e // mod2 (floor)
			;			0x4f // 
                             
	TYPE(1,1)	; #define KEY_ABS	0x50 // |x|
			; #define KEY_BST	0x51 // BST
	TYPE(1,1)	; #define KEY_EE	0x52 // EE
			; #define KEY_LPAR	0x53 // (
	TYPE(1,1)	; #define KEY_RPAR	0x54 // )
			; #define KEY_DIV	0x55 // :
	TYPE(1,1)	; #define KEY_DEL	0x56 // Del
			; #define KEY_ENG	0x57 // Eng
	TYPE(2+TIND,1)	; #define KEY_FIX	0x58 // Fix
			; #define KEY_INT	0x59 // Int
	TYPE(2+TIND,1)	; #define KEY_LCD	0x5a // LCD
			; #define KEY_LEFT	0x5b // <<
	TYPE(1,1)	; #define KEY_RIGHT	0x5c // >>
			; #define KEY_ROUND	0x5d // round
	TYPE(1,1)	; #define KEY_MOD	0x5e // mod (trunc)
			;			0x5f // 
                             
	TYPE(1,2+TADR)	; #define KEY_DEG	0x60 // Deg
			; #define KEY_GTO	0x61 // GTO
	TYPE(2,2)	; #define KEY_PGM_IND	0x62 // Pgm Ind
			; #define KEY_EXC_IND	0x63 // Exc Ind
	TYPE(2,1)	; #define KEY_PRD_IND	0x64 // Prd Ind
			; #define KEY_MUL	0x65 // x
	TYPE(1,2+TADR)	; #define KEY_PAU	0x66 // Pause
			; #define KEY_EQ	0x67 // x=t
	TYPE(1,2)	; #define KEY_NOP	0x68 // Nop
			; #define KEY_OP	0x69 // Op
	TYPE(2,2)	; #define KEY_REL	0x6a // REL
			; #define KEY_INC_IND	0x6b // Inc Ind
	TYPE(3,4+TADR)	; #define KEY_REG_IND	0x6c // Reg Ind
			; #define KEY_IF_IND	0x6d // If Ind
	TYPE(1,1)	; #define KEY_AND	0x6e // AND &
			;			0x6f // 
                             
	TYPE(1,2+TADR)	; #define KEY_RAD	0x70 // Rad
			; #define KEY_SBR	0x71 // SBR
	TYPE(2,2)	; #define KEY_STO_IND	0x72 // STO Ind
			; #define KEY_RCL_IND	0x73 // RCL Ind
	TYPE(2,1)	; #define KEY_SUM_IND	0x74 // SUM Ind
			; #define KEY_SUB	0x75 // -
	TYPE(2,2+TADR)	; #define KEY_LBL	0x76 // Lbl
			; #define KEY_GE	0x77 // x>=t
	TYPE(1,1)	; #define KEY_STA	0x78 // Stat+
			; #define KEY_AVR	0x79 // Avrg x (Mean)
	TYPE(4+TADR,1)	; #define KEY_IF	0x7a // If
			;			0x7b // 
	TYPE(1,1)	; 			0x7c // 
			;			0x7d // 
	TYPE(1,1)	; #define KEY_XOR	0x7e // XOR ~
			;			0x7f // 
                             
	TYPE(1,1)	; #define KEY_GRD	0x80 // Grad
			; #define KEY_RST	0x81 // RST
	TYPE(2,2)	; #define KEY_HIR	0x82 // HIR
			; #define KEY_GTO_IND	0x83 // GTO Ind
	TYPE(2,1)	; #define KEY_OP_IND	0x84 // Op Ind
			; #define KEY_ADD	0x85 // +
	TYPE(2+TIND,3+TIND+TADR) ; #define KEY_STF	0x86 // St Flg
			; #define KEY_IFF	0x87 // If Flg
	TYPE(1,1)	; #define KEY_DMS	0x88 // D.MS
			; #define KEY_PI	0x89 // pi
	TYPE(3,1)	; #define KEY_REG	0x8a // Reg
			; #define KEY_HEX	0x8b // HEX
	TYPE(1,1)	; #define KEY_BIN	0x8c // BIN
			; #define KEY_OCR	0x8d // OCT
	TYPE(1,1)	; #define KEY_OR	0x8e // OR |
			;			0x8f // 
                             
	TYPE(1,1)	; #define KEY_LST	0x90 // List
			; #define KEY_RS	0x91 // R/S
	TYPE(1,1)	; #define KEY_RTN	0x92 // RTN
			; #define KEY_DOT	0x93 // .
	TYPE(1,1)	; #define KEY_NEG	0x94 // +/-
			; #define KEY_RES	0x95 // =
	TYPE(1,3+TIND+TADR) ; #define KEY_WRT	0x96 // Write
			; #define KEY_DSZ	0x97 // Dsz
	TYPE(1,1)	; #define KEY_ADV	0x98 // Adv
			; #define KEY_PRT	0x99 // Prt
	TYPE(1,1)	; #define KEY_PHI	0x9a // phi
			; #define KEY_DEC	0x9b // DEC
	TYPE(2,1)	; #define KEY_INC	0x9c // Inc
			; #define KEY_NOT	0x9d // NOT
	TYPE(1,1)	; #define KEY_PERC	0x9e // %
			;			0x9f // 

	.balign	2

; ----------------------------------------------------------------------------
;        Get program address in ROM module (not for main program)
; ----------------------------------------------------------------------------
; INPUT: R24 = program index (1,...)
; OUTPUT: R31:R30 = program address in ROM
; DESTROYS: R0
; ----------------------------------------------------------------------------

.global GetProgAddr
GetProgAddr:

	ldi	r30,lo8(Module)
	ldi	r31,hi8(Module)

	add	r30,r24
	adc	r31,R_ZERO
	add	r30,r24
	adc	r31,R_ZERO

	lpm	r0,Z+
	lpm	r31,Z
	mov	r30,r0

	subi	r30,lo8(-(Module)) ; program address LOW
	sbci	r31,hi8(-(Module))
	ret

; ----------------------------------------------------------------------------
;      Open program (fatal error if program index is not valid)
; ----------------------------------------------------------------------------
; INPUT: R24 = program index (0=main)
; DESTROYS: R31, R30, R24, R0
; ----------------------------------------------------------------------------

.global OpenProg
OpenProg:

; ----- check program index

	ldd	r30,Y+DATA_PROGNUM	; number of programs in module
	inc	r30
	cp	r24,r30			; check program index
	brcs	2f			; program index is OK
	jmp	Fatal			; fatal error

; ----- set new program index

2:	std	Y+DATA_PROGINX,r24	; current program index
	std	Y+DATA_PROGNEXT,r24	; next program index

; ----- main program

	std	Y+DATA_PROGBEG,R_ZERO	; begin address = 0
	std	Y+DATA_PROGBEG+1,R_ZERO

	ldi	r30,lo8(PROG_NUM)	; end address
	ldi	r31,hi8(PROG_NUM)

	tst	r24			; main program?
	breq	6f			; main program

; ----- get program address
; INPUT: R24 = program index (1,...)
; OUTPUT: R31:R30 = program address in ROM
; DESTROYS: R0
	rcall	GetProgAddr		; address of program begin
	std	Y+DATA_PROGBEG,r30
	std	Y+DATA_PROGBEG+1,r31

; ----- get program end
; INPUT: R24 = program index (1,...)
; OUTPUT: R31:R30 = program address in ROM
; DESTROYS: R0
	inc	r24			; next index
	rcall	GetProgAddr		; address of program end
6:	std	Y+DATA_PROGEND,r30
	std	Y+DATA_PROGEND+1,r31
	ret

; ----------------------------------------------------------------------------
;                   Get display name of program byte
; ----------------------------------------------------------------------------
; INPUT: R24 = code
; OUTPUT: R31:R30 = ASCIIZ text in ROM
; DESTROYS: R25
; ----------------------------------------------------------------------------

.global GetDispName
GetDispName:

; ----- empty

	ldi	r30,lo8(DispNameEmpty)
	ldi	r31,hi8(DispNameEmpty)
	cpi	r24,0xff
	breq	8f

; ----- invalid code

	ldi	r30,lo8(DispNameErr)
	ldi	r31,hi8(DispNameErr)
	cpi	r24,MAXKEY+1
	brcc	8f

; ----- find text

	ldi	r30,lo8(DispName)
	ldi	r31,hi8(DispName)
	tst	r24
	breq	8f

2:	lpm	r25,Z+
	tst	r25
	brne	2b
	dec	r24
	brne	2b

8:	ret

; ----------------------------------------------------------------------------
;                        Load one byte from program
; ----------------------------------------------------------------------------
; INPUT: R27:R26 (X) = address (can be out of range)
; OUTPUT: R24 = byte (0 if invalid)
;	  R27:R26 (X+1) = new address, increased by 1 (not changed on error)
;	  CY = invalid address (R27:R26 not changed)
; DESTROYS: -
; ----------------------------------------------------------------------------

.global LoadByte
LoadByte:

; ----- push registers

	push	r30
	push	r31

; ----- check start of program

	clr	r24		; R24 <- invalid code 0
	ldd	r30,Y+DATA_PROGBEG ; end of program
	ldd	r31,Y+DATA_PROGBEG+1
	cp	r26,r30
	cpc	r27,r31
	brcs	6f		; invalid pointer

; ----- check end of program

	ldd	r30,Y+DATA_PROGEND ; end of program
	ldd	r31,Y+DATA_PROGEND+1
	sbiw	r30,1		; program end - 1
	cp	r30,r26		; check pointer
	cpc	r31,r27		; set CY = invalid pointer
	brcs	6f		; invalid pointer

; ----- check main program

	ldd	r24,Y+DATA_PROGINX	; current program index
	tst	r24			; main program?
	brne	2f			; running program from ROM

; ----- read byte from EEPROM
; INPUT: R27:R26 = source address
; OUTPUT: R24 = data
; DESTROYS: -
	rcall	_EERead
	adiw	r26,1
	rjmp	4f

; ----- read byte from ROM

2:	movw	r30,r26		; Z <- pointer
	lpm	r24,Z+		; load byte
	movw	r26,r30		; X <- new pointer
4:	clc			; NC, operation OK

; ----- pop registers

6:	pop	r31
	pop	r30
	ret

; ----------------------------------------------------------------------------
;  Load one byte from program, increments address (stop program on overflow)
; ----------------------------------------------------------------------------
; OUTPUT: R24 = byte (0 on error)
;	  CY = invalid address (address not changed)
; DESTROYS: -
; ----------------------------------------------------------------------------

.global LoadPrg
LoadPrg:

; ----- push registers

	push	r26
	push	r27

; ----- prepare current address -> X

	ldd	r26,Y+DATA_ADDR
	ldd	r27,Y+DATA_ADDR+1

; ----- load byte
; INPUT: R27:R26 (X) = address (can be out of range)
; OUTPUT: R24 = byte (0 if invalid)
;	  R27:R26 (X+1) = new address, increased by 1 (not changed on error)
;	  CY = invalid address (R27:R26 not changed)
; DESTROYS: -
	rcall	LoadByte
	std	Y+DATA_ADDR,r26
	std	Y+DATA_ADDR+1,r27 ; save new pointer
	brcc	8f		; pointer is OK

	; stop running on end of memory
	CLR_RUNNING		; stop program (do not modify C flag)

; ----- pop registers

8:	pop	r27
	pop	r26
	ret

; ----------------------------------------------------------------------------
;                           Convert BCD to BIN (R24)
; ----------------------------------------------------------------------------
; INPUT: R24 = BCD code
; OUTPUT: R24 = BIN code
;	  R1 = 0
; DESTROYS: R0
; ----------------------------------------------------------------------------

.global Bcd2Bin
Bcd2Bin:
	push	r25

	ldi	r25,10
	mov	r0,r25

	mov	r25,r24		; byte
	swap	r25
	andi	r25,0x0f	; first digit
	mul	r25,r0		; first digit * 10 -> R1:R0

	andi	r24,0x0f	; second digit
	add	r24,r0		; add first digit
	clr	r1		; clear R1

	pop	r25
	ret

; ----------------------------------------------------------------------------
;                           Convert BIN to BCD (R24)
; ----------------------------------------------------------------------------
; INPUT: R24 = BIN code
; OUTPUT: R24 = BCD code
;	  R1 = 0
; DESTROYS: R0
; ----------------------------------------------------------------------------

.global Bin2Bcd
Bin2Bcd:

; ----- push registers

	push	r25
	push	r23

; ----- divide number / 10 -> R24

	mov	r25,r24		; save input number
; INPUT: R24 = dividend (N0)
; OUTPUT: R24 = quotient (Q0), 0..25
;         R1=0
; DESTROYS: R0
	call	DivB10

; ----- multiply number back * 10 and subtract from input number

	ldi	r23,10
	mul	r23,r24
	sub	r25,r0
	clr	r1		; restore R1 (R_ZERO)

; ----- compose numbers

	swap	r24
	or	r24,r25

; ----- pop registers

	pop	r23
	pop	r25
	ret

; ----------------------------------------------------------------------------
;       Load one byte from program, with possible indirect by KEY_IND
; ----------------------------------------------------------------------------
; OUTPUT: R24 = byte
;	  CY = BCD format (from program), NC = BIN format (from indirect memory)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R24, R_M1..R_M10, R0
; ----------------------------------------------------------------------------

.global LoadPrgInd
LoadPrgInd:

; ----- load byte and check indirect
; OUTPUT: R24 = byte (0 on error)
;	  CY = invalid address (address not changed)
; DESTROYS: -
	rcall	LoadPrg		; load byte, increments address
	cpi	r24,KEY_IND	; indirect?
	sec			; set BCD flag
	brne	4f		; not indirect

; ----- load addres of indirect memory and convert it to BIN format
; OUTPUT: R24 = byte (0 on error)
;	  CY = invalid address (address not changed)
; DESTROYS: -
	rcall	LoadPrg		; load next byte
; INPUT: R24 = BCD code
; OUTPUT: R24 = BIN code
;	  R1 = 0
; DESTROYS: R0
	rcall	Bcd2Bin		; convert to bin

; ----- check memory index, fatal on error

LoadPrgInd2:
	cpi	r24,USER_NUM	; check memory index
	brcs	2f		; index is OK
	jmp	Fatal		; error

; ----- load indirected content (ignore sign), memory is in BIN format

2:	subi	r24,-USER_FIRST
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; get memory
; OUTPUT: R24 = unsigned integer
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R25, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackB	; get number
	clc			; BIN flag
4:	ret

; ----------------------------------------------------------------------------
;                       Start InKey and wait for a key
; ----------------------------------------------------------------------------
; OUTPUT: R24 = key
; DESTROYS: -
; ----------------------------------------------------------------------------

StartInKey:
; DESTROYS: -
	rcall	FlagSetInKey	; set input flag
; DESTROYS: -
	rcall	DispFlags
; OUTPUT: R24 = key code
; DESTROYS: -
; NOTE: Enables interrupts
	rjmp	WaitKey

; ----------------------------------------------------------------------------
;                         Stop InKey (saves R24)
; ----------------------------------------------------------------------------
; DESTROYS: -
; ----------------------------------------------------------------------------

StopInKey:
; DESTROYS: -
	rcall	FlagClrInKey	; clear input flag
; DESTROYS: -
	rjmp	DispFlags

; ----------------------------------------------------------------------------
;            Load 1 digit with indirect (from user or from program)
; ----------------------------------------------------------------------------
; OUTPUT: R24 = typically digit 0..15 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
; ----------------------------------------------------------------------------

.global Load1Dig
Load1Dig:

; ----- check if running

	; program is running
	IFN_RUNNING		; if not running
	rjmp	2f		; skip if not running

; ----- running, load byte from program or from indirect memory (result can be > 15)
; OUTPUT: R24 = byte
;	  CY = BCD format (from program), NC = BIN format (from indirect memory)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R24, R_M1..R_M10, R0
	rcall	LoadPrgInd	; load byte with indirect
	clc			; OK (R24 can be 0..0xFF)
	ret

; ----- not running, load key from keyboard
	; start wait mode and wait for a key -> R24
; OUTPUT: R24 = key
; DESTROYS: -
2:	rcall	StartInKey

	; stop wait mode
; DESTROYS: -
	rcall	StopInKey

	; check digit
	cpi	r24,16
	brcs	8f		; key is OK

; ----- indirect, load from memory

Load1Dig2:
	; indirect
	cpi	r24,KEY_IND
	brne	6f		; not indirect, invalid key, break

	; load register indirect
; OUTPUT: R24 = typically 0..159 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
	rcall	Load2Dig2
	brcs	7f		; no key, break input
; OUTPUT: R24 = unsigned integer
;	 NC flag is clear
; DESTROYS: R31, R30, R25, R_M1..R_M10, R0
	rjmp	LoadPrgInd2	; load value or Fatal on invalid memory index

; ----- invalid key, break input, return key to keyboard
; INPUT: R24 = key HEX code
; DESTROYS: -
6:	rcall	ReturnKey	; return key
7:	clr	r24		; returns 0
	sec			; set error flag
	ret

8:	clc			; flag OK
	ret

; ----------------------------------------------------------------------------
;           Load 2 digits (from user with indirect or from program)
; ----------------------------------------------------------------------------
; OUTPUT: R24 = typically 0..159 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
; ----------------------------------------------------------------------------

.global Load2Dig
Load2Dig:

; ----- check if running

	; program is running
	IFN_RUNNING		; if not running
	rjmp	4f		; skip if not running

; ----- running, load byte from program or from indirect memory (result can be > 159)
; OUTPUT: R24 = byte (0 on error)
;	  CY = invalid address (address not changed)
; DESTROYS: -
	rcall	LoadPrg		; load byte (without indirect)
; INPUT: R24 = BCD code
; OUTPUT: R24 = BIN code
;	  R1 = 0
; DESTROYS: R0
	rcall	Bcd2Bin		; convert BCD to BIN
	clc			; OK (R24 can be 0..0xFF)
	ret

; ----- not running, load key from keyboard

Load2Dig2:
	; start wait mode and get first key
; OUTPUT: R24 = key
; DESTROYS: -
4:	rcall	StartInKey

	; check 1st key
	cpi	r24,16
	brcs	2f		; digit is OK

; ----- not valid digit key, stop wait mode and load indirect
; DESTROYS: -
	rcall	StopInKey
; DESTROYS: R31, R30, R27..R24, R_M1..R_M10, R0
	rjmp	Load1Dig2	; indirect, load from memory, or invalid key

; ----- load 2nd key and stop wait mode

2:	push	r24
; OUTPUT: R24 = key code
; DESTROYS: -
; NOTE: Enables interrupts
	rcall	WaitKey
; DESTROYS: -
	rcall	StopInKey
	pop	r25		; 1st key

; ----- invalid 2nd key

	; check 2nd key
	cpi	r24,16
	brcs	2f		; key is OK

; INPUT: R24 = key HEX code
; DESTROYS: -
	rcall	ReturnKey	; return key
	mov	r24,r25		; only one key	
	clc			; flag NC = 1 key is OK
	ret

; ----- compose both key together (as BIN code)

	; add keys
2:	ldi	r30,10
	mul	r30,r25
	add	r24,r0		; add keys
	clr	r1		; restore zero register
	clc			; flag NC = number is OK
	ret

; ----------------------------------------------------------------------------
;     Load 2 HEX digits (from program, 2 digits from user, or as a key)
; ----------------------------------------------------------------------------
; OUTPUT: R24 = byte
; DESTROYS: R25
; ----------------------------------------------------------------------------

.global Load2Hex
Load2Hex:

; ----- if running, load byte from program

	; program is running
	IF_RUNNING		; if running
; OUTPUT: R24 = byte (0 on error)
;	  CY = invalid address (address not changed)
; DESTROYS: -
	rjmp	LoadPrg		; load byte (without indirect)

; ----- start wait mode and get key
; OUTPUT: R24 = key
; DESTROYS: -
	rcall	StartInKey

; ----- if not valid digit, return key

	; check 1st key
	cpi	r24,16		; check valid digit
	brcs	4f		; digit is OK
; DESTROYS: -
	rjmp	StopInKey	; not valid digit, stop wait mode and return key

; ----- wait for 2nd digit and stop wait mode

4:	push	r24
; OUTPUT: R24 = key code
; DESTROYS: -
; NOTE: Enables interrupts
	rcall	WaitKey		; wait for a key
; DESTROYS: -
	rcall	StopInKey	; stop wait mode
	pop	r25		; 1st digit

; ----- if 2nd digit is not valid, return only 1st digit

	; check 2nd key
	cpi	r24,16
	brcs	2f		; valid digit
; INPUT: R24 = key HEX code
; DESTROYS: -
	rcall	ReturnKey	; return key
	mov	r24,r25		; 1st digit
	ret

; ----- compose bith digits

	; add keys
2:	swap	r25
	or	r24,r25
	ret

; ----------------------------------------------------------------------------
;                        Load key length flag
; ----------------------------------------------------------------------------
; INPUT: R24 = key code
; OUTPUT: R24 = key flags (code base length 1..3, flags TIND, TADR)
; DESTROYS: -
; ----------------------------------------------------------------------------

.global LoadKeyLen
LoadKeyLen:

; ----- push registers

	push	r30
	push	r31

; ----- limit invalid code (change to NOP)

	cpi	r24,MAXKEY+1
	brcs	2f
	clr	r24

; ----- load byte

2:	push	r24
	ldi	r30,lo8(KeyLen)
	ldi	r31,hi8(KeyLen)
	lsr	r24		; code / 2
	add	r30,r24
	adc	r31,R_ZERO
	lpm	r24,Z
	pop	r30

; ----- higher key uses high nibble

	sbrc	r30,0		; skip if odd number
	swap	r24		; use high nibble if even number
	andi	r24,0x0f	; mask key flags

; ----- pop registers

	pop	r31
	pop	r30
	ret

; ----------------------------------------------------------------------------
;                     Find label (fatal error if not found)
; ----------------------------------------------------------------------------
; INPUT: R24 = label
; OUTPUT: R27:R26 = absolute address
; DESTROYS: -
; ----------------------------------------------------------------------------

.global FindLab
FindLab:

; ----- push registers

	push	r22
	push	r23
	push	r25
	mov	r25,r24		; required label

; ----- prepare address of program start -> R27:R26 (X)

	ldd	r26,Y+DATA_PROGBEG
	ldd	r27,Y+DATA_PROGBEG+1

; ----- clear INV flag

1:	clr	r22		; R22: flag previous INV

; ----- load next byte
; INPUT: R27:R26 (X) = address (can be out of range)
; OUTPUT: R24 = byte (0 if invalid)
;	  R27:R26 (X+1) = new address, increased by 1 (not changed on error)
;	  CY = invalid address (R27:R26 not changed)
; DESTROYS: -
2:	rcall	LoadByte
	brcs	7f		; end, label not found, fatal error

; ----- INV

	cpi	r24,KEY_INV
	brne	3f
	ldi	r22,1		; INV flag
	rjmp	2b

; ----- INV Fix

3:	cpi	r24,KEY_FIX
	brne	3f
	tst	r22		; previous INV?
	brne	1b		; INV Fix code OK

; ----- check label

3:	cpi	r24,KEY_LBL
	brne	4f		; not label key
; INPUT: R27:R26 (X) = address (can be out of range)
; OUTPUT: R24 = byte (0 if invalid)
;	  R27:R26 (X+1) = new address, increased by 1 (not changed on error)
;	  CY = invalid address (R27:R26 not changed)
; DESTROYS: -
	rcall	LoadByte	; load key code
	brcs	7f		; end, label not found
	cp	r24,r25		; check label
	breq	8f		; label found OK
	rjmp	1b		; load next key code

; ----- HIR xx a

4:	cpi	r24,KEY_HIR
	brne	2f		; not HIR

; INPUT: R27:R26 (X) = address (can be out of range)
; OUTPUT: R24 = byte (0 if invalid)
;	  R27:R26 (X+1) = new address, increased by 1 (not changed on error)
;	  CY = invalid address (R27:R26 not changed)
; DESTROYS: -
	rcall	LoadByte	; load key code
	brcs	7f		; end, label not found
	sbiw	r26,1		; return address
	cpi	r24,0xc0	; code with address?
	ldi	r24,2+TADR	; code with address
	brcc	3f		; use code with address
	ldi	r24,KEY_HIR

; ----- skip instruction
; INPUT: R24 = key code
; OUTPUT: R24 = key flags (code base length 1..3, flags TIND, TADR)
; DESTROYS: -
2:	rcall	LoadKeyLen	; load key len flag
3:	mov	r23,r24

; ----- TIND - indirect (=IND + mem) or memory

	sbrs	r23,TIND_BIT	; indirect?
	rjmp	5f		; skip if not indirect parameter
; INPUT: R27:R26 (X) = address (can be out of range)
; OUTPUT: R24 = byte (0 if invalid)
;	  R27:R26 (X+1) = new address, increased by 1 (not changed on error)
;	  CY = invalid address (R27:R26 not changed)
; DESTROYS: -
	dec	r23
	rcall	LoadByte	; load next byte
	brcs	7f		; end, label not found
	cpi	r24,KEY_IND	; indirect?
	brne	5f		; not indirect
	rcall	LoadByte	; load next byte
	brcs	7f		; end, label not found

; ----- TADR - address (=3 bytes), indirect (=IND + mem) or label (=key)

5:	sbrs	r23,TADR_BIT	; address?
	rjmp	6f
; INPUT: R27:R26 (X) = address (can be out of range)
; OUTPUT: R24 = byte (0 if invalid)
;	  R27:R26 (X+1) = new address, increased by 1 (not changed on error)
;	  CY = invalid address (R27:R26 not changed)
; DESTROYS: -
	dec	r23
	rcall	LoadByte	; load next byte
	brcs	7f		; end, label not found
	cpi	r24,KEY_IND	; indirect?
	breq	4f		; indirect, address is +1
	cpi	r24,16		; digit?
	brcc	6f		; not digit
4:	rcall	LoadByte	; load next byte
	brcs	7f		; end, label not found

; ----- shift address

6:	andi	r23,TYPE_MASK
	add	r26,r23		; add length - 1
	adc	r27,R_ZERO
	rjmp	1b		; next instruction

; ----- fatal error, label not found

7:	jmp	Fatal

; ----- pop registers

8:	pop	r25
	pop	r23
	pop	r22
	ret

; ----------------------------------------------------------------------------
;                  Load address from program or from user
; ----------------------------------------------------------------------------
; OUTPUT: R27:R26 (X) = relative decimal address 0..1665 (should be max. 1599 or 999)
;			or key*256 (if high byte is > 15)
;	  R1 = 0
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
; ----------------------------------------------------------------------------

.global LoadAddr
LoadAddr:

; ----- check if program is running

	IFN_RUNNING		; if not running
	rjmp	LoadAddr5	; not running

; ===== running, input from program

; ----- load 1st byte
; OUTPUT: R24 = byte (0 on error)
;	  CY = invalid address (address not changed)
; DESTROYS: -
	rcall	LoadPrg		; load 1st byte

; ----- check if 1st byte is 1st digit of absolute address

	cpi	r24,16
	brcc	4f		; not digit

	ldi	r26,100
	mul	r24,r26		; multiply 1st digit * 100
	movw	r26,r0		; save 1st digit -> R27:R26
	clr	r1		; restore R1

; ----- load 2nd and 3rd digit
; OUTPUT: R24 = byte (0 on error)
;	  CY = invalid address (address not changed)
; DESTROYS: -
	rcall	LoadPrg		; load 2nd byte

; ----- convert 2 digits from BCD to BIN code
; INPUT: R24 = BCD code
; OUTPUT: R24 = BIN code
;	  R1 = 0
; DESTROYS: R0
	rcall	Bcd2Bin		; convert BCD to BIN code

; ----- compose all 3 digits together

	add	r26,r24		; add 2nd byte
	adc	r27,R_ZERO
	ret

; ----- check indirect

4:	cpi	r24,KEY_IND
	brne	LoadAddr3	; not indirect

; ----- load memory index
; OUTPUT: R24 = byte (0 on error)
;	  CY = invalid address (address not changed)
; DESTROYS: -
	rcall	LoadPrg		; load byte
; INPUT: R24 = BCD code
; OUTPUT: R24 = BIN code
;	  R1 = 0
; DESTROYS: R0
	rcall	Bcd2Bin		; convert to bin

; ----- load indirect memory

LoadAddr2:
	cpi	r24,USER_NUM	; check memory index
	brcs	2f		; index is OK
	jmp	Fatal		; error

2:	subi	r24,-USER_FIRST	; add user offset
; INPUT: R24 = index of the number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
; CALCULATOR STACK: +1
	rcall	_CalcGetMem	; get memory
; OUTPUT: R25:R24 = unsigned integer
;	  R_M3 = negative flag (0 or B7)
;	  C flag is set = overflow valid range
;	  Z flag is set = number is positive or 0 (breq), NZ = number is negative (brne)
; DESTROYS: R31, R30, R_M1..R_M10
; CALCULATOR STACK: -1
	call	CalcUnstackW	; get number
	movw	r26,r24
	ret

; ----- key

LoadAddr3:
	mov	r27,r24		; key code
	clr	r26
	ret	

; ===== not running, input from user

; ----- start wait mode and wait for 1st key

LoadAddr5:
; OUTPUT: R24 = key
; DESTROYS: -
	rcall	StartInKey	; start wait mode

	; input code of label
	cpi	r24,KEY_CODE
	brne	2f
; OUTPUT: R24 = byte
; DESTROYS: R25
	call	Load2Hex	; load 2 HEX digits

	; check 1st key
2:	cpi	r24,16		; digit?
	brcs	4f		; digit is OK

	; not digit (label or indirect), stop wait mode
; DESTROYS: -
	rcall	StopInKey	; stop wait mode

; ----- indirect?

	; indirect
	cpi	r24,KEY_IND
	brne	LoadAddr3	; no indirect, label is valid

; ----- load register index
; OUTPUT: R24 = typically 0..159 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
	rcall	Load2Dig
	rjmp	LoadAddr2	; load address from the register

; ----- wait for 2nd digit
; OUTPUT: R24 = key code
; DESTROYS: -
; NOTE: Enables interrupts
4:	mov	r26,r24		; save 1st digit
	rcall	WaitKey		; wait for a key

; ----- check 2nd digit

	cpi	r24,16
	brcs	6f		; digit is OK

; ----- return key
; DESTROYS: -
	rcall	StopInKey	; stop wait mode
; INPUT: R24 = key HEX code
; DESTROYS: -
5:	rcall	ReturnKey	; return key
	clr	r27		; address is R27:R26 (1 digit 0..15 or 2 digits 0..165)
	ret

; ----- multiply 1st digit * 10 and add 2nd digit

6:	ldi	r27,10
	mul	r27,r26		; multiply 1st digit * 10
	movw	r26,r0		; save 1st digit * 10 -> R27:R26
	clr	r1		; restore R1
	add	r26,r24		; add 2nd digit (result is max. 165, no carry)

; ----- wait for 3rd digit
; OUTPUT: R24 = key code
; DESTROYS: -
; NOTE: Enables interrupts
	rcall	WaitKey

; ----- stop wait mode
; DESTROYS: -
	rcall	StopInKey

; ----- check digit

	cpi	r24,16
	brcc	5b		; invalid digit, return key

; ----- multiply 1st+2nd digit * 10 and add 3rd digit, result is max. 15+15*10+15*100=1665 (0x0681), should be max. 1599

	ldi	r27,10
	mul	r27,r26		; multiply 1st+2nd digit * 10
	movw	r26,r0		; save 1st+2nd digit * 10 -> R27:R26
	clr	r1		; restore R1
	add	r26,r24		; add 3rd digit
	adc	r27,R_ZERO
	ret

; ----------------------------------------------------------------------------
;                       Program number as 3 digits
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = number in decimal form
; DESTROYS:
; ----------------------------------------------------------------------------

.global Prog3Dig
Prog3Dig:

; ----- divide number by 100

	mov	r26,r24		; R26 <- save input number LOW
; INPUT: R25:R24 = dividend (N1:N0)
; OUTPUT: R25:R24 = quotient (Q1:Q0), 0..655
;         R1=0
; DESTROYS: R0
	call	DivW100		; divide word by 100

; ----- multiply number back * 100 and subtract from input number

	ldi	r25,100
	mul	r25,r24
	sub	r26,r0
	clr	r1		; restore R1 (R_ZERO)

; ----- program 1st digit
; INPUT: R24 = key HEX code 0x00..0xFF
; DESTROYS: many

	push	r26
	rcall	ProgKey
	pop	r24

; Prog2Dig must follow

; ----------------------------------------------------------------------------
;                       Program number as 2 digits
; ----------------------------------------------------------------------------
; INPUT: R24 = number
; DESTROYS: many
; ----------------------------------------------------------------------------

.global Prog2Dig
Prog2Dig:

; ----- convert number to BCD code
; INPUT: R24 = BIN code
; OUTPUT: R24 = BCD code
;	  R1 = 0
; DESTROYS: R0
	rcall	Bin2Bcd

; ProgKey must continue

; ----------------------------------------------------------------------------
;               Write key code into program at current address
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
; DESTROYS: R27, R26, R25, R24
; ----------------------------------------------------------------------------

.global ProgKey
ProgKey:

; ----- check if programming mode

	IFN_PROGRAM		; if not programming
2:	ret			; return if not programming mode

; ----- check if main program is active

	ldd	r25,Y+DATA_PROGINX
	tst	r25
	brne	2b		; not main program

; ----- prepare and check address

	ldd	r26,Y+DATA_ADDR	; current address
	ldd	r27,Y+DATA_ADDR+1
	ldi	r25,hi8(PROG_NUM)
	cpi	r26,lo8(PROG_NUM)
	cpc	r27,r25
	brcc	2b		; invalid address

; ----- write key code

	mov	r25,r24
; INPUT: R27:R26 = destination address
;	 R25 = data
; OUTPUT: R24 = old byte
	rcall	_EEWrite

; ----- increase address

	adiw	r26,1
	std	Y+DATA_ADDR,r26
	std	Y+DATA_ADDR+1,r27
8:
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                           LRN (0x31)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
; ----------------------------------------------------------------------------

.global ExecLrn
ExecLrn:
 	IF_RUNNING
	ret			; skip if running

	IF_PROGRAM		; if programming
	rjmp	2f		; programming
	
	SET_PROGRAM		; set programming
	rjmp	4f	
	
2:	CLR_PROGRAM		; clear programming

4:
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                           SST (0x41)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
; ----------------------------------------------------------------------------

.global ExecSst
ExecSst:

; ----- skip if running

 	IF_RUNNING
	ret			; skip if running

; ----- return INV flag if it was set - not if programming

	tst	r23		; test INV flag
	breq	2f
	IFN_PROGRAM		; if not programming
; DESTROYS: -
	rcall	FlagSetInv	; set INV flag back

; ----- read key code and increase address
; OUTPUT: R24 = byte (0 on error)
;	  CY = invalid address (address not changed)
; DESTROYS: -
2:	rcall	LoadPrg

; ----- if not programming, execute code

	IF_PROGRAM		; if programming
	rjmp	9f		; programming

; ----- start running

	push	r24
	call	StartProg	; start program
	pop	r24

; ----- execute code, not programming keys

	call	Exec		; execute code

; ----- stop running

	call	StopProg
9:
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                  Load EEPROM address and limit by the end
; ----------------------------------------------------------------------------
; OUTPUT: R27:R26 = address
; DESTROYS: R25
; ----------------------------------------------------------------------------

.global LimitGetAddr
LimitGetAddr:
	ldd	r26,Y+DATA_ADDR
	ldd	r27,Y+DATA_ADDR+1	

.global LimitAddr
LimitAddr:
	ldi	r25,hi8(PROG_NUM)
	cpi	r26,lo8(PROG_NUM)
	cpc	r27,r25
	brcs	2f

	ldi	r26,lo8(PROG_NUM-1)
	ldi	r27,hi8(PROG_NUM-1)

2:	ret

; ----------------------------------------------------------------------------
;                           Ins (0x46)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
; ----------------------------------------------------------------------------

.global ExecIns
ExecIns:

; ----- skip if running

 	IF_RUNNING
	ret			; skip if running

; ----- skip if not programming

	IFN_PROGRAM		; not programming?
2:	ret			; not programming

; ----- skip if not main program

	ldd	r25,Y+DATA_PROGINX
	tst	r25
	brne	2b		; not main program

; ----- prepare start address
; OUTPUT: R27:R26 = address
; DESTROYS: R25

	rcall	LimitGetAddr	; get address limited

; ----- find start of data (we need this to raise data FF FF...)
; INPUT: R27:R26 = source address
; OUTPUT: R24 = data
; DESTROYS: -
3:	rcall	_EERead		; read byte
	cpi	r24,CLEARKEY	; empty space?
	brne	4f		; start of valid data has been found

	adiw	r26,1		; shift address
	ldi	r24,hi8(PROG_NUM)
	cpi	r26,lo8(PROG_NUM)
	cpc	r27,r24
	brne	3b
	rjmp	2b		; no data, work is done

; ----- write previous byte
; INPUT: R27:R26 = destination address
;	 R25 = data
; OUTPUT: R24 = old byte
4:	ldi	r25,CLEARKEY	; new byte
5:	rcall	_EEWrite	; write byte R25
	mov	r25,r24		; shift old byte to new position

; ----- stop if old byte was empty

	cpi	r24,CLEARKEY
	breq	6f

; ----- shift address

	adiw	r26,1		; shift address
	ldi	r24,hi8(PROG_NUM)
	cpi	r26,lo8(PROG_NUM)
	cpc	r27,r24
	brne	5b

; ----- display new state

6:
; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                           BST (0x51)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
; ----------------------------------------------------------------------------

.global ExecBst
ExecBst:

; ----- skip if running

 	IF_RUNNING
	ret			; skip if running

; ----- skip if not programming

	IFN_PROGRAM		; not programming?
2:	ret			; not programming

; ----- load address

	ldd	r26,Y+DATA_ADDR
	ldd	r27,Y+DATA_ADDR+1

; ----- check start of program

	ldd	r24,Y+DATA_PROGBEG
	cp	r26,r24
	ldd	r24,Y+DATA_PROGBEG+1
	cpc	r27,r24
	breq	2b		; already start of program

; ----- decrease address

	sbiw	r26,1

; ----- save address

	std	Y+DATA_ADDR,r26
	std	Y+DATA_ADDR+1,r27

; ----- display new state

; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                           Del (0x56)
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
;	 R23 = INV flag (1=set)
; ----------------------------------------------------------------------------

.global ExecDel
ExecDel:

; ----- skip if running

 	IF_RUNNING
	ret			; skip if running

; ----- skip if not programming

	IFN_PROGRAM		; not programming?
2:	ret			; not programming

; ----- skip if not main program

	ldd	r25,Y+DATA_PROGINX
	tst	r25
	brne	2b		; not main program

; ----- prepare start address
; OUTPUT: R27:R26 = address
; DESTROYS: R25

	rcall	LimitGetAddr	; get address limited
	movw	r30,r26		; save start address -> R31:R30

; ----- find start of data (we need this to delete data FF FF...)
; INPUT: R27:R26 = source address
; OUTPUT: R24 = data
; DESTROYS: -
3:	rcall	_EERead		; read byte
	cpi	r24,CLEARKEY	; empty space?
	brne	4f		; start of valid data has been found

	adiw	r26,1		; shift address
	ldi	r24,hi8(PROG_NUM)
	cpi	r26,lo8(PROG_NUM)
	cpc	r27,r24
	brne	3b
	rjmp	2b		; no data, work is done

; ----- use last FF as start of data

4:	cp	r26,r30
	cpc	r27,r31
	breq	5f		; already current address
	movw	r30,r26		; set new start of data
	sbiw	r30,1		; use last FF byte

; ----- find end of data
; INPUT: R27:R26 = source address
; OUTPUT: R24 = data
; DESTROYS: -
5:	rcall	_EERead		; read byte
	cpi	r24,CLEARKEY	; empty space?
	breq	6f		; end of valid data has been found

	adiw	r26,1		; shift address
	ldi	r24,hi8(PROG_NUM)
	cpi	r26,lo8(PROG_NUM)
	cpc	r27,r24
	brne	5b
	sbiw	r26,1		; return last valid address

; ----- write previous byte
; INPUT: R27:R26 = destination address
;	 R25 = data
; OUTPUT: R24 = old byte
6:	ldi	r25,CLEARKEY	; new byte
7:	rcall	_EEWrite	; write byte R25
	mov	r25,r24		; shift old byte to new position

; ----- shift address

	sbiw	r26,1		; shift address
	cp	r26,r30
	cpc	r27,r31
	brpl	7b

; ----- display new state

; DESTROYS: R0
	rjmp	Disp		; display all

; ----------------------------------------------------------------------------
;                      Wait for Ind key during programming
; ----------------------------------------------------------------------------
; OUTPUT: R24 = key code
;	  CY = Ind key not pressed
; ----------------------------------------------------------------------------

.global WaitInd
WaitInd:

; OUTPUT: R24 = key code
; DESTROYS: -
; NOTE: Enables interrupts
	rcall	WaitKey		; wait for a key
	cpi	r24,KEY_IND	; Ind key?
	breq	9f		; ok
; INPUT: R24 = key HEX code
; DESTROYS: -
	rcall	ReturnKey	; return key
	sec			; set error flag
WaitInd9:
9:	ret

; ----------------------------------------------------------------------------
;                            Program key code
; ----------------------------------------------------------------------------
; INPUT: R24 = key HEX code 0x00..0xFF
; ----------------------------------------------------------------------------

.global Program
Program:

; ----- read and clear INV flag

	clr	r23		; R23 <- 0, no INV flag
; OUTPUT: NZ = flag is set
; DESTROYS: -
	rcall	FlagTestInv	; test INV flag
	breq	1f		; INV flag not set
; DESTROYS: -
	rcall	FlagClrInv	; clear INV flag
	ldi	r23,1		; INV flag

	; LRN
1:	cpi	r24,KEY_LRN
	brne	2f
	rjmp	ExecLrn

	; SST
2:	cpi	r24,KEY_SST
	brne	3f
	rjmp	ExecSst

	; BST
3:	cpi	r24,KEY_BST
	brne	ProgramMain
	rjmp	ExecBst

; ----- following codes are not allowed if not main program

ProgramMain:
	ldd	r25,Y+DATA_PROGINX
	tst	r25
	brne	WaitInd9	; not main program

	; INV, set flag if was not set
	cpi	r24,KEY_INV
	brne	4f
	tst	r23		; was set?
	brne	3f		; was set
	rcall	FlagSetInv	; set INV flag
; DESTROYS: -
; Do not clear INV flag now, we need it to convert SBR -> RTN
3:	rjmp	ProgProgKey	; write key

	; Ins
4:	cpi	r24,KEY_INS
	brne	5f
	rjmp	ExecIns

	; Del
5:	cpi	r24,KEY_DEL
	brne	6f
	rjmp	ExecDel

	; code
6:	cpi	r24,KEY_CODE
	brne	7f
	rjmp	ExecCode

	; Label
7:	cpi	r24,KEY_LBL
	brne	ProgramFix
	rcall	ProgKey		; write key KEY_LBL
; OUTPUT: R24 = key code
; DESTROYS: -
; NOTE: Enables interrupts
	rcall	WaitKey		; wait key
ProgProgKey:
	rcall	ProgKey		; write label key
; DESTROYS: R0
	rjmp	Disp		; display all

; ----- change INV Fix -> Fix 0F
; ... already not needed, FindLab serves INV Fix OK
ProgramFix:
;	cpi	r24,KEY_FIX
;	brne	ProgramIf
;	tst	r23		; INV was set?
;	breq	ProgramIf	; not set

;	ldd	r26,Y+DATA_ADDR	; load address
;	ldd	r27,Y+DATA_ADDR+1
;	sbiw	r26,1		; decrease address
;	brmi	ProgramIf	; already start of memory

; INPUT: R27:R26 = source address
; OUTPUT: R24 = data
; DESTROYS: -
;	rcall	_EERead		; read EEPROM
;	cpi	r24,KEY_INV	; INV key code?
;	brne	1f

; INPUT: R27:R26 = destination address
;	 R25 = data
; OUTPUT: R24 = old byte
;	ldi	r25,KEY_FIX
;	rcall	_EEWrite	; substitute INV by Fix code

;	ldi	r24,KEY_0F
;	rcall	ProgKey		; write 0x0f key
;	rjmp	Disp

;1:	ldi	r24,KEY_FIX	; restore FIX code

; ----- change INV If -> If Ind

ProgramIf:
8:	cpi	r24,KEY_IF
	brne	ProgramSbr
	tst	r23		; INV was set?
	breq	ProgramSbr	; not set

	ldd	r26,Y+DATA_ADDR	; load address
	ldd	r27,Y+DATA_ADDR+1
	sbiw	r26,1		; decrease address
	brmi	ProgramSbr	; already start of memory

; INPUT: R27:R26 = source address
; OUTPUT: R24 = data
; DESTROYS: -
	rcall	_EERead		; read EEPROM
	cpi	r24,KEY_INV	; INV key code?
	brne	1f

; INPUT: R27:R26 = destination address
;	 R25 = data
; OUTPUT: R24 = old byte
	ldi	r25,KEY_IF_IND
	rcall	_EEWrite	; substitute INV by Fix code

	rcall	Disp

	rjmp	ProgramIfPar	; load parameters

1:	ldi	r24,KEY_IF	; restore IF code

; ----- change INV SBR -> RTN

ProgramSbr:
	cpi	r24,KEY_SBR
	brne	ProgramProg
	tst	r23		; INV was set?
	breq	ProgramProg	; not set

	ldd	r26,Y+DATA_ADDR	; load address
	ldd	r27,Y+DATA_ADDR+1
	sbiw	r26,1		; decrease address
	brmi	ProgramProg	; already start of memory

; INPUT: R27:R26 = source address
; OUTPUT: R24 = data
; DESTROYS: -
	rcall	_EERead		; read EEPROM
	cpi	r24,KEY_INV	; INV key code?
	brne	1f

; INPUT: R27:R26 = destination address
;	 R25 = data
; OUTPUT: R24 = old byte
	ldi	r25,KEY_RTN
	rcall	_EEWrite	; substitute INV by RTN code
; DESTROYS: R0
	rjmp	Disp		; display all

1:	ldi	r24,KEY_SBR	; restore SBR code

; ----- save key code

ProgramProg:
	push	r24
	rcall	ProgKey		; program key code
	pop	r24

; ----- Op, 2 HEX digits parameter

	ldi	r22,KEY_OP_IND
	cpi	r24,KEY_OP	; Op
	brne	3f

	rcall	WaitInd		; wait for Ind
	brcc	ProgramSubst2	; substitute

	rcall	Load2Hex	; load 2 HEX digits
	rcall	ProgKey		; program key code
	rjmp	Disp

; ----- Hir, 2 HEX digits parameter

3:	ldi	r22,KEY_HIR_IND
	cpi	r24,KEY_HIR	; HIR
	brne	ProgramIf2

	rcall	WaitInd		; wait for Ind
ProgramSubst2:
	brcc	ProgramSubst	; substitute

	rcall	Load2Hex	; load 2 HEX digits
	push	r24
	rcall	ProgKey		; program key code
	pop	r24
	cpi	r24,0xc0	; code with address?
	brcs	4f		; no address
	rjmp	ProgramAddr	; program address

4:	rjmp	Disp

; ----- If with 3 parameters

ProgramIf2:
	cpi	r24,KEY_IF
	brne	ProgramReg

ProgramIfPar:
	; 1st parameter
	rcall	Load2Hex	; load 2 HEX digits
	rcall	ProgKey		; program key code
	rcall	Disp

	; 2nd parameter
	rcall	Load2Dig	; load 2 digits from keyboard
	rcall	Prog2Dig	; program 2 digits

	rjmp	ProgramAddr	; write address

; ----- Reg with 2 parameters

ProgramReg:
	cpi	r24,KEY_REG
	brne	ProgramRel

	; 1st parameter
	rcall	Load2Hex	; load 2 HEX digits
	rcall	ProgKey		; program key code
	rcall	Disp

	; 2nd parameter - 2 digits or indirect
	rcall	WaitInd		; wait for Ind
	brcs	Program2Dig	; no Ind, load 2-digit code from keyboard

	; substitute key code
	ldd	r26,Y+DATA_ADDR
	ldd	r27,Y+DATA_ADDR+1
	sbiw	r26,2		; previous address
; INPUT: R27:R26 = destination address
;	 R25 = data
; OUTPUT: R24 = old byte
	ldi	r25,KEY_REG_IND
	rcall	_EEWrite
; DESTROYS: R0
	rcall	Disp		; display all

	rjmp	Program2Dig

; ----- 2 digits parameter

ProgramRel:
	cpi	r24,KEY_REL	; REL
	brne	ProgramInd

Program2Dig:
; OUTPUT: R24 = typically 0..159 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
1:	rcall	Load2Dig	; load 2 digits from keyboard
	rcall	Prog2Dig	; program 2 digits
; DESTROYS: R0
	rjmp	Disp		; display all

; ----- 2 digits with Ind parameter

ProgramInd:
	; check key with 2 digits Ind parameter
	ldi	r22,KEY_PGM_IND
	cpi	r24,KEY_PGM	; Pgm
	breq	3f

	ldi	r22,KEY_STO_IND
	cpi	r24,KEY_STO	; STO
	breq	3f

	ldi	r22,KEY_RCL_IND
	cpi	r24,KEY_RCL	; RCL
	breq	3f

	ldi	r22,KEY_SUM_IND
	cpi	r24,KEY_SUM	; SUM
	breq	3f

	ldi	r22,KEY_EXC_IND
	cpi	r24,KEY_EXC	; Exc
	breq	3f

	ldi	r22,KEY_PRD_IND
	cpi	r24,KEY_PRD	; Prd
	breq	3f

	ldi	r22,KEY_INC_IND
	cpi	r24,KEY_INC	; Inc
	brne	Program3Dig

	; wait for Ind
3:	rcall	WaitInd
	brcs	Program2Dig	; no Ind, load 2-digit code from keyboard

ProgramSubst:
	; substitute key code and get 2 digits
4:	mov	r25,r22		; new key code
	ldd	r26,Y+DATA_ADDR
	ldd	r27,Y+DATA_ADDR+1
	sbiw	r26,1		; previous address
; INPUT: R27:R26 = destination address
;	 R25 = data
; OUTPUT: R24 = old byte
	rcall	_EEWrite
; DESTROYS: R0
	rcall	Disp		; display all
	rjmp	Program2Dig	; load 2-digit code from keyboard

; ----- 3 digits address or label or Ind

Program3Dig:
	; check key with 3 digits address
	ldi	r22,KEY_GTO_IND
	cpi	r24,KEY_GTO	; GTO
	breq	6f

	ldi	r22,KEY_SBR_IND
	cpi	r24,KEY_SBR	; SBR
	brne	Program3DigLab

	; wait for Ind
6:	rcall	WaitInd
	brcc	ProgramSubst	; substitute code and load 2-digit code

ProgramLab:
	; write label
; OUTPUT: R24 = key code
; DESTROYS: -
; NOTE: Enables interrupts
	rcall	WaitKey		; wait for a key
	cpi	r24,16		; digit?
	brcs	2f		; digit
	rjmp	ProgProgKey	; write label

	; load address and program
; INPUT: R24 = key HEX code
; DESTROYS: -
2:	rcall	ReturnKey	; return 1st digit of address
; OUTPUT: R27:R26 (X) = relative decimal address 0..1665 (should be max. 1599 or 999)
;			or key*256 (if high byte is > 15)
;	  R1 = 0
; DESTROYS: R31, R30, R25, R24, R_M1..R_M10, R0
	rcall	LoadAddr	; load address
	movw	r24,r26
	rcall	Prog3Dig	; program 3 digits
; DESTROYS: R0
	rjmp	Disp		; display all

; ----- 3 digits address or label

Program3DigLab:
	cpi	r24,KEY_EQ	; x=t
	breq	2f
	cpi	r24,KEY_GE	; x>=t
	brne	ProgramDsz

ProgramAddr:
	; wait for Ind key
2:	rcall	WaitInd
	brcs	ProgramLab	; not Ind key, load 3-digit address
	rcall	ProgKey		; write key code KEY_IND
	rjmp	Program2Dig	; load 2 digits

; ----- 1 + 3 digits or label

ProgramDsz:
	cpi	r24,KEY_IFF	; If flg
	breq	6f
	cpi	r24,KEY_DSZ	; Dsz
	brne	ProgramStf

6:	rcall	Program1Dig	; program 1 digit or Ind
	rjmp	ProgramAddr	; program address

; ----- 1 digit or Ind

ProgramStf:
	cpi	r24,KEY_STF	; St Flg
	brne	ProgramRet

Program1Dig:
	; wait for Ind
	rcall	WaitInd
	brcs	2f		; not Ind key

	; write Ind and 2 digits
	rcall	ProgKey		; write key code KEY_IND
; OUTPUT: R24 = typically 0..159 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
	rcall	Load2Dig	; load 2 digits from keyboard
	rcall	Prog2Dig	; program 2 digits
; DESTROYS: R0
	rjmp	Disp		; display all

	; write 1 digit
; OUTPUT: R24 = typically digit 0..15 (0 on break), but can be 0..0xFF
;	  C is set on invalid key from keyboard, break input (in such case R24 = 0)
;	  R1 = 0
; DESTROYS: R31, R30, R27..R25, R_M1..R_M10, R0
2:	rcall	Load1Dig	; load 1 digit from program or from user, with indirect
	rcall	ProgKey		; program key
; DESTROYS: R0
	rjmp	Disp		; display all

ProgramRet:
	ret
