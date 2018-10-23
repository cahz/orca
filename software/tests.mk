#Makefile fragment for ORCA riscv-tests/orca-tests Include software.mk
#if in a software directory, or set OUTPUT_PREFIX=software/ (or
#wherever) in a system to get a list of tests.

ORCA_ROOT ?= ../../..

####
# riscv-tests
#####
RISCV_ARCHS=rv32ui rv32mi rv32um
RISCV_TEST_DIR=$(ORCA_ROOT)/software/riscv-tests/
RISCV_TESTS ?= $(addsuffix .elf, $(addprefix $(OUTPUT_PREFIX), $(basename $(foreach arch, $(RISCV_ARCHS),\
			$(addprefix $(arch)-p-, $(notdir $(wildcard $(RISCV_TEST_DIR)/isa/$(arch)/*.S) ))))))


RISCV_OUTPUTS = $(RISCV_TESTS) $(addsuffix .bin, $(basename $(RISCV_TESTS))) $(addsuffix .dump, $(basename $(RISCV_TESTS))) $(addsuffix .ihex, $(basename $(RISCV_TESTS))) $(addsuffix .qex, $(basename $(RISCV_TESTS))) $(addsuffix .coe, $(basename $(RISCV_TESTS)))

$(RISCV_TESTS): $(ORCA_ROOT)/software/orca_lib/orca_printf.c | $(OUTPUT_DIR)
	$(CC) -o $@ $(RISCV_TEST_DIR)/isa/$(firstword $(subst -p-, , $(basename $@)))/$(lastword $(subst -p-, , $(basename $@))).S \
	$< $(INCLUDE_STRING) -nostdlib -T $(LD_SCRIPT)

.PHONY: riscv_tests
riscv-tests: $(RISCV_OUTPUTS)

clean-riscv-test:
	rm -f $(RISCV_OUTPUTS)

####
# orca-tests
#####
ORCA_TESTS ?= $(addsuffix .elf, $(notdir $(abspath $(dir $(wildcard $(ORCA_ROOT)/software/orca-tests/*/Makefile )))))

OUTPUT_DIR ?= $(shell pwd)
$(ORCA_TESTS)::
	make -C $(ORCA_ROOT)/software/orca-tests/$(basename $@) $(OUTPUT_DIR)/$@ OUTPUT_DIR=$(OUTPUT_DIR) RISCV_OLEVEL=-O3

ORCA_TEST_OUTPUTS = $(ORCA_TESTS) $(addsuffix .bin, $(basename $(ORCA_TESTS))) $(addsuffix .dump, $(basename $(ORCA_TESTS))) $(addsuffix .ihex, $(basename $(ORCA_TESTS))) $(addsuffix .qex, $(basename $(ORCA_TESTS))) $(addsuffix .coe, $(basename $(ORCA_TESTS)))

.PHONY: orca-tests
orca-tests: $(ORCA_TEST_OUTPUTS)

clean-orca-test:
	rm -f $(ORCA_TEST_OUTPUTS)
