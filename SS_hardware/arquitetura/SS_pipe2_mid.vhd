library IEEE;
library SegmentedSpline;
library Registers;
--use ieee.float_pkg_c.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity SS_pipe2_mid is
	port(
		clk:  in std_logic;
		vin:  in STD_logic_vector(31 downto 0);
		
		vout: out STD_logic_vector(31 downto 0)
	);
end SS_pipe2_mid; 

architecture ssh of SS_pipe2_mid is 

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

	signal pre_menorzero : bit;
	signal pre_numerador, pre_denominador, pre_p0_0, pre_p0_1, pre_p0_2, pre_p0_3, pre_p1_0, pre_p1_1, pre_p1_2, pre_p1_3, pre_p2_0, pre_p2_1, pre_p2_2, pre_p2_3 : f32;
	signal mid_add1, mid_add2, mid_add3              : f32;
	signal mid_sub1, mid_sub2, mid_sub3              : f32;
	signal mid_mult1,mid_mult2, mid_mult3, mid_mult4 : f32;
	signal mid_div1                                  : f32;
	signal mid_demux1                                : f32;
	signal mid_p0, mid_p1, mid_p2                    : f32;
	signal mid_id2b : bit_vector(1 downto 0);
	signal prepow, pow_in : f32;
	signal compare1, compare5, compare6 : f32;
	
	signal ipre_menorzero : bit; 
	signal ipre_numerador, ipre_denominador, ipre_p0_0, ipre_p0_1, ipre_p0_2, ipre_p0_3, ipre_p1_0, ipre_p1_1, ipre_p1_2, ipre_p1_3, ipre_p2_0, ipre_p2_1, ipre_p2_2, ipre_p2_3 : f32;
	signal imid_add1, imid_add2, imid_add3              : f32;
	signal mid_sub11, mid_sub21, mid_sub31              : f32;
	signal imid_sub1, imid_sub2, imid_sub3              : f32;
	signal imid_mult1,imid_mult2, imid_mult3, imid_mult4 : f32;
	signal imid_div1                                  : f32;
	signal mid_div12, mid_div13                       : f32;
	signal imid_demux1, mid_demux12                   : f32;
	signal imid_p0, imid_p1, imid_p2                    : f32;
	signal imid_id2b : bit_vector(1 downto 0);
	signal iprepow, ipow_in : f32;
	signal icompare1, icompare5, icompare6 : f32;
	signal vin1, vin2, vin3, vin4, vin5, vin6, vin7, vin8, vin9, vin10, vin11, vin12, vin13 : f32;
	signal mid_id2b1, mid_id2b2, mid_id2b3, mid_id2b4 : bit_vector(1 downto 0);
	signal pre_menorzero1, pre_menorzero2, pre_menorzero3, pre_menorzero4, pre_menorzero5, pre_menorzero6, pre_menorzero7, pre_menorzero8, pre_menorzero9 : bit;

	
	constant zero        : f32 := "00000000000000000000000000000000";
	constant menorvalor  : f32 := "00111000100000000000000000000000";
	constant numLow      : f32 := "01000000101010000101001101100000";
	constant denLow      : f32 := "01000000100100000111111010010001";
	constant three       : f32 := "01000000010000000000000000000000";
	constant one         : f32 := "00111111100000000000000000000000";
	constant two         : f32 := "01000000000000000000000000000000";
	constant dot_five    : f32 := "00111111000000000000000000000000";
	constant numHigh     : f32 := "00111111001111101010011001110110";
	constant denHigh     : f32 := "01000000101011010110010010101110";
	constant p0_0l       : f32 := "00111110110101111011011000101100";
	constant p1_0l       : f32 := "10111111110010100001001001110101";
	constant p2_0l       : f32 := "11000000000000000000000000000000";
	constant p0_1l       : f32 := "00111111011010100010110100101000";
	constant p1_1l       : f32 := "00111111000110011001100110000000";
	constant p2_1l       : f32 := "11000000000000000000000000000000";
	constant p0_2l       : f32 := "10111110001011011010010001001100";
	constant p1_2l       : f32 := "01000000011001100010010010111111";
	constant p2_2l       : f32 := "10111111110010100001001001110101";
	constant p0_3l       : f32 := "10111111100101010100111110010100";
	constant p1_3l       : f32 := "01000000010100000111000000110110";
	constant p2_3l       : f32 := "10111110011110000111001010110000";
	constant p0_0h       : f32 := "10111111000110110011001010111000";
	constant p1_0h       : f32 := "01000000100101000100011011001010";
	constant p2_0h       : f32 := "10111110101101111111001011000111";
	constant p0_1h       : f32 := "10111111001000001010101011111000";
	constant p1_1h       : f32 := "01000000011001011001001011110001";
	constant p2_1h       : f32 := "00111111100001010010111110011011";
	constant p0_2h       : f32 := "10111110001010011110101110100000";
	constant p1_2h       : f32 := "01000000000101010011110101110100";
	constant p2_2h       : f32 := "00111111111010101100001010001100";
	constant p0_3h       : f32 := "00000000000000000000000000000000";
	constant p1_3h       : f32 := "01000000000000000000000000000000";
	constant p2_3h       : f32 := "01000000000000000000000000000000";
	constant lessvalue   : f32 := "11000000101010000101001101100000";
	constant minusfour   : f32 := "11000000100000000000000000000000";
	constant midvalue    : f32 := "10111111001111101010011001110110";
	constant highvalue   : f32 := "01000000100101011000111111011111";
	constant four        : f32 := "01000000100000000000000000000000";
	constant pc2         : f32 := "01000000010101001001101001111000";

begin
		
	-- compare1 <= log10_out < midvalue
	CMP1: subtracao port map (clk => clk, Ain => vin,
							  Bin => midvalue, Cout => icompare1);
	
	
	RGTR1: reg32 generic map  (length => 32)
				 port map (d => icompare1, clk => clk, WE => '1',
						   q => compare1);
	RGTR2: reg32 generic map  (length => 32)
				 port map (d => vin, clk => clk, WE => '1',
						   q => vin1);
	
	
	pre_menorzero   <= '0'    when (compare1(31) = '1')   else '1';
	
	
	RGTR3: reg32 generic map  (length => 32)
				 port map (d => vin1, clk => clk, WE => '1',
						   q => vin2);
	RGTR4: regBit port map (d => pre_menorzero, clk => clk, q => pre_menorzero1);
						   
	
	ipre_numerador   <= numLow when(pre_menorzero1 = '0') else numHigh;
	
	
	RGTR5: reg32 generic map  (length => 32)
				 port map (d => ipre_numerador, clk => clk, WE => '1',
						   q => pre_numerador);
	RGTR6: reg32 generic map  (length => 32)
				 port map (d => vin2, clk => clk, WE => '1',
						   q => vin3);
	RGTR6_1: regBit port map (d => pre_menorzero1, clk => clk, q => pre_menorzero2);
	
	
	-- mid_add1 <= log10_out + pre_numerador;
	ADD1: soma port map (clk => clk, Ain => vin3,
						 Bin => pre_numerador, Cout => imid_add1);
	
	
	RGTR7: reg32 generic map  (length => 32)
				 port map (d => imid_add1, clk => clk, WE => '1',
						   q => mid_add1);
	RGTR8: reg32 generic map  (length => 32)
				 port map (d => vin3, clk => clk, WE => '1',
						   q => vin4);
	RGTR9: regBit port map (d => pre_menorzero2, clk => clk, q => pre_menorzero3);
						   
	
	-- mid_mult1  <= mid_add1 * three;
	MLT4: multiplicacao port map (clk => clk, Ain => mid_add1,
								  Bin => three, Cout => imid_mult1);
	ipre_denominador <= denLow when(pre_menorzero3 = '0') else denHigh;
	
	
	RGTR10: reg32 generic map  (length => 32)
				 port map (d => imid_mult1, clk => clk, WE => '1',
						   q => mid_mult1);
	RGTR11: reg32 generic map  (length => 32)
				 port map (d => ipre_denominador, clk => clk, WE => '1',
						   q => pre_denominador);
	RGTR12: reg32 generic map  (length => 32)
				 port map (d => vin4, clk => clk, WE => '1',
						   q => vin5);
	RGTR13: regBit port map (d => pre_menorzero3, clk => clk, q => pre_menorzero4);
						   
	
	-- mid_div1   <= mid_mult1 / pre_denominador;
	DVSR2: divisao port map (clk => clk, Ain => mid_mult1,
							 Bin => pre_denominador, Cout => imid_div1);
	
	
	RGTR14: reg32 generic map  (length => 32)
				 port map (d => imid_div1, clk => clk, WE => '1',
						   q => mid_div1);
	RGTR15: reg32 generic map  (length => 32)
				 port map (d => vin5, clk => clk, WE => '1',
						   q => vin6);
	RGTR16: regBit port map (d => pre_menorzero4, clk => clk, q => pre_menorzero5);
						   
						   
	-- mid_sub1 <= mid_div1 - one
	SUB4: subtracao port map (clk => clk, Ain => mid_div1,
							  Bin => one, Cout => imid_sub1);
	-- mid_sub2   <= mid_div1 - two;
	SUB5: subtracao port map (clk => clk, Ain => mid_div1,
							  Bin => two, Cout => imid_sub2);
	-- mid_sub3   <= mid_div1 - three;
	SUB6: subtracao port map (clk => clk, Ain => mid_div1,
							  Bin => three, Cout => imid_sub3);
	
	
	RGTR17: reg32 generic map  (length => 32)
				 port map (d => imid_sub1, clk => clk, WE => '1',
						   q => mid_sub1);
	RGTR18: reg32 generic map  (length => 32)
				 port map (d => imid_sub2, clk => clk, WE => '1',
						   q => mid_sub2);
	RGTR19: reg32 generic map  (length => 32)
				 port map (d => imid_sub3, clk => clk, WE => '1',
						   q => mid_sub3);
	RGTR20: reg32 generic map  (length => 32)
				 port map (d => vin6, clk => clk, WE => '1',
						   q => vin7);
	RGTR21: regBit port map (d => pre_menorzero5, clk => clk, q => pre_menorzero6);
	RGTR22: reg32 generic map  (length => 32)
				 port map (d => mid_div1, clk => clk, WE => '1',
						   q => mid_div12);
						   

	mid_id2b <= "00" when (mid_sub1(31) = '1') else
				"01" when (mid_sub2(31) = '1') else
				"10" when (mid_sub3(31) = '1') else
				"11";
	
	
	RGTR23: regBits generic map  (length => 2)
				 port map (d => mid_id2b, clk => clk, q => mid_id2b1);
	RGTR24: reg32 generic map  (length => 32)
				 port map (d => vin7, clk => clk, WE => '1',
						   q => vin8);
	RGTR26: regBit port map (d => pre_menorzero6, clk => clk, q => pre_menorzero7);
	RGTR27: reg32 generic map  (length => 32)
				 port map (d => mid_div12, clk => clk, WE => '1',
						   q => mid_div13);
	RGTR28: reg32 generic map  (length => 32)
				 port map (d => imid_sub1, clk => clk, WE => '1',
						   q => mid_sub11);
	RGTR29: reg32 generic map  (length => 32)
				 port map (d => imid_sub2, clk => clk, WE => '1',
						   q => mid_sub21);
	RGTR30: reg32 generic map  (length => 32)
				 port map (d => imid_sub3, clk => clk, WE => '1',
						   q => mid_sub31);
						   
	
	imid_demux1 <= mid_div13 when (mid_id2b1 = "00") else
				  mid_sub11 when (mid_id2b1 = "01") else
				  mid_sub21 when (mid_id2b1 = "10") else
				  mid_sub31;
	ipre_p0_0 <= p0_0l when(pre_menorzero7 = '0') else p0_0h;
	ipre_p0_1 <= p0_1l when(pre_menorzero7 = '0') else p0_1h;
	ipre_p0_2 <= p0_2l when(pre_menorzero7 = '0') else p0_2h;
	ipre_p0_3 <= p0_3l when(pre_menorzero7 = '0') else p0_3h;
	ipre_p1_0 <= p1_0l when(pre_menorzero7 = '0') else p1_0h;
	ipre_p1_1 <= p1_1l when(pre_menorzero7 = '0') else p1_1h;
	ipre_p1_2 <= p1_2l when(pre_menorzero7 = '0') else p1_2h;
	ipre_p1_3 <= p1_3l when(pre_menorzero7 = '0') else p1_3h;
	
	
	RGTR31: reg32 generic map  (length => 32)
				 port map (d => imid_demux1, clk => clk, WE => '1',
						   q => mid_demux1);
	RGTR32: reg32 generic map  (length => 32)
				 port map (d => ipre_p0_0, clk => clk, WE => '1',
						   q => pre_p0_0);
	RGTR33: reg32 generic map  (length => 32)
				 port map (d => ipre_p0_1, clk => clk, WE => '1',
						   q => pre_p0_1);
	RGTR34: reg32 generic map  (length => 32)
				 port map (d => ipre_p0_2, clk => clk, WE => '1',
						   q => pre_p0_2);
	RGTR35: reg32 generic map  (length => 32)
				 port map (d => ipre_p0_3, clk => clk, WE => '1',
						   q => pre_p0_3);
	RGTR36: reg32 generic map  (length => 32)
				 port map (d => ipre_p1_0, clk => clk, WE => '1',
						   q => pre_p1_0);
	RGTR37: reg32 generic map  (length => 32)
				 port map (d => ipre_p1_1, clk => clk, WE => '1',
						   q => pre_p1_1);
	RGTR38: reg32 generic map  (length => 32)
				 port map (d => ipre_p1_2, clk => clk, WE => '1',
						   q => pre_p1_2);
	RGTR39: reg32 generic map  (length => 32)
				 port map (d => ipre_p1_3, clk => clk, WE => '1',
						   q => pre_p1_3);
	RGTR40: reg32 generic map  (length => 32)
				 port map (d => vin8, clk => clk, WE => '1',
						   q => vin9);
	RGTR41: regBits generic map  (length => 2)
				 port map (d => mid_id2b1, clk => clk, q => mid_id2b2);
	RGTR42: regBit port map (d => pre_menorzero7, clk => clk, q => pre_menorzero8);
						   
	
	--mid_mult2  <= mid_demux1 * mid_demux1;
	MLT5: multiplicacao port map (clk => clk, Ain => mid_demux1,
								  Bin => mid_demux1, Cout => imid_mult2);
	imid_p0     <= pre_p0_0 when (mid_id2b2 = "00") else
				  pre_p0_1 when (mid_id2b2 = "01") else
				  pre_p0_2 when (mid_id2b2 = "10") else
				  pre_p0_3;
	imid_p1     <= pre_p1_0 when (mid_id2b2 = "00") else
				  pre_p1_1 when (mid_id2b2 = "01") else
				  pre_p1_2 when (mid_id2b2 = "10") else
				  pre_p1_3;

	
	RGTR43: reg32 generic map  (length => 32)
				 port map (d => imid_mult2, clk => clk, WE => '1',
						   q => mid_mult2);
	RGTR44: reg32 generic map  (length => 32)
				 port map (d => imid_p0, clk => clk, WE => '1',
						   q => mid_p0);
	RGTR45: reg32 generic map  (length => 32)
				 port map (d => imid_p1, clk => clk, WE => '1',
						   q => mid_p1);
	RGTR46: reg32 generic map  (length => 32)
				 port map (d => vin9, clk => clk, WE => '1',
						   q => vin10);
	RGTR47: regBits generic map  (length => 2)
				 port map (d => mid_id2b2, clk => clk, q => mid_id2b3);
	RGTR48: regBit port map (d => pre_menorzero8, clk => clk, q => pre_menorzero9);
	RGTR49: reg32 generic map  (length => 32)
				 port map (d => mid_demux1, clk => clk, WE => '1',
						   q => mid_demux12);
						   
				  
	--mid_mult3  <= mid_mult2 * mid_p0;
	MLT6: multiplicacao port map (clk => clk, Ain => mid_mult2,
								  Bin => mid_p0, Cout => imid_mult3);	
	--mid_mult4  <= mid_demux1 * mid_p1;
	MLT7: multiplicacao port map (clk => clk, Ain => mid_demux12,
								  Bin => mid_p1, Cout => imid_mult4);
	ipre_p2_0 <= p2_0l when(pre_menorzero9 = '0') else p2_0h;
	ipre_p2_1 <= p2_1l when(pre_menorzero9 = '0') else p2_1h;
	ipre_p2_2 <= p2_2l when(pre_menorzero9 = '0') else p2_2h;
	ipre_p2_3 <= p2_3l when(pre_menorzero9 = '0') else p2_3h;
	
	
	RGTR50: reg32 generic map  (length => 32)
				 port map (d => imid_mult3, clk => clk, WE => '1',
						   q => mid_mult3);
	RGTR51: reg32 generic map  (length => 32)
				 port map (d => imid_mult4, clk => clk, WE => '1',
						   q => mid_mult4);
	RGTR52: reg32 generic map  (length => 32)
				 port map (d => ipre_p2_0, clk => clk, WE => '1',
						   q => pre_p2_0);
	RGTR53: reg32 generic map  (length => 32)
				 port map (d => ipre_p2_1, clk => clk, WE => '1',
						   q => pre_p2_1);
	RGTR54: reg32 generic map  (length => 32)
				 port map (d => ipre_p2_2, clk => clk, WE => '1',
						   q => pre_p2_2);
	RGTR55: reg32 generic map  (length => 32)
				 port map (d => ipre_p2_3, clk => clk, WE => '1',
						   q => pre_p2_3);
	RGTR56: reg32 generic map  (length => 32)
				 port map (d => vin10, clk => clk, WE => '1',
						   q => vin11);
	RGTR57: regBits generic map  (length => 2)
				 port map (d => mid_id2b3, clk => clk, q => mid_id2b4);
						   
	
	-- mid_add2 <= mid_mult3 + mid_mult4;
	ADD3: soma port map (clk => clk, Ain => mid_mult3,
						 Bin => mid_mult4, Cout => imid_add2);
	imid_p2     <= pre_p2_0 when (mid_id2b4 = "00") else
				  pre_p2_1 when (mid_id2b4 = "01") else
				  pre_p2_2 when (mid_id2b4 = "10") else
				  pre_p2_3;
	
	
	RGTR58: reg32 generic map  (length => 32)
				 port map (d => imid_add2, clk => clk, WE => '1',
						   q => mid_add2);
	RGTR59: reg32 generic map  (length => 32)
				 port map (d => imid_p2, clk => clk, WE => '1',
						   q => mid_p2);
	RGTR60: reg32 generic map  (length => 32)
				 port map (d => vin11, clk => clk, WE => '1',
						   q => vin12);
						   
	
	-- mid_add3   <= mid_add2 + mid_p2;
	ADD4: soma port map (clk => clk, Ain => mid_add2,
						 Bin => mid_p2, Cout => imid_add3);
	-- compare5 <= log10_out < lessvalue
	CMPR5: subtracao port map (clk => clk, Ain => vin12,
							   Bin => lessvalue, Cout => icompare5);
	-- compare6 <= log10_out > highvalue <-> highvalue < log10_out
	CMPR6: subtracao port map (clk => clk, Ain => highvalue,
							   Bin => vin12, Cout => icompare6);
	

	RGTR61: reg32 generic map  (length => 32)
				 port map (d => imid_add3, clk => clk, WE => '1',
						   q => mid_add3);
	RGTR62: reg32 generic map  (length => 32)
				 port map (d => icompare5, clk => clk, WE => '1',
						   q => compare5);
	RGTR63: reg32 generic map  (length => 32)
				 port map (d => icompare6, clk => clk, WE => '1',
						   q => compare6);
	RGTR64: reg32 generic map  (length => 32)
				 port map (d => vin12, clk => clk, WE => '1',
						   q => vin13);
						   
							
	vout <= minusfour when(compare5(31) = '1') else
			minusfour when(vin13 = lessvalue) else
			four      when(vin13 = highvalue) else
			four      when(compare6(31) = '1') else
			mid_add3;
			
ssh : process (clk)
	
	begin
		if rising_edge(clk) then

		end if; -- rising_edge(clk)
	end process ssh;
end ssh;
