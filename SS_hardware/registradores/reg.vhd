-- MAX+plus II VHDL Example
-- User-Defined Macrofunction
-- Copyright (c) 1994 Altera Corporation

library ieee;
library Registers;
use ieee.std_logic_1164.all;

ENTITY reg IS
	PORT(
		d		: IN   std_logic;
		clk, rst, we: IN   std_logic;
		q		: OUT  std_logic);
END reg;

ARCHITECTURE a OF reg IS
signal Qreg : std_logic;
BEGIN
reg:PROCESS(clk)
	BEGIN
		IF (Clk = '1' and clk'event) THEN
			IF RST = '1' THEN
				Qreg <= '0';
			ELSIF WE = '1' THEN
				Qreg <= d;
			END IF;
		END IF;
	END PROCESS;
q <= Qreg after 1 ns;
END a;


