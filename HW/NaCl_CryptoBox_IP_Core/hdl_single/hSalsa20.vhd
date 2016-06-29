-- used reference from https://github.com/freecores/salsa20/blob/master/rtl/salsaa_mc.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.std_logic_unsigned.all;
  
entity hSalsa20 is
    Port ( 
        CLK     : in  STD_LOGIC;
        
        INIT    : in  STD_LOGIC;
        DONE    : out STD_LOGIC;
        
        SEL     : in  STD_LOGIC;    -- 1 for Salsa20, 0 for HSalsa20
        
        D_IN   : in  STD_LOGIC_VECTOR(127 downto 0);
        KEY     : in  STD_LOGIC_VECTOR(255 downto 0);
        D_OUT  : out STD_LOGIC_VECTOR(511 downto 0)
    );
end hSalsa20;

architecture Behavioral of hSalsa20 is

    type state_type is (s_wait, s_init, s_work, st_fin_salsa20, st_fin_hsalsa20);
	signal state   : state_type;

    type array_x is array(0 to 15) of std_logic_vector(31 downto 0);
    signal x : array_x; 
    
    signal counter_round    : std_logic_vector(7 downto 0)   := (others => '0');
    signal counter_calc     : std_logic_vector(7 downto 0)   := (others => '0');
        
    signal data_out         : std_logic_vector(511 downto 0) := (others => '0');
    signal j                : std_logic_vector(511 downto 0) := (others => '0');
    
    signal sig_done         : std_logic := '0';
    
    signal reg_sel          : std_logic := '0';

begin

    D_OUT <= data_out;

    DONE <= sig_done;
 
    process (CLK)
    begin
        if (CLK'event and CLK = '1') then
        
            case state is
                when s_wait =>
                    if INIT = '1' then
                        state    <= s_init;
                        
                        reg_sel  <= SEL;                        
                        sig_done <= '0';
                    else
                        state    <= s_wait;
                        
                        reg_sel  <= reg_sel;
                        sig_done <= sig_done;
                    end if;
                    
                    counter_round <= counter_round;             
                    counter_calc <= counter_calc;
                                                            
                when s_init =>
                    x(0)  <= x"61707865";
                    x(1)  <= KEY    (32 * 0 + 31 downto 32 * 0 + 0);
                    x(2)  <= KEY    (32 * 1 + 31 downto 32 * 1 + 0);
                    x(3)  <= KEY    (32 * 2 + 31 downto 32 * 2 + 0);
                    x(4)  <= KEY    (32 * 3 + 31 downto 32 * 3 + 0);
                    x(5)  <= x"3320646e";
                    x(6)  <= D_IN  (32 * 0 + 31 downto 32 * 0 + 0);
                    x(7)  <= D_IN  (32 * 1 + 31 downto 32 * 1 + 0);
                    x(8)  <= D_IN  (32 * 2 + 31 downto 32 * 2 + 0);
                    x(9)  <= D_IN  (32 * 3 + 31 downto 32 * 3 + 0);
                    x(10) <= x"79622d32";
                    x(11) <= KEY    (32 * 4 + 31 downto 32 * 4 + 0);
                    x(12) <= KEY    (32 * 5 + 31 downto 32 * 5 + 0);
                    x(13) <= KEY    (32 * 6 + 31 downto 32 * 6 + 0);
                    x(14) <= KEY    (32 * 7 + 31 downto 32 * 7 + 0);
                    x(15) <= x"6b206574";
                    
                    j(32 * 00 + 31 downto 32 * 00 + 0)  <= x"61707865";
                    j(32 * 01 + 31 downto 32 * 01 + 0)  <= KEY    (32 * 0 + 31 downto 32 * 0 + 0);
                    j(32 * 02 + 31 downto 32 * 02 + 0)  <= KEY    (32 * 1 + 31 downto 32 * 1 + 0);
                    j(32 * 03 + 31 downto 32 * 03 + 0)  <= KEY    (32 * 2 + 31 downto 32 * 2 + 0);
                    j(32 * 04 + 31 downto 32 * 04 + 0)  <= KEY    (32 * 3 + 31 downto 32 * 3 + 0);
                    j(32 * 05 + 31 downto 32 * 05 + 0)  <= x"3320646e";
                    j(32 * 06 + 31 downto 32 * 06 + 0)  <= D_IN  (32 * 0 + 31 downto 32 * 0 + 0);
                    j(32 * 07 + 31 downto 32 * 07 + 0)  <= D_IN  (32 * 1 + 31 downto 32 * 1 + 0);
                    j(32 * 08 + 31 downto 32 * 08 + 0)  <= D_IN  (32 * 2 + 31 downto 32 * 2 + 0);
                    j(32 * 09 + 31 downto 32 * 09 + 0)  <= D_IN  (32 * 3 + 31 downto 32 * 3 + 0);
                    j(32 * 10 + 31 downto 32 * 10 + 0)  <= x"79622d32";
                    j(32 * 11 + 31 downto 32 * 11 + 0)  <= KEY    (32 * 4 + 31 downto 32 * 4 + 0);
                    j(32 * 12 + 31 downto 32 * 12 + 0)  <= KEY    (32 * 5 + 31 downto 32 * 5 + 0);
                    j(32 * 13 + 31 downto 32 * 13 + 0)  <= KEY    (32 * 6 + 31 downto 32 * 6 + 0);
                    j(32 * 14 + 31 downto 32 * 14 + 0)  <= KEY    (32 * 7 + 31 downto 32 * 7 + 0);
                    j(32 * 15 + 31 downto 32 * 15 + 0)  <= x"6b206574";
                                        
                    state <= s_work;
                    counter_round <= x"00";
                    counter_calc <= x"00";
                    
                    sig_done <= sig_done;
                    
                when s_work =>
                
                    counter_calc <= counter_calc + x"01";
                    
                    if counter_calc = 7 then
                        if counter_round = 9 then
                            if reg_sel = '1' then
                                state <= st_fin_salsa20;
                            else
                                state <= st_fin_hsalsa20;
                            end if;
                                
                        else
                            counter_calc <= x"00";
                            counter_round <= counter_round + x"01";
                        end if;
                    end if;
                                        
                    reg_sel <= reg_sel;
                    
                    -- processing goes here
                    case counter_calc is
                        when x"00" =>                        
                            x(04) <= x(04) xor std_logic_vector( rotate_left(unsigned(x(12)+x(00)),7));
                            x(09) <= x(09) xor std_logic_vector( rotate_left(unsigned(x(01)+x(05)),7));
                            x(14) <= x(14) xor std_logic_vector( rotate_left(unsigned(x(06)+x(10)),7));
                            x(03) <= x(03) xor std_logic_vector( rotate_left(unsigned(x(11)+x(15)),7));
                        when x"01" =>
                            x(08) <= x(08) xor std_logic_vector( rotate_left(unsigned(x(00)+x(04)),9));
                            x(13) <= x(13) xor std_logic_vector( rotate_left(unsigned(x(05)+x(09)),9));
                            x(02) <= x(02) xor std_logic_vector( rotate_left(unsigned(x(10)+x(14)),9));
                            x(07) <= x(07) xor std_logic_vector( rotate_left(unsigned(x(15)+x(03)),9));
                        when x"02" =>
                            x(12) <= x(12) xor std_logic_vector( rotate_left(unsigned(x(04)+x(08)),13));
                            x(01) <= x(01) xor std_logic_vector( rotate_left(unsigned(x(09)+x(13)),13));
                            x(06) <= x(06) xor std_logic_vector( rotate_left(unsigned(x(14)+x(02)),13));
                            x(11) <= x(11) xor std_logic_vector( rotate_left(unsigned(x(03)+x(07)),13));
                        when x"03" =>
                            x(00) <= x(00) xor std_logic_vector( rotate_left(unsigned(x(08)+x(12)),18));
                            x(05) <= x(05) xor std_logic_vector( rotate_left(unsigned(x(13)+x(01)),18));
                            x(10) <= x(10) xor std_logic_vector( rotate_left(unsigned(x(02)+x(06)),18));
                            x(15) <= x(15) xor std_logic_vector( rotate_left(unsigned(x(07)+x(11)),18));
                            
                        when x"04" =>
                            x(01) <= x(01) xor std_logic_vector( rotate_left(unsigned(x(03)+x(00)),07));
                            x(06) <= x(06) xor std_logic_vector( rotate_left(unsigned(x(04)+x(05)),07));
                            x(11) <= x(11) xor std_logic_vector( rotate_left(unsigned(x(09)+x(10)),07));
                            x(12) <= x(12) xor std_logic_vector( rotate_left(unsigned(x(14)+x(15)),07));
                        when x"05" =>
                            x(02) <= x(02) xor std_logic_vector( rotate_left(unsigned(x(00)+x(01)),09));
                            x(07) <= x(07) xor std_logic_vector( rotate_left(unsigned(x(05)+x(06)),09));
                            x(08) <= x(08) xor std_logic_vector( rotate_left(unsigned(x(10)+x(11)),09));
                            x(13) <= x(13) xor std_logic_vector( rotate_left(unsigned(x(15)+x(12)),09));
                        when x"06" =>
                            x(03) <= x(03) xor std_logic_vector( rotate_left(unsigned(x(01)+x(02)),13));
                            x(04) <= x(04) xor std_logic_vector( rotate_left(unsigned(x(06)+x(07)),13));
                            x(09) <= x(09) xor std_logic_vector( rotate_left(unsigned(x(11)+x(08)),13));
                            x(14) <= x(14) xor std_logic_vector( rotate_left(unsigned(x(12)+x(13)),13));
                        when x"07" =>
                            x(00) <= x(00) xor std_logic_vector( rotate_left(unsigned(x(02)+x(03)),18));
                            x(05) <= x(05) xor std_logic_vector( rotate_left(unsigned(x(07)+x(04)),18));
                            x(10) <= x(10) xor std_logic_vector( rotate_left(unsigned(x(08)+x(09)),18));
                            x(15) <= x(15) xor std_logic_vector( rotate_left(unsigned(x(13)+x(14)),18));
                        when others =>
                            null;
                        
                        sig_done <= sig_done;
                        
                    end case;
                    
                when st_fin_salsa20 =>
                    data_out(32 * 00 + 31 downto 32 * 00 + 0)  <= j(32 * 00 + 31 downto 32 * 00 + 0) + x(00);
                    data_out(32 * 01 + 31 downto 32 * 01 + 0)  <= j(32 * 01 + 31 downto 32 * 01 + 0) + x(01);
                    data_out(32 * 02 + 31 downto 32 * 02 + 0)  <= j(32 * 02 + 31 downto 32 * 02 + 0) + x(02);
                    data_out(32 * 03 + 31 downto 32 * 03 + 0)  <= j(32 * 03 + 31 downto 32 * 03 + 0) + x(03);
                    data_out(32 * 04 + 31 downto 32 * 04 + 0)  <= j(32 * 04 + 31 downto 32 * 04 + 0) + x(04);
                    data_out(32 * 05 + 31 downto 32 * 05 + 0)  <= j(32 * 05 + 31 downto 32 * 05 + 0) + x(05);
                    data_out(32 * 06 + 31 downto 32 * 06 + 0)  <= j(32 * 06 + 31 downto 32 * 06 + 0) + x(06);
                    data_out(32 * 07 + 31 downto 32 * 07 + 0)  <= j(32 * 07 + 31 downto 32 * 07 + 0) + x(07);
                    data_out(32 * 08 + 31 downto 32 * 08 + 0)  <= j(32 * 08 + 31 downto 32 * 08 + 0) + x(08);
                    data_out(32 * 09 + 31 downto 32 * 09 + 0)  <= j(32 * 09 + 31 downto 32 * 09 + 0) + x(09);
                    data_out(32 * 10 + 31 downto 32 * 10 + 0)  <= j(32 * 10 + 31 downto 32 * 10 + 0) + x(10);
                    data_out(32 * 11 + 31 downto 32 * 11 + 0)  <= j(32 * 11 + 31 downto 32 * 11 + 0) + x(11);
                    data_out(32 * 12 + 31 downto 32 * 12 + 0)  <= j(32 * 12 + 31 downto 32 * 12 + 0) + x(12);
                    data_out(32 * 13 + 31 downto 32 * 13 + 0)  <= j(32 * 13 + 31 downto 32 * 13 + 0) + x(13);
                    data_out(32 * 14 + 31 downto 32 * 14 + 0)  <= j(32 * 14 + 31 downto 32 * 14 + 0) + x(14);
                    data_out(32 * 15 + 31 downto 32 * 15 + 0)  <= j(32 * 15 + 31 downto 32 * 15 + 0) + x(15);
                    
                    state <= s_wait;
                  
                    counter_round <= counter_round;             
                    counter_calc <= counter_calc;
                    
                    sig_done <= '1';
                                        
                when st_fin_hsalsa20 =>
                    data_out(32 * 00 + 31 downto 32 * 00 + 0)  <= x(00);
                    data_out(32 * 01 + 31 downto 32 * 01 + 0)  <= x(05);
                    data_out(32 * 02 + 31 downto 32 * 02 + 0)  <= x(10);
                    data_out(32 * 03 + 31 downto 32 * 03 + 0)  <= x(15);
                    data_out(32 * 04 + 31 downto 32 * 04 + 0)  <= x(06);
                    data_out(32 * 05 + 31 downto 32 * 05 + 0)  <= x(07);
                    data_out(32 * 06 + 31 downto 32 * 06 + 0)  <= x(08);
                    data_out(32 * 07 + 31 downto 32 * 07 + 0)  <= x(09);
                    
                    state <= s_wait;
                                      
                    counter_round <= counter_round;             
                    counter_calc <= counter_calc;
                    
                    sig_done <= '1';
                    
               when others =>
                    null;        
                                        
            end case;     
        end if;
    end process;

end Behavioral;