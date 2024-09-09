; ****************************************************************************
;
;                                  Includes
;
; ****************************************************************************

#include <avr/io.h>

; ===== CPU class
#if defined atmega8 || defined attiny2313 || defined attiny4313
#define MCU8				// ATmega8, ATTiny2313, ATTiny4313
#elif defined atmega328p || defined atmega328 || defined atmega88
#define MCU88				// ATmega88, ATmega328, ATmega328P
#else
#error Unsupported MCU!
#endif

; ===== Float number definition
; float number structure (10 bytes per number, starting with most significant byte):
;  0: (2) unsigned exponent with bias 0x8000, 0x0000 = number is 0, 0xFFFF = overflow
;           exponent range: +-9863 (binary +-32766), can display max 4 digits
;  2: (8) 8 bytes mantissa (starting with most significant byte)
;           highest bit of the mantissa is sign bit (and hidden "1" bit)
; Mantissa precision: 8 bytes = 64 bits = 19.27 digits
; Can display: max. 14 digits = 46.5 bits = 5.8 bytes
; Reserve: 5.27 digits = 17.5 bits = 2.2 bytes

#define EXP_BYTES	2			// exponent size in number of bytes
#define EXP_BITS	(EXP_BYTES*8)		// exponent size in number of bits (=16)

#define EXP_BIAS	0x8000			// exponent bias (on change check CalcZ1) - exponent of number 1.0
						//  - do not use 0x7ffff, partially hardcoded on some places
#define EXP_MIN		0x0001			// exponent minimal value (-9863)
#define EXP_MAX		0xFFFE			// exponent maximal value (+9863)
#define EXP_OVER	0xFFFF			// exponent overflow (on change check CalcZOver)

#define MANT_BYTES	8			// mantissa size in number of bytes
#define MANT_BITS	(MANT_BYTES*8)		// mantissa size in number of bits (=64)

#define NUM_BYTES	(MANT_BYTES+EXP_BYTES)	// number of bytes of number (=10)
#define NUM_BITS	(MANT_BITS+EXP_BITS)	// number of bits of number (=80)

#define MAXROUND	22			// number of rounding coefficients

; Rounding corrections - we have reserve 17.5 bits
#define TRIM		12			// number of lower bits to trim in case of SUB operation (difference similar numbers)
#define PRECOR		250			// rounding pre-correction

; ===== Buffers
; If moving REG_* elsewhere from index 0, check ExecCms
#define TEMP_5		0			// (-8) index of temporary register 5
#define TEMP_4		1			// (-7) index of temporary register 4 ; used by goniometric, CalcLn, CalcSqrt, CalcPow
#define TEMP_3		2			// (-6) index of temporary register 3 ; used by goniometric, CalcLn, CalcExp, CalcSqrt, CalcPow
#define TEMP_2		3			// (-5) index of temporary register 2 ; used by goniometric, CalcLn, CalcExp, CalcSqrt, CalcPow
#define TEMP_1		4			// (-4) index of temporary register 1 ; used by CalcFloor, goniometric, CalcLn, CalcExp, CalcSqrt, CalcPow, EncNum
#define REG_LAST	5			// (-3) index of register Last
#define REG_T		6			// (-2) index of register T
#define	REG_X		7			// (-1) index of register X

#define REG_NUM		8			// number of system registers
#define USER_FIRST	REG_NUM			// index of first user variable
#define USER_NUM	110			// number of user variables (1000 bytes)
#define MEM_NUM		(REG_NUM+USER_NUM)	// number of total memory variables (108 variables = 1080 bytes)

#define MEM_0		(USER_FIRST+0)		// user memory register 0
#define MEM_1		(USER_FIRST+1)		// user memory register 1
#define MEM_2		(USER_FIRST+2)		// user memory register 2
#define MEM_3		(USER_FIRST+3)		// user memory register 3
#define MEM_4		(USER_FIRST+4)		// user memory register 4
#define MEM_5		(USER_FIRST+5)		// user memory register 5
#define MEM_6		(USER_FIRST+6)		// user memory register 6
#define MEM_7		(USER_FIRST+7)		// user memory register 7
#define MEM_8		(USER_FIRST+8)		// user memory register 8
#define MEM_9		(USER_FIRST+9)		// user memory register 9

#define LEVEL_MAX	15			// max. arithmetics level
#define CALC_TEMP	10			// reserve in calculator stack for temporary registers
#define CALC_MAX	(LEVEL_MAX+1+CALC_TEMP)	// size of calculator stack (=25)

#define HIR_NUM		16			// number of HIR registers

#define PRINT_NUM	4			// number of print registers

#define EDITBUF_SIZE	16			// size of edit buffer (to display and edit number)

#define PROGSTACK_NUM	16			// max. level of program stack

; ===== LCD display

#define LCD_ROWNUM	2			// number of rows of LCD display
#define LCD_COLNUM	16			// number of columns of LCD display
#define ROW1		0			// address of 1st row
#define ROW2		0x40			// address of 2nd row

;#define VO_MIN		0			// minimal VO correction
;#define VO_MID		5			// middle VO correction (default value)
;#define VO_MAX		9			// maximal VO correction

; Normal font:
;  60 (0x5C) \ CHAR_BACKSLASH
;  94 (0x7E) ~ CHAR_WAVE
;  95 (0x7F) pi CHAR_PI
;  96 (0x80) square root CHAR_ROOT
;  97 (0x81) micro CHAR_U
;  98 (0x82) omega CHAR_OMEGA
;  99 (0x83) full box CHAR_FULL
;  100 (0x84) sum CHAR_SUM

; Graphics fonts:
;  60 (0x5C) \ CHAR_BACKSLASH
;  94 (0x7E) ~ CHAR_WAVE
;  95 (0x7F) pi CHAR_PI
;  96 (0x80) square root CHAR_ROOT
;  97 (0x81) micro CHAR_U
;  98 (0x82) omega CHAR_OMEGA
;  99 (0x83) full box CHAR_FULL

; 00 spc	16 0	32 @	48 P	64 '	80 p 	96 square root
; 01 !    17 1    33 A    49 Q    65 a    81 q    97 micro      
; 02 "    18 2    34 B    50 R    66 b    82 r    98 omega      
; 03 #    19 3    35 C    51 S    67 c    83 s    99 full box   
; 04 $    20 4    36 D    52 T    68 d    84 t 
; 05 %    21 5    37 E    53 U    69 e    85 u 
; 06 &    22 6    38 F    54 V    70 f    86 v 
; 07 '    23 7    39 G    55 W    71 g    87 w 
; 08 (    24 8    40 H    56 X    72 h    88 x 
; 09 )    25 9    41 I    57 Y    73 i    89 y 
; 10 *    26 :    42 J    58 Z    74 j    90 z 
; 11 +    27 ;    43 K    59 [    75 k    91 { 
; 12 ,    28 <    44 L    60 \    76 l    92 | 
; 13 -    29 =    45 M    61 ]    77 m    93 } 
; 14 .    30 >    46 N    62 ^    78 n    94 ~ 
; 15 /    31 ?    47 O    63 _    79 o    95 pi

#define CHAR_BACKSLASH	1			// backslash
#define CHAR_WAVE	2			// wave ~
#define CHAR_PI		3			// pi (instead of character 0x7F)
#define CHAR_ROOT	4			// root V
#define CHAR_U		5			// micro
#define CHAR_OMEGA	6			// omega
#define CHAR_FULL	7			// full
#define CHAR_SUM	8			// sum

#define CHAR_NUM	8			// number of custom characters

; selected font
#define FONT_DEF	0			// default font
#define FONT_COLL	1			// columns from left
#define FONT_COLR	2			// columns from right
#define FONT_LINE	3			// lines
#define FONT_PIX	4			// pixel graphics

#define FONT_NUM	5			// number of fonts

; ===== Arithmetics operations

; code of arithmetics operation (4 bits)
#define OPER_NONE	0	// no arithmetics operation

#define OPER_PLUS	1	// +
#define OPER_MINUS	2	// -
#define OPER_AND	3	// &
#define OPER_OR		4	// |
#define OPER_XOR	5	// ~

#define OPER_MUL	6	// *
#define OPER_DIV	7	// :
#define OPER_MOD	8	// backslash (mod trunc)
#define OPER_MOD2	9	// / (mod floor)
#define OPER_PERC	10	// %
#define OPER_LEFT	11	// <
#define OPER_RIGHT	12	// >

#define OPER_POWER	13	// ^
#define OPER_ROOT	14	// root

#define OPER_MASK	0x0f	// mask of code of arithmetics operation

; level of current arithmetics operation (2 bits)
#define LEVEL_NONE	(0<<4)	// no level
#define LEVEL_PLUSMINUS	(1<<4)	// + - & | ~
#define LEVEL_MULDIV	(2<<4)	// * : / backslash % < >
#define LEVEL_POWER	(3<<4)	// ^ root

#define LEVEL_MASK	(3<<4)	// mask of level of arithmetics operation

; level of lower arithmetics operation (2 bits)
#define LOWER_NONE	(0<<6)	// no level
#define LOWER_PLUSMINUS	(1<<6)	// + - & | ~
#define LOWER_MULDIV	(2<<6)	// * : / backslash % < >
#define LOWER_POWER	(3<<6)	// ^ root

#define LOWER_MASK	(3<<6)	// mask of level of arithmetics operation

; ===== Bit constants

#define	B0	0x1
#define	B1	0x2
#define	B2	0x4
#define	B3	0x8
#define	B4	0x10
#define	B5	0x20
#define	B6	0x40
#define	B7	0x80
#define	B8	0x100
#define	B9	0x200
#define	B10	0x400
#define	B11	0x800
#define	B12	0x1000
#define	B13	0x2000
#define	B14	0x4000
#define	B15	0x8000

#define BIT(pos) (1<<(pos))

; ===== Memory

; RAM address and size
#ifdef MCU8
#define RAM_BEG		0x0060	// SRAM begin
#else
#define RAM_BEG		0x0100	// SRAM begin
#endif
#define RAM_END		(RAMEND+1) // SRAM end + 1
#define RAM_SIZE	(RAM_END-RAM_BEG) // SRAM size
#define STACK		RAMEND // end of stack in RAM (= last byte)

; ROM address and  size
#define ROM_BEG		0x0000	// ROM begin
#define ROM_END		(FLASHEND+1) // ROM end + 1
#define ROM_SIZE	(ROM_END-ROM_BEG) // ROM size

; FLASH address and size
#define EEPROM_BEG	0x0000	// EEPROM begin
#define EEPROM_END	(E2END+1) // EEPROM end + 1
#define EEPROM_SIZE	(EEPROM_END-EEPROM_BEG)	// EEPROM size

; ==== EEPROM

#define PROG_NUM	1000	// number of program steps

#define CFG_SEED	(EEPROM_END-4) // (u32) random seed
#define CFG_TEMP	(CFG_SEED-1) // (s8) temperature correction
#define CFG_LCD		(CFG_TEMP-1) // LCD contrast
#define CFG_SLEEPMAX	(CFG_LCD-2) // sleep max time

; ===== key codes

#define KEY_0		0x00 // digit 0
#define KEY_1		0x01 // digit 1
#define KEY_2		0x02 // digit 2
#define KEY_3		0x03 // digit 3
#define KEY_4		0x04 // digit 4
#define KEY_5		0x05 // digit 5
#define KEY_6		0x06 // digit 6
#define KEY_7		0x07 // digit 7
#define KEY_8		0x08 // digit 8
#define KEY_9		0x09 // digit 9
#define KEY_0A		0x0a // digit 0A
#define KEY_0B		0x0b // digit 0B
#define KEY_0C		0x0c // digit 0C
#define KEY_0D		0x0d // digit 0D
#define KEY_0E		0x0e // digit 0E
#define KEY_0F		0x0f // digit 0F
                             
#define KEY_E2		0x10 // label E'
#define KEY_A		0x11 // label A
#define KEY_B		0x12 // label B
#define KEY_C		0x13 // label C
#define KEY_D		0x14 // label D
#define KEY_E		0x15 // label E
#define KEY_A2		0x16 // label A'
#define KEY_B2		0x17 // label B'
#define KEY_C2		0x18 // label C'
#define KEY_D2		0x19 // label D'
#define KEY_A3		0x1a // label A''
#define KEY_B3		0x1b // label B''
#define KEY_C3		0x1c // label C''
#define KEY_D3		0x1d // label D''
#define KEY_E3		0x1e // label E''
#define KEY_F		0x1f // label F
                             
#define KEY_OFF		0x20 // OFF (ON)
#define KEY_2ND		0x21 // 2nd
#define KEY_INV		0x22 // INV
#define KEY_LNX		0x23 // Ln x
#define KEY_CE		0x24 // CE
#define KEY_CLR		0x25 // CLR
#define KEY_SBR_IND	0x26 // SBR Ind
#define KEY_HIR_IND	0x27 // HIR Ind
#define KEY_LOG		0x28 // log
#define KEY_CP		0x29 // CP
;			0x2a //
#define KEY_CODE	0x2b // code
#define KEY_LG2		0x2c // log2
#define KEY_RAND	0x2d // rand
;			0x2e //
;			0x2f // 
                             
#define KEY_TAN		0x30 // tan
#define KEY_LRN		0x31 // LRN
#define KEY_XT		0x32 // x<>t
#define KEY_X2		0x33 // x^2
#define KEY_SQR		0x34 // Vx
#define KEY_1X		0x35 // 1/x
#define KEY_PGM		0x36 // Pgm
#define KEY_PR		0x37 // P->R
#define KEY_SIN		0x38 // sin
#define KEY_COS		0x39 // cos
#define KEY_TEMP	0x3a // Temp
#define KEY_XY		0x3b // x<>y
#define KEY_SINH	0x3c // sinh
#define KEY_COSH	0x3d // cosh
#define KEY_TANH	0x3e // tanh
;			0x3f // 
                             
#define KEY_IND		0x40 // Ind
#define KEY_SST		0x41 // SST
#define KEY_STO		0x42 // STO
#define KEY_RCL		0x43 // RCL
#define KEY_SUM		0x44 // SUM
#define KEY_POW		0x45 // y^x
#define KEY_INS		0x46 // Ins
#define KEY_CMS		0x47 // CMs
#define KEY_EXC		0x48 // Exc
#define KEY_PRD		0x49 // Prd
#define KEY_BAT		0x4a // BAT
#define KEY_FACT	0x4b // n!
#define KEY_LNFACT	0x4c // ln n!
#define KEY_LOGFACT	0x4d // log n!
#define KEY_MOD2	0x4e // mod2 (floor)
;			0x4f // 
                             
#define KEY_ABS		0x50 // |x|
#define KEY_BST		0x51 // BST
#define KEY_EE		0x52 // EE
#define KEY_LPAR	0x53 // (
#define KEY_RPAR	0x54 // )
#define KEY_DIV		0x55 // :
#define KEY_DEL		0x56 // Del
#define KEY_ENG		0x57 // Eng
#define KEY_FIX		0x58 // Fix
#define KEY_INT		0x59 // Int
#define KEY_LCD		0x5a // LCD
#define KEY_LEFT	0x5b // <<
#define KEY_RIGHT	0x5c // >>
#define KEY_ROUND	0x5d // round
#define KEY_MOD		0x5e // mod (trunc)
;			0x5f // 
                             
#define KEY_DEG		0x60 // Deg
#define KEY_GTO		0x61 // GTO
#define KEY_PGM_IND	0x62 // Pgm Ind
#define KEY_EXC_IND	0x63 // Exc Ind
#define KEY_PRD_IND	0x64 // Prd Ind
#define KEY_MUL		0x65 // x
#define KEY_PAU		0x66 // Pause
#define KEY_EQ		0x67 // x=t
#define KEY_NOP		0x68 // Nop
#define KEY_OP		0x69 // Op
#define KEY_REL		0x6a // Rel
#define KEY_INC_IND	0x6b // Inc Ind
#define KEY_REG_IND	0x6c // Reg Ind
#define KEY_IF_IND	0x6d // If Ind
#define KEY_AND		0x6e // AND &
;			0x6f // 
                             
#define KEY_RAD		0x70 // Rad
#define KEY_SBR		0x71 // SBR
#define KEY_STO_IND	0x72 // STO Ind
#define KEY_RCL_IND	0x73 // RCL Ind
#define KEY_SUM_IND	0x74 // SUM Ind
#define KEY_SUB		0x75 // -
#define KEY_LBL		0x76 // Lbl
#define KEY_GE		0x77 // x>=t
#define KEY_STA		0x78 // Stat+
#define KEY_AVR		0x79 // Avrg x (Mean)
#define KEY_IF		0x7a // If
;			0x7b // 
;			0x7c // 
;			0x7d // 
#define KEY_XOR		0x7e // XOR ~
;			0x7f // 
                             
#define KEY_GRD		0x80 // Grad
#define KEY_RST		0x81 // RST
#define KEY_HIR		0x82 // HIR
#define KEY_GTO_IND	0x83 // GTO Ind
#define KEY_OP_IND	0x84 // Op Ind
#define KEY_ADD		0x85 // +
#define KEY_STF		0x86 // St Flg
#define KEY_IFF		0x87 // If Flg
#define KEY_DMS		0x88 // D.MS
#define KEY_PI		0x89 // pi
#define KEY_REG		0x8a // Reg
#define KEY_HEX		0x8b // HEX
#define KEY_BIN		0x8c // BIN
#define KEY_OCR		0x8d // OCT
#define KEY_OR		0x8e // OR |
;			0x8f // 
                             
#define KEY_LST		0x90 // List
#define KEY_RS		0x91 // R/S
#define KEY_RTN		0x92 // RTN
#define KEY_DOT		0x93 // .
#define KEY_NEG		0x94 // +/-
#define KEY_RES		0x95 // =
#define KEY_WRT		0x96 // Write
#define KEY_DSZ		0x97 // Dsz
#define KEY_ADV		0x98 // Adv
#define KEY_PRT		0x99 // Prt
#define KEY_PHI		0x9a // phi
#define KEY_DEC		0x9b // DEC
#define KEY_INC		0x9c // Inc
#define KEY_NOT		0x9d // NOT
#define KEY_PERC	0x9e // %
;			0x9f // 
                             
#define NOKEY		0xff // empty
#define MAXKEY		0x9f // max. valid key

; ===== key type

#define TYPE_MASK	0x03	// length mask, base length 0..3 = 1..4 bytes
#define TIND_BIT	2
#define TIND		BIT(TIND_BIT)	// next byte (offset 1) can be indirect (increase length if =KEY_IND)
#define TADR_BIT	3
#define TADR		BIT(TADR_BIT)	// next or next-next byte can be absolute or indirect (increase lenth)

#define TYPE(a,b)	.byte (a-1) | ((b-1) << 4)

; ===== Offsets in data area Y
; Data area pointed by Y registers (DataStart, size max. 64 bytes)

; ...general flags
#define DATA_FLAGS	0	// (u8) general flags F_*

; General flags in DATA_FLAGS (bit index):
#define F_INV		0	// INV flag
#define F_EE		1	// EE mode (not set together with Eng)
#define F_ENG		2	// Eng mode (not set together with EE)
#define F_RESDEC	3	// restart DecNum function
#define F_DP		4	// decimal point entered
#define F_EXP		5	// entering exponent
#define F_INKEY		6	// waiting input keys
#define F_OLDTRACE	7	// old trace state

#define DATA_FLAGS2	1	// (u8) general flags 2 F2_*

; General flags 2 in DATA_FLAGS2 (bit index):
#define F2_ERRDEC	0	// overflow error in DecNum function
#define F2_OLDERR	1	// old error flag during DecNum and ExecPr
#define F2_DEBUG	2	// debug mode, display HEX mantissa
#define F2_OLDRUN	3	// old running flag during ExecPr
#define F2_DISP_REGT	4	// display mode reg T (or flags otherwise)
#define F2_DISP_TEXT	5	// display mode text (or T/flags otherwise, reset by CLR)

; Display mode (F2_DISPMODE*):
#define DISPMODE_FLAG	0	// flags
#define DISPMODE_T	1	// T reg
#define DISPMODE_TEXT	2	// text in 1st row

; ...display
#define DATA_POSX	2	// (u8) display X position
#define DATA_LCDVO	3	// (s8) display contrast correction (VO_MIN .. VO_MAX)
; ...keyboard
#define DATA_TIME	4	// (u16) time counter, granularity 10 ms, period 10 minutes
#define DATA_KEYRAW	6	// (u8) current pressed raw key, NOKEY=no key
#define DATA_KEYCNT	7	// (u8) key press time counter
#define DATA_KEY	8	// (u8) key pressed, NOKEY=no key
#define DATA_KEYSAVE	9	// (u8) saved key, NOKEY=no key
#define DATA_FLAG2ND	10	// (u8) 2nd flag (F_NONE, F_2ND, F_3RD)
; ...calculator
#define DATA_EXP	11	// (s16) signed exponent (from DecNum function)
#define DATA_RANDSEED	13	// (u32) seed of random generator
#define DATA_STKEND	17	// (u16) end of calculator stack
#define DATA_LEVEL	19	// (u8) current level of arithmetics operations
#define DATA_LAST	20	// (u8) last arithmetics operation (OPER_*)
; ...editor
#define DATA_EDITDIG	21	// (u8) number of digits of mantissa in edit mode (may be including decimal point and sign, but may be not)
#define DATA_EXPDIG	22	// (u8) number of digits of exponent in edit mode (including sign)
#define DATA_FIX	23	// (u8) fix decimals (0..14 digits or FIX_OFF=off)
#define DATA_EDITMAX	24	// (u8) size of edit buffer (default EDITBUF_SIZE)
; ...program
#define DATA_UNIT	25	// (u8) angle unit UNIT_*
#define DATA_USERFLAGS	26	// (u16) user flags (7=error on Op18/19, 8=stop on error)
#define DATA_ADDR	28	// (u16) program address - edit or run, relative to program base
#define DATA_BASE	30	// (u8) numeric radix base BASE_*
#define DATA_PROGNUM	31	// (u8) number of programs in library module (0=invalid module)
#define DATA_PROGINX	32	// (u8) index of current program (0=main)
#define DATA_PROGNEXT	33	// (u8) next program index (0=main)
#define DATA_PROGBEG	34	// (u16) start address of current program
#define DATA_PROGEND	36	// (u16) end address of current program
#define DATA_SAVEADDR	38	// (u16) saved address in main program
#define DATA_PROGLEVEL	40	// (u8) current index in program stack
; ...buffers
#define DATA_EDITBUF	41	// (17) DATA_EDITBUF edit buffer to edit and display number

; ===== Flags in GPIO global register

#define F_EDITON	0	// edit mode is on
#define F_XVALID	1	// register X is valid
#define F_RUNNING	2	// program is running
#define F_PROGRAM	3	// programming mode
#define F_ERROR		4	// soft error
#define F_FATAL		5	// fatal error
#define F_TRACE		6	// trace program GTO
;#define F_STEPPING	7	// program is stepping (set together with running)

; set flag
#define SET_EDITON	sbi _SFR_IO_ADDR(GPIOR0),F_EDITON	// set 'edit mode' flag
#define SET_XVALID	sbi _SFR_IO_ADDR(GPIOR0),F_XVALID	// set 'register X is valid' flag
#define SET_RUNNING	sbi _SFR_IO_ADDR(GPIOR0),F_RUNNING	// set 'running' flag
#define SET_PROGRAM	sbi _SFR_IO_ADDR(GPIOR0),F_PROGRAM	// set 'programming' flag
#define SET_ERROR	sbi _SFR_IO_ADDR(GPIOR0),F_ERROR	// set 'soft error' flag
#define SET_FATAL	sbi _SFR_IO_ADDR(GPIOR0),F_FATAL	// set 'fatal error' flag
#define SET_TRACE	sbi _SFR_IO_ADDR(GPIOR0),F_TRACE	// set 'trace' flag
;#define SET_STEPPING	sbi _SFR_IO_ADDR(GPIOR0),F_STEPPING	// set 'stepping' flag

; clear flag
#define CLR_EDITON	cbi _SFR_IO_ADDR(GPIOR0),F_EDITON	// clear 'edit mode' flag
#define CLR_XVALID	cbi _SFR_IO_ADDR(GPIOR0),F_XVALID	// clear 'register X is valid' flag
#define CLR_RUNNING	cbi _SFR_IO_ADDR(GPIOR0),F_RUNNING	// clear 'running' flag
#define CLR_PROGRAM	cbi _SFR_IO_ADDR(GPIOR0),F_PROGRAM	// clear 'programming' flag
#define CLR_ERROR	cbi _SFR_IO_ADDR(GPIOR0),F_ERROR	// clear 'soft error' flag
#define CLR_FATAL	cbi _SFR_IO_ADDR(GPIOR0),F_FATAL	// clear 'fatal error' flag
#define CLR_TRACE	cbi _SFR_IO_ADDR(GPIOR0),F_TRACE	// clear 'trace' flag
;#define CLR_STEPPING	cbi _SFR_IO_ADDR(GPIOR0),F_STEPPING	// clear 'stepping' flag

; IF = execute following instruction if flag is set (skip if clear)
#define IF_EDITON	sbic _SFR_IO_ADDR(GPIOR0),F_EDITON	// execute if 'edit mode' flag
#define IF_XVALID	sbic _SFR_IO_ADDR(GPIOR0),F_XVALID	// execute if 'register X is valid' flag
#define IF_RUNNING	sbic _SFR_IO_ADDR(GPIOR0),F_RUNNING	// execute if 'running' flag
#define IF_PROGRAM	sbic _SFR_IO_ADDR(GPIOR0),F_PROGRAM	// execute if 'programming' flag
#define IF_ERROR	sbic _SFR_IO_ADDR(GPIOR0),F_ERROR	// execute if 'soft error' flag
#define IF_FATAL	sbic _SFR_IO_ADDR(GPIOR0),F_FATAL	// execute if 'fatal error' flag
#define IF_TRACE	sbic _SFR_IO_ADDR(GPIOR0),F_TRACE	// execute if 'trace' flag
;#define IF_STEPPING	sbic _SFR_IO_ADDR(GPIOR0),F_STEPPING	// execute if 'stepping' flag

; IFN = execute following instruction if flag is not set (skip if is set)
#define IFN_EDITON	sbis _SFR_IO_ADDR(GPIOR0),F_EDITON	// execute if not 'edit mode' flag
#define IFN_XVALID	sbis _SFR_IO_ADDR(GPIOR0),F_XVALID	// execute if not 'register X is valid' flag
#define IFN_RUNNING	sbis _SFR_IO_ADDR(GPIOR0),F_RUNNING	// execute if not 'running' flag
#define IFN_PROGRAM	sbis _SFR_IO_ADDR(GPIOR0),F_PROGRAM	// execute if not 'programming' flag
#define IFN_ERROR	sbis _SFR_IO_ADDR(GPIOR0),F_ERROR	// execute if not 'soft error' flag
#define IFN_FATAL	sbis _SFR_IO_ADDR(GPIOR0),F_FATAL	// execute if not 'fatal error' flag
#define IFN_TRACE	sbis _SFR_IO_ADDR(GPIOR0),F_TRACE	// execute if not 'trace' flag
;#define IFN_STEPPING	sbis _SFR_IO_ADDR(GPIOR0),F_STEPPING	// execute if not 'stepping' flag

; ===== Switches

; 2nd flag
#define F_NONE		0	// no 2nd flag
#define F_2ND		1	// 2nd flag
#define F_3RD		2	// 3rd flag

; angle unit
#define UNIT_DEG	0	// degrees
#define UNIT_RAD	1	// radians
#define UNIT_GRAD	2	// grads

; numeric radix base
#define BASE_DEC	0	// decimal
#define BASE_BIN	1	// binary
#define BASE_OCT	2	// octal
#define BASE_HEX	3	// hexadecimal

#define FIX_OFF		0x0f	// fix decimals are off

#define CLEARKEY	0xff	// code to clear program memory

; ===== Calculator macro literals

; ... control operations (34)
#define C_CT_BASE	0
#define C_NOP		(C_CT_BASE+0)	// no function (required by byte align)
#define C_END		(C_CT_BASE+1)	// end calculator macro
#define C_DEL		(C_CT_BASE+2)	// delete top number
#define C_DUP		(C_CT_BASE+3)	// duplicate
#define C_DUP2		(C_CT_BASE+4)	// duplicate pre2-last number
#define C_DUP3		(C_CT_BASE+5)	// duplicate pre3-last number
#define C_DUP4		(C_CT_BASE+6)	// duplicate pre4-last number
#define C_DUP5		(C_CT_BASE+7)	// duplicate pre5-last number
#define C_DUP6		(C_CT_BASE+8)	// duplicate pre6-last number
#define C_EXC		(C_CT_BASE+9)	// exchange 2 top numbers (top number and pre-top number)
#define C_EXC2		(C_CT_BASE+10)	// exchange 2 pre-top numbers (top number and pre-pre-top number)
#define C_EXC23		(C_CT_BASE+11)	// exchange 2 pre-pre-top numbers (pre-top number and pre-pre-top number)
#define C_EXC3		(C_CT_BASE+12)	// exchange 2 pre-top numbers (top number and pre-pre-pre-top number)
#define C_EXC4		(C_CT_BASE+13)	// exchange 2 pre-top numbers (top number and pre-pre-pre-pre-top number)
#define C_EXC5		(C_CT_BASE+14)	// exchange 2 pre-top numbers (top number and pre-pre-pre-pre-pre-top number)
#define C_JMP		(C_CT_BASE+15)	// relative jump (offset is relative to next byte)
#define C_JUMPT		(C_CT_BASE+16)	// relative jump if true, register<>0 (offset is relative to next byte)
#define C_JUMPF		(C_CT_BASE+17)	// relative jump if false, register=0 (offset is relative to next byte)
#define C_JUMPNZ	(C_CT_BASE+18)	// relative jump if top number is non zero, do not delete it
#define C_JUMPZ		(C_CT_BASE+19)	// relative jump if top number is zero, do not delete it
#define C_JUMPERR	(C_CT_BASE+20)	// jump if error
#define C_JUMPBREAK	(C_CT_BASE+21)	// jump if not running
#define C_ERROR		(C_CT_BASE+22)	// set error flag
#define C_ADDLOOP	(C_CT_BASE+23)	// add serie member to accumulator and loop if meaningful
#define C_PRECOR	(C_CT_BASE+24)	// round pre-correction (add little correction to mantissa)
#define C_CPXGETTOP	(C_CT_BASE+25)	// Get top complex/fraction number into calculator stack (pre-top=real or numerator 'a', top=imaginary or denominator 'b')
#define C_CPXGETPRETOP	(C_CT_BASE+26)	// Get pre-top complex/fraction number into calculator stack (pre-top=real or numerator 'a', top=imaginary or denominator 'b')
#define C_CPXSETTOP	(C_CT_BASE+27)	// Set top complex/fraction number from calculator stack (pre-top=real or numerator 'a', top=imaginary or denominator 'b')
#define C_CPXSETPRETOP	(C_CT_BASE+28)	// Set pre-top complex/fraction number from calculator stack (pre-top=real or numerator 'a', top=imaginary or denominator 'b')
#define C_CPXDEL	(C_CT_BASE+29)	// delete top complex/fraction number
#define C_FRANORM	(C_CT_BASE+30)	// normalize fraction number in calculator stack (pre-top and top)
#define C_BYTE		(C_CT_BASE+31)	// load unsigned byte, will follow
#define C_CONSTLOAD	(C_CT_BASE+32)	// load constant number from ROM, 10 bytes follow
#define C_HIR		(C_CT_BASE+33)	// HIR instruction, follows parameter:
;	low nibble = HIR register 0..15
;	high nible = command, bit 7 = indirect addressing:
#define HIR_STO		0x00		// STO into HIR register, does not delete from stack
#define HIR_RCL		0x10		// RCL from HIR register
#define HIR_STODEL	0x20		// STO into HIR register, delete from stack
; indirect addressing:
#define HIR_STOIND	(HIR_STO+0x80)	// STO into mem register with HIR index, does not delete
#define HIR_RCLIND	(HIR_RCL+0x80)	// RCL from mem register with HIR index
#define HIR_STOINDDEL	(HIR_STODEL+0x80) // STO into mem register with HIR index, delete from stack

; ... arithmetics and bitwise operations (2 operands) (15)
#define C_AR_BASE	(C_CT_BASE+34)
#define C_MUL		(C_AR_BASE+0)	// multiply
#define C_DIV		(C_AR_BASE+1)	// division
#define C_MUL2		(C_AR_BASE+2)	// multiply*2
#define C_DIV2		(C_AR_BASE+3)	// division/2
#define C_MOD		(C_AR_BASE+4)	// modulus with trunc rounding
#define C_MOD2		(C_AR_BASE+5)	// modulus with floor rounding
#define C_SUB		(C_AR_BASE+6)	// - subtract
#define C_ADD		(C_AR_BASE+7)	// +
#define C_POW		(C_AR_BASE+8)	// ^ power (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
#define C_BITAND	(C_AR_BASE+9)	// bitwise AND
#define C_BITOR		(C_AR_BASE+10)	// bitwise OR
#define C_BITXOR	(C_AR_BASE+11)	// bitwise XOR
#define C_LEFT		(C_AR_BASE+12)	// < shift left
#define C_RIGHT		(C_AR_BASE+13)	// > shift right
#define C_GCD		(C_AR_BASE+14)	// find greatest common divisor (GCD) of two integer numbers

; ... comparisons: do not change order of comparison codes - hardcoded in function CalcCmp (10)
#define C_CP_BASE	(C_AR_BASE+15)
#define C_LTEQ		(C_CP_BASE+0)	// <=
#define C_GREQ		(C_CP_BASE+1)	// >=
#define C_NEQU		(C_CP_BASE+2)	// <>
#define C_LT0		(C_CP_BASE+3)	// < 0 (less 0, but not equ)
#define C_GR		(C_CP_BASE+4)	// >
#define C_LT		(C_CP_BASE+5)	// <
#define C_EQU		(C_CP_BASE+6)	// =
#define C_GR0		(C_CP_BASE+7)	// > 0 (greater 0, but not equ)
#define C_LTEQ0		(C_CP_BASE+8)	// <= 0 (less or equ 0)
#define C_GREQ0		(C_CP_BASE+9)	// >= 0 (greater or equ 0)

; ... logic bool operations (3)
#define C_BL_BASE	(C_CP_BASE+10)
#define C_NOT		(C_BL_BASE+0)	// NOT
#define C_OR		(C_BL_BASE+1)	// OR
#define C_AND		(C_BL_BASE+2)	// AND

; ... functions 1 (misc) (19)
#define C_F1_BASE	(C_BL_BASE+3)
#define C_REC		(C_F1_BASE+0)	// reciprocal value
#define C_INC		(C_F1_BASE+1)	// increment +1
#define C_DEC		(C_F1_BASE+2)	// decrement -1
#define C_NEG		(C_F1_BASE+3)	// unary- (NEG)
#define C_SGN		(C_F1_BASE+4)	// SGN
#define C_ABS		(C_F1_BASE+5)	// ABS
#define C_TRUNCPREC	(C_F1_BASE+6)	// precise truncate (round towards zero)
#define C_TRUNC		(C_F1_BASE+7)	// truncate (round towards zero)
#define C_FLOOR		(C_F1_BASE+8)	// round down
#define C_CEIL		(C_F1_BASE+9)	// round up
#define C_ROUND		(C_F1_BASE+10)	// round nearest
#define C_ROUNDFRAC	(C_F1_BASE+11)	// round nearest fraction -0.5..+0.5
#define C_MAX		(C_F1_BASE+12)	// load max number
#define C_OVER		(C_F1_BASE+13)	// load overflow number
#define C_RAND		(C_F1_BASE+14)	// random number (0 inc. .. 1 exc.)
#define C_USER		(C_F1_BASE+15)	// call user function A' (X -> X, delete stack)
#define C_SND		(C_F1_BASE+16)	// standard normal distribution Z(x) (C_SND)
#define C_CGD		(C_F1_BASE+17)	// complementary Gaussian distribution Q(x) (C_CGD)
#define C_CND		(C_F1_BASE+18)	// cumulative normal distribution P(x) (C_CND)

; ... funcions 2 (angle) (12)
#define C_F2_BASE	(C_F1_BASE+19)
#define C_ARG		(C_F2_BASE+0)	// normalize angle argument
#define C_SIN		(C_F2_BASE+1)	// SIN (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
#define C_COS		(C_F2_BASE+2)	// COS (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
#define C_TAN		(C_F2_BASE+3)	// TAN (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
#define C_COTAN		(C_F2_BASE+4)	// COTAN (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
#define C_ASN		(C_F2_BASE+5)	// ASN (uses TEMP_1, TEMP_2, TEMP_3)
#define C_ACS		(C_F2_BASE+6)	// ACS (uses TEMP_1, TEMP_2, TEMP_3)
#define C_ATN		(C_F2_BASE+7)	// ATN (uses TEMP_1, TEMP_2, TEMP_3)
#define C_TORAD		(C_F2_BASE+8)	// TORAD - angle to radians
#define C_FROMRAD	(C_F2_BASE+9)	// FROMRAD - angle from radians
#define C_PR		(C_F2_BASE+10)	// Convert polar to cartesian (r,a in radians) -> (x,y)
#define C_RP		(C_F2_BASE+11)	// Convert cartesian to polar (x,y) -> (r,a in radians)

; ... functions 3 (logarithm) (8)
#define C_F3_BASE	(C_F2_BASE+12)
#define C_LN		(C_F3_BASE+0)	// LN (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
#define C_EXP		(C_F3_BASE+1)	// EXP (uses TEMP_1, TEMP_2, TEMP_3)
#define C_LOG10		(C_F3_BASE+2)	// LOG10 (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
#define C_EXP10		(C_F3_BASE+3)	// EXP10 (uses TEMP_1, TEMP_2, TEMP_3)
#define C_LOG2		(C_F3_BASE+4)	// LOG2 (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
#define C_EXP2		(C_F3_BASE+5)	// EXP2 (uses TEMP_1, TEMP_2, TEMP_3)
#define C_SQRT		(C_F3_BASE+6)	// SQRT (uses TEMP_1, TEMP_2, TEMP_3, TEMP_4)
#define C_SQR		(C_F3_BASE+7)	// square

; ... groups (compound literals) (4)
;	bit 7: flag of compound literal
;	bit 5..6: group 0..3
;	bit 0..4: parameter 0..31
#define C_GROUP_BASE	(C_F3_BASE+8)
#define C_CONST_GRP	(C_GROUP_BASE+0)	// stack tabled constant (parameter is index of the constant)
#define C_SETMEM_GRP	(C_GROUP_BASE+1)	// set memory from stack (parameter is index of the number)
#define C_GETMEM_GRP	(C_GROUP_BASE+2)	// get number from memory into stack (parameter is index of the number)
#define C_SETMEMDEL_GRP	(C_GROUP_BASE+3)	// set memory from stack and delete (parameter is index of the number)

#define C_CHECK		(C_GROUP_BASE+4)	// check - number of entries (must be < 128) ... 76

#define C_CONST(par) (B7+((C_CONST_GRP-C_GROUP_BASE)<<5)+par)  // stack tabled constant (par=index of constant 0..31)
#define C_SETMEM(par) (B7+((C_SETMEM_GRP-C_GROUP_BASE)<<5)+par)  // set memory from stack (par=index of number 0..31)
#define C_GETMEM(par) (B7+((C_GETMEM_GRP-C_GROUP_BASE)<<5)+par)  // get number from memory into stack (par=index of number 0..31)
#define C_SETMEMDEL(par) (B7+((C_SETMEMDEL_GRP-C_GROUP_BASE)<<5)+par)  // set memory from stack and delete (par=index of number 0..31)

; Indices of constants (max. 32 constants)
#define CONST_0		0	// 0
#define CONST_1		1	// 1
#define CONST_M1	2	// -1
#define CONST_2		3	// 2
#define CONST_05	4	// 0.5
#define CONST_075	5	// 0.75
#define CONST_10	6	// 10
#define CONST_01	7	// 0.1
#define CONST_100	8	// 100
#define CONST_001	9	// 0.01
#define CONST_00001	10	// 0.0001
#define CONST_0000000001 11	// 0.00000001
#define CONST_LN2	12	// ln(2)
#define CONST_RLN2	13	// 1/ln(2)
#define CONST_LN10	14	// ln(10)
#define CONST_RLN10	15	// 1/ln(10)
#define CONST_LOG2	16	// log(2)
#define CONST_RLOG2	17	// 1/log(2)
#define CONST_EXPMAX	18	// exp(x) max
#define CONST_EXPMIN	19	// exp(x) min
#define CONST_EUL	20	// Eul
#define CONST_PI05	21	// PI/2
#define CONST_PI	22	// PI
#define CONST_PI2	23	// PI*2
#define CONST_RPI2	24	// 1/(2*PI)
#define CONST_LNPI22	25	// ln(PI*2)/2
#define CONST_180PI	26	// 180/PI
#define CONST_PI180	27	// PI/180
#define CONST_200PI	28	// 200/PI
#define CONST_PI200	29	// PI/200
#define CONST_PHI	30	// phi (sectio aurea)
#define CONST_99999	31	// 999.99

; ===== Registers
; Y = reserved as pointer to data area
; R0 = temporary, result of multiplication, destroyed
#define R_ZERO	R1	// zero register ... need to restore after multiplications
#define R_LITL	R2	// literal pointer LOW (must be LOW to R_LITH)
#define R_LITH	R3	// literal pointer HIGH (must be HIGH to R_LITL)

#define R_EXH	r27	// result exponent HIGH (=XH), must be HIGH to R_EXL
#define R_EXL	r26	// result exponent LOW (=XL), must be LOW to R_EXH

#define R_MS	R25	// temporary sign in function CalcMul, CalcDiv and CalcPrepMul, temporary loop counter in CalcMul
#define R_MT	R24	// temporary register in functions CalcPrepMul

; temporary result
#define R_R3	R31	// must be HIGH to R_R4
#define R_R4	R30	// must be LOW to R_R3
#define R_R5	R29	// must be HIGH to R_R6
#define R_R6	R28	// must be LOW to R_R5
#define R_R7	R27	// must be HIGH to R_R8
#define R_R8	R26	// must be LOW to R_R7
#define R_R9	R25	// must be HIGH to R_R10
#define R_R10	R24	// must be LOW to R_R9

; accumulator and temporary register in function MulMant (uses R_M3..R_M10, R_N3..R_N10)
#define R_A3	R31
#define R_A4	R30
#define R_A5	R29
#define R_A6	R28
#define R_A7	R27
#define R_A8	R26
#define R_A9	R25
#define R_A10	R24

#define R_T3	R23
#define R_T4	R22
#define R_T5	R13
#define R_T6	R12
#define R_T7	R3
#define R_T8	R2

; 1st number - pointed by Z
#define R_M1	R23	// exponent HIGH, must be HIGH to R_M2, 0=number is zero
#define R_M2	R22	// exponent LOW, must be LOW to R_M1
#define R_M3	R21	// mantissa HIGH + sign bit (or hidden bit), must be HIGH to R_M4
#define R_M4	R20	// must be LOW to R_M3
#define R_M5	R19	// must be HIGH to R_M6
#define R_M6	R18	// must be LOW to R_M5
#define R_M7	R17	// must be HIGH to R_M8
#define R_M8	R16	// mantissa LOW, must be LOW to R_M7
#define R_M9	R15	// must be HIGH to R_M10
#define R_M10	R14	// must be LOW to R_M9

#define R_M11	R_N1	// extra low result byte

; 2nd number - pointed by X, will be deleted from the stack
#define R_N1	R13	// exponent HIGH
#define R_N2	R12	// exponent LOW
#define R_N3	R11	// mantissa HIGH + sign bit (or hidden bit)
#define R_N4	R10
#define R_N5	R9
#define R_N6	R8
#define R_N7	R7
#define R_N8	R6
#define R_N9	R5
#define R_N10	R4	// mantissa LOW
