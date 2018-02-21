//-----------------------------------------------------------------------------
// axi_perf_mon_v5_0_9_throttle  module
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
// Filename     : axi_perf_mon_v5_0_9_throttle.v
// Version      : v5.0
// Description  : This is the top level wrapper file for the AXI Performance
//                Monitor profile mode. 
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
// axi_perf_mon_v5_0_9_top.v
//   \--axi_perf_mon_v5_0_9_profile.v
//     \-- axi_perf_mon_v5_0_9_axi_interface.v
//             \--axi_perf_mon_v5_0_9_cdc_sync.v
//             \-- axi_perf_mon_v5_0_9_intr_sync.v
//                 \--axi_perf_mon_v5_0_9_cdc_sync.v
//      \-- axi_perf_mon_v5_0_9_interrupt_module.v
//      \-- axi_perf_mon_v5_0_9_cdc_sync.v
//      \-- axi_perf_mon_v5_0_9_mon_fifo.v
//           \-- axi_perf_mon_v5_0_9_async_fifo.vhd
//       \-- axi_perf_mon_v5_0_9_register_module_profile.v
//       \-- axi_perf_mon_v5_0_9_metric_calc_profile.v
//            \-- axi_perf_mon_v5_0_9_sync_fifo.vhd
//            \-- axi_perf_mon_v5_0_9_counter.v
//       \-- axi_perf_mon_v5_0_9_metric_counters_profile.v
//           \-- axi_perf_mon_v5_0_9_acc_sample_profile.v
//       \-- axi_perf_mon_v5_0_9_postTriggerMarker.v
//           \-- axi_perf_mon_v5_0_9_throttle.v
//      \-- axi_perf_mon_v5_0_9_strm_fifo_wr_logic.v
//      \-- axi_perf_mon_v5_0_9_async_stream_fifo.v
//       \-- axi_perf_mon_v5_0_9_flags_gen_trace.v
//---------------------------------------------------------------------------
// Author  :   Kartheek 
// History :    
// Kartheek    19/01/2015      First Version
// ^^^^^^
//---------------------------------------------------------------------------
//Aligning start and end events of transactions

`timescale 1ns/1ps
(* DowngradeIPIdentifiedWarnings="yes" *)

module axi_perf_mon_v5_0_9_throttle 
	    (
		 input 	clk,
		 input 	rst_n,
		 input 	start_token,
		 input 	end_token,
		 input 	trigger,
	    input   reStart,
		 output  enable_start_out,
	    output enable_end_out		
		 );

   parameter COUNTER_Width=6;    // counter width
   // counter used to count AXI outstanding tranx
   reg [COUNTER_Width:0] outstanding_c;
   reg [COUNTER_Width:0] outstanding_r; 
   reg [COUNTER_Width :0] outstanding_in;

   // marders fro star and end events  
   reg 			   enable_start;
   reg 			   enable_end;
   reg [1:0] 			       currentState, nextState;

   localparam Idle = 2'b00;
   localparam Reset = 2'b01;
   localparam Filter = 2'b10;
   localparam Bypass =2'b11;
  

   always @ (posedge clk)
    begin
   	if (!rst_n ) begin
	    outstanding_c <=0;
	    outstanding_r <=0;
	   end
	   else  begin
	    if (reStart) begin
	     outstanding_c <= 0;
	     outstanding_r <=0;
	    end
	   else
	    begin
	     outstanding_r <= outstanding_in;
	     if (start_token && !end_token)
		   outstanding_c <= outstanding_c +1;
	     else if (!start_token && end_token)
		   outstanding_c <= outstanding_c -1;
	     else if (start_token && end_token)
		   outstanding_c <= outstanding_c;
	     else 
		   outstanding_c <= outstanding_c;
	     end
	   end
     end
   
   always @( end_token or nextState
	    or outstanding_c or outstanding_r or start_token)
     begin
	   if (nextState == Reset || nextState == Bypass)
	     outstanding_in <=0;
	   else if (nextState == Idle ) begin
	      if (start_token && !end_token)
		     outstanding_in <= outstanding_c +1;
	      else if (!start_token && end_token)
		     outstanding_in <= outstanding_c -1;
	      else if (start_token && end_token)
		     outstanding_in <= outstanding_c;
	      else 
		     outstanding_in <= outstanding_c;
	   end
	   else if (nextState == Filter ) begin
	    if (end_token )
	     outstanding_in <= outstanding_r -1;
	    else
	     outstanding_in <= outstanding_r;
	   end
	   else
	     outstanding_in <= 0;
      end
//state machine, used to align the starts and ends of AXI outstanding tranx      

   always @(posedge clk)
    begin
   	if (!rst_n)
	    begin
	     enable_end <= 1'h0;
	     enable_start <= 1'h0;
	    end
	   else
	    begin
	     case (nextState)
		   Reset: begin
		    enable_end <= 1'h0;
		    enable_start <= 1'h0;
		   end
		   Idle:
		    begin
		     enable_start <= 1'b0;
		     enable_end <= 1'b0;
		    end
		   Filter: begin
		     enable_end <= 1'b0;
		     enable_start <=start_token;
		   end
		   Bypass: begin
		    enable_start<=start_token;
		    enable_end <= end_token;
		   end
		   default: begin
		    enable_start <=1'b0;
		    enable_end <=1'b0;
		   end
      endcase
	  end
    end // always @ (posedge clk or negedge rst_n)
   

   always @(currentState or outstanding_r or trigger)
     begin
	  case (currentState )
	    Reset:begin
	     nextState <= Idle;
	    end
	    Idle: begin
	     if (trigger) begin 
		   nextState <= Filter;
	     end
	     else
	       nextState <= Idle;
	    end
	    Filter : begin
	     if (trigger == 1) begin 
	       if (outstanding_r == 0)
		     nextState <= Bypass;
	       else
		     nextState <= Filter;
	     end
	     else
	      nextState <= Reset;
	    end
	    Bypass:begin
	     if (trigger)
	       nextState <= Bypass;
	     else
	       nextState <= Reset;
	    end
	    default:
	     nextState <= Reset;
   	endcase // case (currentState )
     end

     always @ (posedge clk) begin
     if (!rst_n ) begin
       currentState <= 2'b0;
     end
     else
       currentState <=nextState;
     end

   assign enable_start_out = enable_start;
   assign enable_end_out = enable_end;
   

endmodule // throttle
