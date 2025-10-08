----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2025 02:51:49 PM
-- Design Name: 
-- Module Name: countdown_timer_fsm_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity countdown_timer_fsm_tb is
--  Port ( );
end countdown_timer_fsm_tb;

architecture Behavioral of countdown_timer_fsm_tb is
    SIGNAL switches : std_logic_vector(3 downto 0) := "1010";
    SIGNAL load_btn : std_logic := '0';
    SIGNAL clk: std_logic := '1';
    SIGNAL reset: std_logic := '0';
    SIGNAL start_btn: std_logic := '0'; 
    SIGNAL clk_en_1hz: std_logic := '1';
    SIGNAL count_out: std_logic_vector(3 downto 0) := "1111";
begin
    DUT : entity work.countdown_timer_fsm(Behavioral) PORT MAP (
        switches=>switches,
        load_btn => load_btn,
        clk => clk,
        reset => reset,
        start_btn => start_btn,
        clk_en_1hz => clk_en_1hz,
        count_out => count_out
    );
    
    stimulus : process
    begin
        -- Test idle state + run button:
        start_btn <= '1';
        wait for 200ns;
        start_btn <= '0';
    
    end process stimulus;
    
    -- Process for our TB clock
    clk_proc : process
    begin
        loop
            wait for 10ns;
            clk <= '0';
            wait for 10ns;
            clk <= '1';
        end loop;
    end process;
    
    one_hz_clock : process
    begin
        loop
            wait for 100ns;
            clk_en_1hz <= '0';
            wait for 100ns;
            clk_en_1hz <= '1';
        end loop;
    end process;

end Behavioral;
