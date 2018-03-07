#include "orca_interrupts.h"
#include "orca_csrs.h"



//Disable interrupts and return the old MSTATUS value for a future
//restore_interrupts() call.
uint32_t disable_interrupts(){
  uint32_t bits_to_clear    = MSTATUS_MIE;
  uint32_t previous_mstatus = 0;
  asm volatile("csrrc %0, mstatus, %1" : "=r"(previous_mstatus) : "r"(bits_to_clear));
  return previous_mstatus;
}

//Enable interrupts and return the old MSTATUS value for a future
//restore_interrupts() call.
uint32_t enable_interrupts(){
  uint32_t bits_to_set    = MSTATUS_MIE;
  uint32_t previous_mstatus = 0;
  asm volatile("csrrs %0, mstatus, %1" : "=r"(previous_mstatus) : "r"(bits_to_set));
  return previous_mstatus;
}

//Restore interrupts based on a previous MSTATUS value.
void restore_interrupts(uint32_t previous_mstatus){
  if(previous_mstatus & MSTATUS_MIE){
    enable_interrupts();
  } else {
    disable_interrupts();
  }
}
