library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Testbench for alu8
entity alu_tb is
end entity alu_tb;

architecture tb of alu_tb is

    -- DUT port signals
    signal a_tb   : std_logic_vector(7 downto 0) := (others => '0');
    signal b_tb   : std_logic_vector(7 downto 0) := (others => '0');
    signal sel_tb : std_logic_vector(3 downto 0) := (others => '0');
    signal y_tb   : std_logic_vector(7 downto 0);

begin

    ------------------------------------------------------------------------
    -- DUT instantiation
    ------------------------------------------------------------------------
    uut: entity work.alu
        port map (
            a   => a_tb,
            b   => b_tb,
            sel => sel_tb,
            y   => y_tb
        );

    ------------------------------------------------------------------------
    -- Stimulus process
    ------------------------------------------------------------------------
    stim_proc : process
    begin
        -- First test vector: a = 10, b = 3
        a_tb <= std_logic_vector(to_unsigned(10, 8));  -- 0x0A
        b_tb <= std_logic_vector(to_unsigned(3,  8));  -- 0x03

        -- Loop through all operations (sel = 0000 to 1111)
        for s in 0 to 15 loop
            sel_tb <= std_logic_vector(to_unsigned(s, 4));
            wait for 10 ns;
        end loop;

        -- Second test vector: a = 0xF0, b = 0x02
        a_tb <= x"F0";
        b_tb <= x"02";

        for s in 0 to 15 loop
            sel_tb <= std_logic_vector(to_unsigned(s, 4));
            wait for 10 ns;
        end loop;

        -- Optional: more test vectors can be added here

        wait;  -- stop simulation
    end process;

end architecture tb;

