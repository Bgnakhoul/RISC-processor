library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 16 x 8-bit register file.
-- Asynchronous read, synchronous write.
-- debug_r2 exposes the content of R2.

entity reg_file16x8 is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        we       : in  std_logic;
        waddr    : in  std_logic_vector(3 downto 0);
        wdata    : in  std_logic_vector(7 downto 0);
        raddr_x  : in  std_logic_vector(3 downto 0);
        raddr_y  : in  std_logic_vector(3 downto 0);
        rx       : out std_logic_vector(7 downto 0);
        ry       : out std_logic_vector(7 downto 0);
	debug_r2 : out std_logic_vector(7 downto 0);
debug_r1 : out std_logic_vector(7 downto 0);
        debug_r3 : out std_logic_vector(7 downto 0)
    );
end entity reg_file16x8;

architecture rtl of reg_file16x8 is
    type reg_array_t is array (0 to 15) of std_logic_vector(7 downto 0);
    signal regs : reg_array_t := (others => (others => '0'));
begin
    -- synchronous write / reset
    process(clk, reset)
    begin
        if reset = '1' then
            regs <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if we = '1' then
                regs(to_integer(unsigned(waddr))) <= wdata;
            end if;
        end if;
    end process;

    -- asynchronous read
    rx <= regs(to_integer(unsigned(raddr_x)));
    ry <= regs(to_integer(unsigned(raddr_y)));
debug_r1 <= regs(1);
    debug_r2 <= regs(2);
debug_r3 <= regs(3);
end architecture rtl;

