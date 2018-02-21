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

-- IP VLNV: xilinx.com:ip:axi_dma:7.1
-- IP Revision: 8

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT system_axi_dma_0_1
  PORT (
    s_axi_lite_aclk : IN STD_LOGIC;
    m_axi_mm2s_aclk : IN STD_LOGIC;
    axi_resetn : IN STD_LOGIC;
    s_axi_lite_awvalid : IN STD_LOGIC;
    s_axi_lite_awready : OUT STD_LOGIC;
    s_axi_lite_awaddr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    s_axi_lite_wvalid : IN STD_LOGIC;
    s_axi_lite_wready : OUT STD_LOGIC;
    s_axi_lite_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_lite_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_lite_bvalid : OUT STD_LOGIC;
    s_axi_lite_bready : IN STD_LOGIC;
    s_axi_lite_arvalid : IN STD_LOGIC;
    s_axi_lite_arready : OUT STD_LOGIC;
    s_axi_lite_araddr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    s_axi_lite_rvalid : OUT STD_LOGIC;
    s_axi_lite_rready : IN STD_LOGIC;
    s_axi_lite_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_lite_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_mm2s_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_mm2s_arlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_mm2s_arsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_mm2s_arburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_mm2s_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_mm2s_arcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_mm2s_arvalid : OUT STD_LOGIC;
    m_axi_mm2s_arready : IN STD_LOGIC;
    m_axi_mm2s_rdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axi_mm2s_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_mm2s_rlast : IN STD_LOGIC;
    m_axi_mm2s_rvalid : IN STD_LOGIC;
    m_axi_mm2s_rready : OUT STD_LOGIC;
    mm2s_prmry_reset_out_n : OUT STD_LOGIC;
    m_axis_mm2s_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axis_mm2s_tkeep : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_mm2s_tvalid : OUT STD_LOGIC;
    m_axis_mm2s_tready : IN STD_LOGIC;
    m_axis_mm2s_tlast : OUT STD_LOGIC;
    mm2s_introut : OUT STD_LOGIC;
    axi_dma_tstvec : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : system_axi_dma_0_1
  PORT MAP (
    s_axi_lite_aclk => s_axi_lite_aclk,
    m_axi_mm2s_aclk => m_axi_mm2s_aclk,
    axi_resetn => axi_resetn,
    s_axi_lite_awvalid => s_axi_lite_awvalid,
    s_axi_lite_awready => s_axi_lite_awready,
    s_axi_lite_awaddr => s_axi_lite_awaddr,
    s_axi_lite_wvalid => s_axi_lite_wvalid,
    s_axi_lite_wready => s_axi_lite_wready,
    s_axi_lite_wdata => s_axi_lite_wdata,
    s_axi_lite_bresp => s_axi_lite_bresp,
    s_axi_lite_bvalid => s_axi_lite_bvalid,
    s_axi_lite_bready => s_axi_lite_bready,
    s_axi_lite_arvalid => s_axi_lite_arvalid,
    s_axi_lite_arready => s_axi_lite_arready,
    s_axi_lite_araddr => s_axi_lite_araddr,
    s_axi_lite_rvalid => s_axi_lite_rvalid,
    s_axi_lite_rready => s_axi_lite_rready,
    s_axi_lite_rdata => s_axi_lite_rdata,
    s_axi_lite_rresp => s_axi_lite_rresp,
    m_axi_mm2s_araddr => m_axi_mm2s_araddr,
    m_axi_mm2s_arlen => m_axi_mm2s_arlen,
    m_axi_mm2s_arsize => m_axi_mm2s_arsize,
    m_axi_mm2s_arburst => m_axi_mm2s_arburst,
    m_axi_mm2s_arprot => m_axi_mm2s_arprot,
    m_axi_mm2s_arcache => m_axi_mm2s_arcache,
    m_axi_mm2s_arvalid => m_axi_mm2s_arvalid,
    m_axi_mm2s_arready => m_axi_mm2s_arready,
    m_axi_mm2s_rdata => m_axi_mm2s_rdata,
    m_axi_mm2s_rresp => m_axi_mm2s_rresp,
    m_axi_mm2s_rlast => m_axi_mm2s_rlast,
    m_axi_mm2s_rvalid => m_axi_mm2s_rvalid,
    m_axi_mm2s_rready => m_axi_mm2s_rready,
    mm2s_prmry_reset_out_n => mm2s_prmry_reset_out_n,
    m_axis_mm2s_tdata => m_axis_mm2s_tdata,
    m_axis_mm2s_tkeep => m_axis_mm2s_tkeep,
    m_axis_mm2s_tvalid => m_axis_mm2s_tvalid,
    m_axis_mm2s_tready => m_axis_mm2s_tready,
    m_axis_mm2s_tlast => m_axis_mm2s_tlast,
    mm2s_introut => mm2s_introut,
    axi_dma_tstvec => axi_dma_tstvec
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file system_axi_dma_0_1.vhd when simulating
-- the core, system_axi_dma_0_1. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.

