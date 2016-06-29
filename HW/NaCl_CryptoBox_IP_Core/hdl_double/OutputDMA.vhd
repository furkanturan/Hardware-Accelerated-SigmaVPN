library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity OutputDMA is
    port (
        INIT            : in  std_logic; 
        
        D_IN            : in  std_logic_vector(511 downto 0);
        
        INX32_START     : in  std_logic_vector(4 downto 0);
        INX32_STOP      : in  std_logic_vector(4 downto 0);
        INX32_SEL       : out std_logic;
        
        LAST            : in  std_logic;
                
        DONE            : out std_logic;
                    
        M_AXIS_ACLK     : in  std_logic;
        M_AXIS_ARESETN  : in  std_logic;
        
        -- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
        M_AXIS_TVALID   : out std_logic;
        -- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
        M_AXIS_TDATA    : out std_logic_vector(31 downto 0);
        -- TLAST indicates the boundary of a packet.
        M_AXIS_TLAST    : out std_logic;
        -- TREADY indicates that the slave can accept a transfer in the current cycle.
        M_AXIS_TREADY   : in  std_logic
    );
end OutputDMA;

architecture Behavioral of OutputDMA is

    -- Build an enumerated type for the state machine
	type state_type is (s_wait_init, s_write_data);
	
	-- Register to hold the current state
	signal state       : state_type := s_wait_init;
	
	signal wordcounter : std_logic_vector(4 downto 0) := (others => '0');
    
    signal tlast       : std_logic;
    signal tvalid      : std_logic;
    
    signal data        : std_logic_vector(31 downto 0) := (others => '0');
    
    signal index       : std_logic_vector(8 downto 0) := (others => '0'); 
    
    signal reg_stop   : std_logic_vector(4 downto 0) := (others => '0');
    signal reg_last   : std_logic_vector(4 downto 0) := (others => '0');
    
    signal sig_done     : std_logic := '0';
    
begin

    index <= wordcounter(3 downto 0) & "00000";
    M_AXIS_TDATA      <= D_IN( to_integer(unsigned(index)) + 31 downto to_integer(unsigned(index)));
    
    M_AXIS_TVALID   <= tvalid;
    M_AXIS_TLAST    <= tlast;  
    
    DONE <= sig_done;
    
    INX32_SEL       <= wordcounter(4);
    
    process (M_AXIS_ACLK)
    begin
        if (M_AXIS_ACLK'event and M_AXIS_ACLK = '1') then
            
            if (M_AXIS_ARESETN = '0') then
                state <= s_wait_init;
                sig_done <= '0';
            else
                
                case state is
                
                    when s_wait_init =>
                        
                        if INIT = '0' then
                            state <= s_wait_init;
                            
                            tvalid <= '0';
                            tlast <= '0';
                            
                            sig_done <= sig_done;
                            
                        else
                            state <= s_write_data;
                                                    
                            tvalid <= '1';
                            tlast <= '0';                              
                            
                            sig_done <= '0';
                                
                            wordcounter <= INX32_START;
                            reg_stop    <= INX32_STOP;
                            reg_last    <= INX32_STOP - '1';
                            
                        end if; 
                                        
                    when s_write_data =>
                        
                        if M_AXIS_TREADY = '0' then
                            wordcounter <= wordcounter;
                        else                            
                            wordcounter <= wordcounter + 1;                      
                        end if; 
                        
                        if wordcounter = reg_stop then
                            state <= s_wait_init;                            
                            tvalid <= '0'; 
                            
                            sig_done <= '1';   
                            
                        else
                            state <= s_write_data;                                                    
                            tvalid <= '1';  
                            
                            sig_done <= sig_done;                             
                        end if;
                        
                        if wordcounter = reg_last and LAST='1' then 
                            tlast <= '1';
                        else
                            tlast <= '0';                             
                        end if; 
                                                               
                                     
                    when others =>
                        null;
                        
                end case;
            end if; 
        end if;  
    end process;
end Behavioral;