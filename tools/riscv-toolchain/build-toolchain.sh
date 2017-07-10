#!/bin/sh
if [ -z "$RISCV_INSTALL" ]
then
        echo "RISCV_INSTALL not defined, please define it to path for installing toolchain ... exiting" >&2
        exit 1
fi

#get relevant git repositories, at the correct commit
git clone https://github.com/riscv/riscv-gnu-toolchain
(cd riscv-gnu-toolchain;
 git checkout -q ff21e26eb8c4d55dad7ad0b57e7bd8f7784a60e9;
 git submodule update --init --recursive
 )

if [ -f opcodes-lve.py ]
then
	 git clone https://github.com/riscv/riscv-opcodes.git
	 (cd riscv-opcodes;
	  git checkout -q 3c1a9110b71658f6e3249186e8b44e7474a4ee90;
	 )

	 #edit the opcodes to include lve instructions
	 python opcodes-lve.py > opcodes-lve
	 python opcodes-lve.py --riscv-opc > lve_extensions.h

	 OPCODE_FILES="opcodes-lve \
	 riscv-opcodes/opcodes-pseudo \
	 riscv-opcodes/opcodes \
	 riscv-opcodes/opcodes-rvc \
	 riscv-opcodes/opcodes-rvc-pseudo"

	 RISCV_OPC_H=riscv-gnu-toolchain/riscv-binutils-gdb/include/opcode/riscv-opc.h
	 cat $OPCODE_FILES | python riscv-opcodes/parse-opcodes -c > $RISCV_OPC_H


	 RISCV_OPC_C=riscv-gnu-toolchain/riscv-binutils-gdb/opcodes/riscv-opc.c
	 mv lve_extensions.h $(dirname $RISCV_OPC_C)
	 sed -i 's/#include "lve_extensions.h"//' $RISCV_OPC_C
	 sed -i  '/\ Terminate the list.  /i#include "lve_extensions.h"' $RISCV_OPC_C
fi

# start the compilation/build
cd riscv-gnu-toolchain
mkdir build
cd build
../configure --prefix=$RISCV_INSTALL --with-arch=rv32im --with-abi=ilp32

make -j $(( $(nproc)*2 ))
