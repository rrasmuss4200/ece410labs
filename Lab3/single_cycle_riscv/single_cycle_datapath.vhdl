------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : single_cycle_datapath.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Structural implementation of a single-cycle RISC-V datapath.
--                Includes PC, instruction fetch, decode, ALU, memory, and write-back.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY lw_sw_datapath IS
    PORT (
        clock       : IN STD_LOGIC;
        SIG_WR_ENABLE_MEM     : IN STD_LOGIC;
        SIG_WR_ENABLE_REG     : IN STD_LOGIC;
        SIG_ALU_IP_SELECT     : IN STD_LOGIC;
        SIG_RESULT_SELECT     : IN STD_LOGIC;
        SIG_OUTBUF_ENABLE     : IN STD_LOGIC;
        imm_sel      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIG_ALU_OPCODE     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIG_INSTR_OPCODE_REG_IP      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        SIG_FUNCT3_REG_IP      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIG_FUNCT7_REG_IP      : OUT STD_LOGIC;
        zero_flag   : OUT STD_LOGIC;
        out_data   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        SIG_PC_SOURCE : IN STD_LOGIC
    );
END ENTITY;

ARCHITECTURE structural OF lw_sw_datapath IS

    SIGNAL pc, pc_next                      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL instruction, imm_ext, alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rs1_data, rs2_data, rd_data      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL result_mux_o                     : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL alu_mux_o                        : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    
    SIGNAL branch_adder_alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pc_mux_result : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN
    SIG_INSTR_OPCODE_REG_IP   <= instruction(6 DOWNTO 0);
    SIG_FUNCT3_REG_IP   <= instruction(14 DOWNTO 12);
    SIG_FUNCT7_REG_IP   <= instruction(30);

------------------------------------------------------------------------
-- FETCH BLOCK
------------------------------------------------------------------------
    dp_pc : ENTITY work.program_counter(Behavioral)
        PORT MAP(
            clock   => clock,
            pc_out  => pc,
            pc_next => pc_mux_result
        );

    dp_pc_adder : ENTITY work.pc_adder(structural)
        PORT MAP(
            pc_current => pc,
            pc_next    => pc_next
        );

    dp_instr_mem : ENTITY work.instr_mem(rtl)
        PORT MAP(
            address => pc,
            data    => instruction
        );

------------------------------------------------------------------------
-- DECODE BLOCK
------------------------------------------------------------------------
    dp_regfile : ENTITY work.register_file(behavioral)
        PORT MAP(
            clock    => clock,
            rs1_addr => instruction(19 downto 15),
            rs2_addr => instruction(24 downto 20),
            rd_addr  => instruction(11 downto 7),
            rd_data  => result_mux_o,
            rs1_data => rs1_data,
            rs2_data => rs2_data,
            rd_we    => SIG_WR_ENABLE_REG
        );

    -- TODO: Instantiate your immediate extension unit here.
    --       Connect it to the 'instruction(31 DOWNTO 7)' input,
    --       the 'imm_sel' control signal, and drive the 'imm_ext' output.
    
    dp_extension_unit_src : ENTITY work.extension_unit(behavioral)
        PORT MAP(
            instr => instruction(31 DOWNTO 7),
            imm_sel => imm_sel,
           imm_ext => imm_ext
        );

------------------------------------------------------------------------
-- EXECUTE & MEMORY BLOCK
------------------------------------------------------------------------
    dp_alu_src : ENTITY work.mux_2to1(behavioral)
        PORT MAP(
            in0   => rs2_data,
            in1   => imm_ext,
            out_y => alu_mux_o,
            sel   => SIG_ALU_IP_SELECT
        );

    dp_alu : ENTITY work.alu(behavioral)
        PORT MAP(
            src_a     => rs1_data,
            src_b     => alu_mux_o,
            alu_ctrl  => SIG_ALU_OPCODE,
            result    => alu_result,
            zero_flag => zero_flag
        );

    dp_data_mem : ENTITY work.data_mem(rtl)
        PORT MAP(
            clock      => clock,
            address    => alu_result,
            write_data => rs2_data,
            data       => rd_data,
            write_en   => SIG_WR_ENABLE_MEM
        );

------------------------------------------------------------------------
-- WRITE-BACK BLOCK
------------------------------------------------------------------------
    dp_result_src : ENTITY work.mux_2to1(behavioral)
        PORT MAP(
            in0   => alu_result,
            in1   => rd_data,
            out_y => result_mux_o,
            sel   => SIG_RESULT_SELECT
        );

    dp_tri_state_buffer: ENTITY work.tri_state_buffer(Behavioral)
        PORT MAP(
            output_en => SIG_OUTBUF_ENABLE,
            buffer_input => result_mux_o,
            buffer_output=> out_data
        );

------------------------------------------------------------------------
-- PC UPDATE BLOCK
------------------------------------------------------------------------        
    pc_mux : ENTITY work.mux_2to1(behavioral)
        PORT MAP(
            in0   => pc_next,
            in1   => branch_adder_alu_result,
            out_y => pc_mux_result,
            sel   => SIG_PC_SOURCE
        );
        
    branch_adder : ENTITY WORK.adder_32(Behavioral)
        PORT MAP(
            op_a => pc_next,
            op_b => imm_ext,
            sum  => branch_adder_alu_result    
        );

END structural;
