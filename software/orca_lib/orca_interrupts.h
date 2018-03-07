#ifndef __ORCA_INTERRUPTS_H
#define __ORCA_INTERRUPTS_H

#include <stdint.h>
#include "orca_csrs.h"

//Disable interrupts and return the old MSTATUS value for a future
//restore_interrupts() call.
uint32_t disable_interrupts();

//Enable interrupts and return the old MSTATUS value for a future
//restore_interrupts() call.
uint32_t enable_interrupts();

//Restore interrupts based on a previous MSTATUS value.
void restore_interrupts(uint32_t previous_mstatus);

//Get interrupt mask
static inline uint32_t get_interrupt_mask(){
  uint32_t meimask = 0;
  asm volatile("csrr %0, " CSR_STRING(CSR_MEIMASK) : "=r"(meimask));
  return meimask;
}

//Set interrupt mask bits
static inline void set_interrupt_mask_bits(uint32_t mask_bits_to_set){
  asm volatile("csrs " CSR_STRING(CSR_MEIMASK) ", %0" : : "r"(mask_bits_to_set));
}

//Clear interrupt mask bits
static inline void clear_interrupt_mask_bits(uint32_t mask_bits_to_clear){
  asm volatile("csrc " CSR_STRING(CSR_MEIMASK) ", %0" : : "r"(mask_bits_to_clear));
}

//Get pending interrupts
static inline uint32_t get_pending_interrupts(){
  uint32_t meipend = 0;
  asm volatile("csrr %0, " CSR_STRING(CSR_MEIPEND) : "=r"(meipend));
  return meipend;
}

#endif //#ifndef __ORCA_INTERRUPTS_H
