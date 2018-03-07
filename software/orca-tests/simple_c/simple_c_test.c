

int test_2()
{

  //Tests all return 0 on success, non-zero on failure
  return 0;
}

//this macro runs the test, and returns the test number on failure
#define do_test(TEST_NUMBER) do{                \
    if(test_##TEST_NUMBER()){                   \
      asm volatile ("slli x28, %0,  1\n"        \
                    "ori  x28, x28, 1\n"        \
                    "fence.i\n"                 \
                    "ecall\n"                   \
                    : : "r"(TEST_NUMBER));      \
        return TEST_NUMBER;                     \
    }                                           \
  } while(0)

#define pass_test() do{                         \
    asm volatile ("addi x28, x0, 1\n"           \
                  "fence.i\n"                   \
                  "ecall\n");                   \
    return 0;                                   \
  } while(0)

int main()
{

  do_test(2);

  pass_test();
  return 0;
}
