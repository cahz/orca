

int test_2()
{

  //Tests all return 0 on success, non-zero on failure
  return 0;
}


typedef int (*test_func)() ;
test_func test_functions[] = {
	test_2,
	(void*)0
};
