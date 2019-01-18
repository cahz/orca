#include "orca_printf.h"
#include "orca_csrs.h"
#include "orca_memory.h"
#include "orca_cache.h"
#include "orca_malloc.h"
#include "orca_time.h"
#include "cache_test.h"
#include "bsp.h"

//Assembler macro to create a jump instruction
#define J_FORWARD_BY(BYTES)                     \
  ((((BYTES) << 11) & 0x80000000) |             \
   (((BYTES) << 20) & 0x7FE00000) |             \
   (((BYTES) << 9)  & 0x00100000) |             \
   (((BYTES) << 0)  & 0x000FF000) |             \
   0x6F);

#define WAIT_SECONDS_BEFORE_START 0

#define MAX_PRINT_ERRORS 5

#ifdef ORCA_DUC_READY_DELAYER_DC_BASE_ADDR
#define USE_DELAYER_DC      0
#define DELAYER_DC_RANDOM   1
#define DELAYER_DC_MASK     0x0113
#define DELAYER_DC_CHANNELS 0x1F
#else //#ifdef ORCA_DUC_READY_DELAYER_DC_BASE_ADDR
#define USE_DELAYER_DC 0
#endif //#else //#ifdef ORCA_DUC_READY_DELAYER_DC_BASE_ADDR

#define HEAP_ADDRESS 0x00100000

#define RUN_ASM_TEST              1
#define RUN_FENCE_I_TEST          1
#define RUN_FENCE_RI_TEST         1
#define RUN_RW_TEST               1
#define RUN_LINE_FLUSH_TEST       1
#define RUN_RANDOM_TEST           1
#define RUN_RANDOM_WRITEBACK_TEST 1
#define RUN_RANDOM_FLUSH_TEST     1
#define RUN_WRITEBACK_TEST        1
#define RUN_FLUSH_WRITE_TEST      1
#define RUN_FLUSH_READ_TEST       1
#define RUN_INVALIDATE_TEST       1
#define RUN_3_INSTRUCTION_LOOP    1
#define RUN_6_INSTRUCTION_LOOP    1
#define RUN_BTB_MISSES            1
#define RUN_CACHE_MISSES          1
#define RUN_CACHE_AND_BTB_MISSES  1

#define LOOP_RUNS 1000

#define CACHE_SIZE      8192
#define CACHE_LINE_SIZE 32
#define BTB_SIZE        64

typedef enum {INVALIDATE = 3, FLUSH = 2, WRITEBACK = 1, NOTHING = 0} cache_control_enum;

//Heap in PS memory.  Don't start at 0 to avoid NULL pointer checks.
#define HEAP_ADDRESS 0x00100000
#define HEAP_SIZE    0x00100000

#define TEST_C_STACK   1
#define TEST_C_HEAP    1
#define TEST_UC_STACK  1
#define TEST_UC_HEAP   1
#define TEST_AUX_STACK 1
#define TEST_AUX_HEAP  0

//Some peripherals are only mapped to UC; when fiddling with xMRs make
//sure that UC peripherals (like UART) are still accesible
#define UC_MIN_MEMORY_BASE 0xC0000000

typedef void (*timing_loop)(uint32_t);

#define RANDOM_TEST_RUNS CACHE_SIZE*16
#define GOLDEN_RANDOM    0x1BFE065F //Only valid for specific zedboard parameters

//BSD-ish checksum, should be good enough for random memory
uint32_t checksum(void *mem_base, uint32_t mem_size){
  uint32_t checksum = 0;
  for(uint32_t word = 0; word < mem_size/sizeof(uint32_t); word++){
    checksum = ((checksum >> 1) | checksum << 31) + ((uint32_t *)mem_base)[word];
  }
  return checksum;
}

uint32_t lfsr32(uint32_t input){
  //taps = {31, 29, 25, 24};
  uint32_t mask   = (input & 0x1) * 0xA3000000;
  uint32_t output = (input >> 1) ^ mask;
  return output;
}

uint32_t rand_seed = 0;
void srand(uint32_t seed){
  rand_seed = seed;
}
uint32_t rand(){
  for(int time = 0; time < 32; time++){
    rand_seed = lfsr32(rand_seed);
  }
  return rand_seed;
}

//Make sure FENCE.I works (FENCE.RI if fence_ri argument is true)
uint32_t fence_i_test(void *mem_base, uint32_t mem_size, bool fence_ri){
  uint32_t errors = 0;

  for(int n = 0; n < 3; n++){
    uint32_t add_n_to_t0 = add_1_to_t0 + (0x00100000 * (n - 1));
    int t0 = 2 * n;
    int t0_plus_n = 123456789;
    if(fence_ri){
      asm volatile (
                    "mv t0, %1\n"
                    "auipc t2, 0\n"
                    "addi t2, t2, 20\n"
                    "addi t3, t2, 3\n"
                    "sw %2, 0(t2)\n"
                    ".word 0x07C3900F\n"
                    "li t0, 0xAB\n"
                    "mv %0, t0\n"
                    : "=r"(t0_plus_n)
                    : "r"(t0), "r"(add_n_to_t0)
                    : "t0", "t2", "t3", "memory"
                    );
    } else {
      asm volatile (
                    "mv t0, %1\n"
                    "auipc t1, 0\n"
                    "sw %2, 12(t1)\n"
                    "fence.i\n"
                    "li t0, 0xAB\n"
                    "mv %0, t0\n"
                    : "=r"(t0_plus_n)
                    : "r"(t0), "r"(add_n_to_t0)
                    : "t0", "t1", "memory"
                    );
    }
    if(t0_plus_n != (3 * n)){
      printf("Error in fence.%s test (run %d), expected %d got %d\r\n", fence_ri ? "ri" : "i", n, 3*n, t0);
      errors++;
    }
  }

  return errors;
}

//Write to a cached region, writeback/flush (based on flush
//parameter), then change to uncached and read it back.
uint32_t cached_write_uncached_read_test(void *mem_base, uint32_t mem_size, uint32_t cache_size, uint32_t cache_line_size, bool flush, uint32_t start_word, uint32_t end_word){
  uint32_t errors = 0;
  uint32_t *mem_base32 = (uint32_t *)mem_base;

  uint32_t umr1_addr_base = (uint32_t)mem_base;
  uint32_t umr1_addr_last = ((uint32_t)mem_base)+mem_size;

  uint32_t base_to_writeback = ((uint32_t)mem_base) + (start_word*sizeof(uint32_t));
  uint32_t last_to_writeback = ((uint32_t)mem_base) + (end_word*sizeof(uint32_t)) - 1;

  //Write initial pattern to test memory then flush it to start
  for(int word = 0; word < (mem_size/sizeof(uint32_t)); word++){
    mem_base32[word] = 0-word;
  }
  orca_flush_dcache_range((void *)0x0, (void *)0xFFFFFFFF);

  //Put in test pattern
  for(int word = start_word; word < end_word; word++){
    mem_base32[word] = word;
  }

  uint32_t start_cycle = get_time();
  //Change the UC interface to be everything then flush/writeback.
  //Don't use the set_xmr function call as it does its own cache
  //management.
  if(flush){
    asm volatile("csrw " CSR_STRING(CSR_MUMR1_BASE)", %0\n"
                 "csrw " CSR_STRING(CSR_MUMR1_LAST)", %1\n"
                 "mv a0, %2\n"
                 "mv a1, %3\n"
                 "call orca_flush_dcache_range\n"
                 :: "r"(umr1_addr_base), "r"(umr1_addr_last), "r"(base_to_writeback), "r"(last_to_writeback) : "a0", "a1");
  } else {
    asm volatile("csrw " CSR_STRING(CSR_MUMR1_BASE)", %0\n"
                 "csrw " CSR_STRING(CSR_MUMR1_LAST)", %1\n"
                 "mv a0, %2\n"
                 "mv a1, %3\n"
                 "call orca_writeback_dcache_range\n"
                 :: "r"(umr1_addr_base), "r"(umr1_addr_last), "r"(base_to_writeback), "r"(last_to_writeback) : "a0", "a1");
  }
  uint32_t end_cycle = get_time();

  //Check test pattern
  for(int word = 0; word < (cache_size/sizeof(uint32_t)); word++){
    uint32_t expected_word = ((word < start_word) || (word >= end_word)) ? (0-word) : word;
    if(mem_base32[word] != expected_word){
      if(errors < MAX_PRINT_ERRORS){
        printf("Error at word %d expected 0x%08X got 0x%08X\r\n", word, (int)expected_word, (unsigned int)(mem_base32[word]));
      }
      errors++;
      if(errors == MAX_PRINT_ERRORS){
        printf("Errors reached MAX_PRINT_ERRORS; going silent\r\n");
      }
    }
  }

  //Disable UMR1
  disable_xmr(true, 1);

  printf("%s of %d bytes took %d cycles\r\n", flush ? "Flush" : "Writeback", (int)((end_word-start_word)*sizeof(uint32_t)), (int)(end_cycle-start_cycle));
  
  return errors;
}

//Pull a region into cached, flush/invalidate it (based on invalidate
//parameter), switch to uncached, write to the region, then switch to
//cached and read it back.
uint32_t uncached_write_cached_read_test(void *mem_base, uint32_t mem_size, uint32_t cache_size, uint32_t cache_line_size, bool invalidate, uint32_t start_word, uint32_t end_word){
  uint32_t errors = 0;
  uint32_t *mem_base32 = (uint32_t *)mem_base;

  uint32_t umr1_addr_base = (uint32_t)mem_base;
  uint32_t umr1_addr_last = ((uint32_t)mem_base)+mem_size;

  uint32_t base_to_flush = ((uint32_t)mem_base) + (start_word*sizeof(uint32_t));
  uint32_t last_to_flush = ((uint32_t)mem_base) + (end_word*sizeof(uint32_t)) - 1;

  //Zero out all of test memory then flush it to start
  for(int word = 0; word < (mem_size/sizeof(uint32_t)); word++){
    mem_base32[word] = 0;
  }
  orca_flush_dcache_range((void *)base_to_flush, (void *)last_to_flush);

  //Write initial test pattern
  for(int word = 0; word < (cache_size/sizeof(uint32_t)); word++){
    mem_base32[word] = 0-word;
  }

  uint32_t start_cycle = get_time();
  //Flush/invalidate and overwrite the range to test
  if(invalidate){
    orca_invalidate_dcache_range((void *)base_to_flush, (void *)last_to_flush);
  } else {
    orca_flush_dcache_range((void *)base_to_flush, (void *)last_to_flush);
  }
  uint32_t end_cycle = get_time();

  //Change to uncached.  Don't use set_xmr as it has its own cache flushing instructions
  asm volatile("csrw " CSR_STRING(CSR_MUMR1_BASE)", %0\n"
               "csrw " CSR_STRING(CSR_MUMR1_LAST)", %1\n"
               :: "r"(umr1_addr_base), "r"(umr1_addr_last));
  
  //Put in new test pattern where flushed/invalidated
  for(int word = start_word; word < end_word; word++){
    mem_base32[word] = word;
  }
  
  //Disable UMR1
  disable_xmr(true, 1);

  //Check test pattern
  for(int word = 0; word < (cache_size/sizeof(uint32_t)); word++){
    const uint32_t expected_word = (word >= start_word && word < end_word) ? word : 0-word;
    if(mem_base32[word] != expected_word){
      if(errors < MAX_PRINT_ERRORS){
        printf("Error at word %d expected 0x%08X got 0x%08X\r\n", word, (unsigned int)expected_word, (unsigned int)(mem_base32[word]));
      }
      errors++;
      if(errors == MAX_PRINT_ERRORS){
        printf("Errors reached MAX_PRINT_ERRORS; going silent\r\n");
      }
    }
  }

  printf("%s of %d bytes took %d cycles\r\n", invalidate ? "Invalidate" : "Flush", (int)((end_word-start_word)*sizeof(uint32_t)), (int)(end_cycle-start_cycle));
  
  return errors;
}


//Simple test writing aliased lines and then flushing them
uint32_t line_flush_test(void *mem_base, uint32_t mem_size){
  uint8_t *mem_base8 = (uint8_t *)mem_base;
  mem_base8[0] = 0xAB;
  mem_base8[CACHE_SIZE] = 0xCD;
  orca_flush_dcache_range(mem_base, mem_base+CACHE_SIZE);
  uint32_t errors = 0;
  if(mem_base8[0] != 0xAB){
    errors++;
    printf("Error in line_flush_test; expected 0xAB got 0x%02X\r\n", mem_base8[0]);
  }
  if(mem_base8[CACHE_SIZE] != 0xCD){
    errors++;
    printf("Error in line_flush_test; expected 0xCD got 0x%02X\r\n", mem_base8[CACHE_SIZE]);
  }
  return errors;
}

uint32_t random_test(void *mem_base, uint32_t mem_size, cache_control_enum control){
  srand(1);
  uint32_t *mem_base32 = (uint32_t *)mem_base;
  uint8_t *mem_base8   = (uint8_t *)mem_base;
  for(int word = 0; word < (mem_size/sizeof(uint32_t)); word++){
    mem_base32[word] = rand();
  }
  printf("Random test inital checksum 0x%08X\r\n", (int)(checksum(mem_base, mem_size)));
  uint32_t start_cycle = get_time();
  for(int run = 0; run < RANDOM_TEST_RUNS; run++){
    mem_base8[rand() % mem_size] += mem_base8[rand() % mem_size];
  }
  switch(control){
  case WRITEBACK:
    orca_writeback_dcache_range(mem_base, mem_base+mem_size);
    break;
  case FLUSH:
    orca_flush_dcache_range(mem_base, mem_base+mem_size);
    break;
  case NOTHING:
    break;
  default:
    printf("Unsupported cache control function in line_flush_test\n");
    return 0xFFFFFFFF;
  }
  uint32_t end_cycle = get_time();
  printf("Random test %sfinished after %d cycles\r\n", (control == WRITEBACK) ? "with writeback " : ((control == FLUSH) ? "with flush " : ""), (int)(end_cycle-start_cycle));
  return checksum(mem_base, mem_size);
}

uint32_t rw_test(void *mem_base, uint32_t mem_size, uint32_t cache_size, uint32_t cache_line_size){
  int *test_space32 = (int *)mem_base;

  //Test back-to-back reads and writes that hit in the same line
  for(int run = 0; run < 10; run++){
    test_space32[0] = 1;
    test_space32[1] = 2;
    test_space32[2] = 3;
    test_space32[3] = 4;
    
    int r1 = 5;
    int r2 = 6;
    int r3 = 7;
    int r4 = 8;
    asm volatile
      ("lw %0, 0(%4)\n"
       "sw %2, 4(%4)\n"
       "lw %1, 8(%4)\n"
       "sw %3, 12(%4)\n"
       : "=r"(r1), "=r"(r3) : "r"(r2), "r"(r4), "r"(test_space32) : "memory" );
    if(test_space32[0] != 1){
      printf("Run %d same line error with test_space32[0]; expected %d got %d\r\n", run, 1, test_space32[0]);
      return 1;
    }
    if(test_space32[1] != 6){
      printf("Run %d same line error with test_space32[1]; expected %d got %d\r\n", run, 6, test_space32[1]);
      return 2;
    }
    if(test_space32[2] != 3){
      printf("Run %d same line error with test_space32[2]; expected %d got %d\r\n", run, 3, test_space32[2]);
      return 3;
    }
    if(test_space32[3] != 8){
      printf("Run %d same line error with test_space32[3]; expected %d got %d\r\n", run, 8, test_space32[3]);
      return 4;
    }
    if(r1 != 1){
      printf("Run %d same line error with r1; expected %d got %d\r\n", run, 1, r1);
      return 5;
    }
    if(r2 != 6){
      printf("Run %d same line error with r2; expected %d got %d\r\n", run, 6, r2);
      return 6;
    }
    if(r3 != 3){
      printf("Run %d same line error with r3; expected %d got %d\r\n", run, 3, r3);
      return 7;
    }
    if(r4 != 8){
      printf("Run %d same line error with r4; expected %d got %d\r\n", run, 8, r4);
      return 8;
    }
  }

  //Test back-to-back write/read in different lines
  for(int run = 0; run < 10; run++){
    test_space32[0]  = 1;
    test_space32[17] = 2;
    test_space32[34] = 3;
    test_space32[51] = 4;
    
    int r1 = 5;
    int r2 = 6;
    int r3 = 7;
    int r4 = 8;
    asm volatile
      ("lw %0, 0(%4)\n"
       "sw %2, 68(%4)\n"
       "lw %1, 136(%4)\n"
       "sw %3, 204(%4)\n"
       : "=r"(r1), "=r"(r3) : "r"(r2), "r"(r4), "r"(test_space32) : "memory" );
    if(test_space32[0] != 1){
      printf("Run %d different line error with test_space32[0]; expected %d got %d\r\n", run, 1, test_space32[0]);
      return 1;
    }
    if(test_space32[1] != 6){
      printf("Run %d different line error with test_space32[1]; expected %d got %d\r\n", run, 6, test_space32[1]);
      return 2;
    }
    if(test_space32[2] != 3){
      printf("Run %d different line error with test_space32[2]; expected %d got %d\r\n", run, 3, test_space32[2]);
      return 3;
    }
    if(test_space32[3] != 8){
      printf("Run %d different line error with test_space32[3]; expected %d got %d\r\n", run, 8, test_space32[3]);
      return 4;
    }
    if(r1 != 1){
      printf("Run %d different line error with r1; expected %d got %d\r\n", run, 1, r1);
      return 5;
    }
    if(r2 != 6){
      printf("Run %d different line error with r2; expected %d got %d\r\n", run, 6, r2);
      return 6;
    }
    if(r3 != 3){
      printf("Run %d different line error with r3; expected %d got %d\r\n", run, 3, r3);
      return 7;
    }
    if(r4 != 8){
      printf("Run %d different line error with r4; expected %d got %d\r\n", run, 8, r4);
      return 8;
    }
  }
  
  //Regression for bug found in cache write misses
  for(int run = 0; run < 10; run++){
    test_space32[0]                      = 0x11111111;
    test_space32[cache_size/sizeof(int)] = 0x22222222;
    int return_value = 0;
    asm volatile
      ("mv   t0, %1    \n"
       "mv   t1, %2    \n"
       "lw   t0, 0(t0) \n"
       "sw   t1, 0(t1) \n"
       "lw   %0, 0(%1) \n"
       : "=r"(return_value) : "r"(test_space32), "r"(test_space32+(cache_size/sizeof(int))) : "t0", "t1", "memory" );
    if(return_value != 0x11111111){
      printf("Run %d regression 1 error with return value; expected %d got %d\r\n", run, 0x11111111, return_value);
      return 1;
    }
    if(test_space32[0] != 0x11111111){
      printf("Run %d regression 1 error with test_space32[0]; expected %d got %d\r\n", run, 0x22222222, test_space32[0]);
      return 2;
    }
    if(test_space32[cache_size/sizeof(int)] != ((int)(test_space32+(cache_size/sizeof(int))))){
      printf("Run %d regression 1 error with test_space32[cache_size/sizeof(int)]; expected %d got %d\r\n", run, ((int)(test_space32+(cache_size/sizeof(int)))), test_space32[cache_size/sizeof(int)]);
      return 3;
    }
  }
  
  return 0;
}

//Creates a 6 instruction timing loop (2 jumps) for testing timing
uint32_t timing_test(uint32_t *first_loop_ptr,
                     uint32_t jump_size_bytes){
      uint32_t *function_copy_ptr = (uint32_t *)(&idram_timing_loop);
      uint32_t *function_copy_end = &idram_timing_loop_end;
      uint32_t timing_loop_size   = (uint32_t)(function_copy_end-function_copy_ptr);

      int word;
      for(word = 0; word < timing_loop_size; word++){
        first_loop_ptr[word] = function_copy_ptr[word];
      }
      bool error_found = false;
      for(word = 0; word < timing_loop_size; word++){
        if(first_loop_ptr[word] != function_copy_ptr[word]){
          printf("Error copying function at word 0x%08X expected 0x%08X got 0x%08X\r\n", word, (unsigned)(function_copy_ptr[word]), (unsigned)(first_loop_ptr[word]));
          error_found = true;
        }
      }
      if(error_found){
        return 0;
      }
      //Overwrite the jump back to the beginning of the loop to a jump
      //forward to the next loop.
      first_loop_ptr[2] = J_FORWARD_BY(jump_size_bytes-(2*sizeof(uint32_t)));

      uint32_t *second_loop_ptr = (uint32_t *)(((uintptr_t)first_loop_ptr)+jump_size_bytes);
      for(word = 0; word < timing_loop_size; word++){
        second_loop_ptr[word] = function_copy_ptr[word];
      }
      //Overwrite the jump back to the beginning of the loop to a jump
      //backward to the previous loop.  The function will ping-pong
      //back and forth between these two loops.
      second_loop_ptr[2] = J_FORWARD_BY(0-(jump_size_bytes+(2*sizeof(uint32_t))));

      //IFENCE to make sure instruction cache gets the correct values
      asm volatile("fence.i");
    
      timing_loop the_timing_loop = (timing_loop)(first_loop_ptr);
  
      uint32_t start_cycle = get_time();
      (*the_timing_loop)(LOOP_RUNS);
      uint32_t end_cycle = get_time();

      return end_cycle-start_cycle;
}

int main(void){
  if(WAIT_SECONDS_BEFORE_START){
    for(int i = 0; i < WAIT_SECONDS_BEFORE_START; i++){
      printf("%d... ", i);
      delayms(1000);
    }
  }

  printf("\r\n\r\n\r\n");

#if USE_DELAYER_DC
  {
    printf("Setting up DC delayer to %s delay mask 0x%04X channels 0x%02X\r\n\r\n", DELAYER_DC_RANDOM ? "random" : "fixed", DELAYER_DC_MASK, DELAYER_DC_CHANNELS);
    volatile uint32_t *delayer_dc = (volatile uint32_t *)ORCA_DUC_READY_DELAYER_DC_BASE_ADDR;
    for(int channel = 0; channel < 8; channel++){
      if((1 << channel) & DELAYER_DC_CHANNELS){
        delayer_dc[channel] = (DELAYER_DC_RANDOM ? 0x80000000 : 0x00000000) | DELAYER_DC_MASK;
      }
    }
  }
#endif
  

  uint8_t test_space_stack[3*CACHE_SIZE];  //After alignment will have > 2*CACHE_SIZE to work in
  init_malloc((void *)HEAP_ADDRESS, HEAP_SIZE, CACHE_SIZE);
  uint8_t *test_space_heap = (uint8_t *)malloc(2*CACHE_SIZE);
  

  uint32_t previous_amr0_addr_base = 0;
  uint32_t previous_amr0_addr_last = 0;
  uint32_t previous_umr0_addr_base = 0;
  uint32_t previous_umr0_addr_last = 0;

  int errors = 0;
  bool test_cached_and_uncached = false;

  int type = 0;
  for(type = 0; type < 6; type++){
    test_cached_and_uncached = false;
    switch(type){
    case 0:
      if(!TEST_C_STACK){
        continue;
      }
      if(TEST_UC_STACK){
        test_cached_and_uncached = true;
      }
    case 1:
      if(type == 1){
        if(!TEST_C_HEAP){
          continue;
        }
        if(TEST_UC_HEAP){
          test_cached_and_uncached = true;
        }
      }
      printf("\r\n----------------------------------------\r\n-- CACHED\r\n");
      //Disable the AUX interface
      disable_xmr(false, 0);
      //Change the UC interface to be only the peripherals
      set_xmr(true, 0, UC_MIN_MEMORY_BASE, 0xFFFFFFFF, &previous_umr0_addr_base, &previous_umr0_addr_last);
      break;
    case 2:
      if(!TEST_UC_STACK){
        continue;
      }
    case 3:
      if((type == 3) && (!TEST_UC_HEAP)){
        continue;
      }
      printf("\r\n----------------------------------------\r\n-- UNCACHED\r\n");
      //Change the UC interface to be everything (besides the AMRs which take priority)
      set_xmr(true, 0, 0x00000000, 0xFFFFFFFF, &previous_umr0_addr_base, &previous_umr0_addr_last);
      //Disable the AUX interface
      disable_xmr(false, 0);
      break;
    case 4:
      if(!TEST_AUX_STACK){
        continue;
      }
    case 5:
      if((type == 5) && (!TEST_AUX_HEAP)){
        continue;
      }
      printf("\r\n----------------------------------------\r\n-- AUX\r\n");
      //Set the AUX memory interface to the non-UC addresses
      set_xmr(false, 0, 0x00000000, UC_MIN_MEMORY_BASE-1, &previous_amr0_addr_base, &previous_amr0_addr_last);
      //Change the UC interface to be only the peripherals
      set_xmr(true, 0, UC_MIN_MEMORY_BASE, 0xFFFFFFFF, &previous_umr0_addr_base, &previous_umr0_addr_last);
      break;
    default:
      printf("\r\nError in type\r\n");
      continue;
      break;
    }

    uint8_t *test_space_aligned = NULL;
    if(type & 0x01){
      test_space_aligned = test_space_heap;
      printf("-- HEAP\r\n");
    } else {
      test_space_aligned = (uint8_t *)((((uintptr_t)test_space_stack) + (CACHE_SIZE-1)) & (~(CACHE_SIZE-1)));
      printf("-- STACK\r\n");
    }
    printf("----------------------------------------\r\n");
    
    
    
#if RUN_ASM_TEST
    {
      printf("-- ASM test:\r\n");

      int result = cache_test((void *)test_space_aligned, 2*CACHE_SIZE, CACHE_SIZE, CACHE_LINE_SIZE);
      if(result){
        printf("ASM test failed with error code 0x%08X\r\n", result);
        errors++;
      } else {
        printf("ASM test passed\r\n");
      }
    }
#endif //#if RUN_ASM_TEST
  
#if RUN_FENCE_I_TEST
    {
      printf("-- FENCE_I test:\r\n");

      int result = fence_i_test((void *)test_space_aligned, 2*CACHE_SIZE, false);
      if(result){
        printf("FENCE_I test failed with error code 0x%08X\r\n", result);
        errors++;
      } else {
        printf("FENCE_I test passed\r\n");
      }
    }
#endif //#if RUN_FENCE_I_TEST
  
#if RUN_FENCE_RI_TEST
    {
      printf("-- FENCE_RI test:\r\n");

      int result = fence_i_test((void *)test_space_aligned, 2*CACHE_SIZE, true);
      if(result){
        printf("FENCE_RI test failed with error code 0x%08X\r\n", result);
        errors++;
      } else {
        printf("FENCE_RI test passed\r\n");
      }
    }
#endif //#if RUN_FENCE_I_TEST
  
#if RUN_RW_TEST
    {
      printf("-- RW test:\r\n");

      int result = rw_test((void *)test_space_aligned, 2*CACHE_SIZE, CACHE_SIZE, CACHE_LINE_SIZE);
      if(result){
        printf("RW test failed with error code 0x%08X\r\n", result);
        errors++;
      } else {
        printf("RW test passed\r\n");
      }
    }
#endif //#if RUN_ASM_TEST

#if RUN_LINE_FLUSH_TEST
    {
      printf("-- Line flush test: \r\n");

      uint32_t line_flush_errors = line_flush_test((void *)test_space_aligned, 2*CACHE_SIZE);
      if(line_flush_errors){
        printf("Line flush test failed with %d errors\r\n", (int)line_flush_errors);
      } else {
        printf("Line flush test passed\r\n");
      }
      errors += line_flush_errors;
    }
#endif //#if RUN_LINE_FLUSH_TEST
  
#if RUN_RANDOM_TEST
    {
      printf("-- RANDOM test:\r\n");

      int result = random_test((void *)test_space_aligned, 2*CACHE_SIZE, NOTHING);
      if(result != GOLDEN_RANDOM){
        printf("RANDOM test failed; returned checksum 0x%08X expected 0x%08X\r\n", result, GOLDEN_RANDOM);
        errors++;
      } else {
        printf("RANDOM test passed\r\n");
      }
    }
#endif //#if RUN_RANDOM_TEST
  
#if RUN_RANDOM_WRITEBACK_TEST
    {
      printf("-- RANDOM test with WRITEBACK: ");

      int result = random_test((void *)test_space_aligned, 2*CACHE_SIZE, WRITEBACK);
      if(result != GOLDEN_RANDOM){
        printf("RANDOM test failed; returned checksum 0x%08X expected 0x%08X\r\n", result, GOLDEN_RANDOM);
        errors++;
      } else {
        printf("RANDOM test passed\r\n");
      }
    }
#endif //#if RUN_RANDOM_WRITEBACK_TEST
  
#if RUN_RANDOM_FLUSH_TEST
    {
      printf("-- RANDOM test with FLUSH: ");

      int result = random_test((void *)test_space_aligned, 2*CACHE_SIZE, FLUSH);
      if(result != GOLDEN_RANDOM){
        printf("RANDOM test failed; returned checksum 0x%08X expected 0x%08X\r\n", result, GOLDEN_RANDOM);
        errors++;
      } else {
        printf("RANDOM test passed\r\n");
      }
    }
#endif //#if RUN_RANDOM_FLUSH_TEST
  
#if RUN_WRITEBACK_TEST
    if(test_cached_and_uncached){
      printf("-- WRITEBACK test:\r\n");

      int result = cached_write_uncached_read_test((void *)test_space_aligned, 2*CACHE_SIZE, CACHE_SIZE, CACHE_LINE_SIZE, false, 2, (CACHE_SIZE/sizeof(uint32_t))-2);
      if(result){
        printf("WRITEBACK large cached_write_uncached_read_test failed with error code 0x%08X\r\n", result);
        errors++;
      } else {
        printf("WRITEBACK large cached_write_uncached_read_test passed\r\n");
      }

      result = cached_write_uncached_read_test((void *)test_space_aligned, 2*CACHE_SIZE, CACHE_SIZE, CACHE_LINE_SIZE, false, ((CACHE_SIZE/2)/sizeof(uint32_t))-2, ((CACHE_SIZE/2)/sizeof(uint32_t))+2);
      if(result){
        printf("WRITEBACK small cached_write_uncached_read_test failed with error code 0x%08X\r\n", result);
        errors++;
      } else {
        printf("WRITEBACK small cached_write_uncached_read_test passed\r\n");
      }
    }
#endif //#if RUN_WRITEBACK_TEST

#if RUN_FLUSH_WRITE_TEST
    if(test_cached_and_uncached){
      printf("-- FLUSH_WRITE test:\r\n");

      int result = cached_write_uncached_read_test((void *)test_space_aligned, 2*CACHE_SIZE, CACHE_SIZE, CACHE_LINE_SIZE, true, 2, (CACHE_SIZE/sizeof(uint32_t))-2);
      if(result){
        printf("FLUSH_WRITE large cached_write_uncached_read_test failed with error code 0x%08X\r\n", result);
        errors++;
      } else {
        printf("FLUSH_WRITE large cached_write_uncached_read_test passed\r\n");
      }

      result = cached_write_uncached_read_test((void *)test_space_aligned, 2*CACHE_SIZE, CACHE_SIZE, CACHE_LINE_SIZE, true, ((CACHE_SIZE/2)/sizeof(uint32_t))-2, ((CACHE_SIZE/2)/sizeof(uint32_t))+2);
      if(result){
        printf("FLUSH_WRITE small cached_write_uncached_read_test failed with error code 0x%08X\r\n", result);
        errors++;
      } else {
        printf("FLUSH_WRITE small cached_write_uncached_read_test passed\r\n");
      }
    }
#endif //#if RUN_FLUSH_WRITE_TEST

#if RUN_FLUSH_READ_TEST
    if(test_cached_and_uncached){
      printf("-- FLUSH_READ test:\r\n");

      int result = uncached_write_cached_read_test((void *)test_space_aligned, 2*CACHE_SIZE, CACHE_SIZE, CACHE_LINE_SIZE, false, 2, (CACHE_SIZE/sizeof(uint32_t))-2);
      if(result){
        printf("FLUSH_READ large uncached_write_cached_read_test failed with error code 0x%08X\r\n", result);
        errors++;
      } else {
        printf("FLUSH_READ large uncached_write_cached_read_test passed\r\n");
      }

      result = uncached_write_cached_read_test((void *)test_space_aligned, 2*CACHE_SIZE, CACHE_SIZE, CACHE_LINE_SIZE, false, ((CACHE_SIZE/2)/sizeof(uint32_t))-2, ((CACHE_SIZE/2)/sizeof(uint32_t))+2);
      if(result){
        printf("FLUSH_READ small uncached_write_cached_read_test failed with error code 0x%08X\r\n", result);
        errors++;
      } else {
        printf("FLUSH_READ small uncached_write_cached_read_test passed\r\n");
      }
    }
#endif //#if RUN_FLUSH_READ_TEST

#if RUN_INVALIDATE_TEST
    if(test_cached_and_uncached){
      printf("-- INVALIDATE test:\r\n");

      int result = uncached_write_cached_read_test((void *)test_space_aligned, 2*CACHE_SIZE, CACHE_SIZE, CACHE_LINE_SIZE, true, 2, (CACHE_SIZE/sizeof(uint32_t))-2);
      if(result){
        printf("INVALIDATE large uncached_write_cached_read_test failed with error code 0x%08X\r\n", result);
        errors++;
      } else {
        printf("INVALIDATE large uncached_write_cached_read_test passed\r\n");
      }

      result = uncached_write_cached_read_test((void *)test_space_aligned, 2*CACHE_SIZE, CACHE_SIZE, CACHE_LINE_SIZE, true, ((CACHE_SIZE/2)/sizeof(uint32_t))-2, ((CACHE_SIZE/2)/sizeof(uint32_t))+2);
      if(result){
        printf("INVALIDATE small uncached_write_cached_read_test failed with error code 0x%08X\r\n", result);
        errors++;
      } else {
        printf("INVALIDATE small uncached_write_cached_read_test passed\r\n");
      }
    }
#endif //#if RUN_INVALIDATE_TEST

#if RUN_3_INSTRUCTION_LOOP
    {
      printf("-- 3 instruction loop:\r\n");
  
      uint32_t run_cycles = timing_test(((uint32_t *)test_space_aligned)+1, 0);
      
      printf("%9d cycles for %d runs of 3 instruction loop.\r\n", (int)run_cycles, LOOP_RUNS);
    }
#endif //#if RUN_3_INSTRUCTION_LOOP

#if RUN_6_INSTRUCTION_LOOP
    {
      printf("-- 3 instruction loop (jumping between two copies):\r\n");

      uint32_t timing_loop_size = (uint32_t)(((uintptr_t)(&idram_timing_loop_end))-((uintptr_t)(&idram_timing_loop)));

      uint32_t run_cycles = timing_test((uint32_t *)test_space_aligned, timing_loop_size);
      
      printf("%9d cycles for %d runs of 3 instruction (2 copy) loop.\r\n", (int)run_cycles, LOOP_RUNS);
    }
#endif //#if RUN_6_INSTRUCTION_LOOP

#if RUN_BTB_MISSES
    {
      printf("-- BTB misses:\r\n");

      uint32_t run_cycles = timing_test((uint32_t *)test_space_aligned, (BTB_SIZE*sizeof(uint32_t)));
  
      printf("%9d cycles for %d runs of 3 instruction (2 copy) loop.\r\n", (int)run_cycles, LOOP_RUNS);
    }
#endif //#if RUN_BTB_MISSES

#if RUN_CACHE_MISSES
    {
      printf("-- Cache misses:\r\n");

      //Increment by CACHE_SIZE + one word; this gives the same cache
      //line for both timing loops but a different BTB entry (assuming
      //more than one BTB entry)
      uint32_t run_cycles = timing_test((uint32_t *)test_space_aligned, (CACHE_SIZE+sizeof(uint32_t)));
  
      printf("%9d cycles for %d runs of 3 instruction (2 copy) loop.\r\n", (int)run_cycles, LOOP_RUNS);
    }
#endif //#if RUN_CACHE_MISSES

#if RUN_CACHE_AND_BTB_MISSES
    {
      printf("-- Cache and BTB misses:\r\n");

      uint32_t run_cycles = timing_test((uint32_t *)test_space_aligned, CACHE_SIZE);
  
      printf("%9d cycles for %d runs of 3 instruction (2 copy) loop.\r\n", (int)run_cycles, LOOP_RUNS);
    }
#endif //#if RUN_CACHE_AND_BTB_MISSES

  }

  if(errors){
    printf("\r\nCache test failed with %d errors\r\n\r\n\r\n", errors);
  } else {
    printf("\r\nCache test passed!\r\n\r\n\r\n");
  }
  
  return errors+1;
}
