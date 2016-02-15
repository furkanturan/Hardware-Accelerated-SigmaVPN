library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Poly1305_RS is
    Port ( 
        CLK     : in  std_logic;
        LOAD    : in  std_logic;
    
        KEY     : in  std_logic_vector(255 downto 0);
                         
        R_OUT   : out std_logic_vector(127 downto 0);              
        S_OUT   : out std_logic_vector(127 downto 0)
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
                reg_S <=    KEY(255 downto 128);
                
                reg_R <=    "0000" & KEY(123 downto 98) & "00" & 
                            "0000" & KEY( 91 downto 66) & "00" & 
                            "0000" & KEY( 59 downto 34) & "00" & 
                            "0000" & KEY( 27 downto  0) ;
                                           
            else
                reg_S <= reg_S;
                reg_R <= reg_R;
                
            end if;
        end if;
    end process;
    
end Behavioral;