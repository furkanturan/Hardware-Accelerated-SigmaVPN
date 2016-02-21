library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DMA_Controller is
    generic 
    (
            DMA_SLAVE_BASE_ADDR	 : std_logic_vector	:= x"40000000"
	);
    port (
            CLK     : in std_logic;
            RSTN    : in std_logic;
            
            CONT    : in std_logic;
            INIT    : in std_logic;
            
            TLEN    : in std_logic_vector(15 downto 0);
            
            DONE    : out std_logic;
                        
                        
            
            M_AXI_AWADDR    : out std_logic_vector(31 downto 0);
            -- Write channel Protection type.
            -- This signal indicates the privilege and security level of the transaction,
            -- and whether the transaction is a data access or an instruction access.
            M_AXI_AWPROT    : out std_logic_vector(2 downto 0);
            -- Write address valid. 
        -- This signal indicates that the master signaling valid write address and control information.
            M_AXI_AWVALID    : out std_logic;
            -- Write address ready. 
        -- This signal indicates that the slave is ready to accept an address and associated control signals.
            M_AXI_AWREADY    : in std_logic;
            -- Master Interface Write Data Channel ports. Write data (issued by master)
            M_AXI_WDATA    : out std_logic_vector(31 downto 0);
            -- Write strobes. 
        -- This signal indicates which byte lanes hold valid data.
        -- There is one write strobe bit for each eight bits of the write data bus.
            M_AXI_WSTRB    : out std_logic_vector(3 downto 0);
            -- Write valid. This signal indicates that valid write data and strobes are available.
            M_AXI_WVALID    : out std_logic;
            -- Write ready. This signal indicates that the slave can accept the write data.
            M_AXI_WREADY    : in std_logic;
            -- Master Interface Write Response Channel ports. 
        -- This signal indicates the status of the write transaction.
            M_AXI_BRESP    : in std_logic_vector(1 downto 0);
            -- Write response valid. 
        -- This signal indicates that the channel is signaling a valid write response
            M_AXI_BVALID    : in std_logic;
            -- Response ready. This signal indicates that the master can accept a write response.
            M_AXI_BREADY    : out std_logic;
            -- Master Interface Read Address Channel ports. Read address (issued by master)
            M_AXI_ARADDR    : out std_logic_vector(31 downto 0);
            -- Protection type. 
        -- This signal indicates the privilege and security level of the transaction, 
        -- and whether the transaction is a data access or an instruction access.
            M_AXI_ARPROT    : out std_logic_vector(2 downto 0);
            -- Read address valid. 
        -- This signal indicates that the channel is signaling valid read address and control information.
            M_AXI_ARVALID    : out std_logic;
            -- Read address ready. 
        -- This signal indicates that the slave is ready to accept an address and associated control signals.
            M_AXI_ARREADY    : in std_logic;
            -- Master Interface Read Data Channel ports. Read data (issued by slave)
            M_AXI_RDATA    : in std_logic_vector(31 downto 0);
            -- Read response. This signal indicates the status of the read transfer.
            M_AXI_RRESP    : in std_logic_vector(1 downto 0);
            -- Read valid. This signal indicates that the channel is signaling the required read data.
            M_AXI_RVALID    : in std_logic;
            -- Read ready. This signal indicates that the master can accept the read data and response information.
            M_AXI_RREADY    : out std_logic
        );
end DMA_Controller;

architecture Behavioral of DMA_Controller is

    constant T_NUM_COMMANDS : integer := 2;
    constant C_NUM_COMMANDS : integer := 1;
    
    -- AXI4 signals
    signal awvalid : std_logic;
    signal wvalid : std_logic;
    signal push_write : std_logic;
    signal pop_read : std_logic;
    signal arvalid : std_logic;
    signal rready : std_logic;
    signal bready : std_logic;
    signal awaddr : std_logic_vector (31 downto 0);
    signal wdata : std_logic_vector (31 downto 0);
    signal araddr : std_logic_vector (31 downto 0);
    signal write_resp_error : std_logic;
    signal read_resp_error : std_logic;
        
    -- Design specific signals
    signal writes_done : std_logic;
    signal reads_done : std_logic;
    signal error_reg : std_logic;
    signal write_index : unsigned (5 downto 0) := (others => '0');
    signal write_index_sig : std_logic_vector (5 downto 0);
    signal read_index : std_logic_vector (5 downto 0);
    signal check_rdata : std_logic_vector (31 downto 0);
    signal done_success_int : std_logic;
    signal read_mismatch : std_logic;
    signal last_write : std_logic;
    signal last_read : std_logic;
    
    signal inited : std_logic; 
    signal conted : std_logic;   

    signal DMABASEADDR : std_logic_vector(31 downto 0);

    type state_type is (s_0, s_1, s2, s3, s4, s5);
    signal state       : state_type := s_0;

begin

    DMABASEADDR <= DMA_SLAVE_BASE_ADDR;
    
    -------------------- 
    -- Write Address (AW)
    
    M_AXI_AWADDR <= awaddr;
    
    M_AXI_WDATA <= wdata;
    M_AXI_AWPROT <= "000";
    M_AXI_AWVALID <= awvalid;
    
    --------------/
    --Write Data(W)
    
    M_AXI_WVALID <= wvalid;
    
    --Set all byte strobes ?
    M_AXI_WSTRB <= (others => '1');
    
    --------------------
    --Write Response (B)
    
    M_AXI_BREADY <= bready;
    
    ------------------/   
    --Read Address (AR)
    
    M_AXI_ARADDR <= (others => '0');
    M_AXI_ARVALID <= '0'; 
    M_AXI_ARPROT <= "000";

    ----------------------------
    --Read and Read Response (R)
    
    M_AXI_RREADY <= '0';

    
    DONE <= done_success_int;
    
    ---------------------------------------------
    -- DESIGN STARTS HERE
    ---------------------------------------------
    
    -- This design has two signals: init and cont
    -- INIT signal is used to initialize the DMA controller 
    -- which means DMA controller prepares transfer but
    -- transfer doesn't start
    -- CONT signal finilizes starts the transfer
        
    process (CLK)
    begin
        if CLK'event and CLK = '1' then
            if (RSTN = '0') then
                inited <= '0';
                conted <= '0';
            else
                inited <= (inited or INIT) and (not done_success_int);
                conted <= (conted or CONT) and (not done_success_int);
            end if;
        end if;
    end process;

    --Write Address Channel
    
    process (CLK)
    begin
    
        if (CLK'event and CLK = '1') then
        
            -- Only VALID signals must be deasserted during reset per AXI spec
            -- Consider inverting then registering active-low reset for higher fmax
            if RSTN = '0' or inited = '0' then
                awvalid <= '0';
            
            -- Address accepted by interconnect/slave
            elsif M_AXI_AWREADY = '1' and awvalid = '1' then
                awvalid <= '0';
            
            -- Signal a new address/data command is available by user logic
            elsif push_write = '1' then
                awvalid <= '1';
                
            else
                awvalid <= awvalid;
            end if;
            
        end if;
    end process; 

    
    -- Write Data Channel
    
    process (CLK)
    begin
        if (CLK'event and CLK = '1') then
        
            if RSTN = '0' or inited = '0' then
                wvalid <= '0';
            
            --Data accepted by interconnect/slave
            elsif M_AXI_WREADY = '1' and wvalid = '1' then
                wvalid <= '0';
            
            --Signal a new address/data command is available by user logic
            elsif push_write = '1' then
                wvalid <= '1';
                
            else
                wvalid <= wvalid;                
            end if;
            
        end if;
    end process; 

    
    -- Write Response (B) Channel
       
    -- Always accept write responses
    process (CLK)
    begin
        if (CLK'event and CLK = '1') then
        
            if RSTN = '0' or inited = '0' then
                bready <= '0';
            else
                bready <= '1';
            end if;
            
        end if;
    end process;

    --Flag write errors
    write_resp_error <= bready and M_AXI_BVALID and M_AXI_BRESP(1);
   
    -- Number of address/data pairs specificed below
    
    write_index_sig <= std_logic_vector(write_index);
    process (write_index_sig, inited)
    begin
            
        awaddr <= x"00000000";
        wdata <= x"00000000";
            
        case write_index_sig is                
                
            when "000001" =>
                awaddr <= DMABASEADDR(31 downto 8) & x"34";
                wdata <= x"00000001";
            
            when "000010" =>
                awaddr <= DMABASEADDR(31 downto 8) & x"58";
                wdata <= x"0000" & TLEN;                        
            
            when others =>
                awaddr <= x"00000000";
                wdata <= x"00000000";
            
        end case; 
    end process;
    
    -- Main write controller    
    
    process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            
            if (RSTN = '0') then
                state <= s_0;
            else
            
                case state is
                    
                    -- Wait for initialization
                    when s_0 =>
                        if INIT = '1' then
                            state <= s_1;
                        else
                            state <= s_0;
                        end if;
                        
                        done_success_int <= '0';
                    
                    -- Write data  
                    when s_1 =>
                        state <= s2;
                        
                        done_success_int <= '0';
                        
                    when s2 =>
                    
                        -- if write response received and all data (until CONT) is written knowing that CONT signal is asserted
                        if M_AXI_BVALID = '1' and write_index = C_NUM_COMMANDS and (conted = '1' or CONT ='1') then
                            state <= s4;
                         
                        -- if write response received and all data (until CONT) is written
                        elsif M_AXI_BVALID = '1' and write_index = C_NUM_COMMANDS then
                            state <= s3;
                        
                        -- if write response is received go back and write one more data
                        elsif M_AXI_BVALID = '1' then
                            state <= s_1;
                        
                        -- Wait until receiving write response    
                        else
                            state <= s2;
                            
                        end if;
                                                
                        done_success_int <= '0';                        
                        
                    when s3 =>
                        -- Wait till CONT signal
                        if CONT = '1' then
                            state <= s4;
                        else
                            state <= s3;
                        end if;
                        
                        done_success_int <= '0';  
                        
                    when s4 =>
                        -- Write data (for cont)
                        state <= s5;
                        
                        done_success_int <= '0'; 
                                            
                    when s5 =>
                    
                        -- if write response received and all data is written          
                        if M_AXI_BVALID = '1' and write_index = T_NUM_COMMANDS then
                            
                            state <= s_0;
                            done_success_int <= '1';
                        
                        -- if write response is received go back and write one more data
                        elsif M_AXI_BVALID = '1' then
                            state <= s4;
                            done_success_int <= '0'; 
                        
                         -- Wait until receiving write response    
                        else
                            state <= s5;
                            done_success_int <= '0'; 
                            
                        end if;    
                        
                    when others =>
                         state <= s_0;
                         done_success_int <= '0'; 
                end case;
            
            end if;
        
            case state is
                                                
                when s_0 =>
                    push_write <= '0';
                    write_index <= (others => '0');
                                        
                when s_1 =>
                    push_write <= '1';
                    write_index <= write_index + 1;
                    
                when s2 =>
                    push_write <= '0';
                    write_index <= write_index;                  
                    
                when s3 =>
                    push_write <= '0';
                    write_index <= write_index;                    
                    
                when s4 =>
                    push_write <= '1';
                    write_index <= write_index + 1;
                    
                when s5 =>
                    push_write <= '0';
                    write_index <= write_index;
                    
                    
                when others =>
                    push_write <= '0';
                    write_index <= write_index;
            end case;
        
        end if;
    end process;
            
end Behavioral;