//-----------------------------------------------------------------------------
// axi_perf_mon_v5_0_9_postTriggerMarker  module
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
// Filename     : axi_perf_mon_v5_0_9_postTriggerMarker.v
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
// Kartheek    15/01/2015      First Version
// ^^^^^^
//---------------------------------------------------------------------------

module axi_perf_mon_v5_0_9_postTriggerMarker
  # (
     parameter C_FAMILY                 = "nofamily",
     parameter C_MON_FIFO_DATA_WIDTH    = 64,
     parameter C_LOG_WIDTH              = 71,
     parameter C_FLAG_WIDTH             = 7,  //-- 7: for AXI4   2: for AXI4S
     //AXI Slot Interface parameters
     parameter C_AXI_ADDR_WIDTH         = 32,
     parameter C_AXI_DATA_WIDTH         = 32,
     parameter C_AXI_ID_WIDTH           = 1,
     parameter C_AXI_PROTOCOL           = "AXI4",
     parameter C_SHOW_AXI_IDS           = 1,
     parameter C_SHOW_AXI_LEN           = 1,
     
     parameter C_EN_WR_ADD_FLAG         = 1,
     parameter C_EN_FIRST_WRITE_FLAG    = 1, 
     parameter C_EN_LAST_WRITE_FLAG     = 1, 
     parameter C_EN_RESPONSE_FLAG       = 1, 
     parameter C_EN_RD_ADD_FLAG         = 1, 
     parameter C_EN_FIRST_READ_FLAG = 1, 
     parameter C_EN_LAST_READ_FLAG      = 1, 
     parameter C_OUTSTANDING_TRANX      = 6,

     parameter C_FLAG_SPLIT_POINT        = 4,
     parameter C_EN_EXT_EVENTS_FLAG     = 0
     )
   (
     input 		      clk,
     input 		      rst_n,

     input 		      trigger, // assuming that the trigger signal has been synchronized
     
     input [C_LOG_WIDTH-1:0]  Log_Data,
     input 		      Log_En,
     input 		      reStart,
     output [C_LOG_WIDTH+3:0] Log_Data_Marked,
     output 		      Log_en_out

    
   );
   localparam C_PATH_WIDTH = C_AXI_ADDR_WIDTH+8+2; // 8 is burst length, 2 bit for tokens.
   localparam RD_START_TOKEN = 1;
   localparam RD_END_TOKEN =0;
   localparam WR_START_TOKEN = C_PATH_WIDTH+1;
   localparam WR_END_TOKEN =C_PATH_WIDTH;
   
  
   // parse the start events and end events
   wire 		     Rd_startToken =  Log_Data[RD_START_TOKEN]; 
   wire 		     Rd_endToken = Log_Data [RD_END_TOKEN]; 		     

   wire 		     Wr_startToken = Log_Data[WR_START_TOKEN] ;
   wire 		     Wr_endToken = Log_Data[WR_END_TOKEN] ;

   

   wire 		     Wr_mark_start, Wr_mark_end;
   wire 		     Rd_mark_start, Rd_mark_end; 		     


   reg [C_PATH_WIDTH-1:0]  writePath;
   reg [C_PATH_WIDTH-1:0]  readPath;
   wire [C_PATH_WIDTH+1:0] marked_write_out, marked_read_out;
   wire 		   wr_en, rd_en;
   reg 			   mark_first_trigger;
   wire 		   first_trigger;
   

   // generate post-trigger markers for start and end events
   axi_perf_mon_v5_0_9_throttle throttle_rd (
			 // Outputs
			 .enable_start_out		(Rd_mark_start),
			 .enable_end_out		(Rd_mark_end),
			 // Inputs
			 .clk			(clk),
			 .rst_n			(rst_n),
			 .start_token		(Rd_startToken),
			 .end_token		(Rd_endToken),
			 .reStart (reStart),
			 .trigger		(trigger));
   axi_perf_mon_v5_0_9_throttle throttle_wr (
			 // Outputs
			 .enable_start_out		(Wr_mark_start),
			 .enable_end_out		(Wr_mark_end),
			 // Inputs
			 .clk			(clk),
			 .rst_n			(rst_n),
			 .start_token		(Wr_startToken),
			 .end_token		(Wr_endToken),
			 .reStart (reStart),
			 .trigger		(trigger));
   
   
   always @(posedge clk or negedge rst_n )
     if (!rst_n)
       begin

	  readPath <= {C_PATH_WIDTH{1'b0}};
	  writePath <= {C_PATH_WIDTH{1'b0}};

       end
     else begin
	writePath <= {Log_Data[2*C_PATH_WIDTH-1:C_PATH_WIDTH] }; 
	readPath <= {Log_Data[C_PATH_WIDTH-1: 0]};
     end

   wire [C_AXI_ADDR_WIDTH-1 :0] AWADDR = writePath [C_PATH_WIDTH-1 : C_PATH_WIDTH-C_AXI_ADDR_WIDTH];
    wire [C_AXI_ADDR_WIDTH-1 :0] ARADDR = readPath [C_PATH_WIDTH-1 : C_PATH_WIDTH-C_AXI_ADDR_WIDTH];


   always @(posedge clk or negedge rst_n )
     if (!rst_n ) begin

	mark_first_trigger <= 1'h0;

     end
     else
       begin
	  if (reStart )
	    mark_first_trigger <=0;
	  else if (trigger)
	    mark_first_trigger <=1;
	  else if (!trigger )
	    mark_first_trigger <=0;
	 
       end
   
   // when trigger signal comes in, genereate a one-cyle pulse.  
   assign first_trigger = (~mark_first_trigger) & trigger;

   assign marked_write_out = {writePath, {Wr_mark_start,Wr_mark_end}};
   assign marked_read_out  = {readPath, {Rd_mark_start,Rd_mark_end}};

   //generate enable sigal for FIFO usage
   assign wr_en = writePath[1]|writePath[0];
   assign rd_en = readPath[1]|readPath[0];

   assign Log_Data_Marked = {marked_write_out,marked_read_out };

   
   assign Log_en_out = wr_en |rd_en |first_trigger;
		      

   
endmodule 
