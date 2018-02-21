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
-- IP Revision: 1606221523

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY system_hls_snn_izikevich_0_0 IS
  PORT (
    s_axi_control_AWADDR : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    s_axi_control_AWVALID : IN STD_LOGIC;
    s_axi_control_AWREADY : OUT STD_LOGIC;
    s_axi_control_WDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_control_WSTRB : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_control_WVALID : IN STD_LOGIC;
    s_axi_control_WREADY : OUT STD_LOGIC;
    s_axi_control_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_control_BVALID : OUT STD_LOGIC;
    s_axi_control_BREADY : IN STD_LOGIC;
    s_axi_control_ARADDR : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
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
END system_hls_snn_izikevich_0_0;

ARCHITECTURE system_hls_snn_izikevich_0_0_arch OF system_hls_snn_izikevich_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : string;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF system_hls_snn_izikevich_0_0_arch: ARCHITECTURE IS "yes";

  COMPONENT hls_snn_izikevich IS
    GENERIC (
      C_S_AXI_CONTROL_ADDR_WIDTH : INTEGER;
      C_S_AXI_CONTROL_DATA_WIDTH : INTEGER
    );
    PORT (
      s_axi_control_AWADDR : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      s_axi_control_AWVALID : IN STD_LOGIC;
      s_axi_control_AWREADY : OUT STD_LOGIC;
      s_axi_control_WDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_control_WSTRB : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_control_WVALID : IN STD_LOGIC;
      s_axi_control_WREADY : OUT STD_LOGIC;
      s_axi_control_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_control_BVALID : OUT STD_LOGIC;
      s_axi_control_BREADY : IN STD_LOGIC;
      s_axi_control_ARADDR : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
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
  END COMPONENT hls_snn_izikevich;
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_AWADDR: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control AWADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_AWVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control AWVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_AWREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_WDATA: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_WSTRB: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_WVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_WREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_BRESP: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_BVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_BREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_ARADDR: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_ARVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_ARREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_RDATA: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_RRESP: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_RVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_control_RREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_control RREADY";
  ATTRIBUTE X_INTERFACE_INFO OF ap_clk: SIGNAL IS "xilinx.com:signal:clock:1.0 ap_clk CLK";
  ATTRIBUTE X_INTERFACE_INFO OF ap_rst_n: SIGNAL IS "xilinx.com:signal:reset:1.0 ap_rst_n RST";
  ATTRIBUTE X_INTERFACE_INFO OF interrupt: SIGNAL IS "xilinx.com:signal:interrupt:1.0 interrupt INTERRUPT";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream0_TVALID: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream0 TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream0_TREADY: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream0 TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream0_TDATA: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream0 TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream0_TLAST: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream0 TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream1_TVALID: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream1 TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream1_TREADY: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream1 TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream1_TDATA: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream1 TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream1_TLAST: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream1 TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream2_TVALID: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream2 TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream2_TREADY: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream2 TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream2_TDATA: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream2 TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream2_TLAST: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream2 TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream3_TVALID: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream3 TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream3_TREADY: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream3 TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream3_TDATA: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream3 TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF input_stream3_TLAST: SIGNAL IS "xilinx.com:interface:axis:1.0 input_stream3 TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF output_stream_TVALID: SIGNAL IS "xilinx.com:interface:axis:1.0 output_stream TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF output_stream_TREADY: SIGNAL IS "xilinx.com:interface:axis:1.0 output_stream TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF output_stream_TDATA: SIGNAL IS "xilinx.com:interface:axis:1.0 output_stream TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF output_stream_TLAST: SIGNAL IS "xilinx.com:interface:axis:1.0 output_stream TLAST";
BEGIN
  U0 : hls_snn_izikevich
    GENERIC MAP (
      C_S_AXI_CONTROL_ADDR_WIDTH => 12,
      C_S_AXI_CONTROL_DATA_WIDTH => 32
    )
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
END system_hls_snn_izikevich_0_0_arch;
