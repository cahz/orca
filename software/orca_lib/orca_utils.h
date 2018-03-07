#ifndef __ORCA_UTILS_H
#define __ORCA_UTILS_H

#include <stdint.h>

#define ORCA_IN32(BASE_ADDRESS, OFFSET)                                 \
  (*((volatile uint32_t *)(((uintptr_t)(BASE_ADDRESS)) + ((uintptr_t)(OFFSET)))))
#define ORCA_IN16(BASE_ADDRESS, OFFSET)                                 \
  (*((volatile uint16_t *)(((uintptr_t)(BASE_ADDRESS)) + ((uintptr_t)(OFFSET)))))
#define ORCA_IN8(BASE_ADDRESS, OFFSET)                                  \
  (*((volatile uint8_t *)(((uintptr_t)(BASE_ADDRESS)) + ((uintptr_t)(OFFSET)))))

#define ORCA_OUT32(BASE_ADDRESS, OFFSET, DATA)                          \
  do {                                                                  \
    *((volatile uint32_t *)(((uintptr_t)(BASE_ADDRESS)) + ((uintptr_t)(OFFSET)))) = ((uint32_t)(DATA)); \
  } while(0)
#define ORCA_OUT16(BASE_ADDRESS, OFFSET, DATA)                          \
  do {                                                                  \
    *((volatile uint16_t *)(((uintptr_t)(BASE_ADDRESS)) + ((uintptr_t)(OFFSET)))) = ((uint16_t)(DATA)); \
  } while(0)
#define ORCA_OUT8(BASE_ADDRESS, OFFSET, DATA)                           \
  do {                                                                  \
    *((volatile uint8_t *)(((uintptr_t)(BASE_ADDRESS)) + ((uintptr_t)(OFFSET)))) = ((uint8_t)(DATA)); \
  } while(0)

#define ORCA_PAD_UP(SIZE, ALIGNMENT)                                    \
  ((((size_t)(SIZE)) + (((size_t)(ALIGNMENT))-1)) & ~(((size_t)(ALIGNMENT))-1))
#define ORCA_PAD_DOWN(SIZE, ALIGNMENT)            \
  (((size_t)(SIZE)) & ~(((size_t)(ALIGNMENT))-1))
#define ORCA_IS_ALIGNED(SIZE, ALIGNMENT)                  \
  ((((size_t)(SIZE)) & ((size_t)(ALIGNMENT)-1)) ? 0 : 1)


#endif //#ifndef __ORCA_UTILS_H
