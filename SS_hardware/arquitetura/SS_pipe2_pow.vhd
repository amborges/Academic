library IEEE;
library SegmentedSpline;
library Registers;
--use ieee.float_pkg_c.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity SS_pipe2_pow is
	port(
		clk:     in std_logic;
		vin:  in STD_logic_vector(31 downto 0);
		
		vout: out STD_logic_vector(31 downto 0)
	);
end SS_pipe2_pow; 

architecture ssh of SS_pipe2_pow is 

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
component SS_pipe2_f2i is
	port(
		clk:  in std_logic;
		Vin:  in STD_logic_vector(31 downto 0);
		Vout: out STD_logic_vector(31 downto 0)
	);
end component;
component reg32 is
	generic (length : integer := 32);
	port(
		d		: IN   std_logic_vector(length -1  DOWNTO 0);
		clk, WE	: IN   std_logic;
		q		: OUT  std_logic_vector(length -1 DOWNTO 0)
	);
END component;
component regBits is
	generic (length : integer := 2);
	port(
		d	: IN   bit_vector(length -1  DOWNTO 0);
		clk	: IN   std_logic;
		q	: OUT  bit_vector(length -1 DOWNTO 0)
	);
END component;
component regBit is
	port(
		d  : IN   bit;
		clk: IN   std_logic;
		q  : OUT  bit
	);
END component;
	
	signal pow_add1, pow_add2, pow_add3                               : f32;
	signal ipow_add1, ipow_add2, ipow_add3                               : f32;
	signal pow_add11, pow_add12, pow_add13                               : f32;
	signal pow_sub1, pow_sub2, pow_sub3, pow_sub4, pow_sub5           : f32;
	signal ipow_sub1, ipow_sub2, ipow_sub3, ipow_sub4, ipow_sub5           : f32;
	signal pow_mult1, pow_mult2, pow_mult3                            : f32;
	signal ipow_mult1, ipow_mult2, ipow_mult3                            : f32;
	signal pow_mult11, pow_mult12, pow_mult13, pow_mult14, pow_mult15, pow_mult16, pow_mult17, pow_mult18, pow_mult19, pow_mult110, pow_mult111 : f32;
	signal pow_div1                                                   : f32;
	signal ipow_div1                                                   : f32;
	signal pow_demux1, pow_demux11, pow_demux12, pow_demux13, pow_demux14, pow_demux15, pow_demux16, pow_demux17 : bit;
	signal pow_demux2, pow_demux3, pow_demux4, pow_demux5, pow_demux41             : f32;
	signal ipow_demux2, ipow_demux3, ipow_demux4, ipow_demux5             : f32;
	

	constant zero        : f32 := "00000000000000000000000000000000";
	constant three       : f32 := "01000000010000000000000000000000";
	constant one         : f32 := "00111111100000000000000000000000";
	constant two         : f32 := "01000000000000000000000000000000";
	constant four        : f32 := "01000000100000000000000000000000";
	constant pc2         : f32 := "01000000010101001001101001111000";
	constant five        : f32 := "01000000101000000000000000000000";
	constant six         : f32 := "01000000110000000000000000000000";
	constant seven       : f32 := "01000000111000000000000000000000";
	constant eight       : f32 := "01000001000000000000000000000000";
	constant nine        : f32 := "01000001000100000000000000000000";
	constant ten         : f32 := "01000001001000000000000000000000";
	constant eleven      : f32 := "01000001001100000000000000000000";
	constant twelve      : f32 := "01000001010000000000000000000000";
	constant thirteen    : f32 := "01000001010100000000000000000000";
	constant pc3         : f32 := "01000000100110101111010111111000";
	constant pc4         : f32 := "01000001110111011101001011111110";
	constant pc5         : f32 := "00111111101111101011110010001101";
	constant pc6         : f32 := "01000010111100101000110001010101";
	constant pc7         : f32 := "01001011000000000000000000000000";

begin
	
	-- pow_mult1  <= pow_in * pc2;	
	MLT8: multiplicacao port map (clk => clk, Ain => vin,
								  Bin => pc2, Cout => pow_mult1);
	
	
	RGTR1: reg32 generic map  (length => 32)
				 port map (d => pow_mult1, clk => clk, WE => '1',
						   q => pow_mult12);
						   

	--pow_demux1 <= '1' when (pow_mult1 < zero) else '0';
	pow_demux1 <= '1' when (pow_mult12(31) = '1') else '0';

	
	RGTR2: regBit port map (d => pow_demux1, clk => clk, q => pow_demux12);
	RGTR3: reg32 generic map  (length => 32)
				 port map (d => pow_mult12, clk => clk, WE => '1',
						   q => pow_mult13);
						   

	-- pow_sub1   <= zero - pow_mult1;
	SUB7: subtracao port map (clk => clk, Ain => zero,
							  Bin => pow_mult13, Cout => ipow_sub1);

	
	RGTR4: reg32 generic map  (length => 32)
				 port map (d => ipow_sub1, clk => clk, WE => '1',
						   q => pow_sub1);
	RGTR5: reg32 generic map  (length => 32)
				 port map (d => pow_mult13, clk => clk, WE => '1',
						   q => pow_mult14);
	RGTR6: regBit port map (d => pow_demux12, clk => clk, q => pow_demux13);
	

	ipow_demux2 <= pow_sub1 when (pow_demux13 = '1') else pow_mult14;

		
	RGTR7: reg32 generic map  (length => 32)
				 port map (d => ipow_demux2, clk => clk, WE => '1',
						   q => pow_demux2);
	RGTR8: reg32 generic map  (length => 32)
				 port map (d => pow_mult14, clk => clk, WE => '1',
						   q => pow_mult15);
	RGTR9: regBit port map (d => pow_demux13, clk => clk, q => pow_demux14);
						   

	ipow_demux4 <=   zero   when (pow_demux2 < one)      else
					one    when (pow_demux2 < two)      else
					two    when (pow_demux2 < three)    else
					three  when (pow_demux2 < four)     else
					four   when (pow_demux2 < five)     else
					five   when (pow_demux2 < six)      else
					six    when (pow_demux2 < seven)    else
					seven  when (pow_demux2 < eight)    else
					eight  when (pow_demux2 < nine)     else
					nine   when (pow_demux2 < ten)      else
					ten    when (pow_demux2 < eleven)   else
					eleven when (pow_demux2 < twelve)   else
					twelve when (pow_demux2 < thirteen) else
					thirteen;

					
	RGTR10: reg32 generic map  (length => 32)
				 port map (d => ipow_demux4, clk => clk, WE => '1',
						   q => pow_demux4);
	RGTR11: reg32 generic map  (length => 32)
				 port map (d => pow_mult15, clk => clk, WE => '1',
						   q => pow_mult16);
	RGTR12: regBit port map (d => pow_demux14, clk => clk, q => pow_demux15);
						   

	-- pow_sub2   <= zero - pow_demux4;
	SUB8: subtracao port map (clk => clk, Ain => zero,
							  Bin => pow_demux4, Cout => ipow_sub2);

	
	RGTR13: reg32 generic map  (length => 32)
				 port map (d => ipow_sub2, clk => clk, WE => '1',
						   q => pow_sub2);
	RGTR14: reg32 generic map  (length => 32)
				 port map (d => pow_mult16, clk => clk, WE => '1',
						   q => pow_mult17);
	RGTR15: regBit port map (d => pow_demux15, clk => clk, q => pow_demux16);
	RGTR16: reg32 generic map  (length => 32)
				 port map (d => pow_demux4, clk => clk, WE => '1',
						   q => pow_demux41);
						   

	ipow_demux5 <= pow_sub2 when (pow_demux16 = '1') else pow_demux41;
	
	
	RGTR17: reg32 generic map  (length => 32)
				 port map (d => ipow_demux5, clk => clk, WE => '1',
						   q => pow_demux5);
	RGTR18: reg32 generic map  (length => 32)
				 port map (d => pow_mult17, clk => clk, WE => '1',
						   q => pow_mult18);
	RGTR19: regBit port map (d => pow_demux16, clk => clk, q => pow_demux17);
						   
	
	-- pow_sub3   <= pow_mult1 - pow_demux5;
	SUB9: subtracao port map (clk => clk, Ain => pow_mult18,
							  Bin => pow_demux5, Cout => ipow_sub3);	
	ipow_demux3 <= one when (pow_demux17 = '1') else zero;

	
	RGTR20: reg32 generic map  (length => 32)
				 port map (d => ipow_sub3, clk => clk, WE => '1',
						   q => pow_sub3);
	RGTR21: reg32 generic map  (length => 32)
				 port map (d => ipow_demux3, clk => clk, WE => '1',
						   q => pow_demux3);
	RGTR22: reg32 generic map  (length => 32)
				 port map (d => pow_mult18, clk => clk, WE => '1',
						   q => pow_mult19);
						   
						   
	--pow_add1   <= pow_demux3 + pow_sub3; 
	ADD5: soma port map (clk => clk, Ain => pow_demux3,
						 Bin => pow_sub3, Cout => ipow_add1);
							  
	
	RGTR23: reg32 generic map  (length => 32)
				 port map (d => ipow_add1, clk => clk, WE => '1',
						   q => pow_add1);
	RGTR24: reg32 generic map  (length => 32)
				 port map (d => pow_mult19, clk => clk, WE => '1',
						   q => pow_mult110);
						   
						   
	-- pow_sub4   <= pc3 - pow_add1;
	SUB10: subtracao port map (clk => clk, Ain => pc3,
							   Bin => pow_add1, Cout => ipow_sub4);

	
	RGTR25: reg32 generic map  (length => 32)
				 port map (d => ipow_sub4, clk => clk, WE => '1',
						   q => pow_sub4);
	RGTR26: reg32 generic map  (length => 32)
				 port map (d => pow_mult110, clk => clk, WE => '1',
						   q => pow_mult111);
	RGTR27: reg32 generic map  (length => 32)
				 port map (d => pow_add1, clk => clk, WE => '1',
						   q => pow_add12);
						   
						   
	-- pow_div1   <= pc4 / pow_sub4;
	DVSR3: divisao port map (clk => clk, Ain => pc4,
							 Bin => pow_sub4, Cout => ipow_div1);
	-- pow_add2   <= pc6 + pow_mult1;
	ADD6: soma port map (clk => clk, Ain => pc6,
						 Bin => pow_mult111, Cout => ipow_add2);


	RGTR28: reg32 generic map  (length => 32)
				 port map (d => ipow_div1, clk => clk, WE => '1',
						   q => pow_div1);
	RGTR29: reg32 generic map  (length => 32)
				 port map (d => ipow_add2, clk => clk, WE => '1',
						   q => pow_add2);
	RGTR30: reg32 generic map  (length => 32)
				 port map (d => pow_add12, clk => clk, WE => '1',
						   q => pow_add13);
						   
						   
	-- pow_add3   <= pow_add2 + pow_div1;
	ADD7: soma port map (clk => clk, Ain => pow_add2,
						 Bin => pow_div1, Cout => ipow_add3);
	-- pow_mult2  <= pc5 * pow_add1;
	MLT9: multiplicacao port map (clk => clk, Ain => pc5,
								  Bin => pow_add13, Cout => ipow_mult2);
							   

	RGTR31: reg32 generic map  (length => 32)
				 port map (d => ipow_add3, clk => clk, WE => '1',
						   q => pow_add3);
	RGTR32: reg32 generic map  (length => 32)
				 port map (d => ipow_mult2, clk => clk, WE => '1',
						   q => pow_mult2);
						   
	
	-- pow_sub5   <= pow_add3 - pow_mult2;
	SUB11: subtracao port map (clk => clk, Ain => pow_add3,
							   Bin => pow_mult2, Cout => ipow_sub5);

	
	RGTR33: reg32 generic map  (length => 32)
				 port map (d => ipow_sub5, clk => clk, WE => '1',
						   q => pow_sub5);
						   
							   
	-- pow_mult3  <= pow_sub5 * pc7;
	MLT10: multiplicacao port map (clk => clk, Ain => pow_sub5,
								   Bin => pc7, Cout => ipow_mult3);

								   
	RGTR34: reg32 generic map  (length => 32)
				 port map (d => ipow_mult3, clk => clk, WE => '1',
						   q => pow_mult3);
						   
								   
	F2I: SS_pipe2_f2i port map (clk => clk, vin => pow_mult3, vout => vout);

	
ssh : process (clk)	
	begin
		if rising_edge(clk) then
			
		end if; -- rising_edge(clk)
	end process ssh;
end ssh;
