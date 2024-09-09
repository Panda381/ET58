##########################
# On command line use:
#   make all PROJECT=project_name MCU=mcu_type F_CPU=frequency
#   make clean


##########################
# Project definitions

# target platform
TRGT = avr-

# list of C source files
SRC =

# list of ASM source files
ASRC = data.S const.S 

ASRC += adc.S main.S build.S wait.S key.S eeprom.S lcd.S prog.S sleep.S

ASRC += exec_disp.S exec_flags.S exec_edit.S exec.S exec_op.S exec_arithm.S exec_func.S 

ASRC += decnum.S math.S

ASRC += calc.S calc_stack.S calc_arithm.S calc_ctrl.S calc_mant.S calc_sup.S

# warning - Module requires ROM memory of size max. 64 KB
ASRC += ET58_module/ML.S

# CRC of the file - must be last source file!
ASRC += crc.S

# optimisation level
OPT = -Os

# tools
CC = $(TRGT)gcc
LN = $(TRGT)gcc
OC = $(TRGT)objcopy
AS = $(TRGT)gcc -x assembler-with-cpp
HEX = $(OC) -O ihex
BIN = $(OC) -O binary
LST = $(TRGT)objdump -d -S -m avr

# flags
#CCFLAGS = $(OPT) -Wall -std=gnu99 -gstabs -mrelax -mshort-calls -mmcu=$(MCU) -c $(CDEF) -D$(MCU) -D F_CPU=$(F_CPU)
LNFLAGS = -mmcu=$(MCU) -D$(MCU) -DF_CPU=$(F_CPU)
#-mrelax 
#-mshort-calls
#OCFLAGS = -j .text -j .data
#ASFLAGS = -mmcu=$(MCU) -nostartfiles -g -mrelax -mshort-calls -D$(MCU) -D F_CPU=$(F_CPU) -Wa,-amhls=$(<:.s=.lst)


##########################
# Makefile rules

OBJS = $(ASRC:.s=.o) $(SRC:.c=.o)

all: $(OBJS) $(PROJECT).elf $(PROJECT).hex $(PROJECT).bin $(PROJECT).lst

#%.o : %.c
#	$(CC) -c $(CCFLAGS) $< -o $@

%elf: $(OBJS)
	$(LN) $(LNFLAGS) -o $@ $(OBJS)
  
%hex: %elf
	$(HEX) $< $@

%bin: %elf
	$(BIN) $< $@

%lst: %elf
	$(LST) $< > $@
