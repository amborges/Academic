library IEEE;
library SegmentedSpline;
--use ieee.float_pkg_c.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity SS_pipe2_prelog is
	port(
		clk:     in std_logic;
		vin:  in STD_logic_vector(31 downto 0);
		
		vout: out STD_logic_vector(31 downto 0)
	);
end SS_pipe2_prelog;

architecture ssh of SS_pipe2_prelog is 

	subtype f32 is STD_logic_vector(31 downto 0);
	constant zero : f32 := "00000000000000000000000000000000";
	constant menorvalor : f32 := "00111000100000000000000000000000";

begin
	
	vout <= menorvalor when (vin(31) = '1') else
			menorvalor when (vin = zero) else
			vin;
	
ssh : process (clk)
		
	begin
		if rising_edge(clk) then
			
		end if; -- rising_edge(clk)
	end process ssh;
end ssh;
