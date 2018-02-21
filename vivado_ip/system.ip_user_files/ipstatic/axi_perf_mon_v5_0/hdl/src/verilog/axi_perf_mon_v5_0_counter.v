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
// Filename   :     axi_perf_mon_v5_0_9_counter.v
// Version    :     v5.0
// Description:     Implements a parameterizable N-bit axi_perf_mon_v5_0_9_counter
//                  Up/Down axi_perf_mon_v5_0_9_counter
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
// axi_perf_mon.v
//     \-- axi_perf_mon_v5_0_9_metric_calc.v
//         \-- axi_perf_mon_v5_0_9_counter.v
//      \-- axi_perf_mon_v5_0_9_glbl_clk_cnt.v
//         \-- axi_perf_mon_v5_0_9_counter.v
//      \-- axi_perf_mon_v5_0_9_metric_counters.v
//         \-- axi_perf_mon_v5_0_9_metric_sel_n_cnt.v 
//            \--axi_perf_mon_v5_0_9_acc_n_incr.v
//               \--axi_perf_mon_v5_0_9_counter.v
//      \-- axi_perf_mon_v5_0_9_samp_intl_cnt.v
//               \-- axi_perf_mon_v5_0_9_counter.v
//-----------------------------------------------------------------------------
// Author:      Kalpanath
// History:
// Kalpanath 07/25/2012      First Version
// ^^^^^^
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
(* DowngradeIPIdentifiedWarnings="yes" *)

module axi_perf_mon_v5_0_9_counter 
#(
   parameter                          C_FAMILY             = "nofamily",
   parameter                          C_NUM_BITS           = 32,
   parameter                          COUNTER_LOAD_VALUE   = 32'h00000000
)
(
   input                              clk,
   input                              rst_n,

   input [(C_NUM_BITS - 1):0]         Load_In,  
   input                              Count_Enable,   
   input                              Count_Load,   
   input                              Count_Down,   
   output [(C_NUM_BITS - 1):0]        Count_Out,  
   output reg                         Carry_Out   

);

//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;

//-------------------------------------------------------------------
// Signal Declaration
//-------------------------------------------------------------------
wire [63:0] rst_load_64 = (COUNTER_LOAD_VALUE == 32'h00000000)?64'h0000000000000000:{32'hFFFFFFFF,COUNTER_LOAD_VALUE};
wire                    Overflow;
reg                     Overflow_D1;
reg  [C_NUM_BITS:0]     Count_Out_i;  

//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------
//-- counter
always @(posedge clk) begin
   if (rst_n == RST_ACTIVE) begin
       Count_Out_i <= {1'b0,rst_load_64[C_NUM_BITS-1:0]};
   end
   else begin
       if (Count_Load == 1'b1) begin
           Count_Out_i <= {1'b0, Load_In};
       end
       else if (Count_Enable == 1'b1) begin
           if (Count_Down == 1'b1) begin
               Count_Out_i <= Count_Out_i - 1;
           end
           else begin
               Count_Out_i <= Count_Out_i + 1;
           end
       end
       else begin
           Count_Out_i <= Count_Out_i;
       end
   end
end 


assign Overflow  = Count_Out_i[C_NUM_BITS] ;
assign Count_Out = Count_Out_i[C_NUM_BITS - 1:0];

//-- Delaying Overflow
always @(posedge clk) begin 
   if (rst_n == RST_ACTIVE) begin
       Overflow_D1 <= 1'b0;
   end
   else begin
       Overflow_D1 <= Overflow;
   end
end 

//-- Overflow Pulse
always @(posedge clk) begin 
   if (rst_n == RST_ACTIVE) begin
       Carry_Out <= 1'b0;
   end
   else begin
       Carry_Out <= Overflow & (~Overflow_D1);
   end
end 

endmodule


