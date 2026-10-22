library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity barrel_shifter is
    Port (
        Data_In    : in  STD_LOGIC_VECTOR(7 downto 0);
        Shift_Amt  : in  STD_LOGIC_VECTOR(2 downto 0);
        Shift_Mode : in  STD_LOGIC_VECTOR(1 downto 0);
        Data_Out   : out STD_LOGIC_VECTOR(7 downto 0)
    );
end barrel_shifter;

architecture Behavioral of barrel_shifter is
begin

    process(Data_In, Shift_Amt, Shift_Mode)

        variable S1, S2, S3 : STD_LOGIC_VECTOR(7 downto 0);
        variable Sign_Bit   : STD_LOGIC;

    begin

        S1 := Data_In;
        S2 := Data_In;
        S3 := Data_In;
        Sign_Bit := '0';

        case Shift_Mode is

            -- LSL : decalage logique a gauche
            when "00" =>

                if Shift_Amt(0) = '1' then
                    S1 := Data_In(6 downto 0) & '0';
                end if;

                S2 := S1;
                if Shift_Amt(1) = '1' then
                    S2 := S1(5 downto 0) & "00";
                end if;

                S3 := S2;
                if Shift_Amt(2) = '1' then
                    S3 := S2(3 downto 0) & "0000";
                end if;

            -- LSR et ASR : decalage a droite
            when "01" | "10" =>

                -- ASR : conserver le bit de signe
                if Shift_Mode = "10" then
                    Sign_Bit := Data_In(7);
                end if;

                if Shift_Amt(0) = '1' then
                    S1 := Sign_Bit & Data_In(7 downto 1);
                end if;

                S2 := S1;
                if Shift_Amt(1) = '1' then
                    S2 := Sign_Bit & Sign_Bit &
                          S1(7 downto 2);
                end if;

                S3 := S2;
                if Shift_Amt(2) = '1' then
                    S3 := Sign_Bit & Sign_Bit &
                          Sign_Bit & Sign_Bit &
                          S2(7 downto 4);
                end if;

            when others =>
                S3 := (others => '0');

        end case;

        Data_Out <= S3;

    end process;

end Behavioral;
