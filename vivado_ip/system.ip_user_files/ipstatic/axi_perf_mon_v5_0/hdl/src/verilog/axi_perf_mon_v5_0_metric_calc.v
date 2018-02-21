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
// Filename   :     axi_perf_mon_v5_0_9_metric_calc.v 
// Version    :     v5.0
// Description:      Metric calculator module generates different metric count
//                   enables which will be used in metric counter 
// Verilog-Standard:  Verilog 2001 
//-----------------------------------------------------------------------------
// Structure:
//  axi_perf_mon.v
//      \-- axi_perf_mon_v5_0_9_metric_calc.v
//-----------------------------------------------------------------------------
// Author :  NLR  
// History: 
// NLR       07/25/2012      First Version
// ^^^^^^
// NLR       10/10/2012      Separated the external event calculation from
// ^^^^^^                    this module
//
// NLR       03/20/2013      Added external trigger stop to halt the metric
// ^^^^^^                    counters
//                           Added latency calculation by given ID
//
// NLR       10/02/2013      Added ID Filtering/Masking/ignoring support for all metrics
// ^^^^^^                    Latency start and end point selection 
// Kartheek  09/08/2014      Write latency logic updated , write before
//                           address support enabled
// Kartheek  11/27/2014      32 it ID filtering support added Read latency logic updated
//
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
(* DowngradeIPIdentifiedWarnings="yes" *)

module axi_perf_mon_v5_0_9_metric_calc 
  #(
    parameter C_AXIID                  = 4,
    parameter C_AXIADDR                = 32,
    parameter C_AXIDATA                = 32,
    parameter C_AXISDATA               = 32,
    parameter C_AXISID                 = 4,
    parameter C_AXISDEST               = 1,
    parameter C_AXISUSER               = 1,
    parameter C_OUTSTAND_DEPTH         = 1,
    parameter C_METRIC_COUNT_WIDTH     = 32,
    parameter C_MON_FIFO_WIDTH         = 126,
    parameter C_AXI_PROTOCOL           = "AXI4",
    parameter C_AXI_SUB_PROTOCOL       = "AXI4LITE"
    )
   (
    //AXI Signals
    input                                 clk,        
    input                                 rst_n,  
    input [C_MON_FIFO_WIDTH -1:0]         Data_In,
    input                                 Data_Valid,
    // Register inputs
    input                                 Metrics_Cnt_En,
    input                                 Metrics_Cnt_Reset,
    // External Trigger inputs
    input                                 Use_Ext_Trig,
    input                                 Ext_Trig,
    input                                 Ext_Trig_Stop,
    // Latency ID's from Registers
    input  [15:0]                         Latency_WID,
    input  [15:0]                         Latency_RID,
    input  [15:0]                         WID_Mask,
    input  [15:0]                         RID_Mask,
    input                                 En_Id_Based,
    input                                 Wr_Lat_Start,  //1 Address Issue 0 Address acceptance
    input                                 Wr_Lat_End,    //1 First write   0 Last write  
    input                                 Rd_Lat_Start,  //1 Address Issue 0 Address acceptance 
    input                                 Rd_Lat_End,    //1 First Read    0 Last Read
    /// Metric outputs
    output reg                            Wtrans_Cnt_En,
    output reg                            Rtrans_Cnt_En,
    output     [C_METRIC_COUNT_WIDTH-1:0] Write_Byte_Cnt,
    output reg [C_METRIC_COUNT_WIDTH-1:0] Read_Byte_Cnt,
    output                                Write_Beat_Cnt_En,
    output reg                            Read_Beat_Cnt_En,
    output     [C_METRIC_COUNT_WIDTH-1:0] Write_Beat_Cnt,
    output     [C_METRIC_COUNT_WIDTH-1:0] Read_Latency,
    output     [C_METRIC_COUNT_WIDTH-1:0] Write_Latency,
    output                                Read_Latency_En,
    output                                Write_Latency_En,
    output                                Slv_Wr_Idle_Cnt_En,        
    output     [C_METRIC_COUNT_WIDTH-1:0] Slv_Wr_Idle_Cnt,        
    output reg                            Mst_Rd_Idle_Cnt_En,        
    output reg                            Num_BValids_En,       
    output                                Num_WLasts_En,             
    output reg                            Num_RLasts_En,      
    //AXI Streaming metrics
    output reg                            S_Transfer_Cnt_En,
    output reg                            S_Packet_Cnt_En,  
    output reg [C_METRIC_COUNT_WIDTH-1:0] S_Data_Byte_Cnt,
    output reg [C_METRIC_COUNT_WIDTH-1:0] S_Position_Byte_Cnt,
    output reg [C_METRIC_COUNT_WIDTH-1:0] S_Null_Byte_Cnt,
    output reg                            S_Slv_Idle_Cnt_En,
    output reg                            S_Mst_Idle_Cnt_En,
    output     [C_METRIC_COUNT_WIDTH-1:0] Max_Write_Latency,                   
    output     [C_METRIC_COUNT_WIDTH-1:0] Min_Write_Latency,                   
    output     [C_METRIC_COUNT_WIDTH-1:0] Max_Read_Latency,                   
    output     [C_METRIC_COUNT_WIDTH-1:0] Min_Read_Latency                   
    );

    //Parameter Declarations
    localparam RST_ACTIVE              = 0; 

    //Register declarations
    reg Write_going_on;
    reg Write_iss_going_on;
    reg Read_going_on;

    reg Ext_Trig_Metric_en;
    reg [1:0] Ext_Triggers_Sync_d1;

    //wire declaration

    wire                   RREADY;
    wire                   RVALID;
    wire                   RLAST ;
    wire [1:0]             RRESP;
    wire [C_AXIID-1:0]     RID;
    wire                   ARREADY;
    wire                   ARVALID;
    wire [1:0]             ARBURST;
    wire [2:0]             ARSIZE;
    wire [7:0]             ARLEN;
    wire [C_AXIADDR-1:0]   ARADDR;
    wire [C_AXIID-1:0]     ARID;
    wire                   BREADY;
    wire                   BVALID;
    wire [1:0]             BRESP;
    wire [C_AXIID-1:0]     BID;
    wire                   WREADY;
    wire                   WVALID;
    wire                   WLAST;
    wire [C_AXIDATA/8-1:0] WSTRB;
    wire                   AWREADY;
    wire                   AWVALID;
    wire [1:0]             AWBURST;
    wire [2:0]             AWSIZE;
    wire [7:0]             AWLEN;
    wire [C_AXIADDR-1:0]   AWADDR;
    wire [C_AXIID-1:0]     AWID; 

    wire [C_AXISUSER-1:0] TUSER;
    wire [C_AXISDEST-1:0] TDEST;
    wire [C_AXISID-1:0] TID  ;
    wire TLAST;
    wire [C_AXISDATA/8-1:0] TKEEP;
    wire [C_AXISDATA/8-1:0] TSTRB;
    wire TREADY;
    wire TVALID;


    wire [C_METRIC_COUNT_WIDTH-1:0] zeros = 0;
    wire [C_METRIC_COUNT_WIDTH-1:0] wr_byte_cnt; 
    reg  [C_METRIC_COUNT_WIDTH-1:0] wr_byte_cnt_reg; 

    wire [C_METRIC_COUNT_WIDTH-1:0] Write_Latency_Cnt_Out;
    reg  [C_METRIC_COUNT_WIDTH-1:0] Write_Latency_Cnt_Out_D1;
    reg  [C_METRIC_COUNT_WIDTH-1:0] Write_Latency_Cnt_Out_D2;
    wire [C_METRIC_COUNT_WIDTH-1:0] Read_Latency_Cnt_Out;
    reg [C_METRIC_COUNT_WIDTH:0] Read_Latency_Cnt_Out_D1;
    reg [C_METRIC_COUNT_WIDTH:0] Read_Latency_Cnt_Out_D2;

    // read and write latency counter overflow signals
    wire Write_Latency_Cnt_Ovf;
    wire Read_Latency_Cnt_Ovf;

    wire wr_latency_start;
    wire wr_latency_end;
    wire rd_latency_start;
    wire rd_latency_end;
    wire First_Write_sel;
    wire Last_Write_sel;
    wire First_Read_sel;
    wire Last_Read_sel;

    // read and write latency counter enable signals 
    reg  Read_Latency_En_Int;
    reg  Write_Latency_En_Int;

    // Write Latency FIFO control signals
    //reg  Wr_Latency_Fifo_Wr_En;
    reg  Wr_Latency_Fifo_Rd_En;
    reg  Wr_Latency_Fifo_Rd_En_D1;
    reg  Wr_Latency_Fifo_Rd_En_D2;

    // Read Latency FIFO control signals
    reg  Rd_Latency_Fifo_Wr_En;
    reg  Rd_Latency_Fifo_Rd_En;
    reg  Rd_Latency_Fifo_Rd_En_D1;
    reg  Rd_Latency_Fifo_Rd_En_D2;

    // Write and read latency signals
    reg [C_METRIC_COUNT_WIDTH-1:0] Write_Latency_Int;
    reg [C_METRIC_COUNT_WIDTH-1:0] Read_Latency_Int;

    // read and write latency counter data signals
    //reg [C_METRIC_COUNT_WIDTH-1:0] Wr_Latency_Fifo_Wr_Data;
    reg [C_METRIC_COUNT_WIDTH:0] Rd_Latency_Fifo_Wr_Data;
    reg [C_METRIC_COUNT_WIDTH-1:0] Max_Write_Latency_Int;
    reg [C_METRIC_COUNT_WIDTH-1:0] Min_Write_Latency_Int;
    reg [C_METRIC_COUNT_WIDTH-1:0] Max_Read_Latency_Int;
    reg [C_METRIC_COUNT_WIDTH-1:0] Min_Read_Latency_Int;
    reg Write_Latency_One;            
    reg Write_Latency_One_D1;            
    reg Read_Latency_One;            
    reg Read_Latency_One_D1;  
    reg [4:0]      Wr_Latency_Occupancy;
    //reg [4:0]      Rd_Latency_Occupancy;
    reg  Write_Beat_reg;
    reg  Wr_Idle_reg;
    reg  Last_Write_reg;
    reg  First_Write_reg;
    reg  Last_Read_reg;
    reg  First_Read_reg;
    reg  rid_match_reg;

    wire [C_AXIID-1:0] AWID_COMP;
    wire [C_AXIID-1:0] ARID_COMP;
   // wire Wr_Latency_Fifo_Rd_En_out;
    wire Rd_Latency_Fifo_Rd_En_out;
      
   // wire [C_METRIC_COUNT_WIDTH-1:0] Wr_Latency_Fifo_Rd_Data;
    reg [C_METRIC_COUNT_WIDTH-1:0] Wr_Latency_Fifo_Rd_Data_D1;
    wire [C_METRIC_COUNT_WIDTH:0] Rd_Latency_Fifo_Rd_Data;
    reg [C_METRIC_COUNT_WIDTH:0] Rd_Latency_Fifo_Rd_Data_D1;
    //wire Wr_Latency_Fifo_Full; 
    //wire Wr_Latency_Fifo_Empty; 
    wire Rd_Latency_Fifo_Full; 
    wire Rd_Latency_Fifo_Empty; 
    wire Wr_Latcnt_rst_n; 
    wire Rd_Latcnt_rst_n; 
    wire [C_METRIC_COUNT_WIDTH-1:0] data_byte_cnt;
    wire [C_METRIC_COUNT_WIDTH-1:0] pos_byte_cnt;
    wire [C_METRIC_COUNT_WIDTH-1:0] null_byte_cnt;
    wire [C_METRIC_COUNT_WIDTH-1:0] ONE = 1;
    wire [C_METRIC_COUNT_WIDTH-1:0] TWO = {{(C_METRIC_COUNT_WIDTH-2){1'b0}},2'b10};
    wire [C_METRIC_COUNT_WIDTH-1:0] ALL_ONES = {C_METRIC_COUNT_WIDTH{1'b1}} ;
    wire [1:0] Ext_Triggers = {Ext_Trig_Stop,Ext_Trig}; 
    wire [1:0] Ext_Triggers_Sync;
    wire Ext_Trig_Sync_Out;
    wire Ext_Trig_Stop_Sync_Out;
    //reg Wr_Id_Fifo_Wr_En;
   // reg Wr_Id_Fifo_Rd_En;
   // reg Wr_Id_Fifo_Wr_Data;
   // wire Wr_Id_Fifo_Rd_Data;
   // wire Wr_Id_Fifo_Empty;
    wire wid_match;
   // reg wid_match_int;
   // reg wid_match_latch;
    //reg Write_access_done;
    reg Wr_Add_Issue;
    reg Wr_Valid_Issue;
    reg No_Wr_Ready;
    reg No_Write_Ready;
    reg [C_AXIID-1:0] AWID_reg;
    //reg Read_access_done;
    reg Rd_Add_Issue;
    reg No_Rd_Ready;
    reg [C_AXIID-1:0] ARID_reg;
    //wire Write_Latency_Ovf;
    //reg Read_Latency_Ovf;
    wire Wr_cnt_ld;
    wire Rd_cnt_ld;

    wire rst_int_n = rst_n &  ~(Metrics_Cnt_Reset);
    // Function to find number of '1' in a n bit strobe vector 

    function [C_METRIC_COUNT_WIDTH-1:0] count;
    input [C_AXIDATA/8-1:0] strobe; //Strobe 
    input valid;                    //Data valid
    integer j;
    reg [C_METRIC_COUNT_WIDTH-1:0] count_i;
    begin
      count_i = 0;
      for(j=0;j<=C_AXIDATA/8-1;j=j+1) begin
        if(valid == 1) begin
          count_i = count_i+strobe[j]; 
        end
      end
      count = count_i;
    end
    endfunction

   // Function to find number of '1' in 4-bit strobe

   function [2:0] count_4;
    input [3:0] strobe;     // Strobe
    input valid;            //Data valid
    integer j;
    reg [2:0] count_i;
    begin
      count_i = 0;
      for(j=0;j<=3;j=j+1) begin
          count_i = count_i+(strobe[j] & valid); 
      end
      count_4 = count_i;
    end
    endfunction

   // Function to find number of '1' in 8-bit strobe
    function [3:0] count_8;
    input [7:0] strobe;      //Strobe
    input valid;             //Data valid
    integer j;
    reg [2:0] count_1;
    reg [2:0] count_2;
    begin
      count_1 = count_4(strobe[3:0],valid);
      count_2 = count_4(strobe[7:4],valid);
      count_8 = count_1+count_2;
    end
    endfunction

   // Function to find number of '1' in 16-bit strobe
    function [4:0] count_16; 
    input [15:0] strobe;   //Strobe
    input valid;           //Data valid
    integer j;
    reg [3:0] count_1;
    reg [3:0] count_2;
    begin
      count_1 = count_8(strobe[7:0],valid);
      count_2 = count_8(strobe[15:8],valid);
      count_16 = count_1+count_2;
    end
    endfunction

   // Function to find number of '1' in 32-bit strobe
    function [5:0] count_32;
    input [31:0] strobe;   //Strobe
    input valid;           //Data valid
    integer j;
    reg [4:0] count_1;
    reg [4:0] count_2;
    begin
      count_1 = count_16(strobe[15:0],valid);
      count_2 = count_16(strobe[31:16],valid);
      count_32 = count_1+count_2;
    end
    endfunction

   // Function to find number of '1' in 64-bit strobe
    function [6:0] count_64;
    input [63:0] strobe;   //Strobe
    input valid;           //Data valid
    integer j;
    reg [5:0] count_1;
    reg [5:0] count_2;
    begin
      count_1  = count_32(strobe[31:0],valid);
      count_2  = count_32(strobe[63:32],valid);
      count_64 = count_1+count_2;
    end
    endfunction

   // Function to find number of '1' in 128-bit strobe
    function [7:0] count_128;
    input [127:0] strobe;  //Strobe
    input valid;           //Data valid
    reg [6:0] count_1;  
    reg [6:0] count_2;
    begin
      count_1  = count_64(strobe[63:0],valid);
      count_2  = count_64(strobe[127:64],valid);
      count_128 = count_1+count_2;
    end
    endfunction

  // Function to find ID match based on filtering/masking 
  // If mask bit is '1' ignores the corresponding bit for filtering
  function id_matched;
    input [C_AXIID-1:0] id_mask;     //ID mask
    input [C_AXIID-1:0] id_filter;   //ID filter
    input [C_AXIID-1:0] id;          //Actual ID
    integer j;
    reg [C_AXIID-1:0] id_match;
    begin
      id_match = 0;
      for(j=0;j<C_AXIID;j=j+1) begin
         id_match[j] = (id_mask[j] | (id_filter[j] ^~ id[j]));
      end
      id_matched = &(id_match);
  end
  endfunction

 // Synchronizing external trigger
 //--Level synchronization
    axi_perf_mon_v5_0_9_cdc_sync
    #(
       .c_cdc_type      (1             ),   
       .c_flop_input    (0             ),  
       .c_reset_state   (1             ),  
       .c_single_bit    (0             ),  
       .c_vector_width  (2             ),  
       .c_mtbf_stages   (4             )  
     )ext_trig_cdc_sync 
     (
       .prmry_aclk      (1'b0                ), //Not used as there is no setting for c_flop_input 
       .prmry_rst_n     (1'b1                ),
       .prmry_in        (1'b0                ),
       .prmry_vect_in   (Ext_Triggers        ),
       .scndry_aclk     (clk                 ),
       .scndry_rst_n    (rst_int_n           ),
       .prmry_ack       (                    ),
       .scndry_out      (                    ),
       .scndry_vect_out (Ext_Triggers_Sync   ) 
      );

   always @(posedge clk) begin
      if (rst_int_n == RST_ACTIVE) begin
          Ext_Triggers_Sync_d1 <= 0;
      end
      else begin
          Ext_Triggers_Sync_d1 <= Ext_Triggers_Sync;
      end
   end
  
   // Positive edge detection for the trigger start and stop 
   assign Ext_Trig_Sync_Out = Ext_Triggers_Sync[0] & ~(Ext_Triggers_Sync_d1[0]); 
   assign Ext_Trig_Stop_Sync_Out = Ext_Triggers_Sync[1] & ~(Ext_Triggers_Sync_d1[1]); 

   always @(posedge clk) begin
      if (rst_int_n == RST_ACTIVE) begin
          Ext_Trig_Metric_en <= 0;
      end
      else begin
          if(Use_Ext_Trig == 1'b0 || Ext_Trig_Stop_Sync_Out == 1'b1) begin
            Ext_Trig_Metric_en <=  1'b0;
          end
          else if(Ext_Trig_Sync_Out == 1'b1) begin
            Ext_Trig_Metric_en <=  1'b1;
          end
          else begin
            Ext_Trig_Metric_en <= Ext_Trig_Metric_en;
          end
      end
   end

   wire Metrics_Cnt_En_Int = Use_Ext_Trig?(Metrics_Cnt_En&Ext_Trig_Metric_en):Metrics_Cnt_En;

   assign Metrics_Cnt_En_Out = Metrics_Cnt_En_Int;

   generate if(C_AXI_PROTOCOL == "AXI4") begin : GEN_AXI4

    // AXI Events from parallel FIFO data
    assign RREADY  = Data_In[0];
    assign RVALID  = Data_In[1];
    assign RLAST   = Data_In[2];
    assign RRESP   = Data_In[4:3];
    assign RID     = Data_In[C_AXIID+4:5];
    assign ARREADY = Data_In[C_AXIID+5];
    assign ARVALID = Data_In[C_AXIID+6];
    assign ARBURST = Data_In[C_AXIID+8:C_AXIID+7];
    assign ARSIZE  = Data_In[C_AXIID+11:C_AXIID+9];
    assign ARLEN   = Data_In[C_AXIID+19:C_AXIID+12];
    assign ARADDR  = Data_In[C_AXIADDR+C_AXIID+19:C_AXIID+20];
    assign ARID    = Data_In[(C_AXIADDR+(2*C_AXIID)+19):(C_AXIADDR+C_AXIID+20)];
    assign BREADY  = Data_In[(C_AXIADDR+(2*C_AXIID)+20)];
    assign BVALID  = Data_In[(C_AXIADDR+(2*C_AXIID)+21)];
    assign BRESP   = Data_In[(C_AXIADDR+(2*C_AXIID)+23):(C_AXIADDR+(2*C_AXIID)+22)];
    assign BID     = Data_In[(C_AXIADDR+(3*C_AXIID)+23):(C_AXIADDR+(2*C_AXIID)+24)];
    assign WREADY  = Data_In[(C_AXIADDR+(3*C_AXIID)+24)];
    assign WVALID  = Data_In[(C_AXIADDR+(3*C_AXIID)+25)];
    assign WLAST   = Data_In[(C_AXIADDR+(3*C_AXIID)+26)];
    assign WSTRB   = Data_In[(C_AXIADDR+(C_AXIDATA/8)+(3*C_AXIID)+26):(C_AXIADDR+(3*C_AXIID)+27)];
    assign AWREADY = Data_In[(C_AXIADDR+(C_AXIDATA/8)+(3*C_AXIID)+27)];
    assign AWVALID = Data_In[(C_AXIADDR+(C_AXIDATA/8)+(3*C_AXIID)+28)];
    assign AWBURST = Data_In[(C_AXIADDR+(C_AXIDATA/8)+(3*C_AXIID)+30):(C_AXIADDR+(C_AXIDATA/8)+(3*C_AXIID)+29)];
    assign AWSIZE  = Data_In[(C_AXIADDR+(C_AXIDATA/8)+(3*C_AXIID)+33):(C_AXIADDR+(C_AXIDATA/8)+(3*C_AXIID)+31)];
    assign AWLEN   = Data_In[(C_AXIADDR+(C_AXIDATA/8)+(3*C_AXIID)+41):(C_AXIADDR+(C_AXIDATA/8)+(3*C_AXIID)+34)];
    assign AWADDR  = Data_In[((2*C_AXIADDR)+(C_AXIDATA/8)+(3*C_AXIID)+41):(C_AXIADDR+(C_AXIDATA/8)+(3*C_AXIID)+42)];
    assign AWID    = Data_In[((2*C_AXIADDR)+(C_AXIDATA/8)+(4*C_AXIID)+41):((2*C_AXIADDR)+(C_AXIDATA/8)+(3*C_AXIID)+42)]; 
    assign TUSER   = 0; 
    assign TDEST   = 0;
    assign TID     = 0;
    assign TLAST   = 0;
    assign TKEEP   = 0;
    assign TSTRB   = 0;
    assign TREADY  = 0;
    assign TVALID  = 0;
    end
    endgenerate 

    generate if(C_AXI_PROTOCOL == "AXI4S") begin : GEN_AXI4S
    assign RREADY  = 0; 
    assign RVALID  = 0; 
    assign RLAST   = 0; 
    assign RRESP   = 0; 
    assign RID     = 0; 
    assign ARREADY = 0; 
    assign ARVALID = 0; 
    assign ARBURST = 0; 
    assign ARSIZE  = 0; 
    assign ARLEN   = 0; 
    assign ARADDR  = 0; 
    assign ARID    = 0; 
    assign BREADY  = 0; 
    assign BVALID  = 0; 
    assign BRESP   = 0; 
    assign BID     = 0; 
    assign WREADY  = 0; 
    assign WVALID  = 0; 
    assign WLAST   = 0; 
    assign WSTRB   = 0; 
    assign AWREADY = 0; 
    assign AWVALID = 0; 
    assign AWBURST = 0; 
    assign AWSIZE  = 0; 
    assign AWLEN   = 0; 
    assign AWADDR  = 0; 
    assign AWID    = 0;  
    assign TUSER   = Data_In[C_AXISUSER-1:0];
    assign TDEST   = Data_In[(C_AXISDEST+C_AXISUSER-1):(C_AXISUSER)];
    assign TID     = Data_In[(C_AXISID+C_AXISDEST+C_AXISUSER-1):(C_AXISUSER+C_AXISDEST)];
    assign TLAST   = Data_In[(C_AXISID+C_AXISDEST+C_AXISUSER)];
    assign TKEEP   = Data_In[((C_AXISDATA/8)+C_AXISID+C_AXISDEST+C_AXISUSER):(C_AXISID+C_AXISDEST+C_AXISUSER+1)];
    assign TSTRB   = Data_In[((2*(C_AXISDATA/8))+C_AXISID+C_AXISDEST+C_AXISUSER):((C_AXISDATA/8)+C_AXISID+C_AXISDEST+C_AXISUSER+1)];
    assign TREADY  = Data_In[((2*(C_AXISDATA/8))+C_AXISID+C_AXISDEST+C_AXISUSER+1)];
    assign TVALID  = Data_In[((2*(C_AXISDATA/8))+C_AXISID+C_AXISDEST+C_AXISUSER+2)];
    end
    endgenerate

    //AXI Memory map imp events capture 
    wire Wr_Addr_Lat = AWREADY & AWVALID & Data_Valid;
    wire Wr_Idle = WVALID & ~(WREADY) & Data_Valid;
    wire First_Write = WVALID & WREADY & ~(Write_going_on) & Data_Valid;
    wire First_Write_iss = WVALID & ~(Write_iss_going_on) & Data_Valid;
    wire Last_Write  = WLAST & WVALID & WREADY & Data_Valid;
    wire Response    = BVALID & BREADY & Data_Valid;
    wire Rd_Addr_Lat = ARREADY & ARVALID & Data_Valid;
    wire Rd_Idle     = RVALID & ~(RREADY) & Data_Valid;
    wire First_Read  = RVALID & RREADY & ~(Read_going_on) & Data_Valid;
    wire Last_Read   = RLAST & RVALID & RREADY & Data_Valid;
    wire Write_Beat  = WVALID & WREADY & Data_Valid;
    wire Read_Beat   = RVALID & RREADY & Data_Valid; 
    wire [C_METRIC_COUNT_WIDTH-1:0] rd_byte_cnt = C_AXIDATA/8;

  // Force WID/RID to 0 value from register interface if sub-protocol is
  // AXI4LITE
    wire [15:0] Latency_WID_l = (C_AXI_SUB_PROTOCOL == "AXI4LITE")? 16'h0: Latency_WID;
    wire [15:0] Latency_RID_l = (C_AXI_SUB_PROTOCOL == "AXI4LITE")? 16'h0: Latency_RID;
  // Id matching function calling for AWID, ARID, RID and BID
    wire awid_match     = id_matched(WID_Mask[C_AXIID-1:0],Latency_WID_l[C_AXIID-1:0],AWID_COMP);
    wire awid_match_lat = id_matched(WID_Mask[C_AXIID-1:0],Latency_WID_l[C_AXIID-1:0],AWID);
    wire arid_match     = id_matched(RID_Mask[C_AXIID-1:0],Latency_RID_l[C_AXIID-1:0],ARID_COMP);
    wire arid_match_lat = id_matched(RID_Mask[C_AXIID-1:0],Latency_RID_l[C_AXIID-1:0],ARID);
    wire rid_match_int  = id_matched(RID_Mask[C_AXIID-1:0],Latency_RID_l[C_AXIID-1:0],RID);
    wire bid_match      = id_matched(WID_Mask[C_AXIID-1:0],Latency_WID_l[C_AXIID-1:0],BID);
reg First_Write_d1;  
  /*------------------Registering Write metrics to pipeline along with wid_match-----*/
     always @(posedge clk) begin 
       if (rst_int_n == RST_ACTIVE) begin
          //Write_Beat_reg     <= 0;
          //Wr_Idle_reg        <= 0;
          //Last_Write_reg     <= 0;
          First_Write_reg    <= 0;
          First_Write_d1    <= 0;
          First_Read_reg     <= 0;
          Last_Read_reg      <= 0;
          //wr_byte_cnt_reg    <= 0;
          AWID_reg           <= 0;
          ARID_reg           <= 0;
          rid_match_reg      <= 0;
       end
       else begin
          //Write_Beat_reg     <= Write_Beat;
          //Wr_Idle_reg        <= Wr_Idle;
          //Last_Write_reg     <= Last_Write;
          First_Write_d1    <= First_Write;
          First_Write_reg    <= First_Write_d1;
          First_Read_reg     <= First_Read;
          Last_Read_reg      <= Last_Read;
          //wr_byte_cnt_reg    <= wr_byte_cnt;
          AWID_reg           <= AWID;
          ARID_reg           <= ARID;
          rid_match_reg      <= rid_match_int;
       end
     end
//K K START 
// New architecture for id based filtering calculation.
// Take 4 FIFOs: 
// F1: To store awid match/not match information
// F2: To store first write on write channel for each transaction.
// F3: Time stamp at latency start point
// F4: Time stamp at latency end   point
// How this works:
// Write to F1 awid match information when a Address detected
// Write to F2 when the first write on write channel detected
// Write to F3 when "latency start point" detected
// Write to F4 when "latency end   point" detected
// 
// Read F1&F2 when both are not empty
// Generate wid-match if Rd.data.F1 = 1 and Rd.data.F2 = 1
//  use this as qualifier to generate beat cnt,idle cnt, wlast cnt. 
//  Delay the corresponding beat,idle,wlast data based on above read.
//
// Read F3&F4 when both are not empty
//  use wid-match generated above to qualify if we need calculate latency
//  if(wid.match)
//    update min/max/total latency
//  else no update  
//

//F1
wire F1_Wr_En,F1_Rd_En;
wire F1_Wr_Data,F1_Rd_Data;
reg awid_match_d1;
assign F1_Wr_En   = Wr_Add_Issue & Metrics_Cnt_En_Int;//wr_latency_start; 
assign F1_Wr_Data = awid_match_d1 || ~(En_Id_Based);

 
    axi_perf_mon_v5_0_9_sync_fifo 
     #(
        .WIDTH      (1), 
        .DEPTH_LOG2 (5) 
     ) F1_AWID_MATCH
     (
       .rst_n    (rst_int_n),
       .clk      (clk),
       .wren     (F1_Wr_En   ),
       .rden     (F1_Rd_En   ),
       .din      (F1_Wr_Data ),
       .dout     (F1_Rd_Data ),
       .full     (           ),
       .empty    (F1_Empty   )
     );

//F2
wire F2_Wr_En,F2_Rd_En;
wire F2_Wr_Data,F2_Rd_Data;
//assign F2_Wr_En   = First_Write; 
assign F2_Wr_En   = First_Write_iss & Metrics_Cnt_En_Int; 
//assign F2_Wr_En   = Wr_Valid_Issue;//First_Write; 
assign F2_Wr_Data = 1'b1; 

 
    axi_perf_mon_v5_0_9_sync_fifo 
     #(
        .WIDTH      (1),
        .DEPTH_LOG2 (5)
     ) F2_FIRST_WRITE
     (
       .rst_n    (rst_int_n),
       .clk      (clk),
       .wren     (F2_Wr_En   ),
       .rden     (F2_Rd_En   ),
       .din      (F2_Wr_Data ),
       .dout     (F2_Rd_Data ),
       .full     (           ),
       .empty    (F2_Empty   )
     );

//Rd F1,F2 and generate Wid_match
wire F12_Rd_En;
assign F12_Rd_En = (F1_Empty == 1'b0) && (F2_Empty == 1'b0);
assign F1_Rd_En = F12_Rd_En;
assign F2_Rd_En = F12_Rd_En;

reg F12_Rd_Vld;
  always @(posedge clk) begin
    if (rst_int_n == RST_ACTIVE) begin
        F12_Rd_Vld <= 1'b0;
    end else begin
        F12_Rd_Vld <= F12_Rd_En;
    end
  end

reg wid_match_reg;
assign wid_match = (F12_Rd_Vld)? (F1_Rd_Data&F2_Rd_Data): wid_match_reg;
  always @(posedge clk) begin
    if (rst_int_n == RST_ACTIVE) begin
        wid_match_reg <= 1'b0;
    end else begin
        wid_match_reg <= wid_match;
    end
  end
//Delay Write_Beat,Wr_Idle,Last_Write based on above FIFOs read data
//availability
//
reg  Write_Beat_d1,Write_Beat_d2,Write_Beat_d3,Write_Beat_d4;
reg  Wr_Idle_d1,Wr_Idle_d2,Wr_Idle_d3,Wr_Idle_d4;
//reg  Last_Write_d1;
//,Last_Write_d2;
reg  [C_METRIC_COUNT_WIDTH-1:0] wr_byte_cnt_d1;
reg [C_METRIC_COUNT_WIDTH-1:0] wr_byte_cnt_d2;
reg [C_METRIC_COUNT_WIDTH-1:0] wr_byte_cnt_d3;
reg [C_METRIC_COUNT_WIDTH-1:0] wr_byte_cnt_d4;
reg  Last_Write_d1,Last_Write_d2,Last_Write_d3,Last_Write_d4,Last_Write_cnt2;
always @(posedge clk) begin
  if (rst_int_n == RST_ACTIVE) begin
      Write_Beat_d1  <= 1'b0;
      Write_Beat_d2  <= 1'b0;
      Write_Beat_d3  <= 1'b0;
      Write_Beat_d4  <= 1'b0;
      Write_Beat_reg <= 1'b0;
      Wr_Idle_d1     <= 1'b0;
      Wr_Idle_d2     <= 1'b0;
      Wr_Idle_d3     <= 1'b0;
      Wr_Idle_d4     <= 1'b0;
      Wr_Idle_reg    <= 1'b0;
      Last_Write_d1  <= 1'b0;
      Last_Write_d2  <= 1'b0;
      Last_Write_d3  <= 1'b0;
      Last_Write_d4  <= 1'b0;
      Last_Write_reg <= 1'b0;
      Last_Write_cnt2 <= 1'b0;
      wr_byte_cnt_d1 <= 1'b0;
      wr_byte_cnt_d2 <= 1'b0;
      wr_byte_cnt_d3 <= 1'b0;
      wr_byte_cnt_d4 <= 1'b0;
      wr_byte_cnt_reg <= 1'b0;
  end else begin
      Write_Beat_d1  <= Write_Beat;
      Write_Beat_d2  <= Write_Beat_d1;
      Write_Beat_d3  <= Write_Beat_d2;
      Write_Beat_d4  <= Write_Beat_d3;
      Write_Beat_reg <= Write_Beat_d4;
      Wr_Idle_d1     <= Wr_Idle;
      Wr_Idle_d2     <= Wr_Idle_d1;
      Wr_Idle_d3     <= Wr_Idle_d2;
      Wr_Idle_d4     <= Wr_Idle_d3;
      Wr_Idle_reg    <= Wr_Idle_d4;
      Last_Write_d1  <= Last_Write;
      Last_Write_d2  <= Last_Write_d1;
      Last_Write_d3  <= Last_Write_d2;
      Last_Write_d4  <= Last_Write_d3;
      Last_Write_reg <= Last_Write_d4;
      if(Wr_Lat_Start == 1'b0 && Wr_Lat_End == 1'b0)
      Last_Write_cnt2 <= Last_Write_d3;
      else
      Last_Write_cnt2 <= Last_Write_d4;
      wr_byte_cnt_d1 <= wr_byte_cnt;
      wr_byte_cnt_d2 <= wr_byte_cnt_d1;
      wr_byte_cnt_d3 <= wr_byte_cnt_d2;
      wr_byte_cnt_d4 <= wr_byte_cnt_d3;
      wr_byte_cnt_reg <= wr_byte_cnt_d4;
  end
end

//Latency Fifos
wire F3_Wr_En,F3_Rd_En;
reg F34_Rd_Vld;
wire F34_Rd_En;
//reg F3_Rd_En;
wire [C_METRIC_COUNT_WIDTH:0] F3_Wr_Data;
wire [C_METRIC_COUNT_WIDTH:0] F3_Rd_Data;
reg wr_latency_start_d1;//,awid_match_d1;
reg wr_latency_start_d2,awid_match_d2;
always @(posedge clk) begin
if (rst_int_n == RST_ACTIVE) begin
        wr_latency_start_d1 <= 1'b0;
        wr_latency_start_d2 <= 1'b0;
        awid_match_d1 <= 1'b0;
        awid_match_d2 <= 1'b0;
    end else begin
        wr_latency_start_d1 <= wr_latency_start;
        wr_latency_start_d2 <= wr_latency_start_d1;
        awid_match_d1 <= awid_match_lat;
        awid_match_d2 <= awid_match_d1;
    end
end
assign F3_Wr_En   = wr_latency_start_d2 & Metrics_Cnt_En_Int; 
assign F3_Wr_Data = {Write_Latency_Cnt_Ovf,Write_Latency_Cnt_Out}; 

 
    axi_perf_mon_v5_0_9_sync_fifo 
     #(
        .WIDTH      (C_METRIC_COUNT_WIDTH+1),
        .DEPTH_LOG2 (5)
     ) F3_WR_LAT_START
     (
       .rst_n    (rst_int_n),
       .clk      (clk),
       .wren     (F3_Wr_En   ),
       .rden     (F3_Rd_En   ),
       .din      (F3_Wr_Data ),
       .dout     (F3_Rd_Data ),
       .full     (           ),
       .empty    (F3_Empty   )
     );


wire F4_Wr_En,F4_Rd_En;
wire [C_METRIC_COUNT_WIDTH:0] F4_Wr_Data;
wire [C_METRIC_COUNT_WIDTH:0] F4_Rd_Data;
reg wr_latency_end_d1,wr_latency_end_d2;

always @(posedge clk) begin
if (rst_int_n == RST_ACTIVE) begin
        wr_latency_end_d1 <= 1'b0;
        wr_latency_end_d2 <= 1'b0;
    end else begin
        wr_latency_end_d1 <= wr_latency_end;
        wr_latency_end_d2 <= wr_latency_end_d1;
    end
end


//assign F4_Wr_En   = ((Wr_Lat_Start || Wr_Lat_End) == 1'b0)?wr_latency_end:wr_latency_end_d1; 
assign F4_Wr_En   = wr_latency_end_d2 & Metrics_Cnt_En_Int; 
assign F4_Wr_Data = {Write_Latency_Cnt_Ovf,Write_Latency_Cnt_Out}; 

 
    axi_perf_mon_v5_0_9_sync_fifo 
     #(
        .WIDTH      (C_METRIC_COUNT_WIDTH+1),
        .DEPTH_LOG2 (5)
     ) F4_WR_LAT_END
     (
       .rst_n    (rst_int_n),
       .clk      (clk),
       .wren     (F4_Wr_En   ),
       .rden     (F4_Rd_En   ),
       .din      (F4_Wr_Data ),
       .dout     (F4_Rd_Data ),
       .full     (           ),
       .empty    (F4_Empty   )
     );

//Rd F3,F4 and update latency if wid_matches 
assign F34_Rd_En = (F3_Empty == 1'b0) && (F4_Empty == 1'b0);
assign F3_Rd_En = F34_Rd_En;
assign F4_Rd_En = F34_Rd_En;

  always @(posedge clk) begin
    if (rst_int_n == RST_ACTIVE) begin
        F34_Rd_Vld <= 1'b0;
    end else begin
        F34_Rd_Vld <= F34_Rd_En;
    end
  end

//wire [C_METRIC_COUNT_WIDTH-1:0] Wr_Lat_Cnt_Diff;
reg update_min_Wr_Lat;
reg update_max_Wr_Lat;


//Below logic is for timing violation fix Wr_Lat_Cnt_Diff_reg F34_Rd_Vld_reg 
reg F34_Rd_Vld_reg; 
reg [C_METRIC_COUNT_WIDTH-1:0] Wr_Lat_Cnt_Diff_reg;
always @(posedge clk) begin
    if (rst_int_n == RST_ACTIVE) begin
      F34_Rd_Vld_reg       <= 0;
      Wr_Lat_Cnt_Diff_reg  <= 0;
    end else begin
      if(F34_Rd_Vld) begin
       if(F4_Rd_Data[C_METRIC_COUNT_WIDTH] ^ F3_Rd_Data[C_METRIC_COUNT_WIDTH]) begin
          if(F3_Rd_Data[C_METRIC_COUNT_WIDTH-1:0]>F4_Rd_Data[C_METRIC_COUNT_WIDTH-1:0]) begin
              Wr_Lat_Cnt_Diff_reg  <= (~(F3_Rd_Data[C_METRIC_COUNT_WIDTH-1:0]) + F4_Rd_Data[C_METRIC_COUNT_WIDTH-1:0])+1'b1;//:(F4_Rd_Data - F3_Rd_Data);;
          end else begin
              Wr_Lat_Cnt_Diff_reg <= (~F4_Rd_Data[C_METRIC_COUNT_WIDTH-1:0]) + F3_Rd_Data[C_METRIC_COUNT_WIDTH-1:0]+1'b1;
          end
      end
      else begin
        if(F3_Rd_Data[C_METRIC_COUNT_WIDTH-1:0]>F4_Rd_Data[C_METRIC_COUNT_WIDTH-1:0]) begin
             Wr_Lat_Cnt_Diff_reg  <= (F3_Rd_Data[C_METRIC_COUNT_WIDTH-1:0] - F4_Rd_Data[C_METRIC_COUNT_WIDTH-1:0]);//:(F4_Rd_Data - F3_Rd_Data);;
        end else begin
            Wr_Lat_Cnt_Diff_reg  <= F4_Rd_Data[C_METRIC_COUNT_WIDTH-1:0] - F3_Rd_Data[C_METRIC_COUNT_WIDTH-1:0];
        end
     end
    end
      F34_Rd_Vld_reg <= F34_Rd_Vld;
    end
  end
reg [C_METRIC_COUNT_WIDTH-1:0] Wr_Lat_Cnt_Diff_reg1;
reg F34_Rd_Vld_reg_d2,wid_match_reg_d2;
always @(posedge clk) begin
    if (rst_int_n == RST_ACTIVE) begin
      update_min_Wr_Lat    <= 0;
      update_max_Wr_Lat    <= 0;
      Wr_Lat_Cnt_Diff_reg1  <= 0;
    end else begin
      if(F34_Rd_Vld_reg) begin
       update_min_Wr_Lat    <= Wr_Lat_Cnt_Diff_reg < Min_Write_Latency_Int;
	    update_max_Wr_Lat    <= Wr_Lat_Cnt_Diff_reg > Max_Write_Latency_Int;
     end
     Wr_Lat_Cnt_Diff_reg1  <= Wr_Lat_Cnt_Diff_reg;
     F34_Rd_Vld_reg_d2 <= F34_Rd_Vld_reg;
     wid_match_reg_d2  <= wid_match_reg;
    end
end
  //Total wr.latency
  always @(posedge clk) begin
    if (rst_int_n == RST_ACTIVE) begin
        Write_Latency_Int <= 1'b0;
        Write_Latency_En_Int <= 1'b0;
    end else if(wid_match_reg_d2 == 1'b1 && F34_Rd_Vld_reg_d2) begin
        Write_Latency_Int <= Wr_Lat_Cnt_Diff_reg1;
        Write_Latency_En_Int <= Metrics_Cnt_En_Int;
    end else
        Write_Latency_En_Int <= 1'b0;
  end

//Min wr.latency
  always @(posedge clk) begin
    if (rst_int_n == RST_ACTIVE) begin
      Min_Write_Latency_Int    <= ALL_ONES;
    end else if(wid_match_reg_d2 == 1'b1 && F34_Rd_Vld_reg_d2 && update_min_Wr_Lat) begin
      Min_Write_Latency_Int    <= Wr_Lat_Cnt_Diff_reg1;
    end
  end

//Max wr.latency
  always @(posedge clk) begin
    if (rst_int_n == RST_ACTIVE) begin
      Max_Write_Latency_Int    <= 0;
    end else if(wid_match_reg_d2 == 1'b1 && F34_Rd_Vld_reg_d2 && update_max_Wr_Lat) begin
      Max_Write_Latency_Int    <= Wr_Lat_Cnt_Diff_reg1;
    end
  end

// K K END       
    // awid match latch for write transactions as there is no WID(No Interleaving support).
    // awid FIFO Instance to store outstanding transactions ID match
//commenting dead code - 22-07-2014 
   // Writing to FIFO when there is a write address latch

    // Write data byte counts for different data widths of the bus 

    generate if(C_AXIDATA == 8) begin : GEN_8BIT_BYTECNT
       assign wr_byte_cnt = {zeros[C_METRIC_COUNT_WIDTH-1:1],count(WSTRB,Data_Valid)}; 
    end
    endgenerate

    generate if(C_AXIDATA ==16) begin : GEN_16BIT_BYTECNT
       assign wr_byte_cnt = {zeros[C_METRIC_COUNT_WIDTH-1:2],count(WSTRB,Data_Valid)}; 
    end
    endgenerate

    generate if(C_AXIDATA == 32) begin : GEN_32BIT_BYTECNT
       assign wr_byte_cnt = {zeros[C_METRIC_COUNT_WIDTH-1:3],count_4(WSTRB,Data_Valid)}; 
    end
    endgenerate

    generate if(C_AXIDATA == 64) begin : GEN_64BIT_BYTECNT
       assign wr_byte_cnt = {zeros[C_METRIC_COUNT_WIDTH-1:4],count_8(WSTRB,Data_Valid)}; 
    end
    endgenerate

    generate if(C_AXIDATA == 128) begin : GEN_128BIT_BYTECNT
       assign wr_byte_cnt = {zeros[C_METRIC_COUNT_WIDTH-1:5],count_16(WSTRB,Data_Valid)}; 
    end
    endgenerate

    generate if(C_AXIDATA == 256) begin : GEN_256BIT_BYTECNT
       assign wr_byte_cnt = {zeros[C_METRIC_COUNT_WIDTH-1:6],count_32(WSTRB,Data_Valid)}; 
    end
    endgenerate

    generate if(C_AXIDATA == 512) begin : GEN_512BIT_BYTECNT
       assign wr_byte_cnt = {zeros[C_METRIC_COUNT_WIDTH-1:7],count_64(WSTRB,Data_Valid)}; 
    end
    endgenerate

    generate if(C_AXIDATA == 1024) begin : GEN_1024BIT_BYTECNT
       assign wr_byte_cnt = {zeros[C_METRIC_COUNT_WIDTH-1:8],count_128(WSTRB,Data_Valid)}; 
    end
    endgenerate
    
    //Latency start and end points selection based on control register
    //Write access done logic and registering address ID for identifying write address issue.
    //always @(posedge clk) begin
    //  if (rst_int_n == RST_ACTIVE) begin
    //     Write_access_done = 1'b0;
    //     Reg_AWID          = 0;
    //  end
    //  else begin
    //     Reg_AWID          = AWID;
    //    if (AWVALID == 1'b1 && AWREADY == 1'b1) begin
    //       Write_access_done = 1'b1;
    //    end
    //    else if ((AWVALID ^ AWREADY) == 1'b1) begin
    //       Write_access_done = 1'b0;
    //    end  
    //  end
    //end

    //Write address issuance logic
    always @(posedge clk) begin
      if (rst_int_n == RST_ACTIVE) begin
        Wr_Add_Issue <= 1'b0;
        No_Wr_Ready <= 1'b0;
      end
      else begin //if(Wr_Lat_Start == 1'b0) begin    // If address issue as start point 
        if(AWVALID == 1'b1 && AWREADY == 1'b1 && No_Wr_Ready == 1'b0 && Data_Valid == 1'b1) begin //Address issue&accept
          Wr_Add_Issue <= 1'b1;
          No_Wr_Ready <= 1'b0;
        end
        else if(AWVALID == 1'b1 && AWREADY == 1'b1 && No_Wr_Ready == 1'b1 && Data_Valid == 1'b1) begin//No_Wr_Readyreset
          Wr_Add_Issue <= 1'b0;
          No_Wr_Ready <= 1'b0;
        end
        else if(AWVALID == 1'b1 && AWREADY == 1'b0 && No_Wr_Ready == 1'b0 && Data_Valid == 1'b1)begin //Address issue
          Wr_Add_Issue <= 1'b1;
          No_Wr_Ready <=  1'b1;
        end
        else if(AWVALID == 1'b0 && Data_Valid == 1'b1) begin //No valid address
          Wr_Add_Issue <= 1'b0;
          No_Wr_Ready <=  1'b0;
        end
        else begin //This is to stop address issue assertion when there is no AWREADY
          Wr_Add_Issue <= 1'b0;  
          No_Wr_Ready <=  No_Wr_Ready;
        end
      end
    end  
 // Write valid issuance logic
//reg Wr_Valid_Issue,No_Write_Ready;
  always @(posedge clk) begin
      if (rst_int_n == RST_ACTIVE) begin
        Wr_Valid_Issue <= 1'b0;
        No_Write_Ready <= 1'b0;
      end
      else begin //if(Wr_Lat_Start == 1'b0) begin    // If address issue as start point 
        if(WVALID == 1'b1 && WREADY == 1'b1 && No_Write_Ready == 1'b0 && Data_Valid == 1'b1) begin //Address issue&accept
          Wr_Valid_Issue <= 1'b1;
          No_Write_Ready <= 1'b0;
        end
        else if(WVALID == 1'b1 && WREADY == 1'b1 && No_Write_Ready == 1'b1 && Data_Valid == 1'b1) begin//No_Write_Readyreset
          Wr_Valid_Issue <= 1'b0;
          No_Write_Ready <= 1'b0;
        end
        else if(WVALID == 1'b1 && WREADY == 1'b0 && No_Write_Ready == 1'b0 && Data_Valid == 1'b1)begin //Address issue
          Wr_Valid_Issue <= 1'b1;
          No_Write_Ready <=  1'b1;
        end
        else if(WVALID == 1'b0 && Data_Valid == 1'b1) begin //No valid address
          Wr_Valid_Issue <= 1'b0;
          No_Write_Ready <=  1'b0;
        end
        else begin //This is to stop address issue assertion when there is no WREADY
          Wr_Valid_Issue <= 1'b0;  
          No_Write_Ready <=  No_Write_Ready;
        end
      end
    end

    //Read address issuance logic
    always @(posedge clk) begin
      if (rst_int_n == RST_ACTIVE) begin
          Rd_Add_Issue <= 1'b0;
          No_Rd_Ready  <= 1'b0;
      end
      else if(Rd_Lat_Start == 1'b0) begin  //If address issue as start point
        if(ARVALID == 1'b1 && ARREADY == 1'b1 && No_Rd_Ready == 1'b0 && Data_Valid == 1'b1) begin //Address issue&accept
          Rd_Add_Issue <= 1'b1;
          No_Rd_Ready  <= 1'b0;
        end
      else if(ARVALID==1'b1 && ARREADY==1'b1 && No_Rd_Ready==1'b1 && Data_Valid==1'b1)begin//Resetting No_Rd_Ready 
          Rd_Add_Issue <= 1'b0;
          No_Rd_Ready  <=  1'b0;
        end
        else if(ARVALID == 1'b1 && ARREADY == 1'b0 && No_Rd_Ready == 1'b0 && Data_Valid == 1'b1)begin //Address issue 
          Rd_Add_Issue <= 1'b1;
          No_Rd_Ready  <=  1'b1;
        end
        else if(ARVALID == 1'b0 && Data_Valid == 1'b1) begin // No valid address
          Rd_Add_Issue <= 1'b0;
          No_Rd_Ready  <=  1'b0;
        end
        else begin 
          Rd_Add_Issue <= 1'b0;  //This is to stop address issue assertion when there is no ARREADY
          No_Rd_Ready  <= No_Rd_Ready;
        end
      end
      else begin
        Rd_Add_Issue <= 1'b0;
        No_Rd_Ready  <= 1'b0;
      end
    end  

    //Latency start and end points selection based on control register
    //Default latency calculation is from write/read address issue to last write/read
    assign wr_latency_start = Wr_Lat_Start?Wr_Addr_Lat:Wr_Add_Issue;
    assign First_Write_sel  = Wr_Lat_Start?First_Write:First_Write_d1; //reg;
    //assign Last_Write_sel   = Wr_Lat_Start?Last_Write:Last_Write_reg;
    assign Last_Write_sel   = Wr_Lat_Start?Last_Write:Last_Write_d1; 
    assign First_Read_sel  = Rd_Lat_Start?First_Read:First_Read_reg;
    assign Last_Read_sel   = Rd_Lat_Start?Last_Read:Last_Read_reg;
    assign wr_latency_end   = Wr_Lat_End?First_Write_sel:Last_Write_sel;
    assign rd_latency_start = Rd_Lat_Start?Rd_Addr_Lat:Rd_Add_Issue;
    assign rd_latency_end   = Rd_Lat_End?First_Read_sel:Last_Read_sel;
    wire [C_METRIC_COUNT_WIDTH-1:0] Latency_Load_value = ONE;
    assign AWID_COMP = Wr_Lat_Start?AWID:AWID_reg;
    assign ARID_COMP = Rd_Lat_Start?ARID:ARID_reg;
    wire rid_match = Rd_Lat_Start?rid_match_int:rid_match_reg;

    //-- Write_going_on for First_Write_Flag generation
    always @(posedge clk) begin 
       if (rst_int_n == RST_ACTIVE) begin
           Write_going_on <= 1'b0;
       end
       else begin
           if (Last_Write == 1'b1) begin
               Write_going_on <= 1'b0;
           end
           else if (First_Write == 1'b1)  begin
               Write_going_on <= 1'b1;
           end
           else begin
               Write_going_on <= Write_going_on;
           end
       end
    end 
//-- Write_going_on for First_Write_issuance_Flag generation
    always @(posedge clk) begin 
       if (rst_int_n == RST_ACTIVE) begin
           Write_iss_going_on <= 1'b0;
       end
       else begin
           if (Last_Write == 1'b1) begin
               Write_iss_going_on <= 1'b0;
           end
           else if (First_Write_iss == 1'b1)  begin
               Write_iss_going_on <= 1'b1;
           end
           else begin
               Write_iss_going_on <= Write_iss_going_on;
           end
       end
    end 

    //commenting dead code - 22-07-2014    
    //-- Write latency calculation based on AWID,BID
    //-- Id's are coming from register interface
//     always @(posedge clk) begin 
//       if(rst_int_n == RST_ACTIVE) begin
//           Wr_Latency_Fifo_Wr_En   <= 1'b0;
//           Wr_Latency_Fifo_Wr_Data <= 0;
//       end
//       else begin // Id filtering/ignoring 
//           if(wr_latency_start == 1'b1 && ((awid_match == 1'b1 && En_Id_Based == 1'b1) || En_Id_Based == 1'b0)) begin 
//              Wr_Latency_Fifo_Wr_En   <= ~ Wr_Latency_Fifo_Full;
//	      if(Wr_cnt_ld == 1'b1) begin
//                Wr_Latency_Fifo_Wr_Data <= ONE;
//              end
//	      else begin
//                Wr_Latency_Fifo_Wr_Data <= Write_Latency_Cnt_Out;
//              end
//           end
//           else begin
//              Wr_Latency_Fifo_Wr_En   <= 1'b0;
//              Wr_Latency_Fifo_Wr_Data <= Wr_Latency_Fifo_Wr_Data;
//           end
//       end
//    end

   // Reading the FIFO loaded with the count when write started 
//   always @(posedge clk) begin 
//       if(rst_int_n == RST_ACTIVE) begin
//           Wr_Latency_Fifo_Rd_En       <= 1'b0;
//           Wr_Latency_Fifo_Rd_En_D1    <= 1'b0;
//           Wr_Latency_Fifo_Rd_En_D2    <= 1'b0;
//           Write_Latency_Cnt_Out_D1    <= 0;  
//           Write_Latency_Cnt_Out_D2    <= 0;  
//           Write_Latency_One           <= 0;       //when write end comes with in one clock 
//           Write_Latency_One_D1        <= 0;
//           Wr_Latency_Fifo_Rd_Data_D1  <= 0;
//       end
//       else begin   // If ID based latency is set then only
//           Wr_Latency_Fifo_Rd_En_D1   <= Wr_Latency_Fifo_Rd_En;
//           Wr_Latency_Fifo_Rd_En_D2   <= Wr_Latency_Fifo_Rd_En_D1;
//           Write_Latency_Cnt_Out_D1   <= Write_Latency_Cnt_Out;  
//           Write_Latency_Cnt_Out_D2   <= Write_Latency_Cnt_Out_D1;  
//           Write_Latency_One_D1       <= Write_Latency_One && ~Wr_Latency_Fifo_Empty;
//           Wr_Latency_Fifo_Rd_Data_D1 <= Wr_Latency_Fifo_Rd_Data;
//           if(wr_latency_end==1'b1 && (((Wr_Id_Fifo_Rd_Data == 1'b1 || wid_match == 1'b1) 
//              && En_Id_Based == 1'b1) || En_Id_Based == 1'b0)) begin 
//              Wr_Latency_Fifo_Rd_En   <=  ~ Wr_Latency_Fifo_Empty;
//              Write_Latency_One       <=  Wr_Latency_Fifo_Empty;
//           end
//           else begin
//              Wr_Latency_Fifo_Rd_En  <= 1'b0;
//              Write_Latency_One      <= 0;
//           end
//       end
//    end
//    assign Wr_Latency_Fifo_Rd_En_out = Wr_Latency_Fifo_Rd_En |  Write_Latency_One_D1;
    

    // Write latency FIFO occupancy based on write and reads to FIFO
//    always @(posedge clk) begin 
//       if(rst_int_n == RST_ACTIVE) begin
//           Wr_Latency_Occupancy   <= 0;
//       end
//       else begin
//           if(wr_latency_start == 1'b1 && wr_latency_end == 1'b1 && 
//             ((awid_match == 1'b1 && En_Id_Based == 1'b1) || En_Id_Based == 1'b0)) begin
//              Wr_Latency_Occupancy   <= Wr_Latency_Occupancy;
//           end
//           else if(wr_latency_start==1'b1 && ((awid_match == 1'b1 && En_Id_Based ==1'b1) || En_Id_Based == 1'b0)) begin 
//              Wr_Latency_Occupancy   <= Wr_Latency_Occupancy + 1'b1;
//           end
//           else if(wr_latency_end == 1'b1 && Wr_Latency_Occupancy != 0 && 
//                  (((wid_match == 1'b1) &&
//                     En_Id_Based == 1'b1) || En_Id_Based == 1'b0)) begin
//              Wr_Latency_Occupancy   <= Wr_Latency_Occupancy - 1'b1;
//           end
//       end
//    end

     //-- WR latency FIFO Instance to store outstanding transactions
//    axi_perf_mon_v5_0_9_sync_fifo 
//     #(
//        .WIDTH      (C_METRIC_COUNT_WIDTH), // The width of the FIFO data
//        .DEPTH_LOG2 (5                   )  // Specify power-of-2 FIFO depth
//     ) wr_latency_fifo_inst
//     (
//       .rst_n    (rst_int_n),
//       .clk      (clk),
//       .wren     (Wr_Latency_Fifo_Wr_En),
//       .rden     (Wr_Latency_Fifo_Rd_En_out),
//       .din      (Wr_Latency_Fifo_Wr_Data),
//       .dout     (Wr_Latency_Fifo_Rd_Data),
//       .full     (Wr_Latency_Fifo_Full),
//       .empty    (Wr_Latency_Fifo_Empty)
//     );
    
    //-- Overflow capture of write latency counter for better timing  
    //To address overflow of the counter between Latency start and end `
    //always @(posedge clk) begin 
    //   if(rst_int_n == RST_ACTIVE) begin
    //      Write_Latency_Ovf <= 0;
    //   end
    //   else if(Wr_Latency_Fifo_Rd_En_D1 == 1'b1) begin
    //     if(Write_Latency_Cnt_Out_D1 < Wr_Latency_Fifo_Rd_Data) begin
    //        Write_Latency_Ovf <= 1'b1;
    //     end
    //     else begin  
    //        Write_Latency_Ovf <= 1'b0; 
    //     end
    //   end
    //end

    //-- Write latency capture from fifo read data with current counter value
    //-- TWO is for two clocks pipelining delay 1for Wr_Latency_Fifo_Rd_En_D2 and 1 for Write_Latency_Ovf 
//    always @(posedge clk) begin 
//       if(rst_int_n == RST_ACTIVE) begin
//         // Write_Latency_Int    <= 0;
//          Write_Latency_En_Int <= 0;
//       end
//       else begin
//          if(Write_Latency_One_D1 == 1'b1) begin
//           //   Write_Latency_Int    <= ONE;
//              Write_Latency_En_Int <= Metrics_Cnt_En_Int;
//          end
//          else if(Wr_Latency_Fifo_Rd_En_D2 == 1'b1) begin
//             Write_Latency_En_Int <= Metrics_Cnt_En_Int;
//             if(Write_Latency_Ovf == 1'b0) begin
//             //    Write_Latency_Int    <= Write_Latency_Cnt_Out_D2 - Wr_Latency_Fifo_Rd_Data_D1;
//             end
//             else begin  //To address overflow of the counter between Latency start and end 
//               //  Write_Latency_Int    <= ~(Wr_Latency_Fifo_Rd_Data_D1) +  Write_Latency_Cnt_Out_D2;
//             end
//          end
//          else begin
//           // Write_Latency_Int    <= Write_Latency_Int;
//            Write_Latency_En_Int <= 1'b0;
//          end
//       end
//    end

   assign Write_Latency    = Write_Latency_Int;     //Actual Latency
   assign Write_Latency_En = Write_Latency_En_Int; //Latency Valid
 reg Data_valid_reg,Data_valid_reg1,Data_valid_reg2;
 wire Data_valid_wire;
   always @(posedge clk) begin 
       if(rst_int_n == RST_ACTIVE) begin
          Data_valid_reg    <= 1'b0;
       end
       else begin
          Data_valid_reg    <= Data_Valid;
          Data_valid_reg1    <= Data_valid_reg;
          Data_valid_reg2    <= Data_valid_reg1;
       end
    end
  assign Data_valid_wire = Wr_Lat_Start?Data_valid_reg1:Data_valid_reg2;
  wire  Write_Lat_Cnt_en  = Metrics_Cnt_En_Int & Data_valid_wire; //Counter enable for ID based


    assign Min_Write_Latency = Min_Write_Latency_Int;

 
    assign Max_Write_Latency = Max_Write_Latency_Int;
    assign Wr_Latcnt_rst_n   = rst_int_n;
    assign Wr_cnt_ld           = ~(rst_int_n);

    //--Write latency counter
    //--Counter Instantiation
    //--This counter will be enabled only when id based latency is enabled
    axi_perf_mon_v5_0_9_counter_ovf 
    #(
         .C_FAMILY             ("nofamily"),
         .C_NUM_BITS           (C_METRIC_COUNT_WIDTH),
	      .COUNTER_LOAD_VALUE   (32'h00000000)
     ) wr_latency_cnt_inst 
     (
         .clk                  (clk),
         .rst_n                (Wr_Latcnt_rst_n),
         .Load_In              (Latency_Load_value),
         .Count_Enable         (Write_Lat_Cnt_en),
         .Count_Load           (Wr_cnt_ld),
         .Count_Down           (1'b0),
         .Count_Out            (Write_Latency_Cnt_Out),
         .Carry_Out            (Write_Latency_Cnt_Ovf)
     );


    //-- Read_going_on for First_Read_Flag generation
    //-- First read flag is only valid in case of id based latency
    always @(posedge clk) begin 
       if (rst_int_n == RST_ACTIVE) begin
           Read_going_on  <= 1'b0;
       end
       else begin
         if (Last_Read == 1'b1 && ((rid_match_int == 1'b1 && En_Id_Based == 1'b1) || En_Id_Based == 1'b0)) begin
             Read_going_on  <= 1'b0;
         end
         else if (First_Read == 1'b1 && ((rid_match_int == 1'b1 && En_Id_Based == 1'b1) || En_Id_Based == 1'b0)) begin 
             Read_going_on  <= 1'b1;
         end
         else begin
             Read_going_on  <= Read_going_on;
         end
       end
    end 

    //-- Read latency calculation based on ARID and RID's
    //-- Id's are coming from register interface
     always @(posedge clk) begin 
       if(rst_int_n == RST_ACTIVE) begin
           Rd_Latency_Fifo_Wr_En   <= 1'b0;
           Rd_Latency_Fifo_Wr_Data <= 0;
       end
       else begin   //ID Filtering/Masking/ignoring
           if(rd_latency_start == 1'b1 && ((arid_match == 1'b1 && En_Id_Based == 1'b1) || En_Id_Based == 1'b0)) begin
              Rd_Latency_Fifo_Wr_En   <= ~ Rd_Latency_Fifo_Full;
	     // if(Rd_cnt_ld == 1'b1) begin
        //        Rd_Latency_Fifo_Wr_Data <= ONE;
        //      end
	     // else begin
                Rd_Latency_Fifo_Wr_Data <= {Read_Latency_Cnt_Ovf,Read_Latency_Cnt_Out};
	     // end
           end
           else begin
              Rd_Latency_Fifo_Wr_En   <= 1'b0;
              Rd_Latency_Fifo_Wr_Data <= Rd_Latency_Fifo_Wr_Data;
           end
       end
    end

    // Reading the FIFO loaded with the count when read started 
   always @(posedge clk) begin 
       if(rst_int_n == RST_ACTIVE) begin
           Rd_Latency_Fifo_Rd_En      <= 1'b0;
           Rd_Latency_Fifo_Rd_En_D1   <= 1'b0;
           Rd_Latency_Fifo_Rd_En_D2   <= 1'b0;
           Read_Latency_Cnt_Out_D1    <= 0; 
           Read_Latency_Cnt_Out_D2    <= 0; 
           Read_Latency_One           <= 0;       //when read response comes with in one clock 
           Read_Latency_One_D1        <= 0;
           Rd_Latency_Fifo_Rd_Data_D1 <= 0;
       end
       else begin
           Rd_Latency_Fifo_Rd_En_D1   <= Rd_Latency_Fifo_Rd_En;
           Rd_Latency_Fifo_Rd_En_D2   <= Rd_Latency_Fifo_Rd_En_D1;
           Read_Latency_Cnt_Out_D1    <= {Read_Latency_Cnt_Ovf,Read_Latency_Cnt_Out}; 
           Read_Latency_Cnt_Out_D2    <= Read_Latency_Cnt_Out_D1; 
           Read_Latency_One_D1        <= Read_Latency_One & ~Rd_Latency_Fifo_Empty;
           Rd_Latency_Fifo_Rd_Data_D1 <= Rd_Latency_Fifo_Rd_Data;
           if(rd_latency_end == 1'b1 && ((rid_match == 1'b1 && En_Id_Based == 1'b1) || En_Id_Based == 1'b0)) begin
              Rd_Latency_Fifo_Rd_En   <=  ~Rd_Latency_Fifo_Empty;
              Read_Latency_One        <=   Rd_Latency_Fifo_Empty; 
           end
           else begin
              Rd_Latency_Fifo_Rd_En   <= 1'b0;
              Read_Latency_One        <= 0;    //when read response comes with in one clock 
           end
       end
    end

    assign Rd_Latency_Fifo_Rd_En_out = Rd_Latency_Fifo_Rd_En | Read_Latency_One_D1;

 //-- Rd latency FIFO Instance to store outstanding transactions
     axi_perf_mon_v5_0_9_sync_fifo 
     #(
        .WIDTH       (C_METRIC_COUNT_WIDTH+1), // The width of the FIFO data
        .DEPTH_LOG2  (5                   )  // Specify power-of-2 FIFO depth
     ) rd_latency_fifo_inst 
     (
       .rst_n    (rst_int_n),
       .clk      (clk),
       .wren     (Rd_Latency_Fifo_Wr_En & Metrics_Cnt_En_Int),
       .rden     (Rd_Latency_Fifo_Rd_En_out),
       .din      (Rd_Latency_Fifo_Wr_Data),
       .dout     (Rd_Latency_Fifo_Rd_Data),
       .full     (Rd_Latency_Fifo_Full),
       .empty    (Rd_Latency_Fifo_Empty)
     );
    
     // Read latency FIFO occupancy based on write and reads to FIFO
 //   always @(posedge clk) begin 
 //      if(rst_int_n == RST_ACTIVE) begin
 //          Rd_Latency_Occupancy   <= 0;
 //      end
 //      else begin
 //          if(rd_latency_start == 1'b1 && rd_latency_end == 1'b1 &&
 //            ((arid_match == 1'b1 && rid_match == 1'b1 && En_Id_Based == 1'b1) || En_Id_Based == 1'b0)) begin
 //            Rd_Latency_Occupancy   <= Rd_Latency_Occupancy;
 //          end
 //          else if(rd_latency_start==1'b1 && ((arid_match == 1'b1 && En_Id_Based == 1'b1) || En_Id_Based == 1'b0)) begin
 //             Rd_Latency_Occupancy   <= Rd_Latency_Occupancy + 1'b1;
 //          end
 //          else if(rd_latency_end == 1'b1 && ((rid_match == 1'b1 && En_Id_Based == 1'b1) || En_Id_Based == 1'b0)
 //                  && Rd_Latency_Occupancy != 0 ) begin 
 //             Rd_Latency_Occupancy   <= Rd_Latency_Occupancy - 1'b1;
 //          end
 //      end
 //   end

    //Overflow capture of read latency counter for better timing  
    //To address overflow of the counter between Latency start and end `
 //   always @(posedge clk) begin 
 //      if(rst_int_n == RST_ACTIVE) begin
 //         Read_Latency_Ovf <= 0;
 //      end
 //      else if(Rd_Latency_Fifo_Rd_En_D1 == 1'b1) begin
 //        if(Read_Latency_Cnt_Out_D1[C_METRIC_COUNT_WIDTH-1:0] < Rd_Latency_Fifo_Rd_Data[C_METRIC_COUNT_WIDTH-1:0]) begin
 //           Read_Latency_Ovf <= 1'b1;
 //        end
 //        else begin  
 //           Read_Latency_Ovf <= 1'b0; 
 //        end
 //      end
 //   end

    //Read latency capture from fifo read data with current counter value
    //-- TWO is for two clocks pipelining delay 1for Rd_Latency_Fifo_Rd_En_D2 and 1 for Read_Latency_Ovf 
    always @(posedge clk) begin 
       if(rst_int_n == RST_ACTIVE) begin
          Read_Latency_Int    <= 0;
          Read_Latency_En_Int <= 0;
       end
       else begin
          if(Read_Latency_One_D1 == 1'b1) begin
             Read_Latency_Int    <= ONE;
             Read_Latency_En_Int <= Metrics_Cnt_En_Int;
          end
          else if(Rd_Latency_Fifo_Rd_En_D1 == 1'b1) begin
         if(Read_Latency_Cnt_Out_D2[C_METRIC_COUNT_WIDTH] ^ Rd_Latency_Fifo_Rd_Data_D1[C_METRIC_COUNT_WIDTH]) begin
          if(Rd_Latency_Fifo_Rd_Data_D1[C_METRIC_COUNT_WIDTH-1:0] > Read_Latency_Cnt_Out_D2[C_METRIC_COUNT_WIDTH-1:0]) begin
              Read_Latency_Int  <= (~(Rd_Latency_Fifo_Rd_Data_D1[C_METRIC_COUNT_WIDTH-1:0]) + Read_Latency_Cnt_Out_D2[C_METRIC_COUNT_WIDTH-1:0])+1'b1;//:(F4_Rd_Data - F3_Rd_Data);;
          end else begin
              Read_Latency_Int <= (~Read_Latency_Cnt_Out_D2[C_METRIC_COUNT_WIDTH-1:0]) + Rd_Latency_Fifo_Rd_Data_D1[C_METRIC_COUNT_WIDTH-1:0]+1'b1;
          end
         end
        else begin
          if(Rd_Latency_Fifo_Rd_Data_D1[C_METRIC_COUNT_WIDTH-1:0] > Read_Latency_Cnt_Out_D2[C_METRIC_COUNT_WIDTH-1:0]) begin
             Read_Latency_Int  <= (Rd_Latency_Fifo_Rd_Data_D1[C_METRIC_COUNT_WIDTH-1:0] - Read_Latency_Cnt_Out_D2[C_METRIC_COUNT_WIDTH-1:0]);//:(F4_Rd_Data - F3_Rd_Data);;
          end else begin
            Read_Latency_Int  <= Read_Latency_Cnt_Out_D2[C_METRIC_COUNT_WIDTH-1:0] - Rd_Latency_Fifo_Rd_Data_D1[C_METRIC_COUNT_WIDTH-1:0];
          end
        end
                Read_Latency_En_Int <= Metrics_Cnt_En_Int;
        end
          else begin
            Read_Latency_Int    <= Read_Latency_Int;
            Read_Latency_En_Int <= 1'b0;
          end
       end
    end

    assign Read_Latency    = Read_Latency_Int;
    assign Read_Latency_En = Read_Latency_En_Int; 
 wire Read_Data_valid_wire;
  assign Read_Data_valid_wire = Rd_Lat_Start?Data_Valid:Data_valid_reg;
 
    wire Read_Lat_Cnt_en   = Metrics_Cnt_En_Int & Read_Data_valid_wire;

    //--Minimum read latency calculation
    //--Valid only for ID based latency
    always @(posedge clk) begin 
       if(rst_int_n == RST_ACTIVE) begin
          Min_Read_Latency_Int    <= ALL_ONES;
       end
       else begin
          if(Read_Latency_Int < Min_Read_Latency_Int && Read_Latency_En == 1'b1)begin
             Min_Read_Latency_Int    <= Read_Latency;
          end
          else begin
             Min_Read_Latency_Int    <= Min_Read_Latency_Int;
          end
       end
    end

    assign Min_Read_Latency = Min_Read_Latency_Int;

    //--Maximum read latency calculation
    //--Valid only for ID based latency
    always @(posedge clk) begin 
       if(rst_int_n == RST_ACTIVE) begin
          Max_Read_Latency_Int    <= 0;
       end
       else begin
          if(Read_Latency_Int > Max_Read_Latency_Int && Read_Latency_En == 1'b1)begin
             Max_Read_Latency_Int    <= Read_Latency;
          end
          else begin
             Max_Read_Latency_Int    <= Max_Read_Latency_Int;
          end
       end
    end
 
    assign Max_Read_Latency = Max_Read_Latency_Int;
    assign Rd_Latcnt_rst_n  = rst_int_n; 
    assign Rd_cnt_ld        = ~ (rst_int_n);//(|(Rd_Latency_Occupancy));

    //--Read latency counter
    //--Counter Instantiation
    axi_perf_mon_v5_0_9_counter_ovf 
    #(
         .C_FAMILY             ("nofamily"),
         .C_NUM_BITS           (C_METRIC_COUNT_WIDTH),
	      .COUNTER_LOAD_VALUE   (32'h00000000)
     ) rd_latency_cnt_inst 
     (
         .clk                  (clk),
         .rst_n                (Rd_Latcnt_rst_n),
         .Load_In              (Latency_Load_value),
         .Count_Enable         (Read_Lat_Cnt_en),
         .Count_Load           (Rd_cnt_ld),
         .Count_Down           (1'b0),
         .Count_Out            (Read_Latency_Cnt_Out),
         .Carry_Out            (Read_Latency_Cnt_Ovf)
     );

    /*------------------Registering all AXIMM metrics ------------------*/
    always @(posedge clk) begin 
       if (rst_int_n == RST_ACTIVE) begin
           Wtrans_Cnt_En     <= 1'b0;
           Rtrans_Cnt_En     <= 1'b0;
          // Write_Beat_Cnt_En <= 1'b0;
           Read_Beat_Cnt_En  <= 1'b0;
          // Slv_Wr_Idle_Cnt_En<= 1'b0;
           Mst_Rd_Idle_Cnt_En<= 1'b0; 
           Num_BValids_En    <= 1'b0;
           Num_RLasts_En     <= 1'b0;
         // Num_WLasts_En     <= 1'b0;
         // Write_Byte_Cnt    <= 0;
           Read_Byte_Cnt     <= 0; 
       end
       else begin
           Wtrans_Cnt_En     <=  Wr_Addr_Lat &  Metrics_Cnt_En_Int & ((awid_match_lat & En_Id_Based) || (~En_Id_Based));
           Rtrans_Cnt_En     <=  Rd_Addr_Lat &  Metrics_Cnt_En_Int & ((arid_match_lat & En_Id_Based) || (~En_Id_Based));
          // Write_Beat_Cnt_En <= Write_Beat_reg & Metrics_Cnt_En_Int & wid_match_reg_d2;// || Wr_Id_Fifo_Rd_Data) & En_Id_Based) || (~En_Id_Based));
           Read_Beat_Cnt_En  <= Read_Beat & Metrics_Cnt_En_Int & ((rid_match_int & En_Id_Based) || (~En_Id_Based));
          // Slv_Wr_Idle_Cnt_En<= Wr_Idle_reg & Metrics_Cnt_En_Int & wid_match_reg_d2;// & En_Id_Based) || (~En_Id_Based));
           Mst_Rd_Idle_Cnt_En<= Rd_Idle & Metrics_Cnt_En_Int & ((rid_match_int & En_Id_Based) || (~En_Id_Based)); 
           Num_BValids_En    <=  Response & Metrics_Cnt_En_Int & ((bid_match & En_Id_Based) || (~En_Id_Based));
          // Num_WLasts_En     <= Last_Write_reg & Metrics_Cnt_En_Int & wid_match_reg_d2;// || Wr_Id_Fifo_Rd_Data) & En_Id_Based) || (~En_Id_Based)); 
           Num_RLasts_En     <=  Last_Read & Metrics_Cnt_En_Int & ((rid_match_int & En_Id_Based) || (~En_Id_Based));
          // Write_Byte_Cnt    <= wr_byte_cnt_reg;
           Read_Byte_Cnt     <= rd_byte_cnt ; 
       end
    end
/*------------------Registering Beat Count metric  for all scenarios------------------*/
 reg [C_METRIC_COUNT_WIDTH-1:0] Write_Beat_Cnt_i;  
 reg [C_METRIC_COUNT_WIDTH-1:0] Write_Byte_Cnt_i;  
 reg Beat_fifo_Wr_en;  
 reg [(C_METRIC_COUNT_WIDTH*2)-1:0] Beat_fifo_Wr_data;  
 wire [(C_METRIC_COUNT_WIDTH*2)-1:0] FBC1_Rd_Data;  
 wire FBC1_Empty;  
 wire FBC_Empty;  
 wire FBC_Rd_Data;  
  always @(posedge clk) begin 
       if (rst_int_n == RST_ACTIVE) begin
           Write_Beat_Cnt_i     <= { {31{1'b0}}, 1'b1 };
           Write_Byte_Cnt_i     <= zeros;
           Beat_fifo_Wr_en <= 1'b0;
       end
       else begin
           if(Last_Write_d1) begin
           Beat_fifo_Wr_en <= 1'b1;
           Beat_fifo_Wr_data <= {(Write_Byte_Cnt_i+wr_byte_cnt_d1),Write_Beat_Cnt_i};
           Write_Byte_Cnt_i     <=  zeros;
           Write_Beat_Cnt_i     <=  { {31{1'b0}}, 1'b1 };
           end
           else if(Write_Beat_d1) begin
           Beat_fifo_Wr_en <= 1'b0;
           Write_Beat_Cnt_i     <=  Write_Beat_Cnt_i+1'b1;
           Write_Byte_Cnt_i     <=  Write_Byte_Cnt_i+wr_byte_cnt_d1;
          end
          else
           Beat_fifo_Wr_en <= 1'b0;
    end 
  end
    axi_perf_mon_v5_0_9_sync_fifo 
     #(
        .WIDTH      (C_METRIC_COUNT_WIDTH*2),
        .DEPTH_LOG2 (5)
     ) FBC_WR_BEAT_CNT
     (
       .rst_n    (rst_int_n),
       .clk      (clk),
       .wren     (Beat_fifo_Wr_en & Metrics_Cnt_En_Int ),
       .rden     (FBC_Rd_En   ),
       .din      (Beat_fifo_Wr_data ),
       .dout     (FBC1_Rd_Data ),
       .full     (           ),
       .empty    (FBC1_Empty   )
     );

//assign F1_Wr_En   = Wr_Add_Issue;//wr_latency_start; 
//assign F1_Wr_Data = awid_match_d1 || ~(En_Id_Based);
   axi_perf_mon_v5_0_9_sync_fifo 
     #(
        .WIDTH      (1), 
        .DEPTH_LOG2 (5) 
     ) BEAT_CNT_AWID_MATCH
     (
       .rst_n    (rst_int_n),
       .clk      (clk),
       .wren     (F1_Wr_En   ),
       .rden     (FBC_Rd_En   ),
       .din      (F1_Wr_Data ),
       .dout     (FBC_Rd_Data ),
       .full     (           ),
       .empty    (FBC_Empty   )
     );
assign FBC_Rd_En = (FBC1_Empty == 1'b0) && (FBC_Empty == 1'b0);

reg FBC_Rd_Vld;
  always @(posedge clk) begin
    if (rst_int_n == RST_ACTIVE) begin
        FBC_Rd_Vld <= 1'b0;
    end else begin
        FBC_Rd_Vld <= FBC_Rd_En;
    end
  end

assign Write_Beat_Cnt_En = (FBC_Rd_Vld)? FBC_Rd_Data: 1'b0;
assign Write_Beat_Cnt = (FBC_Rd_Vld)? FBC1_Rd_Data[C_METRIC_COUNT_WIDTH-1:0]: zeros;
assign Write_Byte_Cnt = (FBC_Rd_Vld)? FBC1_Rd_Data[(C_METRIC_COUNT_WIDTH*2)-1:C_METRIC_COUNT_WIDTH]: zeros;

 /*------------------Registering write last Count metric for all scenarios------------------*/
// reg Lw;  
 reg [C_METRIC_COUNT_WIDTH-1:0] Write_Last_Cnt_i;  
 reg Last_fifo_Wr_en;  
 wire FWL1_Rd_Data;  
 wire FWL1_Empty;  
 wire FWL_Empty;  
 wire FWL_Rd_Data;  
  always @(posedge clk) begin 
       if (rst_int_n == RST_ACTIVE) begin
           Last_fifo_Wr_en <= 1'b0;
       end
       else begin
          if(Last_Write) begin
           Last_fifo_Wr_en <= 1'b1;
           end
           else begin
           Last_fifo_Wr_en <= 1'b0;
           end
       end
    end 

    axi_perf_mon_v5_0_9_sync_fifo 
     #(
        .WIDTH      (1),
        .DEPTH_LOG2 (5)
     ) FWL_WR_LAST_CNT
     (
       .rst_n    (rst_int_n),
       .clk      (clk),
       .wren     (Last_fifo_Wr_en & Metrics_Cnt_En_Int ),
       .rden     (FWL_Rd_En   ),
       .din      (1'b1 ),
       .dout     (FWL1_Rd_Data ),
       .full     (           ),
       .empty    (FWL1_Empty   )
     );

//assign F1_Wr_En   = Wr_Add_Issue;//wr_latency_start; 
//assign F1_Wr_Data = awid_match_d1 || ~(En_Id_Based);
   axi_perf_mon_v5_0_9_sync_fifo 
     #(
        .WIDTH      (1), 
        .DEPTH_LOG2 (5) 
     ) LAST_CNT_AWID_MATCH
     (
       .rst_n    (rst_int_n),
       .clk      (clk),
       .wren     (F1_Wr_En   ),
       .rden     (FWL_Rd_En   ),
       .din      (F1_Wr_Data ),
       .dout     (FWL_Rd_Data ),
       .full     (           ),
       .empty    (FWL_Empty   )
     );
assign FWL_Rd_En = (FWL1_Empty == 1'b0) && (FWL_Empty == 1'b0);

reg FWL_Rd_Vld;
  always @(posedge clk) begin
    if (rst_int_n == RST_ACTIVE) begin
        FWL_Rd_Vld <= 1'b0;
    end else begin
        FWL_Rd_Vld <= FWL_Rd_En;
    end
  end

assign Num_WLasts_En = (FWL_Rd_Vld)? FWL_Rd_Data: 1'b0;
//assign Num_WLasts = (FWL_Rd_Vld)? FWL1_Rd_Data: zeros;

 /*------------------Registering Slave Write Idle Count metric  for all scenarios------------------*/
// reg Lw;  
 reg [C_METRIC_COUNT_WIDTH-1:0] Slv_Wr_Idle_Cnt_i;  
 reg [C_METRIC_COUNT_WIDTH-1:0] Slv_Wr_Idle_Fifo_Wr_data;  
 wire [C_METRIC_COUNT_WIDTH-1:0] FSWI1_Rd_Data;  
 wire FSWI1_Empty;  
 wire FSWI_Empty;  
 wire FSWI_Rd_Data;  
 reg Slv_Wr_Idle_Fifo_Wr_en;  
  always @(posedge clk) begin 
       if (rst_int_n == RST_ACTIVE) begin
           Slv_Wr_Idle_Cnt_i     <= zeros;//{ {31{1'b0}}, 1'b1 };
           Slv_Wr_Idle_Fifo_Wr_en <= 1'b0;
       end
       else begin
           if(Last_Write) begin
           Slv_Wr_Idle_Fifo_Wr_en <= 1'b1;
           Slv_Wr_Idle_Fifo_Wr_data <= Slv_Wr_Idle_Cnt_i;
           Slv_Wr_Idle_Cnt_i     <=  zeros;
           end
           else if(Wr_Idle) begin
           Slv_Wr_Idle_Fifo_Wr_en <= 1'b0;
           Slv_Wr_Idle_Cnt_i     <=  Slv_Wr_Idle_Cnt_i+1'b1;
           end
           else 
           Slv_Wr_Idle_Fifo_Wr_en <= 1'b0;
       end
    end 

    axi_perf_mon_v5_0_9_sync_fifo 
     #(
        .WIDTH      (C_METRIC_COUNT_WIDTH),
        .DEPTH_LOG2 (5)
     ) FSWI_WR_LAST_CNT
     (
       .rst_n    (rst_int_n),
       .clk      (clk),
       .wren     (Slv_Wr_Idle_Fifo_Wr_en & Metrics_Cnt_En_Int ),
       .rden     (FSWI_Rd_En   ),
       .din      (Slv_Wr_Idle_Fifo_Wr_data ),
       .dout     (FSWI1_Rd_Data ),
       .full     (           ),
       .empty    (FSWI1_Empty   )
     );

//assign F1_Wr_En   = Wr_Add_Issue;//wr_latency_start; 
//assign F1_Wr_Data = awid_match_d1 || ~(En_Id_Based);
   axi_perf_mon_v5_0_9_sync_fifo 
     #(
        .WIDTH      (1), 
        .DEPTH_LOG2 (5) 
     ) IDLE_CNT_AWID_MATCH
     (
       .rst_n    (rst_int_n),
       .clk      (clk),
       .wren     (F1_Wr_En   ),
       .rden     (FSWI_Rd_En   ),
       .din      (F1_Wr_Data ),
       .dout     (FSWI_Rd_Data ),
       .full     (           ),
       .empty    (FSWI_Empty   )
     );
assign FSWI_Rd_En = (FSWI1_Empty == 1'b0) && (FSWI_Empty == 1'b0);

reg FSWI_Rd_Vld;
  always @(posedge clk) begin
    if (rst_int_n == RST_ACTIVE) begin
        FSWI_Rd_Vld <= 1'b0;
    end else begin
        FSWI_Rd_Vld <= FSWI_Rd_En;
    end
  end

assign Slv_Wr_Idle_Cnt_En = (FSWI_Rd_Vld)? FSWI_Rd_Data: 1'b0;
assign Slv_Wr_Idle_Cnt = (FSWI_Rd_Vld)? FSWI1_Rd_Data: zeros;

    //-- AXI Streaming Imp Events generation 
    wire Stream_Write = TVALID & TREADY & Data_Valid;
    wire Stream_Last_Write  = TLAST & TVALID & TREADY & Data_Valid;
    wire Slave_Idle = TVALID & ~(TREADY) & Data_Valid;
    wire Master_Idle = ~(TVALID) & TREADY & Data_Valid; 
    wire [C_AXISDATA/8-1:0] data_strb = TSTRB & TKEEP;
    wire [C_AXISDATA/8-1:0] pos_strb = ~(TSTRB) & TKEEP;
    wire [C_AXISDATA/8-1:0] null_strb = ~(TSTRB) & ~(TKEEP);

     // Data, Postional and null byte counts for different widths of the streaming data bus 
    generate if(C_AXISDATA == 8 || C_AXISDATA == 16) begin : GEN_AXIS_BYTECNT
       assign data_byte_cnt =count(data_strb,Data_Valid);
       assign pos_byte_cnt  =count(pos_strb,Data_Valid);
       assign null_byte_cnt =count(null_strb,Data_Valid);
    end
    endgenerate

    generate if(C_AXISDATA == 32) begin : GEN_AXIS32BIT_BYTECNT
       assign data_byte_cnt ={zeros[C_METRIC_COUNT_WIDTH-1:3],count_4(data_strb,Data_Valid)};
       assign pos_byte_cnt  ={zeros[C_METRIC_COUNT_WIDTH-1:3],count_4(pos_strb,Data_Valid)};
       assign null_byte_cnt ={zeros[C_METRIC_COUNT_WIDTH-1:3],count_4(null_strb,Data_Valid)};
    end
    endgenerate

    generate if(C_AXISDATA == 64) begin : GEN_AXIS64BIT_BYTECNT
       assign data_byte_cnt ={zeros[C_METRIC_COUNT_WIDTH-1:4],count_8(data_strb,Data_Valid)};
       assign pos_byte_cnt  ={zeros[C_METRIC_COUNT_WIDTH-1:4],count_8(pos_strb,Data_Valid)};
       assign null_byte_cnt ={zeros[C_METRIC_COUNT_WIDTH-1:4],count_8(null_strb,Data_Valid)};
    end
    endgenerate

    generate if(C_AXISDATA == 128) begin : GEN_AXIS128BIT_BYTECNT
       assign data_byte_cnt ={zeros[C_METRIC_COUNT_WIDTH-1:5],count_16(data_strb,Data_Valid)};
       assign pos_byte_cnt  ={zeros[C_METRIC_COUNT_WIDTH-1:5],count_16(pos_strb,Data_Valid)};
       assign null_byte_cnt ={zeros[C_METRIC_COUNT_WIDTH-1:5],count_16(null_strb,Data_Valid)};
    end
    endgenerate

    generate if(C_AXISDATA == 256) begin : GEN_AXIS256BIT_BYTECNT
       assign data_byte_cnt ={zeros[C_METRIC_COUNT_WIDTH-1:6],count_32(data_strb,Data_Valid)};
       assign pos_byte_cnt  ={zeros[C_METRIC_COUNT_WIDTH-1:6],count_32(pos_strb,Data_Valid)};
       assign null_byte_cnt ={zeros[C_METRIC_COUNT_WIDTH-1:6],count_32(null_strb,Data_Valid)};
    end
    endgenerate

    generate if(C_AXISDATA == 512) begin : GEN_AXIS512BIT_BYTECNT
       assign data_byte_cnt ={zeros[C_METRIC_COUNT_WIDTH-1:7],count_64(data_strb,Data_Valid)};
       assign pos_byte_cnt  ={zeros[C_METRIC_COUNT_WIDTH-1:7],count_64(pos_strb,Data_Valid)};
       assign null_byte_cnt ={zeros[C_METRIC_COUNT_WIDTH-1:7],count_64(null_strb,Data_Valid)};

    end
    endgenerate

    generate if(C_AXISDATA == 1024) begin : GEN_AXIS1024BIT_BYTECNT
       assign data_byte_cnt ={zeros[C_METRIC_COUNT_WIDTH-1:8],count_128(data_strb,Data_Valid)};
       assign pos_byte_cnt  ={zeros[C_METRIC_COUNT_WIDTH-1:8],count_128(pos_strb,Data_Valid)};
       assign null_byte_cnt ={zeros[C_METRIC_COUNT_WIDTH-1:8],count_128(null_strb,Data_Valid)};
    end
    endgenerate

   
     /*------------------Registering all streaming metrics ------------------*/
    always @(posedge clk) begin 
       if (rst_int_n == RST_ACTIVE) begin
          S_Transfer_Cnt_En   <= 1'b0;
          S_Packet_Cnt_En     <= 1'b0;
          S_Slv_Idle_Cnt_En   <= 1'b0;
          S_Mst_Idle_Cnt_En   <= 1'b0;
          S_Data_Byte_Cnt     <= 0;
          S_Position_Byte_Cnt <= 0;
          S_Null_Byte_Cnt     <= 0;
       end
       else begin
          S_Transfer_Cnt_En   <= Stream_Write & Metrics_Cnt_En_Int;
          S_Packet_Cnt_En     <= Stream_Last_Write & Metrics_Cnt_En_Int;
          S_Slv_Idle_Cnt_En   <= Slave_Idle & Metrics_Cnt_En_Int;
          S_Mst_Idle_Cnt_En   <= Master_Idle & Metrics_Cnt_En_Int;
          S_Data_Byte_Cnt     <= data_byte_cnt;
          S_Position_Byte_Cnt <= pos_byte_cnt;
          S_Null_Byte_Cnt     <= null_byte_cnt;
       end
    end 


endmodule
