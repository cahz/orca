#ifndef __UART_H
#define __UART_H

//Zynq-7 series UART (using the slave port on the PS from the PL)

#include "bsp.h"
#include <stdbool.h>
#include "orca_utils.h"

#ifndef PS7_UART_BASE_ADDRESS
#error "PS7_UART_BASE_ADDRESS must be defined before including uart.h; it should be defined in bsp.h"
#endif

#define PS7_UART_STATUS_REGISTER   0x2C
#define PS7_UART_DATA_OUT_REGISTER 0x30

#define PS7_UART_STATUS_FULL  0x00000010
#define PS7_UART_STATUS_EMPTY 0x00000008

//Used by printf.c if printf is uninitialized
#define DEFAULT_PUTP ((void *)PS7_UART_BASE_ADDRESS)

static inline void UART_INIT(){
  return;
}

static inline void UART_PUTC(void *base_address, char data){
  ORCA_OUT8(base_address, PS7_UART_DATA_OUT_REGISTER, data);
}

static inline bool UART_BUSY(void *base_address){
  return (ORCA_IN32(base_address, PS7_UART_STATUS_REGISTER) & PS7_UART_STATUS_FULL) != 0;
}

//Used by printf.c if printf is uninitialized
static inline void default_putf(void *base_address, char data){
	while(UART_BUSY(base_address));
	UART_PUTC(base_address, data);
}

static inline void flush_uart(void *base_address){
  while((ORCA_IN32(base_address, PS7_UART_STATUS_REGISTER) & PS7_UART_STATUS_EMPTY) == 0){
  }
}

#endif //#ifndef __UART_H
