-- Bureau d'etude UAL 8 bits - Testbench avance et auto-verifiant
-- Compatible VHDL-93 / ModelSim-Altera 10.1d
-- A utiliser UNIQUEMENT dans ModelSim (non synthetisable).
-- Conventions du projet :
--   * ALU_Result sur 16 bits, zero-extension des resultats 8 bits.
--   * Cout pour SUB = 1 si pas d'emprunt (A unsigned >= B unsigned).
--   * Zero = 1 si les 16 bits de ALU_Result valent zero.
--   * Cout/Overflow = 0 en dehors des operations ADD/SUB.
--   * Codes ALU_Ctrl non definis : resultat = 0.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ual_8bits_advanced is
end tb_ual_8bits_advanced;

architecture Simulation of tb_ual_8bits_advanced is
    signal SrcA       : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal SrcB       : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal ALU_Ctrl   : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal ALU_Result : STD_LOGIC_VECTOR(15 downto 0);
    signal Zero       : STD_LOGIC;
    signal Cout       : STD_LOGIC;
    signal Overflow   : STD_LOGIC;

    type byte_array is array (natural range <>) of STD_LOGIC_VECTOR(7 downto 0);
    constant EDGES : byte_array(0 to 15) := (
        x"00", x"01", x"02", x"03",
        x"05", x"07", x"0F", x"10",
        x"3F", x"40", x"7F", x"80",
        x"81", x"F0", x"FE", x"FF"
    );
begin
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

    stimulus : process
        variable tests_ok : integer := 0;
        variable lfsr     : unsigned(15 downto 0) := x"ACE1";
        variable rand_a   : STD_LOGIC_VECTOR(7 downto 0);
        variable rand_b   : STD_LOGIC_VECTOR(7 downto 0);

        -- Golden reference : modele de reference independant des sous-blocs.
        -- On calcule avec des entiers pour ADD/SUB/MULT, et avec numeric_std
        -- pour les decalages. Les sorties du DUT sont ensuite comparees.
        procedure check_case(
            constant a_test    : in STD_LOGIC_VECTOR(7 downto 0);
            constant b_test    : in STD_LOGIC_VECTOR(7 downto 0);
            constant ctrl_test : in STD_LOGIC_VECTOR(3 downto 0);
            constant test_name : in string
        ) is
            variable au, bu       : integer;
            variable asg, bsg     : integer;
            variable exact_value  : integer;
            variable shift_amount : integer;
            variable value8       : STD_LOGIC_VECTOR(7 downto 0);
            variable exp_result   : STD_LOGIC_VECTOR(15 downto 0);
            variable exp_zero     : STD_LOGIC;
            variable exp_cout     : STD_LOGIC;
            variable exp_overflow : STD_LOGIC;
        begin
            au  := to_integer(unsigned(a_test));
            bu  := to_integer(unsigned(b_test));
            asg := to_integer(signed(a_test));
            bsg := to_integer(signed(b_test));
            shift_amount := to_integer(unsigned(b_test(2 downto 0)));

            exp_result   := (others => '0');
            exp_cout     := '0';
            exp_overflow := '0';
            value8       := (others => '0');

            case ctrl_test is
                when "0000" =>  -- AND
                    value8 := a_test and b_test;
                    exp_result := x"00" & value8;

                when "0001" =>  -- OR
                    value8 := a_test or b_test;
                    exp_result := x"00" & value8;

                when "0010" =>  -- NOT A
                    value8 := not a_test;
                    exp_result := x"00" & value8;

                when "0100" =>  -- ADD
                    exact_value := au + bu;
                    exp_result := std_logic_vector(to_unsigned(exact_value mod 256, 16));
                    if exact_value > 255 then
                        exp_cout := '1';
                    end if;
                    if (asg + bsg > 127) or (asg + bsg < -128) then
                        exp_overflow := '1';
                    end if;

                when "0101" =>  -- SUB, Cout = NOT borrow
                    exact_value := au - bu;
                    exp_result := std_logic_vector(
                        to_unsigned((exact_value + 256) mod 256, 16)
                    );
                    if au >= bu then
                        exp_cout := '1';
                    end if;
                    if (asg - bsg > 127) or (asg - bsg < -128) then
                        exp_overflow := '1';
                    end if;

                when "0110" =>  -- MULT unsigned
                    exact_value := au * bu;
                    exp_result := std_logic_vector(to_unsigned(exact_value, 16));

                when "1000" =>  -- LSL
                    value8 := std_logic_vector(
                        shift_left(unsigned(a_test), shift_amount)
                    );
                    exp_result := x"00" & value8;

                when "1001" =>  -- LSR
                    value8 := std_logic_vector(
                        shift_right(unsigned(a_test), shift_amount)
                    );
                    exp_result := x"00" & value8;

                when "1010" =>  -- ASR : extension du signe sur 8 bits
                    value8 := std_logic_vector(
                        shift_right(signed(a_test), shift_amount)
                    );
                    exp_result := x"00" & value8;

                when others =>
                    exp_result := (others => '0');
            end case;

            if exp_result = x"0000" then
                exp_zero := '1';
            else
                exp_zero := '0';
            end if;

            SrcA <= a_test;
            SrcB <= b_test;
            ALU_Ctrl <= ctrl_test;
            wait for 2 ns;  -- attente de stabilisation combinatoire, simulation seulement

            assert ALU_Result = exp_result
                report "FAIL ALU_Result: " & test_name &
                       ", A=" & integer'image(au) &
                       ", B=" & integer'image(bu) &
                       ", CTRL=" & integer'image(to_integer(unsigned(ctrl_test)))
                severity failure;
            assert Zero = exp_zero
                report "FAIL Zero: " & test_name
                severity failure;
            assert Cout = exp_cout
                report "FAIL Cout: " & test_name
                severity failure;
            assert Overflow = exp_overflow
                report "FAIL Overflow: " & test_name
                severity failure;

            tests_ok := tests_ok + 1;
        end procedure;

    begin
        report "DEBUT : verification automatique UAL 8 bits" severity note;

        -- Phase 1 : 18 cas diriges lisibles dans le chronogramme (0 a 36 ns).
        check_case(x"0F", x"33", "0000", "AND");
        check_case(x"0F", x"33", "0001", "OR");
        check_case(x"0F", x"33", "0010", "NOT");
        check_case(x"05", x"03", "0100", "ADD 5+3");
        check_case(x"FF", x"01", "0100", "ADD carry 255+1");
        check_case(x"7F", x"01", "0100", "ADD overflow 127+1");
        check_case(x"05", x"03", "0101", "SUB 5-3");
        check_case(x"03", x"05", "0101", "SUB 3-5");
        check_case(x"80", x"01", "0101", "SUB overflow -128-1");
        check_case(x"FF", x"02", "0110", "MULT 255x2");
        check_case(x"FF", x"FF", "0110", "MULT 255x255");
        check_case(x"05", x"03", "1000", "LSL 5 by 3");
        check_case(x"F0", x"02", "1001", "LSR F0 by 2");
        check_case(x"F0", x"02", "1010", "ASR -16 by 2");
        check_case(x"01", x"07", "1000", "LSL 1 by 7");
        check_case(x"80", x"07", "1010", "ASR -128 by 7");
        check_case(x"0F", x"F0", "0000", "Zero flag");
        check_case(x"0F", x"F0", "1111", "Invalid control");

        report "PASS : 18 tests diriges" severity note;

        -- Phase 2 : matrice de valeurs limites.
        -- 16 valeurs A x 16 valeurs B x 16 codes ALU_Ctrl = 4096 cas.
        for i in EDGES'range loop
            for j in EDGES'range loop
                for ctrl in 0 to 15 loop
                    check_case(
                        EDGES(i), EDGES(j),
                        std_logic_vector(to_unsigned(ctrl, 4)),
                        "MATRICE_LIMITES"
                    );
                end loop;
            end loop;
        end loop;
        report "PASS : matrice de 4096 tests de valeurs limites" severity note;

        -- Phase 3 : 1024 couples pseudo-aleatoires reproductibles (LFSR).
        -- CTRL parcourt tous les codes de 0 a 15 a chaque groupe de 16 tests.
        for n in 0 to 1023 loop
            lfsr := lfsr(14 downto 0) &
                    (lfsr(15) xor lfsr(13) xor lfsr(12) xor lfsr(10));
            rand_a := std_logic_vector(lfsr(7 downto 0));

            lfsr := lfsr(14 downto 0) &
                    (lfsr(15) xor lfsr(13) xor lfsr(12) xor lfsr(10));
            rand_b := std_logic_vector(lfsr(7 downto 0));

            check_case(
                rand_a, rand_b,
                std_logic_vector(to_unsigned(n mod 16, 4)),
                "PSEUDO_ALEATOIRE"
            );
        end loop;
        report "PASS : 1024 tests pseudo-aleatoires" severity note;

        report "SUCCESS : " & integer'image(tests_ok) &
               " tests auto-verifies sans erreur" severity note;
        wait;
    end process;
end Simulation;
