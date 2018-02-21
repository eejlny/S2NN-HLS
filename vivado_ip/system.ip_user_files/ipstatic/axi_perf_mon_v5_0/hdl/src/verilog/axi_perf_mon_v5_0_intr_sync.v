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
// Filename   :  axi_perf_mon_v5_0_9_intr_sync.v
// Version    :  v5.0
// Description:  Interrupt synchronization module. Interrupt generated
//               at core clock are synchronized with AXI4-Lite clock
//               pulse synchronization method is used for interrupt
//               synchronization
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
// axi_perf_mon.v
//    \-- axi_perf_mon_v5_0_9_intr_sync.v
//-----------------------------------------------------------------------------
// Author:      Kalpanath
// History:
// Kalpanath 07/25/2012      First Version
// ^^^^^^
//----------------------------------------------------------------------------- 
`timescale 1ns/1ps

module axi_perf_mon_v5_0_9_intr_sync 
#(
   parameter                          C_FAMILY    = "nofamily",
   parameter                          C_DWIDTH    = 32
)
(
   input                                  clk_1,
   input                                  rst_1_n,
   input  [(C_DWIDTH - 1):0]              DATA_IN, 
   input                                  clk_2,
   input                                  rst_2_n,
   output [(C_DWIDTH - 1):0]              SYNC_DATA_OUT 
);

//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;


//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------

genvar i;
generate
for (i=0; i<C_DWIDTH; i=i+1) begin : GEN_SYNC
    axi_perf_mon_v5_0_9_cdc_sync
    #(
       .c_cdc_type      (0    ),   
       .c_flop_input    (0    ),  
       .c_reset_state   (1    ),  
       .c_single_bit    (1    ),  
       .c_vector_width  (1    ),  
       .c_mtbf_stages   (4    )  
     )cdc_sync_inst 
     (
       .prmry_aclk      (clk_1             ),
       .prmry_rst_n     (rst_1_n           ),
       .prmry_in        (DATA_IN[i]        ),
       .prmry_vect_in   (1'b0              ),
       .scndry_aclk     (clk_2             ),
       .scndry_rst_n    (rst_2_n           ),
       .prmry_ack       (                  ),
       .scndry_out      (SYNC_DATA_OUT[i]  ),
       .scndry_vect_out (                  ) 
      );
end
endgenerate    

endmodule




