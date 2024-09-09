// ***************************************************************************
//
//                                Includes
//
// ***************************************************************************

#ifdef __linux__
#include "lib/types.h"		// data types and common definitions
#else
#include "lib\types.h"		// data types and common definitions
#endif
#include "config.h"				// configuration

// only for testing purposes
#define PI 3.1415926535897932384626433832795
#define PI2 6.283185307179586476925286766559
#define PI05 1.5707963267948966192313216916398
#define EUL 2.7182818284590452353602874713527
#define LN2 0.69314718055994530941723212145818
#define LN10 2.3025850929940456840179914546844
#define LOG2 0.30102999566398119521373889472449

// error code
extern u8 ErrorCode;

// flag - ignore errors (only store error code)
extern Bool ErrorOff;

// error report (or return if ignoring errors)
// - raise exception, reinitialize stack and return to main loop
void Error(u8 code);

// error codes
#define ERR_OK				0		// all OK
// - hard fails, cannot continue
#define ERR_MEMORY			1		// memory hard fault error
#define ERR_INTERNAL		2		// internal system error
#define ERR_CALCSTACKOVER	3		// calculator stack overflow
// - soft fails, can continue
#define ERR_PARAM			4		// incorrect parameters
#define ERR_OVERFLOW		5		// result overflow (divide by zero)
#define ERR_UNDERFLOW		6		// result underflow

#define ERR_LASTHARD		3		// max. hard fail

// compare flags
#define COMP_LESS		-1	// 1st number is less than 2nd
#define COMP_EQU		0	// numbers are equal
#define COMP_GREATER	1	// 1st number is greater than 2nd

// includes
#ifdef __linux__
#include "lib/real.h"		// floating-point numbers
#include "lib/calc.h"		// expression calculator
#else
#include "lib\real.h"		// floating-point numbers
#include "lib\calc.h"		// expression calculator
#endif
