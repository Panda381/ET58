; ****************************************************************************
;
;                          ADC analog-digital converter
;
; ****************************************************************************

#include "include.inc"

	.text

; ----------------------------------------------------------------------------
;                         Measure power voltage
; ----------------------------------------------------------------------------
; OUTPUT: R25:R24 voltage in 0.01V
; DESTROYS: R23, R22, R21, R20
; ----------------------------------------------------------------------------

.global ADC_Vcc
ADC_Vcc:

; ----- select AVcc reference voltage, Vbg 1.1V input, right justify

	ldi	r20,BIT(REFS0)+14 ; 14 = 1.1V Vbg channel

; ----- measure
; OUTPUT: R25:R24 temperature in °C (with uncalibrated offset, value 0..1023)
; DESTROYS: R23, R22, R21, R20

	rcall	ADC_Temp2	; measure voltage

; ----- calculate power voltage at multiply of 0.01V (reference voltage = 1.1V)
; 4.55V 238 -> 455
; 2.78V 392 -> 278
; 2.55V 428 -> 255
; Vcc = 112000/adc - 7 [at 0.01V]

	movw	r20,r24
	clr	r25		; 112000 = 0x1B580
	ldi	r24,1
	ldi	r23,0xb5
	ldi	r22,0x80

; INPUT: R25:R24:R23:R22 = dividend (N3:N2:N1:N0)
;        R21:R20 = divisor (D1:D0)
; OUTPUT: R25:R24 = quotient (Q1:Q0)
; DESTROYS: R31, R23, R22
	call	DivDWW
	sbiw	r24,7
	ret

; ----------------------------------------------------------------------------
;                         Measure temperature
; ----------------------------------------------------------------------------
; OUTPUT: R25:R24 temperature in °C (with uncalibrated offset, value 0..1023)
; DESTROYS: R23, R22, R21, R20
; ----------------------------------------------------------------------------
; Conversion time: 60 ms

.global ADC_Temp
ADC_Temp:

; ----- select 1.1V reference voltage, temperature sensor input, right justify

	ldi	r20,BIT(REFS1)+BIT(REFS0)+8	; 8 = temperature sensor channel
ADC_Temp2:

; ----- enable ADC

	lds	r21,PRR
	andi	r21,~BIT(PRADC)
	sts	PRR,r21

; ----- set MUX

	sts	ADMUX,r20

; ----- clear accumulator R25:R24:R23

	clr	r23
	clr	r24
	clr	r25
	
; ----- start conversion
; 14 ADC clock cycles = 4460 Hz sample frequency = 0.22 ms, 256 samples = 57 ms
; First conversion takes 25 ADC clock cycles (0.4 ms) and can return wrong result.

	clr	r22		; number of loops = 256
#if F_CPU >= 6000000
2:	ldi	r20,BIT(ADEN)+BIT(ADSC)+7	; 8 MHz: prescaler division 128, clock 62500 Hz
#else
2:	ldi	r20,BIT(ADEN)+BIT(ADSC)+6	; 4 MHz: prescaler division 64, clock 62500 Hz
#endif
	sts	ADCSRA,r20

; ----- wait for end of conversion

4:	lds	r20,ADCSRA	; read status register
	andi	r20,BIT(ADSC)	; check end of conversion
	brne	4b		; conversion not completed yet

; ----- read conversion result and add to accumulator

	lds	r20,ADCL	; result LOW
	lds	r21,ADCH	; result HIGH
	andi	r21,0x03	; mask value

; ----- add to accumulator

	add	r23,r20
	adc	r24,r21
	adc	r25,R_ZERO

; ----- next loop

	dec	r22
	brne	2b

; ----- round

	subi	r23,0x80
	sbc	r24,R_ZERO
	sbc	r25,R_ZERO

; ----- terminate ADC

	sts	ADCSRA,R_ZERO	; turn off ADC, stop conversions
	sts	ADMUX,R_ZERO	; turn off reference

; ----- disable ADC

	lds	r21,PRR
	ori	r21,BIT(PRADC)
	sts	PRR,r21
	ret
