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
// Filename   :  axi_perf_mon_v5_0_9_samp_intl_cnt.v
// Version    :  v5.0
// Description:  sample interval counter module instantiates the counter
//               with load value from sample interval register  
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
// axi_perf_mon.v
//      \-- axi_perf_mon_v5_0_9_samp_intl_cnt.v
//-----------------------------------------------------------------------------
// Author:      Kalpanath
// History:
// Kalpanath 07/25/2012      First Version
// ^^^^^^
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module axi_perf_mon_v5_0_9_samp_intl_cnt 
#(
   parameter                          C_FAMILY             = "nofamily",
   parameter                          C_METRICS_SAMPLE_COUNT_WIDTH = 32
)
(
   input                                         clk,
   input                                         rst_n,
   input                                         Interval_Cnt_En,   
   input                                         Interval_Cnt_Ld,   
   input  [(C_METRICS_SAMPLE_COUNT_WIDTH - 1):0] Interval_Cnt_Ld_Val,  
   output [(C_METRICS_SAMPLE_COUNT_WIDTH - 1):0] Sample_Interval_Cnt,  
   output                                        Sample_Interval_Cnt_Lapse   

);



//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;
localparam ALL_ZEROES = {C_METRICS_SAMPLE_COUNT_WIDTH{1'b0}};

//-------------------------------------------------------------------
// Signal Declaration
//-------------------------------------------------------------------
wire Sample_Interval_Cnt_Lapse_int;
wire Sample_Cnt_Ld = Interval_Cnt_Ld | Sample_Interval_Cnt_Lapse_int;

//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------

//-- Counter Instantiation
axi_perf_mon_v5_0_9_counter 
  #(
       .C_FAMILY             (C_FAMILY),
       .C_NUM_BITS           (C_METRICS_SAMPLE_COUNT_WIDTH),
       .COUNTER_LOAD_VALUE   (32'h00000000)
   ) counter_inst 
   (
       .clk                  (clk),
       .rst_n                (rst_n),
       .Load_In              (Interval_Cnt_Ld_Val),
       .Count_Enable         (Interval_Cnt_En),
       .Count_Load           (Sample_Cnt_Ld),
       .Count_Down           (1'b1),
       .Count_Out            (Sample_Interval_Cnt),
       .Carry_Out            (Sample_Interval_Cnt_Lapse_int)
   );

assign Sample_Interval_Cnt_Lapse = Sample_Interval_Cnt_Lapse_int;


endmodule


