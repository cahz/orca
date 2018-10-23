#ifndef __ORCA_MEMORY_H
#define __ORCA_MEMORY_H

#include <stdbool.h>
#include <stdint.h>

//Check for instruction cache
bool orca_has_icache();

//Check for data cache
bool orca_has_dcache();

//Return an AMR or UMR bounds in in base/last_ptr
void get_xmr(bool umr_not_amr,
             uint8_t xmr_number,
             uint32_t *base_ptr,
             uint32_t *last_ptr);

//Disable an AMR or UMR
//
//Note that if this enables caches on part or all of memory it is the
//programmer's responsibility to have them in a consistent state with
//memory!  Invalidate the cache (or region of memory within the cache)
//being enabled without writing back before running this function if
//unsure.
void disable_xmr(bool umr_not_amr,
                 uint8_t xmr_number);

//Set an AMR or UMR and store the previous values in
//previous_base/last_ptr.
//
//Note that if this enables caches on part or all of memory it is the
//programmer's responsibility to have them in a consistent state with
//memory!  Invalidate the cache (or region of memory within the cache)
//being enabled without writing back before running this function if
//unsure.
void set_xmr(bool umr_not_amr,
             uint8_t xmr_number,
             uint32_t new_base,
             uint32_t new_last,
             uint32_t *previous_base_ptr,
             uint32_t *previous_last_ptr);

#endif //#ifndef __ORCA_MEMORY_H
