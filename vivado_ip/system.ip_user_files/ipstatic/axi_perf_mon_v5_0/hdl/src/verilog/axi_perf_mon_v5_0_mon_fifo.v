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
// Filename     : axi_perf_mon_v5_0_9_mon_fifo.v
// Version      : v5.0
// Description  : This is the top level wrapper file for the monitor-Slots of AXI
//                interface. It has the AXI slots input and sends out the
//                synchronized outputs through Asynchronous FIFO
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
// --  axi_perf_mon.v
//      \-- axi_perf_mon_v5_0_9_mon_fifo.v
//
//-----------------------------------------------------------------------------
// Author :   NLR 
// History:    
// NLR       07/25/2012      First Version
// ^^^^^^
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
(* DowngradeIPIdentifiedWarnings="yes" *)

module axi_perf_mon_v5_0_9_mon_fifo 
  # (
    parameter C_FAMILY                        = "virtex7",
    parameter C_REG_ALL_MONITOR_SIGNALS       = 0,
    parameter C_MON_FIFO_DATA_WIDTH           = 64,
    parameter C_FIFO_ENABLE                   = 1
    )
    (
    input                                  Mon_clk,
    input                                  Mon_rst_n,
    //input                                  mon_en,
    input [C_MON_FIFO_DATA_WIDTH-1:0]      Data_In,
    input                                  CORE_ACLK,
    input                                  CORE_ARESETN,
    output [C_MON_FIFO_DATA_WIDTH-1:0]     Sync_Data_Out,
    output                                 Sync_Data_Valid
    );

    
   /*--------------------wire/connection declarations------------------*/
   
   localparam RST_ACTIVE = 1'b0; 

   /*--------------------wire/connection declarations------------------*/
 
   wire                                 fifo_rst    ;
   wire                                 fifo_wr_en  ;
   wire                                 fifo_rd_en  ;
   wire                                 fifo_full   ;
   wire                                 fifo_empty  ;
   wire [C_MON_FIFO_DATA_WIDTH-1:0]     Fifo_Data_In;
   wire [C_MON_FIFO_DATA_WIDTH-1:0]     Fifo_Data_Out;
   reg  [C_MON_FIFO_DATA_WIDTH-1:0]     Reg_Data_In ;
                             
   /*-------------Active high reset generation--------------------------*/

   assign fifo_rst = (~(Mon_rst_n) | ~(CORE_ARESETN)) ; //Active high reset to fifo


   /*--------------- Fifo write enable and read enable generation------*/

    assign fifo_wr_en = ~(fifo_full);// & mon_en;
    assign fifo_rd_en = ~(fifo_empty);

   /*----------------- Registering Data input based on Parameter------*/
    
    
     always @(posedge Mon_clk) begin
       if (Mon_rst_n == RST_ACTIVE) begin
         Reg_Data_In <= 0 ;
       end
       else begin
         Reg_Data_In <= Data_In;
       end
     end
 
     assign Fifo_Data_In = C_REG_ALL_MONITOR_SIGNALS?Reg_Data_In:Data_In;

   /*----------------- Submodule instantiations------------------------*/

   // async fifo module

  generate
  if(C_FIFO_ENABLE == 1) begin:USE_MON_FIFO

    reg  [C_MON_FIFO_DATA_WIDTH-1:0] Fifo_Data_Out_Reg;
    reg                              fifo_rd_en_reg;

    axi_perf_mon_v5_0_9_async_fifo
    # (
          .C_FAMILY             (C_FAMILY             ),
          .C_FIFO_DEPTH         (32                   ),
          .C_DATA_CNT_WIDTH     (5                    ),
          .C_DATA_WIDTH         (C_MON_FIFO_DATA_WIDTH),
          .C_FULL_FLAGS_RST     (1                    ),//On reset fifo_full value
          .C_USE_BLOCKMEM       (2                    ),//Distributed RAM
          .C_COMMON_CLOCK       (0                    ),//Different clocks then this fifo is required  
          .C_IMPLEMENTATION_TYPE(2                    ),//Different clock BRAM/Distributed 
          .C_USE_FWFT           (1                    )
  
      ) async_fifo_inst
      (
          .Din               (Fifo_Data_In            ),
          .Wr_en             (fifo_wr_en              ),
          .Wr_clk            (Mon_clk                 ),
          .Rd_en             (fifo_rd_en              ),
          .Rd_clk            (CORE_ACLK               ),
          .fifo_rst          (fifo_rst                ), //active high
          .Dout              (Fifo_Data_Out           ),
          .Full              (fifo_full               ),
          .wr_rst_busy       (                        ),
          .Empty             (fifo_empty              ),
          .rd_data_count     (),
          .wr_data_count     (),
          .almost_empty      (                        ), 
          .almost_full       (                        ) 
      );

      // Registering Fifo data out and valid signals
      always @(posedge CORE_ACLK) begin
       if (CORE_ARESETN == RST_ACTIVE) begin
         Fifo_Data_Out_Reg <= 0 ;
         fifo_rd_en_reg    <= 0; 
       end
       else begin
         Fifo_Data_Out_Reg <= Fifo_Data_Out;
         fifo_rd_en_reg    <= fifo_rd_en; 
       end
     end

     assign Sync_Data_Out   = Fifo_Data_Out_Reg;
     assign Sync_Data_Valid = fifo_rd_en_reg;


  end 
  else begin : NO_MON_FIFO            // Default value assignment
     assign fifo_empty      = 1'b0;
     assign fifo_full       = 1'b0;
     assign Sync_Data_Out   = Fifo_Data_In;
     assign Sync_Data_Valid = 1'b1;

  end

  endgenerate 

  
endmodule
