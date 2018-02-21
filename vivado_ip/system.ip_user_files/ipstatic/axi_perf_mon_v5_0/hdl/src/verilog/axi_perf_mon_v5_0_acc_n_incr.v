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
// Filename:       axi_perf_mon_v5_0_9_acc_n_incr.v
// Version :       v5.0
// Description:    Accumulator and incrementor module accumulates and increments
//                 the metric counts based on low and high range values from 
//                 register module.
// Verilog-Standard:verilog-2001
//---------------------------------------------------------------------------
// Structure:   
// --  axi_perf_mon.v
//        \-- axi_perf_mon_v5_0_9_metric_counters.v
//         \-- axi_perf_mon_v5_0_9_metric_sel_n_cnt.v 
//          \--axi_perf_mon_v5_0_9_acc_n_incr.v
//-----------------------------------------------------------------------------
// Author:      Kalpanath
// History:
// Kalpanath 07/25/2012      First Version
// ^^^^^^
// NLR       10/02/2013      Added scaling factor support  
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
(* DowngradeIPIdentifiedWarnings="yes" *)

module axi_perf_mon_v5_0_9_acc_n_incr 
#(
   parameter                  C_FAMILY = "nofamily",
   parameter                  DWIDTH   = 32,
   parameter                  C_SCALE  = 1,
   parameter                  COUNTER_LOAD_VALUE  = 32'h00000000  

)
(
   input                      clk,
   input                      rst_n,

   input                      Enable,   
   input                      Reset,   

   input  [31:0]              Range_Reg,  

   input  [(DWIDTH - 1):0]    Add_in,  
   input                      Add_in_Valid,  
   input                      Accumulate, 
   input  [(DWIDTH - 1):0]    incrementer_input_reg_val,
   output [(DWIDTH - 1):0]    Accumulator,  
   output reg [(DWIDTH - 1):0] Incrementer,  

   output reg                 Acc_OF,   
   output reg                 Incr_OF   

);



//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;
localparam C_DWIDTH = DWIDTH+3;
localparam ALL_ZEROES = {DWIDTH{1'b0}};
localparam ZEROES = {4{1'b0}};

//-------------------------------------------------------------------
// Signal Declaration
//-------------------------------------------------------------------
reg                      Incr_by_1;
reg [C_DWIDTH:0]         Accum_i;  

wire                     Overflow;
reg                      Overflow_D1;
wire [(DWIDTH - 1):0]    Incrementer_i1;  
reg [DWIDTH:0]    Incrementer_i;  
reg  [(DWIDTH - 1):0]    incrementer_input_reg_val_i;
reg                      Incr_OF_i;
reg                      Incr_OF_i1;
wire                     Incr_OF_i2;
reg                      Add_in_Valid_i;
//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------

wire [15:0] Range_LOW  = Range_Reg[15:0];
wire [15:0] Range_HIGH = Range_Reg[31:16];

wire [15:0] Comp_Val   = Add_in[15:0];

//-- Comparator
always @(posedge clk) begin 
   if (rst_n == RST_ACTIVE) begin
       Incr_by_1 <= 1'b0;
   end
   else begin
       if ((Comp_Val >= Range_LOW) && (Comp_Val <= Range_HIGH)) begin
           Incr_by_1 <= Enable && Add_in_Valid;
       end
       else begin
           Incr_by_1 <= 1'b0;
       end
   end
end 

//-- Incrementer
axi_perf_mon_v5_0_9_counter 
  #(
       .C_FAMILY             (C_FAMILY),
       .C_NUM_BITS           (DWIDTH)
   ) counter_inst 
   (
       .clk                  (clk),
       .rst_n                (rst_n),
       .Load_In              (ALL_ZEROES),
       .Count_Enable         (Incr_by_1),
       .Count_Load           (Reset),
       .Count_Down           (1'b0),
       .Count_Out            (Incrementer_i1),
       .Carry_Out            (Incr_OF_i2)
   );

//Incrementer logic
always @(posedge clk) begin 
   if (rst_n == RST_ACTIVE) begin
       Incrementer_i <= 33'b0;
       //Incr_OF_i   <= 1'b0;
   end
   else begin
       //Add_in_Valid_i <= Add_in_Valid;
        incrementer_input_reg_val_i <= incrementer_input_reg_val;
       if(Reset == 1'b1)
        Incrementer_i <= {1'b0,ALL_ZEROES};
       else if(Incr_by_1 == 1'b1)
       Incrementer_i <= Incrementer_i+{1'b0,incrementer_input_reg_val_i};//-1'b1;
      // else
     //  Incrementer <= Incrementer_i;
   end
end

 
//-- Delaying Overflow
always @(posedge clk) begin 
   if (rst_n == RST_ACTIVE) begin
       Incr_OF_i1 <= 1'b0;
   end
   else begin
       Incr_OF_i1 <= Incrementer_i[DWIDTH];
   end
end 

//-- Overflow Pulse
always @(posedge clk) begin 
   if (rst_n == RST_ACTIVE) begin
       Incr_OF <= 1'b0;
       Incrementer <= ALL_ZEROES;
   end
   else begin
       Incr_OF <= Incrementer_i[DWIDTH] & (~Incr_OF_i1);
       Incrementer <= Incrementer_i[(DWIDTH-1):0];
   end
end 
 
//-- Accumulator
always @(posedge clk) begin 
   if (rst_n == RST_ACTIVE) begin
       Accum_i <= 0;
   end
   else begin
       if (Reset == 1'b1) begin
           Accum_i <= COUNTER_LOAD_VALUE;
       end
       else if ((Enable == 1'b1) && (Add_in_Valid == 1'b1) && (Accumulate == 1'b1)) begin
           Accum_i <= Accum_i + {ZEROES, Add_in};
       end
       else if ((Enable == 1'b1) && (Add_in_Valid == 1'b1)) begin
           Accum_i <= {ZEROES, Add_in};
       end
       else begin
           Accum_i <= Accum_i;
       end
   end
end 

//------------------------------------------------------------------
// Accumulator width based on the incoming scaling factor
// Metric accumulated value will be scaled down based on scaling factor
// This logic is to accommodate higher counts which are not fitting into
// 32 bit counter
//------------------------------------------------------------------

  generate if (C_SCALE == 1) begin
    assign Accumulator = Accum_i[C_DWIDTH -4:0];
    assign Overflow    = Accum_i[C_DWIDTH-3] ;
  end
  else if(C_SCALE == 2) begin
    assign Accumulator = Accum_i[C_DWIDTH -3:1];
    assign Overflow    = Accum_i[C_DWIDTH-2] ;
  end
  else if(C_SCALE == 4) begin
    assign Accumulator = Accum_i[C_DWIDTH -2:2];
    assign Overflow    = Accum_i[C_DWIDTH-1] ;
  end
  else if(C_SCALE == 8) begin
    assign Accumulator = Accum_i[C_DWIDTH -1:3];
    assign Overflow    = Accum_i[C_DWIDTH] ;
  end  
  endgenerate

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
       Acc_OF <= 1'b0;
   end
   else begin
       Acc_OF <= Overflow & (~Overflow_D1);
   end
end 

endmodule






