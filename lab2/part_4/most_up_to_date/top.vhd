----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/22/2025 03:56:50 PM
-- Design Name: 
-- Module Name: lab2_p4_top - Behavioral
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

entity lab2_p4_top is
  Port ( 
    clk : in std_logic;
    busy : in std_logic := '1'; -- so we start in startup and not alarm
    self_test : in std_logic;
    startup : in std_logic;
    sleep : in std_logic;
    request : in std_logic;
    secure_channel : in std_logic;
    attack_detected : in std_logic;
    reset : in std_logic;
    RGB : out std_logic_vector(2 downto 0)
    );
end lab2_p4_top;

architecture Structural of lab2_p4_top is
    signal clock_out : std_logic;
    
    --dumby sigs
    signal reset_d : std_logic;
    signal switches_d : std_logic_vector( 3 downto 0);
    signal count_out_d : std_logic_vector( 3 downto 0);
    signal load_btn_d : std_logic;
    
    signal cd_done : std_logic;
    signal start_cd : std_logic;
begin
    
    CLOCK_DIV : ENTITY work.clock_div(Behavioral) PORT MAP (clk => clk, slow_clk => clock_out);
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
        flash_clk => clock_out,
        count_done => cd_done,
        start_cd => start_cd
    );
    COUNT_ELEM : ENTITY WORK.countdown_timer_fsm(Behavioral) PORT MAP(
            reset => reset_d,
            switches => switches_d,
            start_btn => start_cd,
            load_btn => load_btn_d,
            clk_en_1hz => clock_out,
            count_out => count_out_d,
            done_out => cd_done
    );


end Structural;
