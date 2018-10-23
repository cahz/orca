do_tests:
  addi sp,sp,-4
  sw   ra,4(sp)
test_2: /*consecutive shifts*/
  li      a1,0xFFFF
  slli    a2,a1,16
  sra     a2,a2,16
  li      a3,-1
  li      a0,2
  bne     a2,a3,fail

test_3: /*consecutive loads*/
  la      a1, data_3_0
  la      t0, data_3_1
  lw      a2, 0(a1)
  lw      a4, 0(t0)
  li      a0,3
  li      a3,0xAAAAAAAA
  bne     a2,a3,fail
  li      a3,0xBBBBBBBB
  bne     a4,a3,fail

test_4: /*consecutive stores*/
  la      a1, data_4_0
  la      t0, data_4_1
  li      a2,0xAAAAAAAA
  li      a4,0xBBBBBBBB
  sw      a2, 0(a1)
  sw      a4, 0(t0)
  li      a0,4
  lw      a5, 0(a1)
  li      a3,0xAAAAAAAA
  bne     a5,a3,fail
  lw      a5, 0(t0)
  li      a3,0xBBBBBBBB
  bne     a5,a3,fail

test_5: /*csrr after load*/
  la      a1, data_5_0
  li      a2,0xAAAAAAAA
  li      a4,0x80
  /* first make sure csrw/r work as expected */
  csrw    mstatus,a4
  nop
  nop
  nop
  csrr    a7, mstatus
  lw      a5, 0(a1)
  csrr    a6, mstatus
  li      a0, 5
  bne     a7,a4,fail
  bne     a5,a2,fail
  bne     a6,a4,fail
pass:
  li      a0,1
fail:
  lw      ra,4(sp)
  addi    sp,sp,4
  ret

.global main
main:
  addi    sp,sp,-4
  sw      ra,4(sp)
  call    do_tests
  lw      ra,4(sp)
  addi    sp,sp,4
  mv      x3,a0
  fence.i
  ecall
  ret


.data
data_3_0:
  .word 0xAAAAAAAA
data_3_1:
  .word 0xBBBBBBBB

data_4_0:
  .word 0x0
data_4_1:
  .word 0x0
data_5_0:
  .word 0xAAAAAAAA
