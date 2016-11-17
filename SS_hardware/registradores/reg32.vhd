library ieee;
library Registers;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

ENTITY reg32 IS
	GENERIC (length : integer := 8);
	PORT(
		d		: IN   std_logic_vector(length -1  DOWNTO 0);
		clk, WE	: IN   std_logic;
		q		: OUT  std_logic_vector(length -1 DOWNTO 0));
END reg32;

ARCHITECTURE a OF reg32 IS
signal Qreg : std_logic_vector(length -1  DOWNTO 0);
BEGIN
reg:PROCESS(clk)
	BEGIN
		IF (Clk = '1' and clk'event) THEN
			IF WE = '1' THEN
				Qreg <= d;
			END IF;
		END IF;
	END PROCESS;
q <= Qreg after 1 ns;
END a;




