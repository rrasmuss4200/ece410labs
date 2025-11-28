------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : data_memory.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : 1 KB data memory with 32-bit read/write interface.
--                Supports synchronous writes and asynchronous reads.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY combined_mem IS
    PORT (
        clock      : IN STD_LOGIC;
        write_en   : IN STD_LOGIC;
        address    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        data       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF combined_mem IS

    -- Byte-addressable RAM
    TYPE memory_data IS ARRAY (0 TO 1023) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL RAM : memory_data := (
        -- Program (little-endian)
        -- 0x0044A303   lw x6, 4(x9)
        0 => x"03", 1 => x"A3", 2 => x"44", 3 => x"00",
        -- 0x0064AA23   sw x6, 20(x9)
        4 => x"23", 5 => x"AA", 6 => x"64", 7 => x"00",
        -- 0x00802103   lw x2, 8(x0)
        8 => x"03", 9 => x"21", 10 => x"C0", 11 => x"00",
        -- 0x00610433   add x8, x2, x6
        12 => x"33", 13 => x"04", 14 => x"61", 15 => x"00",

        -- 0x08010063   beq x2, x1, 128
        16 => x"63", 17 => x"00", 18 => x"01", 19 => x"08",
       
--        -- 0xFE5388E3   beq x5, x7, -10
--        24 => x"E3", 25 => x"88", 26 => x"53", 27 => x"FE",
        
        -- NOP (will be written by the sw instruction)
        20 => x"FF", 21 => x"FF", 22 => x"FF", 23 => x"FF",

        -- 0x00247413   andi x8, x8, 2
        24 => x"13", 25 => x"74", 26 => x"24", 27 => x"00",

        -- 0x00145413   srli x8, x8, 1
        28 => x"13", 29 => x"54", 30 => x"14", 31 => x"00",

--        -- 0xFE744AE3 blt x8, x7, -12 (x8 < x7)
--        32 => x"E3", 33 => x"4A", 34 => x"74", 35 => x"FE",

--        -- 0xFE644AE3 blt x8, x6, -12 (x8 < x6)
--        36 => x"E3", 37 => x"4A", 38 => x"64", 39 => x"FE",
        
        -- x7 = 0  --> Holds our count
        -- x8 = 1  --> Holds a value of 1 (to increment)
        -- x2 = 610433 ---> Holds our test case number
        -- x3       ---> result of ANDi
        -- x4 = 0  --> CONSTANT holds our zero value
        
--        Reg x2 contains -> (610433)16 = (0110 0001 0000 0100 0011 0011)2
        -- we expect an answer of 8, thus x7 = 0x00000008
          -- 0. Initialize x3 to be 0x0000033 this is becasue we ran out of simulation time since each inst. is 3clk cycles
          -- 1. and with 0x1 and store in x3
          -- 2. a) if result (x3) is 1 -> do not branch ie. continue increment our count
--              b) if result (x3) is 0 -> branch to skip ie. do not increment
          -- 3. incremnt the count if (a) by addint reg x8 which holds 1 to x7 which holds our count
          -- 4. Shift the reg x2 which has our test case number
          -- 5. a) if we have shifted all the bits (ie. the end) --> branch to Hault
--              b) if not continue
--           6. a) if we are not done shifting all bits (!= 0) ---> go back to step 1
        
        --init: 
    --        andi x2, x2, 51
        --loop:
        --    andi  x3, x2, 1          # check LSB
        --    beq   x3, x4, 8
        --    add   x7, x7, x8          # count++ note -> x8 holds '1'
        --skip:
        --    srli  x2, x2, 1
        --    beq   x2, x4, 8
        --    beq   x3, x3, -20   # unconditional jump
        --done:
            -- HALT

        -- 0x03317113 andi x2, x2, 51
        32 => x"13", 33 => x"71", 34 => x"31", 35 => x"03",

        -- 0x00117193 andi x3, x2, 1
        36 => x"93", 37 => x"71", 38 => x"11", 39 => x"00",

        -- 0x00418463  beq x3, x4, 8
        40 => x"63", 41 => x"84", 42 => x"41", 43 => x"00",

        -- 0x008383B3  add   x7, x7, x8
        44 => x"B3", 45 => x"83", 46 => x"83", 47 => x"00",
        
        -- 0x00115113  srli  x2, x2, 1
        48 => x"13", 49 => x"51", 50 => x"11", 51 => x"00",
        
        -- 0x00410463  beq   x2, x4, 8
        52 => x"63", 53 => x"04", 54 => x"41", 55 => x"00",
        
        -- 0xFE3186E3  beq   x3, x3, -20
        56 => x"E3", 57 => x"86", 58 => x"31", 59 => x"FE",
        
        -- 0x0000000B HALT
        60 => x"0B", 61 => x"00", 62 => x"00", 63 => x"00",

        OTHERS => (OTHERS => '0')
    );

    SIGNAL addr_int : INTEGER := 0;

BEGIN
    addr_int <= to_integer(unsigned(address(9 DOWNTO 0))); -- Address conversion fits 1 KB

    PROCESS (clock)
    BEGIN
        IF rising_edge(clock) AND write_en = '1' THEN
            RAM(addr_int)     <= write_data(7 DOWNTO 0);
            RAM(addr_int + 1) <= write_data(15 DOWNTO 8);
            RAM(addr_int + 2) <= write_data(23 DOWNTO 16);
            RAM(addr_int + 3) <= write_data(31 DOWNTO 24);
        END IF;
    END PROCESS;

    -- read 4 consecutive bytes form one 32-bit word
    data <= RAM(addr_int + 3) &
        RAM(addr_int + 2) &
        RAM(addr_int + 1) &
        RAM(addr_int);

END ARCHITECTURE rtl;
