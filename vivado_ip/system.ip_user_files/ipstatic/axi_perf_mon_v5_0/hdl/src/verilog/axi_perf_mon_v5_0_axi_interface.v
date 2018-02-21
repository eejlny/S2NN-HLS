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
// Filename:        axi_perf_mon_v5_0_9_axi_interface.v
// Version:         v5.0
// Description:     This module takes care of AXI protocol interface for AXI4 
//                  AXI4-Lite interfaces. This supports word access and INCR 
//                  burst only.
// Verilog-Standard:verilog-2001
//-----------------------------------------------------------------------------
// Structure:   
// -- axi_perf_mon.v
//     \-- axi_perf_mon_v5_0_9_axi_interface.v
//
//-----------------------------------------------------------------------------
// Author:      Kalpanath
// History:
// Kalpanath    07/25/2012      First Version
// NLR          03/20/2013      Added AXI4 Full interface support with ID 
//                              reflection
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module axi_perf_mon_v5_0_9_axi_interface 
#(
   parameter                              C_FAMILY                = "virtex7",
   // AXI port dependant parameters
   parameter                              C_S_AXI_PROTOCOL        = "AXI4LITE",
   parameter                              C_S_AXI_ADDR_WIDTH      = 32,
   parameter                              C_S_AXI_DATA_WIDTH      = 32,
   parameter                              C_S_AXI_ID_WIDTH        = 1,
   parameter                              C_SUPPORT_ID_REFLECTION = 0
)
(
   input                                  S_AXI_ACLK,
   input                                  S_AXI_ARESETN,
   // AXI Write Address Channel
   input [C_S_AXI_ADDR_WIDTH - 1:0]       S_AXI_AWADDR, 
   input                                  S_AXI_AWVALID,   
   input [C_S_AXI_ID_WIDTH-1:0]           S_AXI_AWID,   
   output                                 S_AXI_AWREADY,    
   // AXI Write Data Channel
   input [C_S_AXI_DATA_WIDTH - 1:0]       S_AXI_WDATA, 
   input [(C_S_AXI_DATA_WIDTH / 8) - 1:0] S_AXI_WSTRB, 
   input                                  S_AXI_WVALID, 
   output                                 S_AXI_WREADY, 
   // AXI Write Response Channel
   output[1:0]                            S_AXI_BRESP, 
   output                                 S_AXI_BVALID,   
   output [C_S_AXI_ID_WIDTH-1:0]          S_AXI_BID,   
   input                                  S_AXI_BREADY, 
   // AXI Read Address Channel
   input [C_S_AXI_ADDR_WIDTH - 1:0]       S_AXI_ARADDR, 
   input                                  S_AXI_ARVALID, 
   input [C_S_AXI_ID_WIDTH-1:0]           S_AXI_ARID,   
   output                                 S_AXI_ARREADY, 
   // AXI Read Data Channel
   output[C_S_AXI_DATA_WIDTH - 1:0]       S_AXI_RDATA, 
   output[1:0]                            S_AXI_RRESP, 
   output                                 S_AXI_RVALID, 
   output [C_S_AXI_ID_WIDTH-1:0]          S_AXI_RID,   
   input                                  S_AXI_RREADY, 
   // Controls to the IP/IPIF modules
   output[(C_S_AXI_ADDR_WIDTH - 1):0]     Bus2IP_Addr,  
   output[(C_S_AXI_DATA_WIDTH - 1):0]     Bus2IP_Data,    
   output[((C_S_AXI_DATA_WIDTH / 8)-1):0] Bus2IP_BE, 
   output                                 Bus2IP_Burst,   
   output                                 Bus2IP_RdCE,   
   output                                 Bus2IP_WrCE,   
   input [(C_S_AXI_DATA_WIDTH - 1):0]     IP2Bus_Data, 
   input                                  IP2Bus_DataValid,
   input                                  IP2Bus_Error
);

//-------------------------------------------------------------------
// Parameter Declaration
//-------------------------------------------------------------------
localparam RST_ACTIVE = 1'b0;


//-------------------------------------------------------------------
// Signal Declaration
//-------------------------------------------------------------------
reg                                awready_i;
reg                                write_req;
reg                                read_req;
reg                                arready_i;
reg                                rvalid;
reg                                bvalid;
reg [(C_S_AXI_DATA_WIDTH - 1):0]   IP2Bus_Data_sampled;

reg [(C_S_AXI_ADDR_WIDTH - 1):0]   bus2ip_addr_i;
wire                               bus2ip_rdce_i;
reg                                bus2ip_rdce_i_d1;

//-------------------------------------------------------------------
// Begin architecture
//-------------------------------------------------------------------
wire wr_req_pend_pulse;
reg [(C_S_AXI_ADDR_WIDTH - 1):0]   wr_req_pend_addr;


// AXI signal assignment
assign  S_AXI_AWREADY = awready_i;
assign  S_AXI_WREADY  = write_req & !read_req;
assign  S_AXI_ARREADY = arready_i;
assign  S_AXI_BRESP   = 2'b0;
assign  S_AXI_BVALID  = bvalid;
assign  S_AXI_RDATA   = IP2Bus_Data_sampled;
assign  S_AXI_RRESP   = 2'b0;

//IPIC signal assignment          
assign  Bus2IP_Addr   = bus2ip_addr_i;
assign  Bus2IP_Data   = S_AXI_WDATA;
assign  Bus2IP_WrCE   = S_AXI_WVALID && write_req;
assign  Bus2IP_RdCE   = bus2ip_rdce_i;
assign  Bus2IP_BE     = S_AXI_WSTRB;
assign  Bus2IP_Burst  = 1'b0;

//CR#782670
reg wr_req_pend;
assign wr_req_pend_pulse = S_AXI_AWVALID & S_AXI_AWREADY & S_AXI_ARVALID & S_AXI_ARREADY;
always @(posedge S_AXI_ACLK) begin 
  if (S_AXI_ARESETN == RST_ACTIVE) begin
    wr_req_pend <=1'b0;
  end else if(S_AXI_AWVALID & S_AXI_AWREADY & S_AXI_ARVALID & S_AXI_ARREADY)begin
    wr_req_pend <= 1'b1; 
  end else if(Bus2IP_RdCE) begin
    wr_req_pend <= 1'b0; 
  end
end
// --------------------------------------------------------------------------
// ID reflection for AXI4 Full interface support
//---------------------------------------------------------------------------
 
generate 
if (C_SUPPORT_ID_REFLECTION == 1) begin : GEN_AXI4FULL
 
  reg [C_S_AXI_ID_WIDTH-1:0]  S_AXI_BID_Reg;
  reg [C_S_AXI_ID_WIDTH-1:0]  S_AXI_RID_Reg;

  // ------------------------------------------------------------------------
  // Process to reflect AWID over BID to support AXI4 Full Interface
  // ------------------------------------------------------------------------
  always @(posedge S_AXI_ACLK) begin : AXI_AWID_P
     if (S_AXI_ARESETN == RST_ACTIVE) begin
         S_AXI_BID_Reg <= 0;
     end
     else begin
         S_AXI_BID_Reg <= S_AXI_AWID;
     end
  end
  
  // ------------------------------------------------------------------------
  // Process to reflect ARID over RID to support AXI4 Full Interface
  // ------------------------------------------------------------------------
  always @(posedge S_AXI_ACLK) begin : AXI_ARID_P
     if (S_AXI_ARESETN == RST_ACTIVE) begin
         S_AXI_RID_Reg <= 0;
     end
     else begin
         S_AXI_RID_Reg <= S_AXI_ARID;
     end
  end

  assign S_AXI_BID = S_AXI_BID_Reg;
  assign S_AXI_RID = S_AXI_RID_Reg;

end

// ----------------------------------------------------------------------------
// No ID reflection for AXI4LITE Protocol
// ---------------------------------------------------------------------------

else if (C_SUPPORT_ID_REFLECTION == 0) begin : GEN_AXI4LIGHT

   assign S_AXI_BID = 0;
   assign S_AXI_RID = 0;
  
end
endgenerate



//  -----------------------------------------------------------------------
//  Process AXI_AWREADY_P to generate Write request on the IPIC
//  -----------------------------------------------------------------------
always @(posedge S_AXI_ACLK) begin : AXI_AWREADY_P
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       awready_i <= 1'b0;
   end
   else if ((S_AXI_AWVALID == 1'b1) && (awready_i == 1'b1)) begin
       awready_i <= 1'b0;
   end
   else begin
       awready_i <= (!write_req) && !(S_AXI_ARVALID || read_req || rvalid);
   end
end 

reg rd_in_progress;
always @(posedge S_AXI_ACLK) begin : AXI_ARREADY_P
  if (S_AXI_ARESETN == RST_ACTIVE) begin
    rd_in_progress <= 1'b0;
  end else if(read_req) begin
    rd_in_progress <= 1'b1;
  end else if(S_AXI_RVALID & S_AXI_RREADY) begin
    rd_in_progress <= 1'b0;
  end
end

//  -----------------------------------------------------------------------
//  Process AXI_ARREADY_P to generate Write request on the IPIC
//  -----------------------------------------------------------------------
always @(posedge S_AXI_ACLK) begin
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       arready_i <= 1'b0;
   end
   else if ((S_AXI_ARVALID == 1'b1) && (arready_i == 1'b1)) begin
       arready_i <= 1'b0;
   end
   else begin
       arready_i <= (!read_req) && (!rd_in_progress) && !(S_AXI_AWVALID || write_req);
   end
end 


//  -----------------------------------------------------------------------
//  Process AXI_READ_OUTPUT_P to generate Write request on the IPIC
//  -----------------------------------------------------------------------
assign S_AXI_RVALID = rvalid;

always @(posedge S_AXI_ACLK) begin 
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       IP2Bus_Data_sampled <= 0;
   end
   else if (IP2Bus_DataValid == 1'b1) begin
       IP2Bus_Data_sampled <= IP2Bus_Data;
   end
   else begin
       IP2Bus_Data_sampled <= IP2Bus_Data_sampled;
   end
end 


//  -----------------------------------------------------------------------
//  Process WRITE_REQUEST_P to generate Write request on the IPIC
//  -----------------------------------------------------------------------

always @(posedge S_AXI_ACLK) begin : WRITE_REQUEST_P
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       write_req <= 1'b0;
   end
   else if ((S_AXI_AWVALID == 1'b1) && (awready_i == 1'b1)) begin
       write_req <= 1'b1;
   end
   else if ((write_req == 1'b1) && (S_AXI_WVALID == 1'b1)) begin
       write_req <= 1'b0;
   end
   else begin
       write_req <= write_req;
   end
end 

//  -----------------------------------------------------------------------
//  Process READ_REQUEST_P to generate read request
//  -----------------------------------------------------------------------
always @(posedge S_AXI_ACLK) begin : READ_REQUEST_P
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       read_req <= 1'b0;
   end
   else if ((S_AXI_ARVALID == 1'b1) && (arready_i == 1'b1)) begin
       read_req <= 1'b1;
   end
   else if (read_req == 1'b1) begin
       read_req <= 1'b0;
   end
   else begin
       read_req <= read_req;
   end
end 

always @(posedge S_AXI_ACLK) begin 
 if (S_AXI_ARESETN == RST_ACTIVE) begin
   wr_req_pend_addr <= 0;
 end else if(wr_req_pend_pulse) begin
   wr_req_pend_addr <= S_AXI_AWADDR;
 end 
end
//  -----------------------------------------------------------------------
//  Process ADDR_GEN_P to generate bus2ip_addr for read/write
//  -----------------------------------------------------------------------
always @(posedge S_AXI_ACLK) begin : ADDR_GEN_P
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       bus2ip_addr_i <= 0;
   end
   else if ((S_AXI_ARVALID == 1'b1) && (arready_i == 1'b1)) begin
       bus2ip_addr_i <= S_AXI_ARADDR;
   end
   else if ((S_AXI_AWVALID == 1'b1) && (awready_i == 1'b1)) begin
       bus2ip_addr_i <= S_AXI_AWADDR;
   end
   else if (wr_req_pend) begin
       bus2ip_addr_i <= wr_req_pend_addr;
   end
   else begin
       bus2ip_addr_i <= bus2ip_addr_i;
   end
end 

//  -----------------------------------------------------------------------
//  Process WRITE_BVALID_P to generate Write Response valid
//  -----------------------------------------------------------------------
always @(posedge S_AXI_ACLK) begin : WRITE_BVALID_P
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       bvalid <= 1'b0;
   end
   else if ((S_AXI_WREADY == 1'b1) && (S_AXI_WVALID == 1'b1)) begin
   //else if (write_req == 1'b1) begin
       bvalid <= 1'b1;
   end
   else if (S_AXI_BREADY == 1'b1) begin
       bvalid <= 1'b0;
   end
   else begin
       bvalid <= bvalid;
   end
end 

//  -----------------------------------------------------------------------
//  Process READ_RVALID_P to generate Read valid
//  -----------------------------------------------------------------------
always @(posedge S_AXI_ACLK) begin : READ_RVALID_P
   if (S_AXI_ARESETN == RST_ACTIVE) begin
       rvalid <= 1'b0;
   end
   else if (IP2Bus_DataValid == 1'b1) begin
       rvalid <= 1'b1;
   end
   else if (S_AXI_RREADY == 1'b1) begin
       rvalid <= 1'b0;
   end
   else begin
       rvalid <= rvalid;
   end
end 

// Read request on IPIC
assign bus2ip_rdce_i = read_req;
      
endmodule
