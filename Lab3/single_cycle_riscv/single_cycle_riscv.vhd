------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : single_cycle_riscv.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Top-level RISC-V CPU combining single-cycle datapath and control logic.
--                Executes basic load, store, and arithmetic instructions.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY single_cycle_riscv IS
    PORT (
        clock     : IN STD_LOGIC;
        out_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE Structural OF single_cycle_riscv IS
    SIGNAL zero_flag                       : STD_LOGIC                     := '0';
    SIGNAL pc, pc_next                     : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL instruction, imm_ext, alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rs1_data, rs2_data, rd_data     : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL SIG_WR_ENABLE_MEM                         : STD_LOGIC;
    SIGNAL SIG_WR_ENABLE_REG                         : STD_LOGIC;
    SIGNAL SIG_FUNCT7_REG_IP                          : STD_LOGIC;
    SIGNAL SIG_ALU_IP_SELECT, SIG_RESULT_SELECT                : STD_LOGIC;
    SIGNAL SIG_FUNCT3_REG_IP                          : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL imm_sel                          : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL SIG_ALU_OPCODE                         : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL SIG_INSTR_OPCODE_REG_IP                          : STD_LOGIC_VECTOR(6 DOWNTO 0);
    signal intermediate_out_buf_en : std_logic := '1';
    SIGNAL SIG_PC_SOURCE : std_logic;

BEGIN

    datapath : ENTITY work.lw_sw_datapath(structural)
        PORT MAP(
            clock       => clock,
            SIG_WR_ENABLE_MEM => SIG_WR_ENABLE_MEM,
            SIG_WR_ENABLE_REG => SIG_WR_ENABLE_REG,
            SIG_ALU_IP_SELECT => SIG_ALU_IP_SELECT,
            SIG_RESULT_SELECT => SIG_RESULT_SELECT,
            SIG_OUTBUF_ENABLE => intermediate_out_buf_en,
            imm_sel => imm_sel,
            SIG_ALU_OPCODE => SIG_ALU_OPCODE,
            SIG_INSTR_OPCODE_REG_IP => SIG_INSTR_OPCODE_REG_IP,
            SIG_FUNCT3_REG_IP => SIG_FUNCT3_REG_IP,
            SIG_FUNCT7_REG_IP => SIG_FUNCT7_REG_IP,
            zero_flag => zero_flag,
            out_data => out_data,
            SIG_PC_SOURCE => SIG_PC_SOURCE
        );

    control_unit : ENTITY work.controller(behavioral)
        PORT MAP(
            SIG_INSTR_OPCODE_REG_IP => SIG_INSTR_OPCODE_REG_IP,
            SIG_FUNCT3_REG_IP => SIG_FUNCT3_REG_IP,
            SIG_FUNCT7_REG_IP => SIG_FUNCT7_REG_IP,
            zero_flag => zero_flag,
            SIG_ALU_IP_SELECT => SIG_ALU_IP_SELECT,
            SIG_RESULT_SELECT => SIG_RESULT_SELECT,
            SIG_WR_ENABLE_MEM => SIG_WR_ENABLE_MEM,
            SIG_WR_ENABLE_REG => SIG_WR_ENABLE_REG,
            SIG_OUTBUF_ENABLE => intermediate_out_buf_en,
            imm_sel => imm_sel,
            SIG_ALU_OPCODE => SIG_ALU_OPCODE,
            SIG_PC_SOURCE => SIG_PC_SOURCE
        );
END Structural;
