#ifndef __BSP_H
#define __BSP_H
#include "orca_defines.h"

#define ORCA_CLK 100000000

#define UART_BASE_ADDRESS   0xFFFD0000
#define TIMER_BASE_ADDRESS  0xFFFE0000

#define ORCA_ENABLE_EXCEPTIONS     1
#define ORCA_ENABLE_EXT_INTERRUPTS 1
#define ORCA_NUM_EXT_INTERRUPTS    1

#define TIMER_CLK ORCA_CLK

#endif //#ifndef __BSP_H
