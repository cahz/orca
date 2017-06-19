#include <stdint.h>

#define X_mWriteReg(BASE_ADDRESS, RegOffset, data)  \
  *(unsigned int *)(BASE_ADDRESS + RegOffset) = ((unsigned int) data);
#define X_mReadReg(BASE_ADDRESS, RegOffset) \
  *(unsigned int *)(BASE_ADDRESS + RegOffset);
#define XUartChanged_IsTransmitFull(BASE_ADDRESS)  \
  ((*(unsigned int *)((unsigned int)BASE_ADDRESS + 0x2C) & 0x10) == 0x10)

void XUARTChanged_SendByte(uint32_t BaseAddress, uint8_t Data);
void outbyte(char c);
void ChangedPrint(char *ptr);
void print_char(char c);
