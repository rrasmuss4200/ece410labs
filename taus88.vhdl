------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410 Fall 2025
-- Project     : Lab 2
-- Authors     : Antonio Andara Lara
-- Date        : 22-Sep-2025
------------------------------------------------------------------------
-- Description : Top module for taus88 implementation with SSD on the zybo board
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY taus88 IS
    PORT (
        clock          : IN STD_LOGIC;
        start          : IN STD_LOGIC;
        btn            : IN STD_LOGIC;
        display_select : OUT STD_LOGIC;
        busy           : OUT STD_LOGIC;
        segments       : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        count_led      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END ENTITY taus88;

ARCHITECTURE Structural OF taus88 IS
    SIGNAL clk_out  : STD_LOGIC;
    SIGNAL dout_s   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL byte_s   : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL digits_s : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL tout_0   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL tout_1   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL tout_2   : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
--U1
    PRNG_1         : ENTITY work.top_taus(Behavioral) GENERIC MAP (C=>X"FFFFFFFE", S1=>13, S2=>19, S3=>12) PORT MAP(clk=>clock, taus_out=>tout_0);
	PRNG_2         : ENTITY work.top_taus(Behavioral) GENERIC MAP (C=>X"FFFFFFF8", S1=>2, S2=>25, S3=>4) PORT MAP(clk=>clock, taus_out=>tout_1);
	PRNG_3         : ENTITY work.top_taus(Behavioral) GENERIC MAP (C=>X"FFFFFFF0", S1=>3, S2=>11, S3=>17) PORT MAP(clk=>clock, taus_out=>tout_2);
    manual_input : ENTITY work.manual_clock(Behavioral) PORT MAP(clock => clock, btn => btn, clk_out => clk_out);
    counter_unit : ENTITY work.byte_counter(Behavioral) PORT MAP(start => start, clock => clock, busy => busy, count_led => count_led, count_byte => byte_s);
    mux          : ENTITY WORK.lab1_mux(Behavioral) PORT MAP(mux_i => dout_s, mux_s => byte_s, mux_o => digits_s);
    ssd_driver   : ENTITY work.display_controller(Behavioral) PORT MAP(digits => digits_s, clock => clock, display_select => display_select, segments => segments);
    
    dout_s <= tout_0 xor tout_1 xor tout_2;
END ARCHITECTURE Structural;


