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
// Filename   :  axi_perf_mon_v5_0_9_interrupt_module.v
// Version    :  v5.0
// Description:  AXI Performance monitor interrupt module generates
//               interrupt to processor based on different counter/fifo
//               overflow conditions
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
// axi_perf_mon.v
//      \-- axi_perf_mon_v5_0_9_interrupt_module.v
//-----------------------------------------------------------------------------
// Author:      Kalpanath
// History:
// Kalpanath 07/25/2012      First Version
// ^^^^^^
//----------------------------------------------------------------------------- 
`timescale 1ns/1ps

module axi_perf_mon_v5_0_9_interrupt_module 
#(
   parameter                          C_FAMILY          = "nofamily",
   parameter                          C_NUM_INTR_INPUTS = 10
)
(
   input                                  clk,
   input                                  rst_n,
   input      [(C_NUM_INTR_INPUTS - 1):0] Intr,
   input                                  Interrupt_Enable,

   input                                  IER_Wr_En,
   input                                  ISR_Wr_En,
   input      [(C_NUM_INTR_INPUTS - 1):0] Wr_Data,

   output reg [(C_NUM_INTR_INPUTS - 1):0] IER, 
   output reg [(C_NUM_INTR_INPUTS - 1):0] ISR, 

   output reg                             Interrupt


);

//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;

//-------------------------------------------------------------------
// Signal Declaration
//-------------------------------------------------------------------

wire                             irq_gen;  


//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------

always @(posedge clk) begin
   if (rst_n == RST_ACTIVE) begin
       IER <= 0;
   end
   else begin
       if (IER_Wr_En == 1'b1) begin
           IER <= Wr_Data;
       end
       else begin
           IER <= IER;
       end
   end
end 

genvar i;
generate
for (i=0; i < C_NUM_INTR_INPUTS ; i=i+1) begin : GEN_ISR_REG
    always @(posedge clk) begin
       if (rst_n == RST_ACTIVE) begin
           ISR[i] <= 1'b0;
       end
       else begin
           if ((ISR_Wr_En == 1'b1) && (Wr_Data[i] == 1'b1)) begin
               ISR[i] <= 1'b0;
           end
           else if ((Intr[i] == 1'b1)) begin
               ISR[i] <= 1'b1;
           end
           else begin
               ISR[i] <= ISR[i];
           end
       end
    end 
end    
endgenerate


assign irq_gen = | (ISR & IER);


always @(posedge clk) begin
   if (rst_n == RST_ACTIVE) begin
       Interrupt <= 1'b0;
   end
   else begin
       Interrupt <= irq_gen && Interrupt_Enable;
   end
end 

endmodule






