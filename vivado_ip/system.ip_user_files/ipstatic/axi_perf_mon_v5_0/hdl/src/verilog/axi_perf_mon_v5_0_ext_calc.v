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
// Filename   :     axi_perf_mon_v5_0_9_ext_calc.v 
// Version    :     v5.0
// Description:     External event calculator module generates external event 
//                  metric count enables which will be used in metric counter
// Verilog-Standard:  Verilog 2001 
//-----------------------------------------------------------------------------
// Structure:
//  axi_perf_mon.v
//      \-- axi_perf_mon_v5_0_9_ext_calc.v
//-----------------------------------------------------------------------------
// Author :  NLR  
// History: 
// NLR       1/10/2012      First Version
// ^^^^^^
//-----------------------------------------------------------------------------
`timescale 1ns/1ps

module axi_perf_mon_v5_0_9_ext_calc 
   (
    //AXI Signals
    input                                 clk,        
    input                                 rst_n,     
    // External Events
    input                                 Ext_Event,
    input                                 Ext_Event_Start,
    input                                 Ext_Event_Stop,
    input                                 Ext_Event_Valid,
    // Register inputs
    input                                 Metrics_Cnt_En,
    input                                 Metrics_Cnt_Reset,
    //External Event outputs
    output reg                            External_Event_Cnt_En
    );

    //Parameter Declarations
    parameter RST_ACTIVE              = 0; 

    //Register declarations
    reg Ext_Event_going_on;
    reg Ext_Event_d1;
    reg Ext_Event_Valid_d1;

    //wire declaration
    wire rst_int_n = rst_n &  ~(Metrics_Cnt_Reset);

  // External event enable generation logic
  // Event going on signal generation based on start and stop signals

    always @(posedge clk) begin 
       if (rst_int_n == RST_ACTIVE) begin
           Ext_Event_going_on <= 1'b0;
       end
       else begin
           if (Ext_Event_Stop == 1'b1 && Ext_Event_Valid == 1'b1) begin
               Ext_Event_going_on <= 1'b0;
           end
           else if (Ext_Event_Start == 1'b1 && Ext_Event_Valid == 1'b1)  begin
               Ext_Event_going_on <= 1'b1;
           end
           else begin
               Ext_Event_going_on <= Ext_Event_going_on;
           end
       end
    end 

    // External event and corresponding event valid registering
    always @(posedge clk) begin 
       if(rst_int_n == RST_ACTIVE) begin
         Ext_Event_d1       <= 0;
         Ext_Event_Valid_d1 <= 0;
       end
       else begin
         Ext_Event_d1       <= Ext_Event;
         Ext_Event_Valid_d1 <= Ext_Event_Valid;
       end
    end
 
    // Event count enable generation 
    always @(posedge clk) begin 
       if(rst_int_n == RST_ACTIVE) begin
         External_Event_Cnt_En <= 1'b0;
       end
       else begin
         External_Event_Cnt_En <=Ext_Event_going_on & Ext_Event_d1 & Metrics_Cnt_En & Ext_Event_Valid_d1;
       end
    end


endmodule







