int test_2(void)
{
  int data_mem = 0;
  // Specifies the number of pipeline stages in the RAM.
  volatile static int data1  asm ("a0");
  volatile static int data2  asm ("a1");
  volatile static int result asm ("a2");
  volatile static int temp   asm ("a3");

  // Write valued, then read them from pipelined RAM.
  // Immediately after, begin a divide.
  data1 = 20;
  data2 = 0;
  asm volatile("sw %0,0(%1)"
    :
    :  "r" (15), "r" (&data_mem));
  asm volatile("lw %0,0(%1)"
    : "=r" (temp)
    : "r" (&data_mem));
  asm volatile("div %0,%1,%2"
    : "=r" (result)
    : "r" (data1), "r" (data2));
  if (result != 0xFFFFFFFF) {
    return 2;
  }

  data1 = 20;
  data2 = 5;
  // Test a multiply after read.
  asm volatile("lw %0,0(%1)"
    : "=r" (temp)
    : "r" (&data_mem));
  asm volatile("mul %0,%1,%2"
    : "=r" (result)
    : "r" (data1), "r" (data2));
  if (result != 100) {
    return 3;
  }

  // Test a shift after read.
  data1 = 24;
  data2 = 2;
  asm volatile("sw %0,0(%1)"
    :
    : "r" (16), "r" (&data_mem));
  asm volatile("lw %0,0(%1)"
    : "=r" (temp)
    : "r" (&data_mem));
  asm volatile("srl %0,%1,%2"
    : "=r" (result)
    : "r" (data1), "r" (data2));

  if (result != 6) {
    return 4;
  }

  return 0;
}
typedef int (*test_func)(void) ;
test_func test_functions[] = {
	test_2,
	(void*)0
};
