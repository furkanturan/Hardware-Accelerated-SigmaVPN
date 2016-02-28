library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Poly1305 is
    Port ( 
        CLK     : in  std_logic;        
        RSTN     : in  std_logic;             
        INIT    : in  std_logic;
        LOAD_RS : in  std_logic;
        LAST    : in  std_logic;           
        DONE    : out std_logic;
    
        MSG     : in  std_logic_vector(127 downto 0);
        MSG_LEN : in  std_logic_vector(3 downto 0);
        
        KEY     : in  std_logic_vector(255 downto 0);
    
        MAC     : out std_logic_vector(127 downto 0)
    );
end Poly1305;

architecture Behavioral of Poly1305 is

    component Poly1305_Chunk is
    port (
        CLK     : in  std_logic;        
        RSTN     : in  std_logic;             
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
    
    
    type state_type is (s_reset, s_idle, s_init, s_checkoverflow, s_busy);
    signal state   : state_type;

    signal C        : std_logic_vector(128 downto 0) := (others => '0');
    
    signal reg_ACC      : std_logic_vector(130 downto 0) := (others => '0');
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
        
    C       <=  '1' & MSG                                               when (MSG_LEN = "1111") else 
                '0' & (127 downto 121 => '0') & '1' & MSG(119 downto 0) when (MSG_LEN = "1110") else 
                '0' & (127 downto 113 => '0') & '1' & MSG(111 downto 0) when (MSG_LEN = "1101") else 
                '0' & (127 downto 105 => '0') & '1' & MSG(103 downto 0) when (MSG_LEN = "1100") else 
                '0' & (127 downto  97 => '0') & '1' & MSG( 95 downto 0) when (MSG_LEN = "1011") else 
                '0' & (127 downto  89 => '0') & '1' & MSG( 87 downto 0) when (MSG_LEN = "1010") else 
                '0' & (127 downto  81 => '0') & '1' & MSG( 79 downto 0) when (MSG_LEN = "1001") else 
                '0' & (127 downto  73 => '0') & '1' & MSG( 71 downto 0) when (MSG_LEN = "1000") else 
                '0' & (127 downto  65 => '0') & '1' & MSG( 63 downto 0) when (MSG_LEN = "0111") else 
                '0' & (127 downto  57 => '0') & '1' & MSG( 55 downto 0) when (MSG_LEN = "0110") else 
                '0' & (127 downto  49 => '0') & '1' & MSG( 47 downto 0) when (MSG_LEN = "0101") else 
                '0' & (127 downto  41 => '0') & '1' & MSG( 39 downto 0) when (MSG_LEN = "0100") else 
                '0' & (127 downto  33 => '0') & '1' & MSG( 31 downto 0) when (MSG_LEN = "0011") else 
                '0' & (127 downto  25 => '0') & '1' & MSG( 23 downto 0) when (MSG_LEN = "0010") else 
                '0' & (127 downto  17 => '0') & '1' & MSG( 15 downto 0) when (MSG_LEN = "0001") else 
                '0' & (127 downto   9 => '0') & '1' & MSG(  7 downto 0) ;
    
    process (CLK)
    begin
    if (CLK'event and CLK = '1') then
    
        if RSTN = '0' then
                        
            state       <= s_reset;
            
            ch_init     <= '0';
            sig_DONE    <= '0';
            sig_LAST    <= '0';
            
            reg_ACC     <= (others => '0');
            
        else
            
            case state is
            
                when s_reset =>
                
                    state <= s_idle;
                    
                    reg_ACC     <= (others => '0');
                    
                    sig_DONE <= '0';
                    ch_init  <= '0';
            
                when s_idle =>
                           
                    if INIT = '1' then
                        state <= s_init;
                        sig_LAST <= LAST;
                        sig_DONE <= '0';
                    else
                        state <= s_idle;
                        sig_DONE <= sig_DONE;
                    end if;
                    
                    ch_init  <= '0';
                
                when s_init =>
                
                    reg_ACC <= reg_ACC + C;
                
                    ch_init  <= '0';
                    
                    state    <= s_checkoverflow;
                    sig_DONE <= sig_DONE;
                    sig_LAST <= sig_LAST;
                
                when s_checkoverflow =>
                
                    if reg_ACC(130) = '1' then
                        reg_ACC <= ('0' & reg_ACC(129 downto 0)) + 5;
                    else
                        reg_ACC <= reg_ACC;
                    end if;
                                        
                    ch_init  <= '1';
                    
                    state    <= s_busy;
                
                when s_busy =>
                    
                    ch_init  <= '0';
                    
                    if ch_done = '0' then
                        
                        reg_ACC <= reg_ACC;
                        
                        state <= s_busy;
                        
                        sig_DONE <= sig_DONE;
                     
                    else
                    
                        if sig_LAST = '0' then    
                            reg_ACC <= '0' & sig_newACC;
                        else
                            reg_ACC <= '0' & (sig_newACC + S);
                        end if;
                        
                        state <= s_idle;
                        
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
        RSTN     => RSTN,        
        INIT    => ch_init,         
        DONE    => ch_done,
                
        R       => R,
        
        ACC_in  => reg_ACC(129 downto 0),
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