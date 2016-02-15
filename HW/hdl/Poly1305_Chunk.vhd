-- Poly1305_Chunk.vhd
-- 
-- In this block one chunk of Poly1305 is handled. 
-- Corresponing operation is:
--    ACC_out := (ACC_in * R) mod (2^130 - 5);
--
-- This is handled in 13 bits blocks, as it is handled here in magma code
-- + https://github.com/furkanturan/Hardware-Accelerated-SigmaVPN/blob/master/CryptoBox_Test/Magma/multiply13.txt
--
-- + Selection of 13 bit (instead of 26 for instance) is to be able to utilize DSP48 slices in the ZYNQ
--
-- + Therefore, multiplication is handled in 10 blocks of 13 bits.
-- + Processing 10 blocks are parallelized.
--
-- + After multiplications, results of 13 bit multiplications are combined 
--   (in shifted manner as it is handled in hand multiplication)
-- + Of course there are carry propagations also from one block to another
-- + That takes 4 more states, and result of one Chunk of Poly1305 is ready.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;

entity Poly1305_Chunk is
    Port ( 
        CLK     : in  std_logic;        
        RST     : in  std_logic;             
        INIT    : in  std_logic;             
        DONE    : out std_logic;
                
        R       : in  std_logic_vector(127 downto 0);
        
        ACC_in  : in  std_logic_vector(129 downto 0);
        ACC_out : out std_logic_vector(129 downto 0)
    );
end Poly1305_Chunk;

architecture Behavioral of Poly1305_Chunk is

    
    signal R_130 : std_logic_vector(129 downto 0) := (others => '0');
    
    signal counter  : integer range 0 to 9 := 0;
    
    type state_type is (s_reset, s_init, s_mult, s_prop1, s_prop2, s_prop3);
    signal state   : state_type;

    signal sig_DONE : std_logic := '0';

    type array_H is array (0 to 9) of std_logic_vector(29 downto 0);
    signal H : array_H := ((others => (others=>'0')));



    type array_accin5 is array (0 to 9) of std_logic_vector(15 downto 0);
    signal accin5 : array_accin5 := ((others => (others=>'0')));

    function compute_accin5 (x: std_logic_vector) return array_accin5 is
        variable ret : array_accin5;
    begin
        for i in 0 to 9 loop
            ret(i) := ('0' & x(13*i+12 downto 13*i) & "00") + ("000" & x(13*i+12 downto 13*i));
        end loop;
        return ret;
    end function;
           
    
    function multiply_with_R (x130, r130: std_logic_vector; x5: array_accin5; c: integer; HH: array_H) return array_H is
        variable ret : array_H;
    begin
        for i in 0 to 9 loop
            
            if i >= c then
                ret(i) := HH(i) + ( "00" & ( unsigned( x130(13*c+12 downto 13*c) ) * unsigned( r130(13*(i-c)+12 downto 13*(i-c)) ) ) );
            else
                ret(i) := HH(i) + ( unsigned( x5( c ) ) * unsigned( r130(13*(10-c+i)+12 downto 13*(10-c+i)) ) );
            end if;
        end loop;                
        return ret;
    end function;

   
    signal result  : std_logic_vector(129 downto 0) := (others => '0');
    
    signal carry : std_logic_vector(10 downto 0) := (others => '0');
    
    signal result0 : std_logic_vector(14 downto 0) := (others => '0');
    signal result1 : std_logic_vector(13 downto 0) := (others => '0');
    signal result2 : std_logic_vector(13 downto 0) := (others => '0');
    signal result3 : std_logic_vector(13 downto 0) := (others => '0');
    signal result4 : std_logic_vector(13 downto 0) := (others => '0');
    signal result5 : std_logic_vector(13 downto 0) := (others => '0');
    signal result6 : std_logic_vector(13 downto 0) := (others => '0');
    signal result7 : std_logic_vector(13 downto 0) := (others => '0');
    signal result8 : std_logic_vector(13 downto 0) := (others => '0');
    signal result9 : std_logic_vector(13 downto 0) := (others => '0');

begin

    carry( 1 downto 0)  <= result0(14 downto 13);
    carry( 2)           <= result1(13);
    carry( 3)           <= result2(13);
    carry( 4)           <= result3(13);
    carry( 5)           <= result4(13);
    carry( 6)           <= result5(13);
    carry( 7)           <= result6(13);
    carry( 8)           <= result7(13);
    carry( 9)           <= result8(13);
    carry(10)           <= result9(13);

    result( 12 downto   0) <= result0(12 downto 0);
    result( 25 downto  13) <= result1(12 downto 0);
    result( 38 downto  26) <= result2(12 downto 0);
    result( 51 downto  39) <= result3(12 downto 0);
    result( 64 downto  52) <= result4(12 downto 0);
    result( 77 downto  65) <= result5(12 downto 0);
    result( 90 downto  78) <= result6(12 downto 0);
    result(103 downto  91) <= result7(12 downto 0);
    result(116 downto 104) <= result8(12 downto 0);
    result(129 downto 117) <= result9(12 downto 0);

    DONE <= sig_DONE;
    ACC_out <= result;

    R_130 <= "00" & R;

    process (CLK)
    begin
    if (CLK'event and CLK = '1') then
    
        if RST = '1' then
                        
            state <= s_reset;
            counter <= counter;
            sig_DONE <= '0';
            
        else
            
            case state is
            
                when s_reset =>
                
                    if INIT = '1' then
                        state <= s_init;
                    else
                        state <= s_reset;
                    end if;
                
                    counter <= counter;
                    sig_DONE <= '0';
                    
            
                when s_init =>
                
                    -- Initialization state 
                    -- + Accumulator collections H are reset to zero
                    -- + accin5 which stores 13 bit parses if ACC_in multiplied with 5
                
                    H <= ((others => (others=>'0')));
                
                    accin5 <= compute_accin5(ACC_in);                    
                    
                    counter <= 0;
                
                    state <= s_mult;
                    
                    sig_DONE <= '0';
                
                when s_mult =>
                
                    -- Multiplication state
                    -- + 13 bits multiplications accourding to the Magma code piece below is handled:
                    -- + The multiplication code is handled in pieces
                    -- + At each clock, one column of operations given below are executed, and h0 to h1 are updated
                    -- + At the 10th clock, multiplication is done
                    -- 
                    -- Magma Code of the multiplication
                    -- h[1] := (x[1] * r[1]  +  5 * x[2] * r[10]  +  5 * x[3] * r[9]  +  5 * x[4] * r[8]  +  5 * x[5] * r[7]  +  5 * x[6] * r[6]   +  5 * x[7] * r[5]   +  5 * x[8] * r[4]   +  5 * x[9] * r[3]   +  5 * x[10] * r[2]  ) ;
                    -- h[2] := (x[1] * r[2]  +      x[2] * r[1]   +  5 * x[3] * r[10] +  5 * x[4] * r[9]  +  5 * x[5] * r[8]  +  5 * x[6] * r[7]   +  5 * x[7] * r[6]   +  5 * x[8] * r[5]   +  5 * x[9] * r[4]   +  5 * x[10] * r[3]  ) ;
                    -- h[3] := (x[1] * r[3]  +      x[2] * r[2]   +      x[3] * r[1]  +  5 * x[4] * r[10] +  5 * x[5] * r[9]  +  5 * x[6] * r[8]   +  5 * x[7] * r[7]   +  5 * x[8] * r[6]   +  5 * x[9] * r[5]   +  5 * x[10] * r[4]  ) ;
                    -- h[4] := (x[1] * r[4]  +      x[2] * r[3]   +      x[3] * r[2]  +      x[4] * r[1]  +  5 * x[5] * r[10] +  5 * x[6] * r[9]   +  5 * x[7] * r[8]   +  5 * x[8] * r[7]   +  5 * x[9] * r[6]   +  5 * x[10] * r[5]  ) ;
                    -- h[5] := (x[1] * r[5]  +      x[2] * r[4]   +      x[3] * r[3]  +      x[4] * r[2]  +      x[5] * r[1]  +  5 * x[6] * r[10]  +  5 * x[7] * r[9]   +  5 * x[8] * r[8]   +  5 * x[9] * r[7]   +  5 * x[10] * r[6]  ) ;
                    -- h[6] := (x[1] * r[6]  +      x[2] * r[5]   +      x[3] * r[4]  +      x[4] * r[3]  +      x[5] * r[2]  +      x[6] * r[1]   +  5 * x[7] * r[10]  +  5 * x[8] * r[9]   +  5 * x[9] * r[8]   +  5 * x[10] * r[7]  ) ;
                    -- h[7] := (x[1] * r[7]  +      x[2] * r[6]   +      x[3] * r[5]  +      x[4] * r[4]  +      x[5] * r[3]  +      x[6] * r[2]   +      x[7] * r[1]   +  5 * x[8] * r[10]  +  5 * x[9] * r[9]   +  5 * x[10] * r[8]  ) ;
                    -- h[8] := (x[1] * r[8]  +      x[2] * r[7]   +      x[3] * r[6]  +      x[4] * r[5]  +      x[5] * r[4]  +      x[6] * r[3]   +      x[7] * r[2]   +      x[8] * r[1]   +  5 * x[9] * r[10]  +  5 * x[10] * r[9]  ) ;
                    -- h[9] := (x[1] * r[9]  +      x[2] * r[8]   +      x[3] * r[7]  +      x[4] * r[6]  +      x[5] * r[5]  +      x[6] * r[4]   +      x[7] * r[3]   +      x[8] * r[2]   +      x[9] * r[1]   +  5 * x[10] * r[10] ) ;
                    -- h[10]:= (x[1] * r[10] +      x[2] * r[9]   +      x[3] * r[8]  +      x[4] * r[7]  +      x[5] * r[6]  +      x[6] * r[5]   +      x[7] * r[4]   +      x[8] * r[3]   +      x[9] * r[2]   +      x[10] * r[1]  ) ;

                    H <= multiply_with_R(ACC_in, R_130, accin5, counter, H);
                    
                    counter <= counter + 1;
                    
                    if counter = 9 then
                        state <= s_prop1;
                    else 
                        state <= s_mult;
                    end if;
                    
                    sig_DONE <= sig_DONE;
                    
                when s_prop1 =>
                    
                    -- Propagation state:
                    -- + This state and following 2 states are to perform higher-lower 13 bits additiions, 
                    --   and carry propagation of the multiplication results
                    -- + It visits first s_prop1 state, for higher-lower 13 bits additiions
                    --   then s_prop3 state for carry propagations
                    --   then s_prop2 state for higher-lower 13 bits additiions again
                    --   then s_prop3 state again for carry propagations 
                    --        (should state there until there is no carry to propagate)
                    
                    result0 <= ("00" & H(0) (12 downto 0) ) + ("00" & H(9) (25 downto 13) ) + ("00" & H(9) (23 downto 13) & "00" );
                    result1 <= ( '0' & H(1) (12 downto 0) ) + ( '0' & H(0) (25 downto 13) );
                    result2 <= ( '0' & H(2) (12 downto 0) ) + ( '0' & H(1) (25 downto 13) );
                    result3 <= ( '0' & H(3) (12 downto 0) ) + ( '0' & H(2) (25 downto 13) );
                    result4 <= ( '0' & H(4) (12 downto 0) ) + ( '0' & H(3) (25 downto 13) );
                    result5 <= ( '0' & H(5) (12 downto 0) ) + ( '0' & H(4) (25 downto 13) );
                    result6 <= ( '0' & H(6) (12 downto 0) ) + ( '0' & H(5) (25 downto 13) );
                    result7 <= ( '0' & H(7) (12 downto 0) ) + ( '0' & H(6) (25 downto 13) );
                    result8 <= ( '0' & H(8) (12 downto 0) ) + ( '0' & H(7) (25 downto 13) );
                    result9 <= ( '0' & H(9) (12 downto 0) ) + ( '0' & H(8) (25 downto 13) );          
                    
                    counter <= counter;
                    
                    state <= s_prop3;
                    
                    sig_DONE <= sig_DONE;
                
                 when s_prop2 =>
                                       
                    result0 <= result0 + H(8) (29 downto 26) + (H(8) (29 downto 26) & "00");
                    result1 <= result1 + H(9) (29 downto 26) +  H(9) (29 downto 24); 
                    result2 <= result2 + H(0) (29 downto 26) ; 
                    result3 <= result3 + H(1) (29 downto 26) ; 
                    result4 <= result4 + H(2) (29 downto 26) ; 
                    result5 <= result5 + H(3) (29 downto 26) ; 
                    result6 <= result6 + H(4) (29 downto 26) ; 
                    result7 <= result7 + H(5) (29 downto 26) ; 
                    result8 <= result8 + H(6) (29 downto 26) ; 
                    result9 <= result9 + H(7) (29 downto 26) ;
                   
                   counter <= counter;
                   
                   state <= s_prop3;
                   
                   sig_DONE <= sig_DONE;
                   
                when s_prop3 =>
                
                    result0 <= ("00" & result0(12 downto 0) ) + carry(10) + (carry(10) & "00");
                    result1 <= ( '0' & result1(12 downto 0) ) + carry(1 downto 0);
                    result2 <= ( '0' & result2(12 downto 0) ) + carry(2); 
                    result3 <= ( '0' & result3(12 downto 0) ) + carry(3); 
                    result4 <= ( '0' & result4(12 downto 0) ) + carry(4); 
                    result5 <= ( '0' & result5(12 downto 0) ) + carry(5);
                    result6 <= ( '0' & result6(12 downto 0) ) + carry(6); 
                    result7 <= ( '0' & result7(12 downto 0) ) + carry(7); 
                    result8 <= ( '0' & result8(12 downto 0) ) + carry(8); 
                    result9 <= ( '0' & result9(12 downto 0) ) + carry(9); 
                    
                    counter <= counter;                    
                    
                    if carry = "00000000000" then
                        state <= s_reset;
                        sig_DONE <= '1';
                    else
                        state <= s_prop2;
                        sig_DONE <= sig_DONE;
                    end if;                   
                   
                when others =>
                    null;
            end case;            
        end if;
    end if;
    end process;

end Behavioral;