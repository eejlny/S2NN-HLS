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
// Filename     : axi_perf_mon_v5_0_9_async_stream_fifo.v
// Version      : v5.0
// Description  : This is the top level wrapper file for the asynchronous 
//                streaming fifo 
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
// --  axi_perf_mon.v
//      \-- axi_perf_mon_v5_0_9_async_stream_fifo.v
//-----------------------------------------------------------------------------
// Author:   NLR 
// History:    
// NLR       07/25/2012      First Version
// ^^^^^^
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module axi_perf_mon_v5_0_9_async_stream_fifo
  # (
    parameter C_FAMILY         = "nofamily",
    parameter C_FIFO_DEPTH     = 512, 
    parameter C_DATA_WIDTH     = 1024,
    parameter C_AXIS_DWIDTH_ROUND_TO_32     = 64,
    parameter C_USE_BLOCKMEM   = 1,   // 2 = Distributed RAM 1= Block RAM
    parameter C_COMMON_CLOCK   = 0,
    parameter C_LOG_DATA_OFFLD     = 0,//0- stream offload,1-Memorymap offload 
    parameter S_AXI_OFFLD_ID_WIDTH = 1, //offload interface ID width.
    parameter C_EN_TRIGGER         = 0 
    )
    (
    input                          Wr_clk,
    input                          Wr_rst_n,
    input                          fifo_wr_en,
    output                         fifo_rd_en,
    output reg [31:0]              eventlog_cur_cnt,
    output                         fifo_full_out,
    output                         fifo_empty_out,
    input [C_DATA_WIDTH-1:0]       Fifo_Data_In,
    input                          m_axis_aclk,
    input                          m_axis_aresetn,
    output                         m_axis_tvalid,
    input                          m_axis_tready,
    output[C_DATA_WIDTH-1:0]       m_axis_tdata,
    input                             s_axi_offld_aclk,
    input                             s_axi_offld_aresetn,
    input [31:0]                      s_axi_offld_araddr ,
    input                             s_axi_offld_arvalid,
    input [7:0]                       s_axi_offld_arlen  ,
    input [S_AXI_OFFLD_ID_WIDTH-1:0]  s_axi_offld_arid   ,    
    output                            s_axi_offld_arready,
    input                             s_axi_offld_rready ,
    output [31:0]                     s_axi_offld_rdata  ,
    output reg [1:0]                  s_axi_offld_rresp  ,
    output                            s_axi_offld_rvalid ,
    output [S_AXI_OFFLD_ID_WIDTH-1:0] s_axi_offld_rid    ,      
    output reg                        s_axi_offld_rlast  ,       
    input                       		  trigger
    );


   wire [31:0]              eventlog_cur_cnt_wire;
   wire m_axis_tready_int;
   wire rd_clk;
   wire rd_rstn;
   assign rd_clk  = (C_LOG_DATA_OFFLD == 0) ? m_axis_aclk : s_axi_offld_aclk;
   assign rd_rstn = (C_LOG_DATA_OFFLD == 0) ? m_axis_aresetn : s_axi_offld_aresetn;
   //-------------------- Parameter declarations-------------------------
     
    localparam RST_ACTIVE = 1'b0; 
    localparam [1:0] IDLE = 2'b00, WRITE_WAIT1 = 2'b01, WRITE = 2'b10;
    //---------------------------------------------------
    // for common clock dist FIFO:
    // C_COMMON_CLOCK = 1
    // C_IMPLEMENTATION_TYPE = 0
    // C_USE_BLOCKMEM = 2
    //---------------------------------------------------
    // for independent clock dist FIFO:
    // C_COMMON_CLOCK = 0
    // C_IMPLEMENTATION_TYPE = 2
    // C_USE_BLOCKMEM = 2
    //---------------------------------------------------
     // for common clock BRAM FIFO:
    // C_COMMON_CLOCK = 1
    // C_IMPLEMENTATION_TYPE = 0
    // C_USE_BLOCKMEM = 1
    //---------------------------------------------------
    // for independent clock BRAM FIFO:
    // C_COMMON_CLOCK = 0
    // C_IMPLEMENTATION_TYPE = 2
    // C_USE_BLOCKMEM = 1
    //---------------------------------------------------
 
    localparam IMP_TYPE = C_COMMON_CLOCK==1?0:2;
   //-------------------- Function to find log base 2 of FIFO_DEPTH
    function integer clogb2;
    input integer depth;   // Depth of fifo
    integer j;
      begin
        j = depth;
        for(clogb2=0; j>0; clogb2=clogb2+1)
           j = j >> 1;
      end
    endfunction
    localparam DATA_CNT_WIDTH = clogb2(C_FIFO_DEPTH)-1;
 
   //--------------------Register declarations---------------------------
    reg m_axis_tvalid_int;   
    reg fifo_empty_reg;
    wire [DATA_CNT_WIDTH-1:0] rd_data_count ;
  //-------------------- Wire declarations------------------------------
    //wire fifo_rd_en;
    wire fifo_empty;
    wire almost_empty;
    wire fifo_empty_fall;
    wire [C_DATA_WIDTH-1:0]  Sync_Data_Out;
    wire fifo_rst = ~Wr_rst_n | ~rd_rstn;
   wire  fifo_rd_en_with_trig;
   wire  drain_fifo_now;
   wire almost_full;

   // Event log fifo based on common clocks parameter either Sync/Async
   // Fifo is generated
   
    axi_perf_mon_v5_0_9_async_fifo
    #(
        .C_FAMILY             (C_FAMILY       ), 
        .C_FIFO_DEPTH         (C_FIFO_DEPTH   ), 
        .C_DATA_WIDTH         (C_DATA_WIDTH   ),
        .C_DATA_CNT_WIDTH     (DATA_CNT_WIDTH ),
        .C_FULL_FLAGS_RST     (0              ),//On reset fifo full value
        .C_USE_BLOCKMEM       (C_USE_BLOCKMEM ),
        .C_COMMON_CLOCK       (C_COMMON_CLOCK ),//Different clocks then this fifo is required  
        .C_IMPLEMENTATION_TYPE(IMP_TYPE       ),//Different clock BRAM/Distributed 
        .C_USE_FWFT           (1              ) //FWFT 
 
     )async_fifo_inst
     (
        .Din               (Fifo_Data_In            ),
        .Wr_en             (fifo_wr_en              ),
        .Wr_clk            (Wr_clk                  ),
        .Rd_en             (fifo_rd_en_with_trig    ),
        .Rd_clk            (rd_clk                  ),
        .fifo_rst          (fifo_rst                ), //active high
        .Dout              (Sync_Data_Out           ),
        .Full              (fifo_full               ),
        .wr_rst_busy       (wr_rst_busy             ),
        .Empty             (fifo_empty              ),
        .rd_data_count     (rd_data_count           ),
        .almost_full       (almost_full             ),
        .almost_empty      (almost_empty            )
     );

    assign fifo_full_out  = fifo_full & ~wr_rst_busy;
    assign fifo_empty_out = fifo_empty;


   // Fifo read enable generation
 //  assign fifo_rd_en = ~(fifo_empty) && m_axis_tready_int && m_axis_tvalid_int;

 //1. before trigger is asserted, drain fifo only when fifo is near full.
 //2. after trigger is asserted, drain fifo when axi is ready.    
   assign fifo_rd_en_with_trig = (C_EN_TRIGGER) ? ((trigger==1'b1) ? fifo_rd_en: drain_fifo_now) : fifo_rd_en;
   assign fifo_rd_en = ~(fifo_empty) && m_axis_tready_int && m_axis_tvalid_int;
   assign drain_fifo_now = almost_full;
   assign fifo_empty_fall = ~ fifo_empty && fifo_empty_reg;
   


  //-----------------AXI Streaming Master Interface logic--------------
   // M_AXIS_TVALID generation Logic 
   always @(posedge rd_clk     ) begin
      if(rd_rstn == RST_ACTIVE) begin
        m_axis_tvalid_int     <= 0;
        fifo_empty_reg        <= 0;
      end
      else begin
        fifo_empty_reg        <= fifo_empty;
        if(fifo_empty_fall || (almost_empty == 1'b0 && C_EN_TRIGGER)) begin 
          m_axis_tvalid_int   <=  1'b1;
        end
        else if(almost_empty == 1'b1 && m_axis_tready_int == 1'b1) begin 
          m_axis_tvalid_int    <=  1'b0;
        end
     end
   end

    wire [C_DATA_WIDTH-1:0]  m_axis_tdata_int;
  // m_axis_tvalid and m_axis_tdata output signal connections
generate if(C_LOG_DATA_OFFLD == 0 && C_EN_TRIGGER == 1) begin : TVALID_ON1 
   assign m_axis_tvalid     = m_axis_tvalid_int & trigger;
   assign m_axis_tdata      = Sync_Data_Out;
   assign m_axis_tdata_int  = {C_DATA_WIDTH{1'b0}};
end
endgenerate
//generate if(C_LOG_DATA_OFFLD == 1 && C_EN_TRIGGER == 1) begin : TVALID_OFF 
//   assign m_axis_tvalid     = 1'b0;
//   assign m_axis_tdata      = {C_DATA_WIDTH{1'b0}};
//   assign m_axis_tdata_int  = Sync_Data_Out;
//end
//endgenerate



   // m_axis_tvalid and m_axis_tdata output signal connections
generate if(C_LOG_DATA_OFFLD == 0 && C_EN_TRIGGER == 0) begin : TVALID_ON 
   assign m_axis_tvalid     = m_axis_tvalid_int;
   assign m_axis_tdata      = Sync_Data_Out;
   assign m_axis_tdata_int  = {C_DATA_WIDTH{1'b0}};
end
endgenerate
generate if(C_LOG_DATA_OFFLD == 1) begin : TVALID_OFF 
   assign m_axis_tvalid     = 1'b0;
   assign m_axis_tdata      = {C_DATA_WIDTH{1'b0}};
   assign m_axis_tdata_int  = Sync_Data_Out;
end
endgenerate

   //localparam C_AXIS_DWIDTH_ROUND_TO_32    = 64 ; //rounded to next 32-bit boundary
   localparam WORDS_IN_ENTRY = C_AXIS_DWIDTH_ROUND_TO_32/32  ; //number of 32-bit words in each FIFO entry
   localparam S_AXI_ADDRCODE = 32'h00000000  ; //read address to FIFO
  //-----------------AXI MM Slave Interface logic--------------
    //wire                                    s_axi_offld_aclk;
    //wire                                    s_axi_offld_aresetn;
    //reg   [15:0]                            s_axi_offld_araddr ;
    //reg                                     s_axi_offld_arvalid;
    //reg   [7:0]                             s_axi_offld_arlen  ;
    //reg  [S_AXI_OFFLD_ID_WIDTH-1:0]               s_axi_offld_arid   ;    
    //reg                                     s_axi_offld_rready ;
    //reg                                     s_axi_offld_arready;
    //wire   [31:0]                           s_axi_offld_rdata  ;
    //reg   [1:0]                             s_axi_offld_rresp  ;
    //wire                                    s_axi_offld_rvalid ;
    //wire   [S_AXI_OFFLD_ID_WIDTH-1:0]             s_axi_offld_rid    ;      
    //reg                                     s_axi_offld_rlast  ;      
   //TODO: remove 
   //assign s_axi_offld_aclk = m_axis_aclk;
   //assign s_axi_offld_aresetn = m_axis_aresetn;


  //common: WORDS_IN_ENTRY ==1 and WORDS_IN_ENTRY >1
   //fifo-status-qualifiers
   wire curr_fifo_oc_gt0 ;
   //reg [DATA_CNT_WIDTH+2-1:0] curr_fifo_oc ; //TODO: re-calculate Width of this signal 
   //intermediate qualifiers
   reg [1:0] buf_valid;
   //axi-mm qualifiers
   reg valid_rd_req;
   reg [8:0] rd_cnt; 
   wire rd_cnt_not0;
   reg  rd_dphase ; 
   wire rd_aphase ;
   wire rd_chidle ;

   //rd.data.cnt calculation
   wire [1:0] rd_cnt_offset;
   assign rd_cnt_offset  = (fifo_empty)?(2'b00) :
                           (almost_empty ? 2'b01: 2'b10);
   assign eventlog_cur_cnt_wire = rd_data_count + buf_valid[0] + buf_valid[1]+ rd_cnt_offset;

   always @(posedge rd_clk     ) begin
     if(rd_rstn == RST_ACTIVE) begin
      eventlog_cur_cnt <= 32'b0;
     end
     else begin
      eventlog_cur_cnt <= eventlog_cur_cnt_wire;
     end
 end

   //reg [31:0] eventlog_cnt_i;
   //reg [31:0] eventlog_cnt_i_d1;
   //reg [31:0] eventlog_cur_cnt_d1;
   //always @(posedge rd_clk     ) begin
   //  if(rd_rstn == RST_ACTIVE) begin
   //    eventlog_cnt_i    <= 32'h0;
   //    eventlog_cnt_i_d1 <= 32'h0;
   //    eventlog_cur_cnt_d1 <= 32'h0;
   //  end else begin
   //    eventlog_cnt_i <= rd_data_count + buf_valid[0] + buf_valid[1]+ rd_cnt_offset;
   //    eventlog_cnt_i_d1 <= eventlog_cnt_i;
   //    eventlog_cur_cnt_d1 <= eventlog_cur_cnt;
   //  end
   //end
   //assign eventlog_cur_cnt = (eventlog_cnt_i == eventlog_cnt_i_d1)?
   //                           eventlog_cnt_i: eventlog_cur_cnt_d1;
  //
  //arready generation
  //
   assign rd_chidle = ~rd_aphase &  ~rd_dphase;
   assign curr_fifo_oc_gt0 = ~fifo_empty | buf_valid[0];
   reg s_axi_offld_arready_i;
   always @(posedge rd_clk     ) begin
     if(rd_rstn == RST_ACTIVE) begin
       s_axi_offld_arready_i <= 1'b0;
     end else if(~s_axi_offld_arvalid & s_axi_offld_arready_i) begin
       s_axi_offld_arready_i <= s_axi_offld_arready_i;
     end else if(s_axi_offld_arvalid & s_axi_offld_arready_i) begin
       s_axi_offld_arready_i <= 1'b0;
     end else if(rd_chidle & curr_fifo_oc_gt0)begin
       s_axi_offld_arready_i <= 1'b1;
     end
   end
   //ID reflection.
   reg [S_AXI_OFFLD_ID_WIDTH-1:0] aid;
   always @(posedge rd_clk     ) begin
     if(rd_rstn == RST_ACTIVE) begin
       aid <= {S_AXI_OFFLD_ID_WIDTH{1'b0}};
     end else if(s_axi_offld_arvalid & s_axi_offld_arready ) begin 
       aid <= s_axi_offld_arid;
     end
   end
   assign s_axi_offld_rid = aid;
  //
  //channel status: address phase- rd_aphase, data phase- rd_dphase
  //
   assign rd_aphase = s_axi_offld_arready;
   always @(posedge rd_clk     ) begin
     if(rd_rstn == RST_ACTIVE) begin
       rd_dphase <= 1'b0;
     end else if (s_axi_offld_arvalid & s_axi_offld_arready) begin
       rd_dphase <= 1'b1;
     end else if(s_axi_offld_rvalid & s_axi_offld_rready & s_axi_offld_rlast) begin
       rd_dphase <= 1'b0;
     end
   end
   //
   //cnt no.of beats trnasferred
   //
   assign rd_cnt_not0 = ( rd_cnt != 9'h0);
   always @(posedge rd_clk     ) begin
     if(rd_rstn == RST_ACTIVE) begin
       rd_cnt <= 9'h0;
     end else if(s_axi_offld_arvalid & s_axi_offld_arready) begin
       rd_cnt <= s_axi_offld_arlen;
     end else if(s_axi_offld_rvalid & s_axi_offld_rready) begin
       rd_cnt <= rd_cnt - rd_cnt_not0;
     end
   end
   //
   //rlast generation:
   //
   always @(posedge rd_clk     ) begin
      if(rd_rstn == RST_ACTIVE) begin
        s_axi_offld_rlast <= 1'b0;
      end else if(s_axi_offld_rvalid & ~s_axi_offld_rready) begin
        s_axi_offld_rlast <= s_axi_offld_rlast;
      end else if(s_axi_offld_rvalid & s_axi_offld_rready & s_axi_offld_rlast) begin
        s_axi_offld_rlast <= 1'b0;
      end else if(s_axi_offld_arvalid & s_axi_offld_arready & (s_axi_offld_arlen == 8'h0)) begin
        s_axi_offld_rlast <= 1'b1;
      end else if(s_axi_offld_rvalid & s_axi_offld_rready & (rd_cnt == 9'h1)) begin
        s_axi_offld_rlast <= 1'b1;
      end
   end

   //qualify read request: error_condition
   //error conditions
   //current fifo occupancy < Length
   //ARADDR not valid
   //ARLEN not aligned
   wire invalid_occupancy;
   wire invalid_addr;
   wire invalid_arlen;
   wire error_condition ;

   //assign invalid_occupancy = (curr_fifo_oc < (s_axi_offld_arlen + 8'h1)) | ((fifo_empty & buf_valid == 2'b00));
   assign invalid_occupancy = ((fifo_empty & buf_valid == 2'b00));
   assign invalid_addr      = 1'b0;//s_axi_offld_araddr != S_AXI_ADDRCODE;
   assign invalid_arlen     = 1'b0;//s_axi_offld_arlen[0] == 1'b0; //TODO:ARLEN should be multiple of WORDS_IN_ENTRY
   wire launch_erresp_data =  invalid_occupancy & rd_dphase; //add time-out condiftion if necessary

   assign error_condition = invalid_occupancy | invalid_addr | invalid_arlen;
   always @(posedge rd_clk     ) begin
      if(rd_rstn == RST_ACTIVE) begin
        s_axi_offld_rresp <= 2'b00;
      end else if(s_axi_offld_rvalid & s_axi_offld_rready & s_axi_offld_rlast) begin
        s_axi_offld_rresp <= 2'b00;
      end else if(s_axi_offld_rvalid & s_axi_offld_rready ) begin
        if(launch_erresp_data) begin  //ie,launch_erresp_data as rvld & rrdy confirms dphase
          s_axi_offld_rresp <= 2'b10;
        end else begin
          s_axi_offld_rresp <= 2'b00;
        end
      end else if(s_axi_offld_rvalid & ~s_axi_offld_rready) begin
        s_axi_offld_rresp <= s_axi_offld_rresp;
      end else if(s_axi_offld_arvalid & s_axi_offld_arready) begin
        if(error_condition) begin
          s_axi_offld_rresp <= 2'b10;
        end else begin
          s_axi_offld_rresp <= 2'b00;
        end 
      end
   end
  
   //chk that the req is valid(like arlen > fifo occupency
   // arlen in multimples of FIFO DWIDTH etc.,
   always @(posedge rd_clk     ) begin
     if(rd_rstn == RST_ACTIVE) begin
       valid_rd_req <= 1'b0;
     end else if(s_axi_offld_rvalid & s_axi_offld_rready & s_axi_offld_rlast) begin
       valid_rd_req <= 1'b0;
     end else if(s_axi_offld_arvalid & s_axi_offld_arready ) begin
       if(error_condition) begin
         valid_rd_req <= 1'b0;
       end else begin
         valid_rd_req <= 1'b1;
       end
     end
   end

   //1-deep buffer
   //always @(posedge s_axi_offld_aclk) begin
   //  if(s_axi_offld_aresetn == RST_ACTIVE) begin
   //    buf_valid[1:0] <= 2'b00;   
   //    buf_data[0] <= {C_AXIS_DWIDTH_ROUND_TO_32{1'b0}};
   //    buf_data[1] <= {C_AXIS_DWIDTH_ROUND_TO_32{1'b0}};
   //  end else if(buf_valid[0] & addr_train[WORDS_IN_ENTRY-1]& valid_rd_req & data_sampled & (WORDS_IN_ENTRY >1)) begin
   //      buf_valid[0] <= 1'b0;
   //  end else if(buf_valid[0] & addr_train[WORDS_IN_ENTRY-1]& valid_rd_req & buffer_valid & ~buffer_valid_d1 & (WORDS_IN_ENTRY ==1)) begin
   //      buf_valid[0] <= 1'b0;
   //  end else if((buf_valid[0] == 1'b0)&(m_axis_tvalid)) begin
   //      buf_valid[0] <= 1'b1;
   //      buf_data[0]  <= m_axis_tdata;
   //  end
   //end
  //TREADY MUXING to Internal FIFO
  generate if(C_LOG_DATA_OFFLD == 0) begin : STRM_OFFLD
    assign m_axis_tready_int = m_axis_tready;
  end
  endgenerate
  //generate if(C_LOG_DATA_OFFLD == 1 & WORDS_IN_ENTRY == 1) begin : MM_OFFLD_EQ1
  //  //pass s_axi_offld_rready to m_axis_tready_int if its a valid rd req
  //  assign m_axis_tready_int = rd_dphase & valid_rd_req ? s_axi_offld_rready : 1'b0;
  //end
  //endgenerate
  generate if(C_LOG_DATA_OFFLD == 1 & WORDS_IN_ENTRY > 1) begin : MM_OFFLD_GT1
    assign m_axis_tready_int = (buf_valid[0] == 1'b0) | (buf_valid[1] == 1'b0) ;
  end
  endgenerate

  //generate if(WORDS_IN_ENTRY == 1 && C_LOG_DATA_OFFLD == 1) begin :WORDS_EQ_1
  ////WORDS_IN_ENTRY == 1 case(data width is 32-bit)
  ////In this case no conversion required, data from FIFO 
  ////can be sent on AXIMM-32 bit
  //  
  //assign s_axi_offld_rvalid  = (rd_dphase & valid_rd_req) ? (m_axis_tvalid) :
  //                       ((rd_dphase & ~valid_rd_req) ? 1'b1 : 1'b0);
  //assign s_axi_offld_rdata   = m_axis_tdata;
  // always @(posedge s_axi_offld_aclk) begin
  //     buf_valid[1:0] <= 2'b00;   
  // end
  //end
  //endgenerate
//generate if(WORDS_IN_ENTRY > 1 && C_LOG_DATA_OFFLD == 1) begin :WORDS_GT_1
  //WORDS_IN_ENTRY > 1 case(data width is  > 32-bit)
  //Conversion of data to 32-bit data is required.
  //buffer qualifiers
   reg [C_AXIS_DWIDTH_ROUND_TO_32-1:0] buf_data[1:0];
   reg [WORDS_IN_ENTRY:0] addr_train; 
   reg [7:0] addr_train_index;
   wire load_buf_data;
   wire buffer_valid;
   reg nxt_data_valid_d1;

   //sample conditions
   wire data_sampled = s_axi_offld_rvalid & s_axi_offld_rready;
   wire last_sampled = s_axi_offld_rvalid & s_axi_offld_rready & s_axi_offld_rlast;
   wire launch_rdata = (buffer_valid ) & rd_dphase;
   wire nxt_data_valid = buffer_valid & valid_rd_req;
   wire launched_new_data = (data_sampled & ~last_sampled)|((nxt_data_valid & ~nxt_data_valid_d1)) ;

  //-copy tdata to internal buffer.
   //2-deep buffer
   always @(posedge rd_clk     ) begin
     if(rd_rstn == RST_ACTIVE) begin
       buf_valid[1:0] <= 2'b00;   
       buf_data[0] <= {C_AXIS_DWIDTH_ROUND_TO_32{1'b0}};
       buf_data[1] <= {C_AXIS_DWIDTH_ROUND_TO_32{1'b0}};
     end else if(buf_valid[0] & addr_train[WORDS_IN_ENTRY-1]& valid_rd_req & data_sampled & (WORDS_IN_ENTRY >1)) begin
         if(buf_valid[1]) begin
           buf_valid[0] <= buf_valid[1];
           buf_data[0] <= buf_data[1];
           if(m_axis_tvalid_int & m_axis_tready_int) begin //another sampl avlbl
             buf_valid[1] <= 1'b1;
             buf_data[1]  <= m_axis_tdata_int;
           end else begin
             buf_valid[1] <= 1'b0;
           end
         end else begin
           if(m_axis_tvalid_int & m_axis_tready_int) begin //another sampl avlbl
             buf_valid[0] <= 1'b1;
             buf_data[0]  <= m_axis_tdata_int;
           end else begin
             buf_valid[0] <= 1'b0;
           end
         end
     end else if((buf_valid[0] == 1'b0)&(m_axis_tvalid_int & m_axis_tready_int)) begin
         buf_valid[0] <= 1'b1;
         buf_data[0]  <= m_axis_tdata_int;
     end else if((buf_valid[1] == 1'b0)&(m_axis_tvalid_int & m_axis_tready_int)) begin
         buf_valid[1] <= 1'b1;
         buf_data[1]  <= m_axis_tdata_int;
     end
   end

  
  wire req_pend;
  //address indicator
  assign req_pend = (|(rd_cnt+1'b1) ) & rd_dphase ;
  //assign load_buf_data = (s_axi_offld_arready | req_pend) & buf_valid[0] & (addr_train[WORDS_IN_ENTRY]);
  assign load_buf_data = (s_axi_offld_arready | (req_pend & ~(s_axi_offld_rvalid & ~s_axi_offld_rready))) & ( (buf_valid[0] & addr_train[WORDS_IN_ENTRY]) |(buf_valid[1] & addr_train[WORDS_IN_ENTRY-1]));
  assign buffer_valid   = |(addr_train[WORDS_IN_ENTRY-1:0]);

  wire [C_AXIS_DWIDTH_ROUND_TO_32-1:0] data2tx;
  wire [31:0] data2txi[WORDS_IN_ENTRY:0];
   //1-deep buffer
   //always @(posedge s_axi_offld_aclk) begin
   //   if(s_axi_offld_aresetn == RST_ACTIVE) begin
   //     addr_train[WORDS_IN_ENTRY-1:0] <= {WORDS_IN_ENTRY{1'b0}};
   //     addr_train[WORDS_IN_ENTRY] <= 1'b1;
   //   end else if (load_buf_data) begin
   //     addr_train[WORDS_IN_ENTRY:1] <= {WORDS_IN_ENTRY{1'b0}};
   //     addr_train[0] <= 1'b1;
   //   end else if (addr_train[WORDS_IN_ENTRY]) begin //wait till next load.
   //     addr_train <= addr_train;
   //   end else if (launched_new_data & valid_rd_req) begin
   //     addr_train <= {addr_train[WORDS_IN_ENTRY-1:0],addr_train[WORDS_IN_ENTRY]};
   //   end else begin
   //   end
   //end
   //2-deep buffer
   always @(posedge rd_clk     ) begin
      if(rd_rstn == RST_ACTIVE) begin
        addr_train[WORDS_IN_ENTRY-1:0] <= {WORDS_IN_ENTRY{1'b0}};
        addr_train[WORDS_IN_ENTRY] <= 1'b1;
        addr_train_index <= 7'h0;
      end else if (load_buf_data) begin
        addr_train[WORDS_IN_ENTRY:1] <= {WORDS_IN_ENTRY{1'b0}};
        addr_train[0] <= 1'b1;
        addr_train_index <= 7'h0;
      end else if (addr_train[WORDS_IN_ENTRY]) begin //wait till next load.
        addr_train <= addr_train;
        addr_train_index <= addr_train_index;
      end else if (launched_new_data & valid_rd_req & ~launch_erresp_data) begin
        addr_train <= {addr_train[WORDS_IN_ENTRY-1:0],addr_train[WORDS_IN_ENTRY]};
        addr_train_index <= addr_train_index + 1'b1;
      end else begin
        addr_train <= addr_train;
      end
   end

   assign  data2tx = buf_data[0];
   //slice buf_data as 2-d array with 32b data in each entry 
   assign  data2txi[WORDS_IN_ENTRY] = 32'h0;
   genvar i;
   generate
   for (i=0; i<WORDS_IN_ENTRY; i=i+1) begin : DATA2TX_SLICE 
      assign  data2txi[i] = buf_data[0][i*32+31:i*32];
   end
   endgenerate  
   wire [31:0] rdata_i;
   assign rdata_i = data2txi[addr_train_index];
   //place rdata onto interface :WORDS_IN_ENTRY =2
   reg [31:0] s_axi_offld_rdata_i;

   always @(posedge rd_clk     ) begin
      if(rd_rstn == RST_ACTIVE) begin
        s_axi_offld_rdata_i <= 32'h0;
      end else if(s_axi_offld_rvalid & ~s_axi_offld_rready) begin
        s_axi_offld_rdata_i <= s_axi_offld_rdata_i;
      end else begin
        s_axi_offld_rdata_i <= rdata_i;
        //if(addr_train[0]) begin
        //  s_axi_offld_rdata_i <= data2tx[31:0];
        //end else if(addr_train[1]) begin
        //  s_axi_offld_rdata_i <= data2tx[63:32];
        //end
      end
   end
   reg s_axi_offld_rvalid_i; 
   always @(posedge rd_clk     ) begin
      if(rd_rstn == RST_ACTIVE) begin
        s_axi_offld_rvalid_i <= 1'b0;
      end else if(s_axi_offld_rvalid_i & s_axi_offld_rready & s_axi_offld_rlast) begin
        s_axi_offld_rvalid_i <= 1'b0;
      end else if(s_axi_offld_rvalid_i & ~s_axi_offld_rready) begin
        s_axi_offld_rvalid_i <= s_axi_offld_rvalid_i;
      end else begin
        if(launch_erresp_data) begin //FIFO is empty but axi req is incomplete.
          s_axi_offld_rvalid_i <= 1'b1;
        end else if(addr_train[WORDS_IN_ENTRY]) begin //all contents of buffer are sent.
          s_axi_offld_rvalid_i <= 1'b0;
        end else if(launch_rdata)begin
          s_axi_offld_rvalid_i <= 1'b1;
        end
      end
   end
   assign s_axi_offld_rvalid = s_axi_offld_rvalid_i;
  //delayed signal generators.
  always @(posedge rd_clk     ) begin
    if(rd_rstn == RST_ACTIVE) begin
      nxt_data_valid_d1 <= 1'b0;
    end else begin
      nxt_data_valid_d1 <= nxt_data_valid;
    end
  end
//end
//endgenerate
   // Fifo occupancy generation
   //always @(posedge rd_clk     ) begin
   //  if(rd_rstn == RST_ACTIVE) begin
   //    curr_fifo_oc <= 'h0;
   //  //end else if(fifo_rd_en & fifo_wr_en) begin
   //  //  curr_fifo_oc <= curr_fifo_oc;
   //  //end else if(fifo_rd_en) begin
   //  //  curr_fifo_oc <= curr_fifo_oc - 2'b10;
   //  //end else if(fifo_wr_en) begin
   //  //  curr_fifo_oc <= curr_fifo_oc + 2'b10;
   //  end else begin
   //    //curr_fifo_oc <= {rd_data_count[DATA_CNT_WIDTH-1:0],1'b0} ;
   //    // Add 1 to current read count due to FWFT(First word fall through set)
   //    curr_fifo_oc <= (2'b01+rd_data_count[DATA_CNT_WIDTH-1:0])*WORDS_IN_ENTRY ;
   //  end
   //end

   //map/un-map outputs based on offload selection
   generate if(C_LOG_DATA_OFFLD == 0) begin : ARREADY_OFF 
     assign s_axi_offld_arready = 1'b0;
     assign s_axi_offld_rdata = 32'h0;
   end else begin : ARREADY_ON
     assign s_axi_offld_arready = s_axi_offld_arready_i;
     assign s_axi_offld_rdata = s_axi_offld_rdata_i;
   end
   endgenerate

  //TODO:REMOVE:TBCODE
  //initial begin
  //  s_axi_offld_araddr <= 'h0; 
  //  s_axi_offld_arvalid <= 'h0; 
  //  s_axi_offld_arid <= 'h0; 
  //  s_axi_offld_arlen <= 'h1F; 
  //  #6567 ;
  //  #22;
  //  s_axi_offld_arvalid <= 1'b1;
  //  #22 ;
  //  s_axi_offld_arvalid <= 1'b1;
  //  s_axi_offld_arlen <= 'h5; 
  //  #1366220 ;
  //  s_axi_offld_arvalid <= 1'b1;
  //  s_axi_offld_arlen <= 'h1; 
  //end
  //initial begin
  //  s_axi_offld_rready <= 'h0; 
  //  #6650;
  //  s_axi_offld_rready <= 'h1; 
  //  #1260;
  //  s_axi_offld_rready <= 'h0; 
  //  #60;
  //  s_axi_offld_rready <= 'h1; 
  //  #824700;
  //  s_axi_offld_rready <= 'h0; 
  //  #100;
  //  s_axi_offld_rready <= 'h1; 
  //end

  //chker
   //always @(posedge rd_clk     ) begin
   //  if(m_axis_tvalid_int & m_axis_tready_int) begin
   //    $display ("PR:AXIS:%x",m_axis_tdata_int);
   //  end
   //end
   //always @(posedge rd_clk     ) begin
   //  if(s_axi_offld_rvalid & s_axi_offld_rready & (s_axi_offld_rresp == 2'b00)) begin
   //    $display ("PR:AXIM:%x",s_axi_offld_rdata);
   //  end
   //end
endmodule
