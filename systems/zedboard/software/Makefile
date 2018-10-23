#Optionally add sources here/set SW_PROJ variable

-include config.mk
-include ../config.mk
TARGET ?= test

ifeq ($(SW_PROJ), cache_test)
  AS_SRCS += cache_test.S orca_cache.S
  C_SRCS  += cache_test_main.c orca_interrupts.c orca_memory.c orca_malloc.c
else #ifeq ($(SW_PROJ), cache_test)
  C_SRCS  ?= hello_world.c
endif #else #ifeq ($(SW_PROJ), cache_test)
C_SRCS  += orca_printf.c orca_exceptions.c
AS_SRCS += full-crt.S

.PHONY: all
all:


#These should come from the BSP
ifdef RESET_VECTOR
IDRAM_BASE_ADDRESS      ?= $(RESET_VECTOR_HEX)
else #ifdef RESET_VECTOR
IDRAM_BASE_ADDRESS      ?= 0xA0000000
endif #else #ifdef RESET_VECTOR
IDRAM_LENGTH            ?= 0x00020000

## Common ORCA software build script and parameters to pass to it
RISCV_OLEVEL ?= -O3
ORCA_ROOT ?= ../../..
include $(ORCA_ROOT)/software/software.mk
include $(ORCA_ROOT)/software/tests.mk

all: target orca-tests riscv-tests

clean: clean-riscv-test clean-orca-test
