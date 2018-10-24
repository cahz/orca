#include "orca_csrs.h"
#define REGBYTES 4

.section .text.init
//Currently we rely on
//reset vector being .text.init
//and interrupt vector being .text.init+4
_reset:
  j _start
  j _isr


.globl _start
_start:
  la gp, _gp
  la sp, _end_of_memory

  la t0, _isr
  csrw mtvec, t0

  jal main

1:
  j 1b

_isr:
  // Save all registers in the response of the caller on the stack.
  addi sp, sp, -64
  sw ra, 60(sp)
  sw t0, 56(sp)
  sw t1, 52(sp)
  sw t2, 48(sp)
  sw t3, 44(sp)
  sw t4, 40(sp)
  sw t5, 36(sp)
  sw t6, 32(sp)
  sw a0, 28(sp)
  sw a1, 24(sp)
  sw a2, 20(sp)
  sw a3, 16(sp)
  sw a4, 12(sp)
  sw a5,  8(sp)
  sw a6,  4(sp)
  sw a7,  0(sp)

  // Prepare the input registers to call the exception handler.
  csrr a0, mcause
  csrr a1, mepc
  mv   a2, sp
  jal  handle_exception
  csrw mepc, a0

  // Restore all registers in the response of the caller from the stack.
  lw ra, 60(sp)
  lw t0, 56(sp)
  lw t1, 52(sp)
  lw t2, 48(sp)
  lw t3, 44(sp)
  lw t4, 40(sp)
  lw t5, 36(sp)
  lw t6, 32(sp)
  lw a0, 28(sp)
  lw a1, 24(sp)
  lw a2, 20(sp)
  lw a3, 16(sp)
  lw a4, 12(sp)
  lw a5,  8(sp)
  lw a6,  4(sp)
  lw a7,  0(sp)
  addi sp, sp, 64

  mret
