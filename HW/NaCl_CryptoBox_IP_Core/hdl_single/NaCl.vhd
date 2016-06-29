library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity NaCl is
    Generic (
        SLAVE_BASE_ADDR     : std_logic_vector    := x"40000000"
    );
    Port ( 
        CLK             : in  std_logic;
        RSTN            : in  std_logic;   
        
        S_AXIS_TREADY   : out std_logic;                
        S_AXIS_TDATA    : in  std_logic_vector(31 downto 0);         
        S_AXIS_TLAST    : in  std_logic;                 
        S_AXIS_TVALID   : in  std_logic;            
         
        M_AXIS_TVALID   : out std_logic;        
        M_AXIS_TDATA    : out std_logic_vector(31 downto 0);
        M_AXIS_TLAST    : out std_logic;        
        M_AXIS_TREADY   : in  std_logic;
        
        M_AXI_AWADDR    : out std_logic_vector(31 downto 0);
        M_AXI_AWPROT    : out std_logic_vector(2 downto 0); 
        M_AXI_AWVALID   : out std_logic;
        M_AXI_AWREADY   : in  std_logic;
        M_AXI_WDATA     : out std_logic_vector(31 downto 0);
        M_AXI_WSTRB     : out std_logic_vector(3 downto 0);
        M_AXI_WVALID    : out std_logic;
        M_AXI_WREADY    : in  std_logic;
        M_AXI_BRESP     : in  std_logic_vector(1 downto 0);
        M_AXI_BVALID    : in  std_logic;
        M_AXI_BREADY    : out std_logic;
        M_AXI_ARADDR    : out std_logic_vector(31 downto 0);
        M_AXI_ARPROT    : out std_logic_vector(2 downto 0);
        M_AXI_ARVALID   : out std_logic;
        M_AXI_ARREADY   : in  std_logic;
        M_AXI_RDATA     : in  std_logic_vector(31 downto 0);
        M_AXI_RRESP     : in  std_logic_vector(1 downto 0);
        M_AXI_RVALID    : in  std_logic;
        M_AXI_RREADY    : out std_logic
    );
end NaCl;

architecture Behavioral of NaCl is

    component NonceMUX is
    port (
        NONCE_IN : in STD_LOGIC_VECTOR ( 191 downto 0 );
        NONCE_OUT : out STD_LOGIC_VECTOR ( 127 downto 0 );
        CLK : in STD_LOGIC;
        SEL : in STD_LOGIC;
        RST : in STD_LOGIC;
        UPD : in STD_LOGIC
    );
    end component NonceMUX;
    
    component DMA_Controller is
    generic 
    (
        DMA_SLAVE_BASE_ADDR     : std_logic_vector    := x"40000000"
    );
    port (
        CLK : in STD_LOGIC;
        RSTN : in STD_LOGIC;
        CONT : in STD_LOGIC;
        INIT : in STD_LOGIC;
        TLEN : in STD_LOGIC_VECTOR ( 15 downto 0 );
        DONE : out STD_LOGIC;
        M_AXI_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
        M_AXI_AWPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
        M_AXI_AWVALID : out STD_LOGIC;
        M_AXI_AWREADY : in STD_LOGIC;
        M_AXI_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
        M_AXI_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
        M_AXI_WVALID : out STD_LOGIC;
        M_AXI_WREADY : in STD_LOGIC;
        M_AXI_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
        M_AXI_BVALID : in STD_LOGIC;
        M_AXI_BREADY : out STD_LOGIC;
        M_AXI_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
        M_AXI_ARPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
        M_AXI_ARVALID : out STD_LOGIC;
        M_AXI_ARREADY : in STD_LOGIC;
        M_AXI_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
        M_AXI_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
        M_AXI_RVALID : in STD_LOGIC;
        M_AXI_RREADY : out STD_LOGIC
    );
    end component DMA_Controller;
    
    component OutputDMA is
    port (
        INIT : in STD_LOGIC;
        D_IN : in STD_LOGIC_VECTOR ( 511 downto 0 );
        INX32_START : in STD_LOGIC_VECTOR ( 3 downto 0 );
        INX32_STOP : in STD_LOGIC_VECTOR ( 3 downto 0 );
        LAST : in STD_LOGIC;
        DONE : out STD_LOGIC;
        M_AXIS_ACLK : in STD_LOGIC;
        M_AXIS_ARESETN : in STD_LOGIC;
        M_AXIS_TVALID : out STD_LOGIC;
        M_AXIS_TDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
        M_AXIS_TLAST : out STD_LOGIC;
        M_AXIS_TREADY : in STD_LOGIC
    );
    end component OutputDMA;
    
    component hSalsa20 is
    port (
        CLK : in STD_LOGIC;
        INIT : in STD_LOGIC;
        DONE : out STD_LOGIC;
        SEL : in STD_LOGIC;
        D_IN : in STD_LOGIC_VECTOR ( 127 downto 0 );
        KEY : in STD_LOGIC_VECTOR ( 255 downto 0 );
        D_OUT : out STD_LOGIC_VECTOR ( 511 downto 0 )
    );
    end component hSalsa20;
    
    component InputReg is
    port (
        CMD : out STD_LOGIC_VECTOR ( 15 downto 0 );
        MLEN : out STD_LOGIC_VECTOR ( 15 downto 0 );
        NONCE : out STD_LOGIC_VECTOR ( 191 downto 0 );
        L1KEY : out STD_LOGIC_VECTOR ( 255 downto 0 );
        MESSAGE : out STD_LOGIC_VECTOR ( 511 downto 0 );
        L2KEY : out STD_LOGIC_VECTOR ( 255 downto 0 );
        L2KEY_IN : in STD_LOGIC_VECTOR ( 255 downto 0 );
        L2KEY_LOAD : in STD_LOGIC;
        RDY : in STD_LOGIC;
        DONE : out STD_LOGIC;
        S_AXIS_ACLK : in STD_LOGIC;
        S_AXIS_ARESETN : in STD_LOGIC;
        S_AXIS_TREADY : out STD_LOGIC;
        S_AXIS_TDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
        S_AXIS_TLAST : in STD_LOGIC;
        S_AXIS_TVALID : in STD_LOGIC
    );
    end component InputReg;
    
    component Controller is
    port (
        CLK : in STD_LOGIC;
        RSTN : in STD_LOGIC;
        INR_L2LOAD : out STD_LOGIC;
        INR_RDY : out STD_LOGIC;
        INR_RSTN: out STD_LOGIC;
        INR_DONE : in STD_LOGIC;
        INR_CMD : in STD_LOGIC_VECTOR ( 15 downto 0 );
        INR_MLEN : in STD_LOGIC_VECTOR ( 15 downto 0 );
        NOM_SEL : out STD_LOGIC;
        NOM_UPD : out STD_LOGIC;
        NOM_RST : out STD_LOGIC;
        KEY_SEL : out STD_LOGIC;
        HoS_INIT : out STD_LOGIC;
        HoS_SEL : out STD_LOGIC;
        HoS_DONE : in STD_LOGIC;
        REG_EN : out STD_LOGIC;
        DCR_EN : out STD_LOGIC;
        DCR_SEL : out STD_LOGIC;
        CIP_SEL : out STD_LOGIC_VECTOR ( 1 downto 0 );
        POL_INIT : out STD_LOGIC;
        POL_RSTN : out std_logic;
        POL_RSLOAD : out STD_LOGIC;
        POL_LAST : out STD_LOGIC;
        POL_LEN : out STD_LOGIC_VECTOR ( 3 downto 0 );
        POL_DONE : in STD_LOGIC;
        MAC_SEL : out STD_LOGIC;
        OUT_INIT : out STD_LOGIC;
        OUT_InSTART : out STD_LOGIC_VECTOR ( 3 downto 0 );
        OUT_InSTOP : out STD_LOGIC_VECTOR ( 3 downto 0 );
        OUT_LAST : out STD_LOGIC;
        OUT_DONE : in STD_LOGIC;
        DMA_INIT : out STD_LOGIC;
        DMA_CONT : out STD_LOGIC;
        DMA_TLEN : out STD_LOGIC_VECTOR ( 15 downto 0 )
    );
    end component Controller;
    
    component Poly1305 is
    port (
        CLK : in STD_LOGIC;
        RSTN : in STD_LOGIC;
        INIT : in STD_LOGIC;
        LOAD_RS : in STD_LOGIC;
        LAST : in STD_LOGIC;
        DONE : out STD_LOGIC;
        MSG : in STD_LOGIC_VECTOR ( 127 downto 0 );
        MSG_LEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
        KEY : in STD_LOGIC_VECTOR ( 255 downto 0 );
        MAC : out STD_LOGIC_VECTOR ( 127 downto 0 )
    );
    end component Poly1305;

    signal sig_INR_L2LOAD 	   : STD_LOGIC;
    signal sig_INR_RDY 	       : STD_LOGIC;
    signal sig_INR_RSTN 	   : STD_LOGIC;
    signal sig_INR_DONE 	   : STD_LOGIC;
    signal sig_INR_CMD 	       : STD_LOGIC_VECTOR ( 15 downto 0 );
    signal sig_INR_MLEN 	   : STD_LOGIC_VECTOR ( 15 downto 0 );
    signal sig_NOM_SEL 	       : STD_LOGIC;
    signal sig_NOM_UPD 	       : STD_LOGIC;
    signal sig_NOM_RST 	       : STD_LOGIC;
    signal sig_KEY_SEL 	       : STD_LOGIC;
    signal sig_HoS_INIT 	   : STD_LOGIC;
    signal sig_HoS_SEL 	       : STD_LOGIC;
    signal sig_HoS_DONE 	   : STD_LOGIC;
    signal sig_REG_EN 	       : STD_LOGIC;
    signal sig_DCR_EN 	       : STD_LOGIC;
    signal sig_DCR_SEL 	       : STD_LOGIC;
    signal sig_CIP_SEL 	       : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal sig_POL_INIT 	   : STD_LOGIC;
    signal sig_POL_RSTN  	   : STD_LOGIC;
    signal sig_POL_RSLOAD 	   : STD_LOGIC;
    signal sig_POL_LAST 	   : STD_LOGIC;
    signal sig_POL_LEN 	       : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal sig_POL_DONE 	   : STD_LOGIC;
    signal sig_MAC_SEL 	       : STD_LOGIC;
    signal sig_OUT_INIT 	   : STD_LOGIC;
    signal sig_OUT_InSTART 	   : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal sig_OUT_InSTOP 	   : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal sig_OUT_LAST 	   : STD_LOGIC;
    signal sig_OUT_DONE 	   : STD_LOGIC;
    signal sig_DMA_INIT 	   : STD_LOGIC;
    signal sig_DMA_CONT 	   : STD_LOGIC;
    signal sig_DMA_TLEN 	   : STD_LOGIC_VECTOR ( 15 downto 0 );

    signal sig_INR_NONCE       : std_logic_vector(191 downto 0);
    signal sig_INR_MESSAGE     : std_logic_vector(511 downto 0);
    signal sig_NMX_NONCE       : std_logic_vector(127 downto 0);     
    signal sig_L1_KEY          : std_logic_vector(255 downto 0);
    signal sig_L2_KEY          : std_logic_vector(255 downto 0);
    signal sig_HS_KEY          : std_logic_vector(255 downto 0);
    signal sig_HS20_OUT        : std_logic_vector(511 downto 0);
    signal sig_PLY_MUX_IN      : std_logic_vector(511 downto 0);
    signal sig_PLY_IN          : std_logic_vector(127 downto 0); 
    signal sig_PLY_MAC         : std_logic_vector(127 downto 0); 
    
    signal sig_MAC_MUX_OUT     : std_logic_vector(511 downto 0);
    
    signal reg_XOR             : std_logic_vector(511 downto 0) := (others => '0');
    signal reg_CIPHER          : std_logic_vector(511 downto 0) := (others => '0');
    
begin

    sig_HS_KEY      <= sig_L1_KEY   when sig_KEY_SEL = '0' else sig_L2_KEY;
    sig_PLY_MUX_IN  <= reg_XOR      when sig_DCR_SEL = '0' else reg_CIPHER;
    sig_MAC_MUX_OUT <= reg_XOR      when sig_MAC_SEL = '0' else (511 downto 128 => '0') & sig_PLY_MAC;

    sig_PLY_IN <=	sig_PLY_MUX_IN(127 downto   0) when sig_CIP_SEL = "00" else
                    sig_PLY_MUX_IN(255 downto 128) when sig_CIP_SEL = "01" else
                    sig_PLY_MUX_IN(383 downto 256) when sig_CIP_SEL = "10" else
                    sig_PLY_MUX_IN(511 downto 384) ;


    process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            
            if (sig_REG_EN = '1') then
                reg_XOR <= sig_HS20_OUT xor sig_INR_MESSAGE;
            else
                reg_XOR <= reg_XOR;
            end if;
        end if;
    end process;

    process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            
            if (sig_DCR_EN = '1') then
                reg_CIPHER <= sig_INR_MESSAGE;
            else
                reg_CIPHER <= reg_CIPHER;
            end if;
        end if;
    end process;

    NMX: component NonceMUX
    port map (        
        NONCE_IN        => sig_INR_NONCE,
        NONCE_OUT       => sig_NMX_NONCE,
        CLK             => CLK,
        SEL             => sig_NOM_SEL,
        RST             => sig_NOM_RST,
        UPD             => sig_NOM_UPD
    );
    
    DMC: component DMA_Controller
    generic map (
        DMA_SLAVE_BASE_ADDR => SLAVE_BASE_ADDR
    )
    port map (
        CLK                 => CLK,
        RSTN                => RSTN, 
        CONT                => sig_DMA_CONT,
        INIT                => sig_DMA_INIT,
        TLEN                => sig_DMA_TLEN, 
        --DONE                => 
        M_AXI_AWADDR 	    => M_AXI_AWADDR ,
        M_AXI_AWPROT        => M_AXI_AWPROT ,
        M_AXI_AWVALID       => M_AXI_AWVALID ,
        M_AXI_AWREADY       => M_AXI_AWREADY ,
        M_AXI_WDATA         => M_AXI_WDATA ,
        M_AXI_WSTRB         => M_AXI_WSTRB ,
        M_AXI_WVALID        => M_AXI_WVALID ,
        M_AXI_WREADY        => M_AXI_WREADY ,
        M_AXI_BRESP         => M_AXI_BRESP ,
        M_AXI_BVALID        => M_AXI_BVALID ,
        M_AXI_BREADY        => M_AXI_BREADY ,
        M_AXI_ARADDR        => M_AXI_ARADDR ,
        M_AXI_ARPROT        => M_AXI_ARPROT ,
        M_AXI_ARVALID       => M_AXI_ARVALID ,
        M_AXI_ARREADY       => M_AXI_ARREADY ,
        M_AXI_RDATA         => M_AXI_RDATA ,
        M_AXI_RRESP         => M_AXI_RRESP ,
        M_AXI_RVALID        => M_AXI_RVALID ,
        M_AXI_RREADY        => M_AXI_RREADY 
      );
      
      ODMA: component OutputDMA
      port map (
        INIT                => sig_OUT_INIT, 
        D_IN                => sig_MAC_MUX_OUT,
        INX32_START         => sig_OUT_InSTART,
        INX32_STOP          => sig_OUT_InSTOP,
        LAST                => sig_OUT_LAST,
        DONE                => sig_OUT_DONE,
        M_AXIS_ACLK         => CLK,
        M_AXIS_ARESETN      => RSTN,
        M_AXIS_TVALID 	    => M_AXIS_TVALID ,
        M_AXIS_TDATA        => M_AXIS_TDATA ,
        M_AXIS_TLAST        => M_AXIS_TLAST ,
        M_AXIS_TREADY       => M_AXIS_TREADY 
      );
            
      HS20: component hSalsa20
      port map (
        CLK                 => CLK,
        INIT                => sig_HoS_INIT,
        DONE                => sig_HoS_DONE,
        SEL                 => sig_HoS_SEL,
        D_IN                => sig_NMX_NONCE,
        KEY                 => sig_HS_KEY,
        D_OUT               => sig_HS20_OUT
      );
      
      INR: component InputReg
      port map (
        CMD                 => sig_INR_CMD,
        MLEN                => sig_INR_MLEN,
        NONCE               => sig_INR_NONCE,
        L1KEY               => sig_L1_KEY, 
        MESSAGE             => sig_INR_MESSAGE,
        L2KEY               => sig_L2_KEY,
        L2KEY_IN            => sig_HS20_OUT(255 downto 0), 
        L2KEY_LOAD          => sig_INR_L2LOAD,
        RDY                 => sig_INR_RDY,
        DONE                => sig_INR_DONE,
        S_AXIS_ACLK         => CLK,
        S_AXIS_ARESETN      => sig_INR_RSTN,
        S_AXIS_TREADY 	    => S_AXIS_TREADY ,
        S_AXIS_TDATA        => S_AXIS_TDATA ,
        S_AXIS_TLAST        => S_AXIS_TLAST ,
        S_AXIS_TVALID       => S_AXIS_TVALID
      );
     
      CNT: component Controller
      port map (
        CLK                 => CLK,
        RSTN                => RSTN,
        INR_L2LOAD          => sig_INR_L2LOAD,
        INR_RDY             => sig_INR_RDY,
        INR_RSTN            => sig_INR_RSTN,
        INR_DONE            => sig_INR_DONE,
        INR_CMD             => sig_INR_CMD,
        INR_MLEN            => sig_INR_MLEN,
        NOM_SEL             => sig_NOM_SEL,
        NOM_UPD             => sig_NOM_UPD,
        NOM_RST             => sig_NOM_RST,
        KEY_SEL             => sig_KEY_SEL,
        HoS_INIT            => sig_HoS_INIT,
        HoS_SEL             => sig_HoS_SEL,
        HoS_DONE            => sig_HoS_DONE,
        REG_EN              => sig_REG_EN,
        DCR_EN              => sig_DCR_EN,
        DCR_SEL             => sig_DCR_SEL,
        CIP_SEL             => sig_CIP_SEL,
        POL_INIT            => sig_POL_INIT,
        POL_RSTN            => sig_POL_RSTN, 
        POL_RSLOAD          => sig_POL_RSLOAD,
        POL_LAST            => sig_POL_LAST,
        POL_LEN             => sig_POL_LEN,
        POL_DONE            => sig_POL_DONE,
        MAC_SEL             => sig_MAC_SEL,
        OUT_INIT            => sig_OUT_INIT,
        OUT_InSTART         => sig_OUT_InSTART,
        OUT_InSTOP          => sig_OUT_InSTOP,
        OUT_LAST            => sig_OUT_LAST,
        OUT_DONE            => sig_OUT_DONE,
        DMA_INIT            => sig_DMA_INIT,
        DMA_CONT            => sig_DMA_CONT,
        DMA_TLEN            => sig_DMA_TLEN
      );
      
      PLY: component Poly1305
      port map (
        CLK                 => CLK,
        RSTN                => sig_POL_RSTN,
        INIT                => sig_POL_INIT,
        LOAD_RS             => sig_POL_RSLOAD,
        LAST                => sig_POL_LAST,
        DONE                => sig_POL_DONE,
        MSG                 => sig_PLY_IN,
        MSG_LEN             => sig_POL_LEN,
        KEY                 => sig_HS20_OUT(255 downto 0),
        MAC                 => sig_PLY_MAC
      );
   
end Behavioral;
