#ifndef __ORCA_MALLOC_H
#define __ORCA_MALLOC_H

#include <stddef.h>

//Initialize the heap for malloc() with memory passed in (allocated by
//the caller using space on the stack or a global variable).
void init_malloc(void *new_heap, size_t new_heap_size, size_t new_min_alignment);

//A simple malloc() that does contiguous allocation until it reaches the
//end of the heap (then returns NULL).  It must be initialized with
//init_malloc() before using.  There is no corresponding free() call, but you
//can call init_malloc() again to free everything.
void *malloc(size_t bytes);

#endif //#ifndef __ORCA_MALLOC_H
