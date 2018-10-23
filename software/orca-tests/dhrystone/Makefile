ORCA_ROOT := ../../..
C_SRCS  ?= dhrystone.c dhrystone_main.c
INCLUDE_DIRS = $(ORCA_ROOT)/software/riscv-tests/benchmarks/common
$(info C_SRCS = $(C_SRCS))
C_SRCS  += orca_printf.c orca_exceptions.c
AS_SRCS ?= $(wildcard *.S)
AS_SRCS += full-crt.S

ORCA_ROOT := ../../..
include $(ORCA_ROOT)/software/software.mk
