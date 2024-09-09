// ***************************************************************************
//
//                      Data types and common definitions
//
// ***************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#ifndef __linux__
#pragma warning ( disable: 4100)		// disable VC++ warning - unreferenced parameter
#pragma warning ( disable: 4101)		// disable VC++ warning - unreferenced local variable
#pragma warning ( disable: 4996)		// disable VC++ warning - unsafe function
#endif

// Base data types
#ifdef __linux__
#include <asm/types.h>
#define s8 __s8
#define u8 __u8
#define s16 __s16
#define u16 __u16
#define s32 __s32
#define u32 __u32
#define s64 __s64
#define u64 __u64
#else
typedef signed char s8;
typedef unsigned char u8;
typedef signed short s16;
typedef unsigned short u16;
typedef signed long int s32;
typedef unsigned long int u32;
typedef signed long long int s64;
typedef unsigned long long int u64;
#endif

typedef unsigned char Bool;
#define True 1
#define False 0
//#define NULL (void*)0

#define REAL real			// name of internal calculator number
#define MEM mem				// name of memory number

// constants
#define	B0 (1<<0)
#define	B1 (1<<1)
#define	B2 (1<<2)
#define	B3 (1<<3)
#define	B4 (1<<4)
#define	B5 (1<<5)
#define	B6 (1<<6)
#define	B7 (1<<7)
#define	B8 (1<<8)
#define	B9 (1<<9)
#define	B10 (1<<10)
#define	B11 (1<<11)
#define	B12 (1<<12)
#define	B13 (1<<13)
#define	B14 (1<<14)
#define	B15 (1<<15)
#define B16 (1<<16)
#define B17 (1<<17)
#define B18 (1<<18)
#define	B19 (1<<19)
#define B20 (1<<20)
#define B21 (1<<21)
#define B22 (1<<22)
#define B23 (1<<23)
#define B24 (1<<24)
#define B25 (1<<25)
#define B26 (1<<26)
#define B27 (1<<27)
#define B28 (1<<28)
#define B29 (1<<29)
#define B30 (1<<30)
#define B31 (1UL<<31)

#define BIT(pos) (1UL << (pos))
