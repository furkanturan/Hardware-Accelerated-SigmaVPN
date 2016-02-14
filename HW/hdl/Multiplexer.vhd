----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/13/2016 01:50:58 PM
-- Design Name: 
-- Module Name: Multiplexer - Behavioral
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

entity Multiplexer is
    generic (
	
        WIDTH	        : integer	:= 32
	);
    Port ( 
        
        A   : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        B   : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        S   : in  STD_LOGIC;
        
        O  : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
end Multiplexer;

architecture Behavioral of Multiplexer is

begin

    O <=	A when S = '0' else B;

end Behavioral;
