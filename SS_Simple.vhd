library IEEE;
library IEEE_PROPOSED;
library work;
--use ieee.float_pkg_c.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use IEEE_PROPOSED.float_pkg.all;

entity segmentedsplineOptimusSimple is
	port(
		clk:     in std_logic;
		vin_slv:  in STD_logic_vector(31 downto 0);
		
		vout: out STD_logic_vector(31 downto 0)
	);
end segmentedsplineOptimusSimple; 

architecture ssh of segmentedsplineOptimusSimple is 

signal s_vout: STD_logic_vector(31 downto 0);
signal conect_entradaslv, conect_saidaslv: STD_logic_vector(31 downto 0);
signal conect_entradaf32, conect_saidaf32: float32;


signal log10_slvin: STD_logic_vector(31 downto 0);
signal log10_and1: STD_logic_vector(31 downto 0);
signal log10_or1 : STD_logic_vector(31 downto 0);
signal log10_in, log10_out                  : float32;
signal log10_or2                            : float32;
signal log10_add1                           : float32;
signal log10_sub1,  log10_sub2,  log10_sub3 : float32;
signal log10_mult1, log10_mult2, log10_mult3: float32;
signal log10_div1                           : float32;
signal log10_tofloat1                       : float32;


signal pre_menorzero : bit; 
signal pre_numerador, pre_denominador, pre_p0_0, pre_p0_1, pre_p0_2, pre_p0_3, pre_p1_0, pre_p1_1, pre_p1_2, pre_p1_3, pre_p2_0, pre_p2_1, pre_p2_2, pre_p2_3 : float32;


signal mid_sum1, mid_add2, mid_add3              : float32;
signal mid_sub1, mid_sub2, mid_sub3              : float32;
signal mid_mult1,mid_mult2, mid_mult3, mid_mult4 : float32;
signal mid_div1                                  : float32;
signal mid_demux1                                : float32;
signal mid_p0, mid_p1, mid_p2                    : float32;
signal mid_id2b : bit_vector(1 downto 0);


signal prepow, pow_in : float32;


signal pow_add1, pow_add2, pow_add3                               : float32;
signal pow_sub1, pow_sub2, pow_sub3, pow_sub4, pow_sub5           : float32;
signal pow_mult1, pow_mult2, pow_mult3                            : float32;
signal pow_div1                                                   : float32;
signal pow_demux1                                                 : bit;     
signal pow_demux2, pow_demux3, pow_demux4, pow_demux5             : float32;
signal pow_f2i_in                                                 : float32;
signal pow_out  : STD_logic_vector(31 downto 0);


signal pow_f2i_slv : STD_logic_vector(31 downto 0);
signal f2i_00      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_01      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_02      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_03      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_04      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_05      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_06      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_07      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_08      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_09      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_10      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_11      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_12      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_13      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_14      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_15      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_16      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_17      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_18      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_19      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_20      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_21      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_22      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_23      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_24      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_25      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_26      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_27      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_28      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_29      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_30      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_31      : STD_logic_vector(31 downto 0) := (others => '0');
signal f2i_or1     : STD_logic_vector( 4 downto 0) := (others => '0');
signal f2i_e       : STD_logic_vector(30 downto 23) := (others => '0');
signal f2i_m       : STD_logic_vector(22 downto 0) := (others => '0');
signal f2i_or2     : STD_logic_vector(31 downto 0);
signal f2i_demux1  : STD_logic_vector(31 downto 0);
signal f2i_demux2  : STD_logic_vector(31 downto 0);
signal f2i_demux3  : float32;
signal f2i_f32     : float32;






--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------- CONSTANTES -----------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
constant zero        : float32 := "00000000000000000000000000000000";
constant menorvalor  : float32 := "00111000100000000000000000000000";
constant mantissa : std_logic_vector(31 downto 0) := "00000000011111111111111111111111";
constant midexp   : std_logic_vector(31 downto 0) := "00111111000000000000000000000000";
constant yv1         : float32 := "01000010111110000111001101101110";
constant yv2         : float32 := "00111111101111111011111101110101";
constant yv3         : float32 := "00111111110111001110100110100011";
constant yv4         : float32 := "00111110101101000100010011111001";
constant inv_log2_10 : float32 := "00111110100110100010000010011011";
constant ymult       : float32 := "00110100000000000000000000000000";
constant numLow      : float32 := "01000000101010000101001101100000";
constant denLow      : float32 := "01000000100100000111111010010001";
constant three       : float32 := "01000000010000000000000000000000";
constant one         : float32 := "00111111100000000000000000000000";
constant two         : float32 := "01000000000000000000000000000000";
constant dot_five    : float32 := "00111111000000000000000000000000";
constant numHigh     : float32 := "00111111001111101010011001110110";
constant denHigh     : float32 := "01000000101011010110010010101110";
constant p0_0l       : float32 := "00111110110101111011011000101100";
constant p1_0l       : float32 := "10111111110010100001001001110101";
constant p2_0l       : float32 := "11000000000000000000000000000000";
constant p0_1l       : float32 := "00111111011010100010110100101000";
constant p1_1l       : float32 := "00111111000110011001100110000000";
constant p2_1l       : float32 := "11000000000000000000000000000000";
constant p0_2l       : float32 := "10111110001011011010010001001100";
constant p1_2l       : float32 := "01000000011001100010010010111111";
constant p2_2l       : float32 := "10111111110010100001001001110101";
constant p0_3l       : float32 := "10111111100101010100111110010100";
constant p1_3l       : float32 := "01000000010100000111000000110110";
constant p2_3l       : float32 := "10111110011110000111001010110000";
constant p0_0h       : float32 := "10111111000110110011001010111000";
constant p1_0h       : float32 := "01000000100101000100011011001010";
constant p2_0h       : float32 := "10111110101101111111001011000111";
constant p0_1h       : float32 := "10111111001000001010101011111000";
constant p1_1h       : float32 := "01000000011001011001001011110001";
constant p2_1h       : float32 := "00111111100001010010111110011011";
constant p0_2h       : float32 := "10111110001010011110101110100000";
constant p1_2h       : float32 := "01000000000101010011110101110100";
constant p2_2h       : float32 := "00111111111010101100001010001100";
constant p0_3h       : float32 := "00000000000000000000000000000000";
constant p1_3h       : float32 := "01000000000000000000000000000000";
constant p2_3h       : float32 := "01000000000000000000000000000000";
constant lessvalue   : float32 := "11000000101010000101001101100000";
constant minusfour   : float32 := "11000000100000000000000000000000";
constant midvalue    : float32 := "10111111001111101010011001110110";
constant highvalue   : float32 := "01000000100101011000111111011111";
constant four        : float32 := "01000000100000000000000000000000";
constant pc2         : float32 := "01000000010101001001101001111000";
constant five        : float32 := "01000000101000000000000000000000";
constant six         : float32 := "01000000110000000000000000000000";
constant seven       : float32 := "01000000111000000000000000000000";
constant eight       : float32 := "01000001000000000000000000000000";
constant nine        : float32 := "01000001000100000000000000000000";
constant ten         : float32 := "01000001001000000000000000000000";
constant eleven      : float32 := "01000001001100000000000000000000";
constant twelve      : float32 := "01000001010000000000000000000000";
constant thirteen    : float32 := "01000001010100000000000000000000";
constant pc3         : float32 := "01000000100110101111010111111000";
constant pc4         : float32 := "01000001110111011101001011111110";
constant pc5         : float32 := "00111111101111101011110010001101";
constant pc6         : float32 := "01000010111100101000110001010101";
constant pc7         : float32 := "01001011000000000000000000000000";

begin

	------------------------------------------------------------
	------------------------------------------------------------
		-- PRE LOG --
				conect_entradaf32 <= to_float(conect_entradaslv);
				log10_in <= menorvalor when (conect_entradaf32 < zero) else
										menorvalor when (conect_entradaf32 = zero) else
										conect_entradaf32;
		-- PRE LOG --
	------------------------------------------------------------
	------------------------------------------------------------
		
	

	------------------------------------------------------------
	------------------------------------------------------------
		-- BASE 10 LOGARITHM --
				log10_slvin    <= to_slv(log10_in);
				log10_and1     <= log10_slvin and mantissa;
				log10_or1      <= log10_and1  or midexp;
				log10_or2      <= to_float(log10_or1);
				log10_mult1    <= yv2 * log10_or2;
				log10_add1     <= yv4 + log10_or2;
				log10_div1     <= yv3 / log10_add1;
				log10_tofloat1 <= to_float2(to_integer(unsigned(log10_slvin)));
				log10_mult2    <= ymult * log10_tofloat1;
				log10_sub1     <= log10_mult2 - yv1;
				log10_sub2     <= log10_sub1 - log10_mult1;
				log10_sub3     <= log10_sub2 - log10_div1;
				log10_mult3    <= log10_sub3 * inv_log2_10;
				log10_out      <= log10_mult3;
		-- BASE 10 LOGARITHM --
	------------------------------------------------------------
	------------------------------------------------------------



	------------------------------------------------------------
	------------------------------------------------------------
		-- PRE MID BLOCK --
				pre_menorzero   <= '0'    when (log10_out < zero)   else '1';
				pre_numerador   <= numLow when(pre_menorzero = '0') else numHigh;
				pre_denominador <= denLow when(pre_menorzero = '0') else denHigh;
				pre_p0_0 <= p0_0l when(pre_menorzero = '0') else p0_0h;
				pre_p0_1 <= p0_1l when(pre_menorzero = '0') else p0_1h;
				pre_p0_2 <= p0_2l when(pre_menorzero = '0') else p0_2h;
				pre_p0_3 <= p0_3l when(pre_menorzero = '0') else p0_3h;
				pre_p1_0 <= p1_0l when(pre_menorzero = '0') else p1_0h;
				pre_p1_1 <= p1_1l when(pre_menorzero = '0') else p1_1h;
				pre_p1_2 <= p1_2l when(pre_menorzero = '0') else p1_2h;
				pre_p1_3 <= p1_3l when(pre_menorzero = '0') else p1_3h;
				pre_p2_0 <= p2_0l when(pre_menorzero = '0') else p2_0h;
				pre_p2_1 <= p2_1l when(pre_menorzero = '0') else p2_1h;
				pre_p2_2 <= p2_2l when(pre_menorzero = '0') else p2_2h;
				pre_p2_3 <= p2_3l when(pre_menorzero = '0') else p2_3h;
		-- PRE MID BLOCK --
	------------------------------------------------------------
	------------------------------------------------------------



	------------------------------------------------------------
	------------------------------------------------------------
		-- MID BLOCK --
				mid_sum1   <= log10_out + pre_numerador;
				mid_mult1  <= mid_sum1 * three;
				mid_div1   <= mid_mult1 / pre_denominador;
				mid_id2b   <= "00" when (mid_div1 < one)   else
										  "01" when (mid_div1 < two)   else
										  "10" when (mid_div1 < three) else
										  "11";
				mid_sub1   <= mid_div1 - one;
				mid_sub2   <= mid_div1 - two;
				mid_sub3   <= mid_div1 - three;
				mid_demux1 <= mid_div1 when (mid_id2b = "00") else
											mid_sub1 when (mid_id2b = "01") else
											mid_sub2 when (mid_id2b = "10") else
											mid_sub3;
				mid_p0     <= pre_p0_0 when (mid_id2b = "00") else
											pre_p0_1 when (mid_id2b = "01") else
											pre_p0_2 when (mid_id2b = "10") else
											pre_p0_3;
				mid_p1     <= pre_p1_0 when (mid_id2b = "00") else
											pre_p1_1 when (mid_id2b = "01") else
											pre_p1_2 when (mid_id2b = "10") else
											pre_p1_3;
				mid_p2     <= pre_p2_0 when (mid_id2b = "00") else
											pre_p2_1 when (mid_id2b = "01") else
											pre_p2_2 when (mid_id2b = "10") else
											pre_p2_3;
				mid_mult2  <= mid_demux1 * mid_demux1;
				mid_mult3  <= mid_mult2 * mid_p0;
				mid_mult4  <= mid_demux1 * mid_p1;
				mid_add2   <= mid_mult3 + mid_mult4;
				mid_add3   <= mid_add2 + mid_p2;
				prepow     <= mid_add3;
		-- MID BLOCK --
	------------------------------------------------------------
	------------------------------------------------------------
	
	
	
	------------------------------------------------------------
	------------------------------------------------------------
		-- PRE POW --
				pow_in <= minusfour when(log10_out < lessvalue) else
									minusfour when(log10_out = lessvalue) else
									four      when(log10_out = highvalue) else
									four      when(log10_out > highvalue) else
									prepow;
		-- PRE POW --
	------------------------------------------------------------
	------------------------------------------------------------
	
	
	
	------------------------------------------------------------
	------------------------------------------------------------
		-- BASE 10 POWER --
				pow_mult1  <= pow_in * pc2;
				pow_demux1 <= '1' when (pow_mult1 < zero) else '0';
				pow_sub1   <= zero - pow_mult1;
				pow_demux2 <= pow_sub1 when (pow_demux1 = '1') else pow_mult1;
				pow_demux3 <= one when (pow_demux1 = '1') else zero;
				pow_demux4 <= zero   when (pow_demux2 < one)      else
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
				pow_sub2   <= zero - pow_demux4;
				pow_demux5 <= pow_sub2 when (pow_demux1 = '1') else pow_demux4;
				pow_sub3   <= pow_mult1 - pow_demux5;
				pow_add1   <= pow_demux3 + pow_sub3; 
				pow_sub4   <= pc3 - pow_add1;
				pow_div1   <= pc4 / pow_sub4;
				pow_mult2  <= pc5 * pow_add1;
				pow_add2   <= pc6 + pow_mult1;
				pow_add3   <= pow_add2 + pow_div1;
				pow_sub5   <= pow_add3 - pow_mult2;
				pow_mult3  <= pow_sub5 * pc7;
				pow_f2i_in <= pow_mult3;
				
				-- FLOAT TO INT --
				pow_f2i_slv <= to_slv(pow_f2i_in);
				f2i_00(          0) <= pow_f2i_slv(22          );
				f2i_01( 1 downto 0) <= pow_f2i_slv(22 downto 21);
				f2i_02( 2 downto 0) <= pow_f2i_slv(22 downto 20);
				f2i_03( 3 downto 0) <= pow_f2i_slv(22 downto 19);
				f2i_04( 4 downto 0) <= pow_f2i_slv(22 downto 18);
				f2i_05( 5 downto 0) <= pow_f2i_slv(22 downto 17);
				f2i_06( 6 downto 0) <= pow_f2i_slv(22 downto 16);
				f2i_07( 7 downto 0) <= pow_f2i_slv(22 downto 15);
				f2i_08( 8 downto 0) <= pow_f2i_slv(22 downto 14);
				f2i_09( 9 downto 0) <= pow_f2i_slv(22 downto 13);
				f2i_10(10 downto 0) <= pow_f2i_slv(22 downto 12);
				f2i_11(11 downto 0) <= pow_f2i_slv(22 downto 11);
				f2i_12(12 downto 0) <= pow_f2i_slv(22 downto 10);
				f2i_13(13 downto 0) <= pow_f2i_slv(22 downto  9);
				f2i_14(14 downto 0) <= pow_f2i_slv(22 downto  8);
				f2i_15(15 downto 0) <= pow_f2i_slv(22 downto  7);
				f2i_16(16 downto 0) <= pow_f2i_slv(22 downto  6);
				f2i_17(17 downto 0) <= pow_f2i_slv(22 downto  5);
				f2i_18(18 downto 0) <= pow_f2i_slv(22 downto  4);
				f2i_19(19 downto 0) <= pow_f2i_slv(22 downto  3);
				f2i_20(20 downto 0) <= pow_f2i_slv(22 downto  2);
				f2i_21(21 downto 0) <= pow_f2i_slv(22 downto  1);
				f2i_22(22 downto 0) <= pow_f2i_slv(22 downto  0);
				f2i_23(23 downto 1) <= pow_f2i_slv(22 downto  0);
				f2i_24(24 downto 2) <= pow_f2i_slv(22 downto  0);
				f2i_25(25 downto 3) <= pow_f2i_slv(22 downto  0);
				f2i_26(26 downto 4) <= pow_f2i_slv(22 downto  0);
				f2i_27(27 downto 5) <= pow_f2i_slv(22 downto  0);
				f2i_28(28 downto 6) <= pow_f2i_slv(22 downto  0);
				f2i_29(29 downto 7) <= pow_f2i_slv(22 downto  0);
				f2i_30(30 downto 8) <= pow_f2i_slv(22 downto  0);
				f2i_31(31 downto 9) <= pow_f2i_slv(22 downto  0);
				f2i_or1(4 downto 0) <= pow_f2i_slv(27 downto 23);
				f2i_demux1 <= f2i_00 when(f2i_or1 = "00000") else
											f2i_01 when(f2i_or1 = "00001") else
											f2i_02 when(f2i_or1 = "00010") else
											f2i_03 when(f2i_or1 = "00011") else
											f2i_04 when(f2i_or1 = "00100") else
											f2i_05 when(f2i_or1 = "00101") else
											f2i_06 when(f2i_or1 = "00110") else
											f2i_07 when(f2i_or1 = "00111") else
											f2i_08 when(f2i_or1 = "01000") else
											f2i_09 when(f2i_or1 = "01001") else
											f2i_10 when(f2i_or1 = "01010") else
											f2i_11 when(f2i_or1 = "01011") else
											f2i_12 when(f2i_or1 = "01100") else
											f2i_13 when(f2i_or1 = "01101") else
											f2i_14 when(f2i_or1 = "01110") else
											f2i_15 when(f2i_or1 = "01111") else
											f2i_16 when(f2i_or1 = "10000") else
											f2i_17 when(f2i_or1 = "10001") else
											f2i_18 when(f2i_or1 = "10010") else
											f2i_19 when(f2i_or1 = "10011") else
											f2i_20 when(f2i_or1 = "10100") else
											f2i_21 when(f2i_or1 = "10101") else
											f2i_22 when(f2i_or1 = "10110") else
											f2i_23 when(f2i_or1 = "10111") else
											f2i_24 when(f2i_or1 = "11000") else
											f2i_25 when(f2i_or1 = "11001") else
											f2i_26 when(f2i_or1 = "11010") else
											f2i_27 when(f2i_or1 = "11011") else
											f2i_28 when(f2i_or1 = "11100") else
											f2i_29 when(f2i_or1 = "11101") else
											f2i_30 when(f2i_or1 = "11110") else
											f2i_31;-- when(f2i_or1 = "11111")
				f2i_demux2 <= "00000000000000000000000000000010" when(f2i_or1 = "00000") else
											"00000000000000000000000000000100" when(f2i_or1 = "00001") else 
											"00000000000000000000000000001000" when(f2i_or1 = "00010") else 
											"00000000000000000000000000010000" when(f2i_or1 = "00011") else 
											"00000000000000000000000000100000" when(f2i_or1 = "00100") else 
											"00000000000000000000000001000000" when(f2i_or1 = "00101") else 
											"00000000000000000000000010000000" when(f2i_or1 = "00110") else 
											"00000000000000000000000100000000" when(f2i_or1 = "00111") else 
											"00000000000000000000001000000000" when(f2i_or1 = "01000") else 
											"00000000000000000000010000000000" when(f2i_or1 = "01001") else 
											"00000000000000000000100000000000" when(f2i_or1 = "01010") else 
											"00000000000000000001000000000000" when(f2i_or1 = "01011") else 
											"00000000000000000010000000000000" when(f2i_or1 = "01100") else 
											"00000000000000000100000000000000" when(f2i_or1 = "01101") else 
											"00000000000000001000000000000000" when(f2i_or1 = "01110") else 
											"00000000000000010000000000000000" when(f2i_or1 = "01111") else 
											"00000000000000100000000000000000" when(f2i_or1 = "10000") else 
											"00000000000001000000000000000000" when(f2i_or1 = "10001") else 
											"00000000000010000000000000000000" when(f2i_or1 = "10010") else 
											"00000000000100000000000000000000" when(f2i_or1 = "10011") else 
											"00000000001000000000000000000000" when(f2i_or1 = "10100") else 
											"00000000010000000000000000000000" when(f2i_or1 = "10101") else 
											"00000000100000000000000000000000" when(f2i_or1 = "10110") else 
											"00000001000000000000000000000000" when(f2i_or1 = "10111") else 
											"00000010000000000000000000000000" when(f2i_or1 = "11000") else 
											"00000100000000000000000000000000" when(f2i_or1 = "11001") else 
											"00001000000000000000000000000000" when(f2i_or1 = "11010") else 
											"00010000000000000000000000000000" when(f2i_or1 = "11011") else 
											"00100000000000000000000000000000" when(f2i_or1 = "11100") else 
											"01000000000000000000000000000000" when(f2i_or1 = "11101") else 
											"10000000000000000000000000000000" when(f2i_or1 = "11110") else  
											"00000000000000000000000000000001";-- when(f2i_or1 = "11111")
				f2i_or2 <= f2i_demux1 or f2i_demux2;
				f2i_f32 <= to_float(f2i_or2);
				f2i_e   <= pow_f2i_slv(30 downto 23);
				f2i_m   <= pow_f2i_slv(22 downto  0);
				f2i_demux3 <= zero when ((f2i_e="00000000")and(f2i_m="00000000000000000000000"))else
											one  when ( f2i_e="01111111") else
											f2i_f32; 
				-- FLOAT TO INT --
				pow_out <= to_slv(f2i_demux3);
		-- BASE 10 POWER --
	------------------------------------------------------------
	------------------------------------------------------------
	

ssh : process (clk)
	
	begin
		
		if rising_edge(clk) then
		
			conect_entradaslv <= vin_slv;
			s_vout <= pow_out;
			
		end if; -- rising_edge(clk)
	
	end process ssh;

	vout <= s_vout;
		
end ssh;
