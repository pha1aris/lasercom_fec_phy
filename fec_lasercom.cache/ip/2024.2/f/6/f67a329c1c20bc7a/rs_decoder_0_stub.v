// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Tue Jan 27 16:00:05 2026
// Host        : FSO-A running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ rs_decoder_0_stub.v
// Design      : rs_decoder_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu15eg-ffvb1156-2-i
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* CHECK_LICENSE_TYPE = "rs_decoder_0,rs_decoder_v9_0_23,{}" *) (* PARTIALLYOBFUSCATED *) (* core_generation_info = "rs_decoder_0,rs_decoder_v9_0_23,{x_ipProduct=Vivado 2024.2,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=rs_decoder,x_ipVersion=9.0,x_ipCoreRevision=23,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_HAS_ACLKEN=0,C_HAS_ARESETN=0,C_HAS_S_AXIS_CTRL=0,C_HAS_S_AXIS_INPUT_TUSER=0,C_HAS_M_AXIS_OUTPUT_TUSER=0,C_S_AXIS_INPUT_TDATA_WIDTH=16,C_S_AXIS_INPUT_TUSER_WIDTH=1,C_S_AXIS_CTRL_TDATA_WIDTH=8,C_M_AXIS_OUTPUT_TDATA_WIDTH=8,C_M_AXIS_OUTPUT_TUSER_WIDTH=1,C_M_AXIS_STAT_TDATA_WIDTH=16,C_HAS_DATA_DEL=0,C_HAS_ERASE=1,C_HAS_ERR_STATS=0,C_HAS_INFO=0,C_HAS_N_IN=0,C_HAS_R_IN=0,C_GEN_START=0,C_H=1,C_K=229,C_N=255,C_POLYNOMIAL=0,C_SPEC=0,C_SYMBOL_WIDTH=8,C_IGNORE_ILLEGAL_N_R=1,C_DEFINE_LEGAL_R_VALS=0,C_NUM_LEGAL_R_VALUES=2,C_LEGAL_R_VECTOR_FILE=no_coe_file_loaded,C_NUM_CHANNELS=1,C_NUM_PUNC_PATTERNS=0,C_PUNCTURE_SELECT_FILE=no_coe_file_loaded,C_PUNCTURE_VECTOR_FILE=no_coe_file_loaded,C_MEMSTYLE=2,C_OUTPUT_CHECK_SYMBOLS=0,C_OPTIMISATION=1,C_SELF_RECOVERING=0,C_MEM_INIT_PREFIX=rs_decoder_0,C_ELABORATION_DIR=./,C_XDEVICEFAMILY=zynquplus,C_FAMILY=zynquplus,x_ipLicense=rs_decoder@2013.03(bought)}" *) 
(* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "rs_decoder_v9_0_23,Vivado 2024.2" *) 
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(aclk, s_axis_input_tdata, 
  s_axis_input_tvalid, s_axis_input_tlast, s_axis_input_tready, m_axis_output_tdata, 
  m_axis_output_tvalid, m_axis_output_tready, m_axis_output_tlast, m_axis_stat_tdata, 
  m_axis_stat_tvalid, m_axis_stat_tready, event_s_input_tlast_missing, 
  event_s_input_tlast_unexpected, event_s_ctrl_tdata_invalid)
/* synthesis syn_black_box black_box_pad_pin="s_axis_input_tdata[15:0],s_axis_input_tvalid,s_axis_input_tlast,s_axis_input_tready,m_axis_output_tdata[7:0],m_axis_output_tvalid,m_axis_output_tready,m_axis_output_tlast,m_axis_stat_tdata[15:0],m_axis_stat_tvalid,m_axis_stat_tready,event_s_input_tlast_missing,event_s_input_tlast_unexpected,event_s_ctrl_tdata_invalid" */
/* synthesis syn_force_seq_prim="aclk" */;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 aclk_intf CLK" *) (* x_interface_mode = "slave aclk_intf" *) (* x_interface_parameter = "XIL_INTERFACENAME aclk_intf, ASSOCIATED_BUSIF M_AXIS_STAT:M_AXIS_OUTPUT:S_AXIS_CTRL:S_AXIS_INPUT, ASSOCIATED_RESET aresetn, ASSOCIATED_CLKEN aclken, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input aclk /* synthesis syn_isclock = 1 */;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TDATA" *) (* x_interface_mode = "slave S_AXIS_INPUT" *) (* x_interface_parameter = "XIL_INTERFACENAME S_AXIS_INPUT, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) input [15:0]s_axis_input_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TVALID" *) input s_axis_input_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TLAST" *) input s_axis_input_tlast;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TREADY" *) output s_axis_input_tready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TDATA" *) (* x_interface_mode = "master M_AXIS_OUTPUT" *) (* x_interface_parameter = "XIL_INTERFACENAME M_AXIS_OUTPUT, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) output [7:0]m_axis_output_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TVALID" *) output m_axis_output_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TREADY" *) input m_axis_output_tready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TLAST" *) output m_axis_output_tlast;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_STAT TDATA" *) (* x_interface_mode = "master M_AXIS_STAT" *) (* x_interface_parameter = "XIL_INTERFACENAME M_AXIS_STAT, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) output [15:0]m_axis_stat_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_STAT TVALID" *) output m_axis_stat_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_STAT TREADY" *) input m_axis_stat_tready;
  (* x_interface_info = "xilinx.com:signal:interrupt:1.0 event_s_input_tlast_missing_intf INTERRUPT" *) (* x_interface_mode = "master event_s_input_tlast_missing_intf" *) (* x_interface_parameter = "XIL_INTERFACENAME event_s_input_tlast_missing_intf, SENSITIVITY EDGE_RISING, PortWidth 1" *) output event_s_input_tlast_missing;
  (* x_interface_info = "xilinx.com:signal:interrupt:1.0 event_s_input_tlast_unexpected_intf INTERRUPT" *) (* x_interface_mode = "master event_s_input_tlast_unexpected_intf" *) (* x_interface_parameter = "XIL_INTERFACENAME event_s_input_tlast_unexpected_intf, SENSITIVITY EDGE_RISING, PortWidth 1" *) output event_s_input_tlast_unexpected;
  (* x_interface_info = "xilinx.com:signal:interrupt:1.0 event_s_ctrl_tdata_invalid_intf INTERRUPT" *) (* x_interface_mode = "master event_s_ctrl_tdata_invalid_intf" *) (* x_interface_parameter = "XIL_INTERFACENAME event_s_ctrl_tdata_invalid_intf, SENSITIVITY EDGE_RISING, PortWidth 1" *) output event_s_ctrl_tdata_invalid;
endmodule
