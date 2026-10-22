
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_bloc_logic is
end tb_bloc_logic;

architecture Behavioral of tb_bloc_logic is

    signal A         : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal B         : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal Sel_Op    : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal Y_logic : STD_LOGIC_VECTOR(7 downto 0);

begin

    DUT : entity work.bloc_logic
        port map (
            A         => A,
            B         => B,
            Sel_Op    => Sel_Op,
            Y_logic => Y_logic
        );

    stim_proc : process
    begin

        -- Test 1 : AND
        A <= "00000101";  -- 5
        B <= "00000011";  -- 3
        Sel_Op <= "00";

        wait for 10 ns;

        assert Y_logic = "00000001"
        report "Erreur : AND"
        severity error;

        -- Test 2 : OR
        Sel_Op <= "01";

        wait for 10 ns;

        assert Y_logic = "00000111"
        report "Erreur : OR"
        severity error;

        -- Test 3 : NOT
        Sel_Op <= "10";

        wait for 10 ns;

        assert Y_logic = "11111010"
        report "Erreur : NOT"
        severity error;

        -- Test 4 : cas non defini (11)
        Sel_Op <= "11";

        wait for 10 ns;

        assert Y_logic = "00000000"
        report "Erreur : cas 11"
        severity error;

        -- Test 5 : AND avec autres valeurs
        A <= "11110000";
        B <= "00001111";
        Sel_Op <= "00";

        wait for 10 ns;

        assert Y_logic = "00000000"
        report "Erreur : AND test 2"
        severity error;

        -- Fin des tests
        report "Fin des tests du bloc logic"
        severity note;

        wait;

    end process;

end Behavioral;
