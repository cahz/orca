#ifndef __UART_H
#define __UART_H

//NULL UART

#include <stdbool.h>

//Used by printf.c if printf is uninitialized
#define DEFAULT_PUTP ((void *)NULL)

static inline void UART_INIT(){
  return;
}

static inline void UART_PUTC(void *base_address, char data){
}

static inline bool UART_BUSY(void *base_address){
  return false;
}

//Used by printf.c if printf is uninitialized
static inline void default_putf(void *base_address, char data){
	while(UART_BUSY(base_address));
	UART_PUTC(base_address, data);
}

static inline void flush_uart(void *base_address){
}

#endif //#ifndef __UART_H
