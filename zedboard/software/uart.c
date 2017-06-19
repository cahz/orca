#include "uart.h"

void XUARTChanged_SendByte(uint32_t BaseAddress, uint8_t Data) {
  while (XUartChanged_IsTransmitFull(BaseAddress));
  X_mWriteReg(BaseAddress, 0x30, Data);
}

void outbyte(char c) {
  XUARTChanged_SendByte(0xE0001000, c);
}

void ChangedPrint(char *ptr) {
  while (*ptr) {
    outbyte(*ptr++);
  }
}

void print_char(char c) {
  outbyte(c);
}

