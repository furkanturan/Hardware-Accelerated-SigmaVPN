library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Poly1305 is
    Port ( 
        CLK     : in  std_logic;        
        RST     : in  std_logic;             
        INIT    : in  std_logic;
        LOAD_RS : in  std_logic;
        LAST    : in  std_logic;           
        DONE    : out std_logic;
    
        MSG     : in  std_logic_vector(127 downto 0);
        MSG_LEN : in  std_logic_vector(4 downto 0);
        
        KEY     : in  std_logic_vector(255 downto 0);
    
        MAC     : out std_logic_vector(127 downto 0)
    );
end Poly1305;

architecture Behavioral of Poly1305 is

    component Poly1305_Chunk is
    port (
        CLK     : in  std_logic;        
        RST     : in  std_logic;             
        INIT    : in  std_logic;             
        DONE    : out std_logic;
                
        R       : in  std_logic_vector(127 downto 0);
        
        ACC_in  : in  std_logic_vector(129 downto 0);
        ACC_out : out std_logic_vector(129 downto 0)
        );
    end component Poly1305_Chunk;

    component Poly1305_RS is
    port (
        CLK     : in  std_logic;
        LOAD    : in  std_logic;
    
        KEY     : in  std_logic_vector(255 downto 0);
                         
        R_OUT   : out std_logic_vector(127 downto 0);              
        S_OUT   : out std_logic_vector(127 downto 0)
        );
    end component Poly1305_RS;
    
--    function C (MSG, MSG_LEN: std_logic_vector) return std_logic_vector(129 downto 0) is
--        variable ret : std_logic_vector(129 downto 0);
--    begin
--        ret := "01" & MSG;
----        if MSG_LEN = "10000" then
----            ret := "01" & MSG;
----        else
----            ret := "01" & MSG;
------            for i in 0 to 15 loop                
------                if MSG_LEN < i then
------                    ret(i*8+7 downto i*8 ) := MSG(i*8+7 downto i*8 );
------                elsif MSG_LEN = i then
------                    ret(i*8+7 downto i*8 ) := "00000001";
------                end if;
------            end loop;
------            ret(129 downto 128) := "00";    
----        end if;
--        return ret;
--    end function;
    
    type state_type is (s_reset, s_init, s_busy);
    signal state   : state_type;

    signal C        : std_logic_vector(128 downto 0) := (others => '0');
    
    signal reg_ACC      : std_logic_vector(129 downto 0) := (others => '0');
    signal sig_newACC   : std_logic_vector(129 downto 0) := (others => '0');
        
    signal R        : std_logic_vector(127 downto 0);
    signal S        : std_logic_vector(127 downto 0);
    
    signal ch_init  : std_logic := '0';              
    signal ch_done  : std_logic := '0';
    
    signal sig_DONE : std_logic := '0';
    signal sig_LAST : std_logic := '0';
    
begin
    
    DONE    <= sig_DONE;
    MAC     <= reg_ACC(127 downto 0);
    
    C       <=  '1' & MSG                                           when (MSG_LEN = "10000") else 
                '0' & MSG(127 downto 121) & '1' & MSG(119 downto 0) when (MSG_LEN = "01111") else 
                '0' & MSG(127 downto 113) & '1' & MSG(111 downto 0) when (MSG_LEN = "01110") else 
                '0' & MSG(127 downto 105) & '1' & MSG(103 downto 0) when (MSG_LEN = "01101") else 
                '0' & MSG(127 downto  97) & '1' & MSG( 95 downto 0) when (MSG_LEN = "01100") else 
                '0' & MSG(127 downto  89) & '1' & MSG( 87 downto 0) when (MSG_LEN = "01011") else 
                '0' & MSG(127 downto  81) & '1' & MSG( 79 downto 0) when (MSG_LEN = "01010") else 
                '0' & MSG(127 downto  73) & '1' & MSG( 71 downto 0) when (MSG_LEN = "01001") else 
                '0' & MSG(127 downto  65) & '1' & MSG( 63 downto 0) when (MSG_LEN = "01000") else 
                '0' & MSG(127 downto  57) & '1' & MSG( 55 downto 0) when (MSG_LEN = "00111") else 
                '0' & MSG(127 downto  49) & '1' & MSG( 47 downto 0) when (MSG_LEN = "00110") else 
                '0' & MSG(127 downto  41) & '1' & MSG( 39 downto 0) when (MSG_LEN = "00101") else 
                '0' & MSG(127 downto  33) & '1' & MSG( 31 downto 0) when (MSG_LEN = "00100") else 
                '0' & MSG(127 downto  25) & '1' & MSG( 23 downto 0) when (MSG_LEN = "00011") else 
                '0' & MSG(127 downto  17) & '1' & MSG( 15 downto 0) when (MSG_LEN = "00010") else 
                '0' & MSG(127 downto   9) & '1' & MSG(  7 downto 0) ;
    
    process (CLK)
    begin
    if (CLK'event and CLK = '1') then
    
        if RST = '1' then
                        
            state       <= s_reset;
            
            ch_init     <= '0';
            sig_DONE    <= '0';
            sig_LAST    <= '0';
            
            reg_ACC     <= (others => '0');
            
        else
            
            case state is
            
                when s_reset =>
                           
                    if INIT = '1' then
                        state <= s_init;
                        sig_LAST <= LAST;
                    else
                        state <= s_reset;
                    end if;
                    
                    ch_init  <= '0';
                    sig_DONE <= '0';
                
                when s_init =>
                
                    reg_ACC <= reg_ACC + C;
                
                    ch_init  <= '1';
                    
                    state    <= s_busy;
                    sig_DONE <= sig_DONE;
                    sig_LAST <= sig_LAST;
                    
                when s_busy =>
                
                    ch_init  <= '0';
                    
                    if ch_done = '0' then
                        
                        reg_ACC <= reg_ACC;
                        
                        state <= s_busy;
                        
                        sig_DONE <= sig_DONE;
                     
                    else
                    
                        if sig_LAST = '0' then    
                            reg_ACC <= sig_newACC;
                        else
                            reg_ACC <= sig_newACC + S;
                        end if;
                        
                        state <= s_reset;
                        
                        sig_DONE <= '1';   
                     
                     end if;
                              
                 when others =>
                     null;
            end case;
        end if;
    end if;
    end process;

    Chunk: component Poly1305_Chunk
    port map (        
        CLK     => CLK,    
        RST     => RST,        
        INIT    => ch_init,         
        DONE    => ch_done,
                
        R       => R,
        
        ACC_in  => reg_ACC,
        ACC_out => sig_newACC
    );
    
    RS: component Poly1305_RS
    port map (        
        CLK     => CLK,    
        LOAD    => LOAD_RS,
                
        KEY     => KEY,
                 
        R_OUT   => R,
        S_OUT   => S
    );

end Behavioral;