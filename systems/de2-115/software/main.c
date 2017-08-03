#define SYS_CLK 50000000
#include "printf.h"

volatile int *  gpio_data= (volatile int*)0x10000;
volatile int *  hex0= (volatile int*)0x01000030;
volatile int *  hex1= (volatile int*)0x01000040;
volatile int *  hex2= (volatile int*)0x01000050;
volatile int *  hex3= (volatile int*)0x01000060;
volatile int *  uart= (volatile int*)0x01000070;
volatile int *  mic_ready= (volatile int*)0x01000100;
volatile int *  mic_data = (volatile int*)0x01000108;


#define UART_INIT() ((void)0)
#define UART_PUTC(c) do{*((char*)uart) = (c);}while(0)
#define UART_BUSY() ((uart[1]&0xFFFF0000) == 0)


void mputc ( void* p, char c)
{
	while(UART_BUSY());
	UART_PUTC(c);
}

static inline unsigned get_time() {
  int tmp;       
  asm volatile(" csrr %0,time":"=r"(tmp));return tmp;
}

void delayus(int us)
{
	unsigned start=get_time();
	us*=(SYS_CLK/1000000);
	while(get_time()-start < us);
}

#define delayms(ms) delayus(ms*1000)

int main() {

  init_printf(0, mputc);

	for (;;) {
		printf("Hello World\r\n");
		delayms(100);
	}

}

int tohost_exit() {
	for(;;);
}

int handle_interrupt(long cause, long epc, long regs[32]) {
  for(;;);
}
