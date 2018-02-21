//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Wed Jun 22 16:36:08 2016
//Host        : FELIPEGS running 64-bit major release  (build 9200)
//Command     : generate_target system.bd
//Design      : system
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module axi_interconnect_imp_1IGFU7E
   (FCLK_CLK0,
    INT_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arready,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awready,
    M00_AXI_awvalid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wvalid,
    M_AXI1_araddr,
    M_AXI1_arburst,
    M_AXI1_arcache,
    M_AXI1_arlen,
    M_AXI1_arlock,
    M_AXI1_arprot,
    M_AXI1_arqos,
    M_AXI1_arready,
    M_AXI1_arsize,
    M_AXI1_arvalid,
    M_AXI1_rdata,
    M_AXI1_rlast,
    M_AXI1_rready,
    M_AXI1_rresp,
    M_AXI1_rvalid,
    M_AXI2_araddr,
    M_AXI2_arburst,
    M_AXI2_arcache,
    M_AXI2_arlen,
    M_AXI2_arlock,
    M_AXI2_arprot,
    M_AXI2_arqos,
    M_AXI2_arready,
    M_AXI2_arsize,
    M_AXI2_arvalid,
    M_AXI2_rdata,
    M_AXI2_rlast,
    M_AXI2_rready,
    M_AXI2_rresp,
    M_AXI2_rvalid,
    M_AXI3_araddr,
    M_AXI3_arburst,
    M_AXI3_arcache,
    M_AXI3_arlen,
    M_AXI3_arlock,
    M_AXI3_arprot,
    M_AXI3_arqos,
    M_AXI3_arready,
    M_AXI3_arsize,
    M_AXI3_arvalid,
    M_AXI3_rdata,
    M_AXI3_rlast,
    M_AXI3_rready,
    M_AXI3_rresp,
    M_AXI3_rvalid,
    M_AXIS_MM2S1_tdata,
    M_AXIS_MM2S1_tlast,
    M_AXIS_MM2S1_tready,
    M_AXIS_MM2S1_tvalid,
    M_AXIS_MM2S2_tdata,
    M_AXIS_MM2S2_tlast,
    M_AXIS_MM2S2_tready,
    M_AXIS_MM2S2_tvalid,
    M_AXIS_MM2S3_tdata,
    M_AXIS_MM2S3_tlast,
    M_AXIS_MM2S3_tready,
    M_AXIS_MM2S3_tvalid,
    M_AXIS_MM2S_tdata,
    M_AXIS_MM2S_tlast,
    M_AXIS_MM2S_tready,
    M_AXIS_MM2S_tvalid,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arid,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arsize,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awid,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awvalid,
    M_AXI_bid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rid,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wid,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    PER_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arburst,
    S00_AXI_arcache,
    S00_AXI_arid,
    S00_AXI_arlen,
    S00_AXI_arlock,
    S00_AXI_arprot,
    S00_AXI_arqos,
    S00_AXI_arready,
    S00_AXI_arsize,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awburst,
    S00_AXI_awcache,
    S00_AXI_awid,
    S00_AXI_awlen,
    S00_AXI_awlock,
    S00_AXI_awprot,
    S00_AXI_awqos,
    S00_AXI_awready,
    S00_AXI_awsize,
    S00_AXI_awvalid,
    S00_AXI_bid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rid,
    S00_AXI_rlast,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wid,
    S00_AXI_wlast,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wvalid,
    S_AXIS_S2MM_tdata,
    S_AXIS_S2MM_tlast,
    S_AXIS_S2MM_tready,
    S_AXIS_S2MM_tvalid,
    mm2s_introut0,
    mm2s_introut1,
    mm2s_introut2,
    mm2s_introut3,
    s2mm_introut0);
  input FCLK_CLK0;
  input [0:0]INT_ARESETN;
  output [31:0]M00_AXI_araddr;
  input [0:0]M00_AXI_arready;
  output [0:0]M00_AXI_arvalid;
  output [31:0]M00_AXI_awaddr;
  input [0:0]M00_AXI_awready;
  output [0:0]M00_AXI_awvalid;
  output [0:0]M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input [0:0]M00_AXI_bvalid;
  input [31:0]M00_AXI_rdata;
  output [0:0]M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input [0:0]M00_AXI_rvalid;
  output [31:0]M00_AXI_wdata;
  input [0:0]M00_AXI_wready;
  output [3:0]M00_AXI_wstrb;
  output [0:0]M00_AXI_wvalid;
  output [31:0]M_AXI1_araddr;
  output [1:0]M_AXI1_arburst;
  output [3:0]M_AXI1_arcache;
  output [3:0]M_AXI1_arlen;
  output [1:0]M_AXI1_arlock;
  output [2:0]M_AXI1_arprot;
  output [3:0]M_AXI1_arqos;
  input M_AXI1_arready;
  output [2:0]M_AXI1_arsize;
  output M_AXI1_arvalid;
  input [63:0]M_AXI1_rdata;
  input M_AXI1_rlast;
  output M_AXI1_rready;
  input [1:0]M_AXI1_rresp;
  input M_AXI1_rvalid;
  output [31:0]M_AXI2_araddr;
  output [1:0]M_AXI2_arburst;
  output [3:0]M_AXI2_arcache;
  output [3:0]M_AXI2_arlen;
  output [1:0]M_AXI2_arlock;
  output [2:0]M_AXI2_arprot;
  output [3:0]M_AXI2_arqos;
  input M_AXI2_arready;
  output [2:0]M_AXI2_arsize;
  output M_AXI2_arvalid;
  input [63:0]M_AXI2_rdata;
  input M_AXI2_rlast;
  output M_AXI2_rready;
  input [1:0]M_AXI2_rresp;
  input M_AXI2_rvalid;
  output [31:0]M_AXI3_araddr;
  output [1:0]M_AXI3_arburst;
  output [3:0]M_AXI3_arcache;
  output [3:0]M_AXI3_arlen;
  output [1:0]M_AXI3_arlock;
  output [2:0]M_AXI3_arprot;
  output [3:0]M_AXI3_arqos;
  input M_AXI3_arready;
  output [2:0]M_AXI3_arsize;
  output M_AXI3_arvalid;
  input [63:0]M_AXI3_rdata;
  input M_AXI3_rlast;
  output M_AXI3_rready;
  input [1:0]M_AXI3_rresp;
  input M_AXI3_rvalid;
  output [63:0]M_AXIS_MM2S1_tdata;
  output M_AXIS_MM2S1_tlast;
  input M_AXIS_MM2S1_tready;
  output M_AXIS_MM2S1_tvalid;
  output [63:0]M_AXIS_MM2S2_tdata;
  output M_AXIS_MM2S2_tlast;
  input M_AXIS_MM2S2_tready;
  output M_AXIS_MM2S2_tvalid;
  output [63:0]M_AXIS_MM2S3_tdata;
  output M_AXIS_MM2S3_tlast;
  input M_AXIS_MM2S3_tready;
  output M_AXIS_MM2S3_tvalid;
  output [63:0]M_AXIS_MM2S_tdata;
  output M_AXIS_MM2S_tlast;
  input M_AXIS_MM2S_tready;
  output M_AXIS_MM2S_tvalid;
  output [31:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [0:0]M_AXI_arid;
  output [3:0]M_AXI_arlen;
  output [1:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [2:0]M_AXI_arsize;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [0:0]M_AXI_awid;
  output [3:0]M_AXI_awlen;
  output [1:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output M_AXI_awvalid;
  input [5:0]M_AXI_bid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  input [5:0]M_AXI_rid;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  output [0:0]M_AXI_wid;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input [0:0]PER_ARESETN;
  input [31:0]S00_AXI_araddr;
  input [1:0]S00_AXI_arburst;
  input [3:0]S00_AXI_arcache;
  input [11:0]S00_AXI_arid;
  input [3:0]S00_AXI_arlen;
  input [1:0]S00_AXI_arlock;
  input [2:0]S00_AXI_arprot;
  input [3:0]S00_AXI_arqos;
  output S00_AXI_arready;
  input [2:0]S00_AXI_arsize;
  input S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  input [1:0]S00_AXI_awburst;
  input [3:0]S00_AXI_awcache;
  input [11:0]S00_AXI_awid;
  input [3:0]S00_AXI_awlen;
  input [1:0]S00_AXI_awlock;
  input [2:0]S00_AXI_awprot;
  input [3:0]S00_AXI_awqos;
  output S00_AXI_awready;
  input [2:0]S00_AXI_awsize;
  input S00_AXI_awvalid;
  output [11:0]S00_AXI_bid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output S00_AXI_bvalid;
  output [31:0]S00_AXI_rdata;
  output [11:0]S00_AXI_rid;
  output S00_AXI_rlast;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output S00_AXI_rvalid;
  input [31:0]S00_AXI_wdata;
  input [11:0]S00_AXI_wid;
  input S00_AXI_wlast;
  output S00_AXI_wready;
  input [3:0]S00_AXI_wstrb;
  input S00_AXI_wvalid;
  input [63:0]S_AXIS_S2MM_tdata;
  input S_AXIS_S2MM_tlast;
  output S_AXIS_S2MM_tready;
  input S_AXIS_S2MM_tvalid;
  output mm2s_introut0;
  output mm2s_introut1;
  output mm2s_introut2;
  output mm2s_introut3;
  output s2mm_introut0;

  wire [31:0]Conn10_ARADDR;
  wire [1:0]Conn10_ARBURST;
  wire [3:0]Conn10_ARCACHE;
  wire [3:0]Conn10_ARLEN;
  wire [1:0]Conn10_ARLOCK;
  wire [2:0]Conn10_ARPROT;
  wire [3:0]Conn10_ARQOS;
  wire Conn10_ARREADY;
  wire [2:0]Conn10_ARSIZE;
  wire Conn10_ARVALID;
  wire [63:0]Conn10_RDATA;
  wire Conn10_RLAST;
  wire Conn10_RREADY;
  wire [1:0]Conn10_RRESP;
  wire Conn10_RVALID;
  wire [31:0]Conn1_ARADDR;
  wire [0:0]Conn1_ARREADY;
  wire [0:0]Conn1_ARVALID;
  wire [31:0]Conn1_AWADDR;
  wire [0:0]Conn1_AWREADY;
  wire [0:0]Conn1_AWVALID;
  wire [0:0]Conn1_BREADY;
  wire [1:0]Conn1_BRESP;
  wire [0:0]Conn1_BVALID;
  wire [31:0]Conn1_RDATA;
  wire [0:0]Conn1_RREADY;
  wire [1:0]Conn1_RRESP;
  wire [0:0]Conn1_RVALID;
  wire [31:0]Conn1_WDATA;
  wire [0:0]Conn1_WREADY;
  wire [3:0]Conn1_WSTRB;
  wire [0:0]Conn1_WVALID;
  wire [63:0]Conn2_TDATA;
  wire Conn2_TLAST;
  wire Conn2_TREADY;
  wire Conn2_TVALID;
  wire [63:0]Conn3_TDATA;
  wire Conn3_TLAST;
  wire Conn3_TREADY;
  wire Conn3_TVALID;
  wire [63:0]Conn4_TDATA;
  wire Conn4_TLAST;
  wire Conn4_TREADY;
  wire Conn4_TVALID;
  wire [63:0]Conn5_TDATA;
  wire Conn5_TLAST;
  wire Conn5_TREADY;
  wire Conn5_TVALID;
  wire [63:0]Conn6_TDATA;
  wire Conn6_TLAST;
  wire Conn6_TREADY;
  wire Conn6_TVALID;
  wire [31:0]Conn7_ARADDR;
  wire [1:0]Conn7_ARBURST;
  wire [3:0]Conn7_ARCACHE;
  wire [0:0]Conn7_ARID;
  wire [3:0]Conn7_ARLEN;
  wire [1:0]Conn7_ARLOCK;
  wire [2:0]Conn7_ARPROT;
  wire [3:0]Conn7_ARQOS;
  wire Conn7_ARREADY;
  wire [2:0]Conn7_ARSIZE;
  wire Conn7_ARVALID;
  wire [31:0]Conn7_AWADDR;
  wire [1:0]Conn7_AWBURST;
  wire [3:0]Conn7_AWCACHE;
  wire [0:0]Conn7_AWID;
  wire [3:0]Conn7_AWLEN;
  wire [1:0]Conn7_AWLOCK;
  wire [2:0]Conn7_AWPROT;
  wire [3:0]Conn7_AWQOS;
  wire Conn7_AWREADY;
  wire [2:0]Conn7_AWSIZE;
  wire Conn7_AWVALID;
  wire [5:0]Conn7_BID;
  wire Conn7_BREADY;
  wire [1:0]Conn7_BRESP;
  wire Conn7_BVALID;
  wire [63:0]Conn7_RDATA;
  wire [5:0]Conn7_RID;
  wire Conn7_RLAST;
  wire Conn7_RREADY;
  wire [1:0]Conn7_RRESP;
  wire Conn7_RVALID;
  wire [63:0]Conn7_WDATA;
  wire [0:0]Conn7_WID;
  wire Conn7_WLAST;
  wire Conn7_WREADY;
  wire [7:0]Conn7_WSTRB;
  wire Conn7_WVALID;
  wire [31:0]Conn8_ARADDR;
  wire [1:0]Conn8_ARBURST;
  wire [3:0]Conn8_ARCACHE;
  wire [3:0]Conn8_ARLEN;
  wire [1:0]Conn8_ARLOCK;
  wire [2:0]Conn8_ARPROT;
  wire [3:0]Conn8_ARQOS;
  wire Conn8_ARREADY;
  wire [2:0]Conn8_ARSIZE;
  wire Conn8_ARVALID;
  wire [63:0]Conn8_RDATA;
  wire Conn8_RLAST;
  wire Conn8_RREADY;
  wire [1:0]Conn8_RRESP;
  wire Conn8_RVALID;
  wire [31:0]Conn9_ARADDR;
  wire [1:0]Conn9_ARBURST;
  wire [3:0]Conn9_ARCACHE;
  wire [3:0]Conn9_ARLEN;
  wire [1:0]Conn9_ARLOCK;
  wire [2:0]Conn9_ARPROT;
  wire [3:0]Conn9_ARQOS;
  wire Conn9_ARREADY;
  wire [2:0]Conn9_ARSIZE;
  wire Conn9_ARVALID;
  wire [63:0]Conn9_RDATA;
  wire Conn9_RLAST;
  wire Conn9_RREADY;
  wire [1:0]Conn9_RRESP;
  wire Conn9_RVALID;
  wire [31:0]S00_AXI_1_ARADDR;
  wire [1:0]S00_AXI_1_ARBURST;
  wire [3:0]S00_AXI_1_ARCACHE;
  wire [11:0]S00_AXI_1_ARID;
  wire [3:0]S00_AXI_1_ARLEN;
  wire [1:0]S00_AXI_1_ARLOCK;
  wire [2:0]S00_AXI_1_ARPROT;
  wire [3:0]S00_AXI_1_ARQOS;
  wire S00_AXI_1_ARREADY;
  wire [2:0]S00_AXI_1_ARSIZE;
  wire S00_AXI_1_ARVALID;
  wire [31:0]S00_AXI_1_AWADDR;
  wire [1:0]S00_AXI_1_AWBURST;
  wire [3:0]S00_AXI_1_AWCACHE;
  wire [11:0]S00_AXI_1_AWID;
  wire [3:0]S00_AXI_1_AWLEN;
  wire [1:0]S00_AXI_1_AWLOCK;
  wire [2:0]S00_AXI_1_AWPROT;
  wire [3:0]S00_AXI_1_AWQOS;
  wire S00_AXI_1_AWREADY;
  wire [2:0]S00_AXI_1_AWSIZE;
  wire S00_AXI_1_AWVALID;
  wire [11:0]S00_AXI_1_BID;
  wire S00_AXI_1_BREADY;
  wire [1:0]S00_AXI_1_BRESP;
  wire S00_AXI_1_BVALID;
  wire [31:0]S00_AXI_1_RDATA;
  wire [11:0]S00_AXI_1_RID;
  wire S00_AXI_1_RLAST;
  wire S00_AXI_1_RREADY;
  wire [1:0]S00_AXI_1_RRESP;
  wire S00_AXI_1_RVALID;
  wire [31:0]S00_AXI_1_WDATA;
  wire [11:0]S00_AXI_1_WID;
  wire S00_AXI_1_WLAST;
  wire S00_AXI_1_WREADY;
  wire [3:0]S00_AXI_1_WSTRB;
  wire S00_AXI_1_WVALID;
  wire [31:0]auto_pc_M_AXI_ARADDR;
  wire [2:0]auto_pc_M_AXI_ARPROT;
  wire [0:0]auto_pc_M_AXI_ARREADY;
  wire auto_pc_M_AXI_ARVALID;
  wire [31:0]auto_pc_M_AXI_AWADDR;
  wire [2:0]auto_pc_M_AXI_AWPROT;
  wire [0:0]auto_pc_M_AXI_AWREADY;
  wire auto_pc_M_AXI_AWVALID;
  wire auto_pc_M_AXI_BREADY;
  wire [1:0]auto_pc_M_AXI_BRESP;
  wire [0:0]auto_pc_M_AXI_BVALID;
  wire [31:0]auto_pc_M_AXI_RDATA;
  wire auto_pc_M_AXI_RREADY;
  wire [1:0]auto_pc_M_AXI_RRESP;
  wire [0:0]auto_pc_M_AXI_RVALID;
  wire [31:0]auto_pc_M_AXI_WDATA;
  wire [0:0]auto_pc_M_AXI_WREADY;
  wire [3:0]auto_pc_M_AXI_WSTRB;
  wire auto_pc_M_AXI_WVALID;
  wire [31:0]axi_crossbar_0_M00_AXI_ARADDR;
  wire [1:0]axi_crossbar_0_M00_AXI_ARBURST;
  wire [3:0]axi_crossbar_0_M00_AXI_ARCACHE;
  wire [0:0]axi_crossbar_0_M00_AXI_ARID;
  wire [7:0]axi_crossbar_0_M00_AXI_ARLEN;
  wire [0:0]axi_crossbar_0_M00_AXI_ARLOCK;
  wire [2:0]axi_crossbar_0_M00_AXI_ARPROT;
  wire [3:0]axi_crossbar_0_M00_AXI_ARQOS;
  wire axi_crossbar_0_M00_AXI_ARREADY;
  wire [3:0]axi_crossbar_0_M00_AXI_ARREGION;
  wire [2:0]axi_crossbar_0_M00_AXI_ARSIZE;
  wire [0:0]axi_crossbar_0_M00_AXI_ARVALID;
  wire [31:0]axi_crossbar_0_M00_AXI_AWADDR;
  wire [1:0]axi_crossbar_0_M00_AXI_AWBURST;
  wire [3:0]axi_crossbar_0_M00_AXI_AWCACHE;
  wire [0:0]axi_crossbar_0_M00_AXI_AWID;
  wire [7:0]axi_crossbar_0_M00_AXI_AWLEN;
  wire [0:0]axi_crossbar_0_M00_AXI_AWLOCK;
  wire [2:0]axi_crossbar_0_M00_AXI_AWPROT;
  wire [3:0]axi_crossbar_0_M00_AXI_AWQOS;
  wire axi_crossbar_0_M00_AXI_AWREADY;
  wire [3:0]axi_crossbar_0_M00_AXI_AWREGION;
  wire [2:0]axi_crossbar_0_M00_AXI_AWSIZE;
  wire [0:0]axi_crossbar_0_M00_AXI_AWVALID;
  wire [0:0]axi_crossbar_0_M00_AXI_BID;
  wire [0:0]axi_crossbar_0_M00_AXI_BREADY;
  wire [1:0]axi_crossbar_0_M00_AXI_BRESP;
  wire axi_crossbar_0_M00_AXI_BVALID;
  wire [63:0]axi_crossbar_0_M00_AXI_RDATA;
  wire [0:0]axi_crossbar_0_M00_AXI_RID;
  wire axi_crossbar_0_M00_AXI_RLAST;
  wire [0:0]axi_crossbar_0_M00_AXI_RREADY;
  wire [1:0]axi_crossbar_0_M00_AXI_RRESP;
  wire axi_crossbar_0_M00_AXI_RVALID;
  wire [63:0]axi_crossbar_0_M00_AXI_WDATA;
  wire [0:0]axi_crossbar_0_M00_AXI_WLAST;
  wire axi_crossbar_0_M00_AXI_WREADY;
  wire [7:0]axi_crossbar_0_M00_AXI_WSTRB;
  wire [0:0]axi_crossbar_0_M00_AXI_WVALID;
  wire [31:0]axi_dma_0_M_AXI_MM2S_ARADDR;
  wire [1:0]axi_dma_0_M_AXI_MM2S_ARBURST;
  wire [3:0]axi_dma_0_M_AXI_MM2S_ARCACHE;
  wire [7:0]axi_dma_0_M_AXI_MM2S_ARLEN;
  wire [2:0]axi_dma_0_M_AXI_MM2S_ARPROT;
  wire [0:0]axi_dma_0_M_AXI_MM2S_ARREADY;
  wire [2:0]axi_dma_0_M_AXI_MM2S_ARSIZE;
  wire axi_dma_0_M_AXI_MM2S_ARVALID;
  wire [63:0]axi_dma_0_M_AXI_MM2S_RDATA;
  wire [0:0]axi_dma_0_M_AXI_MM2S_RLAST;
  wire axi_dma_0_M_AXI_MM2S_RREADY;
  wire [1:0]axi_dma_0_M_AXI_MM2S_RRESP;
  wire [0:0]axi_dma_0_M_AXI_MM2S_RVALID;
  wire [31:0]axi_dma_0_M_AXI_S2MM_AWADDR;
  wire [1:0]axi_dma_0_M_AXI_S2MM_AWBURST;
  wire [3:0]axi_dma_0_M_AXI_S2MM_AWCACHE;
  wire [7:0]axi_dma_0_M_AXI_S2MM_AWLEN;
  wire [2:0]axi_dma_0_M_AXI_S2MM_AWPROT;
  wire [1:1]axi_dma_0_M_AXI_S2MM_AWREADY;
  wire [2:0]axi_dma_0_M_AXI_S2MM_AWSIZE;
  wire axi_dma_0_M_AXI_S2MM_AWVALID;
  wire axi_dma_0_M_AXI_S2MM_BREADY;
  wire [3:2]axi_dma_0_M_AXI_S2MM_BRESP;
  wire [1:1]axi_dma_0_M_AXI_S2MM_BVALID;
  wire [63:0]axi_dma_0_M_AXI_S2MM_WDATA;
  wire axi_dma_0_M_AXI_S2MM_WLAST;
  wire [1:1]axi_dma_0_M_AXI_S2MM_WREADY;
  wire [7:0]axi_dma_0_M_AXI_S2MM_WSTRB;
  wire axi_dma_0_M_AXI_S2MM_WVALID;
  wire axi_dma_0_mm2s_introut;
  wire axi_dma_0_s2mm_introut;
  wire [31:0]axi_dma_1_M_AXI_MM2S_ARADDR;
  wire [1:0]axi_dma_1_M_AXI_MM2S_ARBURST;
  wire [3:0]axi_dma_1_M_AXI_MM2S_ARCACHE;
  wire [7:0]axi_dma_1_M_AXI_MM2S_ARLEN;
  wire [2:0]axi_dma_1_M_AXI_MM2S_ARPROT;
  wire axi_dma_1_M_AXI_MM2S_ARREADY;
  wire [2:0]axi_dma_1_M_AXI_MM2S_ARSIZE;
  wire axi_dma_1_M_AXI_MM2S_ARVALID;
  wire [63:0]axi_dma_1_M_AXI_MM2S_RDATA;
  wire axi_dma_1_M_AXI_MM2S_RLAST;
  wire axi_dma_1_M_AXI_MM2S_RREADY;
  wire [1:0]axi_dma_1_M_AXI_MM2S_RRESP;
  wire axi_dma_1_M_AXI_MM2S_RVALID;
  wire axi_dma_1_mm2s_introut;
  wire [31:0]axi_dma_2_M_AXI_MM2S_ARADDR;
  wire [1:0]axi_dma_2_M_AXI_MM2S_ARBURST;
  wire [3:0]axi_dma_2_M_AXI_MM2S_ARCACHE;
  wire [7:0]axi_dma_2_M_AXI_MM2S_ARLEN;
  wire [2:0]axi_dma_2_M_AXI_MM2S_ARPROT;
  wire axi_dma_2_M_AXI_MM2S_ARREADY;
  wire [2:0]axi_dma_2_M_AXI_MM2S_ARSIZE;
  wire axi_dma_2_M_AXI_MM2S_ARVALID;
  wire [63:0]axi_dma_2_M_AXI_MM2S_RDATA;
  wire axi_dma_2_M_AXI_MM2S_RLAST;
  wire axi_dma_2_M_AXI_MM2S_RREADY;
  wire [1:0]axi_dma_2_M_AXI_MM2S_RRESP;
  wire axi_dma_2_M_AXI_MM2S_RVALID;
  wire axi_dma_2_mm2s_introut;
  wire [31:0]axi_dma_3_M_AXI_MM2S_ARADDR;
  wire [1:0]axi_dma_3_M_AXI_MM2S_ARBURST;
  wire [3:0]axi_dma_3_M_AXI_MM2S_ARCACHE;
  wire [7:0]axi_dma_3_M_AXI_MM2S_ARLEN;
  wire [2:0]axi_dma_3_M_AXI_MM2S_ARPROT;
  wire axi_dma_3_M_AXI_MM2S_ARREADY;
  wire [2:0]axi_dma_3_M_AXI_MM2S_ARSIZE;
  wire axi_dma_3_M_AXI_MM2S_ARVALID;
  wire [63:0]axi_dma_3_M_AXI_MM2S_RDATA;
  wire axi_dma_3_M_AXI_MM2S_RLAST;
  wire axi_dma_3_M_AXI_MM2S_RREADY;
  wire [1:0]axi_dma_3_M_AXI_MM2S_RRESP;
  wire axi_dma_3_M_AXI_MM2S_RVALID;
  wire axi_dma_3_mm2s_introut;
  wire processing_system7_0_FCLK_CLK0;
  wire [0:0]rst_processing_system7_0_100M_interconnect_aresetn;
  wire [0:0]rst_processing_system7_0_100M_peripheral_aresetn;
  wire [63:32]xbar_M01_AXI_ARADDR;
  wire xbar_M01_AXI_ARREADY;
  wire [1:1]xbar_M01_AXI_ARVALID;
  wire [63:32]xbar_M01_AXI_AWADDR;
  wire xbar_M01_AXI_AWREADY;
  wire [1:1]xbar_M01_AXI_AWVALID;
  wire [1:1]xbar_M01_AXI_BREADY;
  wire [1:0]xbar_M01_AXI_BRESP;
  wire xbar_M01_AXI_BVALID;
  wire [31:0]xbar_M01_AXI_RDATA;
  wire [1:1]xbar_M01_AXI_RREADY;
  wire [1:0]xbar_M01_AXI_RRESP;
  wire xbar_M01_AXI_RVALID;
  wire [63:32]xbar_M01_AXI_WDATA;
  wire xbar_M01_AXI_WREADY;
  wire [1:1]xbar_M01_AXI_WVALID;
  wire [95:64]xbar_M02_AXI_ARADDR;
  wire xbar_M02_AXI_ARREADY;
  wire [2:2]xbar_M02_AXI_ARVALID;
  wire [95:64]xbar_M02_AXI_AWADDR;
  wire xbar_M02_AXI_AWREADY;
  wire [2:2]xbar_M02_AXI_AWVALID;
  wire [2:2]xbar_M02_AXI_BREADY;
  wire [1:0]xbar_M02_AXI_BRESP;
  wire xbar_M02_AXI_BVALID;
  wire [31:0]xbar_M02_AXI_RDATA;
  wire [2:2]xbar_M02_AXI_RREADY;
  wire [1:0]xbar_M02_AXI_RRESP;
  wire xbar_M02_AXI_RVALID;
  wire [95:64]xbar_M02_AXI_WDATA;
  wire xbar_M02_AXI_WREADY;
  wire [2:2]xbar_M02_AXI_WVALID;
  wire [127:96]xbar_M03_AXI_ARADDR;
  wire xbar_M03_AXI_ARREADY;
  wire [3:3]xbar_M03_AXI_ARVALID;
  wire [127:96]xbar_M03_AXI_AWADDR;
  wire xbar_M03_AXI_AWREADY;
  wire [3:3]xbar_M03_AXI_AWVALID;
  wire [3:3]xbar_M03_AXI_BREADY;
  wire [1:0]xbar_M03_AXI_BRESP;
  wire xbar_M03_AXI_BVALID;
  wire [31:0]xbar_M03_AXI_RDATA;
  wire [3:3]xbar_M03_AXI_RREADY;
  wire [1:0]xbar_M03_AXI_RRESP;
  wire xbar_M03_AXI_RVALID;
  wire [127:96]xbar_M03_AXI_WDATA;
  wire xbar_M03_AXI_WREADY;
  wire [3:3]xbar_M03_AXI_WVALID;
  wire [159:128]xbar_M04_AXI_ARADDR;
  wire xbar_M04_AXI_ARREADY;
  wire [4:4]xbar_M04_AXI_ARVALID;
  wire [159:128]xbar_M04_AXI_AWADDR;
  wire xbar_M04_AXI_AWREADY;
  wire [4:4]xbar_M04_AXI_AWVALID;
  wire [4:4]xbar_M04_AXI_BREADY;
  wire [1:0]xbar_M04_AXI_BRESP;
  wire xbar_M04_AXI_BVALID;
  wire [31:0]xbar_M04_AXI_RDATA;
  wire [4:4]xbar_M04_AXI_RREADY;
  wire [1:0]xbar_M04_AXI_RRESP;
  wire xbar_M04_AXI_RVALID;
  wire [159:128]xbar_M04_AXI_WDATA;
  wire xbar_M04_AXI_WREADY;
  wire [4:4]xbar_M04_AXI_WVALID;
  wire [1:0]NLW_axi_crossbar_0_s_axi_awready_UNCONNECTED;
  wire [3:0]NLW_axi_crossbar_0_s_axi_bresp_UNCONNECTED;
  wire [1:0]NLW_axi_crossbar_0_s_axi_bvalid_UNCONNECTED;
  wire [1:0]NLW_axi_crossbar_0_s_axi_wready_UNCONNECTED;

  assign Conn10_ARREADY = M_AXI3_arready;
  assign Conn10_RDATA = M_AXI3_rdata[63:0];
  assign Conn10_RLAST = M_AXI3_rlast;
  assign Conn10_RRESP = M_AXI3_rresp[1:0];
  assign Conn10_RVALID = M_AXI3_rvalid;
  assign Conn1_ARREADY = M00_AXI_arready[0];
  assign Conn1_AWREADY = M00_AXI_awready[0];
  assign Conn1_BRESP = M00_AXI_bresp[1:0];
  assign Conn1_BVALID = M00_AXI_bvalid[0];
  assign Conn1_RDATA = M00_AXI_rdata[31:0];
  assign Conn1_RRESP = M00_AXI_rresp[1:0];
  assign Conn1_RVALID = M00_AXI_rvalid[0];
  assign Conn1_WREADY = M00_AXI_wready[0];
  assign Conn2_TREADY = M_AXIS_MM2S_tready;
  assign Conn3_TREADY = M_AXIS_MM2S1_tready;
  assign Conn4_TREADY = M_AXIS_MM2S2_tready;
  assign Conn5_TDATA = S_AXIS_S2MM_tdata[63:0];
  assign Conn5_TLAST = S_AXIS_S2MM_tlast;
  assign Conn5_TVALID = S_AXIS_S2MM_tvalid;
  assign Conn6_TREADY = M_AXIS_MM2S3_tready;
  assign Conn7_ARREADY = M_AXI_arready;
  assign Conn7_AWREADY = M_AXI_awready;
  assign Conn7_BID = M_AXI_bid[5:0];
  assign Conn7_BRESP = M_AXI_bresp[1:0];
  assign Conn7_BVALID = M_AXI_bvalid;
  assign Conn7_RDATA = M_AXI_rdata[63:0];
  assign Conn7_RID = M_AXI_rid[5:0];
  assign Conn7_RLAST = M_AXI_rlast;
  assign Conn7_RRESP = M_AXI_rresp[1:0];
  assign Conn7_RVALID = M_AXI_rvalid;
  assign Conn7_WREADY = M_AXI_wready;
  assign Conn8_ARREADY = M_AXI1_arready;
  assign Conn8_RDATA = M_AXI1_rdata[63:0];
  assign Conn8_RLAST = M_AXI1_rlast;
  assign Conn8_RRESP = M_AXI1_rresp[1:0];
  assign Conn8_RVALID = M_AXI1_rvalid;
  assign Conn9_ARREADY = M_AXI2_arready;
  assign Conn9_RDATA = M_AXI2_rdata[63:0];
  assign Conn9_RLAST = M_AXI2_rlast;
  assign Conn9_RRESP = M_AXI2_rresp[1:0];
  assign Conn9_RVALID = M_AXI2_rvalid;
  assign M00_AXI_araddr[31:0] = Conn1_ARADDR;
  assign M00_AXI_arvalid[0] = Conn1_ARVALID;
  assign M00_AXI_awaddr[31:0] = Conn1_AWADDR;
  assign M00_AXI_awvalid[0] = Conn1_AWVALID;
  assign M00_AXI_bready[0] = Conn1_BREADY;
  assign M00_AXI_rready[0] = Conn1_RREADY;
  assign M00_AXI_wdata[31:0] = Conn1_WDATA;
  assign M00_AXI_wstrb[3:0] = Conn1_WSTRB;
  assign M00_AXI_wvalid[0] = Conn1_WVALID;
  assign M_AXI1_araddr[31:0] = Conn8_ARADDR;
  assign M_AXI1_arburst[1:0] = Conn8_ARBURST;
  assign M_AXI1_arcache[3:0] = Conn8_ARCACHE;
  assign M_AXI1_arlen[3:0] = Conn8_ARLEN;
  assign M_AXI1_arlock[1:0] = Conn8_ARLOCK;
  assign M_AXI1_arprot[2:0] = Conn8_ARPROT;
  assign M_AXI1_arqos[3:0] = Conn8_ARQOS;
  assign M_AXI1_arsize[2:0] = Conn8_ARSIZE;
  assign M_AXI1_arvalid = Conn8_ARVALID;
  assign M_AXI1_rready = Conn8_RREADY;
  assign M_AXI2_araddr[31:0] = Conn9_ARADDR;
  assign M_AXI2_arburst[1:0] = Conn9_ARBURST;
  assign M_AXI2_arcache[3:0] = Conn9_ARCACHE;
  assign M_AXI2_arlen[3:0] = Conn9_ARLEN;
  assign M_AXI2_arlock[1:0] = Conn9_ARLOCK;
  assign M_AXI2_arprot[2:0] = Conn9_ARPROT;
  assign M_AXI2_arqos[3:0] = Conn9_ARQOS;
  assign M_AXI2_arsize[2:0] = Conn9_ARSIZE;
  assign M_AXI2_arvalid = Conn9_ARVALID;
  assign M_AXI2_rready = Conn9_RREADY;
  assign M_AXI3_araddr[31:0] = Conn10_ARADDR;
  assign M_AXI3_arburst[1:0] = Conn10_ARBURST;
  assign M_AXI3_arcache[3:0] = Conn10_ARCACHE;
  assign M_AXI3_arlen[3:0] = Conn10_ARLEN;
  assign M_AXI3_arlock[1:0] = Conn10_ARLOCK;
  assign M_AXI3_arprot[2:0] = Conn10_ARPROT;
  assign M_AXI3_arqos[3:0] = Conn10_ARQOS;
  assign M_AXI3_arsize[2:0] = Conn10_ARSIZE;
  assign M_AXI3_arvalid = Conn10_ARVALID;
  assign M_AXI3_rready = Conn10_RREADY;
  assign M_AXIS_MM2S1_tdata[63:0] = Conn3_TDATA;
  assign M_AXIS_MM2S1_tlast = Conn3_TLAST;
  assign M_AXIS_MM2S1_tvalid = Conn3_TVALID;
  assign M_AXIS_MM2S2_tdata[63:0] = Conn4_TDATA;
  assign M_AXIS_MM2S2_tlast = Conn4_TLAST;
  assign M_AXIS_MM2S2_tvalid = Conn4_TVALID;
  assign M_AXIS_MM2S3_tdata[63:0] = Conn6_TDATA;
  assign M_AXIS_MM2S3_tlast = Conn6_TLAST;
  assign M_AXIS_MM2S3_tvalid = Conn6_TVALID;
  assign M_AXIS_MM2S_tdata[63:0] = Conn2_TDATA;
  assign M_AXIS_MM2S_tlast = Conn2_TLAST;
  assign M_AXIS_MM2S_tvalid = Conn2_TVALID;
  assign M_AXI_araddr[31:0] = Conn7_ARADDR;
  assign M_AXI_arburst[1:0] = Conn7_ARBURST;
  assign M_AXI_arcache[3:0] = Conn7_ARCACHE;
  assign M_AXI_arid[0] = Conn7_ARID;
  assign M_AXI_arlen[3:0] = Conn7_ARLEN;
  assign M_AXI_arlock[1:0] = Conn7_ARLOCK;
  assign M_AXI_arprot[2:0] = Conn7_ARPROT;
  assign M_AXI_arqos[3:0] = Conn7_ARQOS;
  assign M_AXI_arsize[2:0] = Conn7_ARSIZE;
  assign M_AXI_arvalid = Conn7_ARVALID;
  assign M_AXI_awaddr[31:0] = Conn7_AWADDR;
  assign M_AXI_awburst[1:0] = Conn7_AWBURST;
  assign M_AXI_awcache[3:0] = Conn7_AWCACHE;
  assign M_AXI_awid[0] = Conn7_AWID;
  assign M_AXI_awlen[3:0] = Conn7_AWLEN;
  assign M_AXI_awlock[1:0] = Conn7_AWLOCK;
  assign M_AXI_awprot[2:0] = Conn7_AWPROT;
  assign M_AXI_awqos[3:0] = Conn7_AWQOS;
  assign M_AXI_awsize[2:0] = Conn7_AWSIZE;
  assign M_AXI_awvalid = Conn7_AWVALID;
  assign M_AXI_bready = Conn7_BREADY;
  assign M_AXI_rready = Conn7_RREADY;
  assign M_AXI_wdata[63:0] = Conn7_WDATA;
  assign M_AXI_wid[0] = Conn7_WID;
  assign M_AXI_wlast = Conn7_WLAST;
  assign M_AXI_wstrb[7:0] = Conn7_WSTRB;
  assign M_AXI_wvalid = Conn7_WVALID;
  assign S00_AXI_1_ARADDR = S00_AXI_araddr[31:0];
  assign S00_AXI_1_ARBURST = S00_AXI_arburst[1:0];
  assign S00_AXI_1_ARCACHE = S00_AXI_arcache[3:0];
  assign S00_AXI_1_ARID = S00_AXI_arid[11:0];
  assign S00_AXI_1_ARLEN = S00_AXI_arlen[3:0];
  assign S00_AXI_1_ARLOCK = S00_AXI_arlock[1:0];
  assign S00_AXI_1_ARPROT = S00_AXI_arprot[2:0];
  assign S00_AXI_1_ARQOS = S00_AXI_arqos[3:0];
  assign S00_AXI_1_ARSIZE = S00_AXI_arsize[2:0];
  assign S00_AXI_1_ARVALID = S00_AXI_arvalid;
  assign S00_AXI_1_AWADDR = S00_AXI_awaddr[31:0];
  assign S00_AXI_1_AWBURST = S00_AXI_awburst[1:0];
  assign S00_AXI_1_AWCACHE = S00_AXI_awcache[3:0];
  assign S00_AXI_1_AWID = S00_AXI_awid[11:0];
  assign S00_AXI_1_AWLEN = S00_AXI_awlen[3:0];
  assign S00_AXI_1_AWLOCK = S00_AXI_awlock[1:0];
  assign S00_AXI_1_AWPROT = S00_AXI_awprot[2:0];
  assign S00_AXI_1_AWQOS = S00_AXI_awqos[3:0];
  assign S00_AXI_1_AWSIZE = S00_AXI_awsize[2:0];
  assign S00_AXI_1_AWVALID = S00_AXI_awvalid;
  assign S00_AXI_1_BREADY = S00_AXI_bready;
  assign S00_AXI_1_RREADY = S00_AXI_rready;
  assign S00_AXI_1_WDATA = S00_AXI_wdata[31:0];
  assign S00_AXI_1_WID = S00_AXI_wid[11:0];
  assign S00_AXI_1_WLAST = S00_AXI_wlast;
  assign S00_AXI_1_WSTRB = S00_AXI_wstrb[3:0];
  assign S00_AXI_1_WVALID = S00_AXI_wvalid;
  assign S00_AXI_arready = S00_AXI_1_ARREADY;
  assign S00_AXI_awready = S00_AXI_1_AWREADY;
  assign S00_AXI_bid[11:0] = S00_AXI_1_BID;
  assign S00_AXI_bresp[1:0] = S00_AXI_1_BRESP;
  assign S00_AXI_bvalid = S00_AXI_1_BVALID;
  assign S00_AXI_rdata[31:0] = S00_AXI_1_RDATA;
  assign S00_AXI_rid[11:0] = S00_AXI_1_RID;
  assign S00_AXI_rlast = S00_AXI_1_RLAST;
  assign S00_AXI_rresp[1:0] = S00_AXI_1_RRESP;
  assign S00_AXI_rvalid = S00_AXI_1_RVALID;
  assign S00_AXI_wready = S00_AXI_1_WREADY;
  assign S_AXIS_S2MM_tready = Conn5_TREADY;
  assign mm2s_introut0 = axi_dma_0_mm2s_introut;
  assign mm2s_introut1 = axi_dma_1_mm2s_introut;
  assign mm2s_introut2 = axi_dma_2_mm2s_introut;
  assign mm2s_introut3 = axi_dma_3_mm2s_introut;
  assign processing_system7_0_FCLK_CLK0 = FCLK_CLK0;
  assign rst_processing_system7_0_100M_interconnect_aresetn = PER_ARESETN[0];
  assign rst_processing_system7_0_100M_peripheral_aresetn = INT_ARESETN[0];
  assign s2mm_introut0 = axi_dma_0_s2mm_introut;
  system_auto_pc_1 auto_pc
       (.aclk(processing_system7_0_FCLK_CLK0),
        .aresetn(rst_processing_system7_0_100M_peripheral_aresetn),
        .m_axi_araddr(auto_pc_M_AXI_ARADDR),
        .m_axi_arprot(auto_pc_M_AXI_ARPROT),
        .m_axi_arready(auto_pc_M_AXI_ARREADY),
        .m_axi_arvalid(auto_pc_M_AXI_ARVALID),
        .m_axi_awaddr(auto_pc_M_AXI_AWADDR),
        .m_axi_awprot(auto_pc_M_AXI_AWPROT),
        .m_axi_awready(auto_pc_M_AXI_AWREADY),
        .m_axi_awvalid(auto_pc_M_AXI_AWVALID),
        .m_axi_bready(auto_pc_M_AXI_BREADY),
        .m_axi_bresp(auto_pc_M_AXI_BRESP),
        .m_axi_bvalid(auto_pc_M_AXI_BVALID),
        .m_axi_rdata(auto_pc_M_AXI_RDATA),
        .m_axi_rready(auto_pc_M_AXI_RREADY),
        .m_axi_rresp(auto_pc_M_AXI_RRESP),
        .m_axi_rvalid(auto_pc_M_AXI_RVALID),
        .m_axi_wdata(auto_pc_M_AXI_WDATA),
        .m_axi_wready(auto_pc_M_AXI_WREADY),
        .m_axi_wstrb(auto_pc_M_AXI_WSTRB),
        .m_axi_wvalid(auto_pc_M_AXI_WVALID),
        .s_axi_araddr(S00_AXI_1_ARADDR),
        .s_axi_arburst(S00_AXI_1_ARBURST),
        .s_axi_arcache(S00_AXI_1_ARCACHE),
        .s_axi_arid(S00_AXI_1_ARID),
        .s_axi_arlen(S00_AXI_1_ARLEN),
        .s_axi_arlock(S00_AXI_1_ARLOCK),
        .s_axi_arprot(S00_AXI_1_ARPROT),
        .s_axi_arqos(S00_AXI_1_ARQOS),
        .s_axi_arready(S00_AXI_1_ARREADY),
        .s_axi_arsize(S00_AXI_1_ARSIZE),
        .s_axi_arvalid(S00_AXI_1_ARVALID),
        .s_axi_awaddr(S00_AXI_1_AWADDR),
        .s_axi_awburst(S00_AXI_1_AWBURST),
        .s_axi_awcache(S00_AXI_1_AWCACHE),
        .s_axi_awid(S00_AXI_1_AWID),
        .s_axi_awlen(S00_AXI_1_AWLEN),
        .s_axi_awlock(S00_AXI_1_AWLOCK),
        .s_axi_awprot(S00_AXI_1_AWPROT),
        .s_axi_awqos(S00_AXI_1_AWQOS),
        .s_axi_awready(S00_AXI_1_AWREADY),
        .s_axi_awsize(S00_AXI_1_AWSIZE),
        .s_axi_awvalid(S00_AXI_1_AWVALID),
        .s_axi_bid(S00_AXI_1_BID),
        .s_axi_bready(S00_AXI_1_BREADY),
        .s_axi_bresp(S00_AXI_1_BRESP),
        .s_axi_bvalid(S00_AXI_1_BVALID),
        .s_axi_rdata(S00_AXI_1_RDATA),
        .s_axi_rid(S00_AXI_1_RID),
        .s_axi_rlast(S00_AXI_1_RLAST),
        .s_axi_rready(S00_AXI_1_RREADY),
        .s_axi_rresp(S00_AXI_1_RRESP),
        .s_axi_rvalid(S00_AXI_1_RVALID),
        .s_axi_wdata(S00_AXI_1_WDATA),
        .s_axi_wid(S00_AXI_1_WID),
        .s_axi_wlast(S00_AXI_1_WLAST),
        .s_axi_wready(S00_AXI_1_WREADY),
        .s_axi_wstrb(S00_AXI_1_WSTRB),
        .s_axi_wvalid(S00_AXI_1_WVALID));
  system_axi_crossbar_0_0 axi_crossbar_0
       (.aclk(processing_system7_0_FCLK_CLK0),
        .aresetn(rst_processing_system7_0_100M_interconnect_aresetn),
        .m_axi_araddr(axi_crossbar_0_M00_AXI_ARADDR),
        .m_axi_arburst(axi_crossbar_0_M00_AXI_ARBURST),
        .m_axi_arcache(axi_crossbar_0_M00_AXI_ARCACHE),
        .m_axi_arid(axi_crossbar_0_M00_AXI_ARID),
        .m_axi_arlen(axi_crossbar_0_M00_AXI_ARLEN),
        .m_axi_arlock(axi_crossbar_0_M00_AXI_ARLOCK),
        .m_axi_arprot(axi_crossbar_0_M00_AXI_ARPROT),
        .m_axi_arqos(axi_crossbar_0_M00_AXI_ARQOS),
        .m_axi_arready(axi_crossbar_0_M00_AXI_ARREADY),
        .m_axi_arregion(axi_crossbar_0_M00_AXI_ARREGION),
        .m_axi_arsize(axi_crossbar_0_M00_AXI_ARSIZE),
        .m_axi_arvalid(axi_crossbar_0_M00_AXI_ARVALID),
        .m_axi_awaddr(axi_crossbar_0_M00_AXI_AWADDR),
        .m_axi_awburst(axi_crossbar_0_M00_AXI_AWBURST),
        .m_axi_awcache(axi_crossbar_0_M00_AXI_AWCACHE),
        .m_axi_awid(axi_crossbar_0_M00_AXI_AWID),
        .m_axi_awlen(axi_crossbar_0_M00_AXI_AWLEN),
        .m_axi_awlock(axi_crossbar_0_M00_AXI_AWLOCK),
        .m_axi_awprot(axi_crossbar_0_M00_AXI_AWPROT),
        .m_axi_awqos(axi_crossbar_0_M00_AXI_AWQOS),
        .m_axi_awready(axi_crossbar_0_M00_AXI_AWREADY),
        .m_axi_awregion(axi_crossbar_0_M00_AXI_AWREGION),
        .m_axi_awsize(axi_crossbar_0_M00_AXI_AWSIZE),
        .m_axi_awvalid(axi_crossbar_0_M00_AXI_AWVALID),
        .m_axi_bid(axi_crossbar_0_M00_AXI_BID),
        .m_axi_bready(axi_crossbar_0_M00_AXI_BREADY),
        .m_axi_bresp(axi_crossbar_0_M00_AXI_BRESP),
        .m_axi_bvalid(axi_crossbar_0_M00_AXI_BVALID),
        .m_axi_rdata(axi_crossbar_0_M00_AXI_RDATA),
        .m_axi_rid(axi_crossbar_0_M00_AXI_RID),
        .m_axi_rlast(axi_crossbar_0_M00_AXI_RLAST),
        .m_axi_rready(axi_crossbar_0_M00_AXI_RREADY),
        .m_axi_rresp(axi_crossbar_0_M00_AXI_RRESP),
        .m_axi_rvalid(axi_crossbar_0_M00_AXI_RVALID),
        .m_axi_wdata(axi_crossbar_0_M00_AXI_WDATA),
        .m_axi_wlast(axi_crossbar_0_M00_AXI_WLAST),
        .m_axi_wready(axi_crossbar_0_M00_AXI_WREADY),
        .m_axi_wstrb(axi_crossbar_0_M00_AXI_WSTRB),
        .m_axi_wvalid(axi_crossbar_0_M00_AXI_WVALID),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,axi_dma_0_M_AXI_MM2S_ARADDR}),
        .s_axi_arburst({1'b0,1'b0,axi_dma_0_M_AXI_MM2S_ARBURST}),
        .s_axi_arcache({1'b0,1'b0,1'b0,1'b0,axi_dma_0_M_AXI_MM2S_ARCACHE}),
        .s_axi_arid({1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,axi_dma_0_M_AXI_MM2S_ARLEN}),
        .s_axi_arlock({1'b0,1'b0}),
        .s_axi_arprot({1'b0,1'b0,1'b0,axi_dma_0_M_AXI_MM2S_ARPROT}),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(axi_dma_0_M_AXI_MM2S_ARREADY),
        .s_axi_arsize({1'b0,1'b0,1'b0,axi_dma_0_M_AXI_MM2S_ARSIZE}),
        .s_axi_arvalid({1'b0,axi_dma_0_M_AXI_MM2S_ARVALID}),
        .s_axi_awaddr({axi_dma_0_M_AXI_S2MM_AWADDR,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({axi_dma_0_M_AXI_S2MM_AWBURST,1'b0,1'b0}),
        .s_axi_awcache({axi_dma_0_M_AXI_S2MM_AWCACHE,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0}),
        .s_axi_awlen({axi_dma_0_M_AXI_S2MM_AWLEN,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlock({1'b0,1'b0}),
        .s_axi_awprot({axi_dma_0_M_AXI_S2MM_AWPROT,1'b0,1'b0,1'b0}),
        .s_axi_awqos({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready({axi_dma_0_M_AXI_S2MM_AWREADY,NLW_axi_crossbar_0_s_axi_awready_UNCONNECTED[0]}),
        .s_axi_awsize({axi_dma_0_M_AXI_S2MM_AWSIZE,1'b0,1'b0,1'b0}),
        .s_axi_awvalid({axi_dma_0_M_AXI_S2MM_AWVALID,1'b0}),
        .s_axi_bready({axi_dma_0_M_AXI_S2MM_BREADY,1'b0}),
        .s_axi_bresp({axi_dma_0_M_AXI_S2MM_BRESP,NLW_axi_crossbar_0_s_axi_bresp_UNCONNECTED[1:0]}),
        .s_axi_bvalid({axi_dma_0_M_AXI_S2MM_BVALID,NLW_axi_crossbar_0_s_axi_bvalid_UNCONNECTED[0]}),
        .s_axi_rdata(axi_dma_0_M_AXI_MM2S_RDATA),
        .s_axi_rlast(axi_dma_0_M_AXI_MM2S_RLAST),
        .s_axi_rready({1'b0,axi_dma_0_M_AXI_MM2S_RREADY}),
        .s_axi_rresp(axi_dma_0_M_AXI_MM2S_RRESP),
        .s_axi_rvalid(axi_dma_0_M_AXI_MM2S_RVALID),
        .s_axi_wdata({axi_dma_0_M_AXI_S2MM_WDATA,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast({axi_dma_0_M_AXI_S2MM_WLAST,1'b1}),
        .s_axi_wready({axi_dma_0_M_AXI_S2MM_WREADY,NLW_axi_crossbar_0_s_axi_wready_UNCONNECTED[0]}),
        .s_axi_wstrb({axi_dma_0_M_AXI_S2MM_WSTRB,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .s_axi_wvalid({axi_dma_0_M_AXI_S2MM_WVALID,1'b0}));
  system_axi_dma_0_0 axi_dma_0
       (.axi_resetn(rst_processing_system7_0_100M_peripheral_aresetn),
        .m_axi_mm2s_aclk(processing_system7_0_FCLK_CLK0),
        .m_axi_mm2s_araddr(axi_dma_0_M_AXI_MM2S_ARADDR),
        .m_axi_mm2s_arburst(axi_dma_0_M_AXI_MM2S_ARBURST),
        .m_axi_mm2s_arcache(axi_dma_0_M_AXI_MM2S_ARCACHE),
        .m_axi_mm2s_arlen(axi_dma_0_M_AXI_MM2S_ARLEN),
        .m_axi_mm2s_arprot(axi_dma_0_M_AXI_MM2S_ARPROT),
        .m_axi_mm2s_arready(axi_dma_0_M_AXI_MM2S_ARREADY),
        .m_axi_mm2s_arsize(axi_dma_0_M_AXI_MM2S_ARSIZE),
        .m_axi_mm2s_arvalid(axi_dma_0_M_AXI_MM2S_ARVALID),
        .m_axi_mm2s_rdata(axi_dma_0_M_AXI_MM2S_RDATA),
        .m_axi_mm2s_rlast(axi_dma_0_M_AXI_MM2S_RLAST),
        .m_axi_mm2s_rready(axi_dma_0_M_AXI_MM2S_RREADY),
        .m_axi_mm2s_rresp(axi_dma_0_M_AXI_MM2S_RRESP),
        .m_axi_mm2s_rvalid(axi_dma_0_M_AXI_MM2S_RVALID),
        .m_axi_s2mm_aclk(processing_system7_0_FCLK_CLK0),
        .m_axi_s2mm_awaddr(axi_dma_0_M_AXI_S2MM_AWADDR),
        .m_axi_s2mm_awburst(axi_dma_0_M_AXI_S2MM_AWBURST),
        .m_axi_s2mm_awcache(axi_dma_0_M_AXI_S2MM_AWCACHE),
        .m_axi_s2mm_awlen(axi_dma_0_M_AXI_S2MM_AWLEN),
        .m_axi_s2mm_awprot(axi_dma_0_M_AXI_S2MM_AWPROT),
        .m_axi_s2mm_awready(axi_dma_0_M_AXI_S2MM_AWREADY),
        .m_axi_s2mm_awsize(axi_dma_0_M_AXI_S2MM_AWSIZE),
        .m_axi_s2mm_awvalid(axi_dma_0_M_AXI_S2MM_AWVALID),
        .m_axi_s2mm_bready(axi_dma_0_M_AXI_S2MM_BREADY),
        .m_axi_s2mm_bresp(axi_dma_0_M_AXI_S2MM_BRESP),
        .m_axi_s2mm_bvalid(axi_dma_0_M_AXI_S2MM_BVALID),
        .m_axi_s2mm_wdata(axi_dma_0_M_AXI_S2MM_WDATA),
        .m_axi_s2mm_wlast(axi_dma_0_M_AXI_S2MM_WLAST),
        .m_axi_s2mm_wready(axi_dma_0_M_AXI_S2MM_WREADY),
        .m_axi_s2mm_wstrb(axi_dma_0_M_AXI_S2MM_WSTRB),
        .m_axi_s2mm_wvalid(axi_dma_0_M_AXI_S2MM_WVALID),
        .m_axis_mm2s_tdata(Conn2_TDATA),
        .m_axis_mm2s_tlast(Conn2_TLAST),
        .m_axis_mm2s_tready(Conn2_TREADY),
        .m_axis_mm2s_tvalid(Conn2_TVALID),
        .mm2s_introut(axi_dma_0_mm2s_introut),
        .s2mm_introut(axi_dma_0_s2mm_introut),
        .s_axi_lite_aclk(processing_system7_0_FCLK_CLK0),
        .s_axi_lite_araddr(xbar_M01_AXI_ARADDR[41:32]),
        .s_axi_lite_arready(xbar_M01_AXI_ARREADY),
        .s_axi_lite_arvalid(xbar_M01_AXI_ARVALID),
        .s_axi_lite_awaddr(xbar_M01_AXI_AWADDR[41:32]),
        .s_axi_lite_awready(xbar_M01_AXI_AWREADY),
        .s_axi_lite_awvalid(xbar_M01_AXI_AWVALID),
        .s_axi_lite_bready(xbar_M01_AXI_BREADY),
        .s_axi_lite_bresp(xbar_M01_AXI_BRESP),
        .s_axi_lite_bvalid(xbar_M01_AXI_BVALID),
        .s_axi_lite_rdata(xbar_M01_AXI_RDATA),
        .s_axi_lite_rready(xbar_M01_AXI_RREADY),
        .s_axi_lite_rresp(xbar_M01_AXI_RRESP),
        .s_axi_lite_rvalid(xbar_M01_AXI_RVALID),
        .s_axi_lite_wdata(xbar_M01_AXI_WDATA),
        .s_axi_lite_wready(xbar_M01_AXI_WREADY),
        .s_axi_lite_wvalid(xbar_M01_AXI_WVALID),
        .s_axis_s2mm_tdata(Conn5_TDATA),
        .s_axis_s2mm_tkeep({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .s_axis_s2mm_tlast(Conn5_TLAST),
        .s_axis_s2mm_tready(Conn5_TREADY),
        .s_axis_s2mm_tvalid(Conn5_TVALID));
  system_axi_dma_0_1 axi_dma_1
       (.axi_resetn(rst_processing_system7_0_100M_peripheral_aresetn),
        .m_axi_mm2s_aclk(processing_system7_0_FCLK_CLK0),
        .m_axi_mm2s_araddr(axi_dma_1_M_AXI_MM2S_ARADDR),
        .m_axi_mm2s_arburst(axi_dma_1_M_AXI_MM2S_ARBURST),
        .m_axi_mm2s_arcache(axi_dma_1_M_AXI_MM2S_ARCACHE),
        .m_axi_mm2s_arlen(axi_dma_1_M_AXI_MM2S_ARLEN),
        .m_axi_mm2s_arprot(axi_dma_1_M_AXI_MM2S_ARPROT),
        .m_axi_mm2s_arready(axi_dma_1_M_AXI_MM2S_ARREADY),
        .m_axi_mm2s_arsize(axi_dma_1_M_AXI_MM2S_ARSIZE),
        .m_axi_mm2s_arvalid(axi_dma_1_M_AXI_MM2S_ARVALID),
        .m_axi_mm2s_rdata(axi_dma_1_M_AXI_MM2S_RDATA),
        .m_axi_mm2s_rlast(axi_dma_1_M_AXI_MM2S_RLAST),
        .m_axi_mm2s_rready(axi_dma_1_M_AXI_MM2S_RREADY),
        .m_axi_mm2s_rresp(axi_dma_1_M_AXI_MM2S_RRESP),
        .m_axi_mm2s_rvalid(axi_dma_1_M_AXI_MM2S_RVALID),
        .m_axis_mm2s_tdata(Conn3_TDATA),
        .m_axis_mm2s_tlast(Conn3_TLAST),
        .m_axis_mm2s_tready(Conn3_TREADY),
        .m_axis_mm2s_tvalid(Conn3_TVALID),
        .mm2s_introut(axi_dma_1_mm2s_introut),
        .s_axi_lite_aclk(processing_system7_0_FCLK_CLK0),
        .s_axi_lite_araddr(xbar_M02_AXI_ARADDR[73:64]),
        .s_axi_lite_arready(xbar_M02_AXI_ARREADY),
        .s_axi_lite_arvalid(xbar_M02_AXI_ARVALID),
        .s_axi_lite_awaddr(xbar_M02_AXI_AWADDR[73:64]),
        .s_axi_lite_awready(xbar_M02_AXI_AWREADY),
        .s_axi_lite_awvalid(xbar_M02_AXI_AWVALID),
        .s_axi_lite_bready(xbar_M02_AXI_BREADY),
        .s_axi_lite_bresp(xbar_M02_AXI_BRESP),
        .s_axi_lite_bvalid(xbar_M02_AXI_BVALID),
        .s_axi_lite_rdata(xbar_M02_AXI_RDATA),
        .s_axi_lite_rready(xbar_M02_AXI_RREADY),
        .s_axi_lite_rresp(xbar_M02_AXI_RRESP),
        .s_axi_lite_rvalid(xbar_M02_AXI_RVALID),
        .s_axi_lite_wdata(xbar_M02_AXI_WDATA),
        .s_axi_lite_wready(xbar_M02_AXI_WREADY),
        .s_axi_lite_wvalid(xbar_M02_AXI_WVALID));
  system_axi_dma_1_0 axi_dma_2
       (.axi_resetn(rst_processing_system7_0_100M_peripheral_aresetn),
        .m_axi_mm2s_aclk(processing_system7_0_FCLK_CLK0),
        .m_axi_mm2s_araddr(axi_dma_2_M_AXI_MM2S_ARADDR),
        .m_axi_mm2s_arburst(axi_dma_2_M_AXI_MM2S_ARBURST),
        .m_axi_mm2s_arcache(axi_dma_2_M_AXI_MM2S_ARCACHE),
        .m_axi_mm2s_arlen(axi_dma_2_M_AXI_MM2S_ARLEN),
        .m_axi_mm2s_arprot(axi_dma_2_M_AXI_MM2S_ARPROT),
        .m_axi_mm2s_arready(axi_dma_2_M_AXI_MM2S_ARREADY),
        .m_axi_mm2s_arsize(axi_dma_2_M_AXI_MM2S_ARSIZE),
        .m_axi_mm2s_arvalid(axi_dma_2_M_AXI_MM2S_ARVALID),
        .m_axi_mm2s_rdata(axi_dma_2_M_AXI_MM2S_RDATA),
        .m_axi_mm2s_rlast(axi_dma_2_M_AXI_MM2S_RLAST),
        .m_axi_mm2s_rready(axi_dma_2_M_AXI_MM2S_RREADY),
        .m_axi_mm2s_rresp(axi_dma_2_M_AXI_MM2S_RRESP),
        .m_axi_mm2s_rvalid(axi_dma_2_M_AXI_MM2S_RVALID),
        .m_axis_mm2s_tdata(Conn4_TDATA),
        .m_axis_mm2s_tlast(Conn4_TLAST),
        .m_axis_mm2s_tready(Conn4_TREADY),
        .m_axis_mm2s_tvalid(Conn4_TVALID),
        .mm2s_introut(axi_dma_2_mm2s_introut),
        .s_axi_lite_aclk(processing_system7_0_FCLK_CLK0),
        .s_axi_lite_araddr(xbar_M03_AXI_ARADDR[105:96]),
        .s_axi_lite_arready(xbar_M03_AXI_ARREADY),
        .s_axi_lite_arvalid(xbar_M03_AXI_ARVALID),
        .s_axi_lite_awaddr(xbar_M03_AXI_AWADDR[105:96]),
        .s_axi_lite_awready(xbar_M03_AXI_AWREADY),
        .s_axi_lite_awvalid(xbar_M03_AXI_AWVALID),
        .s_axi_lite_bready(xbar_M03_AXI_BREADY),
        .s_axi_lite_bresp(xbar_M03_AXI_BRESP),
        .s_axi_lite_bvalid(xbar_M03_AXI_BVALID),
        .s_axi_lite_rdata(xbar_M03_AXI_RDATA),
        .s_axi_lite_rready(xbar_M03_AXI_RREADY),
        .s_axi_lite_rresp(xbar_M03_AXI_RRESP),
        .s_axi_lite_rvalid(xbar_M03_AXI_RVALID),
        .s_axi_lite_wdata(xbar_M03_AXI_WDATA),
        .s_axi_lite_wready(xbar_M03_AXI_WREADY),
        .s_axi_lite_wvalid(xbar_M03_AXI_WVALID));
  system_axi_dma_1_1 axi_dma_3
       (.axi_resetn(rst_processing_system7_0_100M_peripheral_aresetn),
        .m_axi_mm2s_aclk(processing_system7_0_FCLK_CLK0),
        .m_axi_mm2s_araddr(axi_dma_3_M_AXI_MM2S_ARADDR),
        .m_axi_mm2s_arburst(axi_dma_3_M_AXI_MM2S_ARBURST),
        .m_axi_mm2s_arcache(axi_dma_3_M_AXI_MM2S_ARCACHE),
        .m_axi_mm2s_arlen(axi_dma_3_M_AXI_MM2S_ARLEN),
        .m_axi_mm2s_arprot(axi_dma_3_M_AXI_MM2S_ARPROT),
        .m_axi_mm2s_arready(axi_dma_3_M_AXI_MM2S_ARREADY),
        .m_axi_mm2s_arsize(axi_dma_3_M_AXI_MM2S_ARSIZE),
        .m_axi_mm2s_arvalid(axi_dma_3_M_AXI_MM2S_ARVALID),
        .m_axi_mm2s_rdata(axi_dma_3_M_AXI_MM2S_RDATA),
        .m_axi_mm2s_rlast(axi_dma_3_M_AXI_MM2S_RLAST),
        .m_axi_mm2s_rready(axi_dma_3_M_AXI_MM2S_RREADY),
        .m_axi_mm2s_rresp(axi_dma_3_M_AXI_MM2S_RRESP),
        .m_axi_mm2s_rvalid(axi_dma_3_M_AXI_MM2S_RVALID),
        .m_axis_mm2s_tdata(Conn6_TDATA),
        .m_axis_mm2s_tlast(Conn6_TLAST),
        .m_axis_mm2s_tready(Conn6_TREADY),
        .m_axis_mm2s_tvalid(Conn6_TVALID),
        .mm2s_introut(axi_dma_3_mm2s_introut),
        .s_axi_lite_aclk(processing_system7_0_FCLK_CLK0),
        .s_axi_lite_araddr(xbar_M04_AXI_ARADDR[137:128]),
        .s_axi_lite_arready(xbar_M04_AXI_ARREADY),
        .s_axi_lite_arvalid(xbar_M04_AXI_ARVALID),
        .s_axi_lite_awaddr(xbar_M04_AXI_AWADDR[137:128]),
        .s_axi_lite_awready(xbar_M04_AXI_AWREADY),
        .s_axi_lite_awvalid(xbar_M04_AXI_AWVALID),
        .s_axi_lite_bready(xbar_M04_AXI_BREADY),
        .s_axi_lite_bresp(xbar_M04_AXI_BRESP),
        .s_axi_lite_bvalid(xbar_M04_AXI_BVALID),
        .s_axi_lite_rdata(xbar_M04_AXI_RDATA),
        .s_axi_lite_rready(xbar_M04_AXI_RREADY),
        .s_axi_lite_rresp(xbar_M04_AXI_RRESP),
        .s_axi_lite_rvalid(xbar_M04_AXI_RVALID),
        .s_axi_lite_wdata(xbar_M04_AXI_WDATA),
        .s_axi_lite_wready(xbar_M04_AXI_WREADY),
        .s_axi_lite_wvalid(xbar_M04_AXI_WVALID));
  system_axi_protocol_converter_0_0 axi_protocol_converter_0
       (.aclk(processing_system7_0_FCLK_CLK0),
        .aresetn(rst_processing_system7_0_100M_interconnect_aresetn),
        .m_axi_araddr(Conn7_ARADDR),
        .m_axi_arburst(Conn7_ARBURST),
        .m_axi_arcache(Conn7_ARCACHE),
        .m_axi_arid(Conn7_ARID),
        .m_axi_arlen(Conn7_ARLEN),
        .m_axi_arlock(Conn7_ARLOCK),
        .m_axi_arprot(Conn7_ARPROT),
        .m_axi_arqos(Conn7_ARQOS),
        .m_axi_arready(Conn7_ARREADY),
        .m_axi_arsize(Conn7_ARSIZE),
        .m_axi_arvalid(Conn7_ARVALID),
        .m_axi_awaddr(Conn7_AWADDR),
        .m_axi_awburst(Conn7_AWBURST),
        .m_axi_awcache(Conn7_AWCACHE),
        .m_axi_awid(Conn7_AWID),
        .m_axi_awlen(Conn7_AWLEN),
        .m_axi_awlock(Conn7_AWLOCK),
        .m_axi_awprot(Conn7_AWPROT),
        .m_axi_awqos(Conn7_AWQOS),
        .m_axi_awready(Conn7_AWREADY),
        .m_axi_awsize(Conn7_AWSIZE),
        .m_axi_awvalid(Conn7_AWVALID),
        .m_axi_bid(Conn7_BID[0]),
        .m_axi_bready(Conn7_BREADY),
        .m_axi_bresp(Conn7_BRESP),
        .m_axi_bvalid(Conn7_BVALID),
        .m_axi_rdata(Conn7_RDATA),
        .m_axi_rid(Conn7_RID[0]),
        .m_axi_rlast(Conn7_RLAST),
        .m_axi_rready(Conn7_RREADY),
        .m_axi_rresp(Conn7_RRESP),
        .m_axi_rvalid(Conn7_RVALID),
        .m_axi_wdata(Conn7_WDATA),
        .m_axi_wid(Conn7_WID),
        .m_axi_wlast(Conn7_WLAST),
        .m_axi_wready(Conn7_WREADY),
        .m_axi_wstrb(Conn7_WSTRB),
        .m_axi_wvalid(Conn7_WVALID),
        .s_axi_araddr(axi_crossbar_0_M00_AXI_ARADDR),
        .s_axi_arburst(axi_crossbar_0_M00_AXI_ARBURST),
        .s_axi_arcache(axi_crossbar_0_M00_AXI_ARCACHE),
        .s_axi_arid(axi_crossbar_0_M00_AXI_ARID),
        .s_axi_arlen(axi_crossbar_0_M00_AXI_ARLEN),
        .s_axi_arlock(axi_crossbar_0_M00_AXI_ARLOCK),
        .s_axi_arprot(axi_crossbar_0_M00_AXI_ARPROT),
        .s_axi_arqos(axi_crossbar_0_M00_AXI_ARQOS),
        .s_axi_arready(axi_crossbar_0_M00_AXI_ARREADY),
        .s_axi_arregion(axi_crossbar_0_M00_AXI_ARREGION),
        .s_axi_arsize(axi_crossbar_0_M00_AXI_ARSIZE),
        .s_axi_arvalid(axi_crossbar_0_M00_AXI_ARVALID),
        .s_axi_awaddr(axi_crossbar_0_M00_AXI_AWADDR),
        .s_axi_awburst(axi_crossbar_0_M00_AXI_AWBURST),
        .s_axi_awcache(axi_crossbar_0_M00_AXI_AWCACHE),
        .s_axi_awid(axi_crossbar_0_M00_AXI_AWID),
        .s_axi_awlen(axi_crossbar_0_M00_AXI_AWLEN),
        .s_axi_awlock(axi_crossbar_0_M00_AXI_AWLOCK),
        .s_axi_awprot(axi_crossbar_0_M00_AXI_AWPROT),
        .s_axi_awqos(axi_crossbar_0_M00_AXI_AWQOS),
        .s_axi_awready(axi_crossbar_0_M00_AXI_AWREADY),
        .s_axi_awregion(axi_crossbar_0_M00_AXI_AWREGION),
        .s_axi_awsize(axi_crossbar_0_M00_AXI_AWSIZE),
        .s_axi_awvalid(axi_crossbar_0_M00_AXI_AWVALID),
        .s_axi_bid(axi_crossbar_0_M00_AXI_BID),
        .s_axi_bready(axi_crossbar_0_M00_AXI_BREADY),
        .s_axi_bresp(axi_crossbar_0_M00_AXI_BRESP),
        .s_axi_bvalid(axi_crossbar_0_M00_AXI_BVALID),
        .s_axi_rdata(axi_crossbar_0_M00_AXI_RDATA),
        .s_axi_rid(axi_crossbar_0_M00_AXI_RID),
        .s_axi_rlast(axi_crossbar_0_M00_AXI_RLAST),
        .s_axi_rready(axi_crossbar_0_M00_AXI_RREADY),
        .s_axi_rresp(axi_crossbar_0_M00_AXI_RRESP),
        .s_axi_rvalid(axi_crossbar_0_M00_AXI_RVALID),
        .s_axi_wdata(axi_crossbar_0_M00_AXI_WDATA),
        .s_axi_wlast(axi_crossbar_0_M00_AXI_WLAST),
        .s_axi_wready(axi_crossbar_0_M00_AXI_WREADY),
        .s_axi_wstrb(axi_crossbar_0_M00_AXI_WSTRB),
        .s_axi_wvalid(axi_crossbar_0_M00_AXI_WVALID));
  system_axi_protocol_converter_0_1 axi_protocol_converter_1
       (.aclk(processing_system7_0_FCLK_CLK0),
        .aresetn(rst_processing_system7_0_100M_interconnect_aresetn),
        .m_axi_araddr(Conn8_ARADDR),
        .m_axi_arburst(Conn8_ARBURST),
        .m_axi_arcache(Conn8_ARCACHE),
        .m_axi_arlen(Conn8_ARLEN),
        .m_axi_arlock(Conn8_ARLOCK),
        .m_axi_arprot(Conn8_ARPROT),
        .m_axi_arqos(Conn8_ARQOS),
        .m_axi_arready(Conn8_ARREADY),
        .m_axi_arsize(Conn8_ARSIZE),
        .m_axi_arvalid(Conn8_ARVALID),
        .m_axi_rdata(Conn8_RDATA),
        .m_axi_rlast(Conn8_RLAST),
        .m_axi_rready(Conn8_RREADY),
        .m_axi_rresp(Conn8_RRESP),
        .m_axi_rvalid(Conn8_RVALID),
        .s_axi_araddr(axi_dma_1_M_AXI_MM2S_ARADDR),
        .s_axi_arburst(axi_dma_1_M_AXI_MM2S_ARBURST),
        .s_axi_arcache(axi_dma_1_M_AXI_MM2S_ARCACHE),
        .s_axi_arlen(axi_dma_1_M_AXI_MM2S_ARLEN),
        .s_axi_arlock(1'b0),
        .s_axi_arprot(axi_dma_1_M_AXI_MM2S_ARPROT),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(axi_dma_1_M_AXI_MM2S_ARREADY),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize(axi_dma_1_M_AXI_MM2S_ARSIZE),
        .s_axi_arvalid(axi_dma_1_M_AXI_MM2S_ARVALID),
        .s_axi_rdata(axi_dma_1_M_AXI_MM2S_RDATA),
        .s_axi_rlast(axi_dma_1_M_AXI_MM2S_RLAST),
        .s_axi_rready(axi_dma_1_M_AXI_MM2S_RREADY),
        .s_axi_rresp(axi_dma_1_M_AXI_MM2S_RRESP),
        .s_axi_rvalid(axi_dma_1_M_AXI_MM2S_RVALID));
  system_axi_protocol_converter_0_2 axi_protocol_converter_2
       (.aclk(processing_system7_0_FCLK_CLK0),
        .aresetn(rst_processing_system7_0_100M_interconnect_aresetn),
        .m_axi_araddr(Conn9_ARADDR),
        .m_axi_arburst(Conn9_ARBURST),
        .m_axi_arcache(Conn9_ARCACHE),
        .m_axi_arlen(Conn9_ARLEN),
        .m_axi_arlock(Conn9_ARLOCK),
        .m_axi_arprot(Conn9_ARPROT),
        .m_axi_arqos(Conn9_ARQOS),
        .m_axi_arready(Conn9_ARREADY),
        .m_axi_arsize(Conn9_ARSIZE),
        .m_axi_arvalid(Conn9_ARVALID),
        .m_axi_rdata(Conn9_RDATA),
        .m_axi_rlast(Conn9_RLAST),
        .m_axi_rready(Conn9_RREADY),
        .m_axi_rresp(Conn9_RRESP),
        .m_axi_rvalid(Conn9_RVALID),
        .s_axi_araddr(axi_dma_2_M_AXI_MM2S_ARADDR),
        .s_axi_arburst(axi_dma_2_M_AXI_MM2S_ARBURST),
        .s_axi_arcache(axi_dma_2_M_AXI_MM2S_ARCACHE),
        .s_axi_arlen(axi_dma_2_M_AXI_MM2S_ARLEN),
        .s_axi_arlock(1'b0),
        .s_axi_arprot(axi_dma_2_M_AXI_MM2S_ARPROT),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(axi_dma_2_M_AXI_MM2S_ARREADY),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize(axi_dma_2_M_AXI_MM2S_ARSIZE),
        .s_axi_arvalid(axi_dma_2_M_AXI_MM2S_ARVALID),
        .s_axi_rdata(axi_dma_2_M_AXI_MM2S_RDATA),
        .s_axi_rlast(axi_dma_2_M_AXI_MM2S_RLAST),
        .s_axi_rready(axi_dma_2_M_AXI_MM2S_RREADY),
        .s_axi_rresp(axi_dma_2_M_AXI_MM2S_RRESP),
        .s_axi_rvalid(axi_dma_2_M_AXI_MM2S_RVALID));
  system_axi_protocol_converter_0_3 axi_protocol_converter_3
       (.aclk(processing_system7_0_FCLK_CLK0),
        .aresetn(rst_processing_system7_0_100M_interconnect_aresetn),
        .m_axi_araddr(Conn10_ARADDR),
        .m_axi_arburst(Conn10_ARBURST),
        .m_axi_arcache(Conn10_ARCACHE),
        .m_axi_arlen(Conn10_ARLEN),
        .m_axi_arlock(Conn10_ARLOCK),
        .m_axi_arprot(Conn10_ARPROT),
        .m_axi_arqos(Conn10_ARQOS),
        .m_axi_arready(Conn10_ARREADY),
        .m_axi_arsize(Conn10_ARSIZE),
        .m_axi_arvalid(Conn10_ARVALID),
        .m_axi_rdata(Conn10_RDATA),
        .m_axi_rlast(Conn10_RLAST),
        .m_axi_rready(Conn10_RREADY),
        .m_axi_rresp(Conn10_RRESP),
        .m_axi_rvalid(Conn10_RVALID),
        .s_axi_araddr(axi_dma_3_M_AXI_MM2S_ARADDR),
        .s_axi_arburst(axi_dma_3_M_AXI_MM2S_ARBURST),
        .s_axi_arcache(axi_dma_3_M_AXI_MM2S_ARCACHE),
        .s_axi_arlen(axi_dma_3_M_AXI_MM2S_ARLEN),
        .s_axi_arlock(1'b0),
        .s_axi_arprot(axi_dma_3_M_AXI_MM2S_ARPROT),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(axi_dma_3_M_AXI_MM2S_ARREADY),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize(axi_dma_3_M_AXI_MM2S_ARSIZE),
        .s_axi_arvalid(axi_dma_3_M_AXI_MM2S_ARVALID),
        .s_axi_rdata(axi_dma_3_M_AXI_MM2S_RDATA),
        .s_axi_rlast(axi_dma_3_M_AXI_MM2S_RLAST),
        .s_axi_rready(axi_dma_3_M_AXI_MM2S_RREADY),
        .s_axi_rresp(axi_dma_3_M_AXI_MM2S_RRESP),
        .s_axi_rvalid(axi_dma_3_M_AXI_MM2S_RVALID));
  system_xbar_0 xbar
       (.aclk(processing_system7_0_FCLK_CLK0),
        .aresetn(rst_processing_system7_0_100M_interconnect_aresetn),
        .m_axi_araddr({xbar_M04_AXI_ARADDR,xbar_M03_AXI_ARADDR,xbar_M02_AXI_ARADDR,xbar_M01_AXI_ARADDR,Conn1_ARADDR}),
        .m_axi_arready({xbar_M04_AXI_ARREADY,xbar_M03_AXI_ARREADY,xbar_M02_AXI_ARREADY,xbar_M01_AXI_ARREADY,Conn1_ARREADY}),
        .m_axi_arvalid({xbar_M04_AXI_ARVALID,xbar_M03_AXI_ARVALID,xbar_M02_AXI_ARVALID,xbar_M01_AXI_ARVALID,Conn1_ARVALID}),
        .m_axi_awaddr({xbar_M04_AXI_AWADDR,xbar_M03_AXI_AWADDR,xbar_M02_AXI_AWADDR,xbar_M01_AXI_AWADDR,Conn1_AWADDR}),
        .m_axi_awready({xbar_M04_AXI_AWREADY,xbar_M03_AXI_AWREADY,xbar_M02_AXI_AWREADY,xbar_M01_AXI_AWREADY,Conn1_AWREADY}),
        .m_axi_awvalid({xbar_M04_AXI_AWVALID,xbar_M03_AXI_AWVALID,xbar_M02_AXI_AWVALID,xbar_M01_AXI_AWVALID,Conn1_AWVALID}),
        .m_axi_bready({xbar_M04_AXI_BREADY,xbar_M03_AXI_BREADY,xbar_M02_AXI_BREADY,xbar_M01_AXI_BREADY,Conn1_BREADY}),
        .m_axi_bresp({xbar_M04_AXI_BRESP,xbar_M03_AXI_BRESP,xbar_M02_AXI_BRESP,xbar_M01_AXI_BRESP,Conn1_BRESP}),
        .m_axi_bvalid({xbar_M04_AXI_BVALID,xbar_M03_AXI_BVALID,xbar_M02_AXI_BVALID,xbar_M01_AXI_BVALID,Conn1_BVALID}),
        .m_axi_rdata({xbar_M04_AXI_RDATA,xbar_M03_AXI_RDATA,xbar_M02_AXI_RDATA,xbar_M01_AXI_RDATA,Conn1_RDATA}),
        .m_axi_rready({xbar_M04_AXI_RREADY,xbar_M03_AXI_RREADY,xbar_M02_AXI_RREADY,xbar_M01_AXI_RREADY,Conn1_RREADY}),
        .m_axi_rresp({xbar_M04_AXI_RRESP,xbar_M03_AXI_RRESP,xbar_M02_AXI_RRESP,xbar_M01_AXI_RRESP,Conn1_RRESP}),
        .m_axi_rvalid({xbar_M04_AXI_RVALID,xbar_M03_AXI_RVALID,xbar_M02_AXI_RVALID,xbar_M01_AXI_RVALID,Conn1_RVALID}),
        .m_axi_wdata({xbar_M04_AXI_WDATA,xbar_M03_AXI_WDATA,xbar_M02_AXI_WDATA,xbar_M01_AXI_WDATA,Conn1_WDATA}),
        .m_axi_wready({xbar_M04_AXI_WREADY,xbar_M03_AXI_WREADY,xbar_M02_AXI_WREADY,xbar_M01_AXI_WREADY,Conn1_WREADY}),
        .m_axi_wstrb(Conn1_WSTRB),
        .m_axi_wvalid({xbar_M04_AXI_WVALID,xbar_M03_AXI_WVALID,xbar_M02_AXI_WVALID,xbar_M01_AXI_WVALID,Conn1_WVALID}),
        .s_axi_araddr(auto_pc_M_AXI_ARADDR),
        .s_axi_arprot(auto_pc_M_AXI_ARPROT),
        .s_axi_arready(auto_pc_M_AXI_ARREADY),
        .s_axi_arvalid(auto_pc_M_AXI_ARVALID),
        .s_axi_awaddr(auto_pc_M_AXI_AWADDR),
        .s_axi_awprot(auto_pc_M_AXI_AWPROT),
        .s_axi_awready(auto_pc_M_AXI_AWREADY),
        .s_axi_awvalid(auto_pc_M_AXI_AWVALID),
        .s_axi_bready(auto_pc_M_AXI_BREADY),
        .s_axi_bresp(auto_pc_M_AXI_BRESP),
        .s_axi_bvalid(auto_pc_M_AXI_BVALID),
        .s_axi_rdata(auto_pc_M_AXI_RDATA),
        .s_axi_rready(auto_pc_M_AXI_RREADY),
        .s_axi_rresp(auto_pc_M_AXI_RRESP),
        .s_axi_rvalid(auto_pc_M_AXI_RVALID),
        .s_axi_wdata(auto_pc_M_AXI_WDATA),
        .s_axi_wready(auto_pc_M_AXI_WREADY),
        .s_axi_wstrb(auto_pc_M_AXI_WSTRB),
        .s_axi_wvalid(auto_pc_M_AXI_WVALID));
endmodule

(* CORE_GENERATION_INFO = "system,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=system,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=17,numReposBlks=15,numNonXlnxBlks=0,numHierBlks=2,maxHierDepth=1,da_axi4_cnt=7,da_axi4_s2mm_cnt=1,da_ps7_cnt=1,synth_mode=Global}" *) (* HW_HANDOFF = "system.hwdef" *) 
module system
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;

  wire [31:0]S_AXI_HP0_1_ARADDR;
  wire [1:0]S_AXI_HP0_1_ARBURST;
  wire [3:0]S_AXI_HP0_1_ARCACHE;
  wire [0:0]S_AXI_HP0_1_ARID;
  wire [3:0]S_AXI_HP0_1_ARLEN;
  wire [1:0]S_AXI_HP0_1_ARLOCK;
  wire [2:0]S_AXI_HP0_1_ARPROT;
  wire [3:0]S_AXI_HP0_1_ARQOS;
  wire S_AXI_HP0_1_ARREADY;
  wire [2:0]S_AXI_HP0_1_ARSIZE;
  wire S_AXI_HP0_1_ARVALID;
  wire [31:0]S_AXI_HP0_1_AWADDR;
  wire [1:0]S_AXI_HP0_1_AWBURST;
  wire [3:0]S_AXI_HP0_1_AWCACHE;
  wire [0:0]S_AXI_HP0_1_AWID;
  wire [3:0]S_AXI_HP0_1_AWLEN;
  wire [1:0]S_AXI_HP0_1_AWLOCK;
  wire [2:0]S_AXI_HP0_1_AWPROT;
  wire [3:0]S_AXI_HP0_1_AWQOS;
  wire S_AXI_HP0_1_AWREADY;
  wire [2:0]S_AXI_HP0_1_AWSIZE;
  wire S_AXI_HP0_1_AWVALID;
  wire [5:0]S_AXI_HP0_1_BID;
  wire S_AXI_HP0_1_BREADY;
  wire [1:0]S_AXI_HP0_1_BRESP;
  wire S_AXI_HP0_1_BVALID;
  wire [63:0]S_AXI_HP0_1_RDATA;
  wire [5:0]S_AXI_HP0_1_RID;
  wire S_AXI_HP0_1_RLAST;
  wire S_AXI_HP0_1_RREADY;
  wire [1:0]S_AXI_HP0_1_RRESP;
  wire S_AXI_HP0_1_RVALID;
  wire [63:0]S_AXI_HP0_1_WDATA;
  wire [0:0]S_AXI_HP0_1_WID;
  wire S_AXI_HP0_1_WLAST;
  wire S_AXI_HP0_1_WREADY;
  wire [7:0]S_AXI_HP0_1_WSTRB;
  wire S_AXI_HP0_1_WVALID;
  wire [31:0]S_AXI_HP1_1_ARADDR;
  wire [1:0]S_AXI_HP1_1_ARBURST;
  wire [3:0]S_AXI_HP1_1_ARCACHE;
  wire [3:0]S_AXI_HP1_1_ARLEN;
  wire [1:0]S_AXI_HP1_1_ARLOCK;
  wire [2:0]S_AXI_HP1_1_ARPROT;
  wire [3:0]S_AXI_HP1_1_ARQOS;
  wire S_AXI_HP1_1_ARREADY;
  wire [2:0]S_AXI_HP1_1_ARSIZE;
  wire S_AXI_HP1_1_ARVALID;
  wire [63:0]S_AXI_HP1_1_RDATA;
  wire S_AXI_HP1_1_RLAST;
  wire S_AXI_HP1_1_RREADY;
  wire [1:0]S_AXI_HP1_1_RRESP;
  wire S_AXI_HP1_1_RVALID;
  wire [31:0]S_AXI_HP2_1_ARADDR;
  wire [1:0]S_AXI_HP2_1_ARBURST;
  wire [3:0]S_AXI_HP2_1_ARCACHE;
  wire [3:0]S_AXI_HP2_1_ARLEN;
  wire [1:0]S_AXI_HP2_1_ARLOCK;
  wire [2:0]S_AXI_HP2_1_ARPROT;
  wire [3:0]S_AXI_HP2_1_ARQOS;
  wire S_AXI_HP2_1_ARREADY;
  wire [2:0]S_AXI_HP2_1_ARSIZE;
  wire S_AXI_HP2_1_ARVALID;
  wire [63:0]S_AXI_HP2_1_RDATA;
  wire S_AXI_HP2_1_RLAST;
  wire S_AXI_HP2_1_RREADY;
  wire [1:0]S_AXI_HP2_1_RRESP;
  wire S_AXI_HP2_1_RVALID;
  wire [31:0]S_AXI_HP3_1_ARADDR;
  wire [1:0]S_AXI_HP3_1_ARBURST;
  wire [3:0]S_AXI_HP3_1_ARCACHE;
  wire [3:0]S_AXI_HP3_1_ARLEN;
  wire [1:0]S_AXI_HP3_1_ARLOCK;
  wire [2:0]S_AXI_HP3_1_ARPROT;
  wire [3:0]S_AXI_HP3_1_ARQOS;
  wire S_AXI_HP3_1_ARREADY;
  wire [2:0]S_AXI_HP3_1_ARSIZE;
  wire S_AXI_HP3_1_ARVALID;
  wire [63:0]S_AXI_HP3_1_RDATA;
  wire S_AXI_HP3_1_RLAST;
  wire S_AXI_HP3_1_RREADY;
  wire [1:0]S_AXI_HP3_1_RRESP;
  wire S_AXI_HP3_1_RVALID;
  wire [31:0]axi_interconnect_M00_AXI_ARADDR;
  wire axi_interconnect_M00_AXI_ARREADY;
  wire [0:0]axi_interconnect_M00_AXI_ARVALID;
  wire [31:0]axi_interconnect_M00_AXI_AWADDR;
  wire axi_interconnect_M00_AXI_AWREADY;
  wire [0:0]axi_interconnect_M00_AXI_AWVALID;
  wire [0:0]axi_interconnect_M00_AXI_BREADY;
  wire [1:0]axi_interconnect_M00_AXI_BRESP;
  wire axi_interconnect_M00_AXI_BVALID;
  wire [31:0]axi_interconnect_M00_AXI_RDATA;
  wire [0:0]axi_interconnect_M00_AXI_RREADY;
  wire [1:0]axi_interconnect_M00_AXI_RRESP;
  wire axi_interconnect_M00_AXI_RVALID;
  wire [31:0]axi_interconnect_M00_AXI_WDATA;
  wire axi_interconnect_M00_AXI_WREADY;
  wire [3:0]axi_interconnect_M00_AXI_WSTRB;
  wire [0:0]axi_interconnect_M00_AXI_WVALID;
  wire [63:0]axi_interconnect_M_AXIS_MM2S1_TDATA;
  wire axi_interconnect_M_AXIS_MM2S1_TLAST;
  wire axi_interconnect_M_AXIS_MM2S1_TREADY;
  wire axi_interconnect_M_AXIS_MM2S1_TVALID;
  wire [63:0]axi_interconnect_M_AXIS_MM2S2_TDATA;
  wire axi_interconnect_M_AXIS_MM2S2_TLAST;
  wire axi_interconnect_M_AXIS_MM2S2_TREADY;
  wire axi_interconnect_M_AXIS_MM2S2_TVALID;
  wire [63:0]axi_interconnect_M_AXIS_MM2S3_TDATA;
  wire axi_interconnect_M_AXIS_MM2S3_TLAST;
  wire axi_interconnect_M_AXIS_MM2S3_TREADY;
  wire axi_interconnect_M_AXIS_MM2S3_TVALID;
  wire [63:0]axi_interconnect_M_AXIS_MM2S_TDATA;
  wire axi_interconnect_M_AXIS_MM2S_TLAST;
  wire axi_interconnect_M_AXIS_MM2S_TREADY;
  wire axi_interconnect_M_AXIS_MM2S_TVALID;
  wire axi_interconnect_mm2s_introut0;
  wire axi_interconnect_mm2s_introut1;
  wire axi_interconnect_mm2s_introut2;
  wire axi_interconnect_mm2s_introut3;
  wire hls_snn_izikevich_0_interrupt;
  wire [63:0]hls_snn_izikevich_0_output_stream_TDATA;
  wire [0:0]hls_snn_izikevich_0_output_stream_TLAST;
  wire hls_snn_izikevich_0_output_stream_TREADY;
  wire hls_snn_izikevich_0_output_stream_TVALID;
  wire int_dma_0_rx_1;
  wire [14:0]processing_system7_0_DDR_ADDR;
  wire [2:0]processing_system7_0_DDR_BA;
  wire processing_system7_0_DDR_CAS_N;
  wire processing_system7_0_DDR_CKE;
  wire processing_system7_0_DDR_CK_N;
  wire processing_system7_0_DDR_CK_P;
  wire processing_system7_0_DDR_CS_N;
  wire [3:0]processing_system7_0_DDR_DM;
  wire [31:0]processing_system7_0_DDR_DQ;
  wire [3:0]processing_system7_0_DDR_DQS_N;
  wire [3:0]processing_system7_0_DDR_DQS_P;
  wire processing_system7_0_DDR_ODT;
  wire processing_system7_0_DDR_RAS_N;
  wire processing_system7_0_DDR_RESET_N;
  wire processing_system7_0_DDR_WE_N;
  wire processing_system7_0_FCLK_CLK0;
  wire processing_system7_0_FIXED_IO_DDR_VRN;
  wire processing_system7_0_FIXED_IO_DDR_VRP;
  wire [53:0]processing_system7_0_FIXED_IO_MIO;
  wire processing_system7_0_FIXED_IO_PS_CLK;
  wire processing_system7_0_FIXED_IO_PS_PORB;
  wire processing_system7_0_FIXED_IO_PS_SRSTB;
  wire [31:0]processing_system7_0_M_AXI_GP0_ARADDR;
  wire [1:0]processing_system7_0_M_AXI_GP0_ARBURST;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARCACHE;
  wire [11:0]processing_system7_0_M_AXI_GP0_ARID;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARLEN;
  wire [1:0]processing_system7_0_M_AXI_GP0_ARLOCK;
  wire [2:0]processing_system7_0_M_AXI_GP0_ARPROT;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARQOS;
  wire processing_system7_0_M_AXI_GP0_ARREADY;
  wire [2:0]processing_system7_0_M_AXI_GP0_ARSIZE;
  wire processing_system7_0_M_AXI_GP0_ARVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_AWADDR;
  wire [1:0]processing_system7_0_M_AXI_GP0_AWBURST;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWCACHE;
  wire [11:0]processing_system7_0_M_AXI_GP0_AWID;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWLEN;
  wire [1:0]processing_system7_0_M_AXI_GP0_AWLOCK;
  wire [2:0]processing_system7_0_M_AXI_GP0_AWPROT;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWQOS;
  wire processing_system7_0_M_AXI_GP0_AWREADY;
  wire [2:0]processing_system7_0_M_AXI_GP0_AWSIZE;
  wire processing_system7_0_M_AXI_GP0_AWVALID;
  wire [11:0]processing_system7_0_M_AXI_GP0_BID;
  wire processing_system7_0_M_AXI_GP0_BREADY;
  wire [1:0]processing_system7_0_M_AXI_GP0_BRESP;
  wire processing_system7_0_M_AXI_GP0_BVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_RDATA;
  wire [11:0]processing_system7_0_M_AXI_GP0_RID;
  wire processing_system7_0_M_AXI_GP0_RLAST;
  wire processing_system7_0_M_AXI_GP0_RREADY;
  wire [1:0]processing_system7_0_M_AXI_GP0_RRESP;
  wire processing_system7_0_M_AXI_GP0_RVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_WDATA;
  wire [11:0]processing_system7_0_M_AXI_GP0_WID;
  wire processing_system7_0_M_AXI_GP0_WLAST;
  wire processing_system7_0_M_AXI_GP0_WREADY;
  wire [3:0]processing_system7_0_M_AXI_GP0_WSTRB;
  wire processing_system7_0_M_AXI_GP0_WVALID;
  wire [0:0]rst_processing_system7_0_100M_interconnect_aresetn;
  wire [0:0]rst_processing_system7_0_100M_peripheral_aresetn;

  axi_interconnect_imp_1IGFU7E axi_interconnect
       (.FCLK_CLK0(processing_system7_0_FCLK_CLK0),
        .INT_ARESETN(rst_processing_system7_0_100M_peripheral_aresetn),
        .M00_AXI_araddr(axi_interconnect_M00_AXI_ARADDR),
        .M00_AXI_arready(axi_interconnect_M00_AXI_ARREADY),
        .M00_AXI_arvalid(axi_interconnect_M00_AXI_ARVALID),
        .M00_AXI_awaddr(axi_interconnect_M00_AXI_AWADDR),
        .M00_AXI_awready(axi_interconnect_M00_AXI_AWREADY),
        .M00_AXI_awvalid(axi_interconnect_M00_AXI_AWVALID),
        .M00_AXI_bready(axi_interconnect_M00_AXI_BREADY),
        .M00_AXI_bresp(axi_interconnect_M00_AXI_BRESP),
        .M00_AXI_bvalid(axi_interconnect_M00_AXI_BVALID),
        .M00_AXI_rdata(axi_interconnect_M00_AXI_RDATA),
        .M00_AXI_rready(axi_interconnect_M00_AXI_RREADY),
        .M00_AXI_rresp(axi_interconnect_M00_AXI_RRESP),
        .M00_AXI_rvalid(axi_interconnect_M00_AXI_RVALID),
        .M00_AXI_wdata(axi_interconnect_M00_AXI_WDATA),
        .M00_AXI_wready(axi_interconnect_M00_AXI_WREADY),
        .M00_AXI_wstrb(axi_interconnect_M00_AXI_WSTRB),
        .M00_AXI_wvalid(axi_interconnect_M00_AXI_WVALID),
        .M_AXI1_araddr(S_AXI_HP1_1_ARADDR),
        .M_AXI1_arburst(S_AXI_HP1_1_ARBURST),
        .M_AXI1_arcache(S_AXI_HP1_1_ARCACHE),
        .M_AXI1_arlen(S_AXI_HP1_1_ARLEN),
        .M_AXI1_arlock(S_AXI_HP1_1_ARLOCK),
        .M_AXI1_arprot(S_AXI_HP1_1_ARPROT),
        .M_AXI1_arqos(S_AXI_HP1_1_ARQOS),
        .M_AXI1_arready(S_AXI_HP1_1_ARREADY),
        .M_AXI1_arsize(S_AXI_HP1_1_ARSIZE),
        .M_AXI1_arvalid(S_AXI_HP1_1_ARVALID),
        .M_AXI1_rdata(S_AXI_HP1_1_RDATA),
        .M_AXI1_rlast(S_AXI_HP1_1_RLAST),
        .M_AXI1_rready(S_AXI_HP1_1_RREADY),
        .M_AXI1_rresp(S_AXI_HP1_1_RRESP),
        .M_AXI1_rvalid(S_AXI_HP1_1_RVALID),
        .M_AXI2_araddr(S_AXI_HP2_1_ARADDR),
        .M_AXI2_arburst(S_AXI_HP2_1_ARBURST),
        .M_AXI2_arcache(S_AXI_HP2_1_ARCACHE),
        .M_AXI2_arlen(S_AXI_HP2_1_ARLEN),
        .M_AXI2_arlock(S_AXI_HP2_1_ARLOCK),
        .M_AXI2_arprot(S_AXI_HP2_1_ARPROT),
        .M_AXI2_arqos(S_AXI_HP2_1_ARQOS),
        .M_AXI2_arready(S_AXI_HP2_1_ARREADY),
        .M_AXI2_arsize(S_AXI_HP2_1_ARSIZE),
        .M_AXI2_arvalid(S_AXI_HP2_1_ARVALID),
        .M_AXI2_rdata(S_AXI_HP2_1_RDATA),
        .M_AXI2_rlast(S_AXI_HP2_1_RLAST),
        .M_AXI2_rready(S_AXI_HP2_1_RREADY),
        .M_AXI2_rresp(S_AXI_HP2_1_RRESP),
        .M_AXI2_rvalid(S_AXI_HP2_1_RVALID),
        .M_AXI3_araddr(S_AXI_HP3_1_ARADDR),
        .M_AXI3_arburst(S_AXI_HP3_1_ARBURST),
        .M_AXI3_arcache(S_AXI_HP3_1_ARCACHE),
        .M_AXI3_arlen(S_AXI_HP3_1_ARLEN),
        .M_AXI3_arlock(S_AXI_HP3_1_ARLOCK),
        .M_AXI3_arprot(S_AXI_HP3_1_ARPROT),
        .M_AXI3_arqos(S_AXI_HP3_1_ARQOS),
        .M_AXI3_arready(S_AXI_HP3_1_ARREADY),
        .M_AXI3_arsize(S_AXI_HP3_1_ARSIZE),
        .M_AXI3_arvalid(S_AXI_HP3_1_ARVALID),
        .M_AXI3_rdata(S_AXI_HP3_1_RDATA),
        .M_AXI3_rlast(S_AXI_HP3_1_RLAST),
        .M_AXI3_rready(S_AXI_HP3_1_RREADY),
        .M_AXI3_rresp(S_AXI_HP3_1_RRESP),
        .M_AXI3_rvalid(S_AXI_HP3_1_RVALID),
        .M_AXIS_MM2S1_tdata(axi_interconnect_M_AXIS_MM2S1_TDATA),
        .M_AXIS_MM2S1_tlast(axi_interconnect_M_AXIS_MM2S1_TLAST),
        .M_AXIS_MM2S1_tready(axi_interconnect_M_AXIS_MM2S1_TREADY),
        .M_AXIS_MM2S1_tvalid(axi_interconnect_M_AXIS_MM2S1_TVALID),
        .M_AXIS_MM2S2_tdata(axi_interconnect_M_AXIS_MM2S2_TDATA),
        .M_AXIS_MM2S2_tlast(axi_interconnect_M_AXIS_MM2S2_TLAST),
        .M_AXIS_MM2S2_tready(axi_interconnect_M_AXIS_MM2S2_TREADY),
        .M_AXIS_MM2S2_tvalid(axi_interconnect_M_AXIS_MM2S2_TVALID),
        .M_AXIS_MM2S3_tdata(axi_interconnect_M_AXIS_MM2S3_TDATA),
        .M_AXIS_MM2S3_tlast(axi_interconnect_M_AXIS_MM2S3_TLAST),
        .M_AXIS_MM2S3_tready(axi_interconnect_M_AXIS_MM2S3_TREADY),
        .M_AXIS_MM2S3_tvalid(axi_interconnect_M_AXIS_MM2S3_TVALID),
        .M_AXIS_MM2S_tdata(axi_interconnect_M_AXIS_MM2S_TDATA),
        .M_AXIS_MM2S_tlast(axi_interconnect_M_AXIS_MM2S_TLAST),
        .M_AXIS_MM2S_tready(axi_interconnect_M_AXIS_MM2S_TREADY),
        .M_AXIS_MM2S_tvalid(axi_interconnect_M_AXIS_MM2S_TVALID),
        .M_AXI_araddr(S_AXI_HP0_1_ARADDR),
        .M_AXI_arburst(S_AXI_HP0_1_ARBURST),
        .M_AXI_arcache(S_AXI_HP0_1_ARCACHE),
        .M_AXI_arid(S_AXI_HP0_1_ARID),
        .M_AXI_arlen(S_AXI_HP0_1_ARLEN),
        .M_AXI_arlock(S_AXI_HP0_1_ARLOCK),
        .M_AXI_arprot(S_AXI_HP0_1_ARPROT),
        .M_AXI_arqos(S_AXI_HP0_1_ARQOS),
        .M_AXI_arready(S_AXI_HP0_1_ARREADY),
        .M_AXI_arsize(S_AXI_HP0_1_ARSIZE),
        .M_AXI_arvalid(S_AXI_HP0_1_ARVALID),
        .M_AXI_awaddr(S_AXI_HP0_1_AWADDR),
        .M_AXI_awburst(S_AXI_HP0_1_AWBURST),
        .M_AXI_awcache(S_AXI_HP0_1_AWCACHE),
        .M_AXI_awid(S_AXI_HP0_1_AWID),
        .M_AXI_awlen(S_AXI_HP0_1_AWLEN),
        .M_AXI_awlock(S_AXI_HP0_1_AWLOCK),
        .M_AXI_awprot(S_AXI_HP0_1_AWPROT),
        .M_AXI_awqos(S_AXI_HP0_1_AWQOS),
        .M_AXI_awready(S_AXI_HP0_1_AWREADY),
        .M_AXI_awsize(S_AXI_HP0_1_AWSIZE),
        .M_AXI_awvalid(S_AXI_HP0_1_AWVALID),
        .M_AXI_bid(S_AXI_HP0_1_BID),
        .M_AXI_bready(S_AXI_HP0_1_BREADY),
        .M_AXI_bresp(S_AXI_HP0_1_BRESP),
        .M_AXI_bvalid(S_AXI_HP0_1_BVALID),
        .M_AXI_rdata(S_AXI_HP0_1_RDATA),
        .M_AXI_rid(S_AXI_HP0_1_RID),
        .M_AXI_rlast(S_AXI_HP0_1_RLAST),
        .M_AXI_rready(S_AXI_HP0_1_RREADY),
        .M_AXI_rresp(S_AXI_HP0_1_RRESP),
        .M_AXI_rvalid(S_AXI_HP0_1_RVALID),
        .M_AXI_wdata(S_AXI_HP0_1_WDATA),
        .M_AXI_wid(S_AXI_HP0_1_WID),
        .M_AXI_wlast(S_AXI_HP0_1_WLAST),
        .M_AXI_wready(S_AXI_HP0_1_WREADY),
        .M_AXI_wstrb(S_AXI_HP0_1_WSTRB),
        .M_AXI_wvalid(S_AXI_HP0_1_WVALID),
        .PER_ARESETN(rst_processing_system7_0_100M_interconnect_aresetn),
        .S00_AXI_araddr(processing_system7_0_M_AXI_GP0_ARADDR),
        .S00_AXI_arburst(processing_system7_0_M_AXI_GP0_ARBURST),
        .S00_AXI_arcache(processing_system7_0_M_AXI_GP0_ARCACHE),
        .S00_AXI_arid(processing_system7_0_M_AXI_GP0_ARID),
        .S00_AXI_arlen(processing_system7_0_M_AXI_GP0_ARLEN),
        .S00_AXI_arlock(processing_system7_0_M_AXI_GP0_ARLOCK),
        .S00_AXI_arprot(processing_system7_0_M_AXI_GP0_ARPROT),
        .S00_AXI_arqos(processing_system7_0_M_AXI_GP0_ARQOS),
        .S00_AXI_arready(processing_system7_0_M_AXI_GP0_ARREADY),
        .S00_AXI_arsize(processing_system7_0_M_AXI_GP0_ARSIZE),
        .S00_AXI_arvalid(processing_system7_0_M_AXI_GP0_ARVALID),
        .S00_AXI_awaddr(processing_system7_0_M_AXI_GP0_AWADDR),
        .S00_AXI_awburst(processing_system7_0_M_AXI_GP0_AWBURST),
        .S00_AXI_awcache(processing_system7_0_M_AXI_GP0_AWCACHE),
        .S00_AXI_awid(processing_system7_0_M_AXI_GP0_AWID),
        .S00_AXI_awlen(processing_system7_0_M_AXI_GP0_AWLEN),
        .S00_AXI_awlock(processing_system7_0_M_AXI_GP0_AWLOCK),
        .S00_AXI_awprot(processing_system7_0_M_AXI_GP0_AWPROT),
        .S00_AXI_awqos(processing_system7_0_M_AXI_GP0_AWQOS),
        .S00_AXI_awready(processing_system7_0_M_AXI_GP0_AWREADY),
        .S00_AXI_awsize(processing_system7_0_M_AXI_GP0_AWSIZE),
        .S00_AXI_awvalid(processing_system7_0_M_AXI_GP0_AWVALID),
        .S00_AXI_bid(processing_system7_0_M_AXI_GP0_BID),
        .S00_AXI_bready(processing_system7_0_M_AXI_GP0_BREADY),
        .S00_AXI_bresp(processing_system7_0_M_AXI_GP0_BRESP),
        .S00_AXI_bvalid(processing_system7_0_M_AXI_GP0_BVALID),
        .S00_AXI_rdata(processing_system7_0_M_AXI_GP0_RDATA),
        .S00_AXI_rid(processing_system7_0_M_AXI_GP0_RID),
        .S00_AXI_rlast(processing_system7_0_M_AXI_GP0_RLAST),
        .S00_AXI_rready(processing_system7_0_M_AXI_GP0_RREADY),
        .S00_AXI_rresp(processing_system7_0_M_AXI_GP0_RRESP),
        .S00_AXI_rvalid(processing_system7_0_M_AXI_GP0_RVALID),
        .S00_AXI_wdata(processing_system7_0_M_AXI_GP0_WDATA),
        .S00_AXI_wid(processing_system7_0_M_AXI_GP0_WID),
        .S00_AXI_wlast(processing_system7_0_M_AXI_GP0_WLAST),
        .S00_AXI_wready(processing_system7_0_M_AXI_GP0_WREADY),
        .S00_AXI_wstrb(processing_system7_0_M_AXI_GP0_WSTRB),
        .S00_AXI_wvalid(processing_system7_0_M_AXI_GP0_WVALID),
        .S_AXIS_S2MM_tdata(hls_snn_izikevich_0_output_stream_TDATA),
        .S_AXIS_S2MM_tlast(hls_snn_izikevich_0_output_stream_TLAST),
        .S_AXIS_S2MM_tready(hls_snn_izikevich_0_output_stream_TREADY),
        .S_AXIS_S2MM_tvalid(hls_snn_izikevich_0_output_stream_TVALID),
        .mm2s_introut0(axi_interconnect_mm2s_introut0),
        .mm2s_introut1(axi_interconnect_mm2s_introut1),
        .mm2s_introut2(axi_interconnect_mm2s_introut2),
        .mm2s_introut3(axi_interconnect_mm2s_introut3),
        .s2mm_introut0(int_dma_0_rx_1));
  system_hls_snn_izikevich_0_0 hls_snn_izikevich_0
       (.ap_clk(processing_system7_0_FCLK_CLK0),
        .ap_rst_n(rst_processing_system7_0_100M_peripheral_aresetn),
        .input_stream0_TDATA(axi_interconnect_M_AXIS_MM2S_TDATA),
        .input_stream0_TLAST(axi_interconnect_M_AXIS_MM2S_TLAST),
        .input_stream0_TREADY(axi_interconnect_M_AXIS_MM2S_TREADY),
        .input_stream0_TVALID(axi_interconnect_M_AXIS_MM2S_TVALID),
        .input_stream1_TDATA(axi_interconnect_M_AXIS_MM2S1_TDATA),
        .input_stream1_TLAST(axi_interconnect_M_AXIS_MM2S1_TLAST),
        .input_stream1_TREADY(axi_interconnect_M_AXIS_MM2S1_TREADY),
        .input_stream1_TVALID(axi_interconnect_M_AXIS_MM2S1_TVALID),
        .input_stream2_TDATA(axi_interconnect_M_AXIS_MM2S2_TDATA),
        .input_stream2_TLAST(axi_interconnect_M_AXIS_MM2S2_TLAST),
        .input_stream2_TREADY(axi_interconnect_M_AXIS_MM2S2_TREADY),
        .input_stream2_TVALID(axi_interconnect_M_AXIS_MM2S2_TVALID),
        .input_stream3_TDATA(axi_interconnect_M_AXIS_MM2S3_TDATA),
        .input_stream3_TLAST(axi_interconnect_M_AXIS_MM2S3_TLAST),
        .input_stream3_TREADY(axi_interconnect_M_AXIS_MM2S3_TREADY),
        .input_stream3_TVALID(axi_interconnect_M_AXIS_MM2S3_TVALID),
        .interrupt(hls_snn_izikevich_0_interrupt),
        .output_stream_TDATA(hls_snn_izikevich_0_output_stream_TDATA),
        .output_stream_TLAST(hls_snn_izikevich_0_output_stream_TLAST),
        .output_stream_TREADY(hls_snn_izikevich_0_output_stream_TREADY),
        .output_stream_TVALID(hls_snn_izikevich_0_output_stream_TVALID),
        .s_axi_control_ARADDR(axi_interconnect_M00_AXI_ARADDR[11:0]),
        .s_axi_control_ARREADY(axi_interconnect_M00_AXI_ARREADY),
        .s_axi_control_ARVALID(axi_interconnect_M00_AXI_ARVALID),
        .s_axi_control_AWADDR(axi_interconnect_M00_AXI_AWADDR[11:0]),
        .s_axi_control_AWREADY(axi_interconnect_M00_AXI_AWREADY),
        .s_axi_control_AWVALID(axi_interconnect_M00_AXI_AWVALID),
        .s_axi_control_BREADY(axi_interconnect_M00_AXI_BREADY),
        .s_axi_control_BRESP(axi_interconnect_M00_AXI_BRESP),
        .s_axi_control_BVALID(axi_interconnect_M00_AXI_BVALID),
        .s_axi_control_RDATA(axi_interconnect_M00_AXI_RDATA),
        .s_axi_control_RREADY(axi_interconnect_M00_AXI_RREADY),
        .s_axi_control_RRESP(axi_interconnect_M00_AXI_RRESP),
        .s_axi_control_RVALID(axi_interconnect_M00_AXI_RVALID),
        .s_axi_control_WDATA(axi_interconnect_M00_AXI_WDATA),
        .s_axi_control_WREADY(axi_interconnect_M00_AXI_WREADY),
        .s_axi_control_WSTRB(axi_interconnect_M00_AXI_WSTRB),
        .s_axi_control_WVALID(axi_interconnect_M00_AXI_WVALID));
  zynq_imp_EK5HCS zynq
       (.DDR_addr(DDR_addr[14:0]),
        .DDR_ba(DDR_ba[2:0]),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm[3:0]),
        .DDR_dq(DDR_dq[31:0]),
        .DDR_dqs_n(DDR_dqs_n[3:0]),
        .DDR_dqs_p(DDR_dqs_p[3:0]),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FCLK_CLK0(processing_system7_0_FCLK_CLK0),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio[53:0]),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .M_AXI_GP0_araddr(processing_system7_0_M_AXI_GP0_ARADDR),
        .M_AXI_GP0_arburst(processing_system7_0_M_AXI_GP0_ARBURST),
        .M_AXI_GP0_arcache(processing_system7_0_M_AXI_GP0_ARCACHE),
        .M_AXI_GP0_arid(processing_system7_0_M_AXI_GP0_ARID),
        .M_AXI_GP0_arlen(processing_system7_0_M_AXI_GP0_ARLEN),
        .M_AXI_GP0_arlock(processing_system7_0_M_AXI_GP0_ARLOCK),
        .M_AXI_GP0_arprot(processing_system7_0_M_AXI_GP0_ARPROT),
        .M_AXI_GP0_arqos(processing_system7_0_M_AXI_GP0_ARQOS),
        .M_AXI_GP0_arready(processing_system7_0_M_AXI_GP0_ARREADY),
        .M_AXI_GP0_arsize(processing_system7_0_M_AXI_GP0_ARSIZE),
        .M_AXI_GP0_arvalid(processing_system7_0_M_AXI_GP0_ARVALID),
        .M_AXI_GP0_awaddr(processing_system7_0_M_AXI_GP0_AWADDR),
        .M_AXI_GP0_awburst(processing_system7_0_M_AXI_GP0_AWBURST),
        .M_AXI_GP0_awcache(processing_system7_0_M_AXI_GP0_AWCACHE),
        .M_AXI_GP0_awid(processing_system7_0_M_AXI_GP0_AWID),
        .M_AXI_GP0_awlen(processing_system7_0_M_AXI_GP0_AWLEN),
        .M_AXI_GP0_awlock(processing_system7_0_M_AXI_GP0_AWLOCK),
        .M_AXI_GP0_awprot(processing_system7_0_M_AXI_GP0_AWPROT),
        .M_AXI_GP0_awqos(processing_system7_0_M_AXI_GP0_AWQOS),
        .M_AXI_GP0_awready(processing_system7_0_M_AXI_GP0_AWREADY),
        .M_AXI_GP0_awsize(processing_system7_0_M_AXI_GP0_AWSIZE),
        .M_AXI_GP0_awvalid(processing_system7_0_M_AXI_GP0_AWVALID),
        .M_AXI_GP0_bid(processing_system7_0_M_AXI_GP0_BID),
        .M_AXI_GP0_bready(processing_system7_0_M_AXI_GP0_BREADY),
        .M_AXI_GP0_bresp(processing_system7_0_M_AXI_GP0_BRESP),
        .M_AXI_GP0_bvalid(processing_system7_0_M_AXI_GP0_BVALID),
        .M_AXI_GP0_rdata(processing_system7_0_M_AXI_GP0_RDATA),
        .M_AXI_GP0_rid(processing_system7_0_M_AXI_GP0_RID),
        .M_AXI_GP0_rlast(processing_system7_0_M_AXI_GP0_RLAST),
        .M_AXI_GP0_rready(processing_system7_0_M_AXI_GP0_RREADY),
        .M_AXI_GP0_rresp(processing_system7_0_M_AXI_GP0_RRESP),
        .M_AXI_GP0_rvalid(processing_system7_0_M_AXI_GP0_RVALID),
        .M_AXI_GP0_wdata(processing_system7_0_M_AXI_GP0_WDATA),
        .M_AXI_GP0_wid(processing_system7_0_M_AXI_GP0_WID),
        .M_AXI_GP0_wlast(processing_system7_0_M_AXI_GP0_WLAST),
        .M_AXI_GP0_wready(processing_system7_0_M_AXI_GP0_WREADY),
        .M_AXI_GP0_wstrb(processing_system7_0_M_AXI_GP0_WSTRB),
        .M_AXI_GP0_wvalid(processing_system7_0_M_AXI_GP0_WVALID),
        .S_AXI_HP0_araddr(S_AXI_HP0_1_ARADDR),
        .S_AXI_HP0_arburst(S_AXI_HP0_1_ARBURST),
        .S_AXI_HP0_arcache(S_AXI_HP0_1_ARCACHE),
        .S_AXI_HP0_arid(S_AXI_HP0_1_ARID),
        .S_AXI_HP0_arlen(S_AXI_HP0_1_ARLEN),
        .S_AXI_HP0_arlock(S_AXI_HP0_1_ARLOCK),
        .S_AXI_HP0_arprot(S_AXI_HP0_1_ARPROT),
        .S_AXI_HP0_arqos(S_AXI_HP0_1_ARQOS),
        .S_AXI_HP0_arready(S_AXI_HP0_1_ARREADY),
        .S_AXI_HP0_arsize(S_AXI_HP0_1_ARSIZE),
        .S_AXI_HP0_arvalid(S_AXI_HP0_1_ARVALID),
        .S_AXI_HP0_awaddr(S_AXI_HP0_1_AWADDR),
        .S_AXI_HP0_awburst(S_AXI_HP0_1_AWBURST),
        .S_AXI_HP0_awcache(S_AXI_HP0_1_AWCACHE),
        .S_AXI_HP0_awid(S_AXI_HP0_1_AWID),
        .S_AXI_HP0_awlen(S_AXI_HP0_1_AWLEN),
        .S_AXI_HP0_awlock(S_AXI_HP0_1_AWLOCK),
        .S_AXI_HP0_awprot(S_AXI_HP0_1_AWPROT),
        .S_AXI_HP0_awqos(S_AXI_HP0_1_AWQOS),
        .S_AXI_HP0_awready(S_AXI_HP0_1_AWREADY),
        .S_AXI_HP0_awsize(S_AXI_HP0_1_AWSIZE),
        .S_AXI_HP0_awvalid(S_AXI_HP0_1_AWVALID),
        .S_AXI_HP0_bid(S_AXI_HP0_1_BID),
        .S_AXI_HP0_bready(S_AXI_HP0_1_BREADY),
        .S_AXI_HP0_bresp(S_AXI_HP0_1_BRESP),
        .S_AXI_HP0_bvalid(S_AXI_HP0_1_BVALID),
        .S_AXI_HP0_rdata(S_AXI_HP0_1_RDATA),
        .S_AXI_HP0_rid(S_AXI_HP0_1_RID),
        .S_AXI_HP0_rlast(S_AXI_HP0_1_RLAST),
        .S_AXI_HP0_rready(S_AXI_HP0_1_RREADY),
        .S_AXI_HP0_rresp(S_AXI_HP0_1_RRESP),
        .S_AXI_HP0_rvalid(S_AXI_HP0_1_RVALID),
        .S_AXI_HP0_wdata(S_AXI_HP0_1_WDATA),
        .S_AXI_HP0_wid(S_AXI_HP0_1_WID),
        .S_AXI_HP0_wlast(S_AXI_HP0_1_WLAST),
        .S_AXI_HP0_wready(S_AXI_HP0_1_WREADY),
        .S_AXI_HP0_wstrb(S_AXI_HP0_1_WSTRB),
        .S_AXI_HP0_wvalid(S_AXI_HP0_1_WVALID),
        .S_AXI_HP1_araddr(S_AXI_HP1_1_ARADDR),
        .S_AXI_HP1_arburst(S_AXI_HP1_1_ARBURST),
        .S_AXI_HP1_arcache(S_AXI_HP1_1_ARCACHE),
        .S_AXI_HP1_arlen(S_AXI_HP1_1_ARLEN),
        .S_AXI_HP1_arlock(S_AXI_HP1_1_ARLOCK),
        .S_AXI_HP1_arprot(S_AXI_HP1_1_ARPROT),
        .S_AXI_HP1_arqos(S_AXI_HP1_1_ARQOS),
        .S_AXI_HP1_arready(S_AXI_HP1_1_ARREADY),
        .S_AXI_HP1_arsize(S_AXI_HP1_1_ARSIZE),
        .S_AXI_HP1_arvalid(S_AXI_HP1_1_ARVALID),
        .S_AXI_HP1_rdata(S_AXI_HP1_1_RDATA),
        .S_AXI_HP1_rlast(S_AXI_HP1_1_RLAST),
        .S_AXI_HP1_rready(S_AXI_HP1_1_RREADY),
        .S_AXI_HP1_rresp(S_AXI_HP1_1_RRESP),
        .S_AXI_HP1_rvalid(S_AXI_HP1_1_RVALID),
        .S_AXI_HP2_araddr(S_AXI_HP2_1_ARADDR),
        .S_AXI_HP2_arburst(S_AXI_HP2_1_ARBURST),
        .S_AXI_HP2_arcache(S_AXI_HP2_1_ARCACHE),
        .S_AXI_HP2_arlen(S_AXI_HP2_1_ARLEN),
        .S_AXI_HP2_arlock(S_AXI_HP2_1_ARLOCK),
        .S_AXI_HP2_arprot(S_AXI_HP2_1_ARPROT),
        .S_AXI_HP2_arqos(S_AXI_HP2_1_ARQOS),
        .S_AXI_HP2_arready(S_AXI_HP2_1_ARREADY),
        .S_AXI_HP2_arsize(S_AXI_HP2_1_ARSIZE),
        .S_AXI_HP2_arvalid(S_AXI_HP2_1_ARVALID),
        .S_AXI_HP2_rdata(S_AXI_HP2_1_RDATA),
        .S_AXI_HP2_rlast(S_AXI_HP2_1_RLAST),
        .S_AXI_HP2_rready(S_AXI_HP2_1_RREADY),
        .S_AXI_HP2_rresp(S_AXI_HP2_1_RRESP),
        .S_AXI_HP2_rvalid(S_AXI_HP2_1_RVALID),
        .S_AXI_HP3_araddr(S_AXI_HP3_1_ARADDR),
        .S_AXI_HP3_arburst(S_AXI_HP3_1_ARBURST),
        .S_AXI_HP3_arcache(S_AXI_HP3_1_ARCACHE),
        .S_AXI_HP3_arlen(S_AXI_HP3_1_ARLEN),
        .S_AXI_HP3_arlock(S_AXI_HP3_1_ARLOCK),
        .S_AXI_HP3_arprot(S_AXI_HP3_1_ARPROT),
        .S_AXI_HP3_arqos(S_AXI_HP3_1_ARQOS),
        .S_AXI_HP3_arready(S_AXI_HP3_1_ARREADY),
        .S_AXI_HP3_arsize(S_AXI_HP3_1_ARSIZE),
        .S_AXI_HP3_arvalid(S_AXI_HP3_1_ARVALID),
        .S_AXI_HP3_rdata(S_AXI_HP3_1_RDATA),
        .S_AXI_HP3_rlast(S_AXI_HP3_1_RLAST),
        .S_AXI_HP3_rready(S_AXI_HP3_1_RREADY),
        .S_AXI_HP3_rresp(S_AXI_HP3_1_RRESP),
        .S_AXI_HP3_rvalid(S_AXI_HP3_1_RVALID),
        .int_dma_0_rx(int_dma_0_rx_1),
        .int_dma_0_tx(axi_interconnect_mm2s_introut0),
        .int_dma_1_tx(axi_interconnect_mm2s_introut1),
        .int_dma_2_tx(axi_interconnect_mm2s_introut2),
        .int_dma_3_tx(axi_interconnect_mm2s_introut3),
        .int_hls_block(hls_snn_izikevich_0_interrupt),
        .interconnect_aresetna(rst_processing_system7_0_100M_interconnect_aresetn),
        .peripheral_aresetns(rst_processing_system7_0_100M_peripheral_aresetn));
endmodule

module zynq_imp_EK5HCS
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FCLK_CLK0,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    M_AXI_GP0_araddr,
    M_AXI_GP0_arburst,
    M_AXI_GP0_arcache,
    M_AXI_GP0_arid,
    M_AXI_GP0_arlen,
    M_AXI_GP0_arlock,
    M_AXI_GP0_arprot,
    M_AXI_GP0_arqos,
    M_AXI_GP0_arready,
    M_AXI_GP0_arsize,
    M_AXI_GP0_arvalid,
    M_AXI_GP0_awaddr,
    M_AXI_GP0_awburst,
    M_AXI_GP0_awcache,
    M_AXI_GP0_awid,
    M_AXI_GP0_awlen,
    M_AXI_GP0_awlock,
    M_AXI_GP0_awprot,
    M_AXI_GP0_awqos,
    M_AXI_GP0_awready,
    M_AXI_GP0_awsize,
    M_AXI_GP0_awvalid,
    M_AXI_GP0_bid,
    M_AXI_GP0_bready,
    M_AXI_GP0_bresp,
    M_AXI_GP0_bvalid,
    M_AXI_GP0_rdata,
    M_AXI_GP0_rid,
    M_AXI_GP0_rlast,
    M_AXI_GP0_rready,
    M_AXI_GP0_rresp,
    M_AXI_GP0_rvalid,
    M_AXI_GP0_wdata,
    M_AXI_GP0_wid,
    M_AXI_GP0_wlast,
    M_AXI_GP0_wready,
    M_AXI_GP0_wstrb,
    M_AXI_GP0_wvalid,
    S_AXI_HP0_araddr,
    S_AXI_HP0_arburst,
    S_AXI_HP0_arcache,
    S_AXI_HP0_arid,
    S_AXI_HP0_arlen,
    S_AXI_HP0_arlock,
    S_AXI_HP0_arprot,
    S_AXI_HP0_arqos,
    S_AXI_HP0_arready,
    S_AXI_HP0_arsize,
    S_AXI_HP0_arvalid,
    S_AXI_HP0_awaddr,
    S_AXI_HP0_awburst,
    S_AXI_HP0_awcache,
    S_AXI_HP0_awid,
    S_AXI_HP0_awlen,
    S_AXI_HP0_awlock,
    S_AXI_HP0_awprot,
    S_AXI_HP0_awqos,
    S_AXI_HP0_awready,
    S_AXI_HP0_awsize,
    S_AXI_HP0_awvalid,
    S_AXI_HP0_bid,
    S_AXI_HP0_bready,
    S_AXI_HP0_bresp,
    S_AXI_HP0_bvalid,
    S_AXI_HP0_rdata,
    S_AXI_HP0_rid,
    S_AXI_HP0_rlast,
    S_AXI_HP0_rready,
    S_AXI_HP0_rresp,
    S_AXI_HP0_rvalid,
    S_AXI_HP0_wdata,
    S_AXI_HP0_wid,
    S_AXI_HP0_wlast,
    S_AXI_HP0_wready,
    S_AXI_HP0_wstrb,
    S_AXI_HP0_wvalid,
    S_AXI_HP1_araddr,
    S_AXI_HP1_arburst,
    S_AXI_HP1_arcache,
    S_AXI_HP1_arlen,
    S_AXI_HP1_arlock,
    S_AXI_HP1_arprot,
    S_AXI_HP1_arqos,
    S_AXI_HP1_arready,
    S_AXI_HP1_arsize,
    S_AXI_HP1_arvalid,
    S_AXI_HP1_rdata,
    S_AXI_HP1_rlast,
    S_AXI_HP1_rready,
    S_AXI_HP1_rresp,
    S_AXI_HP1_rvalid,
    S_AXI_HP2_araddr,
    S_AXI_HP2_arburst,
    S_AXI_HP2_arcache,
    S_AXI_HP2_arlen,
    S_AXI_HP2_arlock,
    S_AXI_HP2_arprot,
    S_AXI_HP2_arqos,
    S_AXI_HP2_arready,
    S_AXI_HP2_arsize,
    S_AXI_HP2_arvalid,
    S_AXI_HP2_rdata,
    S_AXI_HP2_rlast,
    S_AXI_HP2_rready,
    S_AXI_HP2_rresp,
    S_AXI_HP2_rvalid,
    S_AXI_HP3_araddr,
    S_AXI_HP3_arburst,
    S_AXI_HP3_arcache,
    S_AXI_HP3_arlen,
    S_AXI_HP3_arlock,
    S_AXI_HP3_arprot,
    S_AXI_HP3_arqos,
    S_AXI_HP3_arready,
    S_AXI_HP3_arsize,
    S_AXI_HP3_arvalid,
    S_AXI_HP3_rdata,
    S_AXI_HP3_rlast,
    S_AXI_HP3_rready,
    S_AXI_HP3_rresp,
    S_AXI_HP3_rvalid,
    int_dma_0_rx,
    int_dma_0_tx,
    int_dma_1_tx,
    int_dma_2_tx,
    int_dma_3_tx,
    int_hls_block,
    interconnect_aresetna,
    peripheral_aresetns);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  output FCLK_CLK0;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output [31:0]M_AXI_GP0_araddr;
  output [1:0]M_AXI_GP0_arburst;
  output [3:0]M_AXI_GP0_arcache;
  output [11:0]M_AXI_GP0_arid;
  output [3:0]M_AXI_GP0_arlen;
  output [1:0]M_AXI_GP0_arlock;
  output [2:0]M_AXI_GP0_arprot;
  output [3:0]M_AXI_GP0_arqos;
  input M_AXI_GP0_arready;
  output [2:0]M_AXI_GP0_arsize;
  output M_AXI_GP0_arvalid;
  output [31:0]M_AXI_GP0_awaddr;
  output [1:0]M_AXI_GP0_awburst;
  output [3:0]M_AXI_GP0_awcache;
  output [11:0]M_AXI_GP0_awid;
  output [3:0]M_AXI_GP0_awlen;
  output [1:0]M_AXI_GP0_awlock;
  output [2:0]M_AXI_GP0_awprot;
  output [3:0]M_AXI_GP0_awqos;
  input M_AXI_GP0_awready;
  output [2:0]M_AXI_GP0_awsize;
  output M_AXI_GP0_awvalid;
  input [11:0]M_AXI_GP0_bid;
  output M_AXI_GP0_bready;
  input [1:0]M_AXI_GP0_bresp;
  input M_AXI_GP0_bvalid;
  input [31:0]M_AXI_GP0_rdata;
  input [11:0]M_AXI_GP0_rid;
  input M_AXI_GP0_rlast;
  output M_AXI_GP0_rready;
  input [1:0]M_AXI_GP0_rresp;
  input M_AXI_GP0_rvalid;
  output [31:0]M_AXI_GP0_wdata;
  output [11:0]M_AXI_GP0_wid;
  output M_AXI_GP0_wlast;
  input M_AXI_GP0_wready;
  output [3:0]M_AXI_GP0_wstrb;
  output M_AXI_GP0_wvalid;
  input [31:0]S_AXI_HP0_araddr;
  input [1:0]S_AXI_HP0_arburst;
  input [3:0]S_AXI_HP0_arcache;
  input [0:0]S_AXI_HP0_arid;
  input [3:0]S_AXI_HP0_arlen;
  input [1:0]S_AXI_HP0_arlock;
  input [2:0]S_AXI_HP0_arprot;
  input [3:0]S_AXI_HP0_arqos;
  output S_AXI_HP0_arready;
  input [2:0]S_AXI_HP0_arsize;
  input S_AXI_HP0_arvalid;
  input [31:0]S_AXI_HP0_awaddr;
  input [1:0]S_AXI_HP0_awburst;
  input [3:0]S_AXI_HP0_awcache;
  input [0:0]S_AXI_HP0_awid;
  input [3:0]S_AXI_HP0_awlen;
  input [1:0]S_AXI_HP0_awlock;
  input [2:0]S_AXI_HP0_awprot;
  input [3:0]S_AXI_HP0_awqos;
  output S_AXI_HP0_awready;
  input [2:0]S_AXI_HP0_awsize;
  input S_AXI_HP0_awvalid;
  output [5:0]S_AXI_HP0_bid;
  input S_AXI_HP0_bready;
  output [1:0]S_AXI_HP0_bresp;
  output S_AXI_HP0_bvalid;
  output [63:0]S_AXI_HP0_rdata;
  output [5:0]S_AXI_HP0_rid;
  output S_AXI_HP0_rlast;
  input S_AXI_HP0_rready;
  output [1:0]S_AXI_HP0_rresp;
  output S_AXI_HP0_rvalid;
  input [63:0]S_AXI_HP0_wdata;
  input [0:0]S_AXI_HP0_wid;
  input S_AXI_HP0_wlast;
  output S_AXI_HP0_wready;
  input [7:0]S_AXI_HP0_wstrb;
  input S_AXI_HP0_wvalid;
  input [31:0]S_AXI_HP1_araddr;
  input [1:0]S_AXI_HP1_arburst;
  input [3:0]S_AXI_HP1_arcache;
  input [3:0]S_AXI_HP1_arlen;
  input [1:0]S_AXI_HP1_arlock;
  input [2:0]S_AXI_HP1_arprot;
  input [3:0]S_AXI_HP1_arqos;
  output S_AXI_HP1_arready;
  input [2:0]S_AXI_HP1_arsize;
  input S_AXI_HP1_arvalid;
  output [63:0]S_AXI_HP1_rdata;
  output S_AXI_HP1_rlast;
  input S_AXI_HP1_rready;
  output [1:0]S_AXI_HP1_rresp;
  output S_AXI_HP1_rvalid;
  input [31:0]S_AXI_HP2_araddr;
  input [1:0]S_AXI_HP2_arburst;
  input [3:0]S_AXI_HP2_arcache;
  input [3:0]S_AXI_HP2_arlen;
  input [1:0]S_AXI_HP2_arlock;
  input [2:0]S_AXI_HP2_arprot;
  input [3:0]S_AXI_HP2_arqos;
  output S_AXI_HP2_arready;
  input [2:0]S_AXI_HP2_arsize;
  input S_AXI_HP2_arvalid;
  output [63:0]S_AXI_HP2_rdata;
  output S_AXI_HP2_rlast;
  input S_AXI_HP2_rready;
  output [1:0]S_AXI_HP2_rresp;
  output S_AXI_HP2_rvalid;
  input [31:0]S_AXI_HP3_araddr;
  input [1:0]S_AXI_HP3_arburst;
  input [3:0]S_AXI_HP3_arcache;
  input [3:0]S_AXI_HP3_arlen;
  input [1:0]S_AXI_HP3_arlock;
  input [2:0]S_AXI_HP3_arprot;
  input [3:0]S_AXI_HP3_arqos;
  output S_AXI_HP3_arready;
  input [2:0]S_AXI_HP3_arsize;
  input S_AXI_HP3_arvalid;
  output [63:0]S_AXI_HP3_rdata;
  output S_AXI_HP3_rlast;
  input S_AXI_HP3_rready;
  output [1:0]S_AXI_HP3_rresp;
  output S_AXI_HP3_rvalid;
  input int_dma_0_rx;
  input int_dma_0_tx;
  input int_dma_1_tx;
  input int_dma_2_tx;
  input int_dma_3_tx;
  input int_hls_block;
  output [0:0]interconnect_aresetna;
  output [0:0]peripheral_aresetns;

  wire In0_1;
  wire In1_1;
  wire In2_1;
  wire In3_1;
  wire In4_1;
  wire In5_1;
  wire [31:0]S_AXI_HP0_1_ARADDR;
  wire [1:0]S_AXI_HP0_1_ARBURST;
  wire [3:0]S_AXI_HP0_1_ARCACHE;
  wire [0:0]S_AXI_HP0_1_ARID;
  wire [3:0]S_AXI_HP0_1_ARLEN;
  wire [1:0]S_AXI_HP0_1_ARLOCK;
  wire [2:0]S_AXI_HP0_1_ARPROT;
  wire [3:0]S_AXI_HP0_1_ARQOS;
  wire S_AXI_HP0_1_ARREADY;
  wire [2:0]S_AXI_HP0_1_ARSIZE;
  wire S_AXI_HP0_1_ARVALID;
  wire [31:0]S_AXI_HP0_1_AWADDR;
  wire [1:0]S_AXI_HP0_1_AWBURST;
  wire [3:0]S_AXI_HP0_1_AWCACHE;
  wire [0:0]S_AXI_HP0_1_AWID;
  wire [3:0]S_AXI_HP0_1_AWLEN;
  wire [1:0]S_AXI_HP0_1_AWLOCK;
  wire [2:0]S_AXI_HP0_1_AWPROT;
  wire [3:0]S_AXI_HP0_1_AWQOS;
  wire S_AXI_HP0_1_AWREADY;
  wire [2:0]S_AXI_HP0_1_AWSIZE;
  wire S_AXI_HP0_1_AWVALID;
  wire [5:0]S_AXI_HP0_1_BID;
  wire S_AXI_HP0_1_BREADY;
  wire [1:0]S_AXI_HP0_1_BRESP;
  wire S_AXI_HP0_1_BVALID;
  wire [63:0]S_AXI_HP0_1_RDATA;
  wire [5:0]S_AXI_HP0_1_RID;
  wire S_AXI_HP0_1_RLAST;
  wire S_AXI_HP0_1_RREADY;
  wire [1:0]S_AXI_HP0_1_RRESP;
  wire S_AXI_HP0_1_RVALID;
  wire [63:0]S_AXI_HP0_1_WDATA;
  wire [0:0]S_AXI_HP0_1_WID;
  wire S_AXI_HP0_1_WLAST;
  wire S_AXI_HP0_1_WREADY;
  wire [7:0]S_AXI_HP0_1_WSTRB;
  wire S_AXI_HP0_1_WVALID;
  wire [31:0]S_AXI_HP1_1_ARADDR;
  wire [1:0]S_AXI_HP1_1_ARBURST;
  wire [3:0]S_AXI_HP1_1_ARCACHE;
  wire [3:0]S_AXI_HP1_1_ARLEN;
  wire [1:0]S_AXI_HP1_1_ARLOCK;
  wire [2:0]S_AXI_HP1_1_ARPROT;
  wire [3:0]S_AXI_HP1_1_ARQOS;
  wire S_AXI_HP1_1_ARREADY;
  wire [2:0]S_AXI_HP1_1_ARSIZE;
  wire S_AXI_HP1_1_ARVALID;
  wire [63:0]S_AXI_HP1_1_RDATA;
  wire S_AXI_HP1_1_RLAST;
  wire S_AXI_HP1_1_RREADY;
  wire [1:0]S_AXI_HP1_1_RRESP;
  wire S_AXI_HP1_1_RVALID;
  wire [31:0]S_AXI_HP2_1_ARADDR;
  wire [1:0]S_AXI_HP2_1_ARBURST;
  wire [3:0]S_AXI_HP2_1_ARCACHE;
  wire [3:0]S_AXI_HP2_1_ARLEN;
  wire [1:0]S_AXI_HP2_1_ARLOCK;
  wire [2:0]S_AXI_HP2_1_ARPROT;
  wire [3:0]S_AXI_HP2_1_ARQOS;
  wire S_AXI_HP2_1_ARREADY;
  wire [2:0]S_AXI_HP2_1_ARSIZE;
  wire S_AXI_HP2_1_ARVALID;
  wire [63:0]S_AXI_HP2_1_RDATA;
  wire S_AXI_HP2_1_RLAST;
  wire S_AXI_HP2_1_RREADY;
  wire [1:0]S_AXI_HP2_1_RRESP;
  wire S_AXI_HP2_1_RVALID;
  wire [31:0]S_AXI_HP3_1_ARADDR;
  wire [1:0]S_AXI_HP3_1_ARBURST;
  wire [3:0]S_AXI_HP3_1_ARCACHE;
  wire [3:0]S_AXI_HP3_1_ARLEN;
  wire [1:0]S_AXI_HP3_1_ARLOCK;
  wire [2:0]S_AXI_HP3_1_ARPROT;
  wire [3:0]S_AXI_HP3_1_ARQOS;
  wire S_AXI_HP3_1_ARREADY;
  wire [2:0]S_AXI_HP3_1_ARSIZE;
  wire S_AXI_HP3_1_ARVALID;
  wire [63:0]S_AXI_HP3_1_RDATA;
  wire S_AXI_HP3_1_RLAST;
  wire S_AXI_HP3_1_RREADY;
  wire [1:0]S_AXI_HP3_1_RRESP;
  wire S_AXI_HP3_1_RVALID;
  wire [14:0]processing_system7_0_DDR_ADDR;
  wire [2:0]processing_system7_0_DDR_BA;
  wire processing_system7_0_DDR_CAS_N;
  wire processing_system7_0_DDR_CKE;
  wire processing_system7_0_DDR_CK_N;
  wire processing_system7_0_DDR_CK_P;
  wire processing_system7_0_DDR_CS_N;
  wire [3:0]processing_system7_0_DDR_DM;
  wire [31:0]processing_system7_0_DDR_DQ;
  wire [3:0]processing_system7_0_DDR_DQS_N;
  wire [3:0]processing_system7_0_DDR_DQS_P;
  wire processing_system7_0_DDR_ODT;
  wire processing_system7_0_DDR_RAS_N;
  wire processing_system7_0_DDR_RESET_N;
  wire processing_system7_0_DDR_WE_N;
  wire processing_system7_0_FCLK_CLK0;
  wire processing_system7_0_FCLK_RESET0_N;
  wire processing_system7_0_FIXED_IO_DDR_VRN;
  wire processing_system7_0_FIXED_IO_DDR_VRP;
  wire [53:0]processing_system7_0_FIXED_IO_MIO;
  wire processing_system7_0_FIXED_IO_PS_CLK;
  wire processing_system7_0_FIXED_IO_PS_PORB;
  wire processing_system7_0_FIXED_IO_PS_SRSTB;
  wire [31:0]processing_system7_0_M_AXI_GP0_ARADDR;
  wire [1:0]processing_system7_0_M_AXI_GP0_ARBURST;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARCACHE;
  wire [11:0]processing_system7_0_M_AXI_GP0_ARID;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARLEN;
  wire [1:0]processing_system7_0_M_AXI_GP0_ARLOCK;
  wire [2:0]processing_system7_0_M_AXI_GP0_ARPROT;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARQOS;
  wire processing_system7_0_M_AXI_GP0_ARREADY;
  wire [2:0]processing_system7_0_M_AXI_GP0_ARSIZE;
  wire processing_system7_0_M_AXI_GP0_ARVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_AWADDR;
  wire [1:0]processing_system7_0_M_AXI_GP0_AWBURST;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWCACHE;
  wire [11:0]processing_system7_0_M_AXI_GP0_AWID;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWLEN;
  wire [1:0]processing_system7_0_M_AXI_GP0_AWLOCK;
  wire [2:0]processing_system7_0_M_AXI_GP0_AWPROT;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWQOS;
  wire processing_system7_0_M_AXI_GP0_AWREADY;
  wire [2:0]processing_system7_0_M_AXI_GP0_AWSIZE;
  wire processing_system7_0_M_AXI_GP0_AWVALID;
  wire [11:0]processing_system7_0_M_AXI_GP0_BID;
  wire processing_system7_0_M_AXI_GP0_BREADY;
  wire [1:0]processing_system7_0_M_AXI_GP0_BRESP;
  wire processing_system7_0_M_AXI_GP0_BVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_RDATA;
  wire [11:0]processing_system7_0_M_AXI_GP0_RID;
  wire processing_system7_0_M_AXI_GP0_RLAST;
  wire processing_system7_0_M_AXI_GP0_RREADY;
  wire [1:0]processing_system7_0_M_AXI_GP0_RRESP;
  wire processing_system7_0_M_AXI_GP0_RVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_WDATA;
  wire [11:0]processing_system7_0_M_AXI_GP0_WID;
  wire processing_system7_0_M_AXI_GP0_WLAST;
  wire processing_system7_0_M_AXI_GP0_WREADY;
  wire [3:0]processing_system7_0_M_AXI_GP0_WSTRB;
  wire processing_system7_0_M_AXI_GP0_WVALID;
  wire [0:0]rst_processing_system7_0_100M_interconnect_aresetn;
  wire [0:0]rst_processing_system7_0_100M_peripheral_aresetn;
  wire [5:0]xlconcat_0_dout;

  assign FCLK_CLK0 = processing_system7_0_FCLK_CLK0;
  assign In0_1 = int_dma_0_rx;
  assign In1_1 = int_dma_0_tx;
  assign In2_1 = int_dma_1_tx;
  assign In3_1 = int_dma_2_tx;
  assign In4_1 = int_dma_3_tx;
  assign In5_1 = int_hls_block;
  assign M_AXI_GP0_araddr[31:0] = processing_system7_0_M_AXI_GP0_ARADDR;
  assign M_AXI_GP0_arburst[1:0] = processing_system7_0_M_AXI_GP0_ARBURST;
  assign M_AXI_GP0_arcache[3:0] = processing_system7_0_M_AXI_GP0_ARCACHE;
  assign M_AXI_GP0_arid[11:0] = processing_system7_0_M_AXI_GP0_ARID;
  assign M_AXI_GP0_arlen[3:0] = processing_system7_0_M_AXI_GP0_ARLEN;
  assign M_AXI_GP0_arlock[1:0] = processing_system7_0_M_AXI_GP0_ARLOCK;
  assign M_AXI_GP0_arprot[2:0] = processing_system7_0_M_AXI_GP0_ARPROT;
  assign M_AXI_GP0_arqos[3:0] = processing_system7_0_M_AXI_GP0_ARQOS;
  assign M_AXI_GP0_arsize[2:0] = processing_system7_0_M_AXI_GP0_ARSIZE;
  assign M_AXI_GP0_arvalid = processing_system7_0_M_AXI_GP0_ARVALID;
  assign M_AXI_GP0_awaddr[31:0] = processing_system7_0_M_AXI_GP0_AWADDR;
  assign M_AXI_GP0_awburst[1:0] = processing_system7_0_M_AXI_GP0_AWBURST;
  assign M_AXI_GP0_awcache[3:0] = processing_system7_0_M_AXI_GP0_AWCACHE;
  assign M_AXI_GP0_awid[11:0] = processing_system7_0_M_AXI_GP0_AWID;
  assign M_AXI_GP0_awlen[3:0] = processing_system7_0_M_AXI_GP0_AWLEN;
  assign M_AXI_GP0_awlock[1:0] = processing_system7_0_M_AXI_GP0_AWLOCK;
  assign M_AXI_GP0_awprot[2:0] = processing_system7_0_M_AXI_GP0_AWPROT;
  assign M_AXI_GP0_awqos[3:0] = processing_system7_0_M_AXI_GP0_AWQOS;
  assign M_AXI_GP0_awsize[2:0] = processing_system7_0_M_AXI_GP0_AWSIZE;
  assign M_AXI_GP0_awvalid = processing_system7_0_M_AXI_GP0_AWVALID;
  assign M_AXI_GP0_bready = processing_system7_0_M_AXI_GP0_BREADY;
  assign M_AXI_GP0_rready = processing_system7_0_M_AXI_GP0_RREADY;
  assign M_AXI_GP0_wdata[31:0] = processing_system7_0_M_AXI_GP0_WDATA;
  assign M_AXI_GP0_wid[11:0] = processing_system7_0_M_AXI_GP0_WID;
  assign M_AXI_GP0_wlast = processing_system7_0_M_AXI_GP0_WLAST;
  assign M_AXI_GP0_wstrb[3:0] = processing_system7_0_M_AXI_GP0_WSTRB;
  assign M_AXI_GP0_wvalid = processing_system7_0_M_AXI_GP0_WVALID;
  assign S_AXI_HP0_1_ARADDR = S_AXI_HP0_araddr[31:0];
  assign S_AXI_HP0_1_ARBURST = S_AXI_HP0_arburst[1:0];
  assign S_AXI_HP0_1_ARCACHE = S_AXI_HP0_arcache[3:0];
  assign S_AXI_HP0_1_ARID = S_AXI_HP0_arid[0];
  assign S_AXI_HP0_1_ARLEN = S_AXI_HP0_arlen[3:0];
  assign S_AXI_HP0_1_ARLOCK = S_AXI_HP0_arlock[1:0];
  assign S_AXI_HP0_1_ARPROT = S_AXI_HP0_arprot[2:0];
  assign S_AXI_HP0_1_ARQOS = S_AXI_HP0_arqos[3:0];
  assign S_AXI_HP0_1_ARSIZE = S_AXI_HP0_arsize[2:0];
  assign S_AXI_HP0_1_ARVALID = S_AXI_HP0_arvalid;
  assign S_AXI_HP0_1_AWADDR = S_AXI_HP0_awaddr[31:0];
  assign S_AXI_HP0_1_AWBURST = S_AXI_HP0_awburst[1:0];
  assign S_AXI_HP0_1_AWCACHE = S_AXI_HP0_awcache[3:0];
  assign S_AXI_HP0_1_AWID = S_AXI_HP0_awid[0];
  assign S_AXI_HP0_1_AWLEN = S_AXI_HP0_awlen[3:0];
  assign S_AXI_HP0_1_AWLOCK = S_AXI_HP0_awlock[1:0];
  assign S_AXI_HP0_1_AWPROT = S_AXI_HP0_awprot[2:0];
  assign S_AXI_HP0_1_AWQOS = S_AXI_HP0_awqos[3:0];
  assign S_AXI_HP0_1_AWSIZE = S_AXI_HP0_awsize[2:0];
  assign S_AXI_HP0_1_AWVALID = S_AXI_HP0_awvalid;
  assign S_AXI_HP0_1_BREADY = S_AXI_HP0_bready;
  assign S_AXI_HP0_1_RREADY = S_AXI_HP0_rready;
  assign S_AXI_HP0_1_WDATA = S_AXI_HP0_wdata[63:0];
  assign S_AXI_HP0_1_WID = S_AXI_HP0_wid[0];
  assign S_AXI_HP0_1_WLAST = S_AXI_HP0_wlast;
  assign S_AXI_HP0_1_WSTRB = S_AXI_HP0_wstrb[7:0];
  assign S_AXI_HP0_1_WVALID = S_AXI_HP0_wvalid;
  assign S_AXI_HP0_arready = S_AXI_HP0_1_ARREADY;
  assign S_AXI_HP0_awready = S_AXI_HP0_1_AWREADY;
  assign S_AXI_HP0_bid[5:0] = S_AXI_HP0_1_BID;
  assign S_AXI_HP0_bresp[1:0] = S_AXI_HP0_1_BRESP;
  assign S_AXI_HP0_bvalid = S_AXI_HP0_1_BVALID;
  assign S_AXI_HP0_rdata[63:0] = S_AXI_HP0_1_RDATA;
  assign S_AXI_HP0_rid[5:0] = S_AXI_HP0_1_RID;
  assign S_AXI_HP0_rlast = S_AXI_HP0_1_RLAST;
  assign S_AXI_HP0_rresp[1:0] = S_AXI_HP0_1_RRESP;
  assign S_AXI_HP0_rvalid = S_AXI_HP0_1_RVALID;
  assign S_AXI_HP0_wready = S_AXI_HP0_1_WREADY;
  assign S_AXI_HP1_1_ARADDR = S_AXI_HP1_araddr[31:0];
  assign S_AXI_HP1_1_ARBURST = S_AXI_HP1_arburst[1:0];
  assign S_AXI_HP1_1_ARCACHE = S_AXI_HP1_arcache[3:0];
  assign S_AXI_HP1_1_ARLEN = S_AXI_HP1_arlen[3:0];
  assign S_AXI_HP1_1_ARLOCK = S_AXI_HP1_arlock[1:0];
  assign S_AXI_HP1_1_ARPROT = S_AXI_HP1_arprot[2:0];
  assign S_AXI_HP1_1_ARQOS = S_AXI_HP1_arqos[3:0];
  assign S_AXI_HP1_1_ARSIZE = S_AXI_HP1_arsize[2:0];
  assign S_AXI_HP1_1_ARVALID = S_AXI_HP1_arvalid;
  assign S_AXI_HP1_1_RREADY = S_AXI_HP1_rready;
  assign S_AXI_HP1_arready = S_AXI_HP1_1_ARREADY;
  assign S_AXI_HP1_rdata[63:0] = S_AXI_HP1_1_RDATA;
  assign S_AXI_HP1_rlast = S_AXI_HP1_1_RLAST;
  assign S_AXI_HP1_rresp[1:0] = S_AXI_HP1_1_RRESP;
  assign S_AXI_HP1_rvalid = S_AXI_HP1_1_RVALID;
  assign S_AXI_HP2_1_ARADDR = S_AXI_HP2_araddr[31:0];
  assign S_AXI_HP2_1_ARBURST = S_AXI_HP2_arburst[1:0];
  assign S_AXI_HP2_1_ARCACHE = S_AXI_HP2_arcache[3:0];
  assign S_AXI_HP2_1_ARLEN = S_AXI_HP2_arlen[3:0];
  assign S_AXI_HP2_1_ARLOCK = S_AXI_HP2_arlock[1:0];
  assign S_AXI_HP2_1_ARPROT = S_AXI_HP2_arprot[2:0];
  assign S_AXI_HP2_1_ARQOS = S_AXI_HP2_arqos[3:0];
  assign S_AXI_HP2_1_ARSIZE = S_AXI_HP2_arsize[2:0];
  assign S_AXI_HP2_1_ARVALID = S_AXI_HP2_arvalid;
  assign S_AXI_HP2_1_RREADY = S_AXI_HP2_rready;
  assign S_AXI_HP2_arready = S_AXI_HP2_1_ARREADY;
  assign S_AXI_HP2_rdata[63:0] = S_AXI_HP2_1_RDATA;
  assign S_AXI_HP2_rlast = S_AXI_HP2_1_RLAST;
  assign S_AXI_HP2_rresp[1:0] = S_AXI_HP2_1_RRESP;
  assign S_AXI_HP2_rvalid = S_AXI_HP2_1_RVALID;
  assign S_AXI_HP3_1_ARADDR = S_AXI_HP3_araddr[31:0];
  assign S_AXI_HP3_1_ARBURST = S_AXI_HP3_arburst[1:0];
  assign S_AXI_HP3_1_ARCACHE = S_AXI_HP3_arcache[3:0];
  assign S_AXI_HP3_1_ARLEN = S_AXI_HP3_arlen[3:0];
  assign S_AXI_HP3_1_ARLOCK = S_AXI_HP3_arlock[1:0];
  assign S_AXI_HP3_1_ARPROT = S_AXI_HP3_arprot[2:0];
  assign S_AXI_HP3_1_ARQOS = S_AXI_HP3_arqos[3:0];
  assign S_AXI_HP3_1_ARSIZE = S_AXI_HP3_arsize[2:0];
  assign S_AXI_HP3_1_ARVALID = S_AXI_HP3_arvalid;
  assign S_AXI_HP3_1_RREADY = S_AXI_HP3_rready;
  assign S_AXI_HP3_arready = S_AXI_HP3_1_ARREADY;
  assign S_AXI_HP3_rdata[63:0] = S_AXI_HP3_1_RDATA;
  assign S_AXI_HP3_rlast = S_AXI_HP3_1_RLAST;
  assign S_AXI_HP3_rresp[1:0] = S_AXI_HP3_1_RRESP;
  assign S_AXI_HP3_rvalid = S_AXI_HP3_1_RVALID;
  assign interconnect_aresetna[0] = rst_processing_system7_0_100M_interconnect_aresetn;
  assign peripheral_aresetns[0] = rst_processing_system7_0_100M_peripheral_aresetn;
  assign processing_system7_0_M_AXI_GP0_ARREADY = M_AXI_GP0_arready;
  assign processing_system7_0_M_AXI_GP0_AWREADY = M_AXI_GP0_awready;
  assign processing_system7_0_M_AXI_GP0_BID = M_AXI_GP0_bid[11:0];
  assign processing_system7_0_M_AXI_GP0_BRESP = M_AXI_GP0_bresp[1:0];
  assign processing_system7_0_M_AXI_GP0_BVALID = M_AXI_GP0_bvalid;
  assign processing_system7_0_M_AXI_GP0_RDATA = M_AXI_GP0_rdata[31:0];
  assign processing_system7_0_M_AXI_GP0_RID = M_AXI_GP0_rid[11:0];
  assign processing_system7_0_M_AXI_GP0_RLAST = M_AXI_GP0_rlast;
  assign processing_system7_0_M_AXI_GP0_RRESP = M_AXI_GP0_rresp[1:0];
  assign processing_system7_0_M_AXI_GP0_RVALID = M_AXI_GP0_rvalid;
  assign processing_system7_0_M_AXI_GP0_WREADY = M_AXI_GP0_wready;
  system_processing_system7_0_0 processing_system7_0
       (.DDR_Addr(DDR_addr[14:0]),
        .DDR_BankAddr(DDR_ba[2:0]),
        .DDR_CAS_n(DDR_cas_n),
        .DDR_CKE(DDR_cke),
        .DDR_CS_n(DDR_cs_n),
        .DDR_Clk(DDR_ck_p),
        .DDR_Clk_n(DDR_ck_n),
        .DDR_DM(DDR_dm[3:0]),
        .DDR_DQ(DDR_dq[31:0]),
        .DDR_DQS(DDR_dqs_p[3:0]),
        .DDR_DQS_n(DDR_dqs_n[3:0]),
        .DDR_DRSTB(DDR_reset_n),
        .DDR_ODT(DDR_odt),
        .DDR_RAS_n(DDR_ras_n),
        .DDR_VRN(FIXED_IO_ddr_vrn),
        .DDR_VRP(FIXED_IO_ddr_vrp),
        .DDR_WEB(DDR_we_n),
        .FCLK_CLK0(processing_system7_0_FCLK_CLK0),
        .FCLK_RESET0_N(processing_system7_0_FCLK_RESET0_N),
        .IRQ_F2P(xlconcat_0_dout),
        .MIO(FIXED_IO_mio[53:0]),
        .M_AXI_GP0_ACLK(processing_system7_0_FCLK_CLK0),
        .M_AXI_GP0_ARADDR(processing_system7_0_M_AXI_GP0_ARADDR),
        .M_AXI_GP0_ARBURST(processing_system7_0_M_AXI_GP0_ARBURST),
        .M_AXI_GP0_ARCACHE(processing_system7_0_M_AXI_GP0_ARCACHE),
        .M_AXI_GP0_ARID(processing_system7_0_M_AXI_GP0_ARID),
        .M_AXI_GP0_ARLEN(processing_system7_0_M_AXI_GP0_ARLEN),
        .M_AXI_GP0_ARLOCK(processing_system7_0_M_AXI_GP0_ARLOCK),
        .M_AXI_GP0_ARPROT(processing_system7_0_M_AXI_GP0_ARPROT),
        .M_AXI_GP0_ARQOS(processing_system7_0_M_AXI_GP0_ARQOS),
        .M_AXI_GP0_ARREADY(processing_system7_0_M_AXI_GP0_ARREADY),
        .M_AXI_GP0_ARSIZE(processing_system7_0_M_AXI_GP0_ARSIZE),
        .M_AXI_GP0_ARVALID(processing_system7_0_M_AXI_GP0_ARVALID),
        .M_AXI_GP0_AWADDR(processing_system7_0_M_AXI_GP0_AWADDR),
        .M_AXI_GP0_AWBURST(processing_system7_0_M_AXI_GP0_AWBURST),
        .M_AXI_GP0_AWCACHE(processing_system7_0_M_AXI_GP0_AWCACHE),
        .M_AXI_GP0_AWID(processing_system7_0_M_AXI_GP0_AWID),
        .M_AXI_GP0_AWLEN(processing_system7_0_M_AXI_GP0_AWLEN),
        .M_AXI_GP0_AWLOCK(processing_system7_0_M_AXI_GP0_AWLOCK),
        .M_AXI_GP0_AWPROT(processing_system7_0_M_AXI_GP0_AWPROT),
        .M_AXI_GP0_AWQOS(processing_system7_0_M_AXI_GP0_AWQOS),
        .M_AXI_GP0_AWREADY(processing_system7_0_M_AXI_GP0_AWREADY),
        .M_AXI_GP0_AWSIZE(processing_system7_0_M_AXI_GP0_AWSIZE),
        .M_AXI_GP0_AWVALID(processing_system7_0_M_AXI_GP0_AWVALID),
        .M_AXI_GP0_BID(processing_system7_0_M_AXI_GP0_BID),
        .M_AXI_GP0_BREADY(processing_system7_0_M_AXI_GP0_BREADY),
        .M_AXI_GP0_BRESP(processing_system7_0_M_AXI_GP0_BRESP),
        .M_AXI_GP0_BVALID(processing_system7_0_M_AXI_GP0_BVALID),
        .M_AXI_GP0_RDATA(processing_system7_0_M_AXI_GP0_RDATA),
        .M_AXI_GP0_RID(processing_system7_0_M_AXI_GP0_RID),
        .M_AXI_GP0_RLAST(processing_system7_0_M_AXI_GP0_RLAST),
        .M_AXI_GP0_RREADY(processing_system7_0_M_AXI_GP0_RREADY),
        .M_AXI_GP0_RRESP(processing_system7_0_M_AXI_GP0_RRESP),
        .M_AXI_GP0_RVALID(processing_system7_0_M_AXI_GP0_RVALID),
        .M_AXI_GP0_WDATA(processing_system7_0_M_AXI_GP0_WDATA),
        .M_AXI_GP0_WID(processing_system7_0_M_AXI_GP0_WID),
        .M_AXI_GP0_WLAST(processing_system7_0_M_AXI_GP0_WLAST),
        .M_AXI_GP0_WREADY(processing_system7_0_M_AXI_GP0_WREADY),
        .M_AXI_GP0_WSTRB(processing_system7_0_M_AXI_GP0_WSTRB),
        .M_AXI_GP0_WVALID(processing_system7_0_M_AXI_GP0_WVALID),
        .PS_CLK(FIXED_IO_ps_clk),
        .PS_PORB(FIXED_IO_ps_porb),
        .PS_SRSTB(FIXED_IO_ps_srstb),
        .S_AXI_HP0_ACLK(processing_system7_0_FCLK_CLK0),
        .S_AXI_HP0_ARADDR(S_AXI_HP0_1_ARADDR),
        .S_AXI_HP0_ARBURST(S_AXI_HP0_1_ARBURST),
        .S_AXI_HP0_ARCACHE(S_AXI_HP0_1_ARCACHE),
        .S_AXI_HP0_ARID({1'b0,1'b0,1'b0,1'b0,1'b0,S_AXI_HP0_1_ARID}),
        .S_AXI_HP0_ARLEN(S_AXI_HP0_1_ARLEN),
        .S_AXI_HP0_ARLOCK(S_AXI_HP0_1_ARLOCK),
        .S_AXI_HP0_ARPROT(S_AXI_HP0_1_ARPROT),
        .S_AXI_HP0_ARQOS(S_AXI_HP0_1_ARQOS),
        .S_AXI_HP0_ARREADY(S_AXI_HP0_1_ARREADY),
        .S_AXI_HP0_ARSIZE(S_AXI_HP0_1_ARSIZE),
        .S_AXI_HP0_ARVALID(S_AXI_HP0_1_ARVALID),
        .S_AXI_HP0_AWADDR(S_AXI_HP0_1_AWADDR),
        .S_AXI_HP0_AWBURST(S_AXI_HP0_1_AWBURST),
        .S_AXI_HP0_AWCACHE(S_AXI_HP0_1_AWCACHE),
        .S_AXI_HP0_AWID({1'b0,1'b0,1'b0,1'b0,1'b0,S_AXI_HP0_1_AWID}),
        .S_AXI_HP0_AWLEN(S_AXI_HP0_1_AWLEN),
        .S_AXI_HP0_AWLOCK(S_AXI_HP0_1_AWLOCK),
        .S_AXI_HP0_AWPROT(S_AXI_HP0_1_AWPROT),
        .S_AXI_HP0_AWQOS(S_AXI_HP0_1_AWQOS),
        .S_AXI_HP0_AWREADY(S_AXI_HP0_1_AWREADY),
        .S_AXI_HP0_AWSIZE(S_AXI_HP0_1_AWSIZE),
        .S_AXI_HP0_AWVALID(S_AXI_HP0_1_AWVALID),
        .S_AXI_HP0_BID(S_AXI_HP0_1_BID),
        .S_AXI_HP0_BREADY(S_AXI_HP0_1_BREADY),
        .S_AXI_HP0_BRESP(S_AXI_HP0_1_BRESP),
        .S_AXI_HP0_BVALID(S_AXI_HP0_1_BVALID),
        .S_AXI_HP0_RDATA(S_AXI_HP0_1_RDATA),
        .S_AXI_HP0_RDISSUECAP1_EN(1'b0),
        .S_AXI_HP0_RID(S_AXI_HP0_1_RID),
        .S_AXI_HP0_RLAST(S_AXI_HP0_1_RLAST),
        .S_AXI_HP0_RREADY(S_AXI_HP0_1_RREADY),
        .S_AXI_HP0_RRESP(S_AXI_HP0_1_RRESP),
        .S_AXI_HP0_RVALID(S_AXI_HP0_1_RVALID),
        .S_AXI_HP0_WDATA(S_AXI_HP0_1_WDATA),
        .S_AXI_HP0_WID({1'b0,1'b0,1'b0,1'b0,1'b0,S_AXI_HP0_1_WID}),
        .S_AXI_HP0_WLAST(S_AXI_HP0_1_WLAST),
        .S_AXI_HP0_WREADY(S_AXI_HP0_1_WREADY),
        .S_AXI_HP0_WRISSUECAP1_EN(1'b0),
        .S_AXI_HP0_WSTRB(S_AXI_HP0_1_WSTRB),
        .S_AXI_HP0_WVALID(S_AXI_HP0_1_WVALID),
        .S_AXI_HP1_ACLK(processing_system7_0_FCLK_CLK0),
        .S_AXI_HP1_ARADDR(S_AXI_HP1_1_ARADDR),
        .S_AXI_HP1_ARBURST(S_AXI_HP1_1_ARBURST),
        .S_AXI_HP1_ARCACHE(S_AXI_HP1_1_ARCACHE),
        .S_AXI_HP1_ARID({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP1_ARLEN(S_AXI_HP1_1_ARLEN),
        .S_AXI_HP1_ARLOCK(S_AXI_HP1_1_ARLOCK),
        .S_AXI_HP1_ARPROT(S_AXI_HP1_1_ARPROT),
        .S_AXI_HP1_ARQOS(S_AXI_HP1_1_ARQOS),
        .S_AXI_HP1_ARREADY(S_AXI_HP1_1_ARREADY),
        .S_AXI_HP1_ARSIZE(S_AXI_HP1_1_ARSIZE),
        .S_AXI_HP1_ARVALID(S_AXI_HP1_1_ARVALID),
        .S_AXI_HP1_AWADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP1_AWBURST({1'b0,1'b0}),
        .S_AXI_HP1_AWCACHE({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP1_AWID({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP1_AWLEN({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP1_AWLOCK({1'b0,1'b0}),
        .S_AXI_HP1_AWPROT({1'b0,1'b0,1'b0}),
        .S_AXI_HP1_AWQOS({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP1_AWSIZE({1'b0,1'b0,1'b0}),
        .S_AXI_HP1_AWVALID(1'b0),
        .S_AXI_HP1_BREADY(1'b0),
        .S_AXI_HP1_RDATA(S_AXI_HP1_1_RDATA),
        .S_AXI_HP1_RDISSUECAP1_EN(1'b0),
        .S_AXI_HP1_RLAST(S_AXI_HP1_1_RLAST),
        .S_AXI_HP1_RREADY(S_AXI_HP1_1_RREADY),
        .S_AXI_HP1_RRESP(S_AXI_HP1_1_RRESP),
        .S_AXI_HP1_RVALID(S_AXI_HP1_1_RVALID),
        .S_AXI_HP1_WDATA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP1_WID({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP1_WLAST(1'b0),
        .S_AXI_HP1_WRISSUECAP1_EN(1'b0),
        .S_AXI_HP1_WSTRB({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP1_WVALID(1'b0),
        .S_AXI_HP2_ACLK(processing_system7_0_FCLK_CLK0),
        .S_AXI_HP2_ARADDR(S_AXI_HP2_1_ARADDR),
        .S_AXI_HP2_ARBURST(S_AXI_HP2_1_ARBURST),
        .S_AXI_HP2_ARCACHE(S_AXI_HP2_1_ARCACHE),
        .S_AXI_HP2_ARID({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP2_ARLEN(S_AXI_HP2_1_ARLEN),
        .S_AXI_HP2_ARLOCK(S_AXI_HP2_1_ARLOCK),
        .S_AXI_HP2_ARPROT(S_AXI_HP2_1_ARPROT),
        .S_AXI_HP2_ARQOS(S_AXI_HP2_1_ARQOS),
        .S_AXI_HP2_ARREADY(S_AXI_HP2_1_ARREADY),
        .S_AXI_HP2_ARSIZE(S_AXI_HP2_1_ARSIZE),
        .S_AXI_HP2_ARVALID(S_AXI_HP2_1_ARVALID),
        .S_AXI_HP2_AWADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP2_AWBURST({1'b0,1'b0}),
        .S_AXI_HP2_AWCACHE({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP2_AWID({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP2_AWLEN({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP2_AWLOCK({1'b0,1'b0}),
        .S_AXI_HP2_AWPROT({1'b0,1'b0,1'b0}),
        .S_AXI_HP2_AWQOS({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP2_AWSIZE({1'b0,1'b0,1'b0}),
        .S_AXI_HP2_AWVALID(1'b0),
        .S_AXI_HP2_BREADY(1'b0),
        .S_AXI_HP2_RDATA(S_AXI_HP2_1_RDATA),
        .S_AXI_HP2_RDISSUECAP1_EN(1'b0),
        .S_AXI_HP2_RLAST(S_AXI_HP2_1_RLAST),
        .S_AXI_HP2_RREADY(S_AXI_HP2_1_RREADY),
        .S_AXI_HP2_RRESP(S_AXI_HP2_1_RRESP),
        .S_AXI_HP2_RVALID(S_AXI_HP2_1_RVALID),
        .S_AXI_HP2_WDATA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP2_WID({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP2_WLAST(1'b0),
        .S_AXI_HP2_WRISSUECAP1_EN(1'b0),
        .S_AXI_HP2_WSTRB({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP2_WVALID(1'b0),
        .S_AXI_HP3_ACLK(processing_system7_0_FCLK_CLK0),
        .S_AXI_HP3_ARADDR(S_AXI_HP3_1_ARADDR),
        .S_AXI_HP3_ARBURST(S_AXI_HP3_1_ARBURST),
        .S_AXI_HP3_ARCACHE(S_AXI_HP3_1_ARCACHE),
        .S_AXI_HP3_ARID({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP3_ARLEN(S_AXI_HP3_1_ARLEN),
        .S_AXI_HP3_ARLOCK(S_AXI_HP3_1_ARLOCK),
        .S_AXI_HP3_ARPROT(S_AXI_HP3_1_ARPROT),
        .S_AXI_HP3_ARQOS(S_AXI_HP3_1_ARQOS),
        .S_AXI_HP3_ARREADY(S_AXI_HP3_1_ARREADY),
        .S_AXI_HP3_ARSIZE(S_AXI_HP3_1_ARSIZE),
        .S_AXI_HP3_ARVALID(S_AXI_HP3_1_ARVALID),
        .S_AXI_HP3_AWADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP3_AWBURST({1'b0,1'b0}),
        .S_AXI_HP3_AWCACHE({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP3_AWID({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP3_AWLEN({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP3_AWLOCK({1'b0,1'b0}),
        .S_AXI_HP3_AWPROT({1'b0,1'b0,1'b0}),
        .S_AXI_HP3_AWQOS({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP3_AWSIZE({1'b0,1'b0,1'b0}),
        .S_AXI_HP3_AWVALID(1'b0),
        .S_AXI_HP3_BREADY(1'b0),
        .S_AXI_HP3_RDATA(S_AXI_HP3_1_RDATA),
        .S_AXI_HP3_RDISSUECAP1_EN(1'b0),
        .S_AXI_HP3_RLAST(S_AXI_HP3_1_RLAST),
        .S_AXI_HP3_RREADY(S_AXI_HP3_1_RREADY),
        .S_AXI_HP3_RRESP(S_AXI_HP3_1_RRESP),
        .S_AXI_HP3_RVALID(S_AXI_HP3_1_RVALID),
        .S_AXI_HP3_WDATA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP3_WID({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP3_WLAST(1'b0),
        .S_AXI_HP3_WRISSUECAP1_EN(1'b0),
        .S_AXI_HP3_WSTRB({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP3_WVALID(1'b0),
        .USB0_VBUS_PWRFAULT(1'b0));
  system_rst_processing_system7_0_100M_0 rst_processing_system7_0_100M
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(processing_system7_0_FCLK_RESET0_N),
        .interconnect_aresetn(rst_processing_system7_0_100M_interconnect_aresetn),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(rst_processing_system7_0_100M_peripheral_aresetn),
        .slowest_sync_clk(processing_system7_0_FCLK_CLK0));
  system_xlconcat_0_0 xlconcat_0
       (.In0(In0_1),
        .In1(In1_1),
        .In2(In2_1),
        .In3(In3_1),
        .In4(In4_1),
        .In5(In5_1),
        .dout(xlconcat_0_dout));
endmodule
