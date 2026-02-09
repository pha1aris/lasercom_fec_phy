// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Tue Jan 27 16:01:29 2026
// Host        : FSO-A running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top rs_encoder_0 -prefix
//               rs_encoder_0_ rs_encoder_0_stub.v
// Design      : rs_encoder_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu15eg-ffvb1156-2-i
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* CHECK_LICENSE_TYPE = "rs_encoder_0,rs_encoder_v9_0_22,{}" *) (* PARTIALLYOBFUSCATED *) (* core_generation_info = "rs_encoder_0,rs_encoder_v9_0_22,{x_ipProduct=Vivado 2024.2,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=rs_encoder,x_ipVersion=9.0,x_ipCoreRevision=22,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_HAS_ACLKEN=0,C_HAS_ARESETN=0,C_HAS_S_AXIS_CTRL=0,C_HAS_S_AXIS_INPUT_TUSER=0,C_HAS_M_AXIS_OUTPUT_TUSER=0,C_HAS_M_AXIS_OUTPUT_TREADY=1,C_S_AXIS_INPUT_TDATA_WIDTH=8,C_S_AXIS_INPUT_TUSER_WIDTH=1,C_S_AXIS_CTRL_TDATA_WIDTH=8,C_M_AXIS_OUTPUT_TDATA_WIDTH=8,C_M_AXIS_OUTPUT_TUSER_WIDTH=1,C_HAS_INFO=0,C_HAS_N_IN=0,C_HAS_R_IN=0,C_GEN_START=0,C_H=1,C_K=229,C_N=255,C_POLYNOMIAL=0,C_SPEC=0,C_SYMBOL_WIDTH=8,C_GEN_POLY_TYPE=0,C_NUM_CHANNELS=1,C_MEMSTYLE=2,C_OPTIMIZATION=2,C_MEM_INIT_PREFIX=rs_encoder_0,C_ELABORATION_DIR=./,C_XDEVICEFAMILY=zynquplus,C_FAMILY=zynquplus,x_ipLicense=rs_encoder@2013.03(bought)}" *) 
(* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "rs_encoder_v9_0_22,Vivado 2024.2" *) 
module rs_encoder_0(aclk, s_axis_input_tdata, 
  s_axis_input_tvalid, s_axis_input_tready, s_axis_input_tlast, m_axis_output_tdata, 
  m_axis_output_tvalid, m_axis_output_tready, m_axis_output_tlast, 
  event_s_input_tlast_missing, event_s_input_tlast_unexpected)
/* synthesis syn_black_box black_box_pad_pin="s_axis_input_tdata[7:0],s_axis_input_tvalid,s_axis_input_tready,s_axis_input_tlast,m_axis_output_tdata[7:0],m_axis_output_tvalid,m_axis_output_tready,m_axis_output_tlast,event_s_input_tlast_missing,event_s_input_tlast_unexpected" */
/* synthesis syn_force_seq_prim="aclk" */;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 aclk_intf CLK" *) (* x_interface_mode = "slave aclk_intf" *) (* x_interface_parameter = "XIL_INTERFACENAME aclk_intf, ASSOCIATED_BUSIF M_AXIS_OUTPUT:S_AXIS_CTRL:S_AXIS_INPUT, ASSOCIATED_RESET aresetn, ASSOCIATED_CLKEN aclken, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input aclk /* synthesis syn_isclock = 1 */;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TDATA" *) (* x_interface_mode = "slave S_AXIS_INPUT" *) (* x_interface_parameter = "XIL_INTERFACENAME S_AXIS_INPUT, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) input [7:0]s_axis_input_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TVALID" *) input s_axis_input_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TREADY" *) output s_axis_input_tready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TLAST" *) input s_axis_input_tlast;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TDATA" *) (* x_interface_mode = "master M_AXIS_OUTPUT" *) (* x_interface_parameter = "XIL_INTERFACENAME M_AXIS_OUTPUT, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) output [7:0]m_axis_output_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TVALID" *) output m_axis_output_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TREADY" *) input m_axis_output_tready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TLAST" *) output m_axis_output_tlast;
  (* x_interface_info = "xilinx.com:signal:interrupt:1.0 event_s_input_tlast_missing_intf INTERRUPT" *) (* x_interface_mode = "master event_s_input_tlast_missing_intf" *) (* x_interface_parameter = "XIL_INTERFACENAME event_s_input_tlast_missing_intf, SENSITIVITY EDGE_RISING, PortWidth 1" *) output event_s_input_tlast_missing;
  (* x_interface_info = "xilinx.com:signal:interrupt:1.0 event_s_input_tlast_unexpected_intf INTERRUPT" *) (* x_interface_mode = "master event_s_input_tlast_unexpected_intf" *) (* x_interface_parameter = "XIL_INTERFACENAME event_s_input_tlast_unexpected_intf, SENSITIVITY EDGE_RISING, PortWidth 1" *) output event_s_input_tlast_unexpected;
endmodule
