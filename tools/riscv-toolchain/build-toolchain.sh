#!/bin/bash
if [ -z "$RISCV_INSTALL" ]
then
        echo "RISCV_INSTALL not defined, please define it to path for installing toolchain ... exiting" >&2
        exit 1
fi
if [ -z "$BUILD_DIR" ]
then
	 BUILD_DIR=$RISCV_INSTALL/build
fi
export SCRIPT_FILE=$(readlink -f $0)
export SCRIPT_DIR=$(readlink -f $(dirname $0))

mkdir -p $BUILD_DIR
cd $BUILD_DIR

export BINUTILS_VERSION=2.30
export GCC_VERSION=8.2.0
export NEWLIB_VERSION=3.0.0

[ ! -f binutils-$BINUTILS_VERSION.tar.gz ] && wget http://ftpmirror.gnu.org/binutils/binutils-$BINUTILS_VERSION.tar.gz
[ ! -f gcc-$GCC_VERSION.tar.gz ] && wget http://ftpmirror.gnu.org/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz
[ ! -f newlib-$NEWLIB_VERSION.tar.gz ] && wget ftp://sourceware.org/pub/newlib/newlib-$NEWLIB_VERSION.tar.gz
(
	 printf "Extracting Archives ... "
	 rm -rf binutils-$BINUTILS_VERSION
	 rm -rf gcc-$GCC_VERSION
	 rm -rf newlib-$NEWLIB_VERSION
	 tar -xf binutils-$BINUTILS_VERSION.tar.gz &
	 tar -xf gcc-$GCC_VERSION.tar.gz &
	 tar -xf newlib-$NEWLIB_VERSION.tar.gz &
	 wait
	 printf "Done\n"
)

export PATH=$RISCV_INSTALL/bin:$PATH

## ADD LVE instructions to the assembler.
OPCODES_PY_FILE=$SCRIPT_DIR/opcodes-lve.py
if [ -f $OPCODES_PY_FILE ]
then

	 python $OPCODES_PY_FILE #creates lve-extensions.h and riscv-lve.h

	 RISCV_OPC_H=binutils-$BINUTILS_VERSION/include/opcode/riscv-opc.h
	 mv riscv-lve.h  $(dirname $RISCV_OPC_H)
	 sed -i '/#define RISCV_ENCODING_H/a #include "riscv-lve.h"'  $RISCV_OPC_H

	 RISCV_OPC_C=binutils-$BINUTILS_VERSION/opcodes/riscv-opc.c
	 mv lve-extensions.h $(dirname $RISCV_OPC_C)
	 sed -i 's/#include "lve-extensions.h"//' $RISCV_OPC_C
	 sed -i  '/\ Terminate the list.  /i#include "lve-extensions.h"' $RISCV_OPC_C
	 #allow extensions to be passed int -march (this requirement should be removed in the future)
	 sed -i "s/if (\*p)/if (\*p \&\& *p != 'x')/" gcc-$GCC_VERSION/gcc/common/config/riscv/riscv-common.c
fi
#bash;exit 0

#binutils
(
	 rm -rf build-binutils

	 mkdir build-binutils
	 cd build-binutils
	 ../binutils-$BINUTILS_VERSION/configure --prefix=$RISCV_INSTALL --with-abi=ilp32 --with-arch=rv32im --target=riscv32-unknown-elf --disable-multilib
	 make -j$(( `nproc` * 2)) && make install
)

#gcc stage1
(
	 rm -rf build-gcc-stage1
	 mkdir -p build-gcc-stage1
	 cd build-gcc-stage1
	 ../gcc-$GCC_VERSION/configure --prefix=$RISCV_INSTALL --with-newlib --target=riscv32-unknown-elf --with-abi=ilp32 --with-arch=rv32im --enable-languages=c,c++ --disable-multilib
	 make -j$(( `nproc` * 2))  all-gcc && make install-gcc
)

#newlib
(
	 rm -rf build-newlib
	 mkdir build-newlib
	 cd build-newlib
	 ../newlib-$NEWLIB_VERSION/configure --target=riscv32-unknown-elf --prefix=$RISCV_INSTALL
	 make -j$(( `nproc` * 2)) && make install
)

#gcc stage2
(
	 rm -rf build-gcc-stage2
	 mkdir -p build-gcc-stage2
	 cd build-gcc-stage2
	 ../gcc-$GCC_VERSION/configure --prefix=$RISCV_INSTALL --with-newlib --target=riscv32-unknown-elf --with-abi=ilp32 --with-arch=rv32im --enable-languages=c,c++ --disable-multilib
	 make -j$(( `nproc` * 2))  && make install
)

#copy this script to the installation directory
cp $SCRIPT_FILE $RISCV_INSTALL/build-script.sh
