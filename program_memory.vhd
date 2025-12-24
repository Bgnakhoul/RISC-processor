library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 256 x 16-bit program ROM.
-- Contains a simple program that sums 1..5 into R2.

entity program_memory is
    port (
        addr  : in  std_logic_vector(11 downto 0);
        instr : out std_logic_vector(15 downto 0)
    );
end entity program_memory;

architecture rtl of program_memory is
    type rom_t is array (0 to 4096) of std_logic_vector(15 downto 0);
    constant rom : rom_t := (
        -- 0: ADI R1,#5      ; counter = 5
        0 => x"2105",
        -- 1: ADI R2,#0      ; accumulator = 0
        1 => x"2200",
        -- 2: ADD R2,R1      ; R2 = R2 + R1
        --    opcode=0001 (R-type arithmetic group)
        --    sel   =1001 (ADD)
        --    dest  =0010 (R2)
        --    src   =0001 (R1)
        2 => x"1921",
        -- 3: ADI R1,#-1     ; R1 = R1 - 1  (0xFF = -1)
        3 => x"21FF",
        -- 4: JNZ R1,-2      ; if R1 != 0, go back to instr 2
        4 => x"A1FE",
        -- 5: NOP
        5 => x"0000",
	6 => x"F000", --JUMP TO 0000 infinite loop
        others => (others => '0')
    );
begin
    instr <= rom(to_integer(unsigned(addr)));
end architecture rtl;

