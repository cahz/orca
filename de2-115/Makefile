QSYS_FILE=system.qsys
QPF_FILE=system.qpf
QIP_FILE=system/synthesis/system.qip
SIP_FILE=system/synthesis/system.sip
OUTPUT_DIR=output_files/
MAP_RPT_FILE=$(OUTPUT_DIR)system.map.rpt
FIT_RPT_FILE=$(OUTPUT_DIR)system.fit.rpt
ASM_RPT_FILE=$(OUTPUT_DIR)system.asm.rpt
MIF_RPT_FILE=$(OUTPUT_DIR)system.mif_update.rpt
STA_RPT_FILE=$(OUTPUT_DIR)system.sta.rpt

all: system.sof  $(STA_RPT_FILE)

DEVICE_FAMILY=$(shell grep deviceFamily $(QSYS_FILE) | head -1 | sed 's/.*value="\(.*\)".*/\1/')
ORCA_FILES=$(wildcard ../rtl/*.vhd)
TEST_FILES+=$(wildcard test_components/*.vhd)

ORCA_SUBMODULE_FILES=$(addprefix system/synthesis/submodules/vblox_orca/,$(notdir $(ORCA_FILES)))
TEST_SUBMODULE_FILES=$(addprefix system/synthesis/submodules/,$(notdir $(TEST_FILES)))
SUBMODULE_FILES=$(ORCA_SUBMODULE_FILES) $(TEST_SUBMODULE_FILES)
TOP_LEVEL_FILES=$(wildcard *.vhd)

-include config.mk

$(QSYS_FILE):$(wildcard config.mk)
ifdef BRANCH_PREDICTION
	sed -i 's|parameter name="BRANCH_PREDICTION" value=".*" />|parameter name="BRANCH_PREDICTION" value=$(BRANCH_PREDICTION) />|' $(QSYS_FILE)
endif
ifdef BTB_SIZE
	sed -i 's|parameter name="BTB_SIZE" value=".*" />|parameter name="BTB_SIZE" value=$(BTB_SIZE) />|' $(QSYS_FILE)
endif
ifdef DIVIDE_ENABLE
	sed -i 's|parameter name="DIVIDE_ENABLE" value=".*" />|parameter name="DIVIDE_ENABLE" value=$(DIVIDE_ENABLE) />|' $(QSYS_FILE)
endif
ifdef COUNTER_LENGTH
	sed -i 's|parameter name="COUNTER_LENGTH" value=".*" />|parameter name="COUNTER_LENGTH" value=$(COUNTER_LENGTH) />|' $(QSYS_FILE)
endif
ifdef MULTIPLY_ENABLE
	sed -i 's|parameter name="MULTIPLY_ENABLE" value=".*" />|parameter name="MULTIPLY_ENABLE" value=$(MULTIPLY_ENABLE) />|' $(QSYS_FILE)
endif
ifdef PIPELINE_STAGES
	sed -i 's|parameter name="PIPELINE_STAGES" value=".*" />|parameter name="PIPELINE_STAGES" value=$(PIPELINE_STAGES) />|' $(QSYS_FILE)
endif
ifdef SHIFTER_MAX_CYCLES
	sed -i 's|parameter name="SHIFTER_MAX_CYCLES" value=".*" />|parameter name="SHIFTER_MAX_CYCLES" value=$(SHIFTER_MAX_CYCLES) />|' $(QSYS_FILE)
endif
#ifdef FORWARD_ALU_ONLY
#	sed -i 's|parameter name="FORWARD_ALU_ONLY" value=".*" />|parameter name="FORWARD_ALU_ONLY" value="$(FORWARD_ALU_ONLY)" />|' $(QSYS_FILE)
#endif

$(QIP_FILE):$(QSYS_FILE) ../rtl/orca_hw.tcl
	qsys-generate --synthesis=VHDL system.qsys 2>&1 | tee ./system.qsys.log
	rm $(ORCA_SUBMODULE_FILES)

$(ORCA_SUBMODULE_FILES): system/synthesis/submodules/vblox_orca/% : ../rtl/% | $(QIP_FILE)
	 cp $^ $@

.phony: copy-files

copy-files: $(ORCA_SUBMODULE_FILES)

$(TEST_SUBMODULE_FILES): system/synthesis/submodules/% : test_components/%
	cp $^ $@

ifndef NO_SW
HEX_FILE=test.hex
else
HEX_FILE=
endif

$(MAP_RPT_FILE) : $(QIP_FILE) $(SUBMODULE_FILES) $(TOP_LEVEL_FILES)
	quartus_map $(QPF_FILE)
$(FIT_RPT_FILE) : $(MAP_RPT_FILE)
	quartus_fit $(QPF_FILE)
$(STA_RPT_FILE) : $(FIT_RPT_FILE)
	quartus_sta $(QPF_FILE)
$(MIF_RPT_FILE) : $(FIT_RPT_FILE) $(HEX_FILE)
	quartus_cdb --update_mif $(QPF_FILE)
$(ASM_RPT_FILE) : $(MIF_RPT_FILE)
	quartus_asm $(QPF_FILE)

system.sof: $(ASM_RPT_FILE)
	cp $(OUTPUT_DIR)/$@ $@

qip: $(QIP_FILE)
map: $(MAP_RPT_FILE)
fit: $(FIT_RPT_FILE)
mif: $(MIF_RPT_FILE)
asm: $(ASM_RPT_FILE)
sta: $(STA_RPT_FILE)

.phony: all clean qip map fit mif asm sta pgm testbench sim help

testbench: system/testbench/mentor/msim_setup.tcl

system/testbench/mentor/msim_setup.tcl:$(QSYS_FILE) $(RTL_FILES) $(TEST_RTL_FILES)
	qsys-generate --testbench --testbench-simulation=VHDL $(QSYS_FILE)

sim:system/testbench/mentor/msim_setup.tcl test.hex
	vsim -do simulate.tcl

clean:
	rm -rf system/ $(OUTPUT_DIR)
	rm -rf db/ incremental_db/
	rm -rf *.log system.sopcinfo
	rm -rf system.sof .qsys_edit/
pgm: system.sof
	quartus_pgm -m JTAG -o P\;$^

help:
	@echo "Makefile Help:"
	@echo "Targets:"
	@echo
	@echo "   all:"
	@echo "     Build bitstream and run timing reports"
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
	@echo "   testbench:"
	@echo "     Generate testbench from qsys file"
	@echo
	@echo "   sim:"
	@echo "     Run modelsim simulator"
	@echo
	@echo "   pgm:"
	@echo "     Program the attached de2-115 board"
