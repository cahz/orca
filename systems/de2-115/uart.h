#ifndef __UART_H
#define __UART_H

#include "bsp.h"
#include <stdbool.h>
#include "orca_utils.h"

#ifndef UART_BASE_ADDRESS
#error "UART_BASE_ADDRESS must be defined before including uart.h; it should be defined in bsp.h"
#endif

#define JTAG_UART_DATA_REGISTER   0x0
#define JTAG_UART_STATUS_REGISTER 0x4

#define JTAG_UART_STATUS_TX_FIFO_MASK 0xFFFF0000

//Used by printf.c if printf is uninitialized
#define DEFAULT_PUTP ((void *)UART_BASE_ADDRESS)

static inline void UART_INIT(){
  return;
}

static inline void UART_PUTC(void *base_address, char data){
  ORCA_OUT8(base_address, JTAG_UART_DATA_REGISTER, data);
}

static inline bool UART_BUSY(void *base_address){
  return (ORCA_IN32(base_address, JTAG_UART_STATUS_REGISTER) & JTAG_UART_STATUS_TX_FIFO_MASK) == 0;
}

//Used by printf.c if printf is uninitialized
static inline void default_putf(void *base_address, char data){
	while(UART_BUSY(base_address));
	UART_PUTC(base_address, data);
}

#endif //#ifndef __UART_H
