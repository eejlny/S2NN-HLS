
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z020clg484-1
#    set_property BOARD_PART em.avnet.com:zed:part0:1.3 [current_project]

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: zynq
proc create_hier_cell_zynq { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_zynq() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR
  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_GP0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_HP0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_HP1
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_HP2
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_HP3

  # Create pins
  create_bd_pin -dir O -type clk FCLK_CLK0
  create_bd_pin -dir I int_dma_0_rx
  create_bd_pin -dir I int_dma_0_tx
  create_bd_pin -dir I int_dma_1_tx
  create_bd_pin -dir I int_dma_2_tx
  create_bd_pin -dir I int_dma_3_tx
  create_bd_pin -dir I int_hls_block
  create_bd_pin -dir O -from 0 -to 0 -type rst interconnect_aresetna
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetns

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_IRQ_F2P_INTR {1} \
CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
CONFIG.PCW_USE_S_AXI_HP0 {1} \
CONFIG.PCW_USE_S_AXI_HP1 {1} \
CONFIG.PCW_USE_S_AXI_HP2 {1} \
CONFIG.PCW_USE_S_AXI_HP3 {1} \
CONFIG.preset {ZedBoard} \
 ] $processing_system7_0

  # Create instance: rst_processing_system7_0_100M, and set properties
  set rst_processing_system7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_100M ]

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {6} \
 ] $xlconcat_0

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_HP0_1 [get_bd_intf_pins S_AXI_HP0] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net S_AXI_HP1_1 [get_bd_intf_pins S_AXI_HP1] [get_bd_intf_pins processing_system7_0/S_AXI_HP1]
  connect_bd_intf_net -intf_net S_AXI_HP2_1 [get_bd_intf_pins S_AXI_HP2] [get_bd_intf_pins processing_system7_0/S_AXI_HP2]
  connect_bd_intf_net -intf_net S_AXI_HP3_1 [get_bd_intf_pins S_AXI_HP3] [get_bd_intf_pins processing_system7_0/S_AXI_HP3]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_pins DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_pins FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins M_AXI_GP0] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]

  # Create port connections
  connect_bd_net -net In0_1 [get_bd_pins int_dma_0_rx] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net In1_1 [get_bd_pins int_dma_0_tx] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net In2_1 [get_bd_pins int_dma_1_tx] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net In3_1 [get_bd_pins int_dma_2_tx] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net In4_1 [get_bd_pins int_dma_3_tx] [get_bd_pins xlconcat_0/In4]
  connect_bd_net -net In5_1 [get_bd_pins int_hls_block] [get_bd_pins xlconcat_0/In5]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins FCLK_CLK0] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP1_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP2_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP3_ACLK] [get_bd_pins rst_processing_system7_0_100M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_processing_system7_0_100M/ext_reset_in]
  connect_bd_net -net rst_processing_system7_0_100M_interconnect_aresetn [get_bd_pins interconnect_aresetna] [get_bd_pins rst_processing_system7_0_100M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_100M_peripheral_aresetn [get_bd_pins peripheral_aresetns] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins processing_system7_0/IRQ_F2P] [get_bd_pins xlconcat_0/dout]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /zynq] -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port int_dma_1_tx -pg 1 -y 80 -defaultsOSRD
preplace port S_AXI_HP1 -pg 1 -y 210 -defaultsOSRD
preplace port DDR -pg 1 -y 160 -defaultsOSRD
preplace port S_AXI_HP2 -pg 1 -y 230 -defaultsOSRD
preplace port S_AXI_HP3 -pg 1 -y 250 -defaultsOSRD
preplace port int_dma_0_rx -pg 1 -y 40 -defaultsOSRD
preplace port M_AXI_GP0 -pg 1 -y 220 -defaultsOSRD
preplace port int_hls_block -pg 1 -y 140 -defaultsOSRD
preplace port FIXED_IO -pg 1 -y 180 -defaultsOSRD
preplace port int_dma_2_tx -pg 1 -y 100 -defaultsOSRD
preplace port FCLK_CLK0 -pg 1 -y 250 -defaultsOSRD
preplace port int_dma_3_tx -pg 1 -y 120 -defaultsOSRD
preplace port int_dma_0_tx -pg 1 -y 60 -defaultsOSRD
preplace port S_AXI_HP0 -pg 1 -y 190 -defaultsOSRD
preplace portBus peripheral_aresetns -pg 1 -y 380 -defaultsOSRD
preplace portBus interconnect_aresetna -pg 1 -y 400 -defaultsOSRD
preplace inst rst_processing_system7_0_100M -pg 1 -lvl 3 -y 340 -defaultsOSRD
preplace inst xlconcat_0 -pg 1 -lvl 1 -y 90 -defaultsOSRD
preplace inst processing_system7_0 -pg 1 -lvl 2 -y 240 -defaultsOSRD
preplace netloc S_AXI_HP0_1 1 0 2 NJ 190 NJ
preplace netloc processing_system7_0_DDR 1 2 2 NJ 160 NJ
preplace netloc In2_1 1 0 1 NJ
preplace netloc processing_system7_0_M_AXI_GP0 1 2 2 NJ 220 NJ
preplace netloc S_AXI_HP3_1 1 0 2 NJ 250 NJ
preplace netloc S_AXI_HP1_1 1 0 2 NJ 210 NJ
preplace netloc In5_1 1 0 1 NJ
preplace netloc processing_system7_0_FCLK_RESET0_N 1 2 1 N
preplace netloc In0_1 1 0 1 NJ
preplace netloc S_AXI_HP2_1 1 0 2 NJ 230 NJ
preplace netloc rst_processing_system7_0_100M_peripheral_aresetn 1 3 1 NJ
preplace netloc In3_1 1 0 1 NJ
preplace netloc xlconcat_0_dout 1 1 1 200
preplace netloc processing_system7_0_FIXED_IO 1 2 2 NJ 180 NJ
preplace netloc rst_processing_system7_0_100M_interconnect_aresetn 1 3 1 950
preplace netloc processing_system7_0_FCLK_CLK0 1 1 3 210 420 630 250 NJ
preplace netloc In4_1 1 0 1 NJ
preplace netloc In1_1 1 0 1 NJ
levelinfo -pg 1 0 110 420 790 970 -top 0 -bot 430
",
}

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: axi_interconnect
proc create_hier_cell_axi_interconnect { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_axi_interconnect() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI1
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI2
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI3
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_MM2S
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_MM2S1
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_MM2S2
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_MM2S3
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_S2MM

  # Create pins
  create_bd_pin -dir I -type clk FCLK_CLK0
  create_bd_pin -dir I -from 0 -to 0 -type rst INT_ARESETN
  create_bd_pin -dir I -from 0 -to 0 -type rst PER_ARESETN
  create_bd_pin -dir O mm2s_introut0
  create_bd_pin -dir O mm2s_introut1
  create_bd_pin -dir O mm2s_introut2
  create_bd_pin -dir O mm2s_introut3
  create_bd_pin -dir O s2mm_introut0

  # Create instance: auto_pc, and set properties
  set auto_pc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 auto_pc ]
  set_property -dict [ list \
CONFIG.MI_PROTOCOL {AXI4LITE} \
CONFIG.SI_PROTOCOL {AXI3} \
 ] $auto_pc

  # Create instance: axi_crossbar_0, and set properties
  set axi_crossbar_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 axi_crossbar_0 ]
  set_property -dict [ list \
CONFIG.NUM_MI {1} \
CONFIG.NUM_SI {2} \
 ] $axi_crossbar_0

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [ list \
CONFIG.c_include_mm2s_dre {1} \
CONFIG.c_include_s2mm_dre {1} \
CONFIG.c_include_sg {0} \
CONFIG.c_m_axi_mm2s_data_width {64} \
CONFIG.c_m_axis_mm2s_tdata_width {64} \
CONFIG.c_mm2s_burst_size {256} \
CONFIG.c_s2mm_burst_size {256} \
CONFIG.c_sg_include_stscntrl_strm {0} \
 ] $axi_dma_0

  # Create instance: axi_dma_1, and set properties
  set axi_dma_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_1 ]
  set_property -dict [ list \
CONFIG.c_include_mm2s_dre {1} \
CONFIG.c_include_s2mm {0} \
CONFIG.c_include_s2mm_dre {0} \
CONFIG.c_include_sg {0} \
CONFIG.c_m_axi_mm2s_data_width {64} \
CONFIG.c_m_axis_mm2s_tdata_width {64} \
CONFIG.c_mm2s_burst_size {256} \
CONFIG.c_s2mm_burst_size {16} \
CONFIG.c_sg_include_stscntrl_strm {0} \
 ] $axi_dma_1

  # Create instance: axi_dma_2, and set properties
  set axi_dma_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_2 ]
  set_property -dict [ list \
CONFIG.c_include_mm2s_dre {1} \
CONFIG.c_include_s2mm {0} \
CONFIG.c_include_s2mm_dre {0} \
CONFIG.c_include_sg {0} \
CONFIG.c_m_axi_mm2s_data_width {64} \
CONFIG.c_m_axis_mm2s_tdata_width {64} \
CONFIG.c_mm2s_burst_size {256} \
CONFIG.c_s2mm_burst_size {16} \
CONFIG.c_sg_include_stscntrl_strm {0} \
 ] $axi_dma_2

  # Create instance: axi_dma_3, and set properties
  set axi_dma_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_3 ]
  set_property -dict [ list \
CONFIG.c_include_mm2s_dre {1} \
CONFIG.c_include_s2mm {0} \
CONFIG.c_include_s2mm_dre {0} \
CONFIG.c_include_sg {0} \
CONFIG.c_m_axi_mm2s_data_width {64} \
CONFIG.c_m_axis_mm2s_tdata_width {64} \
CONFIG.c_mm2s_burst_size {256} \
CONFIG.c_s2mm_burst_size {16} \
CONFIG.c_sg_include_stscntrl_strm {0} \
 ] $axi_dma_3

  # Create instance: axi_protocol_converter_0, and set properties
  set axi_protocol_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_converter_0 ]

  # Create instance: axi_protocol_converter_1, and set properties
  set axi_protocol_converter_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_converter_1 ]

  # Create instance: axi_protocol_converter_2, and set properties
  set axi_protocol_converter_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_converter_2 ]

  # Create instance: axi_protocol_converter_3, and set properties
  set axi_protocol_converter_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_converter_3 ]

  # Create instance: xbar, and set properties
  set xbar [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 xbar ]
  set_property -dict [ list \
CONFIG.NUM_MI {5} \
CONFIG.NUM_SI {1} \
CONFIG.STRATEGY {0} \
 ] $xbar

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins M00_AXI] [get_bd_intf_pins xbar/M00_AXI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins M_AXIS_MM2S] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins M_AXIS_MM2S1] [get_bd_intf_pins axi_dma_1/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins M_AXIS_MM2S2] [get_bd_intf_pins axi_dma_2/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins S_AXIS_S2MM] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins M_AXIS_MM2S3] [get_bd_intf_pins axi_dma_3/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net Conn7 [get_bd_intf_pins M_AXI] [get_bd_intf_pins axi_protocol_converter_0/M_AXI]
  connect_bd_intf_net -intf_net Conn8 [get_bd_intf_pins M_AXI1] [get_bd_intf_pins axi_protocol_converter_1/M_AXI]
  connect_bd_intf_net -intf_net Conn9 [get_bd_intf_pins M_AXI2] [get_bd_intf_pins axi_protocol_converter_2/M_AXI]
  connect_bd_intf_net -intf_net Conn10 [get_bd_intf_pins M_AXI3] [get_bd_intf_pins axi_protocol_converter_3/M_AXI]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins auto_pc/S_AXI]
  connect_bd_intf_net -intf_net auto_pc_M_AXI [get_bd_intf_pins auto_pc/M_AXI] [get_bd_intf_pins xbar/S00_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_0_M00_AXI [get_bd_intf_pins axi_crossbar_0/M00_AXI] [get_bd_intf_pins axi_protocol_converter_0/S_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_crossbar_0/S00_AXI] [get_bd_intf_pins axi_dma_0/M_AXI_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_crossbar_0/S01_AXI] [get_bd_intf_pins axi_dma_0/M_AXI_S2MM]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXI_MM2S [get_bd_intf_pins axi_dma_1/M_AXI_MM2S] [get_bd_intf_pins axi_protocol_converter_1/S_AXI]
  connect_bd_intf_net -intf_net axi_dma_2_M_AXI_MM2S [get_bd_intf_pins axi_dma_2/M_AXI_MM2S] [get_bd_intf_pins axi_protocol_converter_2/S_AXI]
  connect_bd_intf_net -intf_net axi_dma_3_M_AXI_MM2S [get_bd_intf_pins axi_dma_3/M_AXI_MM2S] [get_bd_intf_pins axi_protocol_converter_3/S_AXI]
  connect_bd_intf_net -intf_net xbar_M01_AXI [get_bd_intf_pins axi_dma_0/S_AXI_LITE] [get_bd_intf_pins xbar/M01_AXI]
  connect_bd_intf_net -intf_net xbar_M02_AXI [get_bd_intf_pins axi_dma_1/S_AXI_LITE] [get_bd_intf_pins xbar/M02_AXI]
  connect_bd_intf_net -intf_net xbar_M03_AXI [get_bd_intf_pins axi_dma_2/S_AXI_LITE] [get_bd_intf_pins xbar/M03_AXI]
  connect_bd_intf_net -intf_net xbar_M04_AXI [get_bd_intf_pins axi_dma_3/S_AXI_LITE] [get_bd_intf_pins xbar/M04_AXI]

  # Create port connections
  connect_bd_net -net axi_dma_0_mm2s_introut [get_bd_pins mm2s_introut0] [get_bd_pins axi_dma_0/mm2s_introut]
  connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_pins s2mm_introut0] [get_bd_pins axi_dma_0/s2mm_introut]
  connect_bd_net -net axi_dma_1_mm2s_introut [get_bd_pins mm2s_introut1] [get_bd_pins axi_dma_1/mm2s_introut]
  connect_bd_net -net axi_dma_2_mm2s_introut [get_bd_pins mm2s_introut2] [get_bd_pins axi_dma_2/mm2s_introut]
  connect_bd_net -net axi_dma_3_mm2s_introut [get_bd_pins mm2s_introut3] [get_bd_pins axi_dma_3/mm2s_introut]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins FCLK_CLK0] [get_bd_pins auto_pc/aclk] [get_bd_pins axi_crossbar_0/aclk] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axi_dma_1/m_axi_mm2s_aclk] [get_bd_pins axi_dma_1/s_axi_lite_aclk] [get_bd_pins axi_dma_2/m_axi_mm2s_aclk] [get_bd_pins axi_dma_2/s_axi_lite_aclk] [get_bd_pins axi_dma_3/m_axi_mm2s_aclk] [get_bd_pins axi_dma_3/s_axi_lite_aclk] [get_bd_pins axi_protocol_converter_0/aclk] [get_bd_pins axi_protocol_converter_1/aclk] [get_bd_pins axi_protocol_converter_2/aclk] [get_bd_pins axi_protocol_converter_3/aclk] [get_bd_pins xbar/aclk]
  connect_bd_net -net rst_processing_system7_0_100M_interconnect_aresetn [get_bd_pins PER_ARESETN] [get_bd_pins axi_crossbar_0/aresetn] [get_bd_pins axi_protocol_converter_0/aresetn] [get_bd_pins axi_protocol_converter_1/aresetn] [get_bd_pins axi_protocol_converter_2/aresetn] [get_bd_pins axi_protocol_converter_3/aresetn] [get_bd_pins xbar/aresetn]
  connect_bd_net -net rst_processing_system7_0_100M_peripheral_aresetn [get_bd_pins INT_ARESETN] [get_bd_pins auto_pc/aresetn] [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axi_dma_1/axi_resetn] [get_bd_pins axi_dma_2/axi_resetn] [get_bd_pins axi_dma_3/axi_resetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  # Create ports

  # Create instance: axi_interconnect
  create_hier_cell_axi_interconnect [current_bd_instance .] axi_interconnect

  # Create instance: hls_snn_izikevich_0, and set properties
  set hls_snn_izikevich_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:hls_snn_izikevich:1.0 hls_snn_izikevich_0 ]

  # Create instance: zynq
  create_hier_cell_zynq [current_bd_instance .] zynq

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_HP0_1 [get_bd_intf_pins axi_interconnect/M_AXI] [get_bd_intf_pins zynq/S_AXI_HP0]
  connect_bd_intf_net -intf_net S_AXI_HP1_1 [get_bd_intf_pins axi_interconnect/M_AXI1] [get_bd_intf_pins zynq/S_AXI_HP1]
  connect_bd_intf_net -intf_net S_AXI_HP2_1 [get_bd_intf_pins axi_interconnect/M_AXI2] [get_bd_intf_pins zynq/S_AXI_HP2]
  connect_bd_intf_net -intf_net S_AXI_HP3_1 [get_bd_intf_pins axi_interconnect/M_AXI3] [get_bd_intf_pins zynq/S_AXI_HP3]
  connect_bd_intf_net -intf_net axi_interconnect_M00_AXI [get_bd_intf_pins axi_interconnect/M00_AXI] [get_bd_intf_pins hls_snn_izikevich_0/s_axi_control]
  connect_bd_intf_net -intf_net axi_interconnect_M_AXIS_MM2S [get_bd_intf_pins axi_interconnect/M_AXIS_MM2S] [get_bd_intf_pins hls_snn_izikevich_0/input_stream0]
  connect_bd_intf_net -intf_net axi_interconnect_M_AXIS_MM2S1 [get_bd_intf_pins axi_interconnect/M_AXIS_MM2S1] [get_bd_intf_pins hls_snn_izikevich_0/input_stream1]
  connect_bd_intf_net -intf_net axi_interconnect_M_AXIS_MM2S2 [get_bd_intf_pins axi_interconnect/M_AXIS_MM2S2] [get_bd_intf_pins hls_snn_izikevich_0/input_stream2]
  connect_bd_intf_net -intf_net axi_interconnect_M_AXIS_MM2S3 [get_bd_intf_pins axi_interconnect/M_AXIS_MM2S3] [get_bd_intf_pins hls_snn_izikevich_0/input_stream3]
  connect_bd_intf_net -intf_net hls_snn_izikevich_0_output_stream [get_bd_intf_pins axi_interconnect/S_AXIS_S2MM] [get_bd_intf_pins hls_snn_izikevich_0/output_stream]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins zynq/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins zynq/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins axi_interconnect/S00_AXI] [get_bd_intf_pins zynq/M_AXI_GP0]

  # Create port connections
  connect_bd_net -net axi_interconnect_mm2s_introut0 [get_bd_pins axi_interconnect/mm2s_introut0] [get_bd_pins zynq/int_dma_0_tx]
  connect_bd_net -net axi_interconnect_mm2s_introut1 [get_bd_pins axi_interconnect/mm2s_introut1] [get_bd_pins zynq/int_dma_1_tx]
  connect_bd_net -net axi_interconnect_mm2s_introut2 [get_bd_pins axi_interconnect/mm2s_introut2] [get_bd_pins zynq/int_dma_2_tx]
  connect_bd_net -net axi_interconnect_mm2s_introut3 [get_bd_pins axi_interconnect/mm2s_introut3] [get_bd_pins zynq/int_dma_3_tx]
  connect_bd_net -net hls_snn_izikevich_0_interrupt [get_bd_pins hls_snn_izikevich_0/interrupt] [get_bd_pins zynq/int_hls_block]
  connect_bd_net -net int_dma_0_rx_1 [get_bd_pins axi_interconnect/s2mm_introut0] [get_bd_pins zynq/int_dma_0_rx]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins axi_interconnect/FCLK_CLK0] [get_bd_pins hls_snn_izikevich_0/ap_clk] [get_bd_pins zynq/FCLK_CLK0]
  connect_bd_net -net rst_processing_system7_0_100M_interconnect_aresetn [get_bd_pins axi_interconnect/PER_ARESETN] [get_bd_pins zynq/interconnect_aresetna]
  connect_bd_net -net rst_processing_system7_0_100M_peripheral_aresetn [get_bd_pins axi_interconnect/INT_ARESETN] [get_bd_pins hls_snn_izikevich_0/ap_rst_n] [get_bd_pins zynq/peripheral_aresetns]

  # Create address segments
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces axi_interconnect/axi_dma_0/Data_MM2S] [get_bd_addr_segs zynq/processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces axi_interconnect/axi_dma_0/Data_S2MM] [get_bd_addr_segs zynq/processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces axi_interconnect/axi_dma_1/Data_MM2S] [get_bd_addr_segs zynq/processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces axi_interconnect/axi_dma_2/Data_MM2S] [get_bd_addr_segs zynq/processing_system7_0/S_AXI_HP2/HP2_DDR_LOWOCM] SEG_processing_system7_0_HP2_DDR_LOWOCM
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces axi_interconnect/axi_dma_3/Data_MM2S] [get_bd_addr_segs zynq/processing_system7_0/S_AXI_HP3/HP3_DDR_LOWOCM] SEG_processing_system7_0_HP3_DDR_LOWOCM
  create_bd_addr_seg -range 0x10000 -offset 0x40400000 [get_bd_addr_spaces zynq/processing_system7_0/Data] [get_bd_addr_segs axi_interconnect/axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40410000 [get_bd_addr_spaces zynq/processing_system7_0/Data] [get_bd_addr_segs axi_interconnect/axi_dma_1/S_AXI_LITE/Reg] SEG_axi_dma_1_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40420000 [get_bd_addr_spaces zynq/processing_system7_0/Data] [get_bd_addr_segs axi_interconnect/axi_dma_2/S_AXI_LITE/Reg] SEG_axi_dma_2_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40430000 [get_bd_addr_spaces zynq/processing_system7_0/Data] [get_bd_addr_segs axi_interconnect/axi_dma_3/S_AXI_LITE/Reg] SEG_axi_dma_3_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C00000 [get_bd_addr_spaces zynq/processing_system7_0/Data] [get_bd_addr_segs hls_snn_izikevich_0/s_axi_control/Reg] SEG_hls_snn_izikevich_0_Reg

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port DDR -pg 1 -y 210 -defaultsOSRD
preplace port FIXED_IO -pg 1 -y 230 -defaultsOSRD
preplace inst axi_interconnect -pg 1 -lvl 2 -y 200 -defaultsOSRD
preplace inst hls_snn_izikevich_0 -pg 1 -lvl 1 -y 320 -defaultsOSRD
preplace inst zynq -pg 1 -lvl 3 -y 640 -defaultsOSRD
preplace netloc processing_system7_0_DDR 1 3 1 NJ
preplace netloc S_AXI_HP0_1 1 2 1 N
preplace netloc processing_system7_0_M_AXI_GP0 1 1 3 270 10 NJ 10 1150
preplace netloc axi_interconnect_mm2s_introut0 1 2 1 690
preplace netloc S_AXI_HP3_1 1 2 1 730
preplace netloc S_AXI_HP1_1 1 2 1 750
preplace netloc axi_interconnect_M_AXIS_MM2S 1 0 3 -60 430 NJ 430 600
preplace netloc axi_interconnect_mm2s_introut1 1 2 1 670
preplace netloc axi_interconnect_mm2s_introut2 1 2 1 660
preplace netloc S_AXI_HP2_1 1 2 1 740
preplace netloc axi_interconnect_mm2s_introut3 1 2 1 650
preplace netloc rst_processing_system7_0_100M_peripheral_aresetn 1 0 4 -70 490 290 400 NJ 110 1130
preplace netloc int_dma_0_rx_1 1 2 1 710
preplace netloc processing_system7_0_FIXED_IO 1 3 1 NJ
preplace netloc axi_interconnect_M_AXIS_MM2S1 1 0 3 -50 440 NJ 440 590
preplace netloc axi_interconnect_M_AXIS_MM2S2 1 0 3 -100 460 NJ 460 620
preplace netloc axi_interconnect_M_AXIS_MM2S3 1 0 3 -90 470 NJ 470 610
preplace netloc hls_snn_izikevich_0_output_stream 1 1 1 270
preplace netloc rst_processing_system7_0_100M_interconnect_aresetn 1 1 3 300 380 NJ 80 1160
preplace netloc processing_system7_0_FCLK_CLK0 1 0 4 -80 480 280 390 NJ 100 1140
preplace netloc axi_interconnect_M00_AXI 1 0 3 -110 450 NJ 450 630
preplace netloc hls_snn_izikevich_0_interrupt 1 1 2 NJ 420 640
levelinfo -pg 1 -130 110 450 940 1200 -top 0 -bot 1240
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


