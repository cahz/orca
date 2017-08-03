#!/bin/bash
set -e
#warning Compiling for r

SCRIPTDIR=$(dirname $0)

SEED=$1

#
#mkdir -p csmith-files



compile_dir=csmith-compile/
mkdir -p $compile_dir
#compile host
/nfs/opt/csmith-2.2.0/bin/csmith -s $SEED | gcc -O2 -w -xc - -I /nfs/opt/csmith-2.2.0/include/csmith-2.2.0/ -o $compile_dir/csmith-host-seed$SEED

#compile risc-v
OUT_C=$compile_dir/csmith-riscv-seed$SEED.c
ELF_FILE=$compile_dir/csmith-riscv-seed$SEED
BIN_FILE=$ELF_FILE.bin
MIF_FILE=${BIN_FILE/bin/mif}
HEX_FILE=${BIN_FILE/bin/hex}
DUMP_FILE=${BIN_FILE/bin/dump}

/nfs/opt/csmith-2.2.0/bin/csmith -s $SEED > $OUT_C
riscv32-unknown-elf-gcc -O2 -w -c  -march=RV32IMXmxp -xc $OUT_C -I /nfs/opt/csmith-2.2.0/include/csmith-2.2.0/ -o $compile_dir/csmith-riscv-seed$SEED.o
riscv32-unknown-elf-gcc -O2 -T ../software/link_csmith.ld  $compile_dir/csmith-riscv-seed$SEED.o ../software/crt.S  -o $ELF_FILE -m32 -march=RV32IMXmxp -static -nostartfiles -I/nfs/opt/csmith-2.2.0/include/csmith-2.2.0/ -w

riscv32-unknown-elf-objcopy -O binary $ELF_FILE $BIN_FILE

riscv32-unknown-elf-objdump --disassemble-all -Mnumeric,no-aliases $ELF_FILE > $DUMP_FILE
python $SCRIPTDIR/bin2mif.py $BIN_FILE 0  > $MIF_FILE
mif2hex $MIF_FILE $HEX_FILE >/dev/null 2>&1
cp $HEX_FILE system_csmith/simulation/mentor/test.hex
HOST_OUT=$(timeout 10s $compile_dir/csmith-host-seed$SEED || echo timeout)
if [ "$HOST_OUT" = "timeout" ]
then
	 echo timeout $SEED
	 exit 0
fi
SIM_TCL="cd system_csmith/simulation/mentor;
do msim_setup.tcl;
ld;
add log -r *;
add wave /system_csmith/vectorblox_orca_0/core/X/syscall/mscratch;
when {system_csmith/vectorblox_orca_0/core/X/instruction == x\"00000073\" && system_csmith/vectorblox_orca_0/core/X/valid_input == \"1\" } {stop};
run 10ms;
set v [examine -radix decimal /system_csmith/vectorblox_orca_0/core/X/syscall/mscratch];
puts [format \"checksum = %X\" \$v ];
exit -f ;
"


RISCV_OUT=$(vsim -c -do "$SIM_TCL" | egrep '^[^#R]')


if [ "${RISCV_OUT}" = "${HOST_OUT}" ]
then
	 echo "r$RISCV_OUT h$HOST_OUT PASS  $SEED" | sed 's/checksum = //g'
else
	 echo "r$RISCV_OUT h$HOST_OUT FAIL  $SEED" | sed 's/checksum = //g'
fi
