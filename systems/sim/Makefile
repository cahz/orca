-include config.mk
BUS_TYPES := $(filter-out csmith%,$(patsubst system_%.qsys,%,$(wildcard system_*.qsys)))

ifndef BUS_TYPE
$(info INFO: BUS_TYPE not defined, defaulting to avalon )
BUS_TYPE := avalon
endif
ifeq ($(filter $(BUS_TYPE), $(BUS_TYPES)),)
$(error BUS_TYPE $(BUS_TYPE) is not in the list of bus types ($(BUS_TYPES)))
endif

.PHONY: all
all: testall

SYSTEM          := system_$(BUS_TYPE)
SYSTEMS         := $(BUS_TYPES:%=system_%)
QSYS_FILE       := $(SYSTEM).qsys
QSYS_FILES      := $(SYSTEMS:%=%.qsys)
SIM_WAVES_FILE  := sim_waves_system_$(BUS_TYPE).tcl
SIM_WAVES_FILES := $(BUS_TYPES:%=sim_waves_system_%.tcl)
SIM_FILE        := simulate_$(BUS_TYPE).tcl
SIM_FILES       := $(BUS_TYPES:%=simulate_%.tcl)
MSIM_FILE       := $(SYSTEM)/simulation/mentor/msim_setup.tcl
MSIM_FILES      := $(SYSTEMS:%=%/simulation/mentor/msim_setup.tcl)
TEST_HEX        := $(SYSTEM)/simulation/mentor/test.hex
TEST_HEXES      := $(SYSTEMS:%=%/simulation/mentor/test.hex)
TEST_LOG        := test_$(BUS_TYPE).log
TEST_LOGS       := $(BUS_TYPES:%=test_%.log)

ORCA_ROOT       ?= ../..
ORCA_HW_TCL     := $(ORCA_ROOT)/ip/orca/orca_hw.tcl
ORCA_HDL        := $(wildcard $(ORCA_ROOT)/ip/orca/hdl/*.vhd)

.PHONY: gui-qsys
gui-qsys: $(QSYS_FILE)
	qsys-edit $(QSYS_FILE) --search-path="./,$(ORCA_ROOT)/ip/,$$" &

%/simulation/mentor/msim_setup.tcl: %.qsys $(ORCA_HW_TCL)
	qsys-generate --simulation=vhdl $<
	(cd $(*)/simulation/submodules/vblox_orca; for i in *.vhd; do if [ -f ../../../../ip/orca/hdl/$$i ] ; then ln -sf ../../../../ip/orca/hdl/$$i $$i; fi; done; )
	if [ -e $(*)/simulation/submodules/vblox_lve ]; then (cd $(*)/simulation/submodules/vblox_lve; for i in *.vhd; do if [ -f ../../../../ip/orca/lve/hdl/$$i ] ; then ln -sf ../../../../ip/lve/hdl/$$i $$i; fi; done; ); fi

test:
	mkdir -p $@

## Include tests.mk to populate RISCV_TESTS and ORCA_TESTS
ORCA_ROOT ?= ../../..
OUTPUT_PREFIX = software/
include $(ORCA_ROOT)/software/tests.mk
RISCV_TEST_QEXES := $(addprefix software/, $(addsuffix .qex, $(basename $(RISCV_TESTS))))
ORCA_TEST_QEXES  := $(addprefix software/, $(addsuffix .qex, $(basename $(ORCA_TESTS))))

software/%.qex::
	$(MAKE) -C software $(notdir $(*)).qex $(notdir $(*)).dump

.PHONY: sw
sw: $(RISCV_TEST_QEXES) $(ORCA_TEST_QEXES)

test_%.log: system_%/simulation/mentor/msim_setup.tcl testall.tcl $(ORCA_HDL) $(RISCV_TEST_QEXES) $(ORCA_TEST_QEXES)
	cd system_$*/simulation/mentor && vsim -c -do "source ../../../testall.tcl; run_tests $* {$(basename $(notdir $(RISCV_TESTS) $(ORCA_TESTS)))}" | egrep '(^[^#]|Error:|Error \(suppressible\):)' | tee ../../../test_$*.log

.PHONY: testone
testone: $(TEST_LOG)

.PHONY: testall
testall: $(TEST_LOGS)

orca_defines.h:
	touch $@

.PHONY: sim
ifndef TEST
sim:
	$(error Define TEST variable before running make sim (software/$$(TEST).qex will be used))
else #ifndef TEST
test.hex::
	ln -sf software/$(TEST).qex $@

sim: $(MSIM_FILE) test.hex software/$(TEST).qex
	cd $(SYSTEM)/simulation/mentor/; ln -sf ../../../test.hex .
	vsim -do "set system_name $(BUS_TYPE); source simulate.tcl;"
endif #else #ifndef TEST

.PHONY: clean
clean:
	rm -rf $(SYSTEMS) test test.hex  *.log
	rm -rf transcript *.sopcinfo platform.info csmith-compile *~ \#*
	rm -rf .qsys_edit
	$(MAKE) -C software clean

.DELETE_ON_ERROR:
