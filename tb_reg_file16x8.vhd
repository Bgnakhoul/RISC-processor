library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_reg_file16x8 is
end entity;

architecture behav of tb_reg_file16x8 is

    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal we       : std_logic := '0';
    signal waddr    : std_logic_vector(3 downto 0) := (others => '0');
    signal wdata    : std_logic_vector(7 downto 0) := (others => '0');
    signal raddr_x  : std_logic_vector(3 downto 0) := (others => '0');
    signal raddr_y  : std_logic_vector(3 downto 0) := (others => '0');
    signal rx       : std_logic_vector(7 downto 0);
    signal ry       : std_logic_vector(7 downto 0);
    signal debug_r2 : std_logic_vector(7 downto 0);
signal debug_r1 : std_logic_vector(7 downto 0);
signal debug_r3 : std_logic_vector(7 downto 0);

begin

    -- DUT
    uut : entity work.reg_file16x8
        port map (
            clk      => clk,
            reset    => reset,
            we       => we,
            waddr    => waddr,
            wdata    => wdata,
            raddr_x  => raddr_x,
            raddr_y  => raddr_y,
            rx       => rx,
            ry       => ry,
            debug_r2 => debug_r2,
debug_r3 => debug_r3,
debug_r1 => debug_r1
        );

    -- clock: 20 ns period
    clk <= not clk after 10 ns;

    stim_proc : process
    begin
        -- start: clk edges, all signals default (no reset, no write)
        we      <= '0';
        reset   <= '0';
        waddr   <= (others => '0');
        wdata   <= (others => '0');
        raddr_x <= (others => '0');
        raddr_y <= (others => '0');
        wait for 40 ns;  -- a couple of clock cycles

        -- assert reset
       -- reset <= '1';
        --we    <= '0';
        --wait for 40 ns;

        -- deassert reset, still no write
       -- reset <= '0';
       -- we    <= '0';
        -- wait for 30 ns;

        -- write 0xFF into register 2 on this clock cycle
        -- same cycle: read port X points to reg 2
        we      <= '1';
        waddr   <= "0010";     -- reg2
        wdata   <= x"FF";
        raddr_x <= "0010";     -- read reg2 on rx
        raddr_y <= "0000";
        wait for 20 ns;        -- one clock cycle

        -- next clock cycle: stop writing, read reg2 on ry
        we      <= '0';
        raddr_y <= "0010";     -- ry = reg2 (should see 0xFF)
        wait for 20 ns;

        -- next clock cycle: change ry to read reg4
        raddr_y <= "0100";     -- ry = reg4
        wait for 20 ns;

        wait;
    end process;

end architecture behav;

