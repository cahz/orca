#!/bin/bash
SCRIPTDIR=$(readlink -f $(dirname $0))

RISCV_TEST_DIR=$SCRIPTDIR/../software/riscv-tests
set -e
set -o pipefail
(
	 cd $(dirname $RISCV_TEST_DIR)
	 git submodule update --init --recursive $(basename ${RISCV_TEST_DIR})
	 cd ${RISCV_TEST_DIR}
	 sed -i 's/. = 0x80000000/. = 0x00000000/' env/p/link.ld
	 sed -i 's/.tohost.*$//' env/p/link.ld
	 sed -i 's/ ecall/fence.i;ecall/' env/p/riscv_test.h
	 ./configure --with-xlen=32 2>&1
	 make clean &>/dev/null
	 make -k isa -j10 >/dev/null 2>&1 || true

)

TEST_DIR=${RISCV_TEST_DIR}/isa
FILES=$(ls ${TEST_DIR}/rv32u[ima]-p-* | grep -v dump | grep -v hex)

PREFIX=riscv32-unknown-elf
OBJDUMP=$PREFIX-objdump
OBJCOPY=$PREFIX-objcopy

mkdir -p test


#MEM files are for lattice boards, the hex files are for altera boards
for f in $FILES
do

	 BIN_FILE=test/$(basename $f).bin
	 QEX_FILE=test/$(basename $f).qex
	 MEM_FILE=test/$(basename $f).mem
	 MIF_FILE=test/$(basename $f).mif
	 SPLIT_FILE=test/$(basename $f).split2
	 echo "$f > $QEX_FILE"
	 (
		  cp $f test/
		  $OBJCOPY  -O binary $f $BIN_FILE
		  $OBJDUMP --disassemble-all -Mnumeric,no-aliases $f > test/$(basename $f).dump

		  python $SCRIPTDIR/bin2hex.py $BIN_FILE -a 0x0 > $QEX_FILE || exit -1
		  sed -e 's/://' -e 's/\(..\)/\1 /g'  $QEX_FILE >$SPLIT_FILE
		  awk '{if (NF == 9) print $5$6$7$8}' $SPLIT_FILE > $MEM_FILE
		 # rm -f $MIF_FILE $SPLIT_FILE
	 ) &
done
wait

(
 	 #cleanup edits
	 cd ${RISCV_TEST_DIR}/env
	 git checkout .
)
