#include <stdint.h>
#include <stddef.h>
#include "bsp.h"
#include "orca_exceptions.h"
#include "orca_interrupts.h"
#include "orca_printf.h"

#if ORCA_ENABLE_EXCEPTIONS
static orca_exception_handler illegal_instruction_handler = NULL;
static void *illegal_instruction_context                  = NULL;
static bool registered_illegal_instruction_handler        = false;
#endif //ORCA_ENABLE_EXCEPTIONS

#if ORCA_INTERRUPT_HANDLERS
static orca_interrupt_handler interrupt_handler_table[ORCA_INTERRUPT_HANDLERS] = {NULL};
static void *interrupt_context_table[ORCA_INTERRUPT_HANDLERS]                  = {NULL};
static uint32_t registered_interrupt_handlers = 0x00000000;
#endif //#if ORCA_INTERRUPT_HANDLERS

//Register an illegal instruction handler.
int register_orca_illegal_instruction_handler(orca_exception_handler the_handler, void *the_context){
  int return_code = 0;
#if ORCA_ENABLE_EXCEPTIONS
  if(registered_illegal_instruction_handler){
    return_code |= ORCA_EXCEPTION_ALREADY_REGISTERED;
  }
  illegal_instruction_handler = the_handler;
  illegal_instruction_context = the_context;
#endif //#if ORCA_ENABLE_EXCEPTIONS
  return return_code;
}

//Register an interrupt handler.  The interrupt mask specifies which
//interrupt(s) will use this handler.  See orca_exceptions.h for
//return codes.
int register_orca_interrupt_handler(uint32_t interrupt_mask, orca_interrupt_handler the_handler, void *the_context){
  int return_code = 0;
#if ORCA_INTERRUPT_HANDLERS
  for(int interrupt_number = 0; interrupt_number < ORCA_INTERRUPT_HANDLERS; interrupt_number++){
    if(interrupt_mask & (1 << interrupt_number)){
      if(registered_interrupt_handlers & (1 << interrupt_number)){
        return_code |= ORCA_EXCEPTION_ALREADY_REGISTERED;
      }
      interrupt_handler_table[interrupt_number] = the_handler;
      interrupt_context_table[interrupt_number] = the_context;
      registered_interrupt_handlers |= (1 << interrupt_number);
    }
  }
#endif //#if ORCA_INTERRUPT_HANDLERS
#if ORCA_INTERRUPT_HANDLERS != 32
  if(interrupt_mask & (~((1 << ORCA_INTERRUPT_HANDLERS)-1))){
    return_code |= ORCA_EXCEPTION_ALREADY_REGISTERED;
  }
#endif //#if ORCA_INTERRUPT_HANDLERS != 32
  return return_code;
}


//Pass or fail a test for the orca-tests suite.  Should get moved to a
//support package.
int orca_test_passfail(int t3, int epc){
  if(t3 == 1){
    printf("\r\nTest passed!\r\n--\r\n%c", 0x4);
  } else {
    printf("\r\nTest failed with %d error%s.\r\n--\r\n%c", t3 ? t3 : 1, t3 ? "s" : "", 0x4);
  }

  //Hang here; never return
  while(1){
  }
  
  return epc;
}

//Handle an exception.  Illegal instructions and interrupts can be
//passed to handlers set using the
//register_orca_illegal_instruction_handler() and
//register_orca_interrupt_handler() calls respectively.
int handle_exception(int cause, int epc, int regs[32]){
#if ORCA_ENABLE_EXCEPTIONS
	if (!((cause >> 31) & 0x1)) {
		// Handle illegal instruction
    //
    // By default just print a debug message and hang.
    if(!registered_illegal_instruction_handler){
      if(cause == CAUSE_MACHINE_ECALL){
        printf("\r\n--\r\nUnhandled ECALL; assuming orca-test\r\n");
        return orca_test_passfail(regs[28], epc);
      }
      printf("\r\n--\r\nUnhandled illegal instruction @0x%08X.  Cause: 0x%08X, Instruction: 0x%08X\r\n--\r\n", epc, cause, (unsigned)(*((uint32_t *)epc)));
      for (;;);
    } else {
      return (*illegal_instruction_handler)(cause, epc, regs, illegal_instruction_context);
    }
	}
#else //#if ORCA_ENABLE_EXCEPTIONS
  printf("Exception when exceptions not enabled; assuming orca-test\r\n");
  return orca_test_passfail(regs[28], epc);
#endif //#else //#if ORCA_ENABLE_EXCEPTIONS

#if ORCA_INTERRUPT_HANDLERS
	// Handle interrupts
  uint32_t pending_interrupts = get_pending_interrupts();
  for(int interrupt_number = 0; pending_interrupts; interrupt_number++){
    uint32_t interrupt_mask = 1 << interrupt_number;
    if(registered_interrupt_handlers & interrupt_mask){
      (*interrupt_handler_table[interrupt_number])(interrupt_number, interrupt_context_table[interrupt_number]);
    }

    pending_interrupts &= (~interrupt_mask);
  }
#endif //#if ORCA_INTERRUPT_HANDLERS

	return epc;
}
