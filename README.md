Vectorblox ORCA
================

ORCA is an implementation of RISC-V. It is intended to target FPGAs and can be configured as either RV32I a RV32IM code.

ORCA can be used as a standalone processor, but was built to be a host to Vectorblox's Proprietary Matrix processor
[MXP](https://github.com/VectorBlox/mxp).

It is possible to select between Wishbone, Avalon, and AXI for the data and instruction Memory Mapped interfaces Specification.

A QSYS component is provided for easy integration into the Altera toolchain.


Building Toolchain
-----------------

The official RISC-V toolchain is under active development, and is subject to breaking changes from time to time. Because of that we
have included a linked a specific version of the toolchain to this repository. If you use a different version of the toolchain, you
may have mixed results.

To build the toolchain, set `RISCV_INSTALL` to be the destination directory for the toolchain, then run 
`GIT_TOP/tools/riscv-toolchain/build-toolchain.sh`.

Sample Systems
--------------

We have provided multiple sample projects across different vendor platforms in the systems/ subdirectory.

The first sample system targeting the DE2-115 (found in the TPad or Veek development systems) is located in the de2-115
directory. It uses the Altera toolchain and requires Quartus and Qsys. 

A sample system using the Lattice iCEcube2 toolchain is located in the ice40ultra directory. It targets the iCE5LP4K chip.

In the sf2plus directory is a Microsemi SmartFusion2 sample project that targets the M2S150-FC1152 chip. It is built using the
Libero toolchain.

The zedboard directory contains a Xilinx sample project that targets the Zynq-7000 XC7Z020-CLG484-1 SoC. It is built using the 
Vivado toolchain. 

In addition to this example system we provide a system targeting a simulator such as modelsim. We use QSYS to help maintain
these systems. The Libero tools include BFM models to simulate the SmartFusion2 system, and the Vivado tools include a simulator
to debug a generated Vivado design.


Configuring ORCA
----------------

Below is an overview of the various generics exposed from the top level to configure ORCA.

### BUS TYPE

There are three generics (`AVALON_ENABLE` ,  `WISHBONE_ENABLE` , `AXI_ENABLE` ) of which only one must
be set to one. An Assertion will be thrown if more than one is enabled. From the QSYS Configuration
box, only Avalon or AXI can be selected.

### REGISTER_SIZE (default = 32)

Reserved for future use, must be set to 32

### RESET_VECTOR (default = 0x0000 0000)

Address that the first instruction to be executed at reset is located. The automated tests expect the default value.

### MULTIPLY_ENABLE (default = 0)

Enable hardware multiplication

### DIVIDE_ENABLE (default = 0 )

Enable hardware division (takes 32 cycles)

### SHIFTER_MAX_CYCLES (default = 1)

How many cycles a shift operation can take. valid values are 1, 8 and 32. If `MULTIPLY_ENABLE` is set to 1, this
configuration option is ignored, and the shifter uses the multiplier.

### POWER_OPTIMIZED (default = 0)

If This is set to 1, then extra gates are added to improve power usage at the expense of area.


### COUNTER_LENGTH (default = 0)

How many bits the mtime register contains. The standard RISC-V dictates 64 bits, but ORCA allows 32 and 0 as valid
values as well.

### ENABLE_EXCEPTIONS (default = 1)

If this is set to 1, then logic is added to allow the processor to be interrupted by software interrupts.

### BRANCH_PREDICTORS (default = 0)

Reserved for when a branch predictor is implemented

### PIPELINE STAGES ( default = 5)

Legal values are 4 and 5. If set to 4, the registers on the output side of the register file are eliminated.

### LVE_ENABLE (default = 0)

Enable Lightweight Vector Extensions (not publicly available)

### SCRATCHPAD_ADDR_BITS (default = 10)

If `LVE_ENABLE == 1`, the number of address bits gives the size of the scratchpad memory.

### ENABLE_EXT_INTERRUPTS (default = 0)

Enable interrupts from the outside world to interrupt the processor. Depends on `ENABLE_EXCEPTIONS ==1`

### NUM_EXT_INTERRUPTS (default = 1)

If `ENABLE_EXT_INTERRUPTS = 1` select how many interrupts to support.

## FAMILY (default = ALTERA)

Enables certain portability workarounds when using a specific family ("ALTERA", "LATTICE", "MICROSEMI", and "XILINX").


Interrupts
----------------------

We found that the Platform Level Interrupt controller (PLIC) that was described in the Privileged Specification V1.9
was to complex for our needs, so ORCA has a non-standard but very simple interrupt controller.

We define 2 more 32 bit CSRs, `MEIPEND` and `MEIMASK`. Because these registers are a maximum of 32bits wide, ORCA only
supports 32 interrupts natively.`MEIMASK` is a mask for the external interrupts. If bit *n* of `MEIMASK` is set, then
that the *nth* interrupt is enabled. `MEIPEND` is connected to the external interrupt lines, and a such is read-only.

|**CSR Name** | **CSR Number** | **Access**|
|:------------|:--------------:|:---------:|
|MEIMASK      | 0x7C0          | RW |
|MEIPEND      | 0xFC0          | RO |

The Processor is interrupted by an external interrupt on line *n* if and only if the `MIE` bit of the `MSTATUS` CSR is 1 and
bit *n* of the `MEIMASK` CSR is set to 1.

Sleep CSR
----------------------

By writing to csr number 0x800 (Write-Only) it is possible to stall the processor until the value in `MTIME` is equal to
the value being written.

The standard way of sleeping a risc-v processor is to set `MTIMECMP` and then use the `WIP` instruction to wait for an
interrupt. We chose to implement the above non-standard sleep mode because we wanted to sleep even on systems
without interrupt support.
