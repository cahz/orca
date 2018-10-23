int test_2(void)
{
  volatile static int source1 asm ("a0");
  volatile static int result1 asm ("a1");
  volatile static int source2 asm ("a2");
  volatile static int result2 asm ("a3");
  volatile static int*   data asm ("a4");
  source1 = 2;
  source2 = 4;

  // Test consecutive shifts
  asm volatile("slli %0,%1,4"
    : "=r" (result1)
    : "r" (source1));
  asm volatile("slli %0,%1,2"
    : "=r" (result2)
    : "r" (source2));

  if (result1 != 32 || result2 != 16) {
    return 2;
  }

  int data_mem = 0;
  data = &data_mem;
  source1 = result1;
  source2 = result2;

  // Test consecutive writes
  asm volatile("sw %0,4(%1)"
    :
    : "r" (source1), "r" (data));
  asm volatile("sw %0,8(%1)"
    :
    : "r" (source2), "r" (data));
  // Test consecutive reads
  asm volatile("lw %0,4(%1)"
    : "=r" (result1)
    : "r" (data));
  asm volatile("lw %0,8(%1)"
    : "=r" (result2)
    : "r" (data));
  if (result1 != 32 || result2 != 16) {
    return 3;
  }

  // Test read after write
  source1 = 0xDEADBEEF;
  asm volatile("sw %0,4(%1)"
    :
    : "r" (source1), "r" (data));
  asm volatile("lw %0,4(%1)"
    : "=r" (result1)
    : "r" (data));
  if (result1 != 0xDEADBEEF) {
    return 4;
  }

  return 0;
}
typedef int (*test_func)(void) ;
test_func test_functions[] = {
	test_2,
	(void*)0
};
