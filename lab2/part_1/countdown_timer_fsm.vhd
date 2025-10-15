----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Yaaqoob, Rowan
-- 
-- Create Date: 10/08/2025 01:14:29 PM
-- Design Name: 
-- Module Name: countdown_timer_fsm - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity countdown_timer_fsm is
  Port ( 
    reset: in std_logic;
    switches: in std_logic_vector(3 downto 0);
    start_btn: in std_logic;
    load_btn: in std_logic;
    
    clk_en_1hz: in std_logic;
    
    count_out: out std_logic_vector(3 downto 0);
    rgb_state: out std_logic_vector(2 downto 0)
  );
end countdown_timer_fsm;


architecture Behavioral of countdown_timer_fsm is

    type state_type is (IDLE, LOAD, COUNTDOWN, DONE);
    signal curr_state : state_type := IDLE;
    signal next_state : state_type;
    constant DEFAULT_COUNT : INTEGER := 10;
    signal curr_count_reg : INTEGER := 0; -- Start counter at 0 in IDLE
    signal loaded_val : INTEGER := DEFAULT_COUNT;
    
    -- Next-value signals for registers
    signal loaded_val_next : INTEGER;
    signal curr_count_regnext : INTEGER;
    
begin
    -- PROCESS 1: Sequential Logic (State Updates)
    -- This process is clocked by the 1Hz signal and updates all our registers on its rising edge.
    process (clk_en_1hz, reset) is 
    begin
        if reset = '1' then
            curr_state <= IDLE;
            curr_count_reg <= 0;
            loaded_val <= DEFAULT_COUNT;
        elsif rising_edge(clk_en_1hz) then
            curr_state <= next_state;
            curr_count_reg <= curr_count_regnext;
            loaded_val <= loaded_val_next;
        end if;
    end process;
    
    -- PROCESS 2: Combinational Logic (Next-State and Output Logic)
    -- Notes: purely combinational.
    -- It calculates the next state and next register values based on the current state and inputs.
    process (curr_state, loaded_val, curr_count_reg, load_btn, start_btn, switches) is
    begin
        next_state <= curr_state;
        loaded_val_next <= loaded_val;
        curr_count_regnext <= curr_count_reg;

        case curr_state is
            when IDLE =>
                rgb_state <= "100"; -- Red
                count_out <= std_logic_vector(to_unsigned(loaded_val, 4));
                
                if load_btn = '1' then
                    next_state <= LOAD;
                elsif start_btn = '1' then
                    next_state <= COUNTDOWN;
                    -- NOTE: preload the counter with the LAST loaded value
                    curr_count_regnext <= loaded_val; 
                end if;
            
            when LOAD =>
                rgb_state <= "010"; -- Green
            
                --First check if switches are valid ie. (0-15) if invalid (when others) load 10 then send back to IDLE state
                if to_integer(unsigned(switches)) > 0 and to_integer(unsigned(switches)) < 16 then
                     loaded_val_next <= to_integer(unsigned(switches));
                else
                     loaded_val_next <= DEFAULT_COUNT;
                end if;
                
                count_out <= std_logic_vector(to_unsigned(loaded_val_next, 4));
                
                -- Design choice: Make LOAD a transient state that AUTO returns to IDLE.
                next_state <= IDLE;

            when COUNTDOWN =>
                rgb_state <= "001"; -- Blue
                count_out <= std_logic_vector(to_unsigned(curr_count_reg, 4));
                
                if curr_count_reg > 0 then
                    curr_count_regnext <= curr_count_reg - 1;
                else -- curr_count_reg is 0
                    next_state <= DONE;
                end if;
            
            when DONE =>
                rgb_state <= "011"; -- Cyan
                count_out <= std_logic_vector(to_unsigned(curr_count_reg, 4)); -- Displays 0
                
                -- AUTO go back to IDLE on the next clock tick
                next_state <= IDLE;

        end case;
    end process;

end Behavioral;
