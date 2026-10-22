
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_ual_8bits is
end tb_ual_8bits;

architecture Simulation of tb_ual_8bits is

    signal SrcA : STD_LOGIC_VECTOR(7 downto 0)
                  := (others => '0');

    signal SrcB : STD_LOGIC_VECTOR(7 downto 0)
                  := (others => '0');

    signal ALU_Ctrl : STD_LOGIC_VECTOR(3 downto 0)
                      := (others => '0');

    signal ALU_Result : STD_LOGIC_VECTOR(15 downto 0);
    signal Zero       : STD_LOGIC;
    signal Cout       : STD_LOGIC;
    signal Overflow   : STD_LOGIC;

begin

    -- Instanciation de l'UAL complete
    DUT : entity work.ual_8bits
        port map (
            SrcA       => SrcA,
            SrcB       => SrcB,
            ALU_Ctrl   => ALU_Ctrl,
            ALU_Result => ALU_Result,
            Zero       => Zero,
            Cout       => Cout,
            Overflow   => Overflow
        );

    -- Processus de simulation
    stimulus : process

        -- Procedure de verification automatique
        procedure verifier(
            constant nom       : in string;
            constant res_att   : in STD_LOGIC_VECTOR(15 downto 0);
            constant zero_att  : in STD_LOGIC;
            constant cout_att  : in STD_LOGIC;
            constant ov_att    : in STD_LOGIC
        ) is
        begin
            assert ALU_Result = res_att
                report nom & " : erreur ALU_Result"
                severity failure;

            assert Zero = zero_att
                report nom & " : erreur Zero"
                severity failure;

            assert Cout = cout_att
                report nom & " : erreur Cout"
                severity failure;

            assert Overflow = ov_att
                report nom & " : erreur Overflow"
                severity failure;
        end procedure;

    begin

        -- TEST 1 : AND
        SrcA <= x"0F";
        SrcB <= x"33";
        ALU_Ctrl <= "0000";
        wait for 10 ns;
        verifier("AND", x"0003", '0', '0', '0');

        -- TEST 2 : OR
        ALU_Ctrl <= "0001";
        wait for 10 ns;
        verifier("OR", x"003F", '0', '0', '0');

        -- TEST 3 : NOT A
        ALU_Ctrl <= "0010";
        wait for 10 ns;
        verifier("NOT", x"00F0", '0', '0', '0');

        -- TEST 4 : ADDITION 5 + 3 = 8
        SrcA <= x"05";
        SrcB <= x"03";
        ALU_Ctrl <= "0100";
        wait for 10 ns;
        verifier("ADD", x"0008", '0', '0', '0');

        -- TEST 5 : ADDITION AVEC CARRY
        -- 255 + 1 = 256 (unsigned)
        SrcA <= x"FF";
        SrcB <= x"01";
        ALU_Ctrl <= "0100";
        wait for 10 ns;
        verifier("CARRY", x"0000", '1', '1', '0');

        -- TEST 6 : ADDITION AVEC OVERFLOW
        -- 127 + 1 = 128
        SrcA <= x"7F";
        SrcB <= x"01";
        ALU_Ctrl <= "0100";
        wait for 10 ns;
        verifier("OVERFLOW ADD", x"0080", '0', '0', '1');

        -- TEST 7 : SOUSTRACTION 5 - 3 = 2
        SrcA <= x"05";
        SrcB <= x"03";
        ALU_Ctrl <= "0101";
        wait for 10 ns;
        verifier("SUB", x"0002", '0', '1', '0');

        -- TEST 8 : SOUSTRACTION 3 - 5 = -2
        SrcA <= x"03";
        SrcB <= x"05";
        ALU_Ctrl <= "0101";
        wait for 10 ns;
        verifier("SUB NEG", x"00FE", '0', '0', '0');

        -- TEST 9 : SOUSTRACTION AVEC OVERFLOW
        -- -128 - 1 = -129
        SrcA <= x"80";
        SrcB <= x"01";
        ALU_Ctrl <= "0101";
        wait for 10 ns;
        verifier("OVERFLOW SUB", x"007F", '0', '1', '1');

        -- TEST 10 : MULTIPLICATION 255 * 2
        SrcA <= x"FF";
        SrcB <= x"02";
        ALU_Ctrl <= "0110";
        wait for 10 ns;
        verifier("MULT 255x2", x"01FE", '0', '0', '0');

        -- TEST 11 : MULTIPLICATION MAXIMALE
        -- 255 * 255 = 65025
        SrcA <= x"FF";
        SrcB <= x"FF";
        ALU_Ctrl <= "0110";
        wait for 10 ns;
        verifier("MULT MAX", x"FE01", '0', '0', '0');

        -- TEST 12 : LSL 5 decale de 3
        SrcA <= x"05";
        SrcB <= x"03";
        ALU_Ctrl <= "1000";
        wait for 10 ns;
        verifier("LSL", x"0028", '0', '0', '0');

        -- TEST 13 : LSR
        SrcA <= x"F0";
        SrcB <= x"02";
        ALU_Ctrl <= "1001";
        wait for 10 ns;
        verifier("LSR", x"003C", '0', '0', '0');

        -- TEST 14 : ASR sur un nombre negatif
        -- -16 >> 2 = -4
        SrcA <= x"F0";
        SrcB <= x"02";
        ALU_Ctrl <= "1010";
        wait for 10 ns;
        verifier("ASR NEG", x"00FC", '0', '0', '0');

        -- TEST 15 : LSL de 7 positions
        SrcA <= x"01";
        SrcB <= x"07";
        ALU_Ctrl <= "1000";
        wait for 10 ns;
        verifier("LSL MAX", x"0080", '0', '0', '0');

        -- TEST 16 : ASR de 7 positions
        SrcA <= x"80";
        SrcB <= x"07";
        ALU_Ctrl <= "1010";
        wait for 10 ns;
        verifier("ASR MAX", x"00FF", '0', '0', '0');

        -- TEST 17 : RESULTAT ZERO
        SrcA <= x"0F";
        SrcB <= x"F0";
        ALU_Ctrl <= "0000";
        wait for 10 ns;
        verifier("ZERO", x"0000", '1', '0', '0');

        -- TEST 18 : CODE INVALIDE
        ALU_Ctrl <= "1111";
        wait for 10 ns;
        verifier("INVALIDE", x"0000", '1', '0', '0');

        report "TOUS LES TESTS UAL SONT REUSSIS"
            severity note;

        wait;

    end process;

end Simulation;
