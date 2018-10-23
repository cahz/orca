#ifndef __ORCA_EXCEPTIONS_H
#define __ORCA_EXCEPTIONS_H

#define ORCA_EXCEPTION_ALREADY_REGISTERED       0x00000001
#define ORCA_UNSUPPORTED_EXCEPTION_REGISTRATION 0x00000002

#ifndef ORCA_ENABLE_EXCEPTIONS
#error "ORCA_ENABLE_EXCEPTIONS must be defined before including orca_exceptions.h; it should be defined in bsp.h"
#endif //#ifndef ORCA_ENABLE_EXCEPTIONS

#ifndef ORCA_ENABLE_EXT_INTERRUPTS
#error "ORCA_ENABLE_EXT_INTERRUPTS must be defined before including orca_exceptions.h; it should be defined in bsp.h"
#endif //#ifndef ORCA_ENABLE_EXT_INTERRUPTS

#ifndef ORCA_NUM_EXT_INTERRUPTS
#error "ORCA_NUM_EXT_INTERRUPTS must be defined before including orca_exceptions.h; it should be defined in bsp.h"
#endif //#ifndef ORCA_NUM_EXT_INTERRUPTS

#define ORCA_INTERRUPT_HANDLERS ((ORCA_ENABLE_EXCEPTIONS && ORCA_ENABLE_EXT_INTERRUPTS) ? ORCA_NUM_EXT_INTERRUPTS : 0)
#include <stdint.h>
#include <stdlib.h>
typedef void (*orca_exception_handler)(void *);
typedef void (*orca_interrupt_handler)(int, void *);
typedef int (*orca_illegal_instruction_handler)(size_t, size_t, size_t[], void *);
/**
 * @brief Register a timer interrupt handler.
 * @param handler The function to be called when timer interrupt goes off
 * @param context a pointer to a data that will be passed to the handler when it is called
 *        will point to the old context after this orca_register_timer_hander returns.
 *        If it is NULL, it is ignored.
 * @return The old interrupt handler
 */
orca_exception_handler orca_register_timer_handler(orca_exception_handler handler,void** context);

/**
 * @brief Register a timer interrupt handler.
 * @param handler The function to be called when timer interrupt goes off
 * @param context a pointer to a data that will be passed to the handler when it is called
 *        will point to the old context after this orca_register_timer_hander returns.
 *        If it is NULL, it is ignored.
 * @return The old interrupt handler
 */
orca_exception_handler orca_register_ecall_handler(orca_exception_handler the_handler,void** the_context);

//Register an illegal instruction handler.
int orca_register_illegal_instruction_handler(orca_illegal_instruction_handler the_handler, void *the_context);

//Register an interrupt handler.  The interrupt mask specifies which
//interrupt(s) will use this handler.  See orca_exceptions.h for
//return codes.
int orca_register_interrupt_handler(uint32_t interrupt_mask, orca_interrupt_handler the_handler, void *the_context);

#endif //#ifndef __ORCA_EXCEPTIONS_H
