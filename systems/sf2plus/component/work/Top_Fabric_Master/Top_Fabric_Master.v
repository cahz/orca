//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Wed Jun 28 14:26:04 2017
// Version: v11.7 SP3 11.7.3.8
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// Top_Fabric_Master
module Top_Fabric_Master(
    // Inputs
    DEVRST_N,
    RX,
    // Outputs
    TX
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  DEVRST_N;
input  RX;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output TX;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire          axi_to_apb_0_APB_SLAVE_PENABLE;
wire          axi_to_apb_0_APB_SLAVE_PREADY;
wire          axi_to_apb_0_APB_SLAVE_PSELx;
wire          axi_to_apb_0_APB_SLAVE_PSLVERR;
wire          axi_to_apb_0_APB_SLAVE_PWRITE;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave0_ARADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave0_ARBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_ARCACHE;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave0_ARLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave0_ARPROT;
wire          CoreAXI4Interconnect_0_AXI3mslave0_ARREADY;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave0_ARSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave0_ARUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave0_ARVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave0_AWADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave0_AWBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_AWCACHE;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave0_AWLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave0_AWPROT;
wire          CoreAXI4Interconnect_0_AXI3mslave0_AWREADY;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave0_AWSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave0_AWUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave0_AWVALID;
wire          CoreAXI4Interconnect_0_AXI3mslave0_BREADY;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave0_BRESP;
wire          CoreAXI4Interconnect_0_AXI3mslave0_BVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave0_RDATA;
wire          CoreAXI4Interconnect_0_AXI3mslave0_RLAST;
wire          CoreAXI4Interconnect_0_AXI3mslave0_RREADY;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave0_RRESP;
wire          CoreAXI4Interconnect_0_AXI3mslave0_RVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave0_WDATA;
wire          CoreAXI4Interconnect_0_AXI3mslave0_WLAST;
wire          CoreAXI4Interconnect_0_AXI3mslave0_WREADY;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_WSTRB;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave0_WUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave0_WVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave1_ARADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave1_ARBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave1_ARCACHE;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave1_ARID;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave1_ARLEN;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave1_ARLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave1_ARPROT;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave1_ARSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave1_ARUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave1_ARVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave1_AWADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave1_AWBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave1_AWCACHE;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave1_AWID;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave1_AWLEN;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave1_AWLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave1_AWPROT;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave1_AWSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave1_AWUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave1_AWVALID;
wire          CoreAXI4Interconnect_0_AXI3mslave1_BREADY;
wire          CoreAXI4Interconnect_0_AXI3mslave1_RREADY;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave1_WDATA;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave1_WID;
wire          CoreAXI4Interconnect_0_AXI3mslave1_WLAST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave1_WSTRB;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave1_WUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave1_WVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave2_ARADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave2_ARBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave2_ARCACHE;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave2_ARID;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave2_ARLEN;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave2_ARLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave2_ARPROT;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave2_ARSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave2_ARUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave2_ARVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave2_AWADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave2_AWBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave2_AWCACHE;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave2_AWID;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave2_AWLEN;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave2_AWLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave2_AWPROT;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave2_AWSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave2_AWUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave2_AWVALID;
wire          CoreAXI4Interconnect_0_AXI3mslave2_BREADY;
wire          CoreAXI4Interconnect_0_AXI3mslave2_RREADY;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave2_WDATA;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave2_WID;
wire          CoreAXI4Interconnect_0_AXI3mslave2_WLAST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave2_WSTRB;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave2_WUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave2_WVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave3_ARADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave3_ARBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_ARCACHE;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave3_ARLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave3_ARPROT;
wire          CoreAXI4Interconnect_0_AXI3mslave3_ARREADY;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave3_ARSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave3_ARUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave3_ARVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave3_AWADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave3_AWBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_AWCACHE;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave3_AWLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave3_AWPROT;
wire          CoreAXI4Interconnect_0_AXI3mslave3_AWREADY;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave3_AWSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave3_AWUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave3_AWVALID;
wire          CoreAXI4Interconnect_0_AXI3mslave3_BREADY;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave3_BRESP;
wire          CoreAXI4Interconnect_0_AXI3mslave3_BVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave3_RDATA;
wire          CoreAXI4Interconnect_0_AXI3mslave3_RLAST;
wire          CoreAXI4Interconnect_0_AXI3mslave3_RREADY;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave3_RRESP;
wire          CoreAXI4Interconnect_0_AXI3mslave3_RVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave3_WDATA;
wire          CoreAXI4Interconnect_0_AXI3mslave3_WLAST;
wire          CoreAXI4Interconnect_0_AXI3mslave3_WREADY;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_WSTRB;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave3_WUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave3_WVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave4_ARADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave4_ARBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave4_ARCACHE;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave4_ARID;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave4_ARLEN;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave4_ARLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave4_ARPROT;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave4_ARSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave4_ARUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave4_ARVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave4_AWADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave4_AWBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave4_AWCACHE;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave4_AWID;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave4_AWLEN;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave4_AWLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave4_AWPROT;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave4_AWSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave4_AWUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave4_AWVALID;
wire          CoreAXI4Interconnect_0_AXI3mslave4_BREADY;
wire          CoreAXI4Interconnect_0_AXI3mslave4_RREADY;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave4_WDATA;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave4_WID;
wire          CoreAXI4Interconnect_0_AXI3mslave4_WLAST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave4_WSTRB;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave4_WUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave4_WVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave5_ARADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave5_ARBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave5_ARCACHE;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave5_ARID;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave5_ARLEN;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave5_ARLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave5_ARPROT;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave5_ARSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave5_ARUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave5_ARVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave5_AWADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave5_AWBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave5_AWCACHE;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave5_AWID;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave5_AWLEN;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave5_AWLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave5_AWPROT;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave5_AWSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave5_AWUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave5_AWVALID;
wire          CoreAXI4Interconnect_0_AXI3mslave5_BREADY;
wire          CoreAXI4Interconnect_0_AXI3mslave5_RREADY;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave5_WDATA;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave5_WID;
wire          CoreAXI4Interconnect_0_AXI3mslave5_WLAST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave5_WSTRB;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave5_WUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave5_WVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave6_ARADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave6_ARBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave6_ARCACHE;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave6_ARID;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave6_ARLEN;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave6_ARLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave6_ARPROT;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave6_ARSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave6_ARUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave6_ARVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave6_AWADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave6_AWBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave6_AWCACHE;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave6_AWID;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave6_AWLEN;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave6_AWLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave6_AWPROT;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave6_AWSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave6_AWUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave6_AWVALID;
wire          CoreAXI4Interconnect_0_AXI3mslave6_BREADY;
wire          CoreAXI4Interconnect_0_AXI3mslave6_RREADY;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave6_WDATA;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave6_WID;
wire          CoreAXI4Interconnect_0_AXI3mslave6_WLAST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave6_WSTRB;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave6_WUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave6_WVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave7_ARADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave7_ARBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_ARCACHE;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave7_ARLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave7_ARPROT;
wire          CoreAXI4Interconnect_0_AXI3mslave7_ARREADY;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave7_ARSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave7_ARUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave7_ARVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave7_AWADDR;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave7_AWBURST;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_AWCACHE;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave7_AWLOCK;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave7_AWPROT;
wire          CoreAXI4Interconnect_0_AXI3mslave7_AWREADY;
wire   [2:0]  CoreAXI4Interconnect_0_AXI3mslave7_AWSIZE;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave7_AWUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave7_AWVALID;
wire          CoreAXI4Interconnect_0_AXI3mslave7_BREADY;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave7_BRESP;
wire          CoreAXI4Interconnect_0_AXI3mslave7_BVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave7_RDATA;
wire          CoreAXI4Interconnect_0_AXI3mslave7_RLAST;
wire          CoreAXI4Interconnect_0_AXI3mslave7_RREADY;
wire   [1:0]  CoreAXI4Interconnect_0_AXI3mslave7_RRESP;
wire          CoreAXI4Interconnect_0_AXI3mslave7_RVALID;
wire   [31:0] CoreAXI4Interconnect_0_AXI3mslave7_WDATA;
wire          CoreAXI4Interconnect_0_AXI3mslave7_WLAST;
wire          CoreAXI4Interconnect_0_AXI3mslave7_WREADY;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_WSTRB;
wire   [0:0]  CoreAXI4Interconnect_0_AXI3mslave7_WUSER;
wire          CoreAXI4Interconnect_0_AXI3mslave7_WVALID;
wire          DEVRST_N;
wire   [31:0] fabric_master_0_BIF_1_HADDR;
wire   [2:0]  fabric_master_0_BIF_1_HBURST;
wire   [3:0]  fabric_master_0_BIF_1_HPROT;
wire   [31:0] fabric_master_0_BIF_1_HRDATA;
wire          fabric_master_0_BIF_1_HREADY;
wire   [1:0]  fabric_master_0_BIF_1_HRESP;
wire   [2:0]  fabric_master_0_BIF_1_HSIZE;
wire   [1:0]  fabric_master_0_BIF_1_HTRANS;
wire   [31:0] fabric_master_0_BIF_1_HWDATA;
wire          fabric_master_0_BIF_1_HWRITE;
wire   [31:0] microsemi_wrapper_0_DATA_MASTER_ARADDR;
wire   [1:0]  microsemi_wrapper_0_DATA_MASTER_ARBURST;
wire   [3:0]  microsemi_wrapper_0_DATA_MASTER_ARCACHE;
wire   [3:0]  microsemi_wrapper_0_DATA_MASTER_ARID;
wire   [1:0]  microsemi_wrapper_0_DATA_MASTER_ARLOCK;
wire   [2:0]  microsemi_wrapper_0_DATA_MASTER_ARPROT;
wire          microsemi_wrapper_0_DATA_MASTER_ARREADY;
wire   [2:0]  microsemi_wrapper_0_DATA_MASTER_ARSIZE;
wire          microsemi_wrapper_0_DATA_MASTER_ARVALID;
wire   [31:0] microsemi_wrapper_0_DATA_MASTER_AWADDR;
wire   [1:0]  microsemi_wrapper_0_DATA_MASTER_AWBURST;
wire   [3:0]  microsemi_wrapper_0_DATA_MASTER_AWCACHE;
wire   [3:0]  microsemi_wrapper_0_DATA_MASTER_AWID;
wire   [1:0]  microsemi_wrapper_0_DATA_MASTER_AWLOCK;
wire   [2:0]  microsemi_wrapper_0_DATA_MASTER_AWPROT;
wire          microsemi_wrapper_0_DATA_MASTER_AWREADY;
wire   [2:0]  microsemi_wrapper_0_DATA_MASTER_AWSIZE;
wire          microsemi_wrapper_0_DATA_MASTER_AWVALID;
wire   [3:0]  microsemi_wrapper_0_DATA_MASTER_BID;
wire          microsemi_wrapper_0_DATA_MASTER_BREADY;
wire   [1:0]  microsemi_wrapper_0_DATA_MASTER_BRESP;
wire   [0:0]  microsemi_wrapper_0_DATA_MASTER_BUSER;
wire          microsemi_wrapper_0_DATA_MASTER_BVALID;
wire   [31:0] microsemi_wrapper_0_DATA_MASTER_RDATA;
wire   [3:0]  microsemi_wrapper_0_DATA_MASTER_RID;
wire          microsemi_wrapper_0_DATA_MASTER_RLAST;
wire          microsemi_wrapper_0_DATA_MASTER_RREADY;
wire   [1:0]  microsemi_wrapper_0_DATA_MASTER_RRESP;
wire   [0:0]  microsemi_wrapper_0_DATA_MASTER_RUSER;
wire          microsemi_wrapper_0_DATA_MASTER_RVALID;
wire   [31:0] microsemi_wrapper_0_DATA_MASTER_WDATA;
wire   [3:0]  microsemi_wrapper_0_DATA_MASTER_WID;
wire          microsemi_wrapper_0_DATA_MASTER_WLAST;
wire          microsemi_wrapper_0_DATA_MASTER_WREADY;
wire   [3:0]  microsemi_wrapper_0_DATA_MASTER_WSTRB;
wire          microsemi_wrapper_0_DATA_MASTER_WVALID;
wire   [31:0] my_mss_top_0_AMBA_SLAVE_0_0_PADDR;
wire          my_mss_top_0_AMBA_SLAVE_0_0_PENABLE;
wire   [31:0] my_mss_top_0_AMBA_SLAVE_0_0_PRDATA;
wire          my_mss_top_0_AMBA_SLAVE_0_0_PREADY;
wire          my_mss_top_0_AMBA_SLAVE_0_0_PSELx;
wire   [31:0] my_mss_top_0_AMBA_SLAVE_0_0_PWDATA;
wire          my_mss_top_0_AMBA_SLAVE_0_0_PWRITE;
wire          my_mss_top_0_FIC_0_CLK_1;
wire          my_mss_top_0_GL1;
wire          my_mss_top_0_MSS_READY_0;
wire          RX;
wire          TX_net_0;
wire          TX_net_1;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire          VCC_net;
wire          GND_net;
wire   [3:0]  MASTER0_AWREGION_const_net_0;
wire   [3:0]  MASTER0_AWQOS_const_net_0;
wire   [3:0]  MASTER0_ARREGION_const_net_0;
wire   [3:0]  MASTER0_ARQOS_const_net_0;
wire   [3:0]  MASTER1_ARREGION_const_net_0;
wire   [31:0] MASTER0_HADDR_const_net_0;
wire   [2:0]  MASTER0_HBURST_const_net_0;
wire   [6:0]  MASTER0_HPROT_const_net_0;
wire   [2:0]  MASTER0_HSIZE_const_net_0;
wire   [1:0]  MASTER0_HTRANS_const_net_0;
wire   [31:0] MASTER0_HWDATA_const_net_0;
wire   [31:0] MASTER1_HADDR_const_net_0;
wire   [2:0]  MASTER1_HBURST_const_net_0;
wire   [6:0]  MASTER1_HPROT_const_net_0;
wire   [2:0]  MASTER1_HSIZE_const_net_0;
wire   [1:0]  MASTER1_HTRANS_const_net_0;
wire   [31:0] MASTER1_HWDATA_const_net_0;
wire   [31:0] MASTER2_HADDR_const_net_0;
wire   [2:0]  MASTER2_HBURST_const_net_0;
wire   [6:0]  MASTER2_HPROT_const_net_0;
wire   [2:0]  MASTER2_HSIZE_const_net_0;
wire   [1:0]  MASTER2_HTRANS_const_net_0;
wire   [31:0] MASTER2_HWDATA_const_net_0;
wire   [31:0] MASTER3_HADDR_const_net_0;
wire   [2:0]  MASTER3_HBURST_const_net_0;
wire   [6:0]  MASTER3_HPROT_const_net_0;
wire   [2:0]  MASTER3_HSIZE_const_net_0;
wire   [1:0]  MASTER3_HTRANS_const_net_0;
wire   [31:0] MASTER3_HWDATA_const_net_0;
wire   [31:0] MASTER4_HADDR_const_net_0;
wire   [2:0]  MASTER4_HBURST_const_net_0;
wire   [6:0]  MASTER4_HPROT_const_net_0;
wire   [2:0]  MASTER4_HSIZE_const_net_0;
wire   [1:0]  MASTER4_HTRANS_const_net_0;
wire   [31:0] MASTER4_HWDATA_const_net_0;
wire   [31:0] MASTER5_HADDR_const_net_0;
wire   [2:0]  MASTER5_HBURST_const_net_0;
wire   [6:0]  MASTER5_HPROT_const_net_0;
wire   [2:0]  MASTER5_HSIZE_const_net_0;
wire   [1:0]  MASTER5_HTRANS_const_net_0;
wire   [31:0] MASTER5_HWDATA_const_net_0;
wire   [31:0] MASTER6_HADDR_const_net_0;
wire   [2:0]  MASTER6_HBURST_const_net_0;
wire   [6:0]  MASTER6_HPROT_const_net_0;
wire   [2:0]  MASTER6_HSIZE_const_net_0;
wire   [1:0]  MASTER6_HTRANS_const_net_0;
wire   [31:0] MASTER6_HWDATA_const_net_0;
wire   [31:0] MASTER7_HADDR_const_net_0;
wire   [2:0]  MASTER7_HBURST_const_net_0;
wire   [6:0]  MASTER7_HPROT_const_net_0;
wire   [2:0]  MASTER7_HSIZE_const_net_0;
wire   [1:0]  MASTER7_HTRANS_const_net_0;
wire   [31:0] MASTER7_HWDATA_const_net_0;
wire   [4:0]  SLAVE1_BID_const_net_0;
wire   [1:0]  SLAVE1_BRESP_const_net_0;
wire   [4:0]  SLAVE1_RID_const_net_0;
wire   [31:0] SLAVE1_RDATA_const_net_0;
wire   [1:0]  SLAVE1_RRESP_const_net_0;
wire   [4:0]  SLAVE2_BID_const_net_0;
wire   [1:0]  SLAVE2_BRESP_const_net_0;
wire   [4:0]  SLAVE2_RID_const_net_0;
wire   [31:0] SLAVE2_RDATA_const_net_0;
wire   [1:0]  SLAVE2_RRESP_const_net_0;
wire   [4:0]  SLAVE4_BID_const_net_0;
wire   [1:0]  SLAVE4_BRESP_const_net_0;
wire   [4:0]  SLAVE4_RID_const_net_0;
wire   [31:0] SLAVE4_RDATA_const_net_0;
wire   [1:0]  SLAVE4_RRESP_const_net_0;
wire   [4:0]  SLAVE5_BID_const_net_0;
wire   [1:0]  SLAVE5_BRESP_const_net_0;
wire   [4:0]  SLAVE5_RID_const_net_0;
wire   [31:0] SLAVE5_RDATA_const_net_0;
wire   [1:0]  SLAVE5_RRESP_const_net_0;
wire   [4:0]  SLAVE6_BID_const_net_0;
wire   [1:0]  SLAVE6_BRESP_const_net_0;
wire   [4:0]  SLAVE6_RID_const_net_0;
wire   [31:0] SLAVE6_RDATA_const_net_0;
wire   [1:0]  SLAVE6_RRESP_const_net_0;
wire   [4:0]  SLAVE8_BID_const_net_0;
wire   [1:0]  SLAVE8_BRESP_const_net_0;
wire   [4:0]  SLAVE8_RID_const_net_0;
wire   [31:0] SLAVE8_RDATA_const_net_0;
wire   [1:0]  SLAVE8_RRESP_const_net_0;
wire   [4:0]  SLAVE9_BID_const_net_0;
wire   [1:0]  SLAVE9_BRESP_const_net_0;
wire   [4:0]  SLAVE9_RID_const_net_0;
wire   [31:0] SLAVE9_RDATA_const_net_0;
wire   [1:0]  SLAVE9_RRESP_const_net_0;
wire   [4:0]  SLAVE10_BID_const_net_0;
wire   [1:0]  SLAVE10_BRESP_const_net_0;
wire   [4:0]  SLAVE10_RID_const_net_0;
wire   [31:0] SLAVE10_RDATA_const_net_0;
wire   [1:0]  SLAVE10_RRESP_const_net_0;
wire   [4:0]  SLAVE11_BID_const_net_0;
wire   [1:0]  SLAVE11_BRESP_const_net_0;
wire   [4:0]  SLAVE11_RID_const_net_0;
wire   [31:0] SLAVE11_RDATA_const_net_0;
wire   [1:0]  SLAVE11_RRESP_const_net_0;
wire   [4:0]  SLAVE12_BID_const_net_0;
wire   [1:0]  SLAVE12_BRESP_const_net_0;
wire   [4:0]  SLAVE12_RID_const_net_0;
wire   [31:0] SLAVE12_RDATA_const_net_0;
wire   [1:0]  SLAVE12_RRESP_const_net_0;
wire   [4:0]  SLAVE13_BID_const_net_0;
wire   [1:0]  SLAVE13_BRESP_const_net_0;
wire   [4:0]  SLAVE13_RID_const_net_0;
wire   [31:0] SLAVE13_RDATA_const_net_0;
wire   [1:0]  SLAVE13_RRESP_const_net_0;
wire   [4:0]  SLAVE14_BID_const_net_0;
wire   [1:0]  SLAVE14_BRESP_const_net_0;
wire   [4:0]  SLAVE14_RID_const_net_0;
wire   [31:0] SLAVE14_RDATA_const_net_0;
wire   [1:0]  SLAVE14_RRESP_const_net_0;
wire   [4:0]  SLAVE15_BID_const_net_0;
wire   [1:0]  SLAVE15_BRESP_const_net_0;
wire   [4:0]  SLAVE15_RID_const_net_0;
wire   [31:0] SLAVE15_RDATA_const_net_0;
wire   [1:0]  SLAVE15_RRESP_const_net_0;
wire   [4:0]  SLAVE16_BID_const_net_0;
wire   [1:0]  SLAVE16_BRESP_const_net_0;
wire   [4:0]  SLAVE16_RID_const_net_0;
wire   [31:0] SLAVE16_RDATA_const_net_0;
wire   [1:0]  SLAVE16_RRESP_const_net_0;
wire   [4:0]  SLAVE17_BID_const_net_0;
wire   [1:0]  SLAVE17_BRESP_const_net_0;
wire   [4:0]  SLAVE17_RID_const_net_0;
wire   [31:0] SLAVE17_RDATA_const_net_0;
wire   [1:0]  SLAVE17_RRESP_const_net_0;
wire   [4:0]  SLAVE18_BID_const_net_0;
wire   [1:0]  SLAVE18_BRESP_const_net_0;
wire   [4:0]  SLAVE18_RID_const_net_0;
wire   [31:0] SLAVE18_RDATA_const_net_0;
wire   [1:0]  SLAVE18_RRESP_const_net_0;
wire   [4:0]  SLAVE19_BID_const_net_0;
wire   [1:0]  SLAVE19_BRESP_const_net_0;
wire   [4:0]  SLAVE19_RID_const_net_0;
wire   [31:0] SLAVE19_RDATA_const_net_0;
wire   [1:0]  SLAVE19_RRESP_const_net_0;
wire   [4:0]  SLAVE20_BID_const_net_0;
wire   [1:0]  SLAVE20_BRESP_const_net_0;
wire   [4:0]  SLAVE20_RID_const_net_0;
wire   [31:0] SLAVE20_RDATA_const_net_0;
wire   [1:0]  SLAVE20_RRESP_const_net_0;
wire   [4:0]  SLAVE21_BID_const_net_0;
wire   [1:0]  SLAVE21_BRESP_const_net_0;
wire   [4:0]  SLAVE21_RID_const_net_0;
wire   [31:0] SLAVE21_RDATA_const_net_0;
wire   [1:0]  SLAVE21_RRESP_const_net_0;
wire   [4:0]  SLAVE22_BID_const_net_0;
wire   [1:0]  SLAVE22_BRESP_const_net_0;
wire   [4:0]  SLAVE22_RID_const_net_0;
wire   [31:0] SLAVE22_RDATA_const_net_0;
wire   [1:0]  SLAVE22_RRESP_const_net_0;
wire   [4:0]  SLAVE23_BID_const_net_0;
wire   [1:0]  SLAVE23_BRESP_const_net_0;
wire   [4:0]  SLAVE23_RID_const_net_0;
wire   [31:0] SLAVE23_RDATA_const_net_0;
wire   [1:0]  SLAVE23_RRESP_const_net_0;
wire   [4:0]  SLAVE24_BID_const_net_0;
wire   [1:0]  SLAVE24_BRESP_const_net_0;
wire   [4:0]  SLAVE24_RID_const_net_0;
wire   [31:0] SLAVE24_RDATA_const_net_0;
wire   [1:0]  SLAVE24_RRESP_const_net_0;
wire   [4:0]  SLAVE25_BID_const_net_0;
wire   [1:0]  SLAVE25_BRESP_const_net_0;
wire   [4:0]  SLAVE25_RID_const_net_0;
wire   [31:0] SLAVE25_RDATA_const_net_0;
wire   [1:0]  SLAVE25_RRESP_const_net_0;
wire   [4:0]  SLAVE26_BID_const_net_0;
wire   [1:0]  SLAVE26_BRESP_const_net_0;
wire   [4:0]  SLAVE26_RID_const_net_0;
wire   [31:0] SLAVE26_RDATA_const_net_0;
wire   [1:0]  SLAVE26_RRESP_const_net_0;
wire   [4:0]  SLAVE27_BID_const_net_0;
wire   [1:0]  SLAVE27_BRESP_const_net_0;
wire   [4:0]  SLAVE27_RID_const_net_0;
wire   [31:0] SLAVE27_RDATA_const_net_0;
wire   [1:0]  SLAVE27_RRESP_const_net_0;
wire   [4:0]  SLAVE28_BID_const_net_0;
wire   [1:0]  SLAVE28_BRESP_const_net_0;
wire   [4:0]  SLAVE28_RID_const_net_0;
wire   [31:0] SLAVE28_RDATA_const_net_0;
wire   [1:0]  SLAVE28_RRESP_const_net_0;
wire   [4:0]  SLAVE29_BID_const_net_0;
wire   [1:0]  SLAVE29_BRESP_const_net_0;
wire   [4:0]  SLAVE29_RID_const_net_0;
wire   [31:0] SLAVE29_RDATA_const_net_0;
wire   [1:0]  SLAVE29_RRESP_const_net_0;
wire   [4:0]  SLAVE30_BID_const_net_0;
wire   [1:0]  SLAVE30_BRESP_const_net_0;
wire   [4:0]  SLAVE30_RID_const_net_0;
wire   [31:0] SLAVE30_RDATA_const_net_0;
wire   [1:0]  SLAVE30_RRESP_const_net_0;
wire   [4:0]  SLAVE31_BID_const_net_0;
wire   [1:0]  SLAVE31_BRESP_const_net_0;
wire   [4:0]  SLAVE31_RID_const_net_0;
wire   [31:0] SLAVE31_RDATA_const_net_0;
wire   [1:0]  SLAVE31_RRESP_const_net_0;
wire   [3:0]  MASTER1_AWID_const_net_0;
wire   [31:0] MASTER1_AWADDR_const_net_0;
wire   [7:0]  MASTER1_AWLEN_const_net_0;
wire   [2:0]  MASTER1_AWSIZE_const_net_0;
wire   [1:0]  MASTER1_AWBURST_const_net_0;
wire   [1:0]  MASTER1_AWLOCK_const_net_0;
wire   [3:0]  MASTER1_AWCACHE_const_net_0;
wire   [2:0]  MASTER1_AWPROT_const_net_0;
wire   [3:0]  MASTER1_AWQOS_const_net_0;
wire   [3:0]  MASTER1_AWREGION_const_net_0;
wire   [31:0] MASTER1_WDATA_const_net_0;
wire   [3:0]  MASTER1_WSTRB_const_net_0;
wire   [3:0]  MASTER1_ARID_const_net_0;
wire   [31:0] MASTER1_ARADDR_const_net_0;
wire   [7:0]  MASTER1_ARLEN_const_net_0;
wire   [2:0]  MASTER1_ARSIZE_const_net_0;
wire   [1:0]  MASTER1_ARBURST_const_net_0;
wire   [1:0]  MASTER1_ARLOCK_const_net_0;
wire   [3:0]  MASTER1_ARCACHE_const_net_0;
wire   [2:0]  MASTER1_ARPROT_const_net_0;
wire   [3:0]  MASTER1_ARQOS_const_net_0;
wire   [3:0]  MASTER2_AWID_const_net_0;
wire   [31:0] MASTER2_AWADDR_const_net_0;
wire   [7:0]  MASTER2_AWLEN_const_net_0;
wire   [2:0]  MASTER2_AWSIZE_const_net_0;
wire   [1:0]  MASTER2_AWBURST_const_net_0;
wire   [1:0]  MASTER2_AWLOCK_const_net_0;
wire   [3:0]  MASTER2_AWCACHE_const_net_0;
wire   [2:0]  MASTER2_AWPROT_const_net_0;
wire   [3:0]  MASTER2_AWQOS_const_net_0;
wire   [3:0]  MASTER2_AWREGION_const_net_0;
wire   [31:0] MASTER2_WDATA_const_net_0;
wire   [3:0]  MASTER2_WSTRB_const_net_0;
wire   [3:0]  MASTER2_ARID_const_net_0;
wire   [31:0] MASTER2_ARADDR_const_net_0;
wire   [7:0]  MASTER2_ARLEN_const_net_0;
wire   [2:0]  MASTER2_ARSIZE_const_net_0;
wire   [1:0]  MASTER2_ARBURST_const_net_0;
wire   [1:0]  MASTER2_ARLOCK_const_net_0;
wire   [3:0]  MASTER2_ARCACHE_const_net_0;
wire   [2:0]  MASTER2_ARPROT_const_net_0;
wire   [3:0]  MASTER2_ARQOS_const_net_0;
wire   [3:0]  MASTER2_ARREGION_const_net_0;
wire   [3:0]  MASTER3_AWID_const_net_0;
wire   [31:0] MASTER3_AWADDR_const_net_0;
wire   [7:0]  MASTER3_AWLEN_const_net_0;
wire   [2:0]  MASTER3_AWSIZE_const_net_0;
wire   [1:0]  MASTER3_AWBURST_const_net_0;
wire   [1:0]  MASTER3_AWLOCK_const_net_0;
wire   [3:0]  MASTER3_AWCACHE_const_net_0;
wire   [2:0]  MASTER3_AWPROT_const_net_0;
wire   [3:0]  MASTER3_AWQOS_const_net_0;
wire   [3:0]  MASTER3_AWREGION_const_net_0;
wire   [31:0] MASTER3_WDATA_const_net_0;
wire   [3:0]  MASTER3_WSTRB_const_net_0;
wire   [3:0]  MASTER3_ARID_const_net_0;
wire   [31:0] MASTER3_ARADDR_const_net_0;
wire   [7:0]  MASTER3_ARLEN_const_net_0;
wire   [2:0]  MASTER3_ARSIZE_const_net_0;
wire   [1:0]  MASTER3_ARBURST_const_net_0;
wire   [1:0]  MASTER3_ARLOCK_const_net_0;
wire   [3:0]  MASTER3_ARCACHE_const_net_0;
wire   [2:0]  MASTER3_ARPROT_const_net_0;
wire   [3:0]  MASTER3_ARQOS_const_net_0;
wire   [3:0]  MASTER3_ARREGION_const_net_0;
wire   [3:0]  MASTER4_AWID_const_net_0;
wire   [31:0] MASTER4_AWADDR_const_net_0;
wire   [7:0]  MASTER4_AWLEN_const_net_0;
wire   [2:0]  MASTER4_AWSIZE_const_net_0;
wire   [1:0]  MASTER4_AWBURST_const_net_0;
wire   [1:0]  MASTER4_AWLOCK_const_net_0;
wire   [3:0]  MASTER4_AWCACHE_const_net_0;
wire   [2:0]  MASTER4_AWPROT_const_net_0;
wire   [3:0]  MASTER4_AWQOS_const_net_0;
wire   [3:0]  MASTER4_AWREGION_const_net_0;
wire   [31:0] MASTER4_WDATA_const_net_0;
wire   [3:0]  MASTER4_WSTRB_const_net_0;
wire   [3:0]  MASTER4_ARID_const_net_0;
wire   [31:0] MASTER4_ARADDR_const_net_0;
wire   [7:0]  MASTER4_ARLEN_const_net_0;
wire   [2:0]  MASTER4_ARSIZE_const_net_0;
wire   [1:0]  MASTER4_ARBURST_const_net_0;
wire   [1:0]  MASTER4_ARLOCK_const_net_0;
wire   [3:0]  MASTER4_ARCACHE_const_net_0;
wire   [2:0]  MASTER4_ARPROT_const_net_0;
wire   [3:0]  MASTER4_ARQOS_const_net_0;
wire   [3:0]  MASTER4_ARREGION_const_net_0;
wire   [3:0]  MASTER5_AWID_const_net_0;
wire   [31:0] MASTER5_AWADDR_const_net_0;
wire   [7:0]  MASTER5_AWLEN_const_net_0;
wire   [2:0]  MASTER5_AWSIZE_const_net_0;
wire   [1:0]  MASTER5_AWBURST_const_net_0;
wire   [1:0]  MASTER5_AWLOCK_const_net_0;
wire   [3:0]  MASTER5_AWCACHE_const_net_0;
wire   [2:0]  MASTER5_AWPROT_const_net_0;
wire   [3:0]  MASTER5_AWQOS_const_net_0;
wire   [3:0]  MASTER5_AWREGION_const_net_0;
wire   [31:0] MASTER5_WDATA_const_net_0;
wire   [3:0]  MASTER5_WSTRB_const_net_0;
wire   [3:0]  MASTER5_ARID_const_net_0;
wire   [31:0] MASTER5_ARADDR_const_net_0;
wire   [7:0]  MASTER5_ARLEN_const_net_0;
wire   [2:0]  MASTER5_ARSIZE_const_net_0;
wire   [1:0]  MASTER5_ARBURST_const_net_0;
wire   [1:0]  MASTER5_ARLOCK_const_net_0;
wire   [3:0]  MASTER5_ARCACHE_const_net_0;
wire   [2:0]  MASTER5_ARPROT_const_net_0;
wire   [3:0]  MASTER5_ARQOS_const_net_0;
wire   [3:0]  MASTER5_ARREGION_const_net_0;
wire   [3:0]  MASTER6_AWID_const_net_0;
wire   [31:0] MASTER6_AWADDR_const_net_0;
wire   [7:0]  MASTER6_AWLEN_const_net_0;
wire   [2:0]  MASTER6_AWSIZE_const_net_0;
wire   [1:0]  MASTER6_AWBURST_const_net_0;
wire   [1:0]  MASTER6_AWLOCK_const_net_0;
wire   [3:0]  MASTER6_AWCACHE_const_net_0;
wire   [2:0]  MASTER6_AWPROT_const_net_0;
wire   [3:0]  MASTER6_AWQOS_const_net_0;
wire   [3:0]  MASTER6_AWREGION_const_net_0;
wire   [31:0] MASTER6_WDATA_const_net_0;
wire   [3:0]  MASTER6_WSTRB_const_net_0;
wire   [3:0]  MASTER6_ARID_const_net_0;
wire   [31:0] MASTER6_ARADDR_const_net_0;
wire   [7:0]  MASTER6_ARLEN_const_net_0;
wire   [2:0]  MASTER6_ARSIZE_const_net_0;
wire   [1:0]  MASTER6_ARBURST_const_net_0;
wire   [1:0]  MASTER6_ARLOCK_const_net_0;
wire   [3:0]  MASTER6_ARCACHE_const_net_0;
wire   [2:0]  MASTER6_ARPROT_const_net_0;
wire   [3:0]  MASTER6_ARQOS_const_net_0;
wire   [3:0]  MASTER6_ARREGION_const_net_0;
wire   [3:0]  MASTER7_AWID_const_net_0;
wire   [31:0] MASTER7_AWADDR_const_net_0;
wire   [7:0]  MASTER7_AWLEN_const_net_0;
wire   [2:0]  MASTER7_AWSIZE_const_net_0;
wire   [1:0]  MASTER7_AWBURST_const_net_0;
wire   [1:0]  MASTER7_AWLOCK_const_net_0;
wire   [3:0]  MASTER7_AWCACHE_const_net_0;
wire   [2:0]  MASTER7_AWPROT_const_net_0;
wire   [3:0]  MASTER7_AWQOS_const_net_0;
wire   [3:0]  MASTER7_AWREGION_const_net_0;
wire   [31:0] MASTER7_WDATA_const_net_0;
wire   [3:0]  MASTER7_WSTRB_const_net_0;
wire   [3:0]  MASTER7_ARID_const_net_0;
wire   [31:0] MASTER7_ARADDR_const_net_0;
wire   [7:0]  MASTER7_ARLEN_const_net_0;
wire   [2:0]  MASTER7_ARSIZE_const_net_0;
wire   [1:0]  MASTER7_ARBURST_const_net_0;
wire   [1:0]  MASTER7_ARLOCK_const_net_0;
wire   [3:0]  MASTER7_ARCACHE_const_net_0;
wire   [2:0]  MASTER7_ARPROT_const_net_0;
wire   [3:0]  MASTER7_ARQOS_const_net_0;
wire   [3:0]  MASTER7_ARREGION_const_net_0;
//--------------------------------------------------------------------
// Inverted Nets
//--------------------------------------------------------------------
wire          reset_IN_POST_INV0_0;
//--------------------------------------------------------------------
// Bus Interface Nets Declarations - Unequal Pin Widths
//--------------------------------------------------------------------
wire   [31:0] axi_to_apb_0_APB_SLAVE_PADDR;
wire   [4:0]  axi_to_apb_0_APB_SLAVE_PADDR_0_4to0;
wire   [4:0]  axi_to_apb_0_APB_SLAVE_PADDR_0;
wire   [31:8] axi_to_apb_0_APB_SLAVE_PRDATA_0_31to8;
wire   [7:0]  axi_to_apb_0_APB_SLAVE_PRDATA_0_7to0;
wire   [31:0] axi_to_apb_0_APB_SLAVE_PRDATA_0;
wire   [7:0]  axi_to_apb_0_APB_SLAVE_PRDATA;
wire   [31:0] axi_to_apb_0_APB_SLAVE_PWDATA;
wire   [7:0]  axi_to_apb_0_APB_SLAVE_PWDATA_0_7to0;
wire   [7:0]  axi_to_apb_0_APB_SLAVE_PWDATA_0;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave0_ARID;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_ARID_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_ARID_0;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave0_ARLEN;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_ARLEN_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_ARLEN_0;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave0_AWID;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_AWID_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_AWID_0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_AWLEN_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_AWLEN_0;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave0_AWLEN;
wire   [4:4]  CoreAXI4Interconnect_0_AXI3mslave0_BID_0_4to4;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_BID_0_3to0;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave0_BID_0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_BID;
wire   [4:4]  CoreAXI4Interconnect_0_AXI3mslave0_RID_0_4to4;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_RID_0_3to0;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave0_RID_0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_RID;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave0_WID;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_WID_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave0_WID_0;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave3_ARID;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_ARID_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_ARID_0;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave3_ARLEN;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_ARLEN_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_ARLEN_0;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave3_AWID;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_AWID_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_AWID_0;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave3_AWLEN;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_AWLEN_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_AWLEN_0;
wire   [4:4]  CoreAXI4Interconnect_0_AXI3mslave3_BID_0_4to4;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_BID_0_3to0;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave3_BID_0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_BID;
wire   [4:4]  CoreAXI4Interconnect_0_AXI3mslave3_RID_0_4to4;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_RID_0_3to0;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave3_RID_0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_RID;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave3_WID;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_WID_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave3_WID_0;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave7_ARID;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_ARID_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_ARID_0;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave7_ARLEN;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_ARLEN_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_ARLEN_0;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave7_AWID;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_AWID_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_AWID_0;
wire   [7:0]  CoreAXI4Interconnect_0_AXI3mslave7_AWLEN;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_AWLEN_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_AWLEN_0;
wire   [4:4]  CoreAXI4Interconnect_0_AXI3mslave7_BID_0_4to4;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_BID_0_3to0;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave7_BID_0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_BID;
wire   [4:4]  CoreAXI4Interconnect_0_AXI3mslave7_RID_0_4to4;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_RID_0_3to0;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave7_RID_0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_RID;
wire   [4:0]  CoreAXI4Interconnect_0_AXI3mslave7_WID;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_WID_0_3to0;
wire   [3:0]  CoreAXI4Interconnect_0_AXI3mslave7_WID_0;
wire   [7:4]  microsemi_wrapper_0_DATA_MASTER_ARLEN_0_7to4;
wire   [3:0]  microsemi_wrapper_0_DATA_MASTER_ARLEN_0_3to0;
wire   [7:0]  microsemi_wrapper_0_DATA_MASTER_ARLEN_0;
wire   [3:0]  microsemi_wrapper_0_DATA_MASTER_ARLEN;
wire   [7:4]  microsemi_wrapper_0_DATA_MASTER_AWLEN_0_7to4;
wire   [3:0]  microsemi_wrapper_0_DATA_MASTER_AWLEN_0_3to0;
wire   [7:0]  microsemi_wrapper_0_DATA_MASTER_AWLEN_0;
wire   [3:0]  microsemi_wrapper_0_DATA_MASTER_AWLEN;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign VCC_net                      = 1'b1;
assign GND_net                      = 1'b0;
assign MASTER0_AWREGION_const_net_0 = 4'h0;
assign MASTER0_AWQOS_const_net_0    = 4'h0;
assign MASTER0_ARREGION_const_net_0 = 4'h0;
assign MASTER0_ARQOS_const_net_0    = 4'h0;
assign MASTER1_ARREGION_const_net_0 = 4'h0;
assign MASTER0_HADDR_const_net_0    = 32'h00000000;
assign MASTER0_HBURST_const_net_0   = 3'h0;
assign MASTER0_HPROT_const_net_0    = 7'h00;
assign MASTER0_HSIZE_const_net_0    = 3'h0;
assign MASTER0_HTRANS_const_net_0   = 2'h0;
assign MASTER0_HWDATA_const_net_0   = 32'h00000000;
assign MASTER1_HADDR_const_net_0    = 32'h00000000;
assign MASTER1_HBURST_const_net_0   = 3'h0;
assign MASTER1_HPROT_const_net_0    = 7'h00;
assign MASTER1_HSIZE_const_net_0    = 3'h0;
assign MASTER1_HTRANS_const_net_0   = 2'h0;
assign MASTER1_HWDATA_const_net_0   = 32'h00000000;
assign MASTER2_HADDR_const_net_0    = 32'h00000000;
assign MASTER2_HBURST_const_net_0   = 3'h0;
assign MASTER2_HPROT_const_net_0    = 7'h00;
assign MASTER2_HSIZE_const_net_0    = 3'h0;
assign MASTER2_HTRANS_const_net_0   = 2'h0;
assign MASTER2_HWDATA_const_net_0   = 32'h00000000;
assign MASTER3_HADDR_const_net_0    = 32'h00000000;
assign MASTER3_HBURST_const_net_0   = 3'h0;
assign MASTER3_HPROT_const_net_0    = 7'h00;
assign MASTER3_HSIZE_const_net_0    = 3'h0;
assign MASTER3_HTRANS_const_net_0   = 2'h0;
assign MASTER3_HWDATA_const_net_0   = 32'h00000000;
assign MASTER4_HADDR_const_net_0    = 32'h00000000;
assign MASTER4_HBURST_const_net_0   = 3'h0;
assign MASTER4_HPROT_const_net_0    = 7'h00;
assign MASTER4_HSIZE_const_net_0    = 3'h0;
assign MASTER4_HTRANS_const_net_0   = 2'h0;
assign MASTER4_HWDATA_const_net_0   = 32'h00000000;
assign MASTER5_HADDR_const_net_0    = 32'h00000000;
assign MASTER5_HBURST_const_net_0   = 3'h0;
assign MASTER5_HPROT_const_net_0    = 7'h00;
assign MASTER5_HSIZE_const_net_0    = 3'h0;
assign MASTER5_HTRANS_const_net_0   = 2'h0;
assign MASTER5_HWDATA_const_net_0   = 32'h00000000;
assign MASTER6_HADDR_const_net_0    = 32'h00000000;
assign MASTER6_HBURST_const_net_0   = 3'h0;
assign MASTER6_HPROT_const_net_0    = 7'h00;
assign MASTER6_HSIZE_const_net_0    = 3'h0;
assign MASTER6_HTRANS_const_net_0   = 2'h0;
assign MASTER6_HWDATA_const_net_0   = 32'h00000000;
assign MASTER7_HADDR_const_net_0    = 32'h00000000;
assign MASTER7_HBURST_const_net_0   = 3'h0;
assign MASTER7_HPROT_const_net_0    = 7'h00;
assign MASTER7_HSIZE_const_net_0    = 3'h0;
assign MASTER7_HTRANS_const_net_0   = 2'h0;
assign MASTER7_HWDATA_const_net_0   = 32'h00000000;
assign SLAVE1_BID_const_net_0       = 5'h00;
assign SLAVE1_BRESP_const_net_0     = 2'h0;
assign SLAVE1_RID_const_net_0       = 5'h00;
assign SLAVE1_RDATA_const_net_0     = 32'h00000000;
assign SLAVE1_RRESP_const_net_0     = 2'h0;
assign SLAVE2_BID_const_net_0       = 5'h00;
assign SLAVE2_BRESP_const_net_0     = 2'h0;
assign SLAVE2_RID_const_net_0       = 5'h00;
assign SLAVE2_RDATA_const_net_0     = 32'h00000000;
assign SLAVE2_RRESP_const_net_0     = 2'h0;
assign SLAVE4_BID_const_net_0       = 5'h00;
assign SLAVE4_BRESP_const_net_0     = 2'h0;
assign SLAVE4_RID_const_net_0       = 5'h00;
assign SLAVE4_RDATA_const_net_0     = 32'h00000000;
assign SLAVE4_RRESP_const_net_0     = 2'h0;
assign SLAVE5_BID_const_net_0       = 5'h00;
assign SLAVE5_BRESP_const_net_0     = 2'h0;
assign SLAVE5_RID_const_net_0       = 5'h00;
assign SLAVE5_RDATA_const_net_0     = 32'h00000000;
assign SLAVE5_RRESP_const_net_0     = 2'h0;
assign SLAVE6_BID_const_net_0       = 5'h00;
assign SLAVE6_BRESP_const_net_0     = 2'h0;
assign SLAVE6_RID_const_net_0       = 5'h00;
assign SLAVE6_RDATA_const_net_0     = 32'h00000000;
assign SLAVE6_RRESP_const_net_0     = 2'h0;
assign SLAVE8_BID_const_net_0       = 5'h00;
assign SLAVE8_BRESP_const_net_0     = 2'h0;
assign SLAVE8_RID_const_net_0       = 5'h00;
assign SLAVE8_RDATA_const_net_0     = 32'h00000000;
assign SLAVE8_RRESP_const_net_0     = 2'h0;
assign SLAVE9_BID_const_net_0       = 5'h00;
assign SLAVE9_BRESP_const_net_0     = 2'h0;
assign SLAVE9_RID_const_net_0       = 5'h00;
assign SLAVE9_RDATA_const_net_0     = 32'h00000000;
assign SLAVE9_RRESP_const_net_0     = 2'h0;
assign SLAVE10_BID_const_net_0      = 5'h00;
assign SLAVE10_BRESP_const_net_0    = 2'h0;
assign SLAVE10_RID_const_net_0      = 5'h00;
assign SLAVE10_RDATA_const_net_0    = 32'h00000000;
assign SLAVE10_RRESP_const_net_0    = 2'h0;
assign SLAVE11_BID_const_net_0      = 5'h00;
assign SLAVE11_BRESP_const_net_0    = 2'h0;
assign SLAVE11_RID_const_net_0      = 5'h00;
assign SLAVE11_RDATA_const_net_0    = 32'h00000000;
assign SLAVE11_RRESP_const_net_0    = 2'h0;
assign SLAVE12_BID_const_net_0      = 5'h00;
assign SLAVE12_BRESP_const_net_0    = 2'h0;
assign SLAVE12_RID_const_net_0      = 5'h00;
assign SLAVE12_RDATA_const_net_0    = 32'h00000000;
assign SLAVE12_RRESP_const_net_0    = 2'h0;
assign SLAVE13_BID_const_net_0      = 5'h00;
assign SLAVE13_BRESP_const_net_0    = 2'h0;
assign SLAVE13_RID_const_net_0      = 5'h00;
assign SLAVE13_RDATA_const_net_0    = 32'h00000000;
assign SLAVE13_RRESP_const_net_0    = 2'h0;
assign SLAVE14_BID_const_net_0      = 5'h00;
assign SLAVE14_BRESP_const_net_0    = 2'h0;
assign SLAVE14_RID_const_net_0      = 5'h00;
assign SLAVE14_RDATA_const_net_0    = 32'h00000000;
assign SLAVE14_RRESP_const_net_0    = 2'h0;
assign SLAVE15_BID_const_net_0      = 5'h00;
assign SLAVE15_BRESP_const_net_0    = 2'h0;
assign SLAVE15_RID_const_net_0      = 5'h00;
assign SLAVE15_RDATA_const_net_0    = 32'h00000000;
assign SLAVE15_RRESP_const_net_0    = 2'h0;
assign SLAVE16_BID_const_net_0      = 5'h00;
assign SLAVE16_BRESP_const_net_0    = 2'h0;
assign SLAVE16_RID_const_net_0      = 5'h00;
assign SLAVE16_RDATA_const_net_0    = 32'h00000000;
assign SLAVE16_RRESP_const_net_0    = 2'h0;
assign SLAVE17_BID_const_net_0      = 5'h00;
assign SLAVE17_BRESP_const_net_0    = 2'h0;
assign SLAVE17_RID_const_net_0      = 5'h00;
assign SLAVE17_RDATA_const_net_0    = 32'h00000000;
assign SLAVE17_RRESP_const_net_0    = 2'h0;
assign SLAVE18_BID_const_net_0      = 5'h00;
assign SLAVE18_BRESP_const_net_0    = 2'h0;
assign SLAVE18_RID_const_net_0      = 5'h00;
assign SLAVE18_RDATA_const_net_0    = 32'h00000000;
assign SLAVE18_RRESP_const_net_0    = 2'h0;
assign SLAVE19_BID_const_net_0      = 5'h00;
assign SLAVE19_BRESP_const_net_0    = 2'h0;
assign SLAVE19_RID_const_net_0      = 5'h00;
assign SLAVE19_RDATA_const_net_0    = 32'h00000000;
assign SLAVE19_RRESP_const_net_0    = 2'h0;
assign SLAVE20_BID_const_net_0      = 5'h00;
assign SLAVE20_BRESP_const_net_0    = 2'h0;
assign SLAVE20_RID_const_net_0      = 5'h00;
assign SLAVE20_RDATA_const_net_0    = 32'h00000000;
assign SLAVE20_RRESP_const_net_0    = 2'h0;
assign SLAVE21_BID_const_net_0      = 5'h00;
assign SLAVE21_BRESP_const_net_0    = 2'h0;
assign SLAVE21_RID_const_net_0      = 5'h00;
assign SLAVE21_RDATA_const_net_0    = 32'h00000000;
assign SLAVE21_RRESP_const_net_0    = 2'h0;
assign SLAVE22_BID_const_net_0      = 5'h00;
assign SLAVE22_BRESP_const_net_0    = 2'h0;
assign SLAVE22_RID_const_net_0      = 5'h00;
assign SLAVE22_RDATA_const_net_0    = 32'h00000000;
assign SLAVE22_RRESP_const_net_0    = 2'h0;
assign SLAVE23_BID_const_net_0      = 5'h00;
assign SLAVE23_BRESP_const_net_0    = 2'h0;
assign SLAVE23_RID_const_net_0      = 5'h00;
assign SLAVE23_RDATA_const_net_0    = 32'h00000000;
assign SLAVE23_RRESP_const_net_0    = 2'h0;
assign SLAVE24_BID_const_net_0      = 5'h00;
assign SLAVE24_BRESP_const_net_0    = 2'h0;
assign SLAVE24_RID_const_net_0      = 5'h00;
assign SLAVE24_RDATA_const_net_0    = 32'h00000000;
assign SLAVE24_RRESP_const_net_0    = 2'h0;
assign SLAVE25_BID_const_net_0      = 5'h00;
assign SLAVE25_BRESP_const_net_0    = 2'h0;
assign SLAVE25_RID_const_net_0      = 5'h00;
assign SLAVE25_RDATA_const_net_0    = 32'h00000000;
assign SLAVE25_RRESP_const_net_0    = 2'h0;
assign SLAVE26_BID_const_net_0      = 5'h00;
assign SLAVE26_BRESP_const_net_0    = 2'h0;
assign SLAVE26_RID_const_net_0      = 5'h00;
assign SLAVE26_RDATA_const_net_0    = 32'h00000000;
assign SLAVE26_RRESP_const_net_0    = 2'h0;
assign SLAVE27_BID_const_net_0      = 5'h00;
assign SLAVE27_BRESP_const_net_0    = 2'h0;
assign SLAVE27_RID_const_net_0      = 5'h00;
assign SLAVE27_RDATA_const_net_0    = 32'h00000000;
assign SLAVE27_RRESP_const_net_0    = 2'h0;
assign SLAVE28_BID_const_net_0      = 5'h00;
assign SLAVE28_BRESP_const_net_0    = 2'h0;
assign SLAVE28_RID_const_net_0      = 5'h00;
assign SLAVE28_RDATA_const_net_0    = 32'h00000000;
assign SLAVE28_RRESP_const_net_0    = 2'h0;
assign SLAVE29_BID_const_net_0      = 5'h00;
assign SLAVE29_BRESP_const_net_0    = 2'h0;
assign SLAVE29_RID_const_net_0      = 5'h00;
assign SLAVE29_RDATA_const_net_0    = 32'h00000000;
assign SLAVE29_RRESP_const_net_0    = 2'h0;
assign SLAVE30_BID_const_net_0      = 5'h00;
assign SLAVE30_BRESP_const_net_0    = 2'h0;
assign SLAVE30_RID_const_net_0      = 5'h00;
assign SLAVE30_RDATA_const_net_0    = 32'h00000000;
assign SLAVE30_RRESP_const_net_0    = 2'h0;
assign SLAVE31_BID_const_net_0      = 5'h00;
assign SLAVE31_BRESP_const_net_0    = 2'h0;
assign SLAVE31_RID_const_net_0      = 5'h00;
assign SLAVE31_RDATA_const_net_0    = 32'h00000000;
assign SLAVE31_RRESP_const_net_0    = 2'h0;
assign MASTER1_AWID_const_net_0     = 4'h0;
assign MASTER1_AWADDR_const_net_0   = 32'h00000000;
assign MASTER1_AWLEN_const_net_0    = 8'h00;
assign MASTER1_AWSIZE_const_net_0   = 3'h0;
assign MASTER1_AWBURST_const_net_0  = 2'h3;
assign MASTER1_AWLOCK_const_net_0   = 2'h0;
assign MASTER1_AWCACHE_const_net_0  = 4'h0;
assign MASTER1_AWPROT_const_net_0   = 3'h0;
assign MASTER1_AWQOS_const_net_0    = 4'h0;
assign MASTER1_AWREGION_const_net_0 = 4'h0;
assign MASTER1_WDATA_const_net_0    = 32'h00000000;
assign MASTER1_WSTRB_const_net_0    = 4'hF;
assign MASTER1_ARID_const_net_0     = 4'h0;
assign MASTER1_ARADDR_const_net_0   = 32'h00000000;
assign MASTER1_ARLEN_const_net_0    = 8'h00;
assign MASTER1_ARSIZE_const_net_0   = 3'h0;
assign MASTER1_ARBURST_const_net_0  = 2'h3;
assign MASTER1_ARLOCK_const_net_0   = 2'h0;
assign MASTER1_ARCACHE_const_net_0  = 4'h0;
assign MASTER1_ARPROT_const_net_0   = 3'h0;
assign MASTER1_ARQOS_const_net_0    = 4'h0;
assign MASTER2_AWID_const_net_0     = 4'h0;
assign MASTER2_AWADDR_const_net_0   = 32'h00000000;
assign MASTER2_AWLEN_const_net_0    = 8'h00;
assign MASTER2_AWSIZE_const_net_0   = 3'h0;
assign MASTER2_AWBURST_const_net_0  = 2'h3;
assign MASTER2_AWLOCK_const_net_0   = 2'h0;
assign MASTER2_AWCACHE_const_net_0  = 4'h0;
assign MASTER2_AWPROT_const_net_0   = 3'h0;
assign MASTER2_AWQOS_const_net_0    = 4'h0;
assign MASTER2_AWREGION_const_net_0 = 4'h0;
assign MASTER2_WDATA_const_net_0    = 32'h00000000;
assign MASTER2_WSTRB_const_net_0    = 4'hF;
assign MASTER2_ARID_const_net_0     = 4'h0;
assign MASTER2_ARADDR_const_net_0   = 32'h00000000;
assign MASTER2_ARLEN_const_net_0    = 8'h00;
assign MASTER2_ARSIZE_const_net_0   = 3'h0;
assign MASTER2_ARBURST_const_net_0  = 2'h3;
assign MASTER2_ARLOCK_const_net_0   = 2'h0;
assign MASTER2_ARCACHE_const_net_0  = 4'h0;
assign MASTER2_ARPROT_const_net_0   = 3'h0;
assign MASTER2_ARQOS_const_net_0    = 4'h0;
assign MASTER2_ARREGION_const_net_0 = 4'h0;
assign MASTER3_AWID_const_net_0     = 4'h0;
assign MASTER3_AWADDR_const_net_0   = 32'h00000000;
assign MASTER3_AWLEN_const_net_0    = 8'h00;
assign MASTER3_AWSIZE_const_net_0   = 3'h0;
assign MASTER3_AWBURST_const_net_0  = 2'h3;
assign MASTER3_AWLOCK_const_net_0   = 2'h0;
assign MASTER3_AWCACHE_const_net_0  = 4'h0;
assign MASTER3_AWPROT_const_net_0   = 3'h0;
assign MASTER3_AWQOS_const_net_0    = 4'h0;
assign MASTER3_AWREGION_const_net_0 = 4'h0;
assign MASTER3_WDATA_const_net_0    = 32'h00000000;
assign MASTER3_WSTRB_const_net_0    = 4'hF;
assign MASTER3_ARID_const_net_0     = 4'h0;
assign MASTER3_ARADDR_const_net_0   = 32'h00000000;
assign MASTER3_ARLEN_const_net_0    = 8'h00;
assign MASTER3_ARSIZE_const_net_0   = 3'h0;
assign MASTER3_ARBURST_const_net_0  = 2'h3;
assign MASTER3_ARLOCK_const_net_0   = 2'h0;
assign MASTER3_ARCACHE_const_net_0  = 4'h0;
assign MASTER3_ARPROT_const_net_0   = 3'h0;
assign MASTER3_ARQOS_const_net_0    = 4'h0;
assign MASTER3_ARREGION_const_net_0 = 4'h0;
assign MASTER4_AWID_const_net_0     = 4'h0;
assign MASTER4_AWADDR_const_net_0   = 32'h00000000;
assign MASTER4_AWLEN_const_net_0    = 8'h00;
assign MASTER4_AWSIZE_const_net_0   = 3'h0;
assign MASTER4_AWBURST_const_net_0  = 2'h3;
assign MASTER4_AWLOCK_const_net_0   = 2'h0;
assign MASTER4_AWCACHE_const_net_0  = 4'h0;
assign MASTER4_AWPROT_const_net_0   = 3'h0;
assign MASTER4_AWQOS_const_net_0    = 4'h0;
assign MASTER4_AWREGION_const_net_0 = 4'h0;
assign MASTER4_WDATA_const_net_0    = 32'h00000000;
assign MASTER4_WSTRB_const_net_0    = 4'hF;
assign MASTER4_ARID_const_net_0     = 4'h0;
assign MASTER4_ARADDR_const_net_0   = 32'h00000000;
assign MASTER4_ARLEN_const_net_0    = 8'h00;
assign MASTER4_ARSIZE_const_net_0   = 3'h0;
assign MASTER4_ARBURST_const_net_0  = 2'h3;
assign MASTER4_ARLOCK_const_net_0   = 2'h0;
assign MASTER4_ARCACHE_const_net_0  = 4'h0;
assign MASTER4_ARPROT_const_net_0   = 3'h0;
assign MASTER4_ARQOS_const_net_0    = 4'h0;
assign MASTER4_ARREGION_const_net_0 = 4'h0;
assign MASTER5_AWID_const_net_0     = 4'h0;
assign MASTER5_AWADDR_const_net_0   = 32'h00000000;
assign MASTER5_AWLEN_const_net_0    = 8'h00;
assign MASTER5_AWSIZE_const_net_0   = 3'h0;
assign MASTER5_AWBURST_const_net_0  = 2'h3;
assign MASTER5_AWLOCK_const_net_0   = 2'h0;
assign MASTER5_AWCACHE_const_net_0  = 4'h0;
assign MASTER5_AWPROT_const_net_0   = 3'h0;
assign MASTER5_AWQOS_const_net_0    = 4'h0;
assign MASTER5_AWREGION_const_net_0 = 4'h0;
assign MASTER5_WDATA_const_net_0    = 32'h00000000;
assign MASTER5_WSTRB_const_net_0    = 4'hF;
assign MASTER5_ARID_const_net_0     = 4'h0;
assign MASTER5_ARADDR_const_net_0   = 32'h00000000;
assign MASTER5_ARLEN_const_net_0    = 8'h00;
assign MASTER5_ARSIZE_const_net_0   = 3'h0;
assign MASTER5_ARBURST_const_net_0  = 2'h3;
assign MASTER5_ARLOCK_const_net_0   = 2'h0;
assign MASTER5_ARCACHE_const_net_0  = 4'h0;
assign MASTER5_ARPROT_const_net_0   = 3'h0;
assign MASTER5_ARQOS_const_net_0    = 4'h0;
assign MASTER5_ARREGION_const_net_0 = 4'h0;
assign MASTER6_AWID_const_net_0     = 4'h0;
assign MASTER6_AWADDR_const_net_0   = 32'h00000000;
assign MASTER6_AWLEN_const_net_0    = 8'h00;
assign MASTER6_AWSIZE_const_net_0   = 3'h0;
assign MASTER6_AWBURST_const_net_0  = 2'h3;
assign MASTER6_AWLOCK_const_net_0   = 2'h0;
assign MASTER6_AWCACHE_const_net_0  = 4'h0;
assign MASTER6_AWPROT_const_net_0   = 3'h0;
assign MASTER6_AWQOS_const_net_0    = 4'h0;
assign MASTER6_AWREGION_const_net_0 = 4'h0;
assign MASTER6_WDATA_const_net_0    = 32'h00000000;
assign MASTER6_WSTRB_const_net_0    = 4'hF;
assign MASTER6_ARID_const_net_0     = 4'h0;
assign MASTER6_ARADDR_const_net_0   = 32'h00000000;
assign MASTER6_ARLEN_const_net_0    = 8'h00;
assign MASTER6_ARSIZE_const_net_0   = 3'h0;
assign MASTER6_ARBURST_const_net_0  = 2'h3;
assign MASTER6_ARLOCK_const_net_0   = 2'h0;
assign MASTER6_ARCACHE_const_net_0  = 4'h0;
assign MASTER6_ARPROT_const_net_0   = 3'h0;
assign MASTER6_ARQOS_const_net_0    = 4'h0;
assign MASTER6_ARREGION_const_net_0 = 4'h0;
assign MASTER7_AWID_const_net_0     = 4'h0;
assign MASTER7_AWADDR_const_net_0   = 32'h00000000;
assign MASTER7_AWLEN_const_net_0    = 8'h00;
assign MASTER7_AWSIZE_const_net_0   = 3'h0;
assign MASTER7_AWBURST_const_net_0  = 2'h3;
assign MASTER7_AWLOCK_const_net_0   = 2'h0;
assign MASTER7_AWCACHE_const_net_0  = 4'h0;
assign MASTER7_AWPROT_const_net_0   = 3'h0;
assign MASTER7_AWQOS_const_net_0    = 4'h0;
assign MASTER7_AWREGION_const_net_0 = 4'h0;
assign MASTER7_WDATA_const_net_0    = 32'h00000000;
assign MASTER7_WSTRB_const_net_0    = 4'hF;
assign MASTER7_ARID_const_net_0     = 4'h0;
assign MASTER7_ARADDR_const_net_0   = 32'h00000000;
assign MASTER7_ARLEN_const_net_0    = 8'h00;
assign MASTER7_ARSIZE_const_net_0   = 3'h0;
assign MASTER7_ARBURST_const_net_0  = 2'h3;
assign MASTER7_ARLOCK_const_net_0   = 2'h0;
assign MASTER7_ARCACHE_const_net_0  = 4'h0;
assign MASTER7_ARPROT_const_net_0   = 3'h0;
assign MASTER7_ARQOS_const_net_0    = 4'h0;
assign MASTER7_ARREGION_const_net_0 = 4'h0;
//--------------------------------------------------------------------
// Inversions
//--------------------------------------------------------------------
assign reset_IN_POST_INV0_0 = ~ my_mss_top_0_MSS_READY_0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign TX_net_1 = TX_net_0;
assign TX       = TX_net_1;
//--------------------------------------------------------------------
// Bus Interface Nets Assignments - Unequal Pin Widths
//--------------------------------------------------------------------
assign axi_to_apb_0_APB_SLAVE_PADDR_0_4to0 = axi_to_apb_0_APB_SLAVE_PADDR[4:0];
assign axi_to_apb_0_APB_SLAVE_PADDR_0 = { axi_to_apb_0_APB_SLAVE_PADDR_0_4to0 };

assign axi_to_apb_0_APB_SLAVE_PRDATA_0_31to8 = 24'h0;
assign axi_to_apb_0_APB_SLAVE_PRDATA_0_7to0 = axi_to_apb_0_APB_SLAVE_PRDATA[7:0];
assign axi_to_apb_0_APB_SLAVE_PRDATA_0 = { axi_to_apb_0_APB_SLAVE_PRDATA_0_31to8, axi_to_apb_0_APB_SLAVE_PRDATA_0_7to0 };

assign axi_to_apb_0_APB_SLAVE_PWDATA_0_7to0 = axi_to_apb_0_APB_SLAVE_PWDATA[7:0];
assign axi_to_apb_0_APB_SLAVE_PWDATA_0 = { axi_to_apb_0_APB_SLAVE_PWDATA_0_7to0 };

assign CoreAXI4Interconnect_0_AXI3mslave0_ARID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave0_ARID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave0_ARID_0 = { CoreAXI4Interconnect_0_AXI3mslave0_ARID_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave0_ARLEN_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave0_ARLEN[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave0_ARLEN_0 = { CoreAXI4Interconnect_0_AXI3mslave0_ARLEN_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave0_AWID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave0_AWID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave0_AWID_0 = { CoreAXI4Interconnect_0_AXI3mslave0_AWID_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave0_AWLEN_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave0_AWLEN[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave0_AWLEN_0 = { CoreAXI4Interconnect_0_AXI3mslave0_AWLEN_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave0_BID_0_4to4 = 1'b0;
assign CoreAXI4Interconnect_0_AXI3mslave0_BID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave0_BID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave0_BID_0 = { CoreAXI4Interconnect_0_AXI3mslave0_BID_0_4to4, CoreAXI4Interconnect_0_AXI3mslave0_BID_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave0_RID_0_4to4 = 1'b0;
assign CoreAXI4Interconnect_0_AXI3mslave0_RID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave0_RID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave0_RID_0 = { CoreAXI4Interconnect_0_AXI3mslave0_RID_0_4to4, CoreAXI4Interconnect_0_AXI3mslave0_RID_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave0_WID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave0_WID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave0_WID_0 = { CoreAXI4Interconnect_0_AXI3mslave0_WID_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave3_ARID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave3_ARID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave3_ARID_0 = { CoreAXI4Interconnect_0_AXI3mslave3_ARID_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave3_ARLEN_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave3_ARLEN[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave3_ARLEN_0 = { CoreAXI4Interconnect_0_AXI3mslave3_ARLEN_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave3_AWID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave3_AWID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave3_AWID_0 = { CoreAXI4Interconnect_0_AXI3mslave3_AWID_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave3_AWLEN_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave3_AWLEN[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave3_AWLEN_0 = { CoreAXI4Interconnect_0_AXI3mslave3_AWLEN_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave3_BID_0_4to4 = 1'b0;
assign CoreAXI4Interconnect_0_AXI3mslave3_BID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave3_BID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave3_BID_0 = { CoreAXI4Interconnect_0_AXI3mslave3_BID_0_4to4, CoreAXI4Interconnect_0_AXI3mslave3_BID_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave3_RID_0_4to4 = 1'b0;
assign CoreAXI4Interconnect_0_AXI3mslave3_RID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave3_RID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave3_RID_0 = { CoreAXI4Interconnect_0_AXI3mslave3_RID_0_4to4, CoreAXI4Interconnect_0_AXI3mslave3_RID_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave3_WID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave3_WID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave3_WID_0 = { CoreAXI4Interconnect_0_AXI3mslave3_WID_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave7_ARID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave7_ARID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave7_ARID_0 = { CoreAXI4Interconnect_0_AXI3mslave7_ARID_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave7_ARLEN_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave7_ARLEN[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave7_ARLEN_0 = { CoreAXI4Interconnect_0_AXI3mslave7_ARLEN_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave7_AWID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave7_AWID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave7_AWID_0 = { CoreAXI4Interconnect_0_AXI3mslave7_AWID_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave7_AWLEN_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave7_AWLEN[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave7_AWLEN_0 = { CoreAXI4Interconnect_0_AXI3mslave7_AWLEN_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave7_BID_0_4to4 = 1'b0;
assign CoreAXI4Interconnect_0_AXI3mslave7_BID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave7_BID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave7_BID_0 = { CoreAXI4Interconnect_0_AXI3mslave7_BID_0_4to4, CoreAXI4Interconnect_0_AXI3mslave7_BID_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave7_RID_0_4to4 = 1'b0;
assign CoreAXI4Interconnect_0_AXI3mslave7_RID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave7_RID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave7_RID_0 = { CoreAXI4Interconnect_0_AXI3mslave7_RID_0_4to4, CoreAXI4Interconnect_0_AXI3mslave7_RID_0_3to0 };

assign CoreAXI4Interconnect_0_AXI3mslave7_WID_0_3to0 = CoreAXI4Interconnect_0_AXI3mslave7_WID[3:0];
assign CoreAXI4Interconnect_0_AXI3mslave7_WID_0 = { CoreAXI4Interconnect_0_AXI3mslave7_WID_0_3to0 };

assign microsemi_wrapper_0_DATA_MASTER_ARLEN_0_7to4 = 4'h0;
assign microsemi_wrapper_0_DATA_MASTER_ARLEN_0_3to0 = microsemi_wrapper_0_DATA_MASTER_ARLEN[3:0];
assign microsemi_wrapper_0_DATA_MASTER_ARLEN_0 = { microsemi_wrapper_0_DATA_MASTER_ARLEN_0_7to4, microsemi_wrapper_0_DATA_MASTER_ARLEN_0_3to0 };

assign microsemi_wrapper_0_DATA_MASTER_AWLEN_0_7to4 = 4'h0;
assign microsemi_wrapper_0_DATA_MASTER_AWLEN_0_3to0 = microsemi_wrapper_0_DATA_MASTER_AWLEN[3:0];
assign microsemi_wrapper_0_DATA_MASTER_AWLEN_0 = { microsemi_wrapper_0_DATA_MASTER_AWLEN_0_7to4, microsemi_wrapper_0_DATA_MASTER_AWLEN_0_3to0 };

//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------axi_to_apb
axi_to_apb #( 
        .BYTE_SIZE     ( 8 ),
        .REGISTER_SIZE ( 32 ) )
axi_to_apb_0(
        // Inputs
        .clk     ( my_mss_top_0_FIC_0_CLK_1 ),
        .aresetn ( my_mss_top_0_MSS_READY_0 ),
        .AWVALID ( CoreAXI4Interconnect_0_AXI3mslave3_AWVALID ),
        .WLAST   ( CoreAXI4Interconnect_0_AXI3mslave3_WLAST ),
        .WVALID  ( CoreAXI4Interconnect_0_AXI3mslave3_WVALID ),
        .BREADY  ( CoreAXI4Interconnect_0_AXI3mslave3_BREADY ),
        .ARVALID ( CoreAXI4Interconnect_0_AXI3mslave3_ARVALID ),
        .RREADY  ( CoreAXI4Interconnect_0_AXI3mslave3_RREADY ),
        .PREADY  ( axi_to_apb_0_APB_SLAVE_PREADY ),
        .AWID    ( CoreAXI4Interconnect_0_AXI3mslave3_AWID_0 ),
        .AWADDR  ( CoreAXI4Interconnect_0_AXI3mslave3_AWADDR ),
        .AWLEN   ( CoreAXI4Interconnect_0_AXI3mslave3_AWLEN_0 ),
        .AWSIZE  ( CoreAXI4Interconnect_0_AXI3mslave3_AWSIZE ),
        .AWBURST ( CoreAXI4Interconnect_0_AXI3mslave3_AWBURST ),
        .AWLOCK  ( CoreAXI4Interconnect_0_AXI3mslave3_AWLOCK ),
        .WID     ( CoreAXI4Interconnect_0_AXI3mslave3_WID_0 ),
        .WSTRB   ( CoreAXI4Interconnect_0_AXI3mslave3_WSTRB ),
        .WDATA   ( CoreAXI4Interconnect_0_AXI3mslave3_WDATA ),
        .ARID    ( CoreAXI4Interconnect_0_AXI3mslave3_ARID_0 ),
        .ARADDR  ( CoreAXI4Interconnect_0_AXI3mslave3_ARADDR ),
        .ARLEN   ( CoreAXI4Interconnect_0_AXI3mslave3_ARLEN_0 ),
        .ARSIZE  ( CoreAXI4Interconnect_0_AXI3mslave3_ARSIZE ),
        .ARLOCK  ( CoreAXI4Interconnect_0_AXI3mslave3_ARLOCK ),
        .ARBURST ( CoreAXI4Interconnect_0_AXI3mslave3_ARBURST ),
        .PRDATA  ( axi_to_apb_0_APB_SLAVE_PRDATA_0 ),
        // Outputs
        .AWREADY ( CoreAXI4Interconnect_0_AXI3mslave3_AWREADY ),
        .WREADY  ( CoreAXI4Interconnect_0_AXI3mslave3_WREADY ),
        .BVALID  ( CoreAXI4Interconnect_0_AXI3mslave3_BVALID ),
        .ARREADY ( CoreAXI4Interconnect_0_AXI3mslave3_ARREADY ),
        .RLAST   ( CoreAXI4Interconnect_0_AXI3mslave3_RLAST ),
        .RVALID  ( CoreAXI4Interconnect_0_AXI3mslave3_RVALID ),
        .PENABLE ( axi_to_apb_0_APB_SLAVE_PENABLE ),
        .PWRITE  ( axi_to_apb_0_APB_SLAVE_PWRITE ),
        .PSEL    ( axi_to_apb_0_APB_SLAVE_PSELx ),
        .BID     ( CoreAXI4Interconnect_0_AXI3mslave3_BID ),
        .BRESP   ( CoreAXI4Interconnect_0_AXI3mslave3_BRESP ),
        .RID     ( CoreAXI4Interconnect_0_AXI3mslave3_RID ),
        .RDATA   ( CoreAXI4Interconnect_0_AXI3mslave3_RDATA ),
        .RRESP   ( CoreAXI4Interconnect_0_AXI3mslave3_RRESP ),
        .PADDR   ( axi_to_apb_0_APB_SLAVE_PADDR ),
        .PWDATA  ( axi_to_apb_0_APB_SLAVE_PWDATA ) 
        );

//--------CoreAXI4Interconnect   -   Actel:DirectCore:CoreAXI4Interconnect:2.2.102
CoreAXI4Interconnect #( 
        .ADDR_WIDTH                    ( 32 ),
        .AHB_MASTER0_BRESP_CHECK_MODE  ( 0 ),
        .AHB_MASTER1_BRESP_CHECK_MODE  ( 0 ),
        .AHB_MASTER2_BRESP_CHECK_MODE  ( 0 ),
        .AHB_MASTER3_BRESP_CHECK_MODE  ( 0 ),
        .AHB_MASTER4_BRESP_CHECK_MODE  ( 0 ),
        .AHB_MASTER5_BRESP_CHECK_MODE  ( 0 ),
        .AHB_MASTER6_BRESP_CHECK_MODE  ( 0 ),
        .AHB_MASTER7_BRESP_CHECK_MODE  ( 0 ),
        .CROSSBAR_MODE                 ( 1 ),
        .DATA_WIDTH                    ( 32 ),
        .DWC_ADDR_FIFO_DEPTH_CEILING   ( 10 ),
        .FAMILY                        ( 19 ),
        .ID_WIDTH                      ( 4 ),
        .LOWER_COMPARE_BIT             ( 12 ),
        .MASTER0_ARCHAN_RS             ( 0 ),
        .MASTER0_AWCHAN_RS             ( 0 ),
        .MASTER0_BCHAN_RS              ( 0 ),
        .MASTER0_CLOCK_DOMAIN_CROSSING ( 0 ),
        .MASTER0_DATA_WIDTH            ( 32 ),
        .MASTER0_DEF_BURST_LEN         ( 0 ),
        .MASTER0_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .MASTER0_RCHAN_RS              ( 0 ),
        .MASTER0_READ_SLAVE0           ( 1 ),
        .MASTER0_READ_SLAVE1           ( 1 ),
        .MASTER0_READ_SLAVE2           ( 1 ),
        .MASTER0_READ_SLAVE3           ( 1 ),
        .MASTER0_READ_SLAVE4           ( 1 ),
        .MASTER0_READ_SLAVE5           ( 1 ),
        .MASTER0_READ_SLAVE6           ( 1 ),
        .MASTER0_READ_SLAVE7           ( 1 ),
        .MASTER0_READ_SLAVE8           ( 1 ),
        .MASTER0_READ_SLAVE9           ( 1 ),
        .MASTER0_READ_SLAVE10          ( 1 ),
        .MASTER0_READ_SLAVE11          ( 1 ),
        .MASTER0_READ_SLAVE12          ( 1 ),
        .MASTER0_READ_SLAVE13          ( 1 ),
        .MASTER0_READ_SLAVE14          ( 1 ),
        .MASTER0_READ_SLAVE15          ( 1 ),
        .MASTER0_READ_SLAVE16          ( 1 ),
        .MASTER0_READ_SLAVE17          ( 1 ),
        .MASTER0_READ_SLAVE18          ( 1 ),
        .MASTER0_READ_SLAVE19          ( 1 ),
        .MASTER0_READ_SLAVE20          ( 1 ),
        .MASTER0_READ_SLAVE21          ( 1 ),
        .MASTER0_READ_SLAVE22          ( 1 ),
        .MASTER0_READ_SLAVE23          ( 1 ),
        .MASTER0_READ_SLAVE24          ( 1 ),
        .MASTER0_READ_SLAVE25          ( 1 ),
        .MASTER0_READ_SLAVE26          ( 1 ),
        .MASTER0_READ_SLAVE27          ( 1 ),
        .MASTER0_READ_SLAVE28          ( 1 ),
        .MASTER0_READ_SLAVE29          ( 1 ),
        .MASTER0_READ_SLAVE30          ( 1 ),
        .MASTER0_READ_SLAVE31          ( 1 ),
        .MASTER0_TYPE                  ( 3 ),
        .MASTER0_WCHAN_RS              ( 0 ),
        .MASTER0_WRITE_SLAVE0          ( 1 ),
        .MASTER0_WRITE_SLAVE1          ( 1 ),
        .MASTER0_WRITE_SLAVE2          ( 1 ),
        .MASTER0_WRITE_SLAVE3          ( 1 ),
        .MASTER0_WRITE_SLAVE4          ( 1 ),
        .MASTER0_WRITE_SLAVE5          ( 1 ),
        .MASTER0_WRITE_SLAVE6          ( 1 ),
        .MASTER0_WRITE_SLAVE7          ( 1 ),
        .MASTER0_WRITE_SLAVE8          ( 1 ),
        .MASTER0_WRITE_SLAVE9          ( 1 ),
        .MASTER0_WRITE_SLAVE10         ( 1 ),
        .MASTER0_WRITE_SLAVE11         ( 1 ),
        .MASTER0_WRITE_SLAVE12         ( 1 ),
        .MASTER0_WRITE_SLAVE13         ( 1 ),
        .MASTER0_WRITE_SLAVE14         ( 1 ),
        .MASTER0_WRITE_SLAVE15         ( 1 ),
        .MASTER0_WRITE_SLAVE16         ( 1 ),
        .MASTER0_WRITE_SLAVE17         ( 1 ),
        .MASTER0_WRITE_SLAVE18         ( 1 ),
        .MASTER0_WRITE_SLAVE19         ( 1 ),
        .MASTER0_WRITE_SLAVE20         ( 1 ),
        .MASTER0_WRITE_SLAVE21         ( 1 ),
        .MASTER0_WRITE_SLAVE22         ( 1 ),
        .MASTER0_WRITE_SLAVE23         ( 1 ),
        .MASTER0_WRITE_SLAVE24         ( 1 ),
        .MASTER0_WRITE_SLAVE25         ( 1 ),
        .MASTER0_WRITE_SLAVE26         ( 1 ),
        .MASTER0_WRITE_SLAVE27         ( 1 ),
        .MASTER0_WRITE_SLAVE28         ( 1 ),
        .MASTER0_WRITE_SLAVE29         ( 1 ),
        .MASTER0_WRITE_SLAVE30         ( 1 ),
        .MASTER0_WRITE_SLAVE31         ( 1 ),
        .MASTER1_ARCHAN_RS             ( 1 ),
        .MASTER1_AWCHAN_RS             ( 1 ),
        .MASTER1_BCHAN_RS              ( 1 ),
        .MASTER1_CLOCK_DOMAIN_CROSSING ( 0 ),
        .MASTER1_DATA_WIDTH            ( 32 ),
        .MASTER1_DEF_BURST_LEN         ( 0 ),
        .MASTER1_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .MASTER1_RCHAN_RS              ( 1 ),
        .MASTER1_READ_SLAVE0           ( 1 ),
        .MASTER1_READ_SLAVE1           ( 1 ),
        .MASTER1_READ_SLAVE2           ( 1 ),
        .MASTER1_READ_SLAVE3           ( 1 ),
        .MASTER1_READ_SLAVE4           ( 1 ),
        .MASTER1_READ_SLAVE5           ( 1 ),
        .MASTER1_READ_SLAVE6           ( 1 ),
        .MASTER1_READ_SLAVE7           ( 1 ),
        .MASTER1_READ_SLAVE8           ( 1 ),
        .MASTER1_READ_SLAVE9           ( 1 ),
        .MASTER1_READ_SLAVE10          ( 1 ),
        .MASTER1_READ_SLAVE11          ( 1 ),
        .MASTER1_READ_SLAVE12          ( 1 ),
        .MASTER1_READ_SLAVE13          ( 1 ),
        .MASTER1_READ_SLAVE14          ( 1 ),
        .MASTER1_READ_SLAVE15          ( 1 ),
        .MASTER1_READ_SLAVE16          ( 1 ),
        .MASTER1_READ_SLAVE17          ( 1 ),
        .MASTER1_READ_SLAVE18          ( 1 ),
        .MASTER1_READ_SLAVE19          ( 1 ),
        .MASTER1_READ_SLAVE20          ( 1 ),
        .MASTER1_READ_SLAVE21          ( 1 ),
        .MASTER1_READ_SLAVE22          ( 1 ),
        .MASTER1_READ_SLAVE23          ( 1 ),
        .MASTER1_READ_SLAVE24          ( 1 ),
        .MASTER1_READ_SLAVE25          ( 1 ),
        .MASTER1_READ_SLAVE26          ( 1 ),
        .MASTER1_READ_SLAVE27          ( 1 ),
        .MASTER1_READ_SLAVE28          ( 1 ),
        .MASTER1_READ_SLAVE29          ( 1 ),
        .MASTER1_READ_SLAVE30          ( 1 ),
        .MASTER1_READ_SLAVE31          ( 1 ),
        .MASTER1_TYPE                  ( 0 ),
        .MASTER1_WCHAN_RS              ( 1 ),
        .MASTER1_WRITE_SLAVE0          ( 1 ),
        .MASTER1_WRITE_SLAVE1          ( 1 ),
        .MASTER1_WRITE_SLAVE2          ( 1 ),
        .MASTER1_WRITE_SLAVE3          ( 1 ),
        .MASTER1_WRITE_SLAVE4          ( 1 ),
        .MASTER1_WRITE_SLAVE5          ( 1 ),
        .MASTER1_WRITE_SLAVE6          ( 1 ),
        .MASTER1_WRITE_SLAVE7          ( 1 ),
        .MASTER1_WRITE_SLAVE8          ( 1 ),
        .MASTER1_WRITE_SLAVE9          ( 1 ),
        .MASTER1_WRITE_SLAVE10         ( 1 ),
        .MASTER1_WRITE_SLAVE11         ( 1 ),
        .MASTER1_WRITE_SLAVE12         ( 1 ),
        .MASTER1_WRITE_SLAVE13         ( 1 ),
        .MASTER1_WRITE_SLAVE14         ( 1 ),
        .MASTER1_WRITE_SLAVE15         ( 1 ),
        .MASTER1_WRITE_SLAVE16         ( 1 ),
        .MASTER1_WRITE_SLAVE17         ( 1 ),
        .MASTER1_WRITE_SLAVE18         ( 1 ),
        .MASTER1_WRITE_SLAVE19         ( 1 ),
        .MASTER1_WRITE_SLAVE20         ( 1 ),
        .MASTER1_WRITE_SLAVE21         ( 1 ),
        .MASTER1_WRITE_SLAVE22         ( 1 ),
        .MASTER1_WRITE_SLAVE23         ( 1 ),
        .MASTER1_WRITE_SLAVE24         ( 1 ),
        .MASTER1_WRITE_SLAVE25         ( 1 ),
        .MASTER1_WRITE_SLAVE26         ( 1 ),
        .MASTER1_WRITE_SLAVE27         ( 1 ),
        .MASTER1_WRITE_SLAVE28         ( 1 ),
        .MASTER1_WRITE_SLAVE29         ( 1 ),
        .MASTER1_WRITE_SLAVE30         ( 1 ),
        .MASTER1_WRITE_SLAVE31         ( 1 ),
        .MASTER2_ARCHAN_RS             ( 1 ),
        .MASTER2_AWCHAN_RS             ( 1 ),
        .MASTER2_BCHAN_RS              ( 1 ),
        .MASTER2_CLOCK_DOMAIN_CROSSING ( 0 ),
        .MASTER2_DATA_WIDTH            ( 32 ),
        .MASTER2_DEF_BURST_LEN         ( 0 ),
        .MASTER2_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .MASTER2_RCHAN_RS              ( 1 ),
        .MASTER2_READ_SLAVE0           ( 1 ),
        .MASTER2_READ_SLAVE1           ( 1 ),
        .MASTER2_READ_SLAVE2           ( 1 ),
        .MASTER2_READ_SLAVE3           ( 1 ),
        .MASTER2_READ_SLAVE4           ( 1 ),
        .MASTER2_READ_SLAVE5           ( 1 ),
        .MASTER2_READ_SLAVE6           ( 1 ),
        .MASTER2_READ_SLAVE7           ( 1 ),
        .MASTER2_READ_SLAVE8           ( 1 ),
        .MASTER2_READ_SLAVE9           ( 1 ),
        .MASTER2_READ_SLAVE10          ( 1 ),
        .MASTER2_READ_SLAVE11          ( 1 ),
        .MASTER2_READ_SLAVE12          ( 1 ),
        .MASTER2_READ_SLAVE13          ( 1 ),
        .MASTER2_READ_SLAVE14          ( 1 ),
        .MASTER2_READ_SLAVE15          ( 1 ),
        .MASTER2_READ_SLAVE16          ( 1 ),
        .MASTER2_READ_SLAVE17          ( 1 ),
        .MASTER2_READ_SLAVE18          ( 1 ),
        .MASTER2_READ_SLAVE19          ( 1 ),
        .MASTER2_READ_SLAVE20          ( 1 ),
        .MASTER2_READ_SLAVE21          ( 1 ),
        .MASTER2_READ_SLAVE22          ( 1 ),
        .MASTER2_READ_SLAVE23          ( 1 ),
        .MASTER2_READ_SLAVE24          ( 1 ),
        .MASTER2_READ_SLAVE25          ( 1 ),
        .MASTER2_READ_SLAVE26          ( 1 ),
        .MASTER2_READ_SLAVE27          ( 1 ),
        .MASTER2_READ_SLAVE28          ( 1 ),
        .MASTER2_READ_SLAVE29          ( 1 ),
        .MASTER2_READ_SLAVE30          ( 1 ),
        .MASTER2_READ_SLAVE31          ( 1 ),
        .MASTER2_TYPE                  ( 0 ),
        .MASTER2_WCHAN_RS              ( 1 ),
        .MASTER2_WRITE_SLAVE0          ( 1 ),
        .MASTER2_WRITE_SLAVE1          ( 1 ),
        .MASTER2_WRITE_SLAVE2          ( 1 ),
        .MASTER2_WRITE_SLAVE3          ( 1 ),
        .MASTER2_WRITE_SLAVE4          ( 1 ),
        .MASTER2_WRITE_SLAVE5          ( 1 ),
        .MASTER2_WRITE_SLAVE6          ( 1 ),
        .MASTER2_WRITE_SLAVE7          ( 1 ),
        .MASTER2_WRITE_SLAVE8          ( 1 ),
        .MASTER2_WRITE_SLAVE9          ( 1 ),
        .MASTER2_WRITE_SLAVE10         ( 1 ),
        .MASTER2_WRITE_SLAVE11         ( 1 ),
        .MASTER2_WRITE_SLAVE12         ( 1 ),
        .MASTER2_WRITE_SLAVE13         ( 1 ),
        .MASTER2_WRITE_SLAVE14         ( 1 ),
        .MASTER2_WRITE_SLAVE15         ( 1 ),
        .MASTER2_WRITE_SLAVE16         ( 1 ),
        .MASTER2_WRITE_SLAVE17         ( 1 ),
        .MASTER2_WRITE_SLAVE18         ( 1 ),
        .MASTER2_WRITE_SLAVE19         ( 1 ),
        .MASTER2_WRITE_SLAVE20         ( 1 ),
        .MASTER2_WRITE_SLAVE21         ( 1 ),
        .MASTER2_WRITE_SLAVE22         ( 1 ),
        .MASTER2_WRITE_SLAVE23         ( 1 ),
        .MASTER2_WRITE_SLAVE24         ( 1 ),
        .MASTER2_WRITE_SLAVE25         ( 1 ),
        .MASTER2_WRITE_SLAVE26         ( 1 ),
        .MASTER2_WRITE_SLAVE27         ( 1 ),
        .MASTER2_WRITE_SLAVE28         ( 1 ),
        .MASTER2_WRITE_SLAVE29         ( 1 ),
        .MASTER2_WRITE_SLAVE30         ( 1 ),
        .MASTER2_WRITE_SLAVE31         ( 1 ),
        .MASTER3_ARCHAN_RS             ( 1 ),
        .MASTER3_AWCHAN_RS             ( 1 ),
        .MASTER3_BCHAN_RS              ( 1 ),
        .MASTER3_CLOCK_DOMAIN_CROSSING ( 0 ),
        .MASTER3_DATA_WIDTH            ( 32 ),
        .MASTER3_DEF_BURST_LEN         ( 0 ),
        .MASTER3_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .MASTER3_RCHAN_RS              ( 1 ),
        .MASTER3_READ_SLAVE0           ( 1 ),
        .MASTER3_READ_SLAVE1           ( 1 ),
        .MASTER3_READ_SLAVE2           ( 1 ),
        .MASTER3_READ_SLAVE3           ( 1 ),
        .MASTER3_READ_SLAVE4           ( 1 ),
        .MASTER3_READ_SLAVE5           ( 1 ),
        .MASTER3_READ_SLAVE6           ( 1 ),
        .MASTER3_READ_SLAVE7           ( 1 ),
        .MASTER3_READ_SLAVE8           ( 1 ),
        .MASTER3_READ_SLAVE9           ( 1 ),
        .MASTER3_READ_SLAVE10          ( 1 ),
        .MASTER3_READ_SLAVE11          ( 1 ),
        .MASTER3_READ_SLAVE12          ( 1 ),
        .MASTER3_READ_SLAVE13          ( 1 ),
        .MASTER3_READ_SLAVE14          ( 1 ),
        .MASTER3_READ_SLAVE15          ( 1 ),
        .MASTER3_READ_SLAVE16          ( 1 ),
        .MASTER3_READ_SLAVE17          ( 1 ),
        .MASTER3_READ_SLAVE18          ( 1 ),
        .MASTER3_READ_SLAVE19          ( 1 ),
        .MASTER3_READ_SLAVE20          ( 1 ),
        .MASTER3_READ_SLAVE21          ( 1 ),
        .MASTER3_READ_SLAVE22          ( 1 ),
        .MASTER3_READ_SLAVE23          ( 1 ),
        .MASTER3_READ_SLAVE24          ( 1 ),
        .MASTER3_READ_SLAVE25          ( 1 ),
        .MASTER3_READ_SLAVE26          ( 1 ),
        .MASTER3_READ_SLAVE27          ( 1 ),
        .MASTER3_READ_SLAVE28          ( 1 ),
        .MASTER3_READ_SLAVE29          ( 1 ),
        .MASTER3_READ_SLAVE30          ( 1 ),
        .MASTER3_READ_SLAVE31          ( 1 ),
        .MASTER3_TYPE                  ( 0 ),
        .MASTER3_WCHAN_RS              ( 1 ),
        .MASTER3_WRITE_SLAVE0          ( 1 ),
        .MASTER3_WRITE_SLAVE1          ( 1 ),
        .MASTER3_WRITE_SLAVE2          ( 1 ),
        .MASTER3_WRITE_SLAVE3          ( 1 ),
        .MASTER3_WRITE_SLAVE4          ( 1 ),
        .MASTER3_WRITE_SLAVE5          ( 1 ),
        .MASTER3_WRITE_SLAVE6          ( 1 ),
        .MASTER3_WRITE_SLAVE7          ( 1 ),
        .MASTER3_WRITE_SLAVE8          ( 1 ),
        .MASTER3_WRITE_SLAVE9          ( 1 ),
        .MASTER3_WRITE_SLAVE10         ( 1 ),
        .MASTER3_WRITE_SLAVE11         ( 1 ),
        .MASTER3_WRITE_SLAVE12         ( 1 ),
        .MASTER3_WRITE_SLAVE13         ( 1 ),
        .MASTER3_WRITE_SLAVE14         ( 1 ),
        .MASTER3_WRITE_SLAVE15         ( 1 ),
        .MASTER3_WRITE_SLAVE16         ( 1 ),
        .MASTER3_WRITE_SLAVE17         ( 1 ),
        .MASTER3_WRITE_SLAVE18         ( 1 ),
        .MASTER3_WRITE_SLAVE19         ( 1 ),
        .MASTER3_WRITE_SLAVE20         ( 1 ),
        .MASTER3_WRITE_SLAVE21         ( 1 ),
        .MASTER3_WRITE_SLAVE22         ( 1 ),
        .MASTER3_WRITE_SLAVE23         ( 1 ),
        .MASTER3_WRITE_SLAVE24         ( 1 ),
        .MASTER3_WRITE_SLAVE25         ( 1 ),
        .MASTER3_WRITE_SLAVE26         ( 1 ),
        .MASTER3_WRITE_SLAVE27         ( 1 ),
        .MASTER3_WRITE_SLAVE28         ( 1 ),
        .MASTER3_WRITE_SLAVE29         ( 1 ),
        .MASTER3_WRITE_SLAVE30         ( 1 ),
        .MASTER3_WRITE_SLAVE31         ( 1 ),
        .MASTER4_ARCHAN_RS             ( 1 ),
        .MASTER4_AWCHAN_RS             ( 1 ),
        .MASTER4_BCHAN_RS              ( 1 ),
        .MASTER4_CLOCK_DOMAIN_CROSSING ( 0 ),
        .MASTER4_DATA_WIDTH            ( 32 ),
        .MASTER4_DEF_BURST_LEN         ( 0 ),
        .MASTER4_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .MASTER4_RCHAN_RS              ( 1 ),
        .MASTER4_READ_SLAVE0           ( 1 ),
        .MASTER4_READ_SLAVE1           ( 1 ),
        .MASTER4_READ_SLAVE2           ( 1 ),
        .MASTER4_READ_SLAVE3           ( 1 ),
        .MASTER4_READ_SLAVE4           ( 1 ),
        .MASTER4_READ_SLAVE5           ( 1 ),
        .MASTER4_READ_SLAVE6           ( 1 ),
        .MASTER4_READ_SLAVE7           ( 1 ),
        .MASTER4_READ_SLAVE8           ( 1 ),
        .MASTER4_READ_SLAVE9           ( 1 ),
        .MASTER4_READ_SLAVE10          ( 1 ),
        .MASTER4_READ_SLAVE11          ( 1 ),
        .MASTER4_READ_SLAVE12          ( 1 ),
        .MASTER4_READ_SLAVE13          ( 1 ),
        .MASTER4_READ_SLAVE14          ( 1 ),
        .MASTER4_READ_SLAVE15          ( 1 ),
        .MASTER4_READ_SLAVE16          ( 1 ),
        .MASTER4_READ_SLAVE17          ( 1 ),
        .MASTER4_READ_SLAVE18          ( 1 ),
        .MASTER4_READ_SLAVE19          ( 1 ),
        .MASTER4_READ_SLAVE20          ( 1 ),
        .MASTER4_READ_SLAVE21          ( 1 ),
        .MASTER4_READ_SLAVE22          ( 1 ),
        .MASTER4_READ_SLAVE23          ( 1 ),
        .MASTER4_READ_SLAVE24          ( 1 ),
        .MASTER4_READ_SLAVE25          ( 1 ),
        .MASTER4_READ_SLAVE26          ( 1 ),
        .MASTER4_READ_SLAVE27          ( 1 ),
        .MASTER4_READ_SLAVE28          ( 1 ),
        .MASTER4_READ_SLAVE29          ( 1 ),
        .MASTER4_READ_SLAVE30          ( 1 ),
        .MASTER4_READ_SLAVE31          ( 1 ),
        .MASTER4_TYPE                  ( 0 ),
        .MASTER4_WCHAN_RS              ( 1 ),
        .MASTER4_WRITE_SLAVE0          ( 1 ),
        .MASTER4_WRITE_SLAVE1          ( 1 ),
        .MASTER4_WRITE_SLAVE2          ( 1 ),
        .MASTER4_WRITE_SLAVE3          ( 1 ),
        .MASTER4_WRITE_SLAVE4          ( 1 ),
        .MASTER4_WRITE_SLAVE5          ( 1 ),
        .MASTER4_WRITE_SLAVE6          ( 1 ),
        .MASTER4_WRITE_SLAVE7          ( 1 ),
        .MASTER4_WRITE_SLAVE8          ( 1 ),
        .MASTER4_WRITE_SLAVE9          ( 1 ),
        .MASTER4_WRITE_SLAVE10         ( 1 ),
        .MASTER4_WRITE_SLAVE11         ( 1 ),
        .MASTER4_WRITE_SLAVE12         ( 1 ),
        .MASTER4_WRITE_SLAVE13         ( 1 ),
        .MASTER4_WRITE_SLAVE14         ( 1 ),
        .MASTER4_WRITE_SLAVE15         ( 1 ),
        .MASTER4_WRITE_SLAVE16         ( 1 ),
        .MASTER4_WRITE_SLAVE17         ( 1 ),
        .MASTER4_WRITE_SLAVE18         ( 1 ),
        .MASTER4_WRITE_SLAVE19         ( 1 ),
        .MASTER4_WRITE_SLAVE20         ( 1 ),
        .MASTER4_WRITE_SLAVE21         ( 1 ),
        .MASTER4_WRITE_SLAVE22         ( 1 ),
        .MASTER4_WRITE_SLAVE23         ( 1 ),
        .MASTER4_WRITE_SLAVE24         ( 1 ),
        .MASTER4_WRITE_SLAVE25         ( 1 ),
        .MASTER4_WRITE_SLAVE26         ( 1 ),
        .MASTER4_WRITE_SLAVE27         ( 1 ),
        .MASTER4_WRITE_SLAVE28         ( 1 ),
        .MASTER4_WRITE_SLAVE29         ( 1 ),
        .MASTER4_WRITE_SLAVE30         ( 1 ),
        .MASTER4_WRITE_SLAVE31         ( 1 ),
        .MASTER5_ARCHAN_RS             ( 1 ),
        .MASTER5_AWCHAN_RS             ( 1 ),
        .MASTER5_BCHAN_RS              ( 1 ),
        .MASTER5_CLOCK_DOMAIN_CROSSING ( 0 ),
        .MASTER5_DATA_WIDTH            ( 32 ),
        .MASTER5_DEF_BURST_LEN         ( 0 ),
        .MASTER5_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .MASTER5_RCHAN_RS              ( 1 ),
        .MASTER5_READ_SLAVE0           ( 1 ),
        .MASTER5_READ_SLAVE1           ( 1 ),
        .MASTER5_READ_SLAVE2           ( 1 ),
        .MASTER5_READ_SLAVE3           ( 1 ),
        .MASTER5_READ_SLAVE4           ( 1 ),
        .MASTER5_READ_SLAVE5           ( 1 ),
        .MASTER5_READ_SLAVE6           ( 1 ),
        .MASTER5_READ_SLAVE7           ( 1 ),
        .MASTER5_READ_SLAVE8           ( 1 ),
        .MASTER5_READ_SLAVE9           ( 1 ),
        .MASTER5_READ_SLAVE10          ( 1 ),
        .MASTER5_READ_SLAVE11          ( 1 ),
        .MASTER5_READ_SLAVE12          ( 1 ),
        .MASTER5_READ_SLAVE13          ( 1 ),
        .MASTER5_READ_SLAVE14          ( 1 ),
        .MASTER5_READ_SLAVE15          ( 1 ),
        .MASTER5_READ_SLAVE16          ( 1 ),
        .MASTER5_READ_SLAVE17          ( 1 ),
        .MASTER5_READ_SLAVE18          ( 1 ),
        .MASTER5_READ_SLAVE19          ( 1 ),
        .MASTER5_READ_SLAVE20          ( 1 ),
        .MASTER5_READ_SLAVE21          ( 1 ),
        .MASTER5_READ_SLAVE22          ( 1 ),
        .MASTER5_READ_SLAVE23          ( 1 ),
        .MASTER5_READ_SLAVE24          ( 1 ),
        .MASTER5_READ_SLAVE25          ( 1 ),
        .MASTER5_READ_SLAVE26          ( 1 ),
        .MASTER5_READ_SLAVE27          ( 1 ),
        .MASTER5_READ_SLAVE28          ( 1 ),
        .MASTER5_READ_SLAVE29          ( 1 ),
        .MASTER5_READ_SLAVE30          ( 1 ),
        .MASTER5_READ_SLAVE31          ( 1 ),
        .MASTER5_TYPE                  ( 0 ),
        .MASTER5_WCHAN_RS              ( 1 ),
        .MASTER5_WRITE_SLAVE0          ( 1 ),
        .MASTER5_WRITE_SLAVE1          ( 1 ),
        .MASTER5_WRITE_SLAVE2          ( 1 ),
        .MASTER5_WRITE_SLAVE3          ( 1 ),
        .MASTER5_WRITE_SLAVE4          ( 1 ),
        .MASTER5_WRITE_SLAVE5          ( 1 ),
        .MASTER5_WRITE_SLAVE6          ( 1 ),
        .MASTER5_WRITE_SLAVE7          ( 1 ),
        .MASTER5_WRITE_SLAVE8          ( 1 ),
        .MASTER5_WRITE_SLAVE9          ( 1 ),
        .MASTER5_WRITE_SLAVE10         ( 1 ),
        .MASTER5_WRITE_SLAVE11         ( 1 ),
        .MASTER5_WRITE_SLAVE12         ( 1 ),
        .MASTER5_WRITE_SLAVE13         ( 1 ),
        .MASTER5_WRITE_SLAVE14         ( 1 ),
        .MASTER5_WRITE_SLAVE15         ( 1 ),
        .MASTER5_WRITE_SLAVE16         ( 1 ),
        .MASTER5_WRITE_SLAVE17         ( 1 ),
        .MASTER5_WRITE_SLAVE18         ( 1 ),
        .MASTER5_WRITE_SLAVE19         ( 1 ),
        .MASTER5_WRITE_SLAVE20         ( 1 ),
        .MASTER5_WRITE_SLAVE21         ( 1 ),
        .MASTER5_WRITE_SLAVE22         ( 1 ),
        .MASTER5_WRITE_SLAVE23         ( 1 ),
        .MASTER5_WRITE_SLAVE24         ( 1 ),
        .MASTER5_WRITE_SLAVE25         ( 1 ),
        .MASTER5_WRITE_SLAVE26         ( 1 ),
        .MASTER5_WRITE_SLAVE27         ( 1 ),
        .MASTER5_WRITE_SLAVE28         ( 1 ),
        .MASTER5_WRITE_SLAVE29         ( 1 ),
        .MASTER5_WRITE_SLAVE30         ( 1 ),
        .MASTER5_WRITE_SLAVE31         ( 1 ),
        .MASTER6_ARCHAN_RS             ( 1 ),
        .MASTER6_AWCHAN_RS             ( 1 ),
        .MASTER6_BCHAN_RS              ( 1 ),
        .MASTER6_CLOCK_DOMAIN_CROSSING ( 0 ),
        .MASTER6_DATA_WIDTH            ( 32 ),
        .MASTER6_DEF_BURST_LEN         ( 0 ),
        .MASTER6_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .MASTER6_RCHAN_RS              ( 1 ),
        .MASTER6_READ_SLAVE0           ( 1 ),
        .MASTER6_READ_SLAVE1           ( 1 ),
        .MASTER6_READ_SLAVE2           ( 1 ),
        .MASTER6_READ_SLAVE3           ( 1 ),
        .MASTER6_READ_SLAVE4           ( 1 ),
        .MASTER6_READ_SLAVE5           ( 1 ),
        .MASTER6_READ_SLAVE6           ( 1 ),
        .MASTER6_READ_SLAVE7           ( 1 ),
        .MASTER6_READ_SLAVE8           ( 1 ),
        .MASTER6_READ_SLAVE9           ( 1 ),
        .MASTER6_READ_SLAVE10          ( 1 ),
        .MASTER6_READ_SLAVE11          ( 1 ),
        .MASTER6_READ_SLAVE12          ( 1 ),
        .MASTER6_READ_SLAVE13          ( 1 ),
        .MASTER6_READ_SLAVE14          ( 1 ),
        .MASTER6_READ_SLAVE15          ( 1 ),
        .MASTER6_READ_SLAVE16          ( 1 ),
        .MASTER6_READ_SLAVE17          ( 1 ),
        .MASTER6_READ_SLAVE18          ( 1 ),
        .MASTER6_READ_SLAVE19          ( 1 ),
        .MASTER6_READ_SLAVE20          ( 1 ),
        .MASTER6_READ_SLAVE21          ( 1 ),
        .MASTER6_READ_SLAVE22          ( 1 ),
        .MASTER6_READ_SLAVE23          ( 1 ),
        .MASTER6_READ_SLAVE24          ( 1 ),
        .MASTER6_READ_SLAVE25          ( 1 ),
        .MASTER6_READ_SLAVE26          ( 1 ),
        .MASTER6_READ_SLAVE27          ( 1 ),
        .MASTER6_READ_SLAVE28          ( 1 ),
        .MASTER6_READ_SLAVE29          ( 1 ),
        .MASTER6_READ_SLAVE30          ( 1 ),
        .MASTER6_READ_SLAVE31          ( 1 ),
        .MASTER6_TYPE                  ( 0 ),
        .MASTER6_WCHAN_RS              ( 1 ),
        .MASTER6_WRITE_SLAVE0          ( 1 ),
        .MASTER6_WRITE_SLAVE1          ( 1 ),
        .MASTER6_WRITE_SLAVE2          ( 1 ),
        .MASTER6_WRITE_SLAVE3          ( 1 ),
        .MASTER6_WRITE_SLAVE4          ( 1 ),
        .MASTER6_WRITE_SLAVE5          ( 1 ),
        .MASTER6_WRITE_SLAVE6          ( 1 ),
        .MASTER6_WRITE_SLAVE7          ( 1 ),
        .MASTER6_WRITE_SLAVE8          ( 1 ),
        .MASTER6_WRITE_SLAVE9          ( 1 ),
        .MASTER6_WRITE_SLAVE10         ( 1 ),
        .MASTER6_WRITE_SLAVE11         ( 1 ),
        .MASTER6_WRITE_SLAVE12         ( 1 ),
        .MASTER6_WRITE_SLAVE13         ( 1 ),
        .MASTER6_WRITE_SLAVE14         ( 1 ),
        .MASTER6_WRITE_SLAVE15         ( 1 ),
        .MASTER6_WRITE_SLAVE16         ( 1 ),
        .MASTER6_WRITE_SLAVE17         ( 1 ),
        .MASTER6_WRITE_SLAVE18         ( 1 ),
        .MASTER6_WRITE_SLAVE19         ( 1 ),
        .MASTER6_WRITE_SLAVE20         ( 1 ),
        .MASTER6_WRITE_SLAVE21         ( 1 ),
        .MASTER6_WRITE_SLAVE22         ( 1 ),
        .MASTER6_WRITE_SLAVE23         ( 1 ),
        .MASTER6_WRITE_SLAVE24         ( 1 ),
        .MASTER6_WRITE_SLAVE25         ( 1 ),
        .MASTER6_WRITE_SLAVE26         ( 1 ),
        .MASTER6_WRITE_SLAVE27         ( 1 ),
        .MASTER6_WRITE_SLAVE28         ( 1 ),
        .MASTER6_WRITE_SLAVE29         ( 1 ),
        .MASTER6_WRITE_SLAVE30         ( 1 ),
        .MASTER6_WRITE_SLAVE31         ( 1 ),
        .MASTER7_ARCHAN_RS             ( 1 ),
        .MASTER7_AWCHAN_RS             ( 1 ),
        .MASTER7_BCHAN_RS              ( 1 ),
        .MASTER7_CLOCK_DOMAIN_CROSSING ( 0 ),
        .MASTER7_DATA_WIDTH            ( 32 ),
        .MASTER7_DEF_BURST_LEN         ( 0 ),
        .MASTER7_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .MASTER7_RCHAN_RS              ( 1 ),
        .MASTER7_READ_SLAVE0           ( 1 ),
        .MASTER7_READ_SLAVE1           ( 1 ),
        .MASTER7_READ_SLAVE2           ( 1 ),
        .MASTER7_READ_SLAVE3           ( 1 ),
        .MASTER7_READ_SLAVE4           ( 1 ),
        .MASTER7_READ_SLAVE5           ( 1 ),
        .MASTER7_READ_SLAVE6           ( 1 ),
        .MASTER7_READ_SLAVE7           ( 1 ),
        .MASTER7_READ_SLAVE8           ( 1 ),
        .MASTER7_READ_SLAVE9           ( 1 ),
        .MASTER7_READ_SLAVE10          ( 1 ),
        .MASTER7_READ_SLAVE11          ( 1 ),
        .MASTER7_READ_SLAVE12          ( 1 ),
        .MASTER7_READ_SLAVE13          ( 1 ),
        .MASTER7_READ_SLAVE14          ( 1 ),
        .MASTER7_READ_SLAVE15          ( 1 ),
        .MASTER7_READ_SLAVE16          ( 1 ),
        .MASTER7_READ_SLAVE17          ( 1 ),
        .MASTER7_READ_SLAVE18          ( 1 ),
        .MASTER7_READ_SLAVE19          ( 1 ),
        .MASTER7_READ_SLAVE20          ( 1 ),
        .MASTER7_READ_SLAVE21          ( 1 ),
        .MASTER7_READ_SLAVE22          ( 1 ),
        .MASTER7_READ_SLAVE23          ( 1 ),
        .MASTER7_READ_SLAVE24          ( 1 ),
        .MASTER7_READ_SLAVE25          ( 1 ),
        .MASTER7_READ_SLAVE26          ( 1 ),
        .MASTER7_READ_SLAVE27          ( 1 ),
        .MASTER7_READ_SLAVE28          ( 1 ),
        .MASTER7_READ_SLAVE29          ( 1 ),
        .MASTER7_READ_SLAVE30          ( 1 ),
        .MASTER7_READ_SLAVE31          ( 1 ),
        .MASTER7_TYPE                  ( 0 ),
        .MASTER7_WCHAN_RS              ( 1 ),
        .MASTER7_WRITE_SLAVE0          ( 1 ),
        .MASTER7_WRITE_SLAVE1          ( 1 ),
        .MASTER7_WRITE_SLAVE2          ( 1 ),
        .MASTER7_WRITE_SLAVE3          ( 1 ),
        .MASTER7_WRITE_SLAVE4          ( 1 ),
        .MASTER7_WRITE_SLAVE5          ( 1 ),
        .MASTER7_WRITE_SLAVE6          ( 1 ),
        .MASTER7_WRITE_SLAVE7          ( 1 ),
        .MASTER7_WRITE_SLAVE8          ( 1 ),
        .MASTER7_WRITE_SLAVE9          ( 1 ),
        .MASTER7_WRITE_SLAVE10         ( 1 ),
        .MASTER7_WRITE_SLAVE11         ( 1 ),
        .MASTER7_WRITE_SLAVE12         ( 1 ),
        .MASTER7_WRITE_SLAVE13         ( 1 ),
        .MASTER7_WRITE_SLAVE14         ( 1 ),
        .MASTER7_WRITE_SLAVE15         ( 1 ),
        .MASTER7_WRITE_SLAVE16         ( 1 ),
        .MASTER7_WRITE_SLAVE17         ( 1 ),
        .MASTER7_WRITE_SLAVE18         ( 1 ),
        .MASTER7_WRITE_SLAVE19         ( 1 ),
        .MASTER7_WRITE_SLAVE20         ( 1 ),
        .MASTER7_WRITE_SLAVE21         ( 1 ),
        .MASTER7_WRITE_SLAVE22         ( 1 ),
        .MASTER7_WRITE_SLAVE23         ( 1 ),
        .MASTER7_WRITE_SLAVE24         ( 1 ),
        .MASTER7_WRITE_SLAVE25         ( 1 ),
        .MASTER7_WRITE_SLAVE26         ( 1 ),
        .MASTER7_WRITE_SLAVE27         ( 1 ),
        .MASTER7_WRITE_SLAVE28         ( 1 ),
        .MASTER7_WRITE_SLAVE29         ( 1 ),
        .MASTER7_WRITE_SLAVE30         ( 1 ),
        .MASTER7_WRITE_SLAVE31         ( 1 ),
        .NUM_MASTERS                   ( 1 ),
        .NUM_MASTERS_WIDTH             ( 1 ),
        .NUM_SLAVES                    ( 8 ),
        .NUM_THREADS                   ( 1 ),
        .OPEN_TRANS_MAX                ( 2 ),
        .RD_ARB_EN                     ( 0 ),
        .SLAVE0_ARCHAN_RS              ( 0 ),
        .SLAVE0_AWCHAN_RS              ( 0 ),
        .SLAVE0_BCHAN_RS               ( 0 ),
        .SLAVE0_CLOCK_DOMAIN_CROSSING  ( 0 ),
        .SLAVE0_DATA_WIDTH             ( 32 ),
        .SLAVE0_DWC_DATA_FIFO_DEPTH    ( 16 ),
        .SLAVE0_RCHAN_RS               ( 0 ),
        .SLAVE0_TYPE                   ( 3 ),
        .SLAVE0_WCHAN_RS               ( 0 ),
        .SLAVE1_ARCHAN_RS              ( 0 ),
        .SLAVE1_AWCHAN_RS              ( 0 ),
        .SLAVE1_BCHAN_RS               ( 0 ),
        .SLAVE1_CLOCK_DOMAIN_CROSSING  ( 0 ),
        .SLAVE1_DATA_WIDTH             ( 32 ),
        .SLAVE1_DWC_DATA_FIFO_DEPTH    ( 16 ),
        .SLAVE1_RCHAN_RS               ( 0 ),
        .SLAVE1_TYPE                   ( 3 ),
        .SLAVE1_WCHAN_RS               ( 0 ),
        .SLAVE2_ARCHAN_RS              ( 0 ),
        .SLAVE2_AWCHAN_RS              ( 0 ),
        .SLAVE2_BCHAN_RS               ( 0 ),
        .SLAVE2_CLOCK_DOMAIN_CROSSING  ( 0 ),
        .SLAVE2_DATA_WIDTH             ( 32 ),
        .SLAVE2_DWC_DATA_FIFO_DEPTH    ( 16 ),
        .SLAVE2_RCHAN_RS               ( 0 ),
        .SLAVE2_TYPE                   ( 3 ),
        .SLAVE2_WCHAN_RS               ( 0 ),
        .SLAVE3_ARCHAN_RS              ( 0 ),
        .SLAVE3_AWCHAN_RS              ( 0 ),
        .SLAVE3_BCHAN_RS               ( 0 ),
        .SLAVE3_CLOCK_DOMAIN_CROSSING  ( 0 ),
        .SLAVE3_DATA_WIDTH             ( 32 ),
        .SLAVE3_DWC_DATA_FIFO_DEPTH    ( 16 ),
        .SLAVE3_RCHAN_RS               ( 0 ),
        .SLAVE3_TYPE                   ( 3 ),
        .SLAVE3_WCHAN_RS               ( 0 ),
        .SLAVE4_ARCHAN_RS              ( 0 ),
        .SLAVE4_AWCHAN_RS              ( 0 ),
        .SLAVE4_BCHAN_RS               ( 0 ),
        .SLAVE4_CLOCK_DOMAIN_CROSSING  ( 0 ),
        .SLAVE4_DATA_WIDTH             ( 32 ),
        .SLAVE4_DWC_DATA_FIFO_DEPTH    ( 16 ),
        .SLAVE4_RCHAN_RS               ( 0 ),
        .SLAVE4_TYPE                   ( 3 ),
        .SLAVE4_WCHAN_RS               ( 0 ),
        .SLAVE5_ARCHAN_RS              ( 0 ),
        .SLAVE5_AWCHAN_RS              ( 0 ),
        .SLAVE5_BCHAN_RS               ( 0 ),
        .SLAVE5_CLOCK_DOMAIN_CROSSING  ( 0 ),
        .SLAVE5_DATA_WIDTH             ( 32 ),
        .SLAVE5_DWC_DATA_FIFO_DEPTH    ( 16 ),
        .SLAVE5_RCHAN_RS               ( 0 ),
        .SLAVE5_TYPE                   ( 3 ),
        .SLAVE5_WCHAN_RS               ( 0 ),
        .SLAVE6_ARCHAN_RS              ( 0 ),
        .SLAVE6_AWCHAN_RS              ( 0 ),
        .SLAVE6_BCHAN_RS               ( 0 ),
        .SLAVE6_CLOCK_DOMAIN_CROSSING  ( 0 ),
        .SLAVE6_DATA_WIDTH             ( 32 ),
        .SLAVE6_DWC_DATA_FIFO_DEPTH    ( 16 ),
        .SLAVE6_RCHAN_RS               ( 0 ),
        .SLAVE6_TYPE                   ( 3 ),
        .SLAVE6_WCHAN_RS               ( 0 ),
        .SLAVE7_ARCHAN_RS              ( 0 ),
        .SLAVE7_AWCHAN_RS              ( 0 ),
        .SLAVE7_BCHAN_RS               ( 0 ),
        .SLAVE7_CLOCK_DOMAIN_CROSSING  ( 0 ),
        .SLAVE7_DATA_WIDTH             ( 32 ),
        .SLAVE7_DWC_DATA_FIFO_DEPTH    ( 16 ),
        .SLAVE7_RCHAN_RS               ( 0 ),
        .SLAVE7_TYPE                   ( 3 ),
        .SLAVE7_WCHAN_RS               ( 0 ),
        .SLAVE8_ARCHAN_RS              ( 1 ),
        .SLAVE8_AWCHAN_RS              ( 1 ),
        .SLAVE8_BCHAN_RS               ( 1 ),
        .SLAVE8_CLOCK_DOMAIN_CROSSING  ( 0 ),
        .SLAVE8_DATA_WIDTH             ( 32 ),
        .SLAVE8_DWC_DATA_FIFO_DEPTH    ( 16 ),
        .SLAVE8_RCHAN_RS               ( 1 ),
        .SLAVE8_TYPE                   ( 0 ),
        .SLAVE8_WCHAN_RS               ( 1 ),
        .SLAVE9_ARCHAN_RS              ( 1 ),
        .SLAVE9_AWCHAN_RS              ( 1 ),
        .SLAVE9_BCHAN_RS               ( 1 ),
        .SLAVE9_CLOCK_DOMAIN_CROSSING  ( 0 ),
        .SLAVE9_DATA_WIDTH             ( 32 ),
        .SLAVE9_DWC_DATA_FIFO_DEPTH    ( 16 ),
        .SLAVE9_RCHAN_RS               ( 1 ),
        .SLAVE9_TYPE                   ( 0 ),
        .SLAVE9_WCHAN_RS               ( 1 ),
        .SLAVE10_ARCHAN_RS             ( 1 ),
        .SLAVE10_AWCHAN_RS             ( 1 ),
        .SLAVE10_BCHAN_RS              ( 1 ),
        .SLAVE10_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE10_DATA_WIDTH            ( 32 ),
        .SLAVE10_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE10_RCHAN_RS              ( 1 ),
        .SLAVE10_TYPE                  ( 0 ),
        .SLAVE10_WCHAN_RS              ( 1 ),
        .SLAVE11_ARCHAN_RS             ( 1 ),
        .SLAVE11_AWCHAN_RS             ( 1 ),
        .SLAVE11_BCHAN_RS              ( 1 ),
        .SLAVE11_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE11_DATA_WIDTH            ( 32 ),
        .SLAVE11_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE11_RCHAN_RS              ( 1 ),
        .SLAVE11_TYPE                  ( 0 ),
        .SLAVE11_WCHAN_RS              ( 1 ),
        .SLAVE12_ARCHAN_RS             ( 1 ),
        .SLAVE12_AWCHAN_RS             ( 1 ),
        .SLAVE12_BCHAN_RS              ( 1 ),
        .SLAVE12_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE12_DATA_WIDTH            ( 32 ),
        .SLAVE12_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE12_RCHAN_RS              ( 1 ),
        .SLAVE12_TYPE                  ( 0 ),
        .SLAVE12_WCHAN_RS              ( 1 ),
        .SLAVE13_ARCHAN_RS             ( 1 ),
        .SLAVE13_AWCHAN_RS             ( 1 ),
        .SLAVE13_BCHAN_RS              ( 1 ),
        .SLAVE13_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE13_DATA_WIDTH            ( 32 ),
        .SLAVE13_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE13_RCHAN_RS              ( 1 ),
        .SLAVE13_TYPE                  ( 0 ),
        .SLAVE13_WCHAN_RS              ( 1 ),
        .SLAVE14_ARCHAN_RS             ( 1 ),
        .SLAVE14_AWCHAN_RS             ( 1 ),
        .SLAVE14_BCHAN_RS              ( 1 ),
        .SLAVE14_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE14_DATA_WIDTH            ( 32 ),
        .SLAVE14_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE14_RCHAN_RS              ( 1 ),
        .SLAVE14_TYPE                  ( 0 ),
        .SLAVE14_WCHAN_RS              ( 1 ),
        .SLAVE15_ARCHAN_RS             ( 1 ),
        .SLAVE15_AWCHAN_RS             ( 1 ),
        .SLAVE15_BCHAN_RS              ( 1 ),
        .SLAVE15_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE15_DATA_WIDTH            ( 32 ),
        .SLAVE15_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE15_RCHAN_RS              ( 1 ),
        .SLAVE15_TYPE                  ( 0 ),
        .SLAVE15_WCHAN_RS              ( 1 ),
        .SLAVE16_ARCHAN_RS             ( 1 ),
        .SLAVE16_AWCHAN_RS             ( 1 ),
        .SLAVE16_BCHAN_RS              ( 1 ),
        .SLAVE16_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE16_DATA_WIDTH            ( 32 ),
        .SLAVE16_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE16_RCHAN_RS              ( 1 ),
        .SLAVE16_TYPE                  ( 0 ),
        .SLAVE16_WCHAN_RS              ( 1 ),
        .SLAVE17_ARCHAN_RS             ( 1 ),
        .SLAVE17_AWCHAN_RS             ( 1 ),
        .SLAVE17_BCHAN_RS              ( 1 ),
        .SLAVE17_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE17_DATA_WIDTH            ( 32 ),
        .SLAVE17_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE17_RCHAN_RS              ( 1 ),
        .SLAVE17_TYPE                  ( 0 ),
        .SLAVE17_WCHAN_RS              ( 1 ),
        .SLAVE18_ARCHAN_RS             ( 1 ),
        .SLAVE18_AWCHAN_RS             ( 1 ),
        .SLAVE18_BCHAN_RS              ( 1 ),
        .SLAVE18_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE18_DATA_WIDTH            ( 32 ),
        .SLAVE18_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE18_RCHAN_RS              ( 1 ),
        .SLAVE18_TYPE                  ( 0 ),
        .SLAVE18_WCHAN_RS              ( 1 ),
        .SLAVE19_ARCHAN_RS             ( 1 ),
        .SLAVE19_AWCHAN_RS             ( 1 ),
        .SLAVE19_BCHAN_RS              ( 1 ),
        .SLAVE19_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE19_DATA_WIDTH            ( 32 ),
        .SLAVE19_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE19_RCHAN_RS              ( 1 ),
        .SLAVE19_TYPE                  ( 0 ),
        .SLAVE19_WCHAN_RS              ( 1 ),
        .SLAVE20_ARCHAN_RS             ( 1 ),
        .SLAVE20_AWCHAN_RS             ( 1 ),
        .SLAVE20_BCHAN_RS              ( 1 ),
        .SLAVE20_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE20_DATA_WIDTH            ( 32 ),
        .SLAVE20_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE20_RCHAN_RS              ( 1 ),
        .SLAVE20_TYPE                  ( 0 ),
        .SLAVE20_WCHAN_RS              ( 1 ),
        .SLAVE21_ARCHAN_RS             ( 1 ),
        .SLAVE21_AWCHAN_RS             ( 1 ),
        .SLAVE21_BCHAN_RS              ( 1 ),
        .SLAVE21_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE21_DATA_WIDTH            ( 32 ),
        .SLAVE21_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE21_RCHAN_RS              ( 1 ),
        .SLAVE21_TYPE                  ( 0 ),
        .SLAVE21_WCHAN_RS              ( 1 ),
        .SLAVE22_ARCHAN_RS             ( 1 ),
        .SLAVE22_AWCHAN_RS             ( 1 ),
        .SLAVE22_BCHAN_RS              ( 1 ),
        .SLAVE22_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE22_DATA_WIDTH            ( 32 ),
        .SLAVE22_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE22_RCHAN_RS              ( 1 ),
        .SLAVE22_TYPE                  ( 0 ),
        .SLAVE22_WCHAN_RS              ( 1 ),
        .SLAVE23_ARCHAN_RS             ( 1 ),
        .SLAVE23_AWCHAN_RS             ( 1 ),
        .SLAVE23_BCHAN_RS              ( 1 ),
        .SLAVE23_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE23_DATA_WIDTH            ( 32 ),
        .SLAVE23_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE23_RCHAN_RS              ( 1 ),
        .SLAVE23_TYPE                  ( 0 ),
        .SLAVE23_WCHAN_RS              ( 1 ),
        .SLAVE24_ARCHAN_RS             ( 1 ),
        .SLAVE24_AWCHAN_RS             ( 1 ),
        .SLAVE24_BCHAN_RS              ( 1 ),
        .SLAVE24_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE24_DATA_WIDTH            ( 32 ),
        .SLAVE24_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE24_RCHAN_RS              ( 1 ),
        .SLAVE24_TYPE                  ( 0 ),
        .SLAVE24_WCHAN_RS              ( 1 ),
        .SLAVE25_ARCHAN_RS             ( 1 ),
        .SLAVE25_AWCHAN_RS             ( 1 ),
        .SLAVE25_BCHAN_RS              ( 1 ),
        .SLAVE25_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE25_DATA_WIDTH            ( 32 ),
        .SLAVE25_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE25_RCHAN_RS              ( 1 ),
        .SLAVE25_TYPE                  ( 0 ),
        .SLAVE25_WCHAN_RS              ( 1 ),
        .SLAVE26_ARCHAN_RS             ( 1 ),
        .SLAVE26_AWCHAN_RS             ( 1 ),
        .SLAVE26_BCHAN_RS              ( 1 ),
        .SLAVE26_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE26_DATA_WIDTH            ( 32 ),
        .SLAVE26_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE26_RCHAN_RS              ( 1 ),
        .SLAVE26_TYPE                  ( 0 ),
        .SLAVE26_WCHAN_RS              ( 1 ),
        .SLAVE27_ARCHAN_RS             ( 1 ),
        .SLAVE27_AWCHAN_RS             ( 1 ),
        .SLAVE27_BCHAN_RS              ( 1 ),
        .SLAVE27_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE27_DATA_WIDTH            ( 32 ),
        .SLAVE27_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE27_RCHAN_RS              ( 1 ),
        .SLAVE27_TYPE                  ( 0 ),
        .SLAVE27_WCHAN_RS              ( 1 ),
        .SLAVE28_ARCHAN_RS             ( 1 ),
        .SLAVE28_AWCHAN_RS             ( 1 ),
        .SLAVE28_BCHAN_RS              ( 1 ),
        .SLAVE28_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE28_DATA_WIDTH            ( 32 ),
        .SLAVE28_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE28_RCHAN_RS              ( 1 ),
        .SLAVE28_TYPE                  ( 0 ),
        .SLAVE28_WCHAN_RS              ( 1 ),
        .SLAVE29_ARCHAN_RS             ( 1 ),
        .SLAVE29_AWCHAN_RS             ( 1 ),
        .SLAVE29_BCHAN_RS              ( 1 ),
        .SLAVE29_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE29_DATA_WIDTH            ( 32 ),
        .SLAVE29_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE29_RCHAN_RS              ( 1 ),
        .SLAVE29_TYPE                  ( 0 ),
        .SLAVE29_WCHAN_RS              ( 1 ),
        .SLAVE30_ARCHAN_RS             ( 1 ),
        .SLAVE30_AWCHAN_RS             ( 1 ),
        .SLAVE30_BCHAN_RS              ( 1 ),
        .SLAVE30_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE30_DATA_WIDTH            ( 32 ),
        .SLAVE30_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE30_RCHAN_RS              ( 1 ),
        .SLAVE30_TYPE                  ( 0 ),
        .SLAVE30_WCHAN_RS              ( 1 ),
        .SLAVE31_ARCHAN_RS             ( 1 ),
        .SLAVE31_AWCHAN_RS             ( 1 ),
        .SLAVE31_BCHAN_RS              ( 1 ),
        .SLAVE31_CLOCK_DOMAIN_CROSSING ( 0 ),
        .SLAVE31_DATA_WIDTH            ( 32 ),
        .SLAVE31_DWC_DATA_FIFO_DEPTH   ( 16 ),
        .SLAVE31_RCHAN_RS              ( 1 ),
        .SLAVE31_TYPE                  ( 0 ),
        .SLAVE31_WCHAN_RS              ( 1 ),
        .SLOT0_BASE_VEC                ( 0 ),
        .SLOT0_MAX_VEC                 ( 7 ),
        .SLOT0_MIN_VEC                 ( 0 ),
        .SLOT1_BASE_VEC                ( 1 ),
        .SLOT1_MAX_VEC                 ( 65535 ),
        .SLOT1_MIN_VEC                 ( 0 ),
        .SLOT2_BASE_VEC                ( 2 ),
        .SLOT2_MAX_VEC                 ( 65535 ),
        .SLOT2_MIN_VEC                 ( 0 ),
        .SLOT3_BASE_VEC                ( 3 ),
        .SLOT3_MAX_VEC                 ( 65535 ),
        .SLOT3_MIN_VEC                 ( 0 ),
        .SLOT4_BASE_VEC                ( 4 ),
        .SLOT4_MAX_VEC                 ( 65535 ),
        .SLOT4_MIN_VEC                 ( 0 ),
        .SLOT5_BASE_VEC                ( 5 ),
        .SLOT5_MAX_VEC                 ( 65535 ),
        .SLOT5_MIN_VEC                 ( 0 ),
        .SLOT6_BASE_VEC                ( 6 ),
        .SLOT6_MAX_VEC                 ( 65535 ),
        .SLOT6_MIN_VEC                 ( 0 ),
        .SLOT7_BASE_VEC                ( 0 ),
        .SLOT7_MAX_VEC                 ( 65535 ),
        .SLOT7_MIN_VEC                 ( 8 ),
        .SLOT8_BASE_VEC                ( 8 ),
        .SLOT8_MAX_VEC                 ( 2147483647 ),
        .SLOT8_MIN_VEC                 ( 0 ),
        .SLOT9_BASE_VEC                ( 9 ),
        .SLOT9_MAX_VEC                 ( 2147483647 ),
        .SLOT9_MIN_VEC                 ( 0 ),
        .SLOT10_BASE_VEC               ( 10 ),
        .SLOT10_MAX_VEC                ( 2147483647 ),
        .SLOT10_MIN_VEC                ( 0 ),
        .SLOT11_BASE_VEC               ( 11 ),
        .SLOT11_MAX_VEC                ( 2147483647 ),
        .SLOT11_MIN_VEC                ( 0 ),
        .SLOT12_BASE_VEC               ( 12 ),
        .SLOT12_MAX_VEC                ( 2147483647 ),
        .SLOT12_MIN_VEC                ( 0 ),
        .SLOT13_BASE_VEC               ( 13 ),
        .SLOT13_MAX_VEC                ( 2147483647 ),
        .SLOT13_MIN_VEC                ( 0 ),
        .SLOT14_BASE_VEC               ( 14 ),
        .SLOT14_MAX_VEC                ( 2147483647 ),
        .SLOT14_MIN_VEC                ( 0 ),
        .SLOT15_BASE_VEC               ( 15 ),
        .SLOT15_MAX_VEC                ( 2147483647 ),
        .SLOT15_MIN_VEC                ( 0 ),
        .SLOT16_BASE_VEC               ( 16 ),
        .SLOT16_MAX_VEC                ( 2147483647 ),
        .SLOT16_MIN_VEC                ( 0 ),
        .SLOT17_BASE_VEC               ( 17 ),
        .SLOT17_MAX_VEC                ( 2147483647 ),
        .SLOT17_MIN_VEC                ( 0 ),
        .SLOT18_BASE_VEC               ( 18 ),
        .SLOT18_MAX_VEC                ( 2147483647 ),
        .SLOT18_MIN_VEC                ( 0 ),
        .SLOT19_BASE_VEC               ( 19 ),
        .SLOT19_MAX_VEC                ( 2147483647 ),
        .SLOT19_MIN_VEC                ( 0 ),
        .SLOT20_BASE_VEC               ( 20 ),
        .SLOT20_MAX_VEC                ( 2147483647 ),
        .SLOT20_MIN_VEC                ( 0 ),
        .SLOT21_BASE_VEC               ( 21 ),
        .SLOT21_MAX_VEC                ( 2147483647 ),
        .SLOT21_MIN_VEC                ( 0 ),
        .SLOT22_BASE_VEC               ( 22 ),
        .SLOT22_MAX_VEC                ( 2147483647 ),
        .SLOT22_MIN_VEC                ( 0 ),
        .SLOT23_BASE_VEC               ( 23 ),
        .SLOT23_MAX_VEC                ( 2147483647 ),
        .SLOT23_MIN_VEC                ( 0 ),
        .SLOT24_BASE_VEC               ( 24 ),
        .SLOT24_MAX_VEC                ( 2147483647 ),
        .SLOT24_MIN_VEC                ( 0 ),
        .SLOT25_BASE_VEC               ( 25 ),
        .SLOT25_MAX_VEC                ( 2147483647 ),
        .SLOT25_MIN_VEC                ( 0 ),
        .SLOT26_BASE_VEC               ( 26 ),
        .SLOT26_MAX_VEC                ( 2147483647 ),
        .SLOT26_MIN_VEC                ( 0 ),
        .SLOT27_BASE_VEC               ( 27 ),
        .SLOT27_MAX_VEC                ( 2147483647 ),
        .SLOT27_MIN_VEC                ( 0 ),
        .SLOT28_BASE_VEC               ( 28 ),
        .SLOT28_MAX_VEC                ( 2147483647 ),
        .SLOT28_MIN_VEC                ( 0 ),
        .SLOT29_BASE_VEC               ( 29 ),
        .SLOT29_MAX_VEC                ( 2147483647 ),
        .SLOT29_MIN_VEC                ( 0 ),
        .SLOT30_BASE_VEC               ( 30 ),
        .SLOT30_MAX_VEC                ( 2147483647 ),
        .SLOT30_MIN_VEC                ( 0 ),
        .SLOT31_BASE_VEC               ( 31 ),
        .SLOT31_MAX_VEC                ( 2147483647 ),
        .SLOT31_MIN_VEC                ( 0 ),
        .SLV_AXI4PRT_ADDRDEPTH         ( 4 ),
        .SLV_AXI4PRT_DATADEPTH         ( 4 ),
        .SUPPORT_USER_SIGNALS          ( 0 ),
        .UPPER_COMPARE_BIT             ( 28 ),
        .USER_WIDTH                    ( 1 ) )
CoreAXI4Interconnect_0(
        // Inputs
        .ACLK              ( my_mss_top_0_FIC_0_CLK_1 ),
        .ARESETN           ( my_mss_top_0_MSS_READY_0 ),
        .MASTER0_AWVALID   ( microsemi_wrapper_0_DATA_MASTER_AWVALID ),
        .MASTER1_AWVALID   ( GND_net ), // tied to 1'b0 from definition
        .MASTER2_AWVALID   ( GND_net ), // tied to 1'b0 from definition
        .MASTER3_AWVALID   ( GND_net ), // tied to 1'b0 from definition
        .MASTER4_AWVALID   ( GND_net ), // tied to 1'b0 from definition
        .MASTER5_AWVALID   ( GND_net ), // tied to 1'b0 from definition
        .MASTER6_AWVALID   ( GND_net ), // tied to 1'b0 from definition
        .MASTER7_AWVALID   ( GND_net ), // tied to 1'b0 from definition
        .MASTER0_WLAST     ( microsemi_wrapper_0_DATA_MASTER_WLAST ),
        .MASTER0_WVALID    ( microsemi_wrapper_0_DATA_MASTER_WVALID ),
        .MASTER1_WLAST     ( GND_net ), // tied to 1'b0 from definition
        .MASTER1_WVALID    ( GND_net ), // tied to 1'b0 from definition
        .MASTER2_WLAST     ( GND_net ), // tied to 1'b0 from definition
        .MASTER2_WVALID    ( GND_net ), // tied to 1'b0 from definition
        .MASTER3_WLAST     ( GND_net ), // tied to 1'b0 from definition
        .MASTER3_WVALID    ( GND_net ), // tied to 1'b0 from definition
        .MASTER4_WLAST     ( GND_net ), // tied to 1'b0 from definition
        .MASTER4_WVALID    ( GND_net ), // tied to 1'b0 from definition
        .MASTER5_WLAST     ( GND_net ), // tied to 1'b0 from definition
        .MASTER5_WVALID    ( GND_net ), // tied to 1'b0 from definition
        .MASTER6_WLAST     ( GND_net ), // tied to 1'b0 from definition
        .MASTER6_WVALID    ( GND_net ), // tied to 1'b0 from definition
        .MASTER7_WLAST     ( GND_net ), // tied to 1'b0 from definition
        .MASTER7_WVALID    ( GND_net ), // tied to 1'b0 from definition
        .MASTER0_BREADY    ( microsemi_wrapper_0_DATA_MASTER_BREADY ),
        .MASTER1_BREADY    ( GND_net ), // tied to 1'b0 from definition
        .MASTER2_BREADY    ( GND_net ), // tied to 1'b0 from definition
        .MASTER3_BREADY    ( GND_net ), // tied to 1'b0 from definition
        .MASTER4_BREADY    ( GND_net ), // tied to 1'b0 from definition
        .MASTER5_BREADY    ( GND_net ), // tied to 1'b0 from definition
        .MASTER6_BREADY    ( GND_net ), // tied to 1'b0 from definition
        .MASTER7_BREADY    ( GND_net ), // tied to 1'b0 from definition
        .MASTER0_ARVALID   ( microsemi_wrapper_0_DATA_MASTER_ARVALID ),
        .MASTER1_ARVALID   ( GND_net ), // tied to 1'b0 from definition
        .MASTER2_ARVALID   ( GND_net ), // tied to 1'b0 from definition
        .MASTER3_ARVALID   ( GND_net ), // tied to 1'b0 from definition
        .MASTER4_ARVALID   ( GND_net ), // tied to 1'b0 from definition
        .MASTER5_ARVALID   ( GND_net ), // tied to 1'b0 from definition
        .MASTER6_ARVALID   ( GND_net ), // tied to 1'b0 from definition
        .MASTER7_ARVALID   ( GND_net ), // tied to 1'b0 from definition
        .MASTER0_RREADY    ( microsemi_wrapper_0_DATA_MASTER_RREADY ),
        .MASTER1_RREADY    ( GND_net ), // tied to 1'b0 from definition
        .MASTER2_RREADY    ( GND_net ), // tied to 1'b0 from definition
        .MASTER3_RREADY    ( GND_net ), // tied to 1'b0 from definition
        .MASTER4_RREADY    ( GND_net ), // tied to 1'b0 from definition
        .MASTER5_RREADY    ( GND_net ), // tied to 1'b0 from definition
        .MASTER6_RREADY    ( GND_net ), // tied to 1'b0 from definition
        .MASTER7_RREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE0_AWREADY    ( CoreAXI4Interconnect_0_AXI3mslave0_AWREADY ),
        .SLAVE1_AWREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE2_AWREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE3_AWREADY    ( CoreAXI4Interconnect_0_AXI3mslave3_AWREADY ),
        .SLAVE4_AWREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE5_AWREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE6_AWREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE7_AWREADY    ( CoreAXI4Interconnect_0_AXI3mslave7_AWREADY ),
        .SLAVE0_WREADY     ( CoreAXI4Interconnect_0_AXI3mslave0_WREADY ),
        .SLAVE1_WREADY     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE2_WREADY     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE3_WREADY     ( CoreAXI4Interconnect_0_AXI3mslave3_WREADY ),
        .SLAVE4_WREADY     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE5_WREADY     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE6_WREADY     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE7_WREADY     ( CoreAXI4Interconnect_0_AXI3mslave7_WREADY ),
        .SLAVE0_BVALID     ( CoreAXI4Interconnect_0_AXI3mslave0_BVALID ),
        .SLAVE1_BVALID     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE2_BVALID     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE3_BVALID     ( CoreAXI4Interconnect_0_AXI3mslave3_BVALID ),
        .SLAVE4_BVALID     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE5_BVALID     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE6_BVALID     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE7_BVALID     ( CoreAXI4Interconnect_0_AXI3mslave7_BVALID ),
        .SLAVE0_ARREADY    ( CoreAXI4Interconnect_0_AXI3mslave0_ARREADY ),
        .SLAVE1_ARREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE2_ARREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE3_ARREADY    ( CoreAXI4Interconnect_0_AXI3mslave3_ARREADY ),
        .SLAVE4_ARREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE5_ARREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE6_ARREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE7_ARREADY    ( CoreAXI4Interconnect_0_AXI3mslave7_ARREADY ),
        .SLAVE0_RLAST      ( CoreAXI4Interconnect_0_AXI3mslave0_RLAST ),
        .SLAVE0_RVALID     ( CoreAXI4Interconnect_0_AXI3mslave0_RVALID ),
        .SLAVE1_RLAST      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE1_RVALID     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE2_RLAST      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE2_RVALID     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE3_RLAST      ( CoreAXI4Interconnect_0_AXI3mslave3_RLAST ),
        .SLAVE3_RVALID     ( CoreAXI4Interconnect_0_AXI3mslave3_RVALID ),
        .SLAVE4_RLAST      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE4_RVALID     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE5_RLAST      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE5_RVALID     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE6_RLAST      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE6_RVALID     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE7_RLAST      ( CoreAXI4Interconnect_0_AXI3mslave7_RLAST ),
        .SLAVE7_RVALID     ( CoreAXI4Interconnect_0_AXI3mslave7_RVALID ),
        .MASTER0_HMASTLOCK ( GND_net ), // tied to 1'b0 from definition
        .MASTER0_HNONSEC   ( GND_net ), // tied to 1'b0 from definition
        .MASTER0_HWRITE    ( GND_net ), // tied to 1'b0 from definition
        .MASTER0_HSEL      ( GND_net ), // tied to 1'b0 from definition
        .MASTER1_HMASTLOCK ( GND_net ), // tied to 1'b0 from definition
        .MASTER1_HNONSEC   ( GND_net ), // tied to 1'b0 from definition
        .MASTER1_HWRITE    ( GND_net ), // tied to 1'b0 from definition
        .MASTER1_HSEL      ( GND_net ), // tied to 1'b0 from definition
        .MASTER2_HMASTLOCK ( GND_net ), // tied to 1'b0 from definition
        .MASTER2_HNONSEC   ( GND_net ), // tied to 1'b0 from definition
        .MASTER2_HWRITE    ( GND_net ), // tied to 1'b0 from definition
        .MASTER2_HSEL      ( GND_net ), // tied to 1'b0 from definition
        .MASTER3_HMASTLOCK ( GND_net ), // tied to 1'b0 from definition
        .MASTER3_HNONSEC   ( GND_net ), // tied to 1'b0 from definition
        .MASTER3_HWRITE    ( GND_net ), // tied to 1'b0 from definition
        .MASTER3_HSEL      ( GND_net ), // tied to 1'b0 from definition
        .MASTER4_HMASTLOCK ( GND_net ), // tied to 1'b0 from definition
        .MASTER4_HNONSEC   ( GND_net ), // tied to 1'b0 from definition
        .MASTER4_HWRITE    ( GND_net ), // tied to 1'b0 from definition
        .MASTER4_HSEL      ( GND_net ), // tied to 1'b0 from definition
        .MASTER5_HMASTLOCK ( GND_net ), // tied to 1'b0 from definition
        .MASTER5_HNONSEC   ( GND_net ), // tied to 1'b0 from definition
        .MASTER5_HWRITE    ( GND_net ), // tied to 1'b0 from definition
        .MASTER5_HSEL      ( GND_net ), // tied to 1'b0 from definition
        .MASTER6_HMASTLOCK ( GND_net ), // tied to 1'b0 from definition
        .MASTER6_HNONSEC   ( GND_net ), // tied to 1'b0 from definition
        .MASTER6_HWRITE    ( GND_net ), // tied to 1'b0 from definition
        .MASTER6_HSEL      ( GND_net ), // tied to 1'b0 from definition
        .MASTER7_HMASTLOCK ( GND_net ), // tied to 1'b0 from definition
        .MASTER7_HNONSEC   ( GND_net ), // tied to 1'b0 from definition
        .MASTER7_HWRITE    ( GND_net ), // tied to 1'b0 from definition
        .MASTER7_HSEL      ( GND_net ), // tied to 1'b0 from definition
        .M_CLK0            ( GND_net ), // tied to 1'b0 from definition
        .M_CLK1            ( GND_net ), // tied to 1'b0 from definition
        .M_CLK2            ( GND_net ), // tied to 1'b0 from definition
        .M_CLK3            ( GND_net ), // tied to 1'b0 from definition
        .M_CLK4            ( GND_net ), // tied to 1'b0 from definition
        .M_CLK5            ( GND_net ), // tied to 1'b0 from definition
        .M_CLK6            ( GND_net ), // tied to 1'b0 from definition
        .M_CLK7            ( GND_net ), // tied to 1'b0 from definition
        .S_CLK0            ( GND_net ), // tied to 1'b0 from definition
        .S_CLK1            ( GND_net ), // tied to 1'b0 from definition
        .S_CLK2            ( GND_net ), // tied to 1'b0 from definition
        .S_CLK3            ( GND_net ), // tied to 1'b0 from definition
        .S_CLK4            ( GND_net ), // tied to 1'b0 from definition
        .S_CLK5            ( GND_net ), // tied to 1'b0 from definition
        .S_CLK6            ( GND_net ), // tied to 1'b0 from definition
        .S_CLK7            ( GND_net ), // tied to 1'b0 from definition
        .SLAVE8_AWREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE9_AWREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE10_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE11_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE12_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE13_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE14_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE15_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE8_WREADY     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE9_WREADY     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE10_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE11_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE12_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE13_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE14_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE15_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE8_BVALID     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE9_BVALID     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE10_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE11_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE12_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE13_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE14_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE15_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE8_ARREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE9_ARREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE10_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE11_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE12_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE13_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE14_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE15_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE8_RLAST      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE8_RVALID     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE9_RLAST      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE9_RVALID     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE10_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE10_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE11_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE11_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE12_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE12_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE13_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE13_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE14_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE14_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE15_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE15_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE16_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE17_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE18_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE19_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE20_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE21_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE22_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE23_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE16_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE17_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE18_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE19_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE20_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE21_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE22_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE23_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE16_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE17_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE18_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE19_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE20_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE21_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE22_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE23_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE16_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE17_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE18_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE19_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE20_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE21_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE22_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE23_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE16_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE16_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE17_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE17_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE18_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE18_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE19_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE19_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE20_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE20_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE21_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE21_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE22_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE22_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE23_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE23_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE24_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE25_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE26_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE27_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE28_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE29_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE30_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE31_AWREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE24_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE25_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE26_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE27_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE28_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE29_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE30_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE31_WREADY    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE24_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE25_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE26_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE27_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE28_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE29_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE30_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE31_BVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE24_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE25_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE26_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE27_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE28_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE29_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE30_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE31_ARREADY   ( GND_net ), // tied to 1'b0 from definition
        .SLAVE24_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE24_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE25_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE25_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE26_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE26_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE27_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE27_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE28_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE28_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE29_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE29_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE30_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE30_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE31_RLAST     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE31_RVALID    ( GND_net ), // tied to 1'b0 from definition
        .S_CLK8            ( GND_net ), // tied to 1'b0 from definition
        .S_CLK9            ( GND_net ), // tied to 1'b0 from definition
        .S_CLK10           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK11           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK12           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK13           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK14           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK15           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK16           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK17           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK18           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK19           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK20           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK21           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK22           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK23           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK24           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK25           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK26           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK27           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK28           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK29           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK30           ( GND_net ), // tied to 1'b0 from definition
        .S_CLK31           ( GND_net ), // tied to 1'b0 from definition
        .MASTER0_AWID      ( microsemi_wrapper_0_DATA_MASTER_AWID ),
        .MASTER0_AWADDR    ( microsemi_wrapper_0_DATA_MASTER_AWADDR ),
        .MASTER0_AWLEN     ( microsemi_wrapper_0_DATA_MASTER_AWLEN_0 ),
        .MASTER0_AWSIZE    ( microsemi_wrapper_0_DATA_MASTER_AWSIZE ),
        .MASTER0_AWBURST   ( microsemi_wrapper_0_DATA_MASTER_AWBURST ),
        .MASTER0_AWLOCK    ( microsemi_wrapper_0_DATA_MASTER_AWLOCK ),
        .MASTER0_AWCACHE   ( microsemi_wrapper_0_DATA_MASTER_AWCACHE ),
        .MASTER0_AWPROT    ( microsemi_wrapper_0_DATA_MASTER_AWPROT ),
        .MASTER0_AWREGION  ( MASTER0_AWREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER0_AWQOS     ( MASTER0_AWQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER0_AWUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER1_AWID      ( MASTER1_AWID_const_net_0 ), // tied to 4'h0 from definition
        .MASTER1_AWADDR    ( MASTER1_AWADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER1_AWLEN     ( MASTER1_AWLEN_const_net_0 ), // tied to 8'h00 from definition
        .MASTER1_AWSIZE    ( MASTER1_AWSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER1_AWBURST   ( MASTER1_AWBURST_const_net_0 ), // tied to 2'h3 from definition
        .MASTER1_AWLOCK    ( MASTER1_AWLOCK_const_net_0 ), // tied to 2'h0 from definition
        .MASTER1_AWCACHE   ( MASTER1_AWCACHE_const_net_0 ), // tied to 4'h0 from definition
        .MASTER1_AWPROT    ( MASTER1_AWPROT_const_net_0 ), // tied to 3'h0 from definition
        .MASTER1_AWREGION  ( MASTER1_AWREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER1_AWQOS     ( MASTER1_AWQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER1_AWUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER2_AWID      ( MASTER2_AWID_const_net_0 ), // tied to 4'h0 from definition
        .MASTER2_AWADDR    ( MASTER2_AWADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER2_AWLEN     ( MASTER2_AWLEN_const_net_0 ), // tied to 8'h00 from definition
        .MASTER2_AWSIZE    ( MASTER2_AWSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER2_AWBURST   ( MASTER2_AWBURST_const_net_0 ), // tied to 2'h3 from definition
        .MASTER2_AWLOCK    ( MASTER2_AWLOCK_const_net_0 ), // tied to 2'h0 from definition
        .MASTER2_AWCACHE   ( MASTER2_AWCACHE_const_net_0 ), // tied to 4'h0 from definition
        .MASTER2_AWPROT    ( MASTER2_AWPROT_const_net_0 ), // tied to 3'h0 from definition
        .MASTER2_AWREGION  ( MASTER2_AWREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER2_AWQOS     ( MASTER2_AWQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER2_AWUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER3_AWID      ( MASTER3_AWID_const_net_0 ), // tied to 4'h0 from definition
        .MASTER3_AWADDR    ( MASTER3_AWADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER3_AWLEN     ( MASTER3_AWLEN_const_net_0 ), // tied to 8'h00 from definition
        .MASTER3_AWSIZE    ( MASTER3_AWSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER3_AWBURST   ( MASTER3_AWBURST_const_net_0 ), // tied to 2'h3 from definition
        .MASTER3_AWLOCK    ( MASTER3_AWLOCK_const_net_0 ), // tied to 2'h0 from definition
        .MASTER3_AWCACHE   ( MASTER3_AWCACHE_const_net_0 ), // tied to 4'h0 from definition
        .MASTER3_AWPROT    ( MASTER3_AWPROT_const_net_0 ), // tied to 3'h0 from definition
        .MASTER3_AWREGION  ( MASTER3_AWREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER3_AWQOS     ( MASTER3_AWQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER3_AWUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER4_AWID      ( MASTER4_AWID_const_net_0 ), // tied to 4'h0 from definition
        .MASTER4_AWADDR    ( MASTER4_AWADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER4_AWLEN     ( MASTER4_AWLEN_const_net_0 ), // tied to 8'h00 from definition
        .MASTER4_AWSIZE    ( MASTER4_AWSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER4_AWBURST   ( MASTER4_AWBURST_const_net_0 ), // tied to 2'h3 from definition
        .MASTER4_AWLOCK    ( MASTER4_AWLOCK_const_net_0 ), // tied to 2'h0 from definition
        .MASTER4_AWCACHE   ( MASTER4_AWCACHE_const_net_0 ), // tied to 4'h0 from definition
        .MASTER4_AWPROT    ( MASTER4_AWPROT_const_net_0 ), // tied to 3'h0 from definition
        .MASTER4_AWREGION  ( MASTER4_AWREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER4_AWQOS     ( MASTER4_AWQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER4_AWUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER5_AWID      ( MASTER5_AWID_const_net_0 ), // tied to 4'h0 from definition
        .MASTER5_AWADDR    ( MASTER5_AWADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER5_AWLEN     ( MASTER5_AWLEN_const_net_0 ), // tied to 8'h00 from definition
        .MASTER5_AWSIZE    ( MASTER5_AWSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER5_AWBURST   ( MASTER5_AWBURST_const_net_0 ), // tied to 2'h3 from definition
        .MASTER5_AWLOCK    ( MASTER5_AWLOCK_const_net_0 ), // tied to 2'h0 from definition
        .MASTER5_AWCACHE   ( MASTER5_AWCACHE_const_net_0 ), // tied to 4'h0 from definition
        .MASTER5_AWPROT    ( MASTER5_AWPROT_const_net_0 ), // tied to 3'h0 from definition
        .MASTER5_AWREGION  ( MASTER5_AWREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER5_AWQOS     ( MASTER5_AWQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER5_AWUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER6_AWID      ( MASTER6_AWID_const_net_0 ), // tied to 4'h0 from definition
        .MASTER6_AWADDR    ( MASTER6_AWADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER6_AWLEN     ( MASTER6_AWLEN_const_net_0 ), // tied to 8'h00 from definition
        .MASTER6_AWSIZE    ( MASTER6_AWSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER6_AWBURST   ( MASTER6_AWBURST_const_net_0 ), // tied to 2'h3 from definition
        .MASTER6_AWLOCK    ( MASTER6_AWLOCK_const_net_0 ), // tied to 2'h0 from definition
        .MASTER6_AWCACHE   ( MASTER6_AWCACHE_const_net_0 ), // tied to 4'h0 from definition
        .MASTER6_AWPROT    ( MASTER6_AWPROT_const_net_0 ), // tied to 3'h0 from definition
        .MASTER6_AWREGION  ( MASTER6_AWREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER6_AWQOS     ( MASTER6_AWQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER6_AWUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER7_AWID      ( MASTER7_AWID_const_net_0 ), // tied to 4'h0 from definition
        .MASTER7_AWADDR    ( MASTER7_AWADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER7_AWLEN     ( MASTER7_AWLEN_const_net_0 ), // tied to 8'h00 from definition
        .MASTER7_AWSIZE    ( MASTER7_AWSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER7_AWBURST   ( MASTER7_AWBURST_const_net_0 ), // tied to 2'h3 from definition
        .MASTER7_AWLOCK    ( MASTER7_AWLOCK_const_net_0 ), // tied to 2'h0 from definition
        .MASTER7_AWCACHE   ( MASTER7_AWCACHE_const_net_0 ), // tied to 4'h0 from definition
        .MASTER7_AWPROT    ( MASTER7_AWPROT_const_net_0 ), // tied to 3'h0 from definition
        .MASTER7_AWREGION  ( MASTER7_AWREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER7_AWQOS     ( MASTER7_AWQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER7_AWUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER0_WDATA     ( microsemi_wrapper_0_DATA_MASTER_WDATA ),
        .MASTER0_WSTRB     ( microsemi_wrapper_0_DATA_MASTER_WSTRB ),
        .MASTER0_WUSER     ( GND_net ), // tied to 1'b0 from definition
        .MASTER1_WDATA     ( MASTER1_WDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER1_WSTRB     ( MASTER1_WSTRB_const_net_0 ), // tied to 4'hF from definition
        .MASTER1_WUSER     ( GND_net ), // tied to 1'b0 from definition
        .MASTER2_WDATA     ( MASTER2_WDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER2_WSTRB     ( MASTER2_WSTRB_const_net_0 ), // tied to 4'hF from definition
        .MASTER2_WUSER     ( GND_net ), // tied to 1'b0 from definition
        .MASTER3_WDATA     ( MASTER3_WDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER3_WSTRB     ( MASTER3_WSTRB_const_net_0 ), // tied to 4'hF from definition
        .MASTER3_WUSER     ( GND_net ), // tied to 1'b0 from definition
        .MASTER4_WDATA     ( MASTER4_WDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER4_WSTRB     ( MASTER4_WSTRB_const_net_0 ), // tied to 4'hF from definition
        .MASTER4_WUSER     ( GND_net ), // tied to 1'b0 from definition
        .MASTER5_WDATA     ( MASTER5_WDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER5_WSTRB     ( MASTER5_WSTRB_const_net_0 ), // tied to 4'hF from definition
        .MASTER5_WUSER     ( GND_net ), // tied to 1'b0 from definition
        .MASTER6_WDATA     ( MASTER6_WDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER6_WSTRB     ( MASTER6_WSTRB_const_net_0 ), // tied to 4'hF from definition
        .MASTER6_WUSER     ( GND_net ), // tied to 1'b0 from definition
        .MASTER7_WDATA     ( MASTER7_WDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER7_WSTRB     ( MASTER7_WSTRB_const_net_0 ), // tied to 4'hF from definition
        .MASTER7_WUSER     ( GND_net ), // tied to 1'b0 from definition
        .MASTER0_ARID      ( microsemi_wrapper_0_DATA_MASTER_ARID ),
        .MASTER0_ARADDR    ( microsemi_wrapper_0_DATA_MASTER_ARADDR ),
        .MASTER0_ARLEN     ( microsemi_wrapper_0_DATA_MASTER_ARLEN_0 ),
        .MASTER0_ARSIZE    ( microsemi_wrapper_0_DATA_MASTER_ARSIZE ),
        .MASTER0_ARBURST   ( microsemi_wrapper_0_DATA_MASTER_ARBURST ),
        .MASTER0_ARLOCK    ( microsemi_wrapper_0_DATA_MASTER_ARLOCK ),
        .MASTER0_ARCACHE   ( microsemi_wrapper_0_DATA_MASTER_ARCACHE ),
        .MASTER0_ARPROT    ( microsemi_wrapper_0_DATA_MASTER_ARPROT ),
        .MASTER0_ARREGION  ( MASTER0_ARREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER0_ARQOS     ( MASTER0_ARQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER0_ARUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER1_ARID      ( MASTER1_ARID_const_net_0 ), // tied to 4'h0 from definition
        .MASTER1_ARADDR    ( MASTER1_ARADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER1_ARLEN     ( MASTER1_ARLEN_const_net_0 ), // tied to 8'h00 from definition
        .MASTER1_ARSIZE    ( MASTER1_ARSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER1_ARBURST   ( MASTER1_ARBURST_const_net_0 ), // tied to 2'h3 from definition
        .MASTER1_ARLOCK    ( MASTER1_ARLOCK_const_net_0 ), // tied to 2'h0 from definition
        .MASTER1_ARCACHE   ( MASTER1_ARCACHE_const_net_0 ), // tied to 4'h0 from definition
        .MASTER1_ARPROT    ( MASTER1_ARPROT_const_net_0 ), // tied to 3'h0 from definition
        .MASTER1_ARREGION  ( MASTER1_ARREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER1_ARQOS     ( MASTER1_ARQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER1_ARUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER2_ARID      ( MASTER2_ARID_const_net_0 ), // tied to 4'h0 from definition
        .MASTER2_ARADDR    ( MASTER2_ARADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER2_ARLEN     ( MASTER2_ARLEN_const_net_0 ), // tied to 8'h00 from definition
        .MASTER2_ARSIZE    ( MASTER2_ARSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER2_ARBURST   ( MASTER2_ARBURST_const_net_0 ), // tied to 2'h3 from definition
        .MASTER2_ARLOCK    ( MASTER2_ARLOCK_const_net_0 ), // tied to 2'h0 from definition
        .MASTER2_ARCACHE   ( MASTER2_ARCACHE_const_net_0 ), // tied to 4'h0 from definition
        .MASTER2_ARPROT    ( MASTER2_ARPROT_const_net_0 ), // tied to 3'h0 from definition
        .MASTER2_ARREGION  ( MASTER2_ARREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER2_ARQOS     ( MASTER2_ARQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER2_ARUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER3_ARID      ( MASTER3_ARID_const_net_0 ), // tied to 4'h0 from definition
        .MASTER3_ARADDR    ( MASTER3_ARADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER3_ARLEN     ( MASTER3_ARLEN_const_net_0 ), // tied to 8'h00 from definition
        .MASTER3_ARSIZE    ( MASTER3_ARSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER3_ARBURST   ( MASTER3_ARBURST_const_net_0 ), // tied to 2'h3 from definition
        .MASTER3_ARLOCK    ( MASTER3_ARLOCK_const_net_0 ), // tied to 2'h0 from definition
        .MASTER3_ARCACHE   ( MASTER3_ARCACHE_const_net_0 ), // tied to 4'h0 from definition
        .MASTER3_ARPROT    ( MASTER3_ARPROT_const_net_0 ), // tied to 3'h0 from definition
        .MASTER3_ARREGION  ( MASTER3_ARREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER3_ARQOS     ( MASTER3_ARQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER3_ARUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER4_ARID      ( MASTER4_ARID_const_net_0 ), // tied to 4'h0 from definition
        .MASTER4_ARADDR    ( MASTER4_ARADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER4_ARLEN     ( MASTER4_ARLEN_const_net_0 ), // tied to 8'h00 from definition
        .MASTER4_ARSIZE    ( MASTER4_ARSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER4_ARBURST   ( MASTER4_ARBURST_const_net_0 ), // tied to 2'h3 from definition
        .MASTER4_ARLOCK    ( MASTER4_ARLOCK_const_net_0 ), // tied to 2'h0 from definition
        .MASTER4_ARCACHE   ( MASTER4_ARCACHE_const_net_0 ), // tied to 4'h0 from definition
        .MASTER4_ARPROT    ( MASTER4_ARPROT_const_net_0 ), // tied to 3'h0 from definition
        .MASTER4_ARREGION  ( MASTER4_ARREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER4_ARQOS     ( MASTER4_ARQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER4_ARUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER5_ARID      ( MASTER5_ARID_const_net_0 ), // tied to 4'h0 from definition
        .MASTER5_ARADDR    ( MASTER5_ARADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER5_ARLEN     ( MASTER5_ARLEN_const_net_0 ), // tied to 8'h00 from definition
        .MASTER5_ARSIZE    ( MASTER5_ARSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER5_ARBURST   ( MASTER5_ARBURST_const_net_0 ), // tied to 2'h3 from definition
        .MASTER5_ARLOCK    ( MASTER5_ARLOCK_const_net_0 ), // tied to 2'h0 from definition
        .MASTER5_ARCACHE   ( MASTER5_ARCACHE_const_net_0 ), // tied to 4'h0 from definition
        .MASTER5_ARPROT    ( MASTER5_ARPROT_const_net_0 ), // tied to 3'h0 from definition
        .MASTER5_ARREGION  ( MASTER5_ARREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER5_ARQOS     ( MASTER5_ARQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER5_ARUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER6_ARID      ( MASTER6_ARID_const_net_0 ), // tied to 4'h0 from definition
        .MASTER6_ARADDR    ( MASTER6_ARADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER6_ARLEN     ( MASTER6_ARLEN_const_net_0 ), // tied to 8'h00 from definition
        .MASTER6_ARSIZE    ( MASTER6_ARSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER6_ARBURST   ( MASTER6_ARBURST_const_net_0 ), // tied to 2'h3 from definition
        .MASTER6_ARLOCK    ( MASTER6_ARLOCK_const_net_0 ), // tied to 2'h0 from definition
        .MASTER6_ARCACHE   ( MASTER6_ARCACHE_const_net_0 ), // tied to 4'h0 from definition
        .MASTER6_ARPROT    ( MASTER6_ARPROT_const_net_0 ), // tied to 3'h0 from definition
        .MASTER6_ARREGION  ( MASTER6_ARREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER6_ARQOS     ( MASTER6_ARQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER6_ARUSER    ( GND_net ), // tied to 1'b0 from definition
        .MASTER7_ARID      ( MASTER7_ARID_const_net_0 ), // tied to 4'h0 from definition
        .MASTER7_ARADDR    ( MASTER7_ARADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER7_ARLEN     ( MASTER7_ARLEN_const_net_0 ), // tied to 8'h00 from definition
        .MASTER7_ARSIZE    ( MASTER7_ARSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER7_ARBURST   ( MASTER7_ARBURST_const_net_0 ), // tied to 2'h3 from definition
        .MASTER7_ARLOCK    ( MASTER7_ARLOCK_const_net_0 ), // tied to 2'h0 from definition
        .MASTER7_ARCACHE   ( MASTER7_ARCACHE_const_net_0 ), // tied to 4'h0 from definition
        .MASTER7_ARPROT    ( MASTER7_ARPROT_const_net_0 ), // tied to 3'h0 from definition
        .MASTER7_ARREGION  ( MASTER7_ARREGION_const_net_0 ), // tied to 4'h0 from definition
        .MASTER7_ARQOS     ( MASTER7_ARQOS_const_net_0 ), // tied to 4'h0 from definition
        .MASTER7_ARUSER    ( GND_net ), // tied to 1'b0 from definition
        .SLAVE0_BID        ( CoreAXI4Interconnect_0_AXI3mslave0_BID_0 ),
        .SLAVE0_BRESP      ( CoreAXI4Interconnect_0_AXI3mslave0_BRESP ),
        .SLAVE0_BUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE1_BID        ( SLAVE1_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE1_BRESP      ( SLAVE1_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE1_BUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE2_BID        ( SLAVE2_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE2_BRESP      ( SLAVE2_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE2_BUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE3_BID        ( CoreAXI4Interconnect_0_AXI3mslave3_BID_0 ),
        .SLAVE3_BRESP      ( CoreAXI4Interconnect_0_AXI3mslave3_BRESP ),
        .SLAVE3_BUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE4_BID        ( SLAVE4_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE4_BRESP      ( SLAVE4_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE4_BUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE5_BID        ( SLAVE5_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE5_BRESP      ( SLAVE5_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE5_BUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE6_BID        ( SLAVE6_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE6_BRESP      ( SLAVE6_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE6_BUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE7_BID        ( CoreAXI4Interconnect_0_AXI3mslave7_BID_0 ),
        .SLAVE7_BRESP      ( CoreAXI4Interconnect_0_AXI3mslave7_BRESP ),
        .SLAVE7_BUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE0_RID        ( CoreAXI4Interconnect_0_AXI3mslave0_RID_0 ),
        .SLAVE0_RDATA      ( CoreAXI4Interconnect_0_AXI3mslave0_RDATA ),
        .SLAVE0_RRESP      ( CoreAXI4Interconnect_0_AXI3mslave0_RRESP ),
        .SLAVE0_RUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE1_RID        ( SLAVE1_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE1_RDATA      ( SLAVE1_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE1_RRESP      ( SLAVE1_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE1_RUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE2_RID        ( SLAVE2_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE2_RDATA      ( SLAVE2_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE2_RRESP      ( SLAVE2_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE2_RUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE3_RID        ( CoreAXI4Interconnect_0_AXI3mslave3_RID_0 ),
        .SLAVE3_RDATA      ( CoreAXI4Interconnect_0_AXI3mslave3_RDATA ),
        .SLAVE3_RRESP      ( CoreAXI4Interconnect_0_AXI3mslave3_RRESP ),
        .SLAVE3_RUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE4_RID        ( SLAVE4_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE4_RDATA      ( SLAVE4_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE4_RRESP      ( SLAVE4_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE4_RUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE5_RID        ( SLAVE5_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE5_RDATA      ( SLAVE5_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE5_RRESP      ( SLAVE5_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE5_RUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE6_RID        ( SLAVE6_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE6_RDATA      ( SLAVE6_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE6_RRESP      ( SLAVE6_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE6_RUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE7_RID        ( CoreAXI4Interconnect_0_AXI3mslave7_RID_0 ),
        .SLAVE7_RDATA      ( CoreAXI4Interconnect_0_AXI3mslave7_RDATA ),
        .SLAVE7_RRESP      ( CoreAXI4Interconnect_0_AXI3mslave7_RRESP ),
        .SLAVE7_RUSER      ( GND_net ), // tied to 1'b0 from definition
        .MASTER0_HADDR     ( MASTER0_HADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER0_HBURST    ( MASTER0_HBURST_const_net_0 ), // tied to 3'h0 from definition
        .MASTER0_HPROT     ( MASTER0_HPROT_const_net_0 ), // tied to 7'h00 from definition
        .MASTER0_HSIZE     ( MASTER0_HSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER0_HTRANS    ( MASTER0_HTRANS_const_net_0 ), // tied to 2'h0 from definition
        .MASTER0_HWDATA    ( MASTER0_HWDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER1_HADDR     ( MASTER1_HADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER1_HBURST    ( MASTER1_HBURST_const_net_0 ), // tied to 3'h0 from definition
        .MASTER1_HPROT     ( MASTER1_HPROT_const_net_0 ), // tied to 7'h00 from definition
        .MASTER1_HSIZE     ( MASTER1_HSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER1_HTRANS    ( MASTER1_HTRANS_const_net_0 ), // tied to 2'h0 from definition
        .MASTER1_HWDATA    ( MASTER1_HWDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER2_HADDR     ( MASTER2_HADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER2_HBURST    ( MASTER2_HBURST_const_net_0 ), // tied to 3'h0 from definition
        .MASTER2_HPROT     ( MASTER2_HPROT_const_net_0 ), // tied to 7'h00 from definition
        .MASTER2_HSIZE     ( MASTER2_HSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER2_HTRANS    ( MASTER2_HTRANS_const_net_0 ), // tied to 2'h0 from definition
        .MASTER2_HWDATA    ( MASTER2_HWDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER3_HADDR     ( MASTER3_HADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER3_HBURST    ( MASTER3_HBURST_const_net_0 ), // tied to 3'h0 from definition
        .MASTER3_HPROT     ( MASTER3_HPROT_const_net_0 ), // tied to 7'h00 from definition
        .MASTER3_HSIZE     ( MASTER3_HSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER3_HTRANS    ( MASTER3_HTRANS_const_net_0 ), // tied to 2'h0 from definition
        .MASTER3_HWDATA    ( MASTER3_HWDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER4_HADDR     ( MASTER4_HADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER4_HBURST    ( MASTER4_HBURST_const_net_0 ), // tied to 3'h0 from definition
        .MASTER4_HPROT     ( MASTER4_HPROT_const_net_0 ), // tied to 7'h00 from definition
        .MASTER4_HSIZE     ( MASTER4_HSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER4_HTRANS    ( MASTER4_HTRANS_const_net_0 ), // tied to 2'h0 from definition
        .MASTER4_HWDATA    ( MASTER4_HWDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER5_HADDR     ( MASTER5_HADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER5_HBURST    ( MASTER5_HBURST_const_net_0 ), // tied to 3'h0 from definition
        .MASTER5_HPROT     ( MASTER5_HPROT_const_net_0 ), // tied to 7'h00 from definition
        .MASTER5_HSIZE     ( MASTER5_HSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER5_HTRANS    ( MASTER5_HTRANS_const_net_0 ), // tied to 2'h0 from definition
        .MASTER5_HWDATA    ( MASTER5_HWDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER6_HADDR     ( MASTER6_HADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER6_HBURST    ( MASTER6_HBURST_const_net_0 ), // tied to 3'h0 from definition
        .MASTER6_HPROT     ( MASTER6_HPROT_const_net_0 ), // tied to 7'h00 from definition
        .MASTER6_HSIZE     ( MASTER6_HSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER6_HTRANS    ( MASTER6_HTRANS_const_net_0 ), // tied to 2'h0 from definition
        .MASTER6_HWDATA    ( MASTER6_HWDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER7_HADDR     ( MASTER7_HADDR_const_net_0 ), // tied to 32'h00000000 from definition
        .MASTER7_HBURST    ( MASTER7_HBURST_const_net_0 ), // tied to 3'h0 from definition
        .MASTER7_HPROT     ( MASTER7_HPROT_const_net_0 ), // tied to 7'h00 from definition
        .MASTER7_HSIZE     ( MASTER7_HSIZE_const_net_0 ), // tied to 3'h0 from definition
        .MASTER7_HTRANS    ( MASTER7_HTRANS_const_net_0 ), // tied to 2'h0 from definition
        .MASTER7_HWDATA    ( MASTER7_HWDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE8_BID        ( SLAVE8_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE8_BRESP      ( SLAVE8_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE8_BUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE9_BID        ( SLAVE9_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE9_BRESP      ( SLAVE9_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE9_BUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE10_BID       ( SLAVE10_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE10_BRESP     ( SLAVE10_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE10_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE11_BID       ( SLAVE11_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE11_BRESP     ( SLAVE11_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE11_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE12_BID       ( SLAVE12_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE12_BRESP     ( SLAVE12_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE12_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE13_BID       ( SLAVE13_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE13_BRESP     ( SLAVE13_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE13_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE14_BID       ( SLAVE14_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE14_BRESP     ( SLAVE14_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE14_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE15_BID       ( SLAVE15_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE15_BRESP     ( SLAVE15_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE15_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE8_RID        ( SLAVE8_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE8_RDATA      ( SLAVE8_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE8_RRESP      ( SLAVE8_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE8_RUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE9_RID        ( SLAVE9_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE9_RDATA      ( SLAVE9_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE9_RRESP      ( SLAVE9_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE9_RUSER      ( GND_net ), // tied to 1'b0 from definition
        .SLAVE10_RID       ( SLAVE10_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE10_RDATA     ( SLAVE10_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE10_RRESP     ( SLAVE10_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE10_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE11_RID       ( SLAVE11_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE11_RDATA     ( SLAVE11_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE11_RRESP     ( SLAVE11_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE11_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE12_RID       ( SLAVE12_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE12_RDATA     ( SLAVE12_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE12_RRESP     ( SLAVE12_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE12_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE13_RID       ( SLAVE13_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE13_RDATA     ( SLAVE13_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE13_RRESP     ( SLAVE13_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE13_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE14_RID       ( SLAVE14_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE14_RDATA     ( SLAVE14_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE14_RRESP     ( SLAVE14_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE14_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE15_RID       ( SLAVE15_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE15_RDATA     ( SLAVE15_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE15_RRESP     ( SLAVE15_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE15_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE16_BID       ( SLAVE16_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE16_BRESP     ( SLAVE16_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE16_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE17_BID       ( SLAVE17_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE17_BRESP     ( SLAVE17_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE17_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE18_BID       ( SLAVE18_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE18_BRESP     ( SLAVE18_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE18_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE19_BID       ( SLAVE19_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE19_BRESP     ( SLAVE19_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE19_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE20_BID       ( SLAVE20_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE20_BRESP     ( SLAVE20_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE20_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE21_BID       ( SLAVE21_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE21_BRESP     ( SLAVE21_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE21_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE22_BID       ( SLAVE22_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE22_BRESP     ( SLAVE22_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE22_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE23_BID       ( SLAVE23_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE23_BRESP     ( SLAVE23_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE23_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE16_RID       ( SLAVE16_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE16_RDATA     ( SLAVE16_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE16_RRESP     ( SLAVE16_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE16_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE17_RID       ( SLAVE17_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE17_RDATA     ( SLAVE17_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE17_RRESP     ( SLAVE17_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE17_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE18_RID       ( SLAVE18_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE18_RDATA     ( SLAVE18_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE18_RRESP     ( SLAVE18_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE18_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE19_RID       ( SLAVE19_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE19_RDATA     ( SLAVE19_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE19_RRESP     ( SLAVE19_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE19_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE20_RID       ( SLAVE20_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE20_RDATA     ( SLAVE20_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE20_RRESP     ( SLAVE20_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE20_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE21_RID       ( SLAVE21_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE21_RDATA     ( SLAVE21_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE21_RRESP     ( SLAVE21_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE21_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE22_RID       ( SLAVE22_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE22_RDATA     ( SLAVE22_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE22_RRESP     ( SLAVE22_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE22_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE23_RID       ( SLAVE23_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE23_RDATA     ( SLAVE23_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE23_RRESP     ( SLAVE23_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE23_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE24_BID       ( SLAVE24_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE24_BRESP     ( SLAVE24_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE24_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE25_BID       ( SLAVE25_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE25_BRESP     ( SLAVE25_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE25_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE26_BID       ( SLAVE26_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE26_BRESP     ( SLAVE26_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE26_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE27_BID       ( SLAVE27_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE27_BRESP     ( SLAVE27_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE27_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE28_BID       ( SLAVE28_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE28_BRESP     ( SLAVE28_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE28_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE29_BID       ( SLAVE29_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE29_BRESP     ( SLAVE29_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE29_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE30_BID       ( SLAVE30_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE30_BRESP     ( SLAVE30_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE30_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE31_BID       ( SLAVE31_BID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE31_BRESP     ( SLAVE31_BRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE31_BUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE24_RID       ( SLAVE24_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE24_RDATA     ( SLAVE24_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE24_RRESP     ( SLAVE24_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE24_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE25_RID       ( SLAVE25_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE25_RDATA     ( SLAVE25_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE25_RRESP     ( SLAVE25_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE25_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE26_RID       ( SLAVE26_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE26_RDATA     ( SLAVE26_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE26_RRESP     ( SLAVE26_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE26_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE27_RID       ( SLAVE27_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE27_RDATA     ( SLAVE27_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE27_RRESP     ( SLAVE27_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE27_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE28_RID       ( SLAVE28_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE28_RDATA     ( SLAVE28_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE28_RRESP     ( SLAVE28_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE28_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE29_RID       ( SLAVE29_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE29_RDATA     ( SLAVE29_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE29_RRESP     ( SLAVE29_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE29_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE30_RID       ( SLAVE30_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE30_RDATA     ( SLAVE30_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE30_RRESP     ( SLAVE30_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE30_RUSER     ( GND_net ), // tied to 1'b0 from definition
        .SLAVE31_RID       ( SLAVE31_RID_const_net_0 ), // tied to 5'h00 from definition
        .SLAVE31_RDATA     ( SLAVE31_RDATA_const_net_0 ), // tied to 32'h00000000 from definition
        .SLAVE31_RRESP     ( SLAVE31_RRESP_const_net_0 ), // tied to 2'h0 from definition
        .SLAVE31_RUSER     ( GND_net ), // tied to 1'b0 from definition
        // Outputs
        .MASTER0_AWREADY   ( microsemi_wrapper_0_DATA_MASTER_AWREADY ),
        .MASTER1_AWREADY   (  ),
        .MASTER2_AWREADY   (  ),
        .MASTER3_AWREADY   (  ),
        .MASTER4_AWREADY   (  ),
        .MASTER5_AWREADY   (  ),
        .MASTER6_AWREADY   (  ),
        .MASTER7_AWREADY   (  ),
        .MASTER0_WREADY    ( microsemi_wrapper_0_DATA_MASTER_WREADY ),
        .MASTER1_WREADY    (  ),
        .MASTER2_WREADY    (  ),
        .MASTER3_WREADY    (  ),
        .MASTER4_WREADY    (  ),
        .MASTER5_WREADY    (  ),
        .MASTER6_WREADY    (  ),
        .MASTER7_WREADY    (  ),
        .MASTER0_BVALID    ( microsemi_wrapper_0_DATA_MASTER_BVALID ),
        .MASTER1_BVALID    (  ),
        .MASTER2_BVALID    (  ),
        .MASTER3_BVALID    (  ),
        .MASTER4_BVALID    (  ),
        .MASTER5_BVALID    (  ),
        .MASTER6_BVALID    (  ),
        .MASTER7_BVALID    (  ),
        .MASTER0_ARREADY   ( microsemi_wrapper_0_DATA_MASTER_ARREADY ),
        .MASTER1_ARREADY   (  ),
        .MASTER2_ARREADY   (  ),
        .MASTER3_ARREADY   (  ),
        .MASTER4_ARREADY   (  ),
        .MASTER5_ARREADY   (  ),
        .MASTER6_ARREADY   (  ),
        .MASTER7_ARREADY   (  ),
        .MASTER0_RLAST     ( microsemi_wrapper_0_DATA_MASTER_RLAST ),
        .MASTER0_RVALID    ( microsemi_wrapper_0_DATA_MASTER_RVALID ),
        .MASTER1_RLAST     (  ),
        .MASTER1_RVALID    (  ),
        .MASTER2_RLAST     (  ),
        .MASTER2_RVALID    (  ),
        .MASTER3_RLAST     (  ),
        .MASTER3_RVALID    (  ),
        .MASTER4_RLAST     (  ),
        .MASTER4_RVALID    (  ),
        .MASTER5_RLAST     (  ),
        .MASTER5_RVALID    (  ),
        .MASTER6_RLAST     (  ),
        .MASTER6_RVALID    (  ),
        .MASTER7_RLAST     (  ),
        .MASTER7_RVALID    (  ),
        .SLAVE0_AWVALID    ( CoreAXI4Interconnect_0_AXI3mslave0_AWVALID ),
        .SLAVE1_AWVALID    ( CoreAXI4Interconnect_0_AXI3mslave1_AWVALID ),
        .SLAVE2_AWVALID    ( CoreAXI4Interconnect_0_AXI3mslave2_AWVALID ),
        .SLAVE3_AWVALID    ( CoreAXI4Interconnect_0_AXI3mslave3_AWVALID ),
        .SLAVE4_AWVALID    ( CoreAXI4Interconnect_0_AXI3mslave4_AWVALID ),
        .SLAVE5_AWVALID    ( CoreAXI4Interconnect_0_AXI3mslave5_AWVALID ),
        .SLAVE6_AWVALID    ( CoreAXI4Interconnect_0_AXI3mslave6_AWVALID ),
        .SLAVE7_AWVALID    ( CoreAXI4Interconnect_0_AXI3mslave7_AWVALID ),
        .SLAVE0_WLAST      ( CoreAXI4Interconnect_0_AXI3mslave0_WLAST ),
        .SLAVE0_WVALID     ( CoreAXI4Interconnect_0_AXI3mslave0_WVALID ),
        .SLAVE1_WLAST      ( CoreAXI4Interconnect_0_AXI3mslave1_WLAST ),
        .SLAVE1_WVALID     ( CoreAXI4Interconnect_0_AXI3mslave1_WVALID ),
        .SLAVE2_WLAST      ( CoreAXI4Interconnect_0_AXI3mslave2_WLAST ),
        .SLAVE2_WVALID     ( CoreAXI4Interconnect_0_AXI3mslave2_WVALID ),
        .SLAVE3_WLAST      ( CoreAXI4Interconnect_0_AXI3mslave3_WLAST ),
        .SLAVE3_WVALID     ( CoreAXI4Interconnect_0_AXI3mslave3_WVALID ),
        .SLAVE4_WLAST      ( CoreAXI4Interconnect_0_AXI3mslave4_WLAST ),
        .SLAVE4_WVALID     ( CoreAXI4Interconnect_0_AXI3mslave4_WVALID ),
        .SLAVE5_WLAST      ( CoreAXI4Interconnect_0_AXI3mslave5_WLAST ),
        .SLAVE5_WVALID     ( CoreAXI4Interconnect_0_AXI3mslave5_WVALID ),
        .SLAVE6_WLAST      ( CoreAXI4Interconnect_0_AXI3mslave6_WLAST ),
        .SLAVE6_WVALID     ( CoreAXI4Interconnect_0_AXI3mslave6_WVALID ),
        .SLAVE7_WLAST      ( CoreAXI4Interconnect_0_AXI3mslave7_WLAST ),
        .SLAVE7_WVALID     ( CoreAXI4Interconnect_0_AXI3mslave7_WVALID ),
        .SLAVE0_BREADY     ( CoreAXI4Interconnect_0_AXI3mslave0_BREADY ),
        .SLAVE1_BREADY     ( CoreAXI4Interconnect_0_AXI3mslave1_BREADY ),
        .SLAVE2_BREADY     ( CoreAXI4Interconnect_0_AXI3mslave2_BREADY ),
        .SLAVE3_BREADY     ( CoreAXI4Interconnect_0_AXI3mslave3_BREADY ),
        .SLAVE4_BREADY     ( CoreAXI4Interconnect_0_AXI3mslave4_BREADY ),
        .SLAVE5_BREADY     ( CoreAXI4Interconnect_0_AXI3mslave5_BREADY ),
        .SLAVE6_BREADY     ( CoreAXI4Interconnect_0_AXI3mslave6_BREADY ),
        .SLAVE7_BREADY     ( CoreAXI4Interconnect_0_AXI3mslave7_BREADY ),
        .SLAVE0_ARVALID    ( CoreAXI4Interconnect_0_AXI3mslave0_ARVALID ),
        .SLAVE1_ARVALID    ( CoreAXI4Interconnect_0_AXI3mslave1_ARVALID ),
        .SLAVE2_ARVALID    ( CoreAXI4Interconnect_0_AXI3mslave2_ARVALID ),
        .SLAVE3_ARVALID    ( CoreAXI4Interconnect_0_AXI3mslave3_ARVALID ),
        .SLAVE4_ARVALID    ( CoreAXI4Interconnect_0_AXI3mslave4_ARVALID ),
        .SLAVE5_ARVALID    ( CoreAXI4Interconnect_0_AXI3mslave5_ARVALID ),
        .SLAVE6_ARVALID    ( CoreAXI4Interconnect_0_AXI3mslave6_ARVALID ),
        .SLAVE7_ARVALID    ( CoreAXI4Interconnect_0_AXI3mslave7_ARVALID ),
        .SLAVE0_RREADY     ( CoreAXI4Interconnect_0_AXI3mslave0_RREADY ),
        .SLAVE1_RREADY     ( CoreAXI4Interconnect_0_AXI3mslave1_RREADY ),
        .SLAVE2_RREADY     ( CoreAXI4Interconnect_0_AXI3mslave2_RREADY ),
        .SLAVE3_RREADY     ( CoreAXI4Interconnect_0_AXI3mslave3_RREADY ),
        .SLAVE4_RREADY     ( CoreAXI4Interconnect_0_AXI3mslave4_RREADY ),
        .SLAVE5_RREADY     ( CoreAXI4Interconnect_0_AXI3mslave5_RREADY ),
        .SLAVE6_RREADY     ( CoreAXI4Interconnect_0_AXI3mslave6_RREADY ),
        .SLAVE7_RREADY     ( CoreAXI4Interconnect_0_AXI3mslave7_RREADY ),
        .MASTER0_HREADY    (  ),
        .MASTER0_HRESP     (  ),
        .MASTER1_HREADY    (  ),
        .MASTER1_HRESP     (  ),
        .MASTER2_HREADY    (  ),
        .MASTER2_HRESP     (  ),
        .MASTER3_HREADY    (  ),
        .MASTER3_HRESP     (  ),
        .MASTER4_HREADY    (  ),
        .MASTER4_HRESP     (  ),
        .MASTER5_HREADY    (  ),
        .MASTER5_HRESP     (  ),
        .MASTER6_HREADY    (  ),
        .MASTER6_HRESP     (  ),
        .MASTER7_HREADY    (  ),
        .MASTER7_HRESP     (  ),
        .SLAVE8_AWVALID    (  ),
        .SLAVE9_AWVALID    (  ),
        .SLAVE10_AWVALID   (  ),
        .SLAVE11_AWVALID   (  ),
        .SLAVE12_AWVALID   (  ),
        .SLAVE13_AWVALID   (  ),
        .SLAVE14_AWVALID   (  ),
        .SLAVE15_AWVALID   (  ),
        .SLAVE8_WLAST      (  ),
        .SLAVE8_WVALID     (  ),
        .SLAVE9_WLAST      (  ),
        .SLAVE9_WVALID     (  ),
        .SLAVE10_WLAST     (  ),
        .SLAVE10_WVALID    (  ),
        .SLAVE11_WLAST     (  ),
        .SLAVE11_WVALID    (  ),
        .SLAVE12_WLAST     (  ),
        .SLAVE12_WVALID    (  ),
        .SLAVE13_WLAST     (  ),
        .SLAVE13_WVALID    (  ),
        .SLAVE14_WLAST     (  ),
        .SLAVE14_WVALID    (  ),
        .SLAVE15_WLAST     (  ),
        .SLAVE15_WVALID    (  ),
        .SLAVE8_BREADY     (  ),
        .SLAVE9_BREADY     (  ),
        .SLAVE10_BREADY    (  ),
        .SLAVE11_BREADY    (  ),
        .SLAVE12_BREADY    (  ),
        .SLAVE13_BREADY    (  ),
        .SLAVE14_BREADY    (  ),
        .SLAVE15_BREADY    (  ),
        .SLAVE8_ARVALID    (  ),
        .SLAVE9_ARVALID    (  ),
        .SLAVE10_ARVALID   (  ),
        .SLAVE11_ARVALID   (  ),
        .SLAVE12_ARVALID   (  ),
        .SLAVE13_ARVALID   (  ),
        .SLAVE14_ARVALID   (  ),
        .SLAVE15_ARVALID   (  ),
        .SLAVE8_RREADY     (  ),
        .SLAVE9_RREADY     (  ),
        .SLAVE10_RREADY    (  ),
        .SLAVE11_RREADY    (  ),
        .SLAVE12_RREADY    (  ),
        .SLAVE13_RREADY    (  ),
        .SLAVE14_RREADY    (  ),
        .SLAVE15_RREADY    (  ),
        .SLAVE16_AWVALID   (  ),
        .SLAVE17_AWVALID   (  ),
        .SLAVE18_AWVALID   (  ),
        .SLAVE19_AWVALID   (  ),
        .SLAVE20_AWVALID   (  ),
        .SLAVE21_AWVALID   (  ),
        .SLAVE22_AWVALID   (  ),
        .SLAVE23_AWVALID   (  ),
        .SLAVE16_WLAST     (  ),
        .SLAVE16_WVALID    (  ),
        .SLAVE17_WLAST     (  ),
        .SLAVE17_WVALID    (  ),
        .SLAVE18_WLAST     (  ),
        .SLAVE18_WVALID    (  ),
        .SLAVE19_WLAST     (  ),
        .SLAVE19_WVALID    (  ),
        .SLAVE20_WLAST     (  ),
        .SLAVE20_WVALID    (  ),
        .SLAVE21_WLAST     (  ),
        .SLAVE21_WVALID    (  ),
        .SLAVE22_WLAST     (  ),
        .SLAVE22_WVALID    (  ),
        .SLAVE23_WLAST     (  ),
        .SLAVE23_WVALID    (  ),
        .SLAVE16_BREADY    (  ),
        .SLAVE17_BREADY    (  ),
        .SLAVE18_BREADY    (  ),
        .SLAVE19_BREADY    (  ),
        .SLAVE20_BREADY    (  ),
        .SLAVE21_BREADY    (  ),
        .SLAVE22_BREADY    (  ),
        .SLAVE23_BREADY    (  ),
        .SLAVE16_ARVALID   (  ),
        .SLAVE17_ARVALID   (  ),
        .SLAVE18_ARVALID   (  ),
        .SLAVE19_ARVALID   (  ),
        .SLAVE20_ARVALID   (  ),
        .SLAVE21_ARVALID   (  ),
        .SLAVE22_ARVALID   (  ),
        .SLAVE23_ARVALID   (  ),
        .SLAVE16_RREADY    (  ),
        .SLAVE17_RREADY    (  ),
        .SLAVE18_RREADY    (  ),
        .SLAVE19_RREADY    (  ),
        .SLAVE20_RREADY    (  ),
        .SLAVE21_RREADY    (  ),
        .SLAVE22_RREADY    (  ),
        .SLAVE23_RREADY    (  ),
        .SLAVE24_AWVALID   (  ),
        .SLAVE25_AWVALID   (  ),
        .SLAVE26_AWVALID   (  ),
        .SLAVE27_AWVALID   (  ),
        .SLAVE28_AWVALID   (  ),
        .SLAVE29_AWVALID   (  ),
        .SLAVE30_AWVALID   (  ),
        .SLAVE31_AWVALID   (  ),
        .SLAVE24_WLAST     (  ),
        .SLAVE24_WVALID    (  ),
        .SLAVE25_WLAST     (  ),
        .SLAVE25_WVALID    (  ),
        .SLAVE26_WLAST     (  ),
        .SLAVE26_WVALID    (  ),
        .SLAVE27_WLAST     (  ),
        .SLAVE27_WVALID    (  ),
        .SLAVE28_WLAST     (  ),
        .SLAVE28_WVALID    (  ),
        .SLAVE29_WLAST     (  ),
        .SLAVE29_WVALID    (  ),
        .SLAVE30_WLAST     (  ),
        .SLAVE30_WVALID    (  ),
        .SLAVE31_WLAST     (  ),
        .SLAVE31_WVALID    (  ),
        .SLAVE24_BREADY    (  ),
        .SLAVE25_BREADY    (  ),
        .SLAVE26_BREADY    (  ),
        .SLAVE27_BREADY    (  ),
        .SLAVE28_BREADY    (  ),
        .SLAVE29_BREADY    (  ),
        .SLAVE30_BREADY    (  ),
        .SLAVE31_BREADY    (  ),
        .SLAVE24_ARVALID   (  ),
        .SLAVE25_ARVALID   (  ),
        .SLAVE26_ARVALID   (  ),
        .SLAVE27_ARVALID   (  ),
        .SLAVE28_ARVALID   (  ),
        .SLAVE29_ARVALID   (  ),
        .SLAVE30_ARVALID   (  ),
        .SLAVE31_ARVALID   (  ),
        .SLAVE24_RREADY    (  ),
        .SLAVE25_RREADY    (  ),
        .SLAVE26_RREADY    (  ),
        .SLAVE27_RREADY    (  ),
        .SLAVE28_RREADY    (  ),
        .SLAVE29_RREADY    (  ),
        .SLAVE30_RREADY    (  ),
        .SLAVE31_RREADY    (  ),
        .MASTER0_BID       ( microsemi_wrapper_0_DATA_MASTER_BID ),
        .MASTER0_BRESP     ( microsemi_wrapper_0_DATA_MASTER_BRESP ),
        .MASTER0_BUSER     ( microsemi_wrapper_0_DATA_MASTER_BUSER ),
        .MASTER1_BID       (  ),
        .MASTER1_BRESP     (  ),
        .MASTER1_BUSER     (  ),
        .MASTER2_BID       (  ),
        .MASTER2_BRESP     (  ),
        .MASTER2_BUSER     (  ),
        .MASTER3_BID       (  ),
        .MASTER3_BRESP     (  ),
        .MASTER3_BUSER     (  ),
        .MASTER4_BID       (  ),
        .MASTER4_BRESP     (  ),
        .MASTER4_BUSER     (  ),
        .MASTER5_BID       (  ),
        .MASTER5_BRESP     (  ),
        .MASTER5_BUSER     (  ),
        .MASTER6_BID       (  ),
        .MASTER6_BRESP     (  ),
        .MASTER6_BUSER     (  ),
        .MASTER7_BID       (  ),
        .MASTER7_BRESP     (  ),
        .MASTER7_BUSER     (  ),
        .MASTER0_RID       ( microsemi_wrapper_0_DATA_MASTER_RID ),
        .MASTER0_RDATA     ( microsemi_wrapper_0_DATA_MASTER_RDATA ),
        .MASTER0_RRESP     ( microsemi_wrapper_0_DATA_MASTER_RRESP ),
        .MASTER0_RUSER     ( microsemi_wrapper_0_DATA_MASTER_RUSER ),
        .MASTER1_RID       (  ),
        .MASTER1_RDATA     (  ),
        .MASTER1_RRESP     (  ),
        .MASTER1_RUSER     (  ),
        .MASTER2_RID       (  ),
        .MASTER2_RDATA     (  ),
        .MASTER2_RRESP     (  ),
        .MASTER2_RUSER     (  ),
        .MASTER3_RID       (  ),
        .MASTER3_RDATA     (  ),
        .MASTER3_RRESP     (  ),
        .MASTER3_RUSER     (  ),
        .MASTER4_RID       (  ),
        .MASTER4_RDATA     (  ),
        .MASTER4_RRESP     (  ),
        .MASTER4_RUSER     (  ),
        .MASTER5_RID       (  ),
        .MASTER5_RDATA     (  ),
        .MASTER5_RRESP     (  ),
        .MASTER5_RUSER     (  ),
        .MASTER6_RID       (  ),
        .MASTER6_RDATA     (  ),
        .MASTER6_RRESP     (  ),
        .MASTER6_RUSER     (  ),
        .MASTER7_RID       (  ),
        .MASTER7_RDATA     (  ),
        .MASTER7_RRESP     (  ),
        .MASTER7_RUSER     (  ),
        .SLAVE0_AWID       ( CoreAXI4Interconnect_0_AXI3mslave0_AWID ),
        .SLAVE0_AWADDR     ( CoreAXI4Interconnect_0_AXI3mslave0_AWADDR ),
        .SLAVE0_AWLEN      ( CoreAXI4Interconnect_0_AXI3mslave0_AWLEN ),
        .SLAVE0_AWSIZE     ( CoreAXI4Interconnect_0_AXI3mslave0_AWSIZE ),
        .SLAVE0_AWBURST    ( CoreAXI4Interconnect_0_AXI3mslave0_AWBURST ),
        .SLAVE0_AWLOCK     ( CoreAXI4Interconnect_0_AXI3mslave0_AWLOCK ),
        .SLAVE0_AWCACHE    ( CoreAXI4Interconnect_0_AXI3mslave0_AWCACHE ),
        .SLAVE0_AWPROT     ( CoreAXI4Interconnect_0_AXI3mslave0_AWPROT ),
        .SLAVE0_AWREGION   (  ),
        .SLAVE0_AWQOS      (  ),
        .SLAVE0_AWUSER     ( CoreAXI4Interconnect_0_AXI3mslave0_AWUSER ),
        .SLAVE1_AWID       ( CoreAXI4Interconnect_0_AXI3mslave1_AWID ),
        .SLAVE1_AWADDR     ( CoreAXI4Interconnect_0_AXI3mslave1_AWADDR ),
        .SLAVE1_AWLEN      ( CoreAXI4Interconnect_0_AXI3mslave1_AWLEN ),
        .SLAVE1_AWSIZE     ( CoreAXI4Interconnect_0_AXI3mslave1_AWSIZE ),
        .SLAVE1_AWBURST    ( CoreAXI4Interconnect_0_AXI3mslave1_AWBURST ),
        .SLAVE1_AWLOCK     ( CoreAXI4Interconnect_0_AXI3mslave1_AWLOCK ),
        .SLAVE1_AWCACHE    ( CoreAXI4Interconnect_0_AXI3mslave1_AWCACHE ),
        .SLAVE1_AWPROT     ( CoreAXI4Interconnect_0_AXI3mslave1_AWPROT ),
        .SLAVE1_AWREGION   (  ),
        .SLAVE1_AWQOS      (  ),
        .SLAVE1_AWUSER     ( CoreAXI4Interconnect_0_AXI3mslave1_AWUSER ),
        .SLAVE2_AWID       ( CoreAXI4Interconnect_0_AXI3mslave2_AWID ),
        .SLAVE2_AWADDR     ( CoreAXI4Interconnect_0_AXI3mslave2_AWADDR ),
        .SLAVE2_AWLEN      ( CoreAXI4Interconnect_0_AXI3mslave2_AWLEN ),
        .SLAVE2_AWSIZE     ( CoreAXI4Interconnect_0_AXI3mslave2_AWSIZE ),
        .SLAVE2_AWBURST    ( CoreAXI4Interconnect_0_AXI3mslave2_AWBURST ),
        .SLAVE2_AWLOCK     ( CoreAXI4Interconnect_0_AXI3mslave2_AWLOCK ),
        .SLAVE2_AWCACHE    ( CoreAXI4Interconnect_0_AXI3mslave2_AWCACHE ),
        .SLAVE2_AWPROT     ( CoreAXI4Interconnect_0_AXI3mslave2_AWPROT ),
        .SLAVE2_AWREGION   (  ),
        .SLAVE2_AWQOS      (  ),
        .SLAVE2_AWUSER     ( CoreAXI4Interconnect_0_AXI3mslave2_AWUSER ),
        .SLAVE3_AWID       ( CoreAXI4Interconnect_0_AXI3mslave3_AWID ),
        .SLAVE3_AWADDR     ( CoreAXI4Interconnect_0_AXI3mslave3_AWADDR ),
        .SLAVE3_AWLEN      ( CoreAXI4Interconnect_0_AXI3mslave3_AWLEN ),
        .SLAVE3_AWSIZE     ( CoreAXI4Interconnect_0_AXI3mslave3_AWSIZE ),
        .SLAVE3_AWBURST    ( CoreAXI4Interconnect_0_AXI3mslave3_AWBURST ),
        .SLAVE3_AWLOCK     ( CoreAXI4Interconnect_0_AXI3mslave3_AWLOCK ),
        .SLAVE3_AWCACHE    ( CoreAXI4Interconnect_0_AXI3mslave3_AWCACHE ),
        .SLAVE3_AWPROT     ( CoreAXI4Interconnect_0_AXI3mslave3_AWPROT ),
        .SLAVE3_AWREGION   (  ),
        .SLAVE3_AWQOS      (  ),
        .SLAVE3_AWUSER     ( CoreAXI4Interconnect_0_AXI3mslave3_AWUSER ),
        .SLAVE4_AWID       ( CoreAXI4Interconnect_0_AXI3mslave4_AWID ),
        .SLAVE4_AWADDR     ( CoreAXI4Interconnect_0_AXI3mslave4_AWADDR ),
        .SLAVE4_AWLEN      ( CoreAXI4Interconnect_0_AXI3mslave4_AWLEN ),
        .SLAVE4_AWSIZE     ( CoreAXI4Interconnect_0_AXI3mslave4_AWSIZE ),
        .SLAVE4_AWBURST    ( CoreAXI4Interconnect_0_AXI3mslave4_AWBURST ),
        .SLAVE4_AWLOCK     ( CoreAXI4Interconnect_0_AXI3mslave4_AWLOCK ),
        .SLAVE4_AWCACHE    ( CoreAXI4Interconnect_0_AXI3mslave4_AWCACHE ),
        .SLAVE4_AWPROT     ( CoreAXI4Interconnect_0_AXI3mslave4_AWPROT ),
        .SLAVE4_AWREGION   (  ),
        .SLAVE4_AWQOS      (  ),
        .SLAVE4_AWUSER     ( CoreAXI4Interconnect_0_AXI3mslave4_AWUSER ),
        .SLAVE5_AWID       ( CoreAXI4Interconnect_0_AXI3mslave5_AWID ),
        .SLAVE5_AWADDR     ( CoreAXI4Interconnect_0_AXI3mslave5_AWADDR ),
        .SLAVE5_AWLEN      ( CoreAXI4Interconnect_0_AXI3mslave5_AWLEN ),
        .SLAVE5_AWSIZE     ( CoreAXI4Interconnect_0_AXI3mslave5_AWSIZE ),
        .SLAVE5_AWBURST    ( CoreAXI4Interconnect_0_AXI3mslave5_AWBURST ),
        .SLAVE5_AWLOCK     ( CoreAXI4Interconnect_0_AXI3mslave5_AWLOCK ),
        .SLAVE5_AWCACHE    ( CoreAXI4Interconnect_0_AXI3mslave5_AWCACHE ),
        .SLAVE5_AWPROT     ( CoreAXI4Interconnect_0_AXI3mslave5_AWPROT ),
        .SLAVE5_AWREGION   (  ),
        .SLAVE5_AWQOS      (  ),
        .SLAVE5_AWUSER     ( CoreAXI4Interconnect_0_AXI3mslave5_AWUSER ),
        .SLAVE6_AWID       ( CoreAXI4Interconnect_0_AXI3mslave6_AWID ),
        .SLAVE6_AWADDR     ( CoreAXI4Interconnect_0_AXI3mslave6_AWADDR ),
        .SLAVE6_AWLEN      ( CoreAXI4Interconnect_0_AXI3mslave6_AWLEN ),
        .SLAVE6_AWSIZE     ( CoreAXI4Interconnect_0_AXI3mslave6_AWSIZE ),
        .SLAVE6_AWBURST    ( CoreAXI4Interconnect_0_AXI3mslave6_AWBURST ),
        .SLAVE6_AWLOCK     ( CoreAXI4Interconnect_0_AXI3mslave6_AWLOCK ),
        .SLAVE6_AWCACHE    ( CoreAXI4Interconnect_0_AXI3mslave6_AWCACHE ),
        .SLAVE6_AWPROT     ( CoreAXI4Interconnect_0_AXI3mslave6_AWPROT ),
        .SLAVE6_AWREGION   (  ),
        .SLAVE6_AWQOS      (  ),
        .SLAVE6_AWUSER     ( CoreAXI4Interconnect_0_AXI3mslave6_AWUSER ),
        .SLAVE7_AWID       ( CoreAXI4Interconnect_0_AXI3mslave7_AWID ),
        .SLAVE7_AWADDR     ( CoreAXI4Interconnect_0_AXI3mslave7_AWADDR ),
        .SLAVE7_AWLEN      ( CoreAXI4Interconnect_0_AXI3mslave7_AWLEN ),
        .SLAVE7_AWSIZE     ( CoreAXI4Interconnect_0_AXI3mslave7_AWSIZE ),
        .SLAVE7_AWBURST    ( CoreAXI4Interconnect_0_AXI3mslave7_AWBURST ),
        .SLAVE7_AWLOCK     ( CoreAXI4Interconnect_0_AXI3mslave7_AWLOCK ),
        .SLAVE7_AWCACHE    ( CoreAXI4Interconnect_0_AXI3mslave7_AWCACHE ),
        .SLAVE7_AWPROT     ( CoreAXI4Interconnect_0_AXI3mslave7_AWPROT ),
        .SLAVE7_AWREGION   (  ),
        .SLAVE7_AWQOS      (  ),
        .SLAVE7_AWUSER     ( CoreAXI4Interconnect_0_AXI3mslave7_AWUSER ),
        .SLAVE0_WID        ( CoreAXI4Interconnect_0_AXI3mslave0_WID ),
        .SLAVE0_WDATA      ( CoreAXI4Interconnect_0_AXI3mslave0_WDATA ),
        .SLAVE0_WSTRB      ( CoreAXI4Interconnect_0_AXI3mslave0_WSTRB ),
        .SLAVE0_WUSER      ( CoreAXI4Interconnect_0_AXI3mslave0_WUSER ),
        .SLAVE1_WID        ( CoreAXI4Interconnect_0_AXI3mslave1_WID ),
        .SLAVE1_WDATA      ( CoreAXI4Interconnect_0_AXI3mslave1_WDATA ),
        .SLAVE1_WSTRB      ( CoreAXI4Interconnect_0_AXI3mslave1_WSTRB ),
        .SLAVE1_WUSER      ( CoreAXI4Interconnect_0_AXI3mslave1_WUSER ),
        .SLAVE2_WID        ( CoreAXI4Interconnect_0_AXI3mslave2_WID ),
        .SLAVE2_WDATA      ( CoreAXI4Interconnect_0_AXI3mslave2_WDATA ),
        .SLAVE2_WSTRB      ( CoreAXI4Interconnect_0_AXI3mslave2_WSTRB ),
        .SLAVE2_WUSER      ( CoreAXI4Interconnect_0_AXI3mslave2_WUSER ),
        .SLAVE3_WID        ( CoreAXI4Interconnect_0_AXI3mslave3_WID ),
        .SLAVE3_WDATA      ( CoreAXI4Interconnect_0_AXI3mslave3_WDATA ),
        .SLAVE3_WSTRB      ( CoreAXI4Interconnect_0_AXI3mslave3_WSTRB ),
        .SLAVE3_WUSER      ( CoreAXI4Interconnect_0_AXI3mslave3_WUSER ),
        .SLAVE4_WID        ( CoreAXI4Interconnect_0_AXI3mslave4_WID ),
        .SLAVE4_WDATA      ( CoreAXI4Interconnect_0_AXI3mslave4_WDATA ),
        .SLAVE4_WSTRB      ( CoreAXI4Interconnect_0_AXI3mslave4_WSTRB ),
        .SLAVE4_WUSER      ( CoreAXI4Interconnect_0_AXI3mslave4_WUSER ),
        .SLAVE5_WID        ( CoreAXI4Interconnect_0_AXI3mslave5_WID ),
        .SLAVE5_WDATA      ( CoreAXI4Interconnect_0_AXI3mslave5_WDATA ),
        .SLAVE5_WSTRB      ( CoreAXI4Interconnect_0_AXI3mslave5_WSTRB ),
        .SLAVE5_WUSER      ( CoreAXI4Interconnect_0_AXI3mslave5_WUSER ),
        .SLAVE6_WID        ( CoreAXI4Interconnect_0_AXI3mslave6_WID ),
        .SLAVE6_WDATA      ( CoreAXI4Interconnect_0_AXI3mslave6_WDATA ),
        .SLAVE6_WSTRB      ( CoreAXI4Interconnect_0_AXI3mslave6_WSTRB ),
        .SLAVE6_WUSER      ( CoreAXI4Interconnect_0_AXI3mslave6_WUSER ),
        .SLAVE7_WID        ( CoreAXI4Interconnect_0_AXI3mslave7_WID ),
        .SLAVE7_WDATA      ( CoreAXI4Interconnect_0_AXI3mslave7_WDATA ),
        .SLAVE7_WSTRB      ( CoreAXI4Interconnect_0_AXI3mslave7_WSTRB ),
        .SLAVE7_WUSER      ( CoreAXI4Interconnect_0_AXI3mslave7_WUSER ),
        .SLAVE0_ARID       ( CoreAXI4Interconnect_0_AXI3mslave0_ARID ),
        .SLAVE0_ARADDR     ( CoreAXI4Interconnect_0_AXI3mslave0_ARADDR ),
        .SLAVE0_ARLEN      ( CoreAXI4Interconnect_0_AXI3mslave0_ARLEN ),
        .SLAVE0_ARSIZE     ( CoreAXI4Interconnect_0_AXI3mslave0_ARSIZE ),
        .SLAVE0_ARBURST    ( CoreAXI4Interconnect_0_AXI3mslave0_ARBURST ),
        .SLAVE0_ARLOCK     ( CoreAXI4Interconnect_0_AXI3mslave0_ARLOCK ),
        .SLAVE0_ARCACHE    ( CoreAXI4Interconnect_0_AXI3mslave0_ARCACHE ),
        .SLAVE0_ARPROT     ( CoreAXI4Interconnect_0_AXI3mslave0_ARPROT ),
        .SLAVE0_ARREGION   (  ),
        .SLAVE0_ARQOS      (  ),
        .SLAVE0_ARUSER     ( CoreAXI4Interconnect_0_AXI3mslave0_ARUSER ),
        .SLAVE1_ARID       ( CoreAXI4Interconnect_0_AXI3mslave1_ARID ),
        .SLAVE1_ARADDR     ( CoreAXI4Interconnect_0_AXI3mslave1_ARADDR ),
        .SLAVE1_ARLEN      ( CoreAXI4Interconnect_0_AXI3mslave1_ARLEN ),
        .SLAVE1_ARSIZE     ( CoreAXI4Interconnect_0_AXI3mslave1_ARSIZE ),
        .SLAVE1_ARBURST    ( CoreAXI4Interconnect_0_AXI3mslave1_ARBURST ),
        .SLAVE1_ARLOCK     ( CoreAXI4Interconnect_0_AXI3mslave1_ARLOCK ),
        .SLAVE1_ARCACHE    ( CoreAXI4Interconnect_0_AXI3mslave1_ARCACHE ),
        .SLAVE1_ARPROT     ( CoreAXI4Interconnect_0_AXI3mslave1_ARPROT ),
        .SLAVE1_ARREGION   (  ),
        .SLAVE1_ARQOS      (  ),
        .SLAVE1_ARUSER     ( CoreAXI4Interconnect_0_AXI3mslave1_ARUSER ),
        .SLAVE2_ARID       ( CoreAXI4Interconnect_0_AXI3mslave2_ARID ),
        .SLAVE2_ARADDR     ( CoreAXI4Interconnect_0_AXI3mslave2_ARADDR ),
        .SLAVE2_ARLEN      ( CoreAXI4Interconnect_0_AXI3mslave2_ARLEN ),
        .SLAVE2_ARSIZE     ( CoreAXI4Interconnect_0_AXI3mslave2_ARSIZE ),
        .SLAVE2_ARBURST    ( CoreAXI4Interconnect_0_AXI3mslave2_ARBURST ),
        .SLAVE2_ARLOCK     ( CoreAXI4Interconnect_0_AXI3mslave2_ARLOCK ),
        .SLAVE2_ARCACHE    ( CoreAXI4Interconnect_0_AXI3mslave2_ARCACHE ),
        .SLAVE2_ARPROT     ( CoreAXI4Interconnect_0_AXI3mslave2_ARPROT ),
        .SLAVE2_ARREGION   (  ),
        .SLAVE2_ARQOS      (  ),
        .SLAVE2_ARUSER     ( CoreAXI4Interconnect_0_AXI3mslave2_ARUSER ),
        .SLAVE3_ARID       ( CoreAXI4Interconnect_0_AXI3mslave3_ARID ),
        .SLAVE3_ARADDR     ( CoreAXI4Interconnect_0_AXI3mslave3_ARADDR ),
        .SLAVE3_ARLEN      ( CoreAXI4Interconnect_0_AXI3mslave3_ARLEN ),
        .SLAVE3_ARSIZE     ( CoreAXI4Interconnect_0_AXI3mslave3_ARSIZE ),
        .SLAVE3_ARBURST    ( CoreAXI4Interconnect_0_AXI3mslave3_ARBURST ),
        .SLAVE3_ARLOCK     ( CoreAXI4Interconnect_0_AXI3mslave3_ARLOCK ),
        .SLAVE3_ARCACHE    ( CoreAXI4Interconnect_0_AXI3mslave3_ARCACHE ),
        .SLAVE3_ARPROT     ( CoreAXI4Interconnect_0_AXI3mslave3_ARPROT ),
        .SLAVE3_ARREGION   (  ),
        .SLAVE3_ARQOS      (  ),
        .SLAVE3_ARUSER     ( CoreAXI4Interconnect_0_AXI3mslave3_ARUSER ),
        .SLAVE4_ARID       ( CoreAXI4Interconnect_0_AXI3mslave4_ARID ),
        .SLAVE4_ARADDR     ( CoreAXI4Interconnect_0_AXI3mslave4_ARADDR ),
        .SLAVE4_ARLEN      ( CoreAXI4Interconnect_0_AXI3mslave4_ARLEN ),
        .SLAVE4_ARSIZE     ( CoreAXI4Interconnect_0_AXI3mslave4_ARSIZE ),
        .SLAVE4_ARBURST    ( CoreAXI4Interconnect_0_AXI3mslave4_ARBURST ),
        .SLAVE4_ARLOCK     ( CoreAXI4Interconnect_0_AXI3mslave4_ARLOCK ),
        .SLAVE4_ARCACHE    ( CoreAXI4Interconnect_0_AXI3mslave4_ARCACHE ),
        .SLAVE4_ARPROT     ( CoreAXI4Interconnect_0_AXI3mslave4_ARPROT ),
        .SLAVE4_ARREGION   (  ),
        .SLAVE4_ARQOS      (  ),
        .SLAVE4_ARUSER     ( CoreAXI4Interconnect_0_AXI3mslave4_ARUSER ),
        .SLAVE5_ARID       ( CoreAXI4Interconnect_0_AXI3mslave5_ARID ),
        .SLAVE5_ARADDR     ( CoreAXI4Interconnect_0_AXI3mslave5_ARADDR ),
        .SLAVE5_ARLEN      ( CoreAXI4Interconnect_0_AXI3mslave5_ARLEN ),
        .SLAVE5_ARSIZE     ( CoreAXI4Interconnect_0_AXI3mslave5_ARSIZE ),
        .SLAVE5_ARBURST    ( CoreAXI4Interconnect_0_AXI3mslave5_ARBURST ),
        .SLAVE5_ARLOCK     ( CoreAXI4Interconnect_0_AXI3mslave5_ARLOCK ),
        .SLAVE5_ARCACHE    ( CoreAXI4Interconnect_0_AXI3mslave5_ARCACHE ),
        .SLAVE5_ARPROT     ( CoreAXI4Interconnect_0_AXI3mslave5_ARPROT ),
        .SLAVE5_ARREGION   (  ),
        .SLAVE5_ARQOS      (  ),
        .SLAVE5_ARUSER     ( CoreAXI4Interconnect_0_AXI3mslave5_ARUSER ),
        .SLAVE6_ARID       ( CoreAXI4Interconnect_0_AXI3mslave6_ARID ),
        .SLAVE6_ARADDR     ( CoreAXI4Interconnect_0_AXI3mslave6_ARADDR ),
        .SLAVE6_ARLEN      ( CoreAXI4Interconnect_0_AXI3mslave6_ARLEN ),
        .SLAVE6_ARSIZE     ( CoreAXI4Interconnect_0_AXI3mslave6_ARSIZE ),
        .SLAVE6_ARBURST    ( CoreAXI4Interconnect_0_AXI3mslave6_ARBURST ),
        .SLAVE6_ARLOCK     ( CoreAXI4Interconnect_0_AXI3mslave6_ARLOCK ),
        .SLAVE6_ARCACHE    ( CoreAXI4Interconnect_0_AXI3mslave6_ARCACHE ),
        .SLAVE6_ARPROT     ( CoreAXI4Interconnect_0_AXI3mslave6_ARPROT ),
        .SLAVE6_ARREGION   (  ),
        .SLAVE6_ARQOS      (  ),
        .SLAVE6_ARUSER     ( CoreAXI4Interconnect_0_AXI3mslave6_ARUSER ),
        .SLAVE7_ARID       ( CoreAXI4Interconnect_0_AXI3mslave7_ARID ),
        .SLAVE7_ARADDR     ( CoreAXI4Interconnect_0_AXI3mslave7_ARADDR ),
        .SLAVE7_ARLEN      ( CoreAXI4Interconnect_0_AXI3mslave7_ARLEN ),
        .SLAVE7_ARSIZE     ( CoreAXI4Interconnect_0_AXI3mslave7_ARSIZE ),
        .SLAVE7_ARBURST    ( CoreAXI4Interconnect_0_AXI3mslave7_ARBURST ),
        .SLAVE7_ARLOCK     ( CoreAXI4Interconnect_0_AXI3mslave7_ARLOCK ),
        .SLAVE7_ARCACHE    ( CoreAXI4Interconnect_0_AXI3mslave7_ARCACHE ),
        .SLAVE7_ARPROT     ( CoreAXI4Interconnect_0_AXI3mslave7_ARPROT ),
        .SLAVE7_ARREGION   (  ),
        .SLAVE7_ARQOS      (  ),
        .SLAVE7_ARUSER     ( CoreAXI4Interconnect_0_AXI3mslave7_ARUSER ),
        .MASTER0_HRDATA    (  ),
        .MASTER1_HRDATA    (  ),
        .MASTER2_HRDATA    (  ),
        .MASTER3_HRDATA    (  ),
        .MASTER4_HRDATA    (  ),
        .MASTER5_HRDATA    (  ),
        .MASTER6_HRDATA    (  ),
        .MASTER7_HRDATA    (  ),
        .SLAVE8_AWID       (  ),
        .SLAVE8_AWADDR     (  ),
        .SLAVE8_AWLEN      (  ),
        .SLAVE8_AWSIZE     (  ),
        .SLAVE8_AWBURST    (  ),
        .SLAVE8_AWLOCK     (  ),
        .SLAVE8_AWCACHE    (  ),
        .SLAVE8_AWPROT     (  ),
        .SLAVE8_AWREGION   (  ),
        .SLAVE8_AWQOS      (  ),
        .SLAVE8_AWUSER     (  ),
        .SLAVE9_AWID       (  ),
        .SLAVE9_AWADDR     (  ),
        .SLAVE9_AWLEN      (  ),
        .SLAVE9_AWSIZE     (  ),
        .SLAVE9_AWBURST    (  ),
        .SLAVE9_AWLOCK     (  ),
        .SLAVE9_AWCACHE    (  ),
        .SLAVE9_AWPROT     (  ),
        .SLAVE9_AWREGION   (  ),
        .SLAVE9_AWQOS      (  ),
        .SLAVE9_AWUSER     (  ),
        .SLAVE10_AWID      (  ),
        .SLAVE10_AWADDR    (  ),
        .SLAVE10_AWLEN     (  ),
        .SLAVE10_AWSIZE    (  ),
        .SLAVE10_AWBURST   (  ),
        .SLAVE10_AWLOCK    (  ),
        .SLAVE10_AWCACHE   (  ),
        .SLAVE10_AWPROT    (  ),
        .SLAVE10_AWREGION  (  ),
        .SLAVE10_AWQOS     (  ),
        .SLAVE10_AWUSER    (  ),
        .SLAVE11_AWID      (  ),
        .SLAVE11_AWADDR    (  ),
        .SLAVE11_AWLEN     (  ),
        .SLAVE11_AWSIZE    (  ),
        .SLAVE11_AWBURST   (  ),
        .SLAVE11_AWLOCK    (  ),
        .SLAVE11_AWCACHE   (  ),
        .SLAVE11_AWPROT    (  ),
        .SLAVE11_AWREGION  (  ),
        .SLAVE11_AWQOS     (  ),
        .SLAVE11_AWUSER    (  ),
        .SLAVE12_AWID      (  ),
        .SLAVE12_AWADDR    (  ),
        .SLAVE12_AWLEN     (  ),
        .SLAVE12_AWSIZE    (  ),
        .SLAVE12_AWBURST   (  ),
        .SLAVE12_AWLOCK    (  ),
        .SLAVE12_AWCACHE   (  ),
        .SLAVE12_AWPROT    (  ),
        .SLAVE12_AWREGION  (  ),
        .SLAVE12_AWQOS     (  ),
        .SLAVE12_AWUSER    (  ),
        .SLAVE13_AWID      (  ),
        .SLAVE13_AWADDR    (  ),
        .SLAVE13_AWLEN     (  ),
        .SLAVE13_AWSIZE    (  ),
        .SLAVE13_AWBURST   (  ),
        .SLAVE13_AWLOCK    (  ),
        .SLAVE13_AWCACHE   (  ),
        .SLAVE13_AWPROT    (  ),
        .SLAVE13_AWREGION  (  ),
        .SLAVE13_AWQOS     (  ),
        .SLAVE13_AWUSER    (  ),
        .SLAVE14_AWID      (  ),
        .SLAVE14_AWADDR    (  ),
        .SLAVE14_AWLEN     (  ),
        .SLAVE14_AWSIZE    (  ),
        .SLAVE14_AWBURST   (  ),
        .SLAVE14_AWLOCK    (  ),
        .SLAVE14_AWCACHE   (  ),
        .SLAVE14_AWPROT    (  ),
        .SLAVE14_AWREGION  (  ),
        .SLAVE14_AWQOS     (  ),
        .SLAVE14_AWUSER    (  ),
        .SLAVE15_AWID      (  ),
        .SLAVE15_AWADDR    (  ),
        .SLAVE15_AWLEN     (  ),
        .SLAVE15_AWSIZE    (  ),
        .SLAVE15_AWBURST   (  ),
        .SLAVE15_AWLOCK    (  ),
        .SLAVE15_AWCACHE   (  ),
        .SLAVE15_AWPROT    (  ),
        .SLAVE15_AWREGION  (  ),
        .SLAVE15_AWQOS     (  ),
        .SLAVE15_AWUSER    (  ),
        .SLAVE8_WID        (  ),
        .SLAVE8_WDATA      (  ),
        .SLAVE8_WSTRB      (  ),
        .SLAVE8_WUSER      (  ),
        .SLAVE9_WID        (  ),
        .SLAVE9_WDATA      (  ),
        .SLAVE9_WSTRB      (  ),
        .SLAVE9_WUSER      (  ),
        .SLAVE10_WID       (  ),
        .SLAVE10_WDATA     (  ),
        .SLAVE10_WSTRB     (  ),
        .SLAVE10_WUSER     (  ),
        .SLAVE11_WID       (  ),
        .SLAVE11_WDATA     (  ),
        .SLAVE11_WSTRB     (  ),
        .SLAVE11_WUSER     (  ),
        .SLAVE12_WID       (  ),
        .SLAVE12_WDATA     (  ),
        .SLAVE12_WSTRB     (  ),
        .SLAVE12_WUSER     (  ),
        .SLAVE13_WID       (  ),
        .SLAVE13_WDATA     (  ),
        .SLAVE13_WSTRB     (  ),
        .SLAVE13_WUSER     (  ),
        .SLAVE14_WID       (  ),
        .SLAVE14_WDATA     (  ),
        .SLAVE14_WSTRB     (  ),
        .SLAVE14_WUSER     (  ),
        .SLAVE15_WID       (  ),
        .SLAVE15_WDATA     (  ),
        .SLAVE15_WSTRB     (  ),
        .SLAVE15_WUSER     (  ),
        .SLAVE8_ARID       (  ),
        .SLAVE8_ARADDR     (  ),
        .SLAVE8_ARLEN      (  ),
        .SLAVE8_ARSIZE     (  ),
        .SLAVE8_ARBURST    (  ),
        .SLAVE8_ARLOCK     (  ),
        .SLAVE8_ARCACHE    (  ),
        .SLAVE8_ARPROT     (  ),
        .SLAVE8_ARREGION   (  ),
        .SLAVE8_ARQOS      (  ),
        .SLAVE8_ARUSER     (  ),
        .SLAVE9_ARID       (  ),
        .SLAVE9_ARADDR     (  ),
        .SLAVE9_ARLEN      (  ),
        .SLAVE9_ARSIZE     (  ),
        .SLAVE9_ARBURST    (  ),
        .SLAVE9_ARLOCK     (  ),
        .SLAVE9_ARCACHE    (  ),
        .SLAVE9_ARPROT     (  ),
        .SLAVE9_ARREGION   (  ),
        .SLAVE9_ARQOS      (  ),
        .SLAVE9_ARUSER     (  ),
        .SLAVE10_ARID      (  ),
        .SLAVE10_ARADDR    (  ),
        .SLAVE10_ARLEN     (  ),
        .SLAVE10_ARSIZE    (  ),
        .SLAVE10_ARBURST   (  ),
        .SLAVE10_ARLOCK    (  ),
        .SLAVE10_ARCACHE   (  ),
        .SLAVE10_ARPROT    (  ),
        .SLAVE10_ARREGION  (  ),
        .SLAVE10_ARQOS     (  ),
        .SLAVE10_ARUSER    (  ),
        .SLAVE11_ARID      (  ),
        .SLAVE11_ARADDR    (  ),
        .SLAVE11_ARLEN     (  ),
        .SLAVE11_ARSIZE    (  ),
        .SLAVE11_ARBURST   (  ),
        .SLAVE11_ARLOCK    (  ),
        .SLAVE11_ARCACHE   (  ),
        .SLAVE11_ARPROT    (  ),
        .SLAVE11_ARREGION  (  ),
        .SLAVE11_ARQOS     (  ),
        .SLAVE11_ARUSER    (  ),
        .SLAVE12_ARID      (  ),
        .SLAVE12_ARADDR    (  ),
        .SLAVE12_ARLEN     (  ),
        .SLAVE12_ARSIZE    (  ),
        .SLAVE12_ARBURST   (  ),
        .SLAVE12_ARLOCK    (  ),
        .SLAVE12_ARCACHE   (  ),
        .SLAVE12_ARPROT    (  ),
        .SLAVE12_ARREGION  (  ),
        .SLAVE12_ARQOS     (  ),
        .SLAVE12_ARUSER    (  ),
        .SLAVE13_ARID      (  ),
        .SLAVE13_ARADDR    (  ),
        .SLAVE13_ARLEN     (  ),
        .SLAVE13_ARSIZE    (  ),
        .SLAVE13_ARBURST   (  ),
        .SLAVE13_ARLOCK    (  ),
        .SLAVE13_ARCACHE   (  ),
        .SLAVE13_ARPROT    (  ),
        .SLAVE13_ARREGION  (  ),
        .SLAVE13_ARQOS     (  ),
        .SLAVE13_ARUSER    (  ),
        .SLAVE14_ARID      (  ),
        .SLAVE14_ARADDR    (  ),
        .SLAVE14_ARLEN     (  ),
        .SLAVE14_ARSIZE    (  ),
        .SLAVE14_ARBURST   (  ),
        .SLAVE14_ARLOCK    (  ),
        .SLAVE14_ARCACHE   (  ),
        .SLAVE14_ARPROT    (  ),
        .SLAVE14_ARREGION  (  ),
        .SLAVE14_ARQOS     (  ),
        .SLAVE14_ARUSER    (  ),
        .SLAVE15_ARID      (  ),
        .SLAVE15_ARADDR    (  ),
        .SLAVE15_ARLEN     (  ),
        .SLAVE15_ARSIZE    (  ),
        .SLAVE15_ARBURST   (  ),
        .SLAVE15_ARLOCK    (  ),
        .SLAVE15_ARCACHE   (  ),
        .SLAVE15_ARPROT    (  ),
        .SLAVE15_ARREGION  (  ),
        .SLAVE15_ARQOS     (  ),
        .SLAVE15_ARUSER    (  ),
        .SLAVE16_AWID      (  ),
        .SLAVE16_AWADDR    (  ),
        .SLAVE16_AWLEN     (  ),
        .SLAVE16_AWSIZE    (  ),
        .SLAVE16_AWBURST   (  ),
        .SLAVE16_AWLOCK    (  ),
        .SLAVE16_AWCACHE   (  ),
        .SLAVE16_AWPROT    (  ),
        .SLAVE16_AWREGION  (  ),
        .SLAVE16_AWQOS     (  ),
        .SLAVE16_AWUSER    (  ),
        .SLAVE17_AWID      (  ),
        .SLAVE17_AWADDR    (  ),
        .SLAVE17_AWLEN     (  ),
        .SLAVE17_AWSIZE    (  ),
        .SLAVE17_AWBURST   (  ),
        .SLAVE17_AWLOCK    (  ),
        .SLAVE17_AWCACHE   (  ),
        .SLAVE17_AWPROT    (  ),
        .SLAVE17_AWREGION  (  ),
        .SLAVE17_AWQOS     (  ),
        .SLAVE17_AWUSER    (  ),
        .SLAVE18_AWID      (  ),
        .SLAVE18_AWADDR    (  ),
        .SLAVE18_AWLEN     (  ),
        .SLAVE18_AWSIZE    (  ),
        .SLAVE18_AWBURST   (  ),
        .SLAVE18_AWLOCK    (  ),
        .SLAVE18_AWCACHE   (  ),
        .SLAVE18_AWPROT    (  ),
        .SLAVE18_AWREGION  (  ),
        .SLAVE18_AWQOS     (  ),
        .SLAVE18_AWUSER    (  ),
        .SLAVE19_AWID      (  ),
        .SLAVE19_AWADDR    (  ),
        .SLAVE19_AWLEN     (  ),
        .SLAVE19_AWSIZE    (  ),
        .SLAVE19_AWBURST   (  ),
        .SLAVE19_AWLOCK    (  ),
        .SLAVE19_AWCACHE   (  ),
        .SLAVE19_AWPROT    (  ),
        .SLAVE19_AWREGION  (  ),
        .SLAVE19_AWQOS     (  ),
        .SLAVE19_AWUSER    (  ),
        .SLAVE20_AWID      (  ),
        .SLAVE20_AWADDR    (  ),
        .SLAVE20_AWLEN     (  ),
        .SLAVE20_AWSIZE    (  ),
        .SLAVE20_AWBURST   (  ),
        .SLAVE20_AWLOCK    (  ),
        .SLAVE20_AWCACHE   (  ),
        .SLAVE20_AWPROT    (  ),
        .SLAVE20_AWREGION  (  ),
        .SLAVE20_AWQOS     (  ),
        .SLAVE20_AWUSER    (  ),
        .SLAVE21_AWID      (  ),
        .SLAVE21_AWADDR    (  ),
        .SLAVE21_AWLEN     (  ),
        .SLAVE21_AWSIZE    (  ),
        .SLAVE21_AWBURST   (  ),
        .SLAVE21_AWLOCK    (  ),
        .SLAVE21_AWCACHE   (  ),
        .SLAVE21_AWPROT    (  ),
        .SLAVE21_AWREGION  (  ),
        .SLAVE21_AWQOS     (  ),
        .SLAVE21_AWUSER    (  ),
        .SLAVE22_AWID      (  ),
        .SLAVE22_AWADDR    (  ),
        .SLAVE22_AWLEN     (  ),
        .SLAVE22_AWSIZE    (  ),
        .SLAVE22_AWBURST   (  ),
        .SLAVE22_AWLOCK    (  ),
        .SLAVE22_AWCACHE   (  ),
        .SLAVE22_AWPROT    (  ),
        .SLAVE22_AWREGION  (  ),
        .SLAVE22_AWQOS     (  ),
        .SLAVE22_AWUSER    (  ),
        .SLAVE23_AWID      (  ),
        .SLAVE23_AWADDR    (  ),
        .SLAVE23_AWLEN     (  ),
        .SLAVE23_AWSIZE    (  ),
        .SLAVE23_AWBURST   (  ),
        .SLAVE23_AWLOCK    (  ),
        .SLAVE23_AWCACHE   (  ),
        .SLAVE23_AWPROT    (  ),
        .SLAVE23_AWREGION  (  ),
        .SLAVE23_AWQOS     (  ),
        .SLAVE23_AWUSER    (  ),
        .SLAVE16_WID       (  ),
        .SLAVE16_WDATA     (  ),
        .SLAVE16_WSTRB     (  ),
        .SLAVE16_WUSER     (  ),
        .SLAVE17_WID       (  ),
        .SLAVE17_WDATA     (  ),
        .SLAVE17_WSTRB     (  ),
        .SLAVE17_WUSER     (  ),
        .SLAVE18_WID       (  ),
        .SLAVE18_WDATA     (  ),
        .SLAVE18_WSTRB     (  ),
        .SLAVE18_WUSER     (  ),
        .SLAVE19_WID       (  ),
        .SLAVE19_WDATA     (  ),
        .SLAVE19_WSTRB     (  ),
        .SLAVE19_WUSER     (  ),
        .SLAVE20_WID       (  ),
        .SLAVE20_WDATA     (  ),
        .SLAVE20_WSTRB     (  ),
        .SLAVE20_WUSER     (  ),
        .SLAVE21_WID       (  ),
        .SLAVE21_WDATA     (  ),
        .SLAVE21_WSTRB     (  ),
        .SLAVE21_WUSER     (  ),
        .SLAVE22_WID       (  ),
        .SLAVE22_WDATA     (  ),
        .SLAVE22_WSTRB     (  ),
        .SLAVE22_WUSER     (  ),
        .SLAVE23_WID       (  ),
        .SLAVE23_WDATA     (  ),
        .SLAVE23_WSTRB     (  ),
        .SLAVE23_WUSER     (  ),
        .SLAVE16_ARID      (  ),
        .SLAVE16_ARADDR    (  ),
        .SLAVE16_ARLEN     (  ),
        .SLAVE16_ARSIZE    (  ),
        .SLAVE16_ARBURST   (  ),
        .SLAVE16_ARLOCK    (  ),
        .SLAVE16_ARCACHE   (  ),
        .SLAVE16_ARPROT    (  ),
        .SLAVE16_ARREGION  (  ),
        .SLAVE16_ARQOS     (  ),
        .SLAVE16_ARUSER    (  ),
        .SLAVE17_ARID      (  ),
        .SLAVE17_ARADDR    (  ),
        .SLAVE17_ARLEN     (  ),
        .SLAVE17_ARSIZE    (  ),
        .SLAVE17_ARBURST   (  ),
        .SLAVE17_ARLOCK    (  ),
        .SLAVE17_ARCACHE   (  ),
        .SLAVE17_ARPROT    (  ),
        .SLAVE17_ARREGION  (  ),
        .SLAVE17_ARQOS     (  ),
        .SLAVE17_ARUSER    (  ),
        .SLAVE18_ARID      (  ),
        .SLAVE18_ARADDR    (  ),
        .SLAVE18_ARLEN     (  ),
        .SLAVE18_ARSIZE    (  ),
        .SLAVE18_ARBURST   (  ),
        .SLAVE18_ARLOCK    (  ),
        .SLAVE18_ARCACHE   (  ),
        .SLAVE18_ARPROT    (  ),
        .SLAVE18_ARREGION  (  ),
        .SLAVE18_ARQOS     (  ),
        .SLAVE18_ARUSER    (  ),
        .SLAVE19_ARID      (  ),
        .SLAVE19_ARADDR    (  ),
        .SLAVE19_ARLEN     (  ),
        .SLAVE19_ARSIZE    (  ),
        .SLAVE19_ARBURST   (  ),
        .SLAVE19_ARLOCK    (  ),
        .SLAVE19_ARCACHE   (  ),
        .SLAVE19_ARPROT    (  ),
        .SLAVE19_ARREGION  (  ),
        .SLAVE19_ARQOS     (  ),
        .SLAVE19_ARUSER    (  ),
        .SLAVE20_ARID      (  ),
        .SLAVE20_ARADDR    (  ),
        .SLAVE20_ARLEN     (  ),
        .SLAVE20_ARSIZE    (  ),
        .SLAVE20_ARBURST   (  ),
        .SLAVE20_ARLOCK    (  ),
        .SLAVE20_ARCACHE   (  ),
        .SLAVE20_ARPROT    (  ),
        .SLAVE20_ARREGION  (  ),
        .SLAVE20_ARQOS     (  ),
        .SLAVE20_ARUSER    (  ),
        .SLAVE21_ARID      (  ),
        .SLAVE21_ARADDR    (  ),
        .SLAVE21_ARLEN     (  ),
        .SLAVE21_ARSIZE    (  ),
        .SLAVE21_ARBURST   (  ),
        .SLAVE21_ARLOCK    (  ),
        .SLAVE21_ARCACHE   (  ),
        .SLAVE21_ARPROT    (  ),
        .SLAVE21_ARREGION  (  ),
        .SLAVE21_ARQOS     (  ),
        .SLAVE21_ARUSER    (  ),
        .SLAVE22_ARID      (  ),
        .SLAVE22_ARADDR    (  ),
        .SLAVE22_ARLEN     (  ),
        .SLAVE22_ARSIZE    (  ),
        .SLAVE22_ARBURST   (  ),
        .SLAVE22_ARLOCK    (  ),
        .SLAVE22_ARCACHE   (  ),
        .SLAVE22_ARPROT    (  ),
        .SLAVE22_ARREGION  (  ),
        .SLAVE22_ARQOS     (  ),
        .SLAVE22_ARUSER    (  ),
        .SLAVE23_ARID      (  ),
        .SLAVE23_ARADDR    (  ),
        .SLAVE23_ARLEN     (  ),
        .SLAVE23_ARSIZE    (  ),
        .SLAVE23_ARBURST   (  ),
        .SLAVE23_ARLOCK    (  ),
        .SLAVE23_ARCACHE   (  ),
        .SLAVE23_ARPROT    (  ),
        .SLAVE23_ARREGION  (  ),
        .SLAVE23_ARQOS     (  ),
        .SLAVE23_ARUSER    (  ),
        .SLAVE24_AWID      (  ),
        .SLAVE24_AWADDR    (  ),
        .SLAVE24_AWLEN     (  ),
        .SLAVE24_AWSIZE    (  ),
        .SLAVE24_AWBURST   (  ),
        .SLAVE24_AWLOCK    (  ),
        .SLAVE24_AWCACHE   (  ),
        .SLAVE24_AWPROT    (  ),
        .SLAVE24_AWREGION  (  ),
        .SLAVE24_AWQOS     (  ),
        .SLAVE24_AWUSER    (  ),
        .SLAVE25_AWID      (  ),
        .SLAVE25_AWADDR    (  ),
        .SLAVE25_AWLEN     (  ),
        .SLAVE25_AWSIZE    (  ),
        .SLAVE25_AWBURST   (  ),
        .SLAVE25_AWLOCK    (  ),
        .SLAVE25_AWCACHE   (  ),
        .SLAVE25_AWPROT    (  ),
        .SLAVE25_AWREGION  (  ),
        .SLAVE25_AWQOS     (  ),
        .SLAVE25_AWUSER    (  ),
        .SLAVE26_AWID      (  ),
        .SLAVE26_AWADDR    (  ),
        .SLAVE26_AWLEN     (  ),
        .SLAVE26_AWSIZE    (  ),
        .SLAVE26_AWBURST   (  ),
        .SLAVE26_AWLOCK    (  ),
        .SLAVE26_AWCACHE   (  ),
        .SLAVE26_AWPROT    (  ),
        .SLAVE26_AWREGION  (  ),
        .SLAVE26_AWQOS     (  ),
        .SLAVE26_AWUSER    (  ),
        .SLAVE27_AWID      (  ),
        .SLAVE27_AWADDR    (  ),
        .SLAVE27_AWLEN     (  ),
        .SLAVE27_AWSIZE    (  ),
        .SLAVE27_AWBURST   (  ),
        .SLAVE27_AWLOCK    (  ),
        .SLAVE27_AWCACHE   (  ),
        .SLAVE27_AWPROT    (  ),
        .SLAVE27_AWREGION  (  ),
        .SLAVE27_AWQOS     (  ),
        .SLAVE27_AWUSER    (  ),
        .SLAVE28_AWID      (  ),
        .SLAVE28_AWADDR    (  ),
        .SLAVE28_AWLEN     (  ),
        .SLAVE28_AWSIZE    (  ),
        .SLAVE28_AWBURST   (  ),
        .SLAVE28_AWLOCK    (  ),
        .SLAVE28_AWCACHE   (  ),
        .SLAVE28_AWPROT    (  ),
        .SLAVE28_AWREGION  (  ),
        .SLAVE28_AWQOS     (  ),
        .SLAVE28_AWUSER    (  ),
        .SLAVE29_AWID      (  ),
        .SLAVE29_AWADDR    (  ),
        .SLAVE29_AWLEN     (  ),
        .SLAVE29_AWSIZE    (  ),
        .SLAVE29_AWBURST   (  ),
        .SLAVE29_AWLOCK    (  ),
        .SLAVE29_AWCACHE   (  ),
        .SLAVE29_AWPROT    (  ),
        .SLAVE29_AWREGION  (  ),
        .SLAVE29_AWQOS     (  ),
        .SLAVE29_AWUSER    (  ),
        .SLAVE30_AWID      (  ),
        .SLAVE30_AWADDR    (  ),
        .SLAVE30_AWLEN     (  ),
        .SLAVE30_AWSIZE    (  ),
        .SLAVE30_AWBURST   (  ),
        .SLAVE30_AWLOCK    (  ),
        .SLAVE30_AWCACHE   (  ),
        .SLAVE30_AWPROT    (  ),
        .SLAVE30_AWREGION  (  ),
        .SLAVE30_AWQOS     (  ),
        .SLAVE30_AWUSER    (  ),
        .SLAVE31_AWID      (  ),
        .SLAVE31_AWADDR    (  ),
        .SLAVE31_AWLEN     (  ),
        .SLAVE31_AWSIZE    (  ),
        .SLAVE31_AWBURST   (  ),
        .SLAVE31_AWLOCK    (  ),
        .SLAVE31_AWCACHE   (  ),
        .SLAVE31_AWPROT    (  ),
        .SLAVE31_AWREGION  (  ),
        .SLAVE31_AWQOS     (  ),
        .SLAVE31_AWUSER    (  ),
        .SLAVE24_WID       (  ),
        .SLAVE24_WDATA     (  ),
        .SLAVE24_WSTRB     (  ),
        .SLAVE24_WUSER     (  ),
        .SLAVE25_WID       (  ),
        .SLAVE25_WDATA     (  ),
        .SLAVE25_WSTRB     (  ),
        .SLAVE25_WUSER     (  ),
        .SLAVE26_WID       (  ),
        .SLAVE26_WDATA     (  ),
        .SLAVE26_WSTRB     (  ),
        .SLAVE26_WUSER     (  ),
        .SLAVE27_WID       (  ),
        .SLAVE27_WDATA     (  ),
        .SLAVE27_WSTRB     (  ),
        .SLAVE27_WUSER     (  ),
        .SLAVE28_WID       (  ),
        .SLAVE28_WDATA     (  ),
        .SLAVE28_WSTRB     (  ),
        .SLAVE28_WUSER     (  ),
        .SLAVE29_WID       (  ),
        .SLAVE29_WDATA     (  ),
        .SLAVE29_WSTRB     (  ),
        .SLAVE29_WUSER     (  ),
        .SLAVE30_WID       (  ),
        .SLAVE30_WDATA     (  ),
        .SLAVE30_WSTRB     (  ),
        .SLAVE30_WUSER     (  ),
        .SLAVE31_WID       (  ),
        .SLAVE31_WDATA     (  ),
        .SLAVE31_WSTRB     (  ),
        .SLAVE31_WUSER     (  ),
        .SLAVE24_ARID      (  ),
        .SLAVE24_ARADDR    (  ),
        .SLAVE24_ARLEN     (  ),
        .SLAVE24_ARSIZE    (  ),
        .SLAVE24_ARBURST   (  ),
        .SLAVE24_ARLOCK    (  ),
        .SLAVE24_ARCACHE   (  ),
        .SLAVE24_ARPROT    (  ),
        .SLAVE24_ARREGION  (  ),
        .SLAVE24_ARQOS     (  ),
        .SLAVE24_ARUSER    (  ),
        .SLAVE25_ARID      (  ),
        .SLAVE25_ARADDR    (  ),
        .SLAVE25_ARLEN     (  ),
        .SLAVE25_ARSIZE    (  ),
        .SLAVE25_ARBURST   (  ),
        .SLAVE25_ARLOCK    (  ),
        .SLAVE25_ARCACHE   (  ),
        .SLAVE25_ARPROT    (  ),
        .SLAVE25_ARREGION  (  ),
        .SLAVE25_ARQOS     (  ),
        .SLAVE25_ARUSER    (  ),
        .SLAVE26_ARID      (  ),
        .SLAVE26_ARADDR    (  ),
        .SLAVE26_ARLEN     (  ),
        .SLAVE26_ARSIZE    (  ),
        .SLAVE26_ARBURST   (  ),
        .SLAVE26_ARLOCK    (  ),
        .SLAVE26_ARCACHE   (  ),
        .SLAVE26_ARPROT    (  ),
        .SLAVE26_ARREGION  (  ),
        .SLAVE26_ARQOS     (  ),
        .SLAVE26_ARUSER    (  ),
        .SLAVE27_ARID      (  ),
        .SLAVE27_ARADDR    (  ),
        .SLAVE27_ARLEN     (  ),
        .SLAVE27_ARSIZE    (  ),
        .SLAVE27_ARBURST   (  ),
        .SLAVE27_ARLOCK    (  ),
        .SLAVE27_ARCACHE   (  ),
        .SLAVE27_ARPROT    (  ),
        .SLAVE27_ARREGION  (  ),
        .SLAVE27_ARQOS     (  ),
        .SLAVE27_ARUSER    (  ),
        .SLAVE28_ARID      (  ),
        .SLAVE28_ARADDR    (  ),
        .SLAVE28_ARLEN     (  ),
        .SLAVE28_ARSIZE    (  ),
        .SLAVE28_ARBURST   (  ),
        .SLAVE28_ARLOCK    (  ),
        .SLAVE28_ARCACHE   (  ),
        .SLAVE28_ARPROT    (  ),
        .SLAVE28_ARREGION  (  ),
        .SLAVE28_ARQOS     (  ),
        .SLAVE28_ARUSER    (  ),
        .SLAVE29_ARID      (  ),
        .SLAVE29_ARADDR    (  ),
        .SLAVE29_ARLEN     (  ),
        .SLAVE29_ARSIZE    (  ),
        .SLAVE29_ARBURST   (  ),
        .SLAVE29_ARLOCK    (  ),
        .SLAVE29_ARCACHE   (  ),
        .SLAVE29_ARPROT    (  ),
        .SLAVE29_ARREGION  (  ),
        .SLAVE29_ARQOS     (  ),
        .SLAVE29_ARUSER    (  ),
        .SLAVE30_ARID      (  ),
        .SLAVE30_ARADDR    (  ),
        .SLAVE30_ARLEN     (  ),
        .SLAVE30_ARSIZE    (  ),
        .SLAVE30_ARBURST   (  ),
        .SLAVE30_ARLOCK    (  ),
        .SLAVE30_ARCACHE   (  ),
        .SLAVE30_ARPROT    (  ),
        .SLAVE30_ARREGION  (  ),
        .SLAVE30_ARQOS     (  ),
        .SLAVE30_ARUSER    (  ),
        .SLAVE31_ARID      (  ),
        .SLAVE31_ARADDR    (  ),
        .SLAVE31_ARLEN     (  ),
        .SLAVE31_ARSIZE    (  ),
        .SLAVE31_ARBURST   (  ),
        .SLAVE31_ARLOCK    (  ),
        .SLAVE31_ARCACHE   (  ),
        .SLAVE31_ARPROT    (  ),
        .SLAVE31_ARREGION  (  ),
        .SLAVE31_ARQOS     (  ),
        .SLAVE31_ARUSER    (  ) 
        );

//--------Top_Fabric_Master_CoreUARTapb_0_CoreUARTapb   -   Actel:DirectCore:CoreUARTapb:5.6.102
Top_Fabric_Master_CoreUARTapb_0_CoreUARTapb #( 
        .BAUD_VAL_FRCTN    ( 7 ),
        .BAUD_VAL_FRCTN_EN ( 1 ),
        .BAUD_VALUE        ( 9 ),
        .FAMILY            ( 19 ),
        .FIXEDMODE         ( 1 ),
        .PRG_BIT8          ( 1 ),
        .PRG_PARITY        ( 0 ),
        .RX_FIFO           ( 0 ),
        .RX_LEGACY_MODE    ( 0 ),
        .TX_FIFO           ( 1 ) )
CoreUARTapb_0(
        // Inputs
        .PCLK        ( my_mss_top_0_FIC_0_CLK_1 ),
        .PRESETN     ( my_mss_top_0_MSS_READY_0 ),
        .PSEL        ( axi_to_apb_0_APB_SLAVE_PSELx ),
        .PENABLE     ( axi_to_apb_0_APB_SLAVE_PENABLE ),
        .PWRITE      ( axi_to_apb_0_APB_SLAVE_PWRITE ),
        .RX          ( RX ),
        .PADDR       ( axi_to_apb_0_APB_SLAVE_PADDR_0 ),
        .PWDATA      ( axi_to_apb_0_APB_SLAVE_PWDATA_0 ),
        // Outputs
        .TXRDY       (  ),
        .RXRDY       (  ),
        .PARITY_ERR  (  ),
        .OVERFLOW    (  ),
        .TX          ( TX_net_0 ),
        .PREADY      ( axi_to_apb_0_APB_SLAVE_PREADY ),
        .PSLVERR     ( axi_to_apb_0_APB_SLAVE_PSLVERR ),
        .FRAMING_ERR (  ),
        .PRDATA      ( axi_to_apb_0_APB_SLAVE_PRDATA ) 
        );

//--------fabric_master
fabric_master #( 
        .IRAM_SIZE ( 32768 ),
        .WORD_SIZE ( 32 ) )
fabric_master_0(
        // Inputs
        .AWVALID       ( CoreAXI4Interconnect_0_AXI3mslave7_AWVALID ),
        .WLAST         ( CoreAXI4Interconnect_0_AXI3mslave7_WLAST ),
        .WVALID        ( CoreAXI4Interconnect_0_AXI3mslave7_WVALID ),
        .BREADY        ( CoreAXI4Interconnect_0_AXI3mslave7_BREADY ),
        .ARVALID       ( CoreAXI4Interconnect_0_AXI3mslave7_ARVALID ),
        .RREADY        ( CoreAXI4Interconnect_0_AXI3mslave7_RREADY ),
        .HCLK          ( my_mss_top_0_FIC_0_CLK_1 ),
        .HRESETn       ( my_mss_top_0_MSS_READY_0 ),
        .HREADY        ( fabric_master_0_BIF_1_HREADY ),
        .START         ( VCC_net ),
        .AWID          ( CoreAXI4Interconnect_0_AXI3mslave7_AWID_0 ),
        .AWADDR        ( CoreAXI4Interconnect_0_AXI3mslave7_AWADDR ),
        .AWLEN         ( CoreAXI4Interconnect_0_AXI3mslave7_AWLEN_0 ),
        .AWSIZE        ( CoreAXI4Interconnect_0_AXI3mslave7_AWSIZE ),
        .AWBURST       ( CoreAXI4Interconnect_0_AXI3mslave7_AWBURST ),
        .AWLOCK        ( CoreAXI4Interconnect_0_AXI3mslave7_AWLOCK ),
        .WID           ( CoreAXI4Interconnect_0_AXI3mslave7_WID_0 ),
        .WSTRB         ( CoreAXI4Interconnect_0_AXI3mslave7_WSTRB ),
        .WDATA         ( CoreAXI4Interconnect_0_AXI3mslave7_WDATA ),
        .ARID          ( CoreAXI4Interconnect_0_AXI3mslave7_ARID_0 ),
        .ARADDR        ( CoreAXI4Interconnect_0_AXI3mslave7_ARADDR ),
        .ARLEN         ( CoreAXI4Interconnect_0_AXI3mslave7_ARLEN_0 ),
        .ARSIZE        ( CoreAXI4Interconnect_0_AXI3mslave7_ARSIZE ),
        .ARLOCK        ( CoreAXI4Interconnect_0_AXI3mslave7_ARLOCK ),
        .ARBURST       ( CoreAXI4Interconnect_0_AXI3mslave7_ARBURST ),
        .HRDATA        ( fabric_master_0_BIF_1_HRDATA ),
        .HRESP         ( fabric_master_0_BIF_1_HRESP ),
        // Outputs
        .AWREADY       ( CoreAXI4Interconnect_0_AXI3mslave7_AWREADY ),
        .WREADY        ( CoreAXI4Interconnect_0_AXI3mslave7_WREADY ),
        .BVALID        ( CoreAXI4Interconnect_0_AXI3mslave7_BVALID ),
        .ARREADY       ( CoreAXI4Interconnect_0_AXI3mslave7_ARREADY ),
        .RLAST         ( CoreAXI4Interconnect_0_AXI3mslave7_RLAST ),
        .RVALID        ( CoreAXI4Interconnect_0_AXI3mslave7_RVALID ),
        .HWRITE        ( fabric_master_0_BIF_1_HWRITE ),
        .ahb_busy      (  ),
        .ram_init_done (  ),
        .BID           ( CoreAXI4Interconnect_0_AXI3mslave7_BID ),
        .BRESP         ( CoreAXI4Interconnect_0_AXI3mslave7_BRESP ),
        .RID           ( CoreAXI4Interconnect_0_AXI3mslave7_RID ),
        .RDATA         ( CoreAXI4Interconnect_0_AXI3mslave7_RDATA ),
        .RRESP         ( CoreAXI4Interconnect_0_AXI3mslave7_RRESP ),
        .HADDR         ( fabric_master_0_BIF_1_HADDR ),
        .HTRANS        ( fabric_master_0_BIF_1_HTRANS ),
        .HSIZE         ( fabric_master_0_BIF_1_HSIZE ),
        .HBURST        ( fabric_master_0_BIF_1_HBURST ),
        .HPROT         ( fabric_master_0_BIF_1_HPROT ),
        .HWDATA        ( fabric_master_0_BIF_1_HWDATA ),
        .RESP_err      (  ) 
        );

//--------microsemi_wrapper
microsemi_wrapper #( 
        .BRANCH_PREDICTORS     ( 0 ),
        .BYTE_SIZE             ( 8 ),
        .COUNTER_LENGTH        ( 64 ),
        .DIVIDE_ENABLE         ( 1 ),
        .ENABLE_EXCEPTIONS     ( 1 ),
        .ENABLE_EXT_INTERRUPTS ( 0 ),
        .FORWARD_ALU_ONLY      ( 1 ),
        .LVE_ENABLE            ( 0 ),
        .MULTIPLY_ENABLE       ( 1 ),
        .NUM_EXT_INTERRUPTS    ( 1 ),
        .PIPELINE_STAGES       ( 5 ),
        .POWER_OPTIMIZED       ( 0 ),
        .REGISTER_SIZE         ( 32 ),
        .RESET_VECTOR          ( 0 ),
        .SCRATCHPAD_ADDR_BITS  ( 10 ),
        .SHIFTER_MAX_CYCLES    ( 1 ),
        .TCRAM_SIZE            ( 32768 ) )
microsemi_wrapper_0(
        // Inputs
        .clk          ( my_mss_top_0_FIC_0_CLK_1 ),
        .clk_2x       ( my_mss_top_0_GL1 ),
        .reset        ( reset_IN_POST_INV0_0 ),
        .data_AWREADY ( microsemi_wrapper_0_DATA_MASTER_AWREADY ),
        .data_WREADY  ( microsemi_wrapper_0_DATA_MASTER_WREADY ),
        .data_BVALID  ( microsemi_wrapper_0_DATA_MASTER_BVALID ),
        .data_ARREADY ( microsemi_wrapper_0_DATA_MASTER_ARREADY ),
        .data_RLAST   ( microsemi_wrapper_0_DATA_MASTER_RLAST ),
        .data_RVALID  ( microsemi_wrapper_0_DATA_MASTER_RVALID ),
        .ram_AWVALID  ( CoreAXI4Interconnect_0_AXI3mslave0_AWVALID ),
        .ram_WLAST    ( CoreAXI4Interconnect_0_AXI3mslave0_WLAST ),
        .ram_WVALID   ( CoreAXI4Interconnect_0_AXI3mslave0_WVALID ),
        .ram_BREADY   ( CoreAXI4Interconnect_0_AXI3mslave0_BREADY ),
        .ram_ARVALID  ( CoreAXI4Interconnect_0_AXI3mslave0_ARVALID ),
        .ram_RREADY   ( CoreAXI4Interconnect_0_AXI3mslave0_RREADY ),
        .nvm_PENABLE  ( my_mss_top_0_AMBA_SLAVE_0_0_PENABLE ),
        .nvm_PWRITE   ( my_mss_top_0_AMBA_SLAVE_0_0_PWRITE ),
        .nvm_PSEL     ( my_mss_top_0_AMBA_SLAVE_0_0_PSELx ),
        .data_BID     ( microsemi_wrapper_0_DATA_MASTER_BID ),
        .data_BRESP   ( microsemi_wrapper_0_DATA_MASTER_BRESP ),
        .data_RID     ( microsemi_wrapper_0_DATA_MASTER_RID ),
        .data_RDATA   ( microsemi_wrapper_0_DATA_MASTER_RDATA ),
        .data_RRESP   ( microsemi_wrapper_0_DATA_MASTER_RRESP ),
        .ram_AWID     ( CoreAXI4Interconnect_0_AXI3mslave0_AWID_0 ),
        .ram_AWADDR   ( CoreAXI4Interconnect_0_AXI3mslave0_AWADDR ),
        .ram_AWLEN    ( CoreAXI4Interconnect_0_AXI3mslave0_AWLEN_0 ),
        .ram_AWSIZE   ( CoreAXI4Interconnect_0_AXI3mslave0_AWSIZE ),
        .ram_AWBURST  ( CoreAXI4Interconnect_0_AXI3mslave0_AWBURST ),
        .ram_AWLOCK   ( CoreAXI4Interconnect_0_AXI3mslave0_AWLOCK ),
        .ram_AWCACHE  ( CoreAXI4Interconnect_0_AXI3mslave0_AWCACHE ),
        .ram_AWPROT   ( CoreAXI4Interconnect_0_AXI3mslave0_AWPROT ),
        .ram_WID      ( CoreAXI4Interconnect_0_AXI3mslave0_WID_0 ),
        .ram_WDATA    ( CoreAXI4Interconnect_0_AXI3mslave0_WDATA ),
        .ram_WSTRB    ( CoreAXI4Interconnect_0_AXI3mslave0_WSTRB ),
        .ram_ARID     ( CoreAXI4Interconnect_0_AXI3mslave0_ARID_0 ),
        .ram_ARADDR   ( CoreAXI4Interconnect_0_AXI3mslave0_ARADDR ),
        .ram_ARLEN    ( CoreAXI4Interconnect_0_AXI3mslave0_ARLEN_0 ),
        .ram_ARSIZE   ( CoreAXI4Interconnect_0_AXI3mslave0_ARSIZE ),
        .ram_ARBURST  ( CoreAXI4Interconnect_0_AXI3mslave0_ARBURST ),
        .ram_ARLOCK   ( CoreAXI4Interconnect_0_AXI3mslave0_ARLOCK ),
        .ram_ARCACHE  ( CoreAXI4Interconnect_0_AXI3mslave0_ARCACHE ),
        .ram_ARPROT   ( CoreAXI4Interconnect_0_AXI3mslave0_ARPROT ),
        .nvm_PADDR    ( my_mss_top_0_AMBA_SLAVE_0_0_PADDR ),
        .nvm_PWDATA   ( my_mss_top_0_AMBA_SLAVE_0_0_PWDATA ),
        // Outputs
        .data_AWVALID ( microsemi_wrapper_0_DATA_MASTER_AWVALID ),
        .data_WLAST   ( microsemi_wrapper_0_DATA_MASTER_WLAST ),
        .data_WVALID  ( microsemi_wrapper_0_DATA_MASTER_WVALID ),
        .data_BREADY  ( microsemi_wrapper_0_DATA_MASTER_BREADY ),
        .data_ARVALID ( microsemi_wrapper_0_DATA_MASTER_ARVALID ),
        .data_RREADY  ( microsemi_wrapper_0_DATA_MASTER_RREADY ),
        .ram_AWREADY  ( CoreAXI4Interconnect_0_AXI3mslave0_AWREADY ),
        .ram_WREADY   ( CoreAXI4Interconnect_0_AXI3mslave0_WREADY ),
        .ram_BVALID   ( CoreAXI4Interconnect_0_AXI3mslave0_BVALID ),
        .ram_ARREADY  ( CoreAXI4Interconnect_0_AXI3mslave0_ARREADY ),
        .ram_RLAST    ( CoreAXI4Interconnect_0_AXI3mslave0_RLAST ),
        .ram_RVALID   ( CoreAXI4Interconnect_0_AXI3mslave0_RVALID ),
        .nvm_PREADY   ( my_mss_top_0_AMBA_SLAVE_0_0_PREADY ),
        .data_AWID    ( microsemi_wrapper_0_DATA_MASTER_AWID ),
        .data_AWADDR  ( microsemi_wrapper_0_DATA_MASTER_AWADDR ),
        .data_AWLEN   ( microsemi_wrapper_0_DATA_MASTER_AWLEN ),
        .data_AWSIZE  ( microsemi_wrapper_0_DATA_MASTER_AWSIZE ),
        .data_AWBURST ( microsemi_wrapper_0_DATA_MASTER_AWBURST ),
        .data_AWLOCK  ( microsemi_wrapper_0_DATA_MASTER_AWLOCK ),
        .data_AWCACHE ( microsemi_wrapper_0_DATA_MASTER_AWCACHE ),
        .data_AWPROT  ( microsemi_wrapper_0_DATA_MASTER_AWPROT ),
        .data_WID     ( microsemi_wrapper_0_DATA_MASTER_WID ),
        .data_WDATA   ( microsemi_wrapper_0_DATA_MASTER_WDATA ),
        .data_WSTRB   ( microsemi_wrapper_0_DATA_MASTER_WSTRB ),
        .data_ARID    ( microsemi_wrapper_0_DATA_MASTER_ARID ),
        .data_ARADDR  ( microsemi_wrapper_0_DATA_MASTER_ARADDR ),
        .data_ARLEN   ( microsemi_wrapper_0_DATA_MASTER_ARLEN ),
        .data_ARSIZE  ( microsemi_wrapper_0_DATA_MASTER_ARSIZE ),
        .data_ARBURST ( microsemi_wrapper_0_DATA_MASTER_ARBURST ),
        .data_ARLOCK  ( microsemi_wrapper_0_DATA_MASTER_ARLOCK ),
        .data_ARCACHE ( microsemi_wrapper_0_DATA_MASTER_ARCACHE ),
        .data_ARPROT  ( microsemi_wrapper_0_DATA_MASTER_ARPROT ),
        .ram_BID      ( CoreAXI4Interconnect_0_AXI3mslave0_BID ),
        .ram_BRESP    ( CoreAXI4Interconnect_0_AXI3mslave0_BRESP ),
        .ram_RID      ( CoreAXI4Interconnect_0_AXI3mslave0_RID ),
        .ram_RDATA    ( CoreAXI4Interconnect_0_AXI3mslave0_RDATA ),
        .ram_RRESP    ( CoreAXI4Interconnect_0_AXI3mslave0_RRESP ),
        .nvm_PRDATA   ( my_mss_top_0_AMBA_SLAVE_0_0_PRDATA ) 
        );

//--------my_mss_top
my_mss_top my_mss_top_0(
        // Inputs
        .DEVRST_N                   ( DEVRST_N ),
        .FAB_RESET_N                ( VCC_net ),
        .MMUART_0_RXD_F2M           ( GND_net ),
        .M3_RESET_N                 ( GND_net ),
        .AMBA_MASTER_0_HWRITE_M0    ( fabric_master_0_BIF_1_HWRITE ),
        .AMBA_MASTER_0_HMASTLOCK_M0 ( GND_net ), // tied to 1'b0 from definition
        .PREADYS1                   ( my_mss_top_0_AMBA_SLAVE_0_0_PREADY ),
        .PSLVERRS1                  ( GND_net ), // tied to 1'b0 from definition
        .AMBA_MASTER_0_HADDR_M0     ( fabric_master_0_BIF_1_HADDR ),
        .AMBA_MASTER_0_HTRANS_M0    ( fabric_master_0_BIF_1_HTRANS ),
        .AMBA_MASTER_0_HSIZE_M0     ( fabric_master_0_BIF_1_HSIZE ),
        .AMBA_MASTER_0_HBURST_M0    ( fabric_master_0_BIF_1_HBURST ),
        .AMBA_MASTER_0_HPROT_M0     ( fabric_master_0_BIF_1_HPROT ),
        .AMBA_MASTER_0_HWDATA_M0    ( fabric_master_0_BIF_1_HWDATA ),
        .PRDATAS1                   ( my_mss_top_0_AMBA_SLAVE_0_0_PRDATA ),
        // Outputs
        .MMUART_0_TXD_M2F           (  ),
        .INIT_DONE                  (  ),
        .MSS_READY                  ( my_mss_top_0_MSS_READY_0 ),
        .FIC_0_CLK                  ( my_mss_top_0_FIC_0_CLK_1 ),
        .FIC_0_LOCK                 (  ),
        .POWER_ON_RESET_N           (  ),
        .GL1                        ( my_mss_top_0_GL1 ),
        .AMBA_MASTER_0_HREADY_M0    ( fabric_master_0_BIF_1_HREADY ),
        .PSELS1                     ( my_mss_top_0_AMBA_SLAVE_0_0_PSELx ),
        .PENABLES                   ( my_mss_top_0_AMBA_SLAVE_0_0_PENABLE ),
        .PWRITES                    ( my_mss_top_0_AMBA_SLAVE_0_0_PWRITE ),
        .AMBA_MASTER_0_HRDATA_M0    ( fabric_master_0_BIF_1_HRDATA ),
        .AMBA_MASTER_0_HRESP_M0     ( fabric_master_0_BIF_1_HRESP ),
        .PADDRS                     ( my_mss_top_0_AMBA_SLAVE_0_0_PADDR ),
        .PWDATAS                    ( my_mss_top_0_AMBA_SLAVE_0_0_PWDATA ) 
        );


endmodule
