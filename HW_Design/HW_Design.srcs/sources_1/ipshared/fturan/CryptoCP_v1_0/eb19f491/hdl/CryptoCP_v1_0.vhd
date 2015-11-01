library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CryptoCP_v1_0 is
	generic (
		-- Users to add parameters here
		DATA_LENGTH : integer := 8; 
        DATA_WIDTH	: integer := 32;
        RAM_OFFSET : std_logic_vector	:= x"AA000000";
        DMA_BASE_ADDRESS : std_logic_vector	:= x"40000000"
		-- User parameters ends
	);
	port (
		done : out std_logic;
		-- Ports of Axi Master Bus Interface DMActrl
		--dmactrl_init_axi_txn	: in std_logic;
		--dmactrl_error	: out std_logic;
		--dmactrl_txn_done : out std_logic;
		dmactrl_aclk	: in std_logic;
		dmactrl_aresetn	: in std_logic;
		dmactrl_awaddr	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		dmactrl_awprot	: out std_logic_vector(2 downto 0);
		dmactrl_awvalid	: out std_logic;
		dmactrl_awready	: in std_logic;
		dmactrl_wdata	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		dmactrl_wstrb	: out std_logic_vector(DATA_WIDTH/8-1 downto 0);
		dmactrl_wvalid	: out std_logic;
		dmactrl_wready	: in std_logic;
		dmactrl_bresp	: in std_logic_vector(1 downto 0);
		dmactrl_bvalid	: in std_logic;
		dmactrl_bready	: out std_logic;
		dmactrl_araddr	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		dmactrl_arprot	: out std_logic_vector(2 downto 0);
		dmactrl_arvalid	: out std_logic;
		dmactrl_arready	: in std_logic;
		dmactrl_rdata	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		dmactrl_rresp	: in std_logic_vector(1 downto 0);
		dmactrl_rvalid	: in std_logic;
		dmactrl_rready	: out std_logic;

		-- Ports of Axi Slave Bus Interface RAMtoCP
		ramtocp_aclk	: in std_logic;
		ramtocp_aresetn	: in std_logic;
		ramtocp_tready	: out std_logic;
		ramtocp_tdata	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		ramtocp_tlast	: in std_logic;
		ramtocp_tvalid	: in std_logic;

		-- Ports of Axi Master Bus Interface CPtoRAM
		cptoram_aclk	: in std_logic;
		cptoram_aresetn	: in std_logic;
		cptoram_tvalid	: out std_logic;
		cptoram_tdata	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		cptoram_tlast	: out std_logic;
		cptoram_tready	: in std_logic;
				
		-- Ports of Process Block
        process_aclk    : in std_logic;
        process_aresetn : in std_logic
	);
end CryptoCP_v1_0;

architecture arch_imp of CryptoCP_v1_0 is

	-- component declaration
	component CryptoCP_v1_0_DMActrl is
		generic (
        C_M_START_DATA_VALUE	: std_logic_vector	:= x"AA000000";
        C_M_TARGET_SLAVE_BASE_ADDR    : std_logic_vector    := x"40000000";
        C_M_AXI_ADDR_WIDTH    : integer    := 32;
        C_M_AXI_DATA_WIDTH    : integer    := 32;
        C_M_TRANSACTIONS_NUM    : integer    := 4
		);
		port (
		CONT_AXI_TXN    : in std_logic;
		INIT_AXI_TXN	: in std_logic;
		--ERROR	: out std_logic;
		TXN_DONE	: out std_logic;
		M_AXI_ACLK	: in std_logic;
		M_AXI_ARESETN	: in std_logic;
		M_AXI_AWADDR	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		M_AXI_AWPROT	: out std_logic_vector(2 downto 0);
		M_AXI_AWVALID	: out std_logic;
		M_AXI_AWREADY	: in std_logic;
		M_AXI_WDATA	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		M_AXI_WSTRB	: out std_logic_vector(DATA_WIDTH/8-1 downto 0);
		M_AXI_WVALID	: out std_logic;
		M_AXI_WREADY	: in std_logic;
		M_AXI_BRESP	: in std_logic_vector(1 downto 0);
		M_AXI_BVALID	: in std_logic;
		M_AXI_BREADY	: out std_logic;
		M_AXI_ARADDR	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		M_AXI_ARPROT	: out std_logic_vector(2 downto 0);
		M_AXI_ARVALID	: out std_logic;
		M_AXI_ARREADY	: in std_logic;
		M_AXI_RDATA	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		M_AXI_RRESP	: in std_logic_vector(1 downto 0);
		M_AXI_RVALID	: in std_logic;
		M_AXI_RREADY	: out std_logic
		);
	end component CryptoCP_v1_0_DMActrl;

	component CryptoCP_v1_0_RAMtoCP is
		generic (
        DATA_LENGTH : integer := 8; 
		DATA_WIDTH	: integer	:= 32
		);
		port (
		DATA0 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA1 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA3 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA4 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA5 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA6 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA7 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA8 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA9 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA10 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA11 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA12 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA13 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA14 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA15 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DONE0 : out std_logic;
		
		S_AXIS_ACLK	: in std_logic;
		S_AXIS_ARESETN	: in std_logic;
		S_AXIS_TREADY	: out std_logic;
		S_AXIS_TDATA	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		S_AXIS_TLAST	: in std_logic;
		S_AXIS_TVALID	: in std_logic
		);
	end component CryptoCP_v1_0_RAMtoCP;

	component CryptoCP_v1_0_CPtoRAM is
		generic (
        DATA_LENGTH : integer := 8; 
		DATA_WIDTH	: integer := 32
		);
		port ( 
		DATA0 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA3 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA4 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA5 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA6 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA7 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA8 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA9 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA10 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA11 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA12 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA13 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA14 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA15 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        INIT  : in std_logic; 
		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic
		);
	end component CryptoCP_v1_0_CPtoRAM;
	
	component CryptoCP_v1_0_Process is
        generic (
        DATA_LENGTH : integer := 8; 
        DATA_WIDTH  : integer := 32
        );
        port (
        DATA_IN_0 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_IN_1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_IN_2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_IN_3 : in std_logic_vector(DATA_WIDTH-1 downto 0);  
        DATA_IN_4 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_IN_5 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_IN_6 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_IN_7 : in std_logic_vector(DATA_WIDTH-1 downto 0); 
        DATA_IN_8 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_IN_9 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_IN_10 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_IN_11 : in std_logic_vector(DATA_WIDTH-1 downto 0);  
        DATA_IN_12 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_IN_13 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_IN_14 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_IN_15 : in std_logic_vector(DATA_WIDTH-1 downto 0);                  
        DATA_OUT_0 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_OUT_1 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_OUT_2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_OUT_3 : out std_logic_vector(DATA_WIDTH-1 downto 0);                  
        DATA_OUT_4 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_OUT_5 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_OUT_6 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_OUT_7 : out std_logic_vector(DATA_WIDTH-1 downto 0);                   
        DATA_OUT_8 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_OUT_9 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_OUT_10 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_OUT_11 : out std_logic_vector(DATA_WIDTH-1 downto 0);                  
        DATA_OUT_12 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_OUT_13 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_OUT_14 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_OUT_15 : out std_logic_vector(DATA_WIDTH-1 downto 0);         
        ACLK : in std_logic;
        ARESETN : in std_logic;                    
        INIT : in std_logic;
        DONE : out std_logic   
        );
    end component CryptoCP_v1_0_Process;

    signal ram_to_cp_done : std_logic := '0';
    
    signal ram_to_cp_data0 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data1 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data2 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data3 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data4 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data5 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data6 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data7 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data8 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data9 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data10 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data11 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data12 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data13 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data14 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_to_cp_data15 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

    signal  cp_to_ram_done : std_logic := '0';

    signal cp_to_ram_data0 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data1 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data2 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data3 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data4 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data5 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data6 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data7 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data8 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data9 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data10 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data11 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data12 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data13 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data14 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_data15 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');


begin

-- Instantiation of Axi Bus Interface DMActrl
CryptoCP_v1_0_DMActrl_inst : CryptoCP_v1_0_DMActrl
	generic map (
		C_M_START_DATA_VALUE => RAM_OFFSET,
        C_M_TARGET_SLAVE_BASE_ADDR => DMA_BASE_ADDRESS,
        C_M_AXI_ADDR_WIDTH => DATA_WIDTH,
        C_M_AXI_DATA_WIDTH => DATA_WIDTH,
        C_M_TRANSACTIONS_NUM => DATA_LENGTH
	)
	port map (
	   CONT_AXI_TXN	=> cp_to_ram_done,
		INIT_AXI_TXN	=> ramtocp_tvalid,
		--ERROR	=> dmactrl_error,
		TXN_DONE	=> done,
		M_AXI_ACLK	=> dmactrl_aclk,
		M_AXI_ARESETN	=> dmactrl_aresetn,
		M_AXI_AWADDR	=> dmactrl_awaddr,
		M_AXI_AWPROT	=> dmactrl_awprot,
		M_AXI_AWVALID	=> dmactrl_awvalid,
		M_AXI_AWREADY	=> dmactrl_awready,
		M_AXI_WDATA	=> dmactrl_wdata,
		M_AXI_WSTRB	=> dmactrl_wstrb,
		M_AXI_WVALID	=> dmactrl_wvalid,
		M_AXI_WREADY	=> dmactrl_wready,
		M_AXI_BRESP	=> dmactrl_bresp,
		M_AXI_BVALID	=> dmactrl_bvalid,
		M_AXI_BREADY	=> dmactrl_bready,
		M_AXI_ARADDR	=> dmactrl_araddr,
		M_AXI_ARPROT	=> dmactrl_arprot,
		M_AXI_ARVALID	=> dmactrl_arvalid,
		M_AXI_ARREADY	=> dmactrl_arready,
		M_AXI_RDATA	=> dmactrl_rdata,
		M_AXI_RRESP	=> dmactrl_rresp,
		M_AXI_RVALID	=> dmactrl_rvalid,
		M_AXI_RREADY	=> dmactrl_rready
	);

-- Instantiation of Axi Bus Interface RAMtoCP
CryptoCP_v1_0_RAMtoCP_inst : CryptoCP_v1_0_RAMtoCP
	generic map (
		DATA_LENGTH => DATA_LENGTH,
		DATA_WIDTH	=> DATA_WIDTH
	)
	port map (
        DATA0 => ram_to_cp_data0,
        DATA1 => ram_to_cp_data1,
        DATA2 => ram_to_cp_data2,
        DATA3 => ram_to_cp_data3,
        DATA4 => ram_to_cp_data4,
        DATA5 => ram_to_cp_data5,
        DATA6 => ram_to_cp_data6,
        DATA7 => ram_to_cp_data7,
        DATA8 => ram_to_cp_data8,
        DATA9 => ram_to_cp_data9,
        DATA10 => ram_to_cp_data10,
        DATA11 => ram_to_cp_data11,
        DATA12 => ram_to_cp_data12,
        DATA13 => ram_to_cp_data13,
        DATA14 => ram_to_cp_data14,
        DATA15 => ram_to_cp_data15,
        DONE0 => ram_to_cp_done,
        S_AXIS_ACLK	=> ramtocp_aclk,
		S_AXIS_ARESETN	=> ramtocp_aresetn,
		S_AXIS_TREADY	=> ramtocp_tready,
		S_AXIS_TDATA	=> ramtocp_tdata,
		S_AXIS_TLAST	=> ramtocp_tlast,
		S_AXIS_TVALID	=> ramtocp_tvalid
	);

-- Instantiation of Axi Bus Interface CPtoRAM
CryptoCP_v1_0_CPtoRAM_inst : CryptoCP_v1_0_CPtoRAM
	generic map (
		DATA_LENGTH => DATA_LENGTH,
		DATA_WIDTH	=> DATA_WIDTH
	)
	port map (
        DATA0 => cp_to_ram_data0,
        DATA1 => cp_to_ram_data1,
        DATA2 => cp_to_ram_data2,
        DATA3 => cp_to_ram_data3,
        DATA4 => cp_to_ram_data4,
        DATA5 => cp_to_ram_data5,
        DATA6 => cp_to_ram_data6,
        DATA7 => cp_to_ram_data7,
        DATA8 => cp_to_ram_data8,
        DATA9 => cp_to_ram_data9,
        DATA10 => cp_to_ram_data10,
        DATA11 => cp_to_ram_data11,
        DATA12 => cp_to_ram_data12,
        DATA13 => cp_to_ram_data13,
        DATA14 => cp_to_ram_data14,
        DATA15 => cp_to_ram_data15,
        INIT  => cp_to_ram_done,
		M_AXIS_ACLK	=> cptoram_aclk,
		M_AXIS_ARESETN	=> cptoram_aresetn,
		M_AXIS_TVALID	=> cptoram_tvalid,
		M_AXIS_TDATA	=> cptoram_tdata,
		M_AXIS_TLAST	=> cptoram_tlast,
		M_AXIS_TREADY	=> cptoram_tready
	);
	
-- Instantiation of Axi Bus Interface CPtoRAM
CryptoCP_v1_0_Process_inst : CryptoCP_v1_0_Process
    generic map (
		DATA_LENGTH => DATA_LENGTH,
        DATA_WIDTH    => DATA_WIDTH
    )
    port map (
        DATA_IN_0 => ram_to_cp_data0,
        DATA_IN_1 => ram_to_cp_data1,
        DATA_IN_2 => ram_to_cp_data2,
        DATA_IN_3 => ram_to_cp_data3,  
        DATA_IN_4 => ram_to_cp_data4,
        DATA_IN_5 => ram_to_cp_data5,
        DATA_IN_6 => ram_to_cp_data6,
        DATA_IN_7 => ram_to_cp_data7, 
        DATA_IN_8 => ram_to_cp_data8,
        DATA_IN_9 => ram_to_cp_data9,
        DATA_IN_10 => ram_to_cp_data10,
        DATA_IN_11 => ram_to_cp_data11,  
        DATA_IN_12 => ram_to_cp_data12,
        DATA_IN_13 => ram_to_cp_data13,
        DATA_IN_14 => ram_to_cp_data14,
        DATA_IN_15 => ram_to_cp_data15,                   
        DATA_OUT_0 => cp_to_ram_data0,
        DATA_OUT_1 => cp_to_ram_data1,
        DATA_OUT_2 => cp_to_ram_data2,
        DATA_OUT_3 => cp_to_ram_data3,                
        DATA_OUT_4 => cp_to_ram_data4,
        DATA_OUT_5 => cp_to_ram_data5,
        DATA_OUT_6 => cp_to_ram_data6,
        DATA_OUT_7 => cp_to_ram_data7,                 
        DATA_OUT_8 => cp_to_ram_data8,
        DATA_OUT_9 => cp_to_ram_data9,
        DATA_OUT_10 => cp_to_ram_data10,
        DATA_OUT_11 => cp_to_ram_data11,                
        DATA_OUT_12 => cp_to_ram_data12,
        DATA_OUT_13 => cp_to_ram_data13,
        DATA_OUT_14 => cp_to_ram_data14,
        DATA_OUT_15 => cp_to_ram_data15,
        ACLK => process_aclk,
        ARESETN => process_aresetn,                    
        INIT => ram_to_cp_done,
        DONE => cp_to_ram_done
    );

	-- Add user logic here
    --done0 <= cp_to_ram_done;
	-- User logic ends

end arch_imp;