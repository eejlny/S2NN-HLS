//-----------------------------------------------------------------------------
// axi_perf_mon_v5_0_9_advanced  module
//-----------------------------------------------------------------------------
// (c) Copyright 2009 - 2013 Xilinx, Inc. All rights reserved.
//
//  This file contains confidential and proprietary information
//  of Xilinx, Inc. and is protected under U.S. and 
//  international copyright and other intellectual property
//  laws.
//  
//  DISCLAIMER
//  This disclaimer is not a license and does not grant any
//  rights to the materials distributed herewith. Except as
//  otherwise provided in a valid license issued to you by
//  Xilinx, and to the maximum extent permitted by applicable
//  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//  (2) Xilinx shall not be liable (whether in contract or tort,
//  including negligence, or under any other theory of
//  liability) for any loss or damage of any kind or nature
//  related to, arising under or in connection with these
//  materials, including for any direct, or any indirect,
//  special, incidental, or consequential loss or damage
//  (including loss of data, profits, goodwill, or any type of
//  loss or damage suffered as a result of any action brought
//  by a third party) even if such damage or loss was
//  reasonably foreseeable or Xilinx had been advised of the
//  possibility of the same.
//  
//  CRITICAL APPLICATIONS
//  Xilinx products are not designed or intended to be fail-
//  safe, or for use in any application requiring fail-safe
//  performance, such as life-support or safety devices or
//  systems, Class III medical devices, nuclear facilities,
//  applications related to the deployment of airbags, or any
//  other applications that could lead to death, personal
//  injury, or severe property or environmental damage
//  (individually and collectively, "Critical
//  Applications"). Customer assumes the sole risk and
//  liability of any use of Xilinx products in Critical
//  Applications, subject only to applicable laws and
//  regulations governing limitations on product liability.
//  
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//  PART OF THIS FILE AT ALL TIMES.
//-----------------------------------------------------------------------------
// Filename     : axi_perf_mon_v5_0_9_advanced.v
// Version      : v5.0
// Description  : This is the top level wrapper file for the AXI Performance
//                Monitor advanced mode. 
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
// axi_perf_mon_v5_0_9_top.v
//   \-- axi_perf_mon_v5_0_9_advanced.v
//     \-- axi_perf_mon_v5_0_9_axi_interface.v
//     \-- axi_perf_mon_v5_0_9_register_module.v
//             \--axi_perf_mon_v5_0_9_cdc_sync.v
//             \-- axi_perf_mon_v5_0_9_intr_sync.v
//             \--axi_perf_mon_v5_0_9_cdc_sync.v
//      \-- axi_perf_mon_v5_0_9_interrupt_module.v
//      \-- axi_perf_mon_v5_0_9_cdc_sync.v
//          \-- axi_perf_mon_v5_0_9_glbl_clk_cnt.v
//           \-- axi_perf_mon_v5_0_9_counter.v
//      \-- axi_perf_mon_v5_0_9_mon_fifo.v
//           \-- axi_perf_mon_v5_0_9_async_fifo.vhd
//      \-- axi_perf_mon_v5_0_9_metric_calc.v
//            \-- axi_perf_mon_v5_0_9_sync_fifo.vhd
//            \-- axi_perf_mon_v5_0_9_counter.v
//      \-- axi_perf_mon_v5_0_9_metric_counters.v
//            \-- axi_perf_mon_v5_0_9_metric_sel_n_cnt.v 
//            \--axi_perf_mon_v5_0_9_acc_n_incr.v
//               \--axi_perf_mon_v5_0_9_counter.v
//      \-- axi_perf_mon_v5_0_9_samp_intl_cnt.v
//          \-- axi_perf_mon_v5_0_9_counter.v
//      \-- axi_perf_mon_v5_0_9_samp_metrics_data.v
//      \-- axi_perf_mon_v5_0_9_flags_gen.v
//      \-- axi_perf_mon_v5_0_9_strm_fifo_wr_logic.v
//          \-- axi_perf_mon_v5_0_9_counter.v
//      \-- axi_perf_mon_v5_0_9_async_stream_fifo.v
//           \-- axi_perf_mon_v5_0_9_async_fifo.vhd
//---------------------------------------------------------------------------
// Author  :   NLR 
// History :    
// NLR       07/25/2012      First Version
// ^^^^^^
// NLR       12/18/2012      Release of v3_00_a with feature updates
// ^^^^^^
// NLR       03/20/2013      Release of v5_0
// ^^^^^^ 
// NLR       04/15/2013      Added resetting of sampled metric counters with
//                           Control register bit 
// ^^^^^^^
// NLR       06/18/2013      Restructred the code with proper generate statements 
// ^^^^^^^
// NLR       10/02/2013      Added advanced, profile and trace mode supports
// ^^^^^^^                   Metric scaling factor support
//---------------------------------------------------------------------------
`timescale 1ns/1ps
(* DowngradeIPIdentifiedWarnings="yes" *)

module axi_perf_mon_v5_0_9_advanced 
  # (
    parameter C_FAMILY                        = "virtex7",

    //AXI Slave Interface parameters for this core
    parameter C_S_AXI_ADDR_WIDTH              = 16, 
    parameter C_S_AXI_DATA_WIDTH              = 32,
    parameter C_S_AXI_PROTOCOL                = "AXI4LITE",
    parameter C_S_AXI_ID_WIDTH                = 1,
    parameter C_SUPPORT_ID_REFLECTION         = 0,

    //Counter Parameters
    parameter C_NUM_MONITOR_SLOTS             = 1,
    parameter C_ENABLE_EVENT_COUNT            = 1,  //-- enables/disables perf mon counting logic
    parameter C_NUM_OF_COUNTERS               = 10,
    parameter C_METRIC_COUNT_WIDTH            = 32, 
    parameter C_METRIC_COUNT_SCALE            = 1, 
    parameter C_GLOBAL_COUNT_WIDTH            = 32,
    parameter C_HAVE_SAMPLED_METRIC_CNT       = 1,  //-- enable sampled metric counters logic
    parameter C_METRICS_SAMPLE_COUNT_WIDTH    = 32,
    parameter C_AXI4LITE_CORE_CLK_ASYNC       = 1,  //-- disable synchronizers incase its 0 

    //AXI Slot 0 Interface parameters
    parameter C_SLOT_0_AXI_ADDR_WIDTH         = 32,
    parameter C_SLOT_0_AXI_DATA_WIDTH         = 32,
    parameter C_SLOT_0_AXI_ID_WIDTH           = 1,
    parameter C_SLOT_0_AXI_PROTOCOL           = "AXI4",
    parameter C_SLOT_0_AXI_SUB_PROTOCOL       = "AXI4LITE",
    parameter C_SLOT_0_AXIS_TDATA_WIDTH       = 32,
    parameter C_SLOT_0_AXIS_TID_WIDTH         = 1,
    parameter C_SLOT_0_AXIS_TDEST_WIDTH       = 1,
    parameter C_SLOT_0_AXIS_TUSER_WIDTH       = 1,
    parameter C_SLOT_0_FIFO_ENABLE            = 1,

    //AXI Slot 1 Interface parameters
    parameter C_SLOT_1_AXI_ADDR_WIDTH         = 32,
    parameter C_SLOT_1_AXI_DATA_WIDTH         = 32,
    parameter C_SLOT_1_AXI_ID_WIDTH           = 1,
    parameter C_SLOT_1_AXI_PROTOCOL           = "AXI4",
    parameter C_SLOT_1_AXI_SUB_PROTOCOL       = "AXI4LITE",
    parameter C_SLOT_1_AXIS_TDATA_WIDTH       = 32,
    parameter C_SLOT_1_AXIS_TID_WIDTH         = 1,
    parameter C_SLOT_1_AXIS_TDEST_WIDTH       = 1,
    parameter C_SLOT_1_AXIS_TUSER_WIDTH       = 1,
    parameter C_SLOT_1_FIFO_ENABLE            = 1,

    //AXI Slot 2 Interface parameters
    parameter C_SLOT_2_AXI_ADDR_WIDTH         = 32,
    parameter C_SLOT_2_AXI_DATA_WIDTH         = 32,
    parameter C_SLOT_2_AXI_ID_WIDTH           = 1,
    parameter C_SLOT_2_AXI_PROTOCOL           = "AXI4",
    parameter C_SLOT_2_AXI_SUB_PROTOCOL       = "AXI4LITE",
    parameter C_SLOT_2_AXIS_TDATA_WIDTH       = 32,
    parameter C_SLOT_2_AXIS_TID_WIDTH         = 1,
    parameter C_SLOT_2_AXIS_TDEST_WIDTH       = 1,
    parameter C_SLOT_2_AXIS_TUSER_WIDTH       = 1,
    parameter C_SLOT_2_FIFO_ENABLE            = 1,
 
    //AXI Slot 3 Interface parameters
    parameter C_SLOT_3_AXI_ADDR_WIDTH         = 32,
    parameter C_SLOT_3_AXI_DATA_WIDTH         = 32,
    parameter C_SLOT_3_AXI_ID_WIDTH           = 1,
    parameter C_SLOT_3_AXI_PROTOCOL           = "AXI4",
    parameter C_SLOT_3_AXI_SUB_PROTOCOL       = "AXI4LITE",
    parameter C_SLOT_3_AXIS_TDATA_WIDTH       = 32,
    parameter C_SLOT_3_AXIS_TID_WIDTH         = 1,
    parameter C_SLOT_3_AXIS_TDEST_WIDTH       = 1,
    parameter C_SLOT_3_AXIS_TUSER_WIDTH       = 1,
    parameter C_SLOT_3_FIFO_ENABLE            = 1,

    //AXI Slot 4 Interface parameters
    parameter C_SLOT_4_AXI_ADDR_WIDTH         = 32,
    parameter C_SLOT_4_AXI_DATA_WIDTH         = 32,
    parameter C_SLOT_4_AXI_ID_WIDTH           = 1,
    parameter C_SLOT_4_AXI_PROTOCOL           = "AXI4",
    parameter C_SLOT_4_AXI_SUB_PROTOCOL       = "AXI4LITE",
    parameter C_SLOT_4_AXIS_TDATA_WIDTH       = 32,
    parameter C_SLOT_4_AXIS_TID_WIDTH         = 1,
    parameter C_SLOT_4_AXIS_TDEST_WIDTH       = 1,
    parameter C_SLOT_4_AXIS_TUSER_WIDTH       = 1,
    parameter C_SLOT_4_FIFO_ENABLE            = 1,

    //AXI Slot 5 Interface parameters
    parameter C_SLOT_5_AXI_ADDR_WIDTH         = 32,
    parameter C_SLOT_5_AXI_DATA_WIDTH         = 32,
    parameter C_SLOT_5_AXI_ID_WIDTH           = 1,
    parameter C_SLOT_5_AXI_PROTOCOL           = "AXI4",
    parameter C_SLOT_5_AXI_SUB_PROTOCOL       = "AXI4LITE",
    parameter C_SLOT_5_AXIS_TDATA_WIDTH       = 32,
    parameter C_SLOT_5_AXIS_TID_WIDTH         = 1,
    parameter C_SLOT_5_AXIS_TDEST_WIDTH       = 1,
    parameter C_SLOT_5_AXIS_TUSER_WIDTH       = 1,
    parameter C_SLOT_5_FIFO_ENABLE            = 1,

    //AXI Slot 6 Interface parameters
    parameter C_SLOT_6_AXI_ADDR_WIDTH         = 32,
    parameter C_SLOT_6_AXI_DATA_WIDTH         = 32,
    parameter C_SLOT_6_AXI_ID_WIDTH           = 1,
    parameter C_SLOT_6_AXI_PROTOCOL           = "AXI4",
    parameter C_SLOT_6_AXI_SUB_PROTOCOL       = "AXI4LITE",
    parameter C_SLOT_6_AXIS_TDATA_WIDTH       = 32,
    parameter C_SLOT_6_AXIS_TID_WIDTH         = 1,
    parameter C_SLOT_6_AXIS_TDEST_WIDTH       = 1,
    parameter C_SLOT_6_AXIS_TUSER_WIDTH       = 1,
    parameter C_SLOT_6_FIFO_ENABLE            = 1,

    //AXI Slot 7 Interface parameters
    parameter C_SLOT_7_AXI_ADDR_WIDTH         = 32,
    parameter C_SLOT_7_AXI_DATA_WIDTH         = 32,
    parameter C_SLOT_7_AXI_ID_WIDTH           = 1,
    parameter C_SLOT_7_AXI_PROTOCOL           = "AXI4",
    parameter C_SLOT_7_AXI_SUB_PROTOCOL       = "AXI4LITE",
    parameter C_SLOT_7_AXIS_TDATA_WIDTH       = 32,
    parameter C_SLOT_7_AXIS_TID_WIDTH         = 1,
    parameter C_SLOT_7_AXIS_TDEST_WIDTH       = 1,
    parameter C_SLOT_7_AXIS_TUSER_WIDTH       = 1,
    parameter C_SLOT_7_FIFO_ENABLE            = 1,

    // Register all Monitor inputs option
    parameter C_REG_ALL_MONITOR_SIGNALS       = 0,

    // Fifo option for external events
    parameter C_EXT_EVENT0_FIFO_ENABLE        = 1,
    parameter C_EXT_EVENT1_FIFO_ENABLE        = 1,
    parameter C_EXT_EVENT2_FIFO_ENABLE        = 1,
    parameter C_EXT_EVENT3_FIFO_ENABLE        = 1,
    parameter C_EXT_EVENT4_FIFO_ENABLE        = 1,
    parameter C_EXT_EVENT5_FIFO_ENABLE        = 1,
    parameter C_EXT_EVENT6_FIFO_ENABLE        = 1,
    parameter C_EXT_EVENT7_FIFO_ENABLE        = 1,

    //Event Log Parameters
    parameter C_ENABLE_EVENT_LOG              = 0,   //-- enables event logging logic
    parameter C_FIFO_AXIS_DEPTH               = 32,  // AXI Streaming FIFO depth
    parameter C_FIFO_AXIS_TDATA_WIDTH         = 56, // AXI Streaming FIFO width
    parameter C_AXIS_DWIDTH_ROUND_TO_32       = 56, // AXI Streaming FIFO width rounded to next 32bit
    parameter C_FIFO_AXIS_TID_WIDTH           = 1,   // AXI Streaming FIFO ID width
    parameter C_FIFO_AXIS_SYNC                = 0,   // 1=Sync FIFO, 0=ASYNC FIFO
    parameter C_SHOW_AXI_IDS                  = 1,
    parameter C_SHOW_AXI_LEN                  = 1,
    parameter C_SHOW_AXIS_TID                 = 1,
    parameter C_SHOW_AXIS_TDEST               = 1,
    parameter C_SHOW_AXIS_TUSER               = 1,
    parameter COUNTER_LOAD_VALUE              = 32'h00000000,
    parameter C_LOG_DATA_OFFLD                = 0,//0- stream offload,1-Memorymap offload 
    parameter S_AXI_OFFLD_ID_WIDTH            = 1,//offload interface ID width.
    parameter C_EN_TRIGGER                    = 0,//Enable trigger logic
    parameter C_EN_AXI_DEBUG                  = 0 //Enable AXI Debug
        )
    (
    //AXI-Lite Interface   
    input                                    s_axi_aclk,
    input                                    s_axi_aresetn,
    input [15:0]                             s_axi_awaddr,
    input                                    s_axi_awvalid,
    input [C_S_AXI_ID_WIDTH-1:0]             s_axi_awid,     //AXI4 Full Interface support
    output                                   s_axi_awready,
    input [31:0]                             s_axi_wdata,
    input [3:0]                              s_axi_wstrb,
    input                                    s_axi_wvalid,
    output                                   s_axi_wready,
    output [1:0]                             s_axi_bresp,
    output                                   s_axi_bvalid,
    output [C_S_AXI_ID_WIDTH-1:0]            s_axi_bid,      //AXI4 Full Interface support
    input                                    s_axi_bready,
    input  [15:0]                            s_axi_araddr,
    input                                    s_axi_arvalid,
    input [C_S_AXI_ID_WIDTH-1:0]             s_axi_arid,     //AXI4 Full Interface support
    output                                   s_axi_arready,
    output [31:0]                            s_axi_rdata,
    output [1:0]                             s_axi_rresp,
    output                                   s_axi_rvalid,
    output [C_S_AXI_ID_WIDTH-1:0]            s_axi_rid,      //AXI4 Full Interface support
    input                                    s_axi_rready,
  
    // SLOT 0 AXI MM Interface signals
    input                                    slot_0_axi_aclk,
    input                                    slot_0_axi_aresetn,
    input [C_SLOT_0_AXI_ID_WIDTH-1:0]        slot_0_axi_awid,
    input [C_SLOT_0_AXI_ADDR_WIDTH-1:0]      slot_0_axi_awaddr,
    input [2:0]                              slot_0_axi_awprot,
    input [7:0]                              slot_0_axi_awlen,
    input [2:0]                              slot_0_axi_awsize,
    input [1:0]                              slot_0_axi_awburst,
    input [3:0]                              slot_0_axi_awcache,
    input                                    slot_0_axi_awlock,
    input                                    slot_0_axi_awvalid,
    input                                    slot_0_axi_awready,
    input [C_SLOT_0_AXI_DATA_WIDTH-1:0]      slot_0_axi_wdata,
    input [C_SLOT_0_AXI_DATA_WIDTH/8-1:0]    slot_0_axi_wstrb,
    input                                    slot_0_axi_wlast,
    input                                    slot_0_axi_wvalid,
    input                                    slot_0_axi_wready,
    input [C_SLOT_0_AXI_ID_WIDTH-1:0]        slot_0_axi_bid,
    input [1:0]                              slot_0_axi_bresp,
    input                                    slot_0_axi_bvalid,
    input                                    slot_0_axi_bready,
    input [C_SLOT_0_AXI_ID_WIDTH-1:0]        slot_0_axi_arid,
    input [C_SLOT_0_AXI_ADDR_WIDTH-1:0]      slot_0_axi_araddr,
    input [7:0]                              slot_0_axi_arlen,
    input [2:0]                              slot_0_axi_arsize,
    input [1:0]                              slot_0_axi_arburst,
    input [3:0]                              slot_0_axi_arcache,
    input [2:0]                              slot_0_axi_arprot,
    input                                    slot_0_axi_arlock,
    input                                    slot_0_axi_arvalid,
    input                                    slot_0_axi_arready,
    input [C_SLOT_0_AXI_ID_WIDTH-1:0]        slot_0_axi_rid,
    input [C_SLOT_0_AXI_DATA_WIDTH-1:0]      slot_0_axi_rdata,
    input [1:0]                              slot_0_axi_rresp,
    input                                    slot_0_axi_rlast,
    input                                    slot_0_axi_rvalid,
    input                                    slot_0_axi_rready,
  
    //SLOT 0 AXI Streaming Interface
    input                                    slot_0_axis_aclk,
    input                                    slot_0_axis_aresetn,
    input                                    slot_0_axis_tvalid,
    input                                    slot_0_axis_tready,
    input [C_SLOT_0_AXIS_TDATA_WIDTH-1:0]    slot_0_axis_tdata,
    input [C_SLOT_0_AXIS_TDATA_WIDTH/8-1:0]  slot_0_axis_tstrb,
    input [C_SLOT_0_AXIS_TDATA_WIDTH/8-1:0]  slot_0_axis_tkeep,
    input                                    slot_0_axis_tlast,
    input [C_SLOT_0_AXIS_TID_WIDTH-1:0]      slot_0_axis_tid,
    input [C_SLOT_0_AXIS_TDEST_WIDTH-1:0]    slot_0_axis_tdest,
    input [C_SLOT_0_AXIS_TUSER_WIDTH-1:0]    slot_0_axis_tuser,

    //SLOT 0 External Triggers
    input                                    slot_0_ext_trig,
    input                                    slot_0_ext_trig_stop,
  
    // SLOT 1 AXI MM interface signals
    
    input                                    slot_1_axi_aclk,
    input                                    slot_1_axi_aresetn,
    input [C_SLOT_1_AXI_ID_WIDTH-1:0]        slot_1_axi_awid,
    input [C_SLOT_1_AXI_ADDR_WIDTH-1:0]      slot_1_axi_awaddr,
    input [2:0]                              slot_1_axi_awprot,
    input [7:0]                              slot_1_axi_awlen,
    input [2:0]                              slot_1_axi_awsize,
    input [1:0]                              slot_1_axi_awburst,
    input [3:0]                              slot_1_axi_awcache,
    input                                    slot_1_axi_awlock,
    input                                    slot_1_axi_awvalid,
    input                                    slot_1_axi_awready,
    input [C_SLOT_1_AXI_DATA_WIDTH-1:0]      slot_1_axi_wdata,
    input [C_SLOT_1_AXI_DATA_WIDTH/8-1:0]    slot_1_axi_wstrb,
    input                                    slot_1_axi_wlast,
    input                                    slot_1_axi_wvalid,
    input                                    slot_1_axi_wready,
    input [C_SLOT_1_AXI_ID_WIDTH-1:0]        slot_1_axi_bid,
    input [1:0]                              slot_1_axi_bresp,
    input                                    slot_1_axi_bvalid,
    input                                    slot_1_axi_bready,
    input [C_SLOT_1_AXI_ID_WIDTH-1:0]        slot_1_axi_arid,
    input [C_SLOT_1_AXI_ADDR_WIDTH-1:0]      slot_1_axi_araddr,
    input [7:0]                              slot_1_axi_arlen,
    input [2:0]                              slot_1_axi_arsize,
    input [1:0]                              slot_1_axi_arburst,
    input [3:0]                              slot_1_axi_arcache,
    input [2:0]                              slot_1_axi_arprot,
    input                                    slot_1_axi_arlock,
    input                                    slot_1_axi_arvalid,
    input                                    slot_1_axi_arready,
    input [C_SLOT_1_AXI_ID_WIDTH-1:0]        slot_1_axi_rid,
    input [C_SLOT_1_AXI_DATA_WIDTH-1:0]      slot_1_axi_rdata,
    input [1:0]                              slot_1_axi_rresp,
    input                                    slot_1_axi_rlast,
    input                                    slot_1_axi_rvalid,
    input                                    slot_1_axi_rready,
  
    //SLOT 1 AXI Streaming Interface
    input                                    slot_1_axis_aclk,
    input                                    slot_1_axis_aresetn,
    input                                    slot_1_axis_tvalid,
    input                                    slot_1_axis_tready,
    input [C_SLOT_1_AXIS_TDATA_WIDTH-1:0]    slot_1_axis_tdata,
    input [C_SLOT_1_AXIS_TDATA_WIDTH/8-1:0]  slot_1_axis_tstrb,
    input [C_SLOT_1_AXIS_TDATA_WIDTH/8-1:0]  slot_1_axis_tkeep,
    input                                    slot_1_axis_tlast,
    input [C_SLOT_1_AXIS_TID_WIDTH-1:0]      slot_1_axis_tid,
    input [C_SLOT_1_AXIS_TDEST_WIDTH-1:0]    slot_1_axis_tdest,
    input [C_SLOT_1_AXIS_TUSER_WIDTH-1:0]    slot_1_axis_tuser,
  
    //SLOT 1 External Trigger
    input                                    slot_1_ext_trig,
    input                                    slot_1_ext_trig_stop,

    //SLOT 2 AXI MM Interface 
  
    input                                    slot_2_axi_aclk,
    input                                    slot_2_axi_aresetn,
    input [C_SLOT_2_AXI_ID_WIDTH-1:0]        slot_2_axi_awid,
    input [C_SLOT_2_AXI_ADDR_WIDTH-1:0]      slot_2_axi_awaddr,
    input [2:0]                              slot_2_axi_awprot,
    input [7:0]                              slot_2_axi_awlen,
    input [2:0]                              slot_2_axi_awsize,
    input [1:0]                              slot_2_axi_awburst,
    input [3:0]                              slot_2_axi_awcache,
    input                                    slot_2_axi_awlock,
    input                                    slot_2_axi_awvalid,
    input                                    slot_2_axi_awready,
    input [C_SLOT_2_AXI_DATA_WIDTH-1:0]      slot_2_axi_wdata,
    input [C_SLOT_2_AXI_DATA_WIDTH/8-1: 0]   slot_2_axi_wstrb,
    input                                    slot_2_axi_wlast,
    input                                    slot_2_axi_wvalid,
    input                                    slot_2_axi_wready,
    input [C_SLOT_2_AXI_ID_WIDTH-1:0]        slot_2_axi_bid,
    input [1:0]                              slot_2_axi_bresp,
    input                                    slot_2_axi_bvalid,
    input                                    slot_2_axi_bready,
    input [C_SLOT_2_AXI_ID_WIDTH-1:0]        slot_2_axi_arid,
    input [C_SLOT_2_AXI_ADDR_WIDTH-1:0]      slot_2_axi_araddr,
    input [7:0]                              slot_2_axi_arlen,
    input [2:0]                              slot_2_axi_arsize,
    input [1:0]                              slot_2_axi_arburst,
    input [3:0]                              slot_2_axi_arcache,
    input [2:0]                              slot_2_axi_arprot,
    input                                    slot_2_axi_arlock,
    input                                    slot_2_axi_arvalid,
    input                                    slot_2_axi_arready,
    input [C_SLOT_2_AXI_ID_WIDTH-1:0]        slot_2_axi_rid,
    input [C_SLOT_2_AXI_DATA_WIDTH-1:0]      slot_2_axi_rdata,
    input [1:0]                              slot_2_axi_rresp,
    input                                    slot_2_axi_rlast,
    input                                    slot_2_axi_rvalid,
    input                                    slot_2_axi_rready,
  
   //SLOT 2 AXI Streaming Interface
    input                                    slot_2_axis_aclk,
    input                                    slot_2_axis_aresetn,
    input                                    slot_2_axis_tvalid,
    input                                    slot_2_axis_tready,
    input [C_SLOT_2_AXIS_TDATA_WIDTH-1:0]    slot_2_axis_tdata,
    input [C_SLOT_2_AXIS_TDATA_WIDTH/8-1:0]  slot_2_axis_tstrb,
    input [C_SLOT_2_AXIS_TDATA_WIDTH/8-1:0]  slot_2_axis_tkeep,
    input                                    slot_2_axis_tlast,
    input [C_SLOT_2_AXIS_TID_WIDTH-1:0]      slot_2_axis_tid,
    input [C_SLOT_2_AXIS_TDEST_WIDTH-1:0]    slot_2_axis_tdest,
    input [C_SLOT_2_AXIS_TUSER_WIDTH-1:0]    slot_2_axis_tuser,

   //SLOT 2 External Trigger
    input                                    slot_2_ext_trig,
    input                                    slot_2_ext_trig_stop,
  
   //SLOT 3 AXI MM Interface
    input                                    slot_3_axi_aclk,
    input                                    slot_3_axi_aresetn,
    input [C_SLOT_3_AXI_ID_WIDTH-1:0]        slot_3_axi_awid,
    input [C_SLOT_3_AXI_ADDR_WIDTH-1:0]      slot_3_axi_awaddr,
    input [2:0]                              slot_3_axi_awprot,
    input [7:0]                              slot_3_axi_awlen,
    input [2:0]                              slot_3_axi_awsize,
    input [1:0]                              slot_3_axi_awburst,
    input [3:0]                              slot_3_axi_awcache,
    input                                    slot_3_axi_awlock,
    input                                    slot_3_axi_awvalid,
    input                                    slot_3_axi_awready,
    input [C_SLOT_3_AXI_DATA_WIDTH-1:0]      slot_3_axi_wdata,
    input [C_SLOT_3_AXI_DATA_WIDTH/8-1:0]    slot_3_axi_wstrb,
    input                                    slot_3_axi_wlast,
    input                                    slot_3_axi_wvalid,
    input                                    slot_3_axi_wready,
    input [C_SLOT_3_AXI_ID_WIDTH-1:0]        slot_3_axi_bid,
    input [1:0]                              slot_3_axi_bresp,
    input                                    slot_3_axi_bvalid,
    input                                    slot_3_axi_bready,
    input [C_SLOT_3_AXI_ID_WIDTH-1:0]        slot_3_axi_arid,
    input [C_SLOT_3_AXI_ADDR_WIDTH-1:0]      slot_3_axi_araddr,
    input [7:0]                              slot_3_axi_arlen,
    input [2:0]                              slot_3_axi_arsize,
    input [1:0]                              slot_3_axi_arburst,
    input [3:0]                              slot_3_axi_arcache,
    input [2:0]                              slot_3_axi_arprot,
    input                                    slot_3_axi_arlock,
    input                                    slot_3_axi_arvalid,
    input                                    slot_3_axi_arready,
    input [C_SLOT_3_AXI_ID_WIDTH-1:0]        slot_3_axi_rid,
    input [C_SLOT_3_AXI_DATA_WIDTH-1:0]      slot_3_axi_rdata,
    input [1:0]                              slot_3_axi_rresp,
    input                                    slot_3_axi_rlast,
    input                                    slot_3_axi_rvalid,
    input                                    slot_3_axi_rready,
  
    //SLOT 3 AXI Streaming Interface
    input                                    slot_3_axis_aclk,
    input                                    slot_3_axis_aresetn,
    input                                    slot_3_axis_tvalid,
    input                                    slot_3_axis_tready,
    input [C_SLOT_3_AXIS_TDATA_WIDTH-1:0]    slot_3_axis_tdata,
    input [C_SLOT_3_AXIS_TDATA_WIDTH/8-1:0]  slot_3_axis_tstrb,
    input [C_SLOT_3_AXIS_TDATA_WIDTH/8-1:0]  slot_3_axis_tkeep,
    input                                    slot_3_axis_tlast,
    input [C_SLOT_3_AXIS_TID_WIDTH-1:0]      slot_3_axis_tid,
    input [C_SLOT_3_AXIS_TDEST_WIDTH-1:0]    slot_3_axis_tdest,
    input [C_SLOT_3_AXIS_TUSER_WIDTH-1:0]    slot_3_axis_tuser,

    //SLOT 3 External Trigger
    input                                    slot_3_ext_trig,
    input                                    slot_3_ext_trig_stop,
  
    //SLOT 4 AXI MM Interface
    input                                    slot_4_axi_aclk,
    input                                    slot_4_axi_aresetn,
    input [C_SLOT_4_AXI_ID_WIDTH-1:0]        slot_4_axi_awid,
    input [C_SLOT_4_AXI_ADDR_WIDTH-1:0]      slot_4_axi_awaddr,
    input [2:0]                              slot_4_axi_awprot,
    input [7:0]                              slot_4_axi_awlen,
    input [2:0]                              slot_4_axi_awsize,
    input [1:0]                              slot_4_axi_awburst,
    input [3:0]                              slot_4_axi_awcache,
    input                                    slot_4_axi_awlock,
    input                                    slot_4_axi_awvalid,
    input                                    slot_4_axi_awready,
    input [C_SLOT_4_AXI_DATA_WIDTH-1:0]      slot_4_axi_wdata,
    input [C_SLOT_4_AXI_DATA_WIDTH/8-1:0]    slot_4_axi_wstrb,
    input                                    slot_4_axi_wlast,
    input                                    slot_4_axi_wvalid,
    input                                    slot_4_axi_wready,
    input [C_SLOT_4_AXI_ID_WIDTH-1:0]        slot_4_axi_bid,
    input [1:0]                              slot_4_axi_bresp,
    input                                    slot_4_axi_bvalid,
    input                                    slot_4_axi_bready,
    input  [C_SLOT_4_AXI_ID_WIDTH-1:0]       slot_4_axi_arid,
    input  [C_SLOT_4_AXI_ADDR_WIDTH-1:0]     slot_4_axi_araddr,
    input  [7:0]                             slot_4_axi_arlen,
    input  [2:0]                             slot_4_axi_arsize,
    input  [1:0]                             slot_4_axi_arburst,
    input  [3:0]                             slot_4_axi_arcache,
    input  [2:0]                             slot_4_axi_arprot,
    input                                    slot_4_axi_arlock,
    input                                    slot_4_axi_arvalid,
    input                                    slot_4_axi_arready,
    input [C_SLOT_4_AXI_ID_WIDTH-1:0]        slot_4_axi_rid,
    input [C_SLOT_4_AXI_DATA_WIDTH-1:0]      slot_4_axi_rdata,
    input [1:0]                              slot_4_axi_rresp,
    input                                    slot_4_axi_rlast,
    input                                    slot_4_axi_rvalid,
    input                                    slot_4_axi_rready,
  
    //SLOT 4 AXI Streaming Interface
    input                                    slot_4_axis_aclk,
    input                                    slot_4_axis_aresetn,
    input                                    slot_4_axis_tvalid,
    input                                    slot_4_axis_tready,
    input [C_SLOT_4_AXIS_TDATA_WIDTH-1:0]    slot_4_axis_tdata,
    input [C_SLOT_4_AXIS_TDATA_WIDTH/8-1:0]  slot_4_axis_tstrb,
    input [C_SLOT_4_AXIS_TDATA_WIDTH/8-1:0]  slot_4_axis_tkeep,
    input                                    slot_4_axis_tlast,
    input [C_SLOT_4_AXIS_TID_WIDTH-1:0]      slot_4_axis_tid,
    input [C_SLOT_4_AXIS_TDEST_WIDTH-1:0]    slot_4_axis_tdest,
    input [C_SLOT_4_AXIS_TUSER_WIDTH-1:0]    slot_4_axis_tuser,

    //SLOT 4 External Trigger
    input                                    slot_4_ext_trig,
    input                                    slot_4_ext_trig_stop,

    //SLOT 5 AXI MM Interface
  
    input                                    slot_5_axi_aclk,
    input                                    slot_5_axi_aresetn,
    input [C_SLOT_5_AXI_ID_WIDTH-1:0]        slot_5_axi_awid,
    input [C_SLOT_5_AXI_ADDR_WIDTH-1:0]      slot_5_axi_awaddr,
    input [2:0]                              slot_5_axi_awprot,
    input [7:0]                              slot_5_axi_awlen,
    input [2:0]                              slot_5_axi_awsize,
    input [1:0]                              slot_5_axi_awburst,
    input [3:0]                              slot_5_axi_awcache,
    input                                    slot_5_axi_awlock,
    input                                    slot_5_axi_awvalid,
    input                                    slot_5_axi_awready,
    input [C_SLOT_5_AXI_DATA_WIDTH-1:0]      slot_5_axi_wdata,
    input [C_SLOT_5_AXI_DATA_WIDTH/8-1:0]    slot_5_axi_wstrb,
    input                                    slot_5_axi_wlast,
    input                                    slot_5_axi_wvalid,
    input                                    slot_5_axi_wready,
    input [C_SLOT_5_AXI_ID_WIDTH-1:0]        slot_5_axi_bid,
    input [1:0]                              slot_5_axi_bresp,
    input                                    slot_5_axi_bvalid,
    input                                    slot_5_axi_bready,
    input [C_SLOT_5_AXI_ID_WIDTH-1:0]        slot_5_axi_arid,
    input [C_SLOT_5_AXI_ADDR_WIDTH-1:0]      slot_5_axi_araddr,
    input [7:0]                              slot_5_axi_arlen,
    input [2:0]                              slot_5_axi_arsize,
    input [1:0]                              slot_5_axi_arburst,
    input [3:0]                              slot_5_axi_arcache,
    input [2:0]                              slot_5_axi_arprot,
    input                                    slot_5_axi_arlock,
    input                                    slot_5_axi_arvalid,
    input                                    slot_5_axi_arready,
    input [C_SLOT_5_AXI_ID_WIDTH-1:0]        slot_5_axi_rid,
    input [C_SLOT_5_AXI_DATA_WIDTH-1:0]      slot_5_axi_rdata,
    input [1:0]                              slot_5_axi_rresp,
    input                                    slot_5_axi_rlast,
    input                                    slot_5_axi_rvalid,
    input                                    slot_5_axi_rready,
  
    //SLOT 5 AXI Streaming Interface
    input                                    slot_5_axis_aclk,
    input                                    slot_5_axis_aresetn,
    input                                    slot_5_axis_tvalid,
    input                                    slot_5_axis_tready,
    input [C_SLOT_5_AXIS_TDATA_WIDTH-1:0]    slot_5_axis_tdata,
    input [C_SLOT_5_AXIS_TDATA_WIDTH/8-1:0]  slot_5_axis_tstrb,
    input [C_SLOT_5_AXIS_TDATA_WIDTH/8-1:0]  slot_5_axis_tkeep,
    input                                    slot_5_axis_tlast,
    input [C_SLOT_5_AXIS_TID_WIDTH-1:0]      slot_5_axis_tid,
    input [C_SLOT_5_AXIS_TDEST_WIDTH-1:0]    slot_5_axis_tdest,
    input [C_SLOT_5_AXIS_TUSER_WIDTH-1:0]    slot_5_axis_tuser,

    //SLOT 5 External Trigger
    input                                    slot_5_ext_trig,
    input                                    slot_5_ext_trig_stop,
  
    //SLOT 6 AXI MM Interface
    input                                    slot_6_axi_aclk,
    input                                    slot_6_axi_aresetn,
    input [C_SLOT_6_AXI_ID_WIDTH-1:0]        slot_6_axi_awid,
    input [C_SLOT_6_AXI_ADDR_WIDTH-1:0]      slot_6_axi_awaddr,
    input [2:0]                              slot_6_axi_awprot,
    input [7:0]                              slot_6_axi_awlen,
    input [2:0]                              slot_6_axi_awsize,
    input [1:0]                              slot_6_axi_awburst,
    input [3:0]                              slot_6_axi_awcache,
    input                                    slot_6_axi_awlock,
    input                                    slot_6_axi_awvalid,
    input                                    slot_6_axi_awready,
    input [C_SLOT_6_AXI_DATA_WIDTH-1:0]      slot_6_axi_wdata,
    input [C_SLOT_6_AXI_DATA_WIDTH/8-1:0]    slot_6_axi_wstrb,
    input                                    slot_6_axi_wlast,
    input                                    slot_6_axi_wvalid,
    input                                    slot_6_axi_wready,
    input [C_SLOT_6_AXI_ID_WIDTH-1:0]        slot_6_axi_bid,
    input [1:0]                              slot_6_axi_bresp,
    input                                    slot_6_axi_bvalid,
    input                                    slot_6_axi_bready,
    input [C_SLOT_6_AXI_ID_WIDTH-1:0]        slot_6_axi_arid,
    input [C_SLOT_6_AXI_ADDR_WIDTH-1:0]      slot_6_axi_araddr,
    input [7:0]                              slot_6_axi_arlen,
    input [2:0]                              slot_6_axi_arsize,
    input [1:0]                              slot_6_axi_arburst,
    input [3:0]                              slot_6_axi_arcache,
    input [2:0]                              slot_6_axi_arprot,
    input                                    slot_6_axi_arlock,
    input                                    slot_6_axi_arvalid,
    input                                    slot_6_axi_arready,
    input [C_SLOT_6_AXI_ID_WIDTH-1:0]        slot_6_axi_rid,
    input [C_SLOT_6_AXI_DATA_WIDTH-1:0]      slot_6_axi_rdata,
    input [1:0]                              slot_6_axi_rresp,
    input                                    slot_6_axi_rlast,
    input                                    slot_6_axi_rvalid,
    input                                    slot_6_axi_rready,
  
    //SLOT 6 AXI Streaming Interface
    input                                    slot_6_axis_aclk,
    input                                    slot_6_axis_aresetn,
    input                                    slot_6_axis_tvalid,
    input                                    slot_6_axis_tready,
    input [C_SLOT_6_AXIS_TDATA_WIDTH-1:0]    slot_6_axis_tdata,
    input [C_SLOT_6_AXIS_TDATA_WIDTH/8-1:0]  slot_6_axis_tstrb,
    input [C_SLOT_6_AXIS_TDATA_WIDTH/8-1:0]  slot_6_axis_tkeep,
    input                                    slot_6_axis_tlast,
    input [C_SLOT_6_AXIS_TID_WIDTH-1:0]      slot_6_axis_tid,
    input [C_SLOT_6_AXIS_TDEST_WIDTH-1:0]    slot_6_axis_tdest,
    input [C_SLOT_6_AXIS_TUSER_WIDTH-1:0]    slot_6_axis_tuser,

    //SLOT 6 External Trigger
    input                                    slot_6_ext_trig,
    input                                    slot_6_ext_trig_stop,
  
    //SLOT 7 AXI MM Interface
    input                                    slot_7_axi_aclk,
    input                                    slot_7_axi_aresetn,
    input [C_SLOT_7_AXI_ID_WIDTH-1:0]        slot_7_axi_awid,
    input [C_SLOT_7_AXI_ADDR_WIDTH-1:0]      slot_7_axi_awaddr,
    input [2:0]                              slot_7_axi_awprot,
    input [7:0]                              slot_7_axi_awlen,
    input [2:0]                              slot_7_axi_awsize,
    input [1:0]                              slot_7_axi_awburst,
    input [3:0]                              slot_7_axi_awcache,
    input                                    slot_7_axi_awlock,
    input                                    slot_7_axi_awvalid,
    input                                    slot_7_axi_awready,
    input [C_SLOT_7_AXI_DATA_WIDTH-1:0]      slot_7_axi_wdata,
    input [C_SLOT_7_AXI_DATA_WIDTH/8-1:0]    slot_7_axi_wstrb,
    input                                    slot_7_axi_wlast,
    input                                    slot_7_axi_wvalid,
    input                                    slot_7_axi_wready,
    input [C_SLOT_7_AXI_ID_WIDTH-1:0]        slot_7_axi_bid,
    input [1:0]                              slot_7_axi_bresp,
    input                                    slot_7_axi_bvalid,
    input                                    slot_7_axi_bready,
    input [C_SLOT_7_AXI_ID_WIDTH-1:0]        slot_7_axi_arid,
    input [C_SLOT_7_AXI_ADDR_WIDTH-1:0]      slot_7_axi_araddr,
    input [7:0]                              slot_7_axi_arlen,
    input [2:0]                              slot_7_axi_arsize,
    input [1:0]                              slot_7_axi_arburst,
    input [3:0]                              slot_7_axi_arcache,
    input [2:0]                              slot_7_axi_arprot,
    input                                    slot_7_axi_arlock,
    input                                    slot_7_axi_arvalid,
    input                                    slot_7_axi_arready,
    input  [C_SLOT_7_AXI_ID_WIDTH-1:0]       slot_7_axi_rid,
    input  [C_SLOT_7_AXI_DATA_WIDTH-1:0]     slot_7_axi_rdata,
    input  [1:0]                             slot_7_axi_rresp,
    input                                    slot_7_axi_rlast,
    input                                    slot_7_axi_rvalid,
    input                                    slot_7_axi_rready,
  
    //SLOT 7 AXI Streaming Interface
    input                                    slot_7_axis_aclk,
    input                                    slot_7_axis_aresetn,
    input                                    slot_7_axis_tvalid,
    input                                    slot_7_axis_tready,
    input [C_SLOT_7_AXIS_TDATA_WIDTH-1:0]    slot_7_axis_tdata,
    input [C_SLOT_7_AXIS_TDATA_WIDTH/8-1:0]  slot_7_axis_tstrb,
    input [C_SLOT_7_AXIS_TDATA_WIDTH/8-1:0]  slot_7_axis_tkeep,
    input                                    slot_7_axis_tlast,
    input [C_SLOT_7_AXIS_TID_WIDTH-1:0]      slot_7_axis_tid,
    input [C_SLOT_7_AXIS_TDEST_WIDTH-1:0]    slot_7_axis_tdest,
    input [C_SLOT_7_AXIS_TUSER_WIDTH-1:0]    slot_7_axis_tuser,
 
    //SLOT 7 External Trigger
    input                                    slot_7_ext_trig,
    input                                    slot_7_ext_trig_stop,
 
     // External Event 0
    input                                    ext_clk_0,
    input                                    ext_rstn_0,
    input                                    ext_event_0_cnt_start,
    input                                    ext_event_0_cnt_stop,
    input                                    ext_event_0,
  
     // External Event 1
    input                                    ext_clk_1,
    input                                    ext_rstn_1,
    input                                    ext_event_1_cnt_start,
    input                                    ext_event_1_cnt_stop,
    input                                    ext_event_1,

     // External Event 2
    input                                    ext_clk_2,
    input                                    ext_rstn_2,
    input                                    ext_event_2_cnt_start,
    input                                    ext_event_2_cnt_stop,
    input                                    ext_event_2,

     // External Event 3
    input                                    ext_clk_3,
    input                                    ext_rstn_3,
    input                                    ext_event_3_cnt_start,
    input                                    ext_event_3_cnt_stop,
    input                                    ext_event_3,

    // External Event 4
    input                                    ext_clk_4,
    input                                    ext_rstn_4,
    input                                    ext_event_4_cnt_start,
    input                                    ext_event_4_cnt_stop,
    input                                    ext_event_4,

    // External Event 5
    input                                    ext_clk_5,
    input                                    ext_rstn_5,
    input                                    ext_event_5_cnt_start,
    input                                    ext_event_5_cnt_stop,
    input                                    ext_event_5,

    // External Event 6
    input                                    ext_clk_6,
    input                                    ext_rstn_6,
    input                                    ext_event_6_cnt_start,
    input                                    ext_event_6_cnt_stop,
    input                                    ext_event_6,

    // External Event 7
    input                                    ext_clk_7,
    input                                    ext_rstn_7,
    input                                    ext_event_7_cnt_start,
    input                                    ext_event_7_cnt_stop,
    input                                    ext_event_7,
  
     // Capture and Reset events for metric counters
    input                                    capture_event,
    input                                    reset_event,
  
     // Core Clock and Reset signals
    input                                    core_aclk,
    input                                    core_aresetn,
 
     // Event Log streaming interface
    input                                    m_axis_aclk,
    input                                    m_axis_aresetn,
    output [C_FIFO_AXIS_TDATA_WIDTH-1:0]     m_axis_tdata,
    output [C_FIFO_AXIS_TDATA_WIDTH/8-1:0]   m_axis_tstrb,
    output                                   m_axis_tvalid,
    output [C_FIFO_AXIS_TID_WIDTH-1:0]       m_axis_tid,
    input                                    m_axis_tready,
    
     // Event Log 32b memorymap  interface
    input                                    s_axi_offld_aclk,
    input                                    s_axi_offld_aresetn,
    input [31:0]                             s_axi_offld_araddr ,
    input                                    s_axi_offld_arvalid,
    input [7:0]                              s_axi_offld_arlen  ,
    input [S_AXI_OFFLD_ID_WIDTH-1:0]         s_axi_offld_arid   ,    
    output                                   s_axi_offld_arready,
    input                                    s_axi_offld_rready ,
    output [31:0]                            s_axi_offld_rdata  ,
    output [1:0]                             s_axi_offld_rresp  ,
    output                                   s_axi_offld_rvalid ,
    output [S_AXI_OFFLD_ID_WIDTH-1:0]        s_axi_offld_rid    ,      
    output                                   s_axi_offld_rlast  ,      
     // Interrupt to the Processor
    output                                   interrupt,
    input 				                        trigger_in,
    output 				                        trigger_in_ack
);
  

   /*---------------------------------------------------------------------
   -----------------------Parameter declarations-------------------------
   ------------------------------------------------------------------------*/
  localparam RST_ACTIVE = 1'b0;
  localparam C_NUM_INTR_INPUTS = 13; 
  localparam C_SW_SYNC_DATA_WIDTH = 32; 
  localparam C_SLOT_N_FLAG_WIDTH = 7;
 
  localparam C_MON_FIFO_DWIDTH_S0 = (C_SLOT_0_AXI_PROTOCOL == "AXI4") 
             ?(C_SLOT_0_AXI_ID_WIDTH*4 +C_SLOT_0_AXI_ADDR_WIDTH*2 +(C_SLOT_0_AXI_DATA_WIDTH/8)+42)
                                    :((C_SLOT_0_AXIS_TDATA_WIDTH/8)*2 + C_SLOT_0_AXIS_TID_WIDTH
                                     + C_SLOT_0_AXIS_TDEST_WIDTH+C_SLOT_0_AXIS_TUSER_WIDTH+3);
  localparam C_MON_FIFO_DWIDTH_S1 = (C_SLOT_1_AXI_PROTOCOL == "AXI4") 
             ?(C_SLOT_1_AXI_ID_WIDTH*4 +C_SLOT_1_AXI_ADDR_WIDTH*2 +(C_SLOT_1_AXI_DATA_WIDTH/8)+42)
                                    :((C_SLOT_1_AXIS_TDATA_WIDTH/8)*2 + C_SLOT_1_AXIS_TID_WIDTH
                                    +C_SLOT_1_AXIS_TDEST_WIDTH+C_SLOT_1_AXIS_TUSER_WIDTH+3);
  localparam C_MON_FIFO_DWIDTH_S2 = (C_SLOT_2_AXI_PROTOCOL == "AXI4") 
             ?(C_SLOT_2_AXI_ID_WIDTH*4 +C_SLOT_2_AXI_ADDR_WIDTH*2 +(C_SLOT_2_AXI_DATA_WIDTH/8)+42)
                                    :((C_SLOT_2_AXIS_TDATA_WIDTH/8)*2 + C_SLOT_2_AXIS_TID_WIDTH
                                    +C_SLOT_2_AXIS_TDEST_WIDTH+C_SLOT_2_AXIS_TUSER_WIDTH+3);
  localparam C_MON_FIFO_DWIDTH_S3 = (C_SLOT_3_AXI_PROTOCOL == "AXI4") 
             ?C_SLOT_3_AXI_ID_WIDTH*4 +C_SLOT_3_AXI_ADDR_WIDTH*2 +(C_SLOT_3_AXI_DATA_WIDTH/8)+42
                                    :(C_SLOT_3_AXIS_TDATA_WIDTH/8)*2 + C_SLOT_3_AXIS_TID_WIDTH
                                    +C_SLOT_3_AXIS_TDEST_WIDTH + C_SLOT_3_AXIS_TUSER_WIDTH+3;
  localparam C_MON_FIFO_DWIDTH_S4 = (C_SLOT_4_AXI_PROTOCOL == "AXI4") 
            ?(C_SLOT_4_AXI_ID_WIDTH*4 +C_SLOT_4_AXI_ADDR_WIDTH*2 +(C_SLOT_4_AXI_DATA_WIDTH/8)+42)
                                    :((C_SLOT_4_AXIS_TDATA_WIDTH/8)*2 + C_SLOT_4_AXIS_TID_WIDTH
                                    + C_SLOT_4_AXIS_TDEST_WIDTH+C_SLOT_4_AXIS_TUSER_WIDTH+3);
  localparam C_MON_FIFO_DWIDTH_S5 = (C_SLOT_5_AXI_PROTOCOL == "AXI4") 
            ?(C_SLOT_5_AXI_ID_WIDTH*4 +C_SLOT_5_AXI_ADDR_WIDTH*2 +(C_SLOT_5_AXI_DATA_WIDTH/8)+42)
                                    :((C_SLOT_5_AXIS_TDATA_WIDTH/8)*2 + C_SLOT_5_AXIS_TID_WIDTH
                                    +C_SLOT_5_AXIS_TDEST_WIDTH+C_SLOT_5_AXIS_TUSER_WIDTH+3);
  localparam C_MON_FIFO_DWIDTH_S6 = (C_SLOT_6_AXI_PROTOCOL == "AXI4") 
           ?(C_SLOT_6_AXI_ID_WIDTH*4 +C_SLOT_6_AXI_ADDR_WIDTH*2 +(C_SLOT_6_AXI_DATA_WIDTH/8)+42)
                                    :((C_SLOT_6_AXIS_TDATA_WIDTH/8)*2 + C_SLOT_6_AXIS_TID_WIDTH
                                    +C_SLOT_6_AXIS_TDEST_WIDTH+C_SLOT_6_AXIS_TUSER_WIDTH+3);
  localparam C_MON_FIFO_DWIDTH_S7 = (C_SLOT_7_AXI_PROTOCOL == "AXI4") 
           ?C_SLOT_7_AXI_ID_WIDTH*4 +C_SLOT_7_AXI_ADDR_WIDTH*2 +(C_SLOT_7_AXI_DATA_WIDTH/8)+42
                                    :(C_SLOT_7_AXIS_TDATA_WIDTH/8)*2 + C_SLOT_7_AXIS_TID_WIDTH
                                    +C_SLOT_7_AXIS_TDEST_WIDTH + C_SLOT_7_AXIS_TUSER_WIDTH+3;
  
  //-- Flag widths for each monitor slot  
  localparam C_SLOT_0_FLAG_WIDTH = (C_SLOT_0_AXI_PROTOCOL == "AXI4") ? 7 : 2;
  localparam C_SLOT_1_FLAG_WIDTH = (C_SLOT_1_AXI_PROTOCOL == "AXI4") ? 7 : 2;
  localparam C_SLOT_2_FLAG_WIDTH = (C_SLOT_2_AXI_PROTOCOL == "AXI4") ? 7 : 2;
  localparam C_SLOT_3_FLAG_WIDTH = (C_SLOT_3_AXI_PROTOCOL == "AXI4") ? 7 : 2;
  localparam C_SLOT_4_FLAG_WIDTH = (C_SLOT_4_AXI_PROTOCOL == "AXI4") ? 7 : 2;
  localparam C_SLOT_5_FLAG_WIDTH = (C_SLOT_5_AXI_PROTOCOL == "AXI4") ? 7 : 2;
  localparam C_SLOT_6_FLAG_WIDTH = (C_SLOT_6_AXI_PROTOCOL == "AXI4") ? 7 : 2;
  localparam C_SLOT_7_FLAG_WIDTH = (C_SLOT_7_AXI_PROTOCOL == "AXI4") ? 7 : 2;

  //-- Log Data widths for each monitor slot  
   localparam C_SLOT_0_LOG_DATA_WIDTH = (C_SLOT_0_AXI_PROTOCOL == "AXI4")? ((C_EN_AXI_DEBUG) ? (C_SLOT_0_AXI_ADDR_WIDTH*2 +16+4+4) : ((4*C_SLOT_0_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN))): ((C_SLOT_0_AXIS_TID_WIDTH * C_SHOW_AXIS_TID) + (C_SLOT_0_AXIS_TDEST_WIDTH*C_SHOW_AXIS_TDEST) + (C_SLOT_0_AXIS_TUSER_WIDTH*C_SHOW_AXIS_TUSER));  
  localparam C_SLOT_1_LOG_DATA_WIDTH = (C_SLOT_0_AXI_PROTOCOL == "AXI4")? ((C_EN_AXI_DEBUG) ? (C_SLOT_1_AXI_ADDR_WIDTH*2 +16+4+4) : ((4*C_SLOT_1_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN))) : ((C_SLOT_1_AXIS_TID_WIDTH*C_SHOW_AXIS_TID) + (C_SLOT_1_AXIS_TDEST_WIDTH*C_SHOW_AXIS_TDEST) + (C_SLOT_1_AXIS_TUSER_WIDTH*C_SHOW_AXIS_TUSER));  
  localparam C_SLOT_2_LOG_DATA_WIDTH = (C_SLOT_0_AXI_PROTOCOL == "AXI4")? ((C_EN_AXI_DEBUG) ? (C_SLOT_2_AXI_ADDR_WIDTH*2 +16+4+4) : ((4*C_SLOT_2_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN))) : ((C_SLOT_2_AXIS_TID_WIDTH*C_SHOW_AXIS_TID) + (C_SLOT_2_AXIS_TDEST_WIDTH*C_SHOW_AXIS_TDEST) + (C_SLOT_2_AXIS_TUSER_WIDTH*C_SHOW_AXIS_TUSER));  
  localparam C_SLOT_3_LOG_DATA_WIDTH = (C_SLOT_0_AXI_PROTOCOL == "AXI4")? ((C_EN_AXI_DEBUG) ? (C_SLOT_3_AXI_ADDR_WIDTH*2 +16+4+4) : ((4*C_SLOT_3_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN))) : (C_SLOT_3_AXIS_TID_WIDTH*C_SHOW_AXIS_TID  + C_SLOT_3_AXIS_TDEST_WIDTH*C_SHOW_AXIS_TDEST + C_SLOT_3_AXIS_TUSER_WIDTH*C_SHOW_AXIS_TUSER);  
  localparam C_SLOT_4_LOG_DATA_WIDTH = (C_SLOT_0_AXI_PROTOCOL == "AXI4")? ((C_EN_AXI_DEBUG) ? (C_SLOT_4_AXI_ADDR_WIDTH*2 +16+4+4) : ((4*C_SLOT_4_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN))) : ((C_SLOT_4_AXIS_TID_WIDTH*C_SHOW_AXIS_TID)  + (C_SLOT_4_AXIS_TDEST_WIDTH*C_SHOW_AXIS_TDEST) + (C_SLOT_4_AXIS_TUSER_WIDTH*C_SHOW_AXIS_TUSER));  
  localparam C_SLOT_5_LOG_DATA_WIDTH = (C_SLOT_0_AXI_PROTOCOL == "AXI4")? ((C_EN_AXI_DEBUG) ? (C_SLOT_5_AXI_ADDR_WIDTH*2 +16+4+4) : ((4*C_SLOT_5_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN))) : ((C_SLOT_5_AXIS_TID_WIDTH*C_SHOW_AXIS_TID) + (C_SLOT_5_AXIS_TDEST_WIDTH*C_SHOW_AXIS_TDEST) +(C_SLOT_5_AXIS_TUSER_WIDTH*C_SHOW_AXIS_TUSER));  
  //localparam C_SLOT_6_LOG_DATA_WIDTH = (4*C_SLOT_6_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN);  
  //localparam C_SLOT_7_LOG_DATA_WIDTH = (4*C_SLOT_7_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN);  

//  localparam C_SLOT_0_LOG_DATA_WIDTH = (C_SLOT_0_AXI_PROTOCOL == "AXI4")?  
//                                       ((4*C_SLOT_0_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN)): 
//         ((C_SLOT_0_AXIS_TID_WIDTH * C_SHOW_AXIS_TID) + (C_SLOT_0_AXIS_TDEST_WIDTH*C_SHOW_AXIS_TDEST) + 
//         (C_SLOT_0_AXIS_TUSER_WIDTH*C_SHOW_AXIS_TUSER));
//                                       
//  localparam C_SLOT_1_LOG_DATA_WIDTH = (C_SLOT_1_AXI_PROTOCOL == "AXI4")? 
//                                       ((4*C_SLOT_1_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN)): 
//          ((C_SLOT_1_AXIS_TID_WIDTH*C_SHOW_AXIS_TID) + (C_SLOT_1_AXIS_TDEST_WIDTH*C_SHOW_AXIS_TDEST) + 
//          (C_SLOT_1_AXIS_TUSER_WIDTH*C_SHOW_AXIS_TUSER));
//
//  localparam C_SLOT_2_LOG_DATA_WIDTH = (C_SLOT_2_AXI_PROTOCOL == "AXI4")?  
//                                       ((4*C_SLOT_2_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN)):
//          ((C_SLOT_2_AXIS_TID_WIDTH*C_SHOW_AXIS_TID) + (C_SLOT_2_AXIS_TDEST_WIDTH*C_SHOW_AXIS_TDEST) + 
//          (C_SLOT_2_AXIS_TUSER_WIDTH*C_SHOW_AXIS_TUSER));
//
//  localparam C_SLOT_3_LOG_DATA_WIDTH = (C_SLOT_3_AXI_PROTOCOL == "AXI4")?  
//                                       ((4*C_SLOT_3_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN)):
//          (C_SLOT_3_AXIS_TID_WIDTH*C_SHOW_AXIS_TID  + C_SLOT_3_AXIS_TDEST_WIDTH*C_SHOW_AXIS_TDEST + 
//          C_SLOT_3_AXIS_TUSER_WIDTH*C_SHOW_AXIS_TUSER);
// 
//  localparam C_SLOT_4_LOG_DATA_WIDTH = (C_SLOT_4_AXI_PROTOCOL == "AXI4")?  
//                                       ((4*C_SLOT_4_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN)):
//         ((C_SLOT_4_AXIS_TID_WIDTH*C_SHOW_AXIS_TID)  + (C_SLOT_4_AXIS_TDEST_WIDTH*C_SHOW_AXIS_TDEST) + 
//         (C_SLOT_4_AXIS_TUSER_WIDTH*C_SHOW_AXIS_TUSER));
//
//  localparam C_SLOT_5_LOG_DATA_WIDTH = (C_SLOT_5_AXI_PROTOCOL == "AXI4")?  
//                                       ((4*C_SLOT_5_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN)):
//         ((C_SLOT_5_AXIS_TID_WIDTH*C_SHOW_AXIS_TID) + (C_SLOT_5_AXIS_TDEST_WIDTH*C_SHOW_AXIS_TDEST) + 
//         (C_SLOT_5_AXIS_TUSER_WIDTH*C_SHOW_AXIS_TUSER));
// 
 localparam C_SLOT_6_LOG_DATA_WIDTH = (C_SLOT_6_AXI_PROTOCOL == "AXI4")  
                                       ? ((4*C_SLOT_6_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN)):
         ((C_SLOT_6_AXIS_TID_WIDTH*C_SHOW_AXIS_TID)  + (C_SLOT_6_AXIS_TDEST_WIDTH*C_SHOW_AXIS_TDEST) + 
         (C_SLOT_6_AXIS_TUSER_WIDTH*C_SHOW_AXIS_TUSER));
                                        
 localparam C_SLOT_7_LOG_DATA_WIDTH = (C_SLOT_7_AXI_PROTOCOL == "AXI4")  
                                       ? ((4*C_SLOT_7_AXI_ID_WIDTH*C_SHOW_AXI_IDS) + (16*C_SHOW_AXI_LEN)):
         ((C_SLOT_7_AXIS_TID_WIDTH*C_SHOW_AXIS_TID)  + (C_SLOT_7_AXIS_TDEST_WIDTH*C_SHOW_AXIS_TDEST) + 
         (C_SLOT_7_AXIS_TUSER_WIDTH*C_SHOW_AXIS_TUSER));
 
  localparam C_SLOT_0_LOG_WIDTH = C_SLOT_0_LOG_DATA_WIDTH + C_SLOT_0_FLAG_WIDTH;
  localparam C_SLOT_1_LOG_WIDTH = C_SLOT_1_LOG_DATA_WIDTH + C_SLOT_1_FLAG_WIDTH;
  localparam C_SLOT_2_LOG_WIDTH = C_SLOT_2_LOG_DATA_WIDTH + C_SLOT_2_FLAG_WIDTH;
  localparam C_SLOT_3_LOG_WIDTH = C_SLOT_3_LOG_DATA_WIDTH + C_SLOT_3_FLAG_WIDTH;
  localparam C_SLOT_4_LOG_WIDTH = C_SLOT_4_LOG_DATA_WIDTH + C_SLOT_4_FLAG_WIDTH;
  localparam C_SLOT_5_LOG_WIDTH = C_SLOT_5_LOG_DATA_WIDTH + C_SLOT_5_FLAG_WIDTH;
  localparam C_SLOT_6_LOG_WIDTH = C_SLOT_6_LOG_DATA_WIDTH + C_SLOT_6_FLAG_WIDTH;
  localparam C_SLOT_7_LOG_WIDTH = C_SLOT_7_LOG_DATA_WIDTH + C_SLOT_7_FLAG_WIDTH;
  
  localparam C_MAX_OUTSTAND_DEPTH = 32;

   /*---------------------------------------------------------------------
   -----------------------wire/connection declarations-------------------------
   ------------------------------------------------------------------------*/
  wire  [(C_S_AXI_ADDR_WIDTH - 1):0]   Bus2IP_Addr          ;
  wire  [(C_S_AXI_DATA_WIDTH - 1):0]   Bus2IP_Data          ;
  wire  [(C_S_AXI_DATA_WIDTH/8 - 1):0] Bus2IP_BE            ;
  wire                                 Bus2IP_Burst         ;
  wire                                 Bus2IP_RdCE          ;
  wire                                 Bus2IP_WrCE          ;
  wire  [(C_S_AXI_DATA_WIDTH - 1):0]   IP2Bus_Data          ;
  wire                                 IP2Bus_DataValid     ;
  wire                                 IP2Bus_Error         ;
  wire  [C_GLOBAL_COUNT_WIDTH-1:0]     Global_Clk_Cnt       ;
  wire  [(C_METRICS_SAMPLE_COUNT_WIDTH - 1):0] Sample_Interval;    
  wire  [(C_METRICS_SAMPLE_COUNT_WIDTH - 1):0] Sample_Interval_Cnt;    
  wire                                 Interval_Cnt_En      ;
  wire                                 Interval_Cnt_Ld      ;
  wire                                 Sample_Interval_Cnt_Lapse      ;
  wire                                 Reset_On_Sample_Int_Lapse;
  wire                                 Global_Intr_En       ;
  wire                                 Intr_Reg_IER_Wr_En   ;
  wire                                 Intr_Reg_ISR_Wr_En   ;
  wire [(C_NUM_INTR_INPUTS - 1):0]     Intr_Reg_IER         ;   
  wire [(C_NUM_INTR_INPUTS - 1):0]     Intr_Reg_ISR         ;    
  wire                                 eventlog_rd_clk         ;    
  wire                                 eventlog_rd_rstn         ;    
  wire [31:0]                          eventlog_cur_cnt         ;    
  wire [7:0]                           Metric_Sel_0;    
  wire [7:0]                           Metric_Sel_1;    
  wire [7:0]                           Metric_Sel_2;    
  wire [7:0]                           Metric_Sel_3;    
  wire [7:0]                           Metric_Sel_4;    
  wire [7:0]                           Metric_Sel_5;    
  wire [7:0]                           Metric_Sel_6;    
  wire [7:0]                           Metric_Sel_7;    
  wire [7:0]                           Metric_Sel_8;    
  wire [7:0]                           Metric_Sel_9;    
  wire [31:0]                          Metric_Cnt_0;    
  wire [31:0]                          Metric_Cnt_1;    
  wire [31:0]                          Metric_Cnt_2;    
  wire [31:0]                          Metric_Cnt_3;    
  wire [31:0]                          Metric_Cnt_4;    
  wire [31:0]                          Metric_Cnt_5;    
  wire [31:0]                          Metric_Cnt_6;    
  wire [31:0]                          Metric_Cnt_7;    
  wire [31:0]                          Metric_Cnt_8;    
  wire [31:0]                          Metric_Cnt_9;    
  wire [31:0]                          Incrementer_0;    
  wire [31:0]                          Incrementer_1;    
  wire [31:0]                          Incrementer_2;    
  wire [31:0]                          Incrementer_3;    
  wire [31:0]                          Incrementer_4;    
  wire [31:0]                          Incrementer_5;    
  wire [31:0]                          Incrementer_6;    
  wire [31:0]                          Incrementer_7;    
  wire [31:0]                          Incrementer_8;    
  wire [31:0]                          Incrementer_9;    
  wire [31:0]                          Samp_Metric_Cnt_0;    
  wire [31:0]                          Samp_Metric_Cnt_1;    
  wire [31:0]                          Samp_Metric_Cnt_2;    
  wire [31:0]                          Samp_Metric_Cnt_3;    
  wire [31:0]                          Samp_Metric_Cnt_4;    
  wire [31:0]                          Samp_Metric_Cnt_5;    
  wire [31:0]                          Samp_Metric_Cnt_6;    
  wire [31:0]                          Samp_Metric_Cnt_7;    
  wire [31:0]                          Samp_Metric_Cnt_8;    
  wire [31:0]                          Samp_Metric_Cnt_9;    
  wire [31:0]                          Samp_Incrementer_0;    
  wire [31:0]                          Samp_Incrementer_1;    
  wire [31:0]                          Samp_Incrementer_2;    
  wire [31:0]                          Samp_Incrementer_3;    
  wire [31:0]                          Samp_Incrementer_4;    
  wire [31:0]                          Samp_Incrementer_5;    
  wire [31:0]                          Samp_Incrementer_6;    
  wire [31:0]                          Samp_Incrementer_7;    
  wire [31:0]                          Samp_Incrementer_8;    
  wire [31:0]                          Samp_Incrementer_9;    
  wire [31:0]                          Range_Reg_0;    
  wire [31:0]                          Range_Reg_1;    
  wire [31:0]                          Range_Reg_2;    
  wire [31:0]                          Range_Reg_3;    
  wire [31:0]                          Range_Reg_4;    
  wire [31:0]                          Range_Reg_5;    
  wire [31:0]                          Range_Reg_6;    
  wire [31:0]                          Range_Reg_7;    
  wire [31:0]                          Range_Reg_8;    
  wire [31:0]                          Range_Reg_9;    
  wire [6:0]                           Flag_Enable_Reg;    
  wire                                 SW_Data_Log_En;    
  wire [C_SW_SYNC_DATA_WIDTH-1:0]      SW_Data;    
  wire                                 SW_Data_Wr_En;    
  wire                                 Streaming_FIFO_Reset;
  wire                                 Event_Log_En;
  wire                                 Count_Event_Log_En;
  wire                                 Metrics_Cnt_En;
  wire                                 Metrics_Cnt_Reset;
  wire                                 Global_Clk_Cnt_OF    ;
  wire                                 Global_Clk_Cnt_En    ;
  wire                                 Global_Clk_Cnt_Reset ;
  wire  [10:0]                         Control_Bits_sync  ;
  wire [(C_NUM_INTR_INPUTS - 1):0]     Intr_In             ;    
  wire [(C_NUM_INTR_INPUTS - 1):0]     Intr_In_sync        ;    

  wire  [C_SLOT_0_LOG_WIDTH-1:0]       Slot_0_Log;
  wire  [C_SLOT_1_LOG_WIDTH-1:0]       Slot_1_Log;
  wire  [C_SLOT_2_LOG_WIDTH-1:0]       Slot_2_Log;
  wire  [C_SLOT_3_LOG_WIDTH-1:0]       Slot_3_Log;
  wire  [C_SLOT_4_LOG_WIDTH-1:0]       Slot_4_Log;
  wire  [C_SLOT_5_LOG_WIDTH-1:0]       Slot_5_Log;
  wire  [C_SLOT_6_LOG_WIDTH-1:0]       Slot_6_Log;
  wire  [C_SLOT_7_LOG_WIDTH-1:0]       Slot_7_Log;
  // Start and End point marked data
  wire 	  Slot_0_Log_En_Marked;
  wire [C_SLOT_0_LOG_WIDTH-1:0] Slot_0_Log_Marked;
  wire 	  Slot_1_Log_En_Marked;
  wire [C_SLOT_1_LOG_WIDTH-1:0] Slot_1_Log_Marked;
  wire 	  Slot_2_Log_En_Marked;
  wire [C_SLOT_2_LOG_WIDTH-1:0] Slot_2_Log_Marked;
  wire 	  Slot_3_Log_En_Marked;
  wire [C_SLOT_3_LOG_WIDTH-1:0] Slot_3_Log_Marked;
  wire 	  Slot_4_Log_En_Marked;
  wire [C_SLOT_4_LOG_WIDTH-1:0] Slot_4_Log_Marked;
  wire 	  Slot_5_Log_En_Marked;
  wire [C_SLOT_5_LOG_WIDTH-1:0] Slot_5_Log_Marked;

  // Streaming FIFO connections
  wire                                 Streaming_Fifo_Full   ;
  reg                                  Streaming_Fifo_Full_D1;
  wire                                 Streaming_Fifo_Full_Edge;
  wire                                 Streaming_Fifo_Empty  ;
  wire                                 Streaming_Fifo_Wr_En  ;
  wire  [C_FIFO_AXIS_TDATA_WIDTH-1:0]  Streaming_Fifo_Wr_Data;

  // Event Monitor Fifo connections
  wire [2:0]                           Ext_Event0_Data_In;
  wire [2:0]                           Ext_Event1_Data_In;
  wire [2:0]                           Ext_Event2_Data_In;
  wire [2:0]                           Ext_Event3_Data_In;
  wire [2:0]                           Ext_Event4_Data_In;
  wire [2:0]                           Ext_Event5_Data_In;
  wire [2:0]                           Ext_Event6_Data_In;
  wire [2:0]                           Ext_Event7_Data_In;
  wire [2:0]                           Ext_Event0_Sync_Data_Out;
  wire                                 Ext_Event0_Sync_Data_Valid;
  wire [2:0]                           Ext_Event1_Sync_Data_Out;
  wire                                 Ext_Event1_Sync_Data_Valid;
  wire [2:0]                           Ext_Event2_Sync_Data_Out;
  wire                                 Ext_Event2_Sync_Data_Valid;
  wire [2:0]                           Ext_Event3_Sync_Data_Out;
  wire                                 Ext_Event3_Sync_Data_Valid;
  wire [2:0]                           Ext_Event4_Sync_Data_Out;
  wire                                 Ext_Event4_Sync_Data_Valid;
  wire [2:0]                           Ext_Event5_Sync_Data_Out;
  wire                                 Ext_Event5_Sync_Data_Valid;
  wire [2:0]                           Ext_Event6_Sync_Data_Out;
  wire                                 Ext_Event6_Sync_Data_Valid;
  wire [2:0]                           Ext_Event7_Sync_Data_Out;
  wire                                 Ext_Event7_Sync_Data_Valid;
  
  wire                                 SLOT_0_clk;
  wire                                 SLOT_0_Arst_n;
  wire [C_MON_FIFO_DWIDTH_S0-1:0]      Slot_0_Data_In;
  wire [C_MON_FIFO_DWIDTH_S0-1:0]      Slot_0_Sync_Data_Out;
  wire                                 Slot_0_Sync_Data_Valid;
  wire                                 SLOT_1_clk;
  wire                                 SLOT_1_Arst_n;
  wire [C_MON_FIFO_DWIDTH_S1-1:0]      Slot_1_Data_In;
  wire [C_MON_FIFO_DWIDTH_S1-1:0]      Slot_1_Sync_Data_Out;
  wire                                 Slot_1_Sync_Data_Valid;
  wire                                 SLOT_2_clk;
  wire                                 SLOT_2_Arst_n;
  wire [C_MON_FIFO_DWIDTH_S2-1:0]      Slot_2_Data_In;
  wire [C_MON_FIFO_DWIDTH_S2-1:0]      Slot_2_Sync_Data_Out;
  wire                                 Slot_2_Sync_Data_Valid;
  wire                                 SLOT_3_clk;
  wire                                 SLOT_3_Arst_n;
  wire [C_MON_FIFO_DWIDTH_S3-1:0]      Slot_3_Data_In;
  wire [C_MON_FIFO_DWIDTH_S3-1:0]      Slot_3_Sync_Data_Out;
  wire                                 Slot_3_Sync_Data_Valid;
  wire                                 SLOT_4_clk;
  wire                                 SLOT_4_Arst_n;
  wire [C_MON_FIFO_DWIDTH_S4-1:0]      Slot_4_Data_In;
  wire [C_MON_FIFO_DWIDTH_S4-1:0]      Slot_4_Sync_Data_Out;
  wire                                 Slot_4_Sync_Data_Valid;
  wire                                 SLOT_5_clk;
  wire                                 SLOT_5_Arst_n;
  wire [C_MON_FIFO_DWIDTH_S5-1:0]      Slot_5_Data_In;
  wire [C_MON_FIFO_DWIDTH_S5-1:0]      Slot_5_Sync_Data_Out;
  wire                                 Slot_5_Sync_Data_Valid;
  wire                                 SLOT_6_clk;
  wire                                 SLOT_6_Arst_n;
  wire [C_MON_FIFO_DWIDTH_S6-1:0]      Slot_6_Data_In;
  wire [C_MON_FIFO_DWIDTH_S6-1:0]      Slot_6_Sync_Data_Out;
  wire                                 Slot_6_Sync_Data_Valid;
  wire                                 SLOT_7_clk;
  wire                                 SLOT_7_Arst_n;
  wire [C_MON_FIFO_DWIDTH_S7-1:0]      Slot_7_Data_In;
  wire [C_MON_FIFO_DWIDTH_S7-1:0]      Slot_7_Sync_Data_Out;
  wire                                 Slot_7_Sync_Data_Valid;
  //Metric counter connections 
  wire                                 Metrics_Cnt_En_sync       ; 
  wire                                 Metrics_Cnt_Reset_sync    ; 
  wire                                 Event_Log_En_sync         ; 
  wire                                 Global_Clk_Cnt_En_sync    ; 
  wire                                 Global_Clk_Cnt_Reset_sync ; 
  wire                                 Streaming_FIFO_Reset_sync ; 
  wire                                 Interval_Cnt_Ld_sync ; 
  wire                                 Interval_Cnt_En_sync ; 
  wire                                 Reset_On_Sample_Int_Lapse_sync ; 
  wire                                 Global_Clk_Cnt_Ovf_En_sync;
  wire                                 Sample_Metric_Cnt_Ovf_En_sync;

  // 8 monitor slots metric count enables

  wire [C_NUM_MONITOR_SLOTS-1:0]       Wtrans_Cnt_En;
  wire [C_NUM_MONITOR_SLOTS-1:0]       Rtrans_Cnt_En;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S0_Write_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S1_Write_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S2_Write_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S3_Write_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S4_Write_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S5_Write_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S6_Write_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S7_Write_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S0_Read_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S1_Read_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S2_Read_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S3_Read_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S4_Read_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S5_Read_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S6_Read_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S7_Read_Byte_Cnt;
  wire [C_NUM_MONITOR_SLOTS-1:0]       Write_Beat_Cnt_En;
  wire [C_NUM_MONITOR_SLOTS-1:0]       Read_Beat_Cnt_En;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S0_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S1_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S2_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S3_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S4_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S5_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S6_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S7_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S0_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S1_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S2_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S3_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S4_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S5_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S6_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S7_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S0_Write_Beat_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S1_Write_Beat_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S2_Write_Beat_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S3_Write_Beat_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S4_Write_Beat_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S5_Write_Beat_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S6_Write_Beat_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S7_Write_Beat_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S0_Slv_Wr_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S1_Slv_Wr_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S2_Slv_Wr_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S3_Slv_Wr_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S4_Slv_Wr_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S5_Slv_Wr_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S6_Slv_Wr_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S7_Slv_Wr_Idle_Cnt;
  wire [C_NUM_MONITOR_SLOTS-1:0]       Read_Latency_En;
  wire [C_NUM_MONITOR_SLOTS-1:0]       Write_Latency_En;
  wire [C_NUM_MONITOR_SLOTS-1:0]       Slv_Wr_Idle_Cnt_En;        
  wire [C_NUM_MONITOR_SLOTS-1:0]       Mst_Rd_Idle_Cnt_En;        
  wire [C_NUM_MONITOR_SLOTS-1:0]       Num_BValids_En;       
  wire [C_NUM_MONITOR_SLOTS-1:0]       Num_WLasts_En;             
  wire [C_NUM_MONITOR_SLOTS-1:0]       Num_RLasts_En;      
  //AXI Streaming metrics
  wire [C_NUM_MONITOR_SLOTS-1:0]       S_Transfer_Cnt_En;
  wire [C_NUM_MONITOR_SLOTS-1:0]       S_Packet_Cnt_En;  
  wire [C_METRIC_COUNT_WIDTH-1:0]      S0_S_Data_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S1_S_Data_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S2_S_Data_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S3_S_Data_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S4_S_Data_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S5_S_Data_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S6_S_Data_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S7_S_Data_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S0_S_Position_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S1_S_Position_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S2_S_Position_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S3_S_Position_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S4_S_Position_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S5_S_Position_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S6_S_Position_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S7_S_Position_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S0_S_Null_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S1_S_Null_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S2_S_Null_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S3_S_Null_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S4_S_Null_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S5_S_Null_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S6_S_Null_Byte_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S7_S_Null_Byte_Cnt;
  wire [C_NUM_MONITOR_SLOTS-1:0]       S_Slv_Idle_Cnt_En;
  wire [C_NUM_MONITOR_SLOTS-1:0]       S_Mst_Idle_Cnt_En;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S0_Slv_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S1_Slv_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S2_Slv_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S3_Slv_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S4_Slv_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S5_Slv_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S6_Slv_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S7_Slv_Idle_Cnt;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S0_Max_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S1_Max_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S2_Max_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S3_Max_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S4_Max_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S5_Max_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S6_Max_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S7_Max_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S0_Min_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S1_Min_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S2_Min_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S3_Min_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S4_Min_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S5_Min_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S6_Min_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S7_Min_Write_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S0_Max_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S1_Max_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S2_Max_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S3_Max_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S4_Max_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S5_Max_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S6_Max_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S7_Max_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S0_Min_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S1_Min_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S2_Min_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S3_Min_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S4_Min_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S5_Min_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S6_Min_Read_Latency;
  wire [C_METRIC_COUNT_WIDTH-1:0]      S7_Min_Read_Latency;

  //External Events
  wire [C_NUM_MONITOR_SLOTS-1:0]       External_Event_Cnt_En;
  wire [2:0]                           Ext_Event0_Flags;
  wire [2:0]                           Ext_Event1_Flags;
  wire [2:0]                           Ext_Event2_Flags;
  wire [2:0]                           Ext_Event3_Flags;
  wire [2:0]                           Ext_Event4_Flags;
  wire [2:0]                           Ext_Event5_Flags;
  wire [2:0]                           Ext_Event6_Flags;
  wire [2:0]                           Ext_Event7_Flags;
  wire [2:0]                           Ext_Event_Flag_En;
 
  // Accumulator signals
  wire                                 Acc_OF_0;    
  wire                                 Acc_OF_1;    
  wire                                 Acc_OF_2;    
  wire                                 Acc_OF_3;    
  wire                                 Acc_OF_4;    
  wire                                 Acc_OF_5;    
  wire                                 Acc_OF_6;    
  wire                                 Acc_OF_7;    
  wire                                 Acc_OF_8;    
  wire                                 Acc_OF_9;    
  // Incrementor signals
  wire                                 Incr_OF_0;    
  wire                                 Incr_OF_1;    
  wire                                 Incr_OF_2;    
  wire                                 Incr_OF_3;    
  wire                                 Incr_OF_4;    
  wire                                 Incr_OF_5;    
  wire                                 Incr_OF_6;    
  wire                                 Incr_OF_7;    
  wire                                 Incr_OF_8;    
  wire                                 Incr_OF_9;    
  wire                                 Use_Ext_Trig;
  wire                                 Use_Ext_Trig_sync;
  wire                                 Use_Ext_Trig_Log;
  wire                                 Use_Ext_Trig_Log_sync;
  wire                                 Global_Cnt_Event_Log_En; 
  wire                                 Sample_Cnt_Event_Log_En; 

  //Flag generator log enables
  wire                                 Slot_0_Log_En;
  wire                                 Slot_1_Log_En;
  wire                                 Slot_2_Log_En;
  wire                                 Slot_3_Log_En;
  wire                                 Slot_4_Log_En;
  wire                                 Slot_5_Log_En;
  wire                                 Slot_6_Log_En;
  wire                                 Slot_7_Log_En;

  // Latency ID register connections
  wire [15:0]                          Latency_WID;
  wire [15:0]                          Latency_RID;
  wire [15:0]                          WID_Mask;
  wire [15:0]                          RID_Mask;
  wire                                 En_Id_Based;
  wire                                 En_Id_Based_sync;
   /*-------------Generate Monitor fifo data input -------------------*/

  generate if(C_SLOT_0_AXI_PROTOCOL == "AXI4") begin :GEN_SLOT_0_AXI4
    assign SLOT_0_clk    = slot_0_axi_aclk;
    assign SLOT_0_Arst_n = slot_0_axi_aresetn;
    assign Slot_0_Data_In = {slot_0_axi_awid,slot_0_axi_awaddr,slot_0_axi_awlen,slot_0_axi_awsize,
                            slot_0_axi_awburst,slot_0_axi_awvalid,slot_0_axi_awready,
                            slot_0_axi_wstrb,slot_0_axi_wlast,slot_0_axi_wvalid,slot_0_axi_wready,
                            slot_0_axi_bid,slot_0_axi_bresp,slot_0_axi_bvalid,slot_0_axi_bready,
                            slot_0_axi_arid,slot_0_axi_araddr,slot_0_axi_arlen,slot_0_axi_arsize,
                            slot_0_axi_arburst,slot_0_axi_arvalid,slot_0_axi_arready,slot_0_axi_rid,
                            slot_0_axi_rresp,slot_0_axi_rlast,slot_0_axi_rvalid,slot_0_axi_rready};
  end 
  else if(C_SLOT_0_AXI_PROTOCOL == "AXI4S") begin :GEN_SLOT_0_AXI4S
    assign SLOT_0_clk    = slot_0_axis_aclk;
    assign SLOT_0_Arst_n = slot_0_axis_aresetn;
    assign Slot_0_Data_In = {slot_0_axis_tvalid,slot_0_axis_tready,slot_0_axis_tstrb,
                            slot_0_axis_tkeep,slot_0_axis_tlast,slot_0_axis_tid,
                            slot_0_axis_tdest,slot_0_axis_tuser}; 
  end
  endgenerate

  generate if(C_SLOT_1_AXI_PROTOCOL == "AXI4" && C_NUM_MONITOR_SLOTS > 1) begin :GEN_SLOT_1_AXI4
    assign SLOT_1_clk    = slot_1_axi_aclk;
    assign SLOT_1_Arst_n = slot_1_axi_aresetn;
    assign Slot_1_Data_In = {slot_1_axi_awid,slot_1_axi_awaddr,slot_1_axi_awlen,slot_1_axi_awsize,
                            slot_1_axi_awburst,slot_1_axi_awvalid,slot_1_axi_awready,
                            slot_1_axi_wstrb,slot_1_axi_wlast,slot_1_axi_wvalid,slot_1_axi_wready,
                            slot_1_axi_bid,slot_1_axi_bresp,slot_1_axi_bvalid,slot_1_axi_bready,
                            slot_1_axi_arid,slot_1_axi_araddr,slot_1_axi_arlen,slot_1_axi_arsize,
                            slot_1_axi_arburst,slot_1_axi_arvalid,slot_1_axi_arready,slot_1_axi_rid,
                            slot_1_axi_rresp,slot_1_axi_rlast,slot_1_axi_rvalid,slot_1_axi_rready};

  end
  else if(C_SLOT_1_AXI_PROTOCOL == "AXI4S" && C_NUM_MONITOR_SLOTS > 1) begin :GEN_SLOT_1_AXI4S
    assign SLOT_1_clk    = slot_1_axis_aclk;
    assign SLOT_1_Arst_n = slot_1_axis_aresetn;
    assign Slot_1_Data_In = {slot_1_axis_tvalid,slot_1_axis_tready,slot_1_axis_tstrb,
                            slot_1_axis_tkeep,slot_1_axis_tlast,slot_1_axis_tid,
                            slot_1_axis_tdest,slot_1_axis_tuser}; 
  end
  endgenerate

  generate if(C_SLOT_2_AXI_PROTOCOL == "AXI4" && C_NUM_MONITOR_SLOTS > 2) begin :GEN_SLOT_2_AXI4
    assign SLOT_2_clk    = slot_2_axi_aclk;
    assign SLOT_2_Arst_n = slot_2_axi_aresetn;
    assign Slot_2_Data_In = {slot_2_axi_awid,slot_2_axi_awaddr,slot_2_axi_awlen,slot_2_axi_awsize,
                            slot_2_axi_awburst,slot_2_axi_awvalid,slot_2_axi_awready,
                            slot_2_axi_wstrb,slot_2_axi_wlast,slot_2_axi_wvalid,slot_2_axi_wready,
                            slot_2_axi_bid,slot_2_axi_bresp,slot_2_axi_bvalid,slot_2_axi_bready,
                            slot_2_axi_arid,slot_2_axi_araddr,slot_2_axi_arlen,slot_2_axi_arsize,
                            slot_2_axi_arburst,slot_2_axi_arvalid,slot_2_axi_arready,slot_2_axi_rid,
                            slot_2_axi_rresp,slot_2_axi_rlast,slot_2_axi_rvalid,slot_2_axi_rready};
  end
  else if(C_SLOT_2_AXI_PROTOCOL == "AXI4S" && C_NUM_MONITOR_SLOTS > 2) begin :GEN_SLOT_2_AXI4S
    assign SLOT_2_clk    = slot_2_axis_aclk;
    assign SLOT_2_Arst_n = slot_2_axis_aresetn;
    assign Slot_2_Data_In = {slot_2_axis_tvalid,slot_2_axis_tready,slot_2_axis_tstrb,
                            slot_2_axis_tkeep,slot_2_axis_tlast,slot_2_axis_tid,
                            slot_2_axis_tdest,slot_2_axis_tuser};
  end
  endgenerate

  generate if(C_SLOT_3_AXI_PROTOCOL == "AXI4" && C_NUM_MONITOR_SLOTS > 3) begin :GEN_SLOT_3_AXI4
    assign SLOT_3_clk    = slot_3_axi_aclk;
    assign SLOT_3_Arst_n = slot_3_axi_aresetn;
    assign Slot_3_Data_In = {slot_3_axi_awid,slot_3_axi_awaddr,slot_3_axi_awlen,slot_3_axi_awsize,
                            slot_3_axi_awburst,slot_3_axi_awvalid,slot_3_axi_awready,
                            slot_3_axi_wstrb,slot_3_axi_wlast,slot_3_axi_wvalid,slot_3_axi_wready,
                            slot_3_axi_bid,slot_3_axi_bresp,slot_3_axi_bvalid,slot_3_axi_bready,
                            slot_3_axi_arid,slot_3_axi_araddr,slot_3_axi_arlen,slot_3_axi_arsize,
                            slot_3_axi_arburst,slot_3_axi_arvalid,slot_3_axi_arready,slot_3_axi_rid,
                            slot_3_axi_rresp,slot_3_axi_rlast,slot_3_axi_rvalid,slot_3_axi_rready};

  end
  else if(C_SLOT_3_AXI_PROTOCOL == "AXI4S" && C_NUM_MONITOR_SLOTS > 3) begin :GEN_SLOT_3_AXI4S
    assign SLOT_3_clk    = slot_3_axis_aclk;
    assign SLOT_3_Arst_n = slot_3_axis_aresetn;
    assign Slot_3_Data_In = {slot_3_axis_tvalid,slot_3_axis_tready,slot_3_axis_tstrb,
                            slot_3_axis_tkeep,slot_3_axis_tlast,slot_3_axis_tid,
                            slot_3_axis_tdest,slot_3_axis_tuser};
  end
  endgenerate

  generate if(C_SLOT_4_AXI_PROTOCOL == "AXI4" && C_NUM_MONITOR_SLOTS > 4) begin :GEN_SLOT_4_AXI4
    assign SLOT_4_clk    = slot_4_axi_aclk;
    assign SLOT_4_Arst_n = slot_4_axi_aresetn;
    assign Slot_4_Data_In = {slot_4_axi_awid,slot_4_axi_awaddr,slot_4_axi_awlen,slot_4_axi_awsize,
                            slot_4_axi_awburst,slot_4_axi_awvalid,slot_4_axi_awready,
                            slot_4_axi_wstrb,slot_4_axi_wlast,slot_4_axi_wvalid,slot_4_axi_wready,
                            slot_4_axi_bid,slot_4_axi_bresp,slot_4_axi_bvalid,slot_4_axi_bready,
                            slot_4_axi_arid,slot_4_axi_araddr,slot_4_axi_arlen,slot_4_axi_arsize,
                            slot_4_axi_arburst,slot_4_axi_arvalid,slot_4_axi_arready,slot_4_axi_rid,
                            slot_4_axi_rresp,slot_4_axi_rlast,slot_4_axi_rvalid,slot_4_axi_rready};
  end
  else if(C_SLOT_4_AXI_PROTOCOL == "AXI4S" && C_NUM_MONITOR_SLOTS > 4) begin :GEN_SLOT_4_AXI4S
    assign SLOT_4_clk    = slot_4_axis_aclk;
    assign SLOT_4_Arst_n = slot_4_axis_aresetn;
    assign Slot_4_Data_In = {slot_4_axis_tvalid,slot_4_axis_tready,slot_4_axis_tstrb,
                            slot_4_axis_tkeep,slot_4_axis_tlast,slot_4_axis_tid,
                            slot_4_axis_tdest,slot_4_axis_tuser};
  end
  endgenerate

  generate if(C_SLOT_5_AXI_PROTOCOL == "AXI4" && C_NUM_MONITOR_SLOTS > 5) begin :GEN_SLOT_5_AXI4
    assign SLOT_5_clk    = slot_5_axi_aclk;
    assign SLOT_5_Arst_n = slot_5_axi_aresetn;
    assign Slot_5_Data_In = {slot_5_axi_awid,slot_5_axi_awaddr,slot_5_axi_awlen,slot_5_axi_awsize,
                            slot_5_axi_awburst,slot_5_axi_awvalid,slot_5_axi_awready,
                            slot_5_axi_wstrb,slot_5_axi_wlast,slot_5_axi_wvalid,slot_5_axi_wready,
                            slot_5_axi_bid,slot_5_axi_bresp,slot_5_axi_bvalid,slot_5_axi_bready,
                            slot_5_axi_arid,slot_5_axi_araddr,slot_5_axi_arlen,slot_5_axi_arsize,
                            slot_5_axi_arburst,slot_5_axi_arvalid,slot_5_axi_arready,slot_5_axi_rid,
                            slot_5_axi_rresp,slot_5_axi_rlast,slot_5_axi_rvalid,slot_5_axi_rready};

  end
  else if(C_SLOT_5_AXI_PROTOCOL == "AXI4S" && C_NUM_MONITOR_SLOTS > 5) begin :GEN_SLOT_5_AXI4S
    assign SLOT_5_clk    = slot_5_axis_aclk;
    assign SLOT_5_Arst_n = slot_5_axis_aresetn;
    assign Slot_5_Data_In = {slot_5_axis_tvalid,slot_5_axis_tready,slot_5_axis_tstrb,
                            slot_5_axis_tkeep,slot_5_axis_tlast,slot_5_axis_tid,
                            slot_5_axis_tdest,slot_5_axis_tuser};
  end
  endgenerate

  generate if(C_SLOT_6_AXI_PROTOCOL == "AXI4" && C_NUM_MONITOR_SLOTS > 6) begin :GEN_SLOT_6_AXI4
    assign SLOT_6_clk    = slot_6_axi_aclk;
    assign SLOT_6_Arst_n = slot_6_axi_aresetn;
    assign Slot_6_Data_In = {slot_6_axi_awid,slot_6_axi_awaddr,slot_6_axi_awlen,slot_6_axi_awsize,
                            slot_6_axi_awburst,slot_6_axi_awvalid,slot_6_axi_awready,
                            slot_6_axi_wstrb,slot_6_axi_wlast,slot_6_axi_wvalid,slot_6_axi_wready,
                            slot_6_axi_bid,slot_6_axi_bresp,slot_6_axi_bvalid,slot_6_axi_bready,
                            slot_6_axi_arid,slot_6_axi_araddr,slot_6_axi_arlen,slot_6_axi_arsize,
                            slot_6_axi_arburst,slot_6_axi_arvalid,slot_6_axi_arready,slot_6_axi_rid,
                            slot_6_axi_rresp,slot_6_axi_rlast,slot_6_axi_rvalid,slot_6_axi_rready};

  end
  else if(C_SLOT_6_AXI_PROTOCOL == "AXI4S" && C_NUM_MONITOR_SLOTS > 6) begin :GEN_SLOT_6_AXI4S
    assign SLOT_6_clk    = slot_6_axis_aclk;
    assign SLOT_6_Arst_n = slot_6_axis_aresetn;
    assign Slot_6_Data_In = {slot_6_axis_tvalid,slot_6_axis_tready,slot_6_axis_tstrb,
                            slot_6_axis_tkeep,slot_6_axis_tlast,slot_6_axis_tid,
                            slot_6_axis_tdest,slot_6_axis_tuser};

  end
  endgenerate

  generate if(C_SLOT_7_AXI_PROTOCOL == "AXI4" && C_NUM_MONITOR_SLOTS > 7) begin :GEN_SLOT_7_AXI4
    assign SLOT_7_clk    = slot_7_axi_aclk;
    assign SLOT_7_Arst_n = slot_7_axi_aresetn;
    assign Slot_7_Data_In = {slot_7_axi_awid,slot_7_axi_awaddr,slot_7_axi_awlen,slot_7_axi_awsize,
                            slot_7_axi_awburst,slot_7_axi_awvalid,slot_7_axi_awready,
                            slot_7_axi_wstrb,slot_7_axi_wlast,slot_7_axi_wvalid,slot_7_axi_wready,
                            slot_7_axi_bid,slot_7_axi_bresp,slot_7_axi_bvalid,slot_7_axi_bready,
                            slot_7_axi_arid,slot_7_axi_araddr,slot_7_axi_arlen,slot_7_axi_arsize,
                            slot_7_axi_arburst,slot_7_axi_arvalid,slot_7_axi_arready,slot_7_axi_rid,
                            slot_7_axi_rresp,slot_7_axi_rlast,slot_7_axi_rvalid,slot_7_axi_rready};


  end
  else if(C_SLOT_7_AXI_PROTOCOL == "AXI4S" && C_NUM_MONITOR_SLOTS > 7) begin :GEN_SLOT_7_AXI4S
    assign SLOT_7_clk    = slot_7_axis_aclk;
    assign SLOT_7_Arst_n = slot_7_axis_aresetn;
    assign Slot_7_Data_In = {slot_7_axis_tvalid,slot_7_axis_tready,slot_7_axis_tstrb,
                            slot_7_axis_tkeep,slot_7_axis_tlast,slot_7_axis_tid,
                            slot_7_axis_tdest,slot_7_axis_tuser};

  end
  endgenerate




   /*----------------------------------------------------------------------
   ------------------- Submodule instantiations-----------------------------
   -----------------------------------------------------------------------*/ 

   // AXI Lite Interface module

   axi_perf_mon_v5_0_9_axi_interface
   #(
         .C_FAMILY                (C_FAMILY               ), 
         .C_S_AXI_PROTOCOL        (C_S_AXI_PROTOCOL       ),
         .C_S_AXI_ADDR_WIDTH      (C_S_AXI_ADDR_WIDTH     ),
         .C_S_AXI_DATA_WIDTH      (C_S_AXI_DATA_WIDTH     ),
         .C_S_AXI_ID_WIDTH        (C_S_AXI_ID_WIDTH       ),
         .C_SUPPORT_ID_REFLECTION (C_SUPPORT_ID_REFLECTION) 
     ) axi_interface_inst
     (
         .S_AXI_ACLK          (s_axi_aclk ),       
         .S_AXI_ARESETN       (s_axi_aresetn),
         .S_AXI_AWADDR        (s_axi_awaddr),
         .S_AXI_AWVALID       (s_axi_awvalid),
         .S_AXI_AWID          (s_axi_awid),
         .S_AXI_AWREADY       (s_axi_awready),
         .S_AXI_WDATA         (s_axi_wdata),
         .S_AXI_WSTRB         (s_axi_wstrb),
         .S_AXI_WVALID        (s_axi_wvalid), 
         .S_AXI_WREADY        (s_axi_wready), 
         .S_AXI_BRESP         (s_axi_bresp),
         .S_AXI_BVALID        (s_axi_bvalid),
         .S_AXI_BID           (s_axi_bid),
         .S_AXI_BREADY        (s_axi_bready), 
         .S_AXI_ARADDR        (s_axi_araddr),
         .S_AXI_ARVALID       (s_axi_arvalid),
         .S_AXI_ARID          (s_axi_arid),
         .S_AXI_ARREADY       (s_axi_arready), 
         .S_AXI_RDATA         (s_axi_rdata  ), 
         .S_AXI_RRESP         (s_axi_rresp  ),
         .S_AXI_RVALID        (s_axi_rvalid ),
         .S_AXI_RID           (s_axi_rid),
         .S_AXI_RREADY        (s_axi_rready ),
         .Bus2IP_Addr         (Bus2IP_Addr  ),
         .Bus2IP_Data         (Bus2IP_Data  ),
         .Bus2IP_BE           (Bus2IP_BE    ),
         .Bus2IP_Burst        (Bus2IP_Burst ), 
         .Bus2IP_RdCE         (Bus2IP_RdCE  ), 
         .Bus2IP_WrCE         (Bus2IP_WrCE  ),
         .IP2Bus_Data         (IP2Bus_Data  ), 
         .IP2Bus_DataValid    (IP2Bus_DataValid),
         .IP2Bus_Error        (IP2Bus_Error )
      );
  generate if (C_LOG_DATA_OFFLD == 0 ) begin : LOG_DATA_OFFLOAD_STREAM
    assign eventlog_rd_clk = m_axis_aclk;
    assign eventlog_rd_rstn = m_axis_aresetn;
  end
  endgenerate
  generate if (C_LOG_DATA_OFFLD == 1 ) begin : LOG_DATA_OFFLOAD_MEMORY
    assign eventlog_rd_clk = s_axi_offld_aclk;
    assign eventlog_rd_rstn = s_axi_offld_aresetn;
  end
  endgenerate
  // Register module instance
   axi_perf_mon_v5_0_9_register_module
   #(
         .C_FAMILY                    (C_FAMILY),
         .C_S_AXI_ADDR_WIDTH          (C_S_AXI_ADDR_WIDTH),
         .C_S_AXI_DATA_WIDTH          (C_S_AXI_DATA_WIDTH),
         .C_NUM_MONITOR_SLOTS         (C_NUM_MONITOR_SLOTS), 
         .C_NUM_OF_COUNTERS           (C_NUM_OF_COUNTERS), 
         .C_NUM_INTR_INPUTS           (C_NUM_INTR_INPUTS),
         .C_ENABLE_EVENT_COUNT        (C_ENABLE_EVENT_COUNT),
         .C_ENABLE_EVENT_LOG          (C_ENABLE_EVENT_LOG),
         .C_METRICS_SAMPLE_COUNT_WIDTH(C_METRICS_SAMPLE_COUNT_WIDTH),
         .C_GLOBAL_COUNT_WIDTH        (C_GLOBAL_COUNT_WIDTH),
         .C_SW_SYNC_DATA_WIDTH        (C_SW_SYNC_DATA_WIDTH),
         .C_AXIS_DWIDTH_ROUND_TO_32   (C_AXIS_DWIDTH_ROUND_TO_32),
         .C_AXI4LITE_CORE_CLK_ASYNC   (C_AXI4LITE_CORE_CLK_ASYNC)
    ) register_module_inst
    (
         .S_AXI_ACLK           (s_axi_aclk),
         .S_AXI_ARESETN        (s_axi_aresetn),
         .Bus2IP_Addr          (Bus2IP_Addr),
         .Bus2IP_Data          (Bus2IP_Data),
         .Bus2IP_BE            (Bus2IP_BE),
         .Bus2IP_Burst         (Bus2IP_Burst),
         .Bus2IP_RdCE          (Bus2IP_RdCE)  ,
         .Bus2IP_WrCE          (Bus2IP_WrCE),
         .IP2Bus_Data          (IP2Bus_Data) ,
         .IP2Bus_DataValid     (IP2Bus_DataValid),
         .IP2Bus_Error         (IP2Bus_Error),
         .CORE_ACLK            (core_aclk   ),
         .CORE_ARESETN         (core_aresetn ),
         .Global_Clk_Cnt       (Global_Clk_Cnt) ,
         .Metric_Cnt_0         (Metric_Cnt_0  ) ,
         .Metric_Cnt_1         (Metric_Cnt_1  ) ,
         .Metric_Cnt_2         (Metric_Cnt_2  ) ,
         .Metric_Cnt_3         (Metric_Cnt_3  ) ,
         .Metric_Cnt_4         (Metric_Cnt_4  ) ,
         .Metric_Cnt_5         (Metric_Cnt_5  ) ,
         .Metric_Cnt_6         (Metric_Cnt_6  ) ,
         .Metric_Cnt_7         (Metric_Cnt_7  ) ,
         .Metric_Cnt_8         (Metric_Cnt_8  ) ,
         .Metric_Cnt_9         (Metric_Cnt_9  ) ,
         .Incrementer_0        (Incrementer_0  ) ,
         .Incrementer_1        (Incrementer_1  ) ,
         .Incrementer_2        (Incrementer_2  ) ,
         .Incrementer_3        (Incrementer_3  ) ,
         .Incrementer_4        (Incrementer_4  ) ,
         .Incrementer_5        (Incrementer_5  ) ,
         .Incrementer_6        (Incrementer_6  ) ,
         .Incrementer_7        (Incrementer_7  ) ,
         .Incrementer_8        (Incrementer_8  ) ,
         .Incrementer_9        (Incrementer_9  ) ,
         .Samp_Metric_Cnt_0    (Samp_Metric_Cnt_0  ) ,
         .Samp_Metric_Cnt_1    (Samp_Metric_Cnt_1  ) ,
         .Samp_Metric_Cnt_2    (Samp_Metric_Cnt_2  ) ,
         .Samp_Metric_Cnt_3    (Samp_Metric_Cnt_3  ) ,
         .Samp_Metric_Cnt_4    (Samp_Metric_Cnt_4  ) ,
         .Samp_Metric_Cnt_5    (Samp_Metric_Cnt_5  ) ,
         .Samp_Metric_Cnt_6    (Samp_Metric_Cnt_6  ) ,
         .Samp_Metric_Cnt_7    (Samp_Metric_Cnt_7  ) ,
         .Samp_Metric_Cnt_8    (Samp_Metric_Cnt_8  ) ,
         .Samp_Metric_Cnt_9    (Samp_Metric_Cnt_9  ) ,
         .Samp_Incrementer_0   (Samp_Incrementer_0  ) ,
         .Samp_Incrementer_1   (Samp_Incrementer_1  ) ,
         .Samp_Incrementer_2   (Samp_Incrementer_2  ) ,
         .Samp_Incrementer_3   (Samp_Incrementer_3  ) ,
         .Samp_Incrementer_4   (Samp_Incrementer_4  ) ,
         .Samp_Incrementer_5   (Samp_Incrementer_5  ) ,
         .Samp_Incrementer_6   (Samp_Incrementer_6  ) ,
         .Samp_Incrementer_7   (Samp_Incrementer_7  ) ,
         .Samp_Incrementer_8   (Samp_Incrementer_8  ) ,
         .Samp_Incrementer_9   (Samp_Incrementer_9  ) ,
         .Sample_Interval      (Sample_Interval  ),
         .Interval_Cnt_En      (Interval_Cnt_En  ),
         .Interval_Cnt_Ld      (Interval_Cnt_Ld  ),
         .Reset_On_Sample_Int_Lapse(Reset_On_Sample_Int_Lapse),
         .Global_Intr_En       (Global_Intr_En   ),
         .Intr_Reg_IER_Wr_En   (Intr_Reg_IER_Wr_En ),
         .Intr_Reg_ISR_Wr_En   (Intr_Reg_ISR_Wr_En ),
         .Intr_Reg_IER         (Intr_Reg_IER     ),
         .Intr_Reg_ISR         (Intr_Reg_ISR     ),
         .eventlog_rd_clk      (eventlog_rd_clk  ),
         .eventlog_rd_rstn     (eventlog_rd_rstn ),
         .eventlog_cur_cnt     (eventlog_cur_cnt ),
         .Metric_Sel_0         (Metric_Sel_0     ),
         .Metric_Sel_1         (Metric_Sel_1     ),
         .Metric_Sel_2         (Metric_Sel_2     ),
         .Metric_Sel_3         (Metric_Sel_3     ),
         .Metric_Sel_4         (Metric_Sel_4     ),
         .Metric_Sel_5         (Metric_Sel_5     ),
         .Metric_Sel_6         (Metric_Sel_6     ),
         .Metric_Sel_7         (Metric_Sel_7     ),
         .Metric_Sel_8         (Metric_Sel_8     ),
         .Metric_Sel_9         (Metric_Sel_9     ),
         .Range_Reg_0          (Range_Reg_0      ),
         .Range_Reg_1          (Range_Reg_1      ),
         .Range_Reg_2          (Range_Reg_2      ),
         .Range_Reg_3          (Range_Reg_3      ),
         .Range_Reg_4          (Range_Reg_4      ),
         .Range_Reg_5          (Range_Reg_5      ),
         .Range_Reg_6          (Range_Reg_6      ),
         .Range_Reg_7          (Range_Reg_7      ),
         .Range_Reg_8          (Range_Reg_8      ),
         .Range_Reg_9          (Range_Reg_9      ),
         .Flag_Enable_Reg      (Flag_Enable_Reg  ),
         .SW_Data_Log_En       (SW_Data_Log_En   ),
         .Ext_Event_Flag_En    (Ext_Event_Flag_En),
         .SW_Data              (SW_Data          ),
         .SW_Data_Wr_En        (SW_Data_Wr_En    ),
         .Global_Clk_Cnt_En    (Global_Clk_Cnt_En) ,
         .Global_Clk_Cnt_Reset (Global_Clk_Cnt_Reset),
         .Streaming_FIFO_Reset (Streaming_FIFO_Reset),
         .Event_Log_En         (Event_Log_En     ),
         .Metrics_Cnt_En       (Metrics_Cnt_En   ),
         .Metrics_Cnt_Reset    (Metrics_Cnt_Reset),
         .Use_Ext_Trigger      (Use_Ext_Trig     ),
         .Use_Ext_Trigger_Log  (Use_Ext_Trig_Log ),
         .Global_Clk_Cnt_Ovf_En(Global_Clk_Cnt_Ovf_En),
         .Sample_Metric_Cnt_Ovf_En(Sample_Metric_Cnt_Ovf_En),
         .Count_Event_Log_En   (Count_Event_Log_En),
         .Latency_WID          (Latency_WID),
         .Latency_RID          (Latency_RID),
         .En_Id_Based          (En_Id_Based),
         .Lat_Sample_Reg       (Lat_Sample_Reg),
         .WID_Mask             (WID_Mask),
         .RID_Mask             (RID_Mask),
         .Wr_Lat_Start         (Wr_Lat_Start), //0 Address Issue 1 Address acceptance
         .Wr_Lat_End           (Wr_Lat_End), //1 First write   0 Last write  
         .Rd_Lat_Start         (Rd_Lat_Start), //0 Address Issue 1 Address acceptance 
         .Rd_Lat_End           (Rd_Lat_End)  //1 First Read    0 Last Read
       );

   
   generate    
   if (C_ENABLE_EVENT_COUNT == 1 && C_ENABLE_EVENT_LOG == 1) begin : GEN_CROSS_PROBE_GLOBAL
   //Event logging enable generation when global clock counter overflow
   reg Global_Cnt_Event_Log_En_i;

   always @(posedge core_aclk) begin
       if (core_aresetn == RST_ACTIVE) begin
           Global_Cnt_Event_Log_En_i <= 1'b0;
       end
       else begin
           if(Global_Clk_Cnt_Ovf_En_sync == 1'b0) begin //User control to enable 
             Global_Cnt_Event_Log_En_i <= 1'b0;
           end
           else if(Global_Clk_Cnt_OF == 1'b1) begin     //Counter overflow
             Global_Cnt_Event_Log_En_i <= 1'b1;
           end
       end
   end
       assign Global_Cnt_Event_Log_En = Global_Cnt_Event_Log_En_i;
   end
   else begin: GEN_NO_CROSS_PROBE_GLOBAL 
      assign Global_Cnt_Event_Log_En = 1'b0;
   end
   endgenerate


   //Event logging enable generation when sample metric counter lapse 
   generate    
   if (C_ENABLE_EVENT_COUNT == 1 && C_ENABLE_EVENT_LOG == 1) begin : GEN_CROSS_PROBE_SAMPLE
   reg Sample_Cnt_Event_Log_En_i;
   always @(posedge core_aclk) begin
       if (core_aresetn == RST_ACTIVE) begin
           Sample_Cnt_Event_Log_En_i <= 1'b0;
       end
       else begin
           if(Sample_Metric_Cnt_Ovf_En_sync == 1'b0) begin //User control to enable 
             Sample_Cnt_Event_Log_En_i <= 1'b0;
           end
           else if(Sample_Interval_Cnt_Lapse == 1'b1) begin //Counter overflow
             Sample_Cnt_Event_Log_En_i <= 1'b1;
           end
       end
   end
      assign Sample_Cnt_Event_Log_En = Sample_Cnt_Event_Log_En_i;
   end
   else begin: GEN_NO_CROSS_PROBE_SAMPLE
      assign Sample_Cnt_Event_Log_En = 1'b0;
   end

   endgenerate
   //-- Inputs to interrupt module

    assign Intr_In = { Acc_OF_9, Acc_OF_8, Acc_OF_7, Acc_OF_6, Acc_OF_5,
                       Acc_OF_4, Acc_OF_3, Acc_OF_2, Acc_OF_1, Acc_OF_0,
                       Streaming_Fifo_Full_Edge, Sample_Interval_Cnt_Lapse, Global_Clk_Cnt_OF};

    // synchronizing the inputs to interrupt module
    generate
    if((C_AXI4LITE_CORE_CLK_ASYNC == 1)) begin :GEN_INTR_ASYNC
        axi_perf_mon_v5_0_9_intr_sync
           #(
                 .C_FAMILY            (C_FAMILY),
                 .C_DWIDTH            (C_NUM_INTR_INPUTS) 
            ) intr_sync_module_inst
            (
                 .clk_1               (core_aclk),
                 .rst_1_n             (core_aresetn), 
                 .DATA_IN             (Intr_In),
                 .clk_2               (s_axi_aclk),
                 .rst_2_n             (s_axi_aresetn), 
                 .SYNC_DATA_OUT       (Intr_In_sync)
            );
    end
    else begin :GEN_INTR_SYNC
        assign Intr_In_sync = Intr_In;
    end
    endgenerate
       

    // Interrupt Module instance

    wire [C_NUM_INTR_INPUTS-1:0] Wr_Data = Bus2IP_Data[C_NUM_INTR_INPUTS-1:0];

    axi_perf_mon_v5_0_9_interrupt_module 
    #(
         .C_FAMILY             (C_FAMILY         ),
         .C_NUM_INTR_INPUTS    (C_NUM_INTR_INPUTS)
     ) interrupt_module_inst
     (
         .clk                  (s_axi_aclk        ),
         .rst_n                (s_axi_aresetn     ),
         .Intr                 (Intr_In_sync      ),
         .Interrupt_Enable     (Global_Intr_En    ),
         .IER_Wr_En            (Intr_Reg_IER_Wr_En),                
         .ISR_Wr_En            (Intr_Reg_ISR_Wr_En),
         .Wr_Data              (Wr_Data           ),
         .IER                  (Intr_Reg_IER      ), 
         .ISR                  (Intr_Reg_ISR      ), 
         .Interrupt            (interrupt         )
      );

    //assigning global clock count enable ane reset signals to bus

    //-- Control Bits
    wire [10:0] Control_Bits = {Use_Ext_Trig_Log,Use_Ext_Trig,Sample_Metric_Cnt_Ovf_En,Global_Clk_Cnt_Ovf_En, 
                               Streaming_FIFO_Reset,En_Id_Based,
                               Global_Clk_Cnt_Reset, Global_Clk_Cnt_En,Event_Log_En,
                               Metrics_Cnt_Reset, Metrics_Cnt_En };
 
    generate    
    if (C_AXI4LITE_CORE_CLK_ASYNC == 1) begin : GEN_CONTROL_SYNC
        //-- Synchronizing Control bits to core clk  
        //-- Double Flop synchronization
        axi_perf_mon_v5_0_9_cdc_sync
        #(
           .c_cdc_type      (1             ),   
           .c_flop_input    (0             ),  
           .c_reset_state   (1             ),  
           .c_single_bit    (0             ),  
           .c_vector_width  (11            ),  
           .c_mtbf_stages   (4             )  
         )control_sig_cdc_sync 
         (
           .prmry_aclk      (s_axi_aclk          ),
           .prmry_rst_n     (s_axi_aresetn       ),
           .prmry_in        (1'b0                ),
           .prmry_vect_in   (Control_Bits        ),
           .scndry_aclk     (core_aclk           ),
           .scndry_rst_n    (core_aresetn        ),
           .prmry_ack       (                    ),
           .scndry_out      (                    ),
           .scndry_vect_out (Control_Bits_sync   ) 
          );

        assign Metrics_Cnt_En_sync           = Control_Bits_sync[0];
        assign Metrics_Cnt_Reset_sync        = Control_Bits_sync[1];
        assign Event_Log_En_sync             = Control_Bits_sync[2] | Count_Event_Log_En |
                                               Global_Cnt_Event_Log_En | Sample_Cnt_Event_Log_En;
        assign Global_Clk_Cnt_En_sync        = Control_Bits_sync[3];
        assign Global_Clk_Cnt_Reset_sync     = Control_Bits_sync[4];
        assign En_Id_Based_sync              = Control_Bits_sync[5];
        assign Streaming_FIFO_Reset_sync     = Control_Bits_sync[6];
        assign Global_Clk_Cnt_Ovf_En_sync    = Control_Bits_sync[7];
        assign Sample_Metric_Cnt_Ovf_En_sync = Control_Bits_sync[8];
        assign Use_Ext_Trig_sync             = Control_Bits_sync[9];
        assign Use_Ext_Trig_Log_sync         = Control_Bits_sync[10];

    end 
    else begin : GEN_CONTROL_NO_SYNC
        assign Metrics_Cnt_En_sync           = Control_Bits[0];
        assign Metrics_Cnt_Reset_sync        = Control_Bits[1];
        assign Event_Log_En_sync             = Control_Bits[2] | Count_Event_Log_En |
                                               Global_Cnt_Event_Log_En | Sample_Cnt_Event_Log_En;
        assign Global_Clk_Cnt_En_sync        = Control_Bits[3];
        assign Global_Clk_Cnt_Reset_sync     = Control_Bits[4];
        assign En_Id_Based_sync              = Control_Bits[5];
        assign Streaming_FIFO_Reset_sync     = Control_Bits[6];
        assign Global_Clk_Cnt_Ovf_En_sync    = Control_Bits[7];
        assign Sample_Metric_Cnt_Ovf_En_sync = Control_Bits[8];
        assign Use_Ext_Trig_sync             = Control_Bits[9];
        assign Use_Ext_Trig_Log_sync         = Control_Bits[10];
    end 
    endgenerate 

   wire trigger_in_sync;

   reg 	trigger_in_ack_r;

   wire 	trigger_in_d4;

//synchoronize the input trigger_in signal with level shifter
        axi_perf_mon_v5_0_9_cdc_sync
        #(
           .c_cdc_type      (1             ),   
           .c_flop_input    (0             ),  
           .c_reset_state   (1             ),  
           .c_single_bit    (1             ),  
           .c_vector_width  (1             ),  
           .c_mtbf_stages   (4             )  
         ) trigger_sig_cdc_sync 
         (
           .prmry_aclk      (1'b1                ),
           .prmry_rst_n     (1'b1                ),
           .prmry_in        (trigger_in          ),
           .prmry_vect_in   (1'b0                ),
           .scndry_aclk     (core_aclk           ),
           .scndry_rst_n    (core_aresetn        ),
           .prmry_ack       (                    ),
           .scndry_out      (trigger_in_d4       ),
           .scndry_vect_out (                    ) 
          );
// always @ (posedge core_aclk ) begin
//     if (core_aresetn == RST_ACTIVE)
//       begin
//	  trigger_in_d1 <=0;
//	  trigger_in_d2<=0;
//	  trigger_in_d3<=0;
//	  trigger_in_d4<=0;
//       end
//     else
//       begin
//	  trigger_in_d1 <= trigger_in;
//	  trigger_in_d2 <= trigger_in_d1;
//	  trigger_in_d3 <= trigger_in_d2;
//	  trigger_in_d4 <= trigger_in_d3;
//       end
//   end
   
   assign trigger_in_sync = trigger_in_d4;

 
//generate trigger_ack hand-shaking signal
  always @(posedge core_aclk) begin
      if (core_aresetn == RST_ACTIVE)
      	trigger_in_ack_r <=0;
      else begin
      	if (trigger_in_sync)
	         trigger_in_ack_r <= 1'b1;
      	else
	         trigger_in_ack_r <=1'b0;
    end
  end
   assign trigger_in_ack = trigger_in_ack_r;

//generate trigger signal for the controlling of internal components. Also use Metric_Cnt_En_sync signal as enable signal and Metrics_Cnt_Reset_sync as reset signal
   
   reg trigger,trigger1;
   always @ (posedge core_aclk) begin
			   
       if (core_aresetn == RST_ACTIVE) begin
	     trigger <=0;
	     trigger1 <=0;
        end else begin
	    trigger <= trigger1;
      if (trigger_in_sync && Metrics_Cnt_En_sync && !Metrics_Cnt_Reset_sync)
	     trigger1 <=1'b1;
    	else if (!trigger_in_sync && Metrics_Cnt_En_sync && !Metrics_Cnt_Reset_sync)
	     trigger1 <= trigger1;
      else
	    trigger1 <=0;
   end	
   end

    // Global Clock Counter 

     axi_perf_mon_v5_0_9_glbl_clk_cnt
      #(
         .C_FAMILY             (C_FAMILY),
         .C_GLOBAL_COUNT_WIDTH (C_GLOBAL_COUNT_WIDTH),
	 .COUNTER_LOAD_VALUE   (COUNTER_LOAD_VALUE)
       ) global_clock_counter_inst
       (
         .clk                  (core_aclk   ),
         .rst_n                (core_aresetn),
         .Global_Clk_Cnt_En    (Global_Clk_Cnt_En_sync),
         .Global_Clk_Cnt_Reset (Global_Clk_Cnt_Reset_sync),
         .Global_Clk_Cnt       (Global_Clk_Cnt),
         .Global_Clk_Cnt_OF    (Global_Clk_Cnt_OF)
       );


     //-- Slot 0
     
     // Monitor FIFO instantiations
     axi_perf_mon_v5_0_9_mon_fifo
     #(
       .C_FAMILY                  (C_FAMILY),
       .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),  
       .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S0),
       .C_FIFO_ENABLE             (C_SLOT_0_FIFO_ENABLE) 
      ) mon_fifo_inst_0
      (
       .Mon_clk                   (SLOT_0_clk),
       .Mon_rst_n                 (SLOT_0_Arst_n),
       .Data_In                   (Slot_0_Data_In),
       //.mon_en                    (Metrics_Cnt_En_sync),
       .CORE_ACLK                 (core_aclk),
       .CORE_ARESETN              (core_aresetn),
       .Sync_Data_Out             (Slot_0_Sync_Data_Out),
       .Sync_Data_Valid           (Slot_0_Sync_Data_Valid)
      );

    generate    
    if (C_ENABLE_EVENT_LOG == 1) begin : GEN_FLAGS0
    //Flag Generator instantiation for slot0
     axi_perf_mon_v5_0_9_flags_gen
     #(
       .C_FAMILY                  (C_FAMILY),
       .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S0), 
       .C_LOG_WIDTH               (C_SLOT_0_LOG_WIDTH),
       .C_FLAG_WIDTH              (C_SLOT_0_FLAG_WIDTH), 
       .C_AXI_ADDR_WIDTH          (C_SLOT_0_AXI_ADDR_WIDTH), 
       .C_AXI_DATA_WIDTH          (C_SLOT_0_AXI_DATA_WIDTH), 
       .C_AXI_ID_WIDTH            (C_SLOT_0_AXI_ID_WIDTH), 
       .C_AXI_PROTOCOL            (C_SLOT_0_AXI_PROTOCOL), 
       .C_AXIS_TDATA_WIDTH        (C_SLOT_0_AXIS_TDATA_WIDTH), 
       .C_AXIS_TID_WIDTH          (C_SLOT_0_AXIS_TID_WIDTH), 
       .C_AXIS_TDEST_WIDTH        (C_SLOT_0_AXIS_TDEST_WIDTH), 
       .C_AXIS_TUSER_WIDTH        (C_SLOT_0_AXIS_TUSER_WIDTH),
       .C_SHOW_AXI_IDS            (C_SHOW_AXI_IDS),
       .C_SHOW_AXI_LEN            (C_SHOW_AXI_LEN),
       .C_SHOW_AXIS_TID           (C_SHOW_AXIS_TID),
       .C_SHOW_AXIS_TUSER         (C_SHOW_AXIS_TUSER),
       .C_SHOW_AXIS_TDEST         (C_SHOW_AXIS_TDEST), 
       .C_EN_AXI_DEBUG               (C_EN_AXI_DEBUG) 
      ) flags_generator_inst_0
      (
       .clk                       (core_aclk),
       .rst_n                     (core_aresetn),
       .Data_In                   (Slot_0_Sync_Data_Out),
       .Data_Valid                (Slot_0_Sync_Data_Valid), 
       .Flag_Enable_Reg           (Flag_Enable_Reg),
       .Ext_Trig                  (slot_0_ext_trig),
       .Ext_Trig_Stop             (slot_0_ext_trig_stop),
       .Use_Ext_Trig_Log          (Use_Ext_Trig_Log_sync),                 
       .Log_Data                  (Slot_0_Log),
       .Log_En                    (Slot_0_Log_En),
       .Ext_Data_in               (Ext_Event0_Sync_Data_Out),
       .Ext_Data_Valid            (Ext_Event0_Sync_Data_Valid),
       .Ext_Event_Flag_En         (Ext_Event_Flag_En),
       .Ext_Event_Flags           (Ext_Event0_Flags)
      );
    end 
    else begin : GEN_NO_FLAGS0
       assign Slot_0_Log = 0;
       assign Slot_0_Log_En = 1'b0;
       assign Ext_Event0_Flags = 0;
    end 
    endgenerate 

     // Metric calculator instance for slot0
     axi_perf_mon_v5_0_9_metric_calc 
    #(
      .C_AXIID                   (C_SLOT_0_AXI_ID_WIDTH    ),
      .C_AXIADDR                 (C_SLOT_0_AXI_ADDR_WIDTH  ),
      .C_AXIDATA                 (C_SLOT_0_AXI_DATA_WIDTH  ),
      .C_AXISDATA                (C_SLOT_0_AXIS_TDATA_WIDTH),
      .C_AXISID                  (C_SLOT_0_AXIS_TID_WIDTH  ),
      .C_AXISDEST                (C_SLOT_0_AXIS_TDEST_WIDTH),
      .C_AXISUSER                (C_SLOT_0_AXIS_TUSER_WIDTH),
      .C_OUTSTAND_DEPTH          (C_MAX_OUTSTAND_DEPTH),
      .C_METRIC_COUNT_WIDTH      (C_METRIC_COUNT_WIDTH),
      .C_MON_FIFO_WIDTH          (C_MON_FIFO_DWIDTH_S0),
      .C_AXI_PROTOCOL            (C_SLOT_0_AXI_PROTOCOL),
      .C_AXI_SUB_PROTOCOL        (C_SLOT_0_AXI_SUB_PROTOCOL)
     ) metric_calc_inst0
     (
      .clk                       (core_aclk ),
      .rst_n                     (core_aresetn),
      .Data_In                   (Slot_0_Sync_Data_Out),
      .Data_Valid                (Slot_0_Sync_Data_Valid), 
      .Metrics_Cnt_En            (Metrics_Cnt_En_sync),
      .Metrics_Cnt_Reset         (Metrics_Cnt_Reset_sync),
      .Use_Ext_Trig              (Use_Ext_Trig_sync),
      .Ext_Trig                  (slot_0_ext_trig),
      .Ext_Trig_Stop             (slot_0_ext_trig_stop),
      .Latency_WID               (Latency_WID),
      .Latency_RID               (Latency_RID),
      .WID_Mask                  (WID_Mask),
      .RID_Mask                  (RID_Mask),
      .En_Id_Based               (En_Id_Based_sync),  
      .Wr_Lat_Start              (Wr_Lat_Start    ),  //0 Address Issue 1 Address acceptance
      .Wr_Lat_End                (Wr_Lat_End      ),  //1 First write   0 Last write  
      .Rd_Lat_Start              (Rd_Lat_Start    ),  //0 Address Issue 1 Address acceptance 
      .Rd_Lat_End                (Rd_Lat_End      ),  //1 First Read    0 Last Read
      .Wtrans_Cnt_En             (Wtrans_Cnt_En[0]),
      .Rtrans_Cnt_En             (Rtrans_Cnt_En[0]),
      .Write_Byte_Cnt            (S0_Write_Byte_Cnt),
      .Read_Byte_Cnt             (S0_Read_Byte_Cnt),
      .Write_Beat_Cnt_En         (Write_Beat_Cnt_En[0]),
      .Read_Beat_Cnt_En          (Read_Beat_Cnt_En[0]),
      .Read_Latency              (S0_Read_Latency),
      .Write_Latency             (S0_Write_Latency),
      .Write_Beat_Cnt            (S0_Write_Beat_Cnt),
      .Slv_Wr_Idle_Cnt           (S0_Slv_Wr_Idle_Cnt),
      .Read_Latency_En           (Read_Latency_En[0]),    
      .Write_Latency_En          (Write_Latency_En[0]),   
      .Slv_Wr_Idle_Cnt_En        (Slv_Wr_Idle_Cnt_En[0]), 
      .Mst_Rd_Idle_Cnt_En        (Mst_Rd_Idle_Cnt_En[0]), 
      .Num_BValids_En            (Num_BValids_En[0]),     
      .Num_WLasts_En             (Num_WLasts_En[0]),      
      .Num_RLasts_En             (Num_RLasts_En[0]),      
      .S_Transfer_Cnt_En         (S_Transfer_Cnt_En[0]),
      .S_Packet_Cnt_En           (S_Packet_Cnt_En[0]),  
      .S_Data_Byte_Cnt           (S0_S_Data_Byte_Cnt),
      .S_Position_Byte_Cnt       (S0_S_Position_Byte_Cnt),
      .S_Null_Byte_Cnt           (S0_S_Null_Byte_Cnt),
      .S_Slv_Idle_Cnt_En         (S_Slv_Idle_Cnt_En[0]),
      .S_Mst_Idle_Cnt_En         (S_Mst_Idle_Cnt_En[0]),
      .Max_Write_Latency         (S0_Max_Write_Latency),                   
      .Min_Write_Latency         (S0_Min_Write_Latency),                   
      .Max_Read_Latency          (S0_Max_Read_Latency),                   
      .Min_Read_Latency          (S0_Min_Read_Latency) 
    );

    assign Ext_Event0_Data_In = {ext_event_0_cnt_start,ext_event_0_cnt_stop,ext_event_0};
       
     // External Event0 through monitor FIFO
     axi_perf_mon_v5_0_9_mon_fifo
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
           .C_MON_FIFO_DATA_WIDTH     (3),
           .C_FIFO_ENABLE             (C_EXT_EVENT0_FIFO_ENABLE) 
          ) mon_fifo_ext_event0_inst
          (
           .Mon_clk                   (ext_clk_0),
           .Mon_rst_n                 (ext_rstn_0),
           .Data_In                   (Ext_Event0_Data_In),
           //.mon_en                    (Metrics_Cnt_En_sync),
           .CORE_ACLK                 (core_aclk),
           .CORE_ARESETN              (core_aresetn),
           .Sync_Data_Out             (Ext_Event0_Sync_Data_Out),
           .Sync_Data_Valid           (Ext_Event0_Sync_Data_Valid)
          );

     // External Event0 count enable generation module
      axi_perf_mon_v5_0_9_ext_calc ext_calc_inst0  
         (
           .clk                    (core_aclk),        
           .rst_n                  (core_aresetn),     
           .Ext_Event              (Ext_Event0_Sync_Data_Out[0]),
           .Ext_Event_Start        (Ext_Event0_Sync_Data_Out[2]),
           .Ext_Event_Stop         (Ext_Event0_Sync_Data_Out[1]),
           .Ext_Event_Valid        (Ext_Event0_Sync_Data_Valid ),
           .Metrics_Cnt_En         (Metrics_Cnt_En_sync),
           .Metrics_Cnt_Reset      (Metrics_Cnt_Reset_sync),
           .External_Event_Cnt_En  (External_Event_Cnt_En[0])
         );
  generate if(C_ENABLE_EVENT_LOG == 1 && C_EN_TRIGGER == 1) begin : GEN_POST_TRIGGER
//Aligning start and end events of transactions
       axi_perf_mon_v5_0_9_postTriggerMarker 
	    #(
			   // Parameters
			.C_FAMILY                  (C_FAMILY),
         .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S0), 
         .C_LOG_WIDTH               (C_SLOT_0_LOG_WIDTH),
         .C_FLAG_WIDTH              (C_SLOT_N_FLAG_WIDTH), 
         .C_AXI_ADDR_WIDTH          (C_SLOT_0_AXI_ADDR_WIDTH), 
         .C_AXI_DATA_WIDTH          (C_SLOT_0_AXI_DATA_WIDTH), 
         .C_AXI_ID_WIDTH            (C_SLOT_0_AXI_ID_WIDTH), 
         .C_AXI_PROTOCOL            (C_SLOT_0_AXI_PROTOCOL), 
         .C_SHOW_AXI_IDS            (C_SHOW_AXI_IDS)
      )
		triggerMarker_slot0 (
			    // Outputs
			    .Log_Data_Marked	(Slot_0_Log_Marked),
			    .Log_en_out		(Slot_0_Log_En_Marked),
			    // Inputs
			    .clk		  (core_aclk),
			    .rst_n	  (stream_fifo_rst_n),
			    .trigger  (trigger),
			    .reStart  (Metrics_Cnt_Reset_sync),
			    .Log_Data (Slot_0_Log),
			    .Log_En	  (Slot_0_Log_En)
			    );

     end
      else if(C_ENABLE_EVENT_LOG == 1 && C_EN_TRIGGER == 0) begin :GEN_NO_POST_TRIGGER
      assign Slot_0_Log_Marked = Slot_0_Log;
      assign Slot_0_Log_En_Marked = Slot_0_Log_En;
      end
      endgenerate
 
     //-- Slot 1
     generate
     if((C_NUM_MONITOR_SLOTS > 1)) begin :GEN_SLOT1 

         axi_perf_mon_v5_0_9_mon_fifo
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
           .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S1),
           .C_FIFO_ENABLE             (C_SLOT_1_FIFO_ENABLE) 
          ) mon_fifo_inst_1
          (
           .Mon_clk                   (SLOT_1_clk),
           .Mon_rst_n                 (SLOT_1_Arst_n),
           .Data_In                   (Slot_1_Data_In),
           //.mon_en                    (Metrics_Cnt_En_sync),
           .CORE_ACLK                 (core_aclk),
           .CORE_ARESETN              (core_aresetn),
           .Sync_Data_Out             (Slot_1_Sync_Data_Out),
           .Sync_Data_Valid           (Slot_1_Sync_Data_Valid)
          );

          assign Ext_Event1_Data_In = {ext_event_1_cnt_start,ext_event_1_cnt_stop,ext_event_1};
     
          // External Event1 through monitor FIFO
          axi_perf_mon_v5_0_9_mon_fifo
             #(
               .C_FAMILY                  (C_FAMILY),
               .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
               .C_MON_FIFO_DATA_WIDTH     (3),
               .C_FIFO_ENABLE             (C_EXT_EVENT1_FIFO_ENABLE) 
              ) mon_fifo_ext_event1_inst
              (
               .Mon_clk                   (ext_clk_1),
               .Mon_rst_n                 (ext_rstn_1),
               .Data_In                   (Ext_Event1_Data_In),
               //.mon_en                    (Metrics_Cnt_En_sync),
               .CORE_ACLK                 (core_aclk),
               .CORE_ARESETN              (core_aresetn),
               .Sync_Data_Out             (Ext_Event1_Sync_Data_Out),
               .Sync_Data_Valid           (Ext_Event1_Sync_Data_Valid)
              );

         // External Event1 count enable generation module
         axi_perf_mon_v5_0_9_ext_calc ext_calc_inst1  
            (
              .clk                    (core_aclk),        
              .rst_n                  (core_aresetn),     
              .Ext_Event              (Ext_Event1_Sync_Data_Out[0]),
              .Ext_Event_Start        (Ext_Event1_Sync_Data_Out[2]),
              .Ext_Event_Stop         (Ext_Event1_Sync_Data_Out[1]),
              .Ext_Event_Valid        (Ext_Event1_Sync_Data_Valid ),
              .Metrics_Cnt_En         (Metrics_Cnt_En_sync),
              .Metrics_Cnt_Reset      (Metrics_Cnt_Reset_sync),
              .External_Event_Cnt_En  (External_Event_Cnt_En[1])
            );

          // Metric calculator instance for slot1
          axi_perf_mon_v5_0_9_metric_calc 
          #(
            .C_AXIID                   (C_SLOT_1_AXI_ID_WIDTH    ),
            .C_AXIADDR                 (C_SLOT_1_AXI_ADDR_WIDTH  ),
            .C_AXIDATA                 (C_SLOT_1_AXI_DATA_WIDTH  ),
            .C_AXISDATA                (C_SLOT_1_AXIS_TDATA_WIDTH),
            .C_AXISID                  (C_SLOT_1_AXIS_TID_WIDTH  ),
            .C_AXISDEST                (C_SLOT_1_AXIS_TDEST_WIDTH),
            .C_AXISUSER                (C_SLOT_1_AXIS_TUSER_WIDTH),
            .C_OUTSTAND_DEPTH          (C_MAX_OUTSTAND_DEPTH),
            .C_METRIC_COUNT_WIDTH      (C_METRIC_COUNT_WIDTH),
            .C_MON_FIFO_WIDTH          (C_MON_FIFO_DWIDTH_S1),
            .C_AXI_PROTOCOL            (C_SLOT_1_AXI_PROTOCOL),
            .C_AXI_SUB_PROTOCOL        (C_SLOT_1_AXI_SUB_PROTOCOL)
          ) metric_calc_inst1
          (
            .clk                       (core_aclk ),
            .rst_n                     (core_aresetn),
            .Data_In                   (Slot_1_Sync_Data_Out),
            .Data_Valid                (Slot_1_Sync_Data_Valid), 
            .Metrics_Cnt_En            (Metrics_Cnt_En_sync),
            .Metrics_Cnt_Reset         (Metrics_Cnt_Reset_sync),
            .Use_Ext_Trig              (Use_Ext_Trig_sync),
            .Ext_Trig                  (slot_1_ext_trig),
            .Ext_Trig_Stop             (slot_1_ext_trig_stop),
            .Latency_WID               (Latency_WID),
            .Latency_RID               (Latency_RID),
            .WID_Mask                  (WID_Mask),
            .RID_Mask                  (RID_Mask),
            .En_Id_Based               (En_Id_Based_sync),
            .Wr_Lat_Start              (Wr_Lat_Start    ),  //0 Address Issue 1 Address acceptance
            .Wr_Lat_End                (Wr_Lat_End      ),  //1 First write   0 Last write  
            .Rd_Lat_Start              (Rd_Lat_Start    ),  //0 Address Issue 1 Address acceptance 
            .Rd_Lat_End                (Rd_Lat_End      ),  //1 First Read    0 Last Read
            .Wtrans_Cnt_En             (Wtrans_Cnt_En[1]),
            .Rtrans_Cnt_En             (Rtrans_Cnt_En[1]),
            .Write_Byte_Cnt            (S1_Write_Byte_Cnt),
            .Read_Byte_Cnt             (S1_Read_Byte_Cnt),
            .Write_Beat_Cnt_En         (Write_Beat_Cnt_En[1]),
            .Read_Beat_Cnt_En          (Read_Beat_Cnt_En[1]),
            .Read_Latency              (S1_Read_Latency),
            .Write_Latency             (S1_Write_Latency),
            .Write_Beat_Cnt            (S1_Write_Beat_Cnt),
            .Slv_Wr_Idle_Cnt           (S1_Slv_Wr_Idle_Cnt),
            .Read_Latency_En           (Read_Latency_En[1]),    
            .Write_Latency_En          (Write_Latency_En[1]),   
            .Slv_Wr_Idle_Cnt_En        (Slv_Wr_Idle_Cnt_En[1]), 
            .Mst_Rd_Idle_Cnt_En        (Mst_Rd_Idle_Cnt_En[1]), 
            .Num_BValids_En            (Num_BValids_En[1]),     
            .Num_WLasts_En             (Num_WLasts_En[1]),      
            .Num_RLasts_En             (Num_RLasts_En[1]),      
            .S_Transfer_Cnt_En         (S_Transfer_Cnt_En[1]),
            .S_Packet_Cnt_En           (S_Packet_Cnt_En[1]),  
            .S_Data_Byte_Cnt           (S1_S_Data_Byte_Cnt),
            .S_Position_Byte_Cnt       (S1_S_Position_Byte_Cnt),
            .S_Null_Byte_Cnt           (S1_S_Null_Byte_Cnt),
            .S_Slv_Idle_Cnt_En         (S_Slv_Idle_Cnt_En[1]),
            .S_Mst_Idle_Cnt_En         (S_Mst_Idle_Cnt_En[1]),
            .Max_Write_Latency         (S1_Max_Write_Latency),                   
            .Min_Write_Latency         (S1_Min_Write_Latency),                   
            .Max_Read_Latency          (S1_Max_Read_Latency),                   
            .Min_Read_Latency          (S1_Min_Read_Latency)
          );
     end
     else begin :GEN_NO_SLOT1
         assign S1_Write_Beat_Cnt = 0;
         assign S1_Slv_Wr_Idle_Cnt = 0;
         assign Slot_1_Sync_Data_Out = 0;
         assign S1_Write_Byte_Cnt    = 0;
         assign S1_Read_Byte_Cnt     = 0;
         assign S1_Read_Latency      = 0;
         assign S1_Write_Latency     = 0;
         assign S1_S_Data_Byte_Cnt   = 0;
         assign S1_S_Position_Byte_Cnt = 0;
         assign S1_S_Null_Byte_Cnt     = 0;
         assign Ext_Event1_Sync_Data_Out = 0;
         assign Ext_Event1_Sync_Data_Valid = 0;
         assign S1_Max_Write_Latency  = 0;                  
         assign S1_Min_Write_Latency  = 0;               
         assign S1_Max_Read_Latency   = 0;               
         assign S1_Min_Read_Latency   = 0;
     end
     endgenerate 

    generate    
    if (C_ENABLE_EVENT_LOG == 1 && C_NUM_MONITOR_SLOTS > 1) begin : GEN_FLAGS1

       //Flag Generator instantiation for slot1
         axi_perf_mon_v5_0_9_flags_gen
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S1), 
           .C_LOG_WIDTH               (C_SLOT_1_LOG_WIDTH),
           .C_FLAG_WIDTH              (C_SLOT_1_FLAG_WIDTH), 
           .C_AXI_ADDR_WIDTH          (C_SLOT_1_AXI_ADDR_WIDTH), 
           .C_AXI_DATA_WIDTH          (C_SLOT_1_AXI_DATA_WIDTH), 
           .C_AXI_ID_WIDTH            (C_SLOT_1_AXI_ID_WIDTH), 
           .C_AXI_PROTOCOL            (C_SLOT_1_AXI_PROTOCOL), 
           .C_AXIS_TDATA_WIDTH        (C_SLOT_1_AXIS_TDATA_WIDTH), 
           .C_AXIS_TID_WIDTH          (C_SLOT_1_AXIS_TID_WIDTH), 
           .C_AXIS_TDEST_WIDTH        (C_SLOT_1_AXIS_TDEST_WIDTH), 
           .C_AXIS_TUSER_WIDTH        (C_SLOT_1_AXIS_TUSER_WIDTH),
           .C_SHOW_AXI_IDS            (C_SHOW_AXI_IDS),
           .C_SHOW_AXI_LEN            (C_SHOW_AXI_LEN),
           .C_SHOW_AXIS_TID           (C_SHOW_AXIS_TID),
           .C_SHOW_AXIS_TUSER         (C_SHOW_AXIS_TUSER),
           .C_SHOW_AXIS_TDEST         (C_SHOW_AXIS_TDEST), 
           .C_EN_AXI_DEBUG               (C_EN_AXI_DEBUG) 
          ) flags_generator_inst_1
          (
           .clk                       (core_aclk),
           .rst_n                     (core_aresetn),
           .Data_In                   (Slot_1_Sync_Data_Out),
           .Data_Valid                (Slot_1_Sync_Data_Valid), 
           .Flag_Enable_Reg           (Flag_Enable_Reg),
           .Log_Data                  (Slot_1_Log),
           .Log_En                    (Slot_1_Log_En),
           .Ext_Trig                  (slot_1_ext_trig),
           .Ext_Trig_Stop             (slot_1_ext_trig_stop),
           .Use_Ext_Trig_Log          (Use_Ext_Trig_Log_sync),                
           .Ext_Data_in               (Ext_Event1_Sync_Data_Out),
           .Ext_Data_Valid            (Ext_Event1_Sync_Data_Valid),
           .Ext_Event_Flag_En         (Ext_Event_Flag_En),
           .Ext_Event_Flags           (Ext_Event1_Flags)
          );
    end 
    else begin : GEN_NO_FLAGS1
       assign Slot_1_Log = 0;
       assign Slot_1_Log_En = 1'b0;
       assign Ext_Event1_Flags = 0;
    end 
    endgenerate 
 generate if(C_NUM_MONITOR_SLOTS > 1 && C_ENABLE_EVENT_LOG == 1 && C_EN_TRIGGER == 1) begin : GEN_S1_POST_TRIGGER
//Aligning start and end events of transactions
       axi_perf_mon_v5_0_9_postTriggerMarker 
	    #(
			   // Parameters
			.C_FAMILY                  (C_FAMILY),
         .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S1), 
         .C_LOG_WIDTH               (C_SLOT_1_LOG_WIDTH),
         .C_FLAG_WIDTH              (C_SLOT_N_FLAG_WIDTH), 
         .C_AXI_ADDR_WIDTH          (C_SLOT_1_AXI_ADDR_WIDTH), 
         .C_AXI_DATA_WIDTH          (C_SLOT_1_AXI_DATA_WIDTH), 
         .C_AXI_ID_WIDTH            (C_SLOT_1_AXI_ID_WIDTH), 
         .C_AXI_PROTOCOL            (C_SLOT_1_AXI_PROTOCOL), 
         .C_SHOW_AXI_IDS            (C_SHOW_AXI_IDS)
      )
		triggerMarker_slot1 (
			    // Outputs
			    .Log_Data_Marked	(Slot_1_Log_Marked),
			    .Log_en_out		(Slot_1_Log_En_Marked),
			    // Inputs
			    .clk		  (core_aclk),
			    .rst_n	  (stream_fifo_rst_n),
			    .trigger  (trigger),
			    .reStart  (Metrics_Cnt_Reset_sync),
			    .Log_Data (Slot_1_Log),
			    .Log_En	  (Slot_1_Log_En)
			    );

     end
      else if((C_ENABLE_EVENT_LOG == 1 && C_EN_TRIGGER == 0) || C_NUM_MONITOR_SLOTS < 2 ) begin :GEN_S1_NO_POST_TRIGGER
      assign Slot_1_Log_Marked = Slot_1_Log;
      assign Slot_1_Log_En_Marked = Slot_1_Log_En;
      end
      endgenerate

     //-- Slot 2
     generate
     if((C_NUM_MONITOR_SLOTS > 2)) begin :GEN_SLOT2

         axi_perf_mon_v5_0_9_mon_fifo
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
           .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S2),
           .C_FIFO_ENABLE             (C_SLOT_2_FIFO_ENABLE) 
          ) mon_fifo_inst_2
          (
           .Mon_clk                   (SLOT_2_clk),
           .Mon_rst_n                 (SLOT_2_Arst_n),
           .Data_In                   (Slot_2_Data_In),
           //.mon_en                    (Metrics_Cnt_En_sync),
           .CORE_ACLK                 (core_aclk),
           .CORE_ARESETN              (core_aresetn),
           .Sync_Data_Out             (Slot_2_Sync_Data_Out),
           .Sync_Data_Valid           (Slot_2_Sync_Data_Valid)
          );

          assign Ext_Event2_Data_In = {ext_event_2_cnt_start,ext_event_2_cnt_stop,ext_event_2};
     
          // External Event1 through monitor FIFO
          axi_perf_mon_v5_0_9_mon_fifo
             #(
               .C_FAMILY                  (C_FAMILY),
               .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
               .C_MON_FIFO_DATA_WIDTH     (3),
               .C_FIFO_ENABLE             (C_EXT_EVENT2_FIFO_ENABLE) 
              ) mon_fifo_ext_event2_inst
              (
               .Mon_clk                   (ext_clk_2),
               .Mon_rst_n                 (ext_rstn_2),
               .Data_In                   (Ext_Event2_Data_In),
               //.mon_en                    (Metrics_Cnt_En_sync),
               .CORE_ACLK                 (core_aclk),
               .CORE_ARESETN              (core_aresetn),
               .Sync_Data_Out             (Ext_Event2_Sync_Data_Out),
               .Sync_Data_Valid           (Ext_Event2_Sync_Data_Valid)
              );

         
         // External Event2 count enable generation module
         axi_perf_mon_v5_0_9_ext_calc ext_calc_inst2  
            (
              .clk                    (core_aclk),        
              .rst_n                  (core_aresetn),     
              .Ext_Event              (Ext_Event2_Sync_Data_Out[0]),
              .Ext_Event_Start        (Ext_Event2_Sync_Data_Out[2]),
              .Ext_Event_Stop         (Ext_Event2_Sync_Data_Out[1]),
              .Ext_Event_Valid        (Ext_Event2_Sync_Data_Valid ),
              .Metrics_Cnt_En         (Metrics_Cnt_En_sync),
              .Metrics_Cnt_Reset      (Metrics_Cnt_Reset_sync),
              .External_Event_Cnt_En  (External_Event_Cnt_En[2])
            );

          // Metric calculator instance for slot2
          axi_perf_mon_v5_0_9_metric_calc 
            #(
              .C_AXIID                (C_SLOT_2_AXI_ID_WIDTH    ),
              .C_AXIADDR              (C_SLOT_2_AXI_ADDR_WIDTH  ),
              .C_AXIDATA              (C_SLOT_2_AXI_DATA_WIDTH  ),
              .C_AXISDATA             (C_SLOT_2_AXIS_TDATA_WIDTH),
              .C_AXISID               (C_SLOT_2_AXIS_TID_WIDTH  ),
              .C_AXISDEST             (C_SLOT_2_AXIS_TDEST_WIDTH),
              .C_AXISUSER             (C_SLOT_2_AXIS_TUSER_WIDTH),
              .C_OUTSTAND_DEPTH       (C_MAX_OUTSTAND_DEPTH),
              .C_METRIC_COUNT_WIDTH   (C_METRIC_COUNT_WIDTH),
              .C_MON_FIFO_WIDTH       (C_MON_FIFO_DWIDTH_S2),
              .C_AXI_PROTOCOL         (C_SLOT_2_AXI_PROTOCOL),
              .C_AXI_SUB_PROTOCOL     (C_SLOT_2_AXI_SUB_PROTOCOL)
            ) metric_calc_inst2
            (
              .clk                    (core_aclk ),
              .rst_n                  (core_aresetn),
              .Data_In                (Slot_2_Sync_Data_Out),
              .Data_Valid             (Slot_2_Sync_Data_Valid), 
              .Metrics_Cnt_En         (Metrics_Cnt_En_sync),
              .Metrics_Cnt_Reset      (Metrics_Cnt_Reset_sync),
              .Use_Ext_Trig           (Use_Ext_Trig_sync),
              .Ext_Trig               (slot_2_ext_trig),
              .Ext_Trig_Stop          (slot_2_ext_trig_stop),
              .Latency_WID            (Latency_WID),
              .Latency_RID            (Latency_RID),
              .WID_Mask               (WID_Mask),
              .RID_Mask               (RID_Mask),
              .En_Id_Based            (En_Id_Based_sync),  
              .Wr_Lat_Start           (Wr_Lat_Start),  //0 Address Issue 1 Address acceptance
              .Wr_Lat_End             (Wr_Lat_End),    //1 First write   0 Last write  
              .Rd_Lat_Start           (Rd_Lat_Start),  //0 Address Issue 1 Address acceptance 
              .Rd_Lat_End             (Rd_Lat_End),    //1 First Read    0 Last Read
              .Wtrans_Cnt_En          (Wtrans_Cnt_En[2]),
              .Rtrans_Cnt_En          (Rtrans_Cnt_En[2]),
              .Write_Byte_Cnt         (S2_Write_Byte_Cnt),
              .Read_Byte_Cnt          (S2_Read_Byte_Cnt),
              .Write_Beat_Cnt_En      (Write_Beat_Cnt_En[2]),
              .Read_Beat_Cnt_En       (Read_Beat_Cnt_En[2]),
              .Read_Latency           (S2_Read_Latency),
              .Write_Latency          (S2_Write_Latency),
              .Write_Beat_Cnt         (S2_Write_Beat_Cnt),
              .Slv_Wr_Idle_Cnt        (S2_Slv_Wr_Idle_Cnt),
              .Read_Latency_En        (Read_Latency_En[2]),    
              .Write_Latency_En       (Write_Latency_En[2]),   
              .Slv_Wr_Idle_Cnt_En     (Slv_Wr_Idle_Cnt_En[2]), 
              .Mst_Rd_Idle_Cnt_En     (Mst_Rd_Idle_Cnt_En[2]), 
              .Num_BValids_En         (Num_BValids_En[2]),     
              .Num_WLasts_En          (Num_WLasts_En[2]),      
              .Num_RLasts_En          (Num_RLasts_En[2]),      
              .S_Transfer_Cnt_En      (S_Transfer_Cnt_En[2]),
              .S_Packet_Cnt_En        (S_Packet_Cnt_En[2]),  
              .S_Data_Byte_Cnt        (S2_S_Data_Byte_Cnt),
              .S_Position_Byte_Cnt    (S2_S_Position_Byte_Cnt),
              .S_Null_Byte_Cnt        (S2_S_Null_Byte_Cnt),
              .S_Slv_Idle_Cnt_En      (S_Slv_Idle_Cnt_En[2]),
              .S_Mst_Idle_Cnt_En      (S_Mst_Idle_Cnt_En[2]),
              .Max_Write_Latency      (S2_Max_Write_Latency),                   
              .Min_Write_Latency      (S2_Min_Write_Latency),                   
              .Max_Read_Latency       (S2_Max_Read_Latency),                   
              .Min_Read_Latency       (S2_Min_Read_Latency)
            );
     end
     else begin :GEN_NO_SLOT2
         assign S2_Write_Beat_Cnt = 0;
         assign S2_Slv_Wr_Idle_Cnt = 0;
         assign Slot_2_Sync_Data_Out = 0;
         assign S2_Write_Byte_Cnt    = 0;
         assign S2_Read_Byte_Cnt     = 0;
         assign S2_Read_Latency      = 0;
         assign S2_Write_Latency     = 0;
         assign S2_S_Data_Byte_Cnt   = 0;
         assign S2_S_Position_Byte_Cnt = 0;
         assign S2_S_Null_Byte_Cnt     = 0;
         assign Ext_Event2_Sync_Data_Out = 0;
         assign Ext_Event2_Sync_Data_Valid = 0;
         assign S2_Max_Write_Latency  = 0;                  
         assign S2_Min_Write_Latency  = 0;               
         assign S2_Max_Read_Latency   = 0;               
         assign S2_Min_Read_Latency   = 0;
     end
     endgenerate 

    generate    
    if (C_ENABLE_EVENT_LOG == 1 && C_NUM_MONITOR_SLOTS > 2) begin : GEN_FLAGS2
       //Flag Generator instantiation for slot2
         axi_perf_mon_v5_0_9_flags_gen
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S2), 
           .C_LOG_WIDTH               (C_SLOT_2_LOG_WIDTH),
           .C_FLAG_WIDTH              (C_SLOT_2_FLAG_WIDTH), 
           .C_AXI_ADDR_WIDTH          (C_SLOT_2_AXI_ADDR_WIDTH), 
           .C_AXI_DATA_WIDTH          (C_SLOT_2_AXI_DATA_WIDTH), 
           .C_AXI_ID_WIDTH            (C_SLOT_2_AXI_ID_WIDTH), 
           .C_AXI_PROTOCOL            (C_SLOT_2_AXI_PROTOCOL), 
           .C_AXIS_TDATA_WIDTH        (C_SLOT_2_AXIS_TDATA_WIDTH), 
           .C_AXIS_TID_WIDTH          (C_SLOT_2_AXIS_TID_WIDTH), 
           .C_AXIS_TDEST_WIDTH        (C_SLOT_2_AXIS_TDEST_WIDTH), 
           .C_AXIS_TUSER_WIDTH        (C_SLOT_2_AXIS_TUSER_WIDTH),
           .C_SHOW_AXI_IDS            (C_SHOW_AXI_IDS),
           .C_SHOW_AXI_LEN            (C_SHOW_AXI_LEN),
           .C_SHOW_AXIS_TID           (C_SHOW_AXIS_TID),
           .C_SHOW_AXIS_TUSER         (C_SHOW_AXIS_TUSER),
           .C_SHOW_AXIS_TDEST         (C_SHOW_AXIS_TDEST), 
           .C_EN_AXI_DEBUG               (C_EN_AXI_DEBUG) 
          ) flags_generator_inst_2
          (
           .clk                       (core_aclk),
           .rst_n                     (core_aresetn),
           .Data_In                   (Slot_2_Sync_Data_Out),
           .Data_Valid                (Slot_2_Sync_Data_Valid), 
           .Flag_Enable_Reg           (Flag_Enable_Reg),
           .Ext_Trig                  (slot_2_ext_trig),
           .Ext_Trig_Stop             (slot_2_ext_trig_stop),
           .Use_Ext_Trig_Log          (Use_Ext_Trig_Log_sync),                
           .Log_Data                  (Slot_2_Log),
           .Log_En                    (Slot_2_Log_En),
           .Ext_Data_in               (Ext_Event2_Sync_Data_Out),
           .Ext_Data_Valid            (Ext_Event2_Sync_Data_Valid),
           .Ext_Event_Flag_En         (Ext_Event_Flag_En),
           .Ext_Event_Flags           (Ext_Event2_Flags)
          );

    end 
    else begin : GEN_NO_FLAGS2
       assign Slot_2_Log = 0;
       assign Slot_2_Log_En = 1'b0;
       assign Ext_Event2_Flags = 0;
    end 
    endgenerate
generate if(C_NUM_MONITOR_SLOTS > 2 && C_ENABLE_EVENT_LOG == 1 && C_EN_TRIGGER == 1) begin : GEN_S2_POST_TRIGGER
//Aligning start and end events of transactions
       axi_perf_mon_v5_0_9_postTriggerMarker 
	    #(
			   // Parameters
			.C_FAMILY                  (C_FAMILY),
         .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S2), 
         .C_LOG_WIDTH               (C_SLOT_2_LOG_WIDTH),
         .C_FLAG_WIDTH              (C_SLOT_N_FLAG_WIDTH), 
         .C_AXI_ADDR_WIDTH          (C_SLOT_2_AXI_ADDR_WIDTH), 
         .C_AXI_DATA_WIDTH          (C_SLOT_2_AXI_DATA_WIDTH), 
         .C_AXI_ID_WIDTH            (C_SLOT_2_AXI_ID_WIDTH), 
         .C_AXI_PROTOCOL            (C_SLOT_2_AXI_PROTOCOL), 
         .C_SHOW_AXI_IDS            (C_SHOW_AXI_IDS)
      )
		triggerMarker_slot2 (
			    // Outputs
			    .Log_Data_Marked	(Slot_2_Log_Marked),
			    .Log_en_out		(Slot_2_Log_En_Marked),
			    // Inputs
			    .clk		  (core_aclk),
			    .rst_n	  (stream_fifo_rst_n),
			    .trigger  (trigger),
			    .reStart  (Metrics_Cnt_Reset_sync),
			    .Log_Data (Slot_2_Log),
			    .Log_En	  (Slot_2_Log_En)
			    );

     end
      else if((C_ENABLE_EVENT_LOG == 1 && C_EN_TRIGGER == 0) || C_NUM_MONITOR_SLOTS < 3) begin :GEN_S2_NO_POST_TRIGGER
      assign Slot_2_Log_Marked = Slot_2_Log;
      assign Slot_2_Log_En_Marked = Slot_2_Log_En;
      end
      endgenerate

     //-- Slot 3
     generate
     if((C_NUM_MONITOR_SLOTS > 3)) begin :GEN_SLOT3

         axi_perf_mon_v5_0_9_mon_fifo
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
           .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S3),
           .C_FIFO_ENABLE             (C_SLOT_3_FIFO_ENABLE) 
          ) mon_fifo_inst_3
          (
           .Mon_clk                   (SLOT_3_clk),
           .Mon_rst_n                 (SLOT_3_Arst_n),
           .Data_In                   (Slot_3_Data_In),
           //.mon_en                    (Metrics_Cnt_En_sync),
           .CORE_ACLK                 (core_aclk),
           .CORE_ARESETN              (core_aresetn),
           .Sync_Data_Out             (Slot_3_Sync_Data_Out),
           .Sync_Data_Valid           (Slot_3_Sync_Data_Valid)
          );

          assign Ext_Event3_Data_In = {ext_event_3_cnt_start,ext_event_3_cnt_stop,ext_event_3};
     
          // External Event1 through monitor FIFO
          axi_perf_mon_v5_0_9_mon_fifo
             #(
               .C_FAMILY                  (C_FAMILY),
               .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
               .C_MON_FIFO_DATA_WIDTH     (3),
               .C_FIFO_ENABLE             (C_EXT_EVENT3_FIFO_ENABLE) 
              ) mon_fifo_ext_event3_inst
              (
               .Mon_clk                   (ext_clk_3),
               .Mon_rst_n                 (ext_rstn_3),
               .Data_In                   (Ext_Event3_Data_In),
               //.mon_en                    (Metrics_Cnt_En_sync),
               .CORE_ACLK                 (core_aclk),
               .CORE_ARESETN              (core_aresetn),
               .Sync_Data_Out             (Ext_Event3_Sync_Data_Out),
               .Sync_Data_Valid           (Ext_Event3_Sync_Data_Valid)
              );

         // External Event3 count enable generation module
         axi_perf_mon_v5_0_9_ext_calc ext_calc_inst3  
            (
              .clk                    (core_aclk),        
              .rst_n                  (core_aresetn),     
              .Ext_Event              (Ext_Event3_Sync_Data_Out[0]),
              .Ext_Event_Start        (Ext_Event3_Sync_Data_Out[2]),
              .Ext_Event_Stop         (Ext_Event3_Sync_Data_Out[1]),
              .Ext_Event_Valid        (Ext_Event3_Sync_Data_Valid ),
              .Metrics_Cnt_En         (Metrics_Cnt_En_sync),
              .Metrics_Cnt_Reset      (Metrics_Cnt_Reset_sync),
              .External_Event_Cnt_En  (External_Event_Cnt_En[3])
            );

          // Metric calculator instance for slot3
          axi_perf_mon_v5_0_9_metric_calc 
         #(
           .C_AXIID                   (C_SLOT_3_AXI_ID_WIDTH    ),
           .C_AXIADDR                 (C_SLOT_3_AXI_ADDR_WIDTH  ),
           .C_AXIDATA                 (C_SLOT_3_AXI_DATA_WIDTH  ),
           .C_AXISDATA                (C_SLOT_3_AXIS_TDATA_WIDTH),
           .C_AXISID                  (C_SLOT_3_AXIS_TID_WIDTH  ),
           .C_AXISDEST                (C_SLOT_3_AXIS_TDEST_WIDTH),
           .C_AXISUSER                (C_SLOT_3_AXIS_TUSER_WIDTH),
           .C_OUTSTAND_DEPTH          (C_MAX_OUTSTAND_DEPTH),
           .C_METRIC_COUNT_WIDTH      (C_METRIC_COUNT_WIDTH),
           .C_MON_FIFO_WIDTH          (C_MON_FIFO_DWIDTH_S3),
           .C_AXI_PROTOCOL            (C_SLOT_3_AXI_PROTOCOL),
           .C_AXI_SUB_PROTOCOL        (C_SLOT_3_AXI_SUB_PROTOCOL)
         ) metric_calc_inst3
         (
           .clk                       (core_aclk ),
           .rst_n                     (core_aresetn),
           .Data_In                   (Slot_3_Sync_Data_Out),
           .Data_Valid                (Slot_3_Sync_Data_Valid), 
           .Metrics_Cnt_En            (Metrics_Cnt_En_sync),
           .Metrics_Cnt_Reset         (Metrics_Cnt_Reset_sync),
           .Use_Ext_Trig              (Use_Ext_Trig_sync),
           .Ext_Trig                  (slot_3_ext_trig),
           .Ext_Trig_Stop             (slot_3_ext_trig_stop),
           .Latency_WID               (Latency_WID),
           .Latency_RID               (Latency_RID),
           .WID_Mask                  (WID_Mask),
           .RID_Mask                  (RID_Mask),
           .En_Id_Based               (En_Id_Based_sync),  
           .Wr_Lat_Start              (Wr_Lat_Start    ),  //0 Address Issue 1 Address acceptance
           .Wr_Lat_End                (Wr_Lat_End      ),  //1 First write   0 Last write  
           .Rd_Lat_Start              (Rd_Lat_Start    ),  //0 Address Issue 1 Address acceptance 
           .Rd_Lat_End                (Rd_Lat_End      ),  //1 First Read    0 Last Read
           .Wtrans_Cnt_En             (Wtrans_Cnt_En[3]),
           .Rtrans_Cnt_En             (Rtrans_Cnt_En[3]),
           .Write_Byte_Cnt            (S3_Write_Byte_Cnt),
           .Read_Byte_Cnt             (S3_Read_Byte_Cnt),
           .Write_Beat_Cnt_En         (Write_Beat_Cnt_En[3]),
           .Read_Beat_Cnt_En          (Read_Beat_Cnt_En[3]),
           .Read_Latency              (S3_Read_Latency),
           .Write_Latency             (S3_Write_Latency),
           .Write_Beat_Cnt            (S3_Write_Beat_Cnt),
           .Slv_Wr_Idle_Cnt           (S3_Slv_Wr_Idle_Cnt),
           .Read_Latency_En           (Read_Latency_En[3]),    
           .Write_Latency_En          (Write_Latency_En[3]),   
           .Slv_Wr_Idle_Cnt_En        (Slv_Wr_Idle_Cnt_En[3]), 
           .Mst_Rd_Idle_Cnt_En        (Mst_Rd_Idle_Cnt_En[3]), 
           .Num_BValids_En            (Num_BValids_En[3]),     
           .Num_WLasts_En             (Num_WLasts_En[3]),      
           .Num_RLasts_En             (Num_RLasts_En[3]),      
           .S_Transfer_Cnt_En         (S_Transfer_Cnt_En[3]),
           .S_Packet_Cnt_En           (S_Packet_Cnt_En[3]),  
           .S_Data_Byte_Cnt           (S3_S_Data_Byte_Cnt),
           .S_Position_Byte_Cnt       (S3_S_Position_Byte_Cnt),
           .S_Null_Byte_Cnt           (S3_S_Null_Byte_Cnt),
           .S_Slv_Idle_Cnt_En         (S_Slv_Idle_Cnt_En[3]),
           .S_Mst_Idle_Cnt_En         (S_Mst_Idle_Cnt_En[3]),
           .Max_Write_Latency         (S3_Max_Write_Latency),                   
           .Min_Write_Latency         (S3_Min_Write_Latency),                   
           .Max_Read_Latency          (S3_Max_Read_Latency),                   
           .Min_Read_Latency          (S3_Min_Read_Latency)
         );
     end
     else begin :GEN_NO_SLOT3
         assign S3_Write_Beat_Cnt = 0;
         assign S3_Slv_Wr_Idle_Cnt = 0;
         assign Slot_3_Sync_Data_Out = 0;
         assign S3_Write_Byte_Cnt    = 0;
         assign S3_Read_Byte_Cnt     = 0;
         assign S3_Read_Latency      = 0;
         assign S3_Write_Latency     = 0;
         assign S3_S_Data_Byte_Cnt   = 0;
         assign S3_S_Position_Byte_Cnt = 0;
         assign S3_S_Null_Byte_Cnt     = 0;
         assign Ext_Event3_Sync_Data_Out = 0;
         assign Ext_Event3_Sync_Data_Valid = 0;
         assign S3_Max_Write_Latency  = 0;                  
         assign S3_Min_Write_Latency  = 0;               
         assign S3_Max_Read_Latency   = 0;               
         assign S3_Min_Read_Latency   = 0;
     end
     endgenerate 

    generate    
    if (C_ENABLE_EVENT_LOG == 1 && C_NUM_MONITOR_SLOTS > 3) begin : GEN_FLAGS3
       //Flag Generator instantiation for slot3
         axi_perf_mon_v5_0_9_flags_gen
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S3), 
           .C_LOG_WIDTH               (C_SLOT_3_LOG_WIDTH),
           .C_FLAG_WIDTH              (C_SLOT_3_FLAG_WIDTH), 
           .C_AXI_ADDR_WIDTH          (C_SLOT_3_AXI_ADDR_WIDTH), 
           .C_AXI_DATA_WIDTH          (C_SLOT_3_AXI_DATA_WIDTH), 
           .C_AXI_ID_WIDTH            (C_SLOT_3_AXI_ID_WIDTH), 
           .C_AXI_PROTOCOL            (C_SLOT_3_AXI_PROTOCOL), 
           .C_AXIS_TDATA_WIDTH        (C_SLOT_3_AXIS_TDATA_WIDTH), 
           .C_AXIS_TID_WIDTH          (C_SLOT_3_AXIS_TID_WIDTH), 
           .C_AXIS_TDEST_WIDTH        (C_SLOT_3_AXIS_TDEST_WIDTH), 
           .C_AXIS_TUSER_WIDTH        (C_SLOT_3_AXIS_TUSER_WIDTH),
           .C_SHOW_AXI_IDS            (C_SHOW_AXI_IDS),
           .C_SHOW_AXI_LEN            (C_SHOW_AXI_LEN),
           .C_SHOW_AXIS_TID           (C_SHOW_AXIS_TID),
           .C_SHOW_AXIS_TUSER         (C_SHOW_AXIS_TUSER),
           .C_SHOW_AXIS_TDEST         (C_SHOW_AXIS_TDEST), 
           .C_EN_AXI_DEBUG               (C_EN_AXI_DEBUG) 
          ) flags_generator_inst_3
          (
           .clk                       (core_aclk),
           .rst_n                     (core_aresetn),
           .Data_In                   (Slot_3_Sync_Data_Out),
           .Data_Valid                (Slot_3_Sync_Data_Valid), 
           .Flag_Enable_Reg           (Flag_Enable_Reg),
           .Ext_Trig                  (slot_3_ext_trig),
           .Ext_Trig_Stop             (slot_3_ext_trig_stop),
           .Use_Ext_Trig_Log          (Use_Ext_Trig_Log_sync),                
           .Log_Data                  (Slot_3_Log),
           .Log_En                    (Slot_3_Log_En),
           .Ext_Data_in               (Ext_Event3_Sync_Data_Out),
           .Ext_Data_Valid            (Ext_Event3_Sync_Data_Valid),
           .Ext_Event_Flag_En         (Ext_Event_Flag_En),
           .Ext_Event_Flags           (Ext_Event3_Flags)
          );
    end 
    else begin : GEN_NO_FLAGS3
       assign Slot_3_Log = 0;
       assign Slot_3_Log_En = 1'b0;
       assign Ext_Event3_Flags = 0;
    end 
    endgenerate
 generate if(C_NUM_MONITOR_SLOTS > 3 && C_ENABLE_EVENT_LOG == 1 && C_EN_TRIGGER == 1) begin : GEN_S3_POST_TRIGGER
//Aligning start and end events of transactions
       axi_perf_mon_v5_0_9_postTriggerMarker 
	    #(
			   // Parameters
			.C_FAMILY                  (C_FAMILY),
         .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S3), 
         .C_LOG_WIDTH               (C_SLOT_3_LOG_WIDTH),
         .C_FLAG_WIDTH              (C_SLOT_N_FLAG_WIDTH), 
         .C_AXI_ADDR_WIDTH          (C_SLOT_3_AXI_ADDR_WIDTH), 
         .C_AXI_DATA_WIDTH          (C_SLOT_3_AXI_DATA_WIDTH), 
         .C_AXI_ID_WIDTH            (C_SLOT_3_AXI_ID_WIDTH), 
         .C_AXI_PROTOCOL            (C_SLOT_3_AXI_PROTOCOL), 
         .C_SHOW_AXI_IDS            (C_SHOW_AXI_IDS)
      )
		triggerMarker_slot3 (
			    // Outputs
			    .Log_Data_Marked	(Slot_3_Log_Marked),
			    .Log_en_out		(Slot_3_Log_En_Marked),
			    // Inputs
			    .clk		  (core_aclk),
			    .rst_n	  (stream_fifo_rst_n),
			    .trigger  (trigger),
			    .reStart  (Metrics_Cnt_Reset_sync),
			    .Log_Data (Slot_3_Log),
			    .Log_En	  (Slot_3_Log_En)
			    );

     end
      else if((C_ENABLE_EVENT_LOG == 1 && C_EN_TRIGGER == 0) || C_NUM_MONITOR_SLOTS < 4) begin :GEN_S3_NO_POST_TRIGGER
      assign Slot_3_Log_Marked = Slot_3_Log;
      assign Slot_3_Log_En_Marked = Slot_3_Log_En;
      end
      endgenerate

     //-- Slot 4
     generate
     if((C_NUM_MONITOR_SLOTS > 4)) begin :GEN_SLOT4

         axi_perf_mon_v5_0_9_mon_fifo
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
           .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S4),
           .C_FIFO_ENABLE             (C_SLOT_4_FIFO_ENABLE) 
          ) mon_fifo_inst_4
          (
           .Mon_clk                   (SLOT_4_clk),
           .Mon_rst_n                 (SLOT_4_Arst_n),
           .Data_In                   (Slot_4_Data_In),
           //.mon_en                    (Metrics_Cnt_En_sync),
           .CORE_ACLK                 (core_aclk),
           .CORE_ARESETN              (core_aresetn),
           .Sync_Data_Out             (Slot_4_Sync_Data_Out),
           .Sync_Data_Valid           (Slot_4_Sync_Data_Valid)
          );

          assign Ext_Event4_Data_In = {ext_event_4_cnt_start,ext_event_4_cnt_stop,ext_event_4};
     
          // External Event1 through monitor FIFO
          axi_perf_mon_v5_0_9_mon_fifo
             #(
               .C_FAMILY                  (C_FAMILY),
               .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
               .C_MON_FIFO_DATA_WIDTH     (3),
               .C_FIFO_ENABLE             (C_EXT_EVENT4_FIFO_ENABLE) 
              ) mon_fifo_ext_event4_inst
              (
               .Mon_clk                   (ext_clk_4),
               .Mon_rst_n                 (ext_rstn_4),
               .Data_In                   (Ext_Event4_Data_In),
               //.mon_en                    (Metrics_Cnt_En_sync),
               .CORE_ACLK                 (core_aclk),
               .CORE_ARESETN              (core_aresetn),
               .Sync_Data_Out             (Ext_Event4_Sync_Data_Out),
               .Sync_Data_Valid           (Ext_Event4_Sync_Data_Valid)
              );


          // External Event4 count enable generation module
         axi_perf_mon_v5_0_9_ext_calc ext_calc_inst4  
            (
              .clk                    (core_aclk),        
              .rst_n                  (core_aresetn),     
              .Ext_Event              (Ext_Event4_Sync_Data_Out[0]),
              .Ext_Event_Start        (Ext_Event4_Sync_Data_Out[2]),
              .Ext_Event_Stop         (Ext_Event4_Sync_Data_Out[1]),
              .Ext_Event_Valid        (Ext_Event4_Sync_Data_Valid ),
              .Metrics_Cnt_En         (Metrics_Cnt_En_sync),
              .Metrics_Cnt_Reset      (Metrics_Cnt_Reset_sync),
              .External_Event_Cnt_En  (External_Event_Cnt_En[4])
            );

         // Metric calculator instance for slot4
          axi_perf_mon_v5_0_9_metric_calc 
             #(
            .C_AXIID                   (C_SLOT_4_AXI_ID_WIDTH    ),
            .C_AXIADDR                 (C_SLOT_4_AXI_ADDR_WIDTH  ),
            .C_AXIDATA                 (C_SLOT_4_AXI_DATA_WIDTH  ),
            .C_AXISDATA                (C_SLOT_4_AXIS_TDATA_WIDTH),
            .C_AXISID                  (C_SLOT_4_AXIS_TID_WIDTH  ),
            .C_AXISDEST                (C_SLOT_4_AXIS_TDEST_WIDTH),
            .C_AXISUSER                (C_SLOT_4_AXIS_TUSER_WIDTH),
            .C_OUTSTAND_DEPTH          (C_MAX_OUTSTAND_DEPTH),
            .C_METRIC_COUNT_WIDTH      (C_METRIC_COUNT_WIDTH),
            .C_MON_FIFO_WIDTH          (C_MON_FIFO_DWIDTH_S4),
            .C_AXI_PROTOCOL            (C_SLOT_4_AXI_PROTOCOL),
            .C_AXI_SUB_PROTOCOL        (C_SLOT_4_AXI_SUB_PROTOCOL)
             ) metric_calc_inst4
          (
            .clk                       (core_aclk ),
            .rst_n                     (core_aresetn),
            .Data_In                   (Slot_4_Sync_Data_Out),
            .Data_Valid                (Slot_4_Sync_Data_Valid), 
            .Metrics_Cnt_En            (Metrics_Cnt_En_sync),
            .Metrics_Cnt_Reset         (Metrics_Cnt_Reset_sync),
            .Use_Ext_Trig              (Use_Ext_Trig_sync),
            .Ext_Trig                  (slot_4_ext_trig),
            .Ext_Trig_Stop             (slot_4_ext_trig_stop),
            .Latency_WID               (Latency_WID),
            .Latency_RID               (Latency_RID),
            .WID_Mask                  (WID_Mask),
            .RID_Mask                  (RID_Mask),
            .En_Id_Based               (En_Id_Based_sync),  
            .Wr_Lat_Start              (Wr_Lat_Start    ),  //0 Address Issue 1 Address acceptance
            .Wr_Lat_End                (Wr_Lat_End      ),  //1 First write   0 Last write  
            .Rd_Lat_Start              (Rd_Lat_Start    ),  //0 Address Issue 1 Address acceptance 
            .Rd_Lat_End                (Rd_Lat_End      ),  //1 First Read    0 Last Read
            .Wtrans_Cnt_En             (Wtrans_Cnt_En[4]),
            .Rtrans_Cnt_En             (Rtrans_Cnt_En[4]),
            .Write_Byte_Cnt            (S4_Write_Byte_Cnt),
            .Read_Byte_Cnt             (S4_Read_Byte_Cnt),
            .Write_Beat_Cnt_En         (Write_Beat_Cnt_En[4]),
            .Read_Beat_Cnt_En          (Read_Beat_Cnt_En[4]),
            .Read_Latency              (S4_Read_Latency),
            .Write_Latency             (S4_Write_Latency),
            .Write_Beat_Cnt            (S4_Write_Beat_Cnt),
            .Slv_Wr_Idle_Cnt           (S4_Slv_Wr_Idle_Cnt),
            .Read_Latency_En           (Read_Latency_En[4]),    
            .Write_Latency_En          (Write_Latency_En[4]),   
            .Slv_Wr_Idle_Cnt_En        (Slv_Wr_Idle_Cnt_En[4]), 
            .Mst_Rd_Idle_Cnt_En        (Mst_Rd_Idle_Cnt_En[4]), 
            .Num_BValids_En            (Num_BValids_En[4]),     
            .Num_WLasts_En             (Num_WLasts_En[4]),      
            .Num_RLasts_En             (Num_RLasts_En[4]),      
            .S_Transfer_Cnt_En         (S_Transfer_Cnt_En[4]),
            .S_Packet_Cnt_En           (S_Packet_Cnt_En[4]),  
            .S_Data_Byte_Cnt           (S4_S_Data_Byte_Cnt),
            .S_Position_Byte_Cnt       (S4_S_Position_Byte_Cnt),
            .S_Null_Byte_Cnt           (S4_S_Null_Byte_Cnt),
            .S_Slv_Idle_Cnt_En         (S_Slv_Idle_Cnt_En[4]),
            .S_Mst_Idle_Cnt_En         (S_Mst_Idle_Cnt_En[4]),
            .Max_Write_Latency         (S4_Max_Write_Latency),                   
            .Min_Write_Latency         (S4_Min_Write_Latency),                   
            .Max_Read_Latency          (S4_Max_Read_Latency),                   
            .Min_Read_Latency          (S4_Min_Read_Latency)
          );
     end
     else begin :GEN_NO_SLOT4
         assign S4_Write_Beat_Cnt = 0;
         assign S4_Slv_Wr_Idle_Cnt = 0;
         assign Slot_4_Sync_Data_Out = 0;
         assign S4_Write_Byte_Cnt    = 0;
         assign S4_Read_Byte_Cnt     = 0;
         assign S4_Read_Latency      = 0;
         assign S4_Write_Latency     = 0;
         assign S4_S_Data_Byte_Cnt   = 0;
         assign S4_S_Position_Byte_Cnt = 0;
         assign S4_S_Null_Byte_Cnt     = 0;
         assign Ext_Event4_Sync_Data_Out = 0;
         assign Ext_Event4_Sync_Data_Valid = 0;
         assign S4_Max_Write_Latency  = 0;                  
         assign S4_Min_Write_Latency  = 0;               
         assign S4_Max_Read_Latency   = 0;               
         assign S4_Min_Read_Latency   = 0;
     end
     endgenerate 

    generate    
    if (C_ENABLE_EVENT_LOG == 1 && C_NUM_MONITOR_SLOTS > 4) begin : GEN_FLAGS4
                //Flag Generator instantiation for slot4
         axi_perf_mon_v5_0_9_flags_gen
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S4), 
           .C_LOG_WIDTH               (C_SLOT_4_LOG_WIDTH),
           .C_FLAG_WIDTH              (C_SLOT_4_FLAG_WIDTH), 
           .C_AXI_ADDR_WIDTH          (C_SLOT_4_AXI_ADDR_WIDTH), 
           .C_AXI_DATA_WIDTH          (C_SLOT_4_AXI_DATA_WIDTH), 
           .C_AXI_ID_WIDTH            (C_SLOT_4_AXI_ID_WIDTH), 
           .C_AXI_PROTOCOL            (C_SLOT_4_AXI_PROTOCOL), 
           .C_AXIS_TDATA_WIDTH        (C_SLOT_4_AXIS_TDATA_WIDTH), 
           .C_AXIS_TID_WIDTH          (C_SLOT_4_AXIS_TID_WIDTH), 
           .C_AXIS_TDEST_WIDTH        (C_SLOT_4_AXIS_TDEST_WIDTH), 
           .C_AXIS_TUSER_WIDTH        (C_SLOT_4_AXIS_TUSER_WIDTH),
           .C_SHOW_AXI_IDS            (C_SHOW_AXI_IDS),
           .C_SHOW_AXI_LEN            (C_SHOW_AXI_LEN),
           .C_SHOW_AXIS_TID           (C_SHOW_AXIS_TID),
           .C_SHOW_AXIS_TUSER         (C_SHOW_AXIS_TUSER),
           .C_SHOW_AXIS_TDEST         (C_SHOW_AXIS_TDEST), 
           .C_EN_AXI_DEBUG               (C_EN_AXI_DEBUG) 
          ) flags_generator_inst_4
          (
           .clk                       (core_aclk),
           .rst_n                     (core_aresetn),
           .Data_In                   (Slot_4_Sync_Data_Out),
           .Data_Valid                (Slot_4_Sync_Data_Valid), 
           .Flag_Enable_Reg           (Flag_Enable_Reg),
           .Ext_Trig                  (slot_4_ext_trig),
           .Ext_Trig_Stop             (slot_4_ext_trig_stop),
           .Use_Ext_Trig_Log          (Use_Ext_Trig_Log_sync),                
           .Log_Data                  (Slot_4_Log),
           .Log_En                    (Slot_4_Log_En),
           .Ext_Data_in               (Ext_Event4_Sync_Data_Out),
           .Ext_Data_Valid            (Ext_Event4_Sync_Data_Valid),
           .Ext_Event_Flag_En         (Ext_Event_Flag_En),
           .Ext_Event_Flags           (Ext_Event4_Flags)
          );

    end 
    else begin : GEN_NO_FLAGS4
       assign Slot_4_Log = 0;
       assign Slot_4_Log_En = 1'b0;
       assign Ext_Event4_Flags = 0;
    end 
    endgenerate
 generate if(C_NUM_MONITOR_SLOTS > 4 && C_ENABLE_EVENT_LOG == 1 && C_EN_TRIGGER == 1) begin : GEN_S4_POST_TRIGGER
//Aligning start and end events of transactions
       axi_perf_mon_v5_0_9_postTriggerMarker 
	    #(
			   // Parameters
			.C_FAMILY                  (C_FAMILY),
         .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S4), 
         .C_LOG_WIDTH               (C_SLOT_4_LOG_WIDTH),
         .C_FLAG_WIDTH              (C_SLOT_N_FLAG_WIDTH), 
         .C_AXI_ADDR_WIDTH          (C_SLOT_4_AXI_ADDR_WIDTH), 
         .C_AXI_DATA_WIDTH          (C_SLOT_4_AXI_DATA_WIDTH), 
         .C_AXI_ID_WIDTH            (C_SLOT_4_AXI_ID_WIDTH), 
         .C_AXI_PROTOCOL            (C_SLOT_4_AXI_PROTOCOL), 
         .C_SHOW_AXI_IDS            (C_SHOW_AXI_IDS)
      )
		triggerMarker_slot4 (
			    // Outputs
			    .Log_Data_Marked	(Slot_4_Log_Marked),
			    .Log_en_out		(Slot_4_Log_En_Marked),
			    // Inputs
			    .clk		  (core_aclk),
			    .rst_n	  (stream_fifo_rst_n),
			    .trigger  (trigger),
			    .reStart  (Metrics_Cnt_Reset_sync),
			    .Log_Data (Slot_4_Log),
			    .Log_En	  (Slot_4_Log_En)
			    );

     end
      else if((C_ENABLE_EVENT_LOG == 1 && C_EN_TRIGGER == 0) || C_NUM_MONITOR_SLOTS < 5) begin :GEN_S4_NO_POST_TRIGGER
      assign Slot_4_Log_Marked = Slot_4_Log;
      assign Slot_4_Log_En_Marked = Slot_4_Log_En;
      end
      endgenerate
     //-- Slot 5
     generate
     if((C_NUM_MONITOR_SLOTS > 5)) begin :GEN_SLOT5

         axi_perf_mon_v5_0_9_mon_fifo
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
           .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S5),
           .C_FIFO_ENABLE             (C_SLOT_5_FIFO_ENABLE) 
          ) mon_fifo_inst_5
          (
           .Mon_clk                   (SLOT_5_clk),
           .Mon_rst_n                 (SLOT_5_Arst_n),
           .Data_In                   (Slot_5_Data_In),
           //.mon_en                    (Metrics_Cnt_En_sync),
           .CORE_ACLK                 (core_aclk),
           .CORE_ARESETN              (core_aresetn),
           .Sync_Data_Out             (Slot_5_Sync_Data_Out),
           .Sync_Data_Valid           (Slot_5_Sync_Data_Valid)
          );
         
        assign Ext_Event5_Data_In = {ext_event_5_cnt_start,ext_event_5_cnt_stop,ext_event_5};
     
         // External Event1 through monitor FIFO
         axi_perf_mon_v5_0_9_mon_fifo
             #(
               .C_FAMILY                  (C_FAMILY),
               .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
               .C_MON_FIFO_DATA_WIDTH     (3),
               .C_FIFO_ENABLE             (C_EXT_EVENT5_FIFO_ENABLE) 
              ) mon_fifo_ext_event5_inst
              (
               .Mon_clk                   (ext_clk_5),
               .Mon_rst_n                 (ext_rstn_5),
               .Data_In                   (Ext_Event5_Data_In),
               //.mon_en                    (Metrics_Cnt_En_sync),
               .CORE_ACLK                 (core_aclk),
               .CORE_ARESETN              (core_aresetn),
               .Sync_Data_Out             (Ext_Event5_Sync_Data_Out),
               .Sync_Data_Valid           (Ext_Event5_Sync_Data_Valid)
              );

         // External Event5 count enable generation module
         axi_perf_mon_v5_0_9_ext_calc ext_calc_inst5  
            (
              .clk                    (core_aclk),        
              .rst_n                  (core_aresetn),     
              .Ext_Event              (Ext_Event5_Sync_Data_Out[0]),
              .Ext_Event_Start        (Ext_Event5_Sync_Data_Out[2]),
              .Ext_Event_Stop         (Ext_Event5_Sync_Data_Out[1]),
              .Ext_Event_Valid        (Ext_Event5_Sync_Data_Valid ),
              .Metrics_Cnt_En         (Metrics_Cnt_En_sync),
              .Metrics_Cnt_Reset      (Metrics_Cnt_Reset_sync),
              .External_Event_Cnt_En  (External_Event_Cnt_En[5])
            );

         // Metric calculator instance for slot5
          axi_perf_mon_v5_0_9_metric_calc 
          #(
            .C_AXIID                   (C_SLOT_5_AXI_ID_WIDTH    ),
            .C_AXIADDR                 (C_SLOT_5_AXI_ADDR_WIDTH  ),
            .C_AXIDATA                 (C_SLOT_5_AXI_DATA_WIDTH  ),
            .C_AXISDATA                (C_SLOT_5_AXIS_TDATA_WIDTH),
            .C_AXISID                  (C_SLOT_5_AXIS_TID_WIDTH  ),
            .C_AXISDEST                (C_SLOT_5_AXIS_TDEST_WIDTH),
            .C_AXISUSER                (C_SLOT_5_AXIS_TUSER_WIDTH),
            .C_OUTSTAND_DEPTH          (C_MAX_OUTSTAND_DEPTH),
            .C_METRIC_COUNT_WIDTH      (C_METRIC_COUNT_WIDTH),
            .C_MON_FIFO_WIDTH          (C_MON_FIFO_DWIDTH_S5),
            .C_AXI_PROTOCOL            (C_SLOT_5_AXI_PROTOCOL),
            .C_AXI_SUB_PROTOCOL        (C_SLOT_5_AXI_SUB_PROTOCOL)
          ) metric_calc_inst5
          (
            .clk                       (core_aclk ),
            .rst_n                     (core_aresetn),
            .Data_In                   (Slot_5_Sync_Data_Out),
            .Data_Valid                (Slot_5_Sync_Data_Valid), 
            .Metrics_Cnt_En            (Metrics_Cnt_En_sync),
            .Metrics_Cnt_Reset         (Metrics_Cnt_Reset_sync),
            .Use_Ext_Trig              (Use_Ext_Trig_sync),
            .Ext_Trig                  (slot_5_ext_trig),
            .Ext_Trig_Stop             (slot_5_ext_trig_stop),
            .Latency_WID               (Latency_WID),
            .Latency_RID               (Latency_RID),
            .WID_Mask                  (WID_Mask),
            .RID_Mask                  (RID_Mask),
            .En_Id_Based               (En_Id_Based_sync),  
            .Wr_Lat_Start              (Wr_Lat_Start),  //0 Address Issue 1 Address acceptance
            .Wr_Lat_End                (Wr_Lat_End),  //1 First write   0 Last write  
            .Rd_Lat_Start              (Rd_Lat_Start),  //0 Address Issue 1 Address acceptance 
            .Rd_Lat_End                (Rd_Lat_End),  //1 First Read    0 Last Read
            .Wtrans_Cnt_En             (Wtrans_Cnt_En[5]),
            .Rtrans_Cnt_En             (Rtrans_Cnt_En[5]),
            .Write_Byte_Cnt            (S5_Write_Byte_Cnt),
            .Read_Byte_Cnt             (S5_Read_Byte_Cnt),
            .Write_Beat_Cnt_En         (Write_Beat_Cnt_En[5]),
            .Read_Beat_Cnt_En          (Read_Beat_Cnt_En[5]),
            .Read_Latency              (S5_Read_Latency),
            .Write_Latency             (S5_Write_Latency),
            .Write_Beat_Cnt            (S5_Write_Beat_Cnt),
            .Slv_Wr_Idle_Cnt           (S5_Slv_Wr_Idle_Cnt),
            .Read_Latency_En           (Read_Latency_En[5]),    
            .Write_Latency_En          (Write_Latency_En[5]),   
            .Slv_Wr_Idle_Cnt_En        (Slv_Wr_Idle_Cnt_En[5]), 
            .Mst_Rd_Idle_Cnt_En        (Mst_Rd_Idle_Cnt_En[5]), 
            .Num_BValids_En            (Num_BValids_En[5]),     
            .Num_WLasts_En             (Num_WLasts_En[5]),      
            .Num_RLasts_En             (Num_RLasts_En[5]),      
            .S_Transfer_Cnt_En         (S_Transfer_Cnt_En[5]),
            .S_Packet_Cnt_En           (S_Packet_Cnt_En[5]),  
            .S_Data_Byte_Cnt           (S5_S_Data_Byte_Cnt),
            .S_Position_Byte_Cnt       (S5_S_Position_Byte_Cnt),
            .S_Null_Byte_Cnt           (S5_S_Null_Byte_Cnt),
            .S_Slv_Idle_Cnt_En         (S_Slv_Idle_Cnt_En[5]),
            .S_Mst_Idle_Cnt_En         (S_Mst_Idle_Cnt_En[5]),
            .Max_Write_Latency         (S5_Max_Write_Latency),                   
            .Min_Write_Latency         (S5_Min_Write_Latency),                   
            .Max_Read_Latency          (S5_Max_Read_Latency),                   
            .Min_Read_Latency          (S5_Min_Read_Latency)
          );
     end
     else begin :GEN_NO_SLOT5
         assign S5_Write_Beat_Cnt = 0;
         assign S5_Slv_Wr_Idle_Cnt = 0;
         assign Slot_5_Sync_Data_Out = 0;
         assign S5_Write_Byte_Cnt    = 0;
         assign S5_Read_Byte_Cnt     = 0;
         assign S5_Read_Latency      = 0;
         assign S5_Write_Latency     = 0;
         assign S5_S_Data_Byte_Cnt   = 0;
         assign S5_S_Position_Byte_Cnt = 0;
         assign S5_S_Null_Byte_Cnt     = 0;
         assign Ext_Event5_Sync_Data_Out = 0;
         assign Ext_Event5_Sync_Data_Valid = 0;
         assign S5_Max_Write_Latency  = 0;                  
         assign S5_Min_Write_Latency  = 0;               
         assign S5_Max_Read_Latency   = 0;               
         assign S5_Min_Read_Latency   = 0;
     end
     endgenerate 


    generate    
    if (C_ENABLE_EVENT_LOG == 1 && C_NUM_MONITOR_SLOTS > 5) begin : GEN_FLAGS5
         //Flag Generator instantiation for slot5
         axi_perf_mon_v5_0_9_flags_gen
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S5), 
           .C_LOG_WIDTH               (C_SLOT_5_LOG_WIDTH),
           .C_FLAG_WIDTH              (C_SLOT_5_FLAG_WIDTH), 
           .C_AXI_ADDR_WIDTH          (C_SLOT_5_AXI_ADDR_WIDTH), 
           .C_AXI_DATA_WIDTH          (C_SLOT_5_AXI_DATA_WIDTH), 
           .C_AXI_ID_WIDTH            (C_SLOT_5_AXI_ID_WIDTH), 
           .C_AXI_PROTOCOL            (C_SLOT_5_AXI_PROTOCOL), 
           .C_AXIS_TDATA_WIDTH        (C_SLOT_5_AXIS_TDATA_WIDTH), 
           .C_AXIS_TID_WIDTH          (C_SLOT_5_AXIS_TID_WIDTH), 
           .C_AXIS_TDEST_WIDTH        (C_SLOT_5_AXIS_TDEST_WIDTH), 
           .C_AXIS_TUSER_WIDTH        (C_SLOT_5_AXIS_TUSER_WIDTH),
           .C_SHOW_AXI_IDS            (C_SHOW_AXI_IDS),
           .C_SHOW_AXI_LEN            (C_SHOW_AXI_LEN),
           .C_SHOW_AXIS_TID           (C_SHOW_AXIS_TID),
           .C_SHOW_AXIS_TUSER         (C_SHOW_AXIS_TUSER),
           .C_SHOW_AXIS_TDEST         (C_SHOW_AXIS_TDEST), 
           .C_EN_AXI_DEBUG               (C_EN_AXI_DEBUG) 
          ) flags_generator_inst_5
          (
           .clk                       (core_aclk),
           .rst_n                     (core_aresetn),
           .Data_In                   (Slot_5_Sync_Data_Out),
           .Data_Valid                (Slot_5_Sync_Data_Valid), 
           .Flag_Enable_Reg           (Flag_Enable_Reg),
           .Ext_Trig                  (slot_5_ext_trig),
           .Ext_Trig_Stop             (slot_5_ext_trig_stop),
           .Use_Ext_Trig_Log          (Use_Ext_Trig_Log_sync),                 
           .Log_Data                  (Slot_5_Log),
           .Log_En                    (Slot_5_Log_En),
           .Ext_Data_in               (Ext_Event5_Sync_Data_Out),
           .Ext_Data_Valid            (Ext_Event5_Sync_Data_Valid),
           .Ext_Event_Flag_En         (Ext_Event_Flag_En),
           .Ext_Event_Flags           (Ext_Event5_Flags)
          );

    end 
    else begin : GEN_NO_FLAGS5
       assign Slot_5_Log = 0;
       assign Slot_5_Log_En = 1'b0;
       assign Ext_Event5_Flags = 0;
    end 
    endgenerate
generate if(C_NUM_MONITOR_SLOTS > 5 && C_ENABLE_EVENT_LOG == 1 && C_EN_TRIGGER == 1) begin : GEN_S5_POST_TRIGGER
//Aligning start and end events of transactions
       axi_perf_mon_v5_0_9_postTriggerMarker 
	    #(
			   // Parameters
			.C_FAMILY                  (C_FAMILY),
         .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S5), 
         .C_LOG_WIDTH               (C_SLOT_5_LOG_WIDTH),
         .C_FLAG_WIDTH              (C_SLOT_N_FLAG_WIDTH), 
         .C_AXI_ADDR_WIDTH          (C_SLOT_5_AXI_ADDR_WIDTH), 
         .C_AXI_DATA_WIDTH          (C_SLOT_5_AXI_DATA_WIDTH), 
         .C_AXI_ID_WIDTH            (C_SLOT_5_AXI_ID_WIDTH), 
         .C_AXI_PROTOCOL            (C_SLOT_5_AXI_PROTOCOL), 
         .C_SHOW_AXI_IDS            (C_SHOW_AXI_IDS)
      )
		triggerMarker_slot5 (
			    // Outputs
			    .Log_Data_Marked	(Slot_5_Log_Marked),
			    .Log_en_out		(Slot_5_Log_En_Marked),
			    // Inputs
			    .clk		  (core_aclk),
			    .rst_n	  (stream_fifo_rst_n),
			    .trigger  (trigger),
			    .reStart  (Metrics_Cnt_Reset_sync),
			    .Log_Data (Slot_5_Log),
			    .Log_En	  (Slot_5_Log_En)
			    );

     end
      else if((C_ENABLE_EVENT_LOG == 1 && C_EN_TRIGGER == 0) || C_NUM_MONITOR_SLOTS < 6) begin :GEN_S5_NO_POST_TRIGGER
      assign Slot_5_Log_Marked = Slot_5_Log;
      assign Slot_5_Log_En_Marked = Slot_5_Log_En;
      end
      endgenerate

     //-- Slot 6
     generate
     if((C_NUM_MONITOR_SLOTS > 6)) begin :GEN_SLOT6

         axi_perf_mon_v5_0_9_mon_fifo
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
           .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S6),
           .C_FIFO_ENABLE             (C_SLOT_6_FIFO_ENABLE) 
          ) mon_fifo_inst_6
          (
           .Mon_clk                   (SLOT_6_clk),
           .Mon_rst_n                 (SLOT_6_Arst_n),
           .Data_In                   (Slot_6_Data_In),
           //.mon_en                    (Metrics_Cnt_En_sync),
           .CORE_ACLK                 (core_aclk),
           .CORE_ARESETN              (core_aresetn),
           .Sync_Data_Out             (Slot_6_Sync_Data_Out),
           .Sync_Data_Valid           (Slot_6_Sync_Data_Valid)
          );

          assign Ext_Event6_Data_In = {ext_event_6_cnt_start,ext_event_6_cnt_stop,ext_event_6};
     
          // External Event1 through monitor FIFO
          axi_perf_mon_v5_0_9_mon_fifo
             #(
               .C_FAMILY                  (C_FAMILY),
               .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
               .C_MON_FIFO_DATA_WIDTH     (3),
               .C_FIFO_ENABLE             (C_EXT_EVENT6_FIFO_ENABLE) 
              ) mon_fifo_ext_event6_inst
              (
               .Mon_clk                   (ext_clk_6),
               .Mon_rst_n                 (ext_rstn_6),
               .Data_In                   (Ext_Event6_Data_In),
               //.mon_en                    (Metrics_Cnt_En_sync),
               .CORE_ACLK                 (core_aclk),
               .CORE_ARESETN              (core_aresetn),
               .Sync_Data_Out             (Ext_Event6_Sync_Data_Out),
               .Sync_Data_Valid           (Ext_Event6_Sync_Data_Valid)
              );

        
         // External Event6 count enable generation module
         axi_perf_mon_v5_0_9_ext_calc ext_calc_inst6  
            (
              .clk                    (core_aclk),        
              .rst_n                  (core_aresetn),     
              .Ext_Event              (Ext_Event6_Sync_Data_Out[0]),
              .Ext_Event_Start        (Ext_Event6_Sync_Data_Out[2]),
              .Ext_Event_Stop         (Ext_Event6_Sync_Data_Out[1]),
              .Ext_Event_Valid        (Ext_Event6_Sync_Data_Valid ),
              .Metrics_Cnt_En         (Metrics_Cnt_En_sync),
              .Metrics_Cnt_Reset      (Metrics_Cnt_Reset_sync),
              .External_Event_Cnt_En  (External_Event_Cnt_En[6])
            );

         // Metric calculator instance for slot6
         axi_perf_mon_v5_0_9_metric_calc 
          #(
            .C_AXIID                   (C_SLOT_6_AXI_ID_WIDTH    ),
            .C_AXIADDR                 (C_SLOT_6_AXI_ADDR_WIDTH  ),
            .C_AXIDATA                 (C_SLOT_6_AXI_DATA_WIDTH  ),
            .C_AXISDATA                (C_SLOT_6_AXIS_TDATA_WIDTH),
            .C_AXISID                  (C_SLOT_6_AXIS_TID_WIDTH  ),
            .C_AXISDEST                (C_SLOT_6_AXIS_TDEST_WIDTH),
            .C_AXISUSER                (C_SLOT_6_AXIS_TUSER_WIDTH),
            .C_OUTSTAND_DEPTH          (C_MAX_OUTSTAND_DEPTH),
            .C_METRIC_COUNT_WIDTH      (C_METRIC_COUNT_WIDTH),
            .C_MON_FIFO_WIDTH          (C_MON_FIFO_DWIDTH_S6),
            .C_AXI_PROTOCOL            (C_SLOT_6_AXI_PROTOCOL),
            .C_AXI_SUB_PROTOCOL        (C_SLOT_6_AXI_SUB_PROTOCOL)
          ) metric_calc_inst6
          (
            .clk                       (core_aclk ),
            .rst_n                     (core_aresetn),
            .Data_In                   (Slot_6_Sync_Data_Out),
            .Data_Valid                (Slot_6_Sync_Data_Valid), 
            .Metrics_Cnt_En            (Metrics_Cnt_En_sync),
            .Metrics_Cnt_Reset         (Metrics_Cnt_Reset_sync),
            .Use_Ext_Trig              (Use_Ext_Trig_sync),
            .Ext_Trig                  (slot_6_ext_trig),
            .Ext_Trig_Stop             (slot_6_ext_trig_stop),
            .Latency_WID               (Latency_WID),
            .Latency_RID               (Latency_RID),
            .WID_Mask                  (WID_Mask),
            .RID_Mask                  (RID_Mask),
            .En_Id_Based               (En_Id_Based_sync),  
            .Wr_Lat_Start              (Wr_Lat_Start    ),  //0 Address Issue 1 Address acceptance
            .Wr_Lat_End                (Wr_Lat_End),  //1 First write   0 Last write  
            .Rd_Lat_Start              (Rd_Lat_Start),  //0 Address Issue 1 Address acceptance 
            .Rd_Lat_End                (Rd_Lat_End),  //1 First Read    0 Last Read
            .Wtrans_Cnt_En             (Wtrans_Cnt_En[6]),
            .Rtrans_Cnt_En             (Rtrans_Cnt_En[6]),
            .Write_Byte_Cnt            (S6_Write_Byte_Cnt),
            .Read_Byte_Cnt             (S6_Read_Byte_Cnt),
            .Write_Beat_Cnt_En         (Write_Beat_Cnt_En[6]),
            .Read_Beat_Cnt_En          (Read_Beat_Cnt_En[6]),
            .Read_Latency              (S6_Read_Latency),
            .Write_Latency             (S6_Write_Latency),
            .Write_Beat_Cnt            (S6_Write_Beat_Cnt),
            .Slv_Wr_Idle_Cnt           (S6_Slv_Wr_Idle_Cnt),
            .Read_Latency_En           (Read_Latency_En[6]),    
            .Write_Latency_En          (Write_Latency_En[6]),   
            .Slv_Wr_Idle_Cnt_En        (Slv_Wr_Idle_Cnt_En[6]), 
            .Mst_Rd_Idle_Cnt_En        (Mst_Rd_Idle_Cnt_En[6]), 
            .Num_BValids_En            (Num_BValids_En[6]),     
            .Num_WLasts_En             (Num_WLasts_En[6]),      
            .Num_RLasts_En             (Num_RLasts_En[6]),      
            .S_Transfer_Cnt_En         (S_Transfer_Cnt_En[6]),
            .S_Packet_Cnt_En           (S_Packet_Cnt_En[6]),  
            .S_Data_Byte_Cnt           (S6_S_Data_Byte_Cnt),
            .S_Position_Byte_Cnt       (S6_S_Position_Byte_Cnt),
            .S_Null_Byte_Cnt           (S6_S_Null_Byte_Cnt),
            .S_Slv_Idle_Cnt_En         (S_Slv_Idle_Cnt_En[6]),
            .S_Mst_Idle_Cnt_En         (S_Mst_Idle_Cnt_En[6]),
            .Max_Write_Latency         (S6_Max_Write_Latency),                   
            .Min_Write_Latency         (S6_Min_Write_Latency),                   
            .Max_Read_Latency          (S6_Max_Read_Latency),                   
            .Min_Read_Latency          (S6_Min_Read_Latency)
          );
     end
     else begin :GEN_NO_SLOT6
         assign S6_Write_Beat_Cnt = 0;
         assign S6_Slv_Wr_Idle_Cnt = 0;
         assign Slot_6_Sync_Data_Out = 0;
         assign S6_Write_Byte_Cnt    = 0;
         assign S6_Read_Byte_Cnt     = 0;
         assign S6_Read_Latency      = 0;
         assign S6_Write_Latency     = 0;
         assign S6_S_Data_Byte_Cnt   = 0;
         assign S6_S_Position_Byte_Cnt = 0;
         assign S6_S_Null_Byte_Cnt     = 0;
         assign Ext_Event6_Sync_Data_Out = 0;
         assign Ext_Event6_Sync_Data_Valid = 0;
         assign S6_Max_Write_Latency  = 0;                  
         assign S6_Min_Write_Latency  = 0;               
         assign S6_Max_Read_Latency   = 0;               
         assign S6_Min_Read_Latency   = 0;
     end
     endgenerate 

    generate    
    if (C_ENABLE_EVENT_LOG == 1 && C_NUM_MONITOR_SLOTS > 6) begin : GEN_FLAGS6
         //Flag Generator instantiation for slot6
         axi_perf_mon_v5_0_9_flags_gen
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S6), 
           .C_LOG_WIDTH               (C_SLOT_6_LOG_WIDTH),
           .C_FLAG_WIDTH              (C_SLOT_6_FLAG_WIDTH), 
           .C_AXI_ADDR_WIDTH          (C_SLOT_6_AXI_ADDR_WIDTH), 
           .C_AXI_DATA_WIDTH          (C_SLOT_6_AXI_DATA_WIDTH), 
           .C_AXI_ID_WIDTH            (C_SLOT_6_AXI_ID_WIDTH), 
           .C_AXI_PROTOCOL            (C_SLOT_6_AXI_PROTOCOL), 
           .C_AXIS_TDATA_WIDTH        (C_SLOT_6_AXIS_TDATA_WIDTH), 
           .C_AXIS_TID_WIDTH          (C_SLOT_6_AXIS_TID_WIDTH), 
           .C_AXIS_TDEST_WIDTH        (C_SLOT_6_AXIS_TDEST_WIDTH), 
           .C_AXIS_TUSER_WIDTH        (C_SLOT_6_AXIS_TUSER_WIDTH),
           .C_SHOW_AXI_IDS            (C_SHOW_AXI_IDS),
           .C_SHOW_AXI_LEN            (C_SHOW_AXI_LEN),
           .C_SHOW_AXIS_TID           (C_SHOW_AXIS_TID),
           .C_SHOW_AXIS_TUSER         (C_SHOW_AXIS_TUSER),
           .C_SHOW_AXIS_TDEST         (C_SHOW_AXIS_TDEST), 
           .C_EN_AXI_DEBUG               (C_EN_AXI_DEBUG) 
          ) flags_generator_inst_6
          (
           .clk                       (core_aclk),
           .rst_n                     (core_aresetn),
           .Data_In                   (Slot_6_Sync_Data_Out),
           .Data_Valid                (Slot_6_Sync_Data_Valid), 
           .Flag_Enable_Reg           (Flag_Enable_Reg),
           .Ext_Trig                  (slot_6_ext_trig),
           .Ext_Trig_Stop             (slot_6_ext_trig_stop),
           .Use_Ext_Trig_Log          (Use_Ext_Trig_Log_sync),                
           .Log_Data                  (Slot_6_Log),
           .Log_En                    (Slot_6_Log_En),
           .Ext_Data_in               (Ext_Event6_Sync_Data_Out),
           .Ext_Data_Valid            (Ext_Event6_Sync_Data_Valid),
           .Ext_Event_Flag_En         (Ext_Event_Flag_En),
           .Ext_Event_Flags           (Ext_Event6_Flags)
          );

    end 
    else begin : GEN_NO_FLAGS6
       assign Slot_6_Log = 0;
       assign Slot_6_Log_En = 1'b0;
       assign Ext_Event6_Flags = 0;
    end 
    endgenerate

     //-- Slot 7
     generate
     if((C_NUM_MONITOR_SLOTS > 7)) begin :GEN_SLOT7

         axi_perf_mon_v5_0_9_mon_fifo
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
           .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S7),
           .C_FIFO_ENABLE             (C_SLOT_7_FIFO_ENABLE) 
          ) mon_fifo_inst_7
          (
           .Mon_clk                   (SLOT_7_clk),
           .Mon_rst_n                 (SLOT_7_Arst_n),
           .Data_In                   (Slot_7_Data_In),
           //.mon_en                    (Metrics_Cnt_En_sync),
           .CORE_ACLK                 (core_aclk),
           .CORE_ARESETN              (core_aresetn),
           .Sync_Data_Out             (Slot_7_Sync_Data_Out),
           .Sync_Data_Valid           (Slot_7_Sync_Data_Valid)
          );
         
          assign Ext_Event7_Data_In = {ext_event_7_cnt_start,ext_event_7_cnt_stop,ext_event_7};
     
          // External Event1 through monitor FIFO
          axi_perf_mon_v5_0_9_mon_fifo
             #(
               .C_FAMILY                  (C_FAMILY),
               .C_REG_ALL_MONITOR_SIGNALS (C_REG_ALL_MONITOR_SIGNALS),
               .C_MON_FIFO_DATA_WIDTH     (3),
               .C_FIFO_ENABLE             (C_EXT_EVENT7_FIFO_ENABLE) 
              ) mon_fifo_ext_event7_inst
              (
               .Mon_clk                   (ext_clk_7),
               .Mon_rst_n                 (ext_rstn_7),
               .Data_In                   (Ext_Event7_Data_In),
               //.mon_en                    (Metrics_Cnt_En_sync),
               .CORE_ACLK                 (core_aclk),
               .CORE_ARESETN              (core_aresetn),
               .Sync_Data_Out             (Ext_Event7_Sync_Data_Out),
               .Sync_Data_Valid           (Ext_Event7_Sync_Data_Valid)
              );

         // External Event7 count enable generation module
         axi_perf_mon_v5_0_9_ext_calc ext_calc_inst7  
            (
              .clk                    (core_aclk),        
              .rst_n                  (core_aresetn),     
              .Ext_Event              (Ext_Event7_Sync_Data_Out[0]),
              .Ext_Event_Start        (Ext_Event7_Sync_Data_Out[2]),
              .Ext_Event_Stop         (Ext_Event7_Sync_Data_Out[1]),
              .Ext_Event_Valid        (Ext_Event7_Sync_Data_Valid ),
              .Metrics_Cnt_En         (Metrics_Cnt_En_sync),
              .Metrics_Cnt_Reset      (Metrics_Cnt_Reset_sync),
              .External_Event_Cnt_En  (External_Event_Cnt_En[7])
            );

          // Metric calculator instance for slot7
          axi_perf_mon_v5_0_9_metric_calc 
           #(
             .C_AXIID                   (C_SLOT_7_AXI_ID_WIDTH    ),
             .C_AXIADDR                 (C_SLOT_7_AXI_ADDR_WIDTH  ),
             .C_AXIDATA                 (C_SLOT_7_AXI_DATA_WIDTH  ),
             .C_AXISDATA                (C_SLOT_7_AXIS_TDATA_WIDTH),
             .C_AXISID                  (C_SLOT_7_AXIS_TID_WIDTH  ),
             .C_AXISDEST                (C_SLOT_7_AXIS_TDEST_WIDTH),
             .C_AXISUSER                (C_SLOT_7_AXIS_TUSER_WIDTH),
             .C_OUTSTAND_DEPTH          (C_MAX_OUTSTAND_DEPTH),
             .C_METRIC_COUNT_WIDTH      (C_METRIC_COUNT_WIDTH),
             .C_MON_FIFO_WIDTH          (C_MON_FIFO_DWIDTH_S7),
             .C_AXI_PROTOCOL            (C_SLOT_7_AXI_PROTOCOL),
             .C_AXI_SUB_PROTOCOL        (C_SLOT_7_AXI_SUB_PROTOCOL)
           ) metric_calc_inst7
           (
             .clk                       (core_aclk ),
             .rst_n                     (core_aresetn),
             .Data_In                   (Slot_7_Sync_Data_Out),
             .Data_Valid                (Slot_7_Sync_Data_Valid), 
             .Metrics_Cnt_En            (Metrics_Cnt_En_sync),
             .Metrics_Cnt_Reset         (Metrics_Cnt_Reset_sync),
             .Use_Ext_Trig              (Use_Ext_Trig_sync),
             .Ext_Trig                  (slot_7_ext_trig),
             .Ext_Trig_Stop             (slot_7_ext_trig_stop),
             .Latency_WID               (Latency_WID),
             .Latency_RID               (Latency_RID),
             .WID_Mask                  (WID_Mask),
             .RID_Mask                  (RID_Mask),
             .En_Id_Based               (En_Id_Based_sync),  
             .Wr_Lat_Start              (Wr_Lat_Start),  //0 Address Issue 1 Address acceptance
             .Wr_Lat_End                (Wr_Lat_End),  //1 First write   0 Last write  
             .Rd_Lat_Start              (Rd_Lat_Start),  //0 Address Issue 1 Address acceptance 
             .Rd_Lat_End                (Rd_Lat_End),  //1 First Read    0 Last Read
             .Wtrans_Cnt_En             (Wtrans_Cnt_En[7]),
             .Rtrans_Cnt_En             (Rtrans_Cnt_En[7]),
             .Write_Byte_Cnt            (S7_Write_Byte_Cnt),
             .Read_Byte_Cnt             (S7_Read_Byte_Cnt),
             .Write_Beat_Cnt_En         (Write_Beat_Cnt_En[7]),
             .Read_Beat_Cnt_En          (Read_Beat_Cnt_En[7]),
             .Read_Latency              (S7_Read_Latency),
             .Write_Latency             (S7_Write_Latency),
             .Write_Beat_Cnt            (S7_Write_Beat_Cnt),
             .Slv_Wr_Idle_Cnt           (S7_Slv_Wr_Idle_Cnt),
             .Read_Latency_En           (Read_Latency_En[7]),    
             .Write_Latency_En          (Write_Latency_En[7]),   
             .Slv_Wr_Idle_Cnt_En        (Slv_Wr_Idle_Cnt_En[7]), 
             .Mst_Rd_Idle_Cnt_En        (Mst_Rd_Idle_Cnt_En[7]), 
             .Num_BValids_En            (Num_BValids_En[7]),     
             .Num_WLasts_En             (Num_WLasts_En[7]),      
             .Num_RLasts_En             (Num_RLasts_En[7]),      
             .S_Transfer_Cnt_En         (S_Transfer_Cnt_En[7]),
             .S_Packet_Cnt_En           (S_Packet_Cnt_En[7]),  
             .S_Data_Byte_Cnt           (S7_S_Data_Byte_Cnt),
             .S_Position_Byte_Cnt       (S7_S_Position_Byte_Cnt),
             .S_Null_Byte_Cnt           (S7_S_Null_Byte_Cnt),
             .S_Slv_Idle_Cnt_En         (S_Slv_Idle_Cnt_En[7]),
             .S_Mst_Idle_Cnt_En         (S_Mst_Idle_Cnt_En[7]),
             .Max_Write_Latency         (S7_Max_Write_Latency),                   
             .Min_Write_Latency         (S7_Min_Write_Latency),                   
             .Max_Read_Latency          (S7_Max_Read_Latency),                   
             .Min_Read_Latency          (S7_Min_Read_Latency)
           );
     end
     else begin :GEN_NO_SLOT7
         assign S7_Write_Beat_Cnt = 0;
         assign S7_Slv_Wr_Idle_Cnt = 0;
         assign Slot_7_Sync_Data_Out = 0;
         assign S7_Write_Byte_Cnt    = 0;
         assign S7_Read_Byte_Cnt     = 0;
         assign S7_Read_Latency      = 0;
         assign S7_Write_Latency     = 0;
         assign S7_S_Data_Byte_Cnt   = 0;
         assign S7_S_Position_Byte_Cnt = 0;
         assign S7_S_Null_Byte_Cnt     = 0;
         assign Ext_Event7_Sync_Data_Out = 0;
         assign Ext_Event7_Sync_Data_Valid = 0;
         assign External_Event7_Cnt_En = 0;
         assign S7_Max_Write_Latency  = 0;                  
         assign S7_Min_Write_Latency  = 0;               
         assign S7_Max_Read_Latency   = 0;               
         assign S7_Min_Read_Latency   = 0;
     end
     endgenerate 
     
    generate    
    if (C_ENABLE_EVENT_LOG == 1 && C_NUM_MONITOR_SLOTS > 7) begin : GEN_FLAGS7
        //Flag Generator instantiation for slot7
         axi_perf_mon_v5_0_9_flags_gen
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_MON_FIFO_DATA_WIDTH     (C_MON_FIFO_DWIDTH_S7), 
           .C_LOG_WIDTH               (C_SLOT_7_LOG_WIDTH),
           .C_FLAG_WIDTH              (C_SLOT_7_FLAG_WIDTH), 
           .C_AXI_ADDR_WIDTH          (C_SLOT_7_AXI_ADDR_WIDTH), 
           .C_AXI_DATA_WIDTH          (C_SLOT_7_AXI_DATA_WIDTH), 
           .C_AXI_ID_WIDTH            (C_SLOT_7_AXI_ID_WIDTH), 
           .C_AXI_PROTOCOL            (C_SLOT_7_AXI_PROTOCOL), 
           .C_AXIS_TDATA_WIDTH        (C_SLOT_7_AXIS_TDATA_WIDTH), 
           .C_AXIS_TID_WIDTH          (C_SLOT_7_AXIS_TID_WIDTH), 
           .C_AXIS_TDEST_WIDTH        (C_SLOT_7_AXIS_TDEST_WIDTH), 
           .C_AXIS_TUSER_WIDTH        (C_SLOT_7_AXIS_TUSER_WIDTH),
           .C_SHOW_AXI_IDS            (C_SHOW_AXI_IDS),
           .C_SHOW_AXI_LEN            (C_SHOW_AXI_LEN),
           .C_SHOW_AXIS_TID           (C_SHOW_AXIS_TID),
           .C_SHOW_AXIS_TUSER         (C_SHOW_AXIS_TUSER),
           .C_SHOW_AXIS_TDEST         (C_SHOW_AXIS_TDEST), 
           .C_EN_AXI_DEBUG               (C_EN_AXI_DEBUG) 
          ) flags_generator_inst_7
          (
           .clk                       (core_aclk),
           .rst_n                     (core_aresetn),
           .Data_In                   (Slot_7_Sync_Data_Out),
           .Data_Valid                (Slot_7_Sync_Data_Valid), 
           .Flag_Enable_Reg           (Flag_Enable_Reg),
           .Ext_Trig                  (slot_7_ext_trig),
           .Ext_Trig_Stop             (slot_7_ext_trig_stop),
           .Use_Ext_Trig_Log          (Use_Ext_Trig_Log_sync),                 
           .Log_Data                  (Slot_7_Log),
           .Log_En                    (Slot_7_Log_En),
           .Ext_Data_in               (Ext_Event7_Sync_Data_Out),
           .Ext_Data_Valid            (Ext_Event7_Sync_Data_Valid),
           .Ext_Event_Flag_En         (Ext_Event_Flag_En),
           .Ext_Event_Flags           (Ext_Event7_Flags)
          );

    end 
    else begin : GEN_NO_FLAGS7
       assign Slot_7_Log = 0;
       assign Slot_7_Log_En = 1'b0;
       assign Ext_Event7_Flags = 0;
    end 
    endgenerate       

     //-- Streaming FIFO and its write logic 
     generate
     if((C_ENABLE_EVENT_LOG == 1)) begin :GEN_EVENT_LOG

         axi_perf_mon_v5_0_9_strm_fifo_wr_logic
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_NUM_MONITOR_SLOTS       (C_NUM_MONITOR_SLOTS),
           .C_SW_SYNC_DATA_WIDTH      (C_SW_SYNC_DATA_WIDTH),
           .C_SLOT_0_LOG_WIDTH        (C_SLOT_0_LOG_WIDTH), 
           .C_SLOT_1_LOG_WIDTH        (C_SLOT_1_LOG_WIDTH), 
           .C_SLOT_2_LOG_WIDTH        (C_SLOT_2_LOG_WIDTH), 
           .C_SLOT_3_LOG_WIDTH        (C_SLOT_3_LOG_WIDTH), 
           .C_SLOT_4_LOG_WIDTH        (C_SLOT_4_LOG_WIDTH), 
           .C_SLOT_5_LOG_WIDTH        (C_SLOT_5_LOG_WIDTH), 
           .C_SLOT_6_LOG_WIDTH        (C_SLOT_6_LOG_WIDTH), 
           .C_SLOT_7_LOG_WIDTH        (C_SLOT_7_LOG_WIDTH), 
           .C_FIFO_AXIS_TDATA_WIDTH   (C_FIFO_AXIS_TDATA_WIDTH), 
           .C_EN_AXI_DEBUG            (C_EN_AXI_DEBUG),
           .C_EN_TRIGGER              (C_EN_TRIGGER)
          ) streaming_fifo_write_logic_inst
          (
           .clk                       (core_aclk),
           .rst_n                     (core_aresetn),
           .Event_Log_En              (Event_Log_En_sync),
           .Slot_0_Log                (Slot_0_Log_Marked),
           .Slot_0_Log_En             (Slot_0_Log_En_Marked),
           .Slot_1_Log                (Slot_1_Log_Marked),
           .Slot_1_Log_En             (Slot_1_Log_En_Marked),
           .Slot_2_Log                (Slot_2_Log_Marked),
           .Slot_2_Log_En             (Slot_2_Log_En_Marked),
           .Slot_3_Log                (Slot_3_Log_Marked),
           .Slot_3_Log_En             (Slot_3_Log_En_Marked),
           .Slot_4_Log                (Slot_4_Log_Marked),
           .Slot_4_Log_En             (Slot_4_Log_En_Marked),
           .Slot_5_Log                (Slot_5_Log_Marked),
           .Slot_5_Log_En             (Slot_5_Log_En_Marked),
           .Slot_6_Log                (Slot_6_Log),
           .Slot_6_Log_En             (Slot_6_Log_En),
           .Slot_7_Log                (Slot_7_Log),
           .Slot_7_Log_En             (Slot_7_Log_En),
           .SW_Data_Log_En            (SW_Data_Log_En ),
           .SW_Data                   (SW_Data        ),
           .SW_Data_Wr_En             (SW_Data_Wr_En  ),
           .Ext_Event0_Flags          (Ext_Event0_Flags),
           .Ext_Event1_Flags          (Ext_Event1_Flags),
           .Ext_Event2_Flags          (Ext_Event2_Flags),
           .Ext_Event3_Flags          (Ext_Event3_Flags),
           .Ext_Event4_Flags          (Ext_Event4_Flags),
           .Ext_Event5_Flags          (Ext_Event5_Flags),
           .Ext_Event6_Flags          (Ext_Event6_Flags),
           .Ext_Event7_Flags          (Ext_Event7_Flags),
           .Fifo_Full                 (Streaming_Fifo_Full   ),
           .Fifo_Empty                (Streaming_Fifo_Empty  ),
           .Fifo_Wr_En                (Streaming_Fifo_Wr_En  ),
           .Fifo_Wr_Data              (Streaming_Fifo_Wr_Data),
           .trigger                   (trigger)
          );

         wire stream_fifo_rst_n = ~(Streaming_FIFO_Reset_sync) & core_aresetn;

         // Sync/ Async streaming FIFO
         axi_perf_mon_v5_0_9_async_stream_fifo
         #(
           .C_FAMILY                  (C_FAMILY),
           .C_FIFO_DEPTH              (C_FIFO_AXIS_DEPTH),
           .C_DATA_WIDTH              (C_FIFO_AXIS_TDATA_WIDTH),
           .C_AXIS_DWIDTH_ROUND_TO_32 (C_AXIS_DWIDTH_ROUND_TO_32),
           .C_USE_BLOCKMEM            (1),                   // 1 Use bram
           .C_COMMON_CLOCK            (C_FIFO_AXIS_SYNC),     //1 sync fifo 0 async fifo
           .C_LOG_DATA_OFFLD          (C_LOG_DATA_OFFLD)  ,
           .S_AXI_OFFLD_ID_WIDTH      (S_AXI_OFFLD_ID_WIDTH),  
           .C_EN_TRIGGER              (C_EN_TRIGGER)  
          ) async_stream_fifo_inst
          (
           .Wr_clk               (core_aclk),
           .Wr_rst_n             (stream_fifo_rst_n),
           .fifo_wr_en           (Streaming_Fifo_Wr_En),
           .eventlog_cur_cnt     (eventlog_cur_cnt),
           .fifo_full_out        (Streaming_Fifo_Full),
           .fifo_empty_out       (Streaming_Fifo_Empty),
           .Fifo_Data_In         (Streaming_Fifo_Wr_Data),
           .m_axis_aclk          (m_axis_aclk),
           .m_axis_aresetn       (m_axis_aresetn),
           .m_axis_tvalid        (m_axis_tvalid),
           .m_axis_tready        (m_axis_tready),
           .m_axis_tdata         (m_axis_tdata),
           .s_axi_offld_aclk     (s_axi_offld_aclk    ),
           .s_axi_offld_aresetn  (s_axi_offld_aresetn ),
           .s_axi_offld_araddr   (s_axi_offld_araddr  ),
           .s_axi_offld_arvalid  (s_axi_offld_arvalid ),
           .s_axi_offld_arlen    (s_axi_offld_arlen   ),
           .s_axi_offld_arid     (s_axi_offld_arid    ),
           .s_axi_offld_arready  (s_axi_offld_arready ),
           .s_axi_offld_rready   (s_axi_offld_rready  ),
           .s_axi_offld_rdata    (s_axi_offld_rdata   ),
           .s_axi_offld_rresp    (s_axi_offld_rresp   ),
           .s_axi_offld_rvalid   (s_axi_offld_rvalid  ),
           .s_axi_offld_rid      (s_axi_offld_rid     ),
           .s_axi_offld_rlast    (s_axi_offld_rlast   ),
           .trigger              (trigger) 
          );
         assign m_axis_tstrb = { {(C_FIFO_AXIS_TDATA_WIDTH/8){1'b1}} } ;
         assign m_axis_tid = 0;
     end
     else begin :GEN_NO_EVENT_LOG
         assign m_axis_tdata  = 0;
         assign m_axis_tvalid = 0;
         assign m_axis_tstrb = 0;
         assign m_axis_tid = 0;
         assign Streaming_Fifo_Full = 0;
     end
     endgenerate 

   //-- Edge detection of fifo full
   always @(posedge core_aclk) begin
       if (core_aresetn == RST_ACTIVE) begin
           Streaming_Fifo_Full_D1 <= 1'b0;
       end
       else begin
           Streaming_Fifo_Full_D1 <= Streaming_Fifo_Full;
       end
   end

   assign Streaming_Fifo_Full_Edge = Streaming_Fifo_Full & (!Streaming_Fifo_Full_D1);

   // Resets metric count through control register bit or through sampled interval  control register
   // When ever sample counter expires or when sample register is read 
   wire Metrics_Cnt_Reset_Final = Metrics_Cnt_Reset_sync | (Sample_Interval_Cnt_Lapse & Reset_On_Sample_Int_Lapse_sync)
                                  | (Lat_Sample_Reg & Reset_On_Sample_Int_Lapse_sync);
  


   //-- metric counters instantiation
     axi_perf_mon_v5_0_9_metric_counters 
    #(
      .C_FAMILY                    (C_FAMILY),
      .C_NUM_MONITOR_SLOTS         (C_NUM_MONITOR_SLOTS),
      .C_ENABLE_EVENT_COUNT        (C_ENABLE_EVENT_COUNT),
      .C_NUM_OF_COUNTERS           (C_NUM_OF_COUNTERS), 
      .C_METRIC_COUNT_WIDTH        (C_METRIC_COUNT_WIDTH),
      .C_METRIC_COUNT_SCALE        (C_METRIC_COUNT_SCALE),
      .COUNTER_LOAD_VALUE          (COUNTER_LOAD_VALUE)  

    ) metric_counters_inst
    (
      .clk                           (core_aclk ),
      .rst_n                         (core_aresetn),
      .Wtrans_Cnt_En                 (Wtrans_Cnt_En),
      .Rtrans_Cnt_En                 (Rtrans_Cnt_En),
      .S0_Write_Byte_Cnt             (S0_Write_Byte_Cnt),
      .S1_Write_Byte_Cnt             (S1_Write_Byte_Cnt),
      .S2_Write_Byte_Cnt             (S2_Write_Byte_Cnt),
      .S3_Write_Byte_Cnt             (S3_Write_Byte_Cnt),
      .S4_Write_Byte_Cnt             (S4_Write_Byte_Cnt),
      .S5_Write_Byte_Cnt             (S5_Write_Byte_Cnt),
      .S6_Write_Byte_Cnt             (S6_Write_Byte_Cnt),
      .S7_Write_Byte_Cnt             (S7_Write_Byte_Cnt),
      .S0_Slv_Wr_Idle_Cnt             (S0_Slv_Wr_Idle_Cnt),
      .S1_Slv_Wr_Idle_Cnt             (S1_Slv_Wr_Idle_Cnt),
      .S2_Slv_Wr_Idle_Cnt             (S2_Slv_Wr_Idle_Cnt),
      .S3_Slv_Wr_Idle_Cnt             (S3_Slv_Wr_Idle_Cnt),
      .S4_Slv_Wr_Idle_Cnt             (S4_Slv_Wr_Idle_Cnt),
      .S5_Slv_Wr_Idle_Cnt             (S5_Slv_Wr_Idle_Cnt),
      .S6_Slv_Wr_Idle_Cnt             (S6_Slv_Wr_Idle_Cnt),
      .S7_Slv_Wr_Idle_Cnt             (S7_Slv_Wr_Idle_Cnt),
      .S0_Write_Beat_Cnt             (S0_Write_Beat_Cnt),
      .S1_Write_Beat_Cnt             (S1_Write_Beat_Cnt),
      .S2_Write_Beat_Cnt             (S2_Write_Beat_Cnt),
      .S3_Write_Beat_Cnt             (S3_Write_Beat_Cnt),
      .S4_Write_Beat_Cnt             (S4_Write_Beat_Cnt),
      .S5_Write_Beat_Cnt             (S5_Write_Beat_Cnt),
      .S6_Write_Beat_Cnt             (S6_Write_Beat_Cnt),
      .S7_Write_Beat_Cnt             (S7_Write_Beat_Cnt),
      .S0_Read_Byte_Cnt              (S0_Read_Byte_Cnt),
      .S1_Read_Byte_Cnt              (S1_Read_Byte_Cnt),
      .S2_Read_Byte_Cnt              (S2_Read_Byte_Cnt),
      .S3_Read_Byte_Cnt              (S3_Read_Byte_Cnt),
      .S4_Read_Byte_Cnt              (S4_Read_Byte_Cnt),
      .S5_Read_Byte_Cnt              (S5_Read_Byte_Cnt),
      .S6_Read_Byte_Cnt              (S6_Read_Byte_Cnt),
      .S7_Read_Byte_Cnt              (S7_Read_Byte_Cnt),
      .Write_Beat_Cnt_En             (Write_Beat_Cnt_En),
      .Read_Beat_Cnt_En              (Read_Beat_Cnt_En),
      .S0_Read_Latency               (S0_Read_Latency),
      .S1_Read_Latency               (S1_Read_Latency),
      .S2_Read_Latency               (S2_Read_Latency),
      .S3_Read_Latency               (S3_Read_Latency),
      .S4_Read_Latency               (S4_Read_Latency),
      .S5_Read_Latency               (S5_Read_Latency),
      .S6_Read_Latency               (S6_Read_Latency),
      .S7_Read_Latency               (S7_Read_Latency),
      .S0_Write_Latency              (S0_Write_Latency),
      .S1_Write_Latency              (S1_Write_Latency),
      .S2_Write_Latency              (S2_Write_Latency),
      .S3_Write_Latency              (S3_Write_Latency),
      .S4_Write_Latency              (S4_Write_Latency),
      .S5_Write_Latency              (S5_Write_Latency),
      .S6_Write_Latency              (S6_Write_Latency),
      .S7_Write_Latency              (S7_Write_Latency),
      .Read_Latency_En               (Read_Latency_En),    
      .Write_Latency_En              (Write_Latency_En),   
      .Slv_Wr_Idle_Cnt_En            (Slv_Wr_Idle_Cnt_En), 
      .Mst_Rd_Idle_Cnt_En            (Mst_Rd_Idle_Cnt_En), 
      .Num_BValids_En                (Num_BValids_En),     
      .Num_WLasts_En                 (Num_WLasts_En),      
      .Num_RLasts_En                 (Num_RLasts_En),      
      .S_Transfer_Cnt_En             (S_Transfer_Cnt_En),
      .S_Packet_Cnt_En               (S_Packet_Cnt_En),  
      .S0_S_Data_Byte_Cnt            (S0_S_Data_Byte_Cnt),
      .S1_S_Data_Byte_Cnt            (S1_S_Data_Byte_Cnt),
      .S2_S_Data_Byte_Cnt            (S2_S_Data_Byte_Cnt),
      .S3_S_Data_Byte_Cnt            (S3_S_Data_Byte_Cnt),
      .S4_S_Data_Byte_Cnt            (S4_S_Data_Byte_Cnt),
      .S5_S_Data_Byte_Cnt            (S5_S_Data_Byte_Cnt),
      .S6_S_Data_Byte_Cnt            (S6_S_Data_Byte_Cnt),
      .S7_S_Data_Byte_Cnt            (S7_S_Data_Byte_Cnt),
      .S0_S_Position_Byte_Cnt        (S0_S_Position_Byte_Cnt),
      .S1_S_Position_Byte_Cnt        (S1_S_Position_Byte_Cnt),
      .S2_S_Position_Byte_Cnt        (S2_S_Position_Byte_Cnt),
      .S3_S_Position_Byte_Cnt        (S3_S_Position_Byte_Cnt),
      .S4_S_Position_Byte_Cnt        (S4_S_Position_Byte_Cnt),
      .S5_S_Position_Byte_Cnt        (S5_S_Position_Byte_Cnt),
      .S6_S_Position_Byte_Cnt        (S6_S_Position_Byte_Cnt),
      .S7_S_Position_Byte_Cnt        (S7_S_Position_Byte_Cnt),
      .S0_S_Null_Byte_Cnt            (S0_S_Null_Byte_Cnt),
      .S1_S_Null_Byte_Cnt            (S1_S_Null_Byte_Cnt),
      .S2_S_Null_Byte_Cnt            (S2_S_Null_Byte_Cnt),
      .S3_S_Null_Byte_Cnt            (S3_S_Null_Byte_Cnt),
      .S4_S_Null_Byte_Cnt            (S4_S_Null_Byte_Cnt),
      .S5_S_Null_Byte_Cnt            (S5_S_Null_Byte_Cnt),
      .S6_S_Null_Byte_Cnt            (S6_S_Null_Byte_Cnt),
      .S7_S_Null_Byte_Cnt            (S7_S_Null_Byte_Cnt),
      .S_Slv_Idle_Cnt_En             (S_Slv_Idle_Cnt_En),
      .S_Mst_Idle_Cnt_En             (S_Mst_Idle_Cnt_En),
      .S0_Max_Write_Latency          (S0_Max_Write_Latency),         
      .S1_Max_Write_Latency          (S1_Max_Write_Latency),         
      .S2_Max_Write_Latency          (S2_Max_Write_Latency),         
      .S3_Max_Write_Latency          (S3_Max_Write_Latency),         
      .S4_Max_Write_Latency          (S4_Max_Write_Latency),         
      .S5_Max_Write_Latency          (S5_Max_Write_Latency),         
      .S6_Max_Write_Latency          (S6_Max_Write_Latency),         
      .S7_Max_Write_Latency          (S7_Max_Write_Latency),         
      .S0_Min_Write_Latency          (S0_Min_Write_Latency),       
      .S1_Min_Write_Latency          (S1_Min_Write_Latency),       
      .S2_Min_Write_Latency          (S2_Min_Write_Latency),       
      .S3_Min_Write_Latency          (S3_Min_Write_Latency),       
      .S4_Min_Write_Latency          (S4_Min_Write_Latency),       
      .S5_Min_Write_Latency          (S5_Min_Write_Latency),       
      .S6_Min_Write_Latency          (S6_Min_Write_Latency),       
      .S7_Min_Write_Latency          (S7_Min_Write_Latency),       
      .S0_Max_Read_Latency           (S0_Max_Read_Latency),                  
      .S1_Max_Read_Latency           (S1_Max_Read_Latency),                  
      .S2_Max_Read_Latency           (S2_Max_Read_Latency),                  
      .S3_Max_Read_Latency           (S3_Max_Read_Latency),                  
      .S4_Max_Read_Latency           (S4_Max_Read_Latency),                  
      .S5_Max_Read_Latency           (S5_Max_Read_Latency),                  
      .S6_Max_Read_Latency           (S6_Max_Read_Latency),                  
      .S7_Max_Read_Latency           (S7_Max_Read_Latency),                  
      .S0_Min_Read_Latency           (S0_Min_Read_Latency), 
      .S1_Min_Read_Latency           (S1_Min_Read_Latency), 
      .S2_Min_Read_Latency           (S2_Min_Read_Latency), 
      .S3_Min_Read_Latency           (S3_Min_Read_Latency), 
      .S4_Min_Read_Latency           (S4_Min_Read_Latency), 
      .S5_Min_Read_Latency           (S5_Min_Read_Latency), 
      .S6_Min_Read_Latency           (S6_Min_Read_Latency), 
      .S7_Min_Read_Latency           (S7_Min_Read_Latency), 
      .External_Event_Cnt_En         (External_Event_Cnt_En),
      .Metrics_Cnt_En                (Metrics_Cnt_En_sync),
      .Metrics_Cnt_Reset             (Metrics_Cnt_Reset_Final),
      .Metric_Sel_0                  (Metric_Sel_0     ),
      .Metric_Sel_1                  (Metric_Sel_1     ),
      .Metric_Sel_2                  (Metric_Sel_2     ),
      .Metric_Sel_3                  (Metric_Sel_3     ),
      .Metric_Sel_4                  (Metric_Sel_4     ),
      .Metric_Sel_5                  (Metric_Sel_5     ),
      .Metric_Sel_6                  (Metric_Sel_6     ),
      .Metric_Sel_7                  (Metric_Sel_7     ),
      .Metric_Sel_8                  (Metric_Sel_8     ),
      .Metric_Sel_9                  (Metric_Sel_9     ),
      .Range_Reg_0                   (Range_Reg_0      ),
      .Range_Reg_1                   (Range_Reg_1      ),
      .Range_Reg_2                   (Range_Reg_2      ),
      .Range_Reg_3                   (Range_Reg_3      ),
      .Range_Reg_4                   (Range_Reg_4      ),
      .Range_Reg_5                   (Range_Reg_5      ),
      .Range_Reg_6                   (Range_Reg_6      ),
      .Range_Reg_7                   (Range_Reg_7      ),
      .Range_Reg_8                   (Range_Reg_8      ),
      .Range_Reg_9                   (Range_Reg_9      ),
      .Metric_Cnt_0                  (Metric_Cnt_0  ) ,
      .Metric_Cnt_1                  (Metric_Cnt_1  ) ,
      .Metric_Cnt_2                  (Metric_Cnt_2  ) ,
      .Metric_Cnt_3                  (Metric_Cnt_3  ) ,
      .Metric_Cnt_4                  (Metric_Cnt_4  ) ,
      .Metric_Cnt_5                  (Metric_Cnt_5  ) ,
      .Metric_Cnt_6                  (Metric_Cnt_6  ) ,
      .Metric_Cnt_7                  (Metric_Cnt_7  ) ,
      .Metric_Cnt_8                  (Metric_Cnt_8  ) ,
      .Metric_Cnt_9                  (Metric_Cnt_9  ) ,
      .Incrementer_0                 (Incrementer_0  ) ,
      .Incrementer_1                 (Incrementer_1  ) ,
      .Incrementer_2                 (Incrementer_2  ) ,
      .Incrementer_3                 (Incrementer_3  ) ,
      .Incrementer_4                 (Incrementer_4  ) ,
      .Incrementer_5                 (Incrementer_5  ) ,
      .Incrementer_6                 (Incrementer_6  ) ,
      .Incrementer_7                 (Incrementer_7  ) ,
      .Incrementer_8                 (Incrementer_8  ) ,
      .Incrementer_9                 (Incrementer_9  ) ,
      .Acc_OF_0                      (Acc_OF_0  ) ,
      .Acc_OF_1                      (Acc_OF_1  ) ,
      .Acc_OF_2                      (Acc_OF_2  ) ,
      .Acc_OF_3                      (Acc_OF_3  ) ,
      .Acc_OF_4                      (Acc_OF_4  ) ,
      .Acc_OF_5                      (Acc_OF_5  ) ,
      .Acc_OF_6                      (Acc_OF_6  ) ,
      .Acc_OF_7                      (Acc_OF_7  ) ,
      .Acc_OF_8                      (Acc_OF_8  ) ,
      .Acc_OF_9                      (Acc_OF_9  ) ,
      .Incr_OF_0                     (Incr_OF_0  ) ,
      .Incr_OF_1                     (Incr_OF_1  ) ,
      .Incr_OF_2                     (Incr_OF_2  ) ,
      .Incr_OF_3                     (Incr_OF_3  ) ,
      .Incr_OF_4                     (Incr_OF_4  ) ,
      .Incr_OF_5                     (Incr_OF_5  ) ,
      .Incr_OF_6                     (Incr_OF_6  ) ,
      .Incr_OF_7                     (Incr_OF_7  ) ,
      .Incr_OF_8                     (Incr_OF_8  ) ,
      .Incr_OF_9                     (Incr_OF_9  ) 
    );


  //-- synchronizing Interval_Cnt_En and Interval_Cnt_Ld and reset to metric counters
    generate    
    if (C_AXI4LITE_CORE_CLK_ASYNC == 1) begin : GEN_INTERVAL_CNT_SYNC
      // Synchronizing external trigger
      //-- Double Flop synchronization
      axi_perf_mon_v5_0_9_cdc_sync
      #(
         .c_cdc_type      (1             ),   
         .c_flop_input    (0             ),  
         .c_reset_state   (1             ),  
         .c_single_bit    (0             ),  
         .c_vector_width  (3             ),  
         .c_mtbf_stages   (4             )  
       )sample_interval_cnt_cdc_sync 
       (
         .prmry_aclk      (s_axi_aclk                                                              ),
         .prmry_rst_n     (s_axi_aresetn                                                           ),
         .prmry_in        (1'b0                                                                    ),
         .prmry_vect_in   ({Reset_On_Sample_Int_Lapse,Interval_Cnt_Ld, Interval_Cnt_En}            ),
         .scndry_aclk     (core_aclk                                                               ),
         .scndry_rst_n    (core_aresetn                                                            ),
         .prmry_ack       (                                                                        ),
         .scndry_out      (                                                                        ),
         .scndry_vect_out ({Reset_On_Sample_Int_Lapse_sync,Interval_Cnt_Ld_sync, Interval_Cnt_En_sync}) 
        );
    end 
    else begin : GEN_INTERVAL_CNT_NO_SYNC
        assign Interval_Cnt_Ld_sync           = Interval_Cnt_Ld;
        assign Interval_Cnt_En_sync           = Interval_Cnt_En;
        assign Reset_On_Sample_Int_Lapse_sync = Reset_On_Sample_Int_Lapse;
    end 
    endgenerate 
     
   wire Interval_Cnt_En_i  = Interval_Cnt_En_sync & Metrics_Cnt_En_sync;

   //-- Sample Interval Counter
   generate
   if((C_HAVE_SAMPLED_METRIC_CNT == 1)) begin :GEN_SAMPLE_METRIC_CNT
       axi_perf_mon_v5_0_9_samp_intl_cnt
       #(
             .C_FAMILY                      (C_FAMILY),
             .C_METRICS_SAMPLE_COUNT_WIDTH  (C_METRICS_SAMPLE_COUNT_WIDTH)
        ) sample_interval_counter_inst
        (
             .clk                       (core_aclk     ),
             .rst_n                     (core_aresetn  ),
             .Interval_Cnt_En           (Interval_Cnt_En_i  ),
             .Interval_Cnt_Ld           (Interval_Cnt_Ld_sync  ),
             .Interval_Cnt_Ld_Val       (Sample_Interval  ),
             .Sample_Interval_Cnt       (Sample_Interval_Cnt  ),
             .Sample_Interval_Cnt_Lapse (Sample_Interval_Cnt_Lapse) 
        );
    
   end
   else begin :GEN_NO_SAMPLE_METRIC_CNT
       assign Sample_Interval_Cnt_Lapse = 1'b0;

   end
   endgenerate


   wire Sample_En = capture_event | Sample_Interval_Cnt_Lapse | Lat_Sample_Reg;
   wire Sample_Metrics_Data_Reset_n = (!reset_event) & core_aresetn & (!Metrics_Cnt_Reset_sync);
  
   // Sampled metrics data instance
   axi_perf_mon_v5_0_9_samp_metrics_data
   #(
         .C_FAMILY                    (C_FAMILY),
         .C_NUM_OF_COUNTERS           (C_NUM_OF_COUNTERS), 
         .C_ENABLE_EVENT_COUNT        (C_ENABLE_EVENT_COUNT),
         .C_HAVE_SAMPLED_METRIC_CNT   (C_HAVE_SAMPLED_METRIC_CNT)
    ) sampled_metrics_data_inst
    (
         .clk                  (core_aclk     ),
         .rst_n                (Sample_Metrics_Data_Reset_n  ),
         .Sample_En            (Sample_En     ),
         .Metric_Cnt_0         (Metric_Cnt_0  ) ,
         .Metric_Cnt_1         (Metric_Cnt_1  ) ,
         .Metric_Cnt_2         (Metric_Cnt_2  ) ,
         .Metric_Cnt_3         (Metric_Cnt_3  ) ,
         .Metric_Cnt_4         (Metric_Cnt_4  ) ,
         .Metric_Cnt_5         (Metric_Cnt_5  ) ,
         .Metric_Cnt_6         (Metric_Cnt_6  ) ,
         .Metric_Cnt_7         (Metric_Cnt_7  ) ,
         .Metric_Cnt_8         (Metric_Cnt_8  ) ,
         .Metric_Cnt_9         (Metric_Cnt_9  ) ,
         .Incrementer_0        (Incrementer_0  ) ,
         .Incrementer_1        (Incrementer_1  ) ,
         .Incrementer_2        (Incrementer_2  ) ,
         .Incrementer_3        (Incrementer_3  ) ,
         .Incrementer_4        (Incrementer_4  ) ,
         .Incrementer_5        (Incrementer_5  ) ,
         .Incrementer_6        (Incrementer_6  ) ,
         .Incrementer_7        (Incrementer_7  ) ,
         .Incrementer_8        (Incrementer_8  ) ,
         .Incrementer_9        (Incrementer_9  ) ,
         .Samp_Metric_Cnt_0    (Samp_Metric_Cnt_0  ) ,
         .Samp_Metric_Cnt_1    (Samp_Metric_Cnt_1  ) ,
         .Samp_Metric_Cnt_2    (Samp_Metric_Cnt_2  ) ,
         .Samp_Metric_Cnt_3    (Samp_Metric_Cnt_3  ) ,
         .Samp_Metric_Cnt_4    (Samp_Metric_Cnt_4  ) ,
         .Samp_Metric_Cnt_5    (Samp_Metric_Cnt_5  ) ,
         .Samp_Metric_Cnt_6    (Samp_Metric_Cnt_6  ) ,
         .Samp_Metric_Cnt_7    (Samp_Metric_Cnt_7  ) ,
         .Samp_Metric_Cnt_8    (Samp_Metric_Cnt_8  ) ,
         .Samp_Metric_Cnt_9    (Samp_Metric_Cnt_9  ) ,
         .Samp_Incrementer_0   (Samp_Incrementer_0  ) ,
         .Samp_Incrementer_1   (Samp_Incrementer_1  ) ,
         .Samp_Incrementer_2   (Samp_Incrementer_2  ) ,
         .Samp_Incrementer_3   (Samp_Incrementer_3  ) ,
         .Samp_Incrementer_4   (Samp_Incrementer_4  ) ,
         .Samp_Incrementer_5   (Samp_Incrementer_5  ) ,
         .Samp_Incrementer_6   (Samp_Incrementer_6  ) ,
         .Samp_Incrementer_7   (Samp_Incrementer_7  ) ,
         .Samp_Incrementer_8   (Samp_Incrementer_8  ) ,
         .Samp_Incrementer_9   (Samp_Incrementer_9  ) 
       );

endmodule
