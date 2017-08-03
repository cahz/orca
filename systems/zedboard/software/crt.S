#define REGBYTES 4

.section .init
  
.globl _start
_start:
  la gp, _gp
  la sp, _end_of_memory

	// Enable interrupts.
  csrsi mstatus, 0x8 

	// Enable all interrupt masks.
	// Note: our meimask csr is non-standard.
	li x1, 0xFFFFFFFF
	csrw 0x7C0, x1

  jal main
1:
  j 1b

.align 9
_isr:
  addi sp, sp, -272

  sw x1, 1*REGBYTES(sp)
  sw x2, 2*REGBYTES(sp)
  sw x3, 3*REGBYTES(sp)
  sw x4, 4*REGBYTES(sp)
  sw x5, 5*REGBYTES(sp)
  sw x6, 6*REGBYTES(sp)
  sw x7, 7*REGBYTES(sp)
  sw x8, 8*REGBYTES(sp)
  sw x9, 9*REGBYTES(sp)
  sw x10, 10*REGBYTES(sp)
  sw x11, 11*REGBYTES(sp)
  sw x12, 12*REGBYTES(sp)
  sw x13, 13*REGBYTES(sp)
  sw x14, 14*REGBYTES(sp)
  sw x15, 15*REGBYTES(sp)
  sw x16, 16*REGBYTES(sp)
  sw x17, 17*REGBYTES(sp)
  sw x18, 18*REGBYTES(sp)
  sw x19, 19*REGBYTES(sp)
  sw x20, 20*REGBYTES(sp)
  sw x21, 21*REGBYTES(sp)
  sw x22, 22*REGBYTES(sp)
  sw x23, 23*REGBYTES(sp)
  sw x24, 24*REGBYTES(sp)
  sw x25, 25*REGBYTES(sp)
  sw x26, 26*REGBYTES(sp)
  sw x27, 27*REGBYTES(sp)
  sw x28, 28*REGBYTES(sp)
  sw x29, 29*REGBYTES(sp)
  sw x30, 30*REGBYTES(sp)
  sw x31, 31*REGBYTES(sp)

	// Prepare the input registers for the interrupt handler.
  csrr a0, mcause
  csrr a1, mepc
  mv a2, sp
  jal handle_interrupt
  csrw mepc, a0

  lw x1, 1*REGBYTES(sp)
  lw x2, 2*REGBYTES(sp)
  lw x3, 3*REGBYTES(sp)
  lw x4, 4*REGBYTES(sp)
  lw x5, 5*REGBYTES(sp)
  lw x6, 6*REGBYTES(sp)
  lw x7, 7*REGBYTES(sp)
  lw x8, 8*REGBYTES(sp)
  lw x9, 9*REGBYTES(sp)
  lw x10, 10*REGBYTES(sp)
  lw x11, 11*REGBYTES(sp)
  lw x12, 12*REGBYTES(sp)
  lw x13, 13*REGBYTES(sp)
  lw x14, 14*REGBYTES(sp)
  lw x15, 15*REGBYTES(sp)
  lw x16, 16*REGBYTES(sp)
  lw x17, 17*REGBYTES(sp)
  lw x18, 18*REGBYTES(sp)
  lw x19, 19*REGBYTES(sp)
  lw x20, 20*REGBYTES(sp)
  lw x21, 21*REGBYTES(sp)
  lw x22, 22*REGBYTES(sp)
  lw x23, 23*REGBYTES(sp)
  lw x24, 24*REGBYTES(sp)
  lw x25, 25*REGBYTES(sp)
  lw x26, 26*REGBYTES(sp)
  lw x27, 27*REGBYTES(sp)
  lw x28, 28*REGBYTES(sp)
  lw x29, 29*REGBYTES(sp)
  lw x30, 30*REGBYTES(sp)
  lw x31, 31*REGBYTES(sp)

  addi sp, sp, 272

  mret
