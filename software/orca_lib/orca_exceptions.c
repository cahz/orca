#include <stdint.h>
#include <stddef.h>
#include "bsp.h"
#include "orca_exceptions.h"
#include "orca_interrupts.h"
#include "orca_printf.h"

#if ORCA_ENABLE_EXCEPTIONS
static orca_illegal_instruction_handler illegal_instruction_handler = NULL;
static void *illegal_instruction_context                  = NULL;
static orca_exception_handler timer_handler = NULL;
static void* timer_context=NULL;
static orca_exception_handler ecall_handler = NULL;
static void* ecall_context=NULL;

#if ORCA_INTERRUPT_HANDLERS

static orca_interrupt_handler interrupt_handler_table[ORCA_INTERRUPT_HANDLERS] = {NULL};
static void *interrupt_context_table[ORCA_INTERRUPT_HANDLERS]                  = {NULL};
static uint32_t registered_interrupt_handlers = 0x00000000;

#endif //#if ORCA_INTERRUPT_HANDLERS


orca_exception_handler orca_register_timer_handler(orca_exception_handler the_handler,void** the_context){
	orca_exception_handler old=timer_handler;
	void* old_context=timer_context;
	timer_handler = the_handler;
	if(the_context){
		timer_context = *the_context;
		*the_context = old_context;
	}
	return old;
}
orca_exception_handler orca_register_ecall_handler(orca_exception_handler the_handler,void** the_context){
	orca_exception_handler old=ecall_handler;
	void* old_context=ecall_context;
	ecall_handler = the_handler;
	if(the_context){
		ecall_context = *the_context;
		*the_context = old_context;
	}
	return old;
}

//Register an illegal instruction
int register_orca_illegal_instruction_handler(orca_illegal_instruction_handler the_handler, void *the_context){
	int return_code = 0;
	if(illegal_instruction_handler){
		return_code |= ORCA_EXCEPTION_ALREADY_REGISTERED;
	}
	illegal_instruction_handler = the_handler;
	illegal_instruction_context = the_context;
	return return_code;
}

//Register an interrupt handler.  The interrupt mask specifies which
//interrupt(s) will use this handler.  See orca_exceptions.h for
//return codes.
int orca_register_interrupt_handler(uint32_t interrupt_mask, orca_interrupt_handler the_handler, void *the_context){
#if ORCA_INTERRUPT_HANDLERS
	int return_code = 0;
	if((1<<(ORCA_INTERRUPT_HANDLERS-1)) < interrupt_mask){
		//if interrupt mask tries to register a interrupt that doesn't exist return an error
		return ORCA_UNSUPPORTED_EXCEPTION_REGISTRATION;
	}

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

	return return_code;
#else //#if ORCA_INTERRUPT_HANDLERS
		return ORCA_UNSUPPORTED_EXCEPTION_REGISTRATION;
#endif //#else //#if ORCA_INTERRUPT_HANDLERS
}

static void call_interrupt_handler(){
#if ORCA_INTERRUPT_HANDLERS
	uint32_t pending_interrupts= get_pending_interrupts();
	while(pending_interrupts){
		for(int int_num = 0; int_num<31; int_num++){
			//call the handler if it is regisered and pending
			if((1<<int_num) & registered_interrupt_handlers  & pending_interrupts){
				(*interrupt_handler_table[int_num])(int_num, interrupt_context_table[int_num]);
			}
			pending_interrupts = get_pending_interrupts();
		}
	}
#endif //#if ORCA_INTERRUPT_HANDLERS
}

static void handle_misaligned_load(size_t instr,size_t reg[32])
{
	uint8_t* address;
	csrr(mtval,address);
	int32_t intval;
	switch((instr >>12) &3){
	case 1: //half
		intval=(address[1]<<8) | address[0];
		if(!(instr & (1<<14))){//signed
			intval = (int16_t)intval;
		}

		break;
	default: //word
		intval=(address[3]<<24) | (address[2] << 16) | (address[1] <<8) | address[0];
		break;
	}
	reg[(instr>>7) & 0x1F] = intval;
}
static void handle_misaligned_store(size_t instr,size_t reg[32])
{
	uint8_t* address;
	csrr(mtval,address);
	size_t regval =reg[(instr>>15) & 0x1F] ;
	switch((instr >>12) &3){
	case 1: //half
		address[0] = regval&0xFF;
		address[1] = ((regval>>8)&0xFF);
		break;
	default: //word
		address[0] = regval&0xFF;
		address[1] = ((regval>>8)&0xFF);
		address[2] = ((regval>>16)&0xFF);
		address[3] = ((regval>>24)&0xFF);
		break;
	}

}

//Handle an exception.  Illegal instructions and interrupts can be
//passed to handlers set using the
//register_orca_illegal_instruction_handler() and
//register_orca_interrupt_handler() calls respectively.
int handle_exception(size_t cause, size_t epc, size_t regs[32]){
	switch(cause){
	case 0x8000000B://external interrupt
		call_interrupt_handler();
		break;
	case 0x80000007://timer
		if(timer_handler){
			timer_handler(timer_context);
			break;
		}else{ while(1); }
	case CAUSE_MISALIGNED_STORE:
		handle_misaligned_store(*((size_t*)epc), regs);
		epc+=4;
		break;
	case CAUSE_MISALIGNED_LOAD :
		handle_misaligned_load(*((size_t*)epc), regs);
		epc+=4;
		break;
	case CAUSE_ILLEGAL_INSTRUCTION ://illegal instruction
		if(illegal_instruction_handler){
			epc=illegal_instruction_handler(cause,epc,regs,illegal_instruction_context);
			break;
		}else{while(1);}
	case CAUSE_MACHINE_ECALL://ECALL
		if(ecall_handler){
			ecall_handler(ecall_context);
			epc+=4;
			break;
		}else{ while(1); }

	default:
		while(1);

	}
	return epc;
}

#else //#if ORCA_ENABLE_EXCEPTIONS
int handle_exception(size_t cause, size_t epc, size_t regs[32]){
  return 0;
}
#endif //#else //#if ORCA_ENABLE_EXCEPTIONS
