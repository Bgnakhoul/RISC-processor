library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_data_memory is
end entity;

architecture behav of tb_data_memory is

    signal clk  : std_logic := '0';
    signal addr : std_logic_vector(7 downto 0) := (others => '0');
    signal din  : std_logic_vector(7 downto 0) := (others => '0');
    signal we   : std_logic := '0';
    signal dout : std_logic_vector(7 downto 0);

begin

    -- DUT
    uut : entity work.data_memory
        port map (
            clk  => clk,
            addr => addr,
            din  => din,
            we   => we,
            dout => dout
        );

    -- clock (20 ns period)
    clk <= not clk after 10 ns;

    stim_proc : process
    begin
        ----------------------------------------------------------
        -- 1) Read initial contents at address 0
        ----------------------------------------------------------
        addr <= x"00";
        we   <= '0';
        wait for 25 ns;

        ----------------------------------------------------------
        -- 2) Write 0xAA to address 10 (0x0A)
        ----------------------------------------------------------
        addr <= x"0A";
        din  <= x"AA";
        we   <= '1';
        wait for 20 ns;  -- one clock edge performs the write

        ----------------------------------------------------------
        -- 3) Disable write
        ----------------------------------------------------------
        we <= '0';
        wait for 20 ns;

        ----------------------------------------------------------
        -- 4) Read back from address 10
        ----------------------------------------------------------
        addr <= x"0A";
        wait for 20 ns;   -- asynchronous read updates dout immediately

        ----------------------------------------------------------
        -- 5) Write 0x55 to address 200 (0xC8)
        ----------------------------------------------------------
        addr <= x"C8";
        din  <= x"55";
        we   <= '1';
        wait for 20 ns;

        ----------------------------------------------------------
        -- 6) Disable write and read back address 200
        ----------------------------------------------------------
        we <= '0';
    wait for 20 ns;

        addr <= x"C8";
        wait for 20 ns;

        wait;
    end process;

end architecture;

