// ***************************************************************************
//
//                             Main module
//
// ***************************************************************************

#include "include.h"

// error code
u8 ErrorCode = ERR_OK;

// flag - ignore errors (only store error code)
Bool ErrorOff = False;

#ifdef __linux__
REAL RealConstExpMax; // max. exp(x)  *** SIN: Duplicate definition, the same in real.c, unlinkable on Linux.
#endif

// error report (or return if ignoring errors)
// - raise exception, reinitialize stack and return to main loop
void Error(u8 code)
{
	if ((ErrorOff) && (code > ERR_LASTHARD))
	{
		ErrorCode = code;
	}
	else
	{
		printf("ERROR: %d\n", code);
//		exit(1);
	}
}

FILE* File;
const char* FileName;
int BaseType;
int MantNum;
int ExpType;
REAL Tmp;
REAL TmpMax, TmpMin;

// output one number
void Const1(REAL* num)
{
	u8* s;
	u16* w;
	u32* d;
	int i;
	u8 m;

	fprintf(File, "\t.byte\t");

	// copy into temporary
	RealCopy(&Tmp, num);

	// rounding
	s = ((u8*)&Tmp.m[R_MANT_NUM]) - BaseType*MantNum;
	if ((BaseType*MantNum < R_MANT_BYTES) && (s[-1] >= 0x80))
	{
		for (i = BaseType*MantNum; i > 0; i--)
		{
			s[0] = s[0] + 1;
			if (s[0] != 0) break;
			s++;
		}

		// we ignore overflow case FFFF -> 10000 (we do not have such case ... I hope :) )
	}

	// print exponent
	if (Tmp.exp != R_EXP_0) Tmp.exp += 0x8000;
	fprintf(File, "0x%02X,0x%02X,", ((u8*)&Tmp.exp)[1], ((u8*)&Tmp.exp)[0]);

	// print mantisa
	s = ((u8*)&Tmp.m[R_MANT_NUM]) - 1;
	for (i = MantNum; i > 1; i--)
	{
		fprintf(File, "0x%02X,", *s);
		s--;
	}
	fprintf(File, "0x%02X", *s);
}

// output one constant
void Const(REAL* num, const char* comment, Bool dispnum)
{
	double k;

	// output number
	Const1(num);

	// print comment
	if (dispnum)
	{
		RealSave(num, (MEM*)&k);
		fprintf(File, "\t; %s (%.15g)\n", comment, k);
	}
	else
		fprintf(File, "\t; %s\n", comment);
}

int main(int argc, char* argv[])
{
	int i, i2, i3, dec;
	char buf[100];
	double a1, a2;

	// get parameters
	if (argc != 2)
	{
		printf("Syntax: GenerConst filename\n");
		return 1;
	}

	FileName = argv[1];
	BaseType = 1;
	MantNum = 8;
	ExpType = 2;

	// (re)initialize calculator stack (must be called before RealInit)
	CalcInit();

	// initialize real numbers
	RealInit();

	// open output file
	File = fopen(FileName, "wb");
	if (File == NULL)
	{
		printf("Cannot create output file %s\n", FileName);
		return 2;
	}

	// ln(x) max
	RealFromText(&RealConstExpMax, "1e10000", 7);
	RealLn(&RealConstExpMax);

	// ln(x) min
	RealFromText(&RealConstExpMin, "1e-10000", 8);
	RealLn(&RealConstExpMin);

	// above 0.5
	RealCopy(&RealConstMore05, &RealConst05);
	RealConstMore05.m[R_MANT_NUM-2] = 8;

	// output head
	fprintf(File,
			"; ****************************************************************************\n"
			";\n"
			";                               Constants in ROM\n"
			";\n"
			"; ****************************************************************************\n"
			"; Do not modify - auto generated!\n"
			"\n"
			"#include \"include.inc\"\n"
			"\n"
			"\t.text\n"
			"\n"
			"; ===== Constants\n"
			"\n"
			".global ConstTab\n"
			"ConstTab:\n");

	// output pre-generated constants
	Const(&RealConst0, "[0] 0", True); // 0
	Const(&RealConst1, "[1] 1", True); // 1
	Const(&RealConstM1, "[2] -1", True); // 2
	Const(&RealConst2, "[3] 2", True); // 3
	Const(&RealConst05, "[4] 0.5", True); // 4
	Const(&RealConst075, "[5] 0.75", True); // 5
	Const(&RealConst10, "[6] 10", True); // 6
	Const(&RealConst01, "[7] 0.1", True); // 7
	Const(&RealConst100, "[8] 100", True); // 8
	Const(&RealConst001, "[9] 0.01", True); // 9
	Const(&RealConst00001, "[10] 0.0001", True); // 10
	Const(&RealConst000000001, "[11] 0.00000001", True); // 11
	Const(&RealConstLn2, "[12] ln(2)", True); // 12
	Const(&RealConstRLn2, "[13] 1/ln(2)", True); // 13
	Const(&RealConstLn10, "[14] ln(10)", True); // 14
	Const(&RealConstRLn10, "[15] 1/ln(10)", True); // 15
	Const(&RealConstLog2, "[16] log(2)", True); // 16
	Const(&RealConstRLog2, "[17] 1/log(2)", True); // 17
	Const(&RealConstExpMax, "[18] exp(x) max", True); // 18
	Const(&RealConstExpMin, "[19] exp(x) min", True); // 19
	Const(&RealConstEul, "[20] Eul", True); // 20
	Const(&RealConstPi05, "[21] PI/2", True); // 21
	Const(&RealConstPi, "[22] PI", True); // 22
	Const(&RealConstPi2, "[23] PI*2", True); // 23
	Const(&RealConstRPi2, "[24] 1/(2*PI)", True); // 24
	Const(&RealConstLnPi22, "[25] ln(PI*2)/2", True); // 25
	Const(&RealConstRadDeg, "[26] 180/PI", True); // 26
	Const(&RealConstDegRad, "[27] PI/180", True); // 27
	Const(&RealConstRadGrad, "[28] 200/PI", True); // 28
	Const(&RealConstGradRad, "[29] PI/200", True); // 29
	Const(&RealConstFi, "[30] fi (sectio aurea) = (1 + sqrt(5))/2", True); // 30
	Const(&RealConstMore05, "[31] little above 0.5", True); // 31

	fprintf(File, "\n\t.balign 2\n");

	// output exponent table
	fprintf(File,"\n.global ExpTab\nExpTab:\n");
	i2 = -8192;
	for (i = 16; i < 45; i++)
	{
		if (i == 30)
		{
			Const(&RealDecExp[i], "[14] 1", True);
			i2 = -i2;
		}
		else
		{
			if (i2 == 0) i2 = 1;

			sprintf(buf, "[%d] 1e%d", i-16, i2);
			Const(&RealDecExp[i], buf, ((i > 20) && (i < 40)));

			if (i < 30)
				i2 /= 2;
			else
				i2 *= 2;
		}
	}
	fprintf(File, "\n\t.balign 2\n");

	// output rounding table
	fprintf(File,"\n.global RoundTab\nRoundTab:\n");
	for (i = 0; i < 21; i++)
	{
		sprintf(buf, "[%d] 5e%d", i, -i-1);
		Const(&RealConstRound[i], buf, True);
	}
	fprintf(File, "\n\t.balign 2\n");

	// factorial coefficients
	fprintf(File,"\n.global FactATab\nFactATab:\n");
	for (i = 0; i < FACT_COEFF; i++)
	{
		RealSave(&RealConstFactA1[i], (MEM*)&a1);
		RealSave(&RealConstFactA2[i], (MEM*)&a2);
		sprintf(buf, "[%d] %g/%g", i, a1, a2);
		Const(&RealConstFactA[i], buf, True);
	}
	fprintf(File, "\n\t.balign 2\n");

	// close output file
	fclose(File);

	printf("\n");

	return 0;
}

