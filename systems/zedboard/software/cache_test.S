.section .text
.globl cache_test
.type cache_test, @function

cache_test:
  addi sp, sp, -48
  sw   s0, 44(sp)
  sw   s1, 40(sp)
  sw   s2, 36(sp)
  sw   s3, 32(sp)
  sw   s4, 28(sp)
  sw   s5, 24(sp)
  sw   s6, 20(sp)
  sw   s7, 16(sp)
  sw   s8, 12(sp)
  sw   s9,  8(sp)
  sw   s10, 4(sp)
  sw   s11, 0(sp)


//ASM cache tests go here

  //Initially report succoss
  li a0, 0
        
  //Do a FENCE.  ORCA memory accesses are strictly in-order so
  //assuming that's not broken the FENCE should have no effect and so
  //can't be tested aside from making sure it doesn't decode to an
  //illegal instruction.
  fence iorw, iorw

  //Do a FENCE.R; same deal as FENCE
  //fence.r s0, x0, sp
  .word 0x0420140F
        
        
cache_test_done:
  lw   s0, 44(sp)
  lw   s1, 40(sp)
  lw   s2, 36(sp)
  lw   s3, 32(sp)
  lw   s4, 28(sp)
  lw   s5, 24(sp)
  lw   s6, 20(sp)
  lw   s7, 16(sp)
  lw   s8, 12(sp)
  lw   s9,  8(sp)
  lw   s10, 4(sp)
  lw   s11, 0(sp)
  addi sp, sp, 48
  ret

.globl idram_timing_loop
.type idram_timing_loop, @function

//These get copied into cacheable/uncacheable memory for testing timing
idram_timing_loop:
  beq  a0, x0, idram_timing_loop_ret
  addi a0, a0, -1
  jal  x0, idram_timing_loop
idram_timing_loop_ret:
  ret

.globl idram_timing_loop_end
.type idram_timing_loop_end, @object
idram_timing_loop_end:
.word 0

.globl add_1_to_t0
.type add_1_to_t0, @object
add_1_to_t0:
  add t0, t0, 1
