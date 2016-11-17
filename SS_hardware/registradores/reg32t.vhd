library ieee;
library Registers;
use ieee.std_logic_1164.all;

ENTITY reg32t IS
	GENERIC (length : integer := 32);
	PORT(
		d		: IN   std_logic_vector(length -1  DOWNTO 0);
		clk, WE	: IN   std_logic;
		q		: OUT  std_logic_vector(length -1 DOWNTO 0));
END reg32t;

ARCHITECTURE a OF reg32t is
BEGIN
Q <= D;
END a;


