library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Testbench for the RISC processor.
-- Runs the built-in program that sums 1..5 into R2 and repeat infinitely

entity tb_risc_processor is
end entity tb_risc_processor;

architecture behav of tb_risc_processor is

    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal pc_out    : std_logic_vector(11 downto 0);
    signal instr_out : std_logic_vector(15 downto 0);
    signal alu_res : std_logic_vector(7 downto 0);
    signal debug_r2  : std_logic_vector(7 downto 0);
signal debug_r1  : std_logic_vector(7 downto 0);
signal debug_r3  : std_logic_vector(7 downto 0);

begin

    -- clock: 20 ns period
    clk <= not clk after 10 ns;

    -- reset pulse
    process
    begin
        reset <= '1';
        wait for 40 ns;
        reset <= '0';
        wait;
    end process;

    uut : entity work.risc_processor
        port map (
            clk       => clk,
            reset     => reset,
            pc_out    => pc_out,
            instr_out => instr_out,
		alu_res => alu_res,
            debug_r2  => debug_r2,
debug_r1  => debug_r1,
debug_r3  => debug_r3
        );

    stim_proc : process
    begin
        wait for 2000 ns;

        report "Simulation finished. Final value of R2 (accumulator) = " &
               integer'image(to_integer(unsigned(debug_r2)))
            severity note;

        assert debug_r2 = x"0F"
            report "ERROR: Expected R2 = 0x0F (15 decimal) from the test program."
            severity error;

        wait;
    end process;

end architecture behav;

