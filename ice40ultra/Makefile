all:
.SUFFIXES:

ifndef ICECUBE2
ifeq ($(findstring Vectorblox,$(ORGANIZATION)),Vectorblox)
ICECUBE2=/nfs/opt/lattice/iCEcube2/2015.14
else
$(error Variable $$ICECUBE2 not defined )
endif
endif

PROJECT=ice40ultra
SBT_PROJECT=$(PROJECT)_sbt.project
SYN_PRJ=$(PROJECT)_syn.prj
LSE_PRJ=$(PROJECT)_lse.prj
OUTPUT_DIR=$(PROJECT)_Implmnt
TOP_LEVEL_ENTITY=top
COMPILER_LOG=$(OUTPUT_DIR)/synlog/$(PROJECT)_compiler.srr
TIMING_REPORT=$(OUTPUT_DIR)/sbt/outputs/router/top_timing.rpt
EDF=$(OUTPUT_DIR)/$(PROJECT).edf
BITFILE=$(OUTPUT_DIR)/sbt/outputs/bitmap/$(TOP_LEVEL_ENTITY)_bitmap.hex

IMEM_LIST=imem.list
DMEM_LIST=dmem.list
MEM_FILE=test.mem
HDL_FILES=$(wildcard hdl/*.vhd) $(wildcard hdl/*.v) $(wildcard ../*.vhd)
all: build-software bit
bit: $(BITFILE)

IMEM_BASE=0
IMEM_LEN=4096
DMEM_BASE=4096
DMEM_LEN=4096

imem.mem: $(MEM_FILE)
	tail -n +$$(( $(IMEM_BASE)/4 +1)) test.mem | head -n $$(( $(IMEM_LEN)/4)) >$@
dmem.mem: $(MEM_FILE)
	tail -n +$$(($(DMEM_BASE)/4 +1)) test.mem | head -n $$(( $(DMEM_LEN)/4)) >$@


define ice-tcl
ICECUBE2=$(ICECUBE2) tclsh
endef

define mem-init
LD_LIBRARY_PATH=$(ICECUBE2)/sbt_backend/lib/linux/opt:$${LD_LIBRARY_PATH} $(ICECUBE2)/sbt_backend/bin/linux/opt/meminitializer --des-lib $(OUTPUT_DIR)/sbt/netlist/oadb-top --mem-list-file
endef
$(BITFILE): $(TIMING_REPORT) dmem.mem imem.mem $(DMEM_LIST) $(IMEM_LIST)
	$(ice-tcl) iCEcube2_flow.tcl dmem.mem $(DMEM_LIST)
	$(ice-tcl) iCEcube2_flow.tcl imem.mem $(IMEM_LIST)

	$(mem-init) $(IMEM_LIST)
	$(mem-init) $(DMEM_LIST)

	$(ice-tcl) iCEcube2_flow.tcl $(DMEM_LIST)
	$(ice-tcl) iCEcube2_flow.tcl $(IMEM_LIST)


$(TIMING_REPORT): $(EDF)
	ICECUBE2=$(ICECUBE2) tclsh iCEcube2_flow.tcl
$(EDF): $(HDL_FILES)
#run the compiler, output the log if compiler fails
	SYNPLIFY_PATH=$(ICECUBE2)/synpbase \
	SBT_DIR=$(ICECUBE2)/sbt_backend/ \
	LD_LIBRARY_PATH=$(ICECUBE2)/sbt_backend/bin/linux/opt/synpwrap:$${LD_LIBRARY_PATH} \
	$(ICECUBE2)/sbt_backend/bin/linux/opt/synpwrap/synpwrap -prj $(SYN_PRJ) || \
	 ( cat $(COMPILER_LOG) && exit -1)


syn: $(EDF)




clean:
	rm -rf $(OUTPUT_DIR) *.imem

clean-all: clean
	make -C software clean

build-software:
	make -C software FORMAT=mem
	ln -sf software/*.mem $(MEM_FILE)

.phony: syn all clean clean-all build-software bit
