#include <stdlib.h>
#include <stdint.h>
#include "bsp.h"
#include "orca_exceptions.h"
#include "orca_csrs.h"

#ifndef MTIME_ADDR
#define MTIME_ADDR 0x81000000
#endif

#define MTIMECMP_ADDR (MTIME_ADDR + 8)

int test_2()
{
	//test to make sure mtime is incrementing
	uint64_t then=(*(volatile uint64_t*)MTIME_ADDR);
	int i=30;
	while(i--){	asm("nop;");}
	uint64_t now=(*(volatile uint64_t*)MTIME_ADDR);

	return !(then < now);
}

volatile int interrupt_count=0;
void timer_handler(void * context)
{
	interrupt_count++;
	*((volatile uint64_t*)MTIMECMP_ADDR)=~0;
	return;
}


int test_3(){
	orca_register_timer_handler(timer_handler,NULL);
	csrw(mstatus,MSTATUS_MIE);
	uint64_t mtime=(*(volatile uint64_t*)MTIME_ADDR);
	int before=interrupt_count;
	*((volatile uint64_t*)MTIMECMP_ADDR)=mtime + 100;

	int i=1000;
	while(i--&& interrupt_count ==before){	}

	csrw(mstatus,0);
	return !(interrupt_count == before+1);
}



typedef int (*test_func)(void) ;
test_func test_functions[] = {
	test_2,
	test_3,
	(void*)0
};
