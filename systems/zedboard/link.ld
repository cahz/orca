/*AUTOMATICALLY GENERATED FILE*/

OUTPUT_ARCH( "riscv" )
MEMORY
{

 axi_bram_ctrl_onchip_A4 : ORIGIN = 0x00000000 , LENGTH = 0x20000
 axi_gpio_leds : ORIGIN = 0xFFFF0000 , LENGTH = 0x10000
 lmb_bram_if_cntlr : ORIGIN = 0x00000000 , LENGTH = 0x20000
 orca_timer : ORIGIN = 0xFFFE0000 , LENGTH = 0x10000
 ps7_ethernet_0 : ORIGIN = 0xE000B000 , LENGTH = 0x1000
 ps7_gpio_0 : ORIGIN = 0xE000A000 , LENGTH = 0x1000
 ps7_qspi_0 : ORIGIN = 0xE000D000 , LENGTH = 0x1000
 ps7_qspi_linear_0 : ORIGIN = 0xFC000000 , LENGTH = 0x1000000
 ps7_sd_0 : ORIGIN = 0xE0100000 , LENGTH = 0x1000
 ps7_uart_1 : ORIGIN = 0xE0001000 , LENGTH = 0x1000
 ps7_usb_0 : ORIGIN = 0xE0002000 , LENGTH = 0x1000
}
/*----------------------------------------------------------------------*/
/* Sections                                                             */
/*----------------------------------------------------------------------*/
ENTRY(_start)

SECTIONS
{

  /* text: test code section */
  . = 0x00000000;
  .text.init . :
  {
	  *(.text.init)
  }>axi_bram_ctrl_onchip_A4
  .text . :
  {
    *(.text)
  }>axi_bram_ctrl_onchip_A4

  /* data segment */
  .data : { *(.data) }>axi_bram_ctrl_onchip_A4
  .rodata : { *(.rodata) }>axi_bram_ctrl_onchip_A4

  .sdata : {
    _gp = . + 0x8000;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  }>axi_bram_ctrl_onchip_A4
  _bss_start = .;
  /* bss segment */
  .sbss : {
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
  }>axi_bram_ctrl_onchip_A4
  .bss : { *(.bss) }>axi_bram_ctrl_onchip_A4

  /* thread-local data segment */
  .tdata :
  {
    _tls_data = .;
    *(.tdata)
  }>axi_bram_ctrl_onchip_A4
  .tbss :
  {
    *(.tbss)
  }>axi_bram_ctrl_onchip_A4

  /* End of uninitalized data segement */
  _end = .;

  _end_of_memory = 0x1fffc;
}
