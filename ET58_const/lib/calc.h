// ***************************************************************************
//
//                      Expression Calculator
//
// ***************************************************************************

// calculator stack
extern REAL	CalcStack[CALCMAX];	// calculator stack
extern int	CalcNum;		// number of entries in calculator stack

// (re)initialize calculator stack
void CalcInit();

// get top entry in calculator stack
REAL* CalcTop();

// get pre-last number in calculator stack
REAL* CalcPreTop();

// create new number on top of calculator stack
REAL* CalcNew();

// swap two numbers on top of calculator stack
void CalcSwap();

// delete number from top of the stack
void CalcDel();

// delete more numbers from top of the stack
void CalcDelN(int n);

// duplicate number on top of stack
void CalcDup();

// check if number on top of stack is zero (exponent = 0)
Bool CalcIsZero();

// check if number on top of stack is negative
Bool CalcIsNeg();

// check if number on top of stack is positive (but not zero)
Bool CalcIsPos();

// set sign of number on top of stack (True = negative)
void CalcSetSign(Bool sign);

// negate - flip sign of number on top of stack (except zero)
void CalcNeg();

// absolute value - clear negative flag
void CalcAbs();

// set negative flag (only if not 0)
void CalcSetNeg();

// add number 0 to top of stack
void CalcNew0();

// add number 1 to top of stack
void CalcNew1();

// add number -1 to top of stack
void CalcNewM1();

// add number 2 to top of stack
void CalcNew2();

// add number 0.5 to top of stack
void CalcNew05();

// add constant Pi
void CalcNewPi();

// add constant Pi*2
void CalcNewPi2();

// add constant Pi/2
void CalcNewPi05();

// add constant Eul
void CalcNewEul();

// add constant ln(2)
void CalcNewLn2();

// add constant ln(10)
void CalcNewLn10();

// add constant log(2)
void CalcNewLog2();

// add constant 10
void CalcNew10();

// add constant 0.1
void CalcNew01();

// add unsigned integer value
void CalcNewUInt(r_base val);
void CalcNewU8(u8 val);
void CalcNewU16(u16 val);
void CalcNewU32(u32 val);

// add signed integer value
void CalcNewInt(r_bases val);
void CalcNewS8(s8 val);
void CalcNewS16(s16 val);
void CalcNewS32(s32 val);

// add minimal positive number
void CalcNewMin();

// add maximal positive number
void CalcNewMax();

// get unsigned integer value from top of stack, deletes number (rounded towards zero)
r_base CalcGetUInt();
u8 CalcGetU8();
u16 CalcGetU16();
u32 CalcGetU32();

// get signed integer value from top of stack, deletes number (rounded towards zero)
r_bases CalcGetInt();
s8 CalcGetS8();
s16 CalcGetS16();
s32 CalcGetS32();

// Signum - set number to 0, 1 or -1, by sign
void CalcSign();

// multiply 2 numbers on top of calculator stack (deletes 2nd number)
void CalcMul();

// square (power of 2)
void CalcSqr();

// divide 2 numbers on top of calculator stack (deletes 2nd number)
void CalcDiv();

// reversed divide 2 numbers on top of calculator stack (deletes 2nd number)
void CalcInvDiv();

// reciprocal value 1/x
void CalcRec();

// modulus 2 numbers on top of calculator stack (deletes 2nd number)
void CalcMod();

// reversed modulus 2 numbers on top of calculator stack (deletes 2nd number)
void CalcInvMod();

// multiply by 2 (increases exponent by 1)
void CalcMul2();

// divide by 2 (decreases exponent by 1)
void CalcDiv2();

// add 2 numbers on top of calculator stack (deletes 2nd number)
void CalcAdd();

// subtract 2 numbers on top of calculator stack (deletes 2nd number)
void CalcSub();

// reversed subtract 2 numbers on top of calculator stack (deletes 2nd number)
void CalcInvSub();

// increase number by 1
void CalcInc();

// decrease number by 1
void CalcDec();

// power of 2 numbers (y = base^exp) (deletes 2nd number)
void CalcPow();

// reversed power of 2 numbers (y = base^exp) (deletes 2nd number)
void CalcInvPow();

// compare 2 numbers (returns COMP_LESS=-1, COMP_EQU=0 or COMP_GREATER=1) (deletes 2nd number)
void CalcComp();

// compare 2 absolute values of numbers, without sign (returns COMP_LESS=-1, COMP_EQU=0 or COMP_GREATER=1) (deletes 2nd number)
void CalcCompAbs();

// compare number to zero (returns COMP_LESS=-1, COMP_EQU=0 or COMP_GREATER=1)
void CalcComp0();

// truncation towards zero
void CalcTrunc();

// fractional part
void CalcFrac();

// round down (integer)
void CalcFloor();

// round up
void CalcCeil();

// round number to nearest integer
void CalcRound();

// convert number to text buffer for calculator (minimal size of buffer must be RealFlagDisp) (deletes number)
// - setup function by parameters RealFlagDisp...
// - always saves sign '+', '-' or ' '
// - number is aligned to the right
// - decimal point is not encoded as character, but it is added to the digit as bit 7
// - if decimal point is on 1st position, zero will be substituted by the sign character (another digit cannot occur there)
void CalcToText(char* buf);

// add number and load number from text (returns remaining unused characters; decimal point may be marked as bit 7 of the digit)
int CalcNewFromText(const char* buf, int len);

// convert angles DEG/RAD/GRAD
void CalcDegRad(); // deg->rad
void CalcRadDeg(); // rad-->deg
void CalcDegGrad(); // deg->grad
void CalcGradDeg(); // grad->deg
void CalcGradRad(); // grad->rad
void CalcRadGrad(); // rad->grad

// normalize angle in radians into range 0..PI*2 (= 0..360)
void CalcNormRad();

// sine
void CalcSin();

// cosine
void CalcCos();

// tangent
void CalcTan();

// cotangent
void CalcCoTan();

// arcus sine
// result is in range -PI/2..+PI/2
void CalcASin();

// arcus cosine
// result is in range 0..PI
void CalcACos();

// arcus tangent
// result is in range -PI/2..+PI/2
void CalcATan();

// arcus cotangent
// result is in range -PI/2..+PI/2
void CalcACoTan();

// hyperbolic sine
void CalcSinH();

// hyperbolic cosine
void CalcCosH();

// hyperbolic tangent
void CalcTanH();

// hyperbolic cotangent
void CalcCoTanH();

// hyperbolic secant
void CalcSecH();

// hyperbolic cosecant
void CalcCscH();

// areasine, inverse hyperbolic sine
void CalcArSinH();

// areacosine, inverse hyperbolic cosine
void CalcArCosH();

// areatangent, inverse hyperbolic tangent
void CalcArTanH();

// areacotangent, inverse hyperbolic cotangent
void CalcArCoTan();

// areasecant, inverse hyperbolic secant
void CalcArSecH();

// areacosecant, inverse hyperbolic cosecant
void CalcArCscH();

// natural logarithm
void CalcLn();

// natural exponent
void CalcExp();

// decimal logarithm
void CalcLog10();

// decimal exponent
void CalcExp10();

// binary logarithm
void CalcLog2();

// binary exponent
void CalcExp2();

// sqrt
void CalcSqrt();
