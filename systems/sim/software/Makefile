.PHONY: all
all:

## Common ORCA software build script and parameters to pass to it
RISCV_OLEVEL ?= -O3
ORCA_ROOT ?= ../../..
include $(ORCA_ROOT)/software/software.mk
include $(ORCA_ROOT)/software/tests.mk

clean: clean-riscv-test clean-orca-test
