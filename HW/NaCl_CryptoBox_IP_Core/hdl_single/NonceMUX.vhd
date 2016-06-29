----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/10/2016 04:25:03 PM
-- Design Name: 
-- Module Name: NonceMUX - Behavioral
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
use IEEE.NUMERIC_STD.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity NonceMUX is
    Port ( 
        NONCE_IN    : in  STD_LOGIC_VECTOR(191 downto 0);
        
        NONCE_OUT   : out STD_LOGIC_VECTOR(127 downto 0);
        
        CLK         : in  STD_LOGIC;
        SEL         : in  STD_LOGIC;
        RST         : in  STD_LOGIC;
        UPD         : in  STD_LOGIC
    );
end NonceMUX;

architecture Behavioral of NonceMUX is

    signal reg_NONCE  : std_logic_vector(63 downto 0) := (others => '0');

begin

    NONCE_OUT <= NONCE_IN(127 downto 0) when (SEL = '0') else reg_NONCE & NONCE_IN(191 downto 128);

    process (CLK)
    begin
        if (CLK'event and CLK = '1') then   
            
            if RST = '1' then
                reg_NONCE <= (others => '0');
            
            elsif UPD = '1' then
                reg_NONCE <= reg_NONCE + 1;
            
            else
                reg_NONCE <= reg_NONCE;
            
            end if;
        end if;
    end process;


end Behavioral;