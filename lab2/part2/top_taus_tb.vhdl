----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2025 04:39:50 PM
-- Design Name: 
-- Module Name: top_taus_tb - Behavioral
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

entity top_taus_tb is
end top_taus_tb;

architecture Behavioral of top_taus_tb is
signal clk : std_logic;
signal out_0 : std_logic_vector(31 downto 0);
signal out_1 : std_logic_vector(31 downto 0);
signal out_2 : std_logic_vector(31 downto 0);
signal dout_s : std_logic_vector(31 downto 0);
begin
    PRNG_1         : ENTITY work.top_taus(Behavioral) GENERIC MAP (C=>X"FFFFFFFE", S1=>13, S2=>19, S3=>12) PORT MAP(clk=>clk, taus_out=>out_0);
	PRNG_2         : ENTITY work.top_taus(Behavioral) GENERIC MAP (C=>X"FFFFFFF8", S1=>2, S2=>25, S3=>4) PORT MAP(clk=>clk, taus_out=>out_1);
	PRNG_3         : ENTITY work.top_taus(Behavioral) GENERIC MAP (C=>X"FFFFFFF0", S1=>3, S2=>11, S3=>17) PORT MAP(clk=>clk, taus_out=>out_2);

    dout_s <= out_0 xor out_1 xor out_2;
    
    clk_proc : process
    begin
        loop
            
            wait for 10ns;
            clk <= '0';
            wait for 10ns;
            clk <= '1';
        end loop;
    end process;
end Behavioral;
