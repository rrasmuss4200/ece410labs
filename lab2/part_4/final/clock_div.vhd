LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity clock_div is
    port (
        clk : in std_logic; -- Input clock (e.g., 100 MHz)
        slow_clk : out std_logic -- Output 1 Hz clock
    );
end clock_div;

architecture Behavioral of clock_div is
    signal count : integer := 0;
    signal clk_out_signal : std_logic := '0'; -- Internal signal for the divided clock
    CONSTANT limit : INTEGER   := 62500000;
begin

    divider : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF count < limit - 1 THEN
                count <= count + 1;
            ELSE
                count   <= 0;
                clk_out_signal <= NOT clk_out_signal;
            END IF;
        END IF;
    END PROCESS;
    slow_clk <= clk_out_signal;
end Behavioral;
