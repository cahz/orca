/*======================================================================*/
/* Proxy kernel linker script                                           */
/*======================================================================*/
/* This is the linker script used when building the proxy kernel. */

/*----------------------------------------------------------------------*/
/* Setup                                                                */
/*----------------------------------------------------------------------*/

/* The OUTPUT_ARCH command specifies the machine architecture where the
   argument is one of the names used in the BFD library. More
   specifically one of the entires in bfd/cpu-mips.c */

OUTPUT_ARCH( "riscv" )
MEMORY
{
 IMEM : ORIGIN = 0x0, LENGTH = 4K
 DMEM : ORIGIN = 4K, LENGTH = 4K
}
/*----------------------------------------------------------------------*/
/* Sections                                                             */
/*----------------------------------------------------------------------*/
ENTRY(_start)

SECTIONS
{

  /* text: test code section */
  . = 0x100;
  .init . :
  {
	  *(.init)
  }>IMEM
  .text :
  {
    *(.text)
  }>IMEM
  /* data segment */
  .rodata : { *(.rodata) }>DMEM
  .data : { *(.data) }>DMEM

  .sdata : {
    _gp = . + 0x800;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  }>DMEM

  /* bss segment */
  .sbss : {
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
  }>DMEM
  .bss : { *(.bss) }>DMEM

  /* thread-local data segment */
  .tdata :
  {
    _tls_data = .;
    *(.tdata)
  }>DMEM
  .tbss :
  {
    *(.tbss)
  }>DMEM

  /* End of uninitalized data segement */
  _end = .;

  _end_of_memory = 8K;
}
