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
// Filename     : axi_perf_mon_v5_0_9_samp_metrics_data.v
// Version      : v5.0
// Description  : sampled metrics data registering module
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
//  axi_perf_mon.v
//      \
//      \-- axi_perf_mon_v5_0_9_samp_metrics_data.v
//
//-----------------------------------------------------------------------------
// Author:    Kalpanath
// History:    
// Kalpanath 07/25/2012      First Version
// ~~~~~~
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module axi_perf_mon_v5_0_9_samp_metrics_data 
#(
   parameter                              C_FAMILY                     = "virtex7",

   parameter                              C_NUM_OF_COUNTERS            = 10,
   parameter                              C_ENABLE_EVENT_COUNT         = 1,  //-- enables/disables perf mon counting logic
   parameter                              C_HAVE_SAMPLED_METRIC_CNT    = 1   //-- enable sampled metric counters logic
)
(
   input                                             clk,
   input                                             rst_n,

   input                                             Sample_En,

   // Metric Counters - in core clk domain
   input [31:0]                                      Metric_Cnt_0,    
   input [31:0]                                      Metric_Cnt_1,    
   input [31:0]                                      Metric_Cnt_2,    
   input [31:0]                                      Metric_Cnt_3,    
   input [31:0]                                      Metric_Cnt_4,    
   input [31:0]                                      Metric_Cnt_5,    
   input [31:0]                                      Metric_Cnt_6,    
   input [31:0]                                      Metric_Cnt_7,    
   input [31:0]                                      Metric_Cnt_8,    
   input [31:0]                                      Metric_Cnt_9,    

   // Incrementers in core clk domain
   input [31:0]                                      Incrementer_0,    
   input [31:0]                                      Incrementer_1,    
   input [31:0]                                      Incrementer_2,    
   input [31:0]                                      Incrementer_3,    
   input [31:0]                                      Incrementer_4,    
   input [31:0]                                      Incrementer_5,    
   input [31:0]                                      Incrementer_6,    
   input [31:0]                                      Incrementer_7,    
   input [31:0]                                      Incrementer_8,    
   input [31:0]                                      Incrementer_9,    

   // Sampled Metric Counters - in core clk domain
   output reg [31:0]                                 Samp_Metric_Cnt_0,    
   output reg [31:0]                                 Samp_Metric_Cnt_1,    
   output reg [31:0]                                 Samp_Metric_Cnt_2,    
   output reg [31:0]                                 Samp_Metric_Cnt_3,    
   output reg [31:0]                                 Samp_Metric_Cnt_4,    
   output reg [31:0]                                 Samp_Metric_Cnt_5,    
   output reg [31:0]                                 Samp_Metric_Cnt_6,    
   output reg [31:0]                                 Samp_Metric_Cnt_7,    
   output reg [31:0]                                 Samp_Metric_Cnt_8,    
   output reg [31:0]                                 Samp_Metric_Cnt_9,    

   // Sampled Incrementers - in core clk domain
   output reg [31:0]                                 Samp_Incrementer_0,    
   output reg [31:0]                                 Samp_Incrementer_1,    
   output reg [31:0]                                 Samp_Incrementer_2,    
   output reg [31:0]                                 Samp_Incrementer_3,    
   output reg [31:0]                                 Samp_Incrementer_4,    
   output reg [31:0]                                 Samp_Incrementer_5,    
   output reg [31:0]                                 Samp_Incrementer_6,    
   output reg [31:0]                                 Samp_Incrementer_7,    
   output reg [31:0]                                 Samp_Incrementer_8,    
   output reg [31:0]                                 Samp_Incrementer_9    


);




//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;


//-------------------------------------------------------------------
// Signal Declaration
//-------------------------------------------------------------------
wire [31:0]  all_zeros = 32'b0;    



//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------

//-- Sampled Metric Counter_0
generate
if ((C_HAVE_SAMPLED_METRIC_CNT == 1) && (C_ENABLE_EVENT_COUNT == 1)) begin : GEN_SAMPLE_METRIC_CNT_0
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Samp_Metric_Cnt_0  <= 0;
           Samp_Incrementer_0 <= 0;
       end
       else begin
           if (Sample_En == 1'b1) begin
               Samp_Metric_Cnt_0  <= Metric_Cnt_0;
               Samp_Incrementer_0 <= Incrementer_0;
           end
           else begin
               Samp_Metric_Cnt_0  <= Samp_Metric_Cnt_0;
               Samp_Incrementer_0 <= Samp_Incrementer_0;
           end
       end
    end 
end    
else begin : GEN_NO_SAMPLE_METRIC_CNT_0
    always @(*) 
        Samp_Metric_Cnt_0  <= all_zeros;
    always @(*) 
        Samp_Incrementer_0 <= all_zeros;
end
endgenerate

        
//-- Sampled Metric Counter_1
generate
if ((C_HAVE_SAMPLED_METRIC_CNT == 1) && (C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 1)) begin : GEN_SAMPLE_METRIC_CNT_1
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Samp_Metric_Cnt_1  <= 0;
           Samp_Incrementer_1 <= 0;
       end
       else begin
           if (Sample_En == 1'b1) begin
               Samp_Metric_Cnt_1  <= Metric_Cnt_1;
               Samp_Incrementer_1 <= Incrementer_1;
           end
           else begin
               Samp_Metric_Cnt_1  <= Samp_Metric_Cnt_1;
               Samp_Incrementer_1 <= Samp_Incrementer_1;
           end
       end
    end 
end    
else begin : GEN_NO_SAMPLE_METRIC_CNT_1
    always @(*) 
        Samp_Metric_Cnt_1  <= all_zeros;
    always @(*) 
        Samp_Incrementer_1 <= all_zeros;
end
endgenerate


//-- Sampled Metric Counter_2
generate
if ((C_HAVE_SAMPLED_METRIC_CNT == 1) && (C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 2)) begin : GEN_SAMPLE_METRIC_CNT_2
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Samp_Metric_Cnt_2  <= 0;
           Samp_Incrementer_2 <= 0;
       end
       else begin
           if (Sample_En == 1'b1) begin
               Samp_Metric_Cnt_2  <= Metric_Cnt_2;
               Samp_Incrementer_2 <= Incrementer_2;
           end
           else begin
               Samp_Metric_Cnt_2  <= Samp_Metric_Cnt_2;
               Samp_Incrementer_2 <= Samp_Incrementer_2;
           end
       end
    end 
end    
else begin : GEN_NO_SAMPLE_METRIC_CNT_2
    always @(*) 
        Samp_Metric_Cnt_2  <= all_zeros;
    always @(*) 
        Samp_Incrementer_2 <= all_zeros;
end
endgenerate


//-- Sampled Metric Counter_3
generate
if ((C_HAVE_SAMPLED_METRIC_CNT == 1) && (C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 3)) begin : GEN_SAMPLE_METRIC_CNT_3
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Samp_Metric_Cnt_3  <= 0;
           Samp_Incrementer_3 <= 0;
       end
       else begin
           if (Sample_En == 1'b1) begin
               Samp_Metric_Cnt_3  <= Metric_Cnt_3;
               Samp_Incrementer_3 <= Incrementer_3;
           end
           else begin
               Samp_Metric_Cnt_3  <= Samp_Metric_Cnt_3;
               Samp_Incrementer_3 <= Samp_Incrementer_3;
           end
       end
    end 
end    
else begin : GEN_NO_SAMPLE_METRIC_CNT_3
    always @(*) 
        Samp_Metric_Cnt_3  <= all_zeros;
    always @(*) 
        Samp_Incrementer_3 <= all_zeros;
end
endgenerate


//-- Sampled Metric Counter_4
generate
if ((C_HAVE_SAMPLED_METRIC_CNT == 1) && (C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 4)) begin : GEN_SAMPLE_METRIC_CNT_4
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Samp_Metric_Cnt_4  <= 0;
           Samp_Incrementer_4 <= 0;
       end
       else begin
           if (Sample_En == 1'b1) begin
               Samp_Metric_Cnt_4  <= Metric_Cnt_4;
               Samp_Incrementer_4 <= Incrementer_4;
           end
           else begin
               Samp_Metric_Cnt_4  <= Samp_Metric_Cnt_4;
               Samp_Incrementer_4 <= Samp_Incrementer_4;
           end
       end
    end 
end    
else begin : GEN_NO_SAMPLE_METRIC_CNT_4
    always @(*) 
       Samp_Metric_Cnt_4  <= all_zeros;
    always @(*) 
       Samp_Incrementer_4 <= all_zeros;
end
endgenerate


//-- Sampled Metric Counter_5
generate
if ((C_HAVE_SAMPLED_METRIC_CNT == 1) && (C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 5)) begin : GEN_SAMPLE_METRIC_CNT_5
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Samp_Metric_Cnt_5  <= 0;
           Samp_Incrementer_5 <= 0;
       end
       else begin
           if (Sample_En == 1'b1) begin
               Samp_Metric_Cnt_5  <= Metric_Cnt_5;
               Samp_Incrementer_5 <= Incrementer_5;
           end
           else begin
               Samp_Metric_Cnt_5  <= Samp_Metric_Cnt_5;
               Samp_Incrementer_5 <= Samp_Incrementer_5;
           end
       end
    end 
end    
else begin : GEN_NO_SAMPLE_METRIC_CNT_5
    always @(*) 
        Samp_Metric_Cnt_5  <= all_zeros;
    always @(*) 
        Samp_Incrementer_5 <= all_zeros;
end
endgenerate


//-- Sampled Metric Counter_6
generate
if ((C_HAVE_SAMPLED_METRIC_CNT == 1) && (C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 6)) begin : GEN_SAMPLE_METRIC_CNT_6
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Samp_Metric_Cnt_6  <= 0;
           Samp_Incrementer_6 <= 0;
       end
       else begin
           if (Sample_En == 1'b1) begin
               Samp_Metric_Cnt_6  <= Metric_Cnt_6;
               Samp_Incrementer_6 <= Incrementer_6;
           end
           else begin
               Samp_Metric_Cnt_6  <= Samp_Metric_Cnt_6;
               Samp_Incrementer_6 <= Samp_Incrementer_6;
           end
       end
    end 
end    
else begin : GEN_NO_SAMPLE_METRIC_CNT_6
    always @(*) 
        Samp_Metric_Cnt_6  <= all_zeros;
    always @(*) 
        Samp_Incrementer_6 <= all_zeros;
end
endgenerate


//-- Sampled Metric Counter_7
generate
if ((C_HAVE_SAMPLED_METRIC_CNT == 1) && (C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 7)) begin : GEN_SAMPLE_METRIC_CNT_7
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Samp_Metric_Cnt_7  <= 0;
           Samp_Incrementer_7 <= 0;
       end
       else begin
           if (Sample_En == 1'b1) begin
               Samp_Metric_Cnt_7  <= Metric_Cnt_7;
               Samp_Incrementer_7 <= Incrementer_7;
           end
           else begin
               Samp_Metric_Cnt_7  <= Samp_Metric_Cnt_7;
               Samp_Incrementer_7 <= Samp_Incrementer_7;
           end
       end
    end 
end    
else begin : GEN_NO_SAMPLE_METRIC_CNT_7
    always @(*) 
        Samp_Metric_Cnt_7  <= all_zeros;
    always @(*) 
        Samp_Incrementer_7 <= all_zeros;
end
endgenerate


//-- Sampled Metric Counter_8
generate
if ((C_HAVE_SAMPLED_METRIC_CNT == 1) && (C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 8)) begin : GEN_SAMPLE_METRIC_CNT_8
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Samp_Metric_Cnt_8  <= 0;
           Samp_Incrementer_8 <= 0;
       end
       else begin
           if (Sample_En == 1'b1) begin
               Samp_Metric_Cnt_8  <= Metric_Cnt_8;
               Samp_Incrementer_8 <= Incrementer_8;
           end
           else begin
               Samp_Metric_Cnt_8  <= Samp_Metric_Cnt_8;
               Samp_Incrementer_8 <= Samp_Incrementer_8;
           end
       end
    end 
end    
else begin : GEN_NO_SAMPLE_METRIC_CNT_8
    always @(*) 
        Samp_Metric_Cnt_8  <= all_zeros;
    always @(*) 
        Samp_Incrementer_8 <= all_zeros;
end
endgenerate


//-- Sampled Metric Counter_9
generate
if ((C_HAVE_SAMPLED_METRIC_CNT == 1) && (C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 9)) begin : GEN_SAMPLE_METRIC_CNT_9
    always @(posedge clk) begin 
       if (rst_n == RST_ACTIVE) begin
           Samp_Metric_Cnt_9  <= 0;
           Samp_Incrementer_9 <= 0;
       end
       else begin
           if (Sample_En == 1'b1) begin
               Samp_Metric_Cnt_9  <= Metric_Cnt_9;
               Samp_Incrementer_9 <= Incrementer_9;
           end
           else begin
               Samp_Metric_Cnt_9  <= Samp_Metric_Cnt_9;
               Samp_Incrementer_9 <= Samp_Incrementer_9;
           end
       end
    end 
end    
else begin : GEN_NO_SAMPLE_METRIC_CNT_9
    always @(*) 
       Samp_Metric_Cnt_9  <= all_zeros;
    always @(*) 
       Samp_Incrementer_9 <= all_zeros;
end
endgenerate





endmodule       
