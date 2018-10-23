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
 MEM : ORIGIN = 0x0, LENGTH = 64K
}
/*----------------------------------------------------------------------*/
/* Sections                                                             */
/*----------------------------------------------------------------------*/
ENTRY(_start)

SECTIONS
{

  /* text: test code section */
  . = 0x000;
  .text.init . :
  {
	  *(.text.init)
  }>MEM
  .text :
  {
    *(.text)
  }>MEM
  /* data segment */
  .data : { *(.data) }>MEM
  .rodata : { *(.rodata) }>MEM

  .sdata : {
    _gp = . + 0x800;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  }>MEM

  /* bss segment */
  .sbss : {
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
  }>MEM
  .bss : { *(.bss) }>MEM

  /* thread-local data segment */
  .tdata :
  {
    _tls_data = .;
    *(.tdata)
  }>MEM
  .tbss :
  {
    *(.tbss)
  }>MEM



  /* End of uninitalized data segement */
  _end = .;

  _end_of_memory = 64K;
}
