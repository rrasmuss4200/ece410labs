------------------------------------------------------------------------                                                                                                                          
-- University  : University of Alberta                                                                                                                                                            
-- Course      : ECE 410                                                                                                                                                                          
-- Project     : Lab 3                                                                                                                                                                            
-- File        : single_cycle_controller.vhdl                                                                                                                                                     
-- Authors     : Antonio Alejandro Andara Lara                                                                                                                                                    
-- Date        : 23-Oct-2025                                                                                                                                                                      
------------------------------------------------------------------------                                                                                                                          
-- Description  : Single-cycle control unit for a simple RISC-V processor.                                                                                                                        
--                Decodes opcode, funct3, and funct7 fields to generate                                                                                                                           
--                ALU, memory, and register control signals.                                                                                                                                      
------------------------------------------------------------------------                                                                                                                          
                                                                                                                                                                                                  
LIBRARY IEEE;                                                                                                                                                                                     
USE IEEE.STD_LOGIC_1164.ALL;                                                                                                                                                                      
USE IEEE.NUMERIC_STD.ALL;                                                                                                                                                                         
                                                                                                                                                                                                  
ENTITY controller IS                                                                                                                                                                              
    PORT (                                                                                                                                                                                        
        SIG_INSTR_OPCODE_REG_IP    : IN STD_LOGIC_VECTOR(6 DOWNTO 0);                                                                                                                             
        SIG_FUNCT3_REG_IP    : IN STD_LOGIC_VECTOR(2 DOWNTO 0);                                                                                                                                   
        SIG_FUNCT7_REG_IP    : IN STD_LOGIC;                                                                                                                                                      
        zero_flag : IN STD_LOGIC;                                                                                                                                                                 
        SIG_ALU_IP_SELECT   : OUT STD_LOGIC;                                                                                                                                                      
        SIG_RESULT_SELECT   : OUT STD_LOGIC;                                                                                                                                                      
        SIG_WR_ENABLE_MEM   : OUT STD_LOGIC;                                                                                                                                                      
        SIG_WR_ENABLE_REG   : OUT STD_LOGIC;                                                                                                                                                      
        SIG_OUTBUF_ENABLE : OUT STD_LOGIC;                                                                                                                                                        
        imm_sel    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);                                                                                                                                            
        SIG_ALU_OPCODE   : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);                                                                                                                                      
        SIG_PC_SOURCE : OUT STD_LOGIC                                                                                                                                                             
    );                                                                                                                                                                                            
END controller;                                                                                                                                                                                   
                                                                                                                                                                                                  
ARCHITECTURE Behavioral OF controller IS                                                                                                                                                          
    -- "controls" is a compact control word encoding all the main control signals.                                                                                                                
    -- Bit mapping (from MSB to LSB):                                                                                                                                                             
    --   [10]  - PC Source                                                                                                                                                                        
    --   [9]   - Selects ALU B operand source (0 = register, 1 = immediate)                                                                                                                       
    --   [8]   - Selects write-back data source (0 = ALU result, 1 = memory read)                                                                                                                 
    --   [7]   - Enables register file write                                                                                                                                                      
    --   [6]   - Enables data memory write                                                                                                                                                        
    --   [5:3] - Selects immediate format depending on the instruction type (I, S, B, etc.)                                                                                                       
    --   [2:0] - ALU control operation code                                                                                                                                                       
    --                                                                                                                                                                                            
    -- Each instruction assigns a 10-bit pattern to "controls" that defines its                                                                                                                   
    -- full control behavior in a single line using the WITH-SELECT statement below.                                                                                                              
    SIGNAL controls     : STD_LOGIC_VECTOR(9 DOWNTO 0); --groups the control bits into one signal                                                                                                 
                                                                                                                                                                                                  
    -- added for visibility in simulation                                                                                                                                                         
    TYPE instruction IS (LW, SW, ADD, NOP, BEQ);                                                                                                                                                  
    SIGNAL instr : instruction := NOP;                                                                                                                                                            
    SIGNAL aux          : STD_LOGIC_VECTOR(10 DOWNTO 0);                                                                                                                                          
                                                                                                                                                                                                  
    -- Instruction opcodes. add new values for each instruction                                                                                                                                   
    CONSTANT OPCODE_LW  : STD_LOGIC_VECTOR(6 DOWNTO 0)  := "0000011";                                                                                                                             
    CONSTANT OPCODE_SW  : STD_LOGIC_VECTOR(6 DOWNTO 0)  := "0100011";                                                                                                                             
    CONSTANT OPCODE_ADD : STD_LOGIC_VECTOR(6 DOWNTO 0)  := "0110011";                                                                                                                             
    CONSTANT OPCODE_BEQ : STD_LOGIC_VECTOR(6 DOWNTO 0)  := "1100011";                                                                                                                             
                                                                                                                                                                                                  
    -- Control signals per instruction                                                                                                                                                            
    CONSTANT CTRL_LW  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01110010100";                                                                                                                           
    CONSTANT CTRL_SW  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01101011100";                                                                                                                           
    CONSTANT CTRL_ADD : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00010011100";                                                                                                                           
    CONSTANT CTRL_NOP : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000000";                                                                                                                           
    CONSTANT CTRL_BEQ : STD_LOGIC_VECTOR(10 DOWNTO 0) := "11000101101"; --                                                                                                                        
                                                                                                                                                                                                  
BEGIN                                                                                                                                                                                             
    SIG_OUTBUF_ENABLE <= '1';                                                                                                                                                                     
    aux <= SIG_FUNCT7_REG_IP & SIG_FUNCT3_REG_IP & SIG_INSTR_OPCODE_REG_IP;                                                                                                                       
                                                                                                                                                                                                  
    decode : PROCESS (SIG_INSTR_OPCODE_REG_IP, SIG_FUNCT3_REG_IP, SIG_FUNCT7_REG_IP)                                                                                                              
    BEGIN                                                                                                                                                                                         
        controls <= CTRL_NOP;                                                                                                                                                                     
--        CASE op_code IS                                                                                                                                                                         
        CASE SIG_INSTR_OPCODE_REG_IP IS                                                                                                                                                           
            WHEN OPCODE_LW =>                                                                                                                                                                     
                instr <= LW;                                                                                                                                                                      
                controls <= CTRL_LW;                                                                                                                                                              
            WHEN OPCODE_SW =>                                                                                                                                                                     
                instr <= SW;                                                                                                                                                                      
                controls <= CTRL_SW;                                                                                                                                                              
            WHEN OPCODE_ADD =>                                                                                                                                                                    
                IF SIG_FUNCT3_REG_IP = "000" AND SIG_FUNCT7_REG_IP = '0' THEN                                                                                                                     
                    instr <= ADD;                                                                                                                                                                 
                    controls <= CTRL_ADD;                                                                                                                                                         
                END IF;                                                                                                                                                                           
            WHEN OPCODE_BEQ =>                                                                                                                                                                    
                -- put beq here                                                                                                                                                                   
                IF zero_flag = '1' then                                                                                                                                                           
                    instr <= BEQ;                                                                                                                                                                 
                    controls <= CTRL_BEQ;                                                                                                                                                         
                ELSE                                                                                                                                                                              
                    controls <= '0' & CTRL_BEQ( 9 downto 0);  -- Change the pc sourece to 0                                                                                                       
                END IF;                                                                                                                                                                           
                                                                                                                                                                                                  
            WHEN OTHERS =>                                                                                                                                                                        
                instr <= NOP;                                                                                                                                                                     
                controls <= CTRL_NOP;                                                                                                                                                             
        END CASE;                                                                                                                                                                                 
    END PROCESS;                                                                                                                                                                                  
                                                                                                                                                                                                  
    -- controller output assignments                                                                                                                                                              
    SIG_ALU_IP_SELECT <= controls(9);                                                                                                                                                             
    SIG_RESULT_SELECT <= controls(8);                                                                                                                                                             
    SIG_WR_ENABLE_REG <= controls(7);                                                                                                                                                             
    SIG_WR_ENABLE_MEM <= controls(6);                                                                                                                                                             
    imm_sel  <= controls(5 DOWNTO 3);                                                                                                                                                             
    SIG_ALU_OPCODE <= controls(2 DOWNTO 0);                                                                                                                                                       
    SIG_PC_SOURCE <= controls(10);                                                                                                                                                                
                                                                                                                                                                                                  
END Behavioral;                                                                                                                                                                                   
                                                                                                                                                                                                  
