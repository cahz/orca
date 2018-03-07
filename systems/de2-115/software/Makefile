#Optionally add sources here/set SW_PROJECT variable
-include config.mk
-include ../config.mk

TARGET ?= test
.PHONY: all
all: $(TARGET).elf $(TARGET).hex $(TARGET).dump

AS_SRCS += full-crt.S

ifndef ORCA_TEST
C_SRCS ?= hello_world.c
endif #ifndef ORCA_TEST

C_SRCS += orca_printf.c orca_exceptions.c

## Common ORCA software build script and parameters to pass to it
ORCA_ROOT ?= ../../..
include $(ORCA_ROOT)/software/software.mk
