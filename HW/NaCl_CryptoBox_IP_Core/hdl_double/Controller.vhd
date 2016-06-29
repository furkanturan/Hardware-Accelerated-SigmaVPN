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
        INR_RSTN    : out std_logic;      
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
        MSG1_EN     : out std_logic;
        
        DCR_EN      : out std_logic;
        DCR_SEL     : out std_logic;
        
        CIP_SEL     : out std_logic;
        
        POL_INIT     : out std_logic;
        POL_RSTN     : out std_logic;
        POL_RSLOAD   : out std_logic;
        POL_FINAL     : out std_logic;
        POL_LEN_1    : out std_logic_vector(3 downto 0);
        POL_LEN_2    : out std_logic_vector(3 downto 0);
        POL_DOUBLY   : out std_logic_vector(1 downto 0);
        POL_SEL      : out std_logic;
        POL_DONE     : in  std_logic;
        
        OUT_SEL     : out std_logic;        
        OUT_INIT    : out std_logic;
        OUT_InSTART : out std_logic_vector(4 downto 0);
        OUT_InSTOP  : out std_logic_vector(4 downto 0);
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
    signal sig_INR_RSTN    : std_logic := '1';
        
    signal sig_NOM_SEL     : std_logic := '0';
    signal sig_NOM_RST     : std_logic := '0';
    signal sig_NOM_UPD     : std_logic := '0';
        
    signal sig_KEY_SEL     : std_logic := '0';
        
    signal sig_HoS_INIT    : std_logic := '0';
    signal sig_HoS_SEL     : std_logic := '0';
        
    signal sig_REG_EN      : std_logic := '0'; 
    signal sig_MSG1_EN     : std_logic := '0'; 
    signal sig_MSG1        : std_logic := '0'; 
            
    signal sig_DCR_EN      : std_logic := '0';
    signal sig_DCR_SEL     : std_logic := '0'; 
        
        
    signal sig_POL_INIT    : std_logic := '0';
    signal sig_POL_RSTN    : std_logic := '0';
    signal sig_POL_RSLOAD  : std_logic := '0';
    signal sig_POL_FINAL    : std_logic := '0';
    signal sig_POL_LEN_1   : std_logic_vector(3 downto 0) := (others => '1');
    signal sig_POL_LEN_2   : std_logic_vector(3 downto 0) := (others => '1');
    signal sig_POL_DOUBLY  : std_logic_vector(1 downto 0) := (others => '1');
    signal sig_POL_SEL     : std_logic := '0';
    
    signal sig_OUT_SEL     : std_logic := '0'; 
    signal sig_OUT_INIT    : std_logic := '0';
    signal sig_OUT_InSTART : std_logic_vector(4 downto 0) := (others => '0');
    signal sig_OUT_InSTOP  : std_logic_vector(4 downto 0) := (others => '0');
    signal sig_OUT_LAST    : std_logic := '0';
    
    signal sig_DMA_INIT    : std_logic := '0';
    signal sig_DMA_CONT    : std_logic := '0';
    signal sig_DMA_TLEN    : std_logic_vector(15 downto 0) := (others => '0');

    type state_type is (s_reset, s_idle, s_read_init, s_middle1, s_2ndkey, s_middle2, s_middle3, s_firstsalsa, s_block1, s_middle, s_block2);
    signal state   : state_type;
    
    signal cnt_bytes        : std_logic_vector(10 downto 0) := (others => '0');

    signal reg_firstblock   : std_logic := '0';
    signal reg_ply_stop     : std_logic_vector(1 downto 0) := (others => '0');
    signal reg_ply_start    : std_logic_vector(1 downto 0) := (others => '0');
    signal reg_ply_r2       : std_logic := '0';
    signal reg_ply_last     : std_logic := '0';
    signal reg_ply_done    : std_logic := '0';
begin

    INR_L2LOAD  <= sig_INR_L2LOAD  ;       
    INR_RDY     <= sig_INR_RDY     ;    
    INR_RSTN    <= sig_INR_RSTN    ;
        
    NOM_SEL     <= sig_NOM_SEL     ;
    NOM_RST     <= sig_NOM_RST     ;
    NOM_UPD     <= sig_NOM_UPD     ;
        
    KEY_SEL     <= sig_KEY_SEL     ;
        
    HoS_INIT    <= sig_HoS_INIT    ;
    HoS_SEL     <= sig_HoS_SEL     ;
        
    REG_EN      <= sig_REG_EN      ;
    MSG1_EN     <= sig_MSG1_EN     ; 
    DCR_EN      <= sig_DCR_EN      ;
    DCR_SEL     <= sig_DCR_SEL     ; 
        
    CIP_SEL     <= reg_ply_start(0) ;
        
    POL_INIT    <= sig_POL_INIT    ;
    POL_RSTN    <= sig_POL_RSTN    ;
    POL_RSLOAD  <= sig_POL_RSLOAD  ;
    POL_FINAL    <= sig_POL_FINAL    ;
    POL_LEN_1   <= sig_POL_LEN_1   ;
    POL_LEN_2   <= sig_POL_LEN_2   ;
    POL_DOUBLY  <= sig_POL_DOUBLY  ;
    POL_SEL     <= sig_POL_SEL     ;
        
    sig_POL_SEL <= reg_ply_start(1);
    
    OUT_SEL     <= sig_OUT_SEL     ;
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
            state <= s_reset;
            reg_firstblock <= '0';
        else
              
            case state is
                
                when s_reset =>
                    
                    state <= s_idle;    
                    
                    sig_INR_RSTN    <= '0';
                    sig_NOM_RST     <= '1'; 
                    sig_POL_RSTN    <= '0';                    
                                
                when s_idle =>
                
                    state <= s_read_init;                   
                    
                    
                    sig_INR_RDY     <= '1';
                    sig_INR_RSTN    <= '1';
                    
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
                    
                    sig_POL_RSTN    <= '1';
                    sig_POL_FINAL   <= '0';
                    sig_POL_LEN_1   <= "1111";
                    
                    sig_OUT_SEL     <= '0';
                    
                    sig_OUT_LAST    <= '0';  
                    
                    sig_DMA_INIT    <= '0';
                    sig_DMA_CONT    <= '0';
                    sig_DMA_TLEN    <= (others => '0');
                    
                    cnt_bytes       <= (others => '0');
                    
                    reg_firstblock <= '0';                
                             
                 when s_read_init =>
                    
                    if INR_DONE = '0' then
                        state <= s_read_init;
                    else
                        state <= s_middle1;
                    end if;
                                        
                    sig_INR_RDY     <= '1';
                    
                    sig_MSG1        <= '0';
                    
                    sig_NOM_RST     <= sig_NOM_RST;
                    sig_NOM_SEL     <= sig_NOM_SEL;
                    sig_NOM_UPD     <= sig_NOM_UPD;
                    
                    sig_HoS_INIT    <= INR_DONE;
                    sig_HoS_SEL     <= sig_HoS_SEL;
                    
                    sig_KEY_SEL     <= sig_KEY_SEL;
                    
                    sig_INR_L2LOAD  <= sig_INR_L2LOAD;
                                        
                    sig_REG_EN      <= sig_REG_EN;
                    
                    sig_POL_FINAL    <= sig_POL_FINAL;
                    sig_POL_LEN_1   <= sig_POL_LEN_1;
                    
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
                    
                    sig_POL_RSTN    <= '0';

                 when s_2ndkey =>
                    
                    if HoS_DONE = '0' then
                        state <= s_2ndkey;
                    else
                        state <= s_middle2;                        
                    end if;
                    
                    sig_INR_RDY     <= sig_INR_RDY;
                                        
                    sig_NOM_RST     <= sig_NOM_RST;
                    sig_NOM_SEL     <= sig_NOM_SEL;
                    sig_NOM_UPD     <= sig_NOM_UPD;
                    
                    sig_HoS_INIT    <= '0';
                    sig_HoS_SEL     <= HoS_DONE;
                    
                    sig_KEY_SEL     <= HoS_DONE;
                    
                    sig_INR_L2LOAD  <= HoS_DONE;
                                        
                    sig_POL_FINAL    <= sig_POL_FINAL;
                    sig_POL_LEN_1   <= sig_POL_LEN_1;
                    
                    sig_OUT_LAST    <= sig_OUT_LAST;  
                    
                    sig_POL_RSTN    <= '1';
                    
                    if HoS_DONE = '1' then
                        sig_DMA_INIT    <= '1';
                        sig_DMA_CONT    <= '1';
                        
                        -- Set DMA Controller's transfer length                        
                        if INR_MLEN(3 downto 0) = "0000" then
                            sig_DMA_TLEN    <= INR_MLEN + "10000";
                        else
                            sig_DMA_TLEN    <= (INR_MLEN(15 downto 2) & "00") + "10100";
                        end if;
                    else
                        sig_DMA_INIT    <= '0';
                        sig_DMA_CONT    <= '0';
                        sig_DMA_TLEN    <= (others => '0');
                    end if;
                    
                    cnt_bytes       <= INR_MLEN(10 downto 0) - '1';
                                        
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
                    
                    if INR_DONE = '1' and sig_MSG1 = '0' then
                       sig_MSG1_EN <= '1';
                       sig_MSG1 <= '1';
                       if cnt_bytes > 31 then
                           sig_INR_RDY <= '1';
                       end if;
                    else
                       sig_MSG1_EN <= '0';
                       sig_INR_RDY <= '0';
                    end if;  
                    
                    
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
                    sig_POL_FINAL    <= sig_POL_FINAL;
                    sig_POL_LEN_1   <= sig_POL_LEN_1;
                    
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
                    
                    sig_POL_RSLOAD  <= sig_POL_RSLOAD;
                    
                    cnt_bytes       <= cnt_bytes; 
                    
                    reg_firstblock  <= reg_firstblock;
                    
                    sig_MSG1        <= '0';
                   
                    sig_POL_INIT    <= '1';
                                      
                    reg_ply_done    <= '0';  
                    
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
                        
                        
                        if cnt_bytes > 95 then
                         
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
                                                
                            reg_ply_start   <= "01";
                            reg_ply_stop    <= "11";
                            reg_ply_r2      <= '1';     
                            sig_POL_DOUBLY  <= "10"; 
                            sig_POL_LEN_1   <= "1111";
                            sig_POL_LEN_2   <= "1111";
                            sig_POL_FINAL    <= '0';
                            
                            -- Start DMA to send this full block
                            -- Again start from middle till the end
                            
                            sig_OUT_INIT    <= '1';
                            sig_OUT_InSTART <= "01000";
                            sig_OUT_InSTOP  <= "11111";
                           
                         else
                        --elsif cnt_bytes <= 96 then
                          
                            -- That means this may be a partial block, but maybe not
                            -- Either way there is no more blocks to be fetched.
                            
                            sig_INR_RDY     <= '0';
                            sig_NOM_UPD     <= '0';
                            sig_HoS_INIT    <= '0';
                            
                            -- Poly1305 will
                            -- Start from half of the full block (as always for the first block)
                            -- Stop at the last sub block
                            
                            sig_POL_INIT    <= '1';
                            
                            reg_ply_start   <= "01";
                            reg_ply_stop    <= cnt_bytes(6 downto 5) + '1';
                            reg_ply_r2      <= cnt_bytes(6) xor cnt_bytes(5);
                            
                            if cnt_bytes < 16 then
                                reg_ply_last <= '0';
                                sig_POL_LEN_1   <= cnt_bytes(3 downto 0);
                                sig_POL_LEN_2   <= "0000"; 
                                sig_POL_DOUBLY  <= "00"; 
                                sig_POL_FINAL    <= '0';                            
                            elsif cnt_bytes < 32 then 
                                reg_ply_last <= '0';
                                sig_POL_LEN_1   <= "1111";
                                sig_POL_LEN_2   <= cnt_bytes(3 downto 0);
                                sig_POL_DOUBLY  <= "01"; 
                                sig_POL_FINAL    <= '0';  
                            else
                                reg_ply_last <= '0';
                                sig_POL_LEN_1   <= "1111";
                                sig_POL_LEN_2   <= "1111";
                                sig_POL_DOUBLY  <= "10";
                                sig_POL_FINAL    <= '0';  
                            end if;                            
                                  
                            -- Start DMA to send this one (maybe partial or full)
                            -- Again start from the middle  (as always for the first block)
                            sig_OUT_INIT    <= '1';
                            sig_OUT_InSTART <= "01000";
                            sig_OUT_InSTOP  <= cnt_bytes(6 downto 2) + "1000";
                            sig_OUT_LAST    <= '0';
                                                        
                        end if;
                    
                    elsif cnt_bytes(10 downto 0) = "11111111111" then   
                    --elsif cnt_bytes == -1 then
                    
                        state <= s_middle;
                        
                        -- now there are no more bytes, but there is something to be sent with DMA
                        -- which is the final output of the Poly1305 block
                        
                        sig_INR_RDY     <= '0';
                        sig_NOM_UPD     <= '0';
                        sig_HoS_INIT    <= '0';
                        
                        -- don't ini poly also
                        sig_POL_INIT    <= '0';
                        reg_ply_last    <= '0';
                        reg_ply_start   <= reg_ply_start;
                        reg_ply_stop    <= reg_ply_stop;
                        sig_POL_DOUBLY  <= "00";
                        
                        -- send Poly's 128 bit output to with DMA
                        sig_OUT_INIT    <= '1';
                        sig_OUT_InSTART <= "00000";
                        sig_OUT_InSTOP  <= "00011";
                        sig_OUT_LAST    <= '1';
                        sig_OUT_SEL     <= '1';
                    
                    elsif cnt_bytes(10 downto 7) /= "0000" then
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
                        reg_ply_last    <= '0';
                        reg_ply_start   <= "00";
                        reg_ply_stop    <= "11";
                        sig_POL_LEN_1   <= "1111";
                        sig_POL_LEN_2   <= "1111";
                        sig_POL_DOUBLY  <= "10"; 
                        sig_POL_FINAL   <= '0';  
                        
                        -- Start DMA to send this full block again.              
                        sig_OUT_INIT    <= '1';
                        sig_OUT_InSTART <= "00000";
                        sig_OUT_InSTOP  <= "11111";
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
                        reg_ply_start   <= "00";
                        reg_ply_stop    <= cnt_bytes(6 downto 5);
                        
                        if cnt_bytes < 16 then 
                            reg_ply_last    <= '1';    
                            sig_POL_LEN_1   <= cnt_bytes(3 downto 0);
                            sig_POL_LEN_2   <= "0000";
                            sig_POL_DOUBLY  <= "00";
                            sig_POL_FINAL    <= '0';                          
                        elsif cnt_bytes < 32 then 
                            reg_ply_last    <= '1';  
                            sig_POL_LEN_1   <= "1111";
                            sig_POL_LEN_2   <= cnt_bytes(3 downto 0);
                            sig_POL_DOUBLY  <= "01"; 
                            sig_POL_FINAL    <= '0';  
                        else
                            reg_ply_last    <= '0';  
                            sig_POL_LEN_1   <= "1111";
                            sig_POL_LEN_2   <= "1111";
                            sig_POL_DOUBLY  <= "10"; 
                            sig_POL_FINAL    <= '0';  
                        end if; 
                        
                         -- Start DMA to send this full block again.              
                        sig_OUT_INIT    <= '1';
                        sig_OUT_InSTART <= "00000";
                        sig_OUT_InSTOP  <= cnt_bytes(6 downto 2);  
                        sig_OUT_LAST    <= '0';
                        
                    end if;                    
                
                when s_middle =>
                
                    sig_INR_RDY     <= '0';
                    sig_POL_INIT    <= '0';
                    sig_OUT_INIT    <= '0';                                        
                    sig_HoS_INIT    <= '0';
                    sig_NOM_UPD     <= '0';
                    sig_POL_RSLOAD  <= '0';
                    
                    sig_POL_FINAL   <= '0';
                    state <= s_block2;
                    
                when s_block2 =>
                    
                   sig_OUT_INIT    <= '0';                                        
                   sig_HoS_INIT    <= '0';                    
                               
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
                   
                   
                   if INR_DONE = '1' and sig_MSG1 = '0' then
                       sig_MSG1_EN <= '1';
                       sig_MSG1 <= '1';
                       if (reg_firstblock = '0' and cnt_bytes >= 192) or
                          (reg_firstblock = '1' and cnt_bytes >= 160) then
                           sig_INR_RDY <= '1';
                       end if;
                   else
                       sig_MSG1_EN <= '0';
                       sig_INR_RDY <= '0';
                   end if;
                   
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
                   
                   if cnt_bytes = "11111111111" then
                   
                       -- All data is processed, so wait only for POL_DONE and OUT_DONE
                                           
                       if OUT_DONE = '1' then
                           state <= s_reset;  
                           
                           sig_INR_RSTN <= '0';
                                                                                  
                       else
                           -- wait in this state 
                           state <= s_block2;
                       end if;
                   
                   else                   
                   
                       if HoS_DONE = '1' and INR_DONE = '1' and (reg_ply_done = '1' and POL_DONE = '1') and OUT_DONE = '1' then
                       
                           if reg_firstblock = '1' then
                               
                               reg_firstblock  <= '0';
                               
                               if cnt_bytes > 95 then
                                   cnt_bytes   <= cnt_bytes - "1100000";
                               else
                                   cnt_bytes(10 downto 0) <= "11111111111";
                               end if;
                               
                              state <= s_block1;
                              
                           else
                           
                                reg_firstblock  <= reg_firstblock;
                                
                                if cnt_bytes < 128 then
                                    state           <= s_block1;
                                                                         
                                    cnt_bytes(10 downto 0) <= "11111111111";
                                
                                else
                                    state           <= s_block1;
                                    
                                    cnt_bytes       <= cnt_bytes - "10000000";
                                end if;

                               
--                               if cnt_bytes(10 downto 7) /= "0000" then
--                                   -- Last processed block was one of full blocks.
--                                   -- Decrement remaining bytes by one block
                                   
--                                   cnt_bytes   <= cnt_bytes - "10000000";
--                               else
--                                   -- All the full blocks are processed, 
--                                   -- Last processed was a partial block.
--                                   -- Now there is no more bytes to process.
                                   
--                                   cnt_bytes(10 downto 0) <= "11111111111";
--                               end if;
                           end if;
                           
                           
                       else
                       
                           if reg_ply_start /= reg_ply_stop and POL_DONE = '1' then                        
                               
                               sig_POL_INIT    <= '1';
                               
                               if reg_firstblock = '1' and reg_ply_r2 = '1' then
           
                                    reg_ply_r2 <= '0';
                               
                               elsif (reg_ply_start = reg_ply_stop - 1 and reg_firstblock = '1' and cnt_bytes <  96  and reg_ply_last = '0') or
                                     (reg_ply_start = reg_ply_stop - 1 and reg_firstblock = '0' and cnt_bytes < 128  and reg_ply_last = '0') then
                               
                                    reg_ply_last <= '1';
                                                                        
                                    if cnt_bytes(4 downto 0) < 16 then 
                                        sig_POL_LEN_1   <= cnt_bytes(3 downto 0);
                                        sig_POL_LEN_2   <= "0000";
                                        sig_POL_DOUBLY  <= "00";
                                        sig_POL_FINAL    <= '0';                          
                                    else
                                    --elsif cnt_bytes(4 downto 0) < 32 then 
                                        sig_POL_LEN_1   <= "1111";
                                        sig_POL_LEN_2   <= cnt_bytes(3 downto 0);
                                        sig_POL_DOUBLY  <= "01"; 
                                        sig_POL_FINAL    <= '0';  
                                    end if;
                                                                        
                                    reg_ply_done <= '0';
                                    
                                    reg_ply_start   <= reg_ply_start + '1';
                                                              
                               else
                               
                                   reg_ply_start   <= reg_ply_start + '1';
                                   
                               end if;
                               
                               state <= s_middle;                                                
                                                     
                           elsif reg_ply_start = reg_ply_stop and POL_DONE = '1' and ((cnt_bytes > 127 and reg_firstblock = '0') or (cnt_bytes > 95 and reg_firstblock = '1')) then
                           
                                sig_POL_INIT    <= '0';                                
                                reg_ply_done <= '1';        
                           
                           elsif reg_ply_start = reg_ply_stop and POL_DONE = '1' and reg_ply_last = '1' then
                           
                                sig_POL_INIT    <= '0';
                                reg_ply_last <= '1';
                                                         
                                sig_POL_FINAL    <= '1';                          
                                                                
                                reg_ply_done <= '1';                        
                                        
                                state <= s_middle;     
                                                           
                               
                          elsif reg_ply_start = reg_ply_stop and POL_DONE = '1' and reg_firstblock = '1' then
                                                                                   
                                if cnt_bytes < 32 then
                                    sig_POL_INIT    <= '1';        
                                    reg_ply_done <= '0';
                                    reg_ply_last <= '1';
                                end if;
                                           
                                state <= s_middle;  
                           
                           else
                               sig_POL_INIT    <= '0';
                               
                               state <= s_block2;
                           end if; 
                       
                           cnt_bytes   <= cnt_bytes; 
                           
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