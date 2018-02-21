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
// Filename:       axi_perf_mon_v5_0_9_acc_sample_profile.v
// Version :       v5.0
// Description:    Accumulator module accumulates metrics and samples
//                 into sampled metric counter if sampling trigger is set
// Verilog-Standard:verilog-2001
//---------------------------------------------------------------------------
// Structure:   
// --  axi_perf_mon_v5_0_9_top.v
// --  axi_perf_mon_v5_0_9_profile.v
//        \-- axi_perf_mon_v5_0_9_metric_counters_profile.v
//          \--axi_perf_mon_v5_0_9_acc_sample_profile.v
//-----------------------------------------------------------------------------
// Author:     NLR 
// History:
// NLR     02/10/2013      First Version
// ^^^^^^
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
(* DowngradeIPIdentifiedWarnings="yes" *)

module axi_perf_mon_v5_0_9_acc_sample_profile 
#(
   parameter                  C_FAMILY                   = "nofamily",
   parameter                  DWIDTH                     = 32,
   parameter                  C_HAVE_SAMPLED_METRIC_CNT  = 1
)
(
   input                      clk,
   input                      rst_n,
   input                      Sample_rst_n,

   input                      Enable,   
   input                      Reset,   

   input  [(DWIDTH - 1):0]    Add_in,  
   input                      Add_in_Valid,  
   input                      Accumulate, 
   input                      Sample_En,
   output [(DWIDTH - 1):0]    Accumulator,  
   output [(DWIDTH - 1):0]    Sample_Accumulator  
);



//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;

//-------------------------------------------------------------------
// Signal Declaration
//-------------------------------------------------------------------
reg [DWIDTH:0]           Accum_i;  
reg [DWIDTH-1:0]         Samp_Metric_Cnt;  

//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------

//-- Accumulator
always @(posedge clk) begin 
   if (rst_n == RST_ACTIVE) begin
       Accum_i <= 0;
   end
   else begin
       if (Reset == 1'b1) begin
           Accum_i <= 0;
       end
       else if (Enable == 1'b1 && Add_in_Valid == 1'b1 && Accumulate == 1'b1) begin
           Accum_i <= Accum_i + {1'b0, Add_in};
       end
       else if (Enable == 1'b1 && Add_in_Valid == 1'b1) begin
           Accum_i <= Add_in ;
       end
       else begin
           Accum_i <= Accum_i;
       end
   end
end 

   assign Accumulator = Accum_i[DWIDTH -1:0];
   assign Overflow    = Accum_i[DWIDTH] ;

//-- Sampled Metric Counter
generate
if (C_HAVE_SAMPLED_METRIC_CNT == 1)  begin : GEN_SAMPLE_METRIC_CNT
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Samp_Metric_Cnt  <= 0;
       end
       else begin
           if (Sample_rst_n == RST_ACTIVE) begin
             Samp_Metric_Cnt  <= 0;
           end
           else if (Sample_En == 1'b1) begin
             Samp_Metric_Cnt  <= Accum_i[DWIDTH -1:0];
           end
           else begin
             Samp_Metric_Cnt  <= Samp_Metric_Cnt;
           end
       end
    end 
    assign Sample_Accumulator = Samp_Metric_Cnt;
end    
else begin : GEN_NO_SAMPLE_METRIC_CNT
    assign Sample_Accumulator = 0;
end
endgenerate



endmodule






