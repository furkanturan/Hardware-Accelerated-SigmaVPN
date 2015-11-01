------------------------------------------------------------------------/
--  Asserts TREADY to inform MASTER it can ready data from it
--  Waits for TVALID signal from MASTER to start reading data
--  At every clock when TVALID is asserted, read a word from TDATA
--  While doing this, waits for TLAST indicator of last word
--  After TLAST, asserts DONE, and goes to initial state
------------------------------------------------------------------------/

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CryptoCP_v1_0_Process is
	generic (
        DATA_LENGTH : integer := 4; 
		DATA_WIDTH	: integer := 32
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
        DATA_IN_9 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_IN_8 : in std_logic_vector(DATA_WIDTH-1 downto 0);
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
end CryptoCP_v1_0_Process;

architecture arch_imp of CryptoCP_v1_0_Process is

    type state_type is (s0, s1, s2);
	signal state   : state_type;

    signal p_d0 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d1 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d2 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d3 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d4 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d5 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d6 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d7 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d8 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d9 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d10 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d11 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d12 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d13 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d14 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal p_d15 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');


    signal p_done : std_logic := '0';

begin
    
    DATA_OUT_0 <= p_d0;
    DATA_OUT_1 <= p_d1;
    DATA_OUT_2 <= p_d2;
    DATA_OUT_3 <= p_d3;
    DATA_OUT_4 <= p_d4;
    DATA_OUT_5 <= p_d5;
    DATA_OUT_6 <= p_d6;
    DATA_OUT_7 <= p_d7;
    DATA_OUT_8 <= p_d8;
    DATA_OUT_9 <= p_d9;
    DATA_OUT_10 <= p_d10;
    DATA_OUT_11 <= p_d11;
    DATA_OUT_12 <= p_d12;
    DATA_OUT_13 <= p_d13;
    DATA_OUT_14 <= p_d14;
    DATA_OUT_15 <= p_d15;
     
     DONE <= p_done;
    
process (ACLK)
begin
    if (ACLK'event and ACLK = '1') then
    
        if (ARESETN = '0') then                        
            state <= s0;
        else            
            
            case state is
                when s0 =>
                    if INIT = '1' then
                        state <= s1;
                    else
                        state <= s0;
                    end if;
                when s1 =>
                    state <= s2;
                when others =>
                    state <= s0;
            end case;
        end if;
        
        case state is
            when s0 =>         
                p_d0 <= p_d0;
                p_d1 <= p_d1;
                p_d2 <= p_d2;
                p_d3 <= p_d3;   
                p_d4 <= p_d4;
                p_d5 <= p_d5;
                p_d6 <= p_d6;
                p_d7 <= p_d7; 
                p_d8 <= p_d8;
                p_d9 <= p_d9;
                p_d10 <= p_d10;
                p_d11 <= p_d11;   
                p_d12 <= p_d12;
                p_d13 <= p_d13;
                p_d14 <= p_d14;
                p_d15 <= p_d15;
               
                p_done <= p_done;
               
           when s1 =>
                p_d0 <= not DATA_IN_0;
                p_d1 <= DATA_IN_1;
                p_d2 <= not DATA_IN_2;
                p_d3 <= DATA_IN_3;
                p_d4 <= not DATA_IN_4;
                p_d5 <= DATA_IN_5;
                p_d6 <= not DATA_IN_6;
                p_d7 <= DATA_IN_7;
                p_d8 <= not DATA_IN_8;
                p_d9 <= DATA_IN_9;
                p_d10 <= not DATA_IN_10;
                p_d11 <= DATA_IN_11;
                p_d12 <= not DATA_IN_12;
                p_d13 <= DATA_IN_13;
                p_d14 <= not DATA_IN_14;
                p_d15 <= DATA_IN_15;
                
                p_done <= '1';
               
            when s2 =>     
                p_d0 <= p_d0;
                p_d1 <= p_d1;
                p_d2 <= p_d2;
                p_d3 <= p_d3;   
                p_d4 <= p_d4;
                p_d5 <= p_d5;
                p_d6 <= p_d6;
                p_d7 <= p_d7; 
                p_d8 <= p_d8;
                p_d9 <= p_d9;
                p_d10 <= p_d10;
                p_d11 <= p_d11;   
                p_d12 <= p_d12;
                p_d13 <= p_d13;
                p_d14 <= p_d14;
                p_d15 <= p_d15;
                
                p_done <= '0';
                
        end case;
        
    end if;
end process;
    
end arch_imp;
