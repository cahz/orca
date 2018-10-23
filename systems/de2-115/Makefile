-include config.mk

BD_NAME := orca_system

#Select cached system by default if it exists
ifneq ($(wildcard orca_system_cached.qsys), )
BD_EXTENSION ?= _cached
else #ifeq ($(wildcard orca_system_cached.qsys), )
BD_EXTENSION ?= _tcm
endif #else #ifeq ($(wildcard orca_system_cached.qsys), )


BD_NAME         ?= orca_system
PROJECT_NAME    ?= orca_project
QSYS_HW_TCL     ?= $(BD_NAME)_hw.tcl
QSYS_SOURCE     ?= $(BD_NAME)$(BD_EXTENSION).qsys
QSYS_FILE       ?= $(BD_NAME).qsys
QPF_FILE        ?= $(PROJECT_NAME).qpf
IP_DIR          ?= ../../ip

QIP_FILE     := $(BD_NAME)/synthesis/$(BD_NAME).qip
SIP_FILE     := $(BD_NAME)/synthesis/$(BD_NAME).sip
OUTPUT_DIR   := output_files
MAP_RPT_FILE := $(OUTPUT_DIR)/$(PROJECT_NAME).map.rpt
FIT_RPT_FILE := $(OUTPUT_DIR)/$(PROJECT_NAME).fit.rpt
ASM_RPT_FILE := $(OUTPUT_DIR)/$(PROJECT_NAME).asm.rpt
STA_RPT_FILE := $(OUTPUT_DIR)/$(PROJECT_NAME).sta.rpt

TEST     ?= test
SW_DIR   ?= software
BIN_FILE := $(TEST).bin
HEX_FILE := $(TEST).qex

#Define DEVICE_FAMILY and DEVICE here
include board_cfg.mk

.PHONY: all
all: $(PROJECT_NAME).sof  $(STA_RPT_FILE)

TEST_FILES+=$(wildcard test_components/*.vhd)

ORCA_INTEL_VHDS := $(sort $(shell grep 'PATH hdl/' ../../ip/orca/orca_hw.tcl | sed 's|.*hdl/||g' | sed 's|\.vhd.*|\.vhd|g'))
ORCA_SUBMODULE_FILES=$(addprefix $(BD_NAME)/synthesis/submodules/vblox_orca/,$(ORCA_INTEL_VHDS))
TEST_SUBMODULE_FILES=$(addprefix $(BD_NAME)/synthesis/submodules/,$(notdir $(TEST_FILES)))
JTAG_SUBMODULE_FILES=$(wildcard memory_mapped_reset/*.vhd) 
SUBMODULE_FILES=$(ORCA_SUBMODULE_FILES) $(TEST_SUBMODULE_FILES) $(JTAG_SUBMODULE_FILES)
TOP_LEVEL_FILES=$(wildcard *.vhd)

ifdef REGISTER_SIZE
BD_CHANGES += updateORCA REGISTER_SIZE $(REGISTER_SIZE);
endif #ifdef REGISTER_SIZE
ifdef RESET_VECTOR
BD_CHANGES += updateORCA RESET_VECTOR $(RESET_VECTOR);
endif #ifdef RESET_VECTOR
ifdef INTERRUPT_VECTOR
BD_CHANGES += updateORCA INTERRUPT_VECTOR $(INTERRUPT_VECTOR);
endif #ifdef INTERRUPT_VECTOR
ifdef MAX_IFETCHES_IN_FLIGHT
BD_CHANGES += updateORCA MAX_IFETCHES_IN_FLIGHT $(MAX_IFETCHES_IN_FLIGHT);
endif #ifdef MAX_IFETCHES_IN_FLIGHT
ifdef BTB_ENTRIES
BD_CHANGES += updateORCA BTB_ENTRIES $(BTB_ENTRIES);
endif #ifdef BTB_ENTRIES
ifdef MULTIPLY_ENABLE
BD_CHANGES += updateORCA MULTIPLY_ENABLE $(MULTIPLY_ENABLE);
endif #ifdef MULTIPLY_ENABLE
ifdef DIVIDE_ENABLE
BD_CHANGES += updateORCA DIVIDE_ENABLE $(DIVIDE_ENABLE);
endif #ifdef DIVIDE_ENABLE
ifdef SHIFTER_MAX_CYCLES
BD_CHANGES += updateORCA SHIFTER_MAX_CYCLES $(SHIFTER_MAX_CYCLES);
endif #ifdef SHIFTER_MAX_CYCLES
ifdef ENABLE_EXCEPTIONS
BD_CHANGES += updateORCA ENABLE_EXCEPTIONS $(ENABLE_EXCEPTIONS);
endif #ifdef ENABLE_EXCEPTIONS
ifdef PIPELINE_STAGES
BD_CHANGES += updateORCA PIPELINE_STAGES $(PIPELINE_STAGES);
endif #ifdef PIPELINE_STAGES
ifdef VCP_ENABLE
BD_CHANGES += updateORCA VCP_ENABLE $(VCP_ENABLE);
endif #ifdef VCP_ENABLE
ifdef ENABLE_EXT_INTERRUPTS
BD_CHANGES += updateORCA ENABLE_EXT_INTERRUPTS $(ENABLE_EXT_INTERRUPTS);
endif #ifdef ENABLE_EXT_INTERRUPTS
ifdef NUM_EXT_INTERRUPTS
BD_CHANGES += updateORCA NUM_EXT_INTERRUPTS $(NUM_EXT_INTERRUPTS);
endif #ifdef NUM_EXT_INTERRUPTS
ifdef POWER_OPTIMIZED
BD_CHANGES += updateORCA POWER_OPTIMIZED $(POWER_OPTIMIZED);
endif #ifdef POWER_OPTIMIZED
ifdef FAMILY
BD_CHANGES += updateORCA FAMILY $(FAMILY);
endif #ifdef FAMILY
ifdef LOG2_BURSTLENGTH
BD_CHANGES += updateORCA LOG2_BURSTLENGTH $(LOG2_BURSTLENGTH);
endif #ifdef LOG2_BURSTLENGTH
ifdef AXI_ID_WIDTH
BD_CHANGES += updateORCA AXI_ID_WIDTH $(AXI_ID_WIDTH);
endif #ifdef AXI_ID_WIDTH
ifdef AVALON_AUX
BD_CHANGES += updateORCA AVALON_AUX $(AVALON_AUX);
endif #ifdef AVALON_AUX
ifdef LMB_AUX
BD_CHANGES += updateORCA LMB_AUX $(LMB_AUX);
endif #ifdef LMB_AUX
ifdef WISHBONE_AUX
BD_CHANGES += updateORCA WISHBONE_AUX $(WISHBONE_AUX);
endif #ifdef WISHBONE_AUX
ifdef AUX_MEMORY_REGIONS
BD_CHANGES += updateORCA AUX_MEMORY_REGIONS $(AUX_MEMORY_REGIONS);
endif #ifdef AUX_MEMORY_REGIONS
ifdef AMR0_ADDR_BASE
BD_CHANGES += updateORCA AMR0_ADDR_BASE $(AMR0_ADDR_BASE);
endif #ifdef AMR0_ADDR_BASE
ifdef AMR0_ADDR_LAST
BD_CHANGES += updateORCA AMR0_ADDR_LAST $(AMR0_ADDR_LAST);
endif #ifdef AMR0_ADDR_LAST
ifdef UC_MEMORY_REGIONS
BD_CHANGES += updateORCA UC_MEMORY_REGIONS $(UC_MEMORY_REGIONS);
endif #ifdef UC_MEMORY_REGIONS
ifdef UMR0_ADDR_BASE
BD_CHANGES += updateORCA UMR0_ADDR_BASE $(UMR0_ADDR_BASE);
endif #ifdef UMR0_ADDR_BASE
ifdef UMR0_ADDR_LAST
BD_CHANGES += updateORCA UMR0_ADDR_LAST $(UMR0_ADDR_LAST);
endif #ifdef UMR0_ADDR_LAST
ifdef ICACHE_SIZE
BD_CHANGES += updateORCA ICACHE_SIZE $(ICACHE_SIZE);
endif #ifdef ICACHE_SIZE
ifdef ICACHE_LINE_SIZE
BD_CHANGES += updateORCA ICACHE_LINE_SIZE $(ICACHE_LINE_SIZE);
endif #ifdef ICACHE_LINE_SIZE
ifdef ICACHE_EXTERNAL_WIDTH
BD_CHANGES += updateORCA ICACHE_EXTERNAL_WIDTH $(ICACHE_EXTERNAL_WIDTH);
endif #ifdef ICACHE_EXTERNAL_WIDTH
ifdef INSTRUCTION_REQUEST_REGISTER
BD_CHANGES += updateORCA INSTRUCTION_REQUEST_REGISTER $(INSTRUCTION_REQUEST_REGISTER);
endif #ifdef INSTRUCTION_REQUEST_REGISTER
ifdef INSTRUCTION_RETURN_REGISTER
BD_CHANGES += updateORCA INSTRUCTION_RETURN_REGISTER $(INSTRUCTION_RETURN_REGISTER);
endif #ifdef INSTRUCTION_RETURN_REGISTER
ifdef IUC_REQUEST_REGISTER
BD_CHANGES += updateORCA IUC_REQUEST_REGISTER $(IUC_REQUEST_REGISTER);
endif #ifdef IUC_REQUEST_REGISTER
ifdef IUC_RETURN_REGISTER
BD_CHANGES += updateORCA IUC_RETURN_REGISTER $(IUC_RETURN_REGISTER);
endif #ifdef IUC_RETURN_REGISTER
ifdef IAUX_REQUEST_REGISTER
BD_CHANGES += updateORCA IAUX_REQUEST_REGISTER $(IAUX_REQUEST_REGISTER);
endif #ifdef IAUX_REQUEST_REGISTER
ifdef IAUX_RETURN_REGISTER
BD_CHANGES += updateORCA IAUX_RETURN_REGISTER $(IAUX_RETURN_REGISTER);
endif #ifdef IAUX_RETURN_REGISTER
ifdef IC_REQUEST_REGISTER
BD_CHANGES += updateORCA IC_REQUEST_REGISTER $(IC_REQUEST_REGISTER);
endif #ifdef IC_REQUEST_REGISTER
ifdef IC_RETURN_REGISTER
BD_CHANGES += updateORCA IC_RETURN_REGISTER $(IC_RETURN_REGISTER);
endif #ifdef IC_RETURN_REGISTER
ifdef DCACHE_SIZE
BD_CHANGES += updateORCA DCACHE_SIZE $(DCACHE_SIZE);
endif #ifdef DCACHE_SIZE
ifdef DCACHE_WRITEBACK
BD_CHANGES += updateORCA DCACHE_WRITEBACK $(DCACHE_WRITEBACK);
endif #ifdef DCACHE_WRITEBACK
ifdef DCACHE_LINE_SIZE
BD_CHANGES += updateORCA DCACHE_LINE_SIZE $(DCACHE_LINE_SIZE);
endif #ifdef DCACHE_LINE_SIZE
ifdef DCACHE_EXTERNAL_WIDTH
BD_CHANGES += updateORCA DCACHE_EXTERNAL_WIDTH $(DCACHE_EXTERNAL_WIDTH);
endif #ifdef DCACHE_EXTERNAL_WIDTH
ifdef DATA_REQUEST_REGISTER
BD_CHANGES += updateORCA DATA_REQUEST_REGISTER $(DATA_REQUEST_REGISTER);
endif #ifdef DATA_REQUEST_REGISTER
ifdef DATA_RETURN_REGISTER
BD_CHANGES += updateORCA DATA_RETURN_REGISTER $(DATA_RETURN_REGISTER);
endif #ifdef DATA_RETURN_REGISTER
ifdef DUC_REQUEST_REGISTER
BD_CHANGES += updateORCA DUC_REQUEST_REGISTER $(DUC_REQUEST_REGISTER);
endif #ifdef DUC_REQUEST_REGISTER
ifdef DUC_RETURN_REGISTER
BD_CHANGES += updateORCA DUC_RETURN_REGISTER $(DUC_RETURN_REGISTER);
endif #ifdef DUC_RETURN_REGISTER
ifdef DAUX_REQUEST_REGISTER
BD_CHANGES += updateORCA DAUX_REQUEST_REGISTER $(DAUX_REQUEST_REGISTER);
endif #ifdef DAUX_REQUEST_REGISTER
ifdef DAUX_RETURN_REGISTER
BD_CHANGES += updateORCA DAUX_RETURN_REGISTER $(DAUX_RETURN_REGISTER);
endif #ifdef DAUX_RETURN_REGISTER
ifdef DC_REQUEST_REGISTER
BD_CHANGES += updateORCA DC_REQUEST_REGISTER $(DC_REQUEST_REGISTER);
endif #ifdef DC_REQUEST_REGISTER
ifdef DC_RETURN_REGISTER
BD_CHANGES += updateORCA DC_RETURN_REGISTER $(DC_RETURN_REGISTER);
endif #ifdef DC_RETURN_REGISTER

#Should get generated as part of BSP from system
orca_defines.h:
	touch $@

$(QSYS_FILE): $(QSYS_SOURCE) $(wilcard config.mk)
	cp $^ $@

.PHONY: gui-qsys
gui-qsys: $(QSYS_FILE)
	qsys-edit $(QSYS_FILE) --search-path="./,$(IP_DIR)/,$$" &

.PHONY: archiveBD
archiveBD:
	cp $(QSYS_FILE) $(QSYS_SOURCE)

$(QIP_FILE): $(QSYS_FILE) $(IP_DIR)/orca/orca_hw.tcl
	if [ -e $(SW_DIR)/Makefile ]; then $(MAKE) -C $(SW_DIR) $(HEX_FILE); fi
	rm -f $@
ifdef BD_CHANGES
	rm -f tmp.$(QSYS_FILE)
	qsys-script --search-path="./,$(IP_DIR)/,$$" --cmd="package require qsys; set_project_property DEVICE_FAMILY {$(DEVICE_FAMILY)}; set_project_property DEVICE $(DEVICE); load_system $(QSYS_FILE); source updateORCA.tcl; $(BD_CHANGES) save_system tmp.$(QSYS_FILE)"
	[ -e tmp.$(QSYS_FILE) ]
	mv tmp.$(QSYS_FILE) $(QSYS_FILE)
endif #ifdef BD_CHANGES
	cp $(QSYS_FILE) $(QSYS_SOURCE)
	touch $(QSYS_FILE)
	qsys-generate $(QSYS_FILE) --search-path="./,$(IP_DIR)/,$$" --synthesis=VHDL 2>&1 | tee ./synth.$(QSYS_FILE).log
	[ -e $@ ]

$(ORCA_SUBMODULE_FILES): $(BD_NAME)/synthesis/submodules/vblox_orca/% : $(IP_DIR)/orca/hdl/% | $(QIP_FILE)
	 cp $^ $@

.PHONY: copy-files
copy-files: $(ORCA_SUBMODULE_FILES)

$(TEST_SUBMODULE_FILES): $(BD_NAME)/synthesis/submodules/% : test_components/%
	cp $^ $@

.PHONY: gui-quartus
gui-quartus: $(QIP_FILE) $(SUBMODULE_FILES) $(TOP_LEVEL_FILES)
	quartus $(QPF_FILE) &


$(MAP_RPT_FILE) : $(QIP_FILE) $(SUBMODULE_FILES) $(TOP_LEVEL_FILES) 
	quartus_map $(QPF_FILE)
$(FIT_RPT_FILE) : $(MAP_RPT_FILE)
	quartus_fit $(QPF_FILE)
$(STA_RPT_FILE) : $(FIT_RPT_FILE)
	quartus_sta $(QPF_FILE)
$(OUTPUT_DIR)/$(PROJECT_NAME).sof $(ASM_RPT_FILE) : $(FIT_RPT_FILE)
	quartus_asm $(QPF_FILE)

$(PROJECT_NAME).sof: $(OUTPUT_DIR)/$(PROJECT_NAME).sof
	cp $(OUTPUT_DIR)/$@ $@

.PHONY: qip
qip: $(QIP_FILE)
.PHONY: map
map: $(MAP_RPT_FILE)
.PHONY: fit
fit: $(FIT_RPT_FILE)
.PHONY: asm
asm: $(ASM_RPT_FILE)
.PHONY: sta
sta: $(STA_RPT_FILE)

$(BD_NAME)/simulation/mentor/msim_setup.tcl: $(QSYS_FILE) $(SUBMODULE_FILES)
	qsys-generate $(QSYS_FILE) --search-path="./,$(IP_DIR)/,$$" --simulation=VHDL 2>&1 | tee ./sim.$(QSYS_FILE).log
	[ -e $@ ]

.PHONY: FORCE

$(SW_DIR)/$(HEX_FILE): FORCE
	$(MAKE) -C $(SW_DIR) $(HEX_FILE)
	[ -e $@ ]

$(BD_NAME)/simulation/mentor/software/$(HEX_FILE): $(BD_NAME)/simulation/mentor/msim_setup.tcl $(SW_DIR)/$(HEX_FILE)
	mkdir -p $(BD_NAME)/simulation/mentor/software
	cd $(BD_NAME)/simulation/mentor/software && ln -sf ../../../../software/$(HEX_FILE) 

.PHONY: sim
ifndef TEST
sim:
	$(error Define TEST variable before running make sim (software/$$(TEST).qex will be used))
else #ifndef TEST
sim: $(BD_NAME)/simulation/mentor/software/$(HEX_FILE)
	vsim -do simulate.tcl
endif #else #ifndef TEST

.PHONY: clean
clean:
	rm -rf $(BD_NAME)/ $(OUTPUT_DIR) $(QSYS_HW_TCL) $(QSYS_FILE)
	rm -rf db/ incremental_db/ *.rpt* *.summary *.smsg
	rm -rf *.log *.sopcinfo
	rm -rf *.sof .qsys_edit/
	rm -f *~ \#* PLL*_INFO.txt transcript jtag_init.tcl
	$(MAKE) -C $(SW_DIR)/ clean || true

.PHONY: pgm
pgm: $(PROJECT_NAME).sof
	quartus_pgm -m JTAG -o P\;$^

$(SW_DIR)/$(BIN_FILE): FORCE
	$(MAKE) -C $(SW_DIR) $(BIN_FILE) $(addsuffix .dump, $(basename $(BIN_FILE)))

.PHONY: run
ifndef TEST
run:
	$(error Define TEST variable before running make run (software/$$(TEST).bin will be used))
else #ifndef TEST
run: $(SW_DIR)/$(BIN_FILE) FORCE
	python orca_pgm.py $(SW_DIR)/$(BIN_FILE) --family=altera --base_address=0x80000000 --reset_address=0xFFFF0000 --end_address=0x80010000
endif #else #ifndef TEST

.PHONY: terminal-run
terminal-run:
	$(MAKE) run
	nios2-terminal | tee run.log

.PHONY: help
help:
	@echo "Makefile Help:"
	@echo "Targets:"
	@echo
	@echo "   all:"
	@echo "     Build bitstream and run timing reports"
	@echo
	@echo "   gui-qsys:"
	@echo "     Open the system in the QSYS GUI"
	@echo
	@echo "   gui-quartus:"
	@echo "     Open the project in the Quartus GUI"
	@echo
	@echo "   qip:"
	@echo "     Run qsys-generate"
	@echo
	@echo "   map:"
	@echo "     Run sythesis"
	@echo
	@echo "   fit:"
	@echo "     Run Place and Route"
	@echo
	@echo "   sta:"
	@echo "     Run timing analysis"
	@echo
	@echo "   asm:"
	@echo "     Assemble bitstream"
	@echo
	@echo "   clean:"
	@echo "     Clean all outputs"
	@echo
	@echo "   sim:"
	@echo "     Run Modelsim simulator"
	@echo
	@echo "   pgm:"
	@echo "     Program the attached de2-115 board"
	@echo
	@echo "   run:"
	@echo "     Program and run the program from the software directory"

.DELETE_ON_ERROR:
