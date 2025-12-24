library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 12-bit program counter with load and increment.

entity program_counter is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        load    : in  std_logic;
        addr_in : in  std_logic_vector(11 downto 0);
        pc_out  : out std_logic_vector(11 downto 0)
    );
end entity program_counter;

architecture rtl of program_counter is
    signal pc_reg : std_logic_vector(11 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            pc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                pc_reg <= addr_in;
            else
                pc_reg <= std_logic_vector(unsigned(pc_reg) + 1);
            end if;
        end if;
    end process;

    pc_out <= pc_reg;
end architecture rtl;

