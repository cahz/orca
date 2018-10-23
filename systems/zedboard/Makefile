-include config.mk

#Select cached system by default if it exists
ifndef BD_NAME
ifneq ($(wildcard orca_system_cached.tcl), )
BD_NAME ?= orca_system
BD_EXTENSION ?= _cached
else #ifeq ($(wildcard orca_system_cached.tcl), )
BD_NAME ?= orca_system
BD_EXTENSION ?= _tcm
endif #else #ifeq ($(wildcard orca_system_cached.tcl), )
endif #ifndef BD_NAME


PROJECT_TCL ?= project.tcl
BD_TCL      ?= $(BD_NAME)$(BD_EXTENSION).tcl

PROJ_DIR  ?= orca_project
PROJ_NAME ?= orca_project

TEST     ?= test
SW_DIR   ?= software
COE_FILE = test.coe

PROJ_FILE=$(PROJ_DIR)/$(PROJ_NAME).xpr
BD_FILE=$(PROJ_DIR)/$(PROJ_NAME).srcs/sources_1/bd/$(BD_NAME)/$(BD_NAME).bd
HWDEF_FILE=$(PROJ_DIR)/$(PROJ_NAME).srcs/sources_1/bd/$(BD_NAME)/synth/$(BD_NAME).hwdef
SYNTH_DCP=$(PROJ_DIR)/$(PROJ_NAME).runs/synth_1/$(BD_NAME)_wrapper.dcp
IMPL_BIT=$(PROJ_DIR)/$(PROJ_NAME).runs/impl_1/$(BD_NAME)_wrapper.bit
ORCA_SRCS=$(wildcard ../../ip/orca/hdl/*.vhd) ../../ip/orca/component.xml

RESOURCE_TCL=report_resource_usage.tcl
OUT_BIT=out.bit

PGM_TCL=pgm.tcl

.PHONY: all
all: $(OUT_BIT) resource_utilization.rpt link.ld orca_defines.h

VIVADO_SOURCE=vivado -notrace -nojournal -nolog -mode batch -source

BD_CHANGES = {

ifdef REGISTER_SIZE
BD_CHANGES += REGISTER_SIZE $(REGISTER_SIZE)
endif #ifdef REGISTER_SIZE
ifdef RESET_VECTOR
BD_CHANGES += RESET_VECTOR $(shell printf "0x%08X" $(RESET_VECTOR))
endif #ifdef RESET_VECTOR
ifdef INTERRUPT_VECTOR
BD_CHANGES += INTERRUPT_VECTOR $(shell printf "0x%08X" $(INTERRUPT_VECTOR))
endif #ifdef INTERRUPT_VECTOR
ifdef MAX_IFETCHES_IN_FLIGHT
BD_CHANGES += MAX_IFETCHES_IN_FLIGHT $(MAX_IFETCHES_IN_FLIGHT)
endif #ifdef MAX_IFETCHES_IN_FLIGHT
ifdef BTB_ENTRIES
BD_CHANGES += BTB_ENTRIES $(BTB_ENTRIES)
endif #ifdef BTB_ENTRIES
ifdef MULTIPLY_ENABLE
BD_CHANGES += MULTIPLY_ENABLE $(MULTIPLY_ENABLE)
endif #ifdef MULTIPLY_ENABLE
ifdef DIVIDE_ENABLE
BD_CHANGES += DIVIDE_ENABLE $(DIVIDE_ENABLE)
endif #ifdef DIVIDE_ENABLE
ifdef SHIFTER_MAX_CYCLES
BD_CHANGES += SHIFTER_MAX_CYCLES $(SHIFTER_MAX_CYCLES)
endif #ifdef SHIFTER_MAX_CYCLES
ifdef ENABLE_EXCEPTIONS
BD_CHANGES += ENABLE_EXCEPTIONS $(ENABLE_EXCEPTIONS)
endif #ifdef ENABLE_EXCEPTIONS
ifdef PIPELINE_STAGES
BD_CHANGES += PIPELINE_STAGES $(PIPELINE_STAGES)
endif #ifdef PIPELINE_STAGES
ifdef VCP_ENABLE
BD_CHANGES += VCP_ENABLE $(VCP_ENABLE)
endif #ifdef VCP_ENABLE
ifdef ENABLE_EXT_INTERRUPTS
BD_CHANGES += ENABLE_EXT_INTERRUPTS $(ENABLE_EXT_INTERRUPTS)
endif #ifdef ENABLE_EXT_INTERRUPTS
ifdef NUM_EXT_INTERRUPTS
BD_CHANGES += NUM_EXT_INTERRUPTS $(NUM_EXT_INTERRUPTS)
endif #ifdef NUM_EXT_INTERRUPTS
ifdef POWER_OPTIMIZED
BD_CHANGES += POWER_OPTIMIZED $(POWER_OPTIMIZED)
endif #ifdef POWER_OPTIMIZED
ifdef FAMILY
BD_CHANGES += FAMILY $(FAMILY)
endif #ifdef FAMILY
ifdef LOG2_BURSTLENGTH
BD_CHANGES += LOG2_BURSTLENGTH $(LOG2_BURSTLENGTH)
endif #ifdef LOG2_BURSTLENGTH
ifdef AXI_ID_WIDTH
BD_CHANGES += AXI_ID_WIDTH $(AXI_ID_WIDTH)
endif #ifdef AXI_ID_WIDTH
ifdef AVALON_AUX
BD_CHANGES += AVALON_AUX $(AVALON_AUX)
endif #ifdef AVALON_AUX
ifdef LMB_AUX
BD_CHANGES += LMB_AUX $(LMB_AUX)
endif #ifdef LMB_AUX
ifdef WISHBONE_AUX
BD_CHANGES += WISHBONE_AUX $(WISHBONE_AUX)
endif #ifdef WISHBONE_AUX
ifdef AUX_MEMORY_REGIONS
BD_CHANGES += AUX_MEMORY_REGIONS $(AUX_MEMORY_REGIONS)
endif #ifdef AUX_MEMORY_REGIONS
ifdef AMR0_ADDR_BASE
BD_CHANGES += AMR0_ADDR_BASE $(shell printf "0x%08X" $(AMR0_ADDR_BASE))
endif #ifdef AMR0_ADDR_BASE
ifdef AMR0_ADDR_LAST
BD_CHANGES += AMR0_ADDR_LAST $(shell printf "0x%08X" $(AMR0_ADDR_LAST))
endif #ifdef AMR0_ADDR_LAST
ifdef UC_MEMORY_REGIONS
BD_CHANGES += UC_MEMORY_REGIONS $(UC_MEMORY_REGIONS)
endif #ifdef UC_MEMORY_REGIONS
ifdef UMR0_ADDR_BASE
BD_CHANGES += UMR0_ADDR_BASE $(shell printf "0x%08X" $(UMR0_ADDR_BASE))
endif #ifdef UMR0_ADDR_BASE
ifdef UMR0_ADDR_LAST
BD_CHANGES += UMR0_ADDR_LAST $(shell printf "0x%08X" $(UMR0_ADDR_LAST))
endif #ifdef UMR0_ADDR_LAST
ifdef ICACHE_SIZE
BD_CHANGES += ICACHE_SIZE $(ICACHE_SIZE)
endif #ifdef ICACHE_SIZE
ifdef ICACHE_LINE_SIZE
BD_CHANGES += ICACHE_LINE_SIZE $(ICACHE_LINE_SIZE)
endif #ifdef ICACHE_LINE_SIZE
ifdef ICACHE_EXTERNAL_WIDTH
BD_CHANGES += ICACHE_EXTERNAL_WIDTH $(ICACHE_EXTERNAL_WIDTH)
endif #ifdef ICACHE_EXTERNAL_WIDTH
ifdef INSTRUCTION_REQUEST_REGISTER
BD_CHANGES += INSTRUCTION_REQUEST_REGISTER $(INSTRUCTION_REQUEST_REGISTER)
endif #ifdef INSTRUCTION_REQUEST_REGISTER
ifdef INSTRUCTION_RETURN_REGISTER
BD_CHANGES += INSTRUCTION_RETURN_REGISTER $(INSTRUCTION_RETURN_REGISTER)
endif #ifdef INSTRUCTION_RETURN_REGISTER
ifdef IUC_REQUEST_REGISTER
BD_CHANGES += IUC_REQUEST_REGISTER $(IUC_REQUEST_REGISTER)
endif #ifdef IUC_REQUEST_REGISTER
ifdef IUC_RETURN_REGISTER
BD_CHANGES += IUC_RETURN_REGISTER $(IUC_RETURN_REGISTER)
endif #ifdef IUC_RETURN_REGISTER
ifdef IAUX_REQUEST_REGISTER
BD_CHANGES += IAUX_REQUEST_REGISTER $(IAUX_REQUEST_REGISTER)
endif #ifdef IAUX_REQUEST_REGISTER
ifdef IAUX_RETURN_REGISTER
BD_CHANGES += IAUX_RETURN_REGISTER $(IAUX_RETURN_REGISTER)
endif #ifdef IAUX_RETURN_REGISTER
ifdef IC_REQUEST_REGISTER
BD_CHANGES += IC_REQUEST_REGISTER $(IC_REQUEST_REGISTER)
endif #ifdef IC_REQUEST_REGISTER
ifdef IC_RETURN_REGISTER
BD_CHANGES += IC_RETURN_REGISTER $(IC_RETURN_REGISTER)
endif #ifdef IC_RETURN_REGISTER
ifdef DCACHE_SIZE
BD_CHANGES += DCACHE_SIZE $(DCACHE_SIZE)
endif #ifdef DCACHE_SIZE
ifdef DCACHE_WRITEBACK
BD_CHANGES += DCACHE_WRITEBACK $(DCACHE_WRITEBACK)
endif #ifdef DCACHE_WRITEBACK
ifdef DCACHE_LINE_SIZE
BD_CHANGES += DCACHE_LINE_SIZE $(DCACHE_LINE_SIZE)
endif #ifdef DCACHE_LINE_SIZE
ifdef DCACHE_EXTERNAL_WIDTH
BD_CHANGES += DCACHE_EXTERNAL_WIDTH $(DCACHE_EXTERNAL_WIDTH)
endif #ifdef DCACHE_EXTERNAL_WIDTH
ifdef DATA_REQUEST_REGISTER
BD_CHANGES += DATA_REQUEST_REGISTER $(DATA_REQUEST_REGISTER)
endif #ifdef DATA_REQUEST_REGISTER
ifdef DATA_RETURN_REGISTER
BD_CHANGES += DATA_RETURN_REGISTER $(DATA_RETURN_REGISTER)
endif #ifdef DATA_RETURN_REGISTER
ifdef DUC_REQUEST_REGISTER
BD_CHANGES += DUC_REQUEST_REGISTER $(DUC_REQUEST_REGISTER)
endif #ifdef DUC_REQUEST_REGISTER
ifdef DUC_RETURN_REGISTER
BD_CHANGES += DUC_RETURN_REGISTER $(DUC_RETURN_REGISTER)
endif #ifdef DUC_RETURN_REGISTER
ifdef DAUX_REQUEST_REGISTER
BD_CHANGES += DAUX_REQUEST_REGISTER $(DAUX_REQUEST_REGISTER)
endif #ifdef DAUX_REQUEST_REGISTER
ifdef DAUX_RETURN_REGISTER
BD_CHANGES += DAUX_RETURN_REGISTER $(DAUX_RETURN_REGISTER)
endif #ifdef DAUX_RETURN_REGISTER
ifdef DC_REQUEST_REGISTER
BD_CHANGES += DC_REQUEST_REGISTER $(DC_REQUEST_REGISTER)
endif #ifdef DC_REQUEST_REGISTER
ifdef DC_RETURN_REGISTER
BD_CHANGES += DC_RETURN_REGISTER $(DC_RETURN_REGISTER)
endif #ifdef DC_RETURN_REGISTER

BD_CHANGES += }


$(BD_FILE): $(PROJECT_TCL) $(BD_TCL) $(wildcard config.mk)
	if [ ! -e $(COE_FILE) ]; then echo "memory_initialization_radix=16;" > $(COE_FILE); echo "memory_initialization_vector=0;" >> $(COE_FILE); fi
	$(VIVADO_SOURCE) $(PROJECT_TCL) -tclargs init_project $(PROJ_DIR) $(PROJ_NAME)
	$(VIVADO_SOURCE) $(PROJECT_TCL) -tclargs create_bd $(PROJ_DIR) $(PROJ_NAME) $(BD_TCL) $(BD_CHANGES)

.PHONY: archiveBD
archiveBD: $(HWDEF_FILE)

$(HWDEF_FILE): $(BD_FILE)
	rm -f tmp.$(BD_TCL)
	rm -f $(HWDEF_FILE)
	$(VIVADO_SOURCE) $(PROJECT_TCL) -tclargs generate_bd_design $(PROJ_DIR) $(PROJ_NAME) tmp.$(BD_TCL)
	[ -e $(HWDEF_FILE) ]
	[ -e tmp.$(BD_TCL) ]
	touch -r $(BD_TCL) tmp.$(BD_TCL)
	cp -p tmp.$(BD_TCL) $(BD_TCL)
	rm tmp.$(BD_TCL)

HSI=hsi -nolog -nojournal -notrace -mode batch -source ../../tools/hsi_orca_addressmap.tcl -tclargs
orca_defines.h: $(HWDEF_FILE)
	$(HSI) -h $@  orca $^

$(SYNTH_DCP): $(HWDEF_FILE)
	$(VIVADO_SOURCE) $(PROJECT_TCL) -tclargs project_synth $(PROJ_DIR) $(PROJ_NAME)

$(IMPL_BIT): $(SYNTH_DCP)
	$(VIVADO_SOURCE) $(PROJECT_TCL) -tclargs project_impl $(PROJ_DIR) $(PROJ_NAME)

#These should come from the BSP
JTAG_RESET_BASE_ADDRESS ?= 0x40000000
ifdef RESET_VECTOR
RESET_VECTOR_HEX        := $(shell printf "0x%08X" $(RESET_VECTOR))
IDRAM_BASE_ADDRESS      ?= $(RESET_VECTOR_HEX)
JTAG_IDRAM_BASE_ADDRESS ?= $(RESET_VECTOR_HEX)
else #ifdef RESET_VECTOR
IDRAM_BASE_ADDRESS      ?= 0xA0000000
JTAG_IDRAM_BASE_ADDRESS ?= 0xA0000000
endif #else #ifdef RESET_VECTOR
IDRAM_LENGTH            ?= 0x00020000


link.ld:$(HWDEF_FILE)
	$(HSI) -l $@  orca $^

$(SW_DIR)/$(TEST).coe::
	$(MAKE) -C $(SW_DIR) $(TEST).coe $(TEST).dump

.PHONY: sim
ifndef TEST
sim:
	$(error Define TEST variable before running make sim ($(SW_DIR)/$$(TEST).coe will be used))
else #ifndef TEST
sim: $(BD_FILE) $(SW_DIR)/$(TEST).coe
	ln -sf $(SW_DIR)/$(TEST).coe $(COE_FILE)
	vivado -nolog -nojournal $(PROJ_FILE) -source simulate.tcl &
endif #else #ifndef TEST

.PHONY: gui
gui: $(BD_FILE)
	vivado -nolog -nojournal $(PROJ_FILE) &

.PHONY: bitstream
bitstream: $(OUT_BIT)

$(OUT_BIT): $(IMPL_BIT)
	cp $(IMPL_BIT) $(OUT_BIT)

resource_utilization.rpt: $(IMPL_BIT) $(RESOURCE_TCL)
	$(VIVADO_SOURCE) $(RESOURCE_TCL) -tclargs report_resources $(PROJ_DIR) $(PROJ_NAME) $@

.PHONY: pgm
pgm: $(OUT_BIT)
	xsdb $(PGM_TCL) $(OUT_BIT) ps7_init.tcl

.PHONY: FORCE
$(SW_DIR)/$(TEST).ihex: FORCE
	$(MAKE) -C $(SW_DIR) $(TEST).ihex $(TEST).dump

.PHONY: run
run: orca_defines.h
ifndef TEST
run:
	$(error Define TEST variable before running make run ($(SW_DIR)/$$(TEST).ihex will be used))
else #ifndef TEST
run: $(SW_DIR)/$(TEST).ihex FORCE
	python ../../tools/orca_pgm.py $(SW_DIR)/$(TEST).ihex  --family=xilinx --reset_address=$(JTAG_RESET_BASE_ADDRESS)
endif #else #ifndef TEST

.PHONY: clean
clean:
	rm -rf $(PROJ_DIR) $(PROJ_NAME).bit $(OUT_BIT) *.jou *.log tmp.* vivado_pid* export_sim/ test.bin jtag_init.tcl resource_utilization.rpt nohup.out *~  \#* .Xil orca_defines.h
	$(MAKE) clean -C $(SW_DIR)

.DELETE_ON_ERROR:
