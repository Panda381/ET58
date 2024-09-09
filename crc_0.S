; CRC sample

	.section	.crcdata, "ax", @progbits

.global Crc
Crc:	.word	0x1234	; must be 0x1234
	.balign	2
