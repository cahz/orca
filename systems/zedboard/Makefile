
PROJECT_TCL=project.tcl
BD_TCL=design_1.tcl
PGM_TCL=pgm.tcl

PROJ_DIR=project/
PROJ_NAME=project

SW_DIR=software
ELF_FILE=$(SW_DIR)/test.elf
MEM_FILE=$(SW_DIR)/test.mem

PROJ_FILE=$(PROJ_DIR)/$(PROJ_NAME).xpr
BD_FILE=$(PROJ_DIR)/$(PROJ_NAME).srcs/sources_1/bd/design_1/design_1.bd
BLOCK_DESIGN_GEN_STAMP=$(BD_FILE).gen_stamp
HWDEF_FILE=$(PROJ_DIR)/$(PROJ_NAME).srcs/sources_1/bd/design_1/design_1.hwdef
SYNTH_LOG=$(PROJ_DIR)/$(PROJ_NAME).runs/synth_1/runme.log
IMPL_LOG=$(PROJ_DIR)/$(PROJ_NAME).runs/impl_1/runme.log
VIVADO=vivado -mode tcl -nolog -nojournal

MMI_TCL=write_mmi.tcl
BRAM_NAME=idram_gen
MMI_FILE=$(BRAM_NAME).mmi
OUT_BIT=out.bit
GUI_BIT=$(PROJ_DIR)project.runs/impl_1/design_1_wrapper.bit

all:$(OUT_BIT)

$(PROJ_FILE) $(BD_FILE):
	echo "init_project $(PROJ_DIR) $(PROJ_NAME)" | $(VIVADO) -source $(PROJECT_TCL)
	echo "create_bd $(PROJ_DIR) $(PROJ_NAME) $(BD_TCL)" | $(VIVADO) -source $(PROJECT_TCL)

$(BLOCK_DESIGN_GEN_STAMP): $(BD_FILE)
	echo "generate_bd_design $(PROJ_DIR) $(PROJ_NAME)" | $(VIVADO) -source $(PROJECT_TCL)
	touch $@

$(SYNTH_LOG): $(BLOCK_DESIGN_GEN_STAMP) 
	echo "project_synth $(PROJ_DIR) $(PROJ_NAME)" | $(VIVADO) -source $(PROJECT_TCL)

$(IMPL_LOG): $(SYNTH_LOG)
	echo "project_impl $(PROJ_DIR) $(PROJ_NAME)" | $(VIVADO) -source $(PROJECT_TCL)

$(PROJ_NAME).bit: $(IMPL_LOG)
	echo "export_bit $(PROJ_DIR) $(PROJ_NAME)" | $(VIVADO) -source $(PROJECT_TCL)

$(MMI_FILE): $(IMPL_LOG) 
	echo "mmi_wrapper $(PROJ_DIR) $(PROJ_NAME) $(BRAM_NAME)" | $(VIVADO) -source $(MMI_TCL)

$(ELF_FILE):
	make -C $(SW_DIR)

$(OUT_BIT): $(PROJ_NAME).bit $(MMI_FILE) $(ELF_FILE)
	updatemem -force --meminfo $(MMI_FILE) \
  	--data $(ELF_FILE) \
  	--bit $(PROJ_NAME).bit \
  	--proc dummy \
  	--out $(OUT_BIT) 

bitstream: 
	make -C $(SW_DIR)
	updatemem -force --meminfo $(MMI_FILE) \
  	--data $(ELF_FILE) \
  	--bit $(GUI_BIT) \
  	--proc dummy \
  	--out $(OUT_BIT) 
    
trigger_bitstream: 
	make -C $(SW_DIR)
	updatemem -force --meminfo $(MMI_FILE) \
  	--data $(ELF_FILE) \
  	--bit trig_at_startup.bit \
  	--proc dummy \
  	--out $(OUT_BIT) 

pgm: $(OUT_BIT)
	echo "pgm_bits $(PROJ_DIR) $(PROJ_NAME)" | $(VIVADO) -source $(PGM_TCL)

clean:
	rm -rf $(PROJ_DIR) $(PROJ_NAME).bit $(OUT_BIT) $(MMI_FILE) *.jou *.log
	make clean -C $(SW_DIR)
