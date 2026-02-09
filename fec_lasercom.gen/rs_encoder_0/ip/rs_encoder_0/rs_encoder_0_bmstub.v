// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// -------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

(* BLOCK_STUB = "true" *)
module rs_encoder_0 (
  aclk,
  s_axis_input_tdata,
  s_axis_input_tvalid,
  s_axis_input_tready,
  s_axis_input_tlast,
  m_axis_output_tdata,
  m_axis_output_tvalid,
  m_axis_output_tready,
  m_axis_output_tlast,
  event_s_input_tlast_missing,
  event_s_input_tlast_unexpected
);

  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk_intf CLK" *)
  (* X_INTERFACE_MODE = "slave aclk_intf" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aclk_intf, ASSOCIATED_BUSIF M_AXIS_OUTPUT:S_AXIS_CTRL:S_AXIS_INPUT, ASSOCIATED_RESET aresetn, ASSOCIATED_CLKEN aclken, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN , ASSOCIATED_PORT , INSERT_VIP 0" *)
  input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TDATA" *)
  (* X_INTERFACE_MODE = "slave S_AXIS_INPUT" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_INPUT, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN , LAYERED_METADATA undef, INSERT_VIP 0" *)
  input [7:0]s_axis_input_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TVALID" *)
  input s_axis_input_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TREADY" *)
  output s_axis_input_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TLAST" *)
  input s_axis_input_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TDATA" *)
  (* X_INTERFACE_MODE = "master M_AXIS_OUTPUT" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS_OUTPUT, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN , LAYERED_METADATA undef, INSERT_VIP 0" *)
  output [7:0]m_axis_output_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TVALID" *)
  output m_axis_output_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TREADY" *)
  input m_axis_output_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TLAST" *)
  output m_axis_output_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 event_s_input_tlast_missing_intf INTERRUPT" *)
  (* X_INTERFACE_MODE = "master event_s_input_tlast_missing_intf" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME event_s_input_tlast_missing_intf, SENSITIVITY EDGE_RISING, PortWidth 1" *)
  output event_s_input_tlast_missing;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 event_s_input_tlast_unexpected_intf INTERRUPT" *)
  (* X_INTERFACE_MODE = "master event_s_input_tlast_unexpected_intf" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME event_s_input_tlast_unexpected_intf, SENSITIVITY EDGE_RISING, PortWidth 1" *)
  output event_s_input_tlast_unexpected;

  // stub module has no contents

endmodule
