----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/11/2016 01:32:47 PM
-- Design Name: 
-- Module Name: Poly1305_RS - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Poly1305_RS is
    Port ( 
        CLK     : in  STD_LOGIC;
        LOAD    : in  STD_LOGIC;
    
        CIPHER  : in  STD_LOGIC_VECTOR(255 downto 0);
                         
        R_OUT   : out STD_LOGIC_VECTOR(127 downto 0);              
        S_OUT   : out STD_LOGIC_VECTOR(127 downto 0)
    );
end Poly1305_RS;

architecture Behavioral of Poly1305_RS is
    
    signal reg_S  : std_logic_vector(127 downto 0) := (others => '0');
    signal reg_R  : std_logic_vector(127 downto 0) := (others => '0');
    
begin

    S_OUT <= reg_S;
    R_OUT <= reg_R;    

    process (CLK)
    begin
        if (CLK'event and CLK = '1') then   
            
            if LOAD = '1' then
                reg_S <=    CIPHER(255 downto 128);
                
                reg_R <=    "0000" & CIPHER(123 downto 98) & "00" & 
                            "0000" & CIPHER( 91 downto 66) & "00" & 
                            "0000" & CIPHER( 59 downto 34) & "00" & 
                            "0000" & CIPHER( 27 downto  0) ;
                                           
            else
                reg_S <= reg_S;
                reg_R <= reg_R;
                
            end if;
        end if;
    end process;
    
end Behavioral;
