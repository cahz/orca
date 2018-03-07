-include config.mk
export ORCA_TEST

#Select cached system by default if it exists
ifeq ($(wildcard orca_system_cached.tcl), )
BD_NAME ?= orca_system
else #ifeq ($(wildcard orca_system_cached.tcl), )
BD_NAME ?= orca_system_cached
endif #else #ifeq ($(wildcard orca_system_cached.tcl), )


PROJECT_TCL ?= project.tcl
BD_TCL      ?= $(BD_NAME).tcl

PROJ_DIR  ?= orca_project
PROJ_NAME ?= orca_project

SW_DIR   ?= software
COE_FILE ?= $(SW_DIR)/test.coe
ELF_FILE ?= $(SW_DIR)/test.elf
MEM_FILE ?= $(SW_DIR)/test.mem

PROJ_FILE=$(PROJ_DIR)/$(PROJ_NAME).xpr
BD_FILE=$(PROJ_DIR)/$(PROJ_NAME).srcs/sources_1/bd/$(BD_NAME)/$(BD_NAME).bd
HWH_FILE_SRC=$(PROJ_DIR)/$(PROJ_NAME).srcs/sources_1/bd/$(BD_NAME)/hw_handoff/$(BD_NAME).hwh
HWH_FILE=$(BD_NAME).hwh
HWDEF_FILE=$(PROJ_DIR)/$(PROJ_NAME).srcs/sources_1/bd/$(BD_NAME)/synth/$(BD_NAME).hwdef
SYNTH_DCP=$(PROJ_DIR)/$(PROJ_NAME).runs/synth_1/$(BD_NAME)_wrapper.dcp
IMPL_BIT=$(PROJ_DIR)/$(PROJ_NAME).runs/impl_1/$(BD_NAME)_wrapper.bit
ORCA_SRCS=$(wildcard ../../ip/orca/hdl/*.vhd) ../../ip/orca/component.xml

RESOURCE_TCL=report_resource_usage.tcl
OUT_BIT=out.bit

PGM_TCL=pgm.tcl

.PHONY: all
all: $(OUT_BIT) resource_utilization.rpt link.ld

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
ifdef COUNTER_LENGTH
BD_CHANGES += COUNTER_LENGTH $(COUNTER_LENGTH)
endif #ifdef COUNTER_LENGTH
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
archiveBD: $(HWH_FILE)

#we generate the bd design twice, because the hwh is needed to compile the software,
#and the compiled software is needed to generate the sources.
$(HWH_FILE): $(BD_FILE) $(ORCA_SRCS)
	if [ ! -e $(COE_FILE) ]; then echo "memory_initialization_radix=16;" > $(COE_FILE); echo "memory_initialization_vector=0;" >> $(COE_FILE); fi
	rm -f tmp.$(BD_TCL)
	$(VIVADO_SOURCE) $(PROJECT_TCL) -tclargs generate_bd_design $(PROJ_DIR) $(PROJ_NAME) tmp.$(BD_TCL)
	[ -e tmp.$(BD_TCL) ]
	[ -e $(HWH_FILE_SRC) ]
	mv tmp.$(BD_TCL) $(BD_TCL)
	touch $<
	cp $(HWH_FILE_SRC) $@

$(HWDEF_FILE): $(COE_FILE)
	$(VIVADO_SOURCE) $(PROJECT_TCL) -tclargs generate_bd_design $(PROJ_DIR) $(PROJ_NAME)
	rm -f tmp.$(BD_TCL)


orca_defines.h: $(HWH_FILE)
	hsi -notrace -mode batch -source ../../tools/hsi_orca_addressmap.tcl -tclargs $(HWH_FILE) orca $@
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


link.ld::
	sed "s/0x[0-9A-F]\([0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]\)/0x$$(printf "%01X" $$(expr $$(echo $$(printf "%d" $(IDRAM_BASE_ADDRESS))) / $$(echo $$(printf "%d" 0x10000000))))\1/g" $@ > tmp.$@
	diff -q $@ tmp.$@; if [ $$? != 0 ]; then mv tmp.$@ $@; fi
	rm -f tmp.$@

.PHONY: FORCE

$(ELF_FILE): orca_defines.h FORCE
	$(MAKE) -C $(SW_DIR)

$(COE_FILE): orca_defines.h FORCE
	$(MAKE) -C $(SW_DIR)

.PHONY: sim
sim: $(BD_FILE) $(COE_FILE)
	vivado -nolog -nojournal $(PROJ_FILE) -source simulate.tcl &

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
ifneq ($(ELF_FILE), NONE)
pgm: $(OUT_BIT)
endif #ifneq ($(ELF_FILE), NONE)
pgm:
	xsdb $(PGM_TCL) $(OUT_BIT) ps7_init.tcl

no_elf:
	echo "no elf"
	false

yes_elf:
	echo "yes elf"
	false

.PHONY: run
run:
ifeq ($(ELF_FILE), NONE)
	python orca_pgm.py test.bin --family=xilinx --reset_address=$(JTAG_RESET_BASE_ADDRESS) --base_address=$(JTAG_IDRAM_BASE_ADDRESS) --end_address=`printf "0x%08X" $$(($(JTAG_IDRAM_BASE_ADDRESS) + $(IDRAM_LENGTH)))` --device=xc7z* --project=$(PROJ_FILE) --debug_nets=$(PROJ_DIR)/$(PROJ_NAME).runs/impl_1/$(BD_NAME)_wrapper.ltx --output_file=jtag_init.tcl
else #ifeq ($(ELF_FILE), NONE)
	$(MAKE) -C software test.bin test.dump
	python orca_pgm.py software/test.bin --family=xilinx --reset_address=$(JTAG_RESET_BASE_ADDRESS) --base_address=$(JTAG_IDRAM_BASE_ADDRESS) --end_address=`printf "0x%08X" $$(($(JTAG_IDRAM_BASE_ADDRESS) + $(IDRAM_LENGTH)))` --device=xc7z* --project=$(PROJ_FILE) --debug_nets=$(PROJ_DIR)/$(PROJ_NAME).runs/impl_1/$(BD_NAME)_wrapper.ltx --output_file=jtag_init.tcl
endif #else #ifeq ($(ELF_FILE), NONE)

.PHONY: clean
clean:
	rm -rf $(PROJ_DIR) $(PROJ_NAME).bit $(OUT_BIT) *.jou *.log tmp.* vivado_pid* export_sim/ test.bin jtag_init.tcl resource_utilization.rpt nohup.out *~  \#* .Xil $(HWH_FILE) orca_defines.h
	$(MAKE) clean -C $(SW_DIR)

.DELETE_ON_ERROR:
