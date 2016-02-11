----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/11/2016 08:20:11 PM
-- Design Name: 
-- Module Name: OutputDMA - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity OutputDMA is
    port (
        INIT            : in  std_logic; 
        
        D_IN            : in  std_logic_vector(511 downto 0);        
            
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
	
	signal wordcounter : integer range 0 to 15 := 0;
    
    signal tlast       : std_logic;
    signal tvalid      : std_logic;
    
    signal data        : std_logic_vector(31 downto 0) := (others => '0');
    
    signal index       : std_logic_vector(8 downto 0) := (others => '0'); 
    
begin

    index <= std_logic_vector(to_unsigned(wordcounter, 4)) & "00000";
    M_AXIS_TDATA    <= D_IN( to_integer(unsigned(index)) + 31 downto to_integer(unsigned(index)));
    
    M_AXIS_TVALID   <= tvalid;
    M_AXIS_TLAST    <= tlast;  
        
    process (M_AXIS_ACLK)
    begin
        if (M_AXIS_ACLK'event and M_AXIS_ACLK = '1') then
            
            if (M_AXIS_ARESETN = '0') then
                state <= s_wait_init;
            else
                
                case state is
                
                    when s_wait_init =>
                        
                        if INIT = '0' then
                            state <= s_wait_init;
                            
                            tvalid <= '0';
                            tlast <= '0';
                            
                        else
                            state <= s_write_data;
                                                    
                            tvalid <= '0';
                            tlast <= '0';
                            
                        end if; 
                        
                        wordcounter <= 0;             
                                        
                    when s_write_data =>
                        
                        if M_AXIS_TREADY = '0' then
                            wordcounter <= wordcounter;
                        else                            
                            wordcounter <= wordcounter + 1;                      
                        end if; 
                        
                        if wordcounter = 15 then
                            state <= s_wait_init;                            
                            tvalid <= '0';   
                        else
                            state <= s_write_data;                                                    
                            tvalid <= '1';                            
                        end if;
                        
                        if wordcounter = 14 then                                          
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
