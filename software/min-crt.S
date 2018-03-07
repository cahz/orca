.section .text.init

.globl _start
_start:
  la gp, _gp
  la sp, _end_of_memory

  jal main

  //Store result in t3 and hit an ecall for 'test_done'
  mv t3, a0
  fence.i
  ecall
1:
  j 1b
