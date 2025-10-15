------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410 Fall 2025
-- Project     : Lab 2
-- Authors     : Antonio Andara Lara
-- Date        : 22-Sep-2025
------------------------------------------------------------------------
-- Description : Top-level entity for the Countdown FSM (Part 1 of Lab 2).
--               Students must map all ports in the constraint file to
--               ensure proper functionality, and instantiate their FSM
--               design within this top-level architecture.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY fsm_socket IS
    PORT (
        clock          : IN STD_LOGIC;
        load           : IN STD_LOGIC;
        start          : IN STD_LOGIC;
        reset          : IN STD_LOGIC;
        load_in        : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        RGB            : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        count          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        display_select : OUT STD_LOGIC := '0';
        segments       : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE Structural OF fsm_socket IS
    SIGNAL count_s : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL slow_clk: STD_LOGIC;
BEGIN
    clock_div : ENTITY WORK.clock_div(Behavioral) PORT MAP(clk=>clock, slow_clk=>slow_clk);
    fsm : ENTITY WORK.countdown_timer_fsm(Behavioral) PORT MAP(
            reset => reset,
            switches => load_in,
            start_btn => start,
            load_btn => load,
            clk_en_1hz => slow_clk,
            count_out => count_s,
            rgb_state => RGB
    );
    SSD_controller : ENTITY WORK.display_controller(Behavioral) PORT MAP(digits => count_s, clock => clock, display_select => display_select, segments => segments);
    count <= count_s;
END Structural;
