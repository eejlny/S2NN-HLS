############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 2015 Xilinx Inc. All rights reserved.
############################################################
open_project hls
set_top hls_snn_izikevich
add_files src/snn_config.h
add_files src/common/snn_defs.h
add_files src/common/snn_env.h
add_files src/hw/snn_izikevich.h
add_files src/hw/snn_izikevich_axi.h
add_files src/hw/snn_izikevich_top.cpp
add_files src/common/snn_network.h
add_files src/common/snn_types.h
add_files -tb src/common/snn_start.h
add_files -tb src/common/snn_results.h
add_files -tb src/networks/snn_network_xor.h
add_files -tb src/networks/snn_network_random.h
add_files -tb src/networks/snn_network_pattern.h
add_files -tb src/networks/snn_network_defs.h
add_files -tb src/networks/snn_network_adder.h
add_files -tb src/sw/snn_izikevich_sw.h
add_files -tb src/hw/snn_izikevich_hw_sim.h
add_files -tb src/main_hls.cpp
open_solution "solution"
set_part {xc7z020clg484-1}
create_clock -period 8 -name default
#source "./hls/solution/directives.tcl"
csim_design -setup
csynth_design
cosim_design
export_design -format ip_catalog
