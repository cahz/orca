Vectorblox ORCA
================

ORCA is an implementation of RISC-V. It is intended to target FPGAs and can be
configured as either RV32I a RV32IM core.

ORCA can be used as a standalone processor, but was built to be a host to
Vectorblox's proprietary Lightweight Vector Extensions (LVE) or full-fledged
Matrix processor [MXP](https://github.com/VectorBlox/mxp).

It has optional AXI3/4 instruction and data caches, a separate AXI4-Lite interface for
uncached transactions, and an auxiliary interface that can be configured as
either WISHBONE, Intel Avalon, or Xilinx LMB.

A Qsys component is provided for easy integration into the Intel toolchain, as
well as a Vivado IPI component for Xilinx integration.


Building Toolchain
-----------------

To build the toolchain, set `RISCV_INSTALL` to be the destination directory for
the toolchain, for instance `/opt/riscv/`, then run
`GIT_TOP/tools/riscv-toolchain/build-toolchain.sh`.

Path
-----------------
We need to add environment variables to our bashrc file. `nano ~/.bashrc`

export QSYS_ROOTDIR="~/intelFPGA_lite/17.1/quartus/sopc_builder/bin"
export PATH=$PATH:~/intelFPGA_lite/17.1/quartus/sopc_builder/bin
export PATH=$PATH:~/intelFPGA_lite/17.1/quartus/bin/

If your language is Turkish:
export LC_ALL=en_US.UTF-8

Sample Systems
--------------

We have sample projects for different vendor platforms in the systems/
subdirectory.

The zedboard directory contains a Xilinx Vivado sample project that targets the
Zeboard development board using the Zynq-7000 XC7Z020-CLG484-1 SoC.

The de2-115 directory contains a Intel Qsys/Quartus project that targets the
DE2-115 (found in the TPad or Veek development systems).

In addition to these example system we provide a system (in the sim directory)
for use in debug and automated tests using Modelsim.  We use Intel Qsys to help
maintain these systems and generate interconnect.  The example systems can be
simulated in full if desired; see the README in each individual directory for
details.


ORCA Core Generics
----------------

Below is an overview of the various generics exposed from the top level to
configure the ORCA core (ORCA external memory interface generics are in a
separate section below).  If using Intel Quartus/Qsys or Xilinx Vivado a
graphical interface which simplifies setting the generics is provided.

### `REGISTER_SIZE` (default = 32)

Reserved for future RV64 support; currently only a value of 32 supported.

### `RESET_VECTOR` (default = 0x0000 0000)

Address that the first instruction to be executed at reset is located.

### `INTERRUPT_VECTOR` (default = 0x0000 0200)

Reset value of the `mtvec` register. The register defines the address of the
first instruction to be executed on machine traps (i.e., interrupts and 
exceptions). The value of `mtvec` can be changed via software after reset.

### `MAX_IFETCHES_IN_FLIGHT` (default = 1)

Number of outstanding instruction fetches in flight supported; a higher number
will use more area but get more throughput if there are multiple cycles of delay
to instruction RAM.

### `BTB_ENTRIES` (default = 0)

Number of Branch Target Buffer (BTB) entries.  If set to 0 there is no branch
prediction (equivalent to all branches predicted untaken).  If set to 1 or more
then branch prediction is done using a simple direct-mapped 1-bit BTB.  BTB
entries are stored in simple dual-port distributed RAMs (LUTRAMs) for
architectures that support them and so should not be set to excessive size
(currently they are limited to 64-entries max).  If your architecture does not
support distributed RAMs then flip-flops will be used and the number of BTB
entries should be kept to the low single digits.

### `MULTIPLY_ENABLE` (default = 0)

Enable hardware multiplication.  If set to 0 an illegal instruction exception
will be thrown for multiply instructions.

### `DIVIDE_ENABLE` (default = 0 )

Enable hardware division (32 cycles/instruction).  If set to 0 an illegal
instruction exception will be thrown for divide instructions.

### `SHIFTER_MAX_CYCLES` (default = 1)

How many cycles a shift operation will take, with lower values using more logic.
Valid values are 1, 8 and 32. If `MULTIPLY_ENABLE` is set to 1 this
configuration option is ignored and the shifter uses the multiplier.

### `POWER_OPTIMIZED` (default = 0)

If this is set to 1, then extra gates are added to improve power usage at the
expense of area and maximumx frequency.

### `ENABLE_EXCEPTIONS` (default = 1)

If this is set to 1, then logic is added to allow the processor for supporting
illegal instruction traps and the mret instruction.  If external interrupts are
required this must be set to 1 as well as `ENABLE_EXT_INTERRUPTS`.

### `PIPELINE_STAGES` ( default = 5)

Legal values are 4 and 5. If set to 4, the registers on the output side of the
register file are eliminated to save area at the expense of maxiumum frequency.

### `VCP_ENABLE` (default = 0)

Enable the Vector Coprocessor Port (VCP); this connects to VectorBlox's
proprietary Lightweight Vector Extensions (LVE) or Matrix Processor (MXP).  A
value of 1 enables the 32-bit variant of the VCP instructions, while a value of
2 enables both 32-bit and 64-bit VCP instructions.

### `ENABLE_EXT_INTERRUPTS` (default = 0)

Enable interrupts from the outside world to interrupt the processor.
`ENABLE_EXCEPTIONS` must be set to 1 when setting this to 1.

### `NUM_EXT_INTERRUPTS` (default = 1)

If `ENABLE_EXT_INTERRUPTS` is set to 1 this selects how many interrupts to
support.

### `FAMILY` (default = GENERIC)

Enables certain portability workarounds and optimizations when using a specific
FPGA family.  Currently "GENERIC", "INTEL", "LATTICE", "MICROSEMI", and "XILINX"
are supported.


External MTIME(H) Counter
----------------------

RISC-V dictates that the MTIME/MTIMEH CSRs are shadows of memory-mapped
registers.  To allow flexible implementations of this, we have implemented the
MTIME/MTIMEH counters and timer interrupt as an external component (ORCA Timer)
which can be found in the ip/orca-timer directory.  Wrappers for Qsys and Vivado
IPI are provided for the ORCA Timer component as well.

This also makes it possible for extremely small implementations to save space by
implementing a smaller than 64-bit counter and/or getting rid of the
memory-mapped interface and instead using a free-running counter.


Memory Interfaces
----------------------

ORCA supports multiple memory interfaces to interoperate with different FPGA IP.
Accesses may be cached (if caches are enabled) or uncached.  Cached instruction
or data accesses go out over the IC or DC AXI interface respectively.  Uncached
accesses go over either the uncached AXI4-Lite (IUC/DUC) or auxiliary interfaces
(WISHBONE, Avalon, or LMB).

Which memory interface is used depends on the values of the optional Auxiliarly
Memory Region (AMR) and Uncached Memory Region (UMR) CSRs.  AMRs have the
highest priority; if one or more AMRs are instantiated (by setting the
`AUX_MEMORY_REGIONS` generic to 1 or more) and the address being accessed is
greater than or equal to `AMRx_ADDR_BASE` and less than or equal to
`AMRx_ADDR_LAST` for any AMR x then the access will use the auxiliary memory
interface.  Note that since these are inclusive, to disable an AMR you must set
the base address to greater than the last address.  UMRs have next highest
priority and function the same way as AMRs.  Finally, if the access matches
neither an AMR nor a UMR then the access will try to hit in the cache (if
instantiated by setting the `ICACHE_SIZE`/`DCACHE_SIZE` generics to be
non-zero).  The caches currently only have write-through support with no
allocation on write misses, though other modes will be supported in the future.

|**CSR Name**     | **CSR Number** | **Access**|
|:----------------|:--------------:|:---------:|
|`CSR_MAMR0_BASE` | 0xBD0          | RW        |
|`CSR_MAMR1_BASE` | 0xBD1          | RW        |
|`CSR_MAMR2_BASE` | 0xBD2          | RW        |
|`CSR_MAMR3_BASE` | 0xBD3          | RW        |
|`CSR_MAMR0_LAST` | 0xBD8          | RW        |
|`CSR_MAMR1_LAST` | 0xBD9          | RW        |
|`CSR_MAMR2_LAST` | 0xBDA          | RW        |
|`CSR_MAMR3_LAST` | 0xBDB          | RW        |
|`CSR_MUMR0_BASE` | 0xBE0          | RW        |
|`CSR_MUMR1_BASE` | 0xBE1          | RW        |
|`CSR_MUMR2_BASE` | 0xBE2          | RW        |
|`CSR_MUMR3_BASE` | 0xBE3          | RW        |
|`CSR_MUMR0_LAST` | 0xBE8          | RW        |
|`CSR_MUMR1_LAST` | 0xBE9          | RW        |
|`CSR_MUMR2_LAST` | 0xBEA          | RW        |
|`CSR_MUMR3_LAST` | 0xBEB          | RW        |


Normally AMRs and UMRs can be changed at run-time via CSR writes.  However, if
neither instruction nor data caches are specified and `AUX_MEMORY_REGIONS` is
non-zero and `UC_MEMORY_REGIONS` is 0 all accesses will go over the auxiliary
interface and the AMRs will be disabled to save area.  Likewise, with no caches
and `UC_MEMORY_REGIONS` set to non-zero and `AUX_MEMORY_REGIONS` set to 0 all
accesses will go over the uncached interface and all UMRs will be disabled.
Disabled AMRs/UMRs return 0 when read and cannot be written.

ORCA uses AXI3 or AXI4 for its cached accesses and AXI4-Lite for uncached
accesses but exposes a full AXI3 master for all interfaces because some system
building tools require it.  To use AXI4 interfaces for the cached masters set
`LOG2_BURSTLENGTH` to 8 (4 for AXI3) and do not connect the WID signals.  To use
AXI4-Lite interfaces for the uncached masters only connect the AXI4-Lite
signals; the rest can be safely left unconnected.


ORCA Memory Generics
----------------------

### `LOG2_BURSTLENGTH`

The base 2 logarithm of the burstlength used for cached acesses (has no effect
if caches aren't enabled).

### `AXI_ID_WIDTH`

The AXI ID width for all AXI interfaces.  ORCA does not use multiple AXI IDs
(the xID signals will always be set to 0's); this generic is there simply for
interfaces that require ID signals from a master.

### `(AVALON/LMB/WISHBONE)_AUX`

There are three generics (`AVALON_AUX`, `LMB_AUX`, and `WISHBONE_AUX`) which
select which protocol the auxiliary memory interface uses, of which at most one
must be set to one.  In Intel Qsys this is not exposed and Avalon is enabled,
and likewise in Xilinx Vivado IPI this is not exposed and LMB is enabled.  These
can be safely ignored if the auxiliary memory interface is not used
(`AUX_MEMORY_REGIONS` set to 0).

### `(AUX/UC)_MEMORY_REGIONS`

The number of auxiliary/uncached memory regions and corresponding AMRs/UMRs;
refer to the above Memory Interfaces section for more detail.

### `(AMR0/UMR0)_ADDR_(BASE/LAST)`

Initial values for the first AMR/UMR CSRs.  These can be set via generics for
the common case that there needs to be a single contiguous WISHBONE/Avalon/LMB
interface and/or a single contiguous uncached interface for peripherals and
on-chip memories.  If multiple non-contiguous regions are needed they must be
set at run-time.

### `(ICACHE/DCACHE)_SIZE`

Size in bytes of the instruction cache and data cache.  Setting to
0 disables the cache; each cache can be sized differently and it is possible to
use only instruction or only data caches if desired.  There is a CSR for
determining if caches are enabled: `CSR_MCACHE`.

|**CSR Name** | **CSR Number** | **Access**|
|:------------|:--------------:|:---------:|
|`CSR_MCACHE` | 0xBC0          | RO        |

Bit 0 is set to 1 if the instruction cache is enabled, bit 1 if the data cache
is enabled.

### `DCACHE_WRITEBACK`

Data cache write policy.  Set to 0 for write-through and 1 for write-back.
Write-through immediately puts all writes onto the DC bus and does not allocate
on write misses.  Write-back writes dirty cache lines back on eviction
(conflict, IFENCE, or FLUSH/INVALIDATE) and allocates on write misses.

### `(ICACHE/DCACHE)_LINE_SIZE`

Size in bytes of cache lines in the instruction cache and data cache.

### `(ICACHE/DCACHE)_EXTERNAL_WIDTH`

Size in bits of the external memory interface for the instruction cache and data
cache.

### `(INSTRUCTION/DATA)_(REQUEST/RETURN)_REGISTER`

Registers for increasing maximum frequency at the expense of adding latency to
memory accesses.  These affect all instruction or data accesses (including
cache hits), as opposed to the below generics which are per-interface.

REQUEST registers affect the outgoing path from the master to the slave (reads
and writes).  They can be set to 0 for 'disabled, 1 for 'light', and 2 for
'full'.  A light register does not add latency if the interface does not exert
backpressure and isolates the combinational path through the READY/waitrequest
signal which is often the critical path.  A full register always add one cycle
of latency but maintains full throughput when the interface exerts backpressure
and isolates the combinational path through all signals.

RETURN registers affect the returning data from the slave back to the master on
reads.  They can be only be set set to 0 for 'disabled' and 1 for 'enabled'.
They add a single cycle of latency to reads when enabled.

If instruction registers are necessary to increase frequency be sure to set the
`MAX_IFETCHES_IN_FLIGHT` generic to at least the full latency of the instruction
fetch path.  For instance, if using a full instruction request register
(`INSTRUCTION_REQUEST_REGISTER` set to 2) and an instruction return register
(`INSTRUCTION_RETURN_REGISTER` set to 1) this adds two cycles of delay to
instruction fetch.  As such even when connected to a single-cycle on-chip RAM
all instruction fetches will take three cycles.  In that case with
`MAX_IFETCHES_IN_FLIGHT` set to 3 ORCA will still be able to run at 1 cycle per
instruction (aside from branch misprediction, load latency, multicycle
instructions, etc.) whereas with `MAX_IFETCHES_IN_FLIGHT` set to 1 it would only
be able to execute at 3 cycles per instruction at best.

### `(I/D)(UC/AUX/C)_(REQUEST/RETURN)_REGISTER`

Interface specific memory interface registers.  See the above generic
description for specifics.  Note that the cached
`(IC/DC)_(REQUEST/RETURN)_REGISTER` registers apply to the cache master and
therefore are only used on cache misses, whereas the
`(INSTRUCTION/DATA)_(REQUEST/RETURN)_REGISTER` registers are in between the ORCA
core and the cache and so also affect cache hits.


Interrupts
----------------------

We found that the Platform Level Interrupt controller (PLIC) that was described
in the Privileged Specification V1.9 was too complex for our needs, so ORCA has
a non-standard but very simple interrupt controller.

We define two more 32-bit CSRs, `MEIPEND` and `MEIMASK`. Because these registers
are a maximum of 32-bits wide, ORCA only supports 32 interrupts natively.
`MEIMASK` is a mask for the external interrupts.  If bit *n* of `MEIMASK` is
set, then that the *nth* interrupt is enabled.  `MEIPEND` is connected to the
external interrupt lines, and as such is read-only.

|**CSR Name** | **CSR Number** | **Access**|
|:------------|:--------------:|:---------:|
|MEIMASK      | 0x7C0          |  RW       |
|MEIPEND      | 0xFC0          |  RO       |

The Processor is interrupted by an external interrupt on line *n* if and only if
the `MIE` bit of the `MSTATUS` CSR is 1 and bit *n* of the `MEIMASK` CSR is set
to 1.  Interrupts are level sensitive and active high; as such it is the
responsibility of the interrupt handler to clear the interrupt (generally by
communicating with the responsible peripherial over memory-mapped I/O) before
re-enabling the `MIE` bit.  If the interrupt line is still high when the `MIE`
bit is reset (typically via a mret instruction) then the interrupt will be
immediately taken again.

If interrupts are not enabled (`ENABLE_EXT_INTERRUPTS` is set to 0 or
`ENABLE_EXCEPTIONS` is set to 0) then `MEIMASK` and `MEIPEND` will both be read
only and return 0.
