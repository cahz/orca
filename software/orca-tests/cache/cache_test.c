#include <stdint.h>



#define TEST_SIZE_WORDS 7
#define TEST_RUNS       3

int test_2()
{
  //Test back-to-back word writes followed by reads

  uint32_t temp_location[TEST_SIZE_WORDS];
  uint32_t run = 0;
  for(run = 0; run < TEST_RUNS; run++){
    uint32_t word = 0;
    //Writes 4 copies so do test_size_words-3 locations
    for(word = 0; word < (TEST_SIZE_WORDS-3); word++){
      register uint32_t result0;
      register uint32_t result1;
      register uint32_t result2;
      register uint32_t result3;
      register uint32_t *temp_pointer = &temp_location[word];
      register uint32_t write_value   = word+run;
      asm volatile ("ori a0, %4, 0\n"
                    "ori a1, %5, 0\n"
                    "sw a0, 0(a1)\n"
                    "lw %0, 0(a1)\n"
                    "sw a0, 4(a1)\n"
                    "lw %1, 4(a1)\n"
                    "sw a0, 8(a1)\n"
                    "lw %2, 8(a1)\n"
                    "sw a0, 12(a1)\n"
                    "lw %3, 12(a1)\n"
                    : "=r"(result0), "=r"(result1), "=r"(result2), "=r"(result3)
                    : "r"(write_value), "r"(temp_pointer)
                    : "a0", "a1"
                    );
      if(result0 != write_value){
        return 1;
      }
      if(result1 != write_value){
        return 1;
      }
      if(result2 != write_value){
        return 1;
      }
      if(result3 != write_value){
        return 1;
      }
    }
  }

  return 0;
}

int test_3()
{
  //Test back-to-back halfword writes followed by reads

  uint16_t temp_location[TEST_SIZE_WORDS];
  uint32_t run = 0;
  for(run = 0; run < TEST_RUNS; run++){
    uint32_t word = 0;
    //Writes 4 copies so do test_size_words-3 locations
    for(word = 0; word < (TEST_SIZE_WORDS-3); word++){
      register uint16_t result0;
      register uint16_t result1;
      register uint16_t result2;
      register uint16_t result3;
      register uint16_t *temp_pointer = &temp_location[word];
      register uint16_t write_value   = word+run;
      asm volatile ("ori a0, %4, 0\n"
                    "ori a1, %5, 0\n"
                    "sh a0, 0(a1)\n"
                    "lhu %0, 0(a1)\n"
                    "sh a0, 2(a1)\n"
                    "lhu %1, 2(a1)\n"
                    "sh a0, 4(a1)\n"
                    "lhu %2, 4(a1)\n"
                    "sh a0, 6(a1)\n"
                    "lhu %3, 6(a1)\n"
                    : "=r"(result0), "=r"(result1), "=r"(result2), "=r"(result3)
                    : "r"(write_value), "r"(temp_pointer)
                    : "a0", "a1"
                    );
      if(result0 != write_value){
        return 1;
      }
      if(result1 != write_value){
        return 1;
      }
      if(result2 != write_value){
        return 1;
      }
      if(result3 != write_value){
        return 1;
      }
    }
  }

  return 0;
}

int test_4()
{
  //Test back-to-back byte writes followed by reads

  uint8_t temp_location[TEST_SIZE_WORDS];
  uint32_t run = 0;
  for(run = 0; run < TEST_RUNS; run++){
    uint32_t word = 0;
    //Writes 4 copies so do test_size_words-3 locations
    for(word = 0; word < (TEST_SIZE_WORDS-3); word++){
      register uint8_t result0;
      register uint8_t result1;
      register uint8_t result2;
      register uint8_t result3;
      register uint8_t *temp_pointer = &temp_location[word];
      register uint8_t write_value   = word+run;
      asm volatile ("ori a0, %4, 0\n"
                    "ori a1, %5, 0\n"
                    "sb a0, 0(a1)\n"
                    "lbu %0, 0(a1)\n"
                    "sb a0, 1(a1)\n"
                    "lbu %1, 1(a1)\n"
                    "sb a0, 2(a1)\n"
                    "lbu %2, 2(a1)\n"
                    "sb a0, 3(a1)\n"
                    "lbu %3, 3(a1)\n"
                    : "=r"(result0), "=r"(result1), "=r"(result2), "=r"(result3)
                    : "r"(write_value), "r"(temp_pointer)
                    : "a0", "a1"
                    );
      if(result0 != write_value){
        return 1;
      }
      if(result1 != write_value){
        return 1;
      }
      if(result2 != write_value){
        return 1;
      }
      if(result3 != write_value){
        return 1;
      }
    }
  }

  return 0;
}

typedef int (*test_func)(void) ;
test_func test_functions[] = {
	test_2,
	test_3,
	test_4,
	(void*)0
};
