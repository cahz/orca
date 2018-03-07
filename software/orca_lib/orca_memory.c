#include "orca_memory.h"
#include "orca_csrs.h"
#include "orca_interrupts.h"

//Check for instruction cache
bool orca_has_icache(){
  uint32_t mcache = 0;
  asm volatile("csrr %0, " CSR_STRING(CSR_MCACHE) : "=r"(mcache));
  if(mcache & MCACHE_IEXISTS){
    return true;
  }
  return false;
}

//Check for data cache
bool orca_has_dcache(){
  uint32_t mcache = 0;
  asm volatile("csrr %0, " CSR_STRING(CSR_MCACHE) : "=r"(mcache));
  if(mcache & MCACHE_DEXISTS){
    return true;
  }
  return false;
}

//Return an AMR or UMR bounds in in base/last_ptr
void get_xmr(bool umr_not_amr,
             uint8_t xmr_number,
             uint32_t *base_ptr,
             uint32_t *last_ptr){
  uint32_t csr_read_value = 0;

  //CSRR/W must have immediate CSR numbers; use a jump table to index
  if(umr_not_amr){
    switch(xmr_number){
    case 1:
      asm volatile("csrr %0, " CSR_STRING(CSR_MUMR1_BASE) : "=r"(csr_read_value));
      break;
    case 2:
      asm volatile("csrr %0, " CSR_STRING(CSR_MUMR2_BASE) : "=r"(csr_read_value));
      break;
    case 3:
      asm volatile("csrr %0, " CSR_STRING(CSR_MUMR3_BASE) : "=r"(csr_read_value));
      break;
    default:
      asm volatile("csrr %0, " CSR_STRING(CSR_MUMR0_BASE) : "=r"(csr_read_value));
      break;
    }
  } else {
    switch(xmr_number){
    case 1:
      asm volatile("csrr %0, " CSR_STRING(CSR_MAMR1_BASE) : "=r"(csr_read_value));
      break;
    case 2:
      asm volatile("csrr %0, " CSR_STRING(CSR_MAMR2_BASE) : "=r"(csr_read_value));
      break;
    case 3:
      asm volatile("csrr %0, " CSR_STRING(CSR_MAMR3_BASE) : "=r"(csr_read_value));
      break;
    default:
      asm volatile("csrr %0, " CSR_STRING(CSR_MAMR0_BASE) : "=r"(csr_read_value));
      break;
    }
  }
  *base_ptr = csr_read_value;

  //CSRR/W must have immediate CSR numbers; use a jump table to index
  if(umr_not_amr){
    switch(xmr_number){
    case 1:
      asm volatile("csrr %0, " CSR_STRING(CSR_MUMR1_LAST) : "=r"(csr_read_value));
      break;
    case 2:
      asm volatile("csrr %0, " CSR_STRING(CSR_MUMR2_LAST) : "=r"(csr_read_value));
      break;
    case 3:
      asm volatile("csrr %0, " CSR_STRING(CSR_MUMR3_LAST) : "=r"(csr_read_value));
      break;
    default:
      asm volatile("csrr %0, " CSR_STRING(CSR_MUMR0_LAST) : "=r"(csr_read_value));
      break;
    }
  } else {
    switch(xmr_number){
    case 1:
      asm volatile("csrr %0, " CSR_STRING(CSR_MAMR1_LAST) : "=r"(csr_read_value));
      break;
    case 2:
      asm volatile("csrr %0, " CSR_STRING(CSR_MAMR2_LAST) : "=r"(csr_read_value));
      break;
    case 3:
      asm volatile("csrr %0, " CSR_STRING(CSR_MAMR3_LAST) : "=r"(csr_read_value));
      break;
    default:
      asm volatile("csrr %0, " CSR_STRING(CSR_MAMR0_LAST) : "=r"(csr_read_value));
      break;
    }
  }
  *last_ptr = csr_read_value;
}

//Disable an AMR or UMR
//
//Note that if this enables caches on part or all of memory it is the
//programmer's responsibility to have them in a consistent state with
//memory!  Invalidate the cache (or region of memory within the cache)
//being enabled without writing back before running this function if
//unsure.
void disable_xmr(bool umr_not_amr,
                 uint8_t xmr_number){
  uint32_t new_base = 0xFFFFFFFF;
  uint32_t new_last = 0;

  //CSRR/W must have immediate CSR numbers; use a jump table to index
  if(umr_not_amr){
    switch(xmr_number){
    case 1:
      asm volatile("csrw " CSR_STRING(CSR_MUMR1_BASE)", %0\n"
                   "csrw " CSR_STRING(CSR_MUMR1_LAST)", %1\n"
                   :: "r"(new_base), "r"(new_last));
      break;
    case 2:
      asm volatile("csrw " CSR_STRING(CSR_MUMR2_BASE)", %0\n"
                   "csrw " CSR_STRING(CSR_MUMR2_LAST)", %1\n"
                   :: "r"(new_base), "r"(new_last));
      break;
    case 3:
      asm volatile("csrw " CSR_STRING(CSR_MUMR3_BASE)", %0\n"
                   "csrw " CSR_STRING(CSR_MUMR3_LAST)", %1\n"
                   :: "r"(new_base), "r"(new_last));
      break;
    default:
      asm volatile("csrw " CSR_STRING(CSR_MUMR0_BASE)", %0\n"
                   "csrw " CSR_STRING(CSR_MUMR0_LAST)", %1\n"
                   :: "r"(new_base), "r"(new_last));
      break;
    }
  } else {
    switch(xmr_number){
    case 1:
      asm volatile("csrw " CSR_STRING(CSR_MAMR1_BASE)", %0\n"
                   "csrw " CSR_STRING(CSR_MAMR1_LAST)", %1\n"
                   :: "r"(new_base), "r"(new_last));
      break;
    case 2:
      asm volatile("csrw " CSR_STRING(CSR_MAMR2_BASE)", %0\n"
                   "csrw " CSR_STRING(CSR_MAMR2_LAST)", %1\n"
                   :: "r"(new_base), "r"(new_last));
      break;
    case 3:
      asm volatile("csrw " CSR_STRING(CSR_MAMR3_BASE)", %0\n"
                   "csrw " CSR_STRING(CSR_MAMR3_LAST)", %1\n"
                   :: "r"(new_base), "r"(new_last));
      break;
    default:
      asm volatile("csrw " CSR_STRING(CSR_MAMR0_BASE)", %0\n"
                   "csrw " CSR_STRING(CSR_MAMR0_LAST)", %1\n"
                   :: "r"(new_base), "r"(new_last));
      break;
    }
  }
}

//Set an AMR or UMR and store the previous values in
//previous_base/last_ptr.
//
//Note that if this enables caches on part or all of memory it is the
//programmer's responsibility to have them in a consistent state with
//memory!  Invalidate the cache (or region of memory within the cache)
//being enabled without writing back before running this function if
//unsure.
//
//Note also that if this disables caches on part or all of memory the
//programmer must handle what happens should the cache be re-enabled.
//An IFENCE is used to make sure the data is written back to memory if
//there is a data cache and a chance of it being disabled, but the
//disabled cache is not invalidated; that is the responsibility of the
//programmer.
void set_xmr(bool umr_not_amr,
             uint8_t xmr_number,
             uint32_t new_base,
             uint32_t new_last,
             uint32_t *previous_base_ptr,
             uint32_t *previous_last_ptr){
  bool data_cache_may_be_disabled = false;
  
  //To safely set xMRn we need the following conditions:
  //  If the previous and new regions overlap we must not disable that region while setting the new values
  //    Else if IMEM or DMEM was using them there might be no path to memory
  //  If previous and new regions don't overlap we must not enable the region between them while setting values
  get_xmr(umr_not_amr, xmr_number, previous_base_ptr, previous_last_ptr);
  uint32_t previous_base = *previous_base_ptr;
  uint32_t previous_last = *previous_last_ptr;

  //If previously disabled or new values disable this xMR then set
  //values to the canonical disabed so that setting the new base/last
  //can happen in any order.  Also if the previous and new regions are
  //completely disjoint then disable before enabling.
  if((new_last < new_base) || (previous_last < previous_base) ||
     ((new_last < previous_base) || (previous_last < new_base))){
    disable_xmr(umr_not_amr, xmr_number);
  }

  //If D$ exists, we need to check if it may be disabled by this call.
  //
  //Note that this may not be the case if there are multiple AMRs/UMRs
  //active; it would be possible to check all of them but for now this
  //is conservative and correct.
  if(orca_has_dcache()){
    //D$ may be disabled if this xMR is being enabled and its new
    //region is not contained in the previous region
    if((new_last >= new_base) && ((new_last > previous_last) || (new_base < previous_base))){
      data_cache_may_be_disabled = true;
    }
  }

  //Finally set the values (previous work means they can be set in any order)
  if(data_cache_may_be_disabled){
    //If D$ may be disabled then the D$ must be flushed after the
    //region is modified.  To do so: disable interrupts, set the
    //region, run an IFENCE to flush the D$, then re-enable
    //interrupts.  Interrupts must be disabled so that no memory
    //accesses happen between the last CSR write and the IFENCE.
    uint32_t previous_mstatus = 0;
    disable_interrupts(previous_mstatus);

    //CSRR/W must have immediate CSR numbers; use a jump table to index
    if(umr_not_amr){
      switch(xmr_number){
      case 1:
        asm volatile("csrw " CSR_STRING(CSR_MUMR1_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MUMR1_LAST)", %1\n"
                     "fence.i\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      case 2:
        asm volatile("csrw " CSR_STRING(CSR_MUMR2_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MUMR2_LAST)", %1\n"
                     "fence.i\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      case 3:
        asm volatile("csrw " CSR_STRING(CSR_MUMR3_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MUMR3_LAST)", %1\n"
                     "fence.i\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      default:
        asm volatile("csrw " CSR_STRING(CSR_MUMR0_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MUMR0_LAST)", %1\n"
                     "fence.i\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      }
    } else {
      switch(xmr_number){
      case 1:
        asm volatile("csrw " CSR_STRING(CSR_MAMR1_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MAMR1_LAST)", %1\n"
                     "fence.i\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      case 2:
        asm volatile("csrw " CSR_STRING(CSR_MAMR2_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MAMR2_LAST)", %1\n"
                     "fence.i\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      case 3:
        asm volatile("csrw " CSR_STRING(CSR_MAMR3_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MAMR3_LAST)", %1\n"
                     "fence.i\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      default:
        asm volatile("csrw " CSR_STRING(CSR_MAMR0_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MAMR0_LAST)", %1\n"
                     "fence.i\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      }
    }
    restore_interrupts(previous_mstatus);

  } else {
    //If not disabling the D$ then it's safe to just set the memory region.

    //CSRR/W must have immediate CSR numbers; use a jump table to index
    if(umr_not_amr){
      switch(xmr_number){
      case 1:
        asm volatile("csrw " CSR_STRING(CSR_MUMR1_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MUMR1_LAST)", %1\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      case 2:
        asm volatile("csrw " CSR_STRING(CSR_MUMR2_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MUMR2_LAST)", %1\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      case 3:
        asm volatile("csrw " CSR_STRING(CSR_MUMR3_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MUMR3_LAST)", %1\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      default:
        asm volatile("csrw " CSR_STRING(CSR_MUMR0_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MUMR0_LAST)", %1\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      }
    } else {
      switch(xmr_number){
      case 1:
        asm volatile("csrw " CSR_STRING(CSR_MAMR1_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MAMR1_LAST)", %1\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      case 2:
        asm volatile("csrw " CSR_STRING(CSR_MAMR2_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MAMR2_LAST)", %1\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      case 3:
        asm volatile("csrw " CSR_STRING(CSR_MAMR3_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MAMR3_LAST)", %1\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      default:
        asm volatile("csrw " CSR_STRING(CSR_MAMR0_BASE)", %0\n"
                     "csrw " CSR_STRING(CSR_MAMR0_LAST)", %1\n"
                     :: "r"(new_base), "r"(new_last));
        break;
      }
    }
  }
}
