
PROG = GenerConst

SRCS = GenerConst.c lib/calc.c lib/real.c
OBJS = GenerConst.o real.o calc.o

CC = gcc
CFLAGS = -O2 -fomit-frame-pointer
LDFLAGS = -liconv -s

all: $(PROG)

$(PROG): $(OBJS)
	        $(CC) $(CPPFLAGS) $(LDFLAGS) -o $(PROG) $(OBJS)

GenerConst.o:
	        $(CC) $(CFLAGS) -c GenerConst.c

calc.o:
	        $(CC) $(CFLAGS) -I. -c lib/calc.c

real.o:
	        $(CC) $(CFLAGS) -I. -c lib/real.c

clean:
	rm GenerConst *.o
