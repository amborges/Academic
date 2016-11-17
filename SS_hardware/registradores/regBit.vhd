-- MAX+plus II VHDL Example
-- User-Defined Macrofunction
-- Copyright (c) 1994 Altera Corporation

library ieee;
library Registers;
use ieee.std_logic_1164.all;

ENTITY regBit IS
	PORT(
		d	: IN   bit;
		clk : IN   std_logic;
		q   : OUT  bit);
END regBit;

ARCHITECTURE a OF regBit IS
signal QregBit : bit;
BEGIN
regBit:PROCESS(clk)
	BEGIN
		IF (Clk = '1' and clk'event) THEN
			QregBit <= d;
		END IF;
	END PROCESS;
q <= QregBit after 1 ns;
END a;


