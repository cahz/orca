#ifndef CACHE_TEST_H
#define CACHE_TEST_H

int cache_test(void *mem_base, uint32_t mem_size, uint32_t cache_size, uint32_t cache_line_size);
void idram_timing_loop(uint32_t runs);
extern uint32_t idram_timing_loop_end;
extern uint32_t add_1_to_t0;

#endif
