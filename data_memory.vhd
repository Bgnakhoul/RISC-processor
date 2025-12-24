library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 256 x 8-bit data memory.
-- Asynchronous read, synchronous write.

entity data_memory is
    port (
        clk  : in  std_logic;
        addr : in  std_logic_vector(7 downto 0);
        din  : in  std_logic_vector(7 downto 0);
        we   : in  std_logic;
        dout : out std_logic_vector(7 downto 0)
    );
end entity data_memory;

architecture rtl of data_memory is
    type ram_t is array (0 to 255) of std_logic_vector(7 downto 0);
    signal ram : ram_t := (others => (others => '0'));
begin
    -- synchronous write
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram(to_integer(unsigned(addr))) <= din;
            end if;
        end if;
    end process;

    -- asynchronous read
    dout <= ram(to_integer(unsigned(addr)));
end architecture rtl;

