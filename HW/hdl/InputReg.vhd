----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/09/2016 06:21:24 PM
-- Design Name: 
-- Module Name: InputReg - Behavioral
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
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity InputReg is
    generic (
		DATA_LENGTH : integer := 8; 
		DATA_WIDTH	: integer := 32
	);
    Port (
        CMD             : out std_logic_vector(15 downto 0);
        MLEN            : out std_logic_vector(15 downto 0);
        NONCE           : out std_logic_vector(191 downto 0);   -- 24 bytes / 6 int32 = 192 bits
        PRECOMP         : out std_logic_vector(255 downto 0);   -- 32 bytes / 8 int32 = 256 bits
        MESSAGE         : out std_logic_vector(511 downto 0);   -- 64 bytes / 16 int32 = 512 bits
        
        SL_KEY          : in  std_logic_vector(255 downto 0);   -- Second Level key that will be loaded over of PRECOMP  
        SL_KEY_LOAD     : in  std_logic;                                                                  
    
        RDY             : in  std_logic;
        DONE            : out std_logic;
        
        S_AXIS_ACLK     : in std_logic;         -- AXI4Stream sink: Clock        
        S_AXIS_ARESETN  : in std_logic;         -- AXI4Stream sink: Reset        
        S_AXIS_TREADY   : out std_logic;        -- Ready to accept data in        
        S_AXIS_TDATA    : in std_logic_vector(DATA_WIDTH-1 downto 0);   -- Data in        
        S_AXIS_TLAST    : in std_logic;         -- Indicates boundary of last packet        
        S_AXIS_TVALID   : in std_logic          -- Data is in valid
    );
end InputReg;

architecture Behavioral of InputReg is

    signal tready   : std_logic := '0';
    signal tdone    : std_logic := '0';
    
    signal counter  : integer range 0 to 15 := 0;
    
    signal reg_CMD  : std_logic_vector(15 downto 0) := (others => '0');
    signal reg_MLEN : std_logic_vector(15 downto 0) := (others => '0');
    
    type buffer_NONCE is array (0 to 5) of std_logic_vector(31 downto 0);
    signal reg_NONCE : buffer_NONCE := ((others => (others=>'0')));
    
    type buffer_PRECOMP is array (0 to 7) of std_logic_vector(31 downto 0);
    signal reg_PRECOMP : buffer_PRECOMP := ((others => (others=>'0')));
    
    type buffer_MESSAGE is array (0 to 15) of std_logic_vector(31 downto 0);
    signal reg_MESSAGE : buffer_MESSAGE := ((others => (others=>'0')));
    
    
        
    function to_NONCE_vector (x: buffer_NONCE) return std_logic_vector is
        variable ret : std_logic_vector(191 downto 0);
    begin
        for i in x'RANGE loop
            ret(i*32+31 downto i*32) := x(i);
        end loop;
        return ret;
    end function;
    
    function to_PRECOMP_vector (x: buffer_PRECOMP) return std_logic_vector is
        variable ret : std_logic_vector(255 downto 0);
    begin
        for i in x'RANGE loop
            ret(i*32+31 downto i*32) := x(i);
        end loop;
        return ret;
    end function;
    
    function to_MESSAGE_vector (x: buffer_MESSAGE) return std_logic_vector is
        variable ret : std_logic_vector(511 downto 0);
    begin
        for i in x'RANGE loop
            ret(i*32+31 downto i*32) := x(i);
        end loop;
        return ret;
    end function;
    
    function to_PRECOMP_array (x: std_logic_vector) return buffer_PRECOMP is
        variable ret : buffer_PRECOMP;
    begin
        for i in ret'RANGE loop
            ret(i) := x(i*32+31 downto i*32);
        end loop;
        return ret;
    end function;
    
    
    
    
    type state_type is (s_wait_init, s_read_init, s_wait_data, s_read_data);
    signal state   : state_type;
    
begin

    
    S_AXIS_TREADY <= tready;
    DONE <= tdone;
    
    CMD <= reg_CMD;
    MLEN <= reg_MLEN;
    NONCE <= to_NONCe_vector(reg_NONCE);
    PRECOMP <= to_PRECOMP_vector(reg_PRECOMP);    
    MESSAGE <= to_MESSAGE_vector(reg_MESSAGE) ;
     

process (S_AXIS_ACLK)
begin
    if (S_AXIS_ACLK'event and S_AXIS_ACLK = '1') then
    
        if S_AXIS_ARESETN = '0' then
            -- Don't accept data when RESET  
            tready <= '0'; 
            
            counter <= 0;
            
            tdone <= '0';
            
            state <= s_wait_init;
            
        else
            
            case state is
                
                -- Wait state for initialization
                when s_wait_init => 
                    
                    if SL_KEY_LOAD = '1' then
                       reg_PRECOMP <= to_PRECOMP_array(SL_KEY);                    
                   end if;
                    
                    if RDY = '1' then
                        state <= s_read_init;
                        
                        -- Infrom AXI master that I am ready to read data
                        tready <= '1';  
                        tdone <= '0';
                    else
                        state <= s_wait_init;
                        tready <= '0';  
                        tdone <= tdone;
                    end if;
                 
                    counter <= 0;
                    
                 -- Read state for initialization data
                 when s_read_init => 
                 
                    tready <= '1';
                    tdone <= '0';          
                           
                     -- Allow data input when TVALID
                    if S_AXIS_TVALID = '0' then 
                        counter <= counter;
                        
                    else
                        if counter = 0 then
                            reg_CMD                 <= S_AXIS_TDATA(15 downto 0);
                            reg_MLEN                <= S_AXIS_TDATA(31 downto 16);
                        elsif counter < 7 then
                            reg_NONCE(counter-1)    <= S_AXIS_TDATA;
                        elsif counter < 15 then
                            reg_PRECOMP(counter-7)  <= S_AXIS_TDATA;
                        end if;
                        
                        if counter = 14 then
                            state <= s_read_data;
                            counter <= 0;
                        else
                            state <= s_read_init;
                            counter <= counter + 1;
                        end if;
                        
                    end if;
                
                when s_wait_data =>
                    if SL_KEY_LOAD = '1' then
                        reg_PRECOMP <= to_PRECOMP_array(SL_KEY);                    
                    end if;
                    
                    if RDY = '1' then
                        state <= s_read_init;
                        tready <= '1';  
                    else
                        state <= s_wait_data;
                        tready <= '0';
                    end if;
                    
                    
                when s_read_data =>                      
                    
                    if SL_KEY_LOAD = '1' then
                        reg_PRECOMP <= to_PRECOMP_array(SL_KEY);                    
                    end if;
                    
                    if S_AXIS_TVALID = '0' then 
                        counter <= counter;
                        tready <= tready;
                        state <= s_read_data;
                    else                            
                        reg_MESSAGE(counter) <= S_AXIS_TDATA;                        
                        
                        if S_AXIS_TLAST = '0' then
                                                
                            if counter = 15 then
                                if RDY = '1' then
                                    tready <= '1';
                                    state <= s_read_data;
                                else
                                    tready <= '0';
                                    state <= s_wait_data;
                                end if;                                
                                counter <= 0;
                            else
                                tready <= '1';
                                
                                state <= s_read_data;
                                counter <= counter + 1;
                            end if;
                    
                                            
                            tdone <= '0';
                        else          
                            tready <= '0';
                            tdone <= '1';
                            state <= s_wait_init;
                        end if;
                    end if;
                    
                when others =>
                    null;
                        
            end case;            
        end if;
    end if;
end process;

end Behavioral;
