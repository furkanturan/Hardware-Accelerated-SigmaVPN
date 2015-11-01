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

entity CryptoCP_v1_0_RAMtoCP is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		DATA_LENGTH : integer := 8; 
		DATA_WIDTH	: integer := 32
	);
	port (
		-- Users to add ports here
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
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end CryptoCP_v1_0_RAMtoCP;

architecture arch_imp of CryptoCP_v1_0_RAMtoCP is

    signal d0 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d1 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d2 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d3 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d4 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d5 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d6 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d7 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d8 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d9 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d10 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d11 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d12 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d13 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d14 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal d15 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

    signal tready : std_logic := '0';
    signal tdone : std_logic := '0';
    

begin

    DATA0 <= d0;
    DATA1 <= d1;
    DATA2 <= d2;
    DATA3 <= d3;
    DATA4 <= d4;
    DATA5 <= d5;
    DATA6 <= d6;
    DATA7 <= d7;
    DATA8 <= d8;
    DATA9 <= d9;
    DATA10 <= d10;
    DATA11 <= d11;
    DATA12 <= d12;
    DATA13 <= d13;
    DATA14 <= d14;
    DATA15 <= d15;
    
    S_AXIS_TREADY <= tready;
    DONE0 <= tdone;

process (S_AXIS_ACLK)
begin
    if (S_AXIS_ACLK'event and S_AXIS_ACLK = '1') then
    
        if (S_AXIS_ARESETN = '0') then
            -- Don't accept data when RESET  
            tready <= '0'; 
                        
            d0 <= (others => '0'); 
            d1 <= (others => '0'); 
            d2 <= (others => '0'); 
            d3 <= (others => '0'); 
            d4 <= (others => '0'); 
            d5 <= (others => '0'); 
            d6 <= (others => '0'); 
            d7 <= (others => '0'); 
            d8 <= (others => '0'); 
            d9 <= (others => '0'); 
            d10 <= (others => '0'); 
            d11 <= (others => '0'); 
            d12 <= (others => '0'); 
            d13 <= (others => '0'); 
            d14 <= (others => '0'); 
            d15 <= (others => '0'); 
            
            tdone <= '0';
        else
            -- Accept data when not RESET
            tready <= '1';
                        
             -- Allow data input when not TVALID
            if S_AXIS_TVALID = '0' then            
                d0 <= d0;
                d1 <= d1;
                d2 <= d2;
                d3 <= d3;      
                d4 <= d4;
                d5 <= d5;
                d6 <= d6;
                d7 <= d7;    
                d8 <= d8;
                d9 <= d9;
                d10 <= d10;
                d11 <= d11;      
                d12 <= d12;
                d13 <= d13;
                d14 <= d14;
                d15 <= d15;
            else
                d0 <= S_AXIS_TDATA;
                d1 <= d0;
                d2 <= d1;
                d3 <= d2;
                d4 <= d3;
                d5 <= d4;
                d6 <= d5;
                d7 <= d6;
                d8 <= d7;
                d9 <= d8;
                d10 <= d9;
                d11 <= d10;
                d12 <= d11;
                d13 <= d12;
                d14 <= d13;
                d15 <= d14;
            end if;
            
            -- Probe DONE signal
            if S_AXIS_TLAST = '0' then            
                tdone <= '0';
            else          
                tdone <= '1';
            end if;
            
        end if;
    end if;
end process;
    
end arch_imp;