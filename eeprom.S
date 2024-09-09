; ****************************************************************************
;
;                                   EEPROM
;
; ****************************************************************************

#include "include.inc"

	.text

; ----------------------------------------------------------------------------
;                           Read EEPROM byte
; ----------------------------------------------------------------------------
; INPUT: R27:R26 = source address
; OUTPUT: R24 = data
; DESTROYS: -
; ----------------------------------------------------------------------------

; ----- set up address

.global EERead
EERead:	out	_SFR_IO_ADDR(EEARH),r27
	out	_SFR_IO_ADDR(EEARL),r26

; ----- start read operation

	sbi	_SFR_IO_ADDR(EECR),EERE

; ----- read data

	in	r24,_SFR_IO_ADDR(EEDR)
	ret

; ----------------------------------------------------------------------------
;                           Write EEPROM byte
; ----------------------------------------------------------------------------
; INPUT: R27:R26 = destination address
;	 R25 = data
; OUTPUT: R24 = old byte
; ----------------------------------------------------------------------------

; ----- check old content

.global EEWrite
EEWrite:

; INPUT: R27:R26 = source address
; OUTPUT: R24 = data
; DESTROYS: -
	rcall	EERead		; read old byte -> R24
	cp	r24,r25		; check byte
	breq	EEWrite4	; data already set

; ----- set up address and data

	out	_SFR_IO_ADDR(EEARH),r27
	out	_SFR_IO_ADDR(EEARL),r26
	out	_SFR_IO_ADDR(EEDR),r25

; ----- start write operation

	sbi	_SFR_IO_ADDR(EECR),EEMPE ; from now, 4 clock cycles to write EEPE
	sbi	_SFR_IO_ADDR(EECR),EEPE

; ----- wait operation

2:	sbic	_SFR_IO_ADDR(EECR),EEPE
	rjmp	2b

EEWrite4:
	ret
