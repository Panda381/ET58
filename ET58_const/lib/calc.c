// ***************************************************************************
//
//                      Expression Calculator
//
// ***************************************************************************

#include "include.h"

// calculator stack
REAL	CalcStack[CALCMAX];	// calculator stack
int		CalcNum = 0;		// number of entries in calculator stack

// (re)initialize calculator stack
void CalcInit()
{
	CalcNum = 0;
}

// get top entry in calculator stack
REAL* CalcTop()
{
	return &CalcStack[CalcNum-1];
}

// get pre-last number in calculator stack
REAL* CalcPreTop()
{
	return &CalcStack[CalcNum-2];
}

// create new number on top of calculator stack
REAL* CalcNew()
{
	REAL* r;

	// check stack overflow
	if (CalcNum >= CALCMAX) Error(ERR_CALCSTACKOVER);

	// create new entry
	r = &CalcStack[CalcNum];
	CalcNum++;

	return r;
}

// swap two number on top of calculator stack
void CalcSwap()
{
	RealExch(CalcTop(), CalcPreTop());
}

// delete number from top of the stack
void CalcDel()
{
	// check stack
	if (CalcNum == 0) Error(ERR_INTERNAL);
	CalcNum--;
}

// delete more numbers from top of the stack
void CalcDelN(int n)
{
	// check stack
	if (CalcNum < n) Error(ERR_INTERNAL);
	CalcNum -= n;
}

// duplicate number on top of stack
void CalcDup()
{
	REAL *n1, *n2;
	n1 = CalcTop();
	n2 = CalcNew();
	RealCopy(n2, n1);
}

// check if number on top of stack is zero (exponent = 0)
Bool CalcIsZero()
{
	return RealIsZero(CalcTop());
}

// check if number on top of stack is negative
Bool CalcIsNeg()
{
	return RealIsNeg(CalcTop());
}

// check if number on top of stack is positive (but not zero)
Bool CalcIsPos()
{
	return RealIsPos(CalcTop());
}

// set sign of number on top of stack (True = negative)
void CalcSetSign(Bool sign)
{
	RealSetSign(CalcTop(), sign);
}

// negate - flip sign of number on top of stack (except zero)
void CalcNeg()
{
	RealNeg(CalcTop());
}

// absolute value - clear negative flag
void CalcAbs()
{
	RealAbs(CalcTop());
}

// set negative flag (only if not 0)
void CalcSetNeg()
{
	RealSetNeg(CalcTop());
}

// add number 0 to top of stack
void CalcNew0()
{
	REAL* n = CalcNew();
	RealSet0(n);
}

// add number 1 to top of stack
void CalcNew1()
{
	REAL* n = CalcNew();
	RealSet1(n);
}

// add number -1 to top of stack
void CalcNewM1()
{
	REAL* n = CalcNew();
	RealSetM1(n);
}

// add number 2 to top of stack
void CalcNew2()
{
	REAL* n = CalcNew();
	RealSet2(n);
}

// add number 0.5 to top of stack
void CalcNew05()
{
	REAL* n = CalcNew();
	RealSet05(n);
}

// add constant Pi
void CalcNewPi()
{
	REAL* n = CalcNew();
	RealSetPi(n);
}

// add constant Pi*2
void CalcNewPi2()
{
	REAL* n = CalcNew();
	RealSetPi2(n);
}

// add constant Pi/2
void CalcNewPi05()
{
	REAL* n = CalcNew();
	RealSetPi05(n);
}

// add constant Eul
void CalcNewEul()
{
	REAL* n = CalcNew();
	RealSetEul(n);
}

// add constant ln(2)
void CalcNewLn2()
{
	REAL* n = CalcNew();
	RealSetLn2(n);
}

// add constant ln(10)
void CalcNewLn10()
{
	REAL* n = CalcNew();
	RealSetLn10(n);
}

// add constant log(2)
void CalcNewLog2()
{
	REAL* n = CalcNew();
	RealSetLog2(n);
}

// add number 10 to top of stack
void CalcNew10()
{
	REAL* n = CalcNew();
	RealSet10(n);
}

// add number 0.1 to top of stack
void CalcNew01()
{
	REAL* n = CalcNew();
	RealSet01(n);
}

// add unsigned integer value
void CalcNewUInt(r_base val)
{
	REAL* n = CalcNew();
	RealSetUInt(n, val);
}

void CalcNewU8(u8 val)
{
	REAL* n = CalcNew();
	RealSetU8(n, val);
}

void CalcNewU16(u16 val)
{
	REAL* n = CalcNew();
	RealSetU16(n, val);
}

void CalcNewU32(u32 val)
{
	REAL* n = CalcNew();
	RealSetU32(n, val);
}

// add signed integer value
void CalcNewInt(r_bases val)
{
	REAL* n = CalcNew();
	RealSetInt(n, val);
}

void CalcNewS8(s8 val)
{
	REAL* n = CalcNew();
	RealSetS8(n, val);
}

void CalcNewS16(s16 val)
{
	REAL* n = CalcNew();
	RealSetS16(n, val);
}

void CalcNewS32(s32 val)
{
	REAL* n = CalcNew();
	RealSetS32(n, val);
}

// add minimal positive number
void CalcNewMin()
{
	REAL* n = CalcNew();
	RealSetMin(n);
}

// add maximal positive number
void CalcNewMax()
{
	REAL* n = CalcNew();
	RealSetMax(n);
}

// get unsigned integer value from top of stack, deletes number (rounded towards zero)
r_base CalcGetUInt()
{
	r_base n = RealGetUInt(CalcTop());
	CalcDel();
	return n;
}

u8 CalcGetU8()
{
	u8 n = RealGetU8(CalcTop());
	CalcDel();
	return n;
}

u16 CalcGetU16()
{
	u16 n = RealGetU16(CalcTop());
	CalcDel();
	return n;
}

u32 CalcGetU32()
{
	u32 n = RealGetU32(CalcTop());
	CalcDel();
	return n;
}

// get signed integer value from top of stack, deletes number (rounded towards zero)
r_bases CalcGetInt()
{
	r_bases n = RealGetInt(CalcTop());
	CalcDel();
	return n;
}

s8 CalcGetS8()
{
	s8 n = RealGetS8(CalcTop());
	CalcDel();
	return n;
}

s16 CalcGetS16()
{
	s16 n = RealGetS16(CalcTop());
	CalcDel();
	return n;
}

s32 CalcGetS32()
{
	s32 n = RealGetS32(CalcTop());
	CalcDel();
	return n;
}

// Signum - set number to 0, 1 or -1, by sign
void CalcSign()
{
	RealSign(CalcTop());
}

// multiply 2 numbers on top of calculator stack (deletes 2nd number)
void CalcMul()
{
	REAL *n1, *n2;

	// pointers to 2 last numbers
	n1 = CalcPreTop();
	n2 = CalcTop();

	// multiply
	RealMul(n1, n1, n2);

	// delete 2nd number
	CalcDel();
}

// square (power of 2)
void CalcSqr()
{
	REAL *n;

	// pointer to last number
	n = CalcTop();

	// multiply
	RealMul(n, n, n);
}

// divide 2 numbers on top of calculator stack (deletes 2nd number)
void CalcDiv()
{
	REAL *n1, *n2;

	// pointers to 2 last numbers
	n1 = CalcPreTop();
	n2 = CalcTop();

	// divide
	RealDiv(n1, n1, n2);

	// delete 2nd number
	CalcDel();
}

// reversed divide 2 numbers on top of calculator stack (deletes 2nd number)
void CalcInvDiv()
{
	REAL *n1, *n2;

	// pointers to 2 last numbers
	n1 = CalcPreTop();
	n2 = CalcTop();

	// divide
	RealDiv(n1, n2, n1);

	// delete 2nd number
	CalcDel();
}

// reciprocal value 1/x
void CalcRec()
{
	RealRec(CalcTop());
}

// modulus 2 numbers on top of calculator stack (deletes 2nd number)
void CalcMod()
{
	REAL *n1, *n2;

	// pointers to 2 last numbers
	n1 = CalcPreTop();
	n2 = CalcTop();

	// divide
	RealMod(n1, n1, n2);

	// delete 2nd number
	CalcDel();
}

// reversed modulus 2 numbers on top of calculator stack (deletes 2nd number)
void CalcInvMod()
{
	REAL *n1, *n2;

	// pointers to 2 last numbers
	n1 = CalcPreTop();
	n2 = CalcTop();

	// divide
	RealMod(n1, n2, n1);

	// delete 2nd number
	CalcDel();
}

// multiply by 2 (increases exponent by 1)
void CalcMul2()
{
	RealMul2(CalcTop());
}

// divide by 2 (decreases exponent by 1)
void CalcDiv2()
{
	RealDiv2(CalcTop());
}

// add 2 numbers on top of calculator stack (deletes 2nd number)
void CalcAdd()
{
	REAL *n1, *n2;

	// pointers to 2 last numbers
	n1 = CalcPreTop();
	n2 = CalcTop();

	// addition
	RealAdd(n1, n1, n2);

	// delete 2nd number
	CalcDel();
}

// subtract 2 numbers on top of calculator stack (deletes 2nd number)
void CalcSub()
{
	REAL *n1, *n2;

	// pointers to 2 last numbers
	n1 = CalcPreTop();
	n2 = CalcTop();

	// negate 2nd number
	RealNeg(n2);

	// addition
	RealAdd(n1, n1, n2);

	// delete 2nd number
	CalcDel();
}

// reversed subtract 2 numbers on top of calculator stack (deletes 2nd number)
void CalcInvSub()
{
	REAL *n1, *n2;

	// pointers to 2 last numbers
	n1 = CalcPreTop();
	n2 = CalcTop();

	// negate 1st number
	RealNeg(n1);

	// addition
	RealAdd(n1, n1, n2);

	// delete 2nd number
	CalcDel();
}

// increase number by 1
void CalcInc()
{
	RealInc(CalcTop());
}

// decrease number by 1
void CalcDec()
{
	RealDec(CalcTop());
}

// power of 2 numbers (y = base^exp) (deletes 2nd number)
void CalcPow()
{
	REAL *n1, *n2;

	// pointers to 2 last numbers
	n1 = CalcPreTop();
	n2 = CalcTop();

	// power
	RealPow(n1, n1, n2);

	// delete 2nd number
	CalcDel();
}

// reversed power of 2 numbers (y = base^exp) (deletes 2nd number)
void CalcInvPow()
{
	REAL *n1, *n2;

	// pointers to 2 last numbers
	n1 = CalcPreTop();
	n2 = CalcTop();

	// power
	RealPow(n1, n2, n1);

	// delete 2nd number
	CalcDel();
}

// compare 2 numbers (returns COMP_LESS=-1, COMP_EQU=0 or COMP_GREATER=1) (deletes 2nd number)
void CalcComp()
{
	s8 res = RealComp(CalcPreTop(), CalcTop());
	CalcDel();
	RealSetS8(CalcTop(), res);
}

// compare 2 absolute values of numbers, without sign (returns COMP_LESS=-1, COMP_EQU=0 or COMP_GREATER=1) (deletes 2nd number)
void CalcCompAbs()
{
	s8 res = RealCompAbs(CalcPreTop(), CalcTop());
	CalcDel();
	RealSetS8(CalcTop(), res);
}

// compare number to zero (returns COMP_LESS=-1, COMP_EQU=0 or COMP_GREATER=1)
void CalcComp0()
{
	s8 res = RealComp0(CalcTop());
	RealSetS8(CalcTop(), res);
}

// truncation towards zero
void CalcTrunc()
{
	RealTrunc(CalcTop());
}

// fractional part
void CalcFrac()
{
	RealFrac(CalcTop());
}

// round down (integer)
void CalcFloor()
{
	RealFloor(CalcTop());
}

// round up
void CalcCeil()
{
	RealCeil(CalcTop());
}

// round number to nearest integer
void CalcRound()
{
	RealRound(CalcTop());
}

// convert number to text buffer for calculator (minimal size of buffer must be RealFlagDisp) (deletes number)
// - setup function by parameters RealFlagDisp...
// - always saves sign '+', '-' or ' '
// - number is aligned to the right
// - decimal point is not encoded as character, but it is added to the digit as bit 7
// - if decimal point is on 1st position, zero will be substituted by the sign character (another digit cannot occur there)
void CalcToText(char* buf)
{
	RealToText(CalcTop(), buf);
	CalcTop();
}

// add number and load number from text (returns remaining unused characters; decimal point may be marked as bit 7 of the digit)
int CalcNewFromText(const char* buf, int len)
{
	REAL* n = CalcNew();
	return RealFromText(n, buf, len);
}

// convert angles DEG/RAD/GRAD
void CalcDegRad() // deg->rad
{
	RealDegRad(CalcTop());
}

void CalcRadDeg() // rad-->deg
{
	RealRadDeg(CalcTop());
}

void CalcDegGrad() // deg->grad
{
	RealDegGrad(CalcTop());
}

void CalcGradDeg() // grad->deg
{
	RealGradDeg(CalcTop());
}

void CalcGradRad() // grad->rad
{
	RealGradRad(CalcTop());
}

void CalcRadGrad() // rad->grad
{
	RealRadGrad(CalcTop());
}

// normalize angle in radians into range 0..PI*2 (= 0..360)
void CalcNormRad()
{
	RealNormRad(CalcTop());
}

// sine
void CalcSin()
{
	RealSin(CalcTop());
}

// cosine
void CalcCos()
{
	RealCos(CalcTop());
}

// tangent
void CalcTan()
{
	RealTan(CalcTop());
}

// cotangent
void CalcCoTan()
{
	RealCoTan(CalcTop());
}

// arcus sine
// result is in range -PI/2..+PI/2
void CalcASin()
{
	RealASin(CalcTop());
}

// arcus cosine
// result is in range -PI/2..+PI/2
void CalcACos()
{
	RealACos(CalcTop());
}

// arcus tangent
void CalcATan()
{
	RealATan(CalcTop());
}

// arcus cotangent
void CalcACoTan()
{
	RealACoTan(CalcTop());
}

// hyperbolic sine
void CalcSinH()
{
	RealSinH(CalcTop());
}

// hyperbolic cosine
void CalcCosH()
{
	RealCosH(CalcTop());
}

// hyperbolic tangent
void CalcTanH()
{
	RealTanH(CalcTop());
}

// hyperbolic cotangent
void CalcCoTanH()
{
	RealCoTanH(CalcTop());
}

// hyperbolic secant
void CalcSecH()
{
	RealSecH(CalcTop());
}

// hyperbolic cosecant
void CalcCscH()
{
	RealCscH(CalcTop());
}

// areasine, inverse hyperbolic sine
void CalcArSinH()
{
	RealArSinH(CalcTop());
}

// areacosine, inverse hyperbolic cosine
void CalcArCosH()
{
	RealArCosH(CalcTop());
}

// areatangent, inverse hyperbolic tangent
void CalcArTanH()
{
	RealArTanH(CalcTop());
}

// areacotangent, inverse hyperbolic cotangent
void CalcArCoTan()
{
	RealArCoTan(CalcTop());
}

// areasecant, inverse hyperbolic secant
void CalcArSecH()
{
	RealArSecH(CalcTop());
}

// areacosecant, inverse hyperbolic cosecant
void CalcArCscH()
{
	RealArCscH(CalcTop());
}

// natural logarithm
void CalcLn()
{
	RealLn(CalcTop());
}

// natural exponent
void CalcExp()
{
	RealExp(CalcTop());
}

// sqrt
void CalcSqrt()
{
	RealSqrt(CalcTop());
}
