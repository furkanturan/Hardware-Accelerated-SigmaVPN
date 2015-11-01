library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CryptoCP_v1_0_DMActrl is
	generic (
	
		C_M_START_DATA_VALUE	: std_logic_vector	:= x"AA000000";
		C_M_TARGET_SLAVE_BASE_ADDR	: std_logic_vector	:= x"40000000";
		
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 32;
		C_M_TRANSACTIONS_NUM	: integer	:= 4
	);
	port (
        CONT_AXI_TXN : in std_logic;
        INIT_AXI_TXN : in std_logic;
        --ERROR    : out std_logic;
		TXN_DONE	: out std_logic;
		
		-- AXI clock signal
		M_AXI_ACLK	: in std_logic;
		-- AXI active low reset signal
		M_AXI_ARESETN	: in std_logic;
		-- Master Interface Write Address Channel ports. Write address (issued by master)
		M_AXI_AWADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type.
    -- This signal indicates the privilege and security level of the transaction,
    -- and whether the transaction is a data access or an instruction access.
		M_AXI_AWPROT	: out std_logic_vector(2 downto 0);
		-- Write address valid. 
    -- This signal indicates that the master signaling valid write address and control information.
		M_AXI_AWVALID	: out std_logic;
		-- Write address ready. 
    -- This signal indicates that the slave is ready to accept an address and associated control signals.
		M_AXI_AWREADY	: in std_logic;
		-- Master Interface Write Data Channel ports. Write data (issued by master)
		M_AXI_WDATA	: out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. 
    -- This signal indicates which byte lanes hold valid data.
    -- There is one write strobe bit for each eight bits of the write data bus.
		M_AXI_WSTRB	: out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
		-- Write valid. This signal indicates that valid write data and strobes are available.
		M_AXI_WVALID	: out std_logic;
		-- Write ready. This signal indicates that the slave can accept the write data.
		M_AXI_WREADY	: in std_logic;
		-- Master Interface Write Response Channel ports. 
    -- This signal indicates the status of the write transaction.
		M_AXI_BRESP	: in std_logic_vector(1 downto 0);
		-- Write response valid. 
    -- This signal indicates that the channel is signaling a valid write response
		M_AXI_BVALID	: in std_logic;
		-- Response ready. This signal indicates that the master can accept a write response.
		M_AXI_BREADY	: out std_logic;
		-- Master Interface Read Address Channel ports. Read address (issued by master)
		M_AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. 
    -- This signal indicates the privilege and security level of the transaction, 
    -- and whether the transaction is a data access or an instruction access.
		M_AXI_ARPROT	: out std_logic_vector(2 downto 0);
		-- Read address valid. 
    -- This signal indicates that the channel is signaling valid read address and control information.
		M_AXI_ARVALID	: out std_logic;
		-- Read address ready. 
    -- This signal indicates that the slave is ready to accept an address and associated control signals.
		M_AXI_ARREADY	: in std_logic;
		-- Master Interface Read Data Channel ports. Read data (issued by slave)
		M_AXI_RDATA	: in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the read transfer.
		M_AXI_RRESP	: in std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is signaling the required read data.
		M_AXI_RVALID	: in std_logic;
		-- Read ready. This signal indicates that the master can accept the read data and response information.
		M_AXI_RREADY	: out std_logic
	);
end CryptoCP_v1_0_DMActrl;

architecture implementation of CryptoCP_v1_0_DMActrl is

    attribute DowngradeIPIdentifiedWarnings: string;
    attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";
        
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
    signal awaddr : std_logic_vector (C_M_AXI_ADDR_WIDTH-1 downto 0);
    signal wdata : std_logic_vector (31 downto 0);
    signal araddr : std_logic_vector (C_M_AXI_ADDR_WIDTH-1 downto 0);
    signal write_resp_error : std_logic;
    signal read_resp_error : std_logic;
        
    --Example-specific design signals
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

    signal DMABASEADDR : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);

    type state_type is (s0, s1, s2, s3, s4, s5);
    signal state       : state_type := s0;

begin
	
	DMABASEADDR <= C_M_TARGET_SLAVE_BASE_ADDR;
    -------------------- 
    -- Write Address (AW)
    
    M_AXI_AWADDR <= awaddr;
    
    M_AXI_WDATA <= wdata;
    M_AXI_AWPROT <= "000";
    M_AXI_AWVALID <= awvalid;
    
    --------------/
    --Write Data(W)
    
    M_AXI_WVALID <= wvalid;
    
    --Set all byte strobes ??????????????????????????????
    M_AXI_WSTRB <= (others => '1');
    
    --------------------
    --Write Response (B)
    
    M_AXI_BREADY <= bready;
    
    ------------------/   
    --Read Address (AR)
    
    M_AXI_ARADDR <= (others => '0');
    M_AXI_ARVALID <= '0'; --'0';
    M_AXI_ARPROT <= "000"; --3'b0;

    ----------------------------
    --Read and Read Response (R)
    
    M_AXI_RREADY <= '0'; --'0';

    -------------------------------------------------Will not needed
    --Example design I/O
    
    TXN_DONE <= done_success_int;


    ------------------------------------
    --Double register ddrx init done
    --to lite_master clock domain
    ------------------------------------
    process (M_AXI_ACLK)
    begin
        if M_AXI_ACLK'event and M_AXI_ACLK = '1' then
            if (M_AXI_ARESETN = '0') then
                inited <= '0';
                conted <= '0';
            else
                inited <= (inited or INIT_AXI_TXN) and (not done_success_int);
                conted <= (conted or CONT_AXI_TXN) and (not done_success_int);
            end if;
        end if;
    end process;

    ----------------------/
    --Write Address Channel
    ----------------------/
    process (M_AXI_ACLK)
    begin
    
        if (M_AXI_ACLK'event and M_AXI_ACLK = '1') then
            --Only VALID signals must be deasserted during reset per AXI spec
            --Consider inverting then registering active-low reset for higher fmax
            
            if M_AXI_ARESETN = '0' or inited = '0' then
                awvalid <= '0';
            
            --Address accepted by interconnect/slave
            elsif M_AXI_AWREADY = '1' and awvalid = '1' then
                awvalid <= '0';
            
            --Signal a new address/data command is available by user logic
            elsif push_write = '1' then
                awvalid <= '1';
                
            else
                awvalid <= awvalid;
            end if;
            
        end if;
    end process; 

      

    --------------------
    --Write Data Channel
    --------------------
    process (M_AXI_ACLK)
    begin
        if (M_AXI_ACLK'event and M_AXI_ACLK = '1') then
        
            if M_AXI_ARESETN = '0' or inited = '0' then
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

    ----------------------------
    --Write Response (B) Channel
    ----------------------------
    
    --Always accept write responses
    process (M_AXI_ACLK)
    begin
        if (M_AXI_ACLK'event and M_AXI_ACLK = '1') then
        
            if M_AXI_ARESETN = '0' or inited = '0' then
                bready <= '0';
            else
                bready <= '1';
            end if;
            
        end if;
    end process;

    --Flag write errors
    write_resp_error <= bready and M_AXI_BVALID and M_AXI_BRESP(1);
   
    --Number of address/data pairs specificed below
    
    write_index_sig <= std_logic_vector(write_index);
    process (write_index_sig, inited)
    begin
            
        awaddr <= x"00000000";
        wdata <= x"00000000";
            
        case write_index_sig is                
                
            when "000001" =>
                awaddr <= DMABASEADDR(31 downto 8) & x"34";
                wdata <= x"00001000";
            
            when "000010" =>
                awaddr <= DMABASEADDR(31 downto 8) & x"58";
                wdata <= x"00000040";                        
            
            when others =>
                awaddr <= x"00000000";
                wdata <= x"00000000";
            
--        case write_index_sig is           
--            when "000001" =>
--                awaddr <= DMABASEADDR(31 downto 8) & x"30";
--                wdata <= x"00001001";                
--                -- report "Programming MM2S CR register" severity note;
                
--            when "000010" =>
--                awaddr <= DMABASEADDR(31 downto 8) & x"34";
--                wdata <= x"00001000";
--                --report "Programming SR register" severity note;
            
--            when "000011" =>
--                awaddr <= DMABASEADDR(31 downto 8) & x"58";
--                wdata <= x"00000040";
--                --report "Programming Length register" severity note;
                        
--            when "000100" =>
--                awaddr <= DMABASEADDR(31 downto 8) & x"00";
--                wdata <= x"00000001";
            
--            when others =>
--                awaddr <= x"00000000";
--                wdata <= x"00000000";
        
        end case; 
    end process;

    ----------------------/
    --Main write controller
    ----------------------/
    
    process (M_AXI_ACLK)
    begin
        if (M_AXI_ACLK'event and M_AXI_ACLK = '1') then
            
            if (M_AXI_ARESETN = '0') then
                state <= s0;
            else
            
                case state is
                            
                    when s0 =>
                        if INIT_AXI_TXN = '1' then
                            state <= s1;
                        else
                            state <= s0;
                        end if;
                        
                        done_success_int <= '0';
                        
                    when s1 =>
                        state <= s2;
                        
                        done_success_int <= '0';
                        
                    when s2 =>
                    
                        if M_AXI_BVALID = '1' and write_index = C_NUM_COMMANDS and (conted = '1' or CONT_AXI_TXN ='1') then
                            state <= s4;
                            
                        elsif M_AXI_BVALID = '1' and write_index = C_NUM_COMMANDS then
                            state <= s3;
                            
                        elsif M_AXI_BVALID = '1' then
                            state <= s1;
                            
                        else
                            state <= s2;
                            
                        end if;
                                                
                        done_success_int <= '0';                        
                        
                    when s3 =>
                        if CONT_AXI_TXN = '1' then
                            state <= s4;
                        else
                            state <= s3;
                        end if;
                        
                        done_success_int <= '0';  
                        
                    when s4 =>
                        state <= s5;
                        
                        done_success_int <= '0'; 
                                            
                    when s5 =>
                                            
                        if M_AXI_BVALID = '1' and write_index = T_NUM_COMMANDS then
                            
                            state <= s0;
                            done_success_int <= '1';
                        
                        elsif M_AXI_BVALID = '1' then
                            state <= s4;
                            done_success_int <= '0'; 
                            
                        else
                            state <= s5;
                            done_success_int <= '0'; 
                            
                        end if;    
                        
                    when others =>
                         state <= s0;
                         done_success_int <= '0'; 
                end case;
            
            end if;
        
            case state is
                                                
                when s0 =>
                    push_write <= '0';
                    write_index <= (others => '0');
                    
                    
                when s1 =>
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
            
    
--    process (M_AXI_ACLK)
--    begin
--        if (M_AXI_ACLK'event and M_AXI_ACLK = '1') then
        
--            if (M_AXI_ARESETN = '0' or inited = '0') then
--                push_write <= '0';
--                write_index <= (others => '0');
            
--            --Request new write and increment write commmand counter
--            --elsif write_index <= 2 and (awvalid  = '0' and wvalid = '0' and last_write = '0' and push_write = '0') then
--            elsif write_index <= 1 and (M_AXI_BVALID = '1' and push_write = '0') then
--                push_write <= '1';
--                write_index <= write_index + 1;
            
--            elsif write_index > C_NUM_COMMANDS and comted = '1' and (M_AXI_BVALID = '1' and push_write = '0') then
--                push_write <= '0';
--                write_index <= write_index + 1;
                                
--            --elsif write_index > 2 and comted = '1' and (awvalid  = '0' and wvalid = '0' and last_write = '0' and push_write = '0') then
--            elsif write_index > 1 and comted = '1' and (M_AXI_BVALID = '1' and push_write = '0') then
--                push_write <= '1';
--                write_index <= write_index + 1;
                        
--            else            
--                push_write <= '0'; --Negate to generate a pulse
--                write_index <= write_index;
                
--            end if;
--        end if;
--    end process;
   
   
--    --Terminal write count   
--    last_write <= '1' when (write_index = C_NUM_COMMANDS) else '0';


--    process (M_AXI_ACLK)
--    begin
--        if (M_AXI_ACLK'event and M_AXI_ACLK = '1') then
        
--            if (M_AXI_ARESETN = '0' or inited = '0') then
--                writes_done <= '0';
            
--            --The last write should be associated with a valid response
--            elsif (last_write = '1' and M_AXI_BVALID = '1') then
--                writes_done <= '1';
                
--            else
--                writes_done <= writes_done;
                
--            end if;
--        end if;  
--    end process;

    ----------------------------------------/
    --DONE_SUCCESS output example calculation
    ----------------------------------------/
--    process (M_AXI_ACLK)
--    begin
--        if (M_AXI_ACLK'event and M_AXI_ACLK = '1') then
        
--            if (M_AXI_ARESETN = '0' or inited = '0') then
--                done_success_int <= '0';
            
--            --Are both writes and read done without error?
--            elsif (writes_done = '1' ) then
--                done_success_int <= '1';
                
--            else
--                done_success_int <= done_success_int;
                
--            end if;
--        end if;
--    end process;

end implementation;
