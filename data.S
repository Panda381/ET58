; ****************************************************************************
;
;                                Data
;
; ****************************************************************************

#include "include.inc"

	.data

; ===== Y data area (max. 64 bytes)

; Start of data area pointed by Y registers (to reduce program size; max. 64 bytes)
.global DataStart
	.lcomm DataStart,0

; ...general flags
.global Flags			; 0: (u8) DATA_FLAGS general flags F_*
	.lcomm Flags,1
; B0: F_INV INV flag
; B1: F_EE EE mode (not set together with Eng)
; B2: F_ENG Eng mode (not set together with EE)
; B3: F_RESDEC restart DecNum function
; B4: F_DP decimal point entered
; B5: F_EXP entering exponent
; B6: F_INKEY waiting input keys
; B7: F_OLDTRACE old trace state

.global Flags2			; 1: (u8) DATA_FLAGS2 general flags 2 F2_*
	.lcomm Flags2,1
; B0: F2_ERRDEC overflow error in DecNum function
; B1: F2_OLDERR old error flag during DecNum
; B2: F2_DEBUG debug mode, display HEX mantissa
; B3: F2_OLDRUN	old running flag during ExecPr
; B4: F2_DISP_REGT display mode reg T (or flags otherwise)
; B5: F2_DISP_TEXT display mode text (or T/flags otherwise, reset by CLR)

; ...display
.global PosX			; 2: (u8) DATA_POSX display X position
	.lcomm PosX,1

.global LCDVO			; 3: (s8) DATA_LCDVO display contrast correction (VO_MIN .. VO_MAX)
	.lcomm LCDVO,1

; ...keyboard
.global Time			; 4: (u16) DATA_TIME time counter, granularity 10 ms, period 10 minutes
	.lcomm Time,2

.global KeyRaw			; 6: (u8) DATA_KEYRAW current pressed raw key, NOKEY=no key
	.lcomm KeyRaw,1

.global KeyCnt			; 7: (u8) DATA_KEYCNT key press time counter
	.lcomm KeyCnt,1

.global Key			; 8: (u8) DATA_KEY key pressed, NOKEY=no key
	.lcomm Key,1

.global KeySave			; 9: (u8) DATA_KEYSAVE saved key, NOKEY=no key
	.lcomm KeySave,1

.global Flag2nd			; 10: (u8) DATA_FLAG2ND 2nd flag (F_NONE, F_2ND, F_3RD)
	.lcomm Flag2nd,1

; ...calculator
.global Exp			; 11: (s16) DATA_EXP signed exponent (from DecNum function)
	.lcomm Exp,2

.global RandSeed		; 13: (u32) DATA_RANDSEED seed of random generator
	.lcomm RandSeed,4

.global StkEnd			; 17: (u16) DATA_STKEND end of calculator stack
	.lcomm StkEnd,2

.global Level			; 19: (u8) DATA_LEVEL current level of arithmetics operations
	.lcomm Level,1

.global Last			; 20: (u8) DATA_LAST last arithmetics operation (OPER_*)
	.lcomm Last,1

; ...editor
.global EditDig			; 21: (u8) DATA_EDITDIG number of digits of mantissa in edit mode (may be including decimal point and sign, but may be not)
	.lcomm EditDig,1

.global ExpDig			; 22: (u8) DATA_EXPDIG number of digits of exponent in edit mode (including sign)
	.lcomm ExpDig,1

.global	Fix			; 23: (u8) DATA_FIX fix decimals (0..14 digits or FIX_OFF=off)
	.lcomm Fix,1

.global EditMax			; 24: (u8) DATA_EDITMAX size of edit buffer (default EDITBUF_SIZE)
	.lcomm EditMax,1

; ...program

.global Unit			; 25: (u8) DATA_UNIT angle unit UNIT_*
	.lcomm Unit,1

.global UserFlags		; 26: (u16) DATA_USERFLAGS user flags (7=error on Op18/19, 8=stop on error, 9=print log, 15=error)
	.lcomm UserFlags,2

.global Addr			; 28: (u16) DATA_ADDR program address - edit or run, absolute address, can point behind the end
	.lcomm Addr,2

.global Base			; 30: (u8) DATA_BASE numeric radix base BASE_*
	.lcomm Base,1

.global ProgNum			; 31: (u8) DATA_PROGNUM number of programs in library module (0=invalid module)
	.lcomm ProgNum,1

.global ProgInx			; 32: (u8) DATA_PROGINX index of current program (0=main)
	.lcomm ProgInx,1

.global ProgNext		; 33: (u8) DATA_PROGNEXT next program index (0=main)
	.lcomm ProgNext,1

.global ProgBeg			; 34: (u16) DATA_PROGBEG start address of current program
	.lcomm ProgBeg,2

.global ProgEnd			; 36: (u16) DATA_PROGEND end address of current program
	.lcomm ProgEnd,2

.global SaveAddr		; 38: (u16) DATA_SAVEADDR saved address in main program
	.lcomm SaveAddr,2

.global ProgLevel		; 40: (u8) DATA_PROGLEVEL current index in program stack (0=not running)
	.lcomm ProgLevel,1

; ===== buffers

.global EditBuf			; 41: (17) DATA_EDITBUF edit buffer to edit and display number
	.lcomm EditBuf,EDITBUF_SIZE+1

.global SelFont			; (u8) selected font (FONT_*)
	.lcomm SelFont,1

.global SleepLast		; (u16) last activity time (copy of Time)
	.lcomm SleepLast,2

.global SleepMax		; (u16) sleep max time in 0.01 sec (0 = off, min. 5 seconds, max. 650 seconds = almost 11 minutes)
	.lcomm SleepMax,2

.global TempEditBuf		; temporare edit buffer (to save edit buffer and decode register T)
	.lcomm TempEditBuf,EDITBUF_SIZE+1
.global TempFlags		; temporary save Flags
	.lcomm TempFlags,1
.global TempEditDig		; temporary save EditDig
	.lcomm TempEditDig,1
.global TempExpDig		; temporary save ExpDig
	.lcomm TempExpDig,1

.global CpxBeg			; first memory register of stack of complex/fraction numbers
	.lcomm CpxBeg,1
.global CpxNum			; max. number of complex/fraction numbers in the stack
	.lcomm CpxNum,1
.global CpxInx			; current index in the stack of complex/fraction numbers
	.lcomm CpxInx,1
.global CpxTemp			; temporary register of complex/fraction number
	.lcomm CpxTemp,2*NUM_BYTES

.global MemReg			; memory registers
	.lcomm MemReg,MEM_NUM*NUM_BYTES

.global HirReg			; HIR registers
	.lcomm HirReg,HIR_NUM*NUM_BYTES

.global PrintReg		; print registers
	.lcomm PrintReg,PRINT_NUM*NUM_BYTES

.global PrintBuf1		; print buffer - text to display in row 1 while running (default empty)
	.lcomm PrintBuf1,LCD_COLNUM+1

.global PrintBuf2		; print buffer - text to display in row 2 while running (default C)
	.lcomm PrintBuf2,LCD_COLNUM+1

.global PrintBuf3		; print buffer - text to display in row 1 while not running
	.lcomm PrintBuf3,LCD_COLNUM+1

.global CalcStack		; calculator stack
	.lcomm CalcStack,CALC_MAX*NUM_BYTES

.global OperStack		; stack of arithmetics operations (combination of OPER_x, LEVEL_x and LOWER_x)
	.lcomm OperStack,CALC_MAX

.global ProgStackAddr		; stack of return addresses
	.lcomm ProgStackAddr,PROGSTACK_NUM*2

.global ProgStackInx		; stack of program indices
	.lcomm ProgStackInx,PROGSTACK_NUM

.global TimeMark		; (2) time mark - start measure time
	.lcomm TimeMark,2
