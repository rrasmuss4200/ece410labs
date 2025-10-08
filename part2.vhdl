----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2025 04:06:11 PM
-- Design Name: 
-- Module Name: top_taus - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_taus is
generic ( C : STD_LOGIC_VECTOR (31 downto 0);
S1 : INTEGER;
S2 : INTEGER;
S3 : INTEGER
);
    Port ( clk : in STD_LOGIC;
           taus_out : out STD_LOGIC_VECTOR (31 downto 0));
end top_taus;

architecture Behavioral of top_taus is

signal reg : std_logic_vector(31 downto 0) := (others => '1');
signal reg_after_s1 : std_logic_vector(31 downto 0);
signal after_first_xor : std_logic_vector(31 downto 0);
signal after_and : std_logic_vector(31 downto 0);

signal rhs_result : std_logic_vector(31 downto 0);
signal lhs_result : std_logic_vector(31 downto 0);

begin

process (clk) is
begin
    -- Right side: shift_left( and(reg, 'C' ) )
    after_and <= C and reg;
    rhs_result <= std_logic_vector(shift_left(unsigned(after_and), S3));
    
    
    -- Left Side: xor(reg, shift(reg) )
    reg_after_s1 <= std_logic_vector(shift_left(unsigned(reg), S1));
    after_first_xor <= reg_after_s1 xor reg;
    lhs_result <= std_logic_vector(shift_right(unsigned(after_first_xor), S2));
    
    -- Result:
    taus_out <= lhs_result xor rhs_result;
    
    if rising_edge(clk) then
        reg <= lhs_result xor rhs_result;
    end if;

end process;



end Behavioral;
