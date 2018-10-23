#include "bsp.h"
#include "orca_malloc.h"
#include "orca_printf.h"

static void  *heap;
static size_t heap_base     = 0;
static size_t heap_size     = 0;
static size_t min_alignment = 0;
#define HEAP_START (((uintptr_t)heap)+heap_base)

//Initialize the heap for malloc() with memory passed in (allocated by
//the caller using space on the stack or a global variable).
void init_malloc(void *new_heap, size_t new_heap_size, size_t new_min_alignment){
  heap          = new_heap;
  heap_size     = new_heap_size;
  min_alignment = new_min_alignment;

  heap_base = (ORCA_PAD_UP(HEAP_START, min_alignment) - HEAP_START);
}

//A simple malloc() that does contiguous allocation until it reaches the
//end of the heap (then returns NULL).  It must be initialized with
//init_malloc() before using.  There is no corresponding free() call, but you
//can call init_malloc() again to free everything.
void *malloc(size_t bytes){
  if(heap_size == 0){
    printf("ERROR in %s; heap size is 0; please call init_malloc() with a pointer to memory to be used as heap.", __FILE__);
    return NULL;
  }
  
  if(heap_base + bytes > heap_size){
    printf("ERROR in %s: Heap overflow.  malloc() of %d bytes called with %d bytes already allocated (%d bytes total in heap)\r\n", __FILE__, (int)bytes, (int)heap_base, heap_size);
    return NULL;
  }
  void *return_ptr = (void *)HEAP_START;
  heap_base += bytes;
  heap_base += (ORCA_PAD_UP(HEAP_START, min_alignment) - HEAP_START);
  return return_ptr;
}  
