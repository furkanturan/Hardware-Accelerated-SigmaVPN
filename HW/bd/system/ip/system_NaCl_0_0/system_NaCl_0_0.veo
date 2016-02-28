// (c) Copyright 1995-2016 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.

// IP VLNV: furkanturan:user:NaCl:1.0
// IP Revision: 70

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
system_NaCl_0_0 your_instance_name (
  .CLK(CLK),                      // input wire CLK
  .RSTN(RSTN),                    // input wire RSTN
  .S_AXIS_TREADY(S_AXIS_TREADY),  // output wire S_AXIS_TREADY
  .S_AXIS_TDATA(S_AXIS_TDATA),    // input wire [31 : 0] S_AXIS_TDATA
  .S_AXIS_TLAST(S_AXIS_TLAST),    // input wire S_AXIS_TLAST
  .S_AXIS_TVALID(S_AXIS_TVALID),  // input wire S_AXIS_TVALID
  .M_AXIS_TVALID(M_AXIS_TVALID),  // output wire M_AXIS_TVALID
  .M_AXIS_TDATA(M_AXIS_TDATA),    // output wire [31 : 0] M_AXIS_TDATA
  .M_AXIS_TLAST(M_AXIS_TLAST),    // output wire M_AXIS_TLAST
  .M_AXIS_TREADY(M_AXIS_TREADY),  // input wire M_AXIS_TREADY
  .M_AXI_AWADDR(M_AXI_AWADDR),    // output wire [31 : 0] M_AXI_AWADDR
  .M_AXI_AWPROT(M_AXI_AWPROT),    // output wire [2 : 0] M_AXI_AWPROT
  .M_AXI_AWVALID(M_AXI_AWVALID),  // output wire M_AXI_AWVALID
  .M_AXI_AWREADY(M_AXI_AWREADY),  // input wire M_AXI_AWREADY
  .M_AXI_WDATA(M_AXI_WDATA),      // output wire [31 : 0] M_AXI_WDATA
  .M_AXI_WSTRB(M_AXI_WSTRB),      // output wire [3 : 0] M_AXI_WSTRB
  .M_AXI_WVALID(M_AXI_WVALID),    // output wire M_AXI_WVALID
  .M_AXI_WREADY(M_AXI_WREADY),    // input wire M_AXI_WREADY
  .M_AXI_BRESP(M_AXI_BRESP),      // input wire [1 : 0] M_AXI_BRESP
  .M_AXI_BVALID(M_AXI_BVALID),    // input wire M_AXI_BVALID
  .M_AXI_BREADY(M_AXI_BREADY),    // output wire M_AXI_BREADY
  .M_AXI_ARADDR(M_AXI_ARADDR),    // output wire [31 : 0] M_AXI_ARADDR
  .M_AXI_ARPROT(M_AXI_ARPROT),    // output wire [2 : 0] M_AXI_ARPROT
  .M_AXI_ARVALID(M_AXI_ARVALID),  // output wire M_AXI_ARVALID
  .M_AXI_ARREADY(M_AXI_ARREADY),  // input wire M_AXI_ARREADY
  .M_AXI_RDATA(M_AXI_RDATA),      // input wire [31 : 0] M_AXI_RDATA
  .M_AXI_RRESP(M_AXI_RRESP),      // input wire [1 : 0] M_AXI_RRESP
  .M_AXI_RVALID(M_AXI_RVALID),    // input wire M_AXI_RVALID
  .M_AXI_RREADY(M_AXI_RREADY)    // output wire M_AXI_RREADY
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

