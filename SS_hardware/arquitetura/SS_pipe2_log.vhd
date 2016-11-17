library IEEE;
library IEEE_PROPOSED;
library SegmentedSpline;
library Registers;
--use ieee.float_pkg_c.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use IEEE_PROPOSED.float_pkg.all;

entity SS_pipe2_log is
	port(
		clk:  in std_logic;
		vin:  in STD_logic_vector(31 downto 0);
		
		vout: out STD_logic_vector(31 downto 0)
	);
end SS_pipe2_log; 

architecture ssh of SS_pipe2_log is 

	--type f32 is array (33 downto 0) of STD_logic_vector;
	subtype f32 is STD_logic_vector(31 downto 0);

component soma is
	port(
		clk:  in std_logic;
		Ain:  in STD_logic_vector(31 downto 0);
		Bin:  in STD_logic_vector(31 downto 0);
		Cout: out STD_logic_vector(31 downto 0)
	);
end component;
component subtracao is
	port(
		clk:  in std_logic;
		Ain:  in STD_logic_vector(31 downto 0);
		Bin:  in STD_logic_vector(31 downto 0);
		Cout: out STD_logic_vector(31 downto 0)
	);
end component;
component multiplicacao is
	port(
		clk:  in std_logic;
		Ain:  in STD_logic_vector(31 downto 0);
		Bin:  in STD_logic_vector(31 downto 0);
		Cout: out STD_logic_vector(31 downto 0)
	);
end component;
component divisao is
	port(
		clk:  in std_logic;
		Ain:  in STD_logic_vector(31 downto 0);
		Bin:  in STD_logic_vector(31 downto 0);
		Cout: out STD_logic_vector(31 downto 0)
	);
end component;
component reg32 is
	generic (length : integer := 32);
	port(
		d		: IN   std_logic_vector(length -1  DOWNTO 0);
		clk, WE	: IN   std_logic;
		q		: OUT  std_logic_vector(length -1 DOWNTO 0));
END component;
	
	signal log10_and1: f32;
	signal log10_or1 : f32;
	signal log10_in, log10_out                  : f32;
	signal log10_or2                            : f32;
	signal log10_add1                           : f32;
	signal log10_sub1,  log10_sub2,  log10_sub3 : f32;
	signal log10_mult1, log10_mult2, log10_mult3: f32;
	signal log10_div1                           : f32;
	signal log10_tofloat1                       : f32 := (others => '0');
	signal ilog10_and1: f32;
	signal ilog10_or1 : f32;
	signal ilog10_in, ilog10_out                  : f32;
	signal ilog10_or2                            : f32;
	signal ilog10_add1                           : f32;
	signal ilog10_sub1,  ilog10_sub2,  ilog10_sub3 : f32;
	signal ilog10_mult1, ilog10_mult2, ilog10_mult3: f32;
	signal ilog10_div1                           : f32;
	signal ilog10_tofloat1                       : f32 := (others => '0');
	constant zero        : f32 := "00000000000000000000000000000000";
	constant menorvalor  : f32 := "00111000100000000000000000000000";
	constant mantissa 	 : f32 := "00000000011111111111111111111111";
	constant midexp   	 : f32 := "00111111000000000000000000000000";
	constant yv1         : f32 := "01000010111110000111001101101110";
	constant yv2         : f32 := "00111111101111111011111101110101";
	constant yv3         : f32 := "00111111110111001110100110100011";
	constant yv4         : f32 := "00111110101101000100010011111001";
	constant inv_log2_10 : f32 := "00111110100110100010000010011011";
	constant ymult       : f32 := "00110100000000000000000000000000";


begin
	
		--This line uses to_slv and to_float functions of IEEE_PROPOSED
	ilog10_tofloat1(31 downto 0) <= to_slv(
				to_float2(to_integer(unsigned(vin(31 downto 0)))));			
	ilog10_and1 <= vin and mantissa;
	
	
	RGTR1: reg32 generic map  (length => 32)
				 port map (d => ilog10_tofloat1, clk => clk, WE => '1',
						   q => log10_tofloat1);
	RGTR2: reg32 generic map  (length => 32)
				 port map (d => ilog10_and1, clk => clk, WE => '1',
						   q => log10_and1);
	
	
	ilog10_or1 <= log10_and1 or midexp;
	-- log10_mult2 <= ymult * log10_tofloat1;
	MLT2: multiplicacao port map (clk => clk, Ain => ymult,
								  Bin => log10_tofloat1, Cout => ilog10_mult2);
	
	
	RGTR3: reg32 generic map  (length => 32)
				 port map (d => ilog10_or1, clk => clk, WE => '1',
						   q => log10_or1);
	RGTR4: reg32 generic map  (length => 32)
				 port map (d => ilog10_mult2, clk => clk, WE => '1',
						   q => log10_mult2);
	
	
	-- log10_mult1 <= yv2 * log10_or1;
	MLT1: multiplicacao port map (clk => clk, Ain => yv2,
								  Bin => log10_or1, Cout => ilog10_mult1);
	-- log10_add1 <= yv4 + log10_or1;
	ADD1: soma port map (clk => clk, Ain => yv4,
						 Bin => log10_or1, Cout => ilog10_add1);
	-- log10_sub1 <= log10_mult2 - yv1;
	SUB1: subtracao port map (clk => clk, Ain => log10_mult2,
							  Bin => yv1, Cout => ilog10_sub1);
	
	
	RGTR5: reg32 generic map  (length => 32)
				 port map (d => ilog10_mult1, clk => clk, WE => '1',
						   q => log10_mult1);
	RGTR6: reg32 generic map  (length => 32)
				 port map (d => ilog10_add1, clk => clk, WE => '1',
						   q => log10_add1);
	RGTR7: reg32 generic map  (length => 32)
				 port map (d => ilog10_sub1, clk => clk, WE => '1',
						   q => log10_sub1);
						   
	
	-- log10_div1 <= yv3 / log10_add1;
	DVSR1: divisao port map (clk => clk, Ain => yv3,
							 Bin => log10_add1, Cout => ilog10_div1);
	-- log10_sub2 <= log10_sub1 - log10_mult1;
	SUB2: subtracao port map (clk => clk, Ain => log10_sub1,
							  Bin => log10_mult1, Cout => ilog10_sub2);
	
	
	RGTR8: reg32 generic map  (length => 32)
				 port map (d => ilog10_div1, clk => clk, WE => '1',
						   q => log10_div1);
	RGTR9: reg32 generic map  (length => 32)
				 port map (d => ilog10_sub2, clk => clk, WE => '1',
						   q => log10_sub2);
						   
	
	-- log10_sub3 <= log10_sub2 - log10_div1;
	SUB3: subtracao port map (clk => clk, Ain => log10_sub2,
							  Bin => log10_div1, Cout => ilog10_sub3);
	
	
	RGTR10: reg32 generic map  (length => 32)
				  port map (d => ilog10_sub3, clk => clk, WE => '1',
						    q => log10_sub3);
						   
	
	-- log10_out <= log10_sub3 * inv_log2_10;
	MLT3: multiplicacao port map (clk => clk, Ain => log10_sub3,
								  Bin => inv_log2_10, Cout => vout);

ssh : process (clk)
	
	begin
		if rising_edge(clk) then
			
		end if; -- rising_edge(clk)
	end process ssh;
end ssh;
