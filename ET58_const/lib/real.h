// ***************************************************************************
//
//                       Floating point numbers
//
// ***************************************************************************

/* External configuration:

// internal calculator numbers
#define R_BASE_TYPE	2		// size of 1 mantissa segment (1 = byte u8, 2 = word u16, 4 = dword u32)
#define R_MANT_NUM	4		// number of mantissa segments
#define R_EXP_TYPE	2		// type of exponent (1 = byte u8, 2 = word u16, 4 = dword u32)

// memory numbers
#define M_BYTES		8		// total number of bytes of memory number
#define M_EXP_BITS	11		// number of bits per exponent

*/

// ===========================================================================
//                     Floating point configuration
// ===========================================================================

// precision calculation: 0.30103000 digits per bit
#ifndef LOG2
#define LOG2 0.30102999566398	// log10(2)
#endif

// type of mantissa segment
#if R_BASE_TYPE == 1
typedef u8 r_base;			// type of base segment unsigned
typedef s8 r_bases;			// type of base segment signed
typedef u8 r_half;			// type of half segment unsigned
typedef u16 r_dbl;			// type of double segment unsigned

#elif R_BASE_TYPE == 2
typedef u16 r_base;			// type of base segment unsigned
typedef s16 r_bases;		// type of base segment signed
typedef u8 r_half;			// type of half segment unsigned
typedef u32 r_dbl;			// type of double segment unsigned

#elif R_BASE_TYPE == 4
typedef u32 r_base;			// type of base segment unsigned
typedef s32 r_bases;		// type of base segment signed
typedef u16 r_half;			// type of half segment unsigned
typedef u64 r_dbl;			// type of double segment unsigned

#else
#error R_BASE_TYPE not valid
#endif

// type of exponent
#if R_EXP_TYPE == 1 // (decimal max. 38.53)
typedef u8 r_expu;			// type of exponent unsigned
typedef s8 r_exps;			// type of exponent signed
typedef u16 r_dblexpu;		// type of double exponent unsigned
typedef s16 r_dblexps;		// type of double exponent signed
#define R_DECEXP	6		// number of square decimal exponents: 1, 2, 4, 8, 16, 32

#elif R_EXP_TYPE == 2 // (decimal max. 9863,85)
typedef u16 r_expu;			// type of exponent unsigned
typedef s16 r_exps;			// type of exponent signed
typedef u32 r_dblexpu;		// type of double exponent unsigned
typedef s32 r_dblexps;		// type of double exponent signed
#define R_DECEXP	14		// number of square decimal exponents: 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192

#elif R_EXP_TYPE == 4 // (decimal max. 646456992,94)
typedef u32 r_expu;			// type of exponent unsigned
typedef s32 r_exps;			// type of exponent signed
typedef u32 r_dblexpu;		// type of double exponent unsigned
typedef s32 r_dblexps;		// type of double exponent signed
#define R_DECEXP	30		// number of square decimal exponents: 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, 33554432, 67108864, 134217728, 268435456, 536870912

#else
#error R_EXP_TYPE not valid
#endif

// base segment
#define R_BASE_BYTES R_BASE_TYPE	// size of base segment in number of bytes
#define R_BASE_BITS	(R_BASE_BYTES*8) // size of base segment in number of bits
#define R_BASE_LAST	((r_base)1 << (R_BASE_BITS-1)) // highest bit of base segment (= bit with sign)
#define R_BASE_MASK	((r_base)-1)	// mask of base segments (all bits are '1')
#define R_HALF_BITS	(R_BASE_BITS/2) // size of half segment in number of bits
#define R_HALF_MASK (((r_base)1 << R_HALF_BITS)-1) // mask of half segment
#define R_BASES_MAX	((r_bases)(R_BASE_MASK>>1)) // max value of signed segment (positive)
#define R_BASES_MIN	((r_bases)R_BASE_LAST) // min value of signed segment (negative)

// mantissa
#define R_MANT_BYTES (R_MANT_NUM*R_BASE_BYTES) // size of mantissa in bytes
#define R_MANT_BITS	(R_MANT_BYTES*8)	// size of mantissa in bits
#define R_MANT_DIG	((R_MANT_BITS+1)*30103UL/100000) // max. number of digits per mantissa (= precision)
#define R_MANT_DIG_D ((R_MANT_BITS+1)*LOG2)		// max. number of digits per mantissa as double (= precision)

// exponent
#define R_EXP_BYTES	R_EXP_TYPE		// size of exponent in bytes
#define R_EXP_BITS	(R_EXP_BYTES*8)	// size of exponent in bits
#define R_EXP_0		(r_exps)((r_expu)1 << (R_EXP_BITS-1)) // exponent flag - number is zero
#define R_EXP_MAX	(r_exps)(((r_expu)-1) >> 1) // maximal valid exponent
#define R_EXP_MIN	(r_exps)(-R_EXP_MAX) // minimal valid exponent
#define R_EXP_DIG	((R_EXP_BITS*30103UL+99999)/100000-1) // max. number of digits per exponent
#define R_EXP_MAX_D	(R_EXP_MAX*LOG2)	// max. value of decimal exponent as double

// total number
#define R_BYTES		(R_MANT_BYTES+R_EXP_BYTES) // total size in bytes
#define R_BITS		(R_BYTES*8)		// total size in bits
#define R_DIG		(R_MANT_DIG + R_EXP_DIG + 4) // total max. number of digits, incl. -.e-
#define R_BUFSIZE	(R_DIG+2)					// required buffer size

// misc. setup
#define R_TRIM		(R_MANT_BITS/16)			// trim - delete very small result of substraction

// memory number
//#define M_BYTES		8		// total number of bytes of memory number
//#define M_EXP_BITS	11		// number of bits per exponent
#define M_BITS		(M_BYTES*8)			// total number of bits

#define M_MANT_BITS	(M_BITS-M_EXP_BITS-1) // number of bits of mantissa
#define M_MANT_BYTES ((M_MANT_BITS + 7)/8) // number of bytes of mantissa, rounded up
#define M_MANT_OFF	(M_MANT_BITS - M_MANT_BITS/8*8) // bits in last byte of mantissa
#define M_MANT_MASK (u8)((1UL << M_MANT_OFF) - 1) // mask of bits in last byte of mantissa
#if M_MANT_OFF == 0
#undef M_MANT_OFF
#undef M_MANT_MASK
#define M_MANT_OFF 8
#define M_MANT_MASK 0xff
#endif

#define M_EXP_MAX	((1UL << M_EXP_BITS)-1) // max. exponent
#define M_EXP_BIAS	(M_EXP_MAX >> 1) // exponent bias
#define M_EXP_MIN	1UL				// exponent minimal value
#define M_EXP_0		0UL				// zero number
#define M_EXP_MASK	M_EXP_MAX		// exponent mask
#define M_EXP_INX	(M_BYTES - 4) // index of exponent
#define M_EXP_OFF	(M_MANT_BITS - (M_BITS-32)) // shift of exponent

// ===========================================================================
//                     Floating point number structure
// ===========================================================================

// float number - internal calculator format
typedef struct {
	r_base	m[R_MANT_NUM];	// mantissa (last highest bit is sign)
	r_exps	exp;			// exponent (signed, R_EXP_0 = number is zero)
} REAL;

// float number - memory
typedef struct {
	u8		m[M_BYTES]; // mantissa, exponent (biased) and sign
} MEM;

// initialize real numbers
void RealInit();

// ===========================================================================
//                                  Functions
// ===========================================================================

// ===== internal functions

// multiply 2 segments of mantissa with double result (rH:rL = a * b)
void RealMulInt(r_base* rL, r_base* rH, r_base a, r_base b);

// increment denormalised mantissa, returns carry bit (exponent not changed)
u8 RealMantInc(REAL* num);

// negate denormalised mantissa (returns carry)
u8 RealMantNeg(REAL* num);

// shift denormalized mantissa left to higher bits (returns highest carry bit)
u8 RealShiftL(REAL* num, u8 carry);

// shift denormalized mantissa right to lower bits (returns lowest carry bit)
u8 RealShiftR(REAL* num, u8 carry);

// denormalize number - set hidden bit
void RealDenorm(REAL* num);

// ===== public functions

// --- flags and base manilupations

// check if number is zero
Bool RealIsZero(const REAL* num);

// check if number is negative
Bool RealIsNeg(const REAL* num);

// check if number is positive (but not zero)
Bool RealIsPos(const REAL* num);

// set sign (True = negative)
void RealSetSign(REAL* num, Bool sign);

// negate - flip sign (except zero)
void RealNeg(REAL* num);

// absolute value - clear negative flag
void RealAbs(REAL* num);

// set negative flag (only if not 0)
void RealSetNeg(REAL* num);

// Signum - set number to 0, 1 or -1, by sign
void RealSign(REAL* num);

// --- set/get number

// clear number
void RealSet0(REAL* num);

// set value 1
void RealSet1(REAL* num);

// set value -1
void RealSetM1(REAL* num);

// set value 2
void RealSet2(REAL* num);

// set value 0.5
void RealSet05(REAL* num);

// set constant Pi
void RealSetPi(REAL* num);

// set constant Pi*2
void RealSetPi2(REAL* num);

// set constant Pi/2
void RealSetPi05(REAL* num);

// set constant Eul
void RealSetEul(REAL* num);

// set constant ln(2)
void RealSetLn2(REAL* num);

// set constant ln(10)
void RealSetLn10(REAL* num);

// set constant log(2)
void RealSetLog2(REAL* num);

// set constant 10
void RealSet10(REAL* num);

// set constant 0.1
void RealSet01(REAL* num);

// set unsigned integer value
void RealSetUInt(REAL* num, r_base n);
void RealSetU8(REAL* num, u8 n);
void RealSetU16(REAL* num, u16 n);
void RealSetU32(REAL* num, u32 n);

// set signed integer value
void RealSetInt(REAL* num, r_bases n);
void RealSetS8(REAL* num, s8 n);
void RealSetS16(REAL* num, s16 n);
void RealSetS32(REAL* num, s32 n);

// get unsigned integer value (rounded towards zero)
r_base RealGetUInt(const REAL* num);
u8 RealGetU8(const REAL* num);
u16 RealGetU16(const REAL* num);
u32 RealGetU32(const REAL* num);

// get signed integer value (rounded towards zero)
// - source number can be temporary modified (and then restored back)
r_bases RealGetInt(REAL* num);
s8 RealGetS8(REAL* num);
s16 RealGetS16(REAL* num);
s32 RealGetS32(REAL* num);

// set minimal positive number
void RealSetMin(REAL* num);

// set maximal positive number
void RealSetMax(REAL* num);

// copy number
void RealCopy(REAL* dst, const REAL* src);

// exchange numbers
void RealExch(REAL* num1, REAL* num2);

// export into memory number
void RealSave(REAL* num, MEM* mem);

// import from memory number
void RealLoad(REAL* num, MEM* mem);

// --- arithmetic operations

// multiply 2 numbers (source and destination can be the same)
// - source numbers can be temporary modified (and then restored back)
void RealMul(REAL* dst, REAL* src1, REAL* src2);

// square x^2
void RealSqr(REAL* num);

// divide 2 numbers (source and destination can be the same)
// dst = result quotient, src1 = dividend, src2 = divisor
// - source number src2 can be temporary modified (and then restored back)
void RealDiv(REAL* dst, const REAL* src1, REAL* src2);

// reciprocal value 1/x
void RealRec(REAL* num);

// modulus (source and destination can be the same)
// dst = result quotient, src1 = dividend, src2 = divisor
// - source number src2 can be temporary modified (and then restored back)
void RealMod(REAL* dst, const REAL* src1, REAL* src2);

// multiply by 2 (increases exponent by 1)
void RealMul2(REAL* num);

// divide by 2 (decreases exponent by 1)
void RealDiv2(REAL* num);

// add 2 numbers (source and destination can be the same)
void RealAdd(REAL* dst, const REAL* src1, const REAL* src2);

// subtract 2 numbers (source and destination can be the same)
// - source number src2 can be temporary modified (and then restored back)
void RealSub(REAL* dst, const REAL* src1, REAL* src2);

// increase number by 1
void RealInc(REAL* num);

// decrease number by 1
void RealDec(REAL* num);

// multiply 2 numbers (source and destination can be the same)
// - source numbers can be temporary modified (and then restored back)
void RealMul(REAL* dst, REAL* src1, REAL* src2);

// power of 2 numbers (y = base^exp)
// - exp can be temporary modified (and then restored back)
void RealPow(REAL* dst, const REAL* base, REAL* exp);

// compare 2 numbers (returns COMP_LESS=-1, COMP_EQU=0 or COMP_GREATER=1)
int RealComp(const REAL* num1, const REAL* num2);

// compare 2 absolute values of numbers, without sign (returns COMP_LESS=-1, COMP_EQU=0 or COMP_GREATER=1)
int RealCompAbs(const REAL* num1, const REAL* num2);

// compare number to zero (returns COMP_LESS=-1, COMP_EQU=0 or COMP_GREATER=1)
int RealComp0(const REAL* num);

// truncation towards zero (= "integer" function)
void RealTrunc(REAL* num);

// fractional part
void RealFrac(REAL* num);

// round down (integer)
void RealFloor(REAL* num);

// round up
void RealCeil(REAL* num);

// round number to nearest integer
void RealRound(REAL* num);

// convert number to text buffer for calculator (minimal size of buffer must be RealFlagDisp)
// (TI-58 has display 12 digits: "-3.1415927+00", "-3.141592654 " .3141592654 ")
// - setup function by parameters RealFlagDisp...
// - always saves sign '+', '-' or ' '
// - number is aligned to the right
// - decimal point is not encoded as character, but it is added to the digit as bit 7
// - if decimal point is on 1st position, zero will be substituted by the sign character (another digit cannot occur there)
void RealToText(const REAL* num, char* buf);

// load number from text (returns remaining unused characters; decimal point may be marked as bit 7 of the digit)
int RealFromText(REAL* num, const char* buf, int len);

// convert angles DEG/RAD/GRAD
void RealDegRad(REAL* num); // deg->rad
void RealRadDeg(REAL* num); // rad-->deg
void RealDegGrad(REAL* num); // deg->grad
void RealGradDeg(REAL* num); // grad->deg
void RealGradRad(REAL* num); // grad->rad
void RealRadGrad(REAL* num); // rad->grad

// normalize angle in radians into range 0..PI*2 (= 0..360)
void RealNormRad(REAL* num);

// --- functions

// sine (returns number of loops of iteration)
int RealSin(REAL* num);

// cosine
void RealCos(REAL* num);

// tangent
void RealTan(REAL* num);

// cotangent
void RealCoTan(REAL* num);

// arcus sine (returns number of loops of iteration)
// result is in range -PI/2..+PI/2
int RealASin(REAL* num);

// arcus cosine
// result is in range 0..PI
void RealACos(REAL* num);

// arcus tangent
// result is in range -PI/2..+PI/2
void RealATan(REAL* num);

// arcus cotangent
// result is in range -PI/2..+PI/2
void RealACoTan(REAL* num);

// hyperbolic sine
void RealSinH(REAL* num);

// hyperbolic cosine
void RealCosH(REAL* num);

// hyperbolic tangent
void RealTanH(REAL* num);

// hyperbolic cotangent
void RealCoTanH(REAL* num);

// hyperbolic secant
void RealSecH(REAL* num);

// hyperbolic cosecant
void RealCscH(REAL* num);

// areasine, inverse hyperbolic sine
void RealArSinH(REAL* num);

// areacosine, inverse hyperbolic cosine
void RealArCosH(REAL* num);

// areatangent, inverse hyperbolic tangent
void RealArTanH(REAL* num);

// areacotangent, inverse hyperbolic cotangent
void RealArCoTan(REAL* num);

// areasecant, inverse hyperbolic secant
void RealArSecH(REAL* num);

// areacosecant, inverse hyperbolic cosecant
void RealArCscH(REAL* num);

// natural logarithm (returns number of loops of iteration)
int RealLn(REAL* num);

// ln(2) - calculates ln(2) constant (uses similar method as above, but does not require pre-calculated ln(2) )
int RealLn2(REAL* num);

// natural exponent (returns number of loops of iteration)
int RealExp(REAL* num);

// decimal logarithm
void RealLog10(REAL* num);

// decimal exponent
void RealExp10(REAL* num);

// binary logarithm
void RealLog2(REAL* num);

// binary exponent
void RealExp2(REAL* num);

// sqrt
void RealSqrt(REAL* num);

// set seed of random generator
void SetRndSeed(u64 seed);

// get seed of random generator
u64 GetRndSeed();

// shift random generator
u64 RndShift();

// set random number in range 0<= .. <1 (64-bit precision)
void RealSetRnd(REAL* num);

// random number in range 0<= .. <num (64-bit precision)
void RealRnd(REAL* num);

// integer factorial
void RealFact(REAL* num, u16 n);

// non-integer factorial approximation (precision 5 to 12 digits, error 1/(1400*n^3))
void RealFactSmooth(REAL* num);

// ===========================================================================
//                                Variables
// ===========================================================================

// generated constants
extern REAL RealConst0;		// (0) 0
extern REAL RealConst1;		// (1) 1
extern REAL RealConstM1;	// (2) -1
extern REAL RealConst2;		// (3) 2
extern REAL RealConst05;	// (4) 0.5
extern REAL RealConst075;	// (5) 0.75
extern REAL RealConst10;	// (6) 10
extern REAL RealConst01;	// (7) 0.1
extern REAL RealConst100;	// (8) 100
extern REAL RealConst001;	// (9) 0.01
extern REAL RealConst00001;	// (10) 0.0001
extern REAL RealConst000000001;	// (11) 0.00000001
extern REAL RealConstLn2;	// (12) ln(2)
extern REAL RealConstRLn2;	// (13) 1/ln(2)
extern REAL RealConstLn10;	// (14) ln(10)
extern REAL RealConstRLn10;	// (15) 1/ln(10)
extern REAL RealConstLog2;	// (16) log(2)
extern REAL RealConstRLog2;	// (17) 1/log(2)
extern REAL RealConstExpMax; // (18) maximal exp()
extern REAL RealConstExpMin; // (19) maxinimum exp()
extern REAL RealConstEul;	// (20) Eul
extern REAL RealConstPi05;	// (21) Pi/2
extern REAL RealConstPi;	// (22) Pi
extern REAL RealConstPi2;	// (23) Pi*2
extern REAL RealConstRPi2; // (24) 1/(2*PI)
extern REAL RealConstLnPi22; // (25) ln(2*PI)/2
extern REAL RealConstRadDeg; // (26) rad->deg 180/PI
extern REAL RealConstDegRad; // (27) deg->rad PI/180
extern REAL RealConstRadGrad; // (28) rad->grad 200/PI
extern REAL RealConstGradRad; // (29) grad->rad PI/200
extern REAL RealConstFi; // (30) fi (sectio aurea) = (1 + sqrt(5))/2 = 1.618...
extern REAL RealConstMore05; // (31) little above 0.5

extern REAL RealConst180;	// 180
extern REAL RealConstRLog2; // 1/(log(2))
extern REAL RealConstMPi;	// -Pi
extern REAL RealConstMPi2;	// -Pi*2
extern REAL RealConstSqrt2;	// sqrt(2)
extern REAL RealConstRSqrt2; // 1/sqrt(2)
extern REAL RealConstDegGrad; // deg->grad 200/180
extern REAL RealConstGradDeg; // grad->deg 180/200

// decimal exponents (index R_DECEXP = number "1", middle of table)
extern REAL	RealDecExp[R_DECEXP*2+1]; // exponent floating point valules (10, 100, 10000,...)

// rounding corrections 0.5, 0.05, 0.005, ...
extern REAL RealConstRound[R_DIG+10];

#define FACT_COEFF	12		// number of factorial coefficients
extern real RealConstFactA[FACT_COEFF]; // factorial coefficients (12)
extern real RealConstFactA1[FACT_COEFF]; // factorial coefficients (12)
extern real RealConstFactA2[FACT_COEFF]; // factorial coefficients (12)

// Configuration of function RealToText:
extern int RealFlagDisp; // width of display in number of characters (not including decimal point; point is marked as bit 7)
extern int RealFlagFix; // precision - number of digits after decimal point, or -1=auto
extern int RealFlagDig; // max. number of digits of mantissa (minimal 3)
extern int RealFlagExpDig; // number of digits of exponent (minimal 1)
extern int RealFlagRight; // number of places from right in case of normal format (or 0 in case of exponent format)
extern Bool RealFlagUseExp; // flag - include "e" character for exponent
extern Bool RealFlagExp; // use scientific format (with exponent)
extern Bool RealFlagEng; // use engineer (technical) format (exponent is multiply of 3)
extern Bool RealFlagAuto; // auto format - as normal, but goes to exponent format already with exponent < AUTOEXP
//extern Bool RealFlagGroup; // 3-digits grouping of digits before decimal point

