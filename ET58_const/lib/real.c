// ***************************************************************************
//
//                  Binary floating point numbers
//
// ***************************************************************************

#include "include.h"

// generated constants
REAL RealConst0;	// (0) 0
REAL RealConst1;	// (1) 1
REAL RealConstM1;	// (2) -1
REAL RealConst2;	// (3) 2
REAL RealConst05;	// (4) 0.5
REAL RealConst075; // (5) 0.75  = { {0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x40000000}, -1}; // 0.75 ... 0.750000
REAL RealConst10;	// (6) 10
REAL RealConst01; // (7) 0.1 = { {0xCCCCCCCD,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0x4CCCCCCC}, -4}; // 0.1 ... 0.100000
REAL RealConst100;	// (8) 100
REAL RealConst001; // (9) 0.01 = { {0xCCCCCCCD,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0x4CCCCCCC}, -4}; // 0.1 ... 0.100000
REAL RealConst00001; // (10) 0.0001 = { {0xCCCCCCCD,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0xCCCCCCCC,0x4CCCCCCC}, -4}; // 0.1 ... 0.100000
REAL RealConst000000001; // (11) 0.00000001
REAL RealConstLn2; // (12) ln(2) = { {0xDA2D97CA,0x2F20E3A2,0x655FA187,0x38303248,0xF5DFA6BD,0x9D6548CA,0x72CE87B1,0x7657F74B,0x256FA0EC,0xB136603B,0xB9EA9BC3,0x317C387E,0x1ACBDA11,0x224AE8C5,0x3E96CA16,0x1169B825,0x27573B29,0xC1382144,0xED2EAE35,0x4AFA1B10,0x559552FB,0x6DEBAC98,0xE7B87620,0x8BAAFA2B,0x8A0D175B,0x7298B62D,0x40F34326,0x03F2F6AF,0xC9E3B398,0xD1CF79AB,0x317217F7}, -1}; // ln(2) ... 0.693147
REAL RealConstRLn2; // (13) 1/ln(2) = { {0x612F08F7,0x8CD5DB8F,0xCE7E2035,0x4679C940,0x278CCF08,0x6F5B4967,0x199A9483,0xAB63253C,0x8D1CF457,0x3A828546,0x0B5EBBBF,0x79D5A206,0xB21B43D5,0x2617D9D5,0x2FE29493,0x53DF39B3,0xC4BFAF03,0x0C4A909F,0xEA90B9E6,0xC16BE0B3,0x24D92F75,0x55176CD6,0xDE1C43F7,0xD1A13247,0x8B25166C,0xDD695A58,0xEB577AA8,0x691D3E88,0xBE87FED0,0x5C17F0BB,0x38AA3B29}, 0}; // 1/ln(2) ... 1.442695
REAL RealConstLn10; // (14) ln(10) = { {0x469EA593,0xD5EDE20F,0x5B08B057,0x44789C4F,0x8E93368D,0x23605085,0xCA67B35B,0xD219C7BB,0x5161BB49,0x4AB3C6FA,0xEF66CEB0,0xB0D831FB,0x765AA6C3,0x8A8C911E,0x782CF8A2,0x02E516D6,0xFB8F7884,0x410BE2DA,0x2C622418,0x2C5F0D68,0xCC70CBC0,0xB1A8105C,0x962F02D7,0x01F02D72,0x83C61E82,0xDA5DF90E,0xE28FECF9,0x82D30A28,0xEA56D62B,0xAAA8AC16,0x135D8DDD}, 1}; // ln(10) ... 2.302585
REAL RealConstRLn10; // (15) 1/ln(10) = { {0xB3FE40BC,0x27C968EB,0xD794D64F,0xCC51F934,0x648ECC89,0xE68C04D4,0x5430212A,0x2F3739D5,0x50B36DED,0x42C84D6A,0x658B61EA,0x8C1DC4DA,0x40072005,0x48D06FF9,0x4356BD19,0xC8CDA7B3,0x6FA2B8D2,0xFD38DCBC,0x18CE3BD9,0xC6464A15,0x92235592,0x1402F3F2,0x75424EFA,0xF78EA53C,0x3A3F2D44,0x45C9A202,0x3EE34602,0xAD33DC32,0x355BAAAF,0x37287195,0x5E5BD8A9}, -2}; // 1/ln(10) ... 0.434294
REAL RealConstLog2; // (16) log(2) = { {0xDEEA3177,0x3CF4C8FB,0x6A367B81,0x941AB821,0x0B0833C5,0x9EB153D8,0x048D7EA5,0x1592D9DC,0xEB91129B,0xDE7102F4,0xD26C272F,0xC40602E5,0x9CF1D190,0x02555CBC,0x5F837DEE,0x2552D2CC,0x58B527F5,0xB18B921E,0x91473495,0x3471BD12,0x9E5CBC73,0x919FABD0,0x286A2D81,0xB7CC63CB,0x8A5E6F26,0x43D1F349,0x26AD30C5,0x0B7C9178,0x8F8959AC,0xFBCFF798,0x1A209A84}, -2}; // log(2) ... 0.301030
REAL RealConstRLog2; // (17) 1/log(2)
REAL RealConstExpMax; // (18) max exp() = { {0xDA2D97CA,0x2F20E3A2,0x655FA187,0x38303248,0xF5DFA6BD,0x9D6548CA,0x72CE87B1,0x7657F74B,0x256FA0EC,0xB136603B,0xB9EA9BC3,0x317C387E,0x1ACBDA11,0x224AE8C5,0x3E96CA16,0x1169B825,0x27573B29,0xC1382144,0xED2EAE35,0x4AFA1B10,0x559552FB,0x6DEBAC98,0xE7B87620,0x8BAAFA2B,0x8A0D175B,0x7298B62D,0x40F34326,0x03F2F6AF,0xC9E3B398,0xD1CF79AB,0x317217F7}, 30}; // maximal exp() ... 1488522235.909786
REAL RealConstExpMin; // (19) min exp() = { {0x7BEBD084,0x6461A094,0xF4FF3CF6,0x4C70E4CD,0xBB151527,0xB7C83967,0x861E991A,0x2B78B572,0xC302E076,0x3D6128B3,0x56F22AC6,0xFBE4845C,0xD6360886,0xA51D5498,0x1BC359CB,0xC2BB41D3,0xA4E6F8A0,0xE6DAC4D8,0x573A7813,0x9FCF751A,0x79BDF9CA,0x9E7AC057,0xD06281C8,0x7790CB74,0xA4DBAB00,0xF0B22FE0,0x390D55C7,0x702B8F7F,0x2644C040,0x6EEB49BC,0xB17217F6}, 30}; // minimum exp() ... -1488522235.216639
REAL RealConstEul; // (20) Eul = { {0xBC0AB180,0x483A797A,0x30ACCA4F,0x36ADE735,0x1DF158A1,0xF3EFE872,0xE2A689DA,0xE0E68B77,0x984F0C70,0x7F57C935,0xB557135E,0x3DED1AF3,0x85636555,0x5F066ED0,0x2433F51F,0xD5FD6561,0xD3DF1ED5,0xAEC4617A,0xF681B202,0x630C75D8,0x7D2FE363,0x249B3EF9,0xCC939DCE,0x146433FB,0xA9E13641,0xCE2D3695,0xD8B9C583,0x273D3CF1,0xAFDC5620,0xA2BB4A9A,0x2DF85458}, 1}; // Eul ... 2.718282
REAL RealConstPi05; // (21) Pi/2 = { {0x98DA4836,0xA163BF05,0xC2007CB8,0xECE45B3D,0x49286651,0x7C4B1FE6,0xAE9F2411,0x5A899FA5,0xEE386BFB,0xF406B7ED,0x0BFF5CB6,0xA637ED6B,0xF44C42E9,0x625E7EC6,0xE485B576,0x6D51C245,0x4FE1356D,0xF25F1437,0x302B0A6D,0xCD3A431B,0xEF9519B3,0x8E3404DD,0x514A0879,0x3B139B22,0x020BBEA6,0x8A67CC74,0x29024E08,0x80DC1CD1,0xC4C6628B,0x2168C234,0x490FDAA2}, 0}; // Pi/2 ... 1.570796
REAL RealConstPi; // (22) Pi = { {0x98DA4836,0xA163BF05,0xC2007CB8,0xECE45B3D,0x49286651,0x7C4B1FE6,0xAE9F2411,0x5A899FA5,0xEE386BFB,0xF406B7ED,0x0BFF5CB6,0xA637ED6B,0xF44C42E9,0x625E7EC6,0xE485B576,0x6D51C245,0x4FE1356D,0xF25F1437,0x302B0A6D,0xCD3A431B,0xEF9519B3,0x8E3404DD,0x514A0879,0x3B139B22,0x020BBEA6,0x8A67CC74,0x29024E08,0x80DC1CD1,0xC4C6628B,0x2168C234,0x490FDAA2}, 1}; // Pi ... 3.141593
REAL RealConstPi2; // (23) Pi*2 = { {0x98DA4836,0xA163BF05,0xC2007CB8,0xECE45B3D,0x49286651,0x7C4B1FE6,0xAE9F2411,0x5A899FA5,0xEE386BFB,0xF406B7ED,0x0BFF5CB6,0xA637ED6B,0xF44C42E9,0x625E7EC6,0xE485B576,0x6D51C245,0x4FE1356D,0xF25F1437,0x302B0A6D,0xCD3A431B,0xEF9519B3,0x8E3404DD,0x514A0879,0x3B139B22,0x020BBEA6,0x8A67CC74,0x29024E08,0x80DC1CD1,0xC4C6628B,0x2168C234,0x490FDAA2}, 2}; // Pi*2 ... 6.283185
REAL RealConstRPi2; // (24) 1/(2*PI)
REAL RealConstLnPi22; // (25) ln(2*PI)/2
REAL RealConstRadDeg; // (26) 180/Pi = { {0xECBFDEA9,0x4EB6E14F,0xC77AC928,0x4FF585A9,0x3194A253,0xF69EA974,0x685A30AB,0xD037DDD6,0x24F595BF,0x83266093,0xFC1A265C,0xE0AD097F,0xB8F51540,0x6DA6498B,0xE883FDB6,0xC9B7585A,0x76F71BE0,0x59229330,0xC55A12A0,0x1DCEB578,0x08D6E9F9,0xED3D708B,0x698B3B01,0xB1380D91,0xCDA27429,0x7CBF02DC,0x3482A25F,0x40D257D7,0x0A97537F,0x1E0FBDC3,0x652EE0D3}, 5}; // rad->deg 180/PI ... 57.295780
REAL RealConstDegRad; // (27) Pi/180 = { {0xAB45E3B5,0x6D13BB09,0x349FA2A5,0x47BED4CB,0xAB7D7095,0xB3689F37,0x5A0AC450,0xA117E8FE,0x65226EEB,0x4CD193DC,0x527CB3B5,0xF90B537F,0x5863BDCD,0x57049E6B,0x5E3CF2D1,0x3CABEADC,0x71B1370F,0x9598F1EE,0x60D4A6B4,0x9D5140C9,0x10C50C96,0x81911487,0xB6F61167,0xC94C8512,0xE502A9B4,0x01B5E6B8,0x00B7AEF5,0x9485C4D9,0x0EC5F66E,0x94E9C8AE,0xEFA3512}, -6}; // deg->rad PI/180 ... 0.017453
REAL RealConstRadGrad; // (28) 200/Pi = { {0x070E13D9,0x5775DDE7,0x6BDDC310,0xAE2D3F2E,0x1AA52623,0xBCB04A81,0xE5B98B69,0xCAE8BD98,0x61F46D7F,0x58D54EDC,0x348ED54A,0xDD320A8E,0xE9F3DEB9,0x79D53545,0xAD046F3C,0x19049B0F,0x4B4B744F,0xD4D11552,0x4D0EBF5C,0xAF57744D,0x09D2594D,0x0799997E,0xAE28EC3B,0x8C056468,0x1D5F2BBC,0x6E299167,0x56CA09BF,0x0F229A7D,0x99FD7938,0x5A4A6111,0x7EA5DD5C}, 5}; // rad->grad 200/PI ... 63.661977
REAL RealConstGradRad; // (29) Pi/200 = { {0xE6F219BC,0x155E8EBB,0xAF5C78C8,0x5A2BBF83,0xE7241886,0xA177C27E,0xEAA34A48,0xAA9584E4,0xF49EFD6D,0x91EFD1DF,0x30A36E89,0xC68A318C,0xCF8CF79F,0x67EA8E93,0xEE6A0DBC,0x5034535F,0xFFEC4B27,0x203CD9BC,0xD725C93C,0x5A62BA4E,0x5BE48B54,0x27CF5F46,0xA4AA42DD,0x81F8115D,0x9AE8CBEF,0xE7F082D9,0x1A3EEA42,0x85AB9790,0x407EF763,0xB938CE36,0xADFC90}, -6}; // grad->rad PI/200 ... 0.015708
REAL RealConstFi; // (30) fi (sectio aurea) = (1 + sqrt(5))/2 = 1.618...
REAL RealConstMore05;	// (31) little above 0.5

REAL RealConst180;	// *180
REAL RealConstRLog2; // *1/(log(2))
REAL RealConstMPi; // * -Pi = { {0x98DA4836,0xA163BF05,0xC2007CB8,0xECE45B3D,0x49286651,0x7C4B1FE6,0xAE9F2411,0x5A899FA5,0xEE386BFB,0xF406B7ED,0x0BFF5CB6,0xA637ED6B,0xF44C42E9,0x625E7EC6,0xE485B576,0x6D51C245,0x4FE1356D,0xF25F1437,0x302B0A6D,0xCD3A431B,0xEF9519B3,0x8E3404DD,0x514A0879,0x3B139B22,0x020BBEA6,0x8A67CC74,0x29024E08,0x80DC1CD1,0xC4C6628B,0x2168C234,0xC90FDAA2}, 1}; // -Pi ... -3.141593
REAL RealConstMPi2; // * -Pi*2 = { {0x98DA4836,0xA163BF05,0xC2007CB8,0xECE45B3D,0x49286651,0x7C4B1FE6,0xAE9F2411,0x5A899FA5,0xEE386BFB,0xF406B7ED,0x0BFF5CB6,0xA637ED6B,0xF44C42E9,0x625E7EC6,0xE485B576,0x6D51C245,0x4FE1356D,0xF25F1437,0x302B0A6D,0xCD3A431B,0xEF9519B3,0x8E3404DD,0x514A0879,0x3B139B22,0x020BBEA6,0x8A67CC74,0x29024E08,0x80DC1CD1,0xC4C6628B,0x2168C234,0xC90FDAA2}, 2}; // -Pi*2 ... -6.283185
REAL RealConstSqrt2; // *sqrt(2) = { {0xEAA4A08C,0x836E582E,0xF52F120F,0x31F3C84D,0xCB2A6343,0x8BB7E9DC,0xC6D5A8A3,0x2F7C4E33,0x460ABC72,0x1688458A,0xCAB1BC91,0x11BC337B,0x53059C60,0x42AF1F4E,0xD2202E87,0x3DFA2768,0x78048736,0x439C7B4A,0x0F74A85E,0xDC83DB39,0xA8B1FE6F,0x3AB8A2C3,0x4AFC8304,0x83339915,0xED17AC85,0x893BA84C,0x1D6F60BA,0x754ABE9F,0x597D89B3,0xF9DE6484,0x3504F333}, 0}; // sqrt(2) ... 1.414214
REAL RealConstRSqrt2; // * 1/sqrt(2) = { {0xEAA4A087,0x836E582E,0xF52F120F,0x31F3C84D,0xCB2A6343,0x8BB7E9DC,0xC6D5A8A3,0x2F7C4E33,0x460ABC72,0x1688458A,0xCAB1BC91,0x11BC337B,0x53059C60,0x42AF1F4E,0xD2202E87,0x3DFA2768,0x78048736,0x439C7B4A,0x0F74A85E,0xDC83DB39,0xA8B1FE6F,0x3AB8A2C3,0x4AFC8304,0x83339915,0xED17AC85,0x893BA84C,0x1D6F60BA,0x754ABE9F,0x597D89B3,0xF9DE6484,0x3504F333}, -1}; // 1/sqrt(2) ... 0.707107
REAL RealConstDegGrad; // *200/180 = { {0x8E38E38E,0xE38E38E3,0x38E38E38,0x8E38E38E,0xE38E38E3,0x38E38E38,0x8E38E38E,0xE38E38E3,0x38E38E38,0x8E38E38E,0xE38E38E3,0x38E38E38,0x8E38E38E,0xE38E38E3,0x38E38E38,0x8E38E38E,0xE38E38E3,0x38E38E38,0x8E38E38E,0xE38E38E3,0x38E38E38,0x8E38E38E,0xE38E38E3,0x38E38E38,0x8E38E38E,0xE38E38E3,0x38E38E38,0x8E38E38E,0xE38E38E3,0x38E38E38,0xE38E38E}, 0}; // deg->grad 200/180 ... 1.111111
REAL RealConstGradDeg; // *180/200 = { {0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666,0x66666666}, -1}; // grad->deg 180/200 ... 0.900000

// decimal exponents (index R_DECEXP = number '1', middle of table)
// - exponent floating point valules (...0.1, 1, 10, 100, 10000,...)
REAL RealDecExp[R_DECEXP*2+1];

// rounding corrections 0.5, 0.05, 0.005,...
REAL RealConstRound[R_DIG+10];

real RealConstFactA[FACT_COEFF]; // factorial coefficients (12)
real RealConstFactA1[FACT_COEFF]; // factorial coefficients (12)
real RealConstFactA2[FACT_COEFF]; // factorial coefficients (12)

// factorial coefficients templates
const char* FactA[FACT_COEFF] = {
		"1",	// a0
		"1",	// a1
		"53",	// a2
		"195",	// a3
		"22999",	// a4
		"29944523",	// a5
		"109535241009",	// a6
		"29404527905795295658",	// a7
		"455377030420113432210116914702",	// a8
		"26370812569397719001931992945645578779849",	// a9
		"152537496709054809881638897472985990866753853122697839",	// a10
		"100043420063777451042472529806266909090824649341814868347109676190691",	// a11
};

const char* FactB[FACT_COEFF] = {
		"12",	// a0
		"30",	// a1
		"210",	// a2
		"371",	// a3
		"22737",	// a4
		"19733142",	// a5
		"48264275462",	// a6
		"9769214287853155785",	// a7
		"113084128923675014537885725485",	// a8
		"5271244267917980801966553649147604697542", // a9
		"24274291553105128438297398108902195365373879212227726",	// a10
		"13346384670164266280033479022693768890138348905413621178450736182873",	// a11
};

// Configuration of function RealToText:
int RealFlagDisp = R_BUFSIZE; // width of display in number of characters (not including decimal point - it is marked as bit 7)
int RealFlagFix = -1; // precision - number of digits after decimal point, or -1=auto
int RealFlagDig = 300; //R_MANT_DIG+2; // max. number of digits of mantissa (minimal 3)
int RealFlagExpDig = R_EXP_DIG; // number of digits of exponent (minimal 1)
int RealFlagRight = 1; // number of places from right in case of normal format (or 0 in case of exponent format)
Bool RealFlagUseExp = False; // flag - include "e" character for exponent
Bool RealFlagExp = False; // use scientific format (with exponent)
Bool RealFlagEng = False; // use engineer (technical) format (exponent is multiply of 3)
Bool RealFlagAuto = True; // auto format - as normal, but goes to exponent format already with exponent < AUTOEXP
//Bool RealFlagGroup = False; // 3-digits grouping of digits before decimal point

// temporary variables of function RealFromText
const char* _RealFTextBuf; // pointer into input buffer
int _RealFTextLen; // remainging characters
char _RealFTextDec; // saved decimal point, or 0 (=bit 7 in source buffer)

// initialize real numbers
void RealInit()
{
	int i, i2;

	// generated constants
	RealSet0(&RealConst0); // 0
	RealSet1(&RealConst1); // 1
	RealSetM1(&RealConstM1); // -1
	RealSet2(&RealConst2); // 2
	RealSet05(&RealConst05); // 0.5
	RealSetU8(&RealConst10, 10); // 10
	RealSetU8(&RealConst180, 180); // 180
	RealSetU8(&RealConst100, 100); // 100

	RealSetS16(&RealConstExpMax, 10000);
	RealSetS16(&RealConstExpMin, -10000);

	// - do not change order of operations, may be depended
	RealSet2(&RealConst075); RealInc(&RealConst075); RealDiv2(&RealConst075); RealDiv2(&RealConst075); // = (2+1)/2/2 = 3/4 = 0.75
	RealCopy(&RealConstPi, &RealConst05); RealASin(&RealConstPi); RealSetU8(&RealConstMPi, 6); RealMul(&RealConstPi, &RealConstPi, &RealConstMPi); // 6*arcsin(0.5) = Pi
	RealCopy(&RealConstMPi, &RealConstPi); RealNeg(&RealConstMPi); // -Pi
	RealCopy(&RealConstPi2, &RealConstPi); RealMul2(&RealConstPi2); // Pi*2
	RealCopy(&RealConstRPi2, &RealConstPi2); RealRec(&RealConstRPi2); // 1/Pi*2
	RealCopy(&RealConstMPi2, &RealConstPi2); RealNeg(&RealConstMPi2); // -Pi*2
	RealCopy(&RealConstPi05, &RealConstPi); RealDiv2(&RealConstPi05); // Pi/2
	RealLn2(&RealConstLn2); // ln(2)
	RealDiv(&RealConstRLn2, &RealConst1, &RealConstLn2); // 1/ln(2)
	RealCopy(&RealConstEul, &RealConst1); RealExp(&RealConstEul); // Eul
	RealCopy(&RealConstLn10, &RealConst10); RealLn(&RealConstLn10); // ln(10)
	RealDiv(&RealConstRLn10, &RealConst1, &RealConstLn10); // 1/ln(10)
	RealDiv(&RealConstLog2, &RealConstLn2, &RealConstLn10); // log(2)
	RealDiv(&RealConstRLog2, &RealConst1, &RealConstLog2); // 1/log(2)
	RealCopy(&RealConstSqrt2, &RealConst2); RealSqrt(&RealConstSqrt2); // sqrt(2)
	RealDiv(&RealConstRSqrt2, &RealConst1, &RealConstSqrt2); // 1/sqrt(2)
	RealDiv(&RealConst01, &RealConst1, &RealConst10); // 0.1
	RealDiv(&RealConstDegRad, &RealConstPi, &RealConst180); // deg->rad PI/180
	RealDiv(&RealConstRadDeg, &RealConst180, &RealConstPi); // rad->deg 180/PI
	RealSetU8(&RealConstDegGrad, 200); RealDiv(&RealConstDegGrad, &RealConstDegGrad, &RealConst180); // deg->grad 200/180
	RealSetU8(&RealConstGradDeg, 200); RealDiv(&RealConstGradDeg, &RealConst180, &RealConstGradDeg); // grad->deg 180/200
	RealSetU8(&RealConstGradRad, 200); RealDiv(&RealConstGradRad, &RealConstPi, &RealConstGradRad);	 // grad->rad PI/200
	RealSetU8(&RealConstRadGrad, 200); RealDiv(&RealConstRadGrad, &RealConstRadGrad, &RealConstPi);	 // rad->grad 200/PI
	RealSetMax(&RealConstExpMax); RealLn(&RealConstExpMax); // maximal exp()
	RealSetMin(&RealConstExpMin); RealLn(&RealConstExpMin); // minimal exp()
	RealDiv(&RealConst001, &RealConst1, &RealConst100); // 0.01
	RealMul(&RealConst00001, &RealConst001, &RealConst001); // 0.0001
	RealMul(&RealConst000000001, &RealConst00001, &RealConst00001); // 0.00000001
	RealCopy(&RealConstLnPi22, &RealConstPi2); RealLn(&RealConstLnPi22); RealDiv2(&RealConstLnPi22);
	RealSetU8(&RealConstFi, 5); RealSqrt(&RealConstFi); RealInc(&RealConstFi); RealDiv2(&RealConstFi);

	// decimal exponents
	RealCopy(&RealDecExp[R_DECEXP-1], &RealConst01); // 0.1
	RealSet1(&RealDecExp[R_DECEXP]); // 1
	RealCopy(&RealDecExp[R_DECEXP+1], &RealConst10); // 10

	i2 = R_DECEXP-2;
	for (i = R_DECEXP+2; i < R_DECEXP*2+1; i++)
	{
		RealMul(&RealDecExp[i], &RealDecExp[i-1], &RealDecExp[i-1]);
		RealDiv(&RealDecExp[i2], &RealConst1, &RealDecExp[i]);
		i2--;
	}

	// rounding corrections 0.5, 0.05, 0.005,...
	RealSet05(&RealConstRound[0]);
	for (i = 1; i < R_DIG+10; i++) RealMul(&RealConstRound[i], &RealConstRound[i-1], &RealConst01);

	// factorial coefficients
	for (i = 0; i < FACT_COEFF; i++)
	{
		RealFromText(&RealConstFactA1[i], FactA[i], (int)strlen(FactA[i]));
		RealFromText(&RealConstFactA2[i], FactB[i], (int)strlen(FactB[i]));
		RealDiv(&RealConstFactA[i], &RealConstFactA1[i], &RealConstFactA2[i]);
	}
}

// ===== internal functions

// multiply 2 segments of mantissa with double result (rH:rL = a * b)
void RealMulInt(r_base* rL, r_base* rH, r_base a, r_base b)
{
#ifdef USEDBLMUL	// use DBL method
	
	r_dbl r = (r_dbl)a*b;
	*rL = (r_base)r;
	*rH = (r_base)(r >> R_BASE_BITS);

#else // USEDBLMUL

	r_half a0, a1, b0, b1;
	r_base t0, t1, t2, t3;

	//       a1a0
	//     x b1b0
	// ----------
	//       a0b0 ...   t0
	//     a0b1   ...  t1
	//     a1b0   ...  t2
	//   a1b1     ... t3

	// prepare half segments (value 0000..FFFF)
	a0 = (r_half)(a & R_HALF_MASK);
	a1 = (r_half)(a >> R_HALF_BITS);
	b0 = (r_half)(b & R_HALF_MASK);
	b1 = (r_half)(b >> R_HALF_BITS);

	// temporary results (max. FFFF * FFFF = FFFE0001)
	t0 = (r_base)a0*b0;
	t1 = (r_base)a0*b1;
	t2 = (r_base)a1*b0;
	t3 = (r_base)a1*b1;

	// add elements
	t1 += t0 >> R_HALF_BITS; // max. FFFE0001 + FFFE = FFFEFFFF, no carry yet
	t1 += t2; // max. FFFEFFFF + FFFE0001 = 1FFFD0000, it can be carry
	if (t1 < t2) t3 += (r_base)1 << R_HALF_BITS; // add carry; FFFE0001 + 10000 = FFFF0001, no carry

	// result, max. FFFFFFFF * FFFFFFFF = FFFFFFFE:00000001
	*rL = (t1 << R_HALF_BITS) + (t0 & R_HALF_MASK); // result low, max. FFFF0000 + FFFF = FFFFFFFF, no carry
	*rH = t3 + (t1 >> R_HALF_BITS); // result high, max. FFFF0001 + FFFD = FFFFFFFE, no carry

#endif // USEDBLMUL
}

// increment denormalised mantissa, returns carry bit (exponent not changed)
u8 RealMantInc(REAL* num)
{
	int i;
	r_base b, *s;

	s = num->m;
	for (i = R_MANT_NUM; i > 0; i--)
	{
		b = *s + 1;
		*s++ = b;
		if (b != 0) return 0; // no carry
	}

	// carry
	return 1;
}

// negate denormalised mantissa (returns carry)
u8 RealMantNeg(REAL* num)
{
	r_base b, *s;
	u8 carry;
	int i;

	// negate: complement and than add 1
	carry = 1;
	s = num->m;
	for (i = R_MANT_NUM; i > 0; i--)
	{
		b = ~*s;
		b += carry;
		carry = (b < carry) ? 1 : 0;
		*s++ = b;
	}
	return carry;
}

// shift denormalized mantissa left to higher bits (returns highest carry bit)
u8 RealShiftL(REAL* num, u8 carry)
{
	int i;
	r_base a, b, *s;
	u8 carry2;

	s = num->m;

	for (i = R_MANT_NUM; i > 0; i--)
	{
		b = *s;
		carry2 = carry;
		carry = ((b & R_BASE_LAST) == 0) ? 0 : 1; // carry to higher segment
		b = (b << 1) | carry2; // shift and add new carry
		*s++ = b; // set segment
	}

	return carry;
}

// shift denormalized mantissa right to lower bits (returns lowest carry bit)
u8 RealShiftR(REAL* num, u8 carry)
{
	int i;
	r_base a, b, *s;
	u8 carry2;

	s = &num->m[R_MANT_NUM-1];

	for (i = R_MANT_NUM; i > 0; i--)
	{
		b = *s;
		carry2 = carry;
		carry = (u8)(b & 1); // carry to lower segment
		b >>= 1; // shift
		if (carry2) b |= R_BASE_LAST; // add cary from higher segment
		*s-- = b; // set segment
	}

	return carry;
}

// read 1 segment from constant table
r_base ReadTabSeg(const u8* tab)
{
	r_base k;

	k = *tab++;

#if R_BASE_TYPE != 1
	k <<= 8;
	k |= *tab++;
#endif

#if R_BASE_TYPE == 4
	k <<= 16;
	k |= ((r_base)*tab++ << 8);
	k |= *tab;
#endif

	return k;
}

// denormalize number - set hidden bit (to normalize - use RealSetSign)
void RealDenorm(REAL* num)
{
	num->m[R_MANT_NUM-1] |= R_BASE_LAST;
}

// ===== public functions

// --- flags and base manilupations

// check if number is zero
Bool RealIsZero(const REAL* num)
{
	return num->exp == R_EXP_0;
}

// check if number is negative
Bool RealIsNeg(const REAL* num)
{
	return (num->m[R_MANT_NUM-1] & R_BASE_LAST) != 0;
}

// check if number is positive (but not zero)
Bool RealIsPos(const REAL* num)
{
	return !RealIsNeg(num) && !RealIsZero(num);
}

// set sign (True = negative)
void RealSetSign(REAL* num, Bool sign)
{
	r_base k = num->m[R_MANT_NUM-1] & ~R_BASE_LAST;
	if (sign) k |= R_BASE_LAST;
	num->m[R_MANT_NUM-1] = k;
}

// negate - flip sign (except zero)
void RealNeg(REAL* num)
{
	if (!RealIsZero(num)) num->m[R_MANT_NUM-1] ^= R_BASE_LAST;
}

// absolute value - clear negative flag
void RealAbs(REAL* num)
{
	num->m[R_MANT_NUM-1] &= ~R_BASE_LAST;
}

// set negative flag (only if not 0)
void RealSetNeg(REAL* num)
{
	if (!RealIsZero(num)) num->m[R_MANT_NUM-1] |= R_BASE_LAST;
}

// Signum - set number to 0, 1 or -1, by sign
void RealSign(REAL* num)
{
	if (!RealIsZero(num))
	{
		if (RealIsNeg(num))
			RealSetM1(num);
		else
			RealSet1(num);
	}
}

// --- set number

// clear number
void RealSet0(REAL* num)
{
	int i;
	r_base* d;
	num->exp = R_EXP_0;
	d = num->m;
	for (i = R_MANT_NUM; i > 0; i--) *d++ = 0;
}

// set value 1
void RealSet1(REAL* num)
{
	RealSet0(num);
	num->exp = 0;
}

// set value -1
void RealSetM1(REAL* num)
{
	RealSet1(num);
	RealNeg(num);
}

// set value 2
void RealSet2(REAL* num)
{
	RealSet0(num);
	num->exp = 1;
}

// set value 0.5
void RealSet05(REAL* num)
{
	RealSet0(num);
	num->exp = -1;
}

// set constant Pi
void RealSetPi(REAL* num)
{
	RealCopy(num, &RealConstPi);
}

// set constant Pi*2
void RealSetPi2(REAL* num)
{
	RealCopy(num, &RealConstPi2);
}

// set constant Pi/2
void RealSetPi05(REAL* num)
{
	RealCopy(num, &RealConstPi05);
}

// set constant Eul
void RealSetEul(REAL* num)
{
	RealCopy(num, &RealConstEul);
}

// set constant ln(2)
void RealSetLn2(REAL* num)
{
	RealCopy(num, &RealConstLn2);
}

// set constant ln(10)
void RealSetLn10(REAL* num)
{
	RealCopy(num, &RealConstLn10);
}

// set constant log(2)
void RealSetLog2(REAL* num)
{
	RealCopy(num, &RealConstLog2);
}

// set constant 10
void RealSet10(REAL* num)
{
	RealCopy(num, &RealConst10);
}

// set constant 0.1
void RealSet01(REAL* num)
{
	RealCopy(num, &RealConst01);
}

// set unsigned integer value
void RealSetUInt(REAL* num, r_base n)
{
	r_exps exp;

	// clear number
	RealSet0(num);

	// number is zero
	if (n == 0) return;

	// normalize number to highest bits
	exp = R_BASE_BITS - 1; // exponent for case of max. number
	while ((n & R_BASE_LAST) == 0)
	{
		n <<= 1;
		exp--;
	}

	// delete hidden bit
	n &= ~R_BASE_LAST;

	// save number into last mantissa segment
	num->m[R_MANT_NUM-1] = n;

	// save exponent
	num->exp = exp;
}

void RealSetU8(REAL* num, u8 n)
{
	RealSetUInt(num, n);
}

void RealSetU16(REAL* num, u16 n)
{
#if R_BASE_BYTES >= 2 // size of segment is "word" or more
	RealSetUInt(num, n);
#else

	r_exps exp;

	// clear number
	RealSet0(num);

	// number is zero
	if (n == 0) return;

	// normalize number to highest bits
	exp = 16 - 1; // exponent for case of max. number
	while ((n & 0x8000) == 0)
	{
		n <<= 1;
		exp--;
	}

	// delete hidden bit
	n &= ~0x8000;

	// save higher part of number into last mantissa segment
	num->m[R_MANT_NUM-1] = (r_base)(n >> 8);

#if R_MANT_NUM > 1 // there is another valid segment
	// save lower part
	num->m[R_MANT_NUM-2] = (r_base)n;
#endif

	// save exponent
	num->exp = exp;

#endif // R_BASE_BYTES >= 2
}

void RealSetU32(REAL* num, u32 n)
{
#if R_BASE_BYTES >= 4 // size of segment is "dword" or more
	RealSetUInt(num, n);
#else

	r_exps exp;

	// clear number
	RealSet0(num);

	// number is zero
	if (n == 0) return;

	// normalize number to highest bits
	exp = 32 - 1; // exponent for case of max. number
	while ((n & 0x80000000UL) == 0)
	{
		n <<= 1;
		exp--;
	}

	// delete hidden bit
	n &= ~0x80000000UL;

#if R_BASE_BITS == 8 // segment is 8 bits

	// save higher part of number into last mantissa segment
	num->m[R_MANT_NUM-1] = (r_base)(n >> 24);

#if R_MANT_NUM > 1 // there is another valid segment
	// save middle part
	num->m[R_MANT_NUM-2] = (r_base)(n >> 16);
#endif

#if R_MANT_NUM > 2 // there is another valid segment
	// save middle part
	num->m[R_MANT_NUM-3] = (r_base)(n >> 8);
#endif

#if R_MANT_NUM > 3 // there is another valid segment
	// save lower part
	num->m[R_MANT_NUM-4] = (r_base)n;
#endif

#else // R_BASE_BITS == 8 // segment is 16 bits

	// save higher part of number into last mantissa segment
	num->m[R_MANT_NUM-1] = (r_base)(n >> 16);

#if R_MANT_NUM > 1 // there is another valid segment
	// save lower part
	num->m[R_MANT_NUM-2] = (r_base)n;
#endif

#endif // R_BASE_BITS == 8

	// save exponent
	num->exp = exp;

#endif // R_BASE_BYTES >= 4
}

// set signed integer value
void RealSetInt(REAL* num, r_bases n)
{
	if (n < 0) // negative number
	{
		RealSetUInt(num, (r_base)-n);
		RealNeg(num);
	}
	else // positive number
		RealSetUInt(num, n);
}

void RealSetS8(REAL* num, s8 n)
{
	RealSetInt(num, n);
}

void RealSetS16(REAL* num, s16 n)
{
#if R_BASE_BYTES >= 2 // size of segment is "word" or more
	RealSetInt(num, n);
#else

	if (n < 0) // negative number
	{
		RealSetU16(num, (u16)-n);
		RealNeg(num);
	}
	else // positive number
		RealSetU16(num, n);
#endif
}

void RealSetS32(REAL* num, s32 n)
{
#if R_BASE_BYTES >= 4 // size of segment is "dword" or more
	RealSetInt(num, n);
#else

	if (n < 0) // negative number
	{
		RealSetU32(num, (u32)-n);
		RealNeg(num);
	}
	else // positive number
		RealSetU32(num, n);
#endif
}

// get unsigned integer value (rounded towards zero)
r_base RealGetUInt(const REAL* num)
{
	r_base k;
	r_exps exp;
	Bool sign;

	// number is < 1 (negative or small positive), return zero
	sign = RealIsNeg(num);
	exp = num->exp;
	if (sign || (exp < 0)) return 0;

	// check overflow
	if (exp >= R_BASE_BITS) return R_BASE_MASK;

	// load whole segment
	k = num->m[R_MANT_NUM-1];

	// restore hidden bit
	k |= R_BASE_LAST;

	// shift to valid position
	k >>= R_BASE_BITS - 1 - exp;

	return k;
}

u8 RealGetU8(const REAL* num)
{
	r_base n = RealGetUInt(num);
#if R_BASE_BYTES > 1 // size of segment is "word" or more
	if (n > 0xff) n = 0xff;
#endif
	return (u8)n;
}

u16 RealGetU16(const REAL* num)
{
#if R_BASE_BYTES > 1 // size of segment is "word" or more

	r_base n = RealGetUInt(num);
#if R_BASE_BYTES > 2 // size of segment is "dword" or more
	if (n > 0xffff) n = 0xffff;
#endif
	return (u16)n;

#else // R_BASE_BYTES > 1

// base is u8

	u16 k;
	r_exps exp;
	Bool sign;

	// number is < 1 (negative or small positive), return zero
	sign = RealIsNeg(num);
	exp = num->exp;
	if (sign || (exp < 0)) return 0;

	// check overflow
	if (exp >= 16) return 0xffff;

	// load higher part
	k = num->m[R_MANT_NUM-1];
	k <<= 8;

#if R_MANT_NUM > 1 // there is another valid segment
	// load lower part
	k |= num->m[R_MANT_NUM-2];
#endif

	// restore hidden bit
	k |= 0x8000;

	// shift to valid position
	k >>= 16 - 1 - exp;

	return k;

#endif // R_BASE_BYTES > 1

}

u32 RealGetU32(const REAL* num)
{
#if R_BASE_BYTES > 2 // size of segment is "dword" or more

	return RealGetUInt(num);

#elif R_BASE_BYTES > 1 // size of segment is "word"

// base is u16

	u32 k;
	r_exps exp;
	Bool sign;

	// number is < 1 (negative or small positive), return zero
	sign = RealIsNeg(num);
	exp = num->exp;
	if (sign || (exp < 0)) return 0;

	// check overflow
	if (exp >= 32) return 0xffffffff;

	// load higher part
	k = num->m[R_MANT_NUM-1];
	k <<= 16;

#if R_MANT_NUM > 0 // there is another valid segment
	// load lower part
	k |= num->m[R_MANT_NUM-2];
#endif

	// restore hidden bit
	k |= 0x80000000;

	// shift to valid position
	k >>= 32 - 1 - exp;

	return k;

#else // R_BASE_BYTES > 1

// base is u8

	u32 k;
	r_exps exp;
	Bool sign;

	// number is < 1 (negative or small positive), return zero
	sign = RealIsNeg(num);
	exp = num->exp;
	if (sign || (exp < 0)) return 0;

	// check overflow
	if (exp >= 32) return 0xffffffff;

	// load higher part
	k = num->m[R_MANT_NUM-1];
	k <<= 24;

#if R_MANT_NUM > 1 // there is another valid segment
	// load middle part
	k |= (u32)num->m[R_MANT_NUM-2] << 16;
#endif

#if R_MANT_NUM > 2 // there is another valid segment
	// load middle part
	k |= (u32)num->m[R_MANT_NUM-3] << 8;
#endif

#if R_MANT_NUM > 3 // there is another valid segment
	// load lower part
	k |= num->m[R_MANT_NUM-4];
#endif

	// restore hidden bit
	k |= 0x80000000;

	// shift to valid position
	k >>= 32 - 1 - exp;

	return k;

#endif // R_BASE_BYTES > 1

}

// get signed integer value (rounded towards zero)
// - source number can be temporary modified (and then restored back)
r_bases RealGetInt(REAL* num)
{
	r_base res;

	if (RealIsNeg(num))
	{
		RealNeg(num);
		res = RealGetUInt(num);
		RealNeg(num);
		if (res > R_BASE_LAST) res = R_BASE_LAST;
		return -(r_bases)res;
	}

	res = RealGetUInt(num);
	if (res > R_BASES_MAX) res = R_BASES_MAX;
	return (r_bases)res;
}

s8 RealGetS8(REAL* num)
{
	r_bases n = RealGetInt(num);
#if R_BASE_BYTES > 1 // size of segment is "word" or more
	if (n > 0x7f) n = 0x7f;
	if (n < (s8)-0x80) n = -0x80;
#endif
	return (s8)n;
}

s16 RealGetS16(REAL* num)
{
#if R_BASE_BYTES > 1 // size of segment is "word" or more

	r_bases n = RealGetInt(num);
#if R_BASE_BYTES > 2 // size of segment is "dword" or more
	if (n > 0x7fff) n = 0x7fff;
	if (n < (s16)-0x8000) n = -0x8000;
#endif
	return (s16)n;

#else // R_BASE_BYTES > 1

// base is 8 bit

	u16 res;

	if (RealIsNeg(num))
	{
		RealNeg(num);
		res = RealGetU16(num);
		RealNeg(num);
		if (res > 0x8000) res = 0x8000;
		return -(s16)res;
	}

	res = RealGetU16(num);
	if (res > 0x7fff) res = 0x7fff;
	return (s16)res;

#endif // R_BASE_BYTES > 1
}

s32 RealGetS32(REAL* num)
{
#if R_BASE_BYTES > 2 // size of segment is "dword" or more

	return (s32)RealGetInt(num);

#else // R_BASE_BYTES > 2

// base is 8 or 16 bit

	u32 res;

	if (RealIsNeg(num))
	{
		RealNeg(num);
		res = RealGetU32(num);
		RealNeg(num);
		if (res > 0x80000000) res = 0x80000000;
		return -(s32)res;
	}

	res = RealGetU32(num);
	if (res > 0x7fffffff) res = 0x7fffffff;
	return (s32)res;

#endif // R_BASE_BYTES > 2
}

// set minimal positive number
void RealSetMin(REAL* num)
{
	RealSet0(num);
	num->exp = R_EXP_MIN;
}

// set maximal positive number
void RealSetMax(REAL* num)
{
	int i;
	r_base* d = num->m;
	for (i = R_MANT_NUM-1; i > 0; i--) *d++ = R_BASE_MASK;
	*d = ~R_BASE_LAST;
	num->exp = R_EXP_MAX;
	RealAbs(num);
}

// copy number
void RealCopy(REAL* dst, const REAL* src)
{
	int i;
	r_base* d = dst->m;
	const r_base* s = src->m;
	for (i = R_MANT_NUM; i > 0; i--) *d++ = *s++;
	dst->exp = src->exp;
}

// exchange numbers
void RealExch(REAL* num1, REAL* num2)
{
	int i;
	r_base k;
	r_exps kk;
	r_base* d = num1->m;
	r_base* s = num2->m;
	for (i = R_MANT_NUM; i > 0; i--)
	{
		k = *s;
		*s = *d;
		*d = k;
		s++;
		d++;
	}
	kk = num1->exp;
	num1->exp = num2->exp;
	num2->exp = kk;
}

// export into memory number
void RealSave(REAL* num, MEM* mem)
{
	u8 a, b;
	s32 exp;
	u32 exp2;
	int i, j;
	u8 *s, *d;

	// prepare exponent
	exp = num->exp + M_EXP_BIAS;

	// prepare pointers to copy mantissa
	s = (u8*)&num->m[R_MANT_NUM] - 1;
	d = &mem->m[M_MANT_BYTES-1];
	j = R_MANT_BYTES;

#if M_MANT_OFF == 7
	// copy mantissa not shifted
	for (i = M_MANT_BYTES; i > 0; i--)
	{
		a = (j-- > 0) ? *s-- : 0;
		*d-- = a;
	}
	b = (j-- > 0) ? *s-- : 0;
	b >>= 7;

#elif M_MANT_OFF == 8
	// copy mantissa shifted left
	j--;
	a = *s-- << 1;
	b = (j-- > 0) ? *s-- : 0;
	*d-- = a | (b >> 7);

	for (i = M_MANT_BYTES-1; i > 0; i--)
	{
		a = (j-- > 0) ? *s-- : 0;
		*d-- = (b << 1) | (a >> 7);
		b = a;
	}
	b >>= 7;

#else // M_MANT_OFF

	// copy mantissa - shifted right
	j--;
	a = *s--;
	b = a;
	a >>= 7 - M_MANT_OFF;
	*d-- = a;

	for (i = M_MANT_BYTES-1; i > 0; i--)
	{
		a = (j-- > 0) ? *s-- : 0;
		*d-- = (a >> (7 - M_MANT_OFF)) | (b << (M_MANT_OFF + 1));
		b = a;
	}

	b >>= M_MANT_OFF-1;

#endif // M_MANT_OFF

	// round up
	if ((b & 1) != 0)
	{
		s = mem->m;
		for (i = M_MANT_BYTES-1; i > 0; i++)
		{
			a = *s + 1;
			*s++ = a;
			if (a != 0) break;
		}
		if (i == 0)
		{
			a = (*s + 1) & M_MANT_MASK;
			*s++ = a;

			// overflow 0xfff... -> 0x1000...
			if (a == 0)
			{
				for (i = 0; i < M_MANT_BYTES; i++) mem->m[i] = 0;
				exp++;
			}
		}
	}

	// check exponent
	if (exp > (s32)M_EXP_MAX)
	{
		// overflow
		Error(ERR_OVERFLOW);
		for (i = 0; i < M_BYTES; i++) mem->m[i] = 0xff;
		if (!RealIsNeg(num)) mem->m[M_BYTES-1] = 0x7f;
		return;
	}

	if (exp < (s32)M_EXP_MIN)
	{
		// underflow or zero
		for (i = 0; i < M_BYTES; i++) mem->m[i] = 0;
		return;
	}

	// set exponent and sign
	exp2 = *(u32*)&mem->m[M_EXP_INX];
	exp2 &= ((u32)-1) >> (32 - M_EXP_OFF);
	exp2 |= (exp << M_EXP_OFF);
	if (RealIsNeg(num)) exp2 |= B31;
	*(u32*)&mem->m[M_EXP_INX] = exp2;
}

// import from memory number
void RealLoad(REAL* num, MEM* mem)
{


}

// --- arithmetic operations

// multiply 2 numbers (source and destination can be the same)
// - source numbers can be temporary modified (and then restored back)
void RealMul(REAL* dst, REAL* src1, REAL* src2)
{
	r_base last1, last2, a, b, rL, rH, k, carry;
	Bool sign1, sign2;
	REAL *m1, *m2;
	r_base *mem, *d, *s1, *s2;
	r_exps exp1, exp2;
	r_dblexps exp;
	int i, j;

	// some of the numbers is zero - result will be zero
	if (RealIsZero(src1) || RealIsZero(src2))
	{
		RealSet0(dst);
		return;
	}

	// save signs
	sign1 = RealIsNeg(src1);
	sign2 = RealIsNeg(src2);

	// save exponents
	exp1 = src1->exp;
	exp2 = src2->exp;

	// restore hidden bits
	RealDenorm(src1);
	RealDenorm(src2);

	// clear accumulator (size over 2 numbers)
	m1 = CalcNew();
	m2 = CalcNew();
	mem = m1->m; 
	for (i = 0; i < R_MANT_NUM*2; i++) mem[i] = 0;

	// multiply mantissas
	// min. 0080 0000 * 0080 0000 = 0000 4000 0000 0000
	// max. 00FF FFFF * 00FF FFFF = 0000 FFFF FE00 0001
	s2 = src2->m;
	for (i = R_MANT_NUM; i > 0; i--)
	{
		b = *s2++;
		if (b != 0)
		{
			carry = 0;
			d = mem;
			s1 = src1->m;
			for (j = R_MANT_NUM; j > 0; j--)
			{
				// load segment of 1st number
				a = *s1++;

				if ((a != 0) || (carry != 0))
				{
					// multiply a * b -> rH:rL (max. FFFFFFFE:00000001)
					RealMulInt(&rL, &rH, a, b);

					// carry from lower segment (result is max. 1FFFFFFFF)
					rL += carry;

					// new carry?
					carry = (rL < carry) ? 1 : 0;

					// new carry to higher segment (cannot overflow, result is max. FFFFFFFF)
					carry += rH;

					// get old destination segment (max. FFFFFFFF)
					k = *d;

					// add to new segment LOW (result is max. 1FFFFFFFF)
					rL += k;

					// new carry (here will be no overflow of result)
					carry += (rL < k) ? 1 : 0;

					// save new segment LOW
					*d = rL;
				}
				d++;
			}

			// save carry
			*d = carry;
		}
		mem++;
	}

	// add exponents
	exp = (r_dblexps)exp1 + (r_dblexps)exp2 + 1;

	// copy result to destination buffer
	d = dst->m;
	s1 = &m1->m[R_MANT_NUM]; // start of 2nd number (= result HIGH)
	for (i = R_MANT_NUM; i > 0; i--) // copy mantissa including hidden bit
	{
		a = *s1++;
		*d++ = a;
	}

	// lowest bit
	carry = ((m1->m[R_MANT_NUM-1] & R_BASE_LAST) == 0) ? 0 : 1;

	// normalize mantissa if result is too low
	if ((dst->m[R_MANT_NUM-1] & R_BASE_LAST) == 0)
	{
		RealShiftL(dst, (u8)carry);
		carry = ((m1->m[R_MANT_NUM-1] & (R_BASE_LAST >> 1)) == 0) ? 0 : 1;
		exp--;
	}

	// round result
	if (carry)
	{
		if (RealMantInc(dst))
		{
			RealShiftR(dst, 1);
			exp++;
		}
	}

	// delete temporary registers
	CalcDelN(2);

	// restore source numbers
	RealSetSign(src1, sign1);
	RealSetSign(src2, sign2);

	// result is too small
	if (exp < (r_dblexps)R_EXP_MIN)
	{
		RealSet0(dst);
		return;
	}

	// set exponent
	dst->exp = (r_exps)exp;

	// set sign
	RealSetSign(dst, sign1 ^ sign2);

	// check exponent overflow
	if (exp > (r_dblexps)R_EXP_MAX)
	{
		Error(ERR_OVERFLOW);
		RealSetMax(dst);
		RealSetSign(dst, sign1 ^ sign2);
	}
}

// square x^2
void RealSqr(REAL* num)
{
	RealMul(num, num, num);
}

// divide 2 numbers (source and destination can be the same)
// dst = result quotient, src1 = dividend, src2 = divisor
// - source number src2 can be temporary modified (and then restored back)
void RealDiv(REAL* dst, const REAL* src1, REAL* src2)
{
	r_base a, b, m, *d, *s;
	u8 carry;
	Bool sign, sign2;
	r_exps exp2;
	r_dblexps exp;
	REAL *mem, *res;
	int i, j;

	// divisor is 0, overflow
	if (RealIsZero(src2))
	{
		Error(ERR_OVERFLOW);
		RealSetMax(dst);
		return;
	}

	// dividend is zero - result will be zero (or 1 if dividing 0/0 and ignoring errors)
	if (RealIsZero(src1))
	{
		if (RealIsZero(src2))
			RealSet1(dst);
		else
			RealSet0(dst);
		return;
	}

	// load dividend src1 into mem
	mem = CalcNew();
	RealCopy(mem, src1);

	// prepare quotient (result) accumulator
	res = CalcNew();
	RealSet0(res);
	m = 0; // to save 2 extra bits

	// save src2
	sign2 = RealIsNeg(src2);
	exp2 = src2->exp;

	// prepare exponent
	exp = (r_dblexps)src1->exp - exp2;

	// prepare sign of result
	sign = RealIsNeg(src1) ^ sign2;

	// restore hidden bits
	RealDenorm(mem);
	RealDenorm(src2);

	// loop through bits of mantissa + 1 extra loop
	i = R_MANT_BITS+1;
	carry = 0;
	for (;;)
	{
		// carry from dividend - dividend is higher than divisor, subtract only
		if (carry != 0)
		{
			carry = 0;
			s = src2->m;
			d = mem->m;
			for (j = R_MANT_NUM; j > 0; j--)
			{
				b = *s + carry;
				carry = (b < carry) ? 1 : 0;
				a = *d;
				carry += (a < b) ? 1 : 0;
				*d = a - b;
				d++;
				s++;
			}
			carry = 1;
		}
		else
		{
			// try to subtract divisor from dividend
			s = src2->m;
			d = mem->m;
			for (j = R_MANT_NUM; j > 0; j--)
			{
				b = *s + carry;
				carry = (b < carry) ? 1 : 0;
				a = *d;
				carry += (a < b) ? 1 : 0;
				*d = a - b;
				d++;
				s++;
			}

			// carry, dividend is smaller than divisor, restore dividend
			if (carry)
			{
				// add divisor back to dividend
				carry = 0;
				s = src2->m;
				d = mem->m;
				for (j = R_MANT_NUM; j > 0; j--)
				{
					a = *d + carry;
					carry = (a < carry) ? 1 : 0;
					b = *s;
					a += b;
					carry += (a < b) ? 1 : 0;
					*d = a;
					d++;
					s++;
				}
				carry = 0;
			}
			else
				carry = 1;
		}

		// loop counter
		i--;

		// one extra loop to get additional 2 bits
		if (i <= 0)
		{
			m <<= 1;
			m |= carry;
			if (i < 0) break;
		}
		else
			// shift result quotient left, adding result carry from right
			RealShiftL(res, carry);

		// shift dividend left
		carry = RealShiftL(mem, 0);
	}

	// get extra 2 bits on highest position
	m <<= R_BASE_BITS-2;

	// normalize mantissa if result is too low
	for (i = R_MANT_BITS; i > 0; i--)
	{
		if ((res->m[R_MANT_NUM-1] & R_BASE_LAST) != 0) break;
		RealShiftL(res, ((m & R_BASE_LAST) == 0) ? 0 : 1);
		m <<= 1;
		exp--;
	}

	// round result
	if ((m & R_BASE_LAST) != 0)
	{
		if (RealMantInc(res))
		{
			RealShiftR(res, 1);
			exp++;
		}
	}

	// restore source number
	RealSetSign(src2, sign2);

	// underflow, result is 0
	if ((i == 0) || (exp < (r_dblexps)R_EXP_MIN))
	{
		RealSet0(dst);
		CalcDelN(2);
		return;
	}

	// set exponent
	res->exp = (r_exps)exp;

	// set sign
	RealSetSign(res, sign);

	// check exponent overflow
	if (exp > (r_dblexps)R_EXP_MAX)
	{
		Error(ERR_OVERFLOW);
		RealSetMax(res);
		RealSetSign(res, sign);
	}

	// save result
	RealCopy(dst, res);

	CalcDelN(2);
}

// reciprocal value 1/x
void RealRec(REAL* num)
{
	RealDiv(num, &RealConst1, num);
}

// modulus  (source and destination can be the same)
// dst = result quotient, src1 = dividend, src2 = divisor
// - source number src2 can be temporary modified (and then restored back)
void RealMod(REAL* dst, const REAL* src1, REAL* src2)
{
	// divide a/b
	REAL* m1 = CalcNew();
	RealDiv(m1, src1, src2);

	// truncate a/b (round towards zero)
	RealTrunc(m1);

	// multiply trunc(a/b)*b
	RealMul(m1, m1, src2);

	// substract a - trunc(a/b)*b
	RealSub(dst, src1, m1);

	CalcDel();
}

// multiply by 2 (increases exponent by 1)
void RealMul2(REAL* num)
{
	r_exps exp = num->exp;
	if (exp == R_EXP_0) return; // number is zero
	if (exp == R_EXP_MAX)
	{
		// overflow
		Error(ERR_OVERFLOW);
		RealSetMax(num);
	}
	else
		num->exp = exp + 1;
}

// divide by 2 (decreases exponent by 1)
void RealDiv2(REAL* num)
{
	r_exps exp = num->exp;
	if (exp == R_EXP_0) return; // number is zero
	num->exp = exp - 1;
}

// add 2 numbers (source and destination can be the same)
void RealAdd(REAL* dst, const REAL* src1, const REAL* src2)
{
	REAL *m1, *m2;
	r_base a, b, k, *s, *d, h1, h2;
	r_exps exp1, exp2;
	r_dblexps exp;
	Bool sign, sign1, sign2;
	u8 carry;
	int i;

	// 1st number is zero
	if (RealIsZero(src1))
	{
		RealCopy(dst, src2);
		return;
	}

	// 2nd number is zero
	if (RealIsZero(src2))
	{
		RealCopy(dst, src1);
		return;
	}

	// get operands into temporary memory
	m1 = CalcNew();
	RealCopy(m1, src1);
	m2 = CalcNew();
	RealCopy(m2, src2);

	// load exponents and signs
	exp1 = m1->exp;
	exp2 = m2->exp;
	sign1 = RealIsNeg(m1);
	sign2 = RealIsNeg(m2);

	// prepare 1st number - correct sign
	RealDenorm(m1);
	h1 = 0; // extra high segment
	if (sign1)
	{
		h1 = ~h1;
		if (RealMantNeg(m1)) h1++;
	}

	// prepare 2nd number - correct sign
	RealDenorm(m2);
	h2 = 0; // extra high segment
	if (sign2)
	{
		h2 = ~h2;
		if (RealMantNeg(m2)) h2++;
	}

	// sort numbers - 2nd exponent must not be less than 1st one
	sign = sign1;
	if (exp2 < exp1)
	{
		m1 = CalcTop();
		m2 = CalcPreTop();
		exp1 = src2->exp;
		exp2 = src1->exp;
		sign = sign2;
		a = h1;
		h1 = h2;
		h2 = a;
	}

	// prepare new exponent (= exponent of 2nd number)
	exp = exp2;

	// difference of exponents
	exp2 -= exp1;

	// shift 1st number right to normalize numbers to the same exponent
	carry = 0;
	while (exp2 > 0)
	{
		carry = RealShiftR(m1, sign);
		exp2--;
	}

	// add numbers
	d = m1->m;
	s = m2->m;
	for (i = R_MANT_NUM; i > 0; i--)
	{
		a = *d + carry;
		carry = (a < carry) ? 1 : 0;
		b = *s;
		a += b;
		carry += (a < b) ? 1 : 0;
		*d = a;
		d++;
		s++;
	}

	// add extra high segment (to get sign of result)
	h1 = h1 + h2 + carry;

	// prepare sign flag and negate result
	sign = ((h1 & R_BASE_LAST) == 0) ? 0 : 1;
	if (sign)
	{
		h1 = ~h1;
		if (RealMantNeg(m1)) h1++;
	}

	// overflow
	if (h1 != 0)
	{
		carry = RealShiftR(m1, 1);
		exp++;
		if (carry) RealMantInc(m1); // will not overflow
	}

	// normalize mantissa if result is too low (trim very small results)
	for (i = R_MANT_BITS - R_TRIM; i > 0; i--)
	{
		if ((m1->m[R_MANT_NUM-1] & R_BASE_LAST) != 0) break;
		RealShiftL(m1, 0);
		exp--;
	}

	// underflow, result is 0
	if ((i == 0) || (exp < (r_dblexps)R_EXP_MIN))
	{
		RealSet0(dst);
		CalcDelN(2);
		return;
	}

	// set exponent
	m1->exp = (r_exps)exp;

	// set sign
	RealSetSign(m1, sign);

	// check exponent overflow
	if (exp > (r_dblexps)R_EXP_MAX)
	{
		Error(ERR_OVERFLOW);
		RealSetMax(m1);
		RealSetSign(m1, sign);
	}

	// save result
	RealCopy(dst, m1);

	CalcDelN(2);
}

// subtract 2 numbers (source and destination can be the same)
// - source number src2 can be temporary modified (and then restored back)
void RealSub(REAL* dst, const REAL* src1, REAL* src2)
{
	RealNeg(src2);
	RealAdd(dst, src1, src2);
	if (dst != src2) RealNeg(src2);
}

// increase number by 1
void RealInc(REAL* num)
{
	RealAdd(num, num, &RealConst1);
}

// decrease number by 1
void RealDec(REAL* num)
{
	RealAdd(num, num, &RealConstM1);
}

// power of 2 numbers (y = base^exp)
// - exp can be temporary modified (and then restored back)
void RealPow(REAL* dst, const REAL* base, REAL* exp)
{
	Bool sign;
	REAL* m;
	int i;

	// exponent is 0, result is 1
	if (RealIsZero(exp))
	{
		RealSet1(dst);
		return;
	}

	// base is 0
	if (RealIsZero(base))
	{
		// exponent is > 0, result is 0
		if (!RealIsNeg(exp))
		{
			RealSet0(dst);
			return;
		}

		// exponent is < 0, overflow error, divide by zero
		Error(ERR_OVERFLOW);
		RealSetMax(dst);
		return;
	}

	// negative base - allowed only if exponent is integer
	sign = False;
	if (RealIsNeg(base))
	{
		m = CalcNew();
		RealCopy(m, exp);
		RealTrunc(m); // truncate exponent to integer
		i = RealComp(m, exp); // is exponent integer?
		if (i != 0) // number is not integer
		{
			CalcDel();
			Error(ERR_PARAM); // incorrect parameter
		}
		else
		{
			// exp is integer; check if exponent is odd
			RealInc(m); // increment exponent
			RealDiv2(m); // divide number by 2
			RealTrunc(m); // truncate exponent to integer
			RealMul2(m); // multuply number by 2
			if (RealComp(m, exp) != 0) sign = True; // exponent is odd, result will be negative
			CalcDel();
		}
	}

	// get logarithm of the base
	RealCopy(dst, base);
	RealAbs(dst);
	RealLn(dst);

	// multiply by exponent
	RealMul(dst, dst, exp);

	// back to exponent
	RealExp(dst);

	// set sign
	RealSetSign(dst, sign);
}

// compare 2 numbers (returns COMP_LESS=-1, COMP_EQU=0 or COMP_GREATER=1)
int RealComp(const REAL* num1, const REAL* num2)
{
	int res, i;
	Bool sign1, sign2;
	r_base k1, k2;
	const r_base* s1;
	const r_base* s2;
	r_exps exp1, exp2;

	// load signs (True = negative)
	sign1 = RealIsNeg(num1);
	sign2 = RealIsNeg(num2);

	// 1st is positive, 2nd negative
	if (!sign1 && sign2) return COMP_GREATER;

	// 1st is negative, 2nd positive
	if (sign1 && !sign2) return COMP_LESS;

	// prepare result - for case if 1st positive > 2nd positive
	res = (!sign1) ? COMP_GREATER : COMP_LESS;

	// compare exponents
	exp1 = num1->exp;
	exp2 = num2->exp;
	if (exp1 > exp2) return res;
	if (exp1 < exp2) return -res;

	// compare numbers
	s1 = &num1->m[R_MANT_NUM-1];
	s2 = &num2->m[R_MANT_NUM-1];
	for (i = R_MANT_NUM; i > 0; i--)
	{
		k1 = *s1--;
		k2 = *s2--;
		if (k1 > k2) return res;
		if (k1 < k2) return -res;
	}

	// numbers are equal
	return COMP_EQU;
}

// compare 2 absolute values of numbers, without sign (returns COMP_LESS=-1, COMP_EQU=0 or COMP_GREATER=1)
int RealCompAbs(const REAL* num1, const REAL* num2)
{
	int res, i;
	r_base k1, k2;
	const r_base* s1;
	const r_base* s2;
	r_exps exp1, exp2;

	// compare exponents
	exp1 = num1->exp;
	exp2 = num2->exp;
	if (exp1 > exp2) return COMP_GREATER;
	if (exp1 < exp2) return COMP_LESS;

	// compare numbers
	s1 = &num1->m[R_MANT_NUM-1];
	s2 = &num2->m[R_MANT_NUM-1];
	for (i = R_MANT_NUM; i > 0; i--)
	{
		k1 = *s1--;
		k2 = *s2--;
		if (k1 > k2) return COMP_GREATER;
		if (k1 < k2) return COMP_LESS;
	}

	// numbers are equal
	return COMP_EQU;
}

// compare number to zero (returns COMP_LESS=-1, COMP_EQU=0 or COMP_GREATER=1)
int RealComp0(const REAL* num)
{
	if (RealIsNeg(num)) return COMP_LESS; // negative number
	if (RealIsZero(num)) return COMP_EQU; // zero
	return COMP_GREATER; // positive
}

// truncation towards zero
void RealTrunc(REAL* num)
{
	int i;
	r_base *s;
	r_exps exp;

	// get exponent
	exp = num->exp;

	// small number < 1 can be made zero
	if (exp < 0)
	{
		RealSet0(num);
		return;
	}

	// big number is always integer
	if (exp >= R_MANT_BITS) return;

	// prepare number of bits to clear (range 1..R_MANT_BITS)
	i = R_MANT_BITS - exp;

	// reset segments
	s = num->m;
	for (; i >= R_BASE_BITS; i -= R_BASE_BITS) *s++ = 0;

	// reset remaining bits
	if (i > 0) *s = *s & (R_BASE_MASK << i);
}

// fractional part
void RealFrac(REAL* num)
{
	REAL* m = CalcNew();
	RealCopy(m, num);
	RealTrunc(m);
	RealSub(num, num, m);
	CalcDel();
}

// round down (integer)
void RealFloor(REAL* num)
{
	REAL* m;

	// positive number or 0 is truncated towards zero
	if (!RealIsNeg(num))
	{
		RealTrunc(num);
		return;
	}

	// save original number
	m = CalcNew();
	RealCopy(m, num);

	// truncate negative number towards zero
	RealTrunc(num);

	// number has been changed - decrease by 1
	if (RealComp(num, m) != COMP_EQU) RealDec(num);

	CalcDel();
}

// round up
void RealCeil(REAL* num)
{
	REAL* m;

	// zero
	if (RealIsZero(num)) return;

	// negative number is truncated towards zero
	if (RealIsNeg(num))
	{
		RealTrunc(num);
		return;
	}

	// save original number
	m = CalcNew();
	RealCopy(m, num);

	// truncate positive number towards zero
	RealTrunc(num);

	// number has been changed - increase by 1
	if (RealComp(num, m) != COMP_EQU) RealInc(num);

	CalcDel();
}

// round number to nearest integer
void RealRound(REAL* num)
{
	RealAdd(num, num, &RealConst05); // add 0.5
	RealFloor(num); // round down
}

// convert number to text buffer for calculator (minimal size of buffer must be RealFlagDisp)
// (TI-58 has display 12 digits: "-3.1415927+00", "-3.141592654 " .3141592654 ")
// - setup function by parameters RealFlagDisp...
// - always saves sign '+', '-' or ' '
// - number is aligned to the right
// - decimal point is not encoded as character, but it is added to the digit as bit 7
// - if decimal point is on 1st position, zero will be substituted by the sign character (another digit cannot occur there)
void RealToText(const REAL* num, char* buf)
{
	r_exps exp, exp2;
	r_exps exp10, m;
	REAL *m1, *m2;
	char *s, *d, ch;
	int i, ntot, nint, ndec, nzer, nexp;
	Bool isexp;
	Bool sign;
	Bool restart;

	m1 = CalcNew();
	m2 = CalcNew();

	sign = RealIsNeg(num);	// sign

	// number is zero
	if (RealIsZero(num))
	{
		exp10 = 0;
		RealSet0(m1);
	}
	else
	{
		// calculate exponent in decimal form; EXP10 = (exp2+2|-1) * Log10(2)
		exp = num->exp; // load exponent
#if R_EXP_MAXBITS == 8 // save exponent into m1
		RealSetS8(m1, exp);
#elif R_EXP_MAXBITS == 16
		RealSetS16(m1, exp);
#else // R_EXP_MAXBITS == 32
		RealSetS32(m1, exp);
#endif
		if (exp < 0) // negative exponent (number < 1) ?
			RealAdd(m1, m1, &RealConstM1); // m1 = exp2 -1
		else
			RealAdd(m1, m1, &RealConst2); // m1 = exp2 +2
		RealMul(m1, m1, &RealConstLog2); // multiply (exp2 +2|-1) * Log10(2)
#if R_EXP_MAXBITS == 8 // load exponent from m1
		exp10 = RealGetS8(m1);
#elif R_EXP_MAXBITS == 16
		exp10 = RealGetS16(m1);
#else // R_EXP_MAXBITS == 32
		exp10 = (r_exps)RealGetS32(m1);
#endif

		// divide mantissa by decimal exponent
		RealCopy(m1, num);
		RealAbs(m1);
		m = 1; // bit mask
		if (exp10 >= 0)
		{
			// positive exponent
			for (i = R_DECEXP-1; i >= 0; i--) // starting with exponent 0.1, index -1
			{
				if ((exp10 & m) != 0) RealMul(m1, m1, &RealDecExp[i]);
				m <<= 1;
			}
		}
		else
		{
			// negative exponent
			exp10 = -exp10;

			for (i = R_DECEXP+1; i < R_DECEXP*2+1; i++) // starting with exponent 10, index 1
			{
				if ((exp10 & m) != 0) RealMul(m1, m1, &RealDecExp[i]);
				m <<= 1;
			}

			exp10 = -exp10;
		}

		// mantissa is now in range 0.25..5 (or 0), correction to get into range 1..9.99999
		if (RealComp(m1, &RealConst1) < 0)
		{
			RealMul(m1, m1, &RealConst10);
			exp10--;
		}
	}

	// restart calculations if rounding increases exponent (increase mantissa 9.9999 -> 10.0000)
	restart = False;
Restart:

// ---- here we have positive mantissa (m1) in range 1..9.9999, signed exponent (exp10) and sign

	// prepare total number of digits of mantissa -> ntot
	ntot = RealFlagDisp - 1; // max. number of digits (1 place is reserved for sign)
	if (ntot > RealFlagDig) ntot = RealFlagDig; // limit number of digits

	// check if use exponent mode -> isexp
	isexp = RealFlagExp || RealFlagEng || (exp10 >= ntot);

	// use exponent mode for exponent < AUTOEXP in auto mode
	if (RealFlagAuto && (exp10 < AUTOEXP)) isexp = True;
		
	// use exponent mode for small numbers only if not fixed decimals
	if ((RealFlagFix < 0) && (exp10 < -ntot)) isexp = True;

	// prepare exponent mode
	nzer = 0; // no additional zeroes on start of number (between decimal point and valid digits)
	nexp = 0; // no exponent digits
	if (isexp)
	{
		// prepare number of integer digits of mantissa
		nint = 1; // number of digits for normal exponent mode
		if (RealFlagEng) // engineer mode
		{
			// exp10= 4: 12345. -> 12.345e+03
			// exp10= 3: 1234.5 -> 1.2345e+03
			// exp10= 2: 123.45 -> 123.45e+00
			// exp10= 1: 12.345 -> 12.345e+00
			// exp10= 0: 1.2345 -> 1.2345e+00
			// exp10=-1: 0.12345 -> 123.45e-03
			// exp10=-2: 0.012345 -> 12.345e-03
			// exp10=-3: 0.0012345 -> 1.2345e-03
			// exp10=-4: 0.00012345 -> 123.45e-06
			nint = exp10;
			exp10 = exp10 / 3 * 3;
			nint = nint - exp10 + 1;
			if (nint < 1) // negative exponent
			{
				nint += 3;
				exp10 -= 3;
			}
		}

		// number of decimal places
		ndec = ntot - nint;
		if ((RealFlagFix >= 0) && (RealFlagFix < ndec)) ndec = RealFlagFix;

		// number of exponent digits (including sign and 'e')
		nexp = 1 + RealFlagExpDig;
		if (RealFlagUseExp) nexp++;

		// limit decimal places by free space in display buffer
		//  1 mantissa sign
		//	nint integer digits
		//  ...(ndec decimal digits)
		//  nexp exponent
		//  RealFlagExpDig exponent digits
		i = RealFlagDisp - 1 - nint - nexp;
		if (ndec > i) ndec = i;

	}
	else // prepare normal mode (decimal without exponent)
	{
		// prepare number of integer digits of mantissa
		nint = exp10 + 1;
		if (nint < 1) // negative exponent 0.00123
		{
			nzer = -nint; // additional zeroes on start of number (between decimal point and valid digits)
			nint = 0; // no integer digits
		}

		// number of decimal places
		ndec = ntot - nint;
		if ((RealFlagFix >= 0) && (RealFlagFix < ndec + nzer)) ndec = RealFlagFix - nzer;
		if (ndec < 0) // digits runs behind end
		{
			nzer += ndec; // decrease number of zeroes
			ndec = 0; // no valid decimal digits
		}

		// limit decimal places by free space in display buffer
		//  1 mantissa sign
		//	nint integer digits
		//  nzer additional zeroes
		//  ...(ndec decimal digits)
		//  RealFlagRight right spaces
		i = RealFlagDisp - 1 - nint - nzer - RealFlagRight;
		if (ndec > i)
		{
			ndec = i;
			if (ndec < 0) // number is out of display
			{
				nzer += ndec; // decrease number of zeroes
				ndec = 0; // no valid decimal digits
			}
		}
	}

	// new total number of digits
	ntot = nint + ndec;

	// add rounding correction (not in case or restart)
	if (!restart && (ntot > 0))
	{
		// add rounding correction to the mantissa
		RealAdd(m1, m1, &RealConstRound[ntot-1]);

		// raise mantissa 9.9999 -> 10.0000, normalize and restart
		if (RealComp(m1, &RealConst10) >= 0)
		{
			RealMul(m1, m1, &RealConst01);
			exp10++;
			restart = True;
			goto Restart;
		}
	}

	// clear destination buffer
	d = buf;
	for (i = RealFlagDisp; i > 0; i--) *d++ = ' ';

	// save sign
	d = buf;
	*d++ = sign ? '-' : '+';

	// store initial zeroes
	for (i = nzer; i > 0; i--) *d++ = '0';

	// decode digits of mantissa into destination buffer
	m2 = CalcTop();
	for (i = ntot; i > 0; i--)
	{
		// get 1 digit of mantissa
		ch = RealGetU8(m1);
		*d++ = ch + '0';

		// subtract digit from mantissa
		RealSetU8(m2, ch);
		RealSub(m1, m1, m2);

		// multiply mantissa * 10
		RealMul(m1, m1, &RealConst10);
	}

	// delete ending zeroes of decimal part
	if (RealFlagFix < 0)
	{
		for (; ndec > 0; ndec--)
		{
			if ((d[-1] != ' ') && (d[-1] != '0')) break;
			d--;
			*d = ' ';
			ntot--;
		}
	}

	// mark decimal point
	buf[1 + nint - 1] |= 0x80;

	// decode exponent
	if (isexp)
	{
		// save 'e' character
		if (RealFlagUseExp) *d++ = 'e';

		// save sign
		*d++ = (exp10 < 0) ? '-' : '+';

		// absolute value of exponent
		exp = (exp10 < 0) ? -exp10 : exp10;

		// decode exponent digits
		d += RealFlagExpDig-1;
		for (i = RealFlagExpDig; i > 0; i--)
		{
			exp2 = exp / 10;
			exp -= exp2 * 10;
			*d = (char)(exp + '0');
			exp = exp2;
			d--;
		}
	}

	// total length of text
	ntot = 1 + ntot + nzer + nexp;

	// starting position to align right
	nexp = (isexp) ? RealFlagDisp : (RealFlagDisp - RealFlagRight);
	nexp -= ntot;

	// shift number right
	if (nexp > 0)
	{
		s = buf + ntot - 1;
		d = s + nexp;
		for (i = ntot; i > 0; i--) *d-- = *s--;

		// insert first 0
		if (nint == 0)
		{
			*d = s[1] & 0x7f;
			d[1] = '0' | 0x80;
			d--;
			nexp--;
		}

		// clear old digits
		for (; nexp > 0; nexp--) *d-- = ' ';
	}

	CalcDelN(2);
}

// temporary variables of function RealFromText
//const char* _RealFTextBuf; // pointer into input buffer
//int _RealFTextLen; // remainging characters
//char _RealFTextDec; // saved decimal point, or 0 (=bit 7 in source buffer)

// read one character from text buffer - returns 0 if no other character
char _RealFGetCh()
{
	char ch;

	// get saved decimal point
	if (_RealFTextDec != 0) // saved decimal point?
	{
		_RealFTextDec = 0;
		return '.';
	}

	// load next character
	if (_RealFTextLen <= 0) return 0;
	ch = *_RealFTextBuf++;
	_RealFTextLen--;

	// digit with decimal point mark
	if ((ch & B7) != 0) // decimal point?
	{
		_RealFTextDec = '.';
		ch &= 0x7f;
	}
	return ch;
}

// return character pointer
void _RealFRet()
{
	// decimal point not saved
	if (_RealFTextDec == 0)
	{
		// return decimal point
		if ((_RealFTextBuf[-1] & B7) != 0)
		{
			_RealFTextDec = '.';
		}
		else // return pointers
		{
			_RealFTextBuf--;
			_RealFTextLen++;
		}
	}
	else
	{
		// clear decimal point*/
		_RealFTextDec = 0;
		_RealFTextBuf--;
		_RealFTextLen++;
	}
}

// skip spaces
void _RealFSpc()
{
	char ch;
	for (;;)
	{
		ch = _RealFGetCh(); // load character
		if (ch == 0) return; // end of text
		if ((ch < 0) || (ch > ' ')) // not white space
		{
			_RealFRet(); // return last character
			return;
		}
	}
}

// load number from text (returns remaining unused characters; decimal point may be marked as bit 7 of the digit)
int RealFromText(REAL* num, const char* buf, int len)
{
	char ch;
	Bool sign, signexp; // sign of the number and exponent
	Bool dec; // now in fecimal part
	r_dblexps exp, m; // exponent
	REAL *m1, *m2;
	int i;

	// prepare temporary variables
	_RealFTextBuf = buf;
	_RealFTextLen = len;
	_RealFTextDec = 0;

	// load sign
	sign = False;
	for (;;)
	{
		_RealFSpc(); // skip spaces
		ch = _RealFGetCh(); // load next character
		if (ch == '-')
			sign = !sign; // negate sign
		else if (ch != '+') // not plus
		{
			if (ch != 0) _RealFRet(); // return last character
			break;
		}
	}

	// load mantissa digits
	RealSet0(num);
	m1 = CalcNew();
	RealSet01(m1); // order of decimal digit
	m2 = CalcNew();
	dec = False; // we are now in integer part
	for (;;)
	{
		// load next digit
		ch = _RealFGetCh();
		if ((ch < '0') || (ch > '9'))
		{
			// switch to decimal part (we ignore more '.')
			if ((ch == '.') || (ch == ','))
			{
				dec = True;
				continue;
			}
			if (ch != 0) _RealFRet(); // return last character
			break;
		}

		// save number
		RealSetU8(m2, ch - '0');

		// we are in integer part
		if (!dec)
		{
			// multiply accumulator by 10
			RealMul(num, num, &RealConst10);

		}
		else // we are in decimal part
		{
			// multiply digit by coefficient 0.1,...
			RealMul(m2, m2, m1);

			// shift coefficient by 10
			RealMul(m1, m1, &RealConst01);
		}

		// add new digit to the accumulator
		RealAdd(num, num, m2);
	}

	// skip character 'E' or 'e'
	ch = _RealFGetCh();
	if ((ch != 'e') && (ch != 'E') && (ch != 0)) _RealFRet();

	// load sign of exponent
	signexp = False;
	for (;;)
	{
		ch = _RealFGetCh(); // load next character
		if (ch == '-')
			signexp = !signexp; // negate sign
		else if (ch != '+') // not plus
		{
			if (ch != 0) _RealFRet(); // return last character
			break;
		}
	}

	// load digits of exponent
	exp = 0;
	for (;;)
	{
		// load next digit
		ch = _RealFGetCh();
		if ((ch < '0') || (ch > '9'))
		{
			_RealFRet();
			break;
		}

		// add digit to accumulator
		exp *= 10;
		exp += (u8)(ch - '0');
	}

	// multiply mantissa by exponent
	m = 1; // bit mask
	if (signexp)
	{
		// negative exponent
		for (i = R_DECEXP-1; i >= 0; i--) // starting with exponent 0.1, index -1
		{
			if ((exp & m) != 0) RealMul(num, num, &RealDecExp[i]);
			m <<= 1;
		}
	}
	else
	{
		// positive exponent
		for (i = R_DECEXP+1; i < R_DECEXP*2+1; i++) // starting with exponent 10, index 1
		{
			if ((exp & m) != 0) RealMul(num, num, &RealDecExp[i]);
			m <<= 1;
		}
	}

	// sign correction
	if (sign) RealNeg(num);

	CalcDelN(2);

	// remaining characters
	return _RealFTextLen;
}

// convert angles DEG/RAD/GRAD
void RealDegRad(REAL* num) // deg->rad
{
	RealMul(num, num, &RealConstDegRad);
}

void RealRadDeg(REAL* num) // rad-->deg
{
	RealMul(num, num, &RealConstRadDeg);
}

void RealDegGrad(REAL* num) // deg->grad
{
	RealMul(num, num, &RealConstDegGrad);
}

void RealGradDeg(REAL* num) // grad->deg
{
	RealMul(num, num, &RealConstGradDeg);
}

void RealGradRad(REAL* num) // grad->rad
{
	RealMul(num, num, &RealConstGradRad);
}

void RealRadGrad(REAL* num) // rad->grad
{
	RealMul(num, num, &RealConstRadGrad);
}

// normalize angle in radians into range 0..PI*2 (= 0..360)
void RealNormRad(REAL* num)
{
	r_exps exp = num->exp;

	// zero
	if (exp == R_EXP_0) return;

	// for big angle (out of -16..+16) use modulus
	if ((exp < -4) || (exp > +4)) RealMod(num, num, &RealConstPi2);

	// normalize small angles
	while (RealComp0(num) < 0) RealAdd(num, num, &RealConstPi2);
	while (RealComp(num, &RealConstPi2) >= 0) RealAdd(num, num, &RealConstMPi2);
}

// sine (returns number of loops of iteration)
//  Taylor serie xi+1 = xi * -x^2/((2*i)*(2*i+1)) ... x0 = x
//  sin(x) = x/1! - x^3/3! + x^5/5! - x^7/7! + x^9/9! - ...
int RealSin(REAL* num)
{
	Bool neg;
	REAL* x2, *res, *fac;
	int loop;

	// normalize angle into range 0..PI*2
	RealNormRad(num);

	// normalize angle into range 0..PI
	neg = False;
	if (RealComp(num, &RealConstPi) >= 0) // if angle >= PI
	{
		RealSub(num, &RealConstPi2, num); // correction angle = PI*2 - angle
		neg = True; // negate result
	}

	// number is zero, result will be zero
	if (RealIsZero(num)) return 0;

	// square -x^2
	x2 = CalcNew();
	RealMul(x2, num, num);
	RealNeg(x2);

	// prepare result accumulator -> x
	res = CalcNew();
	RealCopy(res, num);

	// prepare factorial coefficient -> 1
	fac = CalcNew();
	RealSet1(fac);

	// iterations
	loop = 1;
	for (;; loop++)
	{
		// multiply member by -x^2
		RealMul(num, num, x2);

		// increment factorial coefficient
		RealInc(fac);

		// divide member by factorial coefficient
		RealDiv(num, num, fac);

		// increment factorial coefficient
		RealInc(fac);

		// divide member by factorial coefficient
		RealDiv(num, num, fac);

		// add member to accumulator
		RealAdd(res, res, num);

		// check epsilon of member
		if ((res->exp - num->exp > R_MANT_BITS + R_MANT_BITS/16) || RealIsZero(num)) break;
	}

	// limit range to -1..+1
	if (res->exp != 0) RealSet1(res);

	// negate result
	if (neg) RealNeg(res);

	// copy result
	RealCopy(num, res);

	CalcDelN(3);

	return loop;
}

// cosine
// cos = sin(x+PI/2)
void RealCos(REAL* num)
{
	RealAdd(num, num, &RealConstPi05);
	RealSin(num);
}

// tangent
// tan = sin/cos
void RealTan(REAL* num)
{
	REAL* m = CalcNew();
	RealCopy(m, num);
	RealSin(m);
	RealCos(num);
	RealDiv(num, m, num);
	CalcDel();
}

// cotangent
// cotan = cos/sin
void RealCoTan(REAL* num)
{
	REAL* m = CalcNew();
	RealCopy(m, num);
	RealSin(m);
	RealCos(num);
	RealDiv(num, num, m);
	CalcDel();
}

// arcus sine (returns number of loops of iteration)
// result is in range -PI/2..+PI/2
//  Taylor serie xi+1 = xi * (2*i-1)^2*x^2 / ((2*i)*(2*i+1)) ... x0 = x
//  arcsin(x) = x + x^3/2/3 + 3*x^5/2/4/5 + 3*5*x^7/2/4/6/7 +
int RealASin(REAL* num)
{
	Bool neg, alt;
	REAL* x2, *res, *fac;
	int loop;

	// number is zero, result will be zero
	if (RealIsZero(num)) return 0;

	// absolute value
	neg = RealIsNeg(num);
	RealAbs(num);

	// number is 1 - use pre-calculator value PI/2
	loop = RealComp(num, &RealConst1);
//#ifndef REALCALC
	if (loop == 0)
	{
		RealSetPi05(num);
		if (neg) RealNeg(num);
		return 0;
	}
//#endif

	// check if number is > 1 (invalid)
	if (loop > 0)
	{
		Error(ERR_PARAM);
		RealSet1(num);
	}

	// check if use alternate method (if > 0.75, we use sqrt(1 - x^2))
	alt = (RealComp(num, &RealConst075) > 0);
	if (alt)
	{
		RealSqr(num); // x^2
		RealSub(num, &RealConst1, num); // 1 - x^2
		RealSqrt(num); // sqrt(1 - x^2)
	}

	// square x^2
	x2 = CalcNew();
	RealMul(x2, num, num);

	// prepare result accumulator -> x
	res = CalcNew();
	RealCopy(res, num);

	// prepare factorial coefficient -> 1
	fac = CalcNew();
	RealSet1(fac);

	// iterations
	loop = 1;
	for (;; loop++)
	{
		// multiply member by x^2
		RealMul(num, num, x2);

		// multiply member by coefficient^2
		RealMul(num, num, fac);
		RealMul(num, num, fac);

		// increment factorial coefficient
		RealInc(fac);

		// divide member by factorial coefficient
		RealDiv(num, num, fac);

		// increment factorial coefficient
		RealInc(fac);

		// divide member by factorial coefficient
		RealDiv(num, num, fac);

		// add member to accumulator
		RealAdd(res, res, num);

		// check epsilon of member
		if ((res->exp - num->exp > R_MANT_BITS + R_MANT_BITS/16) || RealIsZero(num)) break;
	}

	// correction for alternate method
	if (alt)
	{
		RealNeg(res);
		RealAdd(res, &RealConstPi05, res);
	}

	// negate result
	if (neg) RealNeg(res);

	// copy result
	RealCopy(num, res);

	CalcDelN(3);

	return loop;
}

// arcus cosine
// result is in range 0..PI
void RealACos(REAL* num)
{
	RealASin(num);
	RealNeg(num);
	RealAdd(num, num, &RealConstPi05);
}

// arcus tangent
// result is in range -PI/2..+PI/2
void RealATan(REAL* num)
{
	REAL* m = CalcNew();
	RealMul(m, num, num); // x^2
	RealInc(m); // 1 + x^2
	RealSqrt(m); // sqrt(1 + x^2)
	RealDiv(num, num, m); // x / sqrt(1 + x^2)
	RealASin(num); // atan(x) = asin(x / sqrt(1 + x^2))
	CalcDel();
}

// arcus cotangent
// result is in range -PI/2..+PI/2
void RealACoTan(REAL* num)
{
	RealATan(num);
	RealSub(num, &RealConstPi05, num);
}

// hyperbolic sine
//  sinh(x) = (e^x - e^-x)/2
void RealSinH(REAL* num)
{
	REAL* m = CalcNew();
	RealExp(num);
	RealDiv(m, &RealConst1, num);
	RealSub(num, num, m);
	RealDiv2(num);
	CalcDel();
}

// hyperbolic cosine
//  cosh(x) = (e^x + e^-x)/2
void RealCosH(REAL* num)
{
	REAL* m = CalcNew();
	RealExp(num);
	RealDiv(m, &RealConst1, num);
	RealAdd(num, num, m);
	RealDiv2(num);
	CalcDel();
}

// hyperbolic tangent
//  tanh(x) = (e^2x - 1) / (e^2x + 1)
void RealTanH(REAL* num)
{
	REAL* m = CalcNew();
	RealExp(num);
	RealSqr(num);
	RealCopy(m, num);
	RealDec(num);
	RealInc(m);
	RealDiv(num, num, m);
	CalcDel();
}

// hyperbolic cotangent
//  cotanh(x) = (e^2x + 1) / (e^2x - 1)
void RealCoTanH(REAL* num)
{
	REAL* m = CalcNew();
	RealExp(num);
	RealSqr(num);
	RealCopy(m, num);
	RealInc(num);
	RealDec(m);
	RealDiv(num, num, m);
	CalcDel();
}

// hyperbolic secans
//  sech(x) = 2*e^x / (e^2x + 1)
void RealSecH(REAL* num)
{
	REAL* m = CalcNew();
	RealExp(num);
	RealCopy(m, num);
	RealSqr(m);
	RealInc(m);
	RealMul2(num);
	RealDiv(num, num, m);
	CalcDel();
}

// hyperbolic cosecant
//  csch(x) = 2*e^x / (e^2x - 1)
void RealCscH(REAL* num)
{
	REAL* m = CalcNew();
	RealExp(num);
	RealCopy(m, num);
	RealSqr(m);
	RealDec(m);
	RealMul2(num);
	RealDiv(num, num, m);
	CalcDel();
}

// areasine, inverse hyperbolic sine
//  arsh(x) = ln(x + sqrt(x^2 + 1))
void RealArSinH(REAL* num)
{
	REAL* m = CalcNew();
	RealMul(m, num, num);
	RealInc(m);
	RealSqrt(m);
	RealAdd(num, num, m);
	RealLn(num);
	CalcDel();
}

// areacosine, inverse hyperbolic cosine
//  arch(x) = ln(x + sqrt(x^2 - 1))
void RealArCosH(REAL* num)
{
	REAL* m = CalcNew();
	RealMul(m, num, num);
	RealDec(m);
	RealSqrt(m);
	RealAdd(num, num, m);
	RealLn(num);
	CalcDel();
}

// areatangent, inverse hyperbolic tangent
//  arth(x) = ln((1 + x)/(1 - x))/2
void RealArTanH(REAL* num)
{
	REAL* m = CalcNew();
	RealSub(m, &RealConst1, num);
	RealInc(num);
	RealDiv(num, num, m);
	RealLn(num);
	RealDiv2(num);
	CalcDel();
}

// areacotangent, inverse hyperbolic cotangent
//  arcth(x) = ln((x + 1)/(x - 1))/2
void RealArCoTan(REAL* num)
{
	REAL* m = CalcNew();
	RealSub(m, num, &RealConst1);
	RealInc(num);
	RealDiv(num, num, m);
	RealLn(num);
	RealDiv2(num);
	CalcDel();
}

// areasecant, inverse hyperbolic secant
//  arsch(x) = ln((1 + sqrt(1 - x^2))/x)
void RealArSecH(REAL* num)
{
	REAL* m = CalcNew();
	RealMul(m, num, num);
	RealSub(m, &RealConst1, m);
	RealSqrt(m);
	RealInc(m);
	RealDiv(num, m, num);
	RealLn(num);
	CalcDel();
}

// areacosecant, inverse hyperbolic cosecant
//  arcsch(x) = ln((1 - sqrt(1 + x^2))/x) ... x<0
//  arcsch(x) = ln((1 + sqrt(1 + x^2))/x) ... x>0
void RealArCscH(REAL* num)
{
	REAL* m = CalcNew();
	RealMul(m, num, num);
	RealInc(m);
	RealSqrt(m);
	if (RealIsNeg(num))
		RealSub(m, &RealConst1, m);
	else
		RealAdd(m, &RealConst1, m);
	RealDiv(num, m, num);
	RealLn(num);
	CalcDel();
}

// natural logarithm (returns number of loops of iteration)
//  Taylor serie D = (x-1)/(x+1),  xi+1 = xi*D^2*(i*2-1)/(i*2+1) ... x0 = 2*D
//  ln(x) = 2*D*(1 + D^2/3 + D^4/5 + D^6/7 ...)
int RealLn(REAL* num)
{
	r_dblexps exp;
	REAL *x2, *res, *fac, *tmp;
	int loop;
	Bool neg;

	// check if number is <= 0 (invalid)
	if (RealComp0(num) <= 0)
	{
		Error(ERR_PARAM);
		RealSetMax(num);
		RealNeg(num);
		return 0;
	}

	// result is 0 of x=1
	loop = RealComp(num, &RealConst1);
	if (loop == 0)
	{
		RealSet0(num);
		return 0;
	}

	// do 1/x if <1 (negate result)
	neg = False;
	if (loop < 0)
	{
		RealRec(num);
		neg = True;
	}

	// load exponent
	exp = num->exp;

	// set exponent 0 to get range 1..1.999999 (=set number 1-base)
	num->exp = 0;

	// prepare member D and result accumulator
	res = CalcNew();
	RealCopy(res, num); // res = x
	RealDec(res); // res = x - 1
	RealInc(num); // num = x + 1
	RealDiv(num, res, num); // num = (x - 1) / (x + 1) = D
	RealCopy(res, num);

	// square D^2
	x2 = CalcNew();
	RealMul(x2, num, num);

	// factorial coefficient -> 1
	fac = CalcNew();
	RealSet1(fac);

	// temporary member
	tmp = CalcNew();

	// iterations
	loop = 1;
	for (;; loop++)
	{
		// multiply member by x^2
		RealMul(num, num, x2);

		// increase factorial coefficient by 2
		RealAdd(fac, fac, &RealConst2);

		// divide member by factorial coefficient
		RealDiv(tmp, num, fac);

		// add member to accumulator
		RealAdd(res, res, tmp);

		// check epsilon of member
		if ((res->exp - tmp->exp > R_MANT_BITS + R_MANT_BITS/16) || RealIsZero(tmp)) break;
	}

	// multiply by 2
	RealMul2(res);

	// convert exponent to e-base and add it to the result
#if R_EXP_MAXBITS == 8 // save exponent
	RealSetU8(fac, (u8)exp);
#elif R_EXP_MAXBITS == 16
	RealSetU16(fac, (u16)exp);
#else // R_EXP_MAXBITS == 32
	RealSetU32(fac, (u32)exp);
#endif
	RealMul(fac, fac, &RealConstLn2);
	RealAdd(res, res, fac);

	// negate result
	if (neg) RealNeg(res);

	// copy result
	RealCopy(num, res);

	CalcDelN(4);

	return loop;
}

// ln(2) - calculates ln(2) constant (uses similar method as above, but does not require pre-calculated ln(2) )
int RealLn2(REAL* num)
{
	r_dblexps exp;
	REAL *x2, *res, *fac, *tmp;
	int loop;
	Bool neg;

	// prepare member D and result accumulator (x = 2, D = (2-1)/(2+1) = 1/3)
	res = CalcNew();
	RealSetU8(num, 3);
	RealRec(num);
	RealCopy(res, num);

	// square D^2
	x2 = CalcNew();
	RealMul(x2, num, num);

	// factorial coefficient -> 1
	fac = CalcNew();
	RealSet1(fac);

	// temporary member
	tmp = CalcNew();

	// iterations
	loop = 1;
	for (;; loop++)
	{
		// multiply member by x^2
		RealMul(num, num, x2);

		// increase factorial coefficient by 2
		RealAdd(fac, fac, &RealConst2);

		// divide member by factorial coefficient
		RealDiv(tmp, num, fac);

		// add member to accumulator
		RealAdd(res, res, tmp);

		// check epsilon of member
		if ((res->exp - tmp->exp > R_MANT_BITS + R_MANT_BITS/16) || RealIsZero(tmp)) break;
	}

	// multiply by 2
	RealMul2(res);

	// copy result
	RealCopy(num, res);

	CalcDelN(4);

	return loop;
}

// natural exponent (returns number of loops of iteration)
//  Taylor serie xi+1 = xi * x / (i+1) ... x0 = 1
//  exp(x) = 1 + x/1! + x^2/2! + x^3/3! + x^4/4! + x^5/5! + ...
int RealExp(REAL* num)
{
	REAL *x, *res, *fac, *big;
	r_dblexps exp;
	int loop;

	// zero -> 1
	if (RealIsZero(num))
	{
		RealSet1(num);
		return 0;
	}

	// check overflow
	if (RealComp(num, &RealConstExpMax) > 0)
	{
		Error(ERR_OVERFLOW);
		RealSetMax(num);
		return 0;
	}

	// check underflow
	if (RealComp(num, &RealConstExpMin) < 0)
	{
#ifdef ERRMEXP
		Error(ERR_UNDERFLOW);
#endif
		RealSetMin(num);
		return 0;
	}

	// get integer part of exponent (integer /ln(2) integer *ln(2) subtract ... multiply)
	big = CalcNew();
	RealMul(big, num, &RealConstRLn2); // convert to 2-base big = num / ln(2)
#if R_EXP_MAXBITS == 8 // load integer number exp = int(num / ln(2))
	exp = RealGetS8(big);
#elif R_EXP_MAXBITS == 16
	exp = RealGetS16(big);
#else // R_EXP_MAXBITS == 32
	exp = (r_dblexps)RealGetS32(big);
#endif
	if (exp > (r_dblexps)(R_EXP_MAX-3)) exp = (R_EXP_MAX-3); // limit exponent into valid range
	if (exp < (r_dblexps)(R_EXP_MIN+3)) exp = (R_EXP_MIN+3);
#if R_EXP_MAXBITS == 8 // set exponent back
	RealSetS8(big, (s8)(exp));
#elif R_EXP_MAXBITS == 16
	RealSetS16(big, (s16)(exp));
#else // R_EXP_MAXBITS == 32
	RealSetS32(big, (s32)(exp));
#endif
	RealMul(big, big, &RealConstLn2); // convert back to e-base big = int(num / ln(2)) * ln(2)
	RealSub(num, num, big); // subtract integer exponent

	// prepare member
	x = CalcNew();
	RealSet1(x);

	// factorial coefficient -> 1
	fac = CalcNew();
	RealSet0(fac);

	// result accumulator
	res = CalcNew();
	RealSet1(res);

	// iterations
	loop = 0;
	for (;; loop++)
	{
		// multiply member by x
		RealMul(x, x, num);

		// increase factorial coefficient
		RealInc(fac);

		// divide member by factorial coefficient
		RealDiv(x, x, fac);

		// add member to accumulator
		RealAdd(res, res, x);

		// check epsilon of member
		if ((res->exp - x->exp > R_MANT_BITS + R_MANT_BITS/16) || RealIsZero(x)) break;
	}

	// multiply result by integer part
	RealSet1(big);
	big->exp = (r_exps)exp;
	RealMul(res, res, big);

	// copy result
	RealCopy(num, res);

	// delete temporary numbers
	CalcDelN(4);

	// check underflow
#ifdef ERRMEXP
	if (RealIsZero(num))
	{
		Error(ERR_UNDERFLOW);
		RealSetMin(num);
	}
#endif

	return loop;
}

// decimal logarithm
void RealLog10(REAL* num)
{
	RealLn(num);
	RealMul(num, num, &RealConstRLn10);
}

// decimal exponent
void RealExp10(REAL* num)
{
	RealMul(num, num, &RealConstLn10);
	RealExp(num);
}

// binary logarithm
void RealLog2(REAL* num)
{
	RealLn(num);
	RealMul(num, num, &RealConstRLn2);
}

// binary exponent
void RealExp2(REAL* num)
{
	RealMul(num, num, &RealConstLn2);
	RealExp(num);
}

// sqrt
void RealSqrt(REAL* num)
{
	Bool sign;
	REAL* m;
	int i;

	// base is 0, result is 0
	if (RealIsZero(num))
	{
		RealSet0(num);
		return;
	}

	// negative base - error
	if (RealIsNeg(num))
	{
		Error(ERR_PARAM); // incorrect parameter
		RealAbs(num);
	}

	// get logarithm of the base
	RealLn(num);

	// divide logarithm / 2
	RealDiv2(num);

	// back to exponent
	RealExp(num);
}

// set seed of random generator (@TODO) !!!!!!!!!!!!!
void SetRndSeed(u64 seed);

// get seed of random generator
u64 GetRndSeed();

// shift random generator
u64 RndShift();

// set random number in range 0<= .. <1
void RealSetRnd(REAL* num)
{


}

// random number in range 0<= .. <num
void RealRnd(REAL* num)
{


}

// integer factorial
void RealFact(REAL* num, u16 n)
{
	u16 i;
	REAL* m = CalcNew();
	RealSet1(num);

	for (i = 1; i <= n; i++)
	{
		RealSetU16(m, i);
		RealMul(num, num, m);
	}

	CalcDel();
}

// non-integer factorial approximation (precision 5 to 12 digits, error 1/(1400*n^3))
//  Srinivasa Ramanujan: ln n! = n*ln(n) - n + ln(8*n^3 + 4*n^2 + n + 1/30)/6 + ln(PI)/2
void RealFactSmooth(REAL* num)
{
	REAL *m1, *m2, *m3;
	m1 = CalcNew();
	m2 = CalcNew();
	m3 = CalcNew();

	RealMul(m1, num, num); // m1 = n^2
	RealMul2(m1);
	RealMul2(m1); // m1 = 4*n^2
	RealMul(m2, m1, num);
	RealMul2(m2); // m2 = 8*n^3
	RealAdd(m1, m1, m2);
	RealAdd(m1, m1, num); // m1 = 8*n^3 + 4*n^2 + n
	RealSetU8(m2, 30);
	RealRec(m2);
	RealAdd(m1, m1, m2); 
	RealLn(m1); // m1 = ln(8*n^3 + 4*n^2 + n + 1/30)
	RealSetU8(m2, 6);
	RealDiv(m1, m1, m2); // m1 = ln(8*n^3 + 4*n^2 + n + 1/30)/6

	RealCopy(m2, &RealConstPi);
	RealLn(m2);
	RealDiv2(m2); // m2 = ln(PI)/2

	RealAdd(m1, m1, m2);
	RealSub(m1, m1, num); // m1 = ln(8*n^3 + 4*n^2 + n + 1/30)/6 + ln(PI)/2 - n

	RealCopy(m2, num);
	RealLn(m2);
	RealMul(num, m2, num); // num = n*ln(n)

	RealAdd(num, num, m1);
	RealExp(num);

	CalcDelN(3);

/*
// precision 4 to 6 digits
// e^(x*(ln(x)-1)) * sqrt(2*PI*x) * (1 + (1/(12.0*x)))
	REAL *m1, *m2;
	m1 = CalcNew();
	m2 = CalcNew();

	RealSetU8(m1, 12);
	RealMul(m1, m1, num);
	RealRec(m1);
	RealInc(m1); // m1 = 1 + 1/(12*x)

	RealMul(m2, num, &RealConstPi2);
	RealSqrt(m2); // m2 = sqrt(2*PI*x)

	RealMul(m1, m1, m2);

	RealCopy(m2, num);
	RealLn(m2);
	RealDec(m2);
	RealMul(num, num, m2);
	RealExp(num); // num = e^(x*(ln(x)-1))

	RealMul(num, num, m1);

	CalcDelN(2);
	*/
}
