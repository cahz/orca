#include "uart.h"
#include "main.h"

//void mputc (void* p, char c) {
//  print_char(c); 
//}

int main(void) {
  int i;

  //init_printf(0, mputc);

  for (;;) {
    ChangedPrint("Hello World\r\n");
    delayms(100);
    //printf("Hello World\r\n"); 
  }

  return 1;
}

int handle_trap(long cause,long epc, long regs[32])
{
	//spin forever
	for(;;);
}
