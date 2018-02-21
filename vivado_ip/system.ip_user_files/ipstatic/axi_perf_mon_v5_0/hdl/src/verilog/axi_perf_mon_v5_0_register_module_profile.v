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
// Filename     : axi_perf_mon_v5_0_9_register_module_profile.v
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
//      \-- axi_perf_mon_v5_0_9_register_module_profile.v
//
//-----------------------------------------------------------------------------
// Author :   NLR 
// History: 
// NLR       10/02/2013      First Version   
// ~~~~~~
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
(* DowngradeIPIdentifiedWarnings="yes" *)

module axi_perf_mon_v5_0_9_register_module_profile 
#(
   parameter                              C_FAMILY                     = "virtex7",
   // AXI port dependant parameters
   parameter                              C_S_AXI_ADDR_WIDTH           = 32,
   parameter                              C_S_AXI_DATA_WIDTH           = 32,

   parameter                              C_NUM_MONITOR_SLOTS          = 1,
   parameter                              C_NUM_OF_COUNTERS            = 6,
   parameter                              C_NUM_INTR_INPUTS            = 2,
   parameter                              C_ENABLE_PROFILE             = 1,  //-- enables/disables perf mon counting logic
   parameter                              C_ENABLE_TRACE               = 0,  //-- enables/disables perf mon log logic
   parameter                              C_METRICS_SAMPLE_COUNT_WIDTH = 32,
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

   // Metric Counters - in core clk domain
   input [31:0]                                      Metric_Ram_Data_In,    

   // Sample Interval Register - in axi clk domain
   output [(C_METRICS_SAMPLE_COUNT_WIDTH - 1):0]     Sample_Interval,    

   // Sample Interval Control Register - in axi clk domain
   output                                            Interval_Cnt_En,
   output                                            Interval_Cnt_Ld,
   output                                            Reset_On_Sample_Int_Lapse,

   // Interrupt Register Enables - in axi clk domain
   output reg                                        Global_Intr_En,
   output                                            Intr_Reg_IER_Wr_En,
   output                                            Intr_Reg_ISR_Wr_En,

   // Interrupt Registers - in axi clk domain
   input [(C_NUM_INTR_INPUTS - 1):0]                 Intr_Reg_IER,    
   input [(C_NUM_INTR_INPUTS - 1):0]                 Intr_Reg_ISR,    
   //Stream FIFO:
   //fifo_rd_en in axi-mm/axis clock domain 
   //fifo_wr_en in core clock domain 
   input                                             fifo_rd_en,
   input                                             fifo_wr_en,
   //rd: clk,rst will be either stream/aximm 
   //wr: clk,rst will be core_aclk
   input                                             eventlog_rd_clk ,
   input                                             eventlog_rd_rstn,
   input [31:0]                                      eventlog_cur_cnt,

   output  [C_SW_SYNC_DATA_WIDTH-1:0]                SW_Data,    
   output                                            SW_Data_Wr_En,    

   // Control Register - in axi clk domain
   output reg                                        Streaming_FIFO_Reset,
   output reg                                        Event_Log_En,
   output reg                                        Metrics_Cnt_En,
   output reg                                        Metrics_Cnt_Reset,
   output reg                                        Use_Ext_Trigger,
   output reg                                        Use_Ext_Trigger_Log,
   // Flag enable register - in core clk domain
   output                                            Lat_Sample_Reg,
   output                                            Wr_Lat_Start,
   output                                            Wr_Lat_End,
   output                                            Rd_Lat_Start,
   output                                            Rd_Lat_End,
   output [9:0]                                      Lat_Addr_11downto2
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
 reg [31:0]                       Metric_ram_CDCR [1023:0];
 reg [9:0]                        Lat_Addr_11downto2_CDC;
 wire [31:0]                      Metric_ram_Out;
 wire [C_NUM_INTR_INPUTS-1:0]     Intr_Reg_IER_Int;

// Signal and Register Declaration-PR#741428
  wire [31:0] sync_eventlog_cur_cnt;


//-------------------------------------------------------------------
// Signal and Register Declaration
//-------------------------------------------------------------------
wire                                Rd_En_sync;
wire                                RValid;
wire [31:0]                         Sample_Interval_i;    

reg  [C_S_AXI_DATA_WIDTH-1:0]       IP2Bus_Data_Int;
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
reg                                 Lat_Intr_Reg_Set_Rd_En      ; 
reg                                 Lat_Intr_Reg_GIE_Rd_En      ; 
reg                                 Lat_Intr_Reg_IER_Rd_En      ; 
reg                                 Lat_Intr_Reg_ISR_Rd_En      ; 
reg                                 Lat_Status_Reg_Set_Rd_En  ; 
reg                                 Lat_Status_Reg_FOC_Rd_En  ; 
reg                                 Lat_Status_Reg_WIF_Rd_En  ; 
reg                                 Lat_Sel_Reg_Set_Rd_En       ; 
reg                                 Lat_Metric_Cnt_Reg_Set_Rd_En; 
reg                                 Lat_Samp_Metric_Cnt_Reg_Set_Rd_En; 
reg                                 Lat_Event_Log_Set_Rd_En     ; 

reg                                 Lat_Enlog_Reg_Set_Rd_En;
reg                                 Lat_Sample_Reg_Rd_En;
reg                                 Lat_Sample_Reg_Rd_En_d3;
reg                                 Lat_Sample_Reg_Rd_En_d1;
wire                                Lat_Sample_Reg_Rd_En_d2;

wire                               SW_Data_Wr_En_int;
reg [31:0]                         Sample_Interval_i_reg_CDC;
// latency start and end points
reg                                Wr_Lat_Start_CDC;
reg                                Wr_Lat_End_CDC;
reg                                Rd_Lat_Start_CDC;
reg                                Rd_Lat_End_CDC;
//Sample register read interval counter enable 
reg  [31:0]                        Sample_Time_Diff_Reg;  
wire [31:0]                        Sample_Time_Diff_Reg_int;  
reg                                Sample_Reg_Rd_First;  
wire [31:0]                        Sample_Time_Diff;  
wire                               prmry_ack2;  
wire                               prmry_ack3;  
wire                               prmry_ack4;  
wire                               prmry_ack5;  
wire                               scndry_out1;  
wire                               scndry_vect_out2;  
wire                               scndry_vect_out3;  
wire                               scndry_vect_out4;  
wire [31:0]                        Control_Reg;
reg                                Interval_Cnt_En_int;
reg                                Interval_Cnt_Ld_int;
reg                                Reset_On_Sample_Int_Lapse_int;
//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------
assign IP2Bus_Error = 0;      // No error conditions hence tieng off the error signal to 0 
wire Addr_15downto8_is_0x00 = (Bus2IP_Addr[15:8] == 8'h00) ? 1'b1 : 1'b0;
wire Addr_15downto8_is_0x01 = (Bus2IP_Addr[15:8] == 8'h01) ? 1'b1 : 1'b0;
wire Addr_15downto8_is_0x02 = (Bus2IP_Addr[15:8] == 8'h02) ? 1'b1 : 1'b0;
wire Addr_15downto8_is_0x03 = (Bus2IP_Addr[15:8] == 8'h03) ? 1'b1 : 1'b0;
wire Addr_15downto8_is_0x04 = (Bus2IP_Addr[15:8] == 8'h04) ? 1'b1 : 1'b0;
wire Addr_15downto8_is_0x05 = (Bus2IP_Addr[15:8] == 8'h05) ? 1'b1 : 1'b0;
wire Addr_15downto8_is_0x06 = (Bus2IP_Addr[15:8] == 8'h06) ? 1'b1 : 1'b0;
wire Addr_15downto8_is_0x07 = (Bus2IP_Addr[15:8] == 8'h07) ? 1'b1 : 1'b0;
wire Addr_15downto8_is_0x08 = (Bus2IP_Addr[15:8] == 8'h08) ? 1'b1 : 1'b0;
wire Addr_15downto8_is_0x09 = (Bus2IP_Addr[15:8] == 8'h09) ? 1'b1 : 1'b0;
wire Addr_15downto8_is_0x0A = (Bus2IP_Addr[15:8] == 8'h0A) ? 1'b1 : 1'b0;


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
wire Addr_7downto4_is_0xb   = (Bus2IP_Addr[7:4] == 4'hb) ? 1'b1 : 1'b0;

wire Addr_3downto0_is_0x0   = (Bus2IP_Addr[3:0] == 4'h0) ? 1'b1 : 1'b0;
wire Addr_3downto0_is_0x4   = (Bus2IP_Addr[3:0] == 4'h4) ? 1'b1 : 1'b0;
wire Addr_3downto0_is_0x8   = (Bus2IP_Addr[3:0] == 4'h8) ? 1'b1 : 1'b0;
wire Addr_3downto0_is_0xC   = (Bus2IP_Addr[3:0] == 4'hC) ? 1'b1 : 1'b0;


wire Metric_Cnt_Rd_Add       = Addr_15downto8_is_0x01 || Addr_15downto8_is_0x05 || 
                               Addr_15downto8_is_0x07 || Addr_15downto8_is_0x09;
wire Sample_Metric_Cnt_Rd_Add = Addr_15downto8_is_0x02 || Addr_15downto8_is_0x06 || 
                                Addr_15downto8_is_0x08 || Addr_15downto8_is_0x0A;

wire min_max_latency_add =  Addr_7downto4_is_0x5 | Addr_7downto4_is_0xb;
wire Metric_Cnt_Rd_Add_extnd         = Metric_Cnt_Rd_Add & min_max_latency_add;
wire Sample_Metric_Cnt_Rd_Add_extnd  = Sample_Metric_Cnt_Rd_Add & min_max_latency_add;

//-------------------------------------------------------------------------------
//-- Write enables and read enables generation
//-------------------------------------------------------------------------------

//-- Write enable for Control Register
wire Control_Set_Wr_En = Bus2IP_WrCE && Addr_15downto8_is_0x03 && Addr_7downto0_is_0x00;

//-- Read enable for Control Register
wire Control_Set_Rd_En = Bus2IP_RdCE && Addr_15downto8_is_0x03 && Addr_7downto0_is_0x00;

//-- Write enable for Sample Interval Registers
wire Sample_Interval_Wr_En = Bus2IP_WrCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x2;

//-- Read enable for Sample Interval Registers
wire Sample_Interval_Rd_En = Bus2IP_RdCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x2;
wire Sample_Reg_Rd_En = Bus2IP_RdCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x2 && Addr_3downto0_is_0xC;

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

//-- Write enables for status Registers
//  -- 0x0:FOC: Fifo Occupancy 
//  -- 0x4:WIF: Words in FIFO.
wire Status_Reg_Set_Wr_En = Bus2IP_WrCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x5;
wire Status_Reg_FOC_Wr_En = Status_Reg_Set_Wr_En && Addr_3downto0_is_0x0;
//-- Read enables for status Registers
wire Status_Reg_Set_Rd_En = Bus2IP_RdCE && Addr_15downto8_is_0x00 && Addr_7downto4_is_0x5;
wire Status_Reg_FOC_Rd_En = Status_Reg_Set_Rd_En && Addr_3downto0_is_0x0;
wire Status_Reg_WIF_Rd_En = Status_Reg_Set_Rd_En && Addr_3downto0_is_0x4;


//-- Read enables for Metric Cnt Registers
wire Metric_Cnt_Reg_Set_Rd_En  = Bus2IP_RdCE && ((Metric_Cnt_Rd_Add && Addr_3downto0_is_0x0) |(Metric_Cnt_Rd_Add_extnd));

//-- Read enables for Sampled Metric Cnt Registers
wire Samp_Metric_Cnt_Reg_Set_Rd_En  = Bus2IP_RdCE && ((Sample_Metric_Cnt_Rd_Add && Addr_3downto0_is_0x0)| (Sample_Metric_Cnt_Rd_Add_extnd));

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
       Streaming_FIFO_Reset  <= 1'b0;
       Use_Ext_Trigger       <= 1'b0;
       Use_Ext_Trigger_Log   <= 1'b0;
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
           Wr_Lat_Start_CDC      <= Bus2IP_Data[4];
           Wr_Lat_End_CDC        <= Bus2IP_Data[5];
           Rd_Lat_Start_CDC      <= Bus2IP_Data[6];
           Rd_Lat_End_CDC        <= Bus2IP_Data[7];
           Event_Log_En          <= Bus2IP_Data[8];
           Use_Ext_Trigger_Log   <= Bus2IP_Data[9];
           Streaming_FIFO_Reset  <= Bus2IP_Data[25];
       end
       else begin
           Metrics_Cnt_En        <= Metrics_Cnt_En;
           Metrics_Cnt_Reset     <= Metrics_Cnt_Reset;
           Use_Ext_Trigger       <= Use_Ext_Trigger;
           Wr_Lat_Start_CDC      <= Wr_Lat_Start_CDC;
           Wr_Lat_End_CDC        <= Wr_Lat_End_CDC;
           Rd_Lat_Start_CDC      <= Rd_Lat_Start_CDC;
           Rd_Lat_End_CDC        <= Rd_Lat_End_CDC;
           Event_Log_En          <= Event_Log_En;
           Use_Ext_Trigger_Log   <= Use_Ext_Trigger_Log;
           Streaming_FIFO_Reset  <= Streaming_FIFO_Reset;
       end
   end
end 

assign  Wr_Lat_Start = Wr_Lat_Start_CDC;
assign  Wr_Lat_End   = Wr_Lat_End_CDC;
assign  Rd_Lat_Start = Rd_Lat_Start_CDC;
assign  Rd_Lat_End   = Rd_Lat_End_CDC;



//-- sample register read edge detection logic. 
//-- This will b used in core_aclk domain
generate
    if(C_AXI4LITE_CORE_CLK_ASYNC == 1 && C_ENABLE_PROFILE == 1) begin :GEN_SAMPLE_REG_ASYNC

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
     
     //-- This rising edge pulse will be used to sample metric counts into sampled metric counts
      assign Lat_Sample_Reg= Lat_Sample_Reg_Rd_En && ~Lat_Sample_Reg_Rd_En_d1; 
    end

   endgenerate


  generate
    if( C_ENABLE_PROFILE == 1) begin :GEN_SAMPLE_PROFILE

   //-- Free running Counter after first read of sample register
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
          .Carry_Out            ( )  //Overflow is left to the software as they have to find the difference
                                     //Between two sample register reads
      );  
   
   
   //-- Sample time capture 
   always @(posedge S_AXI_ACLK) begin 
      if (S_AXI_ARESETN == RST_ACTIVE) begin
          Sample_Time_Diff_Reg<= 0;
          Sample_Reg_Rd_First <= 0;
      end
      else begin
          if (Sample_Reg_Rd_En == 1'b1) begin
             Sample_Time_Diff_Reg   <= Sample_Time_Diff;
             Sample_Reg_Rd_First    <= 1;
          end
          else begin
             Sample_Time_Diff_Reg<= Sample_Time_Diff_Reg;
             Sample_Reg_Rd_First <= Sample_Reg_Rd_First;
          end
      end
   end 
     assign Sample_Time_Diff_Reg_int = Sample_Time_Diff_Reg;

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
      assign Sample_Interval = Sample_Interval_i;
    
    //-- Sample Interval Control Register
    always @(posedge S_AXI_ACLK) begin 
       if (S_AXI_ARESETN == RST_ACTIVE) begin
           Interval_Cnt_En_int             <= 1'b0;
           Interval_Cnt_Ld_int             <= 1'b0;
           Reset_On_Sample_Int_Lapse_int   <= 1'b1;
       end
       else begin
           if ((Sample_Interval_Wr_En == 1'b1) && (Addr_3downto0_is_0x8 == 1'b1)) begin
               Interval_Cnt_En_int             <= Bus2IP_Data[0];
               Interval_Cnt_Ld_int             <= Bus2IP_Data[1];
               Reset_On_Sample_Int_Lapse_int   <= Bus2IP_Data[8];
           end
           else begin
               Interval_Cnt_En_int             <= Interval_Cnt_En_int     ;
               Interval_Cnt_Ld_int             <= Interval_Cnt_Ld_int     ;
               Reset_On_Sample_Int_Lapse_int   <= Reset_On_Sample_Int_Lapse_int;
           end
       end
    end 
        assign Interval_Cnt_En  = Interval_Cnt_En_int;
        assign Interval_Cnt_Ld  = Interval_Cnt_Ld_int;
        assign Reset_On_Sample_Int_Lapse = Reset_On_Sample_Int_Lapse_int;
   end
   else begin:GEN_NOSAMPLE_PROFILE
     assign Sample_Time_Diff_Reg_int  = 0;
     assign Sample_Interval_i         = 0;
     assign Sample_Interval           = 0;
     assign Interval_Cnt_En           = 0;
     assign Interval_Cnt_Ld           = 0;
     assign Reset_On_Sample_Int_Lapse = 1;
   end
   endgenerate

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

generate
   if( C_ENABLE_PROFILE == 1 && C_ENABLE_TRACE == 1) begin :GEN_CNTRL_REG
   //--IER register read data
   assign Intr_Reg_IER_Int = Intr_Reg_IER;
   //--Control Register read
   assign Control_Reg = { {6{1'b0}}, Streaming_FIFO_Reset, 1'b0,
                            {8{1'b0}}, 
                            {6{1'b0}}, Use_Ext_Trigger_Log, Event_Log_En,
                            Rd_Lat_End_CDC,Rd_Lat_Start_CDC,Wr_Lat_End_CDC,Wr_Lat_Start_CDC,
                            1'b0,Use_Ext_Trigger,Metrics_Cnt_Reset, Metrics_Cnt_En };
end
else if(C_ENABLE_PROFILE == 1) begin:GEN_CNTRL_REG_PROFILE
   //--IER register read data
   assign Intr_Reg_IER_Int = {1'b0,Intr_Reg_IER[0]};
   assign Control_Reg = { {24{1'b0}},
                            Rd_Lat_End_CDC,Rd_Lat_Start_CDC,Wr_Lat_End_CDC,Wr_Lat_Start_CDC,
                            1'b0,Use_Ext_Trigger,Metrics_Cnt_Reset, Metrics_Cnt_En };

end
else if(C_ENABLE_TRACE == 1) begin:GEN_CNTRL_REG_TRACE
   assign Intr_Reg_IER_Int = {Intr_Reg_IER[1],1'b0};
   assign Control_Reg = { {6{1'b0}}, Streaming_FIFO_Reset, 1'b0,
                          {14{1'b0}}, 
                          Use_Ext_Trigger_Log, Event_Log_En,{8{1'b0}}};
end
endgenerate
     



   generate if(C_ENABLE_TRACE == 1'b1) begin: GEN_PROFILE_MODE 

       reg [31:0] SW_Data_reg;
       reg  SW_Data_Wr_En_reg;

       //-- Software-written Data Register
       always @(posedge S_AXI_ACLK) begin 
          if (S_AXI_ARESETN == RST_ACTIVE) begin
              SW_Data_reg       <= 0;
              SW_Data_Wr_En_reg <= 1'b0;
          end
          else begin
              if ((Event_Log_Set_Wr_En == 1'b1) && (Addr_3downto0_is_0x4 == 1'b1)) begin
                  SW_Data_reg       <= Bus2IP_Data[C_SW_SYNC_DATA_WIDTH-1:0];
                  SW_Data_Wr_En_reg <= 1'b1;
              end
              else begin
                  SW_Data_reg       <= SW_Data_reg;
                  SW_Data_Wr_En_reg <= 1'b0;
              end
          end
       end 
       assign SW_Data = SW_Data_reg;
       assign SW_Data_Wr_En_int = SW_Data_Wr_En_reg;
    end
    else begin :GEN_NO_LOG_DATA_REG
      assign SW_Data                 = 0;
      assign SW_Data_Wr_En_int       = 0;
    end

endgenerate

      

 // Synchronizing SW_Data write enable signal 
 //--Double Flop synchronization
 generate
    if(C_AXI4LITE_CORE_CLK_ASYNC == 1 && C_ENABLE_TRACE == 1) begin :GEN_SW_DATA_ASYNC

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
       Lat_Intr_Reg_Set_Rd_En            <= 1'b0; 
       Lat_Intr_Reg_GIE_Rd_En            <= 1'b0; 
       Lat_Intr_Reg_IER_Rd_En            <= 1'b0; 
       Lat_Intr_Reg_ISR_Rd_En            <= 1'b0; 
       Lat_Status_Reg_Set_Rd_En          <= 1'b0; 
       Lat_Status_Reg_FOC_Rd_En          <= 1'b0; 
       Lat_Status_Reg_WIF_Rd_En          <= 1'b0; 
       Lat_Metric_Cnt_Reg_Set_Rd_En      <= 1'b0; 
       Lat_Samp_Metric_Cnt_Reg_Set_Rd_En <= 1'b0; 
       Lat_Event_Log_Set_Rd_En           <= 1'b0; 
       Lat_Addr_11downto2_CDC            <= 0;
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
           Lat_Intr_Reg_Set_Rd_En            <= Intr_Reg_Set_Rd_En; 
           Lat_Intr_Reg_GIE_Rd_En            <= Intr_Reg_GIE_Rd_En; 
           Lat_Intr_Reg_IER_Rd_En            <= Intr_Reg_IER_Rd_En; 
           Lat_Intr_Reg_ISR_Rd_En            <= Intr_Reg_ISR_Rd_En; 
           Lat_Status_Reg_Set_Rd_En          <= Status_Reg_Set_Rd_En  ; 
           Lat_Status_Reg_FOC_Rd_En          <= Status_Reg_FOC_Rd_En  ; 
           Lat_Status_Reg_WIF_Rd_En          <= Status_Reg_WIF_Rd_En  ; 
           Lat_Metric_Cnt_Reg_Set_Rd_En      <= Metric_Cnt_Reg_Set_Rd_En; 
           Lat_Samp_Metric_Cnt_Reg_Set_Rd_En <= Samp_Metric_Cnt_Reg_Set_Rd_En; 
           Lat_Event_Log_Set_Rd_En           <= Event_Log_Set_Rd_En; 
           Lat_Addr_11downto2_CDC            <= Bus2IP_Addr[11:2];
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
           Lat_Intr_Reg_Set_Rd_En            <= Lat_Intr_Reg_Set_Rd_En; 
           Lat_Intr_Reg_GIE_Rd_En            <= Lat_Intr_Reg_GIE_Rd_En; 
           Lat_Intr_Reg_IER_Rd_En            <= Lat_Intr_Reg_IER_Rd_En; 
           Lat_Intr_Reg_ISR_Rd_En            <= Lat_Intr_Reg_ISR_Rd_En; 
           Lat_Status_Reg_Set_Rd_En          <= Lat_Status_Reg_Set_Rd_En ; 
           Lat_Status_Reg_FOC_Rd_En          <= Lat_Status_Reg_FOC_Rd_En ; 
           Lat_Status_Reg_WIF_Rd_En          <= Lat_Status_Reg_WIF_Rd_En ; 
           Lat_Metric_Cnt_Reg_Set_Rd_En      <= Lat_Metric_Cnt_Reg_Set_Rd_En; 
           Lat_Samp_Metric_Cnt_Reg_Set_Rd_En <= Lat_Samp_Metric_Cnt_Reg_Set_Rd_En; 
           Lat_Event_Log_Set_Rd_En           <= Lat_Event_Log_Set_Rd_En; 
           Lat_Addr_11downto2_CDC            <= Lat_Addr_11downto2_CDC;
       end
   end
end 

assign Lat_Addr_11downto2 = Lat_Addr_11downto2_CDC;

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
           if (Lat_Sample_Interval_Rd_En == 1'b1) begin
               if (Lat_Addr_3downto0_is_0x4 == 1'b1) begin
                   IP2Bus_Data      <= Sample_Interval_i[31:0];   
               end
               else if (Lat_Addr_3downto0_is_0x8 == 1'b1) begin
                   IP2Bus_Data      <= {{23{1'b0}},Reset_On_Sample_Int_Lapse,{6{1'b0}},
                                        Interval_Cnt_Ld, Interval_Cnt_En};   
               end
               else if(Lat_Addr_3downto0_is_0xC == 1'b1) begin
                   IP2Bus_Data      <= Sample_Time_Diff_Reg_int; 
               end
               else begin
                   IP2Bus_Data      <= 0;
               end
           end
           else if (Lat_Control_Set_Rd_En == 1'b1) begin
               IP2Bus_Data      <= Control_Reg;   
           end
           else if (Lat_Intr_Reg_Set_Rd_En == 1'b1) begin
               if (Lat_Intr_Reg_GIE_Rd_En == 1'b1) begin
                   IP2Bus_Data  <= { {31{1'b0}}, Global_Intr_En};   
               end
               else if (Lat_Intr_Reg_IER_Rd_En == 1'b1) begin
                   IP2Bus_Data  <= { {(31-C_NUM_INTR_INPUTS){1'b0}}, Intr_Reg_IER_Int,1'b0};   
               end
               else if (Lat_Intr_Reg_ISR_Rd_En == 1'b1) begin
                   IP2Bus_Data  <= { {(31-C_NUM_INTR_INPUTS){1'b0}}, Intr_Reg_ISR,1'b0};   
               end
               else begin
                   IP2Bus_Data  <= 0;
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
           else if (Lat_Event_Log_Set_Rd_En == 1'b1) begin
               if (Lat_Addr_3downto0_is_0x4 == 1'b1) begin
                   IP2Bus_Data     <= SW_Data;   
               end
               else begin
                   IP2Bus_Data     <= 0;
               end
           end
           else if (Lat_Metric_Cnt_Reg_Set_Rd_En == 1'b1 || Lat_Samp_Metric_Cnt_Reg_Set_Rd_En == 1'b1) begin
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
if (C_ENABLE_PROFILE == 1) begin : GEN_METRIC_RAM

//----------------------------------------------------------------------------------
// Loading Metric counts in RAM memory
//----------------------------------------------------------------------------------
reg [31:0] Metric_ram_Out_Reg_CDCR;

always @(posedge CORE_ACLK) begin 
    if(Rd_En_sync == 1'b1) begin
        Metric_ram_CDCR[Lat_Addr_11downto2_CDC] <= Metric_Ram_Data_In;
    end
    Metric_ram_Out_Reg_CDCR <= Metric_ram_CDCR[Lat_Addr_11downto2_CDC];
end 
    assign Metric_ram_Out = Metric_ram_Out_Reg_CDCR;
end 
else begin : GEN_NO_METRICRAM  
   assign Metric_ram_Out = 0; 
end    
endgenerate
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
