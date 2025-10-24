----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/22/2025 02:26:34 PM
-- Design Name: 
-- Module Name: secure_element_fsm_tb - Behavioral
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

entity secure_element_fsm_tb is
--  Port ( );
end secure_element_fsm_tb;

architecture Behavioral of secure_element_fsm_tb is
    signal clk : std_logic;
    signal busy : std_logic := '1';
    signal self_test : std_logic := '0';
    signal startup : std_logic;
    signal sleep : std_logic;
    signal request : std_logic;
    signal secure_channel : std_logic;
    signal attack_detected : std_logic := '0';
    signal RGB : std_logic_vector(2 downto 0);
    signal reset : std_logic;
    signal slow_clk : std_logic;
    signal cd_done : std_logic;
    signal start_cd : std_logic;
    

begin
--    CLOCK_DIV : ENTITY work.clock_div(Behavioral) PORT MAP (clk => clk, slow_clk => clock_out);
    SEC_ELEM : ENTITY work.secure_element_fsm(Behavioral) PORT MAP(
        clk=>clk, 
        reset => reset,
        busy=>busy, 
        self_test=>self_test, 
        startup=>startup, 
        sleep =>sleep, 
        request=>request, 
        secure_channel=>secure_channel, 
        attack_detected=>attack_detected, 
        RGB=>RGB,
        flash_clk => slow_clk,
        count_done => cd_done,
        start_cd => start_cd
    );
    
    COUNT_ELEM : ENTITY WORK.countdown_timer_fsm(Behavioral) PORT MAP(
            reset => '0',
            switches => "0000",
            start_btn => start_cd,
            load_btn => '0',
            clk_en_1hz => slow_clk,
            count_out => "0000",
            done_out => cd_done
    );
    
    stimulus : process
    begin
    --PART 4
        -- test wake up after 15s
        wait for 5 ns;
        self_test <= '1'; -- In idle now
        busy <= '0';
        wait for 5 ns;
        sleep <= '1'; -- Now in sleep should see countdown
        wait for 10ns;
        sleep <= '0'; 
        wait for 200ns; -- wait for count down to take us to idle
        startup <= '1'; -- take us back to startup after idle
        wait;
    
        -- Test blinking + reset
        wait for 10 ns;
        self_test <= '0';
        wait for 5 ns;
        busy <= '0';
        wait for 5ns;
        reset <= '1';
        wait;

    -- PART 3
        -- stay in startup when busy
        busy <= '1';
        wait for 5 ns;
        self_test <= '1';
        wait for 3 ns;
        self_test <= '0';
        
        -- startup -> alarm
        busy <= '0';
        wait for 5ns;
        self_test <= '0';
        wait for 5ns;
        
        -- alarm -> alarm
        self_test <= '1';
        sleep <= '1';
        wait for 5 ns;
        sleep <= '0';
        wait for 5 ns;
        -- alarm -> idle
        attack_detected <= '0';
        wait for 5ns;
        
        -- idle -> startup
        startup <= '1';
        wait for 5 ns;
        startup <= '0';
        wait for 5ns;
        
        -- startup -> idle
        self_test <= '1';
        wait for 5ns;
        
        -- idle -> sleep 
        sleep <= '1';
        wait for 5ns;
        sleep <= '0';
        
        --sleep -> sleep
        attack_detected <= '1';
        wait for 5ns;
        attack_detected <= '0';
        wait for 5ns;
        -- sleep -> idle
        request <= '1';
        wait for 5ns;
        request <= '0';
        wait for 5ns;
        
        -- idle -> sec_chan
        secure_channel <= '1';
        wait for 5ns;
        
        -- sec_hcna -> sec_chan
        busy <= '1';
        wait for 5ns;
        busy <= '0';
        wait for 5ns;
        
        -- sec_chan -> idle
        secure_channel <= '0';
        wait for 5ns;
        
        -- idle -> alarm
        attack_detected <= '1';
        wait for 5ns;
        
        -- alarm -> alarm
        sleep <= '1';
        wait for 5ns;
        sleep <= '0';
        wait for 5ns;
        
        -- alarm -> idle
        attack_detected <= '0';
        wait for 5ns;

        -- idle -> idle
        request <= '1';
        wait for 5ns;
        
    end process;   
 
    clk_proc : process
        begin
            loop
                wait for 1ns;
                clk <= '0';
                wait for 1ns;
                clk <= '1';
            end loop;
        end process;
        
    slow_clk_p : process
        begin
            loop
                wait for 5ns;
                slow_clk <= '0';
                wait for 5ns;
                slow_clk <= '1';
            end loop;
        end process;    
end Behavioral;
