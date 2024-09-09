; ****************************************************************************
;
;                                LCD display
;
; ****************************************************************************

#include "include.inc"

	.text

; LCD pins:
;   PB6: RS register select, 1=data, 0=command
;   PD4: E enable, 1=enable state
;   PD3: DB4
;   PD2: DB5
;   PD1: DB6
;   PD0: DB7
;   PB7: LCD power
;   PD6: VO2 (OC0A)

; LCD commands
#define LCD_CLEAR	B0	// 00000001 Clear Display and Home the Cursor
#define LCD_HOME	B1	// 0000001* Return Cursor and LCD to Home Position
#define LCD_MOVE	B2	// 000001IS Set Cursor Move Direction (I: increment/decrement; S: shift display)
#define LCD_DISPLAY	B3	// 00001DCB Enable Display/Cursor (D: display on, C: cursor on, B: blink on)
#define LCD_SHIFT	B4	// 0001SR** Move Cursor/Shift Display (S: diplay shift, R: direction right)
#define LCD_SETUP	B5	// 001DNF** Set Interface Length (D: 8 bit interface, N: 2 rows, F: big font 5x10)
#define LCD_CGRAM	B6	// 01AAAAAA Move Cursor into CGRAM (A: address)
#define LCD_DDRAM	B7	// 1AAAAAAA Move Cursor to Display (A: address)

; Set data mode
#define DATA_MODE sbi _SFR_IO_ADDR(PORTB),6

; Set command mode
#define CMD_MODE cbi _SFR_IO_ADDR(PORTB),6

; Set enable state ON
#define EN_ON sbi _SFR_IO_ADDR(PORTD),4

; Set enable state OFF
#define EN_OFF cbi _SFR_IO_ADDR(PORTD),4

#define VOTAB_MAX 10	; max. value of VOTab

; LCD contrast - OCR0A divider (TCC0B prescaler = 2)
.global VOTab
VOTab:

#if F_CPU >= 6000000

	.byte	142	; 0: 3497 Hz
	.byte	113	; 1: 4386 Hz
	.byte	90	; 2: 5495 Hz
	.byte	72	; 3: 6849 Hz
	.byte	58	; 4: 8475 Hz
	.byte	46	; 5: 10638 Hz
	.byte	36	; 6: 13514 Hz
	.byte	29	; 7: 16667 Hz
	.byte	23	; 8: 20833 Hz
	.byte	18	; 9: 26316 Hz

#else

	.byte	71	; 0: 3497 Hz
	.byte	56	; 1: 4386 Hz
	.byte	45	; 2: 5495 Hz
	.byte	36	; 3: 6849 Hz
	.byte	29	; 4: 8475 Hz
	.byte	23	; 5: 10638 Hz
	.byte	18	; 6: 13514 Hz
	.byte	14	; 7: 16667 Hz
	.byte	11	; 8: 20833 Hz
	.byte	9	; 9: 26316 Hz

#endif

; default font (every byte is 1 row of characters; only bits 0..4 are used)
.global FontDef
FontDef:
	; 0 (8): sum (100, 0x84)
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 0 0 0 0
	; 0 0 0 0 1 0 0 0
	; 0 0 0 0 0 1 0 0
	; 0 0 0 0 1 0 0 0
	; 0 0 0 1 0 0 0 0
	; 0 0 0 1 1 1 1 1
	; 0 0 0 0 0 0 0 0
        .byte	0x1f, 0x10, 0x08, 0x04, 0x08, 0x10, 0x1f, 0x00

	; 1: backslash (60, 0x5C)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 1 0 0 0 0
	; 0 0 0 0 1 0 0 0
	; 0 0 0 0 0 1 0 0
	; 0 0 0 0 0 0 1 0
	; 0 0 0 0 0 0 0 1
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
        .byte	0x00, 0x10, 0x08, 0x04, 0x02, 0x01, 0x00, 0x00

	; 2: ~ wave (94, 0x7E)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 1 1 0 1
	; 0 0 0 1 0 1 1 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
        .byte	0x00, 0x00, 0x0d, 0x16, 0x00, 0x00, 0x00, 0x00

	; 3: pi (95, 0x7F)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 1 1 1 1 1
	; 0 0 0 0 1 0 1 0
	; 0 0 0 0 1 0 1 0
	; 0 0 0 0 1 0 1 0
	; 0 0 0 1 0 0 1 1
	; 0 0 0 0 0 0 0 0
        .byte	0x00, 0x00, 0x1f, 0x0a, 0x0a, 0x0a, 0x13, 0x00

	; 4: square root (96, 0x80)
	; 0 0 0 0 0 0 1 1
	; 0 0 0 0 0 0 1 0
	; 0 0 0 1 1 0 1 0
	; 0 0 0 0 1 1 0 0
	; 0 0 0 0 1 1 0 0
	; 0 0 0 0 1 1 0 0
	; 0 0 0 0 1 0 0 0
	; 0 0 0 0 1 0 0 0
	.byte	0x03, 0x02, 0x1a, 0x0c, 0x0c, 0x0c, 0x08, 0x08

	; 5: micro (97, 0x81)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 1 0 0 0 1
	; 0 0 0 1 0 0 0 1
	; 0 0 0 1 0 0 0 1
	; 0 0 0 1 0 0 1 1
	; 0 0 0 1 1 1 0 1
	; 0 0 0 1 0 0 0 0
        .byte	0x00, 0x00, 0x11, 0x11, 0x11, 0x13, 0x1d, 0x10

	; 6: omega (98, 0x82)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 1 1 1 0
	; 0 0 0 1 0 0 0 1
	; 0 0 0 1 0 0 0 1
	; 0 0 0 0 1 0 1 0
	; 0 0 0 1 1 0 1 1
	; 0 0 0 0 0 0 0 0
        .byte	0x00, 0x00, 0x0e, 0x11, 0x11, 0x0a, 0x1b, 0x00

	; 7: full (99, 0x83)
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
        .byte	0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f

	.balign 2

; font for left column
.global FontColL
FontColL:
	; 0 (8) (92, 0x7C)
	; 0 0 0 1 0 0 0 0
	; 0 0 0 1 0 0 0 0
	; 0 0 0 1 0 0 0 0
	; 0 0 0 1 0 0 0 0
	; 0 0 0 1 0 0 0 0
	; 0 0 0 1 0 0 0 0
	; 0 0 0 1 0 0 0 0
	; 0 0 0 1 0 0 0 0
        .byte	0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10

	; 1 (93, 0x7D)
	; 0 0 0 1 1 0 0 0
	; 0 0 0 1 1 0 0 0
	; 0 0 0 1 1 0 0 0
	; 0 0 0 1 1 0 0 0
	; 0 0 0 1 1 0 0 0
	; 0 0 0 1 1 0 0 0
	; 0 0 0 1 1 0 0 0
	; 0 0 0 1 1 0 0 0
        .byte	0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18

	; 2 (94, 0x7E)
	; 0 0 0 1 1 1 0 0
	; 0 0 0 1 1 1 0 0
	; 0 0 0 1 1 1 0 0
	; 0 0 0 1 1 1 0 0
	; 0 0 0 1 1 1 0 0
	; 0 0 0 1 1 1 0 0
	; 0 0 0 1 1 1 0 0
	; 0 0 0 1 1 1 0 0
        .byte	0x1c, 0x1c, 0x1c, 0x1c, 0x1c, 0x1c, 0x1c, 0x1c

	; 3 (95, 0x7F)
	; 0 0 0 1 1 1 1 0
	; 0 0 0 1 1 1 1 0
	; 0 0 0 1 1 1 1 0
	; 0 0 0 1 1 1 1 0
	; 0 0 0 1 1 1 1 0
	; 0 0 0 1 1 1 1 0
	; 0 0 0 1 1 1 1 0
	; 0 0 0 1 1 1 1 0
        .byte	0x1e, 0x1e, 0x1e, 0x1e, 0x1e, 0x1e, 0x1e, 0x1e

	; 4 (96, 0x80)
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
        .byte	0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f

	; 5 (97, 0x81)
	; 0 0 0 1 0 1 0 1
	; 0 0 0 0 1 0 1 0
	; 0 0 0 1 0 1 0 1
	; 0 0 0 0 1 0 1 0
	; 0 0 0 1 0 1 0 1
	; 0 0 0 0 1 0 1 0
	; 0 0 0 1 0 1 0 1
	; 0 0 0 0 1 0 1 0
        .byte	0x15, 0x0a, 0x15, 0x0a, 0x15, 0x0a, 0x15, 0x0a

	; 6 (98, 0x82)
	; 0 0 0 1 0 1 0 0
	; 0 0 0 0 1 0 0 0
	; 0 0 0 1 0 1 0 0
	; 0 0 0 0 1 0 0 0
	; 0 0 0 1 0 1 0 0
	; 0 0 0 0 1 0 0 0
	; 0 0 0 1 0 1 0 0
	; 0 0 0 0 1 0 0 0
        .byte	0x14, 0x08, 0x14, 0x08, 0x14, 0x08, 0x14, 0x08

	; 7 (99, 0x83)
	; 0 0 0 1 1 1 0 1
	; 0 0 0 1 1 1 1 0
	; 0 0 0 1 1 1 0 1
	; 0 0 0 1 1 1 1 0
	; 0 0 0 1 1 1 0 1
	; 0 0 0 1 1 1 1 0
	; 0 0 0 1 1 1 0 1
	; 0 0 0 1 1 1 1 0
        .byte	0x1d, 0x1e, 0x1d, 0x1e, 0x1d, 0x1e, 0x1d, 0x1e

	.balign 2

; font for right column
.global FontColR
FontColR:
	; 0 (8) (92, 0x7C)
	; 0 0 0 0 0 0 0 1
	; 0 0 0 0 0 0 0 1
	; 0 0 0 0 0 0 0 1
	; 0 0 0 0 0 0 0 1
	; 0 0 0 0 0 0 0 1
	; 0 0 0 0 0 0 0 1
	; 0 0 0 0 0 0 0 1
	; 0 0 0 0 0 0 0 1
        .byte	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01

	; 1 (93, 0x7D)
	; 0 0 0 0 0 0 1 1
	; 0 0 0 0 0 0 1 1
	; 0 0 0 0 0 0 1 1
	; 0 0 0 0 0 0 1 1
	; 0 0 0 0 0 0 1 1
	; 0 0 0 0 0 0 1 1
	; 0 0 0 0 0 0 1 1
	; 0 0 0 0 0 0 1 1
        .byte	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03

	; 2 (94, 0x7E)
	; 0 0 0 0 0 1 1 1
	; 0 0 0 0 0 1 1 1
	; 0 0 0 0 0 1 1 1
	; 0 0 0 0 0 1 1 1
	; 0 0 0 0 0 1 1 1
	; 0 0 0 0 0 1 1 1
	; 0 0 0 0 0 1 1 1
	; 0 0 0 0 0 1 1 1
        .byte	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07

	; 3 (95, 0x7F)
	; 0 0 0 0 1 1 1 1
	; 0 0 0 0 1 1 1 1
	; 0 0 0 0 1 1 1 1
	; 0 0 0 0 1 1 1 1
	; 0 0 0 0 1 1 1 1
	; 0 0 0 0 1 1 1 1
	; 0 0 0 0 1 1 1 1
	; 0 0 0 0 1 1 1 1
        .byte	0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f

	; 4 (96, 0x80)
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
        .byte	0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f

	; 5 (97, 0x81)
	; 0 0 0 1 0 1 0 1
	; 0 0 0 0 1 0 1 0
	; 0 0 0 1 0 1 0 1
	; 0 0 0 0 1 0 1 0
	; 0 0 0 1 0 1 0 1
	; 0 0 0 0 1 0 1 0
	; 0 0 0 1 0 1 0 1
	; 0 0 0 0 1 0 1 0
        .byte	0x15, 0x0a, 0x15, 0x0a, 0x15, 0x0a, 0x15, 0x0a

	; 6 (98, 0x82)
	; 0 0 0 0 0 1 0 1
	; 0 0 0 0 0 0 1 0
	; 0 0 0 0 0 1 0 1
	; 0 0 0 0 0 0 1 0
	; 0 0 0 0 0 1 0 1
	; 0 0 0 0 0 0 1 0
	; 0 0 0 0 0 1 0 1
	; 0 0 0 0 0 0 1 0
        .byte	0x05, 0x02, 0x05, 0x02, 0x05, 0x02, 0x05, 0x02

	; 7 (99, 0x83)
	; 0 0 0 1 0 1 1 1
	; 0 0 0 0 1 1 1 1
	; 0 0 0 1 0 1 1 1
	; 0 0 0 0 1 1 1 1
	; 0 0 0 1 0 1 1 1
	; 0 0 0 0 1 1 1 1
	; 0 0 0 1 0 1 1 1
	; 0 0 0 0 1 1 1 1
        .byte	0x17, 0x0f, 0x17, 0x0f, 0x17, 0x0f, 0x17, 0x0f

	.balign 2

; font for lines
.global FontLine
FontLine:
	; 0 (8) (92, 0x7C)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 1 1 1 1 1
        .byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1f

	; 1 (93, 0x7D)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
        .byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1f, 0x1f

	; 2 (94, 0x7E)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
        .byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x1f, 0x1f, 0x1f

	; 3 (95, 0x7F)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
        .byte	0x00, 0x00, 0x00, 0x00, 0x1f, 0x1f, 0x1f, 0x1f

	; 4 (96, 0x80)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
        .byte	0x00, 0x00, 0x00, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f

	; 5 (97, 0x81)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
        .byte	0x00, 0x00, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f

	; 6 (98, 0x82)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
        .byte	0x00, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f

	; 7 (99, 0x83)
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
        .byte	0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f

	.balign 2

; font for pixels
.global FontPix
FontPix:
	; 0 (8) (92, 0x7C)
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
        .byte	0x1f, 0x1f, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00

	; 1 (93, 0x7D)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
        .byte	0x00, 0x00, 0x00, 0x1f, 0x1f, 0x1f, 0x00, 0x00

	; 2 (94, 0x7E)
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
        .byte	0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x00, 0x00

	; 3 (95, 0x7F)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
        .byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1f, 0x1f

	; 4 (96, 0x80)
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
        .byte	0x1f, 0x1f, 0x1f, 0x00, 0x00, 0x00, 0x1f, 0x1f

	; 5 (97, 0x81)
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 0 0 0 0 0
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
        .byte	0x00, 0x00, 0x00, 0x1f, 0x1f, 0x1f, 0x00, 0x00

	; 6 (98, 0x82)
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
	; 0 0 0 1 1 1 1 1
        .byte	0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f

	; 7 (99, 0x83)
	; 0 0 0 1 0 1 0 1
	; 0 0 0 0 1 0 1 0
	; 0 0 0 1 0 1 0 1
	; 0 0 0 0 1 0 1 0
	; 0 0 0 1 0 1 0 1
	; 0 0 0 0 1 0 1 0
	; 0 0 0 1 0 1 0 1
	; 0 0 0 0 1 0 1 0
        .byte	0x15, 0x0a, 0x15, 0x0a, 0x15, 0x0a, 0x15, 0x0a

	.balign 2

; ----- font addresses

FontTab:
	.word	FontDef		; #define FONT_DEF	0	// default font
	.word	FontColL	; #define FONT_COLL	1	// columns from left
	.word	FontColR	; #define FONT_COLR	2	// columns from right
	.word 	FontLine	; #define FONT_LINE	3	// lines
	.word	FontPix		; #define FONT_PIX	4	// pixel graphics

	.balign 2

; ----------------------------------------------------------------------------
;                       Output nibble (takes 20 us)
; ----------------------------------------------------------------------------
; INPUT: R24 = data (bit 0..3 = nibble)
; DESTROYS: -
; ----------------------------------------------------------------------------

LCD_OutNibble:

; ----- clear output bits

	cbi _SFR_IO_ADDR(PORTD),3	; PD3: DB4
	cbi _SFR_IO_ADDR(PORTD),2	; PD2: DB5
	cbi _SFR_IO_ADDR(PORTD),1	; PD1: DB6
	cbi _SFR_IO_ADDR(PORTD),0	; PD0: DB7

; ----- set bits

	sbrc	r24,0
	sbi _SFR_IO_ADDR(PORTD),3	; PD3: DB4

	sbrc	r24,1
	sbi _SFR_IO_ADDR(PORTD),2	; PD2: DB5

	sbrc	r24,2
	sbi _SFR_IO_ADDR(PORTD),1	; PD1: DB6

	sbrc	r24,3
	sbi _SFR_IO_ADDR(PORTD),0	; PD0: DB7

; ----- enable pulse

	EN_ON			; enable
; DESTROYS: -
	rcall	Wait10us	; delay 10 us
	EN_OFF			; disable
; DESTROYS: -
	rjmp	Wait10us	; delay 10 us

; ----------------------------------------------------------------------------
;                          Write command (takes 140 us)
; ----------------------------------------------------------------------------
; INPUT: R24 = data
; DESTROYS: -
; ----------------------------------------------------------------------------

LCD_WriteCmd:

	CMD_MODE		; switch to command mode

; LCD_OutByte must follow

; ----------------------------------------------------------------------------
;                          Output byte (takes 140 us)
; ----------------------------------------------------------------------------
; INPUT: R24 = data
; DESTROYS: -
; ----------------------------------------------------------------------------

LCD_OutByte:

	swap	r24		; swap nibbles
; INPUT: R24 = data (bit 0..3 = nibble)
; DESTROYS: -
	rcall	LCD_OutNibble	; output high nibble

	swap	r24		; swap nibbles back
; INPUT: R24 = data (bit 0..3 = nibble)
; DESTROYS: -
	rcall	LCD_OutNibble	; output low nibble

; DESTROYS: -
	rjmp	Wait100us	; delay 100 us

; ----------------------------------------------------------------------------
;                       Write data (takes 140 us)
; ----------------------------------------------------------------------------
; INPUT: R24 = data
; DESTROYS: -
; ----------------------------------------------------------------------------

LCD_WriteData:

	DATA_MODE		; switch to data mode
	rjmp	LCD_OutByte	; output data byte

; ----------------------------------------------------------------------------
;                      Display character (takes 140 us)
; ----------------------------------------------------------------------------
; INPUT: R24 = character
; DESTROYS: -
; ----------------------------------------------------------------------------

.global DispChar
DispChar:

	push	r24
	push	r25

; ----- substitute character - default font

	lds	r25,SelFont	; selected font
	cpi	r25,FONT_DEF	; default font?
	brne	3f		; no default font

	cpi	r24,0x5c	; backslash
	brne	2f
	ldi	r24,CHAR_BACKSLASH ; 0x5c -> backslash

2:	cpi	r24,0x7e
	brcs	8f
	subi	r24,0x7e - CHAR_WAVE
	rjmp	8f

; ----- substitute character - graphics font

3:	cpi	r24,0x5c	; backslash
	brne	4f
	ldi	r24,0x7c	; substitute by |
	rjmp	8f

4:	cpi	r24,0x7b	; { (91)
	brcs	8f		; not graphics character
	breq	6f		; space

	subi	r24,0x7c	; graphics characters
	rjmp	8f

6:	ldi	r24,' '		; first graphics character is space

; INPUT: R24 = data
; DESTROYS: -
8:	pop	r25

	rcall	LCD_WriteData	; output data byte

	; increase display X position
	ldd	r24,Y+DATA_POSX
	inc	r24		; increase display X position
	std	Y+DATA_POSX,r24	

	pop	r24
	ret

; ----------------------------------------------------------------------------
;                   Set 8-bit interface (takes 10 ms)
; ----------------------------------------------------------------------------
; DESTROYS: R24
; ----------------------------------------------------------------------------

LCD_Set8bit:
	ldi	r24,B1+B0	; (LCD_SETUP command + 8-bit interface) >> 4
LCD_Setbit:
; INPUT: R24 = data (bit 0..3 = nibble)
; DESTROYS: -
	rcall	LCD_OutNibble	; switch to 8-bit interface
; INPUT: R24 = numer of [ms]
; DESTROYS: -
	ldi	r24,10
	rjmp	Waitms		; delay 10 ms

; ----------------------------------------------------------------------------
;                       Restore LCD display
; ----------------------------------------------------------------------------

.global LCD_Restore
LCD_Restore:

; ----- start generator of LCD contrast control, update LCD contrast

	rcall	LCD_InitGen

; ----- LCD initialize (low voltage requires 2 initializations)
; DESTROYS: R31, R30, R24
	rcall	LCD_Init		; initialice LCD

; ----- restore font

	lds	r24,SelFont		; current font
	rjmp	SetFont2

; ----- refresh display

;	rjmp	Disp

; ----------------------------------------------------------------------------
;                   Initialize LCD display generator
; ----------------------------------------------------------------------------

.global LCD_InitGen
LCD_InitGen:

; ----- start generator of LCD contrast control

	ldi	r24,B6+2	; toggle OC0A on compare match, mode CRC (top on OCRA)
	out	_SFR_IO_ADDR(TCCR0A),r24

; LCD_Update must follow

; ----------------------------------------------------------------------------
;                   Update LCD contrast by power voltage
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25..R20 
; ----------------------------------------------------------------------------

;.global LCD_Update
;LCD_Update:

	; set prescaler
	ldi	r24,2		; prescaler 8, output sample frequency 8000000/8/(OCR0A+1)/2 = 2 kHz .. 500 kHz
	out	_SFR_IO_ADDR(TCCR0B),r24

	; prepare required LCD contrast
	ldd	r24,Y+DATA_LCDVO ; user correction = 0..9

; LCD_SetVO must follow

; ----------------------------------------------------------------------------
;                           Set LCD contrast
; ----------------------------------------------------------------------------
; INPUT: R24 = contract 0..9
; ----------------------------------------------------------------------------

.global LCD_SetVO
LCD_SetVO:
	; push registers
	push	r24
	push	r30
	push	r31

	; limit minimum
	tst	r24		; negative index?
	brpl	2f
	clr	r24		; minimal index 0

	; limit maximum
2:	cpi	r24,VOTAB_MAX+1	; maximum index
	brcs	2f
	ldi	r24,VOTAB_MAX	; maximal index

	; address in table
2:	clr	r31
	mov	r30,r24		; contrast index
	subi	r30,lo8(-(VOTab))
	sbci	r31,hi8(-(VOTab))

	; OCR0A divider
	lpm	r24,Z		; laod OCR0A divider
	out	_SFR_IO_ADDR(OCR0A),r24
	
	; pop registers
	pop	r31
	pop	r30
	pop	r24
	ret

; ----------------------------------------------------------------------------
;                            Update font
; ----------------------------------------------------------------------------
; INPUT: R24 = required font (FONT_*)
; DESTROYS: R31, R30, R25, R24
; ----------------------------------------------------------------------------

.global SetFont
SetFont:
	lds	r25,SelFont	; selected font
	cp	r24,r25		; is required font already set?
	breq	LCD_SetFont9	; font is already set

	sts	SelFont,r24	; save new font
SetFont2:
	add	r24,r24		; font index * 2
	ldi	r30,lo8(FontTab) ; font table
	ldi	r31,hi8(FontTab)
	add	r30,r24		; add font index * 2
	adc	r31,R_ZERO
	lpm	r24,Z+		; get font address
	lpm	r31,Z
	mov	r30,r24
	rjmp	LCD_SetFont

; ----------------------------------------------------------------------------
;                         Load fonts
; ----------------------------------------------------------------------------
; INTPUT: R31:R30 (Z) = font table (8 characters)
; DESTROYS: R31, R30, R25, R24
; ----------------------------------------------------------------------------

.global LCD_SetFontDef
LCD_SetFontDef:
	ldi	r30,lo8(FontDef) ; font table
	ldi	r31,hi8(FontDef)
	sts	SelFont,R_ZERO	; set font index

LCD_SetFont:

; ----- load custom characters	
; INPUT: R24 = data
; DESTROYS: -
	ldi	r24,LCD_CGRAM
	rcall	LCD_WriteCmd	; set character generator start address 0
	ldi	r25,CHAR_NUM*8	; number of bytes to send

2:	lpm	r24,Z+		; load one byte
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	LCD_WriteData	; output 1 byte
	dec	r25		; byte counter
	brne	2b		; next byte
LCD_SetFont9:
	ret

; ----------------------------------------------------------------------------
;                   Initialize LCD display
; ----------------------------------------------------------------------------
; DESTROYS: R31, R30, R25, R24
; ----------------------------------------------------------------------------
; ADC convertor must be updated

.global LCD_Init
LCD_Init:

; ----- disable ouput

	EN_OFF

; ----- wait for some time to LCD power up
; DESTROYS: R24
	call	Wait250ms	; wait 250 ms

; ----- set command mode

	CMD_MODE

; ----- byte synchronisation using 8-bit interface - switch to 8-bit interface
; DESTROYS: R24
	rcall	LCD_Set8bit
	rcall	LCD_Set8bit
	rcall	LCD_Set8bit

; ----- switch to 4-bit interface
; DESTROYS: R24
	ldi	r24,B1		; LCD_SETUP command >> 4
	rcall	LCD_Setbit

; ----- setup 4-bit interface, 2 rows, font 5x7
; INPUT: R24 = data
; DESTROYS: -
	ldi	r24,LCD_SETUP+B3
	rcall	LCD_WriteCmd

; ----- display off, cursor off, blinking off
; INPUT: R24 = data
; DESTROYS: -
	ldi	r24,LCD_DISPLAY
	rcall	LCD_WriteCmd

; ----- clear display
; DESTROYS: R24
	ldi	r24,LCD_CLEAR
	rcall	LCD_Home2

; ----- auto move cursor right
; INPUT: R24 = data
; DESTROYS: -
	ldi	r24,LCD_MOVE+B1
	rcall	LCD_WriteCmd

; ----- display on, cursor off, blinking off
; INPUT: R24 = data
; DESTROYS: -
	ldi	r24,LCD_DISPLAY+B2
	rcall	LCD_WriteCmd

; ----- load custom characters	
; INTPUT: R31:R30 (Z) = font table (8 characters)
; DESTROYS: R31, R30, R25, R24

	rcall	LCD_SetFontDef

; ----- set cursor home position

	std	Y+DATA_POSX,R_ZERO ; clear display X position
	ldi	r24,LCD_HOME
LCD_Home2:
; INPUT: R24 = data
; DESTROYS: -
	rcall	LCD_WriteCmd	; write command
; INPUT: R24 = numer of [ms]
; DESTROYS: -
	ldi	r24,5
	rjmp	Waitms		; wait 5 ms

; ----------------------------------------------------------------------------
;                         Set display position
; ----------------------------------------------------------------------------
; INPUT: R24 = position 0..15, add ROW1 or ROW2
; DESTROYS: -
; ----------------------------------------------------------------------------

.global DispSetPos
DispSetPos:
	push	r24
	push	r25

	mov	r25,r24
	andi	r25,0x3f	; mask position X
	std	Y+DATA_POSX,r25	; set new position X
	ori	r24,LCD_DDRAM
; INPUT: R24 = data
; DESTROYS: -
	rcall	LCD_WriteCmd

	pop	r25
	pop	r24
	ret

; ----------------------------------------------------------------------------
;                      Set cursor to start or ROW2
; ----------------------------------------------------------------------------
; DESTROYS: -
; ----------------------------------------------------------------------------

.global DispSetRow2
DispSetRow2:
	push	r24
	ldi	r24,LCD_DDRAM+ROW2
	rjmp	DispSetRow1B

; ----------------------------------------------------------------------------
;                      Set cursor to start or ROW1
; ----------------------------------------------------------------------------
; DESTROYS: -
; ----------------------------------------------------------------------------

.global DispSetRow1
DispSetRow1:
	push	r24
	ldi	r24,LCD_DDRAM+ROW1
DispSetRow1B:
	std	Y+DATA_POSX,R_ZERO ; clear X position
; INPUT: R24 = data
; DESTROYS: -
	rcall	LCD_WriteCmd
	pop	r24
	ret

; ----------------------------------------------------------------------------
;                         Display ASCIIZ text from ROM
; ----------------------------------------------------------------------------
; INPUT: R31:R30 = text in ROM (terminated with 0)
; DESTROYS: R31, R30, R24
; ----------------------------------------------------------------------------

DispTextRom2:
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	DispChar

.global DispTextRom
DispTextRom:
	lpm	r24,Z+
	tst	r24
	brne	DispTextRom2
	ret

; ----------------------------------------------------------------------------
;                         Display ASCIIZ text from RAM
; ----------------------------------------------------------------------------
; INPUT: R31:R30 = text in RAM (terminated with 0)
; DESTROYS: R31, R30, R24
; ----------------------------------------------------------------------------

DispTextRam2:
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	DispChar

.global DispTextRam
DispTextRam:
	ld	r24,Z+
	tst	r24
	brne	DispTextRam2
	ret

; ----------------------------------------------------------------------------
;                        Display space character
; ----------------------------------------------------------------------------
; DESTROYS: -
; ----------------------------------------------------------------------------

.global DispSpc
DispSpc:
	push	r24
	ldi	r24,' '
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	DispChar	; output byte
	pop	r24
	ret

; ----------------------------------------------------------------------------
;                    Display spaces until X position
; ----------------------------------------------------------------------------
; INPUT: R24 = position X
; DESTROYS: R25
; ----------------------------------------------------------------------------

DispSpcPos2:
	rcall	DispSpc

.global DispSpcPos
DispSpcPos:
	ldd	r25,Y+DATA_POSX
	cp	r25,r24
	brcs	DispSpcPos2
	ret

; ----------------------------------------------------------------------------
;                          Clear rest of line
; ----------------------------------------------------------------------------
; DESTROYS: -
; ----------------------------------------------------------------------------

.global DispSpcClr
DispSpcClr:
	push	r24
	push	r25

	ldi	r24,LCD_COLNUM
	rcall	DispSpcPos

	pop	r25
	pop	r24
	ret

; ----------------------------------------------------------------------------
;                         Display HEX word
; ----------------------------------------------------------------------------
; INPUT: R25:R24 = byte
; DESTROYS: -
; ----------------------------------------------------------------------------

.global DispHexW
DispHexW:
	push	r24
	mov	r24,r25
; INPUT: R24 = byte
; DESTROYS: -
	rcall	DispHexB
	pop	r24

; DispHexB must follow

; ----------------------------------------------------------------------------
;                         Display HEX byte
; ----------------------------------------------------------------------------
; INPUT: R24 = byte
; DESTROYS: -
; ----------------------------------------------------------------------------

.global DispHexB
DispHexB:
	swap	r24
; INPUT: R24 = nibble
; DESTROYS: -
	rcall	DispHexDig
	swap	r24

; DispHexDig must follow

; ----------------------------------------------------------------------------
;                         Display HEX digit
; ----------------------------------------------------------------------------
; INPUT: R24 = nibble
; DESTROYS: -
; ----------------------------------------------------------------------------

.global DispHexDig
DispHexDig:
	push	r24

	andi	r24,0x0f	; mask low nibble
	cpi	r24,10		; digit?
	brcs	2f		; digit 0..9
	subi	r24,-7		; correction for digits A..F
2:	subi	r24,-0x30	; conversion to ASCII character
; INPUT: R24 = character or data
; DESTROYS: -
	rcall	DispChar	; display character

	pop	r24
	ret
