-- (c) Copyright 1995-2015 Xilinx, Inc. All rights reserved.
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

-- IP VLNV: fturan:user:CryptoCP:1.0
-- IP Revision: 69

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY system_CryptoCP_0_0 IS
  PORT (
    done : OUT STD_LOGIC;
    ramtocp_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    ramtocp_tlast : IN STD_LOGIC;
    ramtocp_tvalid : IN STD_LOGIC;
    ramtocp_tready : OUT STD_LOGIC;
    ramtocp_aclk : IN STD_LOGIC;
    ramtocp_aresetn : IN STD_LOGIC;
    cptoram_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    cptoram_tlast : OUT STD_LOGIC;
    cptoram_tvalid : OUT STD_LOGIC;
    cptoram_tready : IN STD_LOGIC;
    process_aclk : IN STD_LOGIC;
    process_aresetn : IN STD_LOGIC;
    cptoram_aclk : IN STD_LOGIC;
    cptoram_aresetn : IN STD_LOGIC;
    dmactrl_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    dmactrl_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    dmactrl_awvalid : OUT STD_LOGIC;
    dmactrl_awready : IN STD_LOGIC;
    dmactrl_wdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    dmactrl_wstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    dmactrl_wvalid : OUT STD_LOGIC;
    dmactrl_wready : IN STD_LOGIC;
    dmactrl_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    dmactrl_bvalid : IN STD_LOGIC;
    dmactrl_bready : OUT STD_LOGIC;
    dmactrl_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    dmactrl_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    dmactrl_arvalid : OUT STD_LOGIC;
    dmactrl_arready : IN STD_LOGIC;
    dmactrl_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    dmactrl_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    dmactrl_rvalid : IN STD_LOGIC;
    dmactrl_rready : OUT STD_LOGIC;
    dmactrl_aclk : IN STD_LOGIC;
    dmactrl_aresetn : IN STD_LOGIC
  );
END system_CryptoCP_0_0;

ARCHITECTURE system_CryptoCP_0_0_arch OF system_CryptoCP_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : string;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF system_CryptoCP_0_0_arch: ARCHITECTURE IS "yes";

  COMPONENT CryptoCP_v1_0 IS
    GENERIC (
      DATA_LENGTH : INTEGER;
      DATA_WIDTH : INTEGER;
      RAM_OFFSET : STD_LOGIC_VECTOR;
      DMA_BASE_ADDRESS : STD_LOGIC_VECTOR
    );
    PORT (
      done : OUT STD_LOGIC;
      ramtocp_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      ramtocp_tlast : IN STD_LOGIC;
      ramtocp_tvalid : IN STD_LOGIC;
      ramtocp_tready : OUT STD_LOGIC;
      ramtocp_aclk : IN STD_LOGIC;
      ramtocp_aresetn : IN STD_LOGIC;
      cptoram_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      cptoram_tlast : OUT STD_LOGIC;
      cptoram_tvalid : OUT STD_LOGIC;
      cptoram_tready : IN STD_LOGIC;
      process_aclk : IN STD_LOGIC;
      process_aresetn : IN STD_LOGIC;
      cptoram_aclk : IN STD_LOGIC;
      cptoram_aresetn : IN STD_LOGIC;
      dmactrl_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      dmactrl_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      dmactrl_awvalid : OUT STD_LOGIC;
      dmactrl_awready : IN STD_LOGIC;
      dmactrl_wdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      dmactrl_wstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      dmactrl_wvalid : OUT STD_LOGIC;
      dmactrl_wready : IN STD_LOGIC;
      dmactrl_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      dmactrl_bvalid : IN STD_LOGIC;
      dmactrl_bready : OUT STD_LOGIC;
      dmactrl_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      dmactrl_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      dmactrl_arvalid : OUT STD_LOGIC;
      dmactrl_arready : IN STD_LOGIC;
      dmactrl_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      dmactrl_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      dmactrl_rvalid : IN STD_LOGIC;
      dmactrl_rready : OUT STD_LOGIC;
      dmactrl_aclk : IN STD_LOGIC;
      dmactrl_aresetn : IN STD_LOGIC
    );
  END COMPONENT CryptoCP_v1_0;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF system_CryptoCP_0_0_arch: ARCHITECTURE IS "CryptoCP_v1_0,Vivado 2014.3.1";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF system_CryptoCP_0_0_arch : ARCHITECTURE IS "system_CryptoCP_0_0,CryptoCP_v1_0,{}";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF ramtocp_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 RAMtoCP TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF ramtocp_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 RAMtoCP TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF ramtocp_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 RAMtoCP TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF ramtocp_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 RAMtoCP TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF ramtocp_aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 RAMtoCP_CLK CLK";
  ATTRIBUTE X_INTERFACE_INFO OF ramtocp_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 RAMtoCP_RST RST";
  ATTRIBUTE X_INTERFACE_INFO OF cptoram_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 CPtoRAM TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF cptoram_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 CPtoRAM TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF cptoram_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 CPtoRAM TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF cptoram_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 CPtoRAM TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF cptoram_aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 CPtoRAM_CLK CLK";
  ATTRIBUTE X_INTERFACE_INFO OF cptoram_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 CPtoRAM_RST RST";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_awaddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl AWADDR";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_awprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl AWPROT";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_awvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl AWVALID";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_awready: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_wdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_wstrb: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_wvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_wready: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_bresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_bvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_bready: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_araddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_arprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl ARPROT";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_arvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_arready: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_rdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_rresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_rvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_rready: SIGNAL IS "xilinx.com:interface:aximm:1.0 DMActrl RREADY";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 DMActrl_CLK CLK";
  ATTRIBUTE X_INTERFACE_INFO OF dmactrl_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 DMActrl_RST RST";
BEGIN
  U0 : CryptoCP_v1_0
    GENERIC MAP (
      DATA_LENGTH => 16,
      DATA_WIDTH => 32,
      RAM_OFFSET => X"AA000000",
      DMA_BASE_ADDRESS => X"40400000"
    )
    PORT MAP (
      done => done,
      ramtocp_tdata => ramtocp_tdata,
      ramtocp_tlast => ramtocp_tlast,
      ramtocp_tvalid => ramtocp_tvalid,
      ramtocp_tready => ramtocp_tready,
      ramtocp_aclk => ramtocp_aclk,
      ramtocp_aresetn => ramtocp_aresetn,
      cptoram_tdata => cptoram_tdata,
      cptoram_tlast => cptoram_tlast,
      cptoram_tvalid => cptoram_tvalid,
      cptoram_tready => cptoram_tready,
      process_aclk => process_aclk,
      process_aresetn => process_aresetn,
      cptoram_aclk => cptoram_aclk,
      cptoram_aresetn => cptoram_aresetn,
      dmactrl_awaddr => dmactrl_awaddr,
      dmactrl_awprot => dmactrl_awprot,
      dmactrl_awvalid => dmactrl_awvalid,
      dmactrl_awready => dmactrl_awready,
      dmactrl_wdata => dmactrl_wdata,
      dmactrl_wstrb => dmactrl_wstrb,
      dmactrl_wvalid => dmactrl_wvalid,
      dmactrl_wready => dmactrl_wready,
      dmactrl_bresp => dmactrl_bresp,
      dmactrl_bvalid => dmactrl_bvalid,
      dmactrl_bready => dmactrl_bready,
      dmactrl_araddr => dmactrl_araddr,
      dmactrl_arprot => dmactrl_arprot,
      dmactrl_arvalid => dmactrl_arvalid,
      dmactrl_arready => dmactrl_arready,
      dmactrl_rdata => dmactrl_rdata,
      dmactrl_rresp => dmactrl_rresp,
      dmactrl_rvalid => dmactrl_rvalid,
      dmactrl_rready => dmactrl_rready,
      dmactrl_aclk => dmactrl_aclk,
      dmactrl_aresetn => dmactrl_aresetn
    );
END system_CryptoCP_0_0_arch;
