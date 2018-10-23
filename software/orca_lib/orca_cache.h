#ifndef __ORCA_CACHE_H
#define __ORCA_CACHE_H

//Writeback data in D$ to memory.
//
//Clobbers a0, a1, a2
void orca_writeback_dcache_range(void *base_address, void *last_address);

//Flush (writeback to memory then invalidate) data in D$.
//
//Clobbers a0, a1, a2
void orca_flush_dcache_range(void *base_address, void *last_address);

//Invalidate data in D$.
//
//Clobbers a0, a1, a2
void orca_invalidate_dcache_range(void *base_address, void *last_address);

#endif //#ifndef __ORCA_CACHE_H
