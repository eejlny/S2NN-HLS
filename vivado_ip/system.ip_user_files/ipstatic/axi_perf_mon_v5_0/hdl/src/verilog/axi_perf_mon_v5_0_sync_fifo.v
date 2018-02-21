//-------------------------------------------------------------------------------
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
// Filename     : axi_perf_mon_v5_0_9_sync_fifo.v
// Version      : v5.0
// Description  : This is the verilog file for the synchronous fifo 
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
// --  axi_perf_mon.v
//      \-- axi_perf_mon_v5_0_9_metric_calc.v
//          \-- axi_perf_mon_v5_0_9_sync_fifo.v
//-----------------------------------------------------------------------------
// Author:   NLR 
// History:    
// NLR       06/19/2013      First Version
// ^^^^^^
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
(* DowngradeIPIdentifiedWarnings="yes" *)

module axi_perf_mon_v5_0_9_sync_fifo 
  #(
  parameter WIDTH      = 8, // The width of the FIFO data
  parameter DEPTH_LOG2 = 3  // Specify power-of-2 FIFO depth
)

(
  input                  rst_n,
  input                  clk,
  input                  wren,
  input                  rden,
  input      [WIDTH-1:0]  din,
  output reg [WIDTH-1:0]  dout,
  output reg             full,
  output reg             empty
);

  localparam DEPTH = 1 << DEPTH_LOG2;

/* ========================================================================== */
//  Register and Wire Declarations
/* ========================================================================== */
(* ram_style = "distributed" *) reg [WIDTH-1:0]      mem [0:DEPTH-1];// memory for storing FIFO data
reg [DEPTH_LOG2:0]  wptr; // wr ptr, with extra wrap bit
reg [DEPTH_LOG2:0]  rptr; // rd ptr, with extra wrap bit
//reg rd_en_del; //Delayed read enable
wire [DEPTH_LOG2:0]  wptr_inc;// wr ptr incremented by 1
wire [DEPTH_LOG2:0]  rptr_inc;// rd ptr incremented by 1
wire [DEPTH_LOG2:0]  wptr_nxt;// next wr ptr, with extra wrap bit
wire [DEPTH_LOG2:0]  rptr_nxt;// next rd ptr, with extra wrap bit
wire [DEPTH_LOG2-1:0] mem_wptr;// mem wrptr, extra bit removed
wire [DEPTH_LOG2-1:0] mem_rptr;// mem rdptr, extra bit removed
wire almost_full;              // only 1 entry available in FIFO
wire almost_empty;             // only 1 space used in FIFO

//================================================================================
// Code the FIFO
//================================================================================
assign wptr_inc = wptr + 1'b1; // automatically wraps
assign rptr_inc = rptr + 1'b1; // automatically wraps

assign wptr_nxt = wren ? wptr_inc : wptr;
assign rptr_nxt = rden ? rptr_inc : rptr;

assign mem_wptr = wptr[DEPTH_LOG2-1:0]; // get rid of extra bit
assign mem_rptr = rptr[DEPTH_LOG2-1:0]; // get rid of extra bit

// Assign dout
always @(posedge clk) begin
   //if (~rst_n)
   //    dout <= 0;
   //else if(rden == 1'b1) begin
    dout <= mem[mem_rptr];              //read data output
   //end
end

// Almost_full if one more write will make the FIFO full
assign almost_full = (wptr_inc[DEPTH_LOG2] != rptr[DEPTH_LOG2]) &&
              (wptr_inc[DEPTH_LOG2-1:0] == rptr[DEPTH_LOG2-1:0]);

// Almost_empty if one more read will make the FIFO empty
assign almost_empty = (wptr[DEPTH_LOG2:0] == rptr_inc[DEPTH_LOG2:0]);

// Flags
always @(posedge clk) begin
  if (~rst_n)
    begin
      full <= 1'b0;
      empty <= 1'b1;
      rptr <= {(DEPTH_LOG2+1){1'b0}};
      wptr <= {(DEPTH_LOG2+1){1'b0}};
    end
  else
    begin
      full <= (almost_full & wren & ~rden) | (full & ~rden);
      empty <= (almost_empty & rden & ~wren) | (empty & ~wren);
      rptr <= rptr_nxt;
      wptr <= wptr_nxt;
     // rd_en_del <= rden;
    end
end

// Assign memory
always @(posedge clk) begin
  if (wren)
    mem[mem_wptr] <= din;
end

endmodule
