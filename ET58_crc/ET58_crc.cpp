
#include <stdio.h>

#pragma warning(disable : 4996) // unsafe fopen

typedef unsigned char u8;
typedef unsigned short u16;

// buffer
#define BUFMAX 100000
u8 Buf[BUFMAX+1];
int BufN;

// result CRC
u16 Crc;

// Sample "123456789" -> 0x31C3
const u8* Sample1 = (const u8*)"123456789";

// Sample: 0xFC 0x05 0x4A -> 0x8048
u8 Sample2[3] = { 0xFC, 0x05, 0x4A };

// crc of one byte
u16 Crc_CCITT_1(u16 crc, u8 data)
{
	crc = (crc >> 8) | (crc << 8);
	crc ^= data;
	crc ^= (crc & 0xf0) >> 4;
	crc ^= crc << 12;
	crc ^= (crc & 0xff) << 5;
	return crc;
}

// crc of data
#define CRCXMODEM_INIT 0
u16 Crc_XModem(const u8* buf, int len)
{
	u16 crc = CRCXMODEM_INIT;
	for (; len > 0; len--)
	{
		crc = Crc_CCITT_1(crc, *buf++);
	}
	return crc;
}

// main function
int main(int argc, char* argv[])
{
	// file name
	if (argc != 3)
	{
		printf("Syntax: Enter input and output file name\n");
		return 2;
	}

	// check internal CRC
	if ((Crc_XModem(Sample1, 9) != 0x31C3) ||
		(Crc_XModem(Sample2, 3) != 0x8048))
	{
		printf("Internal CRC error\n");
		return 2;
	}

	// open file
	FILE* f;
	printf("Loading file %s: ", argv[1]);
	f = fopen(argv[1], "rb");
	if (f == NULL)
	{
		printf("\rCannot open %s\n", argv[1]);
		return 2;
	}

	// read file
	BufN = (int)fread(Buf, 1, BUFMAX, f);

	// close file
	fclose(f);

	if ((BufN < 100) || (BufN == BUFMAX))
	{
		printf("\rIncorrect size %u of %s\n", BufN, argv[1]);
		return 2;
	}
	printf("OK\nCalculating CRC: ");

	// search CRC sample 0x1234
	if (*(u16*)&Buf[BufN-2] == 0x1234)
		BufN -= 2;
	else if (*(u16*)&Buf[BufN-3] == 0x1234)
		BufN -= 3;
	else if (*(u16*)&Buf[BufN-4] == 0x1234)
		BufN -= 4;
	else if (*(u16*)&Buf[BufN-5] == 0x1234)
		BufN -= 5;
	else if (*(u16*)&Buf[BufN-6] == 0x1234)
		BufN -= 6;
	else
	{
		printf("Cannot find sample pattern 0x1234\n");
		return 2;
	}

	// calculate crc
	Crc = Crc_XModem(Buf, BufN);
	printf("0x%04X, offset %u\nSaving file %s: ", Crc, BufN, argv[2]);

	// open output file
	f = fopen(argv[2], "wb");
	if (f == NULL)
	{
		printf("\rCannot create %s\n", argv[2]);
		return 2;
	}

	// save CRC
	fprintf(f,	"; CRC of the file, auto generated, do not modify!\n\n"
				"\t.section\t.crcdata, \"ax\", @progbits\n\n"
				".global Crc\t; Offset: %d\n"
				"Crc:\t.word\t0x%04X\n\t.balign\t2\n", BufN, Crc);

	// close file
	fclose(f);
	printf("OK\n");

	return 0;
}

