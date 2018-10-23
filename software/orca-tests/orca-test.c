#include "bsp.h"
#if ORCA_ENABLE_EXCEPTIONS
#include "orca_exceptions.h"
#endif
#include "orca_printf.h"
#include <stdlib.h>
//Pass or fail a test for the orca-tests suite.
int orca_test_passfail(int t3){
  if(t3 == 1){
    printf("\r\nTest passed!\r\n--\r\n\x4");
  } else {
    printf("\r\nTest failed on test # %d.\r\n--\r\n\x4", t3);
  }

  //Hang here; never return
  while(1){
  }
}
void empty_ecall(void* context){}
#define TEST_RESULT_REGISTER "x3"
static void test_fail(int testnum){
	asm volatile ("mv " TEST_RESULT_REGISTER ", %0\n"
	              "fence.i\n"
	              "ecall\n"
	              : : "r"(testnum):TEST_RESULT_REGISTER);
}
static void testpass(){
asm volatile ("li "TEST_RESULT_REGISTER " , 1\n"
              "fence.i\n"
              "ecall\n" :::TEST_RESULT_REGISTER);
}
typedef int (*test_func)(void) ;
extern test_func test_functions[] ;
int main(){
	orca_register_ecall_handler(empty_ecall,NULL);
	int failed=0;
	for(int i=0;test_functions[i];++i){
		int ret = test_functions[i]();
		if (ret){
			//test numbers start at 2 because
			//0 usually indicates t3 wasn't written (problem with test),
			//1 indicates test passes
			//n>1 indicates which test failed
			failed=i+2;
			test_fail(failed);
			break;
		}
	}
	if(!failed){
		testpass();
	}
	orca_test_passfail(failed?failed:1);
}
