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
// Filename     : axi_perf_mon_v5_0_9_register_module.v
// Version      : v5.0
// Description  : register module having all the registers of axi performance
//                monitor read and write logic. Address decoding is also
//                implemented in this module based on which the corresponding 
//                read and write enables being generated
// Verilog-Standard:verilog-2001  
//-----------------------------------------------------------------------------
// Structure:   
//
//  axi_perf_mon_v5_0_9_top.v
//      \-- axi_perf_mon_v5_0_9_register_module.v
//
//-----------------------------------------------------------------------------
// Author :    Kalpanath
// History: 
// Kalpanath 07/25/2012      First Version   
// ~~~~~~
// NLR       10/01/2013      Added new registers
// ~~~~~~
// NLR       24/03/2013      Added bram implementation for metric counters
//                           incrementors, sampled metric counters and
//                           sampled incrementors
// ~~~~~~~
// NLR       19/06/2013      Restructuring the code for coverage improvement     
// ~~~~~~~
// NLR       10/02/2013      Added new sample register and ID masking register
// ~~~~~~~                   Added logic for sample interval capture w.r.t 
//                           sample register read
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
(* DowngradeIPIdentifiedWarnings="yes" *)

module axi_perf_mon_v5_0_9_register_module 
#(
   parameter                              C_FAMILY                     = "virtex7",
   // AXI port dependant parameters
   parameter                              C_S_AXI_ADDR_WIDTH           = 32,
   parameter                              C_S_AXI_DATA_WIDTH           = 32,

   parameter                              C_NUM_MONITOR_SLOTS          = 8,
   parameter                              C_NUM_OF_COUNTERS            = 10,
   parameter                              C_NUM_INTR_INPUTS            = 13,
   parameter                              C_ENABLE_EVENT_COUNT         = 1,  //-- enables/disables perf mon counting logic
   parameter                              C_ENABLE_EVENT_LOG           = 0,  //-- enables/disables perf mon log logic
   parameter                              C_METRICS_SAMPLE_COUNT_WIDTH = 32,
   parameter                              C_GLOBAL_COUNT_WIDTH         = 32,
   parameter                              C_SW_SYNC_DATA_WIDTH         = 32,  //-- Width of SW data register
   parameter                              C_AXIS_DWIDTH_ROUND_TO_32    = 64, // AXI Streaming FIFO width rounded to next 32bit
   parameter                              C_AXI4LITE_CORE_CLK_ASYNC    = 1   //-- disable synchronizers incase its 0 
)
(
   input                                             S_AXI_ACLK,
   input                                             S_AXI_ARESETN,

   // Controls to the IP/IPIF modules
   input [(C_S_AXI_ADDR_WIDTH - 1):0]                Bus2IP_Addr,  
   input [(C_S_AXI_DATA_WIDTH - 1):0]                Bus2IP_Data,    
   input [((C_S_AXI_DATA_WIDTH / 8)-1):0]            Bus2IP_BE, 
   input                                             Bus2IP_Burst,   
   input                                             Bus2IP_RdCE,   
   input                                             Bus2IP_WrCE,   
   output reg [(C_S_AXI_DATA_WIDTH - 1):0]           IP2Bus_Data, 
   output reg                                        IP2Bus_DataValid,
   output                                            IP2Bus_Error,

   input                                             CORE_ACLK,
   input                                             CORE_ARESETN,

   // Global Clock Counter - in core clk domain
   input [(C_GLOBAL_COUNT_WIDTH - 1):0]              Global_Clk_Cnt,    

   // Metric Counters - in core clk domain
   input [31:0]                                      Metric_Cnt_0,    
   input [31:0]                                      Metric_Cnt_1,    
   input [31:0]                                      Metric_Cnt_2,    
   input [31:0]                                      Metric_Cnt_3,    
   input [31:0]                                      Metric_Cnt_4,    
   input [31:0]                                      Metric_Cnt_5,    
   input [31:0]                                      Metric_Cnt_6,    
   input [31:0]                                      Metric_Cnt_7,    
   input [31:0]                                      Metric_Cnt_8,    
   input [31:0]                                      Metric_Cnt_9,    

   // Incrementers in core clk domain
   input [31:0]                                      Incrementer_0,    
   input [31:0]                                      Incrementer_1,    
   input [31:0]                                      Incrementer_2,    
   input [31:0]                                      Incrementer_3,    
   input [31:0]                                      Incrementer_4,    
   input [31:0]                                      Incrementer_5,    
   input [31:0]                                      Incrementer_6,    
   input [31:0]                                      Incrementer_7,    
   input [31:0]                                      Incrementer_8,    
   input [31:0]                                      Incrementer_9,    

   // Metric Counters - in core clk domain
   input [31:0]                                      Samp_Metric_Cnt_0,    
   input [31:0]                                      Samp_Metric_Cnt_1,    
   input [31:0]                                      Samp_Metric_Cnt_2,    
   input [31:0]                                      Samp_Metric_Cnt_3,    
   input [31:0]                                      Samp_Metric_Cnt_4,    
   input [31:0]                                      Samp_Metric_Cnt_5,    
   input [31:0]                                      Samp_Metric_Cnt_6,    
   input [31:0]                                      Samp_Metric_Cnt_7,    
   input [31:0]                                      Samp_Metric_Cnt_8,    
   input [31:0]                                      Samp_Metric_Cnt_9,    

   // Metric Counters - in core clk domain
   input [31:0]                                      Samp_Incrementer_0,    
   input [31:0]                                      Samp_Incrementer_1,    
   input [31:0]                                      Samp_Incrementer_2,    
   input [31:0]                                      Samp_Incrementer_3,    
   input [31:0]                                      Samp_Incrementer_4,    
   input [31:0]                                      Samp_Incrementer_5,    
   input [31:0]                                      Samp_Incrementer_6,    
   input [31:0]                                      Samp_Incrementer_7,    
   input [31:0]                                      Samp_Incrementer_8,    
   input [31:0]                                      Samp_Incrementer_9,    

   // Sample Interval Register - in axi clk domain
   output [(C_METRICS_SAMPLE_COUNT_WIDTH - 1):0]     Sample_Interval,    

   // Sample Interval Control Register - in axi clk domain
   output reg                                        Interval_Cnt_En,
   output reg                                        Interval_Cnt_Ld,
   output reg                                        Reset_On_Sample_Int_Lapse,

   // Interrupt Register Enables - in axi clk domain
   output reg                                        Global_Intr_En,
   output                                            Intr_Reg_IER_Wr_En,
   output                                            Intr_Reg_ISR_Wr_En,

   // Interrupt Registers - in axi clk domain
   input [(C_NUM_INTR_INPUTS - 1):0]                 Intr_Reg_IER,    
   input [(C_NUM_INTR_INPUTS - 1):0]                 Intr_Reg_ISR,    

   //rd: clk,rst will be either stream/aximm 
   input                                             eventlog_rd_clk ,
   input                                             eventlog_rd_rstn,
   input [31:0]                                      eventlog_cur_cnt,

   // Metric Selector Registers - in axi clk domain
   output     [7:0]                                  Metric_Sel_0,    
   output     [7:0]                                  Metric_Sel_1,    
   output     [7:0]                                  Metric_Sel_2,    
   output     [7:0]                                  Metric_Sel_3,    
   output     [7:0]                                  Metric_Sel_4,    
   output     [7:0]                                  Metric_Sel_5,    
   output     [7:0]                                  Metric_Sel_6,    
   output     [7:0]                                  Metric_Sel_7,    
   output     [7:0]                                  Metric_Sel_8,    
   output     [7:0]                                  Metric_Sel_9,    

   // Range Registers - in axi clk domain
   output     [31:0]                                 Range_Reg_0,    
   output     [31:0]                                 Range_Reg_1,    
   output     [31:0]                                 Range_Reg_2,    
   output     [31:0]                                 Range_Reg_3,    
   output     [31:0]                                 Range_Reg_4,    
   output     [31:0]                                 Range_Reg_5,    
   output     [31:0]                                 Range_Reg_6,    
   output     [31:0]                                 Range_Reg_7,    
   output     [31:0]                                 Range_Reg_8,    
   output     [31:0]                                 Range_Reg_9,    

   // Event Log Registers - in axi clk domain
   output     [6:0]                                  Flag_Enable_Reg,    
   output                                            SW_Data_Log_En, 
   output     [2:0]                                  Ext_Event_Flag_En,   

   output  [C_SW_SYNC_DATA_WIDTH-1:0]                SW_Data,    
   output                                            SW_Data_Wr_En,    

   // Control Register - in axi clk domain
   output reg                                        Global_Clk_Cnt_En,
   output reg                                        Global_Clk_Cnt_Reset,
   output reg                                        Streaming_FIFO_Reset,
   output reg                                        Event_Log_En,
   output reg                                        Metrics_Cnt_En,
   output reg                                        Metrics_Cnt_Reset,
   output reg                                        Use_Ext_Trigger,
   output reg                                        Use_Ext_Trigger_Log,
   // Flag enable register - in axi clk domain
   output                                            Global_Clk_Cnt_Ovf_En,
   output                                            Sample_Metric_Cnt_Ovf_En,
   // Flag enable register - in core clk domain
   output reg                                        Count_Event_Log_En,
   output     [15:0]                                 Latency_WID,
   output     [15:0]                                 Latency_RID,
   output reg                                        En_Id_Based,
   output                                            Lat_Sample_Reg,
   output     [15:0]                                 WID_Mask,
   output     [15:0]                                 RID_Mask,
   output                                            Wr_Lat_Start,
   output                                            Wr_Lat_End,
   output                                            Rd_Lat_Start,
   output                                            Rd_Lat_End
);


//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;
localparam TIME_DIFF_LOAD_VALUE = 32'h0001;

//-------------------------------------------------------------------
// Metric count ram declaration
//-------------------------------------------------------------------
//(* ram_style = "block" *) reg [31:0] Metric_ram_CDCR [255:0];
 reg [31:0]                       Metric_ram_CDCR [255:0];
 reg [7:0]                        Lat_Addr_9downto2_CDC;
 wire [31:0]                      Metric_ram_Out;

// Signal and Register Declaration-PR#741428
  wire [31:0] sync_eventlog_cur_cnt;


//-------------------------------------------------------------------
// Signal and Register Declaration
//-------------------------------------------------------------------
wire                                Rd_En_sync;
wire                                RValid;
wire [31:0]                         Sample_Interval_i;    
wire [31:0]                         Global_Clk_Cnt_MSB;  
wire [31:0]                         Global_Clk_Cnt_LSB;  
wire [31:0]                         Control_Reg;  

reg  [C_S_AXI_DATA_WIDTH-1:0]       IP2Bus_Data_Int;
reg  [31:0]                         Lat_Global_Clk_Cnt_MSB_CDCR;  
reg  [31:0]                         Lat_Global_Clk_Cnt_LSB_CDCR;  
reg     [7:0]                       Metric_Sel_0_CDC;    
reg     [7:0]                       Metric_Sel_1_CDC;    
reg     [7:0]                       Metric_Sel_2_CDC;    
reg     [7:0]                       Metric_Sel_3_CDC;    
reg     [7:0]                       Metric_Sel_4_CDC;    
reg     [7:0]                       Metric_Sel_5_CDC;    
reg     [7:0]                       Metric_Sel_6_CDC;    
reg     [7:0]                       Metric_Sel_7_CDC;    
reg     [7:0]                       Metric_Sel_8_CDC;    
reg     [7:0]                       Metric_Sel_9_CDC;    

reg     [31:0]                      Range_Reg_0_CDC;    
reg     [31:0]                      Range_Reg_1_CDC;    
reg     [31:0]                      Range_Reg_2_CDC;    
reg     [31:0]                      Range_Reg_3_CDC;    
reg     [31:0]                      Range_Reg_4_CDC;    
reg     [31:0]                      Range_Reg_5_CDC;    
reg     [31:0]                      Range_Reg_6_CDC;    
reg     [31:0]                      Range_Reg_7_CDC;    
reg     [31:0]                      Range_Reg_8_CDC;    
reg     [31:0]                      Range_Reg_9_CDC;    

reg     [31:0]                      Count0_Cut_Off_CDC;
reg     [31:0]                      Count1_Cut_Off_CDC;
reg     [31:0]                      Count2_Cut_Off_CDC;
reg     [31:0]                      Count3_Cut_Off_CDC;
reg     [31:0]                      Count4_Cut_Off_CDC;
reg     [31:0]                      Count5_Cut_Off_CDC;
reg     [31:0]                      Count6_Cut_Off_CDC;
reg     [31:0]                      Count7_Cut_Off_CDC;
reg     [31:0]                      Count8_Cut_Off_CDC;
reg     [31:0]                      Count9_Cut_Off_CDC;
reg                                 Lat_Addr_7downto4_is_0x0    ; 
reg                                 Lat_Addr_7downto4_is_0x1    ; 
reg                                 Lat_Addr_7downto4_is_0x2    ; 
reg                                 Lat_Addr_7downto4_is_0x3    ; 
reg                                 Lat_Addr_7downto4_is_0x4    ; 
reg                                 Lat_Addr_7downto4_is_0x5    ; 
reg                                 Lat_Addr_7downto4_is_0x6    ; 
reg                                 Lat_Addr_7downto4_is_0x7    ; 
reg                                 Lat_Addr_7downto4_is_0x8    ; 
reg                                 Lat_Addr_7downto4_is_0x9    ; 
reg                                 Lat_Addr_3downto0_is_0x0;
reg                                 Lat_Addr_3downto0_is_0x4;
reg                                 Lat_Addr_3downto0_is_0x8;
reg                                 Lat_Addr_3downto0_is_0xC;
reg                                 Lat_Control_Set_Rd_En       ; 
reg                                 Lat_Sample_Interval_Rd_En   ; 
reg                                 Lat_Global_Clk_Cnt_Set_Rd_En; 
reg                                 Lat_Global_Clk_Cnt_LSB_Rd_En; 
reg                                 Lat_Global_Clk_Cnt_MSB_Rd_En; 
reg                                 Lat_Intr_Reg_Set_Rd_En      ; 
reg                                 Lat_Intr_Reg_GIE_Rd_En      ; 
reg                                 Lat_Intr_Reg_IER_Rd_En      ; 
reg                                 Lat_Intr_Reg_ISR_Rd_En      ; 
reg                                 Lat_Sel_Reg_Set_Rd_En       ; 
reg                                 Lat_Metric_Sel_Reg_0_Rd_En  ; 
reg                                 Lat_Metric_Sel_Reg_1_Rd_En  ; 
reg                                 Lat_Metric_Sel_Reg_2_Rd_En  ; 
reg                                 Lat_Status_Reg_Set_Rd_En  ; 
reg                                 Lat_Status_Reg_FOC_Rd_En  ; 
reg                                 Lat_Status_Reg_WIF_Rd_En  ; 
reg                                 Lat_Rng_Reg_Set_Rd_En       ; 
reg                                 Lat_Metric_Cnt_Reg_Set_Rd_En; 
reg                                 Lat_Incr_Reg_Set_Rd_En      ; 
reg                                 Lat_Samp_Metric_Cnt_Reg_Set_Rd_En; 
reg                                 Lat_Samp_Incr_Reg_Set_Rd_En      ; 
reg                                 Lat_Event_Log_Set_Rd_En     ; 
reg                                 Lat_Latency_ID_Rd_En;
reg                                 Lat_ID_Mask_Rd_En;

reg                                 Count0_Event_Log_En_i;
reg                                 Count1_Event_Log_En_i;
reg                                 Count2_Event_Log_En_i;
reg                                 Count3_Event_Log_En_i;
reg                                 Count4_Event_Log_En_i;
reg                                 Count5_Event_Log_En_i;
reg                                 Count6_Event_Log_En_i;
reg                                 Count7_Event_Log_En_i;
reg                                 Count8_Event_Log_En_i;
reg                                 Count9_Event_Log_En_i;

reg                                 Lat_Enlog_Reg_Set_Rd_En;
reg                                 Lat_Sample_Reg_Rd_En;
reg                                 Lat_Sample_Reg_Rd_En_d3;
reg                                 Lat_Sample_Reg_Rd_En_d1;
wire                                Lat_Sample_Reg_Rd_En_d2;
wire  [9:0]                         Metric_Cnt_Ovf_En;  


wire [31:0]                         Count0_Cut_Off;
wire [31:0]                         Count1_Cut_Off;
wire [31:0]                         Count2_Cut_Off;
wire [31:0]                         Count3_Cut_Off;
wire [31:0]                         Count4_Cut_Off;
wire [31:0]                         Count5_Cut_Off;
wire [31:0]                         Count6_Cut_Off;
wire [31:0]                         Count7_Cut_Off;
wire [31:0]                         Count8_Cut_Off;
wire [31:0]                         Count9_Cut_Off;

wire                                Count0_Event_Log_En;
wire                                Count1_Event_Log_En;
wire                                Count2_Event_Log_En;
wire                                Count3_Event_Log_En;
wire                                Count4_Event_Log_En;
wire                                Count5_Event_Log_En;
wire                                Count6_Event_Log_En;
wire                                Count7_Event_Log_En;
wire                                Count8_Event_Log_En;
wire                                Count9_Event_Log_En;

wire [9:0]                          Sync_Metric_Cnt_Ovf_En;
wire [31:0]                         Lat_Global_Clk_Cnt_MSB;  

wire                               SW_Data_Wr_En_int;
reg [31:0]                         Sample_Interval_i_reg_CDC;
// ID filtering and masking bits
reg [15:0]                         Latency_WID_CDC;
reg [15:0]                         Latency_RID_CDC;
reg [15:0]                         WID_Mask_CDC;
reg [15:0]                         RID_Mask_CDC;
// latency start and end points
reg                                Wr_Lat_Start_CDC;
reg                                Wr_Lat_End_CDC;
reg                                Rd_Lat_Start_CDC;
reg                                Rd_Lat_End_CDC;
//Sample register read interval counter enable 
reg  [31:0]                        Sample_Time_Diff_Reg;  
reg                                Sample_Reg_Rd_First;  
wire [31:0]                        Sample_Time_Diff;  
wire [(C_NUM_INTR_INPUTS - 1):0]   Intr_Reg_IER_Int;    
//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------
assign IP2Bus_Error = 0;      // No error conditions hence tieng off the error signal to 0 
wire Addr_15downto8_is_0x00 = (Bus2IP_Addr[15:8] == 8'h00) ? 1'b1 : 1'b0;
wire Addr_15downto8_is_0x01 = (Bus2IP_Addr[15:8] == 8'h01) ? 1'b1 : 1'b0;
wire Addr_15downto8_is_0x02 = (Bus2IP_Addr[15:8] == 8'h02) ? 1'b1 : 1'b0;
wire Addr_15downto8_is_0x03 = (Bus2IP_Addr[15:8] == 8'h03) ? 1'b1 : 1'b0;
wire Addr_15downto8_is_0x04 = (Bus2IP_Addr[15:8] == 8'h04) ? 1'b1 : 1'b0;

wire Addr_7downto0_is_0x00  = (Bus2IP_Addr[7:0] == 8'h00) ? 1'b1 : 1'b0;
wire Addr_7downto0_is_0x04  = (Bus2IP_Addr[7:0] == 8'h04) ? 1'b1 : 1'b0;
wire Addr_7downto0_is_0x08  = (Bus2IP_Addr[7:0] == 8'h08) ? 1'b1 : 1'b0;

wire Addr_7downto4_is_0x0   = (Bus2IP_Addr[7:4] == 4'h0) ? 1'b1 : 1'b0;
wire Addr_7downto4_is_0x1   = (Bus2IP_Addr[7:4] == 4'h1) ? 1'b1 : 1'b0;
wire Addr_7downto4_is_0x2   = (Bus2IP_Addr[7:4] == 4'h2) ? 1'b1 : 1'b0;
wire Addr_7downto4_is_0x3   = (Bus2IP_Addr[7:4] == 4'h3) ? 1'b1 : 1'b0;
wire Addr_7downto4_is_0x4   = (Bus2IP_Addr[7:4] == 4'h4) ? 1'b1 : 1'b0;
wire Addr_7downto4_is_0x5   = (Bus2IP_Addr[7:4] == 4'h5) ? 1'b1 : 1'b0;
wire Addr_7downto4_is_0x6   = (Bus2IP_Addr[7:4] == 4'h6) ? 1'b1 : 1'b0;
wire Addr_7downto4_is_0x7   = (Bus2IP_Addr[7:4] == 4'h7) ? 1'b1 : 1'b0;
wire Addr_7downto4_is_0x8   = (Bus2IP_Addr[7:4] == 4'h8) ? 1'b1 : 1'b0;
wire Addr_7downto4_is_0x9   = (Bus2IP_Addr[7:4] == 4'h9) ? 1'b1 : 1'b0;

wire Addr_3downto0_is_0x0   = (Bus2IP_Addr[3:0] == 4'h0) ? 1'b1 : 1'b0;
wire Addr_3downto0_is_0x4   = (Bus2IP_Addr[3:0] == 4'h4) ? 1'b1 : 1'b0;
wire Addr_3downto0_is_0x8   = (Bus2IP_Addr[3:0] == 4'h8) ? 1'b1 : 1'b0;
wire Addr_3downto0_is_0xC   = (Bus2IP_Addr[3:0] == 4'hC) ? 1'b1 : 1'b0;
//-------------------------------------------------------------------------------
//-- Write enables and read enables generation
//-------------------------------------------------------------------------------

//-- Write enable for Control Register
wire Control_Set_Wr_En = Bus2IP_WrCE && Addr_15downto8_is_0x03 && Addr_7downto0_is_0x00;

//-- Read enable for Control Register
wire Control_Set_Rd_En = Bus2IP_RdCE && Addr_15downto8_is_0x03 && Addr_7downto0_is_0x00;

//-- Write enable for Latency ID register
wire Latency_ID_Wr_En = Bus2IP_WrCE && Addr_15downto8_is_0x03 && Addr_7downto0_is_0x04;
wire ID_Mask_Wr_En = Bus2IP_WrCE && Addr_15downto8_is_0x03 && Addr_7downto0_is_0x08;

//-- Read enable for Latency ID Register
wire Latency_ID_Rd_En = Bus2IP_RdCE && Addr_15downto8_is_0x03 && Addr_7downto0_is_0x04;
wire ID_Mask_Rd_En = Bus2IP_RdCE && Addr_15downto8_is_0x03 && Addr_7downto0_is_0x08;

//-- Write enable for Sample Interval Registers
wire Sample_Interval_Wr_En = Bus2IP_WrCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x2;

//-- Read enable for Sample Interval Registers
wire Sample_Interval_Rd_En = Bus2IP_RdCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x2;
wire Sample_Reg_Rd_En = Bus2IP_RdCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x2 && Addr_3downto0_is_0xC;

//-- Read enables for Global Clock Count Registers
wire Global_Clk_Cnt_Set_Rd_En = Bus2IP_RdCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x0;
wire Global_Clk_Cnt_MSB_Rd_En = Global_Clk_Cnt_Set_Rd_En && Addr_3downto0_is_0x0;
wire Global_Clk_Cnt_LSB_Rd_En = Global_Clk_Cnt_Set_Rd_En && Addr_3downto0_is_0x4;

//-- Write enables for Interrupt Registers
wire Intr_Reg_Set_Wr_En = Bus2IP_WrCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x3;
wire Intr_Reg_GIE_Wr_En = Intr_Reg_Set_Wr_En && Addr_3downto0_is_0x0;
assign Intr_Reg_IER_Wr_En = Intr_Reg_Set_Wr_En && Addr_3downto0_is_0x4;
assign Intr_Reg_ISR_Wr_En = Intr_Reg_Set_Wr_En && Addr_3downto0_is_0x8;

//-- Read enables for Interrupt Registers
wire Intr_Reg_Set_Rd_En = Bus2IP_RdCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x3;
wire Intr_Reg_GIE_Rd_En = Intr_Reg_Set_Rd_En && Addr_3downto0_is_0x0;
wire Intr_Reg_IER_Rd_En = Intr_Reg_Set_Rd_En && Addr_3downto0_is_0x4;
wire Intr_Reg_ISR_Rd_En = Intr_Reg_Set_Rd_En && Addr_3downto0_is_0x8;

//-- Write enables for Selector Registers
wire Sel_Reg_Set_Wr_En      = Bus2IP_WrCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x4;
wire Metric_Sel_Reg_0_Wr_En = Sel_Reg_Set_Wr_En && Addr_3downto0_is_0x4;
wire Metric_Sel_Reg_1_Wr_En = Sel_Reg_Set_Wr_En && Addr_3downto0_is_0x8;
wire Metric_Sel_Reg_2_Wr_En = Sel_Reg_Set_Wr_En && Addr_3downto0_is_0xC;

//-- Read enables for Selector Registers
wire Sel_Reg_Set_Rd_En      = Bus2IP_RdCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x4;
wire Metric_Sel_Reg_0_Rd_En = Sel_Reg_Set_Rd_En && Addr_3downto0_is_0x4;
wire Metric_Sel_Reg_1_Rd_En = Sel_Reg_Set_Rd_En && Addr_3downto0_is_0x8;
wire Metric_Sel_Reg_2_Rd_En = Sel_Reg_Set_Rd_En && Addr_3downto0_is_0xC;

//-- Write enables for status Registers
//  -- 0x0:FOC: Fifo Occupancy 
//  -- 0x4:WIF: Words in FIFO.
wire Status_Reg_Set_Wr_En = Bus2IP_WrCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x5;
wire Status_Reg_FOC_Wr_En = Status_Reg_Set_Wr_En && Addr_3downto0_is_0x0;
//-- Read enables for status Registers
wire Status_Reg_Set_Rd_En = Bus2IP_RdCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x5;
wire Status_Reg_FOC_Rd_En = Status_Reg_Set_Rd_En && Addr_3downto0_is_0x0;
wire Status_Reg_WIF_Rd_En = Status_Reg_Set_Rd_En && Addr_3downto0_is_0x4;

//-- Write enable for Range Registers
wire Rng_Reg_Set_Wr_En      = Bus2IP_WrCE && Addr_15downto8_is_0x01 && Addr_3downto0_is_0x8;

//-- Read enables for Range Registers
wire Rng_Reg_Set_Rd_En      = Bus2IP_RdCE && Addr_15downto8_is_0x01 && Addr_3downto0_is_0x8;

//-- Read enables for Metric Cnt Registers
wire Metric_Cnt_Reg_Set_Rd_En  = Bus2IP_RdCE && Addr_15downto8_is_0x01 && Addr_3downto0_is_0x0;

//-- Read enables for Incrementer Registers
wire Incr_Reg_Set_Rd_En  = Bus2IP_RdCE && Addr_15downto8_is_0x01 && Addr_3downto0_is_0x4;

//-- Write enable for Event log start register
wire Enlog_Reg_Set_Wr_En =  Bus2IP_WrCE && Addr_15downto8_is_0x01 && Addr_3downto0_is_0xC;

//-- Read enable for Event log start register
wire Enlog_Reg_Set_Rd_En =  Bus2IP_RdCE && Addr_15downto8_is_0x01 && Addr_3downto0_is_0xC;

//-- Read enables for Sampled Metric Cnt Registers
wire Samp_Metric_Cnt_Reg_Set_Rd_En  = Bus2IP_RdCE && Addr_15downto8_is_0x02 && Addr_3downto0_is_0x0;

//-- Read enables for Sampled Incrementer Registers
wire Samp_Incr_Reg_Set_Rd_En  = Bus2IP_RdCE && Addr_15downto8_is_0x02 && Addr_3downto0_is_0x4;

//-- Write enable for Event Log Registers
wire Event_Log_Set_Wr_En    = Bus2IP_WrCE && Addr_15downto8_is_0x04 && Addr_7downto4_is_0x0;

//-- Read enable for Event Log Registers
wire Event_Log_Set_Rd_En    = Bus2IP_RdCE && Addr_15downto8_is_0x04 && Addr_7downto4_is_0x0;

//-- Control Register
always @(posedge S_AXI_ACLK) begin 
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       Metrics_Cnt_En        <= 1'b0;
       Metrics_Cnt_Reset     <= 1'b0;
       Event_Log_En          <= 1'b0;
       Global_Clk_Cnt_En     <= 1'b0;
       Global_Clk_Cnt_Reset  <= 1'b0;
       Streaming_FIFO_Reset  <= 1'b0;
       Use_Ext_Trigger       <= 1'b0;
       Use_Ext_Trigger_Log   <= 1'b0;
       En_Id_Based           <= 1'b0;
       Wr_Lat_Start_CDC      <= 1'b0;
       Wr_Lat_End_CDC        <= 1'b0;
       Rd_Lat_Start_CDC      <= 1'b0;
       Rd_Lat_End_CDC        <= 1'b0;
   end
   else begin 
       if (Control_Set_Wr_En == 1'b1) begin
           Metrics_Cnt_En        <= Bus2IP_Data[0];
           Metrics_Cnt_Reset     <= Bus2IP_Data[1];
           Use_Ext_Trigger       <= Bus2IP_Data[2];
           En_Id_Based           <= Bus2IP_Data[3];
           Wr_Lat_Start_CDC      <= Bus2IP_Data[4];
           Wr_Lat_End_CDC        <= Bus2IP_Data[5];
           Rd_Lat_Start_CDC      <= Bus2IP_Data[6];
           Rd_Lat_End_CDC        <= Bus2IP_Data[7];
           Event_Log_En          <= Bus2IP_Data[8];
           Use_Ext_Trigger_Log   <= Bus2IP_Data[9];
           Global_Clk_Cnt_En     <= Bus2IP_Data[16];
           Global_Clk_Cnt_Reset  <= Bus2IP_Data[17];
           Streaming_FIFO_Reset  <= Bus2IP_Data[25];
       end
       else begin
           Metrics_Cnt_En        <= Metrics_Cnt_En;
           Metrics_Cnt_Reset     <= Metrics_Cnt_Reset;
           Use_Ext_Trigger       <= Use_Ext_Trigger;
           En_Id_Based           <= En_Id_Based;
           Wr_Lat_Start_CDC      <= Wr_Lat_Start_CDC;
           Wr_Lat_End_CDC        <= Wr_Lat_End_CDC;
           Rd_Lat_Start_CDC      <= Rd_Lat_Start_CDC;
           Rd_Lat_End_CDC        <= Rd_Lat_End_CDC;
           Event_Log_En          <= Event_Log_En;
           Use_Ext_Trigger_Log   <= Use_Ext_Trigger_Log;
           Global_Clk_Cnt_En     <= Global_Clk_Cnt_En;
           Global_Clk_Cnt_Reset  <= Global_Clk_Cnt_Reset;
           Streaming_FIFO_Reset  <= Streaming_FIFO_Reset;
       end
   end
end 

assign  Wr_Lat_Start = Wr_Lat_Start_CDC;
assign  Wr_Lat_End   = Wr_Lat_End_CDC;
assign  Rd_Lat_Start = Rd_Lat_Start_CDC;
assign  Rd_Lat_End   = Rd_Lat_End_CDC;


//-- ID Filter register
always @(posedge S_AXI_ACLK) begin 
   if (S_AXI_ARESETN == RST_ACTIVE) begin
      Latency_WID_CDC <= 0; 
      Latency_RID_CDC <= 0; 
   end
   else begin
      if(Latency_ID_Wr_En == 1'b1) begin
         Latency_WID_CDC <= Bus2IP_Data[15:0]; 
         Latency_RID_CDC <= Bus2IP_Data[31:16]; 
      end
      else begin
         Latency_WID_CDC <= Latency_WID_CDC;
         Latency_RID_CDC <= Latency_RID_CDC;
      end
   end
end

assign Latency_WID = Latency_WID_CDC;
assign Latency_RID = Latency_RID_CDC;

//-- ID Mask Register
always @(posedge S_AXI_ACLK) begin 
   if (S_AXI_ARESETN == RST_ACTIVE) begin
      WID_Mask_CDC <= 0; 
      RID_Mask_CDC <= 0; 
   end
   else begin
      if(ID_Mask_Wr_En == 1'b1) begin
         WID_Mask_CDC <= Bus2IP_Data[15:0]; 
         RID_Mask_CDC <= Bus2IP_Data[31:16]; 
      end
      else begin
         WID_Mask_CDC <= WID_Mask_CDC;
         RID_Mask_CDC <= RID_Mask_CDC;
      end
   end
end

assign WID_Mask = WID_Mask_CDC;
assign RID_Mask = RID_Mask_CDC;

//-- Sample Interval LSB Register
always @(posedge S_AXI_ACLK) begin 
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       Sample_Interval_i_reg_CDC <= 0;
   end
   else begin
       if ((Sample_Interval_Wr_En == 1'b1) && (Addr_3downto0_is_0x4 == 1'b1)) begin
           Sample_Interval_i_reg_CDC <= Bus2IP_Data[31:0];
       end
       else begin
           Sample_Interval_i_reg_CDC <= Sample_Interval_i_reg_CDC;
       end
   end
end 
  assign Sample_Interval_i = Sample_Interval_i_reg_CDC;
  assign Sample_Interval = Sample_Interval_i[31:0];

//-- Sample Interval Control Register
always @(posedge S_AXI_ACLK) begin 
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       Interval_Cnt_En             <= 1'b0;
       Interval_Cnt_Ld             <= 1'b0;
       Reset_On_Sample_Int_Lapse   <= 1'b1;
   end
   else begin
       if ((Sample_Interval_Wr_En == 1'b1) && (Addr_3downto0_is_0x8 == 1'b1)) begin
           Interval_Cnt_En             <= Bus2IP_Data[0];
           Interval_Cnt_Ld             <= Bus2IP_Data[1];
           Reset_On_Sample_Int_Lapse   <= Bus2IP_Data[8];
       end
       else begin
           Interval_Cnt_En             <= Interval_Cnt_En     ;
           Interval_Cnt_Ld             <= Interval_Cnt_Ld     ;
           Reset_On_Sample_Int_Lapse   <= Reset_On_Sample_Int_Lapse;
       end
   end
end 

//-- sample register read edge detection logic. 
//-- This will b used in core_aclk domain
generate
    if(C_AXI4LITE_CORE_CLK_ASYNC == 1 && C_ENABLE_EVENT_COUNT == 1) begin :GEN_SAMPLE_REG_ASYNC

    // Synchronizing sample register read enable 
    //-- Double Flop synchronization
    axi_perf_mon_v5_0_9_cdc_sync
    #(
       .c_cdc_type      (1             ),   
       .c_flop_input    (0             ),  
       .c_reset_state   (1             ),  
       .c_single_bit    (1             ),  
       .c_vector_width  (1             ),  
       .c_mtbf_stages   (4             )  
     ) sample_reg_read_inst 
     (
       .prmry_aclk      (S_AXI_ACLK              ),
       .prmry_rst_n     (S_AXI_ARESETN           ),
       .prmry_in        (Lat_Sample_Reg_Rd_En    ),
       .prmry_vect_in   (1'b0                    ),
       .scndry_aclk     (CORE_ACLK               ),
       .scndry_rst_n    (CORE_ARESETN            ),
       .prmry_ack       (                        ),
       .scndry_out      (Lat_Sample_Reg_Rd_En_d2 ),
       .scndry_vect_out (                        ) 
      );

       always @(posedge CORE_ACLK) begin 
         if (CORE_ARESETN == RST_ACTIVE) begin
            Lat_Sample_Reg_Rd_En_d3      <= 0;
         end
         else begin
            Lat_Sample_Reg_Rd_En_d3      <= Lat_Sample_Reg_Rd_En_d2;
         end
       end 

     //-- This rising edge pulse will be used to sample metric counts into sampled metric counts
     assign Lat_Sample_Reg =  Lat_Sample_Reg_Rd_En_d2 && ~Lat_Sample_Reg_Rd_En_d3;
  
    end
    else begin :GEN_SAMPLE_REG_SYNC
      always @(posedge CORE_ACLK) begin 
        if (CORE_ARESETN == RST_ACTIVE) begin
           Lat_Sample_Reg_Rd_En_d1      <= 0;
        end
        else begin
           Lat_Sample_Reg_Rd_En_d1      <= Lat_Sample_Reg_Rd_En;
        end
      end 

      assign  Lat_Sample_Reg= Lat_Sample_Reg_Rd_En && ~Lat_Sample_Reg_Rd_En_d1; 
    end

   endgenerate

   //-- Free running Counter after first read of sample register read 
   //-- The number of clocks is in S_AXI_ACLK domain
   axi_perf_mon_v5_0_9_counter 
     #(
          .C_FAMILY             (C_FAMILY),
          .C_NUM_BITS           (32),
	  .COUNTER_LOAD_VALUE   (32'h00000000)
      ) sample_reg_counter_inst 
      (
          .clk                  (S_AXI_ACLK),
          .rst_n                (S_AXI_ARESETN),
          .Load_In              (TIME_DIFF_LOAD_VALUE),
          .Count_Enable         (Sample_Reg_Rd_First),
          .Count_Load           (1'b0),
          .Count_Down           (1'b0),
          .Count_Out            (Sample_Time_Diff),
          .Carry_Out            ( )  //Overflow is left to the SW as they need to find out
                             // time difference between two sample register reads
      );  
   
   
   //-- Sample time difference capture 
   always @(posedge S_AXI_ACLK) begin 
      if (S_AXI_ARESETN == RST_ACTIVE) begin
          Sample_Time_Diff_Reg<= 0;
          Sample_Reg_Rd_First <= 0;
      end
      else begin
          if (Sample_Reg_Rd_En == 1'b1) begin
             Sample_Time_Diff_Reg<= Sample_Time_Diff;
             Sample_Reg_Rd_First <= 1;
          end
          else begin
             Sample_Time_Diff_Reg<= Sample_Time_Diff_Reg;
             Sample_Reg_Rd_First <= Sample_Reg_Rd_First;
          end
      end
   end 

   //-- Global Interrupt Enable Register
   always @(posedge S_AXI_ACLK) begin 
      if (S_AXI_ARESETN == RST_ACTIVE) begin
          Global_Intr_En <= 1'b0;
      end
      else begin
          if ((Intr_Reg_GIE_Wr_En == 1'b1)) begin
              Global_Intr_En <= Bus2IP_Data[0];
          end
          else begin
              Global_Intr_En <= Global_Intr_En;
          end
      end
   end 

//-- Global Clock Count (for 64-bit and 32-bit)
generate
if (C_GLOBAL_COUNT_WIDTH == 64) begin : GEN_GLOBAL_CLK_64
    assign Global_Clk_Cnt_LSB = Global_Clk_Cnt[31:0];
    assign Global_Clk_Cnt_MSB = Global_Clk_Cnt[63:32];
 
    //-- Latch global clk cnt MSB on synchronized RdEn
    always @(posedge CORE_ACLK) begin 
       if (CORE_ARESETN == RST_ACTIVE) begin
           Lat_Global_Clk_Cnt_MSB_CDCR <= 0;
           Lat_Global_Clk_Cnt_LSB_CDCR <= 0;
       end
       else begin
           if ((Rd_En_sync == 1'b1)) begin
               Lat_Global_Clk_Cnt_MSB_CDCR <= Global_Clk_Cnt_MSB;
               Lat_Global_Clk_Cnt_LSB_CDCR <= Global_Clk_Cnt_LSB;
           end
           else begin
               Lat_Global_Clk_Cnt_MSB_CDCR <= Lat_Global_Clk_Cnt_MSB_CDCR;
               Lat_Global_Clk_Cnt_LSB_CDCR <= Lat_Global_Clk_Cnt_LSB_CDCR;
           end
       end
    end 
    assign Lat_Global_Clk_Cnt_MSB = Lat_Global_Clk_Cnt_MSB_CDCR;
    
end    
else if (C_GLOBAL_COUNT_WIDTH == 32) begin : GEN_GLOBAL_CLK_32
    assign Global_Clk_Cnt_LSB = Global_Clk_Cnt[31:0];
    assign Global_Clk_Cnt_MSB = {32{1'b0}};

    //-- Latch global clk cnt MSB on synchronized RdEn
    always @(posedge CORE_ACLK) begin 
       if (CORE_ARESETN == RST_ACTIVE) begin
           Lat_Global_Clk_Cnt_LSB_CDCR <= 0;
       end
       else begin
           if ((Rd_En_sync == 1'b1)) begin
               Lat_Global_Clk_Cnt_LSB_CDCR <= Global_Clk_Cnt_LSB;
           end
           else begin
               Lat_Global_Clk_Cnt_LSB_CDCR <= Lat_Global_Clk_Cnt_LSB_CDCR;
           end
       end
    end 
    
    assign Lat_Global_Clk_Cnt_MSB = 0;
end    
endgenerate

generate
   if( C_ENABLE_EVENT_COUNT == 1 && C_ENABLE_EVENT_LOG == 1) begin :GEN_CNTRL_REG
   //--IER register read data
   assign Intr_Reg_IER_Int = Intr_Reg_IER;
   //--Control Register read
   assign Control_Reg = { {6{1'b0}}, Streaming_FIFO_Reset, 1'b0,
                          {6{1'b0}}, Global_Clk_Cnt_Reset, Global_Clk_Cnt_En,
                          {6{1'b0}}, Use_Ext_Trigger_Log, Event_Log_En,
                          Rd_Lat_End_CDC,Rd_Lat_Start_CDC,Wr_Lat_End_CDC,Wr_Lat_Start_CDC,
                          En_Id_Based,Use_Ext_Trigger,Metrics_Cnt_Reset, Metrics_Cnt_En };
end
else if(C_ENABLE_EVENT_COUNT == 1) begin:GEN_CNTRL_REG_EVENT_COUNT
   //--IER register read data
   assign Intr_Reg_IER_Int = {Intr_Reg_IER[12:3],1'b0,Intr_Reg_IER[1:0]};
   assign Control_Reg = { {14{1'b0}},
                          Global_Clk_Cnt_Reset, Global_Clk_Cnt_En,
                          {8{1'b0}},
                          Rd_Lat_End_CDC,Rd_Lat_Start_CDC,Wr_Lat_End_CDC,Wr_Lat_Start_CDC,
                          En_Id_Based,Use_Ext_Trigger,Metrics_Cnt_Reset, Metrics_Cnt_En };
end
else if(C_ENABLE_EVENT_LOG == 1) begin:GEN_CNTRL_REG_LOG
   assign Intr_Reg_IER_Int = { {10{1'b0}},Intr_Reg_IER[2],1'b0,Intr_Reg_IER[0]};
   assign Control_Reg = { {6{1'b0}}, Streaming_FIFO_Reset, 1'b0,
                          {6{1'b0}}, Global_Clk_Cnt_Reset, Global_Clk_Cnt_En,
                          {6{1'b0}}, Use_Ext_Trigger_Log, Event_Log_En,{8{1'b0}} };
end
endgenerate


// Synchronizing the enable only. User should load cutt off count and then need to enable 

    generate
    if(C_AXI4LITE_CORE_CLK_ASYNC == 1 && C_ENABLE_EVENT_COUNT == 1 && C_ENABLE_EVENT_LOG == 1) begin:GEN_Metric_Cnt_ASYNC

    // Synchronizing cross probing for 10-metric counters 
    //-- Double Flop synchronization
    axi_perf_mon_v5_0_9_cdc_sync
    #(
       .c_cdc_type      (1             ),   
       .c_flop_input    (0             ),  
       .c_reset_state   (1             ),  
       .c_single_bit    (0             ),  
       .c_vector_width  (10            ),  
       .c_mtbf_stages   (4             )  
     ) Sync_Metric_Cnt_Ovf_inst 
     (
       .prmry_aclk      (S_AXI_ACLK             ),
       .prmry_rst_n     (S_AXI_ARESETN          ),
       .prmry_in        (1'b0                   ),
       .prmry_vect_in   (Metric_Cnt_Ovf_En      ),
       .scndry_aclk     (CORE_ACLK              ),
       .scndry_rst_n    (CORE_ARESETN           ),
       .prmry_ack       (                       ),
       .scndry_out      (                       ),
       .scndry_vect_out (Sync_Metric_Cnt_Ovf_En ) 
      );
    end
    else begin :GEN_Metric_Cnt_SYNC
      assign Sync_Metric_Cnt_Ovf_En = Metric_Cnt_Ovf_En; 
    end

    endgenerate

generate
if (C_ENABLE_EVENT_COUNT == 1) begin : GEN_METRIC_0

//-- Metric Selector for Counter 0 Register
always @(posedge S_AXI_ACLK) begin 
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       Metric_Sel_0_CDC <= 0;
   end
   else begin 
       if (Metric_Sel_Reg_0_Wr_En == 1'b1) begin
           Metric_Sel_0_CDC <= Bus2IP_Data[7:0];
       end
       else begin
           Metric_Sel_0_CDC <= Metric_Sel_0_CDC;
       end
   end
end 

assign Metric_Sel_0 = Metric_Sel_0_CDC;

//-- Range for Counter 0 Register
always @(posedge S_AXI_ACLK) begin 
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       Range_Reg_0_CDC <= 0;
   end
   else begin 
       if ((Rng_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x0 == 1'b1)) begin
           Range_Reg_0_CDC <= Bus2IP_Data[31:0];
       end
       else begin
           Range_Reg_0_CDC <= Range_Reg_0_CDC;
       end
   end
end 

assign Range_Reg_0 = Range_Reg_0_CDC;

end 
else begin : GEN_NO_METRIC_0  //-- else for generate
    assign Metric_Sel_0 = 0;
    assign Range_Reg_0  = 0;
end    
endgenerate


// Generate for counter0 cross probing logic    
generate
if (C_ENABLE_EVENT_COUNT == 1 && C_ENABLE_EVENT_LOG == 1) begin : GEN_CROSS_PROBE_0
//-- Metric Counter0 Cutt off to enable event log 
always @(posedge S_AXI_ACLK) begin 
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       Count0_Cut_Off_CDC <= 0;
   end
   else begin 
       if ((Enlog_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x0 == 1'b1)) begin
           Count0_Cut_Off_CDC <= Bus2IP_Data[31:0];
       end
       else begin
           Count0_Cut_Off_CDC <= Count0_Cut_Off_CDC;
       end
   end
end 

assign Count0_Cut_Off = Count0_Cut_Off_CDC;


//-- Enable event log if metric count0 is greater than Count0_Cut_Off
always @(posedge CORE_ACLK) begin 
   if (CORE_ARESETN == RST_ACTIVE) begin
      Count0_Event_Log_En_i <= 0;
   end
   else begin
       if (Sync_Metric_Cnt_Ovf_En[0] == 1'b0) begin
           Count0_Event_Log_En_i <= 1'b0; 
       end
       else if ((Metric_Cnt_0 >= Count0_Cut_Off_CDC[15:0]) && 
                (Metric_Cnt_0 <= Count0_Cut_Off_CDC[31:16])) begin
           Count0_Event_Log_En_i <= 1'b1;
       end
       else begin
           Count0_Event_Log_En_i <= 1'b0;
       end
   end
end 

assign Count0_Event_Log_En = Count0_Event_Log_En_i;
    
end 
else begin : GEN_NO_CROSS_PROBE_0  //-- else for generate
    assign Count0_Cut_Off = 0;
    assign Count0_Event_Log_En = 0;
end    
endgenerate

//-- generate block for metric counter 1
generate
if ((C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 1)) begin : GEN_METRIC_1

    //-- Metric Selector for Counter 1 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Metric_Sel_1_CDC <= 0;
       end
       else begin 
           if (Metric_Sel_Reg_0_Wr_En == 1'b1) begin
               Metric_Sel_1_CDC <= Bus2IP_Data[15:8];
           end
           else begin
               Metric_Sel_1_CDC <= Metric_Sel_1_CDC;
           end
       end
    end 

    assign Metric_Sel_1 = Metric_Sel_1_CDC;

    //-- Range for Counter 1 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Range_Reg_1_CDC <= 0;
       end
       else begin 
           if ((Rng_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x1 == 1'b1)) begin
               Range_Reg_1_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Range_Reg_1_CDC <= Range_Reg_1_CDC;
           end
       end
    end 
    
    assign Range_Reg_1 = Range_Reg_1_CDC;

end 
else begin : GEN_NO_METRIC_1  //-- else for generate
    assign Metric_Sel_1 = 0;
    assign Range_Reg_1  = 0;
end    
endgenerate


generate
if (C_ENABLE_EVENT_COUNT == 1 && C_ENABLE_EVENT_LOG == 1  && C_NUM_OF_COUNTERS > 1) begin : GEN_CROSS_PROBE_1

    //-- Metric Counter1 Cutt off to enable event log 
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Count1_Cut_Off_CDC <= 0;
       end
       else begin 
           if ((Enlog_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x1 == 1'b1)) begin
               Count1_Cut_Off_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Count1_Cut_Off_CDC <= Count1_Cut_Off_CDC;
           end
       end
    end 

    assign Count1_Cut_Off = Count1_Cut_Off_CDC;

    //-- Enable event log if metric count1 is greater than Count1_Cut_Off
    always @(posedge CORE_ACLK) begin 
       if (CORE_ARESETN == RST_ACTIVE) begin
          Count1_Event_Log_En_i <= 0;
       end
       else begin 
           if (Sync_Metric_Cnt_Ovf_En[1] == 1'b0) begin
               Count1_Event_Log_En_i <= 1'b0;
           end
           else if ((Metric_Cnt_1 >= Count1_Cut_Off_CDC[15:0]) && 
                    (Metric_Cnt_1 <= Count1_Cut_Off_CDC[31:16])) begin
               Count1_Event_Log_En_i <= 1'b1;
           end
           else begin
               Count1_Event_Log_En_i <= 1'b0;
           end
       end
    end 
   
    assign Count1_Event_Log_En = Count1_Event_Log_En_i;

end 
else begin :GEN_NO_CROSS_PROBE_1  //-- else for generate
    assign Count1_Cut_Off = 0;
    assign Count1_Event_Log_En = 0;
end    
endgenerate

//-- generate block for metric counter_2
generate
if ((C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 2)) begin : GEN_METRIC_2

    //-- Metric Selector for Counter_2 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Metric_Sel_2_CDC <= 0;
       end
       else begin 
           if (Metric_Sel_Reg_0_Wr_En == 1'b1) begin
               Metric_Sel_2_CDC <= Bus2IP_Data[23:16];
           end
           else begin
               Metric_Sel_2_CDC <= Metric_Sel_2_CDC;
           end
       end
    end 

    assign Metric_Sel_2 = Metric_Sel_2_CDC;

    //-- Range for Counter_2 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Range_Reg_2_CDC <= 0;
       end
       else begin 
           if ((Rng_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x2 == 1'b1)) begin
               Range_Reg_2_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Range_Reg_2_CDC <= Range_Reg_2_CDC;
           end
       end
    end 
    
    assign Range_Reg_2 = Range_Reg_2_CDC;

end 
else begin : GEN_NO_METRIC_2  //-- else for generate
    assign Metric_Sel_2 = 0;
    assign Range_Reg_2  = 0;
end    
endgenerate


generate
if (C_ENABLE_EVENT_COUNT == 1 && C_ENABLE_EVENT_LOG == 1  && C_NUM_OF_COUNTERS > 2) begin : GEN_CROSS_PROBE_2
 //-- Metric Counter2 Cutt off to enable event log 
   always @(posedge S_AXI_ACLK) begin 
      if (S_AXI_ARESETN == RST_ACTIVE) begin
          Count2_Cut_Off_CDC <= 0;
      end
      else begin 
          if ((Enlog_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x2 == 1'b1)) begin
              Count2_Cut_Off_CDC <= Bus2IP_Data[31:0];
          end
          else begin
              Count2_Cut_Off_CDC <= Count2_Cut_Off_CDC;
          end
      end
   end 

   assign Count2_Cut_Off = Count2_Cut_Off_CDC;

    //-- Enable event log if metric count2 is greater than Count2_Cut_Off
    always @(posedge CORE_ACLK) begin 
       if (CORE_ARESETN == RST_ACTIVE) begin
          Count2_Event_Log_En_i <= 0;
       end
       else begin 
           if (Sync_Metric_Cnt_Ovf_En[2] == 1'b0) begin
               Count2_Event_Log_En_i <= 1'b0;
           end
           else if ((Metric_Cnt_2 >= Count2_Cut_Off_CDC[15:0]) && 
                    (Metric_Cnt_2 <= Count2_Cut_Off_CDC[31:16])) begin
               Count2_Event_Log_En_i <= 1'b1;
           end
           else begin
               Count2_Event_Log_En_i <= 1'b0;
           end
       end
    end 
    assign Count2_Event_Log_En = Count2_Event_Log_En_i;
end 
else begin : GEN_NO_CROSS_PROBE_2  //-- else for generate
    assign Count2_Cut_Off = 0;
    assign Count2_Event_Log_En = 0;
end    
endgenerate


//-- generate block for metric counter 3
generate
if ((C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 3)) begin : GEN_METRIC_3

    //-- Metric Selector for Counter 3 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Metric_Sel_3_CDC <= 0;
       end
       else begin 
           if (Metric_Sel_Reg_0_Wr_En == 1'b1) begin
               Metric_Sel_3_CDC <= Bus2IP_Data[31:24];
           end
           else begin
               Metric_Sel_3_CDC <= Metric_Sel_3_CDC;
           end
       end
    end 

    assign Metric_Sel_3 = Metric_Sel_3_CDC;

    //-- Range for Counter_3 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Range_Reg_3_CDC <= 0;
       end
       else begin 
           if ((Rng_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x3 == 1'b1)) begin
               Range_Reg_3_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Range_Reg_3_CDC <= Range_Reg_3_CDC;
           end
       end
    end 
    
    assign Range_Reg_3 = Range_Reg_3_CDC;

end 
else begin : GEN_NO_METRIC_3  //-- else for generate
    assign Metric_Sel_3 = 0;
    assign Range_Reg_3 = 0;
end    
endgenerate


generate
if (C_ENABLE_EVENT_COUNT == 1 && C_ENABLE_EVENT_LOG == 1  && C_NUM_OF_COUNTERS > 3) begin : GEN_CROSS_PROBE_3
    //-- Metric Counter3 Cutt off to enable event log 
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Count3_Cut_Off_CDC <= 0;
       end
       else begin 
           if ((Enlog_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x3 == 1'b1)) begin
               Count3_Cut_Off_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Count3_Cut_Off_CDC <= Count3_Cut_Off_CDC;
           end
       end
    end 

    assign Count3_Cut_Off = Count3_Cut_Off_CDC;

     //-- Enable event log if metric count3 is greater than Count3_Cut_Off
    always @(posedge CORE_ACLK) begin 
       if (CORE_ARESETN == RST_ACTIVE) begin
          Count3_Event_Log_En_i <= 0;
       end
       else begin 
           if (Sync_Metric_Cnt_Ovf_En[3] == 1'b0) begin
               Count3_Event_Log_En_i <= 1'b0;
           end 
           else if ((Metric_Cnt_3 >= Count3_Cut_Off_CDC[15:0]) && 
                    (Metric_Cnt_3 <= Count3_Cut_Off_CDC[31:16])) begin
               Count3_Event_Log_En_i <= 1'b1;
           end
           else begin
               Count3_Event_Log_En_i <= 1'b0;
           end
       end
    end 
   
    assign Count3_Event_Log_En = Count3_Event_Log_En_i;
end 
else begin : GEN_NO_CROSS_PROBE_3  //-- else for generate
    assign Count3_Cut_Off = 0;
    assign Count3_Event_Log_En = 0;
end    
endgenerate


//-- generate block for metric counter 4
generate
if ((C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 4)) begin : GEN_METRIC_4

    //-- Metric Selector for Counter 4 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Metric_Sel_4_CDC <= 0;
       end
       else begin 
           if (Metric_Sel_Reg_1_Wr_En == 1'b1) begin
               Metric_Sel_4_CDC <= Bus2IP_Data[7:0];
           end
           else begin
               Metric_Sel_4_CDC <= Metric_Sel_4_CDC;
           end
       end
    end 

    assign Metric_Sel_4 = Metric_Sel_4_CDC;

    //-- Range for Counter_4 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Range_Reg_4_CDC <= 0;
       end
       else begin 
           if ((Rng_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x4 == 1'b1)) begin
               Range_Reg_4_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Range_Reg_4_CDC <= Range_Reg_4_CDC;
           end
       end
    end 
    
    assign Range_Reg_4 = Range_Reg_4_CDC;

end 
else begin : GEN_NO_METRIC_4  //-- else for generate
    assign Metric_Sel_4 = 0;
    assign Range_Reg_4 = 0;
end    
endgenerate


generate
if (C_ENABLE_EVENT_COUNT == 1 && C_ENABLE_EVENT_LOG == 1  && C_NUM_OF_COUNTERS > 4) begin : GEN_CROSS_PROBE_4
 //-- Metric Counter4 Cutt off to enable event log 
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Count4_Cut_Off_CDC <= 0;
       end
       else begin 
           if ((Enlog_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x4 == 1'b1)) begin
               Count4_Cut_Off_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Count4_Cut_Off_CDC <= Count4_Cut_Off_CDC;
           end
       end
    end 

    assign Count4_Cut_Off = Count4_Cut_Off_CDC;

    //-- Enable event log if metric count4 is greater than Count4_Cut_Off
    always @(posedge CORE_ACLK) begin 
       if (CORE_ARESETN == RST_ACTIVE) begin
          Count4_Event_Log_En_i <= 0;
       end
       else begin 
           if (Sync_Metric_Cnt_Ovf_En[4] == 1'b0) begin
               Count4_Event_Log_En_i <= 1'b0;
           end
           else if ((Metric_Cnt_4 >= Count4_Cut_Off_CDC[15:0]) &&
                    (Metric_Cnt_4 <= Count4_Cut_Off_CDC[31:16])) begin
               Count4_Event_Log_En_i <= 1'b1;
           end
           else begin
               Count4_Event_Log_En_i <= 1'b0;
           end
       end
    end 
   
    assign Count4_Event_Log_En = Count4_Event_Log_En_i;

end 
else begin : GEN_NO_CROSS_PROBE_4  //-- else for generate
    assign Count4_Cut_Off = 0; 
    assign Count4_Event_Log_En = 0;
end    
endgenerate


//-- generate block for metric counter 5
generate
if ((C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 5)) begin : GEN_METRIC_5

    //-- Metric Selector for Counter 5 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Metric_Sel_5_CDC <= 0;
       end
       else begin 
           if (Metric_Sel_Reg_1_Wr_En == 1'b1) begin
               Metric_Sel_5_CDC <= Bus2IP_Data[15:8];
           end
           else begin
               Metric_Sel_5_CDC <= Metric_Sel_5_CDC;
           end
       end
    end 

    assign Metric_Sel_5 = Metric_Sel_5_CDC;

    //-- Range for Counter_5 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Range_Reg_5_CDC <= 0;
       end
       else begin 
           if ((Rng_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x5 == 1'b1)) begin
               Range_Reg_5_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Range_Reg_5_CDC <= Range_Reg_5_CDC;
           end
       end
    end 
    
    assign Range_Reg_5 = Range_Reg_5_CDC;

end 
else begin : GEN_NO_METRIC_5  //-- else for generate
    assign Metric_Sel_5 = 0;
    assign Range_Reg_5  = 0;
end    
endgenerate


generate
if (C_ENABLE_EVENT_COUNT == 1 && C_ENABLE_EVENT_LOG == 1  && C_NUM_OF_COUNTERS > 5) begin : GEN_CROSS_PROBE_5
    //-- Metric Counter5 Cutt off to enable event log 
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Count5_Cut_Off_CDC <= 0;
       end
       else begin 
           if ((Enlog_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x5 == 1'b1)) begin
               Count5_Cut_Off_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Count5_Cut_Off_CDC <= Count5_Cut_Off_CDC;
           end
       end
    end 

    assign Count5_Cut_Off = Count5_Cut_Off_CDC;

    //-- Enable event log if metric count5 is greater than Count5_Cut_Off
    always @(posedge CORE_ACLK) begin 
       if (CORE_ARESETN == RST_ACTIVE) begin
          Count5_Event_Log_En_i <= 0;
       end
       else begin
           if (Sync_Metric_Cnt_Ovf_En[5] == 1'b0) begin
               Count5_Event_Log_En_i <= 1'b0;
           end
           else if ((Metric_Cnt_5 >= Count5_Cut_Off_CDC[15:0]) &&
                    (Metric_Cnt_5 <= Count5_Cut_Off_CDC[31:16])) begin
               Count5_Event_Log_En_i <= 1'b1;
           end
           else begin
               Count5_Event_Log_En_i <= 1'b0;
           end
       end
    end 
   
    assign Count5_Event_Log_En = Count5_Event_Log_En_i;

end 
else begin : GEN_NO_CROSS_PROBE_5  //-- else for generate
    assign Count5_Cut_Off = 0;
    assign Count5_Event_Log_En = 0;
end    
endgenerate


//-- generate block for metric counter 6
generate
if ((C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 6)) begin : GEN_METRIC_6

    //-- Metric Selector for Counter 6 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Metric_Sel_6_CDC <= 0;
       end
       else begin 
           if (Metric_Sel_Reg_1_Wr_En == 1'b1) begin
               Metric_Sel_6_CDC <= Bus2IP_Data[23:16];
           end
           else begin
               Metric_Sel_6_CDC <= Metric_Sel_6_CDC;
           end
       end
    end 

    assign Metric_Sel_6 = Metric_Sel_6_CDC;

    //-- Range for Counter_6 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Range_Reg_6_CDC <= 0;
       end
       else begin 
           if ((Rng_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x6 == 1'b1)) begin
               Range_Reg_6_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Range_Reg_6_CDC <= Range_Reg_6_CDC;
           end
       end
    end 
    
    assign Range_Reg_6 = Range_Reg_6_CDC;

    end 
else begin : GEN_NO_METRIC_6  //-- else for generate
    assign Metric_Sel_6 = 0;
    assign Range_Reg_6  = 0;
end    
endgenerate

generate
if (C_ENABLE_EVENT_COUNT == 1 && C_ENABLE_EVENT_LOG == 1  && C_NUM_OF_COUNTERS > 6) begin : GEN_CROSS_PROBE_6
    //-- Metric Counter6 Cutt off to enable event log 
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Count6_Cut_Off_CDC <= 0;
       end
       else begin 
           if ((Enlog_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x6 == 1'b1)) begin
               Count6_Cut_Off_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Count6_Cut_Off_CDC <= Count6_Cut_Off_CDC;
           end
       end
    end 

    assign Count6_Cut_Off = Count6_Cut_Off_CDC;

    //-- Enable event log if metric count6 is greater than Count6_Cut_Off
    always @(posedge CORE_ACLK) begin 
       if (CORE_ARESETN == RST_ACTIVE) begin
          Count6_Event_Log_En_i <= 0;
       end
       else begin 
           if (Sync_Metric_Cnt_Ovf_En[6] == 1'b0) begin
               Count6_Event_Log_En_i <= 1'b0;
           end
           else if ((Metric_Cnt_6 >= Count6_Cut_Off_CDC[15:0]) && 
                    (Metric_Cnt_6 <= Count6_Cut_Off_CDC[31:16])) begin
               Count6_Event_Log_En_i <= 1'b1;
           end
           else begin
               Count6_Event_Log_En_i <= 1'b0;
           end
       end
    end 
   
    assign Count6_Event_Log_En = Count6_Event_Log_En_i;

end 
else begin : GEN_NO_CROSS_PROBE_6  //-- else for generate
    assign Count6_Cut_Off = 0;
    assign Count6_Event_Log_En = 0;
end    
endgenerate

//-- generate block for metric counter 7
generate
if ((C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 7)) begin : GEN_METRIC_7

    //-- Metric Selector for Counter 7 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Metric_Sel_7_CDC <= 0;
       end
       else begin 
           if (Metric_Sel_Reg_1_Wr_En == 1'b1) begin
               Metric_Sel_7_CDC <= Bus2IP_Data[31:24];
           end
           else begin
               Metric_Sel_7_CDC <= Metric_Sel_7_CDC;
           end
       end
    end 

    assign Metric_Sel_7 = Metric_Sel_7_CDC;

    //-- Range for Counter_7 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Range_Reg_7_CDC <= 0;
       end
       else begin 
           if ((Rng_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x7 == 1'b1)) begin
               Range_Reg_7_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Range_Reg_7_CDC <= Range_Reg_7_CDC;
           end
       end
    end 
    
    assign Range_Reg_7 = Range_Reg_7_CDC;
 
end 
else begin : GEN_NO_METRIC_7  //-- else for generate
    assign Metric_Sel_7 = 0;
    assign Range_Reg_7  = 0;
end    
endgenerate

generate
if (C_ENABLE_EVENT_COUNT == 1 && C_ENABLE_EVENT_LOG == 1  && C_NUM_OF_COUNTERS > 7) begin : GEN_CROSS_PROBE_7
       //-- Metric Counter7 Cutt off to enable event log 
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Count7_Cut_Off_CDC <= 0;
       end
       else begin 
           if ((Enlog_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x7 == 1'b1)) begin
               Count7_Cut_Off_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Count7_Cut_Off_CDC <= Count7_Cut_Off_CDC;
           end
       end
    end 

    assign Count7_Cut_Off = Count7_Cut_Off_CDC;

    //-- Enable event log if metric count7 is greater than Count7_Cut_Off
    always @(posedge CORE_ACLK) begin 
       if (CORE_ARESETN == RST_ACTIVE) begin
          Count7_Event_Log_En_i <= 0;
       end
       else begin 
           if (Sync_Metric_Cnt_Ovf_En[7] == 1'b0) begin
               Count7_Event_Log_En_i <= 1'b0;
           end
           else if ((Metric_Cnt_7 >= Count7_Cut_Off_CDC[15:0]) &&
                    (Metric_Cnt_7 <= Count7_Cut_Off_CDC[31:16])) begin
               Count7_Event_Log_En_i <= 1'b1;
           end
           else begin
               Count7_Event_Log_En_i <= 1'b0;
           end
       end
    end 
   
    assign Count7_Event_Log_En = Count7_Event_Log_En_i;

end 
else begin : GEN_NO_CROSS_PROBE_7  //-- else for generate
    assign Count7_Cut_Off = 0;
    assign Count7_Event_Log_En = 0;
end    
endgenerate

//-- generate block for metric counter 8
generate
if ((C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 8)) begin : GEN_METRIC_8

    //-- Metric Selector for Counter 8 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Metric_Sel_8_CDC <= 0;
       end
       else begin 
           if (Metric_Sel_Reg_2_Wr_En == 1'b1) begin
               Metric_Sel_8_CDC <= Bus2IP_Data[7:0];
           end
           else begin
               Metric_Sel_8_CDC <= Metric_Sel_8_CDC;
           end
       end
    end 

    assign Metric_Sel_8 = Metric_Sel_8_CDC;

    //-- Range for Counter_8 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Range_Reg_8_CDC <= 0;
       end
       else begin 
           if ((Rng_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x8 == 1'b1)) begin
               Range_Reg_8_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Range_Reg_8_CDC <= Range_Reg_8_CDC;
           end
       end
    end 
    
    assign Range_Reg_8 = Range_Reg_8_CDC;
        
end 
else begin : GEN_NO_METRIC_8  //-- else for generate
    assign Metric_Sel_8 = 0;
    assign Range_Reg_8  = 0;
end    
endgenerate

generate
if (C_ENABLE_EVENT_COUNT == 1 && C_ENABLE_EVENT_LOG == 1  && C_NUM_OF_COUNTERS > 8) begin : GEN_CROSS_PROBE_8
     //-- Metric Counter8 Cutt off to enable event log 
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Count8_Cut_Off_CDC <= 0;
       end
       else begin 
           if ((Enlog_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x8 == 1'b1)) begin
               Count8_Cut_Off_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Count8_Cut_Off_CDC <= Count8_Cut_Off_CDC;
           end
       end
    end 

    assign Count8_Cut_Off = Count8_Cut_Off_CDC;

    //-- Enable event log if metric count8 is greater than Count8_Cut_Off
    always @(posedge CORE_ACLK) begin 
       if (CORE_ARESETN == RST_ACTIVE) begin
          Count8_Event_Log_En_i <= 0;
       end
       else begin 
           if (Sync_Metric_Cnt_Ovf_En[8] == 1'b0) begin
               Count8_Event_Log_En_i <= 1'b0;
           end
           else if ((Metric_Cnt_8 >= Count8_Cut_Off_CDC[15:0]) &&
                    (Metric_Cnt_8 <= Count8_Cut_Off_CDC[31:16])) begin
               Count8_Event_Log_En_i <= 1'b1;
           end
           else begin
               Count8_Event_Log_En_i <= 1'b0;
           end
       end
    end 
   
    assign Count8_Event_Log_En = Count8_Event_Log_En_i;
end 
else begin : GEN_NO_CROSS_PROBE_8  //-- else for generate
    assign Count8_Cut_Off = 0;
    assign Count8_Event_Log_En = 0;
end    
endgenerate

//-- generate block for metric counter 9
generate
if ((C_ENABLE_EVENT_COUNT == 1) && (C_NUM_OF_COUNTERS > 9)) begin : GEN_METRIC_9

    //-- Metric Selector for Counter 9 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Metric_Sel_9_CDC <= 0;
       end
       else begin 
           if (Metric_Sel_Reg_2_Wr_En == 1'b1) begin
               Metric_Sel_9_CDC <= Bus2IP_Data[15:8];
           end
           else begin
               Metric_Sel_9_CDC <= Metric_Sel_9_CDC;
           end
       end
    end 

    assign Metric_Sel_9 = Metric_Sel_9_CDC;

    //-- Range for Counter_9 Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Range_Reg_9_CDC <= 0;
       end
       else begin 
           if ((Rng_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x9 == 1'b1)) begin
               Range_Reg_9_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Range_Reg_9_CDC <= Range_Reg_9_CDC;
           end
       end
    end 
    
    assign Range_Reg_9 = Range_Reg_9_CDC;

   end 
else begin : GEN_NO_METRIC_9  //-- else for generate
    assign Metric_Sel_9 = 0;
    assign Range_Reg_9  = 0;
end    
endgenerate

generate
if (C_ENABLE_EVENT_COUNT == 1 && C_ENABLE_EVENT_LOG == 1  && C_NUM_OF_COUNTERS > 9) begin : GEN_CROSS_PROBE_9
     //-- Metric Counter9 Cutt off to enable event log 
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Count9_Cut_Off_CDC <= 0;
       end
       else begin 
           if ((Enlog_Reg_Set_Wr_En == 1'b1) && (Addr_7downto4_is_0x9 == 1'b1)) begin
               Count9_Cut_Off_CDC <= Bus2IP_Data[31:0];
           end
           else begin
               Count9_Cut_Off_CDC <= Count9_Cut_Off_CDC;
           end
       end
    end 

    assign Count9_Cut_Off = Count9_Cut_Off_CDC;

    //-- Enable event log if metric count9 is greater than Count9_Cut_Off
    always @(posedge CORE_ACLK) begin 
       if (CORE_ARESETN == RST_ACTIVE) begin
          Count9_Event_Log_En_i <= 0;
       end
       else begin 
           if (Sync_Metric_Cnt_Ovf_En[9] == 1'b0) begin
               Count9_Event_Log_En_i <= 1'b0;
           end
           else if ((Metric_Cnt_9 >= Count9_Cut_Off_CDC[15:0]) &&
                    (Metric_Cnt_9 <= Count9_Cut_Off_CDC[31:16])) begin
               Count9_Event_Log_En_i <= 1'b1;
           end
           else begin
               Count9_Event_Log_En_i <= 1'b0;
           end
       end
    end 
   
    assign Count9_Event_Log_En = Count9_Event_Log_En_i;

end 
else begin : GEN_NO_CROSS_PROBE_9  //-- else for generate
    assign Count9_Cut_Off = 0;
    assign Count9_Event_Log_En = 0;
end    
endgenerate


generate
    if(C_ENABLE_EVENT_LOG == 1) begin :GEN_LOG_DATA_REG
     
       reg [6:0]                          Flag_Enable_Reg_CDC;    
       reg                                SW_Data_Log_En_CDC; 
       reg [2:0]                          Ext_Event_Flag_En_CDC;   
       reg                                Global_Clk_Cnt_Ovf_En_int;
       reg                                Sample_Metric_Cnt_Ovf_En_int;
       reg [9:0]                          Metric_Cnt_Ovf_En_int;
       reg [C_SW_SYNC_DATA_WIDTH-1:0]     SW_Data_reg_CDC; 
       reg                                SW_Data_Wr_En_reg; 
       //-- Flag Enable Register
       always @(posedge S_AXI_ACLK) begin 
          if (S_AXI_ARESETN == RST_ACTIVE) begin
              Flag_Enable_Reg_CDC          <= 0;
              SW_Data_Log_En_CDC           <= 1'b0;
              Ext_Event_Flag_En_CDC        <= 0;
              Global_Clk_Cnt_Ovf_En_int    <= 0;
              Sample_Metric_Cnt_Ovf_En_int <= 0;
              Metric_Cnt_Ovf_En_int        <= 0;
          end
          else begin
              if ((Event_Log_Set_Wr_En == 1'b1) && (Addr_3downto0_is_0x0 == 1'b1)) begin
                  Flag_Enable_Reg_CDC          <= Bus2IP_Data[6:0];
                  SW_Data_Log_En_CDC           <= Bus2IP_Data[16];
                  Ext_Event_Flag_En_CDC        <= Bus2IP_Data[19:17];
                  Global_Clk_Cnt_Ovf_En_int    <= Bus2IP_Data[20];
                  Sample_Metric_Cnt_Ovf_En_int <= Bus2IP_Data[21];
                  Metric_Cnt_Ovf_En_int        <= Bus2IP_Data[31:22];
              end
              else begin
                  Flag_Enable_Reg_CDC          <= Flag_Enable_Reg_CDC;
                  SW_Data_Log_En_CDC           <= SW_Data_Log_En_CDC;
                  Ext_Event_Flag_En_CDC        <= Ext_Event_Flag_En_CDC;
                  Global_Clk_Cnt_Ovf_En_int    <= Global_Clk_Cnt_Ovf_En_int ;
                  Sample_Metric_Cnt_Ovf_En_int <= Sample_Metric_Cnt_Ovf_En_int;
                  Metric_Cnt_Ovf_En_int        <= Metric_Cnt_Ovf_En_int;
              end
          end
       end 
       
       assign Flag_Enable_Reg          = Flag_Enable_Reg_CDC;
       assign SW_Data_Log_En           = SW_Data_Log_En_CDC;
       assign Ext_Event_Flag_En        = Ext_Event_Flag_En_CDC;
       assign Global_Clk_Cnt_Ovf_En    = Global_Clk_Cnt_Ovf_En_int;
       assign Sample_Metric_Cnt_Ovf_En = Sample_Metric_Cnt_Ovf_En_int;
       assign Metric_Cnt_Ovf_En        = Metric_Cnt_Ovf_En_int;

      
       //-- Software-written Data Register
       always @(posedge S_AXI_ACLK) begin 
          if (S_AXI_ARESETN == RST_ACTIVE) begin
              SW_Data_reg_CDC       <= 0;
              SW_Data_Wr_En_reg     <= 1'b0;
          end
          else begin
              if ((Event_Log_Set_Wr_En == 1'b1) && (Addr_3downto0_is_0x4 == 1'b1)) begin
                  SW_Data_reg_CDC       <= Bus2IP_Data[C_SW_SYNC_DATA_WIDTH-1:0];
                  SW_Data_Wr_En_reg     <= 1'b1;
              end
              else begin
                  SW_Data_reg_CDC       <= SW_Data_reg_CDC;
                  SW_Data_Wr_En_reg     <= 1'b0;
              end
          end
       end 
       assign SW_Data = SW_Data_reg_CDC;
       assign SW_Data_Wr_En_int = SW_Data_Wr_En_reg;
    end
    else begin :GEN_NO_LOG_DATA_REG
      assign SW_Data                 = 0;
      assign SW_Data_Wr_En_int       = 0;
      assign Flag_Enable_Reg         = 0; 
      assign SW_Data_Log_En          = 0;
      assign Ext_Event_Flag_En       = 0;
      assign Global_Clk_Cnt_Ovf_En   = 0;
      assign Sample_Metric_Cnt_Ovf_En= 0;
      assign Metric_Cnt_Ovf_En       = 0;
    end

endgenerate

      

 // Synchronizing SW_Data write enable signal 
 //--Double Flop synchronization
 generate
    if(C_AXI4LITE_CORE_CLK_ASYNC == 1 && C_ENABLE_EVENT_LOG == 1) begin :GEN_SW_DATA_ASYNC

    axi_perf_mon_v5_0_9_cdc_sync
    #(
       .c_cdc_type      (1             ),   
       .c_flop_input    (0             ),  
       .c_reset_state   (1             ),  
       .c_single_bit    (1             ),  
       .c_vector_width  (1             ),  
       .c_mtbf_stages   (4             )  
     ) sw_data_wr_en_inst 
     (
       .prmry_aclk      (S_AXI_ACLK        ),
       .prmry_rst_n     (S_AXI_ARESETN     ),
       .prmry_in        (SW_Data_Wr_En_int ),
       .prmry_vect_in   (1'b0              ),
       .scndry_aclk     (CORE_ACLK         ),
       .scndry_rst_n    (CORE_ARESETN      ),
       .prmry_ack       (                  ),
       .scndry_out      (SW_Data_Wr_En     ),
       .scndry_vect_out (                  ) 
      );
    end
    else begin :GEN_SW_DATA_SYNC
      assign  SW_Data_Wr_En = SW_Data_Wr_En_int; 
    end

   endgenerate



//-- Address Latched on RdEn
always @(posedge S_AXI_ACLK) begin 
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       Lat_Addr_7downto4_is_0x0          <= 1'b0;
       Lat_Addr_7downto4_is_0x1          <= 1'b0;
       Lat_Addr_7downto4_is_0x2          <= 1'b0;
       Lat_Addr_7downto4_is_0x3          <= 1'b0;
       Lat_Addr_7downto4_is_0x4          <= 1'b0;
       Lat_Addr_7downto4_is_0x5          <= 1'b0;
       Lat_Addr_7downto4_is_0x6          <= 1'b0;
       Lat_Addr_7downto4_is_0x7          <= 1'b0;
       Lat_Addr_7downto4_is_0x8          <= 1'b0;
       Lat_Addr_7downto4_is_0x9          <= 1'b0;

       Lat_Addr_3downto0_is_0x0          <= 1'b0;
       Lat_Addr_3downto0_is_0x4          <= 1'b0;
       Lat_Addr_3downto0_is_0x8          <= 1'b0;
       Lat_Addr_3downto0_is_0xC          <= 1'b0;
       Lat_Control_Set_Rd_En             <= 1'b0;
       Lat_Sample_Interval_Rd_En         <= 1'b0;
       Lat_Sample_Reg_Rd_En              <= 1'b0;
       Lat_Global_Clk_Cnt_Set_Rd_En      <= 1'b0;
       Lat_Global_Clk_Cnt_LSB_Rd_En      <= 1'b0;
       Lat_Global_Clk_Cnt_MSB_Rd_En      <= 1'b0;
       Lat_Intr_Reg_Set_Rd_En            <= 1'b0; 
       Lat_Intr_Reg_GIE_Rd_En            <= 1'b0; 
       Lat_Intr_Reg_IER_Rd_En            <= 1'b0; 
       Lat_Intr_Reg_ISR_Rd_En            <= 1'b0; 
       Lat_Sel_Reg_Set_Rd_En             <= 1'b0; 
       Lat_Metric_Sel_Reg_0_Rd_En        <= 1'b0; 
       Lat_Metric_Sel_Reg_1_Rd_En        <= 1'b0; 
       Lat_Metric_Sel_Reg_2_Rd_En        <= 1'b0; 
       Lat_Status_Reg_Set_Rd_En          <= 1'b0; 
       Lat_Status_Reg_FOC_Rd_En          <= 1'b0; 
       Lat_Status_Reg_WIF_Rd_En          <= 1'b0; 
       Lat_Rng_Reg_Set_Rd_En             <= 1'b0; 
       Lat_Metric_Cnt_Reg_Set_Rd_En      <= 1'b0; 
       Lat_Incr_Reg_Set_Rd_En            <= 1'b0; 
       Lat_Samp_Metric_Cnt_Reg_Set_Rd_En <= 1'b0; 
       Lat_Samp_Incr_Reg_Set_Rd_En       <= 1'b0; 
       Lat_Event_Log_Set_Rd_En           <= 1'b0; 
       Lat_Enlog_Reg_Set_Rd_En           <= 1'b0;
       Lat_Addr_9downto2_CDC             <= 0;
       Lat_Latency_ID_Rd_En              <= 1'b0;
       Lat_ID_Mask_Rd_En                 <= 1'b0;
   end
   else begin
       if ((Bus2IP_RdCE == 1'b1)) begin
           Lat_Addr_7downto4_is_0x0          <= Addr_7downto4_is_0x0;
           Lat_Addr_7downto4_is_0x1          <= Addr_7downto4_is_0x1;
           Lat_Addr_7downto4_is_0x2          <= Addr_7downto4_is_0x2;
           Lat_Addr_7downto4_is_0x3          <= Addr_7downto4_is_0x3;
           Lat_Addr_7downto4_is_0x4          <= Addr_7downto4_is_0x4;
           Lat_Addr_7downto4_is_0x5          <= Addr_7downto4_is_0x5;
           Lat_Addr_7downto4_is_0x6          <= Addr_7downto4_is_0x6;
           Lat_Addr_7downto4_is_0x7          <= Addr_7downto4_is_0x7;
           Lat_Addr_7downto4_is_0x8          <= Addr_7downto4_is_0x8;
           Lat_Addr_7downto4_is_0x9          <= Addr_7downto4_is_0x9;
 
           Lat_Addr_3downto0_is_0x0          <= Addr_3downto0_is_0x0;
           Lat_Addr_3downto0_is_0x4          <= Addr_3downto0_is_0x4;
           Lat_Addr_3downto0_is_0x8          <= Addr_3downto0_is_0x8;
           Lat_Addr_3downto0_is_0xC          <= Addr_3downto0_is_0xC;

           Lat_Control_Set_Rd_En             <= Control_Set_Rd_En;
           Lat_Sample_Interval_Rd_En         <= Sample_Interval_Rd_En;
           Lat_Sample_Reg_Rd_En              <= Sample_Reg_Rd_En;
           Lat_Global_Clk_Cnt_Set_Rd_En      <= Global_Clk_Cnt_Set_Rd_En;
           Lat_Global_Clk_Cnt_LSB_Rd_En      <= Global_Clk_Cnt_LSB_Rd_En;
           Lat_Global_Clk_Cnt_MSB_Rd_En      <= Global_Clk_Cnt_MSB_Rd_En;
           Lat_Intr_Reg_Set_Rd_En            <= Intr_Reg_Set_Rd_En; 
           Lat_Intr_Reg_GIE_Rd_En            <= Intr_Reg_GIE_Rd_En; 
           Lat_Intr_Reg_IER_Rd_En            <= Intr_Reg_IER_Rd_En; 
           Lat_Intr_Reg_ISR_Rd_En            <= Intr_Reg_ISR_Rd_En; 
           Lat_Sel_Reg_Set_Rd_En             <= Sel_Reg_Set_Rd_En     ; 
           Lat_Metric_Sel_Reg_0_Rd_En        <= Metric_Sel_Reg_0_Rd_En; 
           Lat_Metric_Sel_Reg_1_Rd_En        <= Metric_Sel_Reg_1_Rd_En; 
           Lat_Metric_Sel_Reg_2_Rd_En        <= Metric_Sel_Reg_2_Rd_En; 
           Lat_Status_Reg_Set_Rd_En          <= Status_Reg_Set_Rd_En  ; 
           Lat_Status_Reg_FOC_Rd_En          <= Status_Reg_FOC_Rd_En  ; 
           Lat_Status_Reg_WIF_Rd_En          <= Status_Reg_WIF_Rd_En  ; 
           Lat_Rng_Reg_Set_Rd_En             <= Rng_Reg_Set_Rd_En; 
           Lat_Metric_Cnt_Reg_Set_Rd_En      <= Metric_Cnt_Reg_Set_Rd_En; 
           Lat_Incr_Reg_Set_Rd_En            <= Incr_Reg_Set_Rd_En; 
           Lat_Samp_Metric_Cnt_Reg_Set_Rd_En <= Samp_Metric_Cnt_Reg_Set_Rd_En; 
           Lat_Samp_Incr_Reg_Set_Rd_En       <= Samp_Incr_Reg_Set_Rd_En; 
           Lat_Event_Log_Set_Rd_En           <= Event_Log_Set_Rd_En; 
           Lat_Enlog_Reg_Set_Rd_En           <= Enlog_Reg_Set_Rd_En;
           Lat_Addr_9downto2_CDC             <= Bus2IP_Addr[9:2];
           Lat_Latency_ID_Rd_En              <= Latency_ID_Rd_En;
           Lat_ID_Mask_Rd_En                 <= ID_Mask_Rd_En;
       end
       else begin
           Lat_Addr_7downto4_is_0x0          <= Lat_Addr_7downto4_is_0x0;
           Lat_Addr_7downto4_is_0x1          <= Lat_Addr_7downto4_is_0x1;
           Lat_Addr_7downto4_is_0x2          <= Lat_Addr_7downto4_is_0x2;
           Lat_Addr_7downto4_is_0x3          <= Lat_Addr_7downto4_is_0x3;
           Lat_Addr_7downto4_is_0x4          <= Lat_Addr_7downto4_is_0x4;
           Lat_Addr_7downto4_is_0x5          <= Lat_Addr_7downto4_is_0x5;
           Lat_Addr_7downto4_is_0x6          <= Lat_Addr_7downto4_is_0x6;
           Lat_Addr_7downto4_is_0x7          <= Lat_Addr_7downto4_is_0x7;
           Lat_Addr_7downto4_is_0x8          <= Lat_Addr_7downto4_is_0x8;
           Lat_Addr_7downto4_is_0x9          <= Lat_Addr_7downto4_is_0x9;
 
           Lat_Addr_3downto0_is_0x0          <= Lat_Addr_3downto0_is_0x0;
           Lat_Addr_3downto0_is_0x4          <= Lat_Addr_3downto0_is_0x4;
           Lat_Addr_3downto0_is_0x8          <= Lat_Addr_3downto0_is_0x8;
           Lat_Addr_3downto0_is_0xC          <= Lat_Addr_3downto0_is_0xC;

           Lat_Control_Set_Rd_En             <= Lat_Control_Set_Rd_En;
           Lat_Sample_Interval_Rd_En         <= Lat_Sample_Interval_Rd_En;
           Lat_Sample_Reg_Rd_En              <= Lat_Sample_Reg_Rd_En;
           Lat_Global_Clk_Cnt_Set_Rd_En      <= Lat_Global_Clk_Cnt_Set_Rd_En;
           Lat_Global_Clk_Cnt_LSB_Rd_En      <= Lat_Global_Clk_Cnt_LSB_Rd_En;
           Lat_Global_Clk_Cnt_MSB_Rd_En      <= Lat_Global_Clk_Cnt_MSB_Rd_En;
           Lat_Intr_Reg_Set_Rd_En            <= Lat_Intr_Reg_Set_Rd_En; 
           Lat_Intr_Reg_GIE_Rd_En            <= Lat_Intr_Reg_GIE_Rd_En; 
           Lat_Intr_Reg_IER_Rd_En            <= Lat_Intr_Reg_IER_Rd_En; 
           Lat_Intr_Reg_ISR_Rd_En            <= Lat_Intr_Reg_ISR_Rd_En; 
           Lat_Sel_Reg_Set_Rd_En             <= Lat_Sel_Reg_Set_Rd_En     ; 
           Lat_Metric_Sel_Reg_0_Rd_En        <= Lat_Metric_Sel_Reg_0_Rd_En; 
           Lat_Metric_Sel_Reg_1_Rd_En        <= Lat_Metric_Sel_Reg_1_Rd_En; 
           Lat_Metric_Sel_Reg_2_Rd_En        <= Lat_Metric_Sel_Reg_2_Rd_En; 
           Lat_Status_Reg_Set_Rd_En          <= Lat_Status_Reg_Set_Rd_En ; 
           Lat_Status_Reg_FOC_Rd_En          <= Lat_Status_Reg_FOC_Rd_En ; 
           Lat_Status_Reg_WIF_Rd_En          <= Lat_Status_Reg_WIF_Rd_En ; 
           Lat_Rng_Reg_Set_Rd_En             <= Lat_Rng_Reg_Set_Rd_En; 
           Lat_Metric_Cnt_Reg_Set_Rd_En      <= Lat_Metric_Cnt_Reg_Set_Rd_En; 
           Lat_Incr_Reg_Set_Rd_En            <= Lat_Incr_Reg_Set_Rd_En; 
           Lat_Samp_Metric_Cnt_Reg_Set_Rd_En <= Lat_Samp_Metric_Cnt_Reg_Set_Rd_En; 
           Lat_Samp_Incr_Reg_Set_Rd_En       <= Lat_Samp_Incr_Reg_Set_Rd_En; 
           Lat_Event_Log_Set_Rd_En           <= Lat_Event_Log_Set_Rd_En; 
           Lat_Enlog_Reg_Set_Rd_En           <= Lat_Enlog_Reg_Set_Rd_En;
           Lat_Addr_9downto2_CDC             <= Lat_Addr_9downto2_CDC;
           Lat_Latency_ID_Rd_En              <= Lat_Latency_ID_Rd_En;
           Lat_ID_Mask_Rd_En                 <= Lat_ID_Mask_Rd_En;
       end
   end
end 


//-- synchronizing RdEn to core clk domain
//-- Pulse synchronization
    axi_perf_mon_v5_0_9_cdc_sync
    #(
       .c_cdc_type      (0    ),   
       .c_flop_input    (0    ),  
       .c_reset_state   (1    ),  
       .c_single_bit    (1    ),  
       .c_vector_width  (1    ),  
       .c_mtbf_stages   (4    )  
     )cdc_sync_inst1 
     (
       .prmry_aclk      (S_AXI_ACLK       ),
       .prmry_rst_n     (S_AXI_ARESETN    ),
       .prmry_in        (Bus2IP_RdCE      ),
       .prmry_vect_in   (1'b0             ),
       .scndry_aclk     (CORE_ACLK        ),
       .scndry_rst_n    (CORE_ARESETN     ),
       .prmry_ack       (                 ),
       .scndry_out      (Rd_En_sync       ),
       .scndry_vect_out (                 ) 
      );

//-- synchronizing Rd_En_sync to AXI clk domain
//-- Pulse synchronization
     axi_perf_mon_v5_0_9_cdc_sync
    #(
       .c_cdc_type      (0    ),   
       .c_flop_input    (0    ),  
       .c_reset_state   (1    ),  
       .c_single_bit    (1    ),  
       .c_vector_width  (1    ),  
       .c_mtbf_stages   (4    )  
     )cdc_sync_inst2 
     (
       .prmry_aclk      (CORE_ACLK          ),
       .prmry_rst_n     (CORE_ARESETN       ),
       .prmry_in        (Rd_En_sync         ),
       .prmry_vect_in   (1'b0               ),
       .scndry_aclk     (S_AXI_ACLK         ),
       .scndry_rst_n    (S_AXI_ARESETN      ),
       .prmry_ack       (                   ),
       .scndry_out      (RValid             ),
       .scndry_vect_out (                   ) 
      );

//-- Data Valid generation 
always @(posedge S_AXI_ACLK) begin
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       IP2Bus_DataValid <= 1'b0;
   end
   else begin
       IP2Bus_DataValid <= RValid;
   end  
end


//-- Register Read Logic
always @(posedge S_AXI_ACLK) begin
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       IP2Bus_Data <= 0;
   end
   else begin
       if (RValid == 1'b1) begin
           if (Lat_Global_Clk_Cnt_Set_Rd_En == 1'b1) begin
               if (Lat_Global_Clk_Cnt_MSB_Rd_En == 1'b1) begin
                   IP2Bus_Data <= Lat_Global_Clk_Cnt_MSB;
               end
               else if (Lat_Global_Clk_Cnt_LSB_Rd_En == 1'b1) begin
                   IP2Bus_Data <= Lat_Global_Clk_Cnt_LSB_CDCR;
               end
               else begin
                   IP2Bus_Data <= 0;
               end
           end
           else if (Lat_Sample_Interval_Rd_En == 1'b1) begin
               if (Lat_Addr_3downto0_is_0x4 == 1'b1) begin
                   IP2Bus_Data      <= Sample_Interval_i[31:0];   
               end
               else if (Lat_Addr_3downto0_is_0x8 == 1'b1) begin
                   IP2Bus_Data      <= {{23{1'b0}},Reset_On_Sample_Int_Lapse,{6{1'b0}},
                                        Interval_Cnt_Ld, Interval_Cnt_En};   
               end
               else if(Lat_Addr_3downto0_is_0xC == 1'b1) begin
                   IP2Bus_Data      <= Sample_Time_Diff_Reg; 
               end
               else begin
                   IP2Bus_Data      <= 0;
               end
           end
           else if (Lat_Sel_Reg_Set_Rd_En == 1'b1) begin
               if (Lat_Metric_Sel_Reg_0_Rd_En == 1'b1) begin
                   IP2Bus_Data      <= { Metric_Sel_3, Metric_Sel_2, Metric_Sel_1, Metric_Sel_0};   
               end
               else if (Lat_Metric_Sel_Reg_1_Rd_En == 1'b1) begin
                   IP2Bus_Data      <= { Metric_Sel_7, Metric_Sel_6, Metric_Sel_5, Metric_Sel_4};   
               end
               else if (Lat_Metric_Sel_Reg_2_Rd_En == 1'b1) begin
                   IP2Bus_Data      <= {{16{1'b0}}, Metric_Sel_9, Metric_Sel_8};   
               end
               else begin
                   IP2Bus_Data      <= 0;
               end
           end
           else if (Lat_Status_Reg_Set_Rd_En == 1'b1) begin
               if (Lat_Status_Reg_FOC_Rd_En == 1'b1) begin
                   IP2Bus_Data      <= sync_eventlog_cur_cnt;
               end
               else if (Lat_Status_Reg_WIF_Rd_En == 1'b1) begin
                   IP2Bus_Data      <= (C_AXIS_DWIDTH_ROUND_TO_32/32);
               end
               else begin
                   IP2Bus_Data      <= 0;
               end
           end
           else if (Lat_Control_Set_Rd_En == 1'b1) begin
               IP2Bus_Data      <= Control_Reg;   
           end
           else if (Lat_Latency_ID_Rd_En == 1'b1) begin
               IP2Bus_Data      <= {Latency_RID_CDC,Latency_WID_CDC};   
           end
           else if (Lat_ID_Mask_Rd_En == 1'b1) begin
               IP2Bus_Data      <= {RID_Mask_CDC,WID_Mask_CDC};   
           end
           else if (Lat_Intr_Reg_Set_Rd_En == 1'b1) begin
               if (Lat_Intr_Reg_GIE_Rd_En == 1'b1) begin
                   IP2Bus_Data  <= { {31{1'b0}}, Global_Intr_En};   
               end
               else if (Lat_Intr_Reg_IER_Rd_En == 1'b1) begin
                   IP2Bus_Data  <= { {(32-C_NUM_INTR_INPUTS){1'b0}}, Intr_Reg_IER_Int};   
               end
               else if (Lat_Intr_Reg_ISR_Rd_En == 1'b1) begin
                   IP2Bus_Data  <= { {(32-C_NUM_INTR_INPUTS){1'b0}}, Intr_Reg_ISR};   
               end
               else begin
                   IP2Bus_Data  <= 0;
               end
           end
           else if (Lat_Rng_Reg_Set_Rd_En == 1'b1) begin
               if (Lat_Addr_7downto4_is_0x0 == 1'b1) begin
                   IP2Bus_Data  <= Range_Reg_0;   
               end
               else if (Lat_Addr_7downto4_is_0x1 == 1'b1) begin
                   IP2Bus_Data  <= Range_Reg_1;   
               end
               else if (Lat_Addr_7downto4_is_0x2 == 1'b1) begin
                   IP2Bus_Data   <= Range_Reg_2;   
               end
               else if (Lat_Addr_7downto4_is_0x3 == 1'b1) begin
                   IP2Bus_Data   <= Range_Reg_3;   
               end
               else if (Lat_Addr_7downto4_is_0x4 == 1'b1) begin
                   IP2Bus_Data   <= Range_Reg_4;   
               end
               else if (Lat_Addr_7downto4_is_0x5 == 1'b1) begin
                   IP2Bus_Data    <= Range_Reg_5;   
               end
               else if (Lat_Addr_7downto4_is_0x6 == 1'b1) begin
                   IP2Bus_Data    <= Range_Reg_6;   
               end
               else if (Lat_Addr_7downto4_is_0x7 == 1'b1) begin
                   IP2Bus_Data    <= Range_Reg_7;   
               end
               else if (Lat_Addr_7downto4_is_0x8 == 1'b1) begin
                   IP2Bus_Data    <= Range_Reg_8;   
               end
               else if (Lat_Addr_7downto4_is_0x9 == 1'b1) begin
                   IP2Bus_Data    <= Range_Reg_9;   
               end
               else begin
                   IP2Bus_Data     <= 0;
               end
           end
           else if(Lat_Enlog_Reg_Set_Rd_En == 1'b1) begin
               if (Lat_Addr_7downto4_is_0x0 == 1'b1) begin
                   IP2Bus_Data     <= Count0_Cut_Off;   
               end
               else if (Lat_Addr_7downto4_is_0x1 == 1'b1) begin
                   IP2Bus_Data     <= Count1_Cut_Off;   
               end
               else if (Lat_Addr_7downto4_is_0x2 == 1'b1) begin
                   IP2Bus_Data     <= Count2_Cut_Off;   
               end
               else if (Lat_Addr_7downto4_is_0x3 == 1'b1) begin
                   IP2Bus_Data     <= Count3_Cut_Off;   
               end
               else if (Lat_Addr_7downto4_is_0x4 == 1'b1) begin
                   IP2Bus_Data     <= Count4_Cut_Off;   
               end
               else if (Lat_Addr_7downto4_is_0x5 == 1'b1) begin
                   IP2Bus_Data     <= Count5_Cut_Off;   
               end
               else if (Lat_Addr_7downto4_is_0x6 == 1'b1) begin
                   IP2Bus_Data     <= Count6_Cut_Off;   
               end
               else if (Lat_Addr_7downto4_is_0x7 == 1'b1) begin
                   IP2Bus_Data     <= Count7_Cut_Off;   
               end
               else if (Lat_Addr_7downto4_is_0x8 == 1'b1) begin
                   IP2Bus_Data     <= Count8_Cut_Off;   
               end
               else if (Lat_Addr_7downto4_is_0x9 == 1'b1) begin
                   IP2Bus_Data     <= Count9_Cut_Off;   
               end
               else begin
                   IP2Bus_Data     <= 0;
               end
           end
           else if (Lat_Event_Log_Set_Rd_En == 1'b1) begin
               if (Lat_Addr_3downto0_is_0x0 == 1'b1) begin
                   IP2Bus_Data     <= {Metric_Cnt_Ovf_En,Sample_Metric_Cnt_Ovf_En,Global_Clk_Cnt_Ovf_En
                                     ,Ext_Event_Flag_En, SW_Data_Log_En, {9{1'b0}}, Flag_Enable_Reg};   
               end
               else if (Lat_Addr_3downto0_is_0x4 == 1'b1) begin
                   IP2Bus_Data     <= SW_Data;   
               end
               else begin
                   IP2Bus_Data     <= 0;
               end
           end
           else if (Lat_Metric_Cnt_Reg_Set_Rd_En == 1'b1 || Lat_Incr_Reg_Set_Rd_En == 1'b1
                    || Lat_Samp_Metric_Cnt_Reg_Set_Rd_En == 1'b1 || Lat_Samp_Incr_Reg_Set_Rd_En == 1'b1) begin
               IP2Bus_Data  <= Metric_ram_Out;
           end    
           else begin
               IP2Bus_Data <= 0;
           end
       end
       else begin
           IP2Bus_Data <= 0;
       end
   end  
end

generate
if (C_ENABLE_EVENT_COUNT == 1) begin : GEN_METRIC_RAM

//----------------------------------------------------------------------------------
// Loading Metric counts in RAM memory
//----------------------------------------------------------------------------------
reg [31:0] metric_ram_data_in;
reg [31:0] Metric_ram_Out_Reg_CDCR;

always @(*) begin 
      case (Lat_Addr_9downto2_CDC)
        8'h40: metric_ram_data_in<= Metric_Cnt_0;
        8'h41: metric_ram_data_in<= Incrementer_0;
        8'h44: metric_ram_data_in<= Metric_Cnt_1;
        8'h45: metric_ram_data_in<= Incrementer_1;
        8'h48: metric_ram_data_in<= Metric_Cnt_2;
        8'h49: metric_ram_data_in<= Incrementer_2;
        8'h4C: metric_ram_data_in<= Metric_Cnt_3;
        8'h4D: metric_ram_data_in<= Incrementer_3;
        8'h50: metric_ram_data_in<= Metric_Cnt_4;
        8'h51: metric_ram_data_in<= Incrementer_4;
        8'h54: metric_ram_data_in <= Metric_Cnt_5;
        8'h55: metric_ram_data_in <= Incrementer_5;
        8'h58: metric_ram_data_in <= Metric_Cnt_6;
        8'h59: metric_ram_data_in <= Incrementer_6;
        8'h5C: metric_ram_data_in <= Metric_Cnt_7;
        8'h5D: metric_ram_data_in <= Incrementer_7;
        8'h60: metric_ram_data_in <= Metric_Cnt_8;
        8'h61: metric_ram_data_in <= Incrementer_8;
        8'h64: metric_ram_data_in <= Metric_Cnt_9;
        8'h65: metric_ram_data_in <= Incrementer_9;
        8'h80: metric_ram_data_in <= Samp_Metric_Cnt_0;
        8'h81: metric_ram_data_in <= Samp_Incrementer_0;
        8'h84: metric_ram_data_in <= Samp_Metric_Cnt_1;
        8'h85: metric_ram_data_in <= Samp_Incrementer_1;
        8'h88: metric_ram_data_in <= Samp_Metric_Cnt_2;
        8'h89: metric_ram_data_in <= Samp_Incrementer_2;
        8'h8C: metric_ram_data_in <= Samp_Metric_Cnt_3;
        8'h8D: metric_ram_data_in <= Samp_Incrementer_3;
        8'h90: metric_ram_data_in <= Samp_Metric_Cnt_4;
        8'h91: metric_ram_data_in <= Samp_Incrementer_4;
        8'h94: metric_ram_data_in <= Samp_Metric_Cnt_5;
        8'h95: metric_ram_data_in <= Samp_Incrementer_5;
        8'h98: metric_ram_data_in <= Samp_Metric_Cnt_6;
        8'h99: metric_ram_data_in <= Samp_Incrementer_6;
        8'h9C: metric_ram_data_in <= Samp_Metric_Cnt_7;
        8'h9D: metric_ram_data_in <= Samp_Incrementer_7;
        8'hA0: metric_ram_data_in <= Samp_Metric_Cnt_8;
        8'hA1: metric_ram_data_in <= Samp_Incrementer_8;
        8'hA4: metric_ram_data_in <= Samp_Metric_Cnt_9;
        8'hA5: metric_ram_data_in <= Samp_Incrementer_9;
        default:metric_ram_data_in <= 0; 
      endcase
end 


always @(posedge CORE_ACLK) begin 
    if(Rd_En_sync == 1'b1) begin
        Metric_ram_CDCR[Lat_Addr_9downto2_CDC] <= metric_ram_data_in;
    end
    Metric_ram_Out_Reg_CDCR <= Metric_ram_CDCR[Lat_Addr_9downto2_CDC];
end 
    assign Metric_ram_Out = Metric_ram_Out_Reg_CDCR;
end 
else begin : GEN_NO_METRICRAM  
   assign Metric_ram_Out = 0; 
end    
endgenerate


//-- Enable event log if any metric count is greater than Cut_Off count
always @(posedge CORE_ACLK) begin 
   if (CORE_ARESETN == RST_ACTIVE) begin
      Count_Event_Log_En <= 0;
   end
   else begin 
      Count_Event_Log_En  <= Count0_Event_Log_En | Count1_Event_Log_En | Count2_Event_Log_En 
                      | Count3_Event_Log_En | Count4_Event_Log_En | Count5_Event_Log_En
                      | Count6_Event_Log_En | Count7_Event_Log_En | Count8_Event_Log_En
                      | Count9_Event_Log_En ;
   end
end 

//PR#741428
//Synchronize event log read data count to register
// interface clock

    axi_perf_mon_v5_0_9_cdc_sync
    #(
       .c_cdc_type      (1             ),   
       .c_flop_input    (0             ),  
       .c_reset_state   (1             ),  
       .c_single_bit    (0             ),  
       .c_vector_width  (32            ),  
       .c_mtbf_stages   (4             )  
     ) eventlog_fifo_rden 
     (
       .prmry_aclk      (eventlog_rd_clk       ),
       .prmry_rst_n     (eventlog_rd_rstn      ),
       .prmry_in        (1'b0                  ),
       .prmry_vect_in   (eventlog_cur_cnt      ),
       .scndry_aclk     (S_AXI_ACLK            ),
       .scndry_rst_n    (S_AXI_ARESETN         ),
       .prmry_ack       (                      ),
       .scndry_out      (                      ),
       .scndry_vect_out (sync_eventlog_cur_cnt ) 
      );
endmodule
