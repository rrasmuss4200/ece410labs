----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
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
    clk: in std_logic;
    reset: in std_logic;
    switches: in std_logic_vector(3 downto 0);
    start_btn: in std_logic;
    load_btn: in std_logic;
    
    clk_en_1hz: in std_logic;
    
    count_out: out std_logic_vector(3 downto 0);
    done_out: out std_logic
  );
end countdown_timer_fsm;


architecture Behavioral of countdown_timer_fsm is

    type state_type is (IDLE, LOAD, COUNTDOWN, DONE);
    signal curr_state, next_state : state_type;
    signal curr_count_reg : INTEGER := 10;
    
    signal loaded_val : INTEGER := 10;
    constant DEFAULT_COUNT : INTEGER := 10;
    

begin
    -- This process handles async reset and Updates the (next) State
    process (clk, reset) is 
    begin
        if reset = '1' then
            curr_state <= IDLE;
--            curr_count_reg <= 0;
--            loaded_val <= DEFAULT_COUNT;
            done_out <= '0';
        elsif rising_edge(clk) then
            curr_state <= next_state;
        end if;
    end process;
            

    -- Process that handles logic for each data path
    process (curr_state, next_state, loaded_val, curr_count_reg, clk_en_1hz) is
    begin
        
        case curr_state is
            when IDLE =>
                if load_btn = '1' then
                    next_state <= LOAD;
                elsif start_btn = '1' then
                    -- if start is pressed go to count down, the loaded_val is default to 10 or already loaded
                    next_state <= COUNTDOWN;
                end if;
                
    
            when LOAD =>
            --First check if switches are valid ie. (0-15) if invalid (when others) load 10 then send back to IDLE state
                if to_integer(unsigned(switches)) > -1 and to_integer(unsigned(switches)) < 16 then
                    loaded_val <= to_integer(unsigned(switches));
                else
                    loaded_val <= DEFAULT_COUNT;
                end if;
                curr_count_reg <= loaded_val;
                next_state <= IDLE;
                
            when COUNTDOWN =>
                if clk_en_1hz = '1' then
                    if curr_count_reg = 0 then
                        next_state <= DONE;
                    else
                        curr_count_reg <= curr_count_reg - 1;
                    end if;
                end if;
            when DONE =>
                done_out <= '1';
                next_state <= IDLE;
            
        end case;
    end process;
    
    process (curr_state) is
    begin
        case curr_state is
            when IDLE =>
                count_out <= std_logic_vector(to_unsigned(loaded_val, 4));
            when LOAD =>
                count_out <= std_logic_vector(to_unsigned(loaded_val, 4));
            when COUNTDOWN =>
                count_out <= std_logic_vector(to_unsigned(curr_count_reg, 4));
            when DONE =>
                count_out <= std_logic_vector(to_unsigned(curr_count_reg, 4));
        end case;
    end process;

end Behavioral;
