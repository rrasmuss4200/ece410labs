----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/22/2025 01:56:40 PM
-- Design Name: 
-- Module Name: secure_element_fsm - Behavioral
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

entity secure_element_fsm is
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
    RGB : out std_logic_vector(2 downto 0);
    flash_clk : in std_logic;
    count_done : in std_logic := '0';
    start_cd : out std_logic
   );
end secure_element_fsm;

architecture Behavioral of secure_element_fsm is
    type statetype is (ST_STARTUP, ST_SECURE_CHANNEL, ST_IDLE, ST_SLEEP, ST_ALARM);
    signal present_state, next_state : statetype := ST_STARTUP;
begin

    controller_state_reg : process (clk) is
    begin
        if reset = '1' then
            present_state <= ST_STARTUP;
        elsif rising_edge(clk) then
            present_state <= next_state;
        end if;
    end process controller_state_reg;

-- when exiting start up state, check BUSY, THEN self-test


    state_combinational_logic : process (present_state, busy, self_test, startup, sleep, request, secure_channel, attack_detected,
        flash_clk, count_done) is
    begin
        start_cd <= '0';
        case present_state is
            when ST_STARTUP => 
                RGB <= "001"; -- blue
                if busy = '0' and self_test = '1' then
                     next_state <= ST_IDLE;
                elsif busy = '0' and self_test = '0' then
                    next_state <= ST_ALARM;
                else
                    next_state <= ST_STARTUP;
                end if;

            when ST_SECURE_CHANNEL => 
                RGB <= "010"; -- green
                if secure_channel = '0' then
                    next_state <= ST_IDLE;
                elsif sleep = '1' then
                    next_state <= ST_SLEEP;
                else 
                    next_state <= ST_SECURE_CHANNEL;
                end if;
                
            when ST_IDLE => 
                RGB <= "110"; -- yellow
                if attack_detected = '1' then
                    next_state <= ST_ALARM;
                elsif secure_channel = '1' then
                    next_state <= ST_SECURE_CHANNEL;
                elsif startup = '1' then
                    next_state <= ST_STARTUP;
                elsif sleep = '1' then
                    next_state <= ST_SLEEP;
                else
                    next_state <= ST_IDLE;
                end if;
                
            when ST_SLEEP =>
                start_cd <= '1';
                
                RGB <= "000"; -- off
                if request = '1' then
                    next_state <= ST_IDLE;
                    RGB <= "101";
--                    start_cd <= '0';
                elsif count_done = '1' then
                    RGB <= "011";
                    next_state <= ST_IDLE;
                elsif sleep = '0' then
                    next_state <= ST_SLEEP;
                else
                    next_state <= ST_SLEEP;
                end if;

            when ST_ALARM =>
                if flash_clk = '1' then
                    RGB <= "100";
                else
                    RGB <= "000";
                end if;
                next_state <= ST_ALARM;
                
                
        end case;
    end process state_combinational_logic;




end Behavioral;
