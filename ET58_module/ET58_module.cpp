
#include <stdio.h>

#pragma warning(disable : 4996) // unsafe fopen

// input buffer
#define BUFMAX 30000
char buf[BUFMAX+1];
int bufN;

// output buffer
#define PROGNUM 255
#define PROGSIZE 20000
unsigned char prog[PROGNUM][PROGSIZE];
int progN[PROGNUM];
int totalN;
int prognum;

// key names for save
const char SaveName[] = {
	"0\0"		// 0x00 digit 0
	"1\0"		// 0x01 digit 1
	"2\0"		// 0x02 digit 2
	"3\0"		// 0x03 digit 3
	"4\0"		// 0x04 digit 4
	"5\0"		// 0x05 digit 5
	"6\0"		// 0x06 digit 6
	"7\0"		// 0x07 digit 7
	"8\0"		// 0x08 digit 8
	"9\0"		// 0x09 digit 9
	"0A\0"		// 0x0a digit 0A
	"0B\0"		// 0x0b digit 0B
	"0C\0"		// 0x0c digit 0C
	"0D\0"		// 0x0d digit 0D
	"0E\0"		// 0x0e digit 0E
	"0F\0"		// 0x0f digit 0F

	"E'\0"		// 0x10 label E'
	"A\0"		// 0x11 label A
	"B\0"		// 0x12 label B
	"C\0"		// 0x13 label C
	"D\0"		// 0x14 label D
	"E\0"		// 0x15 label E
	"A'\0"		// 0x16 label A'
	"B'\0"		// 0x17 label B'
	"C'\0"		// 0x18 label C'
	"D'\0"		// 0x19 label D'
	"A''\0"		// 0x1a label A''
	"B''\0"		// 0x1b label B''
	"C''\0"		// 0x1c label C''
	"D''\0"		// 0x1d label D''
	"E''\0"		// 0x1e label E''
	"F\0"		// 0x1f label F

	"\0"		// 0x20
	"2ND\0"		// 0x21 2nd
	"INV\0"		// 0x22 INV
	"LNX\0"		// 0x23 Ln x
	"CE\0"		// 0x24 CE
	"CLR\0"		// 0x25 CLR
	"SB*\0"		// 0x26 SBR Ind
	"HI*\0"		// 0x27 HIR Ind
	"LOG\0"		// 0x28 log
	"CP\0"		// 0x29 CP
	"\0"		// 0x2a
	"COD\0"		// 0x2b code
	"LG2\0"		// 0x2c log2
	"RND\0"		// 0x2d rand
	"\0"		// 0x2e
	"\0"		// 0x2f

	"TAN\0"		// 0x30 tan
	"LRN\0"		// 0x31 LRN
	"X/T\0"		// 0x32 x<>t
	"X2\0"		// 0x33 x^2
	"SQR\0"		// 0x34 Vx
	"1/X\0"		// 0x35 1/x
	"PGM\0"		// 0x36 Pgm
	"P/R\0"		// 0x37 P->R
	"SIN\0"		// 0x38 sin
	"COS\0"		// 0x39 cos
	"TMP\0"		// 0x3a Temp
	"X/Y\0"		// 0x3b x<>y
	"SNH\0"		// 0x3c sinh
	"CSH\0"		// 0x3d cosh
	"TNH\0"		// 0x3e tanh
	"\0"		// 0x3f

	"IND\0"		// 0x40 Ind
	"SST\0"		// 0x41 SST
	"STO\0"		// 0x42 STO
	"RCL\0"		// 0x43 RCL
	"SUM\0"		// 0x44 SUM
	"YX\0"		// 0x45 y^x
	"INS\0"		// 0x46 Ins
	"CMS\0"		// 0x47 CMs
	"EXC\0"		// 0x48 Exc
	"PRD\0"		// 0x49 Prd
	"BAT\0"		// 0x4a Bat
	"N!\0"		// 0x4b n!
	"LN!\0"		// 0x4c ln n!
	"LG!\0"		// 0x4d log n!
	"MD2\0"		// 0x4e mod2
	"\0"		// 0x4f

	"IXI\0"		// 0x50 |x|
	"BST\0"		// 0x51 BST
	"EE\0"		// 0x52 EE
	"(\0"		// 0x53 (
	")\0"		// 0x54 )
	"/\0"		// 0x55 :
	"DEL\0"		// 0x56 Del
	"ENG\0"		// 0x57 Eng
	"FIX\0"		// 0x58 Fix
	"INT\0"		// 0x59 Int
	"LCD\0"		// 0x5a LCD
	"LFT\0"		// 0x5b <
	"RGH\0"		// 0x5c >
	"ROU\0"		// 0x5d round
	"MOD\0"		// 0x5e mod
	"\0"		// 0x5f

	"DEG\0"		// 0x60 Deg
	"GTO\0"		// 0x61 GTO
	"PG*\0"		// 0x62 Pgm Ind
	"EX*\0"		// 0x63 Exc Ind
	"PD*\0"		// 0x64 Prd Ind
	"*\0"		// 0x65 x
	"PAU\0"		// 0x66 Pause
	"EQ\0"		// 0x67 x=t
	"NOP\0"		// 0x68 Nop
	"OP\0"		// 0x69 Op
	"REL\0"		// 0x6a REL
	"IN*\0"		// 0x6b Inc Ind
	"RE*\0"		// 0x6c Reg Ind
	"IF*\0"		// 0x6d If Ind
	"AND\0"		// 0x6e & AND
	"\0"		// 0x6f

	"RAD\0"		// 0x70 Rad
	"SBR\0"		// 0x71 SBR
	"ST*\0"		// 0x72 STO Ind
	"RC*\0"		// 0x73 RCL Ind
	"SM*\0"		// 0x74 SUM Ind
	"-\0"		// 0x75 -
	"LBL\0"		// 0x76 Lbl
	"GE\0"		// 0x77 x>=t
	"STA\0"		// 0x78 Stat+
	"AVR\0"		// 0x79 Avrg x
	"IF\0"		// 0x7a If
	"\0"		// 0x7b
	"\0"		// 0x7c
	"\0"		// 0x7d
	"XOR\0"		// 0x7e ~ XOR
	"\0"		// 0x7f

	"GRD\0"		// 0x80 Grad
	"RST\0"		// 0x81 RST
	"HIR\0"		// 0x82 HIR
	"GO*\0"		// 0x83 GTO Ind
	"OP*\0"		// 0x84 Op Ind
	"+\0"		// 0x85 +
	"STF\0"		// 0x86 St Flg
	"IFF\0"		// 0x87 If Flg
	"DMS\0"		// 0x88 D.MS
	"PI\0"		// 0x89 pi
	"REG\0"		// 0x8a Reg
	"HEX\0"		// 0x8b HEX
	"BIN\0"		// 0x8c BIN
	"OCT\0"		// 0x8d OCT
	"OR\0"		// 0x8e | OR
	"\0"		// 0x8f

	"LST\0"		// 0x90 List
	"R/S\0"		// 0x91 R/S
	"RTN\0"		// 0x92 RTN
	".\0"		// 0x93 .
	"+/-\0"		// 0x94 +/-
	"=\0"		// 0x95 =
	"WRT\0"		// 0x96 Write
	"DSZ\0"		// 0x97 Dsz
	"ADV\0"		// 0x98 Adv
	"PRT\0"		// 0x99 Prt
	"PHI\0"		// 0x9a phi
	"DEC\0"		// 0x9b DEC
	"INC\0"		// 0x9c Inc
	"NOT\0"		// 0x9d NOT
	"%\0"		// 0x9e %
	"\0"		// 0x9f

	"\0"		// 0xa0
	"\0"		// 0xa1
	"\0"		// 0xa2
	"\0"		// 0xa3
	"\0"		// 0xa4
	"\0"		// 0xa5
	"\0"		// 0xa6
	"\0"		// 0xa7
	"\0"		// 0xa8
	"\0"		// 0xa9
	"\0"		// 0xaa
	"\0"		// 0xab
	"\0"		// 0xac
	"\0"		// 0xad
	"\0"		// 0xae
	"\0"		// 0xaf

	"\0"		// 0xb0
	"\0"		// 0xb1
	"\0"		// 0xb2
	"\0"		// 0xb3
	"\0"		// 0xb4
	"\0"		// 0xb5
	"\0"		// 0xb6
	"\0"		// 0xb7
	"\0"		// 0xb8
	"\0"		// 0xb9
	"\0"		// 0xba
	"\0"		// 0xbb
	"\0"		// 0xbc
	"\0"		// 0xbd
	"\0"		// 0xbe
	"\0"		// 0xbf

	"\0"		// 0xc0
	"\0"		// 0xc1
	"\0"		// 0xc2
	"\0"		// 0xc3
	"\0"		// 0xc4
	"\0"		// 0xc5
	"\0"		// 0xc6
	"\0"		// 0xc7
	"\0"		// 0xc8
	"\0"		// 0xc9
	"\0"		// 0xca
	"\0"		// 0xcb
	"\0"		// 0xcc
	"\0"		// 0xcd
	"\0"		// 0xce
	"\0"		// 0xcf

	"\0"		// 0xd0
	"\0"		// 0xd1
	"\0"		// 0xd2
	"\0"		// 0xd3
	"\0"		// 0xd4
	"\0"		// 0xd5
	"\0"		// 0xd6
	"\0"		// 0xd7
	"\0"		// 0xd8
	"\0"		// 0xd9
	"\0"		// 0xda
	"\0"		// 0xdb
	"\0"		// 0xdc
	"\0"		// 0xdd
	"\0"		// 0xde
	"\0"		// 0xdf

	"\0"		// 0xe0
	"\0"		// 0xe1
	"\0"		// 0xe2
	"\0"		// 0xe3
	"\0"		// 0xe4
	"\0"		// 0xe5
	"\0"		// 0xe6
	"\0"		// 0xe7
	"\0"		// 0xe8
	"\0"		// 0xe9
	"\0"		// 0xea
	"\0"		// 0xeb
	"\0"		// 0xec
	"\0"		// 0xed
	"\0"		// 0xee
	"\0"		// 0xef

	"\0"		// 0xf0
	"\0"		// 0xf1
	"\0"		// 0xf2
	"\0"		// 0xf3
	"\0"		// 0xf4
	"\0"		// 0xf5
	"\0"		// 0xf6
	"\0"		// 0xf7
	"\0"		// 0xf8
	"\0"		// 0xf9
	"\0"		// 0xfa
	"\0"		// 0xfb
	"\0"		// 0xfc
	"\0"		// 0xfd
	"\0"		// 0xfe
	"...\0"		// 0xff empty
};

// main function
int main(int argc, char* argv[])
{
	int i, j;
	char name[50];
	char *s, *sbeg, *send;
	const char *d, *dbeg;
	char ch, ch2, ch3;
	unsigned char b, b2;
	unsigned short sum;
	int off;

	// library name
	if (argc != 2)
	{
		printf("Syntax: Enter library name (equal to library directory: ML)\n");
		return 2;
	}

	FILE* f;
	printf("Importing %s library: ", argv[1]);
	totalN = 0;
	prognum = 0;
	sum = 0;

	for (i = 0; i < PROGNUM; i++)
	{
		// prepare file name
#ifdef __linux__
		sprintf(name, "%s/%s-%02d.T59", argv[1], argv[1], i+1);
#else
		sprintf(name, "%s\\%s-%02d.T59", argv[1], argv[1], i+1);
#endif
		// open file
		f = fopen(name, "rb");
		if (f == NULL)
		{
			if (i > 2) break;
			printf("Cannot open %s\n", name);
			return 2;
		}
		prognum++;

		// read file
		bufN = (int)fread(buf, 1, BUFMAX, f);
		fclose(f);
		buf[bufN] = 0;

		// convert to uppercase
		s = buf;
		while (*s != 0)
		{
			if ((*s >= 'a') && (*s <= 'z')) *s -= 32;
			s++;
		}

		// read program
		progN[i] = 0;
		s = buf;
		while (*s != 0)
		{
			// skip spaces and comments
			for (;;)
			{
				// skip spaces
				while ((*s > 0) && (*s <= ' ')) s++;

				// skip comment
				if (*s != ';') break;
				for (;;)
				{
					s++;
					if ((*s == 0) || (*s == 10)) break;
				}
			}
			if (*s == 0) break;

			// find end of token
			sbeg = s;
			while ((*s < 0) || (*s > ' ')) s++;
			send = s;

			// alternatives
			ch = sbeg[0];
			ch2 = sbeg[1];
			ch3 = sbeg[2];
			if ((ch == 'W') && (ch2 == 'R') && (ch3 == 'I')) sbeg[2] = 'T'; // WRI -> WRT
			if ((ch == 'G') && (ch2 == 'T') && (ch3 == '*')) sbeg[1] = 'O'; // GT* -> GO*

			// find token in table
			dbeg = SaveName;
			for (j = 0; j < 256; j++)
			{
				// compare token
				s = sbeg;
				d = dbeg;
				for (;;)
				{
					ch = *s++;
					if ((ch >= 0) && (ch <= ' ')) ch = 0;
					if (ch != *d) break;
					if (ch == 0) break;
					d++;
				}

				// save byte
				if ((ch == 0) && (*d == 0))
				{
					prog[i][progN[i]] = (unsigned char)j;
					progN[i]++;
					totalN++;
					sum += (unsigned char)j;
					break;
				}

				// skip to next token
				while (*dbeg != 0) dbeg++;
				dbeg++;
			}

			if (j == 256)
			{
				ch = sbeg[0];
				ch2 = sbeg[1];
				ch3 = sbeg[2];

				// 2 digits
				if ((sbeg+2 == send) &&
					(ch >= '0') && (ch <= '9') &&
					(((ch2 >= '0') && (ch2 <= '9')) || ((ch2 >= 'A') && (ch2 <= 'F'))))
				{
					ch -= '0';
					ch2 -= '0';
					if (ch2 > 9) ch2 -= 'A' - '9' - 1;
					b = (unsigned char)((ch << 4) | ch2);
					sum += b;
					prog[i][progN[i]] = b;
					progN[i]++;
					totalN++;

					s = send;
					continue;
				}

				// 3 digits (2 digits in HEX code)
				if ((sbeg+3 == send) &&
					(ch == '0') &&
					(((ch2 >= '0') && (ch2 <= '9')) || ((ch2 >= 'A') && (ch2 <= 'F'))) &&
					(((ch3 >= '0') && (ch3 <= '9')) || ((ch3 >= 'A') && (ch3 <= 'F'))))
				{
					ch2 -= '0';
					if (ch2 > 9) ch2 -= 'A' - '9' - 1;
					ch3 -= '0';
					if (ch3 > 9) ch3 -= 'A' - '9' - 1;
					b = (unsigned char)((ch2 << 4) | ch3);
					sum += b;
					prog[i][progN[i]] = b;
					progN[i]++;
					totalN++;

					s = send;
					continue;
				}
			}

			if (j == 256)
			{
				*send = 0;
				printf("Unknown token %s in file %s\n", sbeg, name);
				return 1;
			}

			s = send;
		}
	}

	// open output file
	sprintf(name, "%s.S", argv[1]);
	f = fopen(name, "wb");
	if (f == NULL)
	{
		printf("Cannot create %s\n", name);
		return 1;
	}

/*
Library structure:
1B page count
1B security code
2B address of first page
2B address of second page
...
2B address of last page
.. program for page one
.. program for page two
...
.. program for last page
*/

	// export number of programs
	sum += prognum;
	fprintf(f, "\t.text\n\n.global Module\nModule:\n\t.byte\t%d, 0\t\t; number of programs", prognum);

	// export offsets of pages
	j = 4 + prognum*2;
	totalN += j;
	for (i = 0; i <= prognum; i++)
	{
		b = (unsigned char)j;
		sum += b;
		b2 = (unsigned char)(j >> 8);
		sum += b2;
		if (i == prognum)
			fprintf(f, "\n\t.byte\t0x%02X, 0x%02X\t; offset of end (0x%04X = %d)", b, b2, j, j);
		else
			fprintf(f, "\n\t.byte\t0x%02X, 0x%02X\t; offset of program %d (0x%04X = %d)", b, b2, i+1, j, j);

		j += progN[i];
	}

	// export programs
	int pos;
	off = prognum*2 + 4;
	for (i = 0; i < prognum; i++)
	{
		//fwrite(&prog[i][0], 1, progN[i], f);
		fprintf(f, "\n; program %d (offset 0x%04X)", i+1, off);
		pos = 0;
		for (j = 0; j < progN[i]; j++)
		{
			if (pos == 0)
				fprintf(f, "\n\t.byte\t0x%02X", prog[i][j]);
			else
				fprintf(f, ", 0x%02X", prog[i][j]);
			pos++;
			off++;
			if (pos == 16) pos = 0;
		}
	}

	fprintf(f, "\n; end (offset 0x%04X)", off);

	// export name
	sum += (unsigned char)name[0];
	sum += (unsigned char)name[1];
	fprintf(f, "\n\t.byte\t'%c', '%c'\t; program name (offset 0x%04X)", name[0], name[1], off);
	off += 2;

	// export check sum
	fprintf(f, "\n\t.byte\t0x%02X, 0x%02X\t; checksum (offset 0x%04X)", (unsigned char)sum, (unsigned char)(sum >> 8), off);
	off += 2;

	fprintf(f, "\n\t.balign\t2\n; total size 0x%04X = %d bytes\n", off, off);

	// close file
	fclose(f);

	printf("OK, length %u, programs %u, checksum 0x%04X\n", totalN+4, prognum, sum);
	if (prognum > 99) printf("ERROR: too many programs, max. 99 allowed\n");

	return 0;
}

