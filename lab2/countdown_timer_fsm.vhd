library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity countdown_timer_fsm is
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
end countdown_timer_fsm;

architecture Behavioral of countdown_timer_fsm is

    type state_type is (IDLE, LOAD, COUNTING, DONE_STATE);
    signal current_state, next_state : state_type;

    signal count_reg      : unsigned(3 downto 0);  -- Current count register
    signal loaded_value   : unsigned(3 downto 0);  -- Stored loaded value
    signal count_next     : unsigned(3 downto 0);  -- Next count value
    signal loaded_val_next: unsigned(3 downto 0);  -- Next loaded value

    constant DEFAULT_COUNT : unsigned(3 downto 0) := to_unsigned(10, 4);

begin

    -- Asynchronous reset and synchronous state register process
    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= IDLE;
            count_reg <= (others => '0');
            loaded_value <= DEFAULT_COUNT;

        elsif rising_edge(clk) then
            -- Synchronous updates
            current_state <= next_state;
            count_reg <= count_next;
            loaded_value <= loaded_val_next;
        end if;
    end process;

    -- Next state logic and datapath logic
    process(current_state, load_btn, start_btn, clk_en_1hz, count_reg,
            loaded_value, switches)
    begin
        next_state <= current_state;
        count_next <= count_reg;
        loaded_val_next <= loaded_value;

        case current_state is

            when IDLE =>
                if load_btn = '1' then
                    next_state <= LOAD;

                elsif start_btn = '1' then
                    count_next <= loaded_value;
                    next_state <= COUNTING;
                end if;

            when LOAD =>
                -- Sample switches and store value
                if unsigned(switches) = 0 then
                    loaded_val_next <= DEFAULT_COUNT;
                else
                    loaded_val_next <= unsigned(switches);
                end if;

                -- Return to IDLE after loading
                next_state <= IDLE;

            when COUNTING =>
                -- Decrement counter at 1 Hz rate
                if clk_en_1hz = '1' then
                    if count_reg = 1 then
                        -- Reached zero, transition to done
                        count_next <= (others => '0');
                        next_state <= DONE_STATE;
                    else
                        -- Continue counting down
                        count_next <= count_reg - 1;
                    end if;
                end if;

            when DONE_STATE =>
                -- Countdown complete, wait for new command
                if load_btn = '1' then
                    -- Load new value
                    next_state <= LOAD;

                elsif start_btn = '1' then
                    -- Restart with current loaded value
                    count_next <= loaded_value;
                    next_state <= COUNTING;
                end if;

            when others =>
                next_state <= IDLE;

        end case;
    end process;

    -- Output logic (Moore machine - outputs depend only on state)
    process(current_state, count_reg, loaded_value)
    begin
        -- Default outputs
        done <= '0';

        case current_state is
            when IDLE =>
                count_out <= std_logic_vector(loaded_value);  -- Show loaded value

            when LOAD =>
                count_out <= std_logic_vector(loaded_value);  -- Show previous value during load

            when COUNTING =>
                count_out <= std_logic_vector(count_reg);

            when DONE_STATE =>
                count_out <= (others => '0');
                done <= '1';

            when others =>
                count_out <= (others => '0');
        end case;
    end process;

end Behavioral;