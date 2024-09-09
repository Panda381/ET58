// ***************************************************************************
//
//                                Configuration
//
// ***************************************************************************

#define CALCMAX		100		// max. entries in calculator stack
#define AUTOEXP		-4		// min. value of exponent to go into exponent mode in Auto mode
#define ERRMEXP				// uncomment this to report error on exp(-x) underflow (result should be 0)
#define USEDBLMUL			// uncomment this to use double number for multiplication (comment this if not)
#define GENCONST			// uncomment this to generate constants instead of use tables


// ==== Internal calculator format (with higher precission than memory format)
// - Internal calculator format: M segments of mantissa, last bit of mantissa is sign, 1 segment of exponent signed

// 1024 bits, 128 bytes, Constant generator: 298.62 digits, exponent 646456992.94
#define R_BASE_TYPE	4		// size of 1 mantissa segment (1 = byte u8, 2 = word u16, 4 = dword u32)
#define R_MANT_NUM	31		// number of mantissa segments
#define R_EXP_TYPE	4		// type of exponent (1 = byte u8, 2 = word u16, 4 = dword u32)

// ==== Memory format (exported, with lower precision than calculator format)
// - Memory format (exported): M bits ot mantissa, N bits of exponent unsigned (Bias = max/2), 1 bit of sign

// 64 bits, 8 bytes, binary64, double precision: 15.95 digits, exponent 307.95
#define M_BYTES		8		// total number of bytes of memory number
#define M_EXP_BITS	11		// number of bits per exponent
