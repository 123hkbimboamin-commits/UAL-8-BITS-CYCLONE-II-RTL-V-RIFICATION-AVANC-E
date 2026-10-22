library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ual_8bits is
    Port (
        SrcA       : in  STD_LOGIC_VECTOR(7 downto 0);
        SrcB       : in  STD_LOGIC_VECTOR(7 downto 0);
        ALU_Ctrl   : in  STD_LOGIC_VECTOR(3 downto 0);

        ALU_Result : out STD_LOGIC_VECTOR(15 downto 0);
        Zero       : out STD_LOGIC;
        Cout       : out STD_LOGIC;
        Overflow   : out STD_LOGIC
    );
end ual_8bits;

architecture Structural of ual_8bits is

    -- Resultats internes des sous-blocs
    signal Res_Logique : STD_LOGIC_VECTOR(7 downto 0);
    signal Res_Arith   : STD_LOGIC_VECTOR(7 downto 0);
    signal Res_Shift   : STD_LOGIC_VECTOR(7 downto 0);
    signal Res_Mult    : STD_LOGIC_VECTOR(15 downto 0);

    -- Flags du bloc arithmetique
    signal Cout_Arith     : STD_LOGIC;
    signal Overflow_Arith : STD_LOGIC;

    -- Commande addition / soustraction
    signal Sub_Ctrl : STD_LOGIC;

    -- Resultat interne sur 16 bits
    signal Result_Int : STD_LOGIC_VECTOR(15 downto 0);

begin

    -- 1. Instanciation du bloc logique
    U_LOGIC : entity work.bloc_logic
        port map (
            A       => SrcA,
            B       => SrcB,
            Sel_Op  => ALU_Ctrl(1 downto 0),
            Y_logic => Res_Logique
        );

    -- 2. Instanciation additionneur / soustracteur
    Sub_Ctrl <= '1' when ALU_Ctrl = "0101" else '0';

    U_ARITH : entity work.add_sub_8
        port map (
            A        => SrcA,
            B        => SrcB,
            Sub      => Sub_Ctrl,
            R_Arith  => Res_Arith,
            Cout     => Cout_Arith,
            Overflow => Overflow_Arith
        );

    -- 3. Instanciation du Barrel Shifter
    U_SHIFT : entity work.barrel_shifter
        port map (
            Data_In    => SrcA,
            Shift_Amt  => SrcB(2 downto 0),
            Shift_Mode => ALU_Ctrl(1 downto 0),
            Data_Out   => Res_Shift
        );

    -- 4. Instanciation du multiplieur
    U_MULT : entity work.multiplier_8x8
        port map (
            A      => SrcA,
            B      => SrcB,
            Y_Mult => Res_Mult
        );

    -- 5. Multiplexeur de selection du resultat
    process(ALU_Ctrl, Res_Logique, Res_Arith,
            Res_Shift, Res_Mult)
    begin

        case ALU_Ctrl is

            -- Operations logiques
            when "0000" | "0001" | "0010" =>
                Result_Int <= x"00" & Res_Logique;

            -- Addition et soustraction
            when "0100" | "0101" =>
                Result_Int <= x"00" & Res_Arith;

            -- Multiplication
            when "0110" =>
                Result_Int <= Res_Mult;

            -- Decalages
            when "1000" | "1001" | "1010" =>
                Result_Int <= x"00" & Res_Shift;

            -- Operations non definies
            when others =>
                Result_Int <= (others => '0');

        end case;

    end process;

    -- 6. Sortie globale
    ALU_Result <= Result_Int;

    -- 7. Detection du resultat nul
    Zero <= '1' when Result_Int = x"0000"
                else '0';

    -- 8. Propagation des flags arithmetiques
    Cout <= Cout_Arith
        when (ALU_Ctrl = "0100" or ALU_Ctrl = "0101")
        else '0';

    Overflow <= Overflow_Arith
        when (ALU_Ctrl = "0100" or ALU_Ctrl = "0101")
        else '0';

end Structural;
