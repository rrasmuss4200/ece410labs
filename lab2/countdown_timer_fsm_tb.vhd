library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity countdown_timer_fsm_tb is
end countdown_timer_fsm_tb;

architecture Behavioral of countdown_timer_fsm_tb is

    -- Component declaration
    component countdown_timer_fsm
        Port (
            clk         : in  STD_LOGIC;
            rst         : in  STD_LOGIC;
            clk_en_1hz  : in  STD_LOGIC;
            load_btn    : in  STD_LOGIC;
            start_btn   : in  STD_LOGIC;
            switches    : in  STD_LOGIC_VECTOR(3 downto 0);
            count_out   : out STD_LOGIC_VECTOR(3 downto 0);
            done        : out STD_LOGIC
        );
    end component;

    -- Test signals
    signal clk         : STD_LOGIC := '0';
    signal rst         : STD_LOGIC := '0';
    signal clk_en_1hz  : STD_LOGIC := '0';
    signal load_btn    : STD_LOGIC := '0';
    signal start_btn   : STD_LOGIC := '0';
    signal switches    : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal count_out   : STD_LOGIC_VECTOR(3 downto 0);
    signal done        : STD_LOGIC;

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

    -- Simulation control
    signal sim_done : boolean := false;

begin

    -- Instantiate Unit Under Test (UUT)
    uut: countdown_timer_fsm
        port map (
            clk        => clk,
            rst        => rst,
            clk_en_1hz => clk_en_1hz,
            load_btn   => load_btn,
            start_btn  => start_btn,
            switches   => switches,
            count_out  => count_out,
            done       => done
        );

    -- Clock generation
    clk_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Test stimulus process
    stim_proc: process
    begin

        report "========== Starting Countdown Timer FSM Test ==========";

        -- Test 1: Asynchronous Reset
        report "Test 1: Asynchronous Reset";
        rst <= '1';
        wait for 25 ns;
        rst <= '0';
        wait for 20 ns;
        assert unsigned(count_out) = 10 report "Reset failed - should show default 10" severity error;
        report "Test 1 Complete: Reset verified";

        -- Test 2: Default Start (10 seconds)
        report "Test 2: Default countdown from 10";
        wait for 20 ns;
        start_btn <= '1';
        wait for CLK_PERIOD;
        start_btn <= '0';
        wait for CLK_PERIOD * 2;

        -- Should now be counting from 10
        assert unsigned(count_out) = 10 report "Failed to load default value" severity error;

        -- Simulate countdown with 1Hz enable
        for i in 10 downto 1 loop
            assert unsigned(count_out) = i report "Count mismatch at " & integer'image(i) severity error;
            assert done = '0' report "Done asserted prematurely" severity error;
            clk_en_1hz <= '1';
            wait for CLK_PERIOD;
            clk_en_1hz <= '0';
            wait for 20 ns;
        end loop;

        -- Check done state
        assert unsigned(count_out) = 0 report "Count not zero at end" severity error;
        assert done = '1' report "Done not asserted" severity error;
        report "Test 2 Complete: Default countdown successful";

        wait for 40 ns;

        -- Test 4.5: Load invalid values (X, U, Z) - should default to 10
        report "Test 4.5: Load invalid std_logic values (should default to 10)";
        switches <= "XX01";  -- Invalid
        load_btn <= '1';
        wait for CLK_PERIOD;
        load_btn <= '0';
        wait for CLK_PERIOD * 2;

        assert unsigned(count_out) = 10 report "Failed to default to 10 with invalid values" severity error;

        switches <= "ZZZZ";  -- All high-impedance
        load_btn <= '1';
        wait for CLK_PERIOD;
        load_btn <= '0';
        wait for CLK_PERIOD * 2;

        assert unsigned(count_out) = 10 report "Failed to default to 10 with Z values" severity error;
        report "Test 4.5 Complete: Invalid values correctly default to 10";

        wait for 40 ns;

        -- Test 3: Load custom value (5 seconds)
        report "Test 3: Load and countdown from 5";
        switches <= "0101";  -- 5
        load_btn <= '1';
        wait for CLK_PERIOD;
        load_btn <= '0';
        wait for CLK_PERIOD * 2;  -- Wait for LOAD state to complete

        -- Check that loaded value is displayed
        assert unsigned(count_out) = 5 report "Failed to display loaded value 5" severity error;

        start_btn <= '1';
        wait for CLK_PERIOD;
        start_btn <= '0';
        wait for CLK_PERIOD * 2;

        assert unsigned(count_out) = 5 report "Failed to start from value 5" severity error;

        -- Countdown from 5
        for i in 5 downto 1 loop
            assert unsigned(count_out) = i report "Count mismatch at " & integer'image(i) severity error;
            clk_en_1hz <= '1';
            wait for CLK_PERIOD;
            clk_en_1hz <= '0';
            wait for 20 ns;
        end loop;

        assert done = '1' report "Done not asserted after countdown from 5" severity error;
        report "Test 3 Complete: Custom value countdown successful";

        wait for 40 ns;

        -- Test 4: Load value of 0 (should load 0, not default)
        report "Test 4: Load zero (should load 0, not default to 10)";
        switches <= "0000";  -- 0
        load_btn <= '1';
        wait for CLK_PERIOD;
        load_btn <= '0';
        wait for CLK_PERIOD * 2;

        assert unsigned(count_out) = 0 report "Failed to load 0, got " & integer'image(to_integer(unsigned(count_out))) severity error;

        start_btn <= '1';
        wait for CLK_PERIOD;
        start_btn <= '0';
        wait for CLK_PERIOD * 2;

        assert unsigned(count_out) = 0 report "Failed to start from 0" severity error;
        assert done = '1' report "Done should be asserted immediately when starting from 0" severity error;
        report "Test 4 Complete: Zero value correctly loads as 0";

        wait for 40 ns;

        -- Test 5: Reset during countdown
        report "Test 5: Asynchronous reset during countdown";
        switches <= "1111";  -- 15
        load_btn <= '1';
        wait for CLK_PERIOD;
        load_btn <= '0';
        wait for CLK_PERIOD * 2;

        start_btn <= '1';
        wait for CLK_PERIOD;
        start_btn <= '0';
        wait for CLK_PERIOD * 2;

        -- Count down a few times
        for i in 1 to 3 loop
            clk_en_1hz <= '1';
            wait for CLK_PERIOD;
            clk_en_1hz <= '0';
            wait for 20 ns;
        end loop;

        -- Assert reset during countdown
        rst <= '1';
        wait for 15 ns;
        assert unsigned(count_out) = 10 report "Reset should return to default display" severity error;
        rst <= '0';
        wait for 20 ns;
        report "Test 5 Complete: Reset during countdown successful";

        -- Test 6: Maximum value (15)
        report "Test 6: Countdown from maximum value (15)";
        switches <= "1111";  -- 15
        load_btn <= '1';
        wait for CLK_PERIOD;
        load_btn <= '0';
        wait for CLK_PERIOD * 2;

        assert unsigned(count_out) = 15 report "Failed to load max value 15" severity error;

        start_btn <= '1';
        wait for CLK_PERIOD;
        start_btn <= '0';
        wait for CLK_PERIOD * 2;

        assert unsigned(count_out) = 15 report "Failed to start from max value 15" severity error;

        -- Count down a few ticks
        for i in 15 downto 13 loop
            assert unsigned(count_out) = i report "Count error at " & integer'image(i) severity error;
            assert unsigned(count_out) <= 15 report "Count exceeded maximum!" severity error;
            clk_en_1hz <= '1';
            wait for CLK_PERIOD;
            clk_en_1hz <= '0';
            wait for 20 ns;
        end loop;
        report "Test 6 Complete: Maximum value test passed";

        -- Test 7: Verify count never goes negative
        report "Test 7: Verify count stays at zero";
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        switches <= "0001";  -- 1
        load_btn <= '1';
        wait for CLK_PERIOD;
        load_btn <= '0';
        wait for CLK_PERIOD * 2;

        start_btn <= '1';
        wait for CLK_PERIOD;
        start_btn <= '0';
        wait for CLK_PERIOD * 2;

        -- Count down to zero
        clk_en_1hz <= '1';
        wait for CLK_PERIOD;
        clk_en_1hz <= '0';
        wait for 20 ns;

        assert unsigned(count_out) = 0 report "Count not zero" severity error;
        assert done = '1' report "Done not set" severity error;

        -- Try to count more (should stay at zero)
        clk_en_1hz <= '1';
        wait for CLK_PERIOD;
        clk_en_1hz <= '0';
        wait for 20 ns;

        assert unsigned(count_out) = 0 report "Count went below zero!" severity error;
        report "Test 7 Complete: Count correctly stops at zero";

        -- Test 8: Multiple consecutive loads
        report "Test 8: Multiple consecutive loads";
        switches <= "0011";  -- 3
        load_btn <= '1';
        wait for CLK_PERIOD;
        load_btn <= '0';
        wait for CLK_PERIOD * 2;

        assert unsigned(count_out) = 3 report "First load failed" severity error;

        switches <= "0111";  -- 7
        load_btn <= '1';
        wait for CLK_PERIOD;
        load_btn <= '0';
        wait for CLK_PERIOD * 2;

        assert unsigned(count_out) = 7 report "Second load failed" severity error;
        report "Test 8 Complete: Multiple loads successful";

        wait for 100 ns;
        report "========== All Tests Completed Successfully ==========";

        sim_done <= true;
        wait;

    end process;

end Behavioral;