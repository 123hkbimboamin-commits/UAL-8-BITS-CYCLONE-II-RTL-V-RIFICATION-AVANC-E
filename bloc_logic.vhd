
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bloc_logic is
    Port (
        A         : in  STD_LOGIC_VECTOR(7 downto 0);
        B         : in  STD_LOGIC_VECTOR(7 downto 0);
        Sel_Op    : in  STD_LOGIC_VECTOR(1 downto 0);
        Y_logic : out STD_LOGIC_VECTOR(7 downto 0)
    );
end bloc_logic;

architecture Behavioral of bloc_logic is
begin

    process(A, B, Sel_Op)
    begin
        case Sel_Op is

            when "00" =>
                Y_logic <= A and B;

            when "01" =>
                Y_logic <= A or B;

            when "10" =>
                Y_logic <= not A;

            when others =>
                Y_logic <= (others => '0');

        end case;
    end process;

end Behavioral;
