library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_program_counter is
end entity;

architecture behav of tb_program_counter is

    signal clk     : std_logic := '0';
    signal reset   : std_logic := '0';
    signal load    : std_logic := '0';
    signal addr_in : std_logic_vector(11 downto 0) := (others => '0');
    signal pc_out  : std_logic_vector(11 downto 0);

begin

    ------------------------------------------------------------------
    -- DUT: Instantiate the program counter
    ------------------------------------------------------------------
    uut : entity work.program_counter
        port map (
            clk     => clk,
            reset   => reset,
            load    => load,
            addr_in => addr_in,
            pc_out  => pc_out
        );

    ------------------------------------------------------------------
    -- Simple clock generator (20 ns period)
    ------------------------------------------------------------------
    clk <= not clk after 10 ns;

    ------------------------------------------------------------------
    -- Test sequence
    ------------------------------------------------------------------
    stim_proc : process
    begin
        ------------------------------------------------------------------
        -- 1. RESET = 1, NO CLOCK (time is not advancing in PC process)
        ------------------------------------------------------------------
        reset <= '1';
        load  <= '0';
        addr_in <= (others => '0');
        wait for 5 ns;   -- no rising edge yet
        

        ------------------------------------------------------------------
        -- 2. RESET = 1 WITH CLOCK EDGES ? pc_out stays zero
        ------------------------------------------------------------------
        wait for 40 ns;  -- allow several clock cycles
        

        ------------------------------------------------------------------
        -- 3. RESET = 0, NO CLOCK EDGE ? pc_out must remain unchanged
        ------------------------------------------------------------------
        reset <= '0';
        wait for 5 ns;  -- still before a rising edge
        

        ------------------------------------------------------------------
        -- 4. RESET = 0 WITH CLOCK ? PC INCREMENTS
        ------------------------------------------------------------------
        wait for 40 ns;  -- clock edges happen
        

        ------------------------------------------------------------------
        -- 5. ASSERT LOAD = 1, LOAD ADDRESS x"55"
        ------------------------------------------------------------------
        load <= '1';
        addr_in <= x"055";
        wait for 20 ns; -- one clock edge triggers load
        
        wait;
    end process;

end architecture behav;
