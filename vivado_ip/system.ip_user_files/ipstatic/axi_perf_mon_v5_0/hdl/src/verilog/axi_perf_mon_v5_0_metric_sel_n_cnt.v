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
// Filename     : axi_perf_mon_v5_0_9_metric_sel_n_cnt.v
// Version      : v5.0
// Description  : This module calls the accumulator and incrementor module
//                and passes the metrics to be accumulated based on
//                metric selection registers 
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
//
//  axi_perf_mon.v
//        \-- axi_perf_mon_v5_0_9_metric_counters.v
//           \-- axi_perf_mon_v5_0_9_metric_sel_n_cnt.v 
//
//-----------------------------------------------------------------------------
// Author :    Kalpanath
// History:    
// Kalpanath 07/25/2012      First Version
// ~~~~~~
// NLR       10/10/2012      Added support uptill 8 monitor slots at a time
// ~~~~~~
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module axi_perf_mon_v5_0_9_metric_sel_n_cnt 
#(
   parameter                       C_FAMILY             = "virtex7",
   parameter                       C_NUM_MONITOR_SLOTS  = 8,
   parameter                       C_ENABLE_EVENT_COUNT = 1,  //-- enables/disables perf mon counting logic
   parameter                       C_METRIC_COUNT_WIDTH = 32,  //-- enables/disables perf mon counting logic
   parameter                       C_METRIC_COUNT_SCALE = 1,
   parameter                       COUNTER_LOAD_VALUE   = 32'h00000000
)
(
   input                            clk,
   input                            rst_n,

    //-- AXI4 metrics
   
   input [C_NUM_MONITOR_SLOTS-1:0]  Wtrans_Cnt_En,
   input [C_NUM_MONITOR_SLOTS-1:0]  Rtrans_Cnt_En,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Read_Byte_Cnt,
   input [C_NUM_MONITOR_SLOTS-1:0]  Write_Beat_Cnt_En,
   input [C_NUM_MONITOR_SLOTS-1:0]  Read_Beat_Cnt_En,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Write_Beat_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Write_Beat_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Write_Beat_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Write_Beat_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Write_Beat_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Write_Beat_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Write_Beat_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Write_Beat_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Slv_Wr_Idle_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Slv_Wr_Idle_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Slv_Wr_Idle_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Slv_Wr_Idle_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Slv_Wr_Idle_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Slv_Wr_Idle_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Slv_Wr_Idle_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Slv_Wr_Idle_Cnt,
   input [C_NUM_MONITOR_SLOTS-1:0]  Read_Latency_En,        
   input [C_NUM_MONITOR_SLOTS-1:0]  Write_Latency_En,        
   input [C_NUM_MONITOR_SLOTS-1:0]  Slv_Wr_Idle_Cnt_En,        
   input [C_NUM_MONITOR_SLOTS-1:0]  Mst_Rd_Idle_Cnt_En,        
   input [C_NUM_MONITOR_SLOTS-1:0]  Num_BValids_En,       
   input [C_NUM_MONITOR_SLOTS-1:0]  Num_WLasts_En,             
   input [C_NUM_MONITOR_SLOTS-1:0]  Num_RLasts_En,      

   //-- AXI Streaming metrics
   input [C_NUM_MONITOR_SLOTS-1:0]  S_Transfer_Cnt_En,
   input [C_NUM_MONITOR_SLOTS-1:0]  S_Packet_Cnt_En,  
   input [C_METRIC_COUNT_WIDTH-1:0] S0_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_S_Data_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_S_Position_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_S_Null_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_S_Null_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_S_Null_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_S_Null_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_S_Null_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_S_Null_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_S_Null_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_S_Null_Byte_Cnt,
   input [C_NUM_MONITOR_SLOTS-1:0]  S_Slv_Idle_Cnt_En,
   input [C_NUM_MONITOR_SLOTS-1:0]  S_Mst_Idle_Cnt_En,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Max_Write_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Max_Write_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Max_Write_Latency,         
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Max_Write_Latency,         
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Max_Write_Latency,         
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Max_Write_Latency,         
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Max_Write_Latency,         
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Max_Write_Latency,         
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Min_Write_Latency,       
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Max_Read_Latency,     
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Max_Read_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Max_Read_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Max_Read_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Max_Read_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Max_Read_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Max_Read_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Max_Read_Latency,                 
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Min_Read_Latency,            
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Min_Read_Latency,            
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Min_Read_Latency,            
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Min_Read_Latency,            
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Min_Read_Latency,            
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Min_Read_Latency,            
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Min_Read_Latency,            
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Min_Read_Latency, 

   //-- External Events
   input [C_NUM_MONITOR_SLOTS-1:0]  External_Event_Cnt_En,

   //-- Cnt Enable and Reset
   input                            Metrics_Cnt_En,
   input                            Metrics_Cnt_Reset,

   //-- Metric Selector
   input  [7:0]                     Metric_Sel,    

   // Range Register - in core clk domain
   input  [31:0]                    Range_Reg,    

   // Metric Counters - in core clk domain
   output [31:0]                    Metric_Cnt,    

   // Incrementers in core clk domain
   output [31:0]                    Incrementer,

   // OverFlows
   output                           Acc_OF,    
   output                           Incr_OF    


);




//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;


//-------------------------------------------------------------------
// Signal Declaration
//-------------------------------------------------------------------
reg [31:0]                    Add_in;    
reg                           Add_in_Valid;    
reg accumulate;

reg [31:0]                    incrementer_input_reg_val;    

wire  [C_METRIC_COUNT_WIDTH-1:0] Write_Byte_Cnt [7:0];
wire  [C_METRIC_COUNT_WIDTH-1:0] Read_Byte_Cnt [7:0];
wire  [C_METRIC_COUNT_WIDTH-1:0] Read_Latency  [7:0];
wire  [C_METRIC_COUNT_WIDTH-1:0] Write_Latency [7:0];
wire  [C_METRIC_COUNT_WIDTH-1:0] Write_Beat_Cnt [7:0];
wire  [C_METRIC_COUNT_WIDTH-1:0] Slv_Wr_Idle_Cnt [7:0];
wire  [C_METRIC_COUNT_WIDTH-1:0] S_Data_Byte_Cnt [7:0];
wire  [C_METRIC_COUNT_WIDTH-1:0] S_Position_Byte_Cnt [7:0];
wire  [C_METRIC_COUNT_WIDTH-1:0] S_Null_Byte_Cnt [7:0];
wire  [C_METRIC_COUNT_WIDTH-1:0] Min_Write_Latency [7:0];
wire  [C_METRIC_COUNT_WIDTH-1:0] Max_Write_Latency [7:0];
wire  [C_METRIC_COUNT_WIDTH-1:0] Min_Read_Latency  [7:0];
wire  [C_METRIC_COUNT_WIDTH-1:0] Max_Read_Latency  [7:0];


//---------------------------------------------------------------------
// Wire assignments
//---------------------------------------------------------------------

assign Write_Byte_Cnt[0] = S0_Write_Byte_Cnt;
assign Write_Byte_Cnt[1] = S1_Write_Byte_Cnt;
assign Write_Byte_Cnt[2] = S2_Write_Byte_Cnt;
assign Write_Byte_Cnt[3] = S3_Write_Byte_Cnt;
assign Write_Byte_Cnt[4] = S4_Write_Byte_Cnt;
assign Write_Byte_Cnt[5] = S5_Write_Byte_Cnt;
assign Write_Byte_Cnt[6] = S6_Write_Byte_Cnt;
assign Write_Byte_Cnt[7] = S7_Write_Byte_Cnt;

assign Read_Byte_Cnt[0] = S0_Read_Byte_Cnt;
assign Read_Byte_Cnt[1] = S1_Read_Byte_Cnt;
assign Read_Byte_Cnt[2] = S2_Read_Byte_Cnt;
assign Read_Byte_Cnt[3] = S3_Read_Byte_Cnt;
assign Read_Byte_Cnt[4] = S4_Read_Byte_Cnt;
assign Read_Byte_Cnt[5] = S5_Read_Byte_Cnt;
assign Read_Byte_Cnt[6] = S6_Read_Byte_Cnt;
assign Read_Byte_Cnt[7] = S7_Read_Byte_Cnt;

assign Read_Latency[0] = S0_Read_Latency;
assign Read_Latency[1] = S1_Read_Latency;
assign Read_Latency[2] = S2_Read_Latency;
assign Read_Latency[3] = S3_Read_Latency;
assign Read_Latency[4] = S4_Read_Latency;
assign Read_Latency[5] = S5_Read_Latency;
assign Read_Latency[6] = S6_Read_Latency;
assign Read_Latency[7] = S7_Read_Latency;

assign Write_Latency[0] = S0_Write_Latency;
assign Write_Latency[1] = S1_Write_Latency;
assign Write_Latency[2] = S2_Write_Latency;
assign Write_Latency[3] = S3_Write_Latency;
assign Write_Latency[4] = S4_Write_Latency;
assign Write_Latency[5] = S5_Write_Latency;
assign Write_Latency[6] = S6_Write_Latency;
assign Write_Latency[7] = S7_Write_Latency;

assign Write_Beat_Cnt[0] = S0_Write_Beat_Cnt;
assign Write_Beat_Cnt[1] = S1_Write_Beat_Cnt;
assign Write_Beat_Cnt[2] = S2_Write_Beat_Cnt;
assign Write_Beat_Cnt[3] = S3_Write_Beat_Cnt;
assign Write_Beat_Cnt[4] = S4_Write_Beat_Cnt;
assign Write_Beat_Cnt[5] = S5_Write_Beat_Cnt;
assign Write_Beat_Cnt[6] = S6_Write_Beat_Cnt;
assign Write_Beat_Cnt[7] = S7_Write_Beat_Cnt;

assign Slv_Wr_Idle_Cnt[0] = S0_Slv_Wr_Idle_Cnt;
assign Slv_Wr_Idle_Cnt[1] = S1_Slv_Wr_Idle_Cnt;
assign Slv_Wr_Idle_Cnt[2] = S2_Slv_Wr_Idle_Cnt;
assign Slv_Wr_Idle_Cnt[3] = S3_Slv_Wr_Idle_Cnt;
assign Slv_Wr_Idle_Cnt[4] = S4_Slv_Wr_Idle_Cnt;
assign Slv_Wr_Idle_Cnt[5] = S5_Slv_Wr_Idle_Cnt;
assign Slv_Wr_Idle_Cnt[6] = S6_Slv_Wr_Idle_Cnt;
assign Slv_Wr_Idle_Cnt[7] = S7_Slv_Wr_Idle_Cnt;


assign S_Data_Byte_Cnt[0] = S0_S_Data_Byte_Cnt;
assign S_Data_Byte_Cnt[1] = S1_S_Data_Byte_Cnt;
assign S_Data_Byte_Cnt[2] = S2_S_Data_Byte_Cnt;
assign S_Data_Byte_Cnt[3] = S3_S_Data_Byte_Cnt;
assign S_Data_Byte_Cnt[4] = S4_S_Data_Byte_Cnt;
assign S_Data_Byte_Cnt[5] = S5_S_Data_Byte_Cnt;
assign S_Data_Byte_Cnt[6] = S6_S_Data_Byte_Cnt;
assign S_Data_Byte_Cnt[7] = S7_S_Data_Byte_Cnt;

assign S_Position_Byte_Cnt[0] = S0_S_Position_Byte_Cnt;
assign S_Position_Byte_Cnt[1] = S1_S_Position_Byte_Cnt;
assign S_Position_Byte_Cnt[2] = S2_S_Position_Byte_Cnt;
assign S_Position_Byte_Cnt[3] = S3_S_Position_Byte_Cnt;
assign S_Position_Byte_Cnt[4] = S4_S_Position_Byte_Cnt;
assign S_Position_Byte_Cnt[5] = S5_S_Position_Byte_Cnt;
assign S_Position_Byte_Cnt[6] = S6_S_Position_Byte_Cnt;
assign S_Position_Byte_Cnt[7] = S7_S_Position_Byte_Cnt;

assign S_Null_Byte_Cnt[0] = S0_S_Null_Byte_Cnt;
assign S_Null_Byte_Cnt[1] = S1_S_Null_Byte_Cnt;
assign S_Null_Byte_Cnt[2] = S2_S_Null_Byte_Cnt;
assign S_Null_Byte_Cnt[3] = S3_S_Null_Byte_Cnt;
assign S_Null_Byte_Cnt[4] = S4_S_Null_Byte_Cnt;
assign S_Null_Byte_Cnt[5] = S5_S_Null_Byte_Cnt;
assign S_Null_Byte_Cnt[6] = S6_S_Null_Byte_Cnt;
assign S_Null_Byte_Cnt[7] = S7_S_Null_Byte_Cnt;

assign Min_Write_Latency[0] = S0_Min_Write_Latency;
assign Min_Write_Latency[1] = S1_Min_Write_Latency;
assign Min_Write_Latency[2] = S2_Min_Write_Latency;
assign Min_Write_Latency[3] = S3_Min_Write_Latency;
assign Min_Write_Latency[4] = S4_Min_Write_Latency;
assign Min_Write_Latency[5] = S5_Min_Write_Latency;
assign Min_Write_Latency[6] = S6_Min_Write_Latency;
assign Min_Write_Latency[7] = S7_Min_Write_Latency;

assign Max_Write_Latency[0] = S0_Max_Write_Latency;
assign Max_Write_Latency[1] = S1_Max_Write_Latency;
assign Max_Write_Latency[2] = S2_Max_Write_Latency;
assign Max_Write_Latency[3] = S3_Max_Write_Latency;
assign Max_Write_Latency[4] = S4_Max_Write_Latency;
assign Max_Write_Latency[5] = S5_Max_Write_Latency;
assign Max_Write_Latency[6] = S6_Max_Write_Latency;
assign Max_Write_Latency[7] = S7_Max_Write_Latency;

assign Min_Read_Latency[0] = S0_Min_Read_Latency;
assign Min_Read_Latency[1] = S1_Min_Read_Latency;
assign Min_Read_Latency[2] = S2_Min_Read_Latency;
assign Min_Read_Latency[3] = S3_Min_Read_Latency;
assign Min_Read_Latency[4] = S4_Min_Read_Latency;
assign Min_Read_Latency[5] = S5_Min_Read_Latency;
assign Min_Read_Latency[6] = S6_Min_Read_Latency;
assign Min_Read_Latency[7] = S7_Min_Read_Latency;

assign Max_Read_Latency[0] = S0_Max_Read_Latency;
assign Max_Read_Latency[1] = S1_Max_Read_Latency;
assign Max_Read_Latency[2] = S2_Max_Read_Latency;
assign Max_Read_Latency[3] = S3_Max_Read_Latency;
assign Max_Read_Latency[4] = S4_Max_Read_Latency;
assign Max_Read_Latency[5] = S5_Max_Read_Latency;
assign Max_Read_Latency[6] = S6_Max_Read_Latency;
assign Max_Read_Latency[7] = S7_Max_Read_Latency;

//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------


generate
if (C_ENABLE_EVENT_COUNT == 1) begin : GEN_MUX_N_CNT
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Add_in       <= 0;
           Add_in_Valid <= 1'b0;
           accumulate   <= 1'b0;
       end
       else begin
           accumulate   <= 1'b1;
           case (Metric_Sel[4:0])
               5'd0: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= { {31{1'b0}}, 1'b1 };
                   Add_in_Valid <= Wtrans_Cnt_En[Metric_Sel[7:5]];
               end
               5'd1: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= { {31{1'b0}}, 1'b1 };
                   Add_in_Valid <= Rtrans_Cnt_En[Metric_Sel[7:5]];
               end
               5'd2: begin
                   incrementer_input_reg_val <= Write_Beat_Cnt[Metric_Sel[7:5]];
                   Add_in       <= Write_Byte_Cnt[Metric_Sel[7:5]];
                   Add_in_Valid <= Write_Beat_Cnt_En[Metric_Sel[7:5]];
               end
               5'd3: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= Read_Byte_Cnt[Metric_Sel[7:5]];
                   Add_in_Valid <= Read_Beat_Cnt_En[Metric_Sel[7:5]];
               end
               5'd4: begin
                   //Add_in       <= { {31{1'b0}}, 1'b1 };
                   incrementer_input_reg_val <= Write_Beat_Cnt[Metric_Sel[7:5]];
                   Add_in       <= Write_Beat_Cnt[Metric_Sel[7:5]];
                   Add_in_Valid <= Write_Beat_Cnt_En[Metric_Sel[7:5]];
               end
               5'd5: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= Read_Latency[Metric_Sel[7:5]];
                   Add_in_Valid <= Read_Latency_En[Metric_Sel[7:5]];
               end
               5'd6: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= Write_Latency[Metric_Sel[7:5]];
                   Add_in_Valid <= Write_Latency_En[Metric_Sel[7:5]];
               end
               5'd7: begin
                   incrementer_input_reg_val <= Slv_Wr_Idle_Cnt[Metric_Sel[7:5]];
                   //Add_in       <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= Slv_Wr_Idle_Cnt[Metric_Sel[7:5]];
                   Add_in_Valid <= Slv_Wr_Idle_Cnt_En[Metric_Sel[7:5]];
               end
               5'd8: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= { {31{1'b0}}, 1'b1 };
                   Add_in_Valid <= Mst_Rd_Idle_Cnt_En[Metric_Sel[7:5]];
               end
               5'd9: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= { {31{1'b0}}, 1'b1 };
                   Add_in_Valid <= Num_BValids_En[Metric_Sel[7:5]];
               end
               5'd10: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= { {31{1'b0}}, 1'b1 };
                   Add_in_Valid <= Num_WLasts_En[Metric_Sel[7:5]];
               end
               5'd11: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= { {31{1'b0}}, 1'b1 };
                   Add_in_Valid <= Num_RLasts_En[Metric_Sel[7:5]];
               end
               5'd12: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= Min_Write_Latency[Metric_Sel[7:5]];
                   Add_in_Valid <= 1'b1;
                   accumulate   <= 1'b0;
               end
               5'd13: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= Max_Write_Latency[Metric_Sel[7:5]];
                   Add_in_Valid <= 1'b1;
                   accumulate   <= 1'b0;
               end
               5'd14: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= Min_Read_Latency[Metric_Sel[7:5]];
                   Add_in_Valid <= 1'b1;
                   accumulate   <= 1'b0;
               end
               5'd15: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= Max_Read_Latency[Metric_Sel[7:5]];
                   Add_in_Valid <= 1'b1;
                   accumulate   <= 1'b0;
               end
               5'd16: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= { {31{1'b0}}, 1'b1 };
                   Add_in_Valid <= S_Transfer_Cnt_En[Metric_Sel[7:5]];
               end
               5'd17: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= { {31{1'b0}}, 1'b1 };
                   Add_in_Valid <= S_Packet_Cnt_En[Metric_Sel[7:5]];
               end
               5'd18: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= S_Data_Byte_Cnt[Metric_Sel[7:5]];
                   Add_in_Valid <= S_Transfer_Cnt_En[Metric_Sel[7:5]];
               end
               5'd19: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= S_Position_Byte_Cnt[Metric_Sel[7:5]];
                   Add_in_Valid <= S_Transfer_Cnt_En[Metric_Sel[7:5]];
               end
               5'd20: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= S_Null_Byte_Cnt[Metric_Sel[7:5]];
                   Add_in_Valid <= S_Transfer_Cnt_En[Metric_Sel[7:5]];
               end
               5'd21: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= { {31{1'b0}}, 1'b1 };
                   Add_in_Valid <= S_Slv_Idle_Cnt_En[Metric_Sel[7:5]];
               end
               5'd22: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= { {31{1'b0}}, 1'b1 };
                   Add_in_Valid <= S_Mst_Idle_Cnt_En[Metric_Sel[7:5]];
               end
               5'd30: begin
                   incrementer_input_reg_val <= { {31{1'b0}}, 1'b1 };
                   Add_in       <= { {31{1'b0}}, 1'b1 };
                   Add_in_Valid <= External_Event_Cnt_En[Metric_Sel[7:5]];
               end
               default: begin
                   incrementer_input_reg_val <= {32{1'b0}};
                   Add_in       <= {32{1'b0}};
                   Add_in_Valid <= 1'b0;
               end
           endcase
       end
    end 

    //-- Accumulator and Incrementer Instantiation
    axi_perf_mon_v5_0_9_acc_n_incr 
      #(
           .C_FAMILY             (C_FAMILY            ),
           .DWIDTH               (C_METRIC_COUNT_WIDTH),
           .C_SCALE              (C_METRIC_COUNT_SCALE),
	   .COUNTER_LOAD_VALUE   (COUNTER_LOAD_VALUE  )
       ) acc_n_incr_inst 
       (
           .clk                  (clk),
           .rst_n                (rst_n),
           .Enable               (Metrics_Cnt_En),
           .Reset                (Metrics_Cnt_Reset),
           .Range_Reg            (Range_Reg),
           .Add_in               (Add_in),
           .Add_in_Valid         (Add_in_Valid),
           .Accumulate           (accumulate),
           .Accumulator          (Metric_Cnt),
           .incrementer_input_reg_val (incrementer_input_reg_val),
           .Incrementer          (Incrementer),
           .Acc_OF               (Acc_OF),
           .Incr_OF              (Incr_OF)
       );
    
end    
else begin : GEN_NO_MUX_N_CNT
     assign Metric_Cnt  = 0;
     assign Incrementer = 0;
     assign Acc_OF      = 1'b0;
     assign Incr_OF     = 1'b0;
end
endgenerate




endmodule       
