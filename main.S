; ****************************************************************************
;
;                                 Main
;
; ****************************************************************************

#include "include.inc"

	.text

CrcErr:
	.asciz	"CRC Error"
	.balign 2

LogoText:
	.asciz	"www.pajenicko.cz"
	.balign 2

; Uncomment this to check and display number of entries of CALC macro (displays number of C_* functions in DEC)
; - this number must be < 128

;#define CHECK_CALC

#ifdef CHECK_CALC
CheckCalcT1:
	.asciz	"ERR CalcJmpTab"
	.balign 2

CheckCalcT2:
	.asciz	"CALC: "
	.balign 2
#endif

; ----------------------------------------------------------------------------
;                   Display calculator version
; ----------------------------------------------------------------------------

.global DispBuild
DispBuild:

	; display build
	call	DispSetRow1
	ldi	r30,lo8(Build)
	ldi	r31,hi8(Build)
	call	DispTextRom	; display error text
	call	DispSpcClr	; clear rest of the row

	; display logo
	call	DispSetRow2
	ldi	r30,lo8(LogoText)
	ldi	r31,hi8(LogoText)
	call	DispTextRom	; display error text
	call	DispSpcClr	; clear rest of the row

	call	Wait1s		; wait some time (1 second)

;	jmp	DispFlags	; clear 1st row (use if not display logo)
	jmp	Disp		; clear display

; ----------------------------------------------------------------------------
;                   Calculate CRC of 1 byte (CCITT or XModem)
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = CRC accumulator
;	 R22 = input byte
; OUTPUT: R25:R24 = result CRC
; DESTROYS: R23
; ----------------------------------------------------------------------------

.global Crc1
Crc1:
; u16 Crc_CCITT_1(u16 crc, u8 data)
;{
;	crc = (crc >> 8) | (crc << 8);
	mov	r23,r25		; swap registers
	mov	r25,r24
	mov	r24,r23

;	crc ^= data;
	eor	r24,r22		; XOR with data byte

;	crc ^= (crc & 0xf0) >> 4;
	mov	r23,r24
	swap	r23
	andi	r23,0x0f
	eor	r24,r23		; XOR with bits 4..7

;	crc ^= crc << 12;
	mov	r23,r24
	swap	r23
	andi	r23,0xf0
	eor	r25,r23		; XOR with bits 0..3

;	crc ^= (crc & 0xff) << 5;
	mov	r23,r24
	lsr	r23
	lsr	r23
	lsr	r23
	eor	r25,r23		; XOR with bits 0..4

	mov	r23,r24
	swap	r23
	lsl	r23
	andi	r23,0xe0
	eor	r24,r23		; XOR with bits 5..7
	ret

; ----------------------------------------------------------------------------
;                   Calculate CRC of the ROM (XModem)
; ----------------------------------------------------------------------------
; OUTPUT: R25:R24 = result CRC
; DESTROYS: R31, R30, R23, R22
; ----------------------------------------------------------------------------
;#define CRCXMODEM_INIT 0
;u16 Crc_XModem(const u8* buf, int len)
;{
;	u16 crc = CRCXMODEM_INIT;
;	for (; len > 0; len--)
;	{
;		crc = Crc1(crc, *buf++);
;	}
;	return crc;
;}

.global GetCrc
GetCrc:
	clr	r31		; start address 0
	clr	r30
	clr	r25		; initialize CRC accumulator to 0
	clr	r24

2:	lpm	r22,Z+		; load one data byte
	rcall	Crc1		; add byte to CRC accumulator
	cpi	r31,hi8(Crc)	; check end address
	brne	2b
	cpi	r30,lo8(Crc)
	brne	2b
	ret

; ----------------------------------------------------------------------------
;                       Update sleep activity time
; ----------------------------------------------------------------------------

.global SleepUpdate
SleepUpdate:
	push	r24
	ldd	r24,Y+DATA_TIME  ; time LOW
	sts	SleepLast,r24	; update activity time LOW
	ldd	r24,Y+DATA_TIME+1  ; time HIGH
	sts	SleepLast+1,r24	; update activity time HIGH
	pop	r24
	ret

; ----------------------------------------------------------------------------
;                        Port inizialize
; ----------------------------------------------------------------------------

.global PortInit
PortInit:

; ----- initialize port B, reset LCD display
; PB0: ROW4 input pull-up
; PB1: ROW6 input pull-up
; PB2: COL2 input
; PB3: ROW8 input pull-up
; PB4: ROW1 input pull-up
; PB5: COL3 input
; PB6: RS output LOW
; PB7: LCD output HIGH

	ldi	r24,B0+B1+B3+B4+B7
	out	_SFR_IO_ADDR(PORTB),r24	; set pull-ups and outputs
	ldi	r24,B6
	out	_SFR_IO_ADDR(DDRB),r24	; set outputs, LCD is OFF
	rcall	Wait10ms		; wait 10 ms
	ldi	r24,B6+B7
	out	_SFR_IO_ADDR(DDRB),r24	; set outputs, LCD is ON

; ----- initialize port C
; PC0: ROW9 input pull-up
; PC1: COL4 input
; PC2: ROW7 input pull-up
; PC3: COL5 input
; PC4: ROW5 input pull-up
; PC5: ROW3 input pull-up

	ldi	r24,B0+B2+B4+B5
	out	_SFR_IO_ADDR(PORTC),r24	; set pull-ups and outputs
	out	_SFR_IO_ADDR(DDRC),R_ZERO ; all pins are inputs

; ----- initialize port D
; PD0: DB7 output LOW
; PD1: DB6 output LOW
; PD2: DB5 output LOW
; PD3: DB4 output LOW
; PD4: E output LOW
; PD5: COL1 input
; PD6: VO2 output LOW (OC0A)
; PD7: ROW2 input pull-up

	ldi	r24,B7
	out	_SFR_IO_ADDR(PORTD),r24	; set pull-ups and outputs
	ldi	r24,B0+B1+B2+B3+B4+B6
	out	_SFR_IO_ADDR(DDRD),r24	; set outputs
	ret

; ----------------------------------------------------------------------------
;                          Fatal error (hard error 'F')
; ----------------------------------------------------------------------------

.global Fatal
Fatal:

	cli			; disable interrupts

	call	CalcInit	; inicialize calculator stack
	call	StopProg	; stop program

	ldi	r24,lo8(STACK)	; end of stack (= last byte of RAM)
	ldi	r25,hi8(STACK)
	out	_SFR_IO_ADDR(SPH),r25
	out	_SFR_IO_ADDR(SPL),r24

	SET_FATAL		; set fatal flag

	rjmp	Restart

; ----------------------------------------------------------------------------
;                    System reset, start main function
; ----------------------------------------------------------------------------

; Reset
.global main
main:

; ----- initialize global registers

	eor	R_ZERO,R_ZERO	; register 0
	ldi	YL,lo8(DataStart) ; data area LOW
	ldi	YH,hi8(DataStart) ; data area HIGH

; ----- initialize status register

	out	_SFR_IO_ADDR(SREG),R_ZERO

; ----- clear whole RAM memory (initialize to 0)

	ldi	r30,lo8(RAM_BEG)
	ldi	r31,hi8(RAM_BEG)
	ldi	r25,hi8(RAM_END)
1:	st	Z+,R_ZERO
	cpi	r30,lo8(RAM_END)
	cpc	r31,r25
	brne	1b

; ----- initialize stack

	ldi	r24,lo8(STACK)	; end of stack (= last byte of RAM)
	ldi	r25,hi8(STACK)
	out	_SFR_IO_ADDR(SPH),r25
	out	_SFR_IO_ADDR(SPL),r24

; ----- initialize ports

	rcall	PortInit

; ----- disable unused units (TWI0, TIMER2, SPI, USART), enable Timer0 and Timer1

	ldi	r24,BIT(PRTWI)+BIT(PRTIM2)+BIT(PRSPI)+BIT(PRUSART0)+BIT(PRADC)
	sts	PRR,r24

; ----- switch off unused ADC channels

	ldi	r24,0xff
	sts	DIDR0,r24

; ----- some wait
; Better to increase clock later to avoid processor lock at low voltage

	ldi	r24,250/4		; 250 ms ... we run on 1 MHz now, not 4 MHz, so delay/4
	rcall	Waitms

; ----- system clock starts with 1 MHz (CKDIV8 is programmed), set system clock to 4 MHz

	ldi	r24,BIT(CLKPCE)

#if F_CPU >= 6000000

	ldi	r25,0				; divide 8MHz /1

#else

	ldi	r25,1				; divide 8MHz /2

#endif

	sts	CLKPR,r24		; enable
	sts	CLKPR,r25

; ----- some wait

;	rcall	Wait250ms

; ----- default LCD contrast

	ldi	r26,lo8(CFG_LCD)
	ldi	r27,hi8(CFG_LCD)
; INPUT: R27:R26 = source address
; OUTPUT: R24 = data
; DESTROYS: -
	call	_EERead		; read LCD contrast
	cpi	r24,10		; check max. value
	brcs	2f
	ldi	r24,4		; default value
2:	std	Y+DATA_LCDVO,r24

; ----- default sleep max

	ldi	r26,lo8(CFG_SLEEPMAX+1)
	ldi	r27,hi8(CFG_SLEEPMAX+1)
; INPUT: R27:R26 = source address
; OUTPUT: R24 = data
; DESTROYS: -
	call	_EERead		; read sleep max HIGH
	mov	r25,r24
	sbiw	r26,1	
	call	_EERead		; read sleep max LOW
	cpi	r25,0xff	; invalid value?
	brne	2f		; time is ok
	ldi	r24,lo8(30*100)	; default 30 seconds
  	ldi	r25,hi8(30*100)
2:	sts	SleepMax,r24
	sts	SleepMax+1,r25

; ----- read seed of random generator
; INPUT: R27:R26 = source address
; OUTPUT: R24 = data
; DESTROYS: -
	ldi	r26,lo8(CFG_SEED)
	ldi	r27,hi8(CFG_SEED)
	rcall	EERead
	std	Y+DATA_RANDSEED+0,r24

	adiw	r26,1
	rcall	EERead
	std	Y+DATA_RANDSEED+1,r24

	adiw	r26,1
	rcall	EERead
	std	Y+DATA_RANDSEED+2,r24

	adiw	r26,1
	rcall	EERead
	std	Y+DATA_RANDSEED+3,r24

; ----- shift random renerator
; OUTPUT: R25:R24:R23:R22 = new seed
;         R1 = 0
; DESTROYS: R31, R30, R27, R26, R21..R18, R0
; RandSeed = RandSeed * 214013 + 2531011
	call	RandShift

; ----- save new seed of random generator (in reverse order to not repeat similar sequence)
; INPUT: R27:R26 = destination address
;	 R25 = data
; OUTPUT: R24 = old byte
	ldi	r26,lo8(CFG_SEED)
	ldi	r27,hi8(CFG_SEED)
	ldd	r25,Y+DATA_RANDSEED+3
	rcall	EEWrite

	adiw	r26,1
	ldd	r25,Y+DATA_RANDSEED+2
	rcall	EEWrite

	adiw	r26,1
	ldd	r25,Y+DATA_RANDSEED+1
	rcall	EEWrite

	adiw	r26,1
	ldd	r25,Y+DATA_RANDSEED+0
	rcall	EEWrite

; ----- start generator of LCD contrast control, update LCD contrast

	rcall	LCD_InitGen

; ----- LCD initialize (low voltage requires 2 initializations)
; DESTROYS: R31, R30, R24
	rcall	LCD_Init		; initialice LCD

; ----- initialize keyboard
; DESTROYS: R24
	rcall	KEY_Init

; ----- default rounding

	ldi	r24,FIX_OFF
	std	Y+DATA_FIX,r24

; ----- clear print buffer

	call	ClrPrintBuf

	ldi	r26,lo8(PrintBuf3) ; buffer
	ldi	r27,hi8(PrintBuf3)
	ldi	r24,' '
1:	st	X+,r24		; write space character
	cpi	r26,lo8(PrintBuf3+LCD_COLNUM)
	brne	1b
	st	X,R_ZERO	; terminating zero

; ----- clear edit buffer

	call	ExecClr

	; clear register T
	ldi	r24,REG_T
; INPUT: R24 = index of a number
; OUTPUT: R1 = 0
; DESTROYS: R31, R30, R27..R24, R0
	call	CalcSetMem	; clear T register

; ----- inicialize stack of complex/fraction numbers

	ldi	r24,10
	sts	CpxBeg,r24	; first memory register of stack of complex numbers
	sts	CpxNum,r24	; max. number of complex numbers in the stack

; ----- display calculator version

	rcall	DispBuild

; ----- number of programs in module

	ldi	r30,lo8(Module)
	ldi	r31,hi8(Module)
	lpm	r24,Z
	std	Y+DATA_PROGNUM,r24

; ----- open main program
; INPUT: R24 = program index (0=main)
; DESTROYS: R31, R30, R24, R0
	clr	r24
	call	OpenProg

; ----- restart after fatal and after wake-up

.global Restart
Restart:

; ----- update sleep activity

	rcall	SleepUpdate

; ----- enable interrupts

	sei

; ----- check CRC (after every power-on, on wake-up from sleep mode too)

	rcall	GetCrc		; calculate CRC -> R25:R24
	ldi	r30,lo8(Crc)
	ldi	r31,hi8(Crc)
	lpm	r22,Z+		; get expected CRC -> R23:R22
	lpm	r23,Z
	cp	r22,r24		; check CRC
	cpc	r23,r25
	breq	2f		; CRC is OK

	call	DispSetRow1
	ldi	r30,lo8(CrcErr)
	ldi	r31,hi8(CrcErr)
	call	DispTextRom	; display error text
	call	DispSpcClr	; clear rest of the row

	call	Wait1s		; wait some time (2 seconds)
	call	Wait1s

	call	DispFlags	; clear 1st row
2:

; ----- check and display number of entries in CALC macro interpreter (must be < 128)

#ifdef CHECK_CALC

	call	DispSetRow2

	ldi	r24,lo8(CalcJmpTabEnd)
	ldi	r25,hi8(CalcJmpTabEnd)
	subi	r24,lo8(CalcJmpTab)
	sbci	r25,hi8(CalcJmpTab)
	lsr	r25
	ror	r24
	cpi	r24,C_CHECK
	breq	2f

	ldi	r30,lo8(CheckCalcT1)
	ldi	r31,hi8(CheckCalcT1)
	call	DispTextRom
1:	rjmp	1b

2:	ldi	r30,lo8(CheckCalcT2)
	ldi	r31,hi8(CheckCalcT2)
	push	r24
	call	DispTextRom
	pop	r24
	call	Disp3Dig
	call	DispSpcClr

	call	Wait1s

	call	ExecClr

#endif


; ----- initialize LCD again (on short power error)

	rcall	LCD_Init
	rcall	Disp

Loop:

; ----- check sleep (after 30 seconds)

	ldd	r24,Y+DATA_TIME	; time
	ldd	r25,Y+DATA_TIME+1

	lds	r22,SleepLast	; last activity time
	lds	r23,SleepLast+1

	sub	r24,r22		; elapsed time
	sbc	r25,r23

	lds	r22,SleepMax
	lds	r23,SleepMax+1
	tst	r23		; off?
	breq	2f		; sleeping is off

	cp	r24,r22
	cpc	r25,r23
	brcs	2f

	rjmp	GoSleep		; go sleep

; ----- display trace (if running)

2:	call	DispTrace

; ----- running program?

	IFN_RUNNING		; if not running
	rjmp	4f		; not running

; ----- running: update sleep activity

	rcall	SleepUpdate

; ----- running: get next byte
; OUTPUT: R24 = byte (0 on error)
;	  CY = invalid address (address not changed)
; DESTROYS: -
	rcall	LoadPrg		; load byte of program
	brcs	Loop

	; execute one key
	call	Exec

	; check break program
	rcall	BreakKey
	rjmp	Loop

; ----- execute user key
; OUTPUT: R24 = hex key code (NZ brne) or Oxff no key (NOKEY, ZY breq)
;	  ZY = set if NOKEY
; DESTROYS: -
; NOTE: Enables interrupts
4:	rcall	GetKey
	breq	1f		; no key

	; key: update sleep activity
;	rcall	SleepUpdate

	; programming
	IF_PROGRAM		; programming?
	rjmp	5f		; programming

	; execute key
	call	Exec		; execute
	rjmp	1f

5:	rcall	Program		; programming

; ----- indicate error

1:	IF_RUNNING		; running?
	rjmp	Loop		; program running, do not display error
	IF_FATAL		; test fatal error
	rjmp	2f		; fatal error
	IFN_ERROR		; test soft error
	rjmp	Loop		; not error

2:	call	DispErr		; indicate error
	rjmp	Loop
