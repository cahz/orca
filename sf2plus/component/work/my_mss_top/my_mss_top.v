//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Fri Jun 16 11:59:08 2017
// Version: v11.7 SP3 11.7.3.8
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// my_mss_top
module my_mss_top(
    // Inputs
    AMBA_MASTER_0_HADDR_M0,
    AMBA_MASTER_0_HBURST_M0,
    AMBA_MASTER_0_HMASTLOCK_M0,
    AMBA_MASTER_0_HPROT_M0,
    AMBA_MASTER_0_HSIZE_M0,
    AMBA_MASTER_0_HTRANS_M0,
    AMBA_MASTER_0_HWDATA_M0,
    AMBA_MASTER_0_HWRITE_M0,
    DEVRST_N,
    FAB_RESET_N,
    M3_RESET_N,
    MMUART_0_RXD_F2M,
    PRDATAS1,
    PREADYS1,
    PSLVERRS1,
    // Outputs
    AMBA_MASTER_0_HRDATA_M0,
    AMBA_MASTER_0_HREADY_M0,
    AMBA_MASTER_0_HRESP_M0,
    FIC_0_CLK,
    FIC_0_LOCK,
    GL1,
    INIT_DONE,
    MMUART_0_TXD_M2F,
    MSS_READY,
    PADDRS,
    PENABLES,
    POWER_ON_RESET_N,
    PSELS1,
    PWDATAS,
    PWRITES
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  [31:0] AMBA_MASTER_0_HADDR_M0;
input  [2:0]  AMBA_MASTER_0_HBURST_M0;
input         AMBA_MASTER_0_HMASTLOCK_M0;
input  [3:0]  AMBA_MASTER_0_HPROT_M0;
input  [2:0]  AMBA_MASTER_0_HSIZE_M0;
input  [1:0]  AMBA_MASTER_0_HTRANS_M0;
input  [31:0] AMBA_MASTER_0_HWDATA_M0;
input         AMBA_MASTER_0_HWRITE_M0;
input         DEVRST_N;
input         FAB_RESET_N;
input         M3_RESET_N;
input         MMUART_0_RXD_F2M;
input  [31:0] PRDATAS1;
input         PREADYS1;
input         PSLVERRS1;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output [31:0] AMBA_MASTER_0_HRDATA_M0;
output        AMBA_MASTER_0_HREADY_M0;
output [1:0]  AMBA_MASTER_0_HRESP_M0;
output        FIC_0_CLK;
output        FIC_0_LOCK;
output        GL1;
output        INIT_DONE;
output        MMUART_0_TXD_M2F;
output        MSS_READY;
output [31:0] PADDRS;
output        PENABLES;
output        POWER_ON_RESET_N;
output        PSELS1;
output [31:0] PWDATAS;
output        PWRITES;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   [31:0] AMBA_MASTER_0_HADDR_M0;
wire   [2:0]  AMBA_MASTER_0_HBURST_M0;
wire          AMBA_MASTER_0_HMASTLOCK_M0;
wire   [3:0]  AMBA_MASTER_0_HPROT_M0;
wire   [31:0] AMBA_MASTER_0_HRDATA;
wire          AMBA_MASTER_0_HREADY;
wire   [1:0]  AMBA_MASTER_0_HRESP;
wire   [2:0]  AMBA_MASTER_0_HSIZE_M0;
wire   [1:0]  AMBA_MASTER_0_HTRANS_M0;
wire   [31:0] AMBA_MASTER_0_HWDATA_M0;
wire          AMBA_MASTER_0_HWRITE_M0;
wire   [31:0] AMBA_SLAVE_0_10_PADDR;
wire          AMBA_SLAVE_0_10_PENABLE;
wire   [31:0] PRDATAS1;
wire          PREADYS1;
wire          AMBA_SLAVE_0_10_PSELx;
wire          PSLVERRS1;
wire   [31:0] AMBA_SLAVE_0_10_PWDATA;
wire          AMBA_SLAVE_0_10_PWRITE;
wire          DEVRST_N;
wire          FAB_RESET_N;
wire          FIC_0_CLK_0;
wire          FIC_0_LOCK_0;
wire          GL1_net_0;
wire          INIT_DONE_net_0;
wire          M3_RESET_N;
wire          MMUART_0_RXD_F2M;
wire          MMUART_0_TXD_M2F_net_0;
wire          MSS_READY_net_0;
wire          POWER_ON_RESET_N_net_0;
wire          MMUART_0_TXD_M2F_net_1;
wire          INIT_DONE_net_1;
wire          MSS_READY_net_1;
wire          FIC_0_CLK_0_net_0;
wire          FIC_0_LOCK_0_net_0;
wire          POWER_ON_RESET_N_net_1;
wire          GL1_net_1;
wire          AMBA_MASTER_0_HREADY_net_0;
wire          AMBA_SLAVE_0_10_PSELx_net_0;
wire          AMBA_SLAVE_0_10_PENABLE_net_0;
wire          AMBA_SLAVE_0_10_PWRITE_net_0;
wire   [31:0] AMBA_MASTER_0_HRDATA_net_0;
wire   [1:0]  AMBA_MASTER_0_HRESP_net_0;
wire   [31:0] AMBA_SLAVE_0_10_PADDR_net_0;
wire   [31:0] AMBA_SLAVE_0_10_PWDATA_net_0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign MMUART_0_TXD_M2F_net_1        = MMUART_0_TXD_M2F_net_0;
assign MMUART_0_TXD_M2F              = MMUART_0_TXD_M2F_net_1;
assign INIT_DONE_net_1               = INIT_DONE_net_0;
assign INIT_DONE                     = INIT_DONE_net_1;
assign MSS_READY_net_1               = MSS_READY_net_0;
assign MSS_READY                     = MSS_READY_net_1;
assign FIC_0_CLK_0_net_0             = FIC_0_CLK_0;
assign FIC_0_CLK                     = FIC_0_CLK_0_net_0;
assign FIC_0_LOCK_0_net_0            = FIC_0_LOCK_0;
assign FIC_0_LOCK                    = FIC_0_LOCK_0_net_0;
assign POWER_ON_RESET_N_net_1        = POWER_ON_RESET_N_net_0;
assign POWER_ON_RESET_N              = POWER_ON_RESET_N_net_1;
assign GL1_net_1                     = GL1_net_0;
assign GL1                           = GL1_net_1;
assign AMBA_MASTER_0_HREADY_net_0    = AMBA_MASTER_0_HREADY;
assign AMBA_MASTER_0_HREADY_M0       = AMBA_MASTER_0_HREADY_net_0;
assign AMBA_SLAVE_0_10_PSELx_net_0   = AMBA_SLAVE_0_10_PSELx;
assign PSELS1                        = AMBA_SLAVE_0_10_PSELx_net_0;
assign AMBA_SLAVE_0_10_PENABLE_net_0 = AMBA_SLAVE_0_10_PENABLE;
assign PENABLES                      = AMBA_SLAVE_0_10_PENABLE_net_0;
assign AMBA_SLAVE_0_10_PWRITE_net_0  = AMBA_SLAVE_0_10_PWRITE;
assign PWRITES                       = AMBA_SLAVE_0_10_PWRITE_net_0;
assign AMBA_MASTER_0_HRDATA_net_0    = AMBA_MASTER_0_HRDATA;
assign AMBA_MASTER_0_HRDATA_M0[31:0] = AMBA_MASTER_0_HRDATA_net_0;
assign AMBA_MASTER_0_HRESP_net_0     = AMBA_MASTER_0_HRESP;
assign AMBA_MASTER_0_HRESP_M0[1:0]   = AMBA_MASTER_0_HRESP_net_0;
assign AMBA_SLAVE_0_10_PADDR_net_0   = AMBA_SLAVE_0_10_PADDR;
assign PADDRS[31:0]                  = AMBA_SLAVE_0_10_PADDR_net_0;
assign AMBA_SLAVE_0_10_PWDATA_net_0  = AMBA_SLAVE_0_10_PWDATA;
assign PWDATAS[31:0]                 = AMBA_SLAVE_0_10_PWDATA_net_0;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------my_mss
my_mss my_mss_0(
        // Inputs
        .FAB_RESET_N                ( FAB_RESET_N ),
        .AMBA_MASTER_0_HWRITE_M0    ( AMBA_MASTER_0_HWRITE_M0 ),
        .AMBA_MASTER_0_HMASTLOCK_M0 ( AMBA_MASTER_0_HMASTLOCK_M0 ),
        .DEVRST_N                   ( DEVRST_N ),
        .MMUART_0_RXD_F2M           ( MMUART_0_RXD_F2M ),
        .M3_RESET_N                 ( M3_RESET_N ),
        .PREADYS1                   ( PREADYS1 ),
        .PSLVERRS1                  ( PSLVERRS1 ),
        .AMBA_MASTER_0_HADDR_M0     ( AMBA_MASTER_0_HADDR_M0 ),
        .AMBA_MASTER_0_HTRANS_M0    ( AMBA_MASTER_0_HTRANS_M0 ),
        .AMBA_MASTER_0_HSIZE_M0     ( AMBA_MASTER_0_HSIZE_M0 ),
        .AMBA_MASTER_0_HBURST_M0    ( AMBA_MASTER_0_HBURST_M0 ),
        .AMBA_MASTER_0_HPROT_M0     ( AMBA_MASTER_0_HPROT_M0 ),
        .AMBA_MASTER_0_HWDATA_M0    ( AMBA_MASTER_0_HWDATA_M0 ),
        .PRDATAS1                   ( PRDATAS1 ),
        // Outputs
        .POWER_ON_RESET_N           ( POWER_ON_RESET_N_net_0 ),
        .INIT_DONE                  ( INIT_DONE_net_0 ),
        .FIC_0_CLK                  ( FIC_0_CLK_0 ),
        .FIC_0_LOCK                 ( FIC_0_LOCK_0 ),
        .MSS_READY                  ( MSS_READY_net_0 ),
        .AMBA_MASTER_0_HREADY_M0    ( AMBA_MASTER_0_HREADY ),
        .MMUART_0_TXD_M2F           ( MMUART_0_TXD_M2F_net_0 ),
        .GL1                        ( GL1_net_0 ),
        .PSELS1                     ( AMBA_SLAVE_0_10_PSELx ),
        .PENABLES                   ( AMBA_SLAVE_0_10_PENABLE ),
        .PWRITES                    ( AMBA_SLAVE_0_10_PWRITE ),
        .AMBA_MASTER_0_HRDATA_M0    ( AMBA_MASTER_0_HRDATA ),
        .AMBA_MASTER_0_HRESP_M0     ( AMBA_MASTER_0_HRESP ),
        .PADDRS                     ( AMBA_SLAVE_0_10_PADDR ),
        .PWDATAS                    ( AMBA_SLAVE_0_10_PWDATA ) 
        );


endmodule
