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
// Filename     : axi_perf_mon_v5_0_9_metric_counters_profile.v
// Version      : v5.0
// Description  : Metric counter module instantiates the accumulators
//                and calculates the metric counts
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
//  axi_perf_mon.v
//      \--
//      \-- axi_perf_mon_v5_0_9_metric_counters_profile.v
//
//-----------------------------------------------------------------------------
// Author:    NLR 
// History: 
// NLR 02/10/2013      First Version  
// ~~~~~~
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module axi_perf_mon_v5_0_9_metric_counters_profile 
#(
   parameter                       C_FAMILY                   = "virtex7",
   parameter                       C_NUM_MONITOR_SLOTS        = 8,
   parameter                       C_NUM_OF_COUNTERS          = 10,
   parameter                       C_NUM_OF_COUNTERS_EXTND    = 2,
   parameter                       C_METRIC_COUNT_WIDTH       = 32,
   parameter                       C_HAVE_SAMPLED_METRIC_CNT  = 1
)
(
   input                            clk,
   input                            rst_n,
   input                            Sample_rst_n,

   input                            Sample_En,
   input [9:0]                      Lat_Addr_11downto2,
    //-- AXI4 metrics
   input [C_NUM_MONITOR_SLOTS-1:0]  Wtrans_Cnt_En,
   input [C_NUM_MONITOR_SLOTS-1:0]  Rtrans_Cnt_En,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Write_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Read_Byte_Cnt,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Read_Byte_Cnt,
   input [C_NUM_MONITOR_SLOTS-1:0]  Write_Beat_Cnt_En,
   input [C_NUM_MONITOR_SLOTS-1:0]  Read_Beat_Cnt_En,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Min_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Min_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Min_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Min_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Min_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Min_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Min_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Min_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Max_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Max_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Max_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Max_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Max_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Max_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Max_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Max_Read_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Min_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Min_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Min_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Min_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Min_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Min_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Min_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Min_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S0_Max_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S1_Max_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S2_Max_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S3_Max_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S4_Max_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S5_Max_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S6_Max_Write_Latency,
   input [C_METRIC_COUNT_WIDTH-1:0] S7_Max_Write_Latency,
   input [C_NUM_MONITOR_SLOTS-1:0]  Read_Latency_En,        
   input [C_NUM_MONITOR_SLOTS-1:0]  Write_Latency_En,        

   //-- Cnt Enable and Reset
   input                            Metrics_Cnt_En,
   input                            Metrics_Cnt_Reset,

   // Metric Counters - in core clk domain
   output reg [31:0]                Metric_Ram_Data_In    
);


//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;

//-------------------------------------------------------------------
// Signal Declarations
//------------------------------------------------------------------
 wire [C_METRIC_COUNT_WIDTH-1:0] accum_in [C_NUM_OF_COUNTERS-1:0];
 wire [C_NUM_OF_COUNTERS-1:0]    accum_in_valid;
 wire [C_METRIC_COUNT_WIDTH-1:0] Metric_Cnt [47:0];
 wire [C_METRIC_COUNT_WIDTH-1:0] Sample_Metric_Cnt [47:0];

 wire [C_METRIC_COUNT_WIDTH-1:0]    accum_in_extnd [C_NUM_OF_COUNTERS_EXTND-1:0];
 wire [C_NUM_OF_COUNTERS_EXTND-1:0]   accum_in_valid_extnd;
 wire [C_METRIC_COUNT_WIDTH-1:0] Metric_Cnt_extnd [15:0];
 wire [C_METRIC_COUNT_WIDTH-1:0] Sample_Metric_Cnt_extnd [15:0];

//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------
reg [C_NUM_MONITOR_SLOTS-1:0]  MinMax_Write_Latency_En;
reg [C_NUM_MONITOR_SLOTS-1:0]  MinMax_Read_Latency_En;
   always @(posedge clk) begin
      if (rst_n == RST_ACTIVE) begin
          MinMax_Write_Latency_En <= 0;
          MinMax_Read_Latency_En  <= 0;
      end else begin
          MinMax_Write_Latency_En <= Write_Latency_En;
          MinMax_Read_Latency_En  <= Read_Latency_En;
      end
   end

   assign accum_in[0] = S0_Write_Byte_Cnt;
   assign accum_in[1] = 1'b1;
   assign accum_in[2] = S0_Write_Latency;
   assign accum_in[3] = S0_Read_Byte_Cnt;
   assign accum_in[4] = 1'b1;
   assign accum_in[5] = S0_Read_Latency;
   assign accum_in_valid[0] = Write_Beat_Cnt_En[0];
   assign accum_in_valid[1] = Wtrans_Cnt_En[0];
   assign accum_in_valid[2] = Write_Latency_En[0];
   assign accum_in_valid[3] = Read_Beat_Cnt_En[0];
   assign accum_in_valid[4] = Rtrans_Cnt_En[0];
   assign accum_in_valid[5] = Read_Latency_En[0];

assign accum_in_extnd[0]  = {S0_Max_Write_Latency[15:0], S0_Min_Write_Latency[15:0] };    
assign accum_in_extnd[1]  = {S0_Max_Read_Latency[15:0] , S0_Min_Read_Latency[15:0]  };  
assign accum_in_valid_extnd[0] = MinMax_Write_Latency_En[0];
assign accum_in_valid_extnd[1] = MinMax_Read_Latency_En[0];

generate if(C_NUM_OF_COUNTERS > 6) begin
   assign accum_in[6] = S1_Write_Byte_Cnt;
   assign accum_in[7] = 1'b1;
   assign accum_in[8] = S1_Write_Latency;
   assign accum_in[9] = S1_Read_Byte_Cnt;
   assign accum_in[10] = 1'b1;
   assign accum_in[11] = S1_Read_Latency;

   assign accum_in_valid[6] = Write_Beat_Cnt_En[1];
   assign accum_in_valid[7] = Wtrans_Cnt_En[1];
   assign accum_in_valid[8] = Write_Latency_En[1];
   assign accum_in_valid[9] = Read_Beat_Cnt_En[1];
   assign accum_in_valid[10] = Rtrans_Cnt_En[1];
   assign accum_in_valid[11] = Read_Latency_En[1];

assign accum_in_extnd[2]  = {S1_Max_Write_Latency[15:0], S1_Min_Write_Latency[15:0] };    
assign accum_in_extnd[3]  = {S1_Max_Read_Latency[15:0] , S1_Min_Read_Latency[15:0]  };  
assign accum_in_valid_extnd[2] = MinMax_Write_Latency_En[1];
assign accum_in_valid_extnd[3] = MinMax_Read_Latency_En[1];
end
endgenerate

generate if(C_NUM_OF_COUNTERS > 12) begin
   assign accum_in[12] = S2_Write_Byte_Cnt;
   assign accum_in[13] = 1'b1;
   assign accum_in[14] = S2_Write_Latency;
   assign accum_in[15] = S2_Read_Byte_Cnt;
   assign accum_in[16] = 1'b1;
   assign accum_in[17] = S2_Read_Latency;

   assign accum_in_valid[12] = Write_Beat_Cnt_En[2];
   assign accum_in_valid[13] = Wtrans_Cnt_En[2];
   assign accum_in_valid[14] = Write_Latency_En[2];
   assign accum_in_valid[15] = Read_Beat_Cnt_En[2];
   assign accum_in_valid[16] = Rtrans_Cnt_En[2];
   assign accum_in_valid[17] = Read_Latency_En[2];

assign accum_in_extnd[4]  = {S2_Max_Write_Latency[15:0], S2_Min_Write_Latency[15:0] };    
assign accum_in_extnd[5]  = {S2_Max_Read_Latency[15:0] , S2_Min_Read_Latency[15:0]  };  
assign accum_in_valid_extnd[4] = MinMax_Write_Latency_En[2];
assign accum_in_valid_extnd[5] = MinMax_Read_Latency_En[2];
end
endgenerate

generate if(C_NUM_OF_COUNTERS > 18) begin
  assign accum_in[18] = S3_Write_Byte_Cnt;
  assign accum_in[19] = 1'b1;
  assign accum_in[20] = S3_Write_Latency;
  assign accum_in[21] = S3_Read_Byte_Cnt;
  assign accum_in[22] = 1'b1;
  assign accum_in[23] = S3_Read_Latency;

  assign accum_in_valid[18] = Write_Beat_Cnt_En[3];
  assign accum_in_valid[19] = Wtrans_Cnt_En[3];
  assign accum_in_valid[20] = Write_Latency_En[3];
  assign accum_in_valid[21] = Read_Beat_Cnt_En[3];
  assign accum_in_valid[22] = Rtrans_Cnt_En[3];
  assign accum_in_valid[23] = Read_Latency_En[3];

assign accum_in_extnd[6]  = {S3_Max_Write_Latency[15:0], S3_Min_Write_Latency[15:0] };    
assign accum_in_extnd[7]  = {S3_Max_Read_Latency[15:0] , S3_Min_Read_Latency[15:0]  };  
assign accum_in_valid_extnd[6] = MinMax_Write_Latency_En[3];
assign accum_in_valid_extnd[7] = MinMax_Read_Latency_En[3];
end
endgenerate

generate if(C_NUM_OF_COUNTERS > 24) begin
  assign accum_in[24] = S4_Write_Byte_Cnt;
  assign accum_in[25] = 1'b1;
  assign accum_in[26] = S4_Write_Latency;
  assign accum_in[27] = S4_Read_Byte_Cnt;
  assign accum_in[28] = 1'b1;
  assign accum_in[29] = S4_Read_Latency;

  assign accum_in_valid[24] = Write_Beat_Cnt_En[4];
  assign accum_in_valid[25] = Wtrans_Cnt_En[4];
  assign accum_in_valid[26] = Write_Latency_En[4];
  assign accum_in_valid[27] = Read_Beat_Cnt_En[4];
  assign accum_in_valid[28] = Rtrans_Cnt_En[4];
  assign accum_in_valid[29] = Read_Latency_En[4];

assign accum_in_extnd[8]  = {S4_Max_Write_Latency[15:0], S4_Min_Write_Latency[15:0] };    
assign accum_in_extnd[9]  = {S4_Max_Read_Latency[15:0] , S4_Min_Read_Latency[15:0]  };  
assign accum_in_valid_extnd[8] = MinMax_Write_Latency_En[4];
assign accum_in_valid_extnd[9] = MinMax_Read_Latency_En[4];

end
endgenerate

generate if(C_NUM_OF_COUNTERS > 30) begin
  assign accum_in[30] = S5_Write_Byte_Cnt;
  assign accum_in[31] = 1'b1;
  assign accum_in[32] = S5_Write_Latency;
  assign accum_in[33] = S5_Read_Byte_Cnt;
  assign accum_in[34] = 1'b1;
  assign accum_in[35] = S5_Read_Latency;

  assign accum_in_valid[30] = Write_Beat_Cnt_En[5];
  assign accum_in_valid[31] = Wtrans_Cnt_En[5];
  assign accum_in_valid[32] = Write_Latency_En[5];
  assign accum_in_valid[33] = Read_Beat_Cnt_En[5];
  assign accum_in_valid[34] = Rtrans_Cnt_En[5];
  assign accum_in_valid[35] = Read_Latency_En[5];

assign accum_in_extnd[10] = {S5_Max_Write_Latency[15:0], S5_Min_Write_Latency[15:0] };    
assign accum_in_extnd[11] = {S5_Max_Read_Latency[15:0] , S5_Min_Read_Latency[15:0]  };  
assign accum_in_valid_extnd[10] = MinMax_Write_Latency_En[5];
assign accum_in_valid_extnd[11] = MinMax_Read_Latency_En[5];
end
endgenerate

generate if(C_NUM_OF_COUNTERS > 36) begin
  assign accum_in[36] = S6_Write_Byte_Cnt;
  assign accum_in[37] = 1'b1;
  assign accum_in[38] = S6_Write_Latency;
  assign accum_in[39] = S6_Read_Byte_Cnt;
  assign accum_in[40] = 1'b1;
  assign accum_in[41] = S6_Read_Latency;

  assign accum_in_valid[36] = Write_Beat_Cnt_En[6];
  assign accum_in_valid[37] = Wtrans_Cnt_En[6];
  assign accum_in_valid[38] = Write_Latency_En[6];
  assign accum_in_valid[39] = Read_Beat_Cnt_En[6];
  assign accum_in_valid[40] = Rtrans_Cnt_En[6];
  assign accum_in_valid[41] = Read_Latency_En[6];

assign accum_in_extnd[12] = {S6_Max_Write_Latency[15:0], S6_Min_Write_Latency[15:0] };    
assign accum_in_extnd[13] = {S6_Max_Read_Latency[15:0] , S6_Min_Read_Latency[15:0]  };  
assign accum_in_valid_extnd[12] = MinMax_Write_Latency_En[6];
assign accum_in_valid_extnd[13] = MinMax_Read_Latency_En[6];
end
endgenerate

generate if(C_NUM_OF_COUNTERS > 42) begin
  assign accum_in[42] = S7_Write_Byte_Cnt;
  assign accum_in[43] = 1'b1;
  assign accum_in[44] = S7_Write_Latency;
  assign accum_in[45] = S7_Read_Byte_Cnt;
  assign accum_in[46] = 1'b1;
  assign accum_in[47] = S7_Read_Latency;

  assign accum_in_valid[42] = Write_Beat_Cnt_En[7];
  assign accum_in_valid[43] = Wtrans_Cnt_En[7];
  assign accum_in_valid[44] = Write_Latency_En[7];
  assign accum_in_valid[45] = Read_Beat_Cnt_En[7];
  assign accum_in_valid[46] = Rtrans_Cnt_En[7];
  assign accum_in_valid[47] = Read_Latency_En[7];

assign accum_in_extnd[14] = {S7_Max_Write_Latency[15:0], S7_Min_Write_Latency[15:0] };    
assign accum_in_extnd[15] = {S7_Max_Read_Latency[15:0] , S7_Min_Read_Latency[15:0]  };
assign accum_in_valid_extnd[14] = MinMax_Write_Latency_En[7];
assign accum_in_valid_extnd[15] = MinMax_Read_Latency_En[7];

end
endgenerate

//-- Metric Counter
genvar i;
generate
for (i=0; i<C_NUM_OF_COUNTERS; i=i+1) begin : GEN_acc

   axi_perf_mon_v5_0_9_acc_sample_profile 
   #(
     .C_FAMILY                      (C_FAMILY            ),
     .DWIDTH                        (C_METRIC_COUNT_WIDTH),
     .C_HAVE_SAMPLED_METRIC_CNT     (C_HAVE_SAMPLED_METRIC_CNT)
   ) acc_inst_0
   (
      .clk                (clk                        ),
      .rst_n              (rst_n                      ),
      .Sample_rst_n       (Sample_rst_n               ),
      .Enable             (Metrics_Cnt_En             ),   
      .Reset              (Metrics_Cnt_Reset          ) ,   
      .Add_in             (accum_in[i]                ),  
      .Add_in_Valid       (accum_in_valid[i]          ), 
      .Sample_En          (Sample_En                  ), 
      .Accumulate         (1'b1                       ), 
      .Accumulator        (Metric_Cnt[i]              ),
      .Sample_Accumulator (Sample_Metric_Cnt[i]       )
   );
end
endgenerate  

genvar j;
generate for (j=C_NUM_OF_COUNTERS; j<48; j = j+1) begin :GEN_No_acc
  assign Metric_Cnt[j] = 0;
  assign Sample_Metric_Cnt[j] = 0;
end
endgenerate

//-- Metric Counter-extnd
genvar k;
generate
for (k=0; k<C_NUM_OF_COUNTERS_EXTND; k=k+1) begin : GEN_acc_extnd

   axi_perf_mon_v5_0_9_acc_sample_profile 
   #(
     .C_FAMILY                      (C_FAMILY            ),
     .DWIDTH                        (C_METRIC_COUNT_WIDTH),
     .C_HAVE_SAMPLED_METRIC_CNT     (C_HAVE_SAMPLED_METRIC_CNT)
   ) acc_extnd_inst_0
   (
      .clk                (clk                        ),
      .rst_n              (rst_n                      ),
      .Sample_rst_n       (Sample_rst_n               ),
      .Enable             (Metrics_Cnt_En             ),   
      .Reset              (Metrics_Cnt_Reset          ),   
      .Add_in             (accum_in_extnd[k]          ),  
      .Add_in_Valid       (accum_in_valid_extnd[k]    ), 
      .Sample_En          (Sample_En                  ), 
      .Accumulate         (1'b0                       ), 
      .Accumulator        (Metric_Cnt_extnd[k]        ),
      .Sample_Accumulator (Sample_Metric_Cnt_extnd[k] )
   );
end
endgenerate  

genvar l;
generate for (l=C_NUM_OF_COUNTERS_EXTND; l<16; l = l+1) begin :GEN_No_acc_extnd
  assign Metric_Cnt_extnd[l] = 0;
  assign Sample_Metric_Cnt_extnd[l] = 0;
end
endgenerate
wire [11:0] Lat_Addr_11downto0;
assign Lat_Addr_11downto0 = {Lat_Addr_11downto2,2'b00};
always @(*) begin 
      case (Lat_Addr_11downto0)
        12'h100: Metric_Ram_Data_In<= Metric_Cnt[0];   
        12'h110: Metric_Ram_Data_In<= Metric_Cnt[1]; 
        12'h120: Metric_Ram_Data_In<= Metric_Cnt[2]; 
        12'h130: Metric_Ram_Data_In<= Metric_Cnt[3]; 
        12'h140: Metric_Ram_Data_In<= Metric_Cnt[4]; 
        12'h150: Metric_Ram_Data_In<= Metric_Cnt[5]; 
        12'h160: Metric_Ram_Data_In<= Metric_Cnt[6]; 
        12'h170: Metric_Ram_Data_In<= Metric_Cnt[7]; 
        12'h180: Metric_Ram_Data_In<= Metric_Cnt[8]; 
        12'h190: Metric_Ram_Data_In<= Metric_Cnt[9]; 
        12'h1A0: Metric_Ram_Data_In<= Metric_Cnt[10];
        12'h1B0: Metric_Ram_Data_In<= Metric_Cnt[11];
        12'h200: Metric_Ram_Data_In<= Sample_Metric_Cnt[0];   
        12'h210: Metric_Ram_Data_In<= Sample_Metric_Cnt[1]; 
        12'h220: Metric_Ram_Data_In<= Sample_Metric_Cnt[2]; 
        12'h230: Metric_Ram_Data_In<= Sample_Metric_Cnt[3]; 
        12'h240: Metric_Ram_Data_In<= Sample_Metric_Cnt[4]; 
        12'h250: Metric_Ram_Data_In<= Sample_Metric_Cnt[5]; 
        12'h260: Metric_Ram_Data_In<= Sample_Metric_Cnt[6]; 
        12'h270: Metric_Ram_Data_In<= Sample_Metric_Cnt[7]; 
        12'h280: Metric_Ram_Data_In<= Sample_Metric_Cnt[8]; 
        12'h290: Metric_Ram_Data_In<= Sample_Metric_Cnt[9]; 
        12'h2A0: Metric_Ram_Data_In<= Sample_Metric_Cnt[10];
        12'h2B0: Metric_Ram_Data_In<= Sample_Metric_Cnt[11];
        12'h500: Metric_Ram_Data_In<= Metric_Cnt[12];   
        12'h510: Metric_Ram_Data_In<= Metric_Cnt[13]; 
        12'h520: Metric_Ram_Data_In<= Metric_Cnt[14]; 
        12'h530: Metric_Ram_Data_In<= Metric_Cnt[15]; 
        12'h540: Metric_Ram_Data_In<= Metric_Cnt[16]; 
        12'h550: Metric_Ram_Data_In<= Metric_Cnt[17]; 
        12'h560: Metric_Ram_Data_In<= Metric_Cnt[18]; 
        12'h570: Metric_Ram_Data_In<= Metric_Cnt[19]; 
        12'h580: Metric_Ram_Data_In<= Metric_Cnt[20]; 
        12'h590: Metric_Ram_Data_In<= Metric_Cnt[21]; 
        12'h5A0: Metric_Ram_Data_In<= Metric_Cnt[22];
        12'h5B0: Metric_Ram_Data_In<= Metric_Cnt[23];
        12'h600: Metric_Ram_Data_In<= Sample_Metric_Cnt[12];   
        12'h610: Metric_Ram_Data_In<= Sample_Metric_Cnt[13]; 
        12'h620: Metric_Ram_Data_In<= Sample_Metric_Cnt[14]; 
        12'h630: Metric_Ram_Data_In<= Sample_Metric_Cnt[15]; 
        12'h640: Metric_Ram_Data_In<= Sample_Metric_Cnt[16]; 
        12'h650: Metric_Ram_Data_In<= Sample_Metric_Cnt[17]; 
        12'h660: Metric_Ram_Data_In<= Sample_Metric_Cnt[18]; 
        12'h670: Metric_Ram_Data_In<= Sample_Metric_Cnt[19]; 
        12'h680: Metric_Ram_Data_In<= Sample_Metric_Cnt[20]; 
        12'h690: Metric_Ram_Data_In<= Sample_Metric_Cnt[21]; 
        12'h6A0: Metric_Ram_Data_In<= Sample_Metric_Cnt[22];
        12'h6B0: Metric_Ram_Data_In<= Sample_Metric_Cnt[23];
        12'h700: Metric_Ram_Data_In<= Metric_Cnt[24];   
        12'h710: Metric_Ram_Data_In<= Metric_Cnt[25]; 
        12'h720: Metric_Ram_Data_In<= Metric_Cnt[26]; 
        12'h730: Metric_Ram_Data_In<= Metric_Cnt[27]; 
        12'h740: Metric_Ram_Data_In<= Metric_Cnt[28]; 
        12'h750: Metric_Ram_Data_In<= Metric_Cnt[29]; 
        12'h760: Metric_Ram_Data_In<= Metric_Cnt[30]; 
        12'h770: Metric_Ram_Data_In<= Metric_Cnt[31]; 
        12'h780: Metric_Ram_Data_In<= Metric_Cnt[32]; 
        12'h790: Metric_Ram_Data_In<= Metric_Cnt[33]; 
        12'h7A0: Metric_Ram_Data_In<= Metric_Cnt[34];
        12'h7B0: Metric_Ram_Data_In<= Metric_Cnt[35];
        12'h800: Metric_Ram_Data_In<= Sample_Metric_Cnt[24];   
        12'h810: Metric_Ram_Data_In<= Sample_Metric_Cnt[25]; 
        12'h820: Metric_Ram_Data_In<= Sample_Metric_Cnt[26]; 
        12'h830: Metric_Ram_Data_In<= Sample_Metric_Cnt[27]; 
        12'h840: Metric_Ram_Data_In<= Sample_Metric_Cnt[28]; 
        12'h850: Metric_Ram_Data_In<= Sample_Metric_Cnt[29]; 
        12'h860: Metric_Ram_Data_In<= Sample_Metric_Cnt[30]; 
        12'h870: Metric_Ram_Data_In<= Sample_Metric_Cnt[31]; 
        12'h880: Metric_Ram_Data_In<= Sample_Metric_Cnt[32]; 
        12'h890: Metric_Ram_Data_In<= Sample_Metric_Cnt[33]; 
        12'h8A0: Metric_Ram_Data_In<= Sample_Metric_Cnt[34];
        12'h8B0: Metric_Ram_Data_In<= Sample_Metric_Cnt[35];
        12'h900: Metric_Ram_Data_In<= Metric_Cnt[36];   
        12'h910: Metric_Ram_Data_In<= Metric_Cnt[37]; 
        12'h920: Metric_Ram_Data_In<= Metric_Cnt[38]; 
        12'h930: Metric_Ram_Data_In<= Metric_Cnt[39]; 
        12'h940: Metric_Ram_Data_In<= Metric_Cnt[40]; 
        12'h950: Metric_Ram_Data_In<= Metric_Cnt[41]; 
        12'h960: Metric_Ram_Data_In<= Metric_Cnt[42]; 
        12'h970: Metric_Ram_Data_In<= Metric_Cnt[43]; 
        12'h980: Metric_Ram_Data_In<= Metric_Cnt[44]; 
        12'h990: Metric_Ram_Data_In<= Metric_Cnt[45]; 
        12'h9A0: Metric_Ram_Data_In<= Metric_Cnt[46];
        12'h9B0: Metric_Ram_Data_In<= Metric_Cnt[47];
        12'hA00: Metric_Ram_Data_In<= Sample_Metric_Cnt[36];   
        12'hA10: Metric_Ram_Data_In<= Sample_Metric_Cnt[37]; 
        12'hA20: Metric_Ram_Data_In<= Sample_Metric_Cnt[38]; 
        12'hA30: Metric_Ram_Data_In<= Sample_Metric_Cnt[39]; 
        12'hA40: Metric_Ram_Data_In<= Sample_Metric_Cnt[40]; 
        12'hA50: Metric_Ram_Data_In<= Sample_Metric_Cnt[41]; 
        12'hA60: Metric_Ram_Data_In<= Sample_Metric_Cnt[42]; 
        12'hA70: Metric_Ram_Data_In<= Sample_Metric_Cnt[43]; 
        12'hA80: Metric_Ram_Data_In<= Sample_Metric_Cnt[44]; 
        12'hA90: Metric_Ram_Data_In<= Sample_Metric_Cnt[45]; 
        12'hAA0: Metric_Ram_Data_In<= Sample_Metric_Cnt[46];
        12'hAB0: Metric_Ram_Data_In<= Sample_Metric_Cnt[47];
        //PR#780668{
        12'h154: Metric_Ram_Data_In <= Metric_Cnt_extnd[0];
        12'h158: Metric_Ram_Data_In <= Metric_Cnt_extnd[1];
        12'h1b4: Metric_Ram_Data_In <= Metric_Cnt_extnd[2];
        12'h1b8: Metric_Ram_Data_In <= Metric_Cnt_extnd[3];
        12'h554: Metric_Ram_Data_In <= Metric_Cnt_extnd[4];
        12'h558: Metric_Ram_Data_In <= Metric_Cnt_extnd[5];
        12'h5b4: Metric_Ram_Data_In <= Metric_Cnt_extnd[6];
        12'h5b8: Metric_Ram_Data_In <= Metric_Cnt_extnd[7];
        12'h754: Metric_Ram_Data_In <= Metric_Cnt_extnd[8];
        12'h758: Metric_Ram_Data_In <= Metric_Cnt_extnd[9];
        12'h7b4: Metric_Ram_Data_In <= Metric_Cnt_extnd[10];
        12'h7b8: Metric_Ram_Data_In <= Metric_Cnt_extnd[11];
        12'h954: Metric_Ram_Data_In <= Metric_Cnt_extnd[12];
        12'h958: Metric_Ram_Data_In <= Metric_Cnt_extnd[13];
        12'h9b4: Metric_Ram_Data_In <= Metric_Cnt_extnd[14];
        12'h9b8: Metric_Ram_Data_In <= Metric_Cnt_extnd[15];
        12'h254: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[0];
        12'h258: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[1];
        12'h2b4: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[2];
        12'h2b8: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[3];
        12'h654: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[4];
        12'h658: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[5];
        12'h6b4: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[6];
        12'h6b8: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[7];
        12'h854: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[8];
        12'h858: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[9];
        12'h8b4: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[10];
        12'h8b8: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[11];
        12'ha54: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[12];
        12'ha58: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[13];
        12'hab4: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[14];
        12'hab8: Metric_Ram_Data_In <= Sample_Metric_Cnt_extnd[15];
        //PR#780668}
        default:Metric_Ram_Data_In <= 0; 
      endcase
end 

endmodule       
