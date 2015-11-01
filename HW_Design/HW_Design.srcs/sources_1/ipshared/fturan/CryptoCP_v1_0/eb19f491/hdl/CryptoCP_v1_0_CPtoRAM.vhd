library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CryptoCP_v1_0_CPtoRAM is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXIS address bus. The slave accepts the read and write addresses of width DATA_WIDTH.
        DATA_LENGTH : integer := 8; 
        DATA_WIDTH	: integer := 32
		
	);
	port (
		-- Users to add ports here
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
        -- User ports ends
		-- Do not modify the ports beyond this line

		-- Global ports
		M_AXIS_ACLK	: in std_logic;
		-- 
		M_AXIS_ARESETN	: in std_logic;
		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		M_AXIS_TVALID	: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		M_AXIS_TDATA	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST	: out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY	: in std_logic
	);
end CryptoCP_v1_0_CPtoRAM;

architecture implementation of CryptoCP_v1_0_CPtoRAM is
	
	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s2, s3);
	
	-- Register to hold the current state
	signal state       : state_type := s0;
	
	signal wordcounter : integer range 0 to 16;
    
    signal tlast : std_logic;
    signal tvalid : std_logic;
    
    
    signal cp_to_ram_d0 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d1 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d2 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d3 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d4 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d5 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d6 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d7 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d8 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d9 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d10 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d11 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d12 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d13 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d14 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal cp_to_ram_d15 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    M_AXIS_TDATA <= cp_to_ram_d15;
    
    M_AXIS_TVALID <= tvalid;
    M_AXIS_TLAST <= tlast;    
    
    process (M_AXIS_ACLK)
    begin
        if (M_AXIS_ACLK'event and M_AXIS_ACLK = '1') then
            
            if (M_AXIS_ARESETN = '0') then
                state <= s0;
            else
                
                case state is
                
                    when s0 =>
                        
                        if INIT = '0' then
                            state <= s0;
                            
                            tvalid <= '0';
                            tlast <= '0';
                            
                        else
                            state <= s1;
                                                    
                            tvalid <= '0';
                            tlast <= '0';
                            
                        end if;                        
                                        
                    when s1 =>
                        
                        state <= s2;
                       
                        tvalid <= '1';
                        tlast <= '0';                      
                
                     when s2 =>
                        
                        if M_AXIS_TREADY = '0' then      
                            state <= s2;                                                    
                            tvalid <= tvalid;
                            tlast <= tlast;
                        else 
                            if wordcounter = DATA_LENGTH-1 then
                                state <= s0;                            
                                tvalid <= '0';   
                            else
                                state <= s2;                                                    
                                tvalid <= '1';                            
                            end if;
                            
                            if wordcounter = DATA_LENGTH-2 then                                          
                                tlast <= '1';  
                            else
                                tlast <= '0';                             
                            end if;
                        end if;
                    
                    when others =>
                        state <= s0;
                        
                        tvalid <= '0';
                        tlast <= '0';
                        
                end case;
            end if;   
            
            case state is
            
                when s0 =>
                    
                    wordcounter <= 0;
                    
                    cp_to_ram_d0 <= (others => '0');
                    cp_to_ram_d1 <= (others => '0');
                    cp_to_ram_d2 <= (others => '0');
                    cp_to_ram_d3 <= (others => '0');  
                    cp_to_ram_d4 <= (others => '0');
                    cp_to_ram_d5 <= (others => '0');
                    cp_to_ram_d6 <= (others => '0');
                    cp_to_ram_d7 <= (others => '0'); 
                    cp_to_ram_d8 <= (others => '0');
                    cp_to_ram_d9 <= (others => '0');
                    cp_to_ram_d10 <= (others => '0');
                    cp_to_ram_d11 <= (others => '0');  
                    cp_to_ram_d12 <= (others => '0');
                    cp_to_ram_d13 <= (others => '0');
                    cp_to_ram_d14 <= (others => '0');
                    cp_to_ram_d15 <= (others => '0'); 
                    
                when s1 =>
                    
                    wordcounter <= 0;
                    
                    cp_to_ram_d0 <= DATA0;
                    cp_to_ram_d1 <= DATA1;
                    cp_to_ram_d2 <= DATA2;
                    cp_to_ram_d3 <= DATA3;                                                        
                    cp_to_ram_d4 <= DATA4;
                    cp_to_ram_d5 <= DATA5;
                    cp_to_ram_d6 <= DATA6;
                    cp_to_ram_d7 <= DATA7;
                    cp_to_ram_d8 <= DATA8;
                    cp_to_ram_d9 <= DATA9;
                    cp_to_ram_d10 <= DATA10;
                    cp_to_ram_d11 <= DATA11;                                                        
                    cp_to_ram_d12 <= DATA12;
                    cp_to_ram_d13 <= DATA13;
                    cp_to_ram_d14 <= DATA14;
                    cp_to_ram_d15 <= DATA15;
                    
                when s2 =>
                
                    if M_AXIS_TREADY = '0' then                        
                        cp_to_ram_d0 <= cp_to_ram_d0;
                        cp_to_ram_d1 <= cp_to_ram_d1;
                        cp_to_ram_d2 <= cp_to_ram_d2;
                        cp_to_ram_d3 <= cp_to_ram_d3;                                                        
                        cp_to_ram_d4 <= cp_to_ram_d4;
                        cp_to_ram_d5 <= cp_to_ram_d5;
                        cp_to_ram_d6 <= cp_to_ram_d6;
                        cp_to_ram_d7 <= cp_to_ram_d7;              
                        cp_to_ram_d8 <= cp_to_ram_d8;
                        cp_to_ram_d9 <= cp_to_ram_d9;
                        cp_to_ram_d10 <= cp_to_ram_d10;
                        cp_to_ram_d11 <= cp_to_ram_d11;                                                        
                        cp_to_ram_d12 <= cp_to_ram_d12;
                        cp_to_ram_d13 <= cp_to_ram_d13;
                        cp_to_ram_d14 <= cp_to_ram_d14;
                        cp_to_ram_d15 <= cp_to_ram_d15;
                        
                        wordcounter <= wordcounter;
                    else                        
                        cp_to_ram_d0 <= (others => '0');
                        cp_to_ram_d1 <= cp_to_ram_d0;
                        cp_to_ram_d2 <= cp_to_ram_d1;
                        cp_to_ram_d3 <= cp_to_ram_d2; 
                        cp_to_ram_d4 <= cp_to_ram_d3;
                        cp_to_ram_d5 <= cp_to_ram_d4;
                        cp_to_ram_d6 <= cp_to_ram_d5;
                        cp_to_ram_d7 <= cp_to_ram_d6;
                        cp_to_ram_d8 <= cp_to_ram_d7;
                        cp_to_ram_d9 <= cp_to_ram_d8;
                        cp_to_ram_d10 <= cp_to_ram_d9;
                        cp_to_ram_d11 <= cp_to_ram_d10; 
                        cp_to_ram_d12 <= cp_to_ram_d11;
                        cp_to_ram_d13 <= cp_to_ram_d12;
                        cp_to_ram_d14 <= cp_to_ram_d13;
                        cp_to_ram_d15 <= cp_to_ram_d14;
                                                    
                        wordcounter <= wordcounter + 1;                      
                    end if;
                    
                when others =>               
                    
                    wordcounter <= 0;
                    
                    cp_to_ram_d0 <= (others => '0');
                    cp_to_ram_d1 <= (others => '0');
                    cp_to_ram_d2 <= (others => '0');
                    cp_to_ram_d3 <= (others => '0');  
                    cp_to_ram_d4 <= (others => '0');
                    cp_to_ram_d5 <= (others => '0');
                    cp_to_ram_d6 <= (others => '0');
                    cp_to_ram_d7 <= (others => '0'); 
                    cp_to_ram_d8 <= (others => '0');
                    cp_to_ram_d9 <= (others => '0');
                    cp_to_ram_d10 <= (others => '0');
                    cp_to_ram_d11 <= (others => '0');  
                    cp_to_ram_d12 <= (others => '0');
                    cp_to_ram_d13 <= (others => '0');
                    cp_to_ram_d14 <= (others => '0');
                    cp_to_ram_d15 <= (others => '0'); 
                
            end case;            
        end if;
    end process;
   
   

end implementation;