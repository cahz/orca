#include "printf.h"


#define SYS_CLK 12000000
volatile int *ledrgb= (volatile int*)0x10000;

//////////////////////
//
// UART stuff
//////////////////////
#define  UART_BASE ((volatile int*) 0x00020000)
volatile int*  UART_DATA=UART_BASE;
volatile int*  UART_LCR=UART_BASE+3;
volatile int*  UART_LSR=UART_BASE+5;

#define UART_LCR_8BIT_DEFAULT 0x03
#define UART_INIT() do{*UART_LCR = UART_LCR_8BIT_DEFAULT;}while(0)
#define UART_PUTC(c) do{*UART_DATA = (c);}while(0)
#define UART_BUSY() (!((*UART_LSR) &0x20))
void mputc ( void* p, char c)
{
	while(UART_BUSY());
	*UART_DATA = c;
}
#define debug(var) printf("%s:%d  %s = %d \r\n",__FILE__,__LINE__,#var,(signed)(var))
#define debugx(var) printf("%s:%d  %s = %08X \r\n",__FILE__,__LINE__,#var,(unsigned)(var))

////////////
//TIMER   //
////////////
static inline unsigned get_time()
{int tmp;       asm volatile(" csrr %0,time":"=r"(tmp));return tmp;}

void delayus(int us)
{
	unsigned start=get_time();
	us*=(SYS_CLK/1000000);
	while(get_time()-start < us);
}
#define delayms(ms) delayus(ms*1000)


int main()
{
	int i=0;
	int colour=0x01;
	UART_INIT();
	init_printf(0,mputc);

	for(;;){
		if ((colour<<=8) >=0x00800000){
			colour>>= 23;
		}
		debugx(colour);
		*ledrgb=colour;
		printf("Hello World %d\r\n",i++);
		delayms(500);
	}
}


int handle_trap(long cause,long epc, long regs[32])
{
	//spin forever
	for(;;);
}
