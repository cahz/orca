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

typedef int (*orca_exception_handler)(int, int, int[], void *);
typedef void (*orca_interrupt_handler)(int, void *);

//Register an illegal instruction handler.
int register_orca_illegal_instruction_handler(orca_exception_handler the_handler, void *the_context);

//Register an interrupt handler.  The interrupt mask specifies which
//interrupt(s) will use this handler.  See orca_exceptions.h for
//return codes.
int register_orca_interrupt_handler(uint32_t interrupt_mask, orca_interrupt_handler the_handler, void *the_context);

//Handle an exception.  Illegal instructions and interrupts can be
//passed to handlers set using the
//register_orca_illegal_instruction_handler() and
//register_orca_interrupt_handler() calls respectively.
int handle_exception(int cause, int epc, int regs[32]);

#endif //#ifndef __ORCA_EXCEPTIONS_H
