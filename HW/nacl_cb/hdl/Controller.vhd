library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Controller is
    Port ( 
        CLK         : in  std_logic;
        RSTN        : in  std_logic;
    
        INR_L2LOAD  : out std_logic;        
        INR_RDY     : out std_logic;      
        INR_DONE    : in  std_logic;
        INR_CMD     : in  std_logic_vector(15 downto 0);
        INR_MLEN    : in  std_logic_vector(15 downto 0);
        
        NOM_SEL     : out std_logic;
        NOM_RST     : out std_logic;
        NOM_UPD     : out std_logic;
        
        KEY_SEL     : out std_logic;
        
        HoS_INIT    : out std_logic;
        HoS_SEL     : out std_logic;
        HoS_DONE    : in  std_logic;
        
        REG_EN      : out std_logic;
        
        DCR_EN      : out std_logic;
        DCR_SEL     : out std_logic;
        
        CIP_SEL     : out std_logic_vector(1 downto 0);
        
        POL_INIT    : out std_logic;
        POL_RSLOAD  : out std_logic;
        POL_LAST    : out std_logic;
        POL_LEN     : out std_logic_vector(3 downto 0);
        POL_DONE    : in  std_logic;
        
        MAC_SEL     : out std_logic;
        
        OUT_INIT    : out std_logic;
        OUT_InSTART : out std_logic_vector(3 downto 0);
        OUT_InSTOP  : out std_logic_vector(3 downto 0);
        OUT_LAST    : out std_logic;
        OUT_DONE    : in  std_logic;
        
        DMA_INIT    : out std_logic;
        DMA_CONT    : out std_logic;
        DMA_TLEN    : out std_logic_vector(15 downto 0)
    );
end Controller;

architecture Behavioral of Controller is

    signal sig_INR_L2LOAD  : std_logic := '0';       
    signal sig_INR_RDY     : std_logic := '0';
        
    signal sig_NOM_SEL     : std_logic := '0';
    signal sig_NOM_RST     : std_logic := '0';
    signal sig_NOM_UPD     : std_logic := '0';
        
    signal sig_KEY_SEL     : std_logic := '0';
        
    signal sig_HoS_INIT    : std_logic := '0';
    signal sig_HoS_SEL     : std_logic := '0';
        
    signal sig_REG_EN      : std_logic := '0'; 
            
    signal sig_DCR_EN      : std_logic := '0';
    signal sig_DCR_SEL     : std_logic := '0'; 
        
    signal sig_CIP_SEL     : std_logic_vector(1 downto 0) := (others => '0');
        
    signal sig_POL_INIT    : std_logic := '0';
    signal sig_POL_RSLOAD  : std_logic := '0';
    signal sig_POL_LAST    : std_logic := '0';
    signal sig_POL_LEN     : std_logic_vector(3 downto 0) := (others => '1');
        
    signal sig_MAC_SEL     : std_logic := '0';
        
    signal sig_OUT_INIT    : std_logic := '0';
    signal sig_OUT_InSTART : std_logic_vector(3 downto 0) := (others => '0');
    signal sig_OUT_InSTOP  : std_logic_vector(3 downto 0) := (others => '0');
    signal sig_OUT_LAST    : std_logic := '0';
    
    signal sig_DMA_INIT    : std_logic := '0';
    signal sig_DMA_CONT    : std_logic := '0';
    signal sig_DMA_TLEN    : std_logic_vector(15 downto 0) := (others => '0');

    type state_type is (s_idle, s_read_init, s_middle1, s_2ndkey, s_middle2, s_middle3, s_firstsalsa, s_block1, s_middle, s_block2);
    signal state   : state_type;
    
    signal cnt_bytes        : std_logic_vector(9 downto 0) := (others => '0');

    signal reg_firstblock   : std_logic := '0';
    signal reg_pol_lim      : std_logic_vector(1 downto 0) := (others => '0');

begin

    INR_L2LOAD  <= sig_INR_L2LOAD  ;       
    INR_RDY     <= sig_INR_RDY     ;
        
    NOM_SEL     <= sig_NOM_SEL     ;
    NOM_RST     <= sig_NOM_RST     ;
    NOM_UPD     <= sig_NOM_UPD     ;
        
    KEY_SEL     <= sig_KEY_SEL     ;
        
    HoS_INIT    <= sig_HoS_INIT    ;
    HoS_SEL     <= sig_HoS_SEL     ;
        
    REG_EN      <= sig_REG_EN      ;
        
    DCR_EN      <= sig_DCR_EN      ;
    DCR_SEL     <= sig_DCR_SEL     ; 
        
    CIP_SEL     <= sig_CIP_SEL     ;
        
    POL_INIT    <= sig_POL_INIT    ;
    POL_RSLOAD  <= sig_POL_RSLOAD  ;
    POL_LAST    <= sig_POL_LAST    ;
    POL_LEN     <= sig_POL_LEN     ;
       
    MAC_SEL     <= sig_MAC_SEL     ;
        
    OUT_INIT    <= sig_OUT_INIT    ;
    OUT_InSTART <= sig_OUT_InSTART ;
    OUT_InSTOP  <= sig_OUT_InSTOP  ;
    OUT_LAST    <= sig_OUT_LAST    ;
    
    DMA_INIT    <= sig_DMA_INIT    ;
    DMA_CONT    <= sig_DMA_CONT    ;
    DMA_TLEN    <= sig_DMA_TLEN    ;
    
    process (CLK)
    begin    
    if (CLK'event and CLK = '1') then
    
        if RSTN = '0' then
        
            sig_NOM_RST <= '1';
            state <= s_idle;
            reg_firstblock <= '0';
            reg_pol_lim <= "00";
        else
              
            case state is
                
                when s_idle =>
                
                    state <= s_read_init;                    
                    
                    
                    sig_INR_RDY     <= '1';
                    
                    sig_NOM_RST     <= '0'; 
                    sig_NOM_SEL     <= '0';
                    sig_NOM_UPD     <= '0';
                    
                    sig_HoS_INIT    <= '0';
                    sig_HoS_SEL     <= '0';
                    
                    sig_KEY_SEL     <= '0';
                    
                    sig_INR_L2LOAD  <= '0'; 
                    
                    sig_REG_EN      <= '0';
                    
                    sig_DCR_EN      <= '0';
                    sig_DCR_SEL     <= '0'; 
                                        
                    sig_POL_LAST    <= '0';
                    sig_POL_LEN     <= "1111";
                    
                    sig_OUT_LAST    <= '0';  
                    
                    sig_DMA_INIT    <= '0';
                    sig_DMA_CONT    <= '0';
                    sig_DMA_TLEN    <= (others => '0');
                    
                    cnt_bytes       <= (others => '0');
                    
                    reg_firstblock <= '0';
                    reg_pol_lim <= "00";                    
                             
                 when s_read_init =>
                    
                    if INR_DONE = '0' then
                        state <= s_read_init;
                    else
                        state <= s_middle1;
                    end if;
                    
                    
                    sig_INR_RDY     <= '1';
                    
                    sig_NOM_RST     <= sig_NOM_RST;
                    sig_NOM_SEL     <= sig_NOM_SEL;
                    sig_NOM_UPD     <= sig_NOM_UPD;
                    
                    sig_HoS_INIT    <= INR_DONE;
                    sig_HoS_SEL     <= sig_HoS_SEL;
                    
                    sig_KEY_SEL     <= sig_KEY_SEL;
                    
                    sig_INR_L2LOAD  <= sig_INR_L2LOAD;
                                        
                    sig_REG_EN      <= sig_REG_EN;
                    
                    sig_POL_LAST    <= sig_POL_LAST;
                    sig_POL_LEN     <= sig_POL_LEN;
                    
                    sig_OUT_LAST    <= sig_OUT_LAST;  
                    
                    sig_DMA_INIT    <= '0';
                    sig_DMA_CONT    <= '0';
                    sig_DMA_TLEN    <= (others => '0');
                    
                    cnt_bytes       <= cnt_bytes; 
                    
                    reg_firstblock <= reg_firstblock;                    

                 when s_middle1 =>
                 
                    sig_INR_RDY     <= '0';
                    sig_POL_INIT    <= '0';
                    sig_OUT_INIT    <= '0';                                        
                    sig_HoS_INIT    <= '0';
                    sig_NOM_UPD     <= '0';
                    
                    state <= s_2ndkey;

                 when s_2ndkey =>
                    
                    if HoS_DONE = '0' then
                        state <= s_2ndkey;
                    else
                        state <= s_middle2;
                        
                    end if;
                     
                    sig_INR_RDY     <= '0';
                    
                    sig_NOM_RST     <= sig_NOM_RST;
                    sig_NOM_SEL     <= sig_NOM_SEL;
                    sig_NOM_UPD     <= sig_NOM_UPD;
                    
                    sig_HoS_INIT    <= '0';
                    sig_HoS_SEL     <= HoS_DONE;
                    
                    sig_KEY_SEL     <= HoS_DONE;
                    
                    sig_INR_L2LOAD  <= HoS_DONE;
                                        
                    sig_POL_LAST    <= sig_POL_LAST;
                    sig_POL_LEN     <= sig_POL_LEN;
                    
                    sig_OUT_LAST    <= sig_OUT_LAST;  
                    
                    if HoS_DONE = '1' then
                        sig_DMA_INIT    <= '1';
                        sig_DMA_CONT    <= '1';
                        sig_DMA_TLEN    <= INR_MLEN + "10000";
                    else
                        sig_DMA_INIT    <= '0';
                        sig_DMA_CONT    <= '0';
                        sig_DMA_TLEN    <= (others => '0');
                    end if;
                    
                    cnt_bytes       <= INR_MLEN(9 downto 0) - '1';
                                        
                    reg_firstblock <= reg_firstblock;
                 
                 when s_middle2 =>
                                     
                    sig_INR_RDY     <= '0';
                    sig_POL_INIT    <= '0';
                    sig_OUT_INIT    <= '0';                                        
                    sig_HoS_INIT    <= '1';
                    sig_NOM_UPD     <= '0';
                    sig_INR_L2LOAD  <= '0';
                    sig_NOM_SEL     <= '1';
                    
                    state <= s_middle3;
                    
                 when s_middle3 =>
                                                         
                    sig_INR_RDY     <= '0';
                    sig_POL_INIT    <= '0';
                    sig_OUT_INIT    <= '0';                                        
                    sig_HoS_INIT    <= '0';
                    sig_NOM_UPD     <= '0';
                    sig_INR_L2LOAD  <= '0';
                    sig_NOM_SEL     <= '1';
                    
                    state <= s_firstsalsa;
                 
                 when s_firstsalsa =>
                 
                    if HoS_DONE = '0' then
                        state <= s_firstsalsa;
                    else
                        state <= s_block1;
                    end if;                    
                    
                    sig_INR_RDY     <= sig_INR_RDY;
                    
                    sig_NOM_RST     <= sig_NOM_RST;
                    sig_NOM_SEL     <= '1';
                    sig_NOM_UPD     <= '0'; 
                                        
                    sig_HoS_INIT   <= '0';                                        
                    sig_HoS_SEL     <= '1';
                        
                    sig_KEY_SEL     <= '1';
                    
                    sig_INR_L2LOAD  <= '0';
                                        
                    sig_REG_EN      <= '0';
                    sig_DCR_EN      <= '0';
                    
                    if INR_CMD(1) = '1' then
                        sig_DCR_SEL    <= '1';
                        --sig_DCR_EN     <= '1';
                    else
                        sig_DCR_SEL    <= '0';
                        --sig_DCR_EN     <= '0';
                    end if;
                    
                    sig_POL_RSLOAD  <= HoS_DONE;
                    sig_POL_LAST    <= sig_POL_LAST;
                    sig_POL_LEN     <= sig_POL_LEN;
                    
                    sig_OUT_LAST    <= sig_OUT_LAST;  
                    
                    sig_DMA_INIT    <= '0';
                    sig_DMA_CONT    <= '0';
                    sig_DMA_TLEN    <= sig_DMA_TLEN;
                    
                    cnt_bytes      <= cnt_bytes; 
                    
                    reg_firstblock  <= '1';
                 
                 when s_block1 =>
                 
                    sig_NOM_RST     <= sig_NOM_RST;
                    sig_NOM_SEL     <= sig_NOM_SEL;
                    
                    sig_HoS_SEL     <= sig_HoS_SEL;
                    
                    sig_KEY_SEL     <= sig_KEY_SEL;
                    
                    sig_INR_L2LOAD  <= sig_INR_L2LOAD;
                    
                    sig_REG_EN      <= '1';
                    
                    sig_DCR_SEL     <= sig_DCR_SEL;
                    
                    if INR_CMD(1) = '1' then
                        sig_DCR_EN     <= '1';
                    else
                        sig_DCR_EN     <= '0';
                    end if;
                    
                    sig_POL_RSLOAD  <= '0';
                    
                    cnt_bytes       <= cnt_bytes; 
                    
                    reg_firstblock  <= reg_firstblock;
                    
                 
                    -- This is starting state. There are 4 operations and this state is 
                    -- responsible of staerting them with correct parameters. Those are
                    --
                    -- --> InReg for fetching one more block of
                    -- 
                    -- --> hSalsa block creating one more block of cipher stream
                    --      + update nonce every time initing this block
                    --
                    -- --> Poly1305 creating MAC contribution of one quarter block
                    --      + This block works with 16 byte inputs while a block is 64 bytes
                    --        Therefore there is two registers for sub block index.
                    --              + sig_CIP_SEL for start index
                    --              + reg_pol_lim for stop index
                    --        There is both start and stop indexes, since first block's first 
                    --        sub block, is always at the middle of the full block, and any final 
                    --        sub-block may be at the middle of a full block.
                    --      + It requires to know what is the length of the sub-block.
                    --        
                    -- --> OutputDMA block to send one block cipher or plain text to RAM
                    --      + It can send blocks by chunks of 32 bytes because of DMA's
                    --        data channel width.
                    --      + There is chuck index signals for both start and stop again.
                    --        The requirement of them is quite similar to Poly1305 case.
                    
                 
                    if reg_firstblock = '1' then
                    
                        -- If current outputs are of the first block
                    
                        state <= s_middle;
                        
                        
                        if cnt_bytes(9 downto 5) /= "0000" then
                        --if cnt_bytes > 32 then
                         
                            -- If there are more blocks (full or partial)
                            -- Start fetching them 
                            -- Start creating stream for them
                            sig_INR_RDY     <= '1';
                            sig_NOM_UPD     <= '1';
                            sig_HoS_INIT    <= '1';
                            
                            -- Also the condition means that this is a full block
                            -- Therefore Poly1305 will
                            -- Start from half of the full block (as always for the first block)
                            -- Stop at the final sub-block.
                                                      
                            sig_POL_INIT    <= '1';
                            sig_POL_LEN     <= "1111";
                            sig_CIP_SEL     <= "10";
                            reg_pol_lim     <= "11";
                            sig_POL_LAST    <= '0';
                            
                            -- Start DMA to send this full block
                            -- Again start from middle till the end
                            
                            sig_OUT_INIT    <= '1';
                            sig_OUT_InSTART <= "1000";
                            sig_OUT_InSTOP  <= "1111";
                            sig_OUT_LAST    <= '0';
                           
                         else
                        --elsif cnt_bytes <= 32 then
                          
                            -- That means this may be a partial block, but maybe not
                            -- Either way there is no more blocks to be fetched.
                            
                            sig_INR_RDY     <= '0';
                            sig_NOM_UPD     <= '0';
                            sig_HoS_INIT    <= '0';
                            
                            -- Poly1305 will
                            -- Start from half of the full block (as always for the first block)
                            -- Stop at the last sub block
                            
                            sig_POL_INIT    <= '1';
                            sig_POL_LEN     <= "1111";
                            sig_CIP_SEL     <= "10";
                            reg_pol_lim     <= '1' & cnt_bytes(4);
                            if cnt_bytes(4) = '0' then
                                sig_POL_LAST    <= '1';
                                sig_POL_LEN     <= cnt_bytes(3 downto 0);  
                            else 
                                sig_POL_LAST    <= '0';
                            end if;
                                                                 
                            -- Start DMA to send this one (maybe partial or full)
                            -- Again start from the middle  (as always for the first block)
                            sig_OUT_INIT    <= '1';
                            sig_OUT_InSTART <= "1000";
                            sig_OUT_InSTOP <= '1' & cnt_bytes(4 downto 2);
                            sig_OUT_LAST    <= '0';
                                                        
                        end if;
                    
                    elsif cnt_bytes(9 downto 0) = "1111111111" then   
                    --elsif cnt_bytes == -1 then
                    
                        state <= s_middle;
                        
                        -- now there are no more bytes, but there is something to be sent with DMA
                        -- which is the final output of the Poly1305 block
                        
                        sig_INR_RDY     <= '0';
                        sig_NOM_UPD     <= '0';
                        sig_HoS_INIT    <= '0';
                        
                        -- don't ini poly also
                        sig_POL_INIT    <= '0';
                        sig_POL_LEN     <= sig_POL_LEN;
                        sig_CIP_SEL     <= sig_CIP_SEL;
                        reg_pol_lim     <= reg_pol_lim;
                        sig_POL_LAST    <= sig_POL_LAST;
                        
                        -- send Poly's 128 bit output to with DMA
                        sig_OUT_INIT    <= '1';
                        sig_OUT_InSTART <= "0000";
                        sig_OUT_InSTOP  <= "0011";
                        sig_OUT_LAST    <= '1';
                        sig_MAC_SEL     <= '1';
                    
                    elsif cnt_bytes(9 downto 6) /= "0000" then
                    --elsif cnt_bytes > 64 then
                    
                        state <= s_middle;
                                        
                        -- if this is not the first block, a later one
                        -- and if there are more following this
                                        
                        -- start fetching those blocks
                        sig_INR_RDY     <= '1';
                        sig_NOM_UPD     <= '1';
                        sig_HoS_INIT    <= '1';
                        
                        -- the condition says that 
                        -- since there are more blocks; this should be a full block
                        -- therefore initialize Poly to brocess a full blocks
                        sig_POL_INIT    <= '1';
                        sig_POL_LEN     <= "1111";
                        sig_CIP_SEL     <= "00";
                        reg_pol_lim     <= "11";
                        sig_POL_LAST    <= '0';
                        
                        -- Start DMA to send this full block again.              
                        sig_OUT_INIT    <= '1';
                        sig_OUT_InSTART <= "0000";
                        sig_OUT_InSTOP  <= "1111";
                        sig_OUT_LAST    <= '0';
                                                                
                    else
                    
                        state <= s_middle;
                        
                        -- if there is a partial block (not a complete 64 byte block)
                        
                        -- that means there there should be nothing more to be fetched.
                        sig_INR_RDY     <= '0'; --- 1
                        sig_NOM_UPD     <= '0'; --- 1
                        sig_HoS_INIT    <= '0'; --- 1
                        
                        -- the condition says that 
                        -- this is a partial block, so Poly1305 should start from its 
                        -- beginning, process it till its end
                        sig_POL_INIT    <= '1';
                        sig_POL_LEN     <= "1111";
                        sig_CIP_SEL     <= "00";
                        reg_pol_lim     <= cnt_bytes(5 downto 4);
                        
                        if cnt_bytes(5 downto 4) = "00" then
                            sig_POL_LAST    <= '1';                            
                            sig_POL_LEN     <= cnt_bytes(3 downto 0);  
                        else 
                            sig_POL_LAST    <= '0';
                        end if;
                        
                         -- Start DMA to send this full block again.              
                        sig_OUT_INIT    <= '1';
                        sig_OUT_InSTART <= "0000";
                        sig_OUT_InSTOP  <= cnt_bytes(5 downto 2);  
                        sig_OUT_LAST    <= '0';
                        
                    end if;                    
                
                when s_middle =>
                
                    sig_INR_RDY     <= '0';
                    sig_POL_INIT    <= '0';
                    sig_OUT_INIT    <= '0';                                        
                    sig_HoS_INIT    <= '0';
                    sig_NOM_UPD     <= '0';
                    
                    state <= s_block2;
                    
                when s_block2 =>
                    
                    sig_OUT_INIT    <= '0';                                        
                    sig_HoS_INIT    <= '0';                    
                    
                    sig_INR_RDY     <= '0';
                                
                    sig_NOM_RST     <= sig_NOM_RST;
                    sig_NOM_SEL     <= sig_NOM_SEL;
                    sig_NOM_UPD     <= '0';
                    
                    sig_HoS_SEL     <= sig_HoS_SEL;
                    
                    sig_KEY_SEL     <= sig_KEY_SEL;
                    
                    sig_INR_L2LOAD  <= sig_INR_L2LOAD;
                    
                    sig_POL_RSLOAD  <= sig_POL_RSLOAD;
                                                            
                    sig_REG_EN      <= '0';
                    sig_DCR_EN      <= '0';
                    
                    sig_OUT_LAST    <= sig_OUT_LAST;                      
                    
                    
                    -- Now I start receiving done signals.
                    -- And if I will wait them.
                    -- There are 4 done signals:
                    -- --> INR_DONE for input register fetching one more block of inputs
                    -- --> HoS_DONE for hSalsa block creating one more block of cipher stream
                    -- --> POL_DONE for Poly1305 creating MAC of one quarter block
                    --     So it should be considered together with sig_CIP_SEL signal and reg_pol_lim
                    --     If there are equal that means it was the last work of it.
                    -- --> OUT_DONE for Output block to send one block cipher or plain text to RAM
                    --
                    -- If there was no more (full) blocks or (partial blocks) bytes, 
                    -- to be encryted or decrypted, the operation I am waiting here should be 
                    -- sending last outputs. Be careful to that.  
                    
                    if cnt_bytes = "1111111111" then
                    
                        -- All data is processed, so wait only for POL_DONE and OUT_DONE
                                            
                        if OUT_DONE = '1' then
                            state <= s_block2;                                                         
                        else
                            -- wait in this state 
                            state <= s_block2;
                        end if;
                    
                    else
                    
                        if HoS_DONE = '1' and INR_DONE = '1' and (sig_CIP_SEL = reg_pol_lim and POL_DONE = '1') and OUT_DONE = '1' then
                        
                            if reg_firstblock = '1' then                 
                                
                                reg_firstblock  <= '0';     
                                
                                if cnt_bytes(9 downto 5) /= "00000" then
                                
                                    cnt_bytes   <= cnt_bytes - "0100000";
                                else
                                    cnt_bytes(9 downto 0) <= "1111111111";
                                end if;
                                                
                            else
                            
                                reg_firstblock  <= reg_firstblock;
                                                           
                        
                                if cnt_bytes(9 downto 6) /= "0000" then
                                                            
                                    -- Last processed block was one of full blocks.
                                    -- Decrement remaining bytes by one block
                                    
                                    cnt_bytes   <= cnt_bytes - "1000000";
                                    
                                --elsif cnt_bytes(9 downto 6) = "000000" and cnt_bytes(5 downto 0) /= "000000" then
                                --elsif cnt_bytes(5 downto 0) /= "000000" then
                                else
                                    -- All the full blocks are processed, 
                                    -- Last processed was a partial block.
                                    -- Now there is no more bytes to process.
                                    
                                    cnt_bytes(9 downto 0) <= "1111111111";
                                    
    --                            else
    --                                cnt_bytes   <= cnt_bytes; 
    --                                reg_firstblock  <= reg_firstblock;
                                end if;
                            end if; 
                            state <= s_block1;
                            
                        else
                            
                            if sig_CIP_SEL /= reg_pol_lim and POL_DONE = '1' then                        
                                sig_CIP_SEL     <= sig_CIP_SEL + '1';
                                sig_POL_INIT    <= '1';
                                
                                if reg_firstblock = '1' and cnt_bytes(9 downto 5) = "00000" and sig_CIP_SEL = (reg_pol_lim - '1') then
                                    sig_POL_LAST    <= '1';                                    
                                    sig_POL_LEN     <= cnt_bytes(3 downto 0);    
                                    
                                elsif reg_firstblock = '0' and cnt_bytes(9 downto 6) = "0000"  and sig_CIP_SEL = (reg_pol_lim - '1') then
                                    sig_POL_LAST    <= '1';
                                    sig_POL_LEN     <= cnt_bytes(3 downto 0);                              
                                else 
                                    sig_POL_LAST    <= '0';
                                end if;
                                
                                state <= s_middle;
                            else
                                sig_POL_INIT    <= '0';
                                
                                state <= s_block2;
                            end if; 
                        
                            cnt_bytes   <= cnt_bytes; 
                            reg_firstblock  <= reg_firstblock;
                            
                            --state <= s_block2;
                        end if;
                    
                    end if;                    
                    
                 when others =>
                    null;                        
                     
            end case;
        end if;
    end if;
    end process;
   
end Behavioral;