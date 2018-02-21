-- (c) Copyright 1995-2016 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:hls:hls_snn_izikevich:1.0
-- IP Revision: 1606291929

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT system_hls_snn_izikevich_0_0
  PORT (
    s_axi_control_AWADDR : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    s_axi_control_AWVALID : IN STD_LOGIC;
    s_axi_control_AWREADY : OUT STD_LOGIC;
    s_axi_control_WDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_control_WSTRB : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_control_WVALID : IN STD_LOGIC;
    s_axi_control_WREADY : OUT STD_LOGIC;
    s_axi_control_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_control_BVALID : OUT STD_LOGIC;
    s_axi_control_BREADY : IN STD_LOGIC;
    s_axi_control_ARADDR : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    s_axi_control_ARVALID : IN STD_LOGIC;
    s_axi_control_ARREADY : OUT STD_LOGIC;
    s_axi_control_RDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_control_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_control_RVALID : OUT STD_LOGIC;
    s_axi_control_RREADY : IN STD_LOGIC;
    ap_clk : IN STD_LOGIC;
    ap_rst_n : IN STD_LOGIC;
    interrupt : OUT STD_LOGIC;
    input_stream0_TVALID : IN STD_LOGIC;
    input_stream0_TREADY : OUT STD_LOGIC;
    input_stream0_TDATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    input_stream0_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    input_stream1_TVALID : IN STD_LOGIC;
    input_stream1_TREADY : OUT STD_LOGIC;
    input_stream1_TDATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    input_stream1_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    input_stream2_TVALID : IN STD_LOGIC;
    input_stream2_TREADY : OUT STD_LOGIC;
    input_stream2_TDATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    input_stream2_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    input_stream3_TVALID : IN STD_LOGIC;
    input_stream3_TREADY : OUT STD_LOGIC;
    input_stream3_TDATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    input_stream3_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    output_stream_TVALID : OUT STD_LOGIC;
    output_stream_TREADY : IN STD_LOGIC;
    output_stream_TDATA : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    output_stream_TLAST : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : system_hls_snn_izikevich_0_0
  PORT MAP (
    s_axi_control_AWADDR => s_axi_control_AWADDR,
    s_axi_control_AWVALID => s_axi_control_AWVALID,
    s_axi_control_AWREADY => s_axi_control_AWREADY,
    s_axi_control_WDATA => s_axi_control_WDATA,
    s_axi_control_WSTRB => s_axi_control_WSTRB,
    s_axi_control_WVALID => s_axi_control_WVALID,
    s_axi_control_WREADY => s_axi_control_WREADY,
    s_axi_control_BRESP => s_axi_control_BRESP,
    s_axi_control_BVALID => s_axi_control_BVALID,
    s_axi_control_BREADY => s_axi_control_BREADY,
    s_axi_control_ARADDR => s_axi_control_ARADDR,
    s_axi_control_ARVALID => s_axi_control_ARVALID,
    s_axi_control_ARREADY => s_axi_control_ARREADY,
    s_axi_control_RDATA => s_axi_control_RDATA,
    s_axi_control_RRESP => s_axi_control_RRESP,
    s_axi_control_RVALID => s_axi_control_RVALID,
    s_axi_control_RREADY => s_axi_control_RREADY,
    ap_clk => ap_clk,
    ap_rst_n => ap_rst_n,
    interrupt => interrupt,
    input_stream0_TVALID => input_stream0_TVALID,
    input_stream0_TREADY => input_stream0_TREADY,
    input_stream0_TDATA => input_stream0_TDATA,
    input_stream0_TLAST => input_stream0_TLAST,
    input_stream1_TVALID => input_stream1_TVALID,
    input_stream1_TREADY => input_stream1_TREADY,
    input_stream1_TDATA => input_stream1_TDATA,
    input_stream1_TLAST => input_stream1_TLAST,
    input_stream2_TVALID => input_stream2_TVALID,
    input_stream2_TREADY => input_stream2_TREADY,
    input_stream2_TDATA => input_stream2_TDATA,
    input_stream2_TLAST => input_stream2_TLAST,
    input_stream3_TVALID => input_stream3_TVALID,
    input_stream3_TREADY => input_stream3_TREADY,
    input_stream3_TDATA => input_stream3_TDATA,
    input_stream3_TLAST => input_stream3_TLAST,
    output_stream_TVALID => output_stream_TVALID,
    output_stream_TREADY => output_stream_TREADY,
    output_stream_TDATA => output_stream_TDATA,
    output_stream_TLAST => output_stream_TLAST
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file system_hls_snn_izikevich_0_0.vhd when simulating
-- the core, system_hls_snn_izikevich_0_0. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.

