library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Poly1305 is
    Port ( 
        CLK       : in  std_logic;
        RSTN      : in  std_logic;
        INIT      : in  std_logic;
        LOAD_RS   : in  std_logic;
        FINAL     : in  std_logic;        
        DOUBLY    : in  std_logic_vector(  1 downto 0);  
        DONE      : out std_logic;
    
        MSG_1     : in  std_logic_vector(127 downto 0);
        MSG_LEN_1 : in  std_logic_vector(  3 downto 0);        
        MSG_2     : in  std_logic_vector(127 downto 0);
        MSG_LEN_2 : in  std_logic_vector(  3 downto 0);
        
        KEY       : in  std_logic_vector(255 downto 0);
    
        MAC       : out std_logic_vector(127 downto 0)
    );
end Poly1305;

architecture Behavioral of Poly1305 is

    component Poly1305_Chunk is
    port (
        CLK     : in  std_logic;        
        RSTN    : in  std_logic;             
        INIT    : in  std_logic;             
        DONE    : out std_logic;
                
        R       : in  std_logic_vector(129 downto 0);
        
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
    
    
    type state_type is (s_reset, s_idle, s_init, s_r2_start, s_r2_wait, s_checkoverflow, s_mid, s_last_1, s_last_2, s_busy);
    signal state        : state_type;

    signal C_1          : std_logic_vector(128 downto 0) := (others => '0');
    signal C_2          : std_logic_vector(128 downto 0) := (others => '0');
    
    signal reg_ACC_1    : std_logic_vector(130 downto 0) := (others => '0');
    signal sig_newACC_1 : std_logic_vector(129 downto 0) := (others => '0');
        
    signal reg_ACC_2    : std_logic_vector(130 downto 0) := (others => '0');
    signal sig_newACC_2 : std_logic_vector(129 downto 0) := (others => '0');
    
    signal reg_MAC      : std_logic_vector(127 downto 0) := (others => '0');
    
    signal R2           : std_logic_vector(129 downto 0);
    signal R            : std_logic_vector(127 downto 0);
    signal S            : std_logic_vector(127 downto 0);
    
    signal ch_init_1    : std_logic := '0';              
    signal ch_done_1    : std_logic := '0';
    
    signal ch_init_2    : std_logic := '0';              
    signal ch_done_2    : std_logic := '0';
    
    signal sig_DONE     : std_logic := '0';
    
    signal sig_R_1      : std_logic_vector(129 downto 0);
    signal sig_R_SEL_1  : std_logic := '0';
    signal sig_R_2      : std_logic_vector(129 downto 0);
    signal sig_R_SEL_2  : std_logic := '0';
begin
    
    sig_R_1   <= "00" & R when sig_R_SEL_1 = '0' else R2;
    sig_R_2   <= "00" & R when sig_R_SEL_2 = '0' else R2;
    
    DONE    <= sig_DONE;
    MAC     <= reg_MAC(127 downto 0);
        
    C_1     <=  '1' & MSG_1                                               when (MSG_LEN_1 = "1111") else 
                '0' & (127 downto 121 => '0') & '1' & MSG_1(119 downto 0) when (MSG_LEN_1 = "1110") else 
                '0' & (127 downto 113 => '0') & '1' & MSG_1(111 downto 0) when (MSG_LEN_1 = "1101") else 
                '0' & (127 downto 105 => '0') & '1' & MSG_1(103 downto 0) when (MSG_LEN_1 = "1100") else 
                '0' & (127 downto  97 => '0') & '1' & MSG_1( 95 downto 0) when (MSG_LEN_1 = "1011") else 
                '0' & (127 downto  89 => '0') & '1' & MSG_1( 87 downto 0) when (MSG_LEN_1 = "1010") else 
                '0' & (127 downto  81 => '0') & '1' & MSG_1( 79 downto 0) when (MSG_LEN_1 = "1001") else 
                '0' & (127 downto  73 => '0') & '1' & MSG_1( 71 downto 0) when (MSG_LEN_1 = "1000") else 
                '0' & (127 downto  65 => '0') & '1' & MSG_1( 63 downto 0) when (MSG_LEN_1 = "0111") else 
                '0' & (127 downto  57 => '0') & '1' & MSG_1( 55 downto 0) when (MSG_LEN_1 = "0110") else 
                '0' & (127 downto  49 => '0') & '1' & MSG_1( 47 downto 0) when (MSG_LEN_1 = "0101") else 
                '0' & (127 downto  41 => '0') & '1' & MSG_1( 39 downto 0) when (MSG_LEN_1 = "0100") else 
                '0' & (127 downto  33 => '0') & '1' & MSG_1( 31 downto 0) when (MSG_LEN_1 = "0011") else 
                '0' & (127 downto  25 => '0') & '1' & MSG_1( 23 downto 0) when (MSG_LEN_1 = "0010") else 
                '0' & (127 downto  17 => '0') & '1' & MSG_1( 15 downto 0) when (MSG_LEN_1 = "0001") else 
                '0' & (127 downto   9 => '0') & '1' & MSG_1(  7 downto 0) ;
    
    C_2     <=  '1' & MSG_2                                               when (MSG_LEN_2 = "1111") else 
                '0' & (127 downto 121 => '0') & '1' & MSG_2(119 downto 0) when (MSG_LEN_2 = "1110") else 
                '0' & (127 downto 113 => '0') & '1' & MSG_2(111 downto 0) when (MSG_LEN_2 = "1101") else 
                '0' & (127 downto 105 => '0') & '1' & MSG_2(103 downto 0) when (MSG_LEN_2 = "1100") else 
                '0' & (127 downto  97 => '0') & '1' & MSG_2( 95 downto 0) when (MSG_LEN_2 = "1011") else 
                '0' & (127 downto  89 => '0') & '1' & MSG_2( 87 downto 0) when (MSG_LEN_2 = "1010") else 
                '0' & (127 downto  81 => '0') & '1' & MSG_2( 79 downto 0) when (MSG_LEN_2 = "1001") else 
                '0' & (127 downto  73 => '0') & '1' & MSG_2( 71 downto 0) when (MSG_LEN_2 = "1000") else 
                '0' & (127 downto  65 => '0') & '1' & MSG_2( 63 downto 0) when (MSG_LEN_2 = "0111") else 
                '0' & (127 downto  57 => '0') & '1' & MSG_2( 55 downto 0) when (MSG_LEN_2 = "0110") else 
                '0' & (127 downto  49 => '0') & '1' & MSG_2( 47 downto 0) when (MSG_LEN_2 = "0101") else 
                '0' & (127 downto  41 => '0') & '1' & MSG_2( 39 downto 0) when (MSG_LEN_2 = "0100") else 
                '0' & (127 downto  33 => '0') & '1' & MSG_2( 31 downto 0) when (MSG_LEN_2 = "0011") else 
                '0' & (127 downto  25 => '0') & '1' & MSG_2( 23 downto 0) when (MSG_LEN_2 = "0010") else 
                '0' & (127 downto  17 => '0') & '1' & MSG_2( 15 downto 0) when (MSG_LEN_2 = "0001") else 
                '0' & (127 downto   9 => '0') & '1' & MSG_2(  7 downto 0) ;
    
    process (CLK)
    begin
    if (CLK'event and CLK = '1') then
    
        if RSTN = '0' then
                        
            state       <= s_reset;
            
            ch_init_1   <= '0';
            ch_init_2   <= '0';
            sig_DONE    <= '0';
            
            reg_ACC_1   <= (others => '0');
            reg_ACC_2   <= (others => '0');
            
        else
            
            case state is
            
                when s_reset =>
                
                    state       <= s_idle;
                    
                    reg_ACC_1   <= (others => '0');
                    reg_ACC_2   <= (others => '0');
                    
                    sig_DONE    <= '0';
                    
                    ch_init_1   <= '0';
                    ch_init_2   <= '0';
            
                when s_idle =>
                    
                    if INIT='1' and LOAD_RS = '1' then
                        state    <= s_r2_start;
                        sig_DONE <= '0';
                        
                    elsif INIT = '1' then
                        state    <= s_init;
                        sig_DONE <= '0';
                                            
                    elsif FINAL = '1' then
                        state   <= s_last_1;
                        sig_DONE <= '0';
                    else
                        state    <= s_idle;
                        sig_DONE <= sig_DONE;
                    end if;
                    
                    ch_init_1  <= '0';
                    ch_init_2  <= '0';
                
                when s_init =>
                
                    if DOUBLY = "10" then
                        reg_ACC_1 <= reg_ACC_1 + C_1;
                        reg_ACC_2 <= reg_ACC_2 + C_2;
                    elsif DOUBLY = "01" then
                        reg_ACC_1 <= reg_ACC_1 + C_1;
                        reg_ACC_2 <= reg_ACC_2 + C_2;
                    else
                        reg_ACC_1 <= reg_ACC_1 + C_1;  
                        reg_ACC_2 <= reg_ACC_2;                      
                    end if;
                                    
                    ch_init_1  <= '0';
                    ch_init_2  <= '0';
                    
                    state    <= s_checkoverflow;
                    
                    sig_DONE <= sig_DONE;
                    
                when s_r2_start =>
                    reg_ACC_1 <= "000" & R;
                    ch_init_1  <= '1';
                    
                    sig_DONE <= '0';
                    sig_R_SEL_1 <= '0';
                        
                    state    <= s_r2_wait;
                
                when s_r2_wait =>
                    ch_init_1  <= '0';
                    
                    if ch_done_1 = '0' then
                        state    <= s_r2_wait;
                        sig_DONE <= sig_DONE;
                    else
                        state <= s_idle;
                        
                        reg_ACC_1   <= (others => '0');
                        R2 <= sig_newACC_1(129 downto 0);
                        
                        sig_DONE <= '1';  
                    end if;                         
                
                when s_checkoverflow =>
                
                    if reg_ACC_1(130) = '1' then
                        reg_ACC_1 <= ('0' & reg_ACC_1(129 downto 0)) + 5;
                    else
                        reg_ACC_1 <= reg_ACC_1;
                    end if;
                    
                    if reg_ACC_2(130) = '1' then
                       reg_ACC_2 <= ('0' & reg_ACC_2(129 downto 0)) + 5;
                    else
                       reg_ACC_2 <= reg_ACC_2;
                    end if;
                                        
                    if DOUBLY = "10" then
                        ch_init_1  <= '1'; 
                        ch_init_2  <= '1'; 
                        sig_R_SEL_1  <= '1';
                        sig_R_SEL_2  <= '1';
                    elsif DOUBLY = "01" then
                        ch_init_1  <= '1'; 
                        ch_init_2  <= '1'; 
                        sig_R_SEL_1  <= '1';
                        sig_R_SEL_2  <= '0';
                    else
                        ch_init_1  <= '1'; 
                        ch_init_2  <= '0'; 
                        sig_R_SEL_1  <= '0';
                        sig_R_SEL_2  <= '0';             
                    end if;
                    
                    state    <= s_mid;
                
                when s_mid =>
                
                    ch_init_1  <= '0';
                    ch_init_2  <= '0';
                    
                    state    <= s_busy;
                    
                when s_busy =>                    
                    
                    if ((DOUBLY = "10" or DOUBLY = "01") and (ch_done_1 = '0' or ch_done_2 = '0')) or (DOUBLY = "00" and ch_done_1 = '0') then
                        
                        reg_ACC_1 <= reg_ACC_1;
                        reg_ACC_2 <= reg_ACC_2;
                        
                        state <= s_busy;
                        
                        sig_DONE <= sig_DONE;
                     
                    else
                        reg_ACC_1 <= '0' & sig_newACC_1;
                        reg_ACC_2 <= '0' & sig_newACC_2;
                    
                        state   <= s_idle;
                        
                        sig_DONE <= '1';   
                     
                     end if;
                     
                 when s_last_1 =>
                     
                    reg_ACC_1 <= reg_ACC_1 + reg_ACC_2;
                  
                    sig_DONE <= '0';
                    
                    state   <= s_last_2;
                 
                when s_last_2 =>    
                    if reg_ACC_1(130) = '1' then
                        reg_MAC <= reg_ACC_1(127 downto 0) + 5 + S;
                    else
                        reg_MAC <= reg_ACC_1(127 downto 0) + S;
                    end if;
                 
                     sig_DONE <= '1';
                     
                     state   <= s_idle;
                 
                 when others =>
                     null;
            end case;
        end if;
    end if;
    end process;

    Chunk_1: component Poly1305_Chunk
    port map (        
        CLK     => CLK,    
        RSTN    => RSTN,        
        INIT    => ch_init_1,         
        DONE    => ch_done_1,
                
        R       => sig_R_1,
        
        ACC_in  => reg_ACC_1(129 downto 0),
        ACC_out => sig_newACC_1
    );
    
     Chunk_2: component Poly1305_Chunk
     port map (        
       CLK     => CLK,    
       RSTN     => RSTN,        
       INIT    => ch_init_2,         
       DONE    => ch_done_2,
               
       R       => sig_R_2,
       
       ACC_in  => reg_ACC_2(129 downto 0),
       ACC_out => sig_newACC_2
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