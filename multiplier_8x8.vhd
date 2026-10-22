library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier_8x8 is
    Port (
        A      : in  STD_LOGIC_VECTOR(7 downto 0);
        B      : in  STD_LOGIC_VECTOR(7 downto 0);
        Y_Mult : out STD_LOGIC_VECTOR(15 downto 0)
    );
end multiplier_8x8;

architecture Behavioral of multiplier_8x8 is
begin

    Y_Mult <= std_logic_vector(unsigned(A) * unsigned(B));

end Behavioral;
