library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_program_memory is
end entity;

architecture behav of tb_program_memory is

    signal addr  : std_logic_vector(11 downto 0) := (others => '0');
    signal instr : std_logic_vector(15 downto 0);

begin

    uut : entity work.program_memory
        port map (
            addr  => addr,
            instr => instr
        );

    stim_proc : process
    begin
        addr <= x"001";

        wait for 20 ns;
        addr <= x"0C8";

        wait;
    end process;

end architecture behav;

