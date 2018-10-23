#Optionally add sources here/set SW_PROJ variable

-include config.mk
-include ../config.mk
TARGET ?= test

C_SRCS ?= hello_world.c

C_SRCS += orca_printf.c orca_exceptions.c
AS_SRCS += full-crt.S

.PHONY: all
all:

## Common ORCA software build script and parameters to pass to it
RISCV_OLEVEL ?= -O3
ORCA_ROOT ?= ../../..
include $(ORCA_ROOT)/software/software.mk
include $(ORCA_ROOT)/software/tests.mk

all: target orca-tests riscv-tests

clean: clean-riscv-test clean-orca-test
