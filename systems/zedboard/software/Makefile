#Optionally add sources here/set ORCA_TEST/SW_PROJ variables
-include config.mk
-include ../config.mk

TARGET ?= test

ifndef ORCA_TEST
ifeq ($(SW_PROJ), cache_test)
  AS_SRCS += cache_test.S
  C_SRCS  += cache_test_main.c orca_interrupts.c orca_memory.c orca_malloc.c
else
  C_SRCS  ?= hello_world.c
endif
endif #ifndef ORCA_TEST

.PHONY: all
all: ../orca_defines.h

C_SRCS  += orca_printf.c orca_exceptions.c
AS_SRCS += full-crt.S

#These should come from the BSP
ifdef RESET_VECTOR
RESET_VECTOR_HEX        := $(shell printf "0x%08X" $(RESET_VECTOR))
IDRAM_BASE_ADDRESS      ?= $(RESET_VECTOR_HEX)
else #ifdef RESET_VECTOR
IDRAM_BASE_ADDRESS      ?= 0xA0000000
endif #else #ifdef RESET_VECTOR
IDRAM_LENGTH            ?= 0x00020000

## Common ORCA software build script and parameters to pass to it
RISCV_OLEVEL ?= -O3
ORCA_ROOT ?= ../../..
include $(ORCA_ROOT)/software/software.mk

../orca_defines.h:
	$(MAKE) -C .. orca_defines.h

.PHONY: all
all: $(TARGET).elf $(TARGET).coe $(TARGET).dump
