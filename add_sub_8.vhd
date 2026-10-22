library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity add_sub_8 is
    Port (
        A        : in  STD_LOGIC_VECTOR(7 downto 0);
        B        : in  STD_LOGIC_VECTOR(7 downto 0);
        Sub      : in  STD_LOGIC;
        R_Arith  : out STD_LOGIC_VECTOR(7 downto 0);
        Cout     : out STD_LOGIC;
        Overflow : out STD_LOGIC
    );
end add_sub_8;

architecture Behavioral of add_sub_8 is
begin

    process(A, B, Sub)
        variable B_temp   : unsigned(7 downto 0);
        variable Sum_temp : unsigned(8 downto 0);
        variable R_temp   : STD_LOGIC_VECTOR(7 downto 0);
    begin

        if Sub = '0' then
            -- Addition A + B
            Sum_temp := ('0' & unsigned(A))
                      + ('0' & unsigned(B));
        else
            -- Soustraction A - B = A + NOT(B) + 1
            B_temp := unsigned(not B);

            Sum_temp := ('0' & unsigned(A))
                      + ('0' & B_temp)
                      + to_unsigned(1, 9);
        end if;

        -- Resultat sur 8 bits
        R_temp := std_logic_vector(Sum_temp(7 downto 0));
        R_Arith <= R_temp;

        -- Retenue de sortie
        Cout <= Sum_temp(8);

        -- Detection de l'Overflow
        if Sub = '0' then
            Overflow <= (not (A(7) xor B(7)))
                        and (A(7) xor R_temp(7));
        else
            Overflow <= (A(7) xor B(7))
                        and (A(7) xor R_temp(7));
        end if;

    end process;

end Behavioral;
