library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Top-level RISC processor

entity risc_processor is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        pc_out    : out std_logic_vector(11 downto 0);
        instr_out : out std_logic_vector(15 downto 0);
	alu_res : out std_logic_vector(7 downto 0);
        debug_r2  : out std_logic_vector(7 downto 0);
debug_r1  : out std_logic_vector(7 downto 0);
debug_r3  : out std_logic_vector(7 downto 0)
    );
end entity risc_processor;

architecture rtl of risc_processor is

    
    -- Internal signals

    signal pc        : std_logic_vector(11 downto 0);
    signal instr     : std_logic_vector(15 downto 0);

    -- decoded fields
    signal opcode    : std_logic_vector(3 downto 0);
    signal sel       : std_logic_vector(3 downto 0);
    signal dest      : std_logic_vector(3 downto 0);
    signal src       : std_logic_vector(3 downto 0);
    signal imm8      : std_logic_vector(7 downto 0);

    -- Register file signals
    signal reg_x      : std_logic_vector(7 downto 0);  -- R[x]
    signal reg_y      : std_logic_vector(7 downto 0);  -- R[y]
    signal reg_we     : std_logic;
    signal reg_waddr  : std_logic_vector(3 downto 0);
    signal reg_wdata  : std_logic_vector(7 downto 0);
    signal raddr_x_s  : std_logic_vector(3 downto 0);
    signal raddr_y_s  : std_logic_vector(3 downto 0);

    -- ALU signals
    signal alu_a      : std_logic_vector(7 downto 0);
    signal alu_b      : std_logic_vector(7 downto 0);
    signal alu_sel    : std_logic_vector(3 downto 0);
    signal alu_result : std_logic_vector(7 downto 0);

    -- Data memory
    signal mem_addr   : std_logic_vector(7 downto 0);
    signal mem_din    : std_logic_vector(7 downto 0);
    signal mem_dout   : std_logic_vector(7 downto 0);
    signal mem_we     : std_logic;

    -- Program counter control
    signal pc_next    : std_logic_vector(11 downto 0);
    signal pc_target  : std_logic_vector(11 downto 0);
    signal pc_load    : std_logic;

begin

    opcode <= instr(15 downto 12);
    sel    <= instr(11 downto 8);
    dest   <= instr(7 downto 4);
    src    <= instr(3 downto 0);
    imm8   <= instr(7 downto 0);

    -- branch target = PC + signed offset (8-bit for this implementation)
    pc_target <= std_logic_vector(signed(pc) + signed(imm8));

    pc_out    <= pc;
    instr_out <= instr;
    alu_res <= alu_result;


    reg_addr_proc : process(instr)
    begin
        raddr_x_s <= instr(7 downto 4);  -- R[x]
        raddr_y_s <= instr(3 downto 0);  -- R[y]

        case instr(15 downto 12) is
            when "0010" =>            -- ADI R[x], #data (IM)
                raddr_x_s <= instr(11 downto 8);  -- R[x]
                raddr_y_s <= (others => '0');

            when "1000" |            -- LD R[x], #address (EM direct)
                 "1001" |            -- STR #address, R[x] (EM direct)
                 "1010" |            -- JNZ R[x], #offset (BR)
                 "1011" =>           -- JZ R[x], #offset (BR)
                raddr_x_s <= instr(11 downto 8);  -- R[x]
                raddr_y_s <= (others => '0');

            when others =>
                null;
        end case;
    end process;


    pc_inst : entity work.program_counter
        port map (
            clk     => clk,
            reset   => reset,
            load    => pc_load,
            addr_in => pc_next,
            pc_out  => pc
        );


    prog_mem_inst : entity work.program_memory
        port map (
            addr  => pc,
            instr => instr
        );


    reg_file_inst : entity work.reg_file16x8
        port map (
            clk      => clk,
            reset    => reset,
            we       => reg_we,
            waddr    => reg_waddr,
            wdata    => reg_wdata,
            raddr_x  => raddr_x_s,
            raddr_y  => raddr_y_s,
            rx       => reg_x,
            ry       => reg_y,
            debug_r2 => debug_r2,
debug_r1 => debug_r1,
debug_r3 => debug_r3
        );


    data_mem_inst : entity work.data_memory
        port map (
            clk  => clk,
            addr => mem_addr,
            din  => mem_din,
            we   => mem_we,
            dout => mem_dout
        );


    alu_inst : entity work.alu
        port map (
            a   => alu_a,
            b   => alu_b,
            sel => alu_sel,
            y   => alu_result
        );


    control_proc : process(all)
        variable x_lt_y : boolean;
    begin
        x_lt_y := unsigned(reg_x) < unsigned(reg_y);

        -- Defaults
        pc_load   <= '0';
        pc_next   <= (others => '0');  -- ignored when pc_load = '0'

        reg_we    <= '0';
        reg_waddr <= dest;
        reg_wdata <= alu_result;

        mem_we    <= '0';
        mem_addr  <= imm8;
        mem_din   <= reg_y;

        alu_a     <= reg_x;
        alu_b     <= reg_y;
        alu_sel   <= "0000";        


        case opcode is

           
            -- 0000 : NOP
           
            when "0000" =>
                null;

           
            -- 0001 : Arithmetic R-type group
            --   ADD  R[x],R[y] : Sel = 1001
            --   SUB  R[x],R[y] : Sel = 0110
            --   DEC  R[x]      : Sel = 1111
          
            when "0001" =>
                reg_we    <= '1';
                reg_waddr <= dest;
                alu_a     <= reg_x;
                alu_b     <= reg_y;
                case sel is
                    when "1001" =>            -- ADD R[x], R[y]
                        alu_sel <= "0001";    -- ADD
                    when "0110" =>            -- SUB R[x], R[y]
                        alu_sel <= "0010";    -- SUB
                    when "1111" =>            -- DEC R[x]
                        alu_sel <= "0100";    -- DEC
                    when others =>
                        reg_we <= '0';
                end case;

         
            -- 0010 : ADI R[x], #data (IM)
        
            when "0010" =>
                reg_we    <= '1';
                reg_waddr <= instr(11 downto 8); -- R[x]
                alu_a     <= reg_x;              -- value of R[x]
                alu_b     <= imm8;
                alu_sel   <= "0001";           -- ADD

         
            -- 0011 : INC R[x]  (R-type, unary)
     
            when "0011" =>
                reg_we    <= '1';
                reg_waddr <= dest;
                alu_a     <= reg_x;
                alu_sel   <= "0011";           -- INC


            -- 0100 : Shift group (R-type)
            --   SHL R[x], R[y] : Sel = 0000
            --   SHR R[x], R[y] : Sel = 0011
 
            when "0100" =>
                reg_we    <= '1';
                reg_waddr <= dest;
                alu_a     <= reg_x;
                alu_b     <= reg_y;
                if sel = "0000" then           -- SHL
                    alu_sel <= "0101";         -- SHL
                elsif sel = "0001" then        -- SHR
                    alu_sel <= "0110";         -- SHR
                else
                    reg_we <= '0';
                end if;

           
            -- 0101 : Logical group (R-type)
            --   NOT  : Sel=0000
            --   NOR  : Sel=0001
            --   CLR  : Sel=0011
            --   NAND : Sel=0100
            --   XOR  : Sel=0101
            --   AND  : Sel=1011
            --   OR   : Sel=1010
            --   SET  : Sel=1100
           
            when "0101" =>
                reg_we    <= '1';
                reg_waddr <= dest;
                alu_a     <= reg_x;
                alu_b     <= reg_y;
                case sel is
                    when "0000" =>             -- NOT R[x]
                        alu_sel <= "0111";     -- NOT
                    when "0001" =>             -- NOR R[x], R[y]
                        alu_sel <= "1100";     -- NOR
                    when "0011" =>             -- CLR R[x]
                        alu_sel <= "1101";     -- CLR
                    when "0100" =>             -- NAND R[x], R[y]
                        alu_sel <= "1011";     -- NAND
                    when "0110" =>             -- XOR R[x], R[y]
                        alu_sel <= "1010";     -- XOR
                    when "1011" =>             -- AND R[x], R[y]
                        alu_sel <= "1000";     -- AND
                    when "1010" =>             -- OR  R[x], R[y]
                        alu_sel <= "1001";     -- OR
                    when "1100" =>             -- SET R[x]
                        alu_sel <= "1110";     -- SET
                    when others =>
                        reg_we <= '0';
                end case;

           
            -- 0110 : LOAD INDIRECT  (EM)
            --   LD R[x], R[y]   -> R[x] <= MEM[R[y]]
            
            when "0110" =>
                reg_we    <= '1';
                reg_waddr <= dest;       -- R[x]
                mem_addr  <= reg_y;      -- address = R[y]
                reg_wdata <= mem_dout;

            
            -- 0111 : STORE INDIRECT (EM)
            --   ST R[y], R[x]   -> MEM[R[y]] <= R[x]
            
            when "0111" =>
                mem_we   <= '1';
                mem_addr <= reg_y;       -- address = R[y]
                mem_din  <= reg_x;       -- data    = R[x]

           
            -- 1000 : LOAD REGISTER (EM)
            --   LD R[x], #address   -> R[x] <= MEM[address]
            
            when "1000" =>
                reg_we    <= '1';
                reg_waddr <= instr(11 downto 8);  -- R[x]
                mem_addr  <= imm8;
                reg_wdata <= mem_dout;

            
            -- 1001 : STORE REGISTER (EM)
            --   STR #address, R[x]  -> MEM[address] <= R[x]
            
            when "1001" =>
                mem_we   <= '1';
                mem_addr <= imm8;
                mem_din  <= reg_x;

            
            -- 1010 : BRANCH IF NOT ZERO (BR)
            --   JNZ R[x], #offset
            
            when "1010" =>
                if reg_x /= x"00" then
                    pc_load <= '1';
                    pc_next <= pc_target;
                end if;

            
            -- 1011 : BRANCH IF ZERO (BR)
            --   JZ R[x], #offset
           
            when "1011" =>
                if reg_x = x"00" then
                    pc_load <= '1';
                    pc_next <= pc_target;
                end if;

            
            -- 1101 : SET / RESET IF LESS THAN (R-type)
            --   SLT R[x], R[y] : Sel=1111, R[x]=FF if R[x]<R[y] else 00
            --   RLT R[x], R[y] : Sel=0000, R[x]=00 if R[x]<R[y] else FF
            
            when "1101" =>
                reg_we    <= '1';
                reg_waddr <= dest;
                if sel = "1111" then           -- SLT
                    if x_lt_y then
                        reg_wdata <= (others => '1');   -- FF
                    else
                        reg_wdata <= (others => '0');   -- 00
                    end if;
                elsif sel = "0000" then         -- RLT
                    if x_lt_y then
                        reg_wdata <= (others => '0');   -- 00
                    else
                        reg_wdata <= (others => '1');   -- FF
                    end if;
                else
                    reg_we <= '0';
                end if;

           
            -- 1110 : MOVE (R-type)
            --   MOV R[x], R[y]  -> R[x] <= R[y]
            
            when "1110" =>
                reg_we    <= '1';
                reg_waddr <= dest;
                reg_wdata <= reg_y;

          
            -- 1111 : JUMP (BR)
            --   JMP #address     -> PC <= address
            
            when "1111" =>
                pc_load <= '1';
                pc_next <= instr(11 downto 0);

            when others =>
                null;
        end case;
    end process;

end architecture rtl;

