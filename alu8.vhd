library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity alu is
    port (
        a   : in  std_logic_vector(7 downto 0);
        b   : in  std_logic_vector(7 downto 0);
        sel : in  std_logic_vector(3 downto 0);
        y   : out std_logic_vector(7 downto 0)
    );
end entity alu;

architecture rtl of alu is
begin
    process(a, b, sel)
        variable ai  : unsigned(7 downto 0);
        variable bi  : unsigned(7 downto 0);
        variable res : unsigned(7 downto 0);
    begin
        ai := unsigned(a);
        bi := unsigned(b);

        case sel is
            when "0000" =>  -- NOP 
                res := ai;

            when "0001" =>  -- ADD
                res := ai + bi;

            when "0010" =>  -- SUB
                res := ai - bi;

            when "0011" =>  -- INC
                res := ai + 1;

            when "0100" =>  -- DEC
                res := ai - 1;

            when "0101" =>  -- SHL logical 
                res := shift_left(ai, to_integer(bi(2 downto 0)));

            when "0110" =>  -- SHR logical 
                res := shift_right(ai, to_integer(bi(2 downto 0)));

            when "0111" =>  -- NOT
                res := not ai;

            when "1000" =>  -- AND
                res := ai and bi;

            when "1001" =>  -- OR
                res := ai or bi;

            when "1010" =>  -- XOR
                res := ai xor bi;

            when "1011" =>  -- NAND
                res := not (ai and bi);

            when "1100" =>  -- NOR
                res := not (ai or bi);

            when "1101" =>  -- CLR 
                res := (others => '0');

            when "1110" =>  -- SET 
                res := (others => '1');

            when others =>
                res := (others => '0');
        end case;

        y <= std_logic_vector(res);
    end process;
end architecture rtl;

