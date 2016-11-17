library ieee;
library Registers;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

ENTITY regBits IS
	GENERIC (length : integer := 8);
	PORT(
		d	: IN   bit_vector(length -1  DOWNTO 0);
		clk	: IN   std_logic;
		q	: OUT  bit_vector(length -1 DOWNTO 0));
END regBits;

ARCHITECTURE a OF regBits IS
signal Qreg : bit_vector(length -1  DOWNTO 0);
BEGIN
reg:PROCESS(clk)
	BEGIN
		IF (Clk = '1' and clk'event) THEN
			Qreg <= d;
		END IF;
	END PROCESS;
q <= Qreg after 1 ns;
END a;




