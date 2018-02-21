// ==============================================================
// File generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2015.4
// Copyright (C) 2015 Xilinx Inc. All rights reserved.
// 
// ==============================================================

// control
// 0x00 : Control signals
//        bit 0  - ap_start (Read/Write/COH)
//        bit 1  - ap_done (Read/COR)
//        bit 2  - ap_idle (Read)
//        bit 3  - ap_ready (Read)
//        bit 7  - auto_restart (Read/Write)
//        others - reserved
// 0x04 : Global Interrupt Enable Register
//        bit 0  - Global Interrupt Enable (Read/Write)
//        others - reserved
// 0x08 : IP Interrupt Enable Register (Read/Write)
//        bit 0  - Channel 0 (ap_done)
//        bit 1  - Channel 1 (ap_ready)
//        others - reserved
// 0x0c : IP Interrupt Status Register (Read/TOW)
//        bit 0  - Channel 0 (ap_done)
//        bit 1  - Channel 1 (ap_ready)
//        others - reserved
// 0x10 : Data signal of ap_return
//        bit 0  - ap_return[0] (Read)
//        others - reserved
// 0x18 : Data signal of state_V
//        bit 0  - state_V[0] (Read/Write)
//        others - reserved
// 0x1c : reserved
// 0x20 ~
// 0x3f : Memory 'p_input' (6 * 32b)
//        Word n : bit [31:0] - p_input[n]
// 0x40 ~
// 0x47 : Memory 'output_indexes' (2 * 32b)
//        Word n : bit [31:0] - output_indexes[n]
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define XHLS_SNN_IZIKEVICH_CONTROL_ADDR_AP_CTRL             0x00
#define XHLS_SNN_IZIKEVICH_CONTROL_ADDR_GIE                 0x04
#define XHLS_SNN_IZIKEVICH_CONTROL_ADDR_IER                 0x08
#define XHLS_SNN_IZIKEVICH_CONTROL_ADDR_ISR                 0x0c
#define XHLS_SNN_IZIKEVICH_CONTROL_ADDR_AP_RETURN           0x10
#define XHLS_SNN_IZIKEVICH_CONTROL_BITS_AP_RETURN           1
#define XHLS_SNN_IZIKEVICH_CONTROL_ADDR_STATE_V_DATA        0x18
#define XHLS_SNN_IZIKEVICH_CONTROL_BITS_STATE_V_DATA        1
#define XHLS_SNN_IZIKEVICH_CONTROL_ADDR_P_INPUT_BASE        0x20
#define XHLS_SNN_IZIKEVICH_CONTROL_ADDR_P_INPUT_HIGH        0x3f
#define XHLS_SNN_IZIKEVICH_CONTROL_WIDTH_P_INPUT            32
#define XHLS_SNN_IZIKEVICH_CONTROL_DEPTH_P_INPUT            6
#define XHLS_SNN_IZIKEVICH_CONTROL_ADDR_OUTPUT_INDEXES_BASE 0x40
#define XHLS_SNN_IZIKEVICH_CONTROL_ADDR_OUTPUT_INDEXES_HIGH 0x47
#define XHLS_SNN_IZIKEVICH_CONTROL_WIDTH_OUTPUT_INDEXES     32
#define XHLS_SNN_IZIKEVICH_CONTROL_DEPTH_OUTPUT_INDEXES     2
