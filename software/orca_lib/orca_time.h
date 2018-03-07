#ifndef __ORCA_TIME_H
#define __ORCA_TIME_H

#include "bsp.h"
#include <stdint.h>

#ifndef ORCA_CLK
#error "ORCA_CLK must be defined (ORCA core clock in Hz) before including orca_time.h; it should be defined in bsp.h"
#endif //#ifndef ORCA_CLK

//Get time in cycles
static inline uint32_t get_time(){
  int tmp;
  asm volatile("csrr %0, time":"=r"(tmp));
  return tmp;
}

//Delay for a specific number of milliseconds.  Checks for overflow of
//32-bit counters so can handle > 2^32 cycle delays.
static inline void delayms(uint32_t ms){
  uint32_t start_time   = get_time();
  uint64_t delay_cycles = ((uint64_t)ms) * (ORCA_CLK/1000);
  while(delay_cycles){
    uint32_t delay = (uint32_t)delay_cycles;

    //Check for overflow
    const uint64_t max_delay_cycles = 0x00000000FFFFFFFF;
    if(delay_cycles > max_delay_cycles){
      delay = max_delay_cycles;
    }

    //Busy loop
    while((get_time() - start_time) < delay){
    }

    delay_cycles -= delay;
  }
}

//Delay for a specific number of microseconds.  Does not check for
//overflow; take care not to delay for more than 2^32 cycles.
static inline void delayus(uint32_t us) {
  uint32_t start_time = get_time();
  uint32_t delay      = us * (ORCA_CLK/1000000);
  while((get_time() - start_time) < delay){
  }
}

#endif //#ifndef __ORCA_TIME_H
