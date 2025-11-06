----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Rowan and Yaaqoob
-- 
-- Create Date: 09/24/2025 03:29:25 PM
-- Design Name: 
-- Module Name: bit_scrambler - Behavioral
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

entity extension_unit is
    Port ( instr : in STD_LOGIC_VECTOR (24 downto 0);
           imm_sel : in STD_LOGIC_VECTOR (2 downto 0);
           imm_ext : out STD_LOGIC_VECTOR (31 downto 0));
end extension_unit;

architecture Behavioral of extension_unit is
    constant I_TYPE : std_logic_vector(2 downto 0) := "010";
    constant U_TYPE : std_logic_vector(2 downto 0) := "011";
    constant S_TYPE : std_logic_vector(2 downto 0) := "100";
    constant B_TYPE : std_logic_vector(2 downto 0) := "101";
    constant J_TYPE : std_logic_vector(2 downto 0) := "110";

begin
    scramble : process(instr, imm_sel)
    begin
        if imm_sel = "010" then
            imm_ext(31 downto 12) <= (others => instr(24));
            imm_ext(11 downto 0) <= instr(24 downto 13);
        elsif imm_sel = "011" then
            imm_ext(31 downto 12) <= instr(24 downto 5);
            imm_ext(11 downto 0) <= (others => '0');
        elsif imm_sel = "100" then
            imm_ext(31 downto 12) <= (others => instr(24));
            imm_ext(11 downto 5) <= instr(24 downto 18);
            imm_ext(4 downto 0) <= instr(4 downto 0);
        elsif imm_sel = "101" then
            imm_ext(31 downto 13) <= (others => instr(24));
            imm_ext(12) <= instr(24);
            imm_ext(11) <= instr(0);
            imm_ext(10 downto 5) <= instr(23 downto 18);
            imm_ext(4 downto 1) <= instr(4 downto 1);
            imm_ext(0) <= '0';
        elsif imm_sel = "110" then
            imm_ext(31 downto 21) <= (others => instr(24));
            imm_ext(20) <= instr(24);
            imm_ext(19 downto 12) <= instr(12 downto 5);
            imm_ext(11) <= instr(13);
            imm_ext(10 downto 1) <= instr(23 downto 14);
            imm_ext(0) <= '0';
--        elsif imm_sel = "111" then
--            imm_ext <= (others => '1');
        end if;
    end process;


end Behavioral;
